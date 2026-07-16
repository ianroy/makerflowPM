#!/usr/bin/env bash
# One-shot DigitalOcean bring-up for the MakerFlow PM demo (DEPLOY.md, scripted).
#
#   doctl auth init                      # once, with your DO API token
#   makerflow_dart/deploy/do_deploy.sh   # everything else
#
# What it does on first run:
#   1. generates SERVICE_SECRET + SEED_ADMIN_PASSWORD and substitutes them into
#      a TEMP copy of .do/app.yaml (nothing secret ever lands in git),
#   2. `doctl apps create --spec ... --wait` (builds the API + web images,
#      provisions managed PG 17 + Valkey; first build ~10-25 min),
#   3. re-updates the app with MAKERFLOW_API=https://<domain>/api/ so the web
#      bundle rebuilds against its own domain,
#   4. verifies GET /api/ and GET / return 200,
#   5. prints the demo URL + the owner login (STORE THE PASSWORD — it is
#      shown exactly once; the seed itself runs as the app's POST_DEPLOY job).
#
# Re-running against an existing app: verifies it and finishes the
# MAKERFLOW_API wiring if that is still a placeholder; it never rotates
# existing secrets. Day-to-day redeploys need nothing here — every push to
# `staging` redeploys automatically.
set -euo pipefail

APP_NAME="makerflow-dart"
repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
SPEC="$repo_root/makerflow_dart/.do/app.yaml"

say()  { printf '\n==> %s\n' "$*"; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

command -v doctl >/dev/null || die "doctl not installed (brew install doctl)"
doctl account get >/dev/null 2>&1 \
  || die "doctl is not authenticated — run: doctl auth init (token from cloud.digitalocean.com → API → Tokens)"
[ -f "$SPEC" ] || die "spec not found at $SPEC"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

app_id="$(doctl apps list --format ID,Spec.Name --no-header | awk -v n="$APP_NAME" '$2==n{print $1}' | head -1)"

if [ -z "$app_id" ]; then
  say "Creating app '$APP_NAME' (managed PG 17 + Valkey + two images — first build takes 10–25 min)"
  grep -q 'REPLACE_WITH_64_CHAR_SECRET' "$SPEC" || die "spec drifted: SERVICE_SECRET placeholder not found"
  grep -q 'REPLACE_WITH_STRONG_PASSWORD' "$SPEC" || die "spec drifted: SEED_ADMIN_PASSWORD placeholder not found"

  service_secret="$(openssl rand -hex 32)"
  seed_password="$(openssl rand -base64 18 | tr '+/' '-_')"

  sed -e "s|REPLACE_WITH_64_CHAR_SECRET|$service_secret|g" \
      -e "s|REPLACE_WITH_STRONG_PASSWORD|$seed_password|g" \
      "$SPEC" > "$work/app.yaml"

  doctl apps create --spec "$work/app.yaml" --wait
  app_id="$(doctl apps list --format ID,Spec.Name --no-header | awk -v n="$APP_NAME" '$2==n{print $1}' | head -1)"
  [ -n "$app_id" ] || die "app created but not found by name '$APP_NAME'"
else
  say "App '$APP_NAME' already exists ($app_id) — verifying + finishing wiring only (secrets untouched)"
  seed_password=""  # unknown here by design; it was printed when first created
fi

domain="$(doctl apps get "$app_id" --format DefaultIngress --no-header | sed 's|^https\?://||; s|/$||')"
[ -n "$domain" ] || die "could not read the app's default ingress domain"
api_base="https://$domain/api/"
say "App domain: https://$domain"

# Wire the web bundle to its own domain (needs a second build — the domain
# doesn't exist before the first create). Works off the DEPLOYED spec so
# already-encrypted secrets pass through untouched.
current_spec="$work/current.yaml"
doctl apps spec get "$app_id" > "$current_spec"
if grep -q 'REPLACE_WITH_https' "$current_spec"; then
  say "Setting MAKERFLOW_API=$api_base and rebuilding the web bundle (~5–10 min)"
  sed -e "s|REPLACE_WITH_https://<app-domain>/api/|$api_base|g" "$current_spec" > "$work/wired.yaml"
  doctl apps update "$app_id" --spec "$work/wired.yaml" --wait
else
  say "MAKERFLOW_API already wired"
fi

say "Verifying"
api_code="$(curl -m 30 -sS -o /dev/null -w '%{http_code}' "https://$domain/api/" || true)"
web_code="$(curl -m 30 -sS -o /dev/null -w '%{http_code}' "https://$domain/" || true)"
printf '  GET /api/ -> %s (expect 200, Serverpod liveness)\n' "$api_code"
printf '  GET /     -> %s (expect 200, the web demo)\n' "$web_code"
[ "$api_code" = "200" ] || die "API liveness failed — check: doctl apps logs $app_id api --type run"
[ "$web_code" = "200" ] || die "web demo failed — check: doctl apps logs $app_id webapp --type build"

say "Done — the demo is live"
printf '  URL:    https://%s\n' "$domain"
printf '  Login:  admin@makerflow.local\n'
if [ -n "$seed_password" ]; then
  printf '  Password (shown ONCE — store it now): %s\n' "$seed_password"
else
  printf '  Password: unchanged (set when the app was first created)\n'
fi
printf '\nEvery push to `staging` redeploys automatically. Logs:\n'
printf '  doctl apps logs %s api --type run --follow\n' "$app_id"

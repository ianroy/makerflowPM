#!/bin/sh
# Container entrypoint. Serverpod 3.x reads DB/Redis from config/<mode>.yaml and
# secrets from config/passwords.yaml — neither of which we bake into the image.
# DigitalOcean App Platform injects the managed-DB binding vars + secrets as env;
# we render the config files from them here, then apply migrations and serve.
set -eu

mode="${SERVERPOD_RUN_MODE:-production}"

: "${DATABASE_HOST:?DATABASE_HOST is required}"
: "${DATABASE_NAME:?DATABASE_NAME is required}"
: "${DATABASE_USER:?DATABASE_USER is required}"
: "${DATABASE_PASSWORD:?DATABASE_PASSWORD is required}"
: "${SERVICE_SECRET:?SERVICE_SECRET is required}"

cat > "/app/config/passwords.yaml" <<EOF
$mode:
  database: '${DATABASE_PASSWORD}'
  redis: '${REDIS_PASSWORD:-}'
  serviceSecret: '${SERVICE_SECRET}'
EOF
# serverpod_auth reads an optional pepper for email/password hashing. Set it
# BEFORE the first production users exist — it cannot be rotated later without
# invalidating stored credentials.
if [ -n "${EMAIL_PASSWORD_PEPPER:-}" ]; then
  printf "  emailPasswordPepper: '%s'\n" "${EMAIL_PASSWORD_PEPPER}" >> /app/config/passwords.yaml
fi

cat > "/app/config/${mode}.yaml" <<EOF
apiServer:
  port: 8080
  publicHost: ${PUBLIC_HOST:-localhost}
  publicPort: 443
  publicScheme: https
insightsServer:
  port: 8081
  publicHost: ${PUBLIC_HOST:-localhost}
  publicPort: 443
  publicScheme: https
webServer:
  port: 8082
  publicHost: ${PUBLIC_HOST:-localhost}
  publicPort: 443
  publicScheme: https
database:
  host: ${DATABASE_HOST}
  port: ${DATABASE_PORT:-5432}
  name: ${DATABASE_NAME}
  user: ${DATABASE_USER}
  requireSsl: ${DATABASE_REQUIRE_SSL:-true}
redis:
  enabled: ${REDIS_ENABLED:-true}
  host: ${REDIS_HOST:-localhost}
  port: ${REDIS_PORT:-6379}
  user: ${REDIS_USER:-default}
  requireSsl: ${REDIS_REQUIRE_SSL:-true}
EOF

# Dispatch on the first arg. DigitalOcean starts the container with no args, so
# the default ("serve") is what runs in normal operation; `seed` is for a manual
# one-off via the console. Config is rendered above either way, so seeding works
# whether invoked through this entrypoint or by calling /app/server directly.
case "${1:-serve}" in
  serve)
    # Apply pending migrations on boot, then serve (single-instance monolith).
    # For multi-instance, run migrations once via a separate `--role maintenance`
    # job and drop --apply-migrations here.
    exec /app/server --mode "$mode" --apply-migrations --role monolith
    ;;
  seed)
    # Create the first org + owner + sample data, then exit. Idempotent (a
    # no-op once the default org exists) and never starts the HTTP servers, so
    # it is safe alongside a running monolith. Runs automatically as the
    # app's POST_DEPLOY job (.do/app.yaml) and manually via the console.
    #
    # Guard: never create a PUBLIC owner account with a missing/placeholder
    # password. Skip (exit 0) rather than fail, so a deployment created
    # without the secret still goes live — seed later once it's set.
    if [ "$mode" = "production" ]; then
      case "${SEED_ADMIN_PASSWORD:-}" in
        ""|REPLACE_WITH_*)
          echo "entrypoint: SEED_ADMIN_PASSWORD is unset or a placeholder — skipping seed (set it and redeploy or re-run seed)" >&2
          exit 0
          ;;
      esac
    fi
    exec /app/server --mode "$mode" --seed
    ;;
  *)
    echo "entrypoint: unknown command '$1' (expected: serve | seed)" >&2
    exit 64
    ;;
esac

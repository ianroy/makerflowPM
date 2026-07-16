# Deploying the MakerFlow PM Dart rebuild to DigitalOcean

The **full demo** ships to **DigitalOcean App Platform**: the Serverpod API +
the Flutter web app on one domain, with managed PostgreSQL + Valkey. Everything
except the one-time `doctl` auth is prepared; this runbook is the exact
sequence to take it live and retire the local demo stack.

> **Status (2026-07-16):** spec updated for the demo cutover — two components
> (`api` + `webapp`) behind one domain (`/api` prefix stripped for Serverpod),
> seed password now env-driven (`SEED_ADMIN_PASSWORD`). Server image build
> (`dart compile exe`) green on current code; the web image
> ([`makerflow_flutter/Dockerfile.web`](makerflow_flutter/Dockerfile.web))
> gets its first build on DO (no local docker on this machine). The only thing
> that needs you is a DigitalOcean account + API token — the steps below are
> otherwise copy-paste.

---

## 0. What deploys, and from where

- **App spec:** [`.do/app.yaml`](.do/app.yaml) — TWO services on one domain:
  `api` (the Serverpod monolith, routed under **`/api`** with the prefix
  stripped) and `webapp` (nginx serving the Flutter web bundle at **`/`**,
  built in-platform by [`makerflow_flutter/Dockerfile.web`](makerflow_flutter/Dockerfile.web))
  + managed `makerflow-db` (PG 17) + `makerflow-redis` (**Valkey** — DO
  discontinued managed Redis in 2025; protocol-compatible, the `REDIS_*`
  bindings work unchanged).
- **Image:** [`makerflow_server/Dockerfile`](makerflow_server/Dockerfile) —
  multi-stage `dart compile exe` → `debian-slim`. Build context is
  `makerflow_dart/` (the server path-depends on `../makerflow_client` +
  `../makerflow_shared`).
- **Boot:** [`makerflow_server/deploy/entrypoint.sh`](makerflow_server/deploy/entrypoint.sh)
  renders `config/<mode>.yaml` + `config/passwords.yaml` from the env vars DO
  injects (managed-DB bindings + secrets), applies migrations, then serves.
- **Branch:** the spec deploys from **`staging`**. That's where the rebuild and
  these deploy assets live; `main` predates the Dockerfile/spec. For a
  production cutover, merge `staging → main` and flip `branch: main` in the spec.
- This is **independent** of the legacy Python app's [`/.do/app.yaml`](../.do/app.yaml)
  (a different DO app). Deploying the Dart app does not touch it.

---

## 1. One-time: install + authenticate doctl

```sh
brew install doctl                      # or: https://docs.digitalocean.com/reference/doctl/how-to/install/
doctl auth init                         # paste a token from https://cloud.digitalocean.com/account/api/tokens
doctl account get                       # sanity check
```

## 2. Generate the two secrets the spec needs

The spec binds DB/Redis credentials automatically from the managed components.
You supply Serverpod's `SERVICE_SECRET` and — because this deployment is
public — the seed's owner password:

```sh
openssl rand -hex 32                    # 64 hex chars -> SERVICE_SECRET
openssl rand -base64 18                 # -> SEED_ADMIN_PASSWORD (keep it!)
```

Set both after creation (step 4) as encrypted env vars on the `api` component
so they never land in git. **`SEED_ADMIN_PASSWORD` must be set before you run
the seed (step 6)** — without it the seed falls back to the well-known dev
password, which must never reach a public URL.

## 3. Create the app

```sh
cd /path/to/makerflowPM
doctl apps create --spec makerflow_dart/.do/app.yaml
doctl apps list                         # note the APP_ID
```

DO provisions the managed PG + Redis, builds the image from the Dockerfile, and
starts the service. First build ~5–8 min (Dart AOT compile + image).

## 4. Set the secrets

```sh
APP_ID=<from step 3>
# In the dashboard: App → Settings → api → Environment Variables → add
#   SERVICE_SECRET        (encrypted)  — from step 2
#   SEED_ADMIN_PASSWORD   (encrypted)  — from step 2
# or update the spec with the real values and:
doctl apps update "$APP_ID" --spec makerflow_dart/.do/app.yaml
```

## 5. Verify the API

```sh
doctl apps get "$APP_ID"                                  # status, default ingress URL
APP_URL=$(doctl apps get "$APP_ID" --format DefaultIngress --no-header)
curl -sS -o /dev/null -w "GET /api/ -> %{http_code}\n" "$APP_URL/api/"  # expect 200 (Serverpod liveness through the prefix)
doctl apps logs "$APP_ID" api --type run --follow          # watch boot + migration apply
```

Expected in the logs: the entrypoint renders the config, `--apply-migrations`
brings the schema up (56 tables), then `SERVERPOD ... started`.

## 6. Seed the first org + owner (once)

The image doesn't auto-seed (the serve path never touches the seed). After the
service is up (step 5 — migrations applied), run the seed once against the
managed DB via a one-off console. It's **idempotent** (a no-op if the `default`
org already exists) and does **not** start the HTTP servers, so it's safe to run
inside the already-serving `web` instance:

```sh
doctl apps console "$APP_ID" api
# in the console, either:
/app/server --mode production --seed     # config was already rendered on boot
# …or, to (re)render config from the injected env first (more robust):
/app/entrypoint.sh seed
```

This creates the default org, the owner login `admin@makerflow.local` with the
password from **`SEED_ADMIN_PASSWORD`** (verify it is set in the console:
`test -n "$SEED_ADMIN_PASSWORD" && echo ok` — without it the seed uses the
well-known dev password), a sample project, six tasks, and one equipment +
consumable row. Re-running prints `seed: "default" already exists — skipping`
and changes nothing.

> The same path runs in dev as `dart run bin/seed.dart`; `bin/seed.dart` and the
> runtime `--seed` flag share one `runSeed` bootstrap in `makerflow_server/lib/server.dart`.

## 7. Wire the web demo to its own domain (one-time)

The `webapp` component bakes the API base URL into the Flutter bundle at build
time, and the domain isn't known until the app exists — so after the first
create, set it and let DO rebuild the web component:

```sh
# In the dashboard: App → Settings → webapp → Environment Variables →
#   MAKERFLOW_API = https://<the DefaultIngress domain from step 5>/api/
# (scope: Build & Run) — or edit the spec's placeholder and:
doctl apps update "$APP_ID" --spec makerflow_dart/.do/app.yaml
```

When the rebuild finishes, `https://<domain>/` serves the demo UI and signs in
against `https://<domain>/api/` — the demo now lives entirely on DO and
redeploys on every push to `staging`.

## 8. Retire the local demo stack (optional)

```sh
kill $(lsof -ti tcp:8080) $(lsof -ti tcp:8085)             # local API + web
redis-cli -p 8091 -a makerflow_dev_redis shutdown nosave    # local Redis
pg_ctl -D /tmp/mf_pgdata stop                               # disposable local PG
```

For local development you can still bring the stack back any time
([`README.md`](README.md) bring-up); nothing about the DO app depends on it.

> Note: DO's Postgres starts from the seed — anything created only in the
> local demo (custom fields, saved views, test tasks) stays local. Recreate
> what you want in the live demo through the UI.

---

## Cost note

Both managed components are `production: false` (dev-tier) in the spec — fine
for a pilot. For production set `production: true` and a sized cluster; the web
service is `basic-xs`. Scaling to multiple instances means moving migrations out
of the boot path (run `--role maintenance --apply-migrations` as a separate job
and drop `--apply-migrations` from the entrypoint).

## What's verified locally vs. needs the live account

| Step | State |
|---|---|
| `dart compile exe` (API image build) | ✅ green on current code |
| `entrypoint.sh` renders config + serves in production mode | ✅ dry-run verified (prior session) |
| `entrypoint.sh` `serve`/`seed` dispatch | ✅ `sh -n` + traced both paths to a stub server |
| Spec is valid YAML, correct bindings | ✅ (revalidate live: `doctl apps spec validate makerflow_dart/.do/app.yaml`) |
| Migrations present + apply | ✅ (locally, via the compiled binary) |
| `--seed` creates org + owner + sample data, idempotent | ✅ compiled binary vs. local PG; owner password env-driven (`SEED_ADMIN_PASSWORD`) |
| Web image (`Dockerfile.web`: Flutter build → nginx) | ⏳ first build happens on DO (no local docker); the same `flutter build web` command is CI-green |
| Ingress split (`/` → webapp, `/api` → api w/ prefix strip) | ⏳ verified on first deploy (step 5 curl + sign-in) |
| Live `doctl apps create` + managed PG/Valkey | ⏳ needs your token (`doctl auth init`) |

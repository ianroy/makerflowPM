# Deploying the MakerFlow PM Dart rebuild to DigitalOcean

The Serverpod server ships as a container to **DigitalOcean App Platform** with
a managed PostgreSQL + Redis. Everything except the one-time `doctl` auth is
prepared and verified; this runbook is the exact sequence to take it live.

> **Status (2026-06-25):** spec valid, `dart compile exe` (the image build step)
> green on current code, `entrypoint.sh` syntax-checked, migrations present in
> the image, all five packages resolve. The only thing that needs you is a
> DigitalOcean account + API token — the steps below are otherwise copy-paste.

---

## 0. What deploys, and from where

- **App spec:** [`.do/app.yaml`](.do/app.yaml) — one web service (the Serverpod
  monolith) + managed `makerflow-db` (PG 16) + `makerflow-redis`.
- **Image:** [`makerflow_server/Dockerfile`](makerflow_server/Dockerfile) —
  multi-stage `dart compile exe` → `debian-slim`. Build context is
  `makerflow_dart/` (the server path-depends on `../makerflow_client` +
  `../makerflow_shared`).
- **Boot:** [`makerflow_server/deploy/entrypoint.sh`](makerflow_server/deploy/entrypoint.sh)
  renders `config/<mode>.yaml` + `config/passwords.yaml` from the env vars DO
  injects (managed-DB bindings + secrets), applies migrations, then serves.
- **Branch:** the spec deploys from **`staging`**. That's where the rebuild and
  these deploy assets live; `main` is ~10 commits behind and predates the
  Dockerfile/spec. For a production cutover, merge `staging → main` and flip
  `branch: main` in the spec.
- This is **independent** of the legacy Python app's [`/.do/app.yaml`](../.do/app.yaml)
  (a different DO app). Deploying the Dart app does not touch it.

---

## 1. One-time: install + authenticate doctl

```sh
brew install doctl                      # or: https://docs.digitalocean.com/reference/doctl/how-to/install/
doctl auth init                         # paste a token from https://cloud.digitalocean.com/account/api/tokens
doctl account get                       # sanity check
```

## 2. Generate the one secret the spec needs

The spec binds DB/Redis credentials automatically from the managed components.
The only secret you must supply is Serverpod's `SERVICE_SECRET`:

```sh
openssl rand -hex 32                    # 64 hex chars — copy this
```

Either paste it into `.do/app.yaml` (replacing `REPLACE_WITH_64_CHAR_SECRET`)
before creating the app, or set it after creation (step 4) so it never lands in
git. Setting it post-create is preferred.

## 3. Create the app

```sh
cd /path/to/makerflowPM
doctl apps create --spec makerflow_dart/.do/app.yaml
doctl apps list                         # note the APP_ID
```

DO provisions the managed PG + Redis, builds the image from the Dockerfile, and
starts the service. First build ~5–8 min (Dart AOT compile + image).

## 4. Set the service secret (if not inlined)

```sh
APP_ID=<from step 3>
# In the dashboard: App → Settings → web → Environment Variables → SERVICE_SECRET
# (encrypted), or update the spec with the real value and:
doctl apps update "$APP_ID" --spec makerflow_dart/.do/app.yaml
```

## 5. Verify

```sh
doctl apps get "$APP_ID"                                  # status, default ingress URL
APP_URL=$(doctl apps get "$APP_ID" --format DefaultIngress --no-header)
curl -sS -o /dev/null -w "GET / -> %{http_code}\n" "$APP_URL/"   # expect 200 (Serverpod liveness)
doctl apps logs "$APP_ID" --type run --follow              # watch boot + migration apply
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
doctl apps console "$APP_ID" web
# in the console, either:
/app/server --mode production --seed     # config was already rendered on boot
# …or, to (re)render config from the injected env first (more robust):
/app/entrypoint.sh seed
```

This creates the default org, the owner login `admin@makerflow.local`
(password `ChangeMeMeow!2026` — **rotate immediately**), a sample project, six
tasks, and one equipment + consumable row. Re-running prints
`seed: "default" already exists — skipping` and changes nothing.

> The same path runs in dev as `dart run bin/seed.dart`; `bin/seed.dart` and the
> runtime `--seed` flag share one `runSeed` bootstrap in `makerflow_server/lib/server.dart`.

## 7. Point the Flutter client at the deployment

Build the app against the live API:

```sh
flutter build web --release \
  --dart-define=MAKERFLOW_LIVE=true \
  --dart-define=MAKERFLOW_API=https://<your-app>.ondigitalocean.app/
```

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
| `dart compile exe` (image build) | ✅ green on current code (15 MB binary) |
| `entrypoint.sh` renders config + serves in production mode | ✅ dry-run verified (prior session) |
| Spec is valid YAML, correct bindings | ✅ |
| Migrations present + apply (56 tables) | ✅ (locally) |
| Live `doctl apps create` + managed PG/Redis | ⏳ needs your token |

# Deployment Guide (DigitalOcean + Local)

Repository: [https://github.com/ianroy/makerflowPM](https://github.com/ianroy/makerflowPM)
Primary site: [https://makerflow.org](https://makerflow.org)

## 1) Deployment Targets

- **Local test environment** (SQLite): fastest for development and UI iteration.
- **DigitalOcean Droplet** (recommended for small production): stable VM with persistent disk.
- **DigitalOcean App Platform + Managed PostgreSQL**: managed deploy flow and managed database.

## 2) Required Runtime Versions

- Python: `3.11.9`
- Gunicorn: `>=21.0.0`
- Flask: `>=3.0.0`
- Werkzeug: `>=3.0.0`
- psycopg[binary]: `>=3.1.18`
- pypdf: `>=4.3.1`

## 3) Local Test Environment Setup

```bash
git clone https://github.com/ianroy/makerflowPM.git
cd makerflowPM
cp .env.example .env
pip install -r requirements.txt
python3 app/server.py
```

Open: `http://127.0.0.1:8080/login`

Default bootstrap login:

- `admin@makerflow.local`
- `ChangeMeMeow!2026`

Rotate immediately for any shared environment.

## 4) DigitalOcean Droplet Setup (Recommended)

## Recommended Droplet Size

- 2 vCPU
- 2-4 GB RAM
- 50 GB SSD
- Ubuntu 24.04 LTS

## One-command deploy

```bash
./scripts/deploy_production.sh \
  --ssh ubuntu@YOUR_DROPLET_IP \
  --domain makerflow.org \
  --admin-email admin@yourdomain.edu \
  --admin-password 'REPLACE_WITH_STRONG_PASSWORD'
```

Optional flags:

```bash
--letsencrypt-email ops@yourdomain.edu
--no-certbot
--no-ufw
--no-swap
--swap-gb 2
```

## What it configures

- App path: `/opt/makerflow-pm`
- Service: `makerflow` (`systemd`)
- Reverse proxy: `nginx`
- TLS: `certbot` (unless disabled)
- Nightly DB backup cron
- Health endpoints: `/healthz` and `/readyz`

## Validate on server

```bash
sudo systemctl status makerflow
sudo nginx -t
curl -i http://127.0.0.1:8080/healthz
curl -i http://127.0.0.1:8080/readyz
```

## 5) DigitalOcean App Platform Setup

Use the app spec in `.do/app.yaml`.

Create app:

```bash
doctl apps create --spec .do/app.yaml
```

Update app:

```bash
doctl apps update <APP_ID> --spec .do/app.yaml
```

If configuring manually in DO UI:

- Build command:
  - `pip install -r requirements.txt`
- Run command:
  - `bash -lc "python3 scripts/bootstrap_db.py && gunicorn wsgi:application --bind 0.0.0.0:$PORT --workers 2 --threads 2 --timeout 120"`
- HTTP Port:
  - `8080`
- Health check path:
  - `/readyz` (preferred)

## 6) DigitalOcean Managed PostgreSQL Configuration

1. Create a DO Managed PostgreSQL cluster.
2. Add App Platform app (or Droplet IP) as a trusted source.
3. Set `MAKERSPACE_DATABASE_URL`:

```bash
postgresql://doadmin:REPLACE_PASSWORD@REPLACE_HOST:25060/defaultdb?sslmode=require
```

4. Redeploy app.

When `MAKERSPACE_DATABASE_URL` is set, MakerFlow uses PostgreSQL for all application data and sessions.

## Optional SQLite to PostgreSQL migration

```bash
MAKERSPACE_DATABASE_URL='postgresql://USER:PASSWORD@HOST:25060/defaultdb?sslmode=require' \
python3 scripts/migrate_sqlite_to_postgres.py --source data/makerspace_ops.db
```

## 7) Troubleshooting (From Real Deploy Incidents)

## Deploy Error: Run Command Not Executable

- Cause: run command missing/invalid/not executable.
- Fix:
  - Remove custom run command overrides in DO UI.
  - Re-apply exact run command shown above.
  - Confirm command is shell-valid and references existing files.

## Deploy Error: Health Checks

- Cause: app not listening on expected port/path, or slow startup.
- Fix:
  - Bind Gunicorn to `0.0.0.0:$PORT`.
  - Use `/readyz` or `/healthz` path.
  - Increase initial delay to `30-60s`.
  - Ensure bootstrap runs before server process.

## Database initialization failure (`spaces`/table missing)

- Cause: schema bootstrap was skipped.
- Fix:
  - Add `python3 scripts/bootstrap_db.py` to run command before gunicorn.
  - Redeploy.

## Login loop back to `/login`

- Common causes:
  - Misconfigured session/secret settings.
  - Cookie secure/domain mismatch.
  - DB session writes failing.
- Fix:
  - Confirm `MAKERSPACE_SECRET_KEY` is set and stable.
  - In HTTPS production, set `MAKERSPACE_COOKIE_SECURE=1`.
  - Check DB connectivity and session table writes in logs.

## CSRF token mismatch (400)

- Common causes:
  - Stale browser session after redeploy.
  - Mixed hostnames or protocol mismatch.
- Fix:
  - Log out/in, clear cookies for domain, retry.
  - Ensure all traffic is on one canonical HTTPS domain.

## Internal Server Error after switching to PostgreSQL

- Cause: SQL edge-case incompatibilities or missing bootstrap changes.
- Fix:
  - Check logs for exact SQL/parameter error.
  - Re-run bootstrap/migrations.
  - Confirm `MAKERSPACE_DATABASE_URL` includes `sslmode=require`.

## 8) Security Baseline for Production

- Set `MAKERSPACE_COOKIE_SECURE=1`.
- Set strong `MAKERSPACE_SECRET_KEY` (64+ chars).
- Rotate bootstrap admin password immediately.
- Use HTTPS only.
- Restrict admin access (network/VPN/SSO policy).

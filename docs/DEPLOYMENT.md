# Deployment Guide (DigitalOcean)

Repository: [https://github.com/ianroy/makerflowPM](https://github.com/ianroy/makerflowPM)
Primary site: [https://makerflow.org](https://makerflow.org)

## Target

Deploy MakerFlow PM to an Ubuntu 24.04 Droplet with:

- `systemd` process supervision
- `nginx` reverse proxy
- TLS via `certbot`
- SQLite tuning for 10-20 active users

## Recommended Droplet

- 2 vCPU
- 2-4 GB RAM
- 50 GB SSD

## One-Command Deploy

Run from your cloned repository:

```bash
./scripts/deploy_production.sh \
  --ssh ubuntu@YOUR_DROPLET_IP \
  --domain makerflow.org \
  --admin-email admin@yourdomain.edu \
  --admin-password 'REPLACE_WITH_STRONG_PASSWORD'
```

Optional:

```bash
--letsencrypt-email ops@yourdomain.edu
--no-certbot
--no-ufw
--no-swap
--swap-gb 2
```

## App Platform Deploy via Spec

For DigitalOcean App Platform (container/buildpack deploy), use the included spec:

- `.do/app.yaml`

Create app:

```bash
doctl apps create --spec .do/app.yaml
```

Update app after changes:

```bash
doctl apps update <APP_ID> --spec .do/app.yaml
```

Notes:

- This spec binds Gunicorn to `0.0.0.0:$PORT`.
- Health check path is `/healthz`.
- Replace secret placeholders before production use.

## What the Script Configures

- App path: `/opt/makerflow-pm`
- Service: `makerflow`
- Runtime: Python virtualenv + hardened systemd unit
- Proxy: nginx with static caching and security headers
- TLS: certbot (unless disabled)
- Backup: nightly DB backup cron
- Health checks: `/healthz` and `/readyz`

## Validate After Deploy

```bash
sudo systemctl status makerflow
sudo nginx -t
curl -i http://127.0.0.1:8080/healthz
curl -i http://127.0.0.1:8080/readyz
```

Then open:

- `https://makerflow.org/login`
- `https://makerflow.org/website/`

## Data Paths

- Live DB: `/opt/makerflow-pm/data/makerspace_ops.db`
- Backups: `/opt/makerflow-pm/data/backups/`

# MakerFlow PM

Open-source project management and operations platform for makerspaces, labs, and service teams.

Repository: [https://github.com/ianroy/makerflowPM](https://github.com/ianroy/makerflowPM)
Primary site: [https://makerflow.org](https://makerflow.org)

## Highlights

- Multi-workspace architecture (`organizations`) with role-based access.
- Kanban, list, calendar, dashboard, and report workflows.
- Team + space management for physical operations.
- Assets, consumables, onboarding, agendas, comments, and audit trail.
- CSV import/export portability.
- Self-hosted, low-cost runtime (Python stdlib + SQLite).

## Quick Start

```bash
git clone https://github.com/ianroy/makerflowPM.git
cd makerflowPM
cp .env.example .env
python3 app/server.py
```

Open: [http://127.0.0.1:8080/login](http://127.0.0.1:8080/login)

Default bootstrap account (rotate immediately):

- `admin@makerflow.local` / `ChangeMeNow!2026`

## Environment

Key variables (see `.env.example` for full list):

```bash
BDI_SECRET_KEY=replace-with-64+char-secret
BDI_COOKIE_SECURE=1
BDI_DEFAULT_ORG_NAME=Default Workspace
BDI_DEFAULT_ORG_SLUG=default
BDI_ADMIN_EMAIL=admin@makerflow.local
BDI_ADMIN_PASSWORD=ChangeMeNow!2026
```

## Deployment (DigitalOcean Droplet)

```bash
./scripts/deploy_production.sh \
  --ssh ubuntu@YOUR_SERVER_IP \
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

## Test and Verification

```bash
python3 scripts/smoke_test.py
python3 scripts/usability_test.py
python3 scripts/accessibility_audit.py
python3 scripts/comprehensive_feature_security_test.py
```

## Documentation

- `docs/DEPLOYMENT.md`
- `docs/SECURITY.md`
- `docs/ARCHITECTURE.md`
- `docs/DATA_MODEL.md`
- `docs/TESTING.md`
- Website wiki: `/website/wiki/`

## License

This project is licensed under Creative Commons Attribution-ShareAlike 4.0 International (`CC BY-SA 4.0`).

- `LICENSE`
- `docs/LICENSE.md`

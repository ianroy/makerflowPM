# MakerFlow PM

Open-source project management and operations platform for makerspaces, labs, and service teams.
Built by Ian Roy leveraging OpenAI Codex for iterative product engineering and documentation.

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

### Option 1: Original (Zero Dependencies)

```bash
git clone https://github.com/ianroy/makerflowPM.git
cd makerflowPM
cp .env.example .env
python3 app/server.py
```

### Option 2: Flask (Production Ready)

```bash
git clone https://github.com/ianroy/makerflowPM.git
cd makerflowPM
cp .env.example .env
pip install -r requirements.txt
./run_flask.sh
```

Or for production:
```bash
./run_flask.sh production
```

See [QUICKSTART_FLASK.md](QUICKSTART_FLASK.md) for Flask-specific documentation.

---

Open: [http://127.0.0.1:8080/login](http://127.0.0.1:8080/login)

Default bootstrap account (rotate immediately):

- `admin@makerflow.local` / `ChangeMeMeow!2026`

## Environment

Key variables (see `.env.example` for full list):

```bash
MAKERSPACE_SECRET_KEY=replace-with-64+char-secret
MAKERSPACE_COOKIE_SECURE=1
MAKERSPACE_DEFAULT_ORG_NAME=Default Workspace
MAKERSPACE_DEFAULT_ORG_SLUG=default
MAKERSPACE_ADMIN_EMAIL=admin@makerflow.local
MAKERSPACE_ADMIN_PASSWORD=ChangeMeMeow!2026
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

Full release preflight (docs + security + UI + accessibility + 10-user simulation + cleanup):

```bash
./scripts/pre_release_audit.sh
```

This pipeline now includes a final clean-state reset:

```bash
python3 scripts/reset_release_state.py
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

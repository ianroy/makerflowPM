# MakerFlow PM

[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.11.9-blue.svg)](runtime.txt)
[![Status](https://img.shields.io/badge/status-active-success.svg)](#)

> **MakerFlow PM** is an open-source project management and operations platform built for makerspaces, labs, and service teams that need to track work, equipment, consumables, partnerships, and people enablement in one self-hostable, low-cost system.

- **Primary site:** [https://makerflow.org](https://makerflow.org)
- **Repository:** [https://github.com/ianroy/makerflowPM](https://github.com/ianroy/makerflowPM)
- **License:** Creative Commons Attribution-ShareAlike 4.0 International ([`CC BY-SA 4.0`](LICENSE))

---

## Table of contents

- [What it is](#what-it-is)
- [Who built it](#who-built-it)
- [Tech stack](#tech-stack)
- [Architecture at a glance](#architecture-at-a-glance)
- [How it works](#how-it-works)
- [Data model](#data-model)
- [Authorization model](#authorization-model)
- [Quick start (local)](#quick-start-local)
- [Deploying on GitHub](#deploying-on-github)
- [Deploying on DigitalOcean](#deploying-on-digitalocean)
- [Environment variables](#environment-variables)
- [Testing and verification](#testing-and-verification)
- [Repository map](#repository-map)
- [Roadmap](#roadmap)
- [Federal accessibility compliance (ADA Title II + Section 504)](#federal-accessibility-compliance-ada-title-ii--section-504)
- [Documentation index](#documentation-index)
- [Contributing](#contributing)
- [License](#license)

---

## What it is

MakerFlow PM is a single-binary-feeling, stdlib-first Python web application that bundles into one repo all of the routines a small ops/engineering team actually runs day to day:

- **Projects, tasks, and kanban / list / calendar workflows** with custom views, saved filters, and per-org custom fields.
- **Meeting agendas and minutes** that can convert items directly into tasks or projects.
- **Equipment, consumables, and partnerships** tracking with soft-delete and audit history.
- **Onboarding templates and assignments** so role-based checklists travel with new hires.
- **Imports and exports** as a first-class portability contract — CSV in, CSV out, plus PDF/DOCX note import.
- **Google Calendar bidirectional sync** linking tasks to calendar events.
- **Reports and insight snapshots** plus an `audit_log` table that records every mutation for accountability.

It is designed to run cheaply: on a $6 DigitalOcean Droplet, on App Platform with managed PostgreSQL, or on a single developer machine with SQLite.

## Who built it

MakerFlow PM is built by **[Ian Roy](https://github.com/ianroy)**, leveraging the OpenAI Codex (GPT-5.3 family) workflow for implementation, iterative debugging, test simulation, and documentation refinement. The product is shipped under [CC BY-SA 4.0](LICENSE) so universities, labs, and community workshops can self-host, fork, and adapt it without per-seat fees.

## Tech stack

<p align="center">
  <img src="docs/diagrams/09-tech-stack.svg" alt="MakerFlow PM — Tech stack" width="100%"/>
</p>

| Layer | Choice | Notes |
|---|---|---|
| Runtime | **Python 3.11.9** | declared in [`runtime.txt`](runtime.txt) |
| WSGI server | **Gunicorn ≥ 21.0** (Linux) · **Waitress ≥ 2.1** (Windows) | from [`requirements.txt`](requirements.txt) |
| Framework shell | **Flask ≥ 3.0** + **Werkzeug ≥ 3.0** | thin WSGI bridge in [`app/flask_app.py`](app/flask_app.py); core logic remains stdlib |
| Default DB | **SQLite** (stdlib, WAL mode) | [`data/makerspace_ops.db`](data/) |
| Production DB | **PostgreSQL** via **psycopg ≥ 3.1.18** (binary) | enabled by setting `MAKERSPACE_DATABASE_URL` |
| Document import | **pypdf ≥ 4.3.1** | used by [`scripts/import_project_notes.py`](scripts/import_project_notes.py) |
| Frontend | **server-rendered HTML + vanilla JS + hand-rolled CSS** | no build step, no framework |
| Edge (Droplet) | **nginx + certbot + systemd** on Ubuntu 24.04 LTS | provisioned by [`scripts/deploy_production.sh`](scripts/deploy_production.sh) |
| Managed runtime | **DigitalOcean App Platform + DO Managed PostgreSQL** | spec in [`.do/app.yaml`](.do/app.yaml), deploy-on-push |
| Source / CI | **Git + GitHub** · `deploy_on_push` today; **GitHub Actions** tracked in roadmap | see [`FEATUREROADMAP_workplan.md`](FEATUREROADMAP_workplan.md) |
| AI-assisted build | **OpenAI Codex** (GPT-5.3 family workflow) | implementation, debugging, tests, documentation refinement |
| License | **CC BY-SA 4.0** | see [LICENSE](LICENSE) and the [License section](#license) below |

## Architecture at a glance

<p align="center">
  <img src="docs/diagrams/01-system-architecture.svg" alt="MakerFlow PM — System architecture" width="100%"/>
</p>

The runtime is a server-rendered WSGI application:

- **Backend:** Python 3.11.9, stdlib-first, with a thin Flask/Werkzeug compatibility shell ([`app/flask_app.py`](app/flask_app.py)) on top of the monolithic core ([`app/server.py`](app/server.py)).
- **Frontend:** server-rendered HTML + progressive vanilla JavaScript ([`app/static/app.js`](app/static/app.js)) and hand-rolled CSS ([`app/static/style.css`](app/static/style.css)). No build step. No framework lock-in.
- **Data layer:** SQLite by default; PostgreSQL when `MAKERSPACE_DATABASE_URL` is set. The SQL layer adapts placeholders and types transparently.
- **WSGI server:** Gunicorn in production; the stdlib server is used for local dev.
- **Edge:** nginx + certbot on Droplet deploys; DO load balancer + managed health checks on App Platform.

## How it works

<p align="center">
  <img src="docs/diagrams/02-request-lifecycle.svg" alt="MakerFlow PM — Request lifecycle" width="100%"/>
</p>

Every request follows the same lifecycle: WSGI entry → schema bootstrap check → session/org resolution → auth and CSRF gates → RBAC check → route dispatch → org-scoped SQL → audit + side effects → HTML or JSON response with security headers. The contract is enforced consistently in [`app/server.py`](app/server.py) so feature work can focus on rendering and queries rather than reinventing security primitives.

End-to-end, a unit of work flows across four product surfaces:

<p align="center">
  <img src="docs/diagrams/07-feature-flow.svg" alt="MakerFlow PM — Feature flow" width="100%"/>
</p>

## Data model

<p align="center">
  <img src="docs/diagrams/03-data-model.svg" alt="MakerFlow PM — Data model" width="100%"/>
</p>

39 tables across six domains:

- **Tenancy & identity** — `organizations`, `users`, `memberships`, `sessions`, `password_resets`
- **Project management** — `projects`, `tasks`, `custom_views`, `field_configs`, `item_comments`, `item_watchers`, `report_templates`
- **Operations & meetings** — `meeting_agendas`, `meeting_items`, `meeting_item_updates`, `meeting_item_files`, `intake_requests`, `equipment_assets`, `consumables`, `partnerships`
- **People enablement** — `spaces`, `teams`, `team_members`, `onboarding_templates`, `onboarding_assignments`, `user_preferences`, `role_nav_preferences`
- **Calendar & sync** — `calendar_events`, `calendar_sync_settings`, `calendar_sync_links`, `meeting_note_sources`
- **Governance & analytics** — `audit_log`, `insight_snapshots`, `email_messages`

Operational entities are soft-deleted via `deleted_at` + `deleted_by_user_id` before any permanent purge. See [`docs/DATA_MODEL.md`](docs/DATA_MODEL.md).

## Authorization model

<p align="center">
  <img src="docs/diagrams/04-rbac-roles.svg" alt="MakerFlow PM — Roles and RBAC" width="100%"/>
</p>

Roles, least to most privileged: `viewer` → `student` → `staff` → `manager` → `workspace_admin` → `owner`. Workspace admins are pinned to a single organization to limit blast radius; the `is_superuser` flag on `users` is the only path to cross-workspace administration. See [`docs/SECURITY.md`](docs/SECURITY.md) and [`docs/DECISIONS.md`](docs/DECISIONS.md).

## Quick start (local)

### Option 1: Fast start (SQLite, stdlib server)

```bash
git clone https://github.com/ianroy/makerflowPM.git
cd makerflowPM
cp .env.example .env
python3 app/server.py
```

### Option 2: Production-like start (Gunicorn + Flask shell)

```bash
git clone https://github.com/ianroy/makerflowPM.git
cd makerflowPM
cp .env.example .env
pip install -r requirements.txt
./run_flask.sh
```

Open [http://127.0.0.1:8080/login](http://127.0.0.1:8080/login).

Default bootstrap account (**rotate immediately** in any shared environment):

- `admin@makerflow.local` / `ChangeMeMeow!2026`

Seed sample data while iterating:

```bash
python3 scripts/load_sample_data.py
```

## Deploying on GitHub

MakerFlow PM uses GitHub as the single source of truth. The repo supports two GitHub-native deployment paths:

### 1) GitHub → DigitalOcean App Platform (continuous deploy)

The [`.do/app.yaml`](.do/app.yaml) spec wires App Platform to redeploy on every push to `main`:

```yaml
github:
  repo: ianroy/makerflowPM
  branch: main
  deploy_on_push: true
```

Fork the repo, update `.do/app.yaml` with your fork name, then create the app:

```bash
doctl apps create --spec .do/app.yaml
```

Every subsequent `git push origin main` to your fork triggers a build (`pip install -r requirements.txt`) and a run (`scripts/bootstrap_db.py && gunicorn wsgi:application`). Health checks hit `/readyz` every 10 seconds.

### 2) GitHub Pages for the static site (`MakerFlow Website/`)

The `MakerFlow Website/` directory ships an HTML landing page plus a wiki of mirrored markdown docs. To publish it via GitHub Pages:

1. In your fork, go to **Settings → Pages**.
2. Source: **Deploy from a branch**.
3. Branch: `main`, folder: `/MakerFlow Website`.
4. Click **Save**. GitHub serves the site within a minute or two at `https://<your-username>.github.io/makerflowPM/`.

Keep the wiki in sync with `docs/*.md` by running:

```bash
python3 scripts/sync_website_content.py
```

### 3) Recommended GitHub Actions (suggested)

The repo does not yet ship a `.github/workflows/` directory. A reasonable starter pipeline runs the verification scripts on PRs to `main`. The roadmap (see [`FEATUREROADMAP_workplan.md`](FEATUREROADMAP_workplan.md)) tracks this as an explicit P1 task — `ci-smoke-and-security` — with a complete spec.

## Deploying on DigitalOcean

<p align="center">
  <img src="docs/diagrams/05-deployment-topologies.svg" alt="MakerFlow PM — Deployment topologies" width="100%"/>
</p>

Three options:

### A) Local development (SQLite)

Already covered in [Quick start](#quick-start-local).

### B) Single Droplet (recommended for small production)

One-shot bootstrap of an Ubuntu 24.04 Droplet:

```bash
./scripts/deploy_production.sh \
  --ssh ubuntu@YOUR_SERVER_IP \
  --domain makerflow.org \
  --admin-email admin@yourdomain.edu \
  --admin-password 'REPLACE_WITH_STRONG_PASSWORD'
```

Optional flags: `--letsencrypt-email`, `--no-certbot`, `--no-ufw`, `--no-swap`, `--swap-gb 2`.

This installs nginx + systemd + certbot, drops MakerFlow at `/opt/makerflow-pm`, and provisions a nightly DB backup cron.

### C) DigitalOcean App Platform + Managed PostgreSQL

```bash
doctl apps create --spec .do/app.yaml
# or, for an existing app:
doctl apps update <APP_ID> --spec .do/app.yaml
```

If configuring manually in the DO UI:

- **Build command:** `pip install -r requirements.txt`
- **Run command:** `bash -lc "python3 scripts/bootstrap_db.py && gunicorn wsgi:application --bind 0.0.0.0:$PORT --workers 2 --threads 2 --timeout 120"`
- **HTTP port:** `8080`
- **Health check path:** `/readyz`

> SQLite is ephemeral on App Platform — point `MAKERSPACE_DATABASE_URL` at a DO Managed PostgreSQL cluster for any non-throwaway data. Optionally migrate existing SQLite data:
>
> ```bash
> MAKERSPACE_DATABASE_URL='postgresql://USER:PASSWORD@HOST:25060/defaultdb?sslmode=require' \
> python3 scripts/migrate_sqlite_to_postgres.py --source data/makerspace_ops.db
> ```

Common App Platform failure modes (run command invalid, health checks failing, missing tables, login loops, CSRF mismatches, Postgres SQL edge cases) are documented in [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md#7-troubleshooting-from-real-deploy-incidents).

## Environment variables

Copy [`.env.example`](.env.example) to `.env` and adjust.

| Variable | Required | Default | Purpose |
|---|---|---|---|
| `MAKERSPACE_SECRET_KEY` | ✅ prod | `change-this-secret-in-production` | HMAC signing key for cookies/sessions. 64+ chars in production. |
| `MAKERSPACE_COOKIE_SECURE` | ✅ prod | `0` | Set to `1` behind HTTPS. |
| `MAKERSPACE_HOST` | — | `127.0.0.1` | Bind address. |
| `MAKERSPACE_PORT` | — | `8080` | Listen port. |
| `MAKERSPACE_SESSION_DAYS` | — | `14` | Server-side session lifetime in days. |
| `MAKERSPACE_DEFAULT_ORG_NAME` | — | `Default Workspace` | Bootstrap workspace display name. |
| `MAKERSPACE_DEFAULT_ORG_SLUG` | — | `default` | Bootstrap workspace slug. |
| `MAKERSPACE_ADMIN_EMAIL` | ✅ | `admin@makerflow.local` | Bootstrap admin email. |
| `MAKERSPACE_ADMIN_PASSWORD` | ✅ | `ChangeMeMeow!2026` | Bootstrap admin password — rotate immediately. |
| `MAKERSPACE_ADMIN_NAME` | — | `MakerFlow Admin` | Bootstrap admin display name. |
| `MAKERSPACE_DB_PATH` | — | `data/makerspace_ops.db` | SQLite file path override. |
| `MAKERSPACE_DATABASE_URL` | ✅ prod | — | PostgreSQL DSN. When set, MakerFlow uses Postgres for app data + sessions. |
| `MAKERSPACE_SMTP_HOST` / `_PORT` / `_USER` / `_PASSWORD` / `_FROM` | — | — | Optional outbound email. |
| `MAKERSPACE_GCAL_CLIENT_ID` / `_CLIENT_SECRET` / `_REFRESH_TOKEN` / `_CALENDAR_ID` | — | — | Optional Google Calendar OAuth. |
| `FEATURE_INTAKE_ENABLED` | — | `False` | Toggle for the intake queue module. |

## Testing and verification

```bash
python3 scripts/smoke_test.py
python3 scripts/usability_test.py
python3 scripts/accessibility_audit.py
python3 scripts/comprehensive_feature_security_test.py
```

Full release preflight (documentation audit + functional + a11y + security + collaboration sim + cleanup + website resync + clean-state reset):

```bash
./scripts/pre_release_audit.sh
```

Clean state for a fresh release:

```bash
python3 scripts/reset_release_state.py
```

There is currently no `pytest` suite — testing is script-based. Introducing one is tracked in [`FEATUREROADMAP_workplan.md`](FEATUREROADMAP_workplan.md).

## Repository map

<p align="center">
  <img src="docs/diagrams/06-component-map.svg" alt="MakerFlow PM — Repository component map" width="100%"/>
</p>

| Path | Purpose |
|---|---|
| [`app/server.py`](app/server.py) | Monolithic WSGI core: routes, render functions, DB, RBAC, audit, calendar sync. ~14k LOC. |
| [`app/flask_app.py`](app/flask_app.py) | Flask shell that wraps the WSGI core so Gunicorn/uWSGI/Waitress can serve it. |
| [`app/static/app.js`](app/static/app.js) | Vanilla JS for CSRF, modals, kanban drag-and-drop, fetch helpers. |
| [`app/static/style.css`](app/static/style.css) | Hand-rolled CSS — no Tailwind, no build step. |
| [`wsgi.py`](wsgi.py) | Production WSGI entrypoint. |
| [`scripts/`](scripts/) | Deploy, bootstrap, smoke, usability, accessibility, security, migration, import scripts. |
| [`docs/`](docs/) | Architecture, data model, decisions, deployment, security, testing, diagrams. |
| [`docs/diagrams/`](docs/diagrams/) | SVG architecture diagrams referenced from this README and [`ProductSpec.md`](ProductSpec.md). |
| [`MakerFlow Website/`](MakerFlow%20Website/) | Static landing site + wiki, deployable to GitHub Pages. |
| [`.do/app.yaml`](.do/app.yaml) | DigitalOcean App Platform spec (deploy on push). |
| [`data/`](data/) | Local SQLite database (gitignored). |
| [`analysis_outputs/`](analysis_outputs/) | Snapshot artifacts from the release audit scripts. |
| [`ProductSpec.md`](ProductSpec.md) | Developer onboarding guide. |
| [`FEATUREROADMAP_workplan.md`](FEATUREROADMAP_workplan.md) | Resumable, agent-executable feature roadmap. |

## Roadmap

MakerFlow PM ships its roadmap as a resumable, agent-executable file: [`FEATUREROADMAP_workplan.md`](FEATUREROADMAP_workplan.md). It contains a recursive regeneration prompt (to seed new tasks), an execution prompt (to build the top-ready task), 45 seeded task cards across P0–P3 (22 general + 23 accessibility), and a checkpoint log so any agent or human can pick the work up cold.

<p align="center">
  <img src="docs/diagrams/08-roadmap-loop.svg" alt="MakerFlow PM — Roadmap loop" width="100%"/>
</p>

## Federal accessibility compliance (ADA Title II + Section 504)

MakerFlow PM is built to meet **WCAG 2.1 Level AA**, the technical standard adopted by:

- **28 CFR Part 35, Subpart H** — DOJ ADA Title II (state and local government). Compliance deadlines (post-2026 IFR extension): **April 26, 2027** for entities with population ≥ 50,000; **April 26, 2028** for smaller entities and special-district governments.
- **45 CFR Part 84, Subpart I** — HHS Section 504 (federally-funded recipients). Compliance deadlines: **May 11, 2027** for recipients with ≥ 15 employees; **May 10, 2028** for smaller recipients.

The diagram below maps regulatory requirements to the 23 accessibility task cards in [`FEATUREROADMAP_workplan.md`](FEATUREROADMAP_workplan.md#accessibility-compliance-program-ada-title-ii--section-504):

<p align="center">
  <img src="docs/diagrams/10-ada-504-compliance.svg" alt="MakerFlow PM — ADA Title II + Section 504 compliance map" width="100%"/>
</p>

See also [`docs/ACCESSIBILITY.md`](docs/ACCESSIBILITY.md) once it lands as part of `P0-a11y-policy-baseline`.

## Documentation index

- [`ProductSpec.md`](ProductSpec.md) — developer onboarding guide
- [`FEATUREROADMAP_workplan.md`](FEATUREROADMAP_workplan.md) — recursive, resumable feature roadmap
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — system shape, request lifecycle, deployment patterns
- [`docs/DATA_MODEL.md`](docs/DATA_MODEL.md) — entities, roles, deletion model
- [`docs/DECISIONS.md`](docs/DECISIONS.md) — architectural decision log
- [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md) — runbooks for local, Droplet, App Platform
- [`docs/SECURITY.md`](docs/SECURITY.md) — built-in controls and production baseline
- [`docs/TESTING.md`](docs/TESTING.md) — verification matrix
- [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md) — how to propose changes
- [`docs/LICENSE.md`](docs/LICENSE.md) — CC BY-SA 4.0 attribution + ShareAlike requirements
- [`docs/diagrams/`](docs/diagrams/) — ten SVG diagrams onboarding a new developer (architecture, lifecycle, data model, RBAC, deployment, components, feature flow, roadmap loop, tech stack, ADA Title II + § 504 compliance map)
- [`MakerFlow Website/wiki/`](MakerFlow%20Website/wiki/) — published wiki mirror

## Contributing

See [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md). When proposing new features, add a task card to [`FEATUREROADMAP_workplan.md`](FEATUREROADMAP_workplan.md) using the schema documented at the top of that file — the roadmap is designed so an agent can pick the work up later without losing context.

Contributions are accepted under the same license as the project: **CC BY-SA 4.0**. By opening a pull request, you agree that your contribution is licensed accordingly.

## License

[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](LICENSE)

This project is licensed under **Creative Commons Attribution-ShareAlike 4.0 International** (`CC BY-SA 4.0`).

Copyright © 2026 [Ian Roy](https://github.com/ianroy).

You are free to **share** (copy and redistribute the material in any medium or format) and **adapt** (remix, transform, and build upon the material) for any purpose, including commercially, under the following terms:

- **Attribution** — you must give appropriate credit to Ian Roy, provide a link to this repository ([github.com/ianroy/makerflowPM](https://github.com/ianroy/makerflowPM)), link to the [license deed](https://creativecommons.org/licenses/by-sa/4.0/), and indicate if changes were made.
- **ShareAlike** — if you remix, transform, or build upon this project, you must distribute your contributions under the same license (`CC BY-SA 4.0`).
- **No additional restrictions** — you may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.

Full text:

- [`LICENSE`](LICENSE) — license summary in this repository
- [`docs/LICENSE.md`](docs/LICENSE.md) — required attribution details
- [License deed](https://creativecommons.org/licenses/by-sa/4.0/) · [Legal code](https://creativecommons.org/licenses/by-sa/4.0/legalcode)

---

<sub>MakerFlow PM · © 2026 Ian Roy · <a href="LICENSE">CC BY-SA 4.0</a> · <a href="https://github.com/ianroy/makerflowPM">github.com/ianroy/makerflowPM</a></sub>

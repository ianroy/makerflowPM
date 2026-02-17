# Architecture Guide

Repository: [https://github.com/ianroy/makerflowPM](https://github.com/ianroy/makerflowPM)

## System Shape

- Backend: Python WSGI application (`app/server.py`)
- Frontend: server-rendered HTML + progressive JavaScript (`app/static/app.js`)
- Styling: CSS (`app/static/style.css`)
- Data layer:
  - SQLite (default)
  - PostgreSQL via `MAKERSPACE_DATABASE_URL` (production option)

## Runtime and Dependency Versions

- Python `3.11.9`
- Gunicorn `>=21.0.0`
- Flask `>=3.0.0`
- Werkzeug `>=3.0.0`
- psycopg[binary] `>=3.1.18`
- pypdf `>=4.3.1`

## Request Lifecycle

1. WSGI `app()` receives request.
2. Session + active organization context are resolved.
3. Role and CSRF gates are enforced on mutating routes.
4. Organization-scoped SQL executes.
5. HTML or JSON response is returned with security headers.

## Tenancy and Authorization Model

- Multi-workspace tenancy via `organizations` and `memberships`.
- Role levels:
  1. `viewer`
  2. `student`
  3. `staff`
  4. `manager`
  5. `workspace_admin`
  6. `owner`

## Data Safety and Governance

- Soft-delete and restore workflow for core entities.
- Purge workflows for admin cleanup.
- Audit logging for sensitive operations.
- CSV import/export portability.

## Deployment Architecture Patterns

## A) Single-node (Droplet)

- `nginx` reverse proxy
- Gunicorn app service via `systemd`
- SQLite or PostgreSQL backend
- TLS via certbot

## B) Managed service (App Platform)

- Buildpack/container build from repo
- Run command bootstraps schema then launches Gunicorn
- Health checks on `/readyz`
- Managed PostgreSQL recommended for persistence

## Delivery Toolchain Used

- Git + GitHub repository management
- GitHub Desktop for desktop commit/sync workflows
- DigitalOcean for hosting (Droplet, App Platform, Managed PostgreSQL)
- OpenAI Codex (GPT-5.3 family workflow) for implementation, debugging, tests, and documentation iteration

## File-level Technical Anchors

- App entrypoint: `app/server.py`
- WSGI adapter: `wsgi.py`
- Environment defaults: `.env.example`
- App Platform spec: `.do/app.yaml`
- Droplet deploy automation: `scripts/deploy_production.sh`
- Bootstrap/migrations: `scripts/bootstrap_db.py`

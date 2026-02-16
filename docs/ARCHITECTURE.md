# Architecture Guide

Repository: [https://github.com/ianroy/makerflowPM](https://github.com/ianroy/makerflowPM)

## System Shape

- Backend: Python stdlib WSGI (`app/server.py`)
- Database: SQLite (`data/bdi_ops.db`)
- Frontend: server-rendered HTML + progressive JS (`app/static/`)

## Core Principles

- Low operational overhead.
- Explicit, readable route and permission logic.
- Multi-workspace tenancy via `organizations` + `memberships`.
- CSV portability and migration safety.

## Request Lifecycle

1. WSGI `app()` receives request.
2. Session + active organization context resolved.
3. Route-level auth/role/CSRF checks enforced.
4. SQL mutations/queries run with organization scoping.
5. HTML or JSON response returned with security headers.

## Role Levels

1. `viewer`
2. `student`
3. `staff`
4. `manager`
5. `workspace_admin`
6. `owner`

## Data Safety

- Soft-delete on core operational entities.
- Restore/purge workflow for admins.
- Audit log for critical changes.

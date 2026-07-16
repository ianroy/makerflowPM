# makerflow_dart

The **Flutter + Serverpod (Dart)** rebuild of [MakerFlow PM](../README.md). Greenfield, single-language, six platform targets. Governed by [`../FLUTTER_REBUILD_PLAN.md`](../FLUTTER_REBUILD_PLAN.md); status in [`BUILD_STATUS.md`](BUILD_STATUS.md).

> **Where it stands (2026-07-16, Dart 3.12.2 / Flutter 3.44.2 / Serverpod 3.4.10):** a working PM tool in a **monday.com-style UI** — the Vibe-derived design system, boards sidebar, and the grouped inline-editing **Main Table** — with full CRUD (+Trash/Archive) for tasks and projects, ops features, and the **Phase 8 customization platform live**: a persisted per-user column system (drag-resize/reorder/hide), nine custom-field types with server-validated D6 value storage and a type-change conversion flow, and saved/shared views with dirty-state save flows. Everything is **proven against live PostgreSQL** (server integration suite + app widget suite green, CI-gated at the repo root) and the **whole demo deploys to DO App Platform from one spec** (API + web UI on one domain) — the only manual step left is `doctl auth init` ([`DEPLOY.md`](DEPLOY.md)). Per-card history: [`BUILD_STATUS.md`](BUILD_STATUS.md).

## What's here

```
makerflow_dart/
├── melos.yaml                # workspace
├── makerflow_server/         # Serverpod backend
│   ├── config/               # dev config + passwords.example.yaml
│   ├── docker-compose.yaml   # Postgres + Redis
│   ├── lib/src/models/       # 37 Serverpod model YAMLs + 11 enums + typed exceptions
│   ├── lib/src/business/     # auth context, RBAC guard, audit, (tenancy)
│   ├── lib/src/endpoints/    # 14 endpoints (task, project, org, health, collab, equipment,
│   │                         #   consumable, meeting, partnership, intake, onboarding, trash,
│   │                         #   realtime, sync)
│   └── lib/server.dart       # bootstrap (serverpod_auth + /healthz)
├── makerflow_client/         # generated client (committed; regenerate via `serverpod generate`)
├── makerflow_design/         # monday-style (Vibe-derived) design system: tokens, ThemeData,
│                             #   StatusLabel + picker, buttons/avatars/skeletons — AA contrast-tested
├── makerflow_flutter/        # the app — monday-style shell + Main Table (column system, custom
│                             #   fields, saved views), keyboard-accessible kanban + list, projects,
│                             #   equipment, consumables, meetings, trash  (+ Dockerfile.web)
└── makerflow_shared/         # non-generated shared constants
```

## Bring-up (local — requires the toolchain)

```bash
# 1. Tooling
dart pub global activate melos
dart pub global activate serverpod_cli      # the `serverpod` CLI

# 2. Workspace deps
cd makerflow_dart
melos bootstrap

# 3. Infra + DB
cd makerflow_server
cp config/passwords.example.yaml config/passwords.yaml
docker compose up -d                          # Postgres :8090, Redis :8091

# 4. Code generation (only needed after editing model YAML/endpoints — output is committed)
serverpod generate
dart bin/main.dart --apply-migrations         # create tables
dart bin/main.dart                            # serve on :8080

# 5. Run the app (any target)
cd ../makerflow_flutter
flutter run -d chrome        # or: macos | windows | linux | <device>
```

## Deploy to DigitalOcean (required target — D5)

The **full demo** — the Serverpod API and the Flutter web app on one domain — ships to **DO App Platform** from one spec, with **DO Managed PostgreSQL 17 + Valkey**. The moving parts:

- [`.do/app.yaml`](.do/app.yaml) — App Platform spec: `api` service (routed under `/api`, prefix stripped) + `webapp` service (nginx at `/`), both deploy-on-push from `staging`, plus the managed `makerflow-db` and `makerflow-redis`.
- [`makerflow_server/Dockerfile`](makerflow_server/Dockerfile) — multi-stage: `dart compile exe bin/main.dart` → slim runtime (verified locally; produces a ~16 MB native binary).
- [`makerflow_flutter/Dockerfile.web`](makerflow_flutter/Dockerfile.web) — Flutter web release build (API base baked from the `MAKERFLOW_API` build arg) → nginx with SPA fallback.
- [`makerflow_server/deploy/entrypoint.sh`](makerflow_server/deploy/entrypoint.sh) — renders `config/<mode>.yaml` + `config/passwords.yaml` from env (DO managed-DB bindings + the `SERVICE_SECRET`), applies migrations, then serves.

```bash
# one-time: install + auth the DO CLI, then create the app
doctl auth init
doctl apps create --spec makerflow_dart/.do/app.yaml
# then: set SERVICE_SECRET + SEED_ADMIN_PASSWORD (encrypted) on the api
# component, seed once via the console, and point the webapp's MAKERFLOW_API
# at https://<app-domain>/api/ — the exact sequence is DEPLOY.md steps 4–7.
# Every push to staging redeploys automatically. Production cutover:
# merge staging -> main and flip `branch` in .do/app.yaml to main.
```

Or in the DO dashboard: **Create App → GitHub → ianroy/makerflowPM** and point it at `makerflow_dart/.do/app.yaml`. The local `docker-compose.yaml` (Postgres + Redis) remains the dev path; DO managed databases are production.

## Important notes

- **Generated code is committed.** `makerflow_server/lib/src/generated/**` and `makerflow_client/lib/**` are checked in, so the workspace compiles out of the box. Run `serverpod generate` only after editing model YAML or endpoints — and commit the output.
- **The Flutter app runs without a server.** It defaults to in-memory repositories, so the UI, theme, and keyboard kanban are demoable immediately. Pass `--dart-define=MAKERFLOW_LIVE=true` to use the live Serverpod repositories instead — see [`makerflow_flutter/lib/src/data/task_repository.dart`](makerflow_flutter/lib/src/data/task_repository.dart).
- **Accessibility:** the kanban ships a keyboard move pattern + live-region announcements (WCAG 2.1.1 / 2.5.1 / 4.1.3), status is never conveyed by color alone (1.4.1), custom-label ink is AA-checked by a design-system contrast test, and every column operation has a non-pointer path via the Columns popover. The **Flutter Web a11y gate** (`fl-0-a11y-web-spike`): the test fixture is built and reachable at `/spike`; the human screen-reader/keyboard pass (R1) is still owed before the web target is promised — see [`../FLUTTER_REBUILD_PLAN.md` §8](../FLUTTER_REBUILD_PLAN.md#8-accessibility--the-hard-part).
- This codebase is **independent** of the Python app at the repo root and does not modify it (D3: new deployments only).

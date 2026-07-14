# makerflow_dart

The **Flutter + Serverpod (Dart)** rebuild of [MakerFlow PM](../README.md). Greenfield, single-language, six platform targets. Governed by [`../FLUTTER_REBUILD_PLAN.md`](../FLUTTER_REBUILD_PLAN.md); status in [`BUILD_STATUS.md`](BUILD_STATUS.md).

> This is a **walking skeleton** (Phase 0 + a Phase 1 vertical slice), not the finished product — but it **compiles and its tests pass** (Dart 3.12.2 / Flutter 3.44.2 / Serverpod 3.4.10): server `serverpod generate` + `dart analyze` + tests, `flutter analyze` + widget test, `flutter build web`, and `serverpod create-migration` (112 tables) all succeed. It is also **proven against live Postgres/Redis**: a green live integration suite, an authenticated client↔server round-trip, and the live UI write-path — see [`BUILD_STATUS.md`](BUILD_STATUS.md). The remaining gap is the live DO deploy, blocked only on an owner `doctl` token ([`DEPLOY.md`](DEPLOY.md)).

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
├── makerflow_design/         # tokens (ported from style.css), ThemeData, MfCard, StatusBadge
├── makerflow_flutter/        # the app — login, dashboard, tasks (keyboard-accessible board + list),
│                             #   projects, equipment, consumables, meetings, trash
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

The server ships to **DO App Platform** as a Docker image, with **DO Managed PostgreSQL + Redis**. Two files drive it:

- [`makerflow_server/Dockerfile`](makerflow_server/Dockerfile) — multi-stage: `dart compile exe bin/main.dart` → slim runtime (verified locally; produces a ~16 MB native binary).
- [`makerflow_server/deploy/entrypoint.sh`](makerflow_server/deploy/entrypoint.sh) — renders `config/<mode>.yaml` + `config/passwords.yaml` from env (DO managed-DB bindings + the `SERVICE_SECRET`), applies migrations, then serves.
- [`.do/app.yaml`](.do/app.yaml) — App Platform spec: web service from the Dockerfile (deploy-on-push from `staging`), a managed `makerflow-db` (PG 16) and `makerflow-redis`, health check on `GET /`.

```bash
# one-time: install + auth the DO CLI, then create the app
doctl auth init
doctl apps create --spec makerflow_dart/.do/app.yaml
# set the SERVICE_SECRET encrypted env in the dashboard (64+ random chars),
# then every push to staging redeploys automatically. Production cutover:
# merge staging -> main and flip `branch` in .do/app.yaml to main.
```

Or in the DO dashboard: **Create App → GitHub → ianroy/makerflowPM** and point it at `makerflow_dart/.do/app.yaml`. The local `docker-compose.yaml` (Postgres + Redis) remains the dev path; DO managed databases are production.

> Build the image locally to test before DO: `docker build -f makerflow_server/Dockerfile -t makerflow-server makerflow_dart` (run from the repo root). Not run in the authoring env (no Docker), but `dart compile exe` — the image's build step — is verified.

## Important notes

- **Generated code is committed.** `makerflow_server/lib/src/generated/**` and `makerflow_client/lib/**` are checked in, so the workspace compiles out of the box. Run `serverpod generate` only after editing model YAML or endpoints — and commit the output.
- **The Flutter app runs without a server.** It defaults to in-memory repositories, so the UI, theme, and keyboard kanban are demoable immediately. Pass `--dart-define=MAKERFLOW_LIVE=true` to use the live Serverpod repositories instead — see [`makerflow_flutter/lib/src/data/task_repository.dart`](makerflow_flutter/lib/src/data/task_repository.dart).
- **Accessibility:** the kanban ships a keyboard move pattern + live-region announcements (WCAG 2.1.1 / 2.5.1 / 4.1.3) and a non-color [`StatusBadge`](makerflow_design/lib/src/widgets/status_badge.dart) (1.4.1) from day one. The **Flutter Web a11y feasibility gate** (`fl-0-a11y-web-spike`) is unbuilt and must run before the web target is promised — see [`../FLUTTER_REBUILD_PLAN.md` §8](../FLUTTER_REBUILD_PLAN.md#8-accessibility--the-hard-part).
- This codebase is **independent** of the Python app at the repo root and does not modify it (D3: new deployments only).

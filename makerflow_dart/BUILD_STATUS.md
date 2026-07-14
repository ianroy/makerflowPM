# BUILD_STATUS.md — makerflow_dart

Authoritative per-card state for the Dart rebuild. Maps to the task cards in [`../FLUTTER_REBUILD_PLAN.md`](../FLUTTER_REBUILD_PLAN.md).

> **UI-1 monday app shell (2026-07-14, commits `cbddb89`+`f3d2793`):** grey frame + white rounded content sheet; ~48px top bar (wordmark, search/notification stubs, avatar menu w/ theme + sign-out); ~255px sidebar (workspace tile = live org switcher w/ first-membership default, Home, My-Work stub, Favorites stub, **Boards: All tasks + one board per project** — tap sets the project filter — + ops screens + Trash), Vibe selected/hover rows under a nav landmark, session-persistent collapse handle, <900px drawer. Tasks board joined the shell (controls in the sheet title row until UI-2); keyboard-move untouched. Dashboard: tile overflow fix + stale skeleton-note drift removed, retitled Home. **App 19/19** (6 new shell tests on the real router w/ stub sign-in) · analyze clean · web build ✓.
>
> **UI-0 Vibe design system (2026-07-14):** `makerflow_design` v0.2 — the monday.com-style foundation from `UI_REDESIGN_PLAN.md`. Vibe-exact tokens (light default + dark; brand `#0073EA`, surfaces, borders, the 29-color label palette, spacing/radius 4-8-16/shadows/motion), **bundled Figtree + Poppins** (OFL, in-package fonts), full ThemeData (buttons, inputs, dialogs, snackbars, focus ring), restyled `MfCard` (white r8 + xs shadow) and `StatusBadge` (solid label pill, AA text via `MndLabelColors.textOn`), new kit: `StatusLabel` cell/pill + `showStatusPicker`, `MndButton` (3 kinds, press-scale), `MndAvatar`/`MndAvatarStack`, `MndSkeleton` (opacity pulse, reduced-motion aware), `showMndToast` (Undo slot), `MndEmptyState`. App default flipped to **light**. AA notes: label map adjusted where monday's exact colors fail 4.5:1 (blocked → dark-red; black ink on bright labels) — enforced by a contrast unit test. Design suite **7/7** · app **13/13** (dialog dropdowns gained `isExpanded` after a theme-density overflow) · web build ✓. Goldens deferred: CI runs Linux, macOS-generated goldens would false-fail — needs a CI-generated baseline (tracked in the plan).
>
> **M1.4 project CRUD + drift repairs (2026-07-14):** `ProjectEndpoint.update`/`softDelete` (optimistic `version` added to the Project model + migration `20260714153805942`; tenancy pinned on update; audited) — **5 new integration tests → server 24/24**. Client: project create/edit dialog (+ Archive), tap-to-edit projects screen, and a **project filter on the task views** (`taskProjectFilterProvider` → `task.list(projectId)`); **app tests 13/13**; web build ✓. Repo repairs from the 2026-07-11 drift audit: **.dockerignore moved to the build-context root** (was inert → local images baked `passwords.yaml`; Dockerfile also now `rm -f`s it as defense in depth), **real CI at `/.github/workflows/dart-ci.yml`** (server: PG17 service + 24 tests; app: analyze/test/web build; the inert nested copy removed), `passwords.example.yaml` gained the required `test:` section, compose creates `makerflow_test` (PG 16→17 everywhere), `.do/app.yaml` engine `REDIS`→`VALKEY` (DO EOL'd managed Redis) + optional `EMAIL_PASSWORD_PEPPER`, melos `test` script fixed (flutter split), stale READMEs/ProductSpec/roadmap docs refreshed, tracked `.DS_Store`/SQLite-WAL artifacts untracked.
>
> **Re-verified green 2026-07-11** on an unchanged toolchain: server `dart analyze` clean + **19/19** (fresh PG cluster, full live integration suite) · app `flutter analyze` clean + **10/10** + `flutter build web` ✓. Deep-review findings that session: `Flutter_ProductSpec.md` refreshed end-to-end (26 stale claims), 12 stale plan cards corrected, and **CI found inert** (`dart-ci.yml` is under `makerflow_dart/.github/workflows/` — GitHub Actions only reads the repo root; move + modernize it). Next up: NS-M0.2 live DO deploy (owner token) ∥ NS-M1.4 project CRUD; the ranked makerspace capability backlog is in `NEXTSTEPS.md` (M-EXP).
>
> **Compiles + green (2026-06-16).** Run on Dart 3.12.2 / Flutter 3.44.2 / Serverpod 3.4.10:
> - Server: `serverpod generate` ✓ · `dart analyze` clean · `dart test` **19/19 ✓ (2 unit + 17 live integration)** · `serverpod create-migration` ✓ (112 tables).
> - Design: `flutter analyze` clean.
> - App: `flutter analyze` clean · `flutter test` ✓ · `flutter build web` ✓ (2.7 MB; WASM dry-run ✓).
> - Generated code (`makerflow_server/lib/src/generated/**`, `makerflow_client/lib/**`) and the first migration are committed.
>
> **Live run (2026-06-15):** stood up Postgres 17 (:8090) + Redis 8 (:8091) without Docker and exercised the real stack:
> - `serverpod ... --role maintenance --apply-migrations` → migration applied, **56 tables** in Postgres.
> - server booted (monolith); `GET /` → `200 OK` (built-in liveness); `POST /health{ready}` → `true` (live `Organization.db.count`).
> - `POST /task{list}` unauthenticated → **`400` + typed `MakerflowAuthException`** (RBAC gate fires end-to-end; serializable exceptions verified — `fl-0-error-taxonomy` done).
>
> **Seed + generated client (2026-06-15):**
> - `dart bin/seed.dart` → default org + serverpod_auth owner login + project + 6 tasks + equipment/consumable (verified via psql; idempotent).
> - **Generated client proven** end-to-end (`tool/client_smoke.dart`): `health.ready → true`; `task.list` no-auth → deserialized typed `MakerflowAuthException`. Fixed the client barrel export + added the `serverpod_auth_client` dep.
> - `ServerpodTaskRepository` + `serverpodClientProvider` wired into the Flutter app; enable with `--dart-define=MAKERFLOW_LIVE=true` (defaults to in-memory). `flutter analyze`/test/`build web` green.
>
> **Auth + deploy dry-run (2026-06-15):**
> - **Authenticated round-trip proven** (`tool/auth_smoke.dart`): sign in as the seeded owner via `modules.auth.email.authenticate` → Bearer-wrapped session key → `task.list(1)` returns the 6 seeded tasks through the RBAC gate.
> - **Flutter sign-in wired**: `MakerflowKeyManager` + `SessionController` + a real login screen (`--dart-define=MAKERFLOW_LIVE=true`); analyze/test/web-build green.
> - **Production deploy dry-run**: `dart compile exe` output run through the real `entrypoint.sh` in `runMode: production` (env-rendered config, migrations applied, `GET /` 200 + `health.ready` true). `.do/app.yaml` validated.
>
> **Live integration suite (2026-06-16):** 11 `withServerpod` cases, green (rollback-per-test, against `makerflow_test` on :8090). Added `config/test.yaml` (dedicated `test` run mode) + `dart_test.yaml` (declares the `integration` tag; `concurrency: 1` so the per-file Serverpod boots don't collide on ports).
> - `test/integration/role_matrix_test.dart` (6) — RBAC: staff/manager allow; viewer/unauthenticated/cross-org/`workspaceAdmin`-grants-owner deny with typed exceptions.
> - `test/integration/contract_test.dart` (5) — the rest of `docs/SECURITY.md`: every create writes one org-scoped `AuditLog` row; soft-delete drops out of `list` but restores via trash; stale-version `update` → `MakerflowConflictException`; reads are tenant-scoped; mutating a soft-deleted row → `MakerflowNotFoundException`.
> - `test/integration/feature_reads_test.dart` (6) — the read paths the Flutter `Serverpod*Repository` impls call: `org.listMine` (membership-scoped), `project`/`equipment`/`consumable`/`meeting` list endpoints return org-scoped rows; unauthenticated read rejected.
> - Fixed the generated test-tools blocker: `server_test_tools_path` was missing from `config/generator.yaml`, so `serverpod generate` skipped test-tools regen, freezing a stale file (`isDatabaseEnabled: false`, only the `realtime` wrapper). Added the key → regen produced `isDatabaseEnabled: true` + all 14 endpoint wrappers.
>
> **Live UI write-path proof (2026-06-25):** booted the dev server on real Postgres + Redis and ran `tool/ui_writepath_smoke.dart` — the exact `client.task.*` calls `ServerpodTaskRepository` makes. All green: `list`→6 seeded, `create`→id=7, `list`→7, `update` (base version) → v=2/urgent, `move`→inProgress, stale `update`→ typed `MakerflowConflictException`. Full UI write path proven over auth → RBAC → HTTP → Postgres (CanvasKit widgets themselves aren't headlessly DOM-drivable; the dialog→repository wiring is widget-tested).
>
> **Task create + edit write-paths (2026-06-16):** `TaskRepository.create`/`update` (in-memory + live `client.task.create`/`update`) behind one accessible create/edit dialog (`features/tasks/new_task_dialog.dart`: focus-trapped `AlertDialog`, labelled fields, required-field validation, busy state, typed-error surface + live-region announce). Create via a kanban FAB; edit via pointer tap / `E` key / screen-reader "Edit" action (keyboard-move pattern untouched). Live `update` sends the base `version` so the optimistic-concurrency check fires + preserves `sortOrder`. `flutter test` **3/3** (validation → create → card on board; tap card → edit → board updates); analyze + web build green. Server `task.create`/`update` already integration-tested.
>
> **Live Flutter feature repositories (2026-06-16):** added `Serverpod{Org,Project,Equipment,Consumable,Meeting}Repository` (`makerflow_flutter/lib/src/data/serverpod_feature_repositories.dart`) wrapping the generated client, wired behind `--dart-define=MAKERFLOW_LIVE=true` in `state/providers.dart` (default stays in-memory). Client mappers type-checked by `flutter analyze` (clean); server read-paths proven by `feature_reads_test.dart`; `flutter test` ✓ · `flutter build web` ✓ (WASM dry-run ✓). The `Task` repo's runtime round-trip is already proven (`tool/auth_smoke.dart`).
>
> **Auth polish (2026-06-25):** session persistence via `flutter_secure_storage` (native Keychain/Keystore + web Crypto/localStorage; `flutter build web` verified) + a startup `restore()` gate in `main.dart` (no login flash); the org switcher now also defaults the active org to the caller's first membership (`ref.listen(orgsProvider)`), not a hardcoded id.
>
> **Deploy readiness (2026-06-25):** all DO assets re-validated on current code — `dart compile exe` ✓ (15 MB), `.do/app.yaml` valid + bindings correct, `entrypoint.sh` `sh -n` ✓, migrations present. Spec repointed from `main` → **`staging`** (main is 10 commits behind and predates the Dockerfile/spec). Full runbook in [`DEPLOY.md`](DEPLOY.md). Only the live `doctl apps create` needs the user's token.
>
> **Production seed path (2026-06-25):** added a `--seed` flag to the server entrypoint so the *runtime* image can seed the managed DB (previously `bin/seed.dart` ran only in the Docker build stage). `bin/seed.dart` and `--seed` now share one `runSeed` bootstrap (`lib/server.dart`) that constructs Serverpod and calls `createSession()` **without `pod.start()`** — the constructor already starts the DB pool, so a session is available without binding the HTTP ports (8080–82) or connecting Redis, making it safe to run inside the already-serving container (`doctl apps console web` → `/app/server --mode production --seed`, or `/app/entrypoint.sh seed`). `entrypoint.sh` gained a `serve`/`seed` dispatch (default serves; DO's no-arg start is unaffected). **Verified:** `dart compile exe` ✓; the compiled binary applied migrations (56 tables) then seeded the default org + owner login (`admin@makerflow.local`, `["superuser"]`) + project + 6 tasks + equipment/consumable against a local PG (:8090) **with 8080–82 occupied** (proving no port bind); a second run is a no-op (idempotent, counts unchanged); `entrypoint.sh` `sh -n` + dispatch traced; `dart analyze` clean. `DEPLOY.md` step 6 updated.
>
> **Ops-feature edit paths + non-destructive edits (2026-06-25):** equipment/consumable/meeting now have create **and** edit (one create/edit dialog each; tap a list card to edit; `flutter test` 6/6). Edits are **fetch-merge** in the live repos — read the current row, `copyWith` the edited fields, save — so they preserve server-only fields the thin VMs don't carry (assetTag, spaceId, maintenance dates, meetingAt, …). Same fix applied to the **task** edit (fetches the row, overrides `version` with the caller's base so optimistic-concurrency still fires). One known limit: clearing an optional field (e.g. consumable unit) is a no-op via copyWith.
>
> **Remaining:** run the live DO deploy (needs `doctl` + token; see `DEPLOY.md`), password-reset flow, equipment space-name resolution (Space join), a `getById`/`getOne` endpoint to avoid the list round-trip in fetch-merge edits, offline/push/camera/biometric.

## Legend
`[x]` built · `[~]` partial / authored-not-verified · `[ ]` not started

## Phase 0 — Foundations

| Task | State | Notes |
|---|---|---|
| `fl-0-monorepo-scaffold` | `[~]` | Melos workspace, 5 packages, docker-compose, config, entrypoint. Needs `serverpod create` alignment + codegen. |
| `fl-0-design-tokens` | `[x]` | Tokens (dark+light), ThemeData + ThemeExtension, `MfCard`, non-color `StatusBadge`. Font bundling TODO. |
| `fl-0-auth-rbac-tenancy` | `[~]` | RBAC guard, AuthContext, tenancy guards, audit interceptor, soft-delete pattern + `OrgEndpoint` (membership mgmt w/ owner-protection). Real serverpod_auth sign-in proven; **role-matrix proven by a live 6-case integration suite**. Org-switch UI wired to live memberships + session persistence remain. |
| `fl-0-a11y-web-spike` | `[~]` | **GATE — blocked on human AT pass.** Fixture (`/spike`) + report instrument built; needs NVDA/VoiceOver/keyboard run + decision. |
| `fl-0-ci-pipelines` | `[~]` | `dart-ci.yml` authored (analyze/test/build + ephemeral PG/Redis + codegen step). axe-core web gate TODO. |
| `fl-0-error-taxonomy` | `[~]` | Exception types in code + serializable-exception spec (`models/exceptions/`); pagination envelope (`Cursor`/`Page`) authored. Client error-surface + migration onto generated exceptions TODO. |
| `fl-0-state-conventions` | `[~]` | Repository seam, Riverpod providers, go_router auth-redirect, `AsyncList` helper. Conventions doc + optimistic-rollback helper TODO. |
| `fl-0-seed-data` | `[ ]` | Not started (depends on live auth). |

## Phase 1 — Core PM

| Task | State | Notes |
|---|---|---|
| `fl-1-projects-tasks` | `[~]` | Project/Task models + endpoints (security contract + optimistic version, **integration-tested**) · keyboard-accessible kanban · projects list screen · **live `ServerpodTaskRepository` + `ServerpodProjectRepository`** · **task create + edit write-paths** (accessible create/edit dialog; tap / `E` / SR-action to edit; widget-tested). Task list/calendar views TODO. |
| `fl-1-realtime-infra` | `[~]` | `ChangeEvent` model + `Channels` (Redis pub/sub) + `RealtimeEndpoint`. Reconnect-from-cursor + load test TODO. |
| `fl-1-collab` | `[~]` | `ItemComment`/`ItemWatcher` + `CollabEndpoint` (comments, watch, `activityStream`). Client live-region wiring TODO. |
| `fl-1-views-fields` | `[~]` | `CustomView`/`FieldConfig` models authored; endpoints + dynamic field UI TODO. |
| `fl-1-testing-harness` | `[~]` | **Live serverpod_test integration harness (role-matrix, 6 cases, green)** + RBAC unit test + kanban widget test; `dart_test.yaml` tags integration tests. Golden + E2E TODO. |
| `fl-1-i18n-scaffold` | `[ ]` | Not started. |

## Phase 2 — Operations

| Task | State | Notes |
|---|---|---|
| `fl-2-meetings` | `[~]` | Agenda/item/update models + `MeetingEndpoint` (incl. `convertItemToTask`) + meetings list screen + **live `ServerpodMeetingRepository` with create + edit** ("New meeting" / tap-to-edit → `saveAgenda`, fetch-merge). Agenda detail UI TODO. |
| `fl-2-inventory` | `[~]` | Equipment/Consumable/Partnership/Intake models + endpoints (consumable derives reorder status; intake `convertToProject`) + equipment & consumables screens + **live repos with create + edit write-paths** (accessible create/edit dialogs, tap-to-edit cards, widget-tested; consumable numeric validation; **non-destructive fetch-merge edits**). Partnerships/intake screens + attachments TODO. |
| `fl-2-pagination-perf` | `[~]` | Cursor helper authored + used by sync. Roll across all lists + client infinite-scroll TODO. |

## Phase 3 — People & analytics

| Task | State | Notes |
|---|---|---|
| `fl-3-onboarding` | `[~]` | Template/Assignment models + `OnboardingEndpoint` (assign + self/manager setState). UI TODO. |
| `fl-3-reports-admin-settings` | `[~]` | `ReportTemplate`/`InsightSnapshot`/`UserPreference`/`RoleNavPreference`/`Space`/`Team`/`TeamMember`/`UserProfile` models authored. Reports/admin/settings/trash endpoints + UI partial (`TrashEndpoint` done). |

## Phase 4 — Integrations

| Task | State | Notes |
|---|---|---|
| `fl-4-calendar` | `[~]` | `CalendarEvent`/`CalendarSyncSetting`/`CalendarSyncLink`/`MeetingNoteSource` models authored. googleapis FutureCall + endpoints TODO. |
| `fl-4-io-mail` | `[~]` | `EmailMessage` model authored. CSV/ICS/PDF endpoints + SMTP send TODO. |
| `fl-4-observability` | `[~]` | `Obs` structured logger + redaction authored. Request-id propagation + Insights + error tracker TODO. |

## Phase 5 — Native superpowers

| Task | State | Notes |
|---|---|---|
| `fl-5-offline-sync` | `[~]` | `SyncCursor`/`TaskDeltaPage` + `SyncEndpoint` (keyset pull + tombstones + ackCursor). Drift cache + mutation queue + reconciler TODO. |
| `fl-5-push` | `[~]` | `DeviceToken` model authored. FCM/APNs + endpoints + client TODO. |
| `fl-5-camera-biometric` | `[~]` | `Attachment` model authored. Capture/upload + local_auth TODO. |
| `fl-5-store-compliance` | `[ ]` | Not started. |

## Phase 6 — Accessibility & compliance

| Task | State | Notes |
|---|---|---|
| `fl-6-a11y-conformance` | `[~]` | Patterns seeded throughout (Semantics, focus, live regions, non-color status, labelled forms). Cross-platform conformance + manual AT passes TODO; depends on the spike gate. |
| `fl-6-vpat` | `[ ]` | Not started. |

## Phase 7 — Release

| Task | State | Notes |
|---|---|---|
| `fl-7-release-pipelines` | `[ ]` | Not started (CI scaffold exists in `dart-ci.yml`). |

## Inventory summary

- **Models:** 35 (`lib/src/models/*.spy.yaml`) + 11 enums (`lib/src/models/enums/`).
- **Endpoints:** task, project, health, org, collab, equipment, consumable, meeting, partnership, intake, onboarding, trash, realtime, sync.
- **Business:** auth_context, rbac, tenancy, audit, pagination, observability, channels.
- **Flutter:** app shell (org switcher + nav), dashboard, login, kanban, projects, equipment, consumables, meetings, a11y spike; repository seam with both in-memory and **live `Serverpod*Repository`** impls (task + org + project + equipment + consumable + meeting) selected by `MAKERFLOW_LIVE` + Riverpod providers.

## Immediate next steps (in order)

1. ~~Install toolchain + first compile~~ — **done**.
2. ~~Live DB: apply migration + boot server + round-trip~~ — **done** (56 tables; `health.ready` → true; RBAC negative → 400 typed).
3. Close `fl-0-a11y-web-spike` (the gate): run the AT matrix on `/spike` against `flutter run -d chrome`; decide Flutter Web vs server-rendered fallback.
4. Finish `fl-0-auth-rbac-tenancy`: real sign-in (serverpod_auth email/password), org switch wired to live auth, fill the role-matrix test fixtures (serverpod_test).
5. Swap in-memory repositories → `Serverpod*` impls wrapping the generated client (then the Flutter app talks to the live server).
6. Map typed exceptions to the Flutter error surface + a11y announce (client side of `fl-0-error-taxonomy`).

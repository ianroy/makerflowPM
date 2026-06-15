# BUILD_STATUS.md — makerflow_dart

Authoritative per-card state for the Dart rebuild. Maps to the task cards in [`../FLUTTER_REBUILD_PLAN.md`](../FLUTTER_REBUILD_PLAN.md).

> **Compiles + green (2026-06-15).** Run on Dart 3.12.2 / Flutter 3.44.2 / Serverpod 3.4.10:
> - Server: `serverpod generate` ✓ · `dart analyze` clean · `dart test` 2/2 ✓ · `serverpod create-migration` ✓ (112 tables).
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
> **Remaining for a live UI round-trip:** client-side serverpod_auth sign-in/session (so live reads pass the RBAC gate), then the app talks to the live server. Role-matrix serverpod_test fixtures still to do.

## Legend
`[x]` built · `[~]` partial / authored-not-verified · `[ ]` not started

## Phase 0 — Foundations

| Task | State | Notes |
|---|---|---|
| `fl-0-monorepo-scaffold` | `[~]` | Melos workspace, 5 packages, docker-compose, config, entrypoint. Needs `serverpod create` alignment + codegen. |
| `fl-0-design-tokens` | `[x]` | Tokens (dark+light), ThemeData + ThemeExtension, `MfCard`, non-color `StatusBadge`. Font bundling TODO. |
| `fl-0-auth-rbac-tenancy` | `[~]` | RBAC guard, AuthContext, tenancy guards, audit interceptor, soft-delete pattern + `OrgEndpoint` (membership mgmt w/ owner-protection). Real serverpod_auth sign-in flow + org-switch UI wired to live auth + full role-matrix tests remain. |
| `fl-0-a11y-web-spike` | `[~]` | **GATE — blocked on human AT pass.** Fixture (`/spike`) + report instrument built; needs NVDA/VoiceOver/keyboard run + decision. |
| `fl-0-ci-pipelines` | `[~]` | `dart-ci.yml` authored (analyze/test/build + ephemeral PG/Redis + codegen step). axe-core web gate TODO. |
| `fl-0-error-taxonomy` | `[~]` | Exception types in code + serializable-exception spec (`models/exceptions/`); pagination envelope (`Cursor`/`Page`) authored. Client error-surface + migration onto generated exceptions TODO. |
| `fl-0-state-conventions` | `[~]` | Repository seam, Riverpod providers, go_router auth-redirect, `AsyncList` helper. Conventions doc + optimistic-rollback helper TODO. |
| `fl-0-seed-data` | `[ ]` | Not started (depends on live auth). |

## Phase 1 — Core PM

| Task | State | Notes |
|---|---|---|
| `fl-1-projects-tasks` | `[~]` | Project/Task models + endpoints (security contract + optimistic version) · keyboard-accessible kanban · projects list screen. Task list/calendar views + live client TODO. |
| `fl-1-realtime-infra` | `[~]` | `ChangeEvent` model + `Channels` (Redis pub/sub) + `RealtimeEndpoint`. Reconnect-from-cursor + load test TODO. |
| `fl-1-collab` | `[~]` | `ItemComment`/`ItemWatcher` + `CollabEndpoint` (comments, watch, `activityStream`). Client live-region wiring TODO. |
| `fl-1-views-fields` | `[~]` | `CustomView`/`FieldConfig` models authored; endpoints + dynamic field UI TODO. |
| `fl-1-testing-harness` | `[~]` | Role-matrix test scaffold + RBAC unit test + kanban widget test. serverpod_test fixtures + golden + E2E TODO. |
| `fl-1-i18n-scaffold` | `[ ]` | Not started. |

## Phase 2 — Operations

| Task | State | Notes |
|---|---|---|
| `fl-2-meetings` | `[~]` | Agenda/item/update models + `MeetingEndpoint` (incl. `convertItemToTask`) + meetings list screen. Agenda detail UI TODO. |
| `fl-2-inventory` | `[~]` | Equipment/Consumable/Partnership/Intake models + endpoints (consumable derives reorder status; intake `convertToProject`) + equipment & consumables screens. Partnerships/intake screens + attachments TODO. |
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
- **Flutter:** app shell (org switcher + nav), dashboard, login, kanban, projects, equipment, consumables, meetings, a11y spike; repositories + Riverpod providers.

## Immediate next steps (in order)

1. ~~Install toolchain + first compile~~ — **done**.
2. ~~Live DB: apply migration + boot server + round-trip~~ — **done** (56 tables; `health.ready` → true; RBAC negative → 400 typed).
3. Close `fl-0-a11y-web-spike` (the gate): run the AT matrix on `/spike` against `flutter run -d chrome`; decide Flutter Web vs server-rendered fallback.
4. Finish `fl-0-auth-rbac-tenancy`: real sign-in (serverpod_auth email/password), org switch wired to live auth, fill the role-matrix test fixtures (serverpod_test).
5. Swap in-memory repositories → `Serverpod*` impls wrapping the generated client (then the Flutter app talks to the live server).
6. Map typed exceptions to the Flutter error surface + a11y announce (client side of `fl-0-error-taxonomy`).

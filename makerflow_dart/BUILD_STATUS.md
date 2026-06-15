# BUILD_STATUS.md — makerflow_dart

Authoritative per-card state for the Dart rebuild. Maps to the task cards in [`../FLUTTER_REBUILD_PLAN.md`](../FLUTTER_REBUILD_PLAN.md).

> **Authored, NOT compiled.** Everything here was written without a local Dart/Flutter/Serverpod toolchain. Before relying on any of it: `cd makerflow_dart && melos bootstrap && (cd makerflow_server && serverpod generate) && melos run analyze` and resolve findings. The server's `lib/src/generated/**` + `makerflow_client/lib/**` do not exist until codegen runs; the Flutter app runs before codegen via in-memory repositories.

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

1. Install toolchain; `serverpod generate`; `melos bootstrap`; `melos run analyze` — resolve first-compile findings (relations syntax, generated imports, serverpod_auth API shape).
2. Close `fl-0-a11y-web-spike` (the gate): run the AT matrix on `/spike`; decide Flutter Web vs server-rendered fallback.
3. Finish `fl-0-auth-rbac-tenancy`: real sign-in, org switch wired to live auth, fill the role-matrix test fixtures.
4. Swap in-memory repositories → `Serverpod*` impls wrapping the generated client.
5. Generate migrations (`serverpod create-migration`) and run them.

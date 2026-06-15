# BUILD_STATUS.md — makerflow_dart

Maps what's on disk to the task cards in [`../FLUTTER_REBUILD_PLAN.md`](../FLUTTER_REBUILD_PLAN.md). This is a **walking skeleton**, authored without a local toolchain (not compiled here — see [README](README.md)).

## Legend
`[x]` built · `[~]` partial / scaffolded · `[ ]` not started

## Phase 0 — Foundations

| Task | State | Notes |
|---|---|---|
| `fl-0-monorepo-scaffold` | `[~]` | Melos workspace, 5 packages, docker-compose, server config, entrypoint authored. Not run through `serverpod create`/`generate` (no toolchain here). |
| `fl-0-design-tokens` | `[x]` | `makerflow_design`: all 12 color tokens (dark+light) ported from `style.css`, `ThemeData` + `ThemeExtension`, `MfCard`, non-color `StatusBadge`. Avenir Next font bundling left as a TODO in pubspec. |
| `fl-0-auth-rbac-tenancy` | `[~]` | RBAC guard (`requireRole`, role rank), `AuthContext`, audit interceptor, soft-delete pattern, models (org/membership/audit) authored + a unit test. `serverpod_auth` wired in `server.dart`. Tenancy repository base + full org-switch UI still to do. |
| `fl-0-a11y-web-spike` | `[ ]` | **GATE — not started.** Highest-priority next task; must resolve before the web target is promised. |
| `fl-0-ci-pipelines` | `[~]` | `dart-ci.yml` authored (analyze + test + web/android build, ephemeral PG/Redis). axe-core web gate still to add. |

## Phase 1 — Core PM (vertical slice)

| Task | State | Notes |
|---|---|---|
| `fl-1-projects-tasks` | `[~]` | Server: `Project`/`Task` models + endpoints with full security contract (requireRole → org-scope → audit → soft-delete → optimistic-version). App: keyboard-accessible kanban (drag **and** keyboard move + live-region announcements), dashboard, login. Running on `InMemoryTaskRepository` until codegen + auth land. List/calendar views, projects screen, real client wiring: TODO. |
| `fl-1-collab` | `[ ]` | Not started. |
| `fl-1-views-fields` | `[ ]` | Not started. |

## Phases 2–7

`[ ]` Not started. Operations, people/analytics, integrations, native (offline/push/camera/biometric), cross-platform accessibility conformance + VPAT, and release pipelines remain — see the plan.

## Immediate next steps (in order)

1. Install toolchain; `serverpod create`-align the server package layout; `serverpod generate`; `melos bootstrap`; resolve analyzer findings.
2. Run `fl-0-a11y-web-spike` (the gate) — decide Flutter Web vs server-rendered web fallback.
3. Finish `fl-0-auth-rbac-tenancy`: real sign-in, org switch, tenancy repository base, role-matrix tests.
4. Swap `InMemoryTaskRepository` → `ServerpodTaskRepository`; wire the kanban to live endpoints.
5. Round out `fl-1`: list + calendar views, projects screen, comments/watchers.

# MakerFlow PM (Dart Rebuild) — Product Spec & Developer Onboarding Guide

> Audience: a developer joining the **Flutter + Serverpod** rebuild of MakerFlow PM. By the end you can run the Dart stack locally, find anything in the monorepo, ship a small change end-to-end, and know where the work is sequenced.
>
> **Status (read first, updated 2026-07-14):** the Dart rebuild has grown well past the original walking skeleton. On disk and green: the **full parity data model** (37 models + 11 enums + 4 typed exceptions), **14 endpoint classes**, a **live serverpod_test integration suite** (19 green server tests: 2 unit + 17 live integration over real Postgres), the committed generated client wired into the app behind **live repositories**, **task CRUD + ops-feature create/edit from the UI**, soft-delete with a **Trash screen**, real sign-in with **persisted sessions**, a **production seed path**, and **verified DigitalOcean deploy assets**. The front end now wears the **monday.com-style interface** (UI-0…UI-3a shipped: Vibe design system w/ bundled Figtree/Poppins, grey-frame shell + boards sidebar, board chrome with view tabs + toolbar, and the grouped inline-editing **Main Table** as the default Tasks view — see [`makerflow_dart/UI_REDESIGN_PLAN.md`](makerflow_dart/UI_REDESIGN_PLAN.md) §8 for the tick-by-tick build log). It compiles green on Dart 3.12.2 / Flutter 3.44.2 / Serverpod 3.4.10 and all suites pass (server 24 · design 7 · app 26). The shipping product is still the Python app at the repo root ([`ProductSpec.md`](ProductSpec.md)); this rebuild is **greenfield, new deployments only**.

- Plan & backlog: [`FLUTTER_REBUILD_PLAN.md`](FLUTTER_REBUILD_PLAN.md)
- What's actually on disk: [`makerflow_dart/BUILD_STATUS.md`](makerflow_dart/BUILD_STATUS.md)
- Roadmap / next milestones: [`makerflow_dart/NEXTSTEPS.md`](makerflow_dart/NEXTSTEPS.md)
- Deploy runbook (DigitalOcean): [`makerflow_dart/DEPLOY.md`](makerflow_dart/DEPLOY.md)
- Target architecture diagram: [`docs/diagrams/11-flutter-target-architecture.svg`](docs/diagrams/11-flutter-target-architecture.svg)
- The product being matched (domain reference): [`ProductSpec.md`](ProductSpec.md)
- License: [CC BY-SA 4.0](LICENSE)

---

## Table of contents

1. [What this is](#1-what-this-is)
2. [Why a rebuild, and the four locked decisions](#2-why-a-rebuild-and-the-four-locked-decisions)
3. [Current status — what's built](#3-current-status--whats-built)
4. [Architecture](#4-architecture)
5. [Monorepo layout — where things live](#5-monorepo-layout--where-things-live)
6. [Run it locally](#6-run-it-locally)
7. [Request lifecycle](#7-request-lifecycle)
8. [Data model](#8-data-model)
9. [Auth, RBAC, tenancy, audit](#9-auth-rbac-tenancy-audit)
10. [Adding a feature — the canonical recipe](#10-adding-a-feature--the-canonical-recipe)
11. [State management & navigation conventions](#11-state-management--navigation-conventions)
12. [Design system](#12-design-system)
13. [Accessibility](#13-accessibility)
14. [Offline & realtime](#14-offline--realtime)
15. [Testing](#15-testing)
16. [Debugging cookbook](#16-debugging-cookbook)
17. [Deployment](#17-deployment)
18. [Known gaps and not-yet-built](#18-known-gaps-and-not-yet-built)
19. [Where to go next](#19-where-to-go-next)

---

## 1. What this is

MakerFlow PM is a self-hostable project-management + operations platform for makerspaces, university labs, and service teams (full domain in [`ProductSpec.md`](ProductSpec.md)). This document covers the **Dart rebuild**: the same product, re-implemented as a single-language stack —

- a **Flutter** client compiled to **six targets** (web, iOS, Android, macOS, Windows, Linux), and
- a **Serverpod** backend (Dart) on PostgreSQL + Redis,

with end-to-end type safety (the server generates the client), plus native capabilities the server-rendered Python app can't offer: offline-first, push notifications, camera capture, biometric unlock.

Built by [Ian Roy](https://github.com/ianroy). The Python original was built with an OpenAI Codex workflow; this rebuild is sequenced for agent-driven execution via [`FLUTTER_REBUILD_PLAN.md`](FLUTTER_REBUILD_PLAN.md).

## 2. Why a rebuild, and the four locked decisions

The Python app is a server-rendered WSGI monolith — excellent for cheap self-hosting and accessibility, but web-only and single-language (Python + JS + CSS). The rebuild trades that for one Dart codebase across every platform plus native features.

Four decisions are **locked** (see [`FLUTTER_REBUILD_PLAN.md` §1](FLUTTER_REBUILD_PLAN.md#1-decisions-of-record); a fifth, D5, requires the server to deploy on DigitalOcean):

| # | Decision | Choice |
|---|---|---|
| D1 | Backend | **Full Dart — Serverpod** (+ PostgreSQL, Redis) |
| D2 | Platforms | **Web + iOS + Android + macOS + Windows + Linux** |
| D3 | Migration | **Greenfield, new deployments only** (no data migration; Python app stays) |
| D4 | Scope | **Full parity + native-only features** (offline, push, camera, biometric) |
| D5 | Hosting | **Must deploy on DigitalOcean App Platform** (managed PG + Redis) |

## 3. Current status — what's built

Everything below **compiles and passes its tests** (Dart 3.12.2 / Flutter 3.44.2 / Serverpod 3.4.10; re-verified green 2026-07-11 — authoritative detail in [`makerflow_dart/BUILD_STATUS.md`](makerflow_dart/BUILD_STATUS.md)):

- **Server:** the full parity data model — **37 models + 11 enums + 4 serializable exceptions** (`lib/src/models/`); **14 endpoint classes** (`task`, `project`, `health`, `org`, `collab`, `equipment`, `consumable`, `meeting`, `partnership`, `intake`, `onboarding`, `trash`, `realtime`, `sync`); the security contract (`RbacGuard.requireRole`, `AuthContext`, `Tenancy`, `Audit`) **proven by a live 17-case serverpod_test integration suite** (role matrix · audit/soft-delete/version/tenancy contract · feature read-paths) plus 2 unit tests; `serverpod_auth` sign-in proven end-to-end; a production `--seed` path.
- **Design:** `makerflow_design` — the 12 color tokens (dark + light) ported from the Python `style.css`, `ThemeData`, `MfCard`, and a non-color `StatusBadge`.
- **App:** `makerflow_flutter` — Riverpod + go_router; **real sign-in with persisted sessions** (`flutter_secure_storage` + a startup `restore()` gate); an app shell with a **live org switcher** (active org defaults to the caller's first membership); dashboard; tasks as a **keyboard-accessible kanban + a List view** (Board/List toggle) with accessible create/edit dialogs and soft-delete; projects, equipment, consumables, and meetings screens with **create and non-destructive (fetch-merge) edit**; a **Trash screen** (restore / confirm-gated purge). The UI talks to a repository seam with in-memory impls (default) and **live `Serverpod*Repository` impls** wrapping the generated client, selected by `--dart-define=MAKERFLOW_LIVE=true`. **10 widget/unit tests** across three files.
- **Infra/docs:** `docker-compose` (Postgres + Redis), the committed first migration, seed tooling (`bin/seed.dart` + the production `--seed` flag), **verified DO deploy assets** (`Dockerfile`, `deploy/entrypoint.sh` with a `serve|seed` dispatch, `.do/app.yaml`) with the [`DEPLOY.md`](makerflow_dart/DEPLOY.md) runbook, smoke scripts under `tool/` (`client_smoke`, `auth_smoke`, `ui_writepath_smoke` — the last proves the full UI write path over auth → RBAC → HTTP → Postgres), plus README, BUILD_STATUS, and [`NEXTSTEPS.md`](makerflow_dart/NEXTSTEPS.md).

**Not built:** the offline client (Drift cache + mutation queue), push, camera, biometric, calendar-sync jobs, reports/admin/settings UI, partnerships/intake screens, agenda detail (items + convert-to-task), store compliance, and release pipelines. Meetings and inventory have endpoints and screens with create/edit; onboarding, realtime, and sync exist **server-side** with client work TODO.

**The a11y web gate** (`fl-0-a11y-web-spike`): the fixture (`/spike` route) and report instrument are **built**; the empirical screen-reader/keyboard pass is human-gated and still open — it decides the web target's fate (see §13).

## 4. Architecture

<p align="center">
  <img src="docs/diagrams/11-flutter-target-architecture.svg" alt="Flutter + Serverpod target architecture" width="100%"/>
</p>

- **Client (`makerflow_flutter`)** — one widget tree → six targets. Layered: `go_router` → screens/widgets → **Riverpod** state → repositories → generated client. Local **Drift** cache for offline (planned); native plugins for biometric/camera/push (planned).
- **Transport (`makerflow_client`)** — Serverpod's generated, type-safe client (committed). `Future<T>` over HTTP; `Stream<T>` over WebSocket for realtime + sync. Bearer-token auth (no cookies → **no CSRF**).
- **Server (`makerflow_server`)** — Serverpod. Endpoint classes replace the Python app's 103 route branches; `serverpod_auth` replaces the sessions table + PBKDF2 + CSRF. A central RBAC + tenancy guard and an audit interceptor wrap business logic; `FutureCall`s will run scheduled jobs (calendar sync, reminders); the ORM is generated from model YAML.
- **Data** — PostgreSQL (primary), Redis (cache + pub/sub for streaming), object storage (DO Spaces / S3) for attachments.

Full Python→Dart mapping: [`FLUTTER_REBUILD_PLAN.md` §3](FLUTTER_REBUILD_PLAN.md#3-stack-translation-python--dart). Endpoint map: [Appendix A](FLUTTER_REBUILD_PLAN.md#a-endpoint-map-103-routes--serverpod-endpoints).

## 5. Monorepo layout — where things live

```
makerflow_dart/                  # Melos workspace
├── melos.yaml
├── .do/app.yaml                 # DO App Platform spec (deploys from `staging`)
├── DEPLOY.md                    # DigitalOcean runbook
├── NEXTSTEPS.md                 # milestone roadmap (M0–M6)
├── makerflow_server/            # Serverpod backend
│   ├── config/                  # development.yaml, test.yaml, generator.yaml, passwords.example.yaml
│   ├── docker-compose.yaml      # Postgres :8090 + Redis :8091
│   ├── Dockerfile               # multi-stage dart compile exe → debian-slim
│   ├── deploy/entrypoint.sh     # renders config from env; `serve` | `seed`
│   ├── migrations/              # committed migrations (applied = 56 tables)
│   ├── bin/{main,seed}.dart
│   ├── lib/server.dart          # bootstrap (serverpod_auth) + shared runSeed() (--seed flag)
│   ├── lib/src/models/          # 37 *.spy.yaml + enums/ + exceptions/
│   ├── lib/src/business/        # rbac, auth_context, tenancy, audit, pagination, channels, seed, observability
│   ├── lib/src/endpoints/       # 14 endpoints (task…sync)
│   ├── lib/src/generated/       # committed codegen output (regen on model changes)
│   ├── test/                    # 2 unit + 17 live integration (test/integration/)
│   └── tool/                    # client_smoke, auth_smoke, ui_writepath_smoke
├── makerflow_client/            # generated client (committed; never hand-edit)
├── makerflow_design/            # tokens, ThemeData, MfCard, StatusBadge
├── makerflow_flutter/           # the app
│   └── lib/src/{data,state,features}/
└── makerflow_shared/            # non-generated shared constants
```

| Looking for… | Go to… |
|---|---|
| A server route | `makerflow_server/lib/src/endpoints/*_endpoint.dart` |
| A DB table | `makerflow_server/lib/src/models/*.spy.yaml` |
| The RBAC gate | `makerflow_server/lib/src/business/rbac.dart` |
| The audit interceptor | `makerflow_server/lib/src/business/audit.dart` |
| A screen | `makerflow_flutter/lib/src/features/<area>/` |
| App state / providers / routes | `makerflow_flutter/lib/src/state/providers.dart` |
| The repository seam | `makerflow_flutter/lib/src/data/*_repository.dart` (in-memory + `serverpod_*` live impls) |
| Create/edit dialogs | `features/tasks/new_task_dialog.dart`, `features/inventory/feature_create_dialogs.dart` |
| Design tokens / theme | `makerflow_design/lib/src/{tokens,theme}.dart` |

## 6. Run it locally

Requires the Dart + Flutter + Serverpod toolchain (none of it is committed; install locally).

```bash
# tooling
dart pub global activate melos
dart pub global activate serverpod_cli

# workspace deps
cd makerflow_dart && melos bootstrap

# infra + DB
cd makerflow_server
cp config/passwords.example.yaml config/passwords.yaml
docker compose up -d                 # Postgres :8090, Redis :8091

dart bin/main.dart --apply-migrations --role maintenance   # 56 tables
dart bin/seed.dart                   # default org + owner (admin@makerflow.local) + demo data (idempotent)
dart bin/main.dart                   # serves on :8080

# run the app on any target — LIVE against the local server:
cd ../makerflow_flutter
flutter run -d chrome --dart-define=MAKERFLOW_LIVE=true
# …or omit the define to run on in-memory demo data (no server needed)
```

**Generated code is committed.** `makerflow_server/lib/src/generated/**` and `makerflow_client/lib/**` are in the repo, so a fresh clone compiles immediately. Re-run `serverpod generate` whenever you change model YAML or endpoint signatures, and commit the regenerated output. The app runs in two modes: in-memory repositories by default (demo data, serverless), or the live `Serverpod*Repository` impls behind `--dart-define=MAKERFLOW_LIVE=true` (selection in `lib/src/state/providers.dart`).

## 7. Request lifecycle

A typical authenticated call:

1. **Client** invokes a generated method, e.g. `client.task.move(id, status, order)`. The serverpod_auth session key (persisted in `flutter_secure_storage`) rides the request as a Bearer header — no CSRF.
2. **Serverpod** routes to `TaskEndpoint.move(session, …)`; `session.authenticated` resolves the signed-in user.
3. **Guard** — `RbacGuard.requireRole(session, orgId, MembershipRole.staff)` loads the caller's `Membership`, confirms the role, and returns an `AuthContext`. Missing/under-privileged/cross-org → throws a typed exception.
4. **Tenancy** — every query is scoped `organizationId == ctx.organizationId`; `Tenancy` guards block org reassignment.
5. **Mutation + version** — `Task` carries a `version`; a stale `version` throws `MakerflowConflictException` (surfaced in the edit dialog; offline-safe).
6. **Audit** — `Audit.record(...)` writes an append-only `AuditLog` row (actor, org, entity, action, payload hash).
7. **Response** — the typed result returns to the client; **streaming** endpoints push deltas over WebSocket (activity feed, sync).

Health: `GET /` (Serverpod's built-in liveness, no DB — the old `/healthz` route was dropped in the Serverpod 3.x move; a string route is tracked as `fl-0-health-route`, deferred) and `HealthEndpoint.ready` (DB round-trip readiness).

## 8. Data model

Serverpod generates the Dart class + table + ORM from YAML. Conventions: `organizationId` on every org-scoped row; `createdAt/updatedAt/createdByUserInfoId`; `deletedAt/deletedByUserInfoId` for soft-delete; `version` + `clientUuid` on offline-writable rows; keyset/cursor pagination on lists (the `Cursor`/`Page` helper exists; rollout across all lists is pending).

The full 39-table mapping (with soft-delete / offline / tenancy flags, ID strategy, polymorphic associations, and the enum inventory) is in [`FLUTTER_REBUILD_PLAN.md` §4](FLUTTER_REBUILD_PLAN.md#4-data-model-translation-39-tables--serverpod-models). **All 37 parity models + 11 enums + 4 typed exceptions are authored and generated**, and the first migration is committed and verified against live Postgres (56 tables). Remaining schema work is incremental (new fields per feature), not new-entity buildout.

## 9. Auth, RBAC, tenancy, audit

The Python app's security contract is reproduced exactly, not approximated ([`docs/SECURITY.md`](docs/SECURITY.md)) — and **proven by the live integration suite** (`test/integration/`).

- **Auth:** `serverpod_auth` email/password. Session keys persist in secure storage (Keychain/Keystore native, Web Crypto + localStorage web); bearer transport. Register + password-reset flows are still TODO.
- **Roles:** `viewer < student < staff < manager < workspaceAdmin < owner`, as a `MembershipRole` enum with integer rank. Platform-level `superuser` is a serverpod_auth scope and the only path across orgs; `workspaceAdmin` is pinned to one org (integration-tested).
- **Guard:** `RbacGuard.requireRole(session, orgId, minRole)` is called first in every endpoint method.
- **Tenancy:** repository-level org scoping + `Tenancy` guards; cross-org access rejected (integration-tested).
- **Audit:** `Audit.record` centralizes the append-only trail (create → one org-scoped row with actor + payload hash; integration-tested).
- **Soft-delete:** `deletedAt` is set; default reads exclude it; `TrashEndpoint` + the Trash screen restore or purge (integration- and widget-tested).

Deep dives: auth/session ([Appendix B](FLUTTER_REBUILD_PLAN.md#b-auth--session-architecture)), security hardening ([Appendix G](FLUTTER_REBUILD_PLAN.md#g-security-hardening-threat-model-port)).

## 10. Adding a feature — the canonical recipe

To add an entity (say `widget`) end-to-end:

1. **Model** — add `makerflow_server/lib/src/models/widget.spy.yaml` with the tenancy + soft-delete + (if offline) `version`/`clientUuid` conventions; add any enum YAML.
2. **Generate** — `serverpod generate` (creates the Dart class, table, ORM, and client types; commit the output).
3. **Migrate** — `serverpod create-migration` then `dart bin/main.dart --apply-migrations --role maintenance`.
4. **Endpoint** — `widget_endpoint.dart`: each method calls `RbacGuard.requireRole(...)` first, scopes queries by org, writes `Audit.record(...)` on mutations, soft-deletes (never hard-deletes), and bumps `version`. Paginate lists by cursor.
5. **Repository** — define a `WidgetRepository` interface + an in-memory impl and a `ServerpodWidgetRepository` wrapping the generated client; select by `useLiveBackend` in `state/providers.dart`. **Edits are fetch-merge**: read the current row, `copyWith` only the edited fields, save — so thin view-models never wipe server-only fields.
6. **Screen** — build the feature under `makerflow_flutter/lib/src/features/widget/`, using `makerflow_design` widgets, the shared accessible-dialog pattern (`feature_create_dialogs.dart` is the reference), and a FAB + tap-to-edit wiring.
7. **Accessibility** — `Semantics` on custom widgets, visible focus, keyboard paths, non-color status cues, live-region announcements for async results. **Required** for any UI (the rebuild's WCAG 2.1 AA mandate).
8. **Tests** — a live `withServerpod` integration test (see `test/integration/feature_reads_test.dart` for the pattern) + a widget test of the dialog flow.
9. **Plan** — record the work as an `fl-` task card in [`FLUTTER_REBUILD_PLAN.md` §13](FLUTTER_REBUILD_PLAN.md#13-phased-task-cards).

## 11. State management & navigation conventions

Full detail in [Appendix E](FLUTTER_REBUILD_PLAN.md#e-state-management--navigation-conventions). In short:

- **Riverpod:** `Provider` for singletons (repositories, client); `FutureProvider` for org-scoped reads; invalidate after writes. No `setState` for server data.
- **Repository seam:** UI talks to a repository interface, never the generated client directly — keeps the UI testable and serverless-runnable.
- **Errors:** typed server exceptions surface in dialogs with a live-region announcement (the conflict case is user-visible: "modified by someone else — reload and retry").
- **Navigation:** `go_router` with a central auth redirect (in `providers.dart`); the first frame is gated on session `restore()` so a persisted login doesn't flash the login screen.
- **Forms:** the shared dialog pattern bundles labels, validation with identified errors, busy state, and announcements.

## 12. Design system

`makerflow_design` ports the Python token system ([`ProductSpec.md` §12](ProductSpec.md#12-design-system-tokens-components-diagrams)):

- 12 color tokens (`bg`, `card`, `brand`, `brand2`, `focus`, `danger`, …) for dark + light, surfaced via `ThemeData` + a `ThemeExtension` (`MakerflowTheme.of(context).colors`).
- Shape: 16 px card radius, 999 px pills, the signature flat `0 3px 0` offset shadow (`MfCard`).
- `StatusBadge` carries a **non-color** cue (icon + label) — the single source for the status icon↔meaning map (WCAG 1.4.1).
- Typography: Avenir Next (bundling the font in `makerflow_flutter/fonts/` is still TODO).

Keep docs and app visually unified — the SVG diagrams use the same palette.

## 13. Accessibility

The rebuild inherits a **WCAG 2.1 AA mandate** (ADA Title II + Section 504 — see the Python program in [`FEATUREROADMAP_workplan.md`](FEATUREROADMAP_workplan.md#accessibility-compliance-program-ada-title-ii--section-504)). The honest risk: **Flutter Web's accessibility lags server-rendered HTML.** Native targets are strong; the web target must be **proven** via the Phase-0 gate `fl-0-a11y-web-spike`, with a server-rendered web fallback kept in reserve.

Gate status: the AT test fixture (`/spike` route) and the WCAG report instrument are **built**; the empirical NVDA/VoiceOver/keyboard pass is **human-gated and open**. Wired throughout the app already: keyboard-accessible kanban (pick-up/move/drop plus `E`-to-edit and an SR "Edit" action), focus-trapped dialogs with labelled fields and identified errors, live-region announcements, visible focus, and non-color status badges. Treat any new UI as a11y-incomplete until it passes axe (web) and a manual screen-reader pass.

## 14. Offline & realtime

Designed in [Appendix C](FLUTTER_REBUILD_PLAN.md#c-realtime--offline-sync-architecture); the **server side is scaffolded**: `SyncEndpoint` (keyset deltas + tombstones + `SyncCursor` ack), `RealtimeEndpoint` over org-scoped Redis pub/sub (`business/channels.dart`), and the `ChangeEvent`/`SyncCursor`/`TaskDeltaPage` models. The client half — Drift cache, mutation queue, reconciler, stream subscription — is Phase 5 work and not started. Version-based conflict resolution **never silently drops a write** (it surfaces conflicts; the dialog already shows the conflict case).

## 15. Testing

What exists today, all green (re-verified 2026-07-11):

- **Server (19):** 2 unit tests (`rbac_rank_test.dart`) + a **17-case live serverpod_test integration suite** — rollback-per-test against a dedicated `makerflow_test` DB (`config/test.yaml`, Postgres :8090): `role_matrix_test.dart` (6 — RBAC allow/deny incl. cross-org + owner-grant), `contract_test.dart` (5 — audit rows, soft-delete→trash→restore, optimistic-concurrency conflict, tenant-scoped reads, NotFound on deleted), `feature_reads_test.dart` (6 — the read paths the live repositories call). `dart_test.yaml` tags them `integration` (`concurrency: 1`).
- **App (10):** kanban board render / create / edit / delete / list-toggle (5), ops create/edit dialog flows (3), trash-coordination unit tests (2).
- **Proof scripts** (`tool/`): `auth_smoke.dart` (sign-in → authed list) and `ui_writepath_smoke.dart` (the exact `client.task.*` calls the UI makes: create/update/move + stale-edit conflict, against a live server).

Still TODO: golden tests, `integration_test`/Patrol E2E, axe-core on the web build — and **CI is currently inert** (see §18).

## 16. Debugging cookbook

| Symptom | Likely cause | Look at |
|---|---|---|
| `generated/...` imports unresolved | model/endpoint changed without regen (output is otherwise committed) | `serverpod generate` from `makerflow_server`; commit the output |
| Live mode shows demo data | app built without the live flag | rebuild with `--dart-define=MAKERFLOW_LIVE=true` |
| Server won't start | Postgres/Redis down or wrong passwords | `docker compose ps`; `config/passwords.yaml` vs compose |
| `requireRole` always 403 | no `Membership` row for the user/org | seed: `dart bin/seed.dart` locally, or `entrypoint.sh seed` in production; check the active org in the switcher |
| Conflict on save | stale `version` (concurrent edit) | reload the entity; the dialog surfaces this by design |
| Auth header 400 "Invalid header format" | raw `keyId:key` sent without wrapping | `wrapAsBearerAuthHeaderValue` (see `MakerflowKeyManager`) |
| Integration tests: "Database is not enabled" or missing endpoints | stale generated test tools | `server_test_tools_path` must be set in `config/generator.yaml`; re-run `serverpod generate` |
| Web a11y failures | Flutter Web semantics gaps | the `fl-0-a11y-web-spike` findings; consider fallback |
| Migrations out of sync | model YAML changed without migration | `serverpod create-migration` then `--apply-migrations` |

## 17. Deployment

Six client targets + a server image. Details in [`FLUTTER_REBUILD_PLAN.md` §11](FLUTTER_REBUILD_PLAN.md#11-infrastructure--deployment) and [Appendix K](FLUTTER_REBUILD_PLAN.md#k-platform--store-compliance).

- **Server** → **DigitalOcean App Platform (D5)**: builds [`makerflow_server/Dockerfile`](makerflow_dart/makerflow_server/Dockerfile) on push to the **`staging`** branch via [`makerflow_dart/.do/app.yaml`](makerflow_dart/.do/app.yaml), with DO Managed PostgreSQL + Redis. [`deploy/entrypoint.sh`](makerflow_dart/makerflow_server/deploy/entrypoint.sh) renders config from the managed-DB bindings, applies migrations, and serves — or seeds (`entrypoint.sh seed` ≡ `/app/server --mode production --seed`) so the managed DB gets its first org + owner post-deploy. All assets validated (`dart compile exe` green, spec + entrypoint checked); **only the live `doctl apps create` remains** (needs an owner token). Full runbook: [`makerflow_dart/DEPLOY.md`](makerflow_dart/DEPLOY.md).
- **Web** → `flutter build web --release --dart-define=MAKERFLOW_LIVE=true --dart-define=MAKERFLOW_API=https://<app>.ondigitalocean.app/` → GitHub Pages or a CDN.
- **iOS/Android** → TestFlight / Play internal → stores (signing in CI). Not started.
- **macOS/Windows/Linux** → notarized `.dmg` / signed MSIX / Flatpak-Snap-AppImage → GitHub Releases. Not started.

Two infra profiles (self-host single-node vs managed) with rough cost bands: [Appendix L](FLUTTER_REBUILD_PLAN.md#l-cost-infra-sizing--effort).

## 18. Known gaps and not-yet-built

Everything committed compiles green and is test-covered; the gaps are **unbuilt features, not broken builds**:

- **The live DO deploy has not been executed** — needs an owner `doctl` token; everything else is copy-paste ([`DEPLOY.md`](makerflow_dart/DEPLOY.md)).
- **CI is inert:** [`dart-ci.yml`](makerflow_dart/.github/workflows/dart-ci.yml) sits at `makerflow_dart/.github/workflows/`, but **GitHub Actions only reads root-level `.github/workflows/`** — it has never run. Move it to the repo root and update it for the current layout (integration tag, PG service, test-tools path).
- **The a11y web gate awaits a human AT pass** (NVDA/VoiceOver/keyboard on `/spike`) — it decides the web target.
- No register/password-reset flows; a restored session key is trusted until the first authed call fails.
- No `getById` endpoints — fetch-merge edits do a full `list` round-trip; clearing an optional field via edit is a no-op (`copyWith` limitation).
- Equipment `space` shows null until a Space-name join exists; cursor pagination isn't rolled out across lists yet.
- No partnerships/intake/onboarding/reports/admin/settings screens; no agenda detail (items, convert-to-task); no task calendar view (`dueAt` plumbing pending).
- Offline/realtime are **server-side only** (endpoints + models exist; the client Drift cache, mutation queue, and stream wiring do not).
- No push, camera, biometric, store compliance, or release pipelines; the Avenir Next font isn't bundled yet.

Authoritative, always-current status: [`makerflow_dart/BUILD_STATUS.md`](makerflow_dart/BUILD_STATUS.md).

## 19. Where to go next

The near-term milestone roadmap (with effort + blockers) lives in [`makerflow_dart/NEXTSTEPS.md`](makerflow_dart/NEXTSTEPS.md). As of 2026-07-11:

**Track A — make it a working product (finish M0/M1):**
1. **Go live (M0):** run the DO deploy per [`DEPLOY.md`](makerflow_dart/DEPLOY.md) (owner: `doctl` token) → `entrypoint.sh seed` → build the web client against the live API. *Everything else on this list is testable against a real URL afterward.*
2. **Resume the build at M1.4 — project CRUD:** add `ProjectEndpoint.update`/`softDelete` (+ integration test + `serverpod generate`), project create/edit UI, and a project filter on the task views. Then **M1.5 — detail screens:** agenda detail (items + `convertItemToTask`), intake (+ `convertToProject`), partnerships. Then **M1.3b** — the task calendar view (`dueAt` plumbing + date picker).
3. **Fix CI** (move `dart-ci.yml` to the repo root, update for the current layout, gate the 19 + 10 tests) and **run the a11y gate** (human AT pass on `/spike`).

**Track B — expand it to run a makerspace team** (ranked by operational value ÷ effort; from the 2026-07-11 capability review):
1. **Low-stock alerts + reorder queue** (S) — dashboard "needs reorder" panel, quick stock adjust, one-tap reorder task; builds on the derived `ConsumableStatus`.
2. **Onboarding / training checklist UI** (S) — the server side (`OnboardingEndpoint`, templates/assignments) is done; pure client work; becomes the substrate for certifications.
3. **Comments, watchers + activity stream UI** (S) — `CollabEndpoint` is done; mounts in the task edit dialog; makes the kanban multi-player.
4. **Equipment maintenance scheduling + service log** (M) — act on `nextMaintenanceAt` (FutureCall sweep → auto-task), per-asset service history.
5. **Member certifications / badging with equipment gating** (M) — put teeth behind `certificationRequired`; grant via completed onboarding checklists.
6. **Intake + partnerships screens** (S) — endpoints exist incl. `convertToProject`; copies the equipment screen pattern.
7. **Incident / safety log** (M) — new org-scoped entity + corrective-action tasks; university EHS need.
8. **Equipment reservation / booking** (L) — slot booking on `CalendarEvent`, cert-gated, conflict-rejected via the version pattern.
9. **Member check-in + volunteer hours** (M) — kiosk check-in screen + hour rollups for institutional reporting.
10. **Reports & insights dashboard** (M) — utilization/uptime/burn/training rollups; consumes everything above; accessible charts (non-color encodings + data tables).

Then the native edge (offline client, push, camera, biometric — NEXTSTEPS M4) and release readiness (M6).

**To resume cold:** read [`makerflow_dart/BUILD_STATUS.md`](makerflow_dart/BUILD_STATUS.md), then [`FLUTTER_REBUILD_PLAN.md` §15](FLUTTER_REBUILD_PLAN.md#15-checkpoint-log) (checkpoint log) and §13 statuses, and pick up the top item above — or run the execution prompt in [§0.3](FLUTTER_REBUILD_PLAN.md#03-the-execution-prompt-build-the-next-task).

Welcome aboard.

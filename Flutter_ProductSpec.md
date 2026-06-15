# MakerFlow PM (Dart Rebuild) — Product Spec & Developer Onboarding Guide

> Audience: a developer joining the **Flutter + Serverpod** rebuild of MakerFlow PM. By the end you can run the Dart stack locally, find anything in the monorepo, ship a small change end-to-end, and know where the work is sequenced.
>
> **Status (read first):** the Dart rebuild is a **walking skeleton** (Phase 0 + a Phase 1 vertical slice), not the shipping product — but it **compiles and tests pass** (Serverpod codegen + `dart analyze` + server unit tests; `flutter analyze` + widget test; `flutter build web`; first migration generated). The shipping product is the Python app at the repo root ([`ProductSpec.md`](ProductSpec.md)). This rebuild is **greenfield, new deployments only** — it does not replace the Python app for existing installs.

- Plan & backlog: [`FLUTTER_REBUILD_PLAN.md`](FLUTTER_REBUILD_PLAN.md)
- What's actually on disk: [`makerflow_dart/BUILD_STATUS.md`](makerflow_dart/BUILD_STATUS.md)
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

Four decisions are **locked** (see [`FLUTTER_REBUILD_PLAN.md` §1](FLUTTER_REBUILD_PLAN.md#1-decisions-of-record)):

| # | Decision | Choice |
|---|---|---|
| D1 | Backend | **Full Dart — Serverpod** (+ PostgreSQL, Redis) |
| D2 | Platforms | **Web + iOS + Android + macOS + Windows + Linux** |
| D3 | Migration | **Greenfield, new deployments only** (no data migration; Python app stays) |
| D4 | Scope | **Full parity + native-only features** (offline, push, camera, biometric) |

## 3. Current status — what's built

A walking skeleton that **compiles and passes its tests** (Dart 3.12.2 / Flutter 3.44.2 / Serverpod 3.4.10 — see [`makerflow_dart/BUILD_STATUS.md`](makerflow_dart/BUILD_STATUS.md)):

- **Server:** `Organization` / `Membership` / `Project` / `Task` / `AuditLog` models + enums; the security contract (`RbacGuard.requireRole`, `AuthContext`, `Tenancy`, `Audit`); `TaskEndpoint` (CRUD + kanban move + optimistic version + soft-delete + audit), `ProjectEndpoint`, `HealthEndpoint`; `serverpod_auth` bootstrap; an RBAC unit test.
- **Design:** `makerflow_design` — the 12 color tokens (dark + light) ported from the Python `style.css`, `ThemeData`, `MfCard`, and a non-color `StatusBadge`.
- **App:** `makerflow_flutter` — Riverpod + go_router, login, dashboard, and a **keyboard-accessible kanban** (drag **and** keyboard move + live-region announcements) running on an in-memory repository seam, plus a widget smoke test.
- **Infra/docs:** `docker-compose` (Postgres + Redis), a CI workflow, the monorepo README + BUILD_STATUS.

**Not built:** everything from Phase 2 on — meetings, inventory, onboarding, reports, calendar sync, offline sync, push, camera, biometric, cross-platform a11y conformance, and the release pipelines. The **Flutter Web accessibility gate** (`fl-0-a11y-web-spike`) is unstarted and is the highest-priority next task.

## 4. Architecture

<p align="center">
  <img src="docs/diagrams/11-flutter-target-architecture.svg" alt="Flutter + Serverpod target architecture" width="100%"/>
</p>

- **Client (`makerflow_flutter`)** — one widget tree → six targets. Layered: `go_router` → screens/widgets → **Riverpod** state → repositories → generated client. Local **Drift** cache for offline; native plugins for biometric/camera/push.
- **Transport (`makerflow_client`)** — Serverpod's generated, type-safe client. `Future<T>` over HTTP; `Stream<T>` over WebSocket for realtime + sync. Bearer-token auth (no cookies → **no CSRF**).
- **Server (`makerflow_server`)** — Serverpod. Endpoint classes replace the Python app's 103 route branches; `serverpod_auth` replaces the sessions table + PBKDF2 + CSRF. A central RBAC + tenancy guard and an audit interceptor wrap business logic; `FutureCall`s run scheduled jobs (calendar sync, reminders); the ORM is generated from model YAML.
- **Data** — PostgreSQL (primary), Redis (cache + pub/sub for streaming), object storage (DO Spaces / S3) for attachments.

Full Python→Dart mapping: [`FLUTTER_REBUILD_PLAN.md` §3](FLUTTER_REBUILD_PLAN.md#3-stack-translation-python--dart). Endpoint map: [Appendix A](FLUTTER_REBUILD_PLAN.md#a-endpoint-map-103-routes--serverpod-endpoints).

## 5. Monorepo layout — where things live

```
makerflow_dart/                  # Melos workspace
├── melos.yaml
├── makerflow_server/            # Serverpod backend
│   ├── config/                  # dev config + passwords.example.yaml
│   ├── docker-compose.yaml      # Postgres + Redis
│   ├── lib/server.dart          # bootstrap (serverpod_auth + /healthz)
│   ├── lib/src/models/          # *.spy.yaml model defs + enums/
│   ├── lib/src/business/        # rbac, auth_context, tenancy, audit
│   ├── lib/src/endpoints/       # task, project, health (+ more per phase)
│   └── lib/src/generated/       # serverpod generate output (do not hand-edit)
├── makerflow_client/            # generated client (populated by codegen)
├── makerflow_design/            # tokens, ThemeData, MfCard, StatusBadge
├── makerflow_flutter/           # the app
│   └── lib/src/{data,state,features,router.dart}
└── makerflow_shared/            # non-generated shared constants
```

| Looking for… | Go to… |
|---|---|
| A server route | `makerflow_server/lib/src/endpoints/*_endpoint.dart` |
| A DB table | `makerflow_server/lib/src/models/*.spy.yaml` |
| The RBAC gate | `makerflow_server/lib/src/business/rbac.dart` |
| The audit interceptor | `makerflow_server/lib/src/business/audit.dart` |
| A screen | `makerflow_flutter/lib/src/features/<area>/` |
| App state / providers | `makerflow_flutter/lib/src/state/providers.dart` |
| The repository seam | `makerflow_flutter/lib/src/data/task_repository.dart` |
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

# code generation (produces makerflow_client + ORM the server imports)
serverpod generate
dart bin/main.dart --apply-migrations
dart bin/main.dart                   # serves on :8080

# run the app on any target
cd ../makerflow_flutter
flutter run -d chrome                # or macos | windows | linux | <device>
```

**Codegen is not optional.** `makerflow_server/lib/src/generated/**` and `makerflow_client/lib/**` do not exist until `serverpod generate` runs — that's why the server's `generated/` imports and the `MembershipRole`/`TaskStatus` enums resolve only after codegen. The Flutter app, however, runs **before** codegen because the UI talks to a repository seam (`InMemoryTaskRepository`) — swap to the real client later (§10).

## 7. Request lifecycle

A typical authenticated call:

1. **Client** invokes a generated method, e.g. `client.task.move(id, status, order)`. The auth token (from `flutter_secure_storage`) rides the request — no CSRF.
2. **Serverpod** routes to `TaskEndpoint.move(session, …)`; `session.authenticated` resolves the signed-in user.
3. **Guard** — `RbacGuard.requireRole(session, orgId, MembershipRole.staff)` loads the caller's `Membership`, confirms the role, and returns an `AuthContext`. Missing/under-privileged/cross-org → throws (surfaces as a typed error).
4. **Tenancy** — every query is scoped `organizationId == ctx.organizationId`; `Tenancy` guards block org reassignment.
5. **Mutation + version** — `Task` carries a `version`; a stale `version` throws `MakerflowConflictException` (offline-safe).
6. **Audit** — `Audit.record(...)` writes an append-only `AuditLog` row (actor, org, entity, action, payload hash).
7. **Response** — the typed result returns to the client; **streaming** endpoints push deltas over WebSocket (activity feed, sync).

Health: `/healthz` (cheap liveness, no DB) and `HealthEndpoint.ready` (DB round-trip readiness).

## 8. Data model

Serverpod generates the Dart class + table + ORM from YAML. Conventions: `organizationId` on every org-scoped row; `createdAt/updatedAt/createdByUserInfoId`; `deletedAt/deletedByUserInfoId` for soft-delete; `version` + `clientUuid` on offline-writable rows; keyset/cursor pagination on every list.

The full 39-table → ~38-model + 3-new mapping (with soft-delete / offline / tenancy flags, ID strategy, polymorphic associations, and the enum inventory) is in [`FLUTTER_REBUILD_PLAN.md` §4](FLUTTER_REBUILD_PLAN.md#4-data-model-translation-39-tables--serverpod-models). The skeleton ships `organization`, `membership`, `project`, `task`, `audit_log` + three enums; the rest land per phase.

## 9. Auth, RBAC, tenancy, audit

The Python app's security contract is reproduced exactly, not approximated ([`docs/SECURITY.md`](docs/SECURITY.md)).

- **Auth:** `serverpod_auth` email/password (register/sign-in/reset). Tokens in secure storage; bearer transport.
- **Roles:** `viewer < student < staff < manager < workspaceAdmin < owner`, as a `MembershipRole` enum with integer rank. Platform-level `superuser` is a serverpod_auth scope and the only path across orgs; `workspaceAdmin` is pinned to one org.
- **Guard:** `RbacGuard.requireRole(session, orgId, minRole)` is called first in every mutating endpoint.
- **Tenancy:** repository-level org scoping + `Tenancy` guards; cross-org access is impossible by construction.
- **Audit:** `Audit.record` centralizes the append-only trail so no endpoint forgets it.
- **Soft-delete:** `deletedAt` is set; default reads exclude it; a trash screen restores or purges.

Deep dives: auth/session ([Appendix B](FLUTTER_REBUILD_PLAN.md#b-auth--session-architecture)), security hardening ([Appendix G](FLUTTER_REBUILD_PLAN.md#g-security-hardening-threat-model-port)).

## 10. Adding a feature — the canonical recipe

To add an entity (say `widget`) end-to-end:

1. **Model** — add `makerflow_server/lib/src/models/widget.spy.yaml` with the tenancy + soft-delete + (if offline) `version`/`clientUuid` conventions; add any enum YAML.
2. **Generate** — `serverpod generate` (creates the Dart class, table, ORM, and client types).
3. **Migrate** — `serverpod create-migration` then `dart bin/main.dart --apply-migrations`.
4. **Endpoint** — `widget_endpoint.dart`: each method calls `RbacGuard.requireRole(...)` first, scopes queries by org, writes `Audit.record(...)` on mutations, soft-deletes (never hard-deletes), and bumps `version`. Paginate lists by cursor.
5. **Repository** — define a `WidgetRepository` interface + a `Serverpod` impl wrapping the generated client (and an in-memory impl for tests/early UI). Register a Riverpod provider.
6. **Screen** — build the feature under `makerflow_flutter/lib/src/features/widget/`, using `makerflow_design` widgets and the optimistic-update + rollback helper.
7. **Accessibility** — `Semantics` on custom widgets, visible focus, keyboard paths, non-color status cues, live-region announcements for async results. **Required** for any UI (the rebuild's WCAG 2.1 AA mandate).
8. **Tests** — serverpod_test endpoint test + the role-matrix assertion + a widget test.
9. **Plan** — record the work as an `fl-` task card in [`FLUTTER_REBUILD_PLAN.md` §13](FLUTTER_REBUILD_PLAN.md#13-phased-task-cards).

## 11. State management & navigation conventions

Full detail in [Appendix E](FLUTTER_REBUILD_PLAN.md#e-state-management--navigation-conventions). In short:

- **Riverpod:** `Provider` for singletons (repositories, client); `Future`/`StreamProvider` for reads; `AsyncNotifier` for mutations. No `setState` for server data.
- **Repository seam:** UI talks to a repository interface, never the generated client directly — keeps the UI testable and runnable before codegen.
- **Optimistic updates:** mutate local state immediately, call the endpoint, roll back + announce on error.
- **Navigation:** `go_router` with a central auth redirect (in `providers.dart`) and deep/universal links so a push opens the right screen.
- **Forms:** one reusable form-field widget bundles label + `autofillHints` + validator + accessible error wiring.

## 12. Design system

`makerflow_design` ports the Python token system ([`ProductSpec.md` §12](ProductSpec.md#12-design-system-tokens-components-diagrams)):

- 12 color tokens (`bg`, `card`, `brand`, `brand2`, `focus`, `danger`, …) for dark + light, surfaced via `ThemeData` + a `ThemeExtension` (`MakerflowTheme.of(context).colors`).
- Shape: 16 px card radius, 999 px pills, the signature flat `0 3px 0` offset shadow (`MfCard`).
- `StatusBadge` carries a **non-color** cue (icon + label) — the single source for the status icon↔meaning map (WCAG 1.4.1).
- Typography: Avenir Next (bundle the font in `makerflow_flutter/fonts/`).

Keep docs and app visually unified — the SVG diagrams use the same palette.

## 13. Accessibility

The rebuild inherits a **WCAG 2.1 AA mandate** (ADA Title II + Section 504 — see the Python program in [`FEATUREROADMAP_workplan.md`](FEATUREROADMAP_workplan.md#accessibility-compliance-program-ada-title-ii--section-504)). The honest risk: **Flutter Web's accessibility lags server-rendered HTML.** Native targets are strong; the web target must be **proven** via the Phase-0 gate `fl-0-a11y-web-spike`, with a server-rendered web fallback kept in reserve. Per-criterion Flutter mechanisms are in [`FLUTTER_REBUILD_PLAN.md` §8](FLUTTER_REBUILD_PLAN.md#8-accessibility--the-hard-part).

What's already wired in the skeleton: keyboard-accessible kanban + live-region announcements + visible focus + non-color status badges. Treat any new UI as a11y-incomplete until it passes axe (web) and a manual screen-reader pass.

## 14. Offline & realtime

Designed in [Appendix C](FLUTTER_REBUILD_PLAN.md#c-realtime--offline-sync-architecture); built in Phase 5. Realtime rides a Serverpod streaming endpoint over org-scoped Redis pub/sub channels. Offline: a Drift local cache, a mutation queue keyed by `clientUuid` + idempotency key, server deltas pulled by `SyncCursor`, and **version-based conflict resolution that never silently drops a write** (it surfaces conflicts). Ships read-only-offline first, then per-entity offline writes.

## 15. Testing

The pyramid ([Appendix F](FLUTTER_REBUILD_PLAN.md#f-testing-strategy)): unit (business guards), serverpod_test integration against ephemeral Postgres, the **role-matrix test** (port of the Python security suite), Flutter widget + golden, `integration_test`/Patrol E2E, and axe-core on the web build. Run `melos run analyze` + `melos run test`; CI gates PRs.

## 16. Debugging cookbook

| Symptom | Likely cause | Look at |
|---|---|---|
| `generated/...` imports unresolved | codegen not run | `serverpod generate` from `makerflow_server` |
| Enum/`Client` types missing in the app | client not generated / not depended on | run codegen; uncomment `makerflow_client` dep in the app pubspec |
| Server won't start | Postgres/Redis down or wrong passwords | `docker compose ps`; `config/passwords.yaml` vs compose |
| `requireRole` always 403 | no `Membership` row for the user/org | seed data (`fl-0-seed-data`); check active org |
| Conflict on save | stale `version` (offline reconcile) | reload entity; see Appendix C |
| Web a11y failures | Flutter Web semantics gaps | the `fl-0-a11y-web-spike` findings; consider fallback |
| Migrations out of sync | model YAML changed without migration | `serverpod create-migration` then `--apply-migrations` |

## 17. Deployment

Six client targets + a server image. Details in [`FLUTTER_REBUILD_PLAN.md` §11](FLUTTER_REBUILD_PLAN.md#11-infrastructure--deployment) and [Appendix K](FLUTTER_REBUILD_PLAN.md#k-platform--store-compliance); GitHub specifics in the [README](README.md#deploying-the-dart-rebuild-on-github).

- **Server** → Docker image (server + Postgres + Redis) on DO / any container host; or GHCR + a deploy job.
- **Web** → `flutter build web` → GitHub Pages or a CDN.
- **iOS/Android** → TestFlight / Play internal → stores (signing in CI).
- **macOS/Windows/Linux** → notarized `.dmg` / signed MSIX / Flatpak-Snap-AppImage → GitHub Releases.

Two infra profiles (self-host single-node vs managed) with rough cost bands: [Appendix L](FLUTTER_REBUILD_PLAN.md#l-cost-infra-sizing--effort).

## 18. Known gaps and not-yet-built

- The skeleton **has not been compiled** (authored without a toolchain) — expect to resolve analyzer findings on first `melos bootstrap` + `serverpod generate`.
- Only ~5 of ~38 models, 3 of ~19 endpoint classes, and 3 screens exist.
- No codegen output committed; the app runs on an in-memory repository until the client is generated and wired.
- The Flutter Web accessibility question is **open** (the gate).
- No release pipelines, no native features, no offline/realtime yet.

Authoritative, always-current status: [`makerflow_dart/BUILD_STATUS.md`](makerflow_dart/BUILD_STATUS.md).

## 19. Where to go next

1. Install the toolchain and bring the skeleton up (§6); fix analyzer findings.
2. Run the accessibility gate `fl-0-a11y-web-spike` — it decides the web target's fate.
3. Finish `fl-0-auth-rbac-tenancy` (real sign-in, org switch, role-matrix tests).
4. Swap the kanban onto the generated client (`ServerpodTaskRepository`).
5. Open [`FLUTTER_REBUILD_PLAN.md`](FLUTTER_REBUILD_PLAN.md), pick the top `[ ] ready` card, and run the execution prompt in [§0.3](FLUTTER_REBUILD_PLAN.md#03-the-execution-prompt-build-the-next-task).

Welcome aboard.

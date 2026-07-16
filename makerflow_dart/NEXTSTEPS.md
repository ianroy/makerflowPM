# NEXTSTEPS.md — MakerFlow PM Dart rebuild

The near-term, sequenced roadmap from *here* (the rebuild is **merged to
`main`** — [PR #6](https://github.com/ianroy/makerflowPM/pull/6), 2026-07-16 —
with the monday-style UI, the Phase 8 customization platform, and the
full-demo DO spec) to a shippable v1 and beyond. The full per-card backlog lives in
[`../FLUTTER_REBUILD_PLAN.md`](../FLUTTER_REBUILD_PLAN.md); this file is the
prioritized milestone view. Effort: S≈hours · M≈1–2d · L≈3–5d · XL≈1–2wk (one dev).

![Rebuild roadmap: M0–M6 milestones, blockers, and sequence](../docs/diagrams/12-rebuild-roadmap.svg)

## Where we are (2026-07-16)
**Suites: server 36/36 · app 69/69 · design 7/7 · CI green.** The app wears
the monday-style UI (Vibe design system, grey-frame shell + boards sidebar,
board chrome, the grouped inline-editing **Main Table** as the default view).
Full CRUD for tasks (+Trash) and projects (+Archive); ops features
create/edit. **Phase 8 is 6/11 done**: the persisted per-user column system;
9 custom-field types end-to-end (D6 values, server validation, type-change
coercion, per-type editors, field manager); saved/shared views with
dirty-state flows; the AND/OR **filter builder**, **multi-sort** (+ header
clicks), and **group-by-any-field** with value-carrying add rows; and
**column summaries** (footer aggregations + per-group/status batteries).
Verified live repeatedly against the demo stack. **Merged to `main`**
(PR #6, 2026-07-16); the DO demo spec deploys from `staging` (latest work) —
production cutover = flip `branch: main` in `.do/app.yaml`.

**▶ NEXT CARD: `fl-8-subitems`** (nested rows w/ a parent progress rollup) —
spec in FLUTTER_REBUILD_PLAN.md §13 Phase 8; Phase 8 is 6/11 done. Owner-blocked items: doctl token (live deploy — everything after
`doctl auth init` is `deploy/do_deploy.sh`), human AT pass (R1). Local demo
stack running (:8085 web · :8080 API · :8090 PG · :8091 Redis; the PG cluster
is disposable /tmp). Known follow-ups: URL `?view=` param; member-directory
endpoint (person picker + Person filter chip + assignee writes); per-user
default-view marker; default-table filter persistence; calendar surface (UI-7).

---

## M0 — Go live (unblocks everything) · ~1–2 days
A real URL on managed Postgres.

| Task | Effort | Deps | Notes |
|---|---|---|---|
| ~~M0.1 Decide PR #6~~ ✅ merged 2026-07-16 | — | — | `main` carries the rebuild; demo spec stays on `staging` |
| M0.2 Live DO deploy ([DEPLOY.md](DEPLOY.md)) | S | doctl token | **Blocked on owner** |
| M0.3 Production `--seed` server flag | S | — | seed only runs in the build stage today |
| M0.4 Deployed web build → live API; browser-smoke | S | M0.2 | `--dart-define=MAKERFLOW_API=…` |

**DoD:** open URL → sign in → create a task → it persists.

## M1 — Finish the interactive core · ~1 wk (no blockers)
| Task | Effort | Notes |
|---|---|---|
| ~~M1.1 Edit paths for equipment/consumables/meetings~~ ✅ | M | done — create/edit dialogs, tap-to-edit, non-destructive fetch-merge |
| ~~M1.2 Delete + Trash UI~~ ✅ | M | done — soft-delete from edit dialog + `/trash` screen (restore/purge), shared in-memory store |
| M1.3 Task list + calendar views | M | **list + toggle ✅**; calendar deferred (M1.3b — needs `dueAt` + date picker) |
| ~~M1.4 Project create/edit + project→task linkage~~ ✅ | M | done — `update`/`softDelete` + version + migration; dialog + Archive; task-view project filter |
| M1.5 Detail screens: meeting agenda (convert-to-task), intake→project, partnerships | L | endpoints exist |

**DoD:** every core entity is full CRUD from the UI against live data; widget-tested.

## M2 — Realtime + collaboration · ~1 wk
Infra exists (`RealtimeEndpoint`, Redis `Channels`, `ChangeEvent`, `ItemComment`/`ItemWatcher`).

| Task | Effort | Notes |
|---|---|---|
| M2.1 Client `ChangeEvent` subscription; live board/list; reconnect-from-cursor | L | streaming endpoint built |
| M2.2 Comments + activity-stream UI w/ live-region announce | M | `CollabEndpoint.activityStream` |
| M2.3 Watchers | S | `ItemWatcher` model |

**DoD:** two browsers see each other's moves live; comments stream in.

## M3 — Accessibility gate (R1) + CI · ~1 wk — *schedule M3.1 early*
| Task | Effort | Deps | Notes |
|---|---|---|---|
| M3.1 Run `/spike` AT matrix (NVDA+Firefox, VoiceOver+Safari, keyboard); record verdict; decide web vs server-rendered fallback | M | **Human AT pass** | the R1 gate; fixture + report built |
| M3.2 CI gates: 19 server tests (ephemeral PG/Redis) + 10 Flutter tests + axe-core | M | — | **moved + rewritten 2026-07-14** → `/.github/workflows/dart-ci.yml` (server: PG17 + 24 tests; app: analyze/test/web). Remaining: axe-core gate + goldens/E2E |
| M3.3 Golden tests (both themes) + one Patrol E2E | M | — | — |

**DoD:** CI blocks regressions; recorded AT verdict; web-target decision made.

## M4 — Native superpowers · ~2–3 wk
| Task | Effort | Notes |
|---|---|---|
| M4.1 Offline-sync: Drift cache + mutation queue + reconciler | XL | `SyncEndpoint` keyset-pull + tombstones server-side |
| M4.2 Push (FCM/APNs) + `DeviceToken` | L | model exists |
| M4.3 Camera→`Attachment` upload + biometric (`local_auth`) | L | model exists |

## M5 — Integrations + people/analytics · ~2–3 wk
Calendar sync (googleapis), CSV/ICS/PDF + SMTP, onboarding UI, reports/admin/settings UI, i18n scaffold (ARB/RTL/`<html lang>`), observability (request-id, Insights, error tracker). Models/endpoints mostly stubbed; this is client UI + a few `FutureCall`s.

## M6 — Release readiness · ~2 wk
VPAT (after M3 verdict), store compliance (privacy manifests, signing), per-platform release pipelines.

## M-UI — monday.com-style front-end redesign (planned 2026-07-14)
The owner wants the interface to look like **monday.com**. Researched against monday's
open-source **Vibe** design system (exact tokens) and planned in
[`UI_REDESIGN_PLAN.md`](UI_REDESIGN_PLAN.md): 11 phases — UI-0 (Vibe-derived design system) →
UI-1 shell → UI-2 board chrome → **UI-3 Main Table (the signature)** → kanban restyle → item
card (Updates = CollabEndpoint UI) → bulk actions → calendar (absorbs M1.3b) → My Work →
dashboard widgets → polish (confetti on Done). ≈4–6 wk to the "looks like monday" bar.
**Build M1.5's screens on the new system (after UI-3) rather than styling them twice.**

## M-EXP — Makerspace-team expansion track (from the 2026-07-11 capability review)
Ranked by operational value ÷ effort; interleave with M2–M5 as capacity allows.
Each builds on existing models/endpoints (details in [`Flutter_ProductSpec.md` §19](../Flutter_ProductSpec.md#19-where-to-go-next)):

| # | Capability | Effort | Builds on |
|---|---|---|---|
| 1 | Low-stock alerts + reorder queue (dashboard panel, quick stock adjust, one-tap reorder task) | S | derived `ConsumableStatus`, TaskEndpoint, dashboard |
| 2 | Onboarding / training checklist UI | S | `OnboardingEndpoint` (server done) |
| 3 | Comments, watchers + activity stream UI | S | `CollabEndpoint` (server done), task edit dialog |
| 4 | Equipment maintenance scheduling + service log | M | `nextMaintenanceAt`, FutureCall sweep → auto-task |
| 5 | Member certifications / badging w/ equipment gating | M | `certificationRequired`, onboarding checklists as cert source |
| 6 | Intake + partnerships screens | S | endpoints exist incl. `convertToProject` |
| 7 | Incident / safety log (+ corrective-action tasks) | M | canonical model recipe, Attachment (photos later) |
| 8 | Equipment reservation / booking (cert-gated, conflict-rejected) | L | `CalendarEvent`, version-conflict pattern, realtime |
| 9 | Member check-in + volunteer hours (kiosk mode) | M | Membership/UserProfile, dashboard, InsightSnapshot |
| 10 | Reports & insights dashboard (accessible charts + data tables) | M | `ReportTemplate`/`InsightSnapshot`, AuditLog as source |

## M-CUST — Customization platform (Phase 8, added 2026-07-14)
From PoC to a monday-class customizable tool. Full cards in
[`../FLUTTER_REBUILD_PLAN.md` §13 Phase 8](../FLUTTER_REBUILD_PLAN.md); storage decision **D6**
(custom-field values = JSON property bag on the entity). Grounding: `CustomView`/`FieldConfig`
models exist with **no endpoints and no value storage**; Main Table columns are hardcoded.

| Order | Card | Effort | What it unlocks |
|---|---|---|---|
| ~~1~~ ✅ | ~~fl-8-view-field-endpoints~~ done 2026-07-14 | M | endpoints live; theme+sidebar persist across restarts |
| ~~2~~ ✅ | ~~fl-8-column-registry~~ done 2026-07-15 | L | resize · autofit · reorder · show/hide · pin shipped, persisted per user |
| ~~3~~ ✅ | ~~fl-8-custom-fields~~ done 2026-07-15 | XL | 9 tier-1 field types live end-to-end: D6 values + validation + coercion, dynamic columns, per-type editors, field manager |
| ~~4~~ ✅ | ~~fl-8-saved-views~~ done 2026-07-16 | M | tabs = built-in defaults + named saved/shared views w/ dirty-state save flows |
| ~~5~~ ✅ | ~~fl-8-filter-sort-group~~ done 2026-07-16 | L | AND/OR filter builder w/ per-type operators · multi-sort + header clicks · group-by-any-field w/ value-carrying add rows |
| ~~6~~ ✅ | ~~fl-8-column-summaries~~ done 2026-07-16 | S | footer aggregations (sum/avg/range/%/unique/battery) · per-group + grand-total footers · persisted with the layout |
| 7–11 | subitems · drag suite · templates · dashboards · automations | M→XL | the long tail |

## M-ENT — Enterprise readiness (Phase 9, added 2026-07-14)
Ranked for the actual buyer (university/makerspace procurement):
**VPAT** (rides fl-6) → **fl-9-oidc-sso** (OIDC + JIT membership; SAML via IdP proxy) →
**fl-9-ops-hardening** (migration-job split, status page, security.txt, restore drill, HECVAT) →
**fl-9-org-export** (org + audit export) → **fl-9-user-lifecycle** (invites, suspend, cohort
offboard) → **fl-9-pats** → fl-9-resource-grants (private boards/guests — the structural one)
→ fl-9-csv-import → fl-9-rest-webhooks. Deliberately deferred: SOC2 (HECVAT first), native
SAML, SCIM, seat billing (universities buy site licenses on PO).

---

## Recommended sequence
1. **M0 now** — a live URL makes everything demoable + testable.
2. **M1 in parallel** — unblocked, completes the interactive core.
3. **Schedule M3.1 ASAP** — every week of new web UI rides on an unverified web-a11y assumption (R1); waiting compounds rework risk.
4. **M3.2 CI** early + cheap — protect the green state.
5. Then **M2 → M4 → M5 → M6**.

## Blocked on the owner
- **doctl token** → M0.2 live deploy.
- **A screen-reader/keyboard AT pass** (or a tester) → M3.1, or a decision to defer web.

## Open follow-ups (non-blocking)
Production seed flag · ops-feature edit paths · equipment space-name resolution
(Space join) · password-reset flow · validate/refresh a restored session key.

_Last updated: 2026-07-16 (Phase 8 at 6/11 — column system, custom fields, saved views, filter/sort/group, summaries; next card fl-8-subitems)._

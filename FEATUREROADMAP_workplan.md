# FEATUREROADMAP_workplan.md

> A **resumable, pause-able, context-window-aware** roadmap for MakerFlow PM.
> Designed so an LLM agent (or a human) can pick this file up at any time, regenerate or execute, and never lose track of state. All state lives in this file; no external orchestrator is required.

![Roadmap loop](docs/diagrams/08-roadmap-loop.svg)

---

## Table of contents

- [0. How to use this file](#0-how-to-use-this-file)
- [1. The regeneration prompt (find new features)](#1-the-regeneration-prompt-find-new-features)
- [2. The execution prompt (build the next task)](#2-the-execution-prompt-build-the-next-task)
- [3. Schema and conventions](#3-schema-and-conventions)
- [4. Status legend, personas, scales](#4-status-legend-personas-scales)
- [5. Task index (at-a-glance dashboard)](#5-task-index-at-a-glance-dashboard)
- [6. Task cards](#6-task-cards)
- [7. Checkpoint log](#7-checkpoint-log)

---

## 0. How to use this file

This roadmap drives an **A → B → C → D → E → F → A** loop. The loop is shown in [`docs/diagrams/08-roadmap-loop.svg`](docs/diagrams/08-roadmap-loop.svg):

- **A. Regenerate** — paste [§1](#1-the-regeneration-prompt-find-new-features) into an LLM agent. It scans the repo + this file and proposes new task cards in [§6](#6-task-cards), updates dependencies in [§5](#5-task-index-at-a-glance-dashboard), and dedupes.
- **B. Triage** — a human edits Spec/DOD, adjusts Priority/Complexity, promotes Backlog → Ready, and confirms Agent Persona.
- **C. Execute** — paste [§2](#2-the-execution-prompt-build-the-next-task) into an LLM agent. It picks the top-ready task, implements, verifies, records decisions verbosely, ticks the Status checkbox.
- **D. Verify** — agent runs the required test scripts; if anything fails, Status flips back to `in_progress` and Decisions are appended.
- **E. Propagate** — agent walks the completed task's `Unblocks` list and promotes newly-eligible items to Ready. Appends a one-line entry to [§7. Checkpoint log](#7-checkpoint-log).
- **F. Loop or stop** — if ready queue is empty, re-run A. If context window > 70% used, stop and checkpoint. Otherwise C again.

**Resumability rule:** every state change is written to this file. Anyone restarting cold reads the file top to bottom and resumes where the checkpoint log left off. No hidden state. No external tracker.

**Context-window rule:** the execution prompt is built so the agent only reads the single task it is about to work on plus the files listed in `Files to modify`. It does *not* require reading the entire file or the full codebase to make progress on one task.

---

## 1. The regeneration prompt (find new features)

Copy-paste the block below into a fresh agent session when you want to refresh the backlog. The prompt is self-contained; the agent should be able to act on it without the rest of this document being visible.

````text
SYSTEM: You are a senior staff engineer auditing MakerFlow PM, an open-source
project management + operations platform for makerspaces. The repository lives
at the path passed in the user message. The file `FEATUREROADMAP_workplan.md`
is the canonical state; you must respect its existing task IDs and statuses.

GOAL: Propose new feature/refactor/hardening tasks. Do NOT implement code. Do
NOT modify any file other than `FEATUREROADMAP_workplan.md`.

PROCEDURE:

1. Read `README.md`, `ProductSpec.md`, and `FEATUREROADMAP_workplan.md` in full.
2. Skim `docs/ARCHITECTURE.md`, `docs/DATA_MODEL.md`, `docs/DECISIONS.md`,
   `docs/SECURITY.md`, `docs/TESTING.md`.
3. Survey the codebase. Targeted reads only — do not read all of `app/server.py`.
   Useful greps:
     - `def render_` to enumerate UI surfaces
     - `if req.path == ` to enumerate routes
     - `CREATE TABLE` to enumerate entities
     - `TODO|FIXME|XXX` for explicit debt markers
     - `# HACK|# NOTE` for known smells
4. Read `analysis_outputs/*.json` and `analysis_outputs/*.md` for the most
   recent audit findings.
5. Read the open issues if accessible (`gh issue list --limit 50`) and recent
   commits (`git log --oneline -n 50`).
6. Read the existing task cards in section 6 of the roadmap. Identify:
     - which tasks are still relevant (keep)
     - which are obsolete (mark Status `[~] deferred` with a reason in Decisions)
     - which are duplicates (merge, keep the earlier ID)
7. Generate NEW task cards for genuinely-new work. Each new card MUST use the
   schema described in section 3 of the roadmap. Each card MUST have:
     - a unique ID following the pattern P{priority}-{kebab-case-slug}, e.g.
       `P1-pytest-scaffold`. Never reuse an existing ID.
     - a non-empty `Spec` with a measurable Definition of Done.
     - explicit `Dependencies` (other task IDs that must be `[x] done` first).
     - explicit `Unblocks` (other task IDs this work clears).
     - a ranked `Priority` (P0/P1/P2/P3) and `Complexity` (XS/S/M/L/XL).
     - a concrete `Files to modify` list with paths, not vague descriptions.
8. Append the new cards to section 6 of the roadmap, inserted in priority
   order. Update the task index in section 5 to include them.
9. Append a one-line entry to section 7 (Checkpoint log) describing what you
   added and why.

CONSTRAINTS:

- Cap output at 7 new tasks per regeneration pass to keep triage tractable.
- Prefer concrete, shippable work over broad initiatives. "Add observability"
  is too broad; "Emit JSON access logs with request_id + user_id" is right.
- Prefer tasks that unblock multiple downstream tasks (high-leverage).
- Do NOT propose tasks that violate the project's design principles documented
  in `docs/DECISIONS.md` (e.g., do not propose ripping out the WSGI core for
  an SPA rewrite).
- Any task that touches the UI MUST be evaluated against WCAG 2.1 Level AA
  (the standard adopted by 28 CFR Part 35 Subpart H and 45 CFR Part 84
  Subpart I). If a proposed task would regress accessibility, propose its
  a11y mitigation alongside it.
- If you cannot find anything worth proposing, write a section 7 entry that
  says so explicitly. Do not invent busy-work.

OUTPUT:
- Modified `FEATUREROADMAP_workplan.md` only.
- A short summary message to the human listing the new task IDs and one-line
  rationale each.
````

---

## 2. The execution prompt (build the next task)

Copy-paste the block below into a fresh agent session when you want to actually do work.

````text
SYSTEM: You are an implementation agent for MakerFlow PM. The repository is
your current working directory. `FEATUREROADMAP_workplan.md` is the canonical
queue. Your job is to pick the top-ready task, implement it end-to-end,
verify it, and update the roadmap.

PROCEDURE:

1. Read `FEATUREROADMAP_workplan.md`. Identify the next task to work on:
     - Status must be `[ ] ready`.
     - All Dependencies must be `[x] done`.
     - If multiple qualify, pick the one with the highest Priority (P0 > P1 …);
       break ties by lowest Complexity (XS > S > M …).
2. Set that task's Status to `[ ] in_progress` and write a short note in its
   Decisions block: timestamp + "Picked up by execution prompt".
3. Read ONLY the files listed under that task's `Files to modify` plus the
   files explicitly named in the Spec. Use the `Agent Persona` block to
   focus your style: a backend-monolith persona writes plain stdlib Python
   in the existing band of `app/server.py`; a docs-curator persona changes
   only markdown and SVGs; etc.
4. Plan briefly in the Decisions block: what approach you will take, what you
   considered and rejected, and any open questions. If a question must be
   answered by a human before you can proceed, set Status to `[ ] blocked`,
   write the question in Decisions, and stop.
5. Implement. Keep the change scoped to the listed files. If you discover the
   work bleeds into unlisted files, STOP, append a follow-up task card to
   section 6 (suffix `-followup`), and either narrow the current task or
   block on the follow-up.
6. Verify against the Definition of Done. At minimum run:
     - `python3 scripts/smoke_test.py`
     - any tests the task names explicitly.
   For features that affect security/auth: run
     `python3 scripts/comprehensive_feature_security_test.py`.
   For UI changes: take a manual browser pass on the affected routes.
7. Write a verbose Agent Decisions entry covering: approach taken, alternatives
   considered, surprises encountered, follow-ups identified, and the exact
   commands you ran to verify. Include enough detail that a future agent can
   audit the work without re-reading the diff.
8. Flip the task's Status to `[x] done`.
9. For each task ID listed under this task's `Unblocks`, check whether all of
   ITS Dependencies are now `[x] done`. If so, promote that downstream task
   from `[ ] backlog` to `[ ] ready`.
10. Append a one-line entry to section 7 (Checkpoint log): timestamp, task ID,
    outcome.
11. Decide whether to continue:
     - If the next-ready task exists, the context window is below 70%, and no
       P0 question is open: pick up the next task and return to step 2.
     - Otherwise STOP. Report to the human what was completed, what was queued,
       and any open questions.

CONSTRAINTS:

- NEVER create commits unless the human asks. If a commit is required mid-task
  (e.g., to test deploy), ask first.
- NEVER amend the schema in section 3 from this prompt — that change is a
  separate, dedicated task.
- NEVER touch tasks other than the one you're working on, except to flip
  Status on downstream tasks per step 9.
- NEVER skip the Decisions write-up. It is the project's audit trail.
- For ANY task that adds, moves, or changes a UI element: explicitly verify
  WCAG 2.1 Level AA conformance for the affected surface before flipping
  Status to done. At minimum run `python3 scripts/accessibility_audit.py`
  (or its successor — see the `P1-a11y-axe-ci` card) and record the result
  in Decisions. If the project's accessibility CI gate is in place, it must
  pass. Regressing accessibility is a Definition-of-Done failure.
- If a task's Spec is ambiguous or contradicts the code, set Status to
  `[ ] blocked`, write the conflict in Decisions, and stop.

OUTPUT:
- Code changes for the picked task.
- Updated `FEATUREROADMAP_workplan.md` (status + decisions + checkpoint log).
- A short summary message to the human.
````

---

## 3. Schema and conventions

Every task card in [§6](#6-task-cards) uses this exact structure:

```markdown
### {ID} — {Title}

- **Status:** [ ] backlog · [ ] ready · [ ] in_progress · [ ] blocked · [x] done · [~] deferred
- **Agent Persona:** {persona}
- **Priority:** P0 | P1 | P2 | P3
- **Complexity:** XS | S | M | L | XL
- **Dependencies:** {task IDs that must be done first, or `—`}
- **Unblocks:** {task IDs this work clears, or `—`}
- **Files to modify:**
  - `path/to/file.py`
  - `path/to/another.md`

**Spec (human-editable):**
{Prose description of the work, plus a Definition of Done checklist:}
- [ ] DOD item 1
- [ ] DOD item 2

**Notes:**
{free-form notes from humans during triage}

**Agent Decisions (append-only, verbose):**
{The executing agent appends timestamped entries here describing approach,
alternatives considered, commands run, surprises, follow-ups. Never overwritten.}
```

**Status checkbox rules:**

- Only one status box may be checked per task at a time.
- The agent never deletes prior status boxes — it un-checks the previous one and checks the new one. This preserves the visible history in the file diff.
- `[~] deferred` requires a one-line reason in Decisions.

**Sequencing rules:**

- A task can only be promoted from `backlog` → `ready` when every Dependency is `[x] done`.
- A task with no Dependencies is `ready` from creation.
- A task that has been `[x] done` is immutable except for the Decisions block, which may receive post-hoc audit entries.

---

## 4. Status legend, personas, scales

### Status legend

| Box | Meaning |
|---|---|
| `[ ] backlog` | Captured but not approved for execution. Spec may be incomplete. |
| `[ ] ready` | Triaged, dependencies resolved, agent can pick this up next. |
| `[ ] in_progress` | An agent has picked it up. Decisions block is being written. |
| `[ ] blocked` | Cannot proceed; a question or external dependency is pending. |
| `[x] done` | DOD met, verification passed, downstream tasks notified. |
| `[~] deferred` | Explicitly parked. Reason recorded in Decisions. |

### Agent personas

| Persona | Scope | Touch |
|---|---|---|
| `backend-monolith` | Routes, RBAC, SQL, render functions inside `app/server.py`. | Python, stdlib-first. |
| `frontend-progressive` | `app/static/app.js`, `app/static/style.css`. No build pipeline. | Vanilla JS + CSS. |
| `ops-deploy` | `scripts/deploy_production.sh`, `.do/app.yaml`, systemd, nginx. | Bash + YAML + ops. |
| `data-migrations` | `ensure_bootstrap()`, `run_schema_upgrades()`, `scripts/migrate_*`. | SQL + Python. |
| `security-reviewer` | Auth, sessions, CSRF, RBAC, audit, security headers. | Read-heavy, surgical writes. |
| `docs-curator` | `README.md`, `docs/`, `MakerFlow Website/wiki/`, SVG diagrams. | Markdown + SVG only. |
| `qa-automation` | `scripts/*test*.py`, future `tests/` directory, CI workflows. | Python + GitHub Actions YAML. |
| `integrations` | Calendar sync, SMTP, future webhooks, future SSO. | Python + external API specs. |

### Priority scale

| Rank | Meaning |
|---|---|
| **P0** | Foundational — must land before downstream work makes sense. Or: data-loss / security risk. |
| **P1** | Production hardening or critical UX. Should land within the current quarter. |
| **P2** | Product growth / new capability. Plan for the next quarter. |
| **P3** | Nice-to-have / aesthetic / experimental. |

### Complexity scale

| Size | ~LOC | ~Time for the agent |
|---|---|---|
| **XS** | < 50 | < 30 minutes |
| **S** | 50–250 | 30–120 minutes |
| **M** | 250–1000 | 2–6 hours |
| **L** | 1000–3000 | 1–3 days |
| **XL** | > 3000 | Multi-week initiative — should usually be split before execution. |

---

## 5. Task index (at-a-glance dashboard)

This index is **human-maintained-by-default** but the regeneration and execution prompts both keep it in sync.

| ID | Title | Status | Priority | Complexity | Dependencies | Unblocks |
|---|---|---|---|---|---|---|
| [P0-onboarding-docs](#p0-onboarding-docs--ship-onboarding-docs-and-diagrams) | Ship onboarding docs + diagrams | `[x] done` | P0 | M | — | P0-roadmap-bootstrap |
| [P0-roadmap-bootstrap](#p0-roadmap-bootstrap--bootstrap-this-roadmap-file) | Bootstrap this roadmap file | `[x] done` | P0 | S | P0-onboarding-docs | P1-ci-smoke-and-security, P1-pytest-scaffold |
| [P1-ci-smoke-and-security](#p1-ci-smoke-and-security--github-actions-smoke--security-on-prs) | GitHub Actions: smoke + security on PRs | `[ ] ready` | P1 | S | P0-roadmap-bootstrap | P1-release-tag-flow |
| [P1-pytest-scaffold](#p1-pytest-scaffold--introduce-pytest-with-shared-db-fixture) | Introduce pytest with shared DB fixture | `[ ] ready` | P1 | M | P0-roadmap-bootstrap | P2-server-modularization, P1-api-openapi-spec |
| [P1-release-tag-flow](#p1-release-tag-flow--tag-versioned-releases-from-main) | Tag versioned releases from `main` | `[ ] backlog` | P1 | S | P1-ci-smoke-and-security | — |
| [P1-api-openapi-spec](#p1-api-openapi-spec--openapi-spec-for-api-endpoints) | OpenAPI spec for `/api/*` endpoints | `[ ] backlog` | P1 | M | P1-pytest-scaffold | P2-api-key-auth, P3-public-api-docs |
| [P1-observability-baseline](#p1-observability-baseline--structured-logs--request-ids) | Structured JSON logs + request_id | `[ ] ready` | P1 | S | P0-roadmap-bootstrap | P2-error-tracking |
| [P1-hard-purge-policy](#p1-hard-purge-policy--gdpr-grade-hard-purge-workflow) | GDPR-grade hard purge workflow | `[ ] backlog` | P1 | M | P0-roadmap-bootstrap | P2-data-retention-policies |
| [P1-2fa-totp](#p1-2fa-totp--per-user-totp-second-factor) | Per-user TOTP second factor | `[ ] backlog` | P1 | M | P0-roadmap-bootstrap | P2-oidc-sso |
| [P2-server-modularization](#p2-server-modularization--split-appserverpy-into-focused-modules) | Split `app/server.py` into focused modules | `[ ] backlog` | P2 | L | P1-pytest-scaffold | P2-blueprint-routes |
| [P2-blueprint-routes](#p2-blueprint-routes--migrate-dispatcher-to-flask-blueprints) | Migrate dispatcher to Flask blueprints | `[ ] backlog` | P2 | L | P2-server-modularization | — |
| [P2-api-key-auth](#p2-api-key-auth--api-keys-for-machine-clients) | API keys for machine clients | `[ ] backlog` | P2 | M | P1-api-openapi-spec | P3-webhooks |
| [P2-oidc-sso](#p2-oidc-sso--institution-oidc-single-sign-on) | Institution OIDC single sign-on | `[ ] backlog` | P2 | L | P1-2fa-totp | — |
| [P2-error-tracking](#p2-error-tracking--sentry-style-error-aggregation) | Sentry-style error aggregation | `[ ] backlog` | P2 | M | P1-observability-baseline | — |
| [P2-fulltext-search](#p2-fulltext-search--unified-search-across-tasksprojectsmeetings) | Unified search across tasks/projects/meetings | `[ ] backlog` | P2 | M | — | — |
| [P2-bulk-operations](#p2-bulk-operations--multi-select-bulk-edit-on-tasks) | Multi-select bulk edit on tasks | `[ ] backlog` | P2 | M | — | — |
| [P2-attachments-objectstore](#p2-attachments-objectstore--attachments-to-spaces3) | Attachments to Spaces/S3 | `[ ] backlog` | P2 | L | — | — |
| [P2-data-retention-policies](#p2-data-retention-policies--per-org-retention-windows) | Per-org retention windows | `[ ] backlog` | P2 | M | P1-hard-purge-policy | — |
| [P3-mobile-layout-pass](#p3-mobile-layout-pass--responsive-pass-on-kanban--modals) | Responsive pass on kanban + modals | `[ ] backlog` | P3 | M | — | — |
| [P3-webhooks](#p3-webhooks--outbound-webhooks-for-mutations) | Outbound webhooks for mutations | `[ ] backlog` | P3 | M | P2-api-key-auth | — |
| [P3-public-api-docs](#p3-public-api-docs--publish-openapi-on-the-website) | Publish OpenAPI on the website | `[ ] backlog` | P3 | S | P1-api-openapi-spec | — |
| [P3-design-tokens](#p3-design-tokens--codify-design-tokens-and-darklight-themes) | Codify design tokens and dark/light themes | `[ ] backlog` | P3 | M | — | — |

### Accessibility — ADA Title II + Section 504 compliance program

A dedicated track. See [§6 — Accessibility compliance program](#accessibility-compliance-program-ada-title-ii--section-504) for regulatory context.

| ID | Title | Status | Priority | Complexity | Dependencies | Unblocks |
|---|---|---|---|---|---|---|
| [P0-a11y-policy-baseline](#p0-a11y-policy-baseline--adopt-wcag-21-aa-as-the-project-baseline) | Adopt WCAG 2.1 AA as the project baseline | `[ ] ready` | P0 | S | P0-roadmap-bootstrap | almost every a11y task below |
| [P0-a11y-statement-page](#p0-a11y-statement-page--publish-an-accessibility-conformance-statement) | Publish `/accessibility` conformance statement | `[ ] backlog` | P0 | M | P0-a11y-policy-baseline | P2-a11y-alt-format-workflow, P3-a11y-coordinator-config |
| [P1-a11y-axe-ci](#p1-a11y-axe-ci--axe-core-violation-gate-in-ci) | axe-core violation gate in CI | `[ ] backlog` | P1 | S | P0-a11y-policy-baseline, P1-ci-smoke-and-security | every other a11y P1 |
| [P1-a11y-keyboard-kanban](#p1-a11y-keyboard-kanban--keyboard-alternative-to-drag-and-drop-on-tasks) | Keyboard alternative to drag-and-drop on `/tasks` | `[ ] backlog` | P1 | L | P0-a11y-policy-baseline | P2-a11y-screen-reader-pass |
| [P1-a11y-modal-focus](#p1-a11y-modal-focus--card-editor-modal-focus-trap-and-dialog-semantics) | Card-editor modal: focus trap + dialog semantics | `[ ] backlog` | P1 | M | P0-a11y-policy-baseline | P2-a11y-screen-reader-pass |
| [P1-a11y-non-color-status](#p1-a11y-non-color-status--non-color-cues-for-every-status-indicator) | Non-color cues for every status indicator | `[ ] backlog` | P1 | M | P0-a11y-policy-baseline | — |
| [P1-a11y-aria-live](#p1-a11y-aria-live--live-regions-for-activity-toasts-errors-and-drag-results) | Live regions for activity, toasts, errors | `[ ] backlog` | P1 | M | P0-a11y-policy-baseline | P1-a11y-keyboard-kanban |
| [P1-a11y-forms-labels-errors](#p1-a11y-forms-labels-errors--programmatic-labels-error-identification-autocomplete) | Programmatic labels, error identification, autocomplete | `[ ] backlog` | P1 | M | P0-a11y-policy-baseline | — |
| [P1-a11y-landmarks-headings](#p1-a11y-landmarks-headings--landmarks-and-heading-hierarchy-audit) | Landmarks + heading hierarchy audit | `[ ] backlog` | P1 | M | P0-a11y-policy-baseline | — |
| [P1-a11y-focus-visible](#p1-a11y-focus-visible--standardize-focus-visible-ring-with-31-contrast) | Standardize `:focus-visible` ring with 3:1 contrast | `[ ] backlog` | P1 | S | P0-a11y-policy-baseline | — |
| [P1-a11y-page-titles](#p1-a11y-page-titles--descriptive-page-title-per-route) | Descriptive `<title>` per route | `[ ] backlog` | P1 | S | P0-a11y-policy-baseline | — |
| [P1-a11y-contrast-audit](#p1-a11y-contrast-audit--contrast-pass-on-dark--light-themes) | Contrast pass on dark + light themes | `[ ] backlog` | P1 | S | P0-a11y-policy-baseline | — |
| [P1-a11y-session-timeout](#p1-a11y-session-timeout--warn--extend-before-session-expiry) | Warn + extend before session expiry | `[ ] backlog` | P1 | M | P0-a11y-policy-baseline | — |
| [P1-a11y-skip-link-and-lang](#p1-a11y-skip-link-and-lang--verify-skip-link-and-set-html-lang) | Verify skip-link, set `<html lang>` | `[ ] backlog` | P1 | XS | P0-a11y-policy-baseline | — |
| [P2-a11y-reflow-zoom](#p2-a11y-reflow-zoom--200-zoom--320-px-reflow-pass) | 200% zoom + 320 px reflow pass | `[ ] backlog` | P2 | M | P0-a11y-policy-baseline | — |
| [P2-a11y-reduced-motion](#p2-a11y-reduced-motion--respect-prefers-reduced-motion) | Respect `prefers-reduced-motion` | `[ ] backlog` | P2 | XS | P0-a11y-policy-baseline | — |
| [P2-a11y-screen-reader-pass](#p2-a11y-screen-reader-pass--manual-nvda--voiceover--talkback-audit) | Manual NVDA + VoiceOver + TalkBack audit | `[ ] backlog` | P2 | M | P1-a11y-keyboard-kanban, P1-a11y-modal-focus, P1-a11y-aria-live | P2-a11y-vpat-acr |
| [P2-a11y-vpat-acr](#p2-a11y-vpat-acr--publish-vpat-24-accessibility-conformance-report) | Publish VPAT 2.4 ACR | `[ ] backlog` | P2 | M | P2-a11y-screen-reader-pass | — |
| [P2-a11y-alt-format-workflow](#p2-a11y-alt-format-workflow--alternative-format-request-workflow) | Alternative-format request workflow | `[ ] backlog` | P2 | M | P0-a11y-statement-page | — |
| [P2-a11y-pdf-attachments](#p2-a11y-pdf-attachments--tagged-pdf-policy-and-alt-text-on-attachments) | Tagged-PDF policy + alt text on attachments | `[ ] backlog` | P2 | M | P0-a11y-policy-baseline | — |
| [P2-a11y-print-css](#p2-a11y-print-css--print-stylesheet-and-exported-pdf-pass) | Print stylesheet + exported-PDF pass | `[ ] backlog` | P2 | S | P0-a11y-policy-baseline | — |
| [P3-a11y-wcag22-uplift](#p3-a11y-wcag22-uplift--plan-for-wcag-22-aa-uplift) | Plan for WCAG 2.2 AA uplift | `[ ] backlog` | P3 | M | P2-a11y-vpat-acr | — |
| [P3-a11y-coordinator-config](#p3-a11y-coordinator-config--per-org-ada-coordinator--grievance-procedure) | Per-org ADA coordinator + grievance procedure | `[ ] backlog` | P3 | S | P0-a11y-statement-page | — |

---

## 6. Task cards

### P0-onboarding-docs — Ship onboarding docs and diagrams

- **Status:** [x] done
- **Agent Persona:** docs-curator
- **Priority:** P0
- **Complexity:** M
- **Dependencies:** —
- **Unblocks:** P0-roadmap-bootstrap
- **Files to modify:**
  - `README.md`
  - `ProductSpec.md`
  - `docs/diagrams/01-system-architecture.svg`
  - `docs/diagrams/02-request-lifecycle.svg`
  - `docs/diagrams/03-data-model.svg`
  - `docs/diagrams/04-rbac-roles.svg`
  - `docs/diagrams/05-deployment-topologies.svg`
  - `docs/diagrams/06-component-map.svg`
  - `docs/diagrams/07-feature-flow.svg`
  - `docs/diagrams/08-roadmap-loop.svg`

**Spec (human-editable):**
Produce the developer-onboarding artifacts required to make this codebase legible to someone who has never seen it. README must cover product purpose, author, usage, GitHub deployment. ProductSpec must cover architecture, data model, RBAC, repo layout, feature recipe, debugging cookbook, known gaps. Diagrams must cover system architecture, request lifecycle, data model, RBAC, deployment topologies, repo component map, end-to-end feature flow, and the roadmap loop itself.

- [x] README.md rewritten with TOC, embedded diagrams, env table, repo map
- [x] ProductSpec.md written end-to-end
- [x] 8 SVG diagrams created under `docs/diagrams/`
- [x] Diagrams embedded in README + ProductSpec via relative paths
- [x] No new external dependencies introduced

**Notes:**
This was the seed pass that bootstrapped the documentation system. Subsequent doc work should refer to this set, not redo it.

**Agent Decisions (append-only, verbose):**
- 2026-05-21 — Initial onboarding pass. Chose hand-written SVG over Mermaid so diagrams render identically on GitHub, GitHub Pages, and local markdown previewers without JS. Chose to expand README to a full onboarding doc rather than keep it terse — the audience is forks/self-hosters who arrive cold. Wrote ProductSpec as a sequential 20-section guide because the codebase's monolithic core rewards a navigation map more than a topical reference.

---

### P0-roadmap-bootstrap — Bootstrap this roadmap file

- **Status:** [x] done
- **Agent Persona:** docs-curator
- **Priority:** P0
- **Complexity:** S
- **Dependencies:** P0-onboarding-docs
- **Unblocks:** P1-ci-smoke-and-security, P1-pytest-scaffold, P1-observability-baseline, P1-hard-purge-policy, P1-2fa-totp
- **Files to modify:**
  - `FEATUREROADMAP_workplan.md`

**Spec (human-editable):**
Create this file with the schema, regen prompt, execute prompt, status legend, persona definitions, priority and complexity scales, an index, and the initial seeded backlog. Roadmap must be self-contained — restartable cold without external state.

- [x] Schema documented in §3
- [x] Regen prompt complete in §1
- [x] Execute prompt complete in §2
- [x] Status legend + personas + scales in §4
- [x] Index in §5 reflects seeded cards
- [x] At least 15 seeded task cards in §6
- [x] Checkpoint log scaffolded in §7
- [x] Cross-linked from README and ProductSpec

**Notes:**
The file itself is the persistence layer. Do not introduce a database table or external tracker for roadmap state.

**Agent Decisions (append-only, verbose):**
- 2026-05-21 — Chose a single-file design over a `docs/roadmap/` directory because it's easier to diff, grep, and restart from. Chose explicit IDs (`P{priority}-{slug}`) over UUIDs so humans can reference tasks in PR titles. Made the execute prompt scope reads narrowly to `Files to modify` so an agent doesn't blow its context window reading the whole repo for a small task.

---

### P1-ci-smoke-and-security — GitHub Actions: smoke + security on PRs

- **Status:** [ ] ready
- **Agent Persona:** qa-automation
- **Priority:** P1
- **Complexity:** S
- **Dependencies:** P0-roadmap-bootstrap
- **Unblocks:** P1-release-tag-flow
- **Files to modify:**
  - `.github/workflows/ci.yml` (new)
  - `requirements.txt` (if a dev section needs adding)
  - `docs/TESTING.md`

**Spec (human-editable):**
Add a GitHub Actions workflow that runs on every pull request to `main`. It should install dependencies, run the smoke test and the comprehensive feature/security test against a SQLite backend, and post the result as a check. Failures must block merge. Workflow must be < 5 minutes for the smoke job.

Definition of Done:
- [ ] `.github/workflows/ci.yml` exists and triggers on `pull_request` to `main`
- [ ] Job 1: smoke (`python3 scripts/smoke_test.py`) on Ubuntu, Python 3.11.9
- [ ] Job 2: usability + accessibility (`scripts/usability_test.py`, `scripts/accessibility_audit.py`)
- [ ] Job 3: security (`scripts/comprehensive_feature_security_test.py`) — allowed to be slow, marked required
- [ ] Workflow artifacts: `analysis_outputs/*.json|md` uploaded on failure
- [ ] `docs/TESTING.md` updated with a "Continuous integration" section
- [ ] PR template updated with a "CI checklist" if one exists

**Notes:**
Keep the matrix simple — one Python version, one OS. Don't over-engineer.

**Agent Decisions (append-only, verbose):**
_(empty — to be filled by executing agent)_

---

### P1-pytest-scaffold — Introduce pytest with shared DB fixture

- **Status:** [ ] ready
- **Agent Persona:** qa-automation
- **Priority:** P1
- **Complexity:** M
- **Dependencies:** P0-roadmap-bootstrap
- **Unblocks:** P2-server-modularization, P1-api-openapi-spec, P2-blueprint-routes
- **Files to modify:**
  - `requirements.txt`
  - `pytest.ini` (new) or `pyproject.toml` (new)
  - `tests/__init__.py` (new)
  - `tests/conftest.py` (new)
  - `tests/test_smoke.py` (new — port of `scripts/smoke_test.py`)
  - `tests/test_rbac.py` (new — minimal coverage of `role_allows`)
  - `tests/test_csrf.py` (new — minimal coverage of `verify_csrf`)
  - `docs/TESTING.md`
  - `.github/workflows/ci.yml` (additive, if it exists)

**Spec (human-editable):**
Introduce a `tests/` directory using pytest, with a shared `conftest.py` providing a fresh SQLite DB per test session, a `client` fixture that yields a callable returning `(status, headers, body)` for a given request, and a `session` fixture that returns an authenticated session for a given role.

Definition of Done:
- [ ] `pytest -q` runs green from the repo root
- [ ] `conftest.py` creates a temp SQLite DB and tears it down after the session
- [ ] At least three test modules land: smoke, RBAC, CSRF
- [ ] Smoke test parity with `scripts/smoke_test.py` (port, don't delete the script yet — keep both during transition)
- [ ] CI job runs pytest in addition to the existing scripts
- [ ] `docs/TESTING.md` includes a "pytest" section

**Notes:**
Do not bundle test-only deps into the production `requirements.txt`. Use a separate `requirements-dev.txt` or a `[project.optional-dependencies] dev` table.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P1-release-tag-flow — Tag versioned releases from `main`

- **Status:** [ ] backlog
- **Agent Persona:** ops-deploy
- **Priority:** P1
- **Complexity:** S
- **Dependencies:** P1-ci-smoke-and-security
- **Unblocks:** —
- **Files to modify:**
  - `.github/workflows/release.yml` (new)
  - `docs/DEPLOYMENT.md`
  - `CHANGELOG.md` (new)

**Spec (human-editable):**
Add a workflow that, when a maintainer pushes a `v*.*.*` git tag, runs the full release audit pipeline and creates a GitHub Release with the changelog excerpt and attached audit artifacts.

Definition of Done:
- [ ] `.github/workflows/release.yml` triggers on `push` of `v*.*.*` tags
- [ ] Workflow runs `./scripts/pre_release_audit.sh` headlessly
- [ ] Creates a GitHub Release with notes drawn from `CHANGELOG.md`
- [ ] Attaches `analysis_outputs/*.md` files as release artifacts
- [ ] `docs/DEPLOYMENT.md` gains a "Tagging a release" section
- [ ] `CHANGELOG.md` is seeded with the current state of `main`

**Notes:**
Use Keep-a-Changelog format.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P1-api-openapi-spec — OpenAPI spec for `/api/*` endpoints

- **Status:** [ ] backlog
- **Agent Persona:** docs-curator
- **Priority:** P1
- **Complexity:** M
- **Dependencies:** P1-pytest-scaffold
- **Unblocks:** P2-api-key-auth, P3-public-api-docs
- **Files to modify:**
  - `docs/api/openapi.yaml` (new)
  - `docs/api/README.md` (new)
  - `tests/test_openapi_contract.py` (new)
  - `docs/ARCHITECTURE.md`

**Spec (human-editable):**
Author an OpenAPI 3.1 spec covering every `/api/*` route currently in `app/server.py`. The spec must be the source of truth; add a pytest test that asserts every documented path has a matching dispatcher branch and vice versa.

Definition of Done:
- [ ] `docs/api/openapi.yaml` validates with `openapi-spec-validator`
- [ ] Every `/api/*` route is documented with request/response shapes
- [ ] Auth + CSRF requirements noted per route
- [ ] `tests/test_openapi_contract.py` enforces drift detection
- [ ] `docs/ARCHITECTURE.md` links to the spec
- [ ] No existing routes are modified by this task (read-only documentation pass)

**Notes:**
Use a deferred (request-time) read of `server.py` to enumerate routes. Do not refactor — just document.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P1-observability-baseline — Structured JSON logs + request_id

- **Status:** [ ] ready
- **Agent Persona:** backend-monolith
- **Priority:** P1
- **Complexity:** S
- **Dependencies:** P0-roadmap-bootstrap
- **Unblocks:** P2-error-tracking
- **Files to modify:**
  - `app/server.py` (Request/Response classes + dispatcher logging hooks)
  - `app/flask_app.py` (request id propagation)
  - `docs/SECURITY.md`
  - `docs/ARCHITECTURE.md`

**Spec (human-editable):**
Generate a `request_id` (uuid4) at the WSGI entry, attach it to a request-scoped context, include it in every log line emitted during the request, and return it as an `X-Request-Id` response header. Move log output to single-line JSON.

Definition of Done:
- [ ] Every request emits at least one JSON log line: timestamp, request_id, method, path, status, duration_ms, user_id (if any), org_id (if any)
- [ ] `X-Request-Id` header is set on all responses (including health probes)
- [ ] No PII (passwords, tokens, full request bodies) appears in log lines
- [ ] `docs/SECURITY.md` notes the redaction policy
- [ ] `docs/ARCHITECTURE.md` notes the new log format
- [ ] `python3 scripts/smoke_test.py` still passes

**Notes:**
Stay stdlib. Use `logging` with a JSON formatter — do not add `structlog` or `loguru` deps.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P1-hard-purge-policy — GDPR-grade hard purge workflow

- **Status:** [ ] backlog
- **Agent Persona:** security-reviewer
- **Priority:** P1
- **Complexity:** M
- **Dependencies:** P0-roadmap-bootstrap
- **Unblocks:** P2-data-retention-policies
- **Files to modify:**
  - `app/server.py` (`/admin/data/purge-*` routes + new `hard_purge_user`)
  - `app/static/app.js` (confirmation UX)
  - `docs/SECURITY.md`
  - `docs/DATA_MODEL.md`

**Spec (human-editable):**
Today MakerFlow soft-deletes by default and supports admin "purge". Define and implement a "right to be forgotten" path that hard-deletes a user's PII, anonymizes their authored records (set `created_by_user_id` to a sentinel "deleted_user" row), and writes an immutable `audit_log` entry capturing the request and approver.

Definition of Done:
- [ ] New route `POST /admin/users/forget` (owner-only) accepts a user id + reason
- [ ] User row is deleted; foreign-key references are nulled or repointed to a sentinel
- [ ] Sessions for that user are deleted
- [ ] `audit_log` entry written with the actor, target, reason, and timestamp; this entry is never purged
- [ ] Confirmation modal in the admin UI requires typing the target email
- [ ] `docs/SECURITY.md` "Incident response" section updated
- [ ] `docs/DATA_MODEL.md` documents the sentinel row and the audit-immutability rule
- [ ] `scripts/comprehensive_feature_security_test.py` exercises the new path

**Notes:**
This is policy-laden. Triage with a privacy stakeholder before promoting from backlog.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P1-2fa-totp — Per-user TOTP second factor

- **Status:** [ ] backlog
- **Agent Persona:** security-reviewer
- **Priority:** P1
- **Complexity:** M
- **Dependencies:** P0-roadmap-bootstrap
- **Unblocks:** P2-oidc-sso
- **Files to modify:**
  - `app/server.py` (new tables `user_totp`, login flow modifications)
  - `app/static/app.js` (enrollment UX)
  - `app/static/style.css`
  - `docs/SECURITY.md`
  - `requirements.txt` (consider adding `pyotp` or implement HMAC-SHA1 manually to stay stdlib)

**Spec (human-editable):**
Optional TOTP second factor for any user. Enrollment flow: user generates a secret, scans a QR (display the otpauth URL — leave QR rendering to client-side libraries or skip for v1), confirms a 6-digit code, secret is stored encrypted at rest. Login flow: after password success, if 2FA is enabled, prompt for the 6-digit code before issuing a session.

Definition of Done:
- [ ] New table `user_totp(user_id, secret_enc, confirmed_at, last_used_step)`
- [ ] `/account/2fa` enrollment page (GET + POST)
- [ ] Login flow gates session issuance behind TOTP for opted-in users
- [ ] Backup codes (10 single-use codes) generated on enrollment
- [ ] Owner can require 2FA for an org
- [ ] `docs/SECURITY.md` documents the threat model and the encryption-at-rest choice for `secret_enc`
- [ ] All new routes covered by `scripts/comprehensive_feature_security_test.py`

**Notes:**
Decide whether to depend on `pyotp` (~50 LOC, well-trusted) or implement TOTP manually. Default to `pyotp` unless the security-reviewer persona has a strong reason otherwise; record the decision in Decisions.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P2-server-modularization — Split `app/server.py` into focused modules

- **Status:** [ ] backlog
- **Agent Persona:** backend-monolith
- **Priority:** P2
- **Complexity:** L
- **Dependencies:** P1-pytest-scaffold
- **Unblocks:** P2-blueprint-routes
- **Files to modify:**
  - `app/server.py` (slim down to dispatcher only)
  - `app/db.py` (new — connection, adapter, bootstrap)
  - `app/auth.py` (new — sessions, CSRF, RBAC)
  - `app/render.py` (new — HTML composition helpers)
  - `app/calendar.py` (new — Google sync)
  - `app/audit.py` (new — audit log helpers)
  - `app/routes/*.py` (new — one module per feature area)
  - `tests/` (must continue to pass)

**Spec (human-editable):**
Split the ~14k LOC `app/server.py` into ~10 focused modules without changing behavior. Tests (added by `P1-pytest-scaffold`) act as the regression suite.

Definition of Done:
- [ ] No single Python file under `app/` exceeds 2000 LOC
- [ ] Module boundaries respect the band layout documented in ProductSpec.md §10
- [ ] All imports remain `from app.server import …` compatible for downstream scripts (`bootstrap_db.py`, `migrate_sqlite_to_postgres.py`) OR those scripts are updated in the same PR
- [ ] `pytest -q` passes
- [ ] `python3 scripts/comprehensive_feature_security_test.py` passes
- [ ] `docs/ARCHITECTURE.md` updated with the new file map
- [ ] `docs/diagrams/06-component-map.svg` updated

**Notes:**
This is a high-blast-radius refactor. Land it in many small PRs, with `git mv` operations and behavior-preserving changes only. Do not combine with feature work.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P2-blueprint-routes — Migrate dispatcher to Flask blueprints

- **Status:** [ ] backlog
- **Agent Persona:** backend-monolith
- **Priority:** P2
- **Complexity:** L
- **Dependencies:** P2-server-modularization
- **Unblocks:** —
- **Files to modify:**
  - `app/flask_app.py`
  - `app/routes/*.py`
  - `app/server.py` (delete dispatcher branches once migrated)

**Spec (human-editable):**
Once modularization lands, migrate the hand-rolled `if req.path == …` dispatcher to Flask blueprints, one feature area at a time. Behavior must be preserved — same URLs, same responses, same security headers.

Definition of Done:
- [ ] Every feature area has its own blueprint
- [ ] `app/server.py` no longer contains the dispatcher branch list
- [ ] CSRF + RBAC remain centrally enforced via Flask `before_request` hooks
- [ ] `pytest -q` passes
- [ ] No new dependencies introduced

**Notes:**
Avoid Flask extensions that hide behavior. Keep CSRF + RBAC visible in code, not in decorators.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P2-api-key-auth — API keys for machine clients

- **Status:** [ ] backlog
- **Agent Persona:** security-reviewer
- **Priority:** P2
- **Complexity:** M
- **Dependencies:** P1-api-openapi-spec
- **Unblocks:** P3-webhooks
- **Files to modify:**
  - `app/server.py` (new table `api_keys`, new auth path)
  - `app/static/app.js` (key issuance UX)
  - `docs/api/openapi.yaml`
  - `docs/SECURITY.md`

**Spec (human-editable):**
Allow workspace admins to issue scoped API keys. Keys are presented as `Authorization: Bearer <key>` on `/api/*` routes; sessions still apply elsewhere. Keys carry: scope (read | write), expiry, last_used_at, created_by.

Definition of Done:
- [ ] New table `api_keys(id, organization_id, scope, hash, prefix, expires_at, last_used_at, created_by_user_id, deleted_at)`
- [ ] `/settings/api-keys` issuance + revoke UI (workspace_admin+)
- [ ] `/api/*` accepts bearer auth, falls back to session
- [ ] Tokens displayed once on creation; only their prefix is stored thereafter
- [ ] Audit log entry on issue, revoke, and use
- [ ] OpenAPI spec updated
- [ ] `docs/SECURITY.md` documents the threat model

**Notes:**
Hash keys with PBKDF2-SHA256, same as passwords.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P2-oidc-sso — Institution OIDC single sign-on

- **Status:** [ ] backlog
- **Agent Persona:** integrations
- **Priority:** P2
- **Complexity:** L
- **Dependencies:** P1-2fa-totp
- **Unblocks:** —
- **Files to modify:**
  - `app/server.py` (OIDC redirect + callback routes, `user_oidc_identities` table)
  - `app/static/app.js`
  - `docs/SECURITY.md`
  - `docs/DEPLOYMENT.md`
  - `requirements.txt` (consider `authlib`; favor a minimal stdlib path if feasible)

**Spec (human-editable):**
Allow an organization to configure an OIDC provider (Google Workspace, Azure AD, Okta, Shibboleth-OIDC) for SSO. On first SSO login, link to an existing user by email or create one (with a configurable role).

Definition of Done:
- [ ] Per-org OIDC config table (`org_oidc_settings`)
- [ ] `/login/sso/<org-slug>` initiates the redirect
- [ ] `/auth/oidc/callback` exchanges the code, verifies the id_token, links/creates the user
- [ ] Password login can be disabled per org once SSO is enforced
- [ ] Session issuance reuses the existing flow (so CSRF/RBAC are unchanged)
- [ ] `docs/SECURITY.md` documents the trust model
- [ ] Documented setup recipe for at least one provider

**Notes:**
Decide trust source for `email_verified` carefully — providers vary.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P2-error-tracking — Sentry-style error aggregation

- **Status:** [ ] backlog
- **Agent Persona:** ops-deploy
- **Priority:** P2
- **Complexity:** M
- **Dependencies:** P1-observability-baseline
- **Unblocks:** —
- **Files to modify:**
  - `app/server.py`
  - `app/flask_app.py`
  - `docs/DEPLOYMENT.md`
  - `.env.example`

**Spec (human-editable):**
Optional integration with a hosted error tracker (Sentry, GlitchTip, self-hosted equivalent). Configured via env vars. Disabled by default. Captures exceptions with request_id, user_id, org_id but never request body or session data.

Definition of Done:
- [ ] `MAKERSPACE_SENTRY_DSN` env var (optional)
- [ ] If set, exceptions in the WSGI handler are sent to the tracker
- [ ] `request_id`, `user_id`, `org_id` attached as tags
- [ ] No PII / no request body sent
- [ ] `docs/DEPLOYMENT.md` has a "Error tracking" section
- [ ] Disabled-by-default behavior verified by `scripts/smoke_test.py`

**Notes:**
Consider a vendor-neutral stdlib implementation that posts JSON to a configurable webhook URL, before reaching for a vendor SDK.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P2-fulltext-search — Unified search across tasks/projects/meetings

- **Status:** [ ] backlog
- **Agent Persona:** backend-monolith
- **Priority:** P2
- **Complexity:** M
- **Dependencies:** —
- **Unblocks:** —
- **Files to modify:**
  - `app/server.py` (FTS5 virtual table on SQLite; tsvector on Postgres; unified `/search` route)
  - `app/static/app.js` (search bar + result list)
  - `app/static/style.css`
  - `docs/DATA_MODEL.md`

**Spec (human-editable):**
Add a global search box that returns matches across tasks, projects, meeting items, and partnerships, scoped to the active organization.

Definition of Done:
- [ ] Backend-detected: FTS5 on SQLite, tsvector + GIN index on Postgres
- [ ] Index is rebuilt by `ensure_bootstrap()` if absent
- [ ] Results are organization-scoped and RBAC-filtered
- [ ] Search bar in the top nav, ⌘K to focus
- [ ] Sub-100ms for 10k-row workspaces
- [ ] `docs/DATA_MODEL.md` documents the index

**Notes:**
Watch for tokenizer differences between SQLite and Postgres. Aim for "good enough" prefix + exact match in v1.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P2-bulk-operations — Multi-select bulk edit on tasks

- **Status:** [ ] backlog
- **Agent Persona:** frontend-progressive
- **Priority:** P2
- **Complexity:** M
- **Dependencies:** —
- **Unblocks:** —
- **Files to modify:**
  - `app/static/app.js`
  - `app/static/style.css`
  - `app/server.py` (`/api/tasks/bulk-update` route)

**Spec (human-editable):**
Allow users to multi-select tasks in the list view and bulk-edit status, priority, assignee, or due date in a single request.

Definition of Done:
- [ ] Checkbox column on task list, "Select all visible" affordance
- [ ] Floating action bar with bulk actions appears when ≥1 selected
- [ ] `POST /api/tasks/bulk-update` accepts `{ids: [...], patch: {...}}` with CSRF
- [ ] RBAC enforced per row; partial failures are reported back
- [ ] Single `audit_log` row per affected task (preserves history granularity)

**Notes:**
Do NOT introduce a transaction across rows that hides individual errors — the audit log must reflect each row.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P2-attachments-objectstore — Attachments to Spaces/S3

- **Status:** [ ] backlog
- **Agent Persona:** integrations
- **Priority:** P2
- **Complexity:** L
- **Dependencies:** —
- **Unblocks:** —
- **Files to modify:**
  - `app/server.py` (signed-URL flow, `attachments` table)
  - `app/static/app.js` (drag-and-drop uploader)
  - `docs/DEPLOYMENT.md`
  - `.env.example`

**Spec (human-editable):**
Today `meeting_item_files` stores attachments. Move attachment payloads to an S3-compatible object store (DigitalOcean Spaces by default), retain metadata in the DB, and use signed URLs for client uploads and downloads.

Definition of Done:
- [ ] New table `attachments(id, organization_id, entity_type, entity_id, filename, content_type, bytes, storage_key, created_at, created_by_user_id, deleted_at)`
- [ ] `/api/attachments/sign-upload` returns a signed PUT URL
- [ ] `/api/attachments/sign-download` returns a signed GET URL with short TTL
- [ ] RBAC enforced on both
- [ ] Existing `meeting_item_files` rows migrated
- [ ] `docs/DEPLOYMENT.md` documents Spaces/S3 setup + env vars

**Notes:**
Keep stdlib if possible — sign URLs via HMAC-SHA256 directly. Avoid pulling in `boto3` for this single feature.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P2-data-retention-policies — Per-org retention windows

- **Status:** [ ] backlog
- **Agent Persona:** security-reviewer
- **Priority:** P2
- **Complexity:** M
- **Dependencies:** P1-hard-purge-policy
- **Unblocks:** —
- **Files to modify:**
  - `app/server.py` (`retention_policies` table, scheduled purge entrypoint)
  - `scripts/retention_sweep.py` (new)
  - `docs/SECURITY.md`

**Spec (human-editable):**
Allow workspace owners to configure retention windows per entity type (e.g., delete soft-deleted tasks after 90 days, archive completed projects after 18 months). Provide a CLI sweep script that can be cron-scheduled.

Definition of Done:
- [ ] `retention_policies(organization_id, entity_type, soft_delete_days, archive_days)` table
- [ ] `/settings/retention` UI (owner-only)
- [ ] `scripts/retention_sweep.py` honors the policies, dry-run by default
- [ ] Audit log entry per purge
- [ ] `docs/SECURITY.md` documents the operational model

**Notes:**
Don't combine retention with hard-purge — they have different audit semantics.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P3-mobile-layout-pass — Responsive pass on kanban + modals

- **Status:** [ ] backlog
- **Agent Persona:** frontend-progressive
- **Priority:** P3
- **Complexity:** M
- **Dependencies:** —
- **Unblocks:** —
- **Files to modify:**
  - `app/static/style.css`
  - `app/static/app.js`

**Spec (human-editable):**
The kanban board and the card-editor modal are awkward below ~768px. Tighten layouts, allow horizontal swipe across columns, ensure the modal goes full-screen on small viewports.

Definition of Done:
- [ ] Kanban scrolls horizontally without breaking column drag-and-drop
- [ ] Modal goes full-screen below 600px
- [ ] All form controls are at least 44px tap targets
- [ ] `scripts/accessibility_audit.py` passes

**Notes:**
Don't introduce a CSS framework — keep the hand-rolled approach.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P3-webhooks — Outbound webhooks for mutations

- **Status:** [ ] backlog
- **Agent Persona:** integrations
- **Priority:** P3
- **Complexity:** M
- **Dependencies:** P2-api-key-auth
- **Unblocks:** —
- **Files to modify:**
  - `app/server.py` (`webhooks` table, dispatcher hook)
  - `docs/api/openapi.yaml`
  - `docs/SECURITY.md`

**Spec (human-editable):**
Allow workspace admins to register outbound webhook URLs that fire on selected events (task.created, task.completed, project.archived, etc.). HMAC-sign payloads. Retry with exponential backoff. Record delivery attempts.

Definition of Done:
- [ ] `webhooks(id, organization_id, url, secret_enc, events, last_status, last_attempt_at)` table
- [ ] `webhook_deliveries` table for the attempt log
- [ ] `/settings/webhooks` issue + revoke UI
- [ ] HMAC-SHA256 signature on the `X-MakerFlow-Signature` header
- [ ] Retry policy documented + tested

**Notes:**
A truly minimal v1 may dispatch synchronously and skip a queue. Note this in Decisions if so; defer the queue to a follow-up task.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P3-public-api-docs — Publish OpenAPI on the website

- **Status:** [ ] backlog
- **Agent Persona:** docs-curator
- **Priority:** P3
- **Complexity:** S
- **Dependencies:** P1-api-openapi-spec
- **Unblocks:** —
- **Files to modify:**
  - `MakerFlow Website/wiki/api-routes.html`
  - `MakerFlow Website/assets/`
  - `scripts/sync_website_content.py`

**Spec (human-editable):**
Generate an HTML view of the OpenAPI spec and publish it under the existing wiki. Embed via Stoplight Elements or Redoc loaded from a CDN — no build pipeline.

Definition of Done:
- [ ] `api-routes.html` loads the spec from `docs/api/openapi.yaml`
- [ ] Renders without JavaScript errors
- [ ] `sync_website_content.py` copies the spec alongside the HTML
- [ ] Linked from the wiki index

**Notes:**
Pin the CDN library version explicitly.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P3-design-tokens — Codify design tokens and dark/light themes

- **Status:** [ ] backlog
- **Agent Persona:** frontend-progressive
- **Priority:** P3
- **Complexity:** M
- **Dependencies:** —
- **Unblocks:** —
- **Files to modify:**
  - `app/static/style.css`
  - `docs/diagrams/` (color palette refresh if relevant)
  - `docs/ARCHITECTURE.md`

**Spec (human-editable):**
Extract color, spacing, radius, and typography values into CSS custom properties scoped to `:root` (light) and `[data-theme="dark"]`. Sweep the codebase for hard-coded hex values and replace them.

Definition of Done:
- [ ] Zero hex colors in component-level CSS rules (only in the `:root` token block)
- [ ] Dark mode toggle still works without media-query reliance
- [ ] `docs/ARCHITECTURE.md` documents the token system
- [ ] Visual regression spot-checked on dashboard, kanban, modal, and reports

**Notes:**
Defer building a "design system" page; just codify the tokens.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

## Accessibility compliance program (ADA Title II + Section 504)

<p align="center">
  <img src="docs/diagrams/10-ada-504-compliance.svg" alt="MakerFlow PM — ADA Title II + Section 504 compliance map" width="100%"/>
</p>

### Regulatory context

MakerFlow PM is deployed at public universities and other state/local-government instrumentalities. Those entities (and any federally-funded recipients running MakerFlow) carry federal digital-accessibility obligations. The roadmap below brings the product to **WCAG 2.1 Level AA** so adopters can meet those obligations without forking. Citations are to primary sources; verify against the eCFR before quoting in customer collateral.

**Binding regulations**

- **28 CFR Part 35, Subpart H — Web and Mobile Accessibility** (DOJ Title II final rule, 89 FR 31320, published April 24, 2024; effective June 24, 2024). Adopts **WCAG 2.1 Level AA** (§ 35.200) for web content and mobile apps that public entities provide or make available, directly or through third parties.
- **45 CFR Part 84, Subpart I — Web, Mobile, and Kiosk Accessibility** (HHS Section 504 final rule, 89 FR 40066, published May 9, 2024; effective July 8, 2024). Adopts WCAG 2.1 Level AA (§ 84.84) for recipients of HHS federal financial assistance.
- **34 CFR Part 104** (Department of Education Section 504). ED has not (as of this writing) finalized a parallel WCAG technical standard rule; OCR enforcement nonetheless treats WCAG 2.1 AA as the de facto bar. Verify before publication.

**Compliance dates** (after the April/May 2026 DOJ + HHS Interim Final Rules that each extended the original deadlines by one year)

| Regime | Entity size | Deadline |
|---|---|---|
| 28 CFR 35.200 (Title II) | Public entities, population ≥ 50,000 | **April 26, 2027** |
| 28 CFR 35.200 (Title II) | Public entities, population < 50,000 · special-district governments (any size) | **April 26, 2028** |
| 45 CFR 84.84 (Section 504, HHS) | Recipients with ≥ 15 employees | **May 11, 2027** |
| 45 CFR 84.84 (Section 504, HHS) | Recipients with < 15 employees | **May 10, 2028** |

**Scope of "content"** — HTML, electronic documents (PDF, Word, PowerPoint, spreadsheets), images, audio, video, and the chrome of the application itself. **Exceptions** in 28 CFR 35.201 and 45 CFR 84.85 cover archived content, preexisting conventional electronic documents not used in active programs, third-party content not posted on behalf of the entity, individualized password-protected documents, and preexisting social-media posts — but the underlying **effective-communication** duty (28 CFR 35.160) still requires alternative-format provision on request.

**Operational obligations beyond the technical standard**

- 28 CFR 35.105 — self-evaluation of services, policies, and practices (now extends to digital assets).
- 28 CFR 35.106 — public notice of ADA rights.
- 28 CFR 35.107 — designated ADA Coordinator + published grievance procedure (entities with ≥ 50 employees).
- 28 CFR 35.160 — effective communication, including alternative-format provision.
- DOJ compliance guidance recommends training for content authors, developers, designers, and procurement staff.
- Procurement: standard practice is to require a vendor **Accessibility Conformance Report (ACR / VPAT 2.4)** in RFPs.

**Why this matters for MakerFlow specifically** — kanban drag-and-drop, color-coded statuses, the card-editor modal, the activity log, dynamic form errors, and the dark/light theme contrast are the highest-risk surfaces. The tasks below address each by name.

### P0-a11y-policy-baseline — Adopt WCAG 2.1 AA as the project baseline

- **Status:** [ ] ready
- **Agent Persona:** docs-curator
- **Priority:** P0
- **Complexity:** S
- **Dependencies:** P0-roadmap-bootstrap
- **Unblocks:** P0-a11y-statement-page, P1-a11y-axe-ci, P1-a11y-keyboard-kanban, P1-a11y-modal-focus, P1-a11y-non-color-status, P1-a11y-aria-live, P1-a11y-forms-labels-errors, P1-a11y-landmarks-headings, P1-a11y-focus-visible, P1-a11y-page-titles, P1-a11y-contrast-audit, P1-a11y-session-timeout, P1-a11y-skip-link-and-lang, P2-a11y-reflow-zoom, P2-a11y-reduced-motion, P2-a11y-pdf-attachments, P2-a11y-print-css
- **Files to modify:**
  - `docs/ACCESSIBILITY.md` (new)
  - `docs/DECISIONS.md`
  - `docs/CONTRIBUTING.md`
  - `README.md` (cross-link)
  - `ProductSpec.md` (cross-link from §12 Design system and §17 Testing)

**Spec (human-editable):**
Codify **WCAG 2.1 Level AA** as MakerFlow's technical accessibility standard, document the deployment-side regulatory matrix (28 CFR Part 35 Subpart H · 45 CFR Part 84 Subpart I), and bind contributor expectations.

- [ ] `docs/ACCESSIBILITY.md` exists with: policy statement, applicable regulations, scope (what is covered + what is out of scope), compliance-date matrix, conformance testing approach (axe + manual AT pass), exceptions and how MakerFlow handles them, and links to the canonical WCAG 2.1 AA criteria
- [ ] `docs/DECISIONS.md` gains an ADR titled "Accessibility baseline" noting the choice of WCAG 2.1 AA and the rejection of "AA-aware but not conforming" alternatives
- [ ] `docs/CONTRIBUTING.md` adds a checklist item: every PR touching UI must declare its a11y impact
- [ ] `README.md` and `ProductSpec.md` link to `docs/ACCESSIBILITY.md`
- [ ] The execute prompt in §2 already requires a11y verification on UI tasks — verify wording is consistent

**Notes:**
This is governance. No code changes. It is a prerequisite for every other a11y card because their Definition-of-Done references the baseline.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P0-a11y-statement-page — Publish an accessibility conformance statement

- **Status:** [ ] backlog
- **Agent Persona:** backend-monolith + docs-curator
- **Priority:** P0
- **Complexity:** M
- **Dependencies:** P0-a11y-policy-baseline
- **Unblocks:** P2-a11y-alt-format-workflow, P3-a11y-coordinator-config
- **Files to modify:**
  - `app/server.py` (new public route `/accessibility`, no auth required; new `render_accessibility_page`)
  - `app/static/style.css`
  - `docs/ACCESSIBILITY.md` (canonical source content; the page renders from this)
  - `MakerFlow Website/wiki/accessibility.html` (mirror via `sync_website_content.py`)

**Spec (human-editable):**
Add a public-facing accessibility statement at `/accessibility` so deploying entities can publish (and customize) their conformance disclosure. Page must remain reachable without authentication so it satisfies 28 CFR 35.106 public-notice expectations and standard procurement requirements.

Content (industry-consensus structure):

1. Conformance commitment ("MakerFlow conforms to WCAG 2.1 Level AA")
2. Date of statement + date of last review
3. Known accessibility limitations, with planned remediation timeline (pulled from roadmap completed/pending status)
4. Contact channel for accessibility complaints and **alternative-format requests** (per-org configurable — pulled from `accessibility_settings` table set up by `P3-a11y-coordinator-config`)
5. ADA Coordinator name and contact (for public entities, see 28 CFR 35.107)
6. Link to the grievance procedure
7. Compatibility statement (browsers + assistive technologies tested)
8. Technical specifications (technologies relied upon)
9. Assessment approach (self-evaluation, third-party audit, user testing)
10. Date of next planned review

Definition of Done:
- [ ] `GET /accessibility` returns the rendered page without requiring auth
- [ ] Page is linked from the footer of every authenticated page and from the login screen
- [ ] Content is sourced from `docs/ACCESSIBILITY.md` (single source of truth); `sync_website_content.py` mirrors it to the wiki
- [ ] Page lists the WCAG 2.1 AA conformance target and the current known limitations
- [ ] Page is itself WCAG 2.1 AA conformant (passes `scripts/accessibility_audit.py`)
- [ ] An `accessibility_settings` table holds the per-org coordinator name, email, and grievance procedure URL (consumed by `P3-a11y-coordinator-config`; for v1 it can be hard-coded to defaults if the table doesn't exist)

**Notes:**
The page itself is a regulatory artifact; treat changes to it as governance changes (PR review by a docs-curator persona).

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P1-a11y-axe-ci — axe-core violation gate in CI

- **Status:** [ ] backlog
- **Agent Persona:** qa-automation
- **Priority:** P1
- **Complexity:** S
- **Dependencies:** P0-a11y-policy-baseline, P1-ci-smoke-and-security
- **Unblocks:** every other a11y P1 (regression prevention)
- **Files to modify:**
  - `.github/workflows/ci.yml`
  - `scripts/accessibility_audit.py` (extend to include axe-core run, or add a sibling script)
  - `docs/TESTING.md`
  - `docs/ACCESSIBILITY.md`

**Spec (human-editable):**
Run [axe-core](https://github.com/dequelabs/axe-core) (via the `axe-core-cli` or Playwright + `@axe-core/playwright`) against the canonical pages on every PR. Fail the build on **new** violations; allow a baseline file to grandfather existing violations so the gate can be turned on before all violations are fixed.

Definition of Done:
- [ ] CI job named `a11y` runs on `pull_request` to `main`
- [ ] Tests boot the app with sample data, log in as each role, and visit: `/login`, `/dashboard`, `/projects`, `/tasks`, `/agenda`, `/assets`, `/consumables`, `/settings`, `/admin/users`, `/accessibility`
- [ ] axe runs against each page; results uploaded as a CI artifact
- [ ] A baseline file (`tests/a11y/baseline.json`) records currently-known violations; CI passes if and only if no new violations appear vs the baseline
- [ ] Updating the baseline requires an explicit PR comment label (`a11y-baseline-bump`) — prevents silent regressions
- [ ] `docs/TESTING.md` documents how to run locally and how to update the baseline
- [ ] `docs/ACCESSIBILITY.md` lists the current baseline violation count + a graph of trend over time

**Notes:**
The baseline pattern is essential — flipping the gate on without a baseline blocks all PRs. Plan to drive baseline → zero over Q3.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P1-a11y-keyboard-kanban — Keyboard alternative to drag-and-drop on `/tasks`

- **Status:** [ ] backlog
- **Agent Persona:** frontend-progressive
- **Priority:** P1
- **Complexity:** L
- **Dependencies:** P0-a11y-policy-baseline
- **Unblocks:** P2-a11y-screen-reader-pass
- **Files to modify:**
  - `app/static/app.js` (kanban handlers)
  - `app/static/style.css` (focus styles for grabbed/dropped states)
  - `app/server.py` (`render_tasks_page`; ensure each card and column has a unique programmatic identity)

**Spec (human-editable):**
Today the kanban board on `/tasks` relies on pointer drag-and-drop, which violates WCAG **2.1.1 Keyboard**, **2.5.1 Pointer Gestures**, and **2.5.2 Pointer Cancellation**. Add a parallel keyboard-and-screen-reader-accessible mechanism. The W3C ARIA Authoring Practices Guide (APG) describes appropriate patterns — prefer "select then move" (Enter to pick up, Arrow keys to move, Enter to drop, Esc to cancel) over the legacy `aria-grabbed` pattern (deprecated).

Definition of Done:
- [ ] Every kanban card is keyboard-focusable, has `role="button"` (or is a real `<button>`), and exposes its title + status + column position in its accessible name
- [ ] Pressing `Enter` or `Space` on a focused card "picks it up"; visible focus indicator changes to indicate grabbed state; `aria-live="polite"` announces "Picked up `<title>`. Use arrow keys to move."
- [ ] Arrow keys move the grabbed card between columns; `aria-live` announces destination column on each move
- [ ] `Enter`/`Space` drops the card (commits the status change); `Esc` cancels and restores original column
- [ ] Pointer drag-and-drop still works as before for sighted mouse/touch users
- [ ] Touch interactions support single-pointer alternative to drag (long-press → menu → "Move to…")
- [ ] No `aria-grabbed` (deprecated)
- [ ] `scripts/accessibility_audit.py` + axe gate pass on `/tasks`
- [ ] Manual NVDA pass: a screen-reader user can move every card to every column without using a mouse

**Notes:**
This is the highest-risk a11y blocker in MakerFlow. Plan time for manual AT testing — the implementation is the easy part.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P1-a11y-modal-focus — Card-editor modal: focus trap and dialog semantics

- **Status:** [ ] backlog
- **Agent Persona:** frontend-progressive
- **Priority:** P1
- **Complexity:** M
- **Dependencies:** P0-a11y-policy-baseline
- **Unblocks:** P2-a11y-screen-reader-pass
- **Files to modify:**
  - `app/static/app.js` (modal lifecycle: open/close/keyboard)
  - `app/static/style.css` (focus ring inside modal)
  - `app/server.py` (render the modal shell with the correct ARIA attributes)

**Spec (human-editable):**
The card-editor modal violates WCAG **4.1.2 Name, Role, Value**, **2.1.2 No Keyboard Trap** (focus can wander behind the modal), and **2.4.3 Focus Order** (focus does not return to the launching element on close).

Definition of Done:
- [ ] Modal root has `role="dialog"`, `aria-modal="true"`, `aria-labelledby="<id of heading>"`, and `aria-describedby` if there's introductory text
- [ ] First focusable element receives focus when the modal opens
- [ ] Tab cycles inside the modal (focus trap); Shift+Tab cycles backward; focus cannot leave the modal until it closes
- [ ] `Esc` closes the modal and returns focus to the element that opened it
- [ ] Closing by Save / Cancel button also returns focus to the launching element
- [ ] Background content has `aria-hidden="true"` while the modal is open
- [ ] No `inert` attribute is required, but if added, it must be polyfilled for older browsers
- [ ] Axe + manual NVDA pass on opening, editing, saving, and canceling a task in the modal

**Notes:**
The "return focus" requirement is what catches teams. Save the launching element ID when opening; restore explicitly on close.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P1-a11y-non-color-status — Non-color cues for every status indicator

- **Status:** [ ] backlog
- **Agent Persona:** frontend-progressive
- **Priority:** P1
- **Complexity:** M
- **Dependencies:** P0-a11y-policy-baseline
- **Unblocks:** —
- **Files to modify:**
  - `app/static/style.css`
  - `app/static/app.js` (lookup helpers that build status badges)
  - `app/server.py` (`render_*` functions that emit status pills)

**Spec (human-editable):**
Status is communicated by color across MakerFlow — task status pills, project lanes, agenda item state, intake-request scoring, equipment maintenance status, consumable reorder warnings. WCAG **1.4.1 Use of Color** and **1.3.3 Sensory Characteristics** require non-color signal.

Definition of Done:
- [ ] Every status pill includes a text label (already true in most cases — verify) AND an icon or shape token that varies by status (e.g., ○ Open, ◐ In Progress, ● Done, ✕ Blocked, ⌫ Deferred)
- [ ] Color is supplementary, not primary
- [ ] Same status carries the same icon/shape everywhere (consistent identification — WCAG 3.2.4)
- [ ] In dark and light themes, the icons remain visible without depending on color contrast alone (per 1.4.11)
- [ ] The design system documentation in `ProductSpec.md` §12 gets a new sub-section "Status semantics" enumerating the icon ↔ status mapping
- [ ] Axe gate passes; manual review confirms a user with the chrome "Force colors" / Windows high-contrast mode still understands status

**Notes:**
Pick a small, consistent icon set. Lucide or Heroicons inline-SVG approach fits the no-build philosophy.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P1-a11y-aria-live — Live regions for activity, toasts, errors, and drag results

- **Status:** [ ] backlog
- **Agent Persona:** frontend-progressive
- **Priority:** P1
- **Complexity:** M
- **Dependencies:** P0-a11y-policy-baseline
- **Unblocks:** P1-a11y-keyboard-kanban
- **Files to modify:**
  - `app/static/app.js` (announce helper + integration points)
  - `app/server.py` (render skeleton live-region containers in the layout)
  - `app/static/style.css` (screen-reader-only utility class `.sr-only`)

**Spec (human-editable):**
WCAG **4.1.3 Status Messages** requires that status updates be programmatically determinable without focus change. MakerFlow's activity log, save toasts, inline form validation, and drag-result outcomes all currently render visually only.

Definition of Done:
- [ ] A reusable `announce(message, {assertive: false})` helper exists in `app.js`. It writes into a hidden `<div role="status" aria-live="polite">` (or `role="alert" aria-live="assertive"` when `assertive: true`) appended to `<body>` once on load
- [ ] Activity log refresh on the dashboard announces new entries (polite, debounced)
- [ ] Save toasts (project saved, task saved, etc.) announce on success (polite)
- [ ] Inline form validation errors announce on submit attempt (assertive); also referenced via `aria-describedby` from the offending input
- [ ] Kanban drag-and-keyboard-move results announce destination column (polite) — coordination with `P1-a11y-keyboard-kanban`
- [ ] CSRF-mismatch and 503 error pages announce their state on load
- [ ] Axe + manual NVDA + VoiceOver pass: a screen-reader user notices state changes without leaving the focused control

**Notes:**
Keep the live-region root in the DOM at all times; toggling its existence (`removeChild` / `appendChild`) defeats AT detection. Just update its `textContent`.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P1-a11y-forms-labels-errors — Programmatic labels, error identification, autocomplete

- **Status:** [ ] backlog
- **Agent Persona:** backend-monolith + frontend-progressive
- **Priority:** P1
- **Complexity:** M
- **Dependencies:** P0-a11y-policy-baseline
- **Unblocks:** —
- **Files to modify:**
  - `app/server.py` (form-rendering helpers across `render_*` functions)
  - `app/static/app.js` (validation hooks)
  - `app/static/style.css`

**Spec (human-editable):**
Audit every form in MakerFlow for WCAG **3.3.1 Error Identification**, **3.3.2 Labels or Instructions**, **3.3.3 Error Suggestion**, **1.3.5 Identify Input Purpose**, and **3.3.4 Error Prevention** (for destructive actions).

Definition of Done:
- [ ] Every form control has a programmatically associated label (either `<label for="...">` or `aria-labelledby`)
- [ ] Required fields use `aria-required="true"` and visible asterisk + explanation
- [ ] Common inputs use HTML `autocomplete` tokens (email, current-password, new-password, given-name, family-name, organization, tel, etc.)
- [ ] Validation errors:
  - render adjacent to the offending input
  - set `aria-invalid="true"` on the input
  - link via `aria-describedby` to the error message
  - announce assertively via the live region (depends on `P1-a11y-aria-live`)
  - include a suggested fix where applicable (date format, file size/type, allowed character set)
- [ ] Destructive forms (delete project, purge item, forget user, bulk delete) require explicit confirmation (review/revoke per WCAG 3.3.4)
- [ ] Login form and password reset form support copy-paste of password managers
- [ ] Axe + manual NVDA pass on every form

**Notes:**
Coordinate with `P1-a11y-aria-live` (validation needs the announce helper) and any future 2FA work.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P1-a11y-landmarks-headings — Landmarks and heading hierarchy audit

- **Status:** [ ] backlog
- **Agent Persona:** backend-monolith
- **Priority:** P1
- **Complexity:** M
- **Dependencies:** P0-a11y-policy-baseline
- **Unblocks:** —
- **Files to modify:**
  - `app/server.py` (layout + every `render_*` function)

**Spec (human-editable):**
Audit and fix landmark roles and heading hierarchy across all rendered pages. WCAG **1.3.1 Info and Relationships** and **2.4.6 Headings and Labels**.

Definition of Done:
- [ ] Every page emits `<header>`, `<nav>`, `<main>`, `<aside>`, and `<footer>` landmarks (or ARIA equivalents); each `<nav>` has a discriminating `aria-label`
- [ ] Each page has exactly one `<h1>` and a logical, non-skipping heading sequence
- [ ] Section headings are programmatic, not visual-weight-only
- [ ] Repeated regions (filter sidebar, activity panel) get accessible names so AT users can jump between them
- [ ] Axe gate passes on every canonical page; manual VoiceOver rotor verifies landmark navigability

**Notes:**
This is a sweep, not a redesign. The CSS layout doesn't need to change — only the elements that produce it.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P1-a11y-focus-visible — Standardize `:focus-visible` ring with 3:1 contrast

- **Status:** [ ] backlog
- **Agent Persona:** frontend-progressive
- **Priority:** P1
- **Complexity:** S
- **Dependencies:** P0-a11y-policy-baseline
- **Unblocks:** —
- **Files to modify:**
  - `app/static/style.css`

**Spec (human-editable):**
WCAG **2.4.7 Focus Visible** and **1.4.11 Non-text Contrast**. Every focusable element needs a visible focus ring that hits 3:1 contrast against its background in both themes.

Definition of Done:
- [ ] No CSS rule strips outline without supplying a replacement (`grep -n "outline:[[:space:]]*none" app/static/style.css` returns only rules that follow with `box-shadow` or `outline` replacement)
- [ ] Focus ring uses the `--focus` token (`#ffbe55` dark / `#ff8f00` light) by default and meets 3:1 contrast against `--card`, `--bg`, and `--card-soft`
- [ ] Buttons, links, inputs, custom widgets (kanban cards, status chips, theme switch, sidebar nav, modal close, theme switch knob) all show focus
- [ ] `:focus-visible` is used (not `:focus`) so mouse clicks don't show the ring, but keyboard focus does
- [ ] Axe gate passes; manual keyboard tab-around demo recorded for the changelog

**Notes:**
Coordinate with `P3-design-tokens` if it lands first — they share the token system.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P1-a11y-page-titles — Descriptive `<title>` per route

- **Status:** [ ] backlog
- **Agent Persona:** backend-monolith
- **Priority:** P1
- **Complexity:** S
- **Dependencies:** P0-a11y-policy-baseline
- **Unblocks:** —
- **Files to modify:**
  - `app/server.py` (layout shell + every `render_*` function)

**Spec (human-editable):**
WCAG **2.4.2 Page Titled**. Every rendered route must set a descriptive `<title>` including the active organization and the page subject.

Definition of Done:
- [ ] Title format: `<page> · <org name> · MakerFlow` (e.g., `Tasks · Brandeis MakerLab · MakerFlow`)
- [ ] Auth screens (`/login`, `/forgot-password`) omit the org name
- [ ] After a modal save that changes context (e.g., switching active project), update the title client-side via the `announce` helper companion — or accept that no client title update happens for modals
- [ ] No two routes share identical titles
- [ ] Axe gate passes; manual screen-reader pass verifies title is announced on page load

**Notes:**
Small but high-value. Pair with `P1-a11y-landmarks-headings` for a single sweep PR.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P1-a11y-contrast-audit — Contrast pass on dark + light themes

- **Status:** [ ] backlog
- **Agent Persona:** frontend-progressive
- **Priority:** P1
- **Complexity:** S
- **Dependencies:** P0-a11y-policy-baseline
- **Unblocks:** —
- **Files to modify:**
  - `app/static/style.css`
  - `docs/ACCESSIBILITY.md` (contrast matrix appendix)

**Spec (human-editable):**
Run automated contrast checks against the canonical token palette in both themes. WCAG **1.4.3 Contrast (Minimum)** = 4.5:1 for normal text, 3:1 for large text. WCAG **1.4.11 Non-text Contrast** = 3:1 for UI components and meaningful graphics.

Definition of Done:
- [ ] A contrast matrix in `docs/ACCESSIBILITY.md` documents the ratio for every token combination actually used (text on card, muted text on card, brand link on card, focus ring on card, etc.) in both themes
- [ ] Any failing combination is either fixed (token adjustment) or documented as a known limitation with a remediation date
- [ ] The theme switch itself meets 3:1 against its background
- [ ] Status pills meet 3:1 for their borders against the card surface
- [ ] axe + the `scripts/accessibility_audit.py` contrast check pass

**Notes:**
The dark theme is the riskier of the two — soft tokens like `--muted` may fail on `--card-soft`. Allow token tweaks if needed.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P1-a11y-session-timeout — Warn + extend before session expiry

- **Status:** [ ] backlog
- **Agent Persona:** backend-monolith + frontend-progressive
- **Priority:** P1
- **Complexity:** M
- **Dependencies:** P0-a11y-policy-baseline
- **Unblocks:** —
- **Files to modify:**
  - `app/server.py` (`/api/session/extend` endpoint; expiry hint in JSON responses)
  - `app/static/app.js` (countdown + extend dialog)
  - `app/static/style.css`

**Spec (human-editable):**
WCAG **2.2.1 Timing Adjustable**. Currently sessions expire without warning, which can lose work and is a usability barrier — especially for AT users who take longer to complete forms.

Definition of Done:
- [ ] 60 seconds before session expiry, a modal warns the user and offers "Extend session" + "Log out now"
- [ ] "Extend" calls `POST /api/session/extend` (CSRF-protected) which issues a refreshed session token without losing form state
- [ ] If the user does not respond and the session expires, any in-progress form data is saved to `sessionStorage` and restored after re-login
- [ ] The warning modal is itself accessible (focus trap, `role="dialog"`, announced via live region)
- [ ] Session expiry can be turned off by user preference for accommodations-eligible users (per 2.2.1's "user can adjust" provision); persist the preference in `user_preferences.session_timeout_seconds`
- [ ] Axe gate + manual NVDA pass

**Notes:**
Coordinate the session-extend endpoint with future 2FA (`P1-2fa-totp`) — the refreshed token must not bypass the 2FA gate.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P1-a11y-skip-link-and-lang — Verify skip-link and set `<html lang>`

- **Status:** [ ] backlog
- **Agent Persona:** backend-monolith
- **Priority:** P1
- **Complexity:** XS
- **Dependencies:** P0-a11y-policy-baseline
- **Unblocks:** —
- **Files to modify:**
  - `app/server.py` (page shell)

**Spec (human-editable):**
Two quick wins:

- WCAG **2.4.1 Bypass Blocks**: a skip-link exists in CSS (`.skip-link`) but verify it's actually rendered on every page, focuses the main content region, and isn't hidden from AT.
- WCAG **3.1.1 Language of Page** + **3.1.2 Language of Parts**: emit `<html lang="en">` on every page; allow per-page override and per-element `lang=""` for foreign-language content (used by future i18n).

Definition of Done:
- [ ] `<html lang="en">` is present on every rendered page; configurable via a new env var `MAKERSPACE_DEFAULT_LANG` (default `en`)
- [ ] `<a class="skip-link" href="#main">Skip to main content</a>` is the first focusable element on every page; `<main id="main">` exists
- [ ] Skip-link is visible when focused and meets 3:1 contrast
- [ ] Axe gate passes

**Notes:**
Sub-30-minute task. Bundle into the landmarks PR.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P2-a11y-reflow-zoom — 200% zoom + 320 px reflow pass

- **Status:** [ ] backlog
- **Agent Persona:** frontend-progressive
- **Priority:** P2
- **Complexity:** M
- **Dependencies:** P0-a11y-policy-baseline
- **Unblocks:** —
- **Files to modify:**
  - `app/static/style.css`
  - `app/static/app.js` (any layout that's JS-driven)

**Spec (human-editable):**
WCAG **1.4.4 Resize Text** (200% zoom without loss) and **1.4.10 Reflow** (320 CSS px width without two-dimensional scrolling, except for content that intrinsically needs 2D — e.g., a kanban grid).

Definition of Done:
- [ ] Every canonical page is usable at browser zoom 200%
- [ ] Below 600 px viewport, the kanban collapses to a single-column "stacked" view; users can switch between columns via a select
- [ ] Modals fill the viewport on small screens (already partially true)
- [ ] Tables (admin/users, reports) become scrollable on narrow viewports rather than overflowing
- [ ] Sidebar collapses to a hamburger drawer below 768 px
- [ ] Axe + manual mobile-Safari + mobile-Chrome verification

**Notes:**
Coordinate with `P3-mobile-layout-pass` — they overlap. Possibly merge.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P2-a11y-reduced-motion — Respect `prefers-reduced-motion`

- **Status:** [ ] backlog
- **Agent Persona:** frontend-progressive
- **Priority:** P2
- **Complexity:** XS
- **Dependencies:** P0-a11y-policy-baseline
- **Unblocks:** —
- **Files to modify:**
  - `app/static/style.css`
  - `app/static/app.js`

**Spec (human-editable):**
WCAG **2.3.3 Animation from Interactions** (AAA, not required) and general usability for vestibular-disorder users. Respect `@media (prefers-reduced-motion: reduce)`.

Definition of Done:
- [ ] Theme-switch knob transition is removed when reduced-motion is set
- [ ] Kanban drag-and-drop transitions reduced to instant
- [ ] Modal open/close transitions reduced to instant
- [ ] No motion-only signal carries information (e.g., a card "wiggle" must also signal via a status change)
- [ ] Axe gate passes

**Notes:**
Single CSS block + a couple of JS guards. Pair with `P3-design-tokens`.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P2-a11y-screen-reader-pass — Manual NVDA + VoiceOver + TalkBack audit

- **Status:** [ ] backlog
- **Agent Persona:** qa-automation
- **Priority:** P2
- **Complexity:** M
- **Dependencies:** P1-a11y-keyboard-kanban, P1-a11y-modal-focus, P1-a11y-aria-live, P1-a11y-forms-labels-errors, P1-a11y-landmarks-headings
- **Unblocks:** P2-a11y-vpat-acr
- **Files to modify:**
  - `analysis_outputs/a11y-screen-reader-report-YYYY-MM-DD.md` (new)
  - `docs/ACCESSIBILITY.md` (cross-link to the latest report)

**Spec (human-editable):**
Manual assistive-technology pass. Automated tools catch ~30-40% of WCAG issues; the rest must be observed.

Definition of Done:
- [ ] NVDA + Firefox on Windows: canonical flows tested — login, dashboard read, create project, create task, drag task across columns via keyboard, save modal, comment, log out
- [ ] VoiceOver + Safari on macOS: same canonical flows
- [ ] VoiceOver + Safari on iOS: read-only canonical flows + edit a task
- [ ] TalkBack + Chrome on Android: read-only canonical flows + edit a task
- [ ] Findings recorded in a dated report under `analysis_outputs/`
- [ ] Each finding becomes a discrete task card (suffix `-followup`) added to §6 via the regen prompt
- [ ] `docs/ACCESSIBILITY.md` updated with the report date and a summary

**Notes:**
Schedule a focused day for this. NVDA is free; VoiceOver is built-in. Allocate budget for an external accessibility consultant if budget exists — fresh eyes catch what regulars miss.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P2-a11y-vpat-acr — Publish VPAT 2.4 Accessibility Conformance Report

- **Status:** [ ] backlog
- **Agent Persona:** docs-curator + security-reviewer
- **Priority:** P2
- **Complexity:** M
- **Dependencies:** P2-a11y-screen-reader-pass
- **Unblocks:** —
- **Files to modify:**
  - `docs/accessibility/vpat-2.4-int.md` (new, derived from the ITI template)
  - `docs/accessibility/vpat-2.4-int.html` (rendered)
  - `MakerFlow Website/wiki/accessibility-conformance.html`
  - `README.md` (link in the Tech stack table)

**Spec (human-editable):**
Author and publish a **VPAT 2.4 INT** Accessibility Conformance Report (ACR) documenting conformance to WCAG 2.1 Level AA. Procurement teams at adopting institutions need this as a standard part of vendor evaluation.

Definition of Done:
- [ ] Use the ITI VPAT 2.4 INT template (https://www.itic.org/policy/accessibility/vpat)
- [ ] Complete the WCAG 2.1 AA section criterion-by-criterion (Supports / Partially Supports / Does Not Support / Not Applicable / Not Evaluated, with remarks)
- [ ] Cite the screen-reader-pass report as the assessment source
- [ ] Date the ACR; commit to refreshing it every release cycle
- [ ] Publish at `/accessibility-conformance` (linked from `/accessibility`) and mirrored to the wiki

**Notes:**
The ACR is a public commitment. Be honest about "Partially Supports" — the goal is procurement transparency, not marketing.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P2-a11y-alt-format-workflow — Alternative-format request workflow

- **Status:** [ ] backlog
- **Agent Persona:** backend-monolith
- **Priority:** P2
- **Complexity:** M
- **Dependencies:** P0-a11y-statement-page
- **Unblocks:** —
- **Files to modify:**
  - `app/server.py` (new table `alt_format_requests`; routes `POST /accessibility/request-alt-format`, `GET /admin/a11y/requests`)
  - `app/static/app.js`
  - `docs/ACCESSIBILITY.md`

**Spec (human-editable):**
28 CFR 35.160 (effective communication) and 45 CFR 84.85's exception scheme both require public entities to provide content in an alternative format on request, even when the original is exempt from the technical standard. MakerFlow needs a workflow.

Definition of Done:
- [ ] `/accessibility` page includes a "Request an alternative format" form (public; works without auth)
- [ ] Submission requires: requester name, contact email/phone, the URL or attachment in question, the format requested (audio, large-print PDF, braille, structured HTML, etc.), and a free-text note
- [ ] A new table `alt_format_requests(id, organization_id, requester_name, requester_contact, target_url_or_attachment_id, format_requested, note, status, created_at, fulfilled_at, fulfilled_by_user_id)` is added
- [ ] `/admin/a11y/requests` page lists open requests for the active org (workspace_admin+) with status workflow (received → in progress → fulfilled / referred / declined)
- [ ] On submission, email the org's accessibility coordinator (from `accessibility_settings` set up by `P3-a11y-coordinator-config`)
- [ ] Submission and admin views are themselves WCAG 2.1 AA conformant
- [ ] Audit log entry on each state change

**Notes:**
This is a regulatory artifact. Treat it like an incident-tracking workflow — every state change must be auditable.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P2-a11y-pdf-attachments — Tagged-PDF policy and alt text on attachments

- **Status:** [ ] backlog
- **Agent Persona:** backend-monolith
- **Priority:** P2
- **Complexity:** M
- **Dependencies:** P0-a11y-policy-baseline
- **Unblocks:** —
- **Files to modify:**
  - `app/server.py` (attachment upload route — meeting_item_files; future attachments table from `P2-attachments-objectstore`)
  - `app/static/app.js` (upload UX)
  - `docs/ACCESSIBILITY.md`

**Spec (human-editable):**
PDFs uploaded by a public entity to MakerFlow are "web content" under 28 CFR 35.200, so they must be tagged (PDF/UA) or accompanied by an accessible alternative. Implement guardrails.

Definition of Done:
- [ ] Attachment upload UI accepts an `alt_text` field per file (required for images, optional for documents)
- [ ] On PDF upload, a lightweight server-side check inspects whether the PDF has structure tags (`pypdf` exposes the catalog `/MarkInfo` / `/StructTreeRoot`); if not, surface a warning to the uploader: "This PDF doesn't appear to be tagged. Consider uploading a tagged version or attaching an accessible alternative."
- [ ] Warning is not blocking (per the regulatory exception structure)
- [ ] Per-org setting can flip the warning to a hard block for high-stakes content
- [ ] `docs/ACCESSIBILITY.md` documents the policy and links to OCR guidance on PDF accessibility
- [ ] Manual review confirms uploaded image attachments display their alt text in screen readers

**Notes:**
Don't try to re-tag PDFs server-side; that's a quagmire. Just detect, warn, and accept supplementary alternatives.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P2-a11y-print-css — Print stylesheet and exported-PDF pass

- **Status:** [ ] backlog
- **Agent Persona:** frontend-progressive
- **Priority:** P2
- **Complexity:** S
- **Dependencies:** P0-a11y-policy-baseline
- **Unblocks:** —
- **Files to modify:**
  - `app/static/style.css`

**Spec (human-editable):**
Print and "Save as PDF" output from the browser is often the artifact that ends up in compliance reviews. The current print stylesheet exists but hasn't been audited.

Definition of Done:
- [ ] Print stylesheet outputs reports, agendas, and the deleted-queue audit list in a linear, single-column layout
- [ ] Status pills retain their non-color cues when printed in grayscale
- [ ] Headings and form labels survive the print transform
- [ ] If the platform later adds server-side PDF generation, route it through the print stylesheet
- [ ] Manual print-preview pass on Chrome + Safari + Firefox

**Notes:**
Print is the lowest-priority surface, but trivial to fix.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P3-a11y-wcag22-uplift — Plan for WCAG 2.2 AA uplift

- **Status:** [ ] backlog
- **Agent Persona:** docs-curator + frontend-progressive
- **Priority:** P3
- **Complexity:** M
- **Dependencies:** P2-a11y-vpat-acr
- **Unblocks:** —
- **Files to modify:**
  - `docs/ACCESSIBILITY.md`
  - `app/static/style.css`
  - `app/static/app.js`

**Spec (human-editable):**
WCAG 2.2 (W3C Recommendation, October 2023) is not yet the binding standard under 28 CFR 35.200 or 45 CFR 84.84, but DOJ and HHS have signaled they will likely uplift in a future rulemaking. Net-new WCAG 2.2 AA criteria worth tracking now: **2.4.11 Focus Not Obscured (Minimum)**, **2.4.12 Focus Not Obscured (Enhanced)** (AAA), **2.4.13 Focus Appearance** (AAA), **2.5.7 Dragging Movements**, **2.5.8 Target Size (Minimum)**, **3.2.6 Consistent Help**, **3.3.7 Redundant Entry**, **3.3.8 Accessible Authentication (Minimum)**, **3.3.9 Accessible Authentication (Enhanced)** (AAA).

Definition of Done:
- [ ] `docs/ACCESSIBILITY.md` gains a "WCAG 2.2 readiness" appendix mapping each net-new criterion to MakerFlow's current state
- [ ] Where conformance gaps exist, file `-followup` task cards in §6 to address them
- [ ] `P2-a11y-vpat-acr` ACR template gains a 2.2 column (Not Evaluated where not assessed, populated as readiness work lands)

**Notes:**
This is a tracking task, not an implementation task. Don't claim 2.2 conformance in the ACR until the screen-reader pass has retested.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

### P3-a11y-coordinator-config — Per-org ADA coordinator + grievance procedure

- **Status:** [ ] backlog
- **Agent Persona:** backend-monolith
- **Priority:** P3
- **Complexity:** S
- **Dependencies:** P0-a11y-statement-page
- **Unblocks:** —
- **Files to modify:**
  - `app/server.py` (`accessibility_settings` table; `/settings/accessibility` route; pull-through to `/accessibility`)
  - `app/static/app.js`
  - `docs/ACCESSIBILITY.md`

**Spec (human-editable):**
28 CFR 35.107 requires public entities with 50+ employees to designate an ADA Coordinator and publish a grievance procedure. MakerFlow should let each deploying organization configure these so the `/accessibility` page displays correct, locally-binding contact details.

Definition of Done:
- [ ] New table `accessibility_settings(organization_id PRIMARY KEY, coordinator_name, coordinator_email, coordinator_phone, grievance_url, last_reviewed_at, known_limitations_md)`
- [ ] `/settings/accessibility` (workspace_admin+) edits the row
- [ ] `/accessibility` reads from this row for the active org (falling back to a sensible "Contact your administrator" placeholder if unset)
- [ ] Audit-logged on change
- [ ] Axe + manual screen-reader pass

**Notes:**
Last in the dependency chain — depends on `/accessibility` existing and the org switching mechanic being stable.

**Agent Decisions (append-only, verbose):**
_(empty)_

---

## 7. Checkpoint log

Append-only. One line per completed-or-deferred task, in execution order. The execution prompt writes here automatically.

- `2026-05-21` — `P0-onboarding-docs` — Shipped README, ProductSpec, 8 SVG diagrams. Seeded the doc system.
- `2026-05-21` — `P0-roadmap-bootstrap` — Created this roadmap with regen + execute prompts, schema, 22 seeded task cards across P0/P1/P2/P3, and checkpoint log.
- `2026-05-21` — `ada-504-program-seed` — Added ADA Title II (28 CFR Part 35 Subpart H) + Section 504 (45 CFR Part 84 Subpart I) accessibility compliance program. Regulatory context block + 23 seeded WCAG 2.1 AA task cards (2 P0 · 12 P1 · 7 P2 · 2 P3). Updated regen + execute prompts to require a11y conformance on UI work.

---

_Last updated: 2026-05-21. Next regeneration recommended after the first 3 tasks complete or whenever a major audit lands. Active compliance deadlines for adopters: ADA Title II § 35.200 (Apr 26 2027 / Apr 26 2028); HHS § 504 § 84.84 (May 11 2027 / May 10 2028)._

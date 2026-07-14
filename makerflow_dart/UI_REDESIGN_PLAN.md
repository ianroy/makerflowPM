# UI_REDESIGN_PLAN.md — a monday.com-style front end for MakerFlow PM

> **What this is:** the planning document for restyling + restructuring the Flutter app
> (`makerflow_flutter` + `makerflow_design`) to look and feel like **monday.com Work OS**.
> Researched 2026-07-14 against monday's open-source **Vibe design system**
> (vibe.monday.com · github.com/mondaycom/vibe — their real token source) plus product/support
> docs, so the values below are exact, not approximations. **Planning stage only — the build
> phases (UI-0 … UI-10) come next.**
>
> Companions: [`NEXTSTEPS.md`](NEXTSTEPS.md) (where this slots into the roadmap) ·
> [`../FLUTTER_REBUILD_PLAN.md`](../FLUTTER_REBUILD_PLAN.md) (canonical backlog) ·
> [`BUILD_STATUS.md`](BUILD_STATUS.md) (what exists today).

---

## 1. Approach: reskin + structural upgrade, not a rewrite

Everything under the UI keeps working as-is — repositories, Riverpod providers, the generated
client, RBAC, tests. What changes:

1. **`makerflow_design` is replaced wholesale** with a Vibe-derived token set + component kit
   (the current dark-navy "MakerFlow" look retires; it can live on as the dark theme's base).
2. **The app shell is rebuilt** to monday's anatomy (grey frame, left sidebar, top bar, white
   rounded content sheet).
3. **The task surface is rebuilt around monday's signature Main Table view** (grouped, colored,
   inline-editable), with the existing kanban restyled and a calendar view added.
4. Screens keep their repository seams, so in-memory demo mode and `MAKERFLOW_LIVE` both keep
   working; widget tests evolve with each phase.

---

## 2. What monday.com actually looks like (research summary)

### 2.1 Page anatomy
- **App frame:** everything sits on a light grey frame (`#ECEFF8` family); the working area is a
  **white content sheet with a rounded top-left corner (~8px)** set into that frame. Dark mode
  swaps the frame to a navy family (`#181B34` / `#292F4C`).
- **Left sidebar** (~255px, fixed width, collapsible via a circular chevron on its edge):
  **Home**, **My Work**, a collapsible **Favorites** section, then a **Workspaces** block — a
  workspace switcher (colored rounded-square tile with the workspace initial), search/filter, a
  blue **“+ Add”** button, and the boards tree (folders → boards/dashboards/docs, hover ⋯ menus).
  Selected row = light-blue `#CCE5FF` rounded-4px highlight.
- **Top bar** (~48px, on the grey frame): product wordmark left; right cluster = notifications
  bell (red count badge), inbox/update feed, invite, **search** (opens a "Search Everything"
  overlay), help, product switcher, profile avatar (menu: profile, **theme switcher**, admin,
  trash/archive, log out).
- **Board header** (3 stacked rows on the white sheet):
  1. **Title row** — board name (Poppins ~24px, inline-editable, favorite ⭐ on hover) · right:
     last-seen avatar stack, **Integrate** + **Automate** buttons, **Invite**, ⋯ board menu.
  2. **View tabs** — “Main table” first, then Kanban / Calendar / etc.; active tab = blue text +
     blue underline; “+” adds a view.
  3. **Toolbar** — blue **New item** split button · Search · Person · Filter · Sort · Hide ·
     Group by · ⋯. The header is sticky and collapses on scroll.

### 2.2 The design tokens (Vibe — exact values)
| Token | Value |
|---|---|
| Primary blue / hover / selected / highlight | `#0073EA` / `#0060B9` / `#CCE5FF` / `#F0F7FF` |
| Text primary / secondary | `#323338` / `#676879` |
| Surfaces: white / canvas grey / app frame / ui grey / disabled | `#FFFFFF` / `#F6F7FB` / `#ECEFF8` / `#E7E9EF` / `#ECEDF5` |
| Borders: controls / table grid | `#C3C6D4` / `#D0D4E4` |
| Status: done / working / stuck / blank | `#00C875` / `#FDAB3D` / `#DF2F4A` (legacy in-product `#E2445C`) / `#C4C4C4` |
| Semantic: positive / negative / warning / link | `#00854D` / `#D83A52` / `#FFCB00` / `#1F76C2` |
| Dark theme | bg `#181B34`, surface `#30324E`, text `#D5D8DF`/`#9699A6`, same blue |
| Fonts | **Figtree** (body; text2 = 14/20 is the default UI size) + **Poppins** (H1–H3 titles). Both OFL-licensed → bundleable. |
| Radius | 4px (buttons/inputs/cells/chips) · 8px (cards/popovers) · 16px (modals/widgets) |
| Spacing | 2, 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80 |
| Shadows | xs `0 4px 6px -4px rgba(0,0,0,.1)` · sm `0 4px 8px rgba(0,0,0,.2)` · md `0 6px 20px rgba(0,0,0,.2)` (popovers) · lg `0 15px 50px rgba(0,0,0,.3)` (modals) |
| Motion | productive 70/100/150ms, expressive 250/400ms; enter `cubic-bezier(0,0,0.35,1)`, emphasize `cubic-bezier(0,0,0.2,1.4)` (the popover "pop") |
| Focus (keyboard only) | 3px halo `hsla(209,100%,50%,.5)` + 1px inset `#0060B9` ring |
| Buttons | Primary (blue filled) / Secondary (outlined `#C3C6D4`) / Tertiary (text); heights 32/40/48; radius 4; press = scale(.95) @70ms |
| Icons | 20×20 single-color line style (`currentColor`), rendered 16–24px |
| Skeletons | `#E7E9EF`, radius 4, **opacity pulse .4→1, 0.8s alternate** (not shimmer) |
| Label palette | 40 named colors for statuses/groups (grass-green `#037F4C`, bright-blue `#579BFC`, purple `#9D50DD`, indigo `#5559DF`, lipstick `#FF5AC4`, …) — the picker grid |

### 2.3 The signature components (what makes it *feel* like monday)
1. **Main Table:** colored **groups** — group title rendered *in the group's color* (~18px),
   collapsible, and a **4–6px colored bar down the left edge of every row**; white rows ~36px
   tall on `#D0D4E4` gridlines; sticky first column (checkbox on hover + item name + "Open" +
   💬 chat icon); **inline editing everywhere** (no page navigation); a ghost **“+ Add item”**
   row per group (Enter = create + keep typing); **column summaries** under each group — most
   importantly the **status “battery”**: a stacked horizontal bar of the group's status mix in
   exact label colors (hover → label/count/%).
2. **Status cells & picker:** in the table the status is a **full-bleed colored cell** with
   centered white 14px text; on cards it's a small radius-4 pill. Clicking opens a popover
   (white, r8, shadow-md, ~150ms pop) with full-width colored label buttons + **“Edit Labels”**
   (rename, recolor from the 40-color grid, add up to 40, mark which labels “count as done”).
3. **Bulk actions:** row checkboxes → a **floating bottom-center bar** (big blue count +
   Duplicate / Export / Archive / Delete / Move) · toasts slide in bottom-left with **Undo**.
4. **Item card:** right **slide-in panel** (~40–50% width, expandable) — header (name,
   breadcrumb, expand/copy-link/close) + tabs: **Updates** (rich-text composer; threaded,
   avatar + timestamp + like/reply + “seen by”) / **Files** / **Activity Log** (old value → new
   value chips, filterable). Column values editable in the panel with the same popovers.
5. **Kanban:** columns from the status labels (colored header strip + count), white r8 cards
   with configurable “card columns” (avatars, date, priority) and optional cover images.
6. **Calendar:** month/week/day; items as compact colored pills (group color by default);
   drag a pill to reschedule; weekend toggle.
7. **Dashboards:** widget grid on the grey canvas — Numbers (big KPI), Chart (status-colored
   pies/bars), **Battery** (overall progress bar), Timeline, Workload, …the llama farm.
8. **Feel-makers:** 🎉 **confetti when something is set to Done**; skeleton loading; friendly
   empty states with a blue CTA; pervasive hover-reveal (drag handles, checkboxes, ⋯ menus);
   deadline mode (date turns green+✓ when done, red+! when overdue).

### 2.4 monday's own accessibility rules (they align with our mandate)
Vibe documents: text ≥ 4.5:1 contrast (3:1 for large), non-text UI ≥ 3:1, focus visible on
everything interactive, keyboard equivalents for all mouse interactions, and — notably —
**status colors belong on the board only, nowhere else in the chrome**. The colored label always
carries its **text inside it** (white 14px on the label color), which is the non-color cue.

---

## 3. Mapping monday → MakerFlow

| monday concept | MakerFlow today | Plan |
|---|---|---|
| Workspace | Organization (`org.listMine`, switcher exists) | Workspace switcher tile in the sidebar = org switcher |
| Board | The Tasks screen (+ project filter) | **Tasks becomes “the board.”** Sidebar boards tree lists: All Tasks + one board per Project, plus the ops screens (Equipment, Consumables, Meetings…) as boards. Later: `CustomView` model (already authored) = saved views |
| Group (colored section) | Task status / project lane | Default grouping = status (labels below); “Group by” toolbar control can switch to project/priority later |
| Item | Task | 1:1 |
| Status labels + colors | `TaskStatus` enum + `StatusBadge` | Fixed label set at first (Backlog `#579BFC` · To do `#C4C4C4`→gray · In progress `#FDAB3D` · In review `#9D50DD` · Blocked `#E2445C` · Done `#00C875`). Custom labels later via `FieldConfig` (model authored) |
| Person column | — (assignee not plumbed to the UI) | Needs `assigneeUserInfoId` surfaced through TaskVm + a members lookup (OrgEndpoint.members exists) |
| Date column + deadline mode | — (`dueAt` exists in the model, not the VM) | Plumb `dueAt` (also unblocks Calendar = old M1.3b) |
| Updates tab | `CollabEndpoint` (comments, watch, activityStream) — **server done, no UI** | The item card's Updates tab is the CollabEndpoint UI (this was already M2.2) |
| Activity Log | `AuditLog` (every mutation audited) | Read endpoint + the Activity tab |
| My Work | — | New endpoint: my assigned tasks across the org, grouped by date bucket |
| Dashboards | `InsightSnapshot`/`ReportTemplate` models (authored) | Widget grid = the reports surface (M-EXP #10) |
| Automate/Integrate buttons | FutureCall infra (planned) | Buttons present but stubbed until M-EXP #4 (maintenance sweeps) — honest “coming soon” |
| Confetti on Done | — | Yes. Obviously. (With a reduced-motion opt-out.) |

---

## 4. Constraints & standing decisions

- **WCAG 2.1 AA stays non-negotiable.** monday's pattern language is compatible: label text
  inside colored cells (non-color cue), documented contrast floors, keyboard-only focus rings.
  We **keep** our two hard-won a11y assets: the keyboard kanban-move pattern and dialog
  live-region announcements — they get restyled, not removed. Every phase below lists its a11y
  acceptance items; hover-only affordances always get a keyboard/AT-visible equivalent.
- **Light theme becomes the default** (monday is light-first); the existing dark-navy look is
  reborn as the dark theme using Vibe's dark tokens. Theme switcher moves to the avatar menu.
- **Fonts:** bundle Figtree + Poppins (both SIL OFL — license-compatible; replaces the never-
  bundled Avenir Next plan).
- **Repository/provider architecture is untouched** — this is a presentation-layer program.
- Where monday uses color-only meaning outside labels (e.g. group edge bars), our group headers
  keep the text label + count so color is never the sole carrier (1.4.1).

---

## 5. The build-out feature list (phased, build-ready)

> Effort: S≈hours · M≈1–2d · L≈3–5d · XL≈1–2wk. Each phase ends analyze-clean + widget-tested +
> web build green (the CI now enforces this). Goldens land with UI-0 and grow per phase.

### UI-0 · Vibe-derived design system (`makerflow_design` v2) — **M** · unblocks everything
Tokens: the §2.2 table verbatim (light + dark), 40-color label palette, spacing/radius/shadow/
motion constants, focus-ring style. Fonts bundled. Core widgets: `MndButton` (3 kinds × 3
sizes, press-scale), `MndPopover` (r8, shadow-md, pop-in), `StatusLabel` (cell + pill modes) +
`StatusPickerPopover` (label grid + 40-color swatch editor stub), `MndAvatar` (photo/initials,
stack w/ +N), `MndSkeleton` (opacity pulse), `MndToast` (with Undo slot), `MndEmptyState`.
**DoD:** golden tests for every widget in both themes; focus ring visible on all; contrast
checked against the 4.5:1/3:1 floors. *(Replaces `MfCard`/old tokens; old screens keep working
through a compat shim until each is rebuilt.)*

### UI-1 · App shell: frame, sidebar, top bar — **L** · deps UI-0
Grey app frame + white rounded content sheet; left sidebar (Home, My Work stub, Favorites stub,
workspace switcher = org tile + boards tree = All Tasks / per-project boards / ops screens;
collapse toggle; `#CCE5FF` selected rows); top bar (wordmark, search stub, notifications bell
stub, avatar menu w/ theme switcher + sign out). go_router routes unchanged underneath.
**DoD:** keyboard-traversable sidebar (landmark + arrow-key tree), collapse state persists,
mobile breakpoint = drawer (existing behavior), widget tests for nav + org switch.

### UI-2 · Board chrome: header, view tabs, toolbar — **M** · deps UI-1
Three-row board header on the Tasks board: title row (board name, star stub, member avatars via
`org.members`, Invite stub, ⋯ menu), view tabs (**Main table · Kanban · Calendar**, blue
underline, reorderable later), toolbar (**New item** split button → existing dialog; Search
(client-side filter); **Person** filter (avatar popover); **Filter** (status/priority);
**Group by** (status ⇄ project); Sort; Hide stub). Sticky on scroll.
**DoD:** every toolbar control keyboard-operable + labelled; filters compose with the existing
`taskProjectFilterProvider`; tab state in the URL (`/tasks?view=table`).

### UI-3 · **Main Table view** — **XL** · deps UI-2 · *the signature — build third, ship first-class*
Grouped table: colored group headers (title in group color, chevron collapse, count, ⋯ menu),
**left-edge color bar per row**, ~36px rows on `#D0D4E4` gridlines, sticky name column (hover
checkbox + “Open” + 💬 count), columns: **Item · Person · Status · Due date · Priority**.
Inline editing: status = full-bleed colored cell → `StatusPickerPopover`; date → date-picker
popover (Today shortcut; deadline mode: green ✓ done / red ! overdue); person → member picker;
name → inline text. **“+ Add item”** ghost row per group (Enter chains). Group footer: status
**battery bar** (stacked, hover tooltips) + date range summary. Column header sort.
**Server/data prereqs (small):** TaskVm + repos gain `dueAt` + `assigneeUserInfoId` (+ fetch-
merge passthrough); `OrgEndpoint.members` already exists for the person picker.
**DoD:** table fully keyboard-navigable (arrow-key cell grid per WAI-ARIA grid pattern; every
popover reachable by Enter); screen-reader row semantics (item name + each column announced);
all edits announce via live region; widget tests: group collapse, inline status/date/person
edit, add-item chaining, battery math; goldens both themes.

### UI-4 · Selection + bulk actions + undo — **M** · deps UI-3
Row checkboxes (+group select-all, shift-range), **floating bottom bulk bar** (count ·
Duplicate · Archive → Trash · Delete · Move-to-project · X), toasts bottom-left with **Undo**
(undo = restore from trash / inverse move). While selected, a status-cell click applies to all.
**Server prereq:** none hard (loop the existing endpoints client-side first; batch endpoints
are a later perf card).
**DoD:** bulk bar keyboard/AT reachable (announced count), Undo works for archive/move, tests.

### UI-5 · Item card panel (Updates · Files · Activity) — **L** · deps UI-2, server `CollabEndpoint` (done) + a small AuditLog read endpoint
Right slide-in (~45%, expand-to-modal, Esc/return-focus), header (name inline-edit, breadcrumb,
copy link, close), field list (same pickers as the table), tabs:
**Updates** = `CollabEndpoint` comments UI (composer + threaded list + watch toggle; realtime
`activityStream` hookup can land with M2.1); **Activity** = new `AuditEndpoint.forEntity`
(old→new chips); **Files** = stub until Attachment upload (M4.3).
**DoD:** focus trap + return focus; composer labelled; new updates announced; deep link
`/tasks/:id`; tests for open/edit/comment.

### UI-6 · Kanban restyle — **M** · deps UI-0/2
Existing board re-skinned: columns = status labels (colored top strip + count), white r8 cards
(shadow-xs, hover-raise) with card columns (avatars, due date, priority pill), same drag +
**unchanged keyboard-move pattern** (Enter/arrows/Esc — already proven), “+” per column header.
**DoD:** goldens; keyboard-move regression tests keep passing; drop animates (~150ms).

### UI-7 · Calendar view — **M/L** · deps UI-3's `dueAt` plumbing *(closes old M1.3b)*
Month grid (week/day later): tasks as colored pills (status color), click → item card, **drag
to reschedule** (update `dueAt`), Today jump, weekend toggle.
**DoD:** grid keyboard-navigable (arrow keys, Enter opens), drag has a keyboard equivalent
(“move to date” in the item card), tests: render on correct day + reschedule.

### UI-8 · My Work — **M** · deps UI-3 fields · server: `TaskEndpoint.myWork`
Sidebar destination: my assigned tasks across all boards, grouped Today / This week / Next
week / Later / No date, each row = mini table row (board chip, status cell, date).
**DoD:** endpoint org-scoped + integration-tested; groups are semantic headers; tests.

### UI-9 · Dashboard: widget grid — **L** · deps UI-0 · pairs with M-EXP #10
The Home/dashboard surface on the grey canvas: **Numbers** (open tasks, overdue, low-stock
count), **Chart** (tasks by status — label colors, with a data-table equivalent for AT),
**Battery** (per-project progress), and a makerspace twist: **equipment status** + **low-stock**
widgets (our M-EXP #1 dashboard panel lands here). Static layout first; drag/resize later.
**DoD:** every chart has a text/table alternative; widgets keyboard-focusable with summaries.

### UI-10 · Micro-interactions & polish — **S–M**, sprinkled
Confetti on Done (respect `MediaQuery.disableAnimations` / reduced-motion), skeletons on every
async surface, empty states w/ blue CTA, hover-reveal with focus-visible equivalents, pervasive
motion curves, deadline-mode date coloring, sidebar/board-header collapse animations.

### Cross-cutting (every phase)
Golden tests both themes · widget tests per interaction · axe pass on the web build once CI
gains it (M3.3) · the **a11y web-spike verdict (R1) applies to all of this** — if the human AT
pass fails Flutter Web, this design system ports to the fallback unchanged in spirit.

---

## 6. Sequencing & effort summary

| Order | Phase | Effort | Server work needed |
|---|---|---|---|
| 1 | UI-0 design system | M | — |
| 2 | UI-1 app shell | L | — |
| 3 | UI-2 board chrome | M | — |
| 4 | UI-3 Main Table | XL | tiny (VM fields: dueAt, assignee) |
| 5 | UI-6 kanban restyle | M | — |
| 6 | UI-5 item card | L | small (`AuditEndpoint.forEntity`) |
| 7 | UI-4 bulk actions | M | — |
| 8 | UI-7 calendar | M/L | — (rides UI-3 fields) |
| 9 | UI-8 My Work | M | small (`myWork` query) |
| 10 | UI-9 dashboard | L | reads existing data |
| 11 | UI-10 polish | S–M | — |

≈ 4–6 focused weeks single-dev for UI-0→UI-7 (the “it looks like monday” bar); UI-8→10 rounds
out the “it works like monday” bar. M1.5 (agenda/intake/partnership screens) should land **on**
the new system (build them as boards after UI-3) rather than being styled twice.

## 7. Open decisions (answer before/while building UI-0)

1. **Board = project?** Plan assumes: sidebar shows *All Tasks* + per-project boards + ops
   screens as boards. Alternative: one board, project = a column. (Default: as planned.)
2. **Custom status labels now or later?** Later (fixed set mapped to `TaskStatus`; the
   `FieldConfig` model is ready when wanted). Editing label *colors* could come sooner.
3. **Keep the llama farm?** …a MakerFlow twist (3D-printer farm?) is available as a delight
   widget in UI-9. Optional.
4. **Confetti default-on?** Plan says yes with reduced-motion opt-out (monday.labs lets users
   disable; we'd mirror in Settings later).

---

*Research sources: Vibe design-system source (`packages/style/src/themes/*.scss`,
`typography/border-radius/spacing/motion.scss`, `Button/Label/Skeleton.module.scss`,
`@vibe/icons`), vibe.monday.com docs (foundations: colors/typography/shadow/spacing/
accessibility), brand-monday.com/typography, monday.com support center (Status Column, Groups,
Columns, Batch Actions, Item Card, Updates, Activity Log, Kanban/Calendar views, Deadline Mode,
Battery/Calendar/Llama-Farm widgets), 2024–2026 product-update writeups. Pixel-level values not
published by monday (row ≈36px, sidebar ≈255px, edge bar 4–6px) are observational — verify
against the Vibe UI Kit Figma before hard-coding.*

*Written 2026-07-14. Next step: build UI-0.*

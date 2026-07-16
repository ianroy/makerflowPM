# Flutter Web Accessibility Spike — Report (`fl-0-a11y-web-spike`)

> **Purpose.** Decide whether **Flutter Web** can meet **WCAG 2.1 Level AA** for MakerFlow's compliance-critical surfaces, or whether the web target needs a **server-rendered fallback** (see [`../../../FLUTTER_REBUILD_PLAN.md` §8](../../../FLUTTER_REBUILD_PLAN.md) and Risk R1). This is the **Phase-0 gate** — the web target is not declared parity-capable until this resolves.
>
> **Status: BLOCKED on a human assistive-technology pass.** The test fixture is built ([`makerflow_flutter/lib/src/features/_spike/a11y_spike_screen.dart`](../../makerflow_flutter/lib/src/features/_spike/a11y_spike_screen.dart), route `/spike`). The empirical results below must be filled by a person running real screen readers — they cannot be produced in a headless/no-toolchain environment.

---

## How to run this spike

```bash
cd makerflow_dart && melos bootstrap
cd makerflow_flutter
flutter run -d chrome --web-renderer canvaskit   # then also test --web-renderer html
# navigate to /spike
```

Test the four surfaces on the fixture with **each** of the environments below. For Flutter Web specifically, also compare the **CanvasKit** vs **HTML/semantics** renderer — they differ materially for AT.

## Environment matrix (fill in)

| Environment | Version | Renderer | Tester | Date |
|---|---|---|---|---|
| NVDA + Firefox (Windows) | | canvaskit / html | | |
| VoiceOver + Safari (macOS) | | canvaskit / html | | |
| VoiceOver + Safari (iOS) | | — | | |
| Keyboard-only (no AT) | n/a | canvaskit / html | | |
| Chrome + axe DevTools | | canvaskit / html | | |

## Results — WCAG 2.1 AA criteria × surface

Mark **P** (pass) / **~** (partial) / **F** (fail) / **n/a**, with an evidence note. Surfaces: **Form**, **Kanban** (keyboard move), **Modal**, **Table**.

| SC | Criterion | Form | Kanban | Modal | Table | Evidence / notes |
|---|---|:--:|:--:|:--:|:--:|---|
| 1.1.1 | Non-text content | | | | | |
| 1.3.1 | Info & relationships | | | | | header/role mapping in the semantics tree |
| 1.3.5 | Identify input purpose | | n/a | | n/a | autofill hints surfaced? |
| 1.4.1 | Use of color | | | | | status conveyed without color |
| 1.4.3 | Contrast (minimum) | | | | | both themes |
| 1.4.10 | Reflow (320px) | | | | | **Flutter Web weak spot** |
| 1.4.11 | Non-text contrast | | | | | focus ring, borders |
| 2.1.1 | Keyboard | | | | | all ops without a pointer |
| 2.1.2 | No keyboard trap | n/a | n/a | | n/a | can Tab/Esc out of the modal |
| 2.4.3 | Focus order | | | | | logical; modal returns focus to launcher |
| 2.4.7 | Focus visible | | | | | **default web focus often invisible** |
| 2.5.1 | Pointer gestures | n/a | | n/a | n/a | keyboard alt to drag works |
| 3.3.1 | Error identification | | n/a | | n/a | error text + announce |
| 3.3.2 | Labels / instructions | | n/a | | n/a | |
| 4.1.2 | Name, role, value | | | | | custom widgets expose role/state |
| 4.1.3 | Status messages | | | | n/a | `SemanticsService.announce` heard? |

## Findings

_(Per surface: what worked, what failed, severity, and whether a Flutter-side fix exists.)_

- **Form:** …
- **Kanban (keyboard move + live region):** …
- **Modal (focus trap + return):** …
- **Table:** …
- **Renderer comparison (CanvasKit vs HTML):** …
- **Reflow / 200% zoom:** …

## Decision (the deliverable)

Choose one and give the rationale:

- [ ] **(a) Flutter Web is sufficient.** All compliance-critical criteria reach AA (or have a tracked, achievable Flutter-side fix). Proceed with Flutter Web as the web target. File follow-up cards for any partials.
- [ ] **(b) Server-rendered web fallback required.** One or more AA criteria cannot be met on Flutter Web with reasonable effort. Flutter owns mobile/desktop; the web target ships as a server-rendered view (the existing Python app or a small server-rendered Dart view). **File follow-up card `fl-0-web-fallback`** and update §8 / Risk R1.

**Rationale:** …

**Decided by:** ______  **Date:** ______

---

_Generated as the instrument for `fl-0-a11y-web-spike`. The fixture and this template were authored by the execution loop; the empirical pass + decision are the human contribution that closes the card._

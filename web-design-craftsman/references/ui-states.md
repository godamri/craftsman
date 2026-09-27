# UI State Architecture & Edge Case Matrix

A production interface is defined by how it behaves when conditions are imperfect. This reference provides the state specifications, consequence-proportional recovery patterns, and boundary handling required by `web-design-craftsman`.

---

## 1. The Core State Lifecycle

Every dynamic component or data-driven surface must account for these seven lifecycle states:

```text
[ INITIALIZING / IDLE ]
         ↓
    [ LOADING ] ──(Failure)──→ [ ERROR / RECOVERY ]
         ↓ (Success)
  [ DATA EVALUATION ]
     ├── Empty? ─────────────→ [ EMPTY / ONBOARDING ]
     ├── Partial / Degraded? ──→ [ PARTIAL / DEGRADED ]
     └── Populated? ─────────→ [ POPULATED / DEFAULT ]
                                     ↓
                          [ INTERACTIVE STATES ]
                          (Hover, Focus, Active, Selected, Disabled)
```

---

## 2. State Specification Matrix

| State | Purpose & User Need | Visual Treatment | Interaction & Invariants |
| :--- | :--- | :--- | :--- |
| **Default / Populated** | Nominal operating baseline. | Clear hierarchy, balanced contrast, distinct surfaces. | Full keyboard and pointer operability. |
| **Hover** (Pointer only) | Affordance confirmation before click. | Subtle surface tint, border highlight, or elevation shift. | Never reveal critical actions on hover alone. Never apply to touch viewports. |
| **Focus-Visible** | Spatial orientation for keyboard users. | High-contrast visible outline with appropriate offset. | Invariant: Never suppress with `outline: none` without providing an equal or superior visible ring. |
| **Active / Pressed** | Immediate physical confirmation of input receipt. | Subtle downward translation or tactile surface shift. | Latency under 50ms. Must feel responsive. |
| **Selected** | Indicates active choice among alternatives. | Clear border or surface accent + semantic checkmark/icon. | Must use `aria-selected="true"` or `aria-checked="true"`. |
| **Disabled** | Action unavailable in current context. | Reduced contrast/opacity, muted cursor (`not-allowed`). | Invariant: When the reason for a disabled state is not already obvious, communicate the reason through an accessible inline explanation, label, helper text, or other appropriate mechanism. Avoid tooltip-by-default behavior. |
| **Loading (Initial)** | Communicates progress during full page mount. | Content-shaped skeletons matching target layout. | Never use a single generic full-screen spinner if skeletons can prevent layout shifts. |
| **Loading (Inline)** | Background data fetch or form submission. | Inline spinner or button progress indicator; disable re-submission. | Maintain button dimensions during loading to prevent layout reflow. |
| **Empty** | Zero items in dataset (first run or filtered). | Clear explanation of the condition and an appropriate next action when one exists. | Invariant: Never leave an uncommunicative blank space. Illustration or iconography is optional and should only be used when it improves comprehension, orientation, or product character; avoid decorative illustrations that add visual noise. |
| **Error (Component)** | Local failure (e.g., query failed, card error). | Inline error card with semantic accent, plain-language cause, "Retry" button. | Isolate blast radius: one failing widget must not crash the entire view. |
| **Error (Input)** | Validation failure on form field. | High-contrast visual indicator, error message linked via `aria-describedby`. | Invariant: Message must explain how to fix the input, not just state that it is invalid. |
| **Partial / Degraded** | Stale cache or missing auxiliary service. | Ambient warning banner ("Viewing cached data"), non-intrusive. | Allow core local operations to continue. |
| **Permission Denied** | User lacks authorization for this view. | Clear explanation of required role + contact admin CTA. | Do not display raw HTTP stack traces. |

---

## 3. Destructive Action & Proportional Confirmation Mechanics

Calibrate friction directly to the **consequence and reversibility** of the action to avoid confirmation fatigue:

```text
┌───────────────────────────────┬─────────────────────────────────────────────────────────────┐
│ Consequence & Reversibility   │ Appropriate Confirmation Mechanism                         │
├───────────────────────────────┼─────────────────────────────────────────────────────────────┤
│ Low Consequence + Reversible  │ Direct action execution + non-blocking undo toast/action.   │
│ (e.g., archiving an item,     │ Friction: Zero prior dialogs. Immediate recovery path.      │
│  removing a tag)              │                                                             │
├───────────────────────────────┼─────────────────────────────────────────────────────────────┤
│ Moderate Consequence          │ Proportional confirmation (e.g., inline prompt or popover:  │
│ (e.g., leaving unsaved form,  │ "Discard draft? [Keep Editing] [Discard]").                 │
│  resetting filter settings)   │ Friction: Single lightweight confirmation step.             │
├───────────────────────────────┼─────────────────────────────────────────────────────────────┤
│ High Consequence /            │ Strong confirmation: Modal dialog requiring explicit intent │
│ Irreversible                  │ (e.g., typing resource identifier, explicit checkbox).      │
│ (e.g., deleting a database,   │ Invariant: Default keyboard focus must land on CANCEL,      │
│  revoking root credentials)   │ never the destructive action.                               │
└───────────────────────────────┴─────────────────────────────────────────────────────────────┘
```

---

## 4. Content Stress Boundaries

Every interface container must be engineered to withstand real-world content extremes:

```text
┌──────────────────────────┬─────────────────────────────────────────────────────────────────┐
│ Stress Condition         │ Mandatory Handling Pattern                                      │
├──────────────────────────┼─────────────────────────────────────────────────────────────────┤
│ Unusually Long Title     │ Natural wrap to 2–3 lines with proportional line-height.        │
│                          │ Never truncate titles with ellipsis unless in fixed table cells.│
│ Long Identifier / String │ `break-words` or middle-truncation where appropriate.           │
│ Missing Avatar / Media   │ Graceful fallback to initials or structured neutral placeholder.│
│ Extreme Numeric Values   │ Formatted metric display with appropriate precision scaling.   │
│ Missing Description Text │ Hide container cleanly without leaving orphan spacing or borders│
│ Text Expansion / Loc     │ Stress-test with plausible long localized strings without       │
│                          │ clipping, overflow, or broken touch targets.                    │
│ Ultra-wide Viewport      │ Max container constraint centered; background extends cleanly.  │
└──────────────────────────┴─────────────────────────────────────────────────────────────────┘
```

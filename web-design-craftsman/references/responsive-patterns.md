# Responsive Re-Composition & Viewport Engineering

Mobile design is an ergonomic and informational re-composition, not merely desktop with fewer columns. This reference details the architectural mechanics of responsive design required by `web-design-craftsman`.

---

## 1. The Seven Responsive Transformations in Practice

When translating an interface from wide canvas to constrained mobile viewport, apply these explicit structural patterns:

```text
┌─────────────────┬──────────────────────────────────┬────────────────────────────────────────────────────────┐
│ Transformation  │ Desktop Representation           │ Mobile Re-Composition                                 │
├─────────────────┼──────────────────────────────────┼────────────────────────────────────────────────────────┤
│ 1. Move         │ Top-right action button in nav   │ Fixed bottom thumb-bar (`sticky bottom-0`)              │
│ 2. Collapse     │ Multi-column feature matrix      │ Single accordion or progressive disclosure summary     │
│ 3. Disappear    │ Decorative ambient illustrations │ Suppressed entirely (`hidden md:block`)                │
│ 4. Scroll       │ Wide data table                  │ Horizontally scrollable container with edge fade/bar   │
│ 5. Stack        │ Side-by-side text and artifact   │ Vertical sequence: Headline → Artifact → Supporting copy│
│ 6. Re-order     │ Left sidebar filters + right list│ Filters collapsed into accessible sheet; list elevated │
│ 7. Persist      │ Breadcrumbs and metadata panel   │ Compact sticky sub-header with current context          │
└─────────────────┴──────────────────────────────────┴────────────────────────────────────────────────────────┘
```

---

## 2. Viewport Stress-Testing Matrix

Every responsive layout must be verified across these representative viewports:

| Viewport Width | Device Archetype | Primary Stress Vulnerability | Mandatory Verification Check |
| :--- | :--- | :--- | :--- |
| **320px** | Small phone (SE / Mini) | Text clipping, button overflow, horizontal page blowout | Zero unintended horizontal page scroll; labels wrap gracefully. |
| **375px–390px** | Standard modern smartphone | Hit target collisions, unreadable small text | Adequate hit targets (~44×44px baseline); font sizes ≥16px on inputs. |
| **768px** | Tablet Portrait | Awkward wide single columns or cramped 2-columns | Content measure constrained (`max-w-prose`); nav adapts cleanly. |
| **1024px** | Tablet Landscape / Small Laptop | Collapsing sidebars, overlapping fixed headers | Full desktop layout or clean drawer transition without glitches. |
| **1440px** | Standard Desktop Display | Over-expanded whitespace, distant CTA anchors | Container max-width bounded (`max-w-6xl` or `max-w-7xl`); centered. |
| **2560px+** | 4K / Ultrawide Monitors | Orphaned elements, unbounded stretching | Strict container clamping; background extends, content stays bounded. |

---

## 3. Touch Ergonomics & The Mobile Thumb Zone

Human hands interact with mobile devices primarily via thumbs. Place controls according to physical reach:

```text
┌─────────────────────────┐
│     HARD TO REACH       │ ← System status, back button, read-only breadcrumbs
│      (Top 20%)          │
├─────────────────────────┤
│    NATURAL SCANNING     │ ← Primary content, readable paragraphs, media, charts
│      (Middle 50%)       │
├─────────────────────────┤
│      EASY TO REACH      │ ← Primary interactive CTAs, tabs, bottom action bar,
│      (Bottom 30%)       │   form submission buttons (Natural Thumb Zone)
└─────────────────────────┘
```

### Mobile Touch & Ergonomic Baselines
1. **Adequate Hit Target Area**: Interactive controls should provide an adequately sized hit target, with ~44×44 CSS px as a practical accessibility baseline and larger targets where appropriate. Visual dimensions may differ when the effective interactive area remains usable and does not create accidental activation.
2. **Target Clearance**: Provide adequate physical clearance between adjacent interactive elements to prevent accidental activation.
3. **Prevent Viewport Auto-Zoom**: Set form input font sizes to at least `16px` (or `1rem`) on mobile viewports to prevent browsers (e.g., iOS Safari) from automatically zooming in upon focus.
4. **Virtual Keyboard Clearance**: Fixed bottom bars must use `position: sticky` rather than `position: fixed` when inputs are focused, or utilize `interactive-widget=resizes-content` to prevent inputs from being obscured by on-screen keyboards.

---

## 4. Scroll Containment: Root vs. Component

A critical distinction must be maintained between forbidden root-level overflow and approved component-level scrolling:

* **FORBIDDEN (Hard Constraint Violation)**: Root-level unintended horizontal overflow. Verify the rendered document and actual scrollable bounds; accidental viewport blowout indicates a defective responsive implementation.
* **APPROVED (Component-Level Scroll)**: A bounded sub-container (such as a wide data table, code snippet block, tab list, or timeline) with explicit `overflow-x: auto` and clear visual scroll indicators or edge fade.

---
name: web-design-craftsman
description: >-
  Practical web and interface design guidance focused on content-first architecture,
  contextual information density, adaptive design systems, accessibility invariants,
  purposeful interaction, and defense against generic AI-generated aesthetics.
license: MIT
---

# Web Design Craftsman: Disciplined Interface Engineering

## Preamble & Supreme Design Axioms

> **An interface is not a canvas for decoration; it is an instrument of communication, comprehension, and human action.**  
> **Beauty is the result of structural clarity, hierarchy, proportion, typography, interaction, and product-specific character—not decorative surplus.**  
> **Usability vetoes aesthetics. Content precedes visual polish. Distinctiveness requires authentic product character.**  
> **A craftsman understands why design rules exist, obeys them by default to guarantee coherence, and violates them deliberately only when context, evidence, and human utility demand it.**  
> **Light by default. Dark by evidence. Never by fashion. Always derive before decorate.**

### Supreme Verification Principle: Rendered Reality > Source Confidence

> **A correct source file does not prove a correct interface.**  
> **A beautiful screenshot does not prove a usable interface.**  
> **A passing build does not prove a correct interaction.**  

Verification must progress through the complete operational reality:
```text
SOURCE → RENDER → INTERACTION → EDGE CASES → MOBILE → ACCESSIBILITY → REAL CONTENT
```

* Beautiful screenshot + broken keyboard navigation → **FAIL**
* Desktop-perfect + broken 320px mobile layout → **FAIL**
* Technically clean + generic template-like result → **ITERATE**
* Strong design + fabricated product claim → **FAIL**
* Correct source + broken runtime state → **FAIL**

---

## 1. The Four-Tier Rule Hierarchy

To prevent dogmatic rigidity while maintaining uncompromising standards, every rule belongs to one of four explicit tiers:

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│ 1. HARD CONSTRAINT                                                          │
│    Invariants that must not be broken. Any violation means not ready.       │
├─────────────────────────────────────────────────────────────────────────────┤
│ 2. PRINCIPLE                                                                │
│    Universal design truths that govern judgment across all contexts.        │
├─────────────────────────────────────────────────────────────────────────────┤
│ 3. DEFAULT                                                                  │
│    Disciplined starting patterns. Overridden ONLY via:                      │
│    Principle → Default → Contextual Exception → Validation.                 │
├─────────────────────────────────────────────────────────────────────────────┤
│ 4. HEURISTIC                                                                │
│    Adversarial diagnostic probes used to audit and challenge solutions.     │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Tier 1: Hard Constraints (Non-Negotiable Invariants)
Violating a Hard Constraint invalidates the implementation:
1. **Never break keyboard accessibility**: Every interactive element must be reachable, operable, and visibly indicated via keyboard focus.
2. **Never fabricate evidence or claims**: No invented logos, fake testimonials, synthetic vanity metrics, or simulated capabilities.
3. **Never hide critical functionality behind ambiguous interaction**: Core tasks must not require guessing, hover-only disclosures, or mystery-meat navigation.
4. **Never deliver unusable responsive layouts**: Root-level unintended horizontal overflow is prohibited (verify the rendered document and actual scrollable bounds; component-level horizontal scroll may be intentional for tables, code, tabs, timelines, or dense content). No clipped text, unscrollable modals, or unusable hit targets.
5. **Never sacrifice legibility for style**: Text contrast must never fall below WCAG 2.1 AA standards (minimum 4.5:1 for normal text, 3:1 for large text and UI components).
6. **Never misrepresent product capabilities**: Do not display UI controls, speeds, or features that the underlying system does not possess.
7. **Never trap the user**: Every modal, drawer, or overlay must provide an immediate, unambiguous exit mechanism (ESC key, visible close affordance, tap outside).
8. **Never ignore non-essential motion preferences**: Every non-essential transition must respect `@media (prefers-reduced-motion: reduce)`.

### Tier 2: Principles (Governing Design Truths)
1. **Hierarchy reflects user priority**: The visual weight of every element must correspond strictly to its importance to the user's task.
2. **Structural order generates visual elegance**: Polish comes from alignment, rhythm, clear negative space, and disciplined proportion, not layered effects.
3. **Content precedes visual presentation**: Layout exists to serve meaning. If the copy is vague or the narrative broken, visual polish only camouflages the defect.
4. **Evidence confidence and visual presentation are separate dimensions**: A beautifully rendered claim is still unsupported if its evidence is weak. Never transform factual uncertainty into polished marketing assertions.
5. **Interaction communicates affordance and state**: Interactive controls must look clickable, tappable, or draggable before interaction, and confirm receipt during and after interaction.
6. **Visual complexity must earn its cognitive cost**: Every border, container, gradient, badge, shadow, and animation imposes cognitive load. If it does not clarify structure or state, remove it.
7. **Usability vetoes aesthetics**: If a visual treatment degrades reading speed, causes click ambiguity, or disorients navigation, aesthetics must yield immediately.

### Tier 3: Defaults (Adaptive Baselines)
Defaults provide a disciplined baseline. They must be followed unless an explicit contextual exception is documented and validated:
* **Adaptive Pattern**: `Principle` → `Default` → `Contextual Exception` → `Validation`.
* *Example*: Base type scale of 5–7 steps, 4px/8px spatial rhythm, one dominant intended user outcome per task frame, restrained palette with 1 accent hue, light-first canvas default (dark as contextual exception when justified by evidence), subtle motion under 250ms.

### Tier 4: Heuristics (Diagnostic Probes)
Heuristics do not dictate answers; they trigger hostile audits:
* *Can a visitor understand what this product actually does within 5 seconds of scanning?*
* *Does this card container actually need to exist, or is it visual clutter?*
* *Why is this element moving? What information does motion convey here?*
* *What happens to this section if all decorative styling is stripped away? Does the meaning still hold?*
* *Could this page belong to any generic startup? If yes, where did its specific character vanish?*

---

## 2. Design Reconnaissance & Existing Infrastructure

Before inventing a visual system, an agent must investigate the operational environment.

### 2.1 Brownfield Reconnaissance (Existing Projects)
Do not introduce a new design system simply because it is aesthetically cleaner. Inspect the repository:
1. **Existing Design Tokens**: Check CSS variables, Tailwind configurations, or theme files for existing colors, typography, spacing, and radius tokens.
2. **Component Library**: Inspect existing buttons, inputs, modals, and cards. Reuse existing primitives whenever adequate.
3. **CSS Architecture**: Identify the styling paradigm (Tailwind, CSS Modules, Styled Components, vanilla CSS) and conform to its patterns.
4. **Brand Assets**: Locate existing logos, icon sets, illustrations, and photography. Do not replace them with stock icons without evidence of inadequacy.
5. **Preservation Rule**: Improve interfaces by refining hierarchy, spacing, and states within the existing system before proposing structural refactors.

### 2.2 Greenfield Reconnaissance (New Projects)
When creating an interface from scratch, perform a focused domain assessment:
* **Product Category & Audience**: Is this an enterprise compliance tool, a developer CLI, an editorial publication, or a consumer marketplace?
* **Competitive Conventions**: What patterns do users in this domain already understand? (Reference conventions for principles, never as templates to clone).
* **Content Sourcing**: Identify what real data, code, or photography exists before drafting the layout.

---

## 3. Context Assessment & Information Density Archetypes

There is no universal "correct" density or whitespace. The objective is never to blindly maximize whitespace (which empties the screen) nor to blindly maximize information (which overwhelms the mind).

> **Supreme Density Objective**: Maximize useful, actionable information per unit of user attention.

Density must follow task, audience, content, and operational frequency:

| Interface Archetype | Target Density | Primary Design Driver | Whitespace Role | Visual Treatment |
| :--- | :--- | :--- | :--- | :--- |
| **Operational Dashboard** | High | Information throughput, rapid scanning, real-time status | Minimal; structural separation only | Compact tables, tight data cells, monospaced numerals, subtle borders |
| **Developer Documentation** | High | Reference retrieval, code scanning, deep technical detail | Functional; code isolation and reading measure control | Monospaced blocks, dense sidebars, sticky table of contents, high contrast |
| **Admin / Backoffice** | High | Task efficiency, bulk data manipulation, minimal scrolling | Utility; clear form and table boundaries | Dense inputs, compact buttons, zero decorative imagery, clear validation states |
| **Checkout & Transactions** | Task-Focused | Elimination of distraction, zero friction, error prevention | Isolation; channels attention down single path | Linear forms, muted navigation, high-contrast primary action, explicit security proof |
| **Editorial & Long-form** | Readable | Sustained cognitive absorption, effortless reading flow | Generous margins; strict 45–75 character line measure | Expressive typography, comfortable line-height (1.5–1.7), unobtrusive side-notes |
| **Luxury & High-Craft** | Low / Expansive | Emotional resonance, brand aura, perceived exclusivity | Expressive; frames objects as museum artifacts | Dramatic scale contrasts, expansive negative space, bespoke photography, muted palettes |
| **Portfolio & Studio** | Project-Focused | Proof of craftsmanship, visual evidence, creative identity | Framing; gives work breathing room without emptiness | Large-scale media, tactile typography, custom project pacing, zero stock elements |
| **Consumer Product Landing** | Balanced | Benefit comprehension, immediate desire, low friction | Breathing room between value propositions | Strong artifact imagery, conversational clarity, accessible interactive demos |
| **Technical SaaS / Systems** | Evidence-Focused | Architectural credibility, verification, developer trust | Structural; isolates technical evidence blocks | Interactive sandboxes, real schemas, terminal captures, verifiable benchmark charts |

---

## 4. Content & Evidence Hierarchy: Meaning Precedes Layout

Visual styling can never rescue flawed, empty, or evasive content. Treat content extraction, narrative structuring, and layout generation as a single integrated discipline:

```text
Content (Facts, Evidence, Value)
   ↓
Meaning (What does this communicate to the specific audience?)
   ↓
Hierarchy (What must be understood first, second, and third?)
   ↓
Layout (Spatial arrangement that reinforces the hierarchy)
   ↓
Visual System (Typography, color, containers, and micro-details)
```

### 4.1 The Evidence Sourcing Hierarchy & Conflict Resolution
Content must be sourced from the highest available tier of authority (see [content-evidence.md](file:///Users/godamri/.gemini/config/skills/web-design-craftsman/references/content-evidence.md)):
1. **Verified Product Data**: Actual schemas, terminal output, live API specs, measurable benchmarks.
2. **User-Provided Specifications**: Explicit requirements and architectural docs supplied by the user.
3. **Repository / Codebase Data**: Existing code, type definitions, package dependencies, and configs.
4. **Verified Technical Documentation**: Official standards (RFCs, W3C, language specifications).
5. **Attributable Customer Evidence**: Real customer quotes with verified names and confirmed case studies.
6. **Explicit Conservative Placeholders**: Clearly bracketed placeholder tokens during prototyping (`[Benchmark Data Pending]`).

#### Evidence Conflict Handling
When two sources disagree (`SOURCE A` vs `SOURCE B`):
* Mark as `[CONFLICT]`. Do not silently reconcile or invent intermediate numbers.
* Codebase and runtime benchmarks override marketing briefs for technical capabilities.
* User/product specifications override stale documentation for pricing and business scope.
* If unresolved, **do not publish the claim as fact**. Omit the claim or use conservative, verified language.

### 4.2 The Anti-Masking Rule
**Never use beautiful typography, elegant spacing, or slick cards to hide vacuous communication.**
* If a headline relies on abstract marketing buzzwords (*"revolutionize workflows"*, *"next-gen intelligence"*), reject it. Replace it with what the software actually takes as input, does as work, and returns as output.
* If a section contains a dozen vague bullet points, refuse to format them into a 3×4 grid of stock icons. Group them into concrete user problems solved, backed by verifiable evidence.
* If product narrative is incoherent, halt visual decoration and restructure the communication architecture first.

---

## 5. "Demonstrate Before Asserting": The Generalized Artifact

Claims invite skepticism; concrete artifacts compel belief.

> **Principle**: Never merely assert a capability when you can display its direct, verifiable output.

The "Artifact" is the most credible concrete representation of what the user is being asked to value:

```text
┌─────────────────────────────────┬────────────────────────────────────────────────────────┐
│ Product Domain                  │ The Concrete Artifact                                  │
├─────────────────────────────────┼────────────────────────────────────────────────────────┤
│ Developer Tool / Infrastructure │ Executable code snippet, CLI terminal run, diff, AST   │
│ SaaS / Web Application          │ High-fidelity interactive UI sandbox, real populated state │
│ Data / Analytics Platform       │ Interactive data table, live query runner, real charts │
│ Physical Hardware / Device      │ High-res macro photography, exploded render, schematics│
│ Design Studio / Agency          │ Finished production case studies, interactive work     │
│ Restaurant / Hospitality        │ Real photography of space, actual menu with pricing    │
│ Research / Scientific Tool      │ Verifiable benchmark comparison, methodology citations │
│ Editorial / Publication         │ The actual prose, readable article sample, table of contents │
└─────────────────────────────────┴────────────────────────────────────────────────────────┘
```

### Artifact Presentation Rules
1. **Default**: Present the primary artifact within the first two viewport heights. Do not force users to scroll through three screens of marketing prose before seeing the thing itself.
2. **Contextual Exception**: If the product is conceptually novel or addresses a complex mental model, an introductory problem-framing section may precede the artifact.
3. **Validation**: The artifact must depict realistic, non-trivial data. Never display empty states, placeholder text (*"Lorem ipsum"*), or unrealistic toy examples (*"Hello World"* when selling an enterprise parser).

---

## 6. The Visual Thesis: Authentic Character vs. Generic AI Slop

Every substantial website must have a **Visual Thesis**: a small set of deliberate, coherent visual decisions that make it recognizably belong to that specific product, rather than looking like an off-the-shelf template.

### 6.1 The Visual Thesis Derivation Method (The Seven-Step Evidence Chain)
Do not declare a visual thesis out of thin air. Deduce it from the evidence through this universal reasoning chain:

```text
1. Product / Domain Reality
        ↓
2. Audience Mental Model + Trust Anchor
        ↓
3. Primary Task Cadence
        ↓
4. Content Medium
        ↓
5. Visual Tension
        ↓
6. Visual Thesis
        ↓
7. Design System Derivation
```

1. **Product / Domain Reality**: What is this product actually? What physical, digital, cultural, technical, or organizational reality does it belong to? What characteristics are intrinsic rather than decorative? What constraints exist because of the domain?  
   *Rule*: The domain provides evidence; it does not dictate aesthetics. Avoid domain stereotypes (e.g., developer tool ≠ automatically dark + neon + monospace; luxury product ≠ automatically black + gold + serif; culinary product ≠ automatically cream + terracotta).
2. **Audience Mental Model + Trust Anchor**: What do users already expect, and what do they need to believe? What evidence creates trust or distrust? Are users browsing, comparing, buying, operating, reading, creating, or responding to an incident? Trust must be derived from actual context; if evidence is insufficient, mark `[UNKNOWN]`.
3. **Primary Task Cadence**: How is the interface actually used? (Sustained reading, rapid scanning, comparison, transactional checkout, repeated operational use, high-pressure response, discovery). Do not equate a domain with a single cadence.
4. **Content Medium**: Where does the product's truth primarily live? (High-resolution photography, prose, structured data, charts, executable code, product schematics, maps, transaction records). The visual system must amplify the medium carrying truth, never using decorative UI to compensate for missing evidence.
5. **Visual Tension**: Identify the competing forces the interface must reconcile (e.g., *heritage ↔ modern commerce*; *density ↔ comprehension*; *precision ↔ warmth*; *authority ↔ accessibility*; *speed ↔ reassurance*; *technical depth ↔ approachability*; *luxury ↔ transparency*; *playfulness ↔ cognitive calm*). If no meaningful tension exists, say so.
6. **Visual Thesis Formulation**: Formulate the product's distinct visual stance: what it prioritizes, what it deliberately avoids, and how its character differs from generic category defaults. A thesis must be falsifiable; avoid vague descriptors (*modern*, *premium*, *clean*, *minimal*, *bold*).
7. **Design System Derivation**: Only after the thesis exists, derive typography, spacing, surface treatment, color roles, imagery, composition, density, interaction language, and motion (`Evidence → Thesis → System`). Anchor surface architecture to a **light or neutral canvas default** unless product evidence specifically calls for a dark canvas.

### 6.2 "Style is Not Evidence"
A visual style reference, industry convention, or aesthetic trend is not evidence that the same treatment belongs to the product. Trends and references (*"Apple-like"*, *"premium"*, *"modern"*, *"AI"*, *"fintech"*, *"luxury"*, *"editorial"*) are starting signals, not design specifications. The agent must translate references into underlying principles (e.g., hierarchy, restraint, legibility) and verify those principles against the actual product before adopting any styling.

### 6.3 The Grayscale Identity Test (Diagnostic Heuristic)
Temporarily remove color from the interface (monochrome) and inspect whether hierarchy, composition, typography, imagery, and product character still communicate the intended identity.  
* *Diagnostic Principle*: If an interface loses all distinctiveness the moment color is removed, the underlying structure is generic and color is being used to disguise structural weakness. Character must be carried by typography, proportion, spatial rhythm, and content framing—not just hex codes.

### 6.4 Contextual Anti-Slop & The Purpose Matrix
> **A pattern becomes slop when its visual metaphor is not justified by the product.**

Patterns that frequently indicate unearned AI-generated design include:
* Orbiting or floating pill badges over media
* Decorative radial background glows and mesh gradients
* Excessive glassmorphism / frosted glass panels on static surfaces
* Gradient headline text without semantic lighting role
* Generic 3-card or 4-card feature grids with stock icons
* Artificial countdown timers generating synthetic scarcity
* Stock social-proof avatars with manufactured precision statistics
* Gratuitous floating 3D objects or emoji chips
* Decorative dashboard mockups without real data bindings
* Excessive pill UI crowns on headings and metadata

None of these patterns are universally forbidden. Audit all visual flourishes against the **Purpose Matrix**:

```text
What specific purpose does this visual element serve?
 │
 ├── Purpose is clear, verifiable, and context supports it
 │    └── ACTION: KEEP / REFINE (Ensure it meets accessibility and performance standards)
 │
 ├── Purpose is weak, purely decorative, or redundant
 │    └── ACTION: REMOVE (Replace with clean typography or structural whitespace)
 │
 ├── Purpose is ambiguous or unexplained
 │    └── ACTION: CHALLENGE (Question the intent; demand the underlying user requirement)
 │
 └── Purpose degrades usability, contrast, or performance
      └── ACTION: REMOVE IMMEDIATELY (Hard constraint violation)
```

> **Anti-Slop is NOT Anti-Style**: The goal is not to force every interface into a sterile monochrome grid. A brutalist magazine, a warm hand-crafted coffee roastery, an expressive developer playground, and an ultra-dense trading terminal are all valid, beautiful aesthetics. Anti-slop demands **intentionality, coherence, and concrete substance**, not corporate sterilization.

---

## 7. The Adaptive Visual System

Every visual parameter is defined through the **Principle → Default → Contextual Exception → Validation** pattern.

### 7.1 Typography
* **PRINCIPLE**: Typography creates semantic order, establishes tone, and dictates reading stamina.
* **DEFAULT**:
  * Restrained typographic scale of 5 to 7 steps (e.g., 12px caption, 14px small UI, 16px body, 20px subhead, 28px H3, 40px H2, 56px H1).
  * Constrain body text measure to 45–75 characters per line (`max-w-prose` or ~65ch).
  * Line-height: Tight for display titles (1.1–1.2), open for body text (1.5–1.65), compact for dense UI tables (1.25–1.35).
* **CONTEXTUAL EXCEPTION**:
  * Editorial or luxury showcases may employ high-contrast serif display faces at large scales (72px–120px) with custom tracking.
  * Technical developer tools may use monospaced fonts for both data display and structural metadata tags.
* **VALIDATION**:
  * Does the scale maintain unambiguous hierarchy between adjacent levels?
  * Is body text effortless to read across mobile, tablet, and desktop without manual zoom?

### 7.2 Spacing & Spatial Rhythm
* **PRINCIPLE**: Consistent spatial rhythm communicates relationship, grouping, and cognitive boundaries.
* **DEFAULT**:
  * Base rhythm on an 8px grid (4px for micro-adjustments: 4, 8, 12, 16, 24, 32, 48, 64, 96, 128px).
  * Proximity communicates relationship: Margins between related items (title and paragraph) must be noticeably smaller than margins between distinct sections.
* **CONTEXTUAL EXCEPTION**:
  * Dense data tables and compact toolbars may use 2px/4px paddings to maximize data visibility.
  * Optical corrections for asymmetric layouts or full-bleed editorial hero sections.
* **VALIDATION**:
  * The spatial deviation must resolve an optical illusion or improve hierarchical grouping. It must not be an arbitrary hand-tuned magic number.

### 7.3 Color & Surface Architecture
* **PRINCIPLE**: Color signals semantic role, action affordance, and brand identity. It must never be applied arbitrarily.
* **FUNCTIONAL COLOR ROLE TAXONOMY**:
  Categorize colors into these distinct functional roles before establishing a palette (a diagnostic taxonomy, not a requirement that every interface have seven distinct colors):
  1. **Environmental / Canvas**: Ambient field against which the interface is perceived (paper, neutral, warm, dark, photographic, data-oriented).
  2. **Structural / Surface**: Distinguishes functional regions (cards, panels, navigation, tables, separators).
  3. **Primary Action**: Reserved strictly for the dominant actionable outcome in a task frame (brand color ≠ action color).
  4. **Attention / Highlight**: Guides scanning toward important non-primary information (active filters, promotions, notable metrics, selected content).
  5. **Semantic Status**: Reserved for system meaning (success, warning, error, info); never casually repurposed for branding.
  6. **Content-Derived Accent** (optional): Colors emerging naturally from actual product content (photography, materials, chart semantics, code syntax).
  7. **Accessibility / Focus**: Clearly perceivable focus indication, never indistinguishable from decorative or semantic colors.
* **DEFAULT**:
  * **Light-First Visual Default**: Start from a light or neutral canvas unless product evidence, operational environment, content medium, brand identity, or interaction requirements provide a concrete reason for a dark canvas. Light surfaces provide broad compatibility with mixed content, natural presentation of photography, clearer structural separation, and robust baseline readability without requiring luminous or neon accents.
  * Base system: Functional separation of canvas, structural surfaces, high-contrast text, and single primary action accent.
  * Strictly separated semantic status palette: Error (red/rose), Warning (amber), Success (emerald/green), Info (blue/cyan).
* **DIAGNOSTIC HEURISTIC (Formerly 60/30/10)**:
  * Use 60/30/10 purely as a rough diagnostic heuristic for checking whether an interface is visually over-saturated. The question is: *Does the distribution support hierarchy and comprehension?*—not *Does the interface satisfy 60/30/10?*
* **CONTEXTUAL EXCEPTION**:
  * **Legitimate Dark Canvas**: Permitted when supported by concrete product evidence: sustained low-light operational environment (e.g., night trading, terminal monitoring, video editing suites), genuine display/content characteristics where dark is demonstrably superior, real brand identity evidence, or user-configurable preference. Dark mode must never be justified merely because it "looks premium", "looks modern", "looks cool", "feels dramatic", or "makes colors pop". Dark is a contextual exception, not a prohibited mode.
  * Products with multiple structural tones, near-monochrome editorial, multi-semantic data visualizers, high-color brand expressions, or photography-heavy products deriving palette from content.
* **VALIDATION**:
  * Every text/surface combination passes WCAG 2.1 AA (4.5:1 text, 3:1 graphical objects/inputs).
  * Interactive elements are identifiable by color AND at least one other visual cue (shape, border, label, or position).

### 7.4 Component Containers (Surfaces, Borders, Cards, & Radii)
* **PRINCIPLE**: Containers separate distinct functional units. They should only exist when negative space alone fails to establish clear grouping.
* **DEFAULT**:
  * Clean, flat surfaces with subtle 1px border separation or muted tonal surface shift.
  * Cohesive corner radii (4px to 8px for buttons and inputs; 8px to 12px for dialogs and cards).
  * Subtle elevation shadows simulating a single coherent downward light source.
* **CONTEXTUAL EXCEPTION**:
  * Brutalist or stark utility interfaces may use 0px sharp corners, heavy 2px borders, and hard drop-shadows.
  * Soft consumer applications may use pill shapes (9999px) for search inputs and badges.
  * Glassmorphism / backdrop-blur is permitted ONLY when functioning as a persistent overlay (e.g., sticky header, floating toolbar) to preserve spatial awareness of content passing underneath.
* **COMPONENT JUSTIFICATION AUDIT**:
  For every visually prominent card or box, verify:
  1. *What specific information or interactive task does this container group?*
  2. *Would pure whitespace, typographic hierarchy, or a subtle divider line communicate this structure with less visual clutter?*
  3. *Does this container add cognitive weight without adding structural clarity?*

### 7.5 Action Hierarchy (Dominant Outcome Architecture)
* **PRINCIPLE**: A task frame should communicate one dominant intended user outcome. The action hierarchy must remain unmistakable.
* **DEFAULT**:
  * Establish one dominant primary action per task frame. Supporting actions must be secondary (outlined/ghost) or tertiary (plain text with icon/underline).
  * Clear visual differentiation between destructive, constructive, and navigational actions.
* **CONTEXTUAL EXCEPTION**:
  * Multiple primary actions are acceptable when they represent genuinely distinct, equally valid user paths (e.g., dual entry paths on an auth gateway, or distinct creation vs. operational workflows) and their hierarchy remains clear.
* **VALIDATION & HEURISTIC PROBE**:
  * Ask: *"What is the dominant user outcome here?"*—not *"How many buttons are allowed?"*
  * Are secondary links visually subdued so they do not compete with the primary goal?

---

## 8. Real UI State Architecture

A production interface is defined by how it behaves across its complete lifecycle, not just its happy path (see [ui-states.md](file:///Users/godamri/.gemini/config/skills/web-design-craftsman/references/ui-states.md)):

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

### State Modeling Invariants & Guidelines
1. **Loading States**: Use layout-shaped skeleton placeholders matching target components to eliminate Cumulative Layout Shift (CLS). Avoid generic full-screen spinners for sub-component loading.
2. **Empty States**: Empty states must explain the current condition and provide an appropriate next action when one exists. Illustration or iconography is optional and should only be used when it improves comprehension, orientation, or product character. Avoid decorative artwork that adds visual noise without clarifying the task.
3. **Error States**: Localize errors to the failing component boundary. Provide plain-language explanations of the failure and an actionable "Retry" button. Never expose raw stack traces.
4. **Destructive Actions**: Calibrate confirmation to consequence and reversibility to avoid confirmation fatigue:
   * *Low consequence + reversible*: Direct action execution + non-blocking undo toast/action.
   * *Moderate consequence*: Proportional confirmation (e.g., inline prompt or popover).
   * *High consequence / irreversible*: Strong confirmation (modal dialog requiring explicit resource identifier typing), with default keyboard focus landing safely on CANCEL.
5. **Interactive States**: Hover (pointer only), Focus-Visible (visible high-contrast ring), Active/Pressed (tactile feedback under 50ms), and Disabled (dimmed; communicate the reason via inline text, helper label, or appropriate accessible mechanism when not already obvious. Avoid tooltip-by-default behavior).

---

## 9. Content Stress-Testing & Viewport Boundaries

Interfaces must be engineered to withstand real-world data extremes and physical viewport constraints:

### 9.1 Content Stress Invariants
Before declaring an interface complete, stress-test it against these edge conditions:
* **Long Strings**: Test with 3-line headlines, 40-character user names, and long button labels. Text must wrap naturally without clipping or layout breakage.
* **Missing Media**: Missing avatars or broken product images must fall back gracefully to neutral initials or structured placeholder icons without collapsing containers.
* **Numeric Extremes**: Format large numbers cleanly. Data table cells must maintain alignment with variable number lengths.
* **Empty Datasets**: Ensure views render informative empty states rather than empty boxes.
* **Text Expansion Resilience**: Stress-test text expansion using plausible target languages/localization requirements and actual product content. Where no localization target is known, test sufficiently long labels and strings rather than relying on a fixed percentage.

### 9.2 Responsive Re-Composition
Mobile design is an ergonomic and informational re-composition (see [responsive-patterns.md](file:///Users/godamri/.gemini/config/skills/web-design-craftsman/references/responsive-patterns.md)):
1. **The Seven Transformations**: Apply **Move** (to thumb zone), **Collapse** (progressive disclosure), **Disappear** (suppress non-essential decoration), **Scroll** (contained horizontal scroll for wide tables), **Stack** (linearize columns), **Re-order** (promote critical actions), and **Persist** (sticky bottom bar).
2. **Scroll Containment**: Root-level unintended horizontal overflow is prohibited. Verify the rendered document and actual scrollable bounds; component-level horizontal scrolling may be intentional for tables, code snippets, tabs, or timelines with clear visual scroll indicators or edge affordance.
3. **Touch Ergonomics**: Interactive controls should provide an adequately sized hit target, with ~44×44 CSS px as a practical accessibility baseline and larger targets where appropriate. Visual dimensions may differ when the effective interactive area remains usable and does not create accidental activation. Form inputs should use minimum 16px font size on mobile viewports to prevent unwanted browser auto-zoom.

---

## 10. Purposeful Motion & Interaction

Motion is an engineering tool that carries cognitive cost and performance overhead.

> **Principle**: Animation must clarify spatial relationships, confirm state transitions, or reduce cognitive disruption. Never animate solely to make a page look "dynamic".

### Motion Invariants & Budgets
* **Legitimate Roles**: State transition, spatial continuity, hierarchy disclosure, action feedback, direct manipulation, and cognitive softening.
* **Duration Budget**: Micro-interactions (hover, active, toggle): 100ms–150ms. Component expansions (modals, dropdowns): 200ms–250ms. Page transitions: maximum 300ms. Anything over 400ms feels sluggish.
* **Easing**: Use deceleration (`ease-out`) for entering elements, acceleration (`ease-in`) for exiting elements, and standard ease (`cubic-bezier(0.2, 0, 0, 1)`) for UI movements. Never use linear motion for spatial shifts.
* **Accessibility Invariant**: Every non-essential transition must respect `@media (prefers-reduced-motion: reduce)`. When reduced motion is requested, instantly set transitions to `none` or subtle opacity cuts.
* **Performance Baseline**: Prefer performant compositor-friendly properties such as `transform` and `opacity`. Animate layout-affecting properties (e.g., accordion height expansion) only when the interaction genuinely benefits from spatial expansion/collapse and the implementation remains performant.

---

## 11. Implementation & Code Discipline

For agents writing or modifying frontend code:
1. **Inspect Before Modifying**: Inspect existing repository patterns, component definitions, and CSS architecture before introducing new abstractions.
2. **Reuse Existing Primitives**: Do not create a custom `NewButton.tsx` or duplicate modal when the project already possesses an established primitive.
3. **Dependency Discipline**: Never introduce a heavy external UI library (Radix, MUI, Chakra) or animation library (Framer Motion, GSAP) solely for minor visual flourishes. Use native HTML elements and CSS transitions whenever sufficient.
4. **Token Centralization**: Keep color, spacing, typography, and radius values bound to semantic design tokens. Avoid one-off magic numbers in component styles.
5. **Architectural Restraint**: Avoid premature abstraction. Build concrete, clean components first; extract reusable abstractions only after three identical repetitions exist.

---

## 12. The Non-Linear Operational Workflow

Interface creation is an iterative engineering loop, not a waterfall:

```text
 1. UNDERSTAND       --> Product category, target audience, core user goal.
 2. INSPECT (RECON)  --> Existing design tokens, component library, CSS architecture.
 3. CLASSIFY         --> Identify Density Archetype (High, Balanced, Readable, etc.).
 4. DEFINE INTENT    --> Single primary user task and message to communicate.
 5. CONTENT ARCH     --> Source verified data; refactor claims into evidence; resolve conflicts.
 6. CHOOSE DENSITY   --> Calibrate spacing, typography scale, and layout density.
 7. VISUAL THESIS    --> Establish the unique, authentic character for this product.
 8. MODEL STATES     --> Map Default, Loading, Empty, Error, and Interactive states.
 9. COMPOSE          --> Layout structural wireframe for desktop and mobile viewports.
10. IMPLEMENT        --> Write clean code using existing primitives and semantic tokens.
11. RENDER           --> Inspect actual rendered browser output across viewports.
12. STRESS-TEST      --> Attack layout with long strings, missing media, and edge widths.
13. HOSTILE CRITIQUE --> Execute 11-dimension review (Clarity, Usability, Character, etc.).
14. REVISE (LOOP)    --> If critique reveals weak IA, return to Step 5; if layout breaks, return to Step 9.
15. VERIFY (QA EXIT) --> Confirm all Definition of Done criteria pass via Rendered Reality.
```

---

## 13. Preflight Diagnostic (Ten Internal Probes)

Before writing or modifying interface code, internally answer these ten questions:

```text
1. What is this product, and what does it actually do?
2. Who is the specific audience, and what is their operational context?
3. What must the user understand within 5 seconds of arriving?
4. What is the dominant user outcome on this screen?
5. What concrete product evidence or artifact supports the claims?
6. What is the appropriate density archetype for this task?
7. What is the visual thesis that gives this interface authentic character? (Is canvas anchored to the light-first default, or is dark mode supported by concrete operational or brand evidence?)
8. What existing repository tokens, components, and conventions must be preserved?
9. What failure, loading, empty, and edge states materially affect the user?
10. What could go wrong under extreme content, narrow mobile viewports, or keyboard navigation?
```

*Rule*: If a missing answer is a **Blocking Unknown**, ask immediately. If non-blocking, make a conservative assumption, document it, and proceed.

---

## 14. The 11-Dimension Hostile Design Critique Protocol

Every interface must undergo an adversarial audit across these eleven dimensions (see [visual-critique.md](file:///Users/godamri/.gemini/config/skills/web-design-craftsman/references/visual-critique.md)):

```text
For every defect identified, answer:
  1. What is wrong?
  2. Why does it matter?
  3. What evidence demonstrates the problem?
  4. What is the smallest useful correction?
```

1. **CLARITY**: *What does this interface communicate within 5 seconds? Can a first-time visitor describe the core offering without marketing jargon?*
2. **HIERARCHY**: *What draws the eye first, second, and third? Does this path match the user's primary decision flow, or are elements competing for attention?*
3. **USABILITY**: *Can the user complete their primary task with zero ambiguity? Are interactive targets obvious, responsive, and forgiving of errors?*
4. **CHARACTER**: *Does the visual design express a coherent visual thesis? Apply the Grayscale Identity Test: if identity dissolves completely without color, the structural composition is generic.*
5. **DENSITY**: *Is information density calibrated to the task? Is it too sparse (forcing endless scrolling) or too dense (causing cognitive overload)?*
6. **CREDIBILITY**: *Are claims supported by immediate, verifiable evidence? Does the product artifact show genuine functionality and realistic data?*
7. **RESPONSIVENESS**: *Does the design re-compose intelligently on mobile viewports? Are touch targets sized correctly, and is horizontal scrolling eliminated?*
8. **ACCESSIBILITY**: *Can a person navigating via keyboard alone operate every control? Do all text elements meet WCAG 2.1 AA contrast? Are form errors clearly communicated?*
9. **PERFORMANCE**: *Are visual effects (blurs, massive images, heavy animations) creating layout shifts (CLS) or input lag (INP)? Can it render smoothly on low-power devices?*
10. **RESTRAINT**: *What can be removed without harming comprehension or utility? Scrutinize visual metaphors (floating badges, decorative glows, fake timers) that are not justified by the product.*
11. **DISTINCTIVENESS**: *Could this page belong to any random competitor or generic startup? If yes, what specific product qualities have been erased, and how do we restore them?*

> *Note*: When color perception is challenged, execute the 10-probe **Color-Diagnosis Protocol** (in [visual-critique.md](file:///Users/godamri/.gemini/config/skills/web-design-craftsman/references/visual-critique.md)) to isolate contrast, hierarchy, or environmental mismatches before modifying the palette.

---

## 15. Comprehensive Quality Assurance (QA Exit Gates)

Validate actual rendered output across these six verification gates before declaring work complete:

1. **Structural QA**: Information hierarchy is intentional; navigation and user flows are unambiguous; content reads logically.
2. **Visual QA**: Typography scale is disciplined; spatial rhythm adheres to consistent increments; colors map to semantic roles; visual thesis is consistently applied.
3. **Interaction QA**: Hover states confirm affordance (pointer only); active states feel tactile (<50ms); focus-visible indicators are prominent; modals trap and restore focus.
4. **State QA**: Loading skeletons prevent layout shifts; empty states provide clear onboarding actions without decorative noise; error states isolate blast radius and offer retry mechanisms; destructive actions apply consequence-proportional confirmation.
5. **Responsive & Stress QA**: Verified at 320px, 375px, 768px, 1440px, and ultrawide viewports; zero unintended root horizontal overflow; long text wraps cleanly; media fallbacks work; interactive hit targets meet usability baselines.
6. **Accessibility & Performance QA**: Full keyboard navigation verified; WCAG 2.1 AA contrast satisfied; form labels properly associated; non-essential animations respect `prefers-reduced-motion`; zero layout-heavy animation bottlenecks.

---

## 16. Operational Stop Conditions

Classify every design ambiguity into one of three operational states:

1. **Blocking Unknown (Halt & Inquire)**: Missing fundamental information where guessing risks producing a completely incorrect interface (e.g., target audience identity is unknown, core product value is undisclosed, primary user task is undefined).  
   *Action*: Stop work. Present the specific unknown clearly, outline viable alternatives, explain trade-offs, and wait for confirmation.
2. **Safe Assumption (Proceed & Document)**: A secondary design detail is unspecified, but a conservative, highly accessible default exists (e.g., specific font family unspecified → choose clean system grotesque stack; exact micro-spacing unspecified → apply standard 8px rhythm).  
   *Action*: Proceed with implementation. Explicitly record the assumption and rationale in the design notes.
3. **Design Ambiguity (Decide & Defend)**: Multiple defensible aesthetic or structural directions exist, all satisfying the core constraints (e.g., dense data table vs. master-detail view; sidebar navigation vs. top header navigation).  
   *Action*: Choose the direction best supported by the product's density archetype and evidence goals. Briefly communicate the trade-off made and continue execution.

---

## 17. Outcome-Driven Definition of Done

A design implementation is complete only when all the following verifiable outcomes are satisfied:

- [ ] **Clear Intent**: Primary user goal and core value proposition are immediately intelligible without marketing jargon.
- [ ] **Verified Content**: Copy contains concrete, specific statements backed by verifiable evidence, clear metrics, or real examples.
- [ ] **Artifact Prominence**: Core product artifact (code, UI sandbox, data table, photography) is prominently featured with realistic data.
- [ ] **Coherent Hierarchy**: Visual weight strictly tracks informational importance; typography, scale, and contrast guide the user through a clear reading path.
- [ ] **Unmistakable Action**: A task frame communicates one dominant intended user outcome; multiple primary actions are justified by distinct paths.
- [ ] **Contextual Density**: Information density directly matches the task archetype (high for operational tools; readable for editorial; balanced for SaaS).
- [ ] **Authentic Visual Thesis**: Interface possesses authentic brand identity and domain specificity; follows the light-first visual default unless dark mode is justified by concrete operational or brand evidence; cannot be mistaken for a generic template.
- [ ] **Real States Implemented**: Default, loading skeleton, empty (without required decorative filler), error recovery, and interactive states are fully modeled.
- [ ] **Content Stress-Tested**: Layout withstands long strings, missing media, and edge numeric values without breaking.
- [ ] **Responsive Re-Composition**: Layout adapts intentionally across mobile, tablet, and desktop viewports using the 7 transformations; zero unintended root horizontal overflow; adequate hit targets.
- [ ] **Accessibility Invariants Enforced**: Full keyboard operability, visible focus rings, WCAG 2.1 AA contrast compliance, semantic HTML, valid form labeling, and reduced-motion respect.
- [ ] **Implementation Discipline**: Existing repository tokens and component primitives are reused; no gratuitous external libraries added.
- [ ] **11-Dimension Critique Completed**: Hostile review executed and necessary iterative corrections applied.
- [ ] **Exceptions Validated**: Any departure from system defaults is explicitly documented, defended by context, and verified against usability.
- [ ] **Rendered Reality Verified**: The interface has been demonstrated across real rendered viewports, interaction states, and accessibility checks, not judged by source code or static screenshots alone.

---

## 18. The Behavioral Voice of the Craftsman

A craftsman is a rigorous engineering partner who evaluates trade-offs, protects usability, and defends product integrity:

* **When a user requests a trendy but unusable pattern**:
  > *"Your requested glassmorphism card treatment looks attractive in static mockups, but it degrades contrast below WCAG AA thresholds on low-brightness displays and creates visual vibration behind body text. Here is the trade-off: we can maintain the layered depth you want by using solid, elevated surface tones with a subtle 1px border, preserving both the modern aesthetic and 100% legibility."*

* **When deliberately defending a departure from a standard default**:
  > *"Normally I would enforce a single dominant action button here. However, our users arrive with two distinct, mutually exclusive intents: developers wanting immediate CLI installation, and enterprise buyers requiring security compliance documentation. I have implemented a split primary action pattern with equal visual weighting to serve both paths without dead ends."*

* **When an interface has been stripped into sterile emptiness**:
  > *"This screen is too minimal. In removing visual decoration, we also stripped away critical explanatory context, category metadata, and product character. The page now looks sterile and uninformative. I am re-introducing structured micro-labels, a richer typographic contrast, and direct product screenshots to restore clarity and identity."*

* **When visual polish is camouflaging weak product substance**:
  > *"This section looks polished on the surface, but the underlying content hierarchy is broken. We have five nested cards describing the product with abstract buzzwords (*'seamless synergy'*, *'intelligent velocity'*), but nowhere do we state what inputs the tool takes or what output it returns. Let's fix the narrative and display the real data schema before refining the border radii."*

* **When an interface is technically clean but visually anonymous**:
  > *"This design strictly passes our design system tokens, but it is visually indistinguishable from fifty other developer tools. We have engineered out all personality. I am introducing custom monospaced status callouts, high-contrast terminal styling, and authentic architectural diagrams to make this uniquely representative of the engineering behind it."*

* **When asked to "Make it look like Apple"**:
  > *"Apple's design strength is not white backgrounds or rounded rectangles; it is ruthless typographic hierarchy, uncompromised product presentation, immaculate edge alignment, and smooth tactile responsiveness. We will apply Apple's discipline—stronger hierarchy, greater restraint, deliberate spacing, and polished interaction—while rejecting hardware-styled floating cards or sterile tech minimalism that does not fit this product's actual domain."*

* **When asked to "Make it more modern"**:
  > *"'Modern' is an underspecified aesthetic request that often leads to decorative slop like glowing gradients, glassmorphism, and floating cards. What user-facing quality are we actually seeking? Do we need faster task completion, clearer typographic hierarchy, more trustworthy evidence presentation, or less visual clutter? Let's identify the functional outcome and derive the visual system from there."*

* **When told "The color feels wrong"**:
  > *"Before we swap hex codes, let's diagnose why the color feels wrong using our color diagnosis protocol. Is it a contrast failure degrading legibility, an action hierarchy collision where buttons compete with badges, an environmental mismatch where the background tone contradicts the product's physical reality, or a typography/composition problem incorrectly perceived as color? Changing the paint without diagnosing the cause will leave the underlying structural defect intact."*

* **When asked "Why is this light? Shouldn't it be dark mode?"**:
  > *"We follow a light-first visual default because light surfaces provide broad compatibility with mixed content, natural presentation of photography, clearer structural separation, and robust baseline readability without requiring luminous or neon accents. Dark mode is fully supported when evidence justifies it—such as sustained low-light operational environments, dedicated terminal tooling, or established brand systems. But choosing dark merely because it 'looks sleek' or 'feels techy' risks introducing accidental cyber aesthetics and luminous color competition. What specific operational or content evidence supports a dark canvas for this product?"*

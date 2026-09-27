# The 11-Dimension Hostile Design Critique Protocol

A design critique must be operational, rigorous, and falsifiable. Vague aesthetic opinions ("This feels cluttered" or "Make it pop") are banned. Every critique finding must identify concrete evidence and specify the smallest useful correction.

---

## 1. The Four-Question Diagnostic Probe

For every weakness or suspected defect, the reviewer must answer these four questions:

```text
1. WHAT IS WRONG?
   Identify the precise visual, structural, or interactive defect.
2. WHY DOES IT MATTER?
   State the specific cost to user comprehension, task completion, or credibility.
3. WHAT EVIDENCE DEMONSTRATES THE PROBLEM?
   Point to observable element collisions, contrast metrics, DOM attributes, or reading tests.
4. WHAT IS THE SMALLEST USEFUL CORRECTION?
   Specify the minimal surgical change that eliminates the defect without redesigning the page.
```

### Forensic Heuristic: The Grayscale Identity Test
Temporarily render the interface in monochrome (e.g., CSS `filter: grayscale(100%)`). Inspect whether hierarchy, composition, typography, imagery, and product character still communicate the intended identity.
* *Diagnostic Check*: Does the interface collapse into generic SaaS without color? Does hierarchy still guide the eye? Does typography carry character?
* *Principle*: If an interface loses all distinctiveness the moment color is removed, the underlying structure is generic and color is being used to disguise structural weakness.

---

## 2. The 11 Dimensions of Hostile Review

| Dimension | Diagnostic Question | Observable Evidence of Defect | Smallest Useful Correction |
| :--- | :--- | :--- | :--- |
| **1. Clarity** | *Can a first-time visitor describe what the product does in 5 seconds?* | Vague hero headline using marketing abstractions without mentioning inputs/outputs. | Rewrite headline with concrete verb + noun; state exact product mechanism. |
| **2. Hierarchy** | *Does visual weight match user decision priorities?* | Multiple competing actions sharing identical weight, obscuring the dominant outcome. | Clarify dominant outcome; demote secondary actions to secondary/tertiary styles. |
| **3. Usability** | *Can the user complete their primary task without hesitation?* | Interactive icons lack text labels or hover/focus states; forms have confusing tab order. | Add explicit text labels; restore high-contrast focus rings; fix DOM order. |
| **4. Character** | *Does the interface express a coherent visual thesis?* | Generic sans-serif, default gray cards, and stock icons showing zero product personality. | Introduce product-specific visual thesis: monospaced data tags, bespoke typography, etc. |
| **5. Density** | *Is information density calibrated to the user's operational task?* | Developer documentation with excessive whitespace forcing 10 scrolls for an API table. | Compact table cell padding; reduce heading margins; increase information density. |
| **6. Credibility** | *Are assertions backed by verifiable evidence?* | Unattributed quotes, synthetic logos, or unverified performance claims. | Delete fake logos; replace abstract claims with reproducible evidence or code. |
| **7. Responsiveness** | *Does the experience re-compose intentionally on mobile?* | Root horizontal page overflow at 320px; cramped hit targets causing collisions. | Fix root overflow; provide adequate hit targets (~44px baseline) and clearance. |
| **8. Accessibility** | *Can a keyboard or screen-reader user operate the view?* | Missing `focus-visible` styles; contrast ratio below 4.5:1; missing form `<label>`. | Add visible focus ring; darken text to pass WCAG AA; link labels with `for/id`. |
| **9. Performance** | *Are visual effects degrading rendering speed or battery life?* | Multiple backdrop-blur layers causing scroll stutter; heavy unoptimized assets. | Replace heavy filters with solid surface tones; optimize and lazy-load assets. |
| **10. Restraint** | *What decorative elements can be eliminated without loss?* | Ambient floating decorative shapes, colored gradient borders, gratuitous badge pills. | Delete decorative meshes and pills; let typography and whitespace carry grouping. |
| **11. Distinctiveness** | *Could this page belong to any random competitor?* | Typical generic SaaS composition: headline + 2 buttons + glowing mockup + 3 cards. | Re-orient layout around the unique product artifact (live terminal, schema, or photo). |

---

## 3. Vague vs. Operational Critique Examples

```text
BAD CRITIQUE:  "This hero section looks weak and uninspired."
GOOD CRITIQUE: "The hero contains three competing focal points (a glowing badge, an oversized CTA, and a high-contrast mockup), causing action ambiguity. The headline also uses abstract jargon ('intelligent acceleration'). 
Smallest Correction: Remove the glowing badge, demote the secondary CTA to plain text, and state the product's primary output in the headline."

BAD CRITIQUE:  "The cards feel too heavy."
GOOD CRITIQUE: "The feature grid uses thick 2px borders, heavy drop-shadows, and 16px corner radius, which draws attention to the containers rather than the technical specifications inside them.
Smallest Correction: Remove the drop-shadows, reduce the borders to 1px neutral muted, and adjust padding to give the data breathing room."
```

---

## 4. The Color-Diagnosis Protocol ("The Color Feels Wrong")

When a user or reviewer states that *"the color feels wrong"*, never jump directly to generating a new palette. Execute this 10-probe diagnostic sequence:

```text
1. CONTRAST FAILURE?
   Is text or control contrast failing WCAG 2.1 AA against its surface?
   → FIX: Adjust lightness/value, not hue.

2. ACTION HIERARCHY FAILURE?
   Are primary buttons, secondary tags, and decorative badges competing in identical hues?
   → FIX: Isolate action color exclusively to the primary actionable outcome.

3. SEMANTIC COLLISION?
   Is a brand accent clashing with warning (amber), error (red), or success (green) states?
   → FIX: Protect semantic status colors from brand tinting.

4. ENVIRONMENTAL MISMATCH?
   Does the canvas tone contradict the physical/domain reality (e.g., cold dark slate for hot soup), or default to dark mode without operational or brand justification?
   → FIX: Recalibrate environmental surface temperature; adhere to the light-first default unless evidence justifies a dark canvas.

5. BRAND MISMATCH?
   Does the palette contradict the established brand identity or domain conventions?
   → FIX: Align with verified brand assets or domain trust anchors.

6. CONTENT / IMAGERY MISMATCH?
   Are surface colors clashing with photography, video, or data visualization elements?
   → FIX: Extract accents directly from content medium; use neutral framing.

7. TYPOGRAPHY / COMPOSITION CONFUSION?
   Is weak typographic hierarchy or cluttered spacing being misperceived as a color flaw?
   → FIX: Refactor typography scale and spatial rhythm first; leave color untouched.

8. SURFACE HIERARCHY AMBIGUITY?
   Are cards, modals, and base backgrounds lacking clear elevation or separation?
   → FIX: Adjust tonal steps between surface levels.

9. EXCESSIVE SATURATION OR GLOW?
   Are unearned radial gradients, glowing drop shadows, or high-chroma fills causing visual fatigue?
   → FIX: Remove glows; reduce saturation to calm the eye.

10. ACTUAL PALETTE FAILURE?
    Only when probes 1–9 pass does an actual palette disharmony exist.
    → FIX: Re-derive palette from the Visual Thesis.
```

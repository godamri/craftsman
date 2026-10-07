# Video Adapter: Visual Quality & Human Educator Contract

This document establishes the design principles, anti-simulator standards, human technical educator scripting guidelines, typography invariants, and visual contracts for Gen-Craftsman video explainer artifacts.

---

## 1. Project Focus: Video Explainer Production Only

> **PRIMARY GOAL: Generate educational explainer videos that feel designed by a human technical educator.**  
> **The output is NOT a simulator.**  
> **The output is NOT a fake monitoring dashboard.**  
> **The output is NOT a system architecture presentation.**  
> **The video is an explanation, not a simulation.**

A great explainer video focuses on:
- **Clear visual explanation**: Concepts made tangible through clean physical/spatial metaphors.
- **Simple storytelling**: A natural narrative progression from problem to understanding.
- **Human-designed scenes**: Layouts crafted with intent and generous negative space.
- **One idea per scene**: No cognitive overload or simultaneous competing panels.
- **Calm professional pacing**: Time for the viewer to absorb each concept before moving on.

---

## 2. Content Style Rules

### STRICTLY FORBIDDEN:
- ❌ AI-style terminology
- ❌ Unnecessary engineering jargon
- ❌ Fake system dashboards
- ❌ Fake monitoring panels
- ❌ Fake telemetry monitors
- ❌ Fake execution reports
- ❌ Fake benchmark numbers
- ❌ Fake "engine status" cards
- ❌ Fake "pipeline completed" notifications
- ❌ Fake architecture simulator UI

### Do NOT create visuals like:
```text
❌ "QUERY LIFECYCLE COMPLETE"
❌ "ROUNDTRIP: 1.2ms"
❌ "ENGINE STATUS: OK"
❌ "BUFFER POOL: 8KB"
❌ "EXECUTION COMPLETED"
❌ "STATUS: OK"
❌ "OPTIMIZED PIPELINE"
❌ "TELEMETRY MONITOR"
```
Unless the video topic specifically requires showing a real metric as part of a concrete teaching example, **omit them completely**.

---

## 3. Human Explainer Style

Design like a developer making a clear, engaging educational video.

### Vocabulary Comparison:
| Prefer Human Language | Do NOT Use Architecture Jargon |
| :--- | :--- |
| ✔ *"Application sends query"* | ❌ *"CLIENT DISPATCH LAYER"* |
| ✔ *"Database checks index"* | ❌ *"QUERY EXECUTION PIPELINE"* |
| ✔ *"Storage finds the data"* | ❌ *"RDBMS KERNEL ARCHITECTURE"* |
| ✔ *"Instead of checking every single file, the database uses an index, like an index in a book."* | ❌ *"B-Tree index traversal algorithm executed across storage blocks."* |
| ✔ *"Two users click withdraw at the exact same millisecond."* | ❌ *"Demonstrating concurrency race condition failure mode in non-repeatable read isolation level."* |

Prefer human language over architecture vocabulary unless technical depth strictly requires it.

---

## 4. Video Structure Contract

Every generated video should naturally contain a 4-part progression:
1. **Opening Explanation**: Frame the core problem or situation simply and relatable.
2. **Main Concept Visualization**: Introduce the central mental model or mechanism using an intuitive spatial/physical metaphor.
3. **Simple Concrete Example**: Walk through a step-by-step query, data lookup, or user action.
4. **Conclusion**: Deliver the core takeaway with clear, memorable typography.

### Do NOT force:
- ❌ Scene numbering visible on screen ("Scene 1/4", "Scene 2 of 5")
- ❌ "Verified Summary" or "Technical Validation" stamps
- ❌ "AI Generated" or framework telemetry labels
Internal metadata may exist in machine manifests, but **must NEVER appear in the video**.

---

## 5. Theme Default Contract & Visual Design

### 1. Default Visual Theme: LIGHT MODE
Unless the user explicitly requests dark mode, **ALWAYS generate a light theme**.  
Do not assume technical content requires dark UI aesthetics. Technical subject alone is **NOT** a reason to use dark mode.

#### Light Mode Style Characteristics:
- **Canvas Background**: Clean white (`#FFFFFF`) or warm neutral background (`#F8FAFC`, `#FDFBF7`).
- **Typography**: Highly readable dark typography (`#0F172A`, `#1E293B`, WCAG AA+ contrast $\ge 7:1$).
- **Subtle Elevation**: Soft, realistic box shadows (`0 4px 6px -1px rgba(0, 0, 0, 0.05)`) and subtle border strokes (`#E2E8F0`).
- **Simple Illustrations**: Grounded diagrams, clean geometry, intentional line art, and semantic accent highlights.
- **Atmosphere**: Professional documentation style and educational presentation feeling.

#### Preferred Visual References:
- Technical blog illustrations (e.g. Stripe, Linear engineering blogs)
- Engineering documentation diagrams
- Modern computer science textbooks
- Clean, elegant product explainer visuals

---

### 2. Dark Mode Exception (Explicit Opt-In Only)
Dark mode is allowed **ONLY** when explicitly requested by the user.  
Examples of explicit triggers:
- *"dark elegant"*
- *"dark theme"*
- *"cinematic dark"*
- *"black background"*

If explicitly requested, follow the dark theme specification:
- Solid deep canvas (`#080B11` or `#0B0F19`)
- Crisp high-contrast light typography (`#F8FAFC`, `#CBD5E1`)
- Deep surface cards (`#111726`, `#182238`) with subtle border strokes (`rgba(255, 255, 255, 0.08)`)
- Restrained color accents ($\le 5\%$ canvas area)

---

### 3. Forbidden Default Styles
Never automatically create:
- ❌ Cyberpunk UI
- ❌ Hacker aesthetic
- ❌ Neon blue/purple glow
- ❌ Terminal-heavy screens
- ❌ Futuristic HUD
- ❌ Enterprise dashboard look

Technical subject alone is **NOT** a reason to use dark mode.

---

### 4. Final Check Before Rendering
Before rendering, ask internally:
> *"Did the user explicitly request dark mode?"*  
> If **NO**: use **LIGHT MODE**.

---

## 6. Render Quality Contract (Anti-Blur Standards)

All videos must prioritize **razor-sharp text and crisp diagrams**.

### Required Engineering Invariants:
1. **Intermediate Frame Format**:
   - **PNG ONLY. NEVER JPEG.**
   - In `remotion.config.ts`, set `Config.setVideoImageFormat("png")`.
   - Never use lossy JPEG for intermediate screenshots. JPEG 80 introduces destructive 8×8 DCT ringing, mosquito noise, and 4:2:0 chroma blur at text boundaries.
2. **Color Management & Metadata**:
   - **Rec.709 (`bt709`)**, **`yuv420p`**, **broadcast limited range (`tv`)**, correct HD metadata.
   - In `remotion.config.ts`, set `Config.setColorSpace("bt709")` and `Config.setPixelFormat("yuv420p")`.
   - Eliminates deprecated `yuvj420p` and standard-definition PAL `bt470bg` metadata errors.
3. **High-DPI Rendering**:
   - Enable high-DPI rendering; **prefer `--scale=2` when possible**.
   - Activates Chromium's `deviceScaleFactor: 2`, rendering vector fonts and SVG lines at 2x Retina resolution.
   - 1440p+ renders bypass YouTube's low-bitrate 1080p AVC1 compression ladder.
4. **Bitrate Protection on Canvas Backgrounds**:
   - Protect canvas backgrounds, subtle gradients, and soft elevation shadows against macroblocking and color banding.
   - Avoid low bitrate output.
   - **Minimum expectations**:
     - **1080p**: Video bitrate $\ge 5\text{ Mbps}$
     - **1440p**: Video bitrate $\ge 8\text{ Mbps}$
5. **Typography Minimums**:
   - **Titles**: $\ge 48\text{px}$ (font-weight: 700–800)
   - **Body**: $\ge 24\text{px}$ (font-weight: 500–600)
   - **Labels**: $\ge 18\text{px}$ (font-weight: 600–700)
   - **Avoid tiny text**: **NO 12px–14px labels anywhere**.
   - **No thin fonts**: Font weights $< 400$ are strictly forbidden.

---

## 7. Audio Rules (Human Scale & Subtle)

Audio is allowed but simple:
- **Default sounds**:
  - Subtle beep (warm sine/harmonic notification)
  - Soft click (tactile UI feedback)
  - Transition sound (smooth filtered sweep with gentle bell resonance)
  - Ambient tone (warm, low-tempo background drone at $\le 0.15$ volume)
- **NO narration unless explicitly requested**.
- **Do NOT generate fake robotic AI voice**.
- Audio must support visuals, never become the main content.

---

## 8. Publishing Deliverables (`out/title.txt` & `out/caption.txt`)

Every project must generate 3 deliverable files in `./out/`:
1. `out/artifact.mp4` — Master rendered video binary.
2. `out/title.txt` — Human-crafted video title ready for platform publishing.
3. `out/caption.txt` — Short natural sentence + 3–8 educational hashtags.

### Part A: Title Output (`./out/title.txt`)
- **Length**: Short, human-designed educational title (4 to 10 words).
- **Tone**: Curious, explanatory, or practical hook.
- **Format**: Plain text, single line, no surrounding quotes.
- **Avoid Generic AI Clichés**:
  - ❌ *"The Ultimate Guide to..."*
  - ❌ *"Mastering the Art of..."*
  - ❌ *"A Comprehensive Deep Dive into..."*
  - ❌ *"Unlocking the Secrets of..."*
- **Examples**:
  - `How Databases Find Your Data`
  - `Why Two Withdrawals Can Lose Money`
  - `How Distributed Servers Agree on Reality`
  - `What Happens When Hash Keys Collide`

### Part B: Caption Output (`./out/caption.txt`)

#### Format:
```text
[Short, casual, human-written sentence]

#hashtag1 #hashtag2 #hashtag3 ...
```

#### Rules:
- Short, conversational, human written.
- Reads like a developer sharing their work on social media.
- Include 3 to 8 relevant educational hashtags matching the actual video topic.
- Zero marketing copy, zero promotional hype.
- No AI wording (e.g. ❌ *"In this video we will explore..."*, ❌ *"Discover the power of..."*).
- No long descriptions.

#### Example:
```text
how a database finds your data, from request to result.

#database #backend #sql #programming #technology
```

---

## 9. Final Quality Check & Rejection Gate

Before packaging or marking an artifact complete, execute the three-dimensional audit:

### 1. Content Audit:
- Does this explain something?
- Is every visual necessary?
- Is the language human?

### 2. Design Audit:
- Is text readable?
- Are all labels $\ge 18\text{px}$ (no 12px–14px micro-text)?
- Is there any unnecessary UI or dashboard clutter?
- Does it look like a real educational video?

### 3. Technical Audit:
- Is output sharp?
- Was frame capture performed with PNG only?
- Is bitrate sufficient ($\ge 5\text{ Mbps}$ for 1080p, $\ge 8\text{ Mbps}$ for 1440p)?
- Is color metadata correct (Rec.709, `yuv420p`, `tv` range)?

### Reject Generation If:
- ❌ Looks like an AI dashboard or simulator.
- ❌ Contains unnecessary jargon or telemetry labels.
- ❌ Contains fake metrics ("1.2ms", "99% hit rate").
- ❌ Text is too small ($< 18\text{px}$) or thin ($< 400$).
- ❌ Video appears soft, blurry, or ringing around text.

> **The Ultimate Goal**:  
> *"A developer could publish this as an educational YouTube short/lesson without explaining that it was generated."*

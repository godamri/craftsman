---
name: gen-craftsman
description: >-
  Autonomous digital artifact creation guidance focused on structured planning,
  deterministic generation, editable source code, realistic technical validation,
  human-crafted technical video storytelling, and natural publishing captions.
license: MIT
---

# Gen-Craftsman: Autonomous Digital Artifact Engineering (v0.2)

## Preamble & Supreme Generation Axioms

> **An artifact is an engineered digital output, not a disposable generated file.**  
> **PRIMARY GOAL: Generate educational explainer videos that feel designed by a human technical educator.**  
> **PROJECT FOCUS: Video explainer production only.**  
> **The output is NOT a simulator. The output is NOT a fake monitoring dashboard. The output is NOT a system architecture presentation.**  
> **Focus: Clear visual explanation, simple storytelling, human-designed scenes, one idea per scene, calm professional pacing.**  
> **Visual Clarity Priority: Prioritize sharpness for text, diagrams, thin lines, and illustrations. Do NOT optimize for smallest file size.**  
> **THEME DEFAULT CONTRACT: Default visual theme is LIGHT MODE.**  
> **If the user does not explicitly request dark mode ("dark mode", "dark theme", "black background", "cinematic dark style"), ALWAYS generate a light theme.**  
> **Technical content alone is NOT a reason to use dark UI aesthetics.**  
> **Pre-Rendering Internal Check: Ask internally: "Did the user explicitly request dark mode?" If NO: use LIGHT MODE.**  
> **Intermediate Frame Invariant: PNG ONLY. NEVER JPEG.**  
> **Color & Metadata Invariant: Rec.709 (`bt709`), `yuv420p`, broadcast limited range (`tv`), correct HD metadata.**  
> **High-DPI Rendering: Enable high-DPI rendering; prefer `--scale=2` when possible to activate Chromium Retina font rasterization.**  
> **Bitrate Protection: Protect backgrounds and subtle gradients against banding; enforce minimum video bitrates ($\ge 5\text{ Mbps}$ for 1080p, $\ge 8\text{ Mbps}$ for 1440p).**  
> **Typography Threshold: Titles $\ge 48\text{px}$, Body $\ge 24\text{px}$, Labels $\ge 18\text{px}$. Avoid tiny text: NO 12px–14px labels.**  
> **1:1 Composition Rule: Never render at smaller internal resolution and upscale. Composition resolution matches output resolution.**  
> **Deterministic source precedes generated binary. Rendered reality validates source intent.**  
> **Usable artifact + publishing title + casual caption + editable source + metadata + validation evidence = Complete delivery.**  
> **Internal system telemetry stays hidden. The viewer sees only engaging educational content.**  
> **Final Quality Gate: "Would a human technical educator publish this video as an educational YouTube short/lesson without explaining that it was generated?" If it looks like a dashboard, contains jargon, or feels blurry -> REJECT and fix.**

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ THE CRAFTSMAN DELIVERY BUNDLE INVARIANT                                                │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 1. USABLE ARTIFACT      │ Master rendered video binary (out/artifact.mp4)              │
│ 2. PUBLISHING TITLE     │ Human-crafted engaging video title (out/title.txt)           │
│ 3. PUBLISHING CAPTION   │ Human-written casual social/YouTube caption (out/caption.txt)│
│ 4. EDITABLE SOURCE      │ Declarative React/Remotion source tree (src/)                │
│ 5. GENERATION METADATA  │ Machine-readable spec, seeds, versions (report/manifest.json) │
│ 6. VALIDATION EVIDENCE  │ Automated checks + keyframes (report/validation-report.md)   │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 1. Skill Identity & Purpose

- **Name**: `gen-craftsman`
- **Version**: `0.2.0`
- **Scope Focus**: **Educational Technical Explainer Videos with Human-Crafted Storytelling & Publishing Captions** (Remotion, React, TypeScript, FFmpeg).
- **Core Role**: Autonomous Educational Explainer Video Compiler.
- **Fundamental Problem Solved**: Replaces opaque, one-shot stochastic AI generation, generic AI visual slop, fake simulator dashboards, and robotic jargon with an **inspectable, deterministic, editable code-to-artifact compiler loop** producing human-grade educational explainers and natural publishing captions.

---

## 2. Core vs. Domain Architecture Boundary

To ensure long-term extensibility without premature architectural bloat, Gen-Craftsman maintains an unyielding boundary between **Universal Core** and **Domain Implementation**:

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ 1. UNIVERSAL CORE (core/)                                                             │
│    • BaseArtifactSpec (id, domain, objective, description, constraints, metadata)      │
│    • Lifecycle State Machine (SPECIFIED ➔ SCAFFOLDED ➔ IMPLEMENTED ➔ RENDERED ➔ ...)    │
│    • Delivery Bundle Contract (artifact + caption + source + metadata + validation)    │
│    • Two-Tier Validation Model (Technical Probing + Visual Evidence Preparation)       │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 2. DOMAIN IMPLEMENTATION: VIDEO (adapters/video/)                                      │
│    • VideoArtifactSpec (format presets, semantic theme, safe-area profile, audio, ...) │
│    • Human Educator Contract (Explainer Not Simulator, Anti-AI Slop, Visual Metaphors) │
│    • Remotion Component Architecture (Series, Pure Frame Functions, Responsive UI)     │
│    • High-Clarity Render Contract (PNG frames, Rec.709, scale=2, bitrate floor)        │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Human Technical Educator Style & Strict Content Rules

A video must feel like it was designed, scripted, and animated by a human technical educator explaining a concept with clarity, empathy, and patience.

### Rule 1: STRICTLY FORBIDDEN Visuals & AI Jargon
Never generate internal system labels, generative AI buzzwords, or fake telemetry just to make the video look advanced:

```text
❌ QUERY LIFECYCLE COMPLETE      ❌ ROUNDTRIP: 1.2ms        ❌ ENGINE STATUS: OK
❌ BUFFER POOL: 8KB              ❌ EXECUTION COMPLETED     ❌ OPTIMIZED PIPELINE
❌ CLIENT DISPATCH LAYER         ❌ RDBMS KERNEL ARCH       ❌ OBSERVABILITY DASHBOARD
❌ STATUS: OK                    ❌ AUTONOMOUS ENGINE       ❌ TELEMETRY MONITOR
❌ ARCHITECTURE LAYER            ❌ END-TO-END RUNTIME      ❌ PERFORMANCE METRICS
```

Unless the educational topic explicitly requires showing a real, concrete metric, **omit them completely**.  
**The video is an explanation, not a simulation.**

### Rule 2: NO Fake Simulator UI
Do NOT create:
- Monitoring dashboards
- Terminal simulator windows everywhere
- Fake benchmark numbers
- Fake latency counters ("1.2ms")
- System status panels ("STATUS: OK")
- Architecture diagrams full of tiny labels

### Rule 3: Human Explainer Style (Prefer Human Language)
Design like a developer making a clear educational video.

- **Preferred Phrasing**:
  - *"Application sends query"* (instead of *"CLIENT DISPATCH LAYER"*)
  - *"Database checks index"* (instead of *"QUERY EXECUTION PIPELINE"*)
  - *"Storage finds the data"* (instead of *"RDBMS KERNEL ARCHITECTURE"*)
  - *"Instead of checking every single file, the database uses an index, like an index in a book."*
- **Visual Design Preference**:
  - Simple spatial diagrams
  - Clean illustrations
  - Gradual step-by-step explanation
  - One idea per scene
  - Calm, natural pacing
  - Highly readable labels

### Rule 4: Video Structure Contract
Every generated explainer video must naturally contain a 4-part progression:
1. **Opening Explanation**: Frame the problem or real-world situation simply.
2. **Main Concept Visualization**: Introduce the central mental model or mechanism using an intuitive spatial/physical metaphor.
3. **Simple Concrete Example**: Walk through a step-by-step query, data lookup, or user action.
4. **Conclusion**: Deliver the core takeaway with clear, memorable typography.

**Do NOT force**:
- ❌ Scene numbering visible on screen ("Scene 1 of 4", "Scene 2/5")
- ❌ "Verified Summary" or "Technical Validation" badges
- ❌ "AI Generated" or framework telemetry labels
Internal metadata may exist in manifests, but **never appears in the video**.

### Rule 5: Theme Default Contract & Visual Design

#### 1. Default Visual Theme: LIGHT MODE
Unless the user explicitly requests dark mode, **ALWAYS generate a light theme**.  
Technical content alone is **NOT** a reason to use dark UI aesthetics.

**Light Mode Style Characteristics**:
- **Canvas Background**: Clean white (`#FFFFFF`) or warm neutral (`#F8FAFC`, `#FDFBF7`).
- **Typography**: Highly readable dark typography (`#0F172A`, `#1E293B`) with WCAG AA+ contrast ($\ge 7:1$).
- **Subtle Elevation**: Soft, realistic box shadows (`0 4px 6px -1px rgba(0, 0, 0, 0.05)`) and delicate border strokes (`#E2E8F0`).
- **Illustrations**: Simple, intentional line art, grounded geometric shapes, and focused semantic highlights.
- **Tone**: Professional documentation style and educational presentation feeling.
- **Preferred Visual References**:
  - Technical blog illustrations (e.g. Stripe, Linear engineering blogs)
  - Clear engineering documentation diagrams
  - Modern computer science textbooks
  - Clean, elegant product explainer visuals

#### 2. Dark Mode Exception (Explicit Opt-In Only)
Dark mode is allowed **ONLY** when explicitly requested by the user.  
Examples of explicit requests:
- *"dark elegant"*
- *"dark theme"*
- *"cinematic dark"*
- *"black background"*

When explicitly requested, follow the dark theme specification:
- Solid deep canvas (`#080B11` or `#0B0F19`)
- Crisp high-contrast light typography (`#F8FAFC`, `#CBD5E1`)
- Deep surface cards (`#111726`, `#182238`) with subtle border strokes (`rgba(255, 255, 255, 0.08)`)
- Restrained color accents ($\le 5\%$ canvas area)

#### 3. Forbidden Default Styles
Never automatically create:
- ❌ Cyberpunk UI
- ❌ Hacker aesthetic
- ❌ Neon blue/purple glow
- ❌ Terminal-heavy screens
- ❌ Futuristic HUD
- ❌ Enterprise dashboard look

Technical subject alone is **NOT** a reason to use dark mode.

#### 4. Pre-Rendering Internal Check
Before rendering any frame, ask internally:
> *"Did the user explicitly request dark mode?"*  
> If **NO** $\to$ use **LIGHT MODE**.

### Rule 6: Audio Rules (Human Scale & Subtle)
- Audio is allowed but simple:
  - Subtle clicks (tactile UI feedback)
  - Small beeps (warm sine/harmonic notification tones)
  - Transition sounds (smooth filtered sweeps with gentle bell resonance)
  - Ambient tone (warm, low-tempo background drone at $\le 0.15$ volume)
- **NO narration unless explicitly requested**.
- **Do NOT generate fake robotic AI voice**.
- Audio must support visuals, never become the main content.

### Rule 7: Publishing Deliverables (`out/title.txt` & `out/caption.txt`)
Every completed video project must generate 3 deliverable files in `./out/`:
1. `out/artifact.mp4` — Master rendered video binary.
2. `out/title.txt` — Human-crafted video title ready for platform publishing.
3. `out/caption.txt` — Short natural sentence + 3–8 educational hashtags.

#### 1. Title Output Contract (`./out/title.txt`)
- **Length**: Short and impactful (4 to 10 words).
- **Tone**: Human technical educator voice; curious, explanatory, or practical hook.
- **Format**: Plain text, single line, Title Case or clean sentence casing, no wrapping quotation marks.
- **Strictly Avoid Generic AI Titles**:
  - ❌ *"The Ultimate Guide to..."*
  - ❌ *"Mastering the Art of..."*
  - ❌ *"A Comprehensive Deep Dive into..."*
  - ❌ *"Unlocking the Secrets of..."*
- **Examples**:
  - `How Databases Find Your Data`
  - `Why Two Withdrawals Can Lose Money`
  - `How Distributed Servers Agree on Reality`
  - `What Happens When Hash Keys Collide`

#### 2. Caption Output Contract (`./out/caption.txt`)
**Structure**:
```text
[Short, casual, human-written sentence]

#hashtag1 #hashtag2 #hashtag3 ...
```

**Rules**:
- Short, conversational tone (reads like a developer sharing their work).
- Include 3 to 8 relevant educational hashtags (`#database #sql #backend #programming`).
- Zero marketing copy, zero promotional hype.
- No AI cliché openers (e.g. ❌ *"In this video we will explore..."*, ❌ *"Discover the power of..."*).
- No long descriptive paragraphs.

**Example**:
```text
how a database finds your data, from request to result.

#database #backend #sql #programming #technology
```

---

## 4. Render Quality Contract & Anti-Blur Standards

All videos must prioritize **razor-sharp text and crisp diagrams**.

### Invariant 1: Intermediate Frame Format — PNG ONLY
- In `remotion.config.ts`, set:
  ```typescript
  Config.setVideoImageFormat("png");
  ```
- **NEVER use JPEG**. Remotion defaults to JPEG Quality 80, which introduces destructive 8×8 DCT ringing, mosquito noise, and 4:2:0 chroma blur at text boundaries *before* FFmpeg encodes the video.

### Invariant 2: Color Space & Metadata — Rec.709 & yuv420p
- In `remotion.config.ts`, set:
  ```typescript
  Config.setColorSpace("bt709");
  Config.setPixelFormat("yuv420p");
  ```
- Generates standard HD Rec.709 color primaries and limited broadcast range (`tv`). Eliminates deprecated `yuvj420p` and 1960s PAL `bt470bg` metadata errors.

### Invariant 3: High-DPI Rendering & Supersampling
- **Enable high-DPI rendering**: Prefer `--scale=2` (or 2x composition resolution) whenever possible.
- Passing `--scale=2` activates Chromium's `deviceScaleFactor: 2`, rendering vector fonts and SVG lines at 2x Retina resolution.
- Rendering at 1440p (e.g. $1920 \times 1440$ for 4:3 or $2560 \times 1440$ for 16:9) forces YouTube and video platforms to allocate their highest-tier **VP9/AV1** encoding ladder, bypassing the low-bitrate 1080p compression penalty.

### Invariant 4: Bitrate Floor Protection
- Protect dark backgrounds and subtle gradients against macroblocking and color banding.
- Avoid low bitrate output. Enforce minimum expectations:
  - **1080p**: Video bitrate $\ge 5\text{ Mbps}$
  - **1440p**: Video bitrate $\ge 8\text{ Mbps}$
- Use CRF 16–18 with `--x264-preset=slow` or add explicit rate limits (`--video-bitrate=6000k --max-rate=10000k --buffer-size=12000k`).

### Invariant 5: Typography Readability Scale
Technical explainer videos convey high-density visual concepts. Text must never collapse under chroma subsampling:
- **Titles**: $\ge 48\text{px}$ (font-weight: 700–800)
- **Body & Subtitles**: $\ge 24\text{px}$ (font-weight: 500–600)
- **Labels & Badges**: $\ge 18\text{px}$ (font-weight: 600–700)
- **Strictly Forbidden**: Tiny text. **NO 12px–14px labels anywhere**.
- **No thin fonts**: Font weights $< 400$ are strictly forbidden.

### Invariant 6: 1:1 Composition Resolution Rule
- Never render at a smaller internal resolution and upscale.
- The Remotion `<Composition>` width/height must match the output resolution 1:1.

---

## 5. The 4-Zone Layout System & Semantic Colors

Before rendering, vertical space must be divided into four deterministic functional zones:

```text
┌────────────────────────────────────────────────────────┐  ▲
│ 1. TITLE ZONE (10% - 15% Height)                       │  │
│    Topic / Headline (e.g. "Looking at the Index First")│  │
├────────────────────────────────────────────────────────┤  │
│ 2. EXPLANATION ZONE (10% - 15% Height)                 │  │ 100%
│    Conversational insight (e.g. "Checks index first")  │  │ Viewport
├────────────────────────────────────────────────────────┤  │ Height
│ 3. VISUALIZATION ZONE (55% - 65% Height) — MAIN STAGE  │  │
│    Concrete spatial diagram, visual metaphor, flow     │  │
├────────────────────────────────────────────────────────┤  │
│ 4. ANNOTATION ZONE (10% - 12% Height)                  │  │
│    Clear viewer takeaway (e.g. "Only 3 hops followed") │  │
└────────────────────────────────────────────────────────┘  ▼
```

### Semantic Color Tokens

#### Default Light Mode Tokens (Standard Default)
- **Background**: Canvas base (`#FFFFFF`, `#F8FAFC`, or warm neutral `#FDFBF7`).
- **Surface**: Container elevation for cards and panels (`#FFFFFF`, `#F1F5F9`).
- **Surface Border**: Clean subtle container borders (`#E2E8F0`, `#CBD5E1`).
- **Primary Text**: Main headline and active diagram labels (`#0F172A`, `#1E293B`, $\ge 7:1$ contrast).
- **Secondary Text**: Subheadlines, steps, and conversational takeaways (`#475569`, `#64748B`).
- **Subtle Shadows**: Soft natural shadows (`0 4px 6px -1px rgba(0, 0, 0, 0.05)`).
- **Accents**: Technical Blue (`#2563EB`), Emerald (`#059669`), Amber (`#D97706`), Coral (`#E11D48`). Accent pixels must remain $\le 5\%$ of canvas.

#### Dark Mode Tokens (Only When Explicitly Requested)
- **Background**: Deep solid canvas (`#080B11` or `#0B0F19`).
- **Surface**: Container elevation for cards (`#111726`, `#182238`).
- **Surface Border**: Clean subtle borders (`rgba(255, 255, 255, 0.08)`).
- **Primary Text**: Main text and active diagram nodes (`#F8FAFC`, $\ge 4.5:1$ contrast).
- **Secondary Text**: Subheadlines and explanations (`#94A3B8`, `#CBD5E1`).
- **Accents**: Amber (`#FBBF24`), Emerald (`#34D399`), Sky Blue (`#38BDF8`), Coral (`#F87171`). Accent pixels $\le 5\%$.

---

## 6. Supported Format Presets

| Preset | Resolution | Aspect Ratio | Primary Use Case |
| :--- | :--- | :--- | :--- |
| `classic` | $1440 \times 1080$ (or $1920 \times 1440$ @ 1440p) | 4:3 | Educational presentations, technical lectures |
| `youtube-landscape` | $1920 \times 1080$ (or $2560 \times 1440$ @ 1440p) | 16:9 | YouTube desktop explainer videos |
| `mobile-social` | $1080 \times 1920$ | 9:16 | YouTube Shorts, TikTok, Instagram Reels |
| `square-social` | $1080 \times 1080$ | 1:1 | LinkedIn, Twitter / X square feeds |

---

## 7. The 5-Phase Artifact Compiler Loop

```text
  ┌─────────────┐
  │ 1. DISCOVER │  Audit Node.js (>=18), FFmpeg, Remotion CLI, scratch disk space.
  └──────┬──────┘
         ▼
  ┌─────────────┐
  │   2. PLAN   │  Compile intent into 4-part narrative; Theme Decision Gate (Light Mode default).
  └──────┬──────┘
         ▼
  ┌─────────────┐
  │  3. CRAFT   │  Write React scene components with PNG frames, high-DPI scaling, bold typography.
  └──────┬──────┘
         ▼
  ┌─────────────┐
  │  4. VERIFY  │  Audit Tier 1 invariants (ffprobe, Rec.709, bitrate) + Tier 2 visual quality.
  └──────┬──────┘
         ▼
  ┌─────────────┐
  │  5. REFINE  │  Write out/title.txt & out/caption.txt; package complete delivery bundle.
  └─────────────┘
```

---

## 8. Final Quality Check & Rejection Gate

Before marking any video artifact complete or delivering it to the user, execute this mandatory three-dimensional audit:

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ THE FINAL QUALITY AUDIT                                                                │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 1. CONTENT AUDIT                                                                       │
│    • Does this video genuinely explain something?                                      │
│    • Is every visual element necessary to the explanation?                             │
│    • Is the language conversational and human (zero AI jargon, zero fake metrics)?     │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 2. DESIGN AUDIT                                                                        │
│    • THEME DEFAULT: Did the video use LIGHT MODE unless dark mode was explicitly       │
│      requested? (Ask: "Did user explicitly request dark mode?" If NO: MUST be light).  │
│    • Is all text readable at normal viewing distance?                                  │
│    • Are all font sizes >= 18px (no 12px-14px micro-text)?                             │
│    • Is there any unnecessary UI clutter, dashboard tiles, or terminal spam?          │
│    • Does it look like a real human-made educational video?                            │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 3. TECHNICAL AUDIT                                                                     │
│    • Is intermediate frame format strictly PNG (never JPEG)?                           │
│    • Is the output razor-sharp when paused?                                            │
│    • Is the video bitrate sufficient (>= 5 Mbps for 1080p, >= 8 Mbps for 1440p)?       │
│    • Are color metadata tags correct (Rec.709, yuv420p, tv range)?                     │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

### Immediate Rejection Criteria
Reject generation and fix immediately if:
- ❌ Used dark mode when the user did not explicitly request it.
- ❌ Output looks like an AI dashboard, cyberpunk UI, futuristic HUD, or terminal simulator.
- ❌ Contains unnecessary engineering jargon or telemetry phrases.
- ❌ Contains fake metrics ("1.2ms", "99% hit rate").
- ❌ Text is too small ($< 18\text{px}$) or thin ($< 400$ weight).
- ❌ Video appears soft, blurry, ringing, or banding on canvas backgrounds.
- ❌ Frame capture was performed using lossy JPEG.

> **The Ultimate Standard**:  
> *"A developer could publish this as an educational YouTube short/lesson without explaining that it was generated."*

---

## 9. Failure Recovery Protocols

| Symptom | Root Cause | Agent Action |
| :--- | :--- | :--- |
| **Unrequested Dark Mode** | Video generated with dark theme without explicit user request | Re-theme with clean Light Mode tokens (white/neutral canvas, dark text, subtle shadows). |
| **Blurry / Ringing Text Edges** | Intermediate frames rendered as JPEG | Set `Config.setVideoImageFormat("png")` in `remotion.config.ts`. |
| **Banding in Canvas Gradients**| Low video bitrate or 8-bit CRF starvation | Enforce bitrate floor (`--video-bitrate=6000k`) or `-tune animation`. |
| **Incorrect Color / Deprecated yuvj420p** | Missing Rec.709 color management | Set `Config.setColorSpace("bt709")` and `Config.setPixelFormat("yuv420p")`. |
| **Small / Illegible Text on High-DPI** | Font size $< 18\text{px}$ or 1x rasterization | Enforce typography minimums (Titles $\ge 48\text{px}$, Body $\ge 24\text{px}$, Labels $\ge 18\text{px}$) and render with `--scale=2`. |
| **Fake Simulator UI Detected** | Dashboard cards, fake latency ("1.2ms"), fake status | Strip mock console tiles; replace with clean visual metaphor. |
| **Robotic / AI Jargon** | Words like "lifecycle summary", "status: OK" | Rewrite to conversational human phrasing (e.g. "Database checks index"). |
| **Missing Title or Caption** | `./out/title.txt` or `./out/caption.txt` missing | Generate both `out/title.txt` (clean 4–10 word title) and `out/caption.txt` (1 sentence + 3–8 hashtags). |
| **Internal Telemetry Leaked** | "Scene 1/4" or "Validation: PASS" on frame | Remove internal text immediately; replace with topic-specific headline. |

---

## 10. Reference Documents

For in-depth schemas, architecture guides, and quality contracts:
- Visual Quality & Human-Creator Contract: [`adapters/video/visual-quality-contract.md`](file:///Users/godamri/.gemini/config/skills/gen-craftsman/adapters/video/visual-quality-contract.md)
- Video Render Contract: [`adapters/video/render-contract.md`](file:///Users/godamri/.gemini/config/skills/gen-craftsman/adapters/video/render-contract.md)
- Video Remotion Architecture: [`adapters/video/remotion-architecture.md`](file:///Users/godamri/.gemini/config/skills/gen-craftsman/adapters/video/remotion-architecture.md)
- Core Specification Contract: [`core/artifact-spec.md`](file:///Users/godamri/.gemini/config/skills/gen-craftsman/core/artifact-spec.md)
- Core Lifecycle & Delivery: [`core/lifecycle.md`](file:///Users/godamri/.gemini/config/skills/gen-craftsman/core/lifecycle.md)
- Core Validation Contract: [`core/validation.md`](file:///Users/godamri/.gemini/config/skills/gen-craftsman/core/validation.md)

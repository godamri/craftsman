# Video Adapter: Remotion Architecture

This document defines the video-domain architecture using Remotion, React, and TypeScript, including format presets, semantic themes, responsive composition primitives, platform safe-area profiles, high-DPI scaling, and audio contracts.

---

## 1. The Video Domain Model

The Video Adapter translates a `VideoArtifactSpec` into a runnable React project:

```text
VideoArtifactSpec ──> Root.tsx ──> Compositions ──> Series/Scenes ──> Responsive Primitives & Audio
```

### The Pure Deterministic Frame Rule
In Remotion, video is rendered frame-by-frame in headless Chromium. Visual output must be a pure mathematical function of frame index, fps, props, and composition dimensions:
$$\text{UI} = f(\text{frame}, \text{fps}, \text{props}, \text{dimensions})$$

#### Forbidden Non-Deterministic Patterns
- ❌ `window.innerWidth` / `window.innerHeight` / `window.matchMedia` (use `useVideoConfig()`)
- ❌ `Date.now()` / `new Date()` (use `frame / fps`)
- ❌ `Math.random()` (use seeded pseudo-random or hash of frame)
- ❌ `getBoundingClientRect()` or runtime layout measurement queries
- ❌ Non-deterministic network calls or dynamic runtime audio downloads

---

## 2. Video Format Presets

Remotion compositions must define explicit, deterministic dimensions matching one of the four supported format presets:

```typescript
export const FORMAT_PRESETS = {
  "youtube-landscape": { width: 1920, height: 1080, aspectRatio: "16:9" },
  "classic":           { width: 1440, height: 1080, aspectRatio: "4:3" },
  "mobile-social":     { width: 1080, height: 1920, aspectRatio: "9:16" },
  "square-social":     { width: 1080, height: 1080, aspectRatio: "1:1" },
} as const;
```

### Dynamic Root Registration (`src/Root.tsx`)
> [!IMPORTANT]
> **1:1 Composition Invariant**: The `<Composition>` `width` and `height` props MUST strictly equal `format.width` and `format.height`. Never render at a lower resolution (e.g. 720p) and upscale to 1080p.

```tsx
import { Composition } from "remotion";
import { MainVideo } from "./compositions/MainVideo";
import { defaultSpec } from "./spec";

export const Root = () => {
  const { format, theme, safeArea, audio } = defaultSpec.video;

  return (
    <Composition
      id="MainVideo"
      component={MainVideo}
      durationInFrames={format.durationFrames}
      fps={format.fps}
      width={format.width}     // Strict 1:1 match with format preset (e.g. 1920 or 1440)
      height={format.height}   // Strict 1:1 match with format preset (e.g. 1080)
      defaultProps={{
        theme,
        safeArea,
        audio,
      }}
    />
  );
};
```

---

## 3. High-Quality Render Configuration (`remotion.config.ts`)

Every Remotion project must configure the quality invariants at the engine level:

```typescript
import { Config } from "@remotion/cli/config";

// 1. Lossless intermediate frame capture (PNG ONLY, NEVER JPEG)
Config.setVideoImageFormat("png");

// 2. Standard HD Rec.709 color management
Config.setColorSpace("bt709");
Config.setPixelFormat("yuv420p");

// 3. High visual quality encoding
Config.setCrf(18);
Config.setOverwriteOutput(true);
```

---

## 4. Semantic Theme System & Theme Default Contract

Scenes and components must NEVER hardcode raw color hex codes. All styling consumes semantic tokens.

> **THEME DEFAULT CONTRACT**: Default visual theme is **LIGHT MODE**.  
> If the user does not explicitly request dark mode ("dark mode", "dark theme", "black background", "cinematic dark style"), **ALWAYS generate a light theme**. Technical content alone is NOT a reason to use dark UI aesthetics.  
> Ask internally before rendering: *"Did the user explicitly request dark mode?"* If NO $\to$ use LIGHT MODE.

### Theme Contract (`src/theme/types.ts`)
```typescript
export type ThemeMode = "light" | "dark" | "custom";

export interface SemanticThemeTokens {
  background: string;       // Canvas background
  surface: string;          // Card / panel container fill
  surfaceElevated: string;  // Elevated elements / floating badges
  surfaceBorder: string;    // Container stroke / border
  text: string;             // Primary text (>= 7:1 contrast)
  textMuted: string;        // Subheadline / secondary text
  textDim: string;          // Subtle annotations / step counters
  primary: string;          // Brand / primary action accent
  accent: string;           // Semantic highlight / callout
  amber: string;            // Reference amber / warning
  coral: string;            // Error / scan coral
  shadowSubtle?: string;    // Soft elevation shadow for light theme
}

export interface VideoTheme {
  mode: ThemeMode;
  tokens: SemanticThemeTokens;
  typography: {
    primaryFont: string;
    codeFont: string;
  };
}

/** Standard Default: Clean Light Mode Theme */
export const defaultLightTheme: VideoTheme = {
  mode: "light",
  tokens: {
    background: "#F8FAFC",       // Clean soft slate neutral
    surface: "#FFFFFF",          // Crisp white cards
    surfaceElevated: "#FFFFFF",  // Floating white containers
    surfaceBorder: "#E2E8F0",    // Soft slate boundary
    text: "#0F172A",             // Deep high-contrast slate text
    textMuted: "#475569",        // Secondary explanations
    textDim: "#64748B",          // Subtle metadata labels
    primary: "#2563EB",          // Engineering blue
    accent: "#059669",           // Clean emerald
    amber: "#D97706",            // Clear amber
    coral: "#E11D48",            // Sharp rose/coral
    shadowSubtle: "0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -2px rgba(0, 0, 0, 0.05)",
  },
  typography: {
    primaryFont: "Inter, -apple-system, BlinkMacSystemFont, sans-serif",
    codeFont: "JetBrains Mono, monospace",
  },
};

/** Dark Mode Exception (Used ONLY when explicitly requested) */
export const darkThemeException: VideoTheme = {
  mode: "dark",
  tokens: {
    background: "#080B11",
    surface: "#111726",
    surfaceElevated: "#182238",
    surfaceBorder: "rgba(255, 255, 255, 0.08)",
    text: "#F8FAFC",
    textMuted: "#94A3B8",
    textDim: "#CBD5E1",
    primary: "#38BDF8",
    accent: "#34D399",
    amber: "#FBBF24",
    coral: "#F87171",
  },
  typography: {
    primaryFont: "Inter, -apple-system, BlinkMacSystemFont, sans-serif",
    codeFont: "JetBrains Mono, monospace",
  },
};
```

---

## 5. Typography Scale & Anti-Blur Invariants

Educational videos must remain legible across small and large screens alike. Text must never collapse under 4:2:0 chroma subsampling:

```text
┌────────────────────────────────────────────────────────┐
│ TYPOGRAPHY SCALE INVARIANTS                            │
├────────────────────────────────────────────────────────┤
│ • Main Title:      >= 48px @ 1080p (weight: 700 - 800) │
│ • Body / Subtitle: >= 24px @ 1080p (weight: 500 - 600) │
│ • Labels / Badges: >= 18px @ 1080p (weight: 600 - 700) │
├────────────────────────────────────────────────────────┤
│ ❌ NO 12px - 14px labels anywhere on canvas            │
│ ❌ Avoid thin/hairline fonts (weights < 400 forbidden) │
└────────────────────────────────────────────────────────┘
```

---

## 6. Audio Rules & Configuration

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

## 7. Responsive Composition Primitives

To support 16:9, 4:3, 9:16, and 1:1 without rewriting scenes, components must query Remotion's `useVideoConfig()`.

### 1. `ResponsiveContainer` (`src/components/ResponsiveContainer.tsx`)
```tsx
import React from "react";
import { useVideoConfig } from "remotion";
import { VideoTheme } from "../theme/types";

interface ResponsiveContainerProps {
  theme: VideoTheme;
  insets: { top: number; bottom: number; left: number; right: number };
  children: React.ReactNode;
}

export const ResponsiveContainer: React.FC<ResponsiveContainerProps> = ({
  theme,
  insets,
  children,
}) => {
  const { width, height } = useVideoConfig();

  return (
    <div
      style={{
        width,
        height,
        backgroundColor: theme.tokens.background,
        paddingTop: `${insets.top}%`,
        paddingBottom: `${insets.bottom}%`,
        paddingLeft: `${insets.left}%`,
        paddingRight: `${insets.right}%`,
        boxSizing: "border-box",
        display: "flex",
        flexDirection: "column",
        justifyContent: "space-between",
        alignItems: "stretch",
        overflow: "hidden",
        fontFamily: theme.typography.primaryFont,
        color: theme.tokens.text,
      }}
    >
      {children}
    </div>
  );
};
```

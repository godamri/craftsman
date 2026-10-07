# Core Specification: BaseArtifactSpec

This document defines the universal artifact specification contract (`BaseArtifactSpec`) and the extension boundary for domain-specific specifications.

---

## 1. Architectural Boundary: Universal Core vs. Domain

The Core Artifact Specification establishes what an artifact *is* (identity, objective, constraints, provenance) without coupling to how a specific media format operates.

- **Universal Core (`BaseArtifactSpec`)**: Contains only properties shared by every digital artifact (video, image, document, presentation, code scaffold).
- **Domain Extension (`VideoArtifactSpec`)**: Contains domain-specific parameters (format presets, geometry, frame rate, duration, semantic theme, safe-area profile, audio contract, scenes, timeline, transitions).

```text
┌────────────────────────────────────────────────────────┐
│                   BaseArtifactSpec                     │
│  (id, domain, objective, description, constraints,     │
│   metadata, creationInfo)                              │
└───────────────────────────┬────────────────────────────┘
                            │
              extends / specializes via domain
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│                  VideoArtifactSpec                     │
│  (format [preset, width, height, aspect],              │
│   theme [mode, semantic tokens],                       │
│   safeArea [profile, insets],                          │
│   audio [required, type, codec, sampleRate, channels], │
│   scenes, timeline, transitions, assets)               │
└────────────────────────────────────────────────────────┘
```

> [!IMPORTANT]
> **Boundary Rule**: Never leak domain-specific concepts (such as frames, audio sample rates, video codecs, pixels, format presets, or safe areas) into `BaseArtifactSpec`. If a property does not apply equally to a PDF report, an SVG graphic, a video file, and a React component, it belongs in a domain extension.

---

## 2. Universal Contract: `BaseArtifactSpec`

Every Gen-Craftsman artifact specification MUST implement the `BaseArtifactSpec` schema:

```typescript
export interface BaseArtifactSpec {
  /** Schema specification version */
  version: "0.1.0";

  /** Unique kebab-case identifier for this artifact */
  id: string;

  /** Domain discriminator (e.g. "video") */
  domain: string;

  /** Primary functional or communication objective of the artifact */
  objective: string;

  /** High-level description of what is being created */
  description: string;

  /** Operational, brand, or technical constraints */
  constraints: {
    /** Target audience or persona */
    targetAudience?: string;
    /** Resource or execution bounds (e.g., maximum runtime, compute restrictions) */
    budget?: {
      maxExecutionSeconds?: number;
      allowExternalNetwork?: boolean;
    };
  };

  /** Machine-readable metadata and provenance */
  metadata: {
    author: string;
    createdAt: string; // ISO 8601
    tags?: string[];
  };

  /** Environment and toolchain requirements */
  creationInfo: {
    toolchain: string; // e.g. "remotion-react-ts"
    targetArtifactPath: string; // Relative output path, e.g. "out/artifact.mp4"
  };
}
```

---

## 3. Domain Extension: `VideoArtifactSpec` (v0.1)

The video domain extends `BaseArtifactSpec` by adding format presets, semantic theming, safe-area profiles, audio contract, and scene timelines under a dedicated `video` payload:

```typescript
export type VideoFormatPreset =
  | "youtube-landscape" // 1920x1080 (16:9)
  | "classic"           // 1440x1080 (4:3)
  | "mobile-social"     // 1080x1920 (9:16)
  | "square-social";    // 1080x1080 (1:1)

export type ThemeMode = "light" | "dark" | "custom";

export type SafeAreaProfile = "desktop-safe" | "mobile-social-safe";

export interface AudioConfig {
  /** Whether audio output is strictly required for this artifact */
  required: boolean;

  /** Output role (v0.1 supports ambient background only) */
  type: "background";

  /** Standard audio container codec */
  codec: "aac";

  /** Audio sample rate in Hz */
  sampleRate: 48000;

  /** Audio channel count (2 for stereo) */
  channels: 2;

  /** Output volume multiplier between 0.0 and 1.0 (recommended <= 0.15 for background bed) */
  volume: number;

  /** Deterministic asset path relative to project assets (e.g. "audio/ambient-bed.mp3") */
  assetPath?: string;
}

export interface VideoArtifactSpec extends BaseArtifactSpec {
  domain: "video";

  video: {
    /** Output geometry, preset, and temporal frame rate */
    format: {
      preset: VideoFormatPreset;
      width: number;           // Deterministic output value matching preset
      height: number;          // Deterministic output value matching preset
      aspectRatio: "16:9" | "4:3" | "9:16" | "1:1";
      fps: number;             // e.g. 30
      durationFrames: number;  // e.g. 450 (15s @ 30fps)
      codec: "h264";
      container: "mp4";
    };

    /** Semantic Theme Layer (Defaults to "light" unless dark mode explicitly requested) */
    theme: {
      mode: ThemeMode;          // Standard default: "light". Set "dark" ONLY when explicitly requested.
      tokens: {
        background: string;     // Base canvas background (default light: "#FFFFFF" or "#F8FAFC")
        surface: string;        // Card / panel container color (default light: "#FFFFFF" or "#F1F5F9")
        surfaceBorder: string;  // Border stroke color (default light: "#E2E8F0")
        text: string;           // Primary headline and body text (default light: "#0F172A", >= 7:1)
        textMuted: string;      // Secondary / subheadline text (default light: "#475569")
        primary: string;        // Brand highlight color (default light: "#2563EB")
        accent: string;         // Callout / badge highlight (default light: "#059669")
        shadowSubtle?: string;  // Subtle elevation shadow for light containers
      };
      typography: {
        primaryFont: string;
        secondaryFont?: string;
        codeFont?: string;
      };
    };

    /** Platform Safe Area Configuration */
    safeArea: {
      profile: SafeAreaProfile;
      insets: {
        top: number;    // Percentage reserved (e.g. 5 for desktop, 15 for mobile)
        bottom: number; // Percentage reserved (e.g. 5 for desktop, 20 for mobile)
        left: number;   // Percentage reserved (e.g. 5 for desktop, 6 for mobile)
        right: number;  // Percentage reserved (e.g. 5 for desktop, 6 for mobile)
      };
    };

    /** Audio Contract (Optional; silent video is valid if omitted or required=false) */
    audio?: AudioConfig;

    /** Scene breakdown and narrative timeline */
    scenes: VideoScene[];

    /** Local assets required for rendering */
    assets: VideoAsset[];
  };
}

export interface VideoScene {
  id: string;
  index: number;
  title: string;
  durationFrames: number;
  component: string; // React component name, e.g. "Scene01Intro"
  narrative: {
    headline: string;
    subheadline?: string;
    scriptText?: string;
  };
  transition?: {
    type: "fade" | "slide" | "wipe" | "none";
    durationFrames: number;
  };
}

export interface VideoAsset {
  id: string;
  type: "svg" | "image" | "audio";
  path: string;
  required: boolean;
}
```

### Video Format Preset Matrix
| Preset | Dimensions (WxH) | Aspect Ratio | Primary Target Platforms |
| :--- | :--- | :--- | :--- |
| `youtube-landscape` | $1920 \times 1080$ | 16:9 | YouTube, Vimeo, Web desktop players |
| `classic` | $1440 \times 1080$ | 4:3 | Presentations, retro displays, academic talks |
| `mobile-social` | $1080 \times 1920$ | 9:16 | TikTok, YouTube Shorts, Instagram Reels |
| `square-social` | $1080 \times 1080$ | 1:1 | LinkedIn, Instagram Feed, X/Twitter media cards |

### Audio Contract Rules
1. **Explicit Declaration**: Audio is never assumed to exist unless explicitly declared with `audio.required = true`.
2. **Silent Video Validity**: A video artifact is completely valid as silent when `audio` is omitted or `audio.required = false`.
3. **Deterministic Local Assets**: All audio assets must be local files referenced deterministically. No dynamic cloud audio synthesis, no real-time URL streaming, and no external AI TTS dependencies in v0.1.
4. **Volume Ceiling**: Ambient background beds should maintain `volume <= 0.15` to ensure comfortable listening and avoid acoustic clipping.

---

## 4. Extension Boundary Policy

1. **Format Presets & Audio are Domain-Bound**: Format presets and audio encoding configurations exist strictly within `VideoArtifactSpec`. They are never referenced in `BaseArtifactSpec`.
2. **Semantic Themes are Domain-Bound**: Themes map to CSS/React properties in the video engine; they do not pollute the universal core.
3. **No Speculative Schemas**: We do NOT create schemas for images, slide decks, documents, or UI widgets in v0.1.
4. **Validation Independence**: `BaseArtifactSpec` can be validated independently using standard JSON schema validators before any video-domain logic runs.

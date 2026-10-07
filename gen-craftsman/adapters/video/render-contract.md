# Video Adapter: Render Contract & Quality Specification

This document defines the CLI execution contract, rendering configuration, strict encoding quality requirements, high-DPI scaling invariants, and automated stream validation (`ffprobe`) for Gen-Craftsman video explainer artifacts.

---

## 1. Visual Clarity & Rendering Philosophy

> **The final artifact must prioritize visual clarity, especially for text, diagrams, thin lines, and educational illustrations.**  
> **Do NOT optimize for smallest file size.**

The final video must remain crisp and readable when:
- Paused on any individual frame.
- Viewed on standard and high-DPI desktop screens (1080p / 1440p / 4K / Retina).
- Uploaded and re-encoded by video sharing platforms (YouTube, LinkedIn, X).

---

## 2. Strict Render & Quality Invariants

All educational explainer video renders must enforce these baseline parameters:

| Parameter | Standard Requirement | Purpose / Rationale |
| :--- | :--- | :--- |
| **Intermediate Frame Format** | **`png` ONLY (never `jpeg`)** | Eliminates 8x8 DCT ringing, mosquito noise, and chroma smudging around text |
| **Color Space Matrix** | **`bt709` (Rec. 709)** | Standard HD color primaries and transfer characteristics; eliminates `bt470bg` PAL errors |
| **Pixel Format & Range** | **`yuv420p` with `color_range=tv`** | Universal broadcast/web compatibility; eliminates deprecated `yuvj420p` |
| **High-DPI Rendering** | **Enable high-DPI; prefer `--scale=2`** | Activates Chromium `deviceScaleFactor: 2` for crisp Retina font rasterization |
| **Minimum Bitrate (1080p)** | **Video bitrate $\ge 5\text{ Mbps}$** | Protects canvas backgrounds, subtle shadows, and gradients from banding and prevents platform down-sampling |
| **Minimum Bitrate (1440p)** | **Video bitrate $\ge 8\text{ Mbps}$** | Enforces pristine high-DPI video density and triggers YouTube VP9/AV1 ladder |
| **Frame Rate** | `30` fps | Smooth kinetic typography and visual transitions |
| **Video Codec** | `h264` (High Profile) | Universal hardware acceleration across all operating systems |
| **Audio Codec** | `aac` (`48000Hz`, `2` channels) | Broadcast stereo standard |

---

## 3. Remotion Configuration (`remotion.config.ts`)

Every project must enforce the quality contract directly in its configuration:

```typescript
import { Config } from "@remotion/cli/config";

// 1. Lossless intermediate frame capture (NEVER use JPEG)
Config.setVideoImageFormat("png");

// 2. Standard HD Rec.709 color management
Config.setColorSpace("bt709");
Config.setPixelFormat("yuv420p");

// 3. High quality encoding parameters
Config.setCrf(18);
Config.setOverwriteOutput(true);
```

---

## 4. Headless CLI Render Command Contract

The render must be executed via the standard Remotion CLI with deterministic high-clarity flags:

### Standard 1080p Render:
```bash
npx remotion render \
  src/index.ts \
  MainVideo \
  out/artifact.mp4 \
  --concurrency=4 \
  --codec=h264 \
  --image-format=png \
  --color-space=bt709 \
  --pixel-format=yuv420p \
  --crf=18 \
  --video-bitrate=6000k \
  --max-rate=10000k \
  --buffer-size=12000k \
  --gl=angle \
  --log=info
```

### High-DPI Supersampled Render (Recommended for YouTube / Retina):
```bash
npx remotion render \
  src/index.ts \
  MainVideo \
  out/artifact.mp4 \
  --concurrency=4 \
  --scale=2 \
  --codec=h264 \
  --image-format=png \
  --color-space=bt709 \
  --pixel-format=yuv420p \
  --crf=18 \
  --video-bitrate=10000k \
  --max-rate=15000k \
  --buffer-size=18000k \
  --gl=angle \
  --log=info
```

---

## 5. Technical Video Stream Validation (`ffprobe`)

Immediately following a render, extract authoritative stream metrics:

```bash
ffprobe -v error -select_streams v:0 \
  -show_entries stream=codec_name,width,height,pix_fmt,color_space,color_range,r_frame_rate,bit_rate \
  -show_entries format=duration,bit_rate,size \
  -of json out/artifact.mp4 > report/ffprobe_video.json
```

### Automated Binary Rejection Predicates
Reject the artifact (`FAIL`) if any of the following occur:
1. **Pixel Format Failure**: `pix_fmt === "yuvj420p"` (deprecated full-range format; must be `yuv420p`).
2. **Color Space Failure**: `color_space === "bt470bg"` (deprecated PAL SD matrix; must be `bt709`).
3. **Bitrate Starvation**:
   - For 1080p: Video stream bitrate $< 5,000\text{ kbps}$ (5 Mbps).
   - For 1440p+: Video stream bitrate $< 8,000\text{ kbps}$ (8 Mbps).
4. **Resolution Mismatch**: Output dimensions do not match specified composition dimensions.
5. **Duration Desync**: Video and audio duration differ by more than $\pm 0.100\text{s}$.

---

## 6. Typography Scale Invariants

Ensure all text rendered on canvas adheres to readable size thresholds:
- **Main Titles**: $\ge 48\text{px}$ (font-weight: 700–800)
- **Supporting / Body Text**: $\ge 24\text{px}$ (font-weight: 500–600)
- **Labels, Badges, Chips**: $\ge 18\text{px}$ (font-weight: 600–700)
- **Strictly Forbidden**: **NO 12px–14px labels**. Any label under 18px is an immediate failure.
- **Font Weights**: No thin or hairline fonts ($< 400$ weight forbidden).

---

## 7. Milestone Keyframe Extraction Contract

Extract standardized milestone frames for visual audit:

```bash
mkdir -p report/frames

ffmpeg -y -ss 00:00:00.100 -i out/artifact.mp4 -frames:v 1 report/frames/frame_00_start.png
ffmpeg -y -ss $(bc <<< "$D * 0.25") -i out/artifact.mp4 -frames:v 1 report/frames/frame_25_pct.png
ffmpeg -y -ss $(bc <<< "$D * 0.50") -i out/artifact.mp4 -frames:v 1 report/frames/frame_50_pct.png
ffmpeg -y -ss $(bc <<< "$D * 0.75") -i out/artifact.mp4 -frames:v 1 report/frames/frame_75_pct.png
ffmpeg -y -ss $(bc <<< "$D - 0.5") -i out/artifact.mp4 -frames:v 1 report/frames/frame_100_end.png
```

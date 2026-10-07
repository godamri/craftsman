# Core Validation Contract: Video Explainer Quality Verification

This document defines the realistic two-tier validation system for Gen-Craftsman video explainer artifacts, including technical invariant probing, stream verification, typography scale audits, and visual quality inspection evidence.

---

## 1. Architectural Philosophy: Evidence Over Claims

> **Do NOT claim automated aesthetic judgment.**  
> The system does not pretend to "know" whether an artifact is artistically pleasing, emotionally resonant, or beautifully balanced.  
> The system's responsibility is to:
> 1. Programmatically prove **technical correctness**, **Rec.709 metadata conformance**, **video bitrate health**, and **audio-video synchronization**.
> 2. Deterministically assemble **visual evidence** so that a human reviewer or multimodal model can audit against the **Visual Quality Contract** and **Human Explainer Standard**.

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│ TIER 1: TECHNICAL & METADATA VALIDATION (Automated Machine Probing)         │
│   • Compiler exit code == 0                                                 │
│   • File existence & non-zero byte size                                     │
│   • Pixel format: yuv420p (FAIL if deprecated yuvj420p)                     │
│   • Color space matrix: bt709 (FAIL if SD PAL bt470bg)                      │
│   • Video bitrate floor: >= 5 Mbps (1080p) or >= 8 Mbps (1440p)              │
│   • Intermediate frame format: PNG ONLY (FAIL if jpeg)                      │
│   • Typography scale check: Titles >= 48px, Body >= 24px, Labels >= 18px    │
│   • Audio stream presence, codec (AAC), sample rate (48kHz), channels (2)   │
│   • Audio-video duration synchronization (±100ms tolerance)                 │
│   • Internal telemetry leak check (FAIL if "Scene X/X", "Validation PASS")  │
│   • Fake simulator / metric check (FAIL if "1.2ms", "BUFFER HIT: 99%")      │
├─────────────────────────────────────────────────────────────────────────────┤
│ TIER 2: VISUAL QUALITY INSPECTION EVIDENCE (Assembled for Review)           │
│   • Extract keyframes at timeline milestones (0%, 25%, 50%, 75%, 100%)       │
│   • Generate frame artifacts in report/frames/                              │
│   • Audit against Visual Quality Contract (Anti-AI Slop, Layout Zones)      │
│   • Verify text edges, line definition, and absence of compression banding  │
│   • Apply "No-Text Communication Test" to technical diagrams                │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Tier 1: Technical & Metadata Validation (Hard Invariants)

Tier 1 checks are automated and strictly binary (PASS / FAIL). Any failure aborts delivery.

### Mandatory Video Technical Invariants
| Check | Validation Command / Probe | Success Criterion | Failure Action |
| :--- | :--- | :--- | :--- |
| **Exit Code** | Process exit code from render CLI | `code === 0` | Abort; capture compiler stderr |
| **Output Exists** | File system check on `targetArtifactPath` | `stat(path).isFile() === true` | Abort; check render output logs |
| **File Size** | File size in bytes | `size > 1024` (non-empty) | Abort; corrupted render |
| **Container & Codec**| `ffprobe -show_streams -select_v:0` | Codec == `"h264"`, container == `"mp4"` | Fail; verify Remotion codec flags |
| **Resolution** | `ffprobe -show_entries stream=width,height` | Matches `format.width` & `format.height` | Fail; verify `<Composition>` dimensions |
| **Pixel Format** | `ffprobe -show_entries stream=pix_fmt` | `pix_fmt === "yuv420p"` | **FAIL if `yuvj420p`** (deprecated format) |
| **Color Space** | `ffprobe -show_entries stream=color_space` | `color_space === "bt709"` | **FAIL if `bt470bg`** (PAL standard) |
| **Bitrate Floor**| `ffprobe -show_entries stream=bit_rate` | $\ge 5,000\text{ kbps}$ (1080p)<br>$\ge 8,000\text{ kbps}$ (1440p) | Fail; enforce bitrate floor |
| **Intermediate Format**| Inspect `remotion.config.ts` | `Config.setVideoImageFormat("png")` | **FAIL if `"jpeg"`** |
| **Frame Rate** | `ffprobe -show_entries stream=r_frame_rate` | Matches specified FPS (e.g. `30/1`) | Fail; check composition fps prop |
| **Duration** | `ffprobe -show_entries format=duration` | Matches expected duration within $\pm 0.1\text{s}$ | Fail; check total scene frame sum |

### Mandatory Typography, Theme & Code Invariants
| Check | Probe | Success Criterion |
| :--- | :--- | :--- |
| **Theme Default Invariant**| Inspect `artifact.spec.json` | `theme.mode === "light"` unless user prompt explicitly requested dark mode. **FAIL if unrequested dark mode.** |
| **Typography Scale** | Static code scan on scene TSX | Titles $\ge 48\text{px}$, Body $\ge 24\text{px}$, Labels $\ge 18\text{px}$. **FAIL if `12px`–`14px` labels found.** |
| **Font Weights** | Static code scan on scene TSX | Weights $\ge 500$ (Titles 700–800). **FAIL if weights $< 400$ found.** |
| **Internal Telemetry Leak** | Regex scan on scene TSX | Zero occurrences of `"Scene X of"`, `"Scene 1/"`, `"Validation PASS"`, `"Pipeline"`. |
| **Fake Simulator UI** | Regex scan on scene TSX | Zero occurrences of `"1.2ms"`, `"BUFFER HIT: 99%"`, `"ENGINE STATUS: OK"`. |
| **Publishing Title** | File check `./out/title.txt` | File exists; 4–10 word natural human title (no AI clickbait/clichés). |
| **Publishing Caption** | File check `./out/caption.txt` | File exists; short human sentence followed by 3–8 relevant hashtags. |

### Mandatory Audio Technical Invariants (When `audio.required === true`)
| Check | Validation Probe (`ffprobe`) | Expected Criterion | Status |
| :--- | :--- | :--- | :--- |
| **Audio Stream** | `ffprobe -show_streams -select_a:0` | Present (Stream #0:a exists) | PASS / FAIL (Reject if missing) |
| **Codec** | `stream=codec_name` | `aac` | PASS / FAIL |
| **Sample Rate** | `stream=sample_rate` | `48000` Hz | PASS / FAIL |
| **Channels** | `stream=channels` | `2` (stereo) | PASS / FAIL |
| **Duration Sync** | `abs(audio_duration - video_duration)` | $\le 0.100\text{s}$ ($\pm 100\text{ms}$) | PASS / FAIL |

---

## 3. Tier 2: Visual Inspection & Human Educator Review

Tier 2 extracts evidence to enable high-confidence human or multimodal review against the **Visual Quality Contract**, **Anti-Blur Rules**, and **Human Explainer Standard**.

### Automated Keyframe Extraction
For a video artifact of duration $D$, extract 5 standardized milestone frames:

```bash
mkdir -p report/frames
ffmpeg -y -ss 00:00:00.100 -i out/artifact.mp4 -frames:v 1 report/frames/frame_00_start.png
ffmpeg -y -ss $(bc <<< "$D * 0.25") -i out/artifact.mp4 -frames:v 1 report/frames/frame_25_pct.png
ffmpeg -y -ss $(bc <<< "$D * 0.50") -i out/artifact.mp4 -frames:v 1 report/frames/frame_50_pct.png
ffmpeg -y -ss $(bc <<< "$D * 0.75") -i out/artifact.mp4 -frames:v 1 report/frames/frame_75_pct.png
ffmpeg -y -ss $(bc <<< "$D - 0.5") -i out/artifact.mp4 -frames:v 1 report/frames/frame_100_end.png
```

### Reviewer Checklist:
1. **Theme Default Audit**: Did the video use LIGHT MODE unless dark mode was explicitly requested? (Clean white/neutral background, readable dark typography, subtle elevation shadows, professional documentation style).
2. **Visual Clarity**: Are text edges and thin lines razor-sharp when paused?
3. **Color Fidelity & Canvas Cleanliness**: Are canvas backgrounds free from macroblocking, color banding, or noisy gradients?
4. **Explainer Standard**: Does this feel like an educational video designed by a human engineer, rather than a fake system dashboard, cyberpunk UI, or terminal simulator?
5. **Publishing Deliverables**: Does `out/title.txt` contain an engaging 4–10 word human title and `out/caption.txt` contain a short natural sentence with 3–8 educational hashtags?

# Validation Report: concurrent-race-conditions

## 1. Tier 1: Technical & Metadata Validation

### Stream & Binary Invariants
| Check | Expected | Observed | Status |
| :--- | :--- | :--- | :--- |
| **Exit Code** | 0 | 0 | PASS |
| **Output File** | out/artifact.mp4 | Exists (9.32 MB) | PASS |
| **Container** | mp4 | mp4 | PASS |
| **Video Codec** | h264 | h264 (High) | PASS |
| **Resolution** | 1080x1920 | 1080x1920 | PASS |
| **Frame Rate** | 30.00 fps | 30.00 fps | PASS |
| **Duration** | 15.00s (450 frames)| 15.00s (450 frames)| PASS |

### Metadata & Human-Style Contract Conformance
| Dimension | Contract Property | Observed Evidence | Status |
| :--- | :--- | :--- | :--- |
| **Format Preset** | `mobile-social` (9:16) | 1080x1920 stream dimensions match preset | PASS |
| **Theme System** | `mode: "light"` | All 7 semantic tokens defined & resolved | PASS |
| **Safe-Area Profile** | `mobile-social-safe` | Top 15%, Bottom 20%, Sides 6% enforced | PASS |
| **Audio Contract** | Silent (`required = false`) | Audio omitted; silent output verified | PASS |
| **Internal Leakage Audit**| Zero system telemetry on screen | Regex scan confirms 0 occurrences of forbidden internal terms | PASS |
| **Responsive Primitives**| `ResponsiveContainer`, `ResponsiveText` | Scaled to vertical 1920px height | PASS |

**Tier 1 Verdict**: **PASS** (13/13 automated checks passed).

---

## 2. Tier 2: Visual Quality & Human-Creator Audit
Extracted 5 keyframes:
- Keyframe 00s (Simultaneous Read): `report/frames/frame_00_start.png`
- Keyframe 03s (Timeline Divergence): `report/frames/frame_25_pct.png`
- Keyframe 07s (Lost Update Overwrite): `report/frames/frame_50_pct.png`
- Keyframe 11s (Row Lock Serialization): `report/frames/frame_75_pct.png`
- Keyframe 14s (Consistent Balance State): `report/frames/frame_100_end.png`

---

## 3. Visual Reviewer Checklist (Human / Multimodal Prompt)
- [ ] **Human Creator Voice**: Does the script open with an intuitive, real-world bug scenario without corporate filler?
- [ ] **No Internal Leaks**: Are scene numbers ("Scene 1/3"), validation notes, and pipeline metadata completely absent from the video?
- [ ] **Safe-Area Insets**: Does any text or graphic collide with the top 15% (header/profile) or bottom 20% (caption/controls) overlay zones?
- [ ] **Contrast & Theme**: Is dark text (`#0F172A`) distinctly legible on the light background (`#F8FAFC`)?
- [ ] **The No-Text Test**: Do the parallel timeline arrows and balance counter diagrams clearly communicate the race condition without reading copy?
- [ ] **Publishing Deliverables**: Are `out/title.txt` ("Why Two Withdrawals Can Lose Money") and `out/caption.txt` present and compliant?

---

## 4. Final Verdict
- **Technical & Metadata Invariants**: **PASS**
- **Human-Creator Style Conformance**: **VERIFIED**
- **Visual Evidence Status**: **READY FOR REVIEW**
- **Artifact Status**: Eligible for promotion to `PACKAGED`.

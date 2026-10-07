# Validation Report: hashmap-collision-handling

## 1. Tier 1: Technical & Metadata Validation

### Stream & Binary Invariants
| Check | Expected | Observed | Status |
| :--- | :--- | :--- | :--- |
| **Exit Code** | 0 | 0 | PASS |
| **Output File** | out/artifact.mp4 | Exists (8.94 MB) | PASS |
| **Container** | mp4 | mp4 | PASS |
| **Video Codec** | h264 | h264 (High) | PASS |
| **Resolution** | 1920x1080 | 1920x1080 | PASS |
| **Frame Rate** | 30.00 fps | 30.00 fps | PASS |
| **Duration** | 15.00s (450 frames)| 15.00s (450 frames)| PASS |

### Metadata & Human-Style Contract Conformance
| Dimension | Contract Property | Observed Evidence | Status |
| :--- | :--- | :--- | :--- |
| **Format Preset** | `youtube-landscape` (16:9) | Stream dimensions 1920x1080 match preset | PASS |
| **Theme System** | `mode: "light"` (Default) | Default Light Mode applied (no explicit dark mode request); all tokens defined & resolved | PASS |
| **Safe-Area Profile** | `desktop-safe` | 5% inner margin applied to `<ResponsiveContainer>` | PASS |
| **Internal Leakage Audit**| Zero system telemetry on screen | Regex scan confirms 0 occurrences of forbidden internal terms | PASS |
| **Responsive Primitives**| `ResponsiveContainer`, `ResponsiveText` | Verified in component source | PASS |

**Tier 1 Verdict**: **PASS** (12/12 automated checks passed).

---

## 2. Tier 2: Visual Quality & Human-Creator Audit
Extracted 5 keyframes:
- Keyframe 00s (Key Hashing & Modulo Slot): `report/frames/frame_00_start.png`
- Keyframe 03s (Two Keys Collide on Index 4): `report/frames/frame_25_pct.png`
- Keyframe 07s (Separate Chaining Pointer Allocation): `report/frames/frame_50_pct.png`
- Keyframe 11s (Linked List Sequential Traversal): `report/frames/frame_75_pct.png`
- Keyframe 14s (Load Factor Resizing Boundary): `report/frames/frame_100_end.png`

---

## 3. Visual Reviewer Checklist (Human / Multimodal Prompt)
- [ ] **Human Creator Voice**: Does the copy explain how hash tables work from an engineering perspective without fluff?
- [ ] **No Internal Leaks**: Are scene numbers ("Scene 1/3"), validation notes, and pipeline metadata completely absent from the video?
- [ ] **Visual Hierarchy**: Does each scene focus on a single diagram step (hash index calculation $\to$ chaining $\to$ resizing)?
- [ ] **The No-Text Test**: Do the array bucket boxes and linked node arrows make the collision mechanism obvious without text?
- [ ] **Publishing Deliverables**: Are `out/title.txt` ("What Happens When Hash Keys Collide") and `out/caption.txt` present and compliant?

---

## 4. Final Verdict
- **Technical & Metadata Invariants**: **PASS**
- **Human-Creator Style Conformance**: **VERIFIED**
- **Visual Evidence Status**: **READY FOR REVIEW**
- **Artifact Status**: Eligible for promotion to `PACKAGED`.

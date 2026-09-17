# Evolutionary Architecture & Migration Strategies

> **Core Principle**: Systems must be designed for continuous, safe evolution. Breaking architectural migrations without backward-compatible coexistence are prohibited.

---

## 1. The 3-Phase Expand $\to$ Migrate $\to$ Contract Protocol

When altering contracts, databases, or communication protocols:

```text
Phase 1: EXPAND (Additive Changes)
  - Deploy new API fields / database columns alongside existing structures.
  - System supports both old and new consumers.

Phase 2: MIGRATE (Dual-Write / Backfill)
  - Producers write to both old and new targets.
  - Background workers backfill historical data in bounded batches.
  - Consumers switch to reading from the new structure.

Phase 3: CONTRACT (Deprecation & Cleanup)
  - Verify zero traffic and zero queries hit the old structure.
  - Remove deprecated fields, columns, and legacy adapters.
```

---

## 2. API Contract Compatibility Rules

1. **Additive Only in Minor/Patch**: Adding optional fields is safe; renaming or removing fields requires versioning.
2. **Tolerant Reader**: Consumers must ignore unknown fields rather than crashing.
3. **Deprecation Windows**: Mark endpoints deprecated with telemetry before removing them.

# Release Engineering & Progressive Delivery

> **Core Principle**: A release is not verified when the binary builds; it is verified when running in production under real traffic without SLO degradation or data anomaly.

---

## 1. Progressive Deployment Strategy

1. **Phase 1: Internal Dogfooding / Staging**: Automated verification, security scanning, and migration testing.
2. **Phase 2: Canary Rollout (e.g. 1% – 5% traffic)**: Monitor error rate, p99 latency, and saturation telemetry against the baseline fleet.
3. **Phase 3: Automated Rollback Trigger**: If error rates exceed baseline threshold or panics occur, immediately abort and roll back automatically.
4. **Phase 4: Fleet Convergence (100% rollout)**: Decommission legacy instances and monitor for 24 hours.

---

## 2. Multi-Phase Expand/Contract Deployment Order

```text
Step 1: Apply Expand DDL (Add columns as NULL, create concurrent index).
Step 2: Deploy Application Version N+1 (Writes to both old & new, reads from new).
Step 3: Run background batch backfill for historical data.
Step 4: Verify 100% data convergence and zero queries hitting legacy columns.
Step 5: Apply Contract DDL (Drop old column, add NOT NULL constraint).
```

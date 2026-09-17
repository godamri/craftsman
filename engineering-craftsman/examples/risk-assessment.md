# Risk Assessment & Blast Radius Analysis: Customer Ledger Table Partitioning

## 1. Initiative Overview
- **Initiative**: Range-partitioning the primary `customer_ledger` table (280 million rows) by `created_at` year to prevent index bloat and maintain query p99 under 50ms.
- **Risk Classification**: **P1 (Major Risk)**

---

## 2. Risk Dimension Evaluation

| Risk Dimension | Score (1-5) | Analysis & Operational Context |
| :--- | :--- | :--- |
| **Probability of Fault** | 2 (Low-Med) | Well-understood PostgreSQL DDL, but potential locking contention on table rename. |
| **Impact of Fault** | 4 (High) | If migration locks the table > 2s, billing transactions queue up and fail. |
| **Blast Radius** | 4 (Broad) | All payment settlement and invoice generation paths touch this table. |
| **Detectability** | 5 (Immediate) | Lock wait alerts and connection pool saturation metrics trigger in < 5 seconds. |
| **Reversibility** | 4 (Fast) | Pre-scripted rollback swaps table views back to the original unpartitioned table. |

---

## 3. Preventive Controls & Blast Radius Containment

1. **Lock Timeout Policy**: `SET lock_timeout = '2s'; SET statement_timeout = '30s';` prevents cascading connection queue buildup.
2. **Expand/Migrate Protocol**: Historical rows copied to partitioned tables via bounded background worker (5,000 rows/batch) during off-peak hours (02:00 UTC).
3. **Automated Rollback Trigger**: If lock wait exceeds 1.5 seconds or query latency spikes +20%, abort migration script automatically.
4. **Data Verification Drill**: Pre-tested on a 100% production-clone snapshot in staging; verified zero data discrepancy across 280M rows.

# Example: Multi-Milestone Feature Execution Walkthrough

This scenario demonstrates how an AI coding agent executes a complex feature using the milestone execution loop, repository reconnaissance, vertical slicing, falsification, defect discovery, and evidence-backed completion.

---

## 1. User Request
> "Add a concurrent equipment checkout feature that reserves inventory and prevents double-allocation."

---

## 2. Phase 1: Planning & Repository Reconnaissance

### Reconnaissance Findings:
- `FACT`: The repository contains `internal/store/postgres.go` with transaction management using `pgxpool.Pool`.
- `FACT`: Existing entities use UUID primary keys and integer status codes (`StatusDraft = 10`, `StatusActive = 20`, `StatusCompleted = 30`).
- `INFERENCE`: Inventory tracking should use a dedicated `equipment_inventory` table with a foreign key to `equipment_items`.
- `UNKNOWN`: Whether the client application expects asynchronous webhook notifications on checkout completion. (Classified as `OUT OF SCOPE` for checkout core).

---

## 3. Milestone Decomposition & Change Budget

```text
M1 — Core Ingress & Inventory Schema (Vertical Slice: Schema -> Model -> Unit Invariant)
M2 — Checkout Transaction & Concurrency Falsification (Vertical Slice: Atomic Reservation -> Parallel Race)
M3 — Idempotency, Failure Recovery & Full Regression (Vertical Slice: Duplicate Requests -> Full Suite)
```

---

## 4. Milestone M1: Core Ingress & Inventory Schema

### Change Budget:
- `REQUIRED`: Add `equipment_inventory` migration and `InventoryStore` interface in `internal/domain/equipment.go`.
- `REQUIRED FOR VERIFICATION`: Unit test suite in `internal/domain/equipment_test.go`.
- `OPTIONAL / FOLLOW-UP`: Add batch import tool for inventory CSVs. (Deferred).

### Execution & Verification:
- Created schema with `CHECK (available_qty >= 0)`.
- Verified unit domain invariants: Negative quantity decrements return `ErrInsufficientInventory`.
- **Exit Status**: `PASS`.

---

## 5. Milestone M2: Checkout Transaction & Concurrency Falsification

### Observable Acceptance Criteria:
1. Valid checkout for quantity $N \le \text{available}$ $\to$ deducts quantity, creates `checkout_record`, returns 201 Created.
2. Checkout for quantity $N > \text{available}$ $\to$ returns 409 Conflict with error code `INSUFFICIENT_STOCK`.

### Falsification Attack:
- Spawned 20 concurrent goroutines attempting to checkout the single remaining item (`available_qty = 1`).

### Defect Discovered:
- **Observed**: 2 checkout requests succeeded, and final inventory was `-1` before the database constraint triggered a 500 internal server error instead of a controlled 409 Conflict.
- **Root Cause Hypothesis**: The application query performed `SELECT available_qty FROM equipment_inventory` without a row-level lock (`FOR UPDATE`), causing a race condition where both workers read `1` before either wrote `0`.
- **Minimal Fix**: Updated the repository query to `SELECT available_qty FROM equipment_inventory WHERE id = $1 FOR UPDATE`.
- **Re-Verification**: Concurrency race re-run with 20 workers: exactly 1 worker received 201 Created; 19 workers received 409 Conflict; final persisted inventory was exactly `0`.
- **Exit Status**: `PASS`.

---

## 6. Final Engineering Report

```text
================================================================================
FINAL ENGINEERING REPORT
================================================================================

1. EXECUTIVE SUMMARY:
   - Feature: Equipment Checkout & Concurrent Inventory Reservation
   - Final Status: VERIFIED

2. MILESTONE SUMMARY:
   - M1: Inventory Schema & Domain Model     --> PASS
   - M2: Atomic Checkout & Concurrency Race --> PASS
   - M3: Idempotency & Full Regression       --> PASS

3. EVIDENCE COVERAGE MATRIX:
   | Significant Claim | Evidence Provided | Coverage Level | Remaining Gap |
   | :--- | :--- | :--- | :--- |
   | Inventory deduction atomic | Postgres transaction integration test | Verified | None |
   | Concurrency race safe      | 20-worker barrier test with race detector| Verified | Scale beyond 100 workers not tested |
   | Persisted state durable    | Independent session reload test       | Verified | Disk I/O corruption not tested |
   | Production Readiness       | —                                     | Not Established | Deployment load testing required |

4. FAILURE PATHS & FALSIFICATION:
   - [TESTED] Insufficient inventory returns 409 Conflict.
   - [TESTED] Concurrent race on single item serializes safely with row lock.
   - [TESTED] Database rollback on simulated error leaves inventory unchanged.

5. DEFECTS LOG:
   - Defect: Race condition allowed double-allocation in M2.
   - Fix: Added SELECT ... FOR UPDATE in repository transaction.
   - Verification: 20-worker parallel barrier verified.

6. FINAL CERTIFICATION:
   VERIFIED
================================================================================
```

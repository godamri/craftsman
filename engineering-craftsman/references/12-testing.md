# Risk-Based Testing & Invariant Verification

> **Core Principle**: High test count is not evidence of quality. Verification must be measured by invariant coverage, negative boundary exploration, concurrency stress, and failure injection.

---

## 1. The Risk-Driven Testing Spectrum

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ 1. INVARIANT & PROPERTY TESTS                                                          │
│    Prove mathematical properties (e.g. Ledger Debit == Credit, Balance >= 0).          │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 2. CONCURRENCY & RACE BARRIER TESTS                                                    │
│    Execute simultaneous parallel workers with race detectors to catch lost updates.    │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 3. FAILURE INJECTION & CHAOS TESTS                                                     │
│    Inject 503s, timeouts, packet drops, and sudden process terminations.               │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 4. MIGRATION & BACKWARD COMPATIBILITY TESTS                                            │
│    Verify Version N client compatibility against Version N+1 migrated databases.       │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 5. RECOVERY & RESTORE DRILL TESTS                                                      │
│    Prove point-in-time recovery (PITR) and database backup restorability.              │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

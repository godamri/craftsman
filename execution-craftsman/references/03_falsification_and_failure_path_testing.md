# Falsification, Concurrency & Failure-Path Testing

> **Core Principle**: An implementation is not verified until you have actively attempted to break it under adversarial and failure conditions.

---

## 1. The Falsification Mindset

Once the happy path passes, immediately switch perspective from *builder* to *adversary*. Ask:

> **"Under what conditions would this implementation produce incorrect state or silent data corruption?"**

### Attack Dimensions:
1. **Invalid State Transitions**:
   - What happens if an already-cancelled order is cancelled again?
   - What happens if a completed transaction is submitted for refund twice?
2. **Missing or Null Dependencies**:
   - What happens if the database connection drops mid-transaction?
   - What happens if an optional header is omitted?
3. **Payload Boundaries**:
   - Zero amount, negative integers, string length overflows, invalid UTF-8 sequences.
4. **Authorization Bypass**:
   - Can Tenant A access or modify a resource owned by Tenant B?

---

## 2. Concurrency Race Testing

When multiple actors can concurrently read or mutate shared state, sequential testing is insufficient.

```text
Concurrent Test Structure:
1. Set up initial shared resource in database/memory (e.g. 1 available inventory item).
2. Spawn N parallel workers (e.g. 20 concurrent goroutines / async tasks).
3. Synchronize workers at a deterministic start barrier (e.g. close(startGate)).
4. Release all workers simultaneously to execute the mutating operation.
5. Await all workers (sync.WaitGroup).
6. Assert Invariant:
   - Exactly 1 worker receives success (HTTP 200 / Order Placed).
   - Exactly N-1 workers receive controlled failure (HTTP 409 / Out of Stock).
   - Final persisted inventory equals exactly 0 (never negative).
   - Exactly 1 audit record exists.
```

---

## 3. Explicit Failure-Path Status Taxonomy

Every milestone report and test plan must categorize failure scenarios into four explicit states:

- **`TESTED`**: The failure condition was actively executed with automated test code and proven to fail safely.
- **`NOT APPLICABLE`**: The scenario is conceptually irrelevant to the current component boundary (e.g. database rollback is not applicable to a pure formatting utility).
- **`NOT TESTED`**: The scenario is relevant to the domain, but was not executed in the current milestone (must be declared as an explicit testing gap).
- **`UNKNOWN`**: Insufficient system or environment visibility to determine how the failure path behaves.

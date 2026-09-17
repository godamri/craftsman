---
name: distributed-systems-craftsman
description: >-
  Practical distributed systems guidance focused on state consistency,
  idempotency, message delivery semantics, fencing tokens, outbox patterns, and resilient recovery.
license: MIT
---

# Distributed Systems Craftsman: Distributed Systems & Failure Semantics

## Preamble & Universal Engineering Principles

> **Never assume distributed operations are atomic merely because the local code path appears atomic.**  
> **Networks are unreliable, clocks drift, processes crash midway, and messages are duplicated, reordered, and delayed.**  
> **Every distributed workflow must explicitly define ownership, identity, ordering, retry behavior, failure semantics, and reconciliation.**

### The 12 Cross-Skill Engineering Pillars
Every distributed architecture, messaging pipeline, and worker must uphold and optimize for:
```text
1. Resilience       — System withstands network partitions, partial crashes, broker drops, and downstream degradation.
2. Reliability      — Deterministic state transitions, explicit delivery contracts, and reproducible distributed workflows.
3. Adaptability     — Partitions, node additions, and rolling deployments execute without split-brain or data corruption.
4. Maintainability  — Clear causality tracking (correlation IDs, trace contexts), bounded interfaces, and self-documenting events.
5. Recoverability   — Bounded recovery paths, automatic dead-lettering, transactional outbox retries, and state reconciliation.
6. Security         — Mutual TLS (mTLS) across boundaries, payload signing, token verification, and tenant isolation.
7. Observability    — Distributed tracing (OpenTelemetry), queue depth monitoring, retry rate histograms, and DLQ alerting.
8. Simplicity       — Avoid distributed coordination when a single-leader database or partitioned local state suffices.
9. Consistency      — Explicit consistency boundaries (Linearizable vs Eventual); clear definition of stale read tolerances.
10. Verifiability   — Distributed invariants proven via failure injection, partition simulation, network chaos, and race tests.
11. Controlled Change — Backward/forward compatible serialization (Protobuf/JSON) allowing mixed-version fleet execution.
12. Long-Term Durability — Event schemas, deduplication tables, and outbox logs have explicit retention and archival policies.
```

### Priority Meta-Rule
> **No distributed design may claim guarantees that the underlying transport and network cannot physically provide.**  
> - Correctness beats convenience.  
> - Effectively-once business outcomes beat naive "exactly-once" delivery claims.  
> - Evidence beats assumption.  
> - Bounded queues and load shedding beat unbounded buffering.  
> - Recovery and reconciliation must be designed before failures occur.

---

## The 12 Constitutional Distributed Systems Principles

### 1. The Fallacy of Distributed Atomicity
A local database commit followed by a network call (e.g. message publish or HTTP webhook) is NOT atomic. If the process crashes between the commit and the network call, the side effect is lost. If the network call succeeds but acknowledgement fails, the client retries and the side effect executes twice.

### 2. Effectively-Once Business Outcomes
"Exactly-once delivery" cannot be assumed across distributed networks. Build for **at-least-once transport combined with idempotent consumer state machines** to achieve deterministic, effectively-once business outcomes.

### 3. Idempotency & Request Fingerprinting
Every state-mutating command or event must carry a unique Idempotency Key bound to a cryptographic fingerprint (e.g. SHA-256) of the request payload:
- *Same Key + Same Fingerprint*: Return stored outcome (idempotent replay).
- *Same Key + Different Fingerprint*: Reject immediately as conflict (`409 Conflict`).
- *Duplicate Event*: Deduplicate against the persistent `inbox` table.

### 4. The Transactional Outbox Pattern
Never publish events to message brokers directly inside an uncommitted database transaction. Persist outbox event records into an `outbox_events` table within the same atomic database transaction as the business mutation. Asynchronous dispatchers stream/poll the outbox table and publish events with bounded retries.

### 5. Coordination, Leases & Fencing Tokens
Distributed locks are insufficient on their own because garbage collection pauses, thread preemptions, or network delays can expire a lock while a worker is still processing. Always pair distributed leases with **monotonic fencing tokens** checked at the storage boundary:
```sql
UPDATE target_resource SET data = $data, lock_version = $token
WHERE id = $id AND lock_version < $token;
```

### 6. Time, Clocks & Ordering
Wall-clock timestamps (`time.Now()`) drift across physical machines and NTP adjustments. Never use wall-clock timestamps as the sole ordering or concurrency control primitive in distributed systems. Use logical clocks, monotonic database sequences, or UUIDv7.

### 7. Asynchronous Decoupling & Dead-Letter Queues (DLQ)
Consumers must isolate poison messages (malformed payloads, unhandled bugs) to a Dead-Letter Queue after a bounded number of failed retry attempts, rather than blocking consumer group progress indefinitely.

### 8. Backpressure, Concurrency Limits & Load Shedding
Every message consumer, queue, and RPC handler must enforce bounded concurrency and channel capacity. Under saturation, drop or reject requests early (load shedding) rather than accumulating unbounded memory buffers that cause catastrophic OOM crashes.

### 9. Resilient Retries & Full Jitter
All remote RPC and message retries must:
1. Only retry known transient errors (timeouts, 503, connection drops).
2. Enforce exponential backoff with **Full Randomized Jitter** to prevent synchronized client retry storms (thundering herds).
3. Enforce maximum attempt counts and end-to-end deadline budgets.

### 10. State Reconciliation & Compensation
Distributed multi-step workflows must define compensation actions or background reconciliation jobs to heal partial failures and inconsistent intermediate states.

### 11. Stale Worker & Split-Brain Defense
Workers must assume that a previous worker instance might still be running concurrently due to network partitions or execution pauses. Every state transition must be validated against the authoritative database using optimistic version checks.

### 12. Schema Compatibility in Mixed Fleets
Event schemas and RPC message definitions must follow additive evolution rules. During rolling deployments, Version $N$ consumers must gracefully ignore unknown fields emitted by Version $N+1$ producers.

---

## Explicit Prohibitions

1. **PROHIBITED**: Claiming "exactly-once delivery" without specifying the idempotency and deduplication mechanisms that achieve it.
2. **PROHIBITED**: Publishing events or calling external network APIs inside an uncommitted database transaction.
3. **PROHIBITED**: Using distributed locks without monotonic fencing tokens or lease expiration validation.
4. **PROHIBITED**: Unbounded retry loops without exponential backoff and randomized jitter.
5. **PROHIBITED**: Using wall-clock timestamps as the sole distributed ordering primitive.
6. **PROHIBITED**: Consumer pipelines that block indefinitely on poison messages without DLQ routing.
7. **PROHIBITED**: Deploying breaking event or API schema changes without backward-compatible rolling coexistence.

---

## The Distributed Systems Readiness Gate

Before shipping any distributed service, worker, or event-driven pipeline:

- [ ] **Effectively-Once Model Verified**: Are commands protected by idempotency keys and inbox deduplication?
- [ ] **Transactional Outbox Implemented**: Are published events persisted atomically with business state?
- [ ] **Leases Protected by Fencing Tokens**: Do distributed lease holders pass monotonic fencing tokens to storage?
- [ ] **Retries Jittered & Bounded**: Are all retries bounded with exponential backoff and randomized jitter?
- [ ] **Poison Messages Isolated**: Is a Dead-Letter Queue (DLQ) configured with bounded retry counts?
- [ ] **Backpressure Enforced**: Are queues and worker pools strictly bounded against memory exhaustion?
- [ ] **No Wall-Clock Dependency**: Are distributed ordering decisions based on monotonic versions or logical sequences?
- [ ] **Partial Failures Handled**: Are compensation or reconciliation mechanisms defined for multi-step workflows?

---

## Status Declaration

```text
DISTRIBUTED-SYSTEMS-CRAFTSMAN
STATUS: FROZEN
```

> **Final Law**: In a distributed system, anything that can happen will happen. Design every component assuming messages arrive late, twice, out of order, or not at all, and make recovery deterministic.

---

## License

This skill is open source under the [MIT License](LICENSE).

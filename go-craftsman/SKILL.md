---
name: go-craftsman
description: >-
  Practical Go engineering guidance (Go 1.22+) focused on correctness,
  explicit error handling, structured concurrency, memory ownership, and test verification.
license: MIT
---

# Go Craftsman: Go Engineering Principles

## Preamble & Core Go Principles

> **Correctness first. Simplicity second. Performance third. Cleverness last.**  
> **Use the simplest design that is demonstrably correct for the actual problem. Add complexity only when a concrete requirement justifies it.**

### The 12 Cross-Skill Engineering Pillars
Every Go system must uphold and optimize for:
```text
1. Resilience       — Survive failure, degradation, dependency outages, and unexpected conditions without losing integrity.
2. Reliability      — Deterministic, predictable, correct, and consistent behavior against established contracts.
3. Adaptability     — Evolve smoothly as requirements, scale, and environment change without fragile redesigns.
4. Maintainability  — Easy to understand, test, refactor, and operate over the long term.
5. Recoverability   — Every failure mode has a clear, bounded, testable recovery path without relying on heroics.
6. Security         — Confidentiality, integrity, least privilege, and secret protection built-in as correctness invariants.
7. Observability    — Emit actionable signals (structured logs, metrics) to reveal state, failure, and operational impact timely.
8. Simplicity       — Choose the simplest solution meeting requirements; complexity must be explicitly justified.
9. Consistency      — Contracts, state transitions, interfaces, and behaviors must be non-contradictory across layers.
10. Verifiability   — Critical behavior is provable through tests, telemetry, validation, and deterministic verification.
11. Controlled Change — State, schema, configuration, and code mutations have bounded blast radius and pre-tested rollback paths.
12. Long-Term Durability — Decisions consider lifecycle, technical debt, operational burden, and migration cost.
```

### Priority Meta-Rule
> **No skill may optimize one dimension by silently sacrificing another critical engineering property.**  
> - Correctness beats convenience.  
> - Safety beats speed when the blast radius is material.  
> - Evidence beats assumption.  
> - Simple solutions beat unnecessary complexity.  
> - Recovery must be designed before failure occurs.

### Core Axioms
1. **The Race-Free Fallacy**: `"The code is race-free" != "The system is correct."` `go test -race` detects memory data races; it does NOT prove absence of deadlocks, lost updates, goroutine leaks, ordering bugs, split-brain states, or distributed consistency failures.
2. **The Happy-Path Fallacy**: Passing tests does not prove correctness unless tests explicitly exercise invariants under concurrency, failure injection, restarts, and network partitions.
3. **Illustrative Examples**: Examples in this skill and documentation are illustrative, not authoritative. Every implementation must satisfy every constitutional rule. If an example conflicts with a rule, the rule wins.
4. **Proof Before Pass**: Never declare code `safe`, `correct`, `idempotent`, or `production-ready` without explicit assumptions and verifiable failure-mode testing.

---

## Article I: The Invariant & Authority Model

### 1. The Invariant Lifecycle
For every critical business and system requirement, enforce:
```text
Invariant (What must always remain true?)
   ↓
Authority (Who is the single source of truth?)
   ↓
Mutation Boundary (Where is state altered, and how are concurrent races prevented?)
   ↓
Failure Semantics (What happens when execution fails halfway or crashes?)
   ↓
Recovery Semantics (How does the system heal, reconcile, or replay?)
   ↓
Verification (What deterministic test or invariant check proves it?)
```

### 2. The Authority Hierarchy
State must flow strictly down the authority hierarchy:
```text
AUTHORITATIVE SOURCE (e.g. Primary PostgreSQL with constraints, Raft leader)
        ↓
CACHE / PROJECTION (e.g. Redis, In-memory cache, Read replicas)
        ↓
DERIVED / CLIENT STATE (e.g. API responses, event payloads, local UI state)
```
> [!CRITICAL]
> **Cached, replica, or derived state MUST NEVER silently become authoritative merely because it is faster or easier to access.** Stale reads from replicas or caches must never be used to authorize balance deductions, state transitions, or security decisions.

---

## Article II: Simplicity, Architecture & Complexity Escalation

Follow the **Go Complexity Escalation Model**. Default to the lowest sufficient level:

```text
Level 0: Package functions & pure logic
   ↓ (when state + lifecycle require encapsulation)
Level 1: Concrete structs & methods (value vs pointer receivers)
   ↓ (when multiple real implementations or strict test seams exist)
Level 2: Consumer-defined interfaces (minimal: 1–2 methods)
   ↓ (when isolating core domain logic from volatile infrastructure)
Level 3: Decoupled internal packages (explicit dependency direction)
   ↓ (only when distributed workflows or team boundaries demand it)
Level 4: Distributed / gRPC / Event-driven boundaries
```

### Architectural Mandates
- **Accept Interfaces, Return Concrete Structs (When Justified)**: Define interfaces at the *consumer* site only when multiple implementations or test fakes genuinely exist. Avoid interface pollution for single concrete implementations.
- **Minimal Exported Surface**: Keep types, fields, and functions `unexported` by default. Export only what external callers must interact with. Prevent internal state leakage.
- **No Global Mutable State**: Pass dependencies explicitly via constructor parameters (`NewService(...)`). Global mutable variables create hidden coupling, test pollution, and concurrency hazards.

---

## Article III: Data Modeling, Memory & Ownership Semantics

- **Make Zero Values Useful**: Design structs so their zero value is immediately valid without initialization where practical (`sync.Mutex`, `bytes.Buffer`).
- **Receiver Consistency**:
  - Use **pointer receivers (`*T`)** if the method mutates state, contains non-copyable primitives (`sync.Mutex`), or if the struct is large.
  - Use **value receivers (`T`)** for small, immutable value objects where copying is cheap and mutation is forbidden. Never mix receivers arbitrarily on the same type.
- **Slice Aliasing & Backing Arrays**: Slices share underlying arrays when resliced. Modifying elements of a sub-slice modifies the original.
- **Map Concurrency**: Concurrent read/write to a standard map causes an unrecoverable runtime crash. Guard maps with `sync.RWMutex` or use `sync.Map` for read-heavy append-only caches.
- **Defensive Copying Rule**: Copy slices or maps **only when ownership or mutation semantics require it** (e.g. returning internal mutable collections to external callers). Do not copy blindly everywhere.

---

## Article IV: State Machine Engineering & Lifecycle Invariants

Model complex lifecycles (payments, order processing, workflow orchestration) as formal state machines:

```text
State + Allowed Event + Preconditions -> State Transition + Postconditions + Side Effects
```

### State Machine Rules
1. **Explicit Legal Transitions**: Define an explicit transition matrix. Reject all unlisted transitions with domain errors (`ErrInvalidStateTransition`).
2. **Terminal Boundaries**: Terminal states (`COMPLETED`, `CANCELLED`, `FAILED`) must reject all subsequent transition attempts or handle them as idempotent no-ops.
3. **Monotonic Version Fencing**: Persist a monotonic `version` or `updated_at` column in database records to guarantee that concurrent transition requests fail safely via optimistic locking.

---

## Article V: Distributed Systems & Effectively-Once Failure Semantics

> **Principle**: Exactly-once delivery cannot be assumed from message transport. Reason about **effectively-once business outcomes**.

```text
Delivery Semantics:
- At-Most-Once: Message may be lost; never duplicated.
- At-Least-Once: Message is guaranteed delivered; may be duplicated, reordered, or delayed.
- Effectively-Once: At-least-once transport + idempotent consumer state machine = single business outcome.
```

### Distributed Mandates
1. **Idempotency Keys & Request Fingerprints**:
   - Require unique idempotency keys for all mutating commands.
   - Bind key to a SHA-256 request payload fingerprint.
   - *Same key + same fingerprint*: Return saved business outcome without re-executing mutation.
   - *Same key + different fingerprint*: Reject immediately with `409 Conflict` (`ErrIdempotencyConflict`).
2. **Transactional Outbox Pattern**:
   - Write business state mutation AND outbox event in the **same atomic database transaction**.
   - Dispatchers poll/stream outbox records and publish to the message broker.
   - *Crash Window*: If the process dies between publishing and updating outbox status, the event is re-published on restart. Consumers **MUST** be idempotent.
3. **Poison Messages & Dead-Letter Queues (DLQ)**: Enforce bounded retries. Route unprocessable payloads to a DLQ rather than blocking the consumer pipeline indefinitely.

---

## Article VI: Database Concurrency, Transactions & Migrations

> **Principle**: If an invariant can be enforced by the database, enforce it in the database.

### Database Correctness Mandates
1. **Explicit Transaction Context**: Always use `db.BeginTx(ctx, &sql.TxOptions{...})` with `defer tx.Rollback()`.
2. **Prevent Lost Updates**: Never use naive `Get() -> mutate in memory -> Save()` under concurrency. Use:
   - Atomic SQL mutations (`UPDATE accounts SET balance = balance - $1 WHERE id = $2 AND balance >= $1`),
   - Optimistic version fencing (`WHERE version = $currentVersion`), or
   - Pessimistic row locking (`SELECT ... FOR UPDATE`).
3. **Database Constraints as Invariants**: Use `PRIMARY KEY`, `UNIQUE`, `CHECK`, and foreign keys. Never rely solely on application pre-checks.
4. **Zero-Downtime Schema Migrations (Expand/Contract)**:
   - *Phase 1 (Expand)*: Add new column as nullable or new table. Deploy code reading old, writing both.
   - *Phase 2 (Backfill)*: Migrate historical data in bounded batches.
   - *Phase 3 (Contract)*: Deploy code using only new schema. Remove old column.

---

## Article VII: Resource Ownership, Lifecycle & Cleanup Scopes

Every acquired resource must satisfy the **7-Part Resource Contract**:
```text
Creator | Owner | Transfer Rule | Lifetime | Release Authority | Failure Release Path | Shutdown Release Path
```

### Resource Mandates
- **`defer Close()` in Functions vs Loops**:
  - In normal functions: Place `defer resource.Close()` immediately after checking `err == nil`.
  - In loops: Do NOT `defer` inside loops (leaks descriptors until function exit). Close explicitly or wrap iterations in helper functions.
- **HTTP Response Body Draining**:
  ```go
  resp, err := client.Do(req)
  if err != nil {
      return fmt.Errorf("executing request: %w", err)
  }
  defer resp.Body.Close()
  // Bounded drain to enable HTTP/1.1 connection reuse without unbounded memory reads
  _, _ = io.Copy(io.Discard, io.LimitReader(resp.Body, 1<<20))
  ```

---

## Article VIII: HTTP, gRPC & Overload Defense

### Server & Client Mandates
- **Production Server Timeouts**: Always configure `ReadHeaderTimeout` (mitigates Slowloris), `ReadTimeout`, `WriteTimeout`, `IdleTimeout`, and `MaxHeaderBytes`. Never use raw `http.ListenAndServe`.
- **Client Transport Pooling**: Reuse a shared `*http.Client` with configured `Transport` connection pools (`MaxIdleConns`, `MaxIdleConnsPerHost`).
- **Payload Limits**: Wrap request readers with `http.MaxBytesReader` or `io.LimitReader` (e.g. max 10MB) to prevent memory exhaustion attacks.
- **Graceful Shutdown**: Listen for `SIGINT`/`SIGTERM` and execute `server.Shutdown(ctx)` with a bounded timeout.
- **Retry Engineering**:
  - Only retry known transient errors (`429` with `Retry-After`, `503`, network timeouts).
  - Never retry non-idempotent operations without an idempotency key.
  - Enforce exponential backoff with **Full Jitter** to prevent retry storms.

---

## Article IX: Structured Concurrency, Goroutine Lifecycles & Memory Model

Every goroutine must satisfy the **7-Part Goroutine Contract**:
```text
Owner | Start Condition | Stop Condition | Cancellation Check | Wait Mechanism | Error Propagation | Resource Cleanup
```

### Concurrency Mandates
- **Channel Ownership & Closure Authority**:
  - The producer/sender alone owns the channel and is the **only** entity permitted to close it.
  - Never close a channel from the receiver side or from multiple concurrent goroutines.
  - Sending to a closed channel causes an immediate, fatal panic.
- **Channels vs Mutexes**:
  - Use **channels** for ownership transfer, data streaming, coordination, and bounded queues.
  - Use **mutexes / atomics** for shared in-memory state, caches, counters, and small critical sections.
- **Structured Concurrency**: Use `golang.org/x/sync/errgroup` with context to coordinate sibling goroutines.
- **The Multi-Variable Atomicity Fallacy**: Individual atomic operations on multiple fields do NOT make multi-variable invariants atomic. Guard multi-variable invariants with a `sync.Mutex`.

---

## Article X: Security Baseline & Defensive OS Boundaries

### Security Mandates
- **DNS-Rebinding-Safe SSRF Prevention**:
  - Validate outbound URLs: restrict protocol to HTTPS, enforce hostname allowlists.
  - Intercept connections at the `net.Dialer.Control` / `DialContext` layer to validate resolved IP addresses at connection time against private/loopback/link-local/cloud-metadata ranges (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`, `127.0.0.0/8`, `169.254.0.0/16`, IPv6 `::1`, `fc00::/7`, `fe80::/10`, and IPv4-mapped IPv6 `::ffff:0:0/96`).
  - Enforce safe redirect checks that re-verify dialer restrictions on every hop.
- **Symlink-Safe Path Traversal Protection**: Sanitize paths using `filepath.Clean` and verify base directory containment using `filepath.EvalSymlinks` or `os.DirFS`. Ensure symlinks cannot escape the root boundary.
- **Subprocess Isolation**:
  - Always use `exec.CommandContext(ctx, "binary", args...)` with slice arguments. Never construct shell strings.
  - Attach a context timeout, set bounded `io.LimitReader` buffers on stdout/stderr, detect limit breaches with `ErrOutputLimitExceeded`, and ensure descendant process group termination (`syscall.Kill(-pgid, syscall.SIGKILL)` on Unix).
- **TLS & Secrets**: Never set `InsecureSkipVerify: true` in production. Never log credentials, API keys, or auth headers.

---

## Article XI: Error Taxonomy & Panic Policy

### The 14-Category Error Taxonomy
| Category | Meaning | HTTP Status | Action |
| :--- | :--- | :--- | :--- |
| **Validation** | Malformed input, missing fields | 400 Bad Request | Reject at boundary. No retry. |
| **Unauthorized** | Missing/invalid authentication | 401 Unauthorized | Reject at boundary. No retry. |
| **Forbidden** | Insufficient permissions | 403 Forbidden | Reject at boundary. No retry. |
| **Not Found** | Resource does not exist | 404 Not Found | Return error. No retry. |
| **Conflict** | Concurrent update / stale version / key conflict | 409 Conflict | Return error / reload & retry. |
| **Domain Rejection** | Business rule violation (e.g. insufficient funds) | 422 Unprocessable | Return domain error. No retry. |
| **Transient Infra** | DB lock timeout, network drop | 503 / 429 | Retry with bounded backoff & jitter (if idempotent). |
| **Permanent Infra** | DB syntax error, disk full | 500 Internal Error | Translate, log context, propagate. No retry. |
| **Timeout** | Operation deadline exceeded | 504 Gateway Timeout | Clean up resources, propagate error. |
| **Cancellation** | Client/context aborted | 499 / Canceled | Clean up resources, propagate error. |
| **Dependency Unavail** | Upstream API down | 502 / 503 | Circuit break / retry if idempotent. |
| **Resource Exhausted** | Rate limit, queue full | 429 / 503 | Load shed immediately. |
| **Programming Defect** | Nil pointer, boundary invariant breach | 500 Internal Error | Fail fast / recover at top boundary. |
| **Data Corruption** | Checksum failure, inconsistent DB state | 500 Internal Error | Halt mutation, alert on-call. |

### Panic Policy
- `panic` is reserved exclusively for unrecoverable startup configuration failures or internal invariant violations during development.
- Normal business failures, database errors, and network timeouts must NEVER panic.
- Recover panics only at top-level HTTP/worker recovery middleware to log stack traces and prevent process crashes.

---

## Article XII: Observability & Operational Invariants

> **Principle**: Log an error where it can be acted upon, not at every layer it passes through.

- **Structured Logging (`log/slog`)**: Include correlation IDs, request IDs, and operational attributes in `slog.Attr`.
- **The 4 Golden Signals**:
  - *Latency*: Track distribution histograms (p50, p95, p99), not merely averages.
  - *Traffic*: Measure request rates and throughput.
  - *Errors*: Measure explicit failure rates by error category.
  - *Saturation*: Track queue depths, connection pool utilization, and active worker counts.
- **Cardinals & Secrets**: Never log high-cardinality unbounded strings (e.g. raw request payloads) or sensitive tokens.

---

## Article XIII: Testing, Fuzzing & Failure Injection

> **Principle**: Test the invariant, not merely the implementation path.

```text
Unit Tests        → Pure business logic, state machines, domain models.
Integration Tests → Real PostgreSQL transactions, driver semantics, migration compatibility.
Concurrency Tests → Race detector (`go test -race`), lock contention, simultaneous state transitions.
Fuzz Tests        → Native Go fuzzing (`testing.F`) for parsers, decoders, serializers, and boundary sanitizers.
Failure Injection → Simulating DB disconnects, timeouts, partial commits, and crash recovery.
```

---

## Article XIV: The Adversarial Review Protocol

Before approving any Go code, verify:
```text
1. What if this operation succeeds halfway and the process crashes?
2. What if two instances execute this simultaneously?
3. What if this message or webhook is delivered twice or out of order?
4. What if the database transaction commits, but the external side effect fails?
5. Does every spawned goroutine have a guaranteed, bounded termination path?
6. Can capacity exhaustion (memory, connections, file descriptors) cause an unrecoverable outage?
7. Can version N and version N+1 of this code run concurrently during rolling deployments?
8. What proves this invariant survives concurrent adversarial execution?
```

### The Workflow Failure Matrix
For every critical distributed workflow, document:
| Failure Boundary | Possible State | Recovery Mechanism | Duplicate Risk | Protected Invariant |
| :--- | :--- | :--- | :--- | :--- |
| **Crash after DB commit** | DB committed, outbox pending | Outbox dispatcher replays event | At-least-once | Business state is durable |
| **Upstream timeout** | Command executed, ack lost | Client retries with Idempotency-Key | Handled by Inbox table | Exactly-once business outcome |
| **Concurrent state mutation** | Two workers debit same account | Stale version fails via optimistic CAS | Zero lost updates | Account balance non-negative |

---

## Article XV: The Proof-Before-Pass Protocol & Verification Gate

### Verdict Vocabulary
Every verification report must use explicit verdicts:
- **`PASS`**: Invariant is verified by executed automated tests exercising concurrency and failure paths.
- **`PASS WITH EXPLICIT ASSUMPTIONS`**: Verified under stated, documented operational constraints.
- **`FAIL`**: Invariant breach or failure mode unhandled.
- **`UNVERIFIED`**: Code compiled, but required environment (e.g. live PostgreSQL) was unavailable.
- **`BLOCKED BY ENVIRONMENT`**: Verification could not run due to missing toolchain/infra.

> [!CRITICAL]
> **`UNVERIFIED` MUST NEVER BE CONVERTED INTO `PASS`.**

---

### The Final Production Readiness Gate

Before declaring Go systems complete, verify:

- [ ] **State & Invariants**: Are state machine transitions legal, monotonic, and guarded by database constraints?
- [ ] **Concurrency Safety**: Is state protected from lost updates via atomic SQL, row locking, or optimistic versioning?
- [ ] **Effectively-Once Delivery**: Are mutating commands idempotent with idempotency keys or transactional outbox?
- [ ] **Goroutine Hygiene**: Does every goroutine have a guaranteed exit path and no leaks?
- [ ] **Channel Ownership**: Does only the producer close channels, with zero risk of send-on-closed panics?
- [ ] **Context Propagation**: Is `ctx` passed to all blocking I/O calls and never stored in struct fields?
- [ ] **HTTP & Network**: Are client transports pooled, server timeouts configured, and response bodies bounded & drained?
- [ ] **Database Transactions**: Are transaction boundaries explicit with `defer tx.Rollback()` and post-commit side effects?
- [ ] **Security Sanitization**: Are file paths sanitized, SSRF blocked at dialer level, and TLS verified?
- [ ] **Error Semantics**: Are errors wrapped with `%w`, classified correctly, and never silently ignored?
- [ ] **Observability**: Are logs structured with correlation IDs and operational metrics (Golden Signals) tracked?
- [ ] **Resource Limits**: Are queue sizes, body sizes, and connection pools strictly bounded against overload?
- [ ] **Adversarial Tests**: Did `go test -race`, table-driven tests, and native fuzz tests (`testing.F`) pass cleanly?
- [ ] **Toolchain Clean**: Did `go vet ./...` and static analysis pass with zero warnings?

---

## Status Declaration

```text
GO-CRAFTSMAN
STATUS: FROZEN
```

> **Final Law**: Clear is better than clever. Do not ask whether the code works on the happy path. Ask under which conditions it works, how it fails, how it recovers, and what evidence proves the invariant survives both concurrency and failure.

---

## License

This skill is open source under the [MIT License](LICENSE).

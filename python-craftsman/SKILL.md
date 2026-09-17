---
name: python-craftsman
description: >-
  Practical Python engineering guidance (Python 3.12+) focused on simple sufficient design,
  explicit failure semantics, data modeling, safe concurrency, and measurable performance.
license: MIT
---

# Python Craftsman: Python Engineering Principles

## Preamble & Universal Engineering Principles

> **Use the simplest design that is demonstrably correct for the actual problem. Add complexity only when a concrete requirement justifies it.**

### The 12 Cross-Skill Engineering Pillars
Every Python system must uphold and optimize for:
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

---

## 1. Simplicity & Architecture

Follow the **Complexity Escalation Model**. Only move downward when the simpler level cannot satisfy a concrete requirement:

```text
1. Function / module
   ↓ (when state + lifecycle/domain behavior require encapsulation)
2. Class / dataclass
   ↓ (when a dependency boundary, test seam, or multiple implementations exist)
3. Interface / Protocol
   ↓ (when isolating core domain logic from volatile infrastructure/frameworks)
4. Architectural boundary (Ports & Adapters)
   ↓ (only when distributed workflows, system scale, or service boundaries dictate)
5. Distributed / event-driven design
```

### Decision Rules
- **Prefer Plain Functions & Modules First**: Solve problems with pure functions and cohesive modules before introducing classes.
- **No Speculative Abstractions**: Do not introduce interfaces, ABCs, or base classes for hypothetical future flexibility.
- **Protocols & Interfaces**: Introduce an interface only when it creates a real benefit at a dependency boundary, test seam, or multiple-implementation requirement.
- **Dependency Injection**: Pass dependencies explicitly via function arguments or class `__init__`. Do not introduce DI frameworks for ordinary Python applications.
- **Architecture Follows Reality**: Match architecture to actual system complexity, not architectural fashion.

---

## 2. Data Modeling

Choose data structures based on data semantics and lifecycle requirements:

- **Value Objects**: Use `@dataclass(frozen=True)` when immutability improves correctness (e.g. coordinates, money, identifiers). Compare by value; validate invariants on construction.
- **DTOs / Events / Messages**: Use `@dataclass(frozen=True)` for internal immutable payloads.
- **Entities**: Use `@dataclass` or standard classes when an object has identity (`id`) and state transitions require mutation over its lifecycle.
- **Data Structure Selection**:
  - `dict`: Genuinely unstructured or dynamic key-value data.
  - `TypedDict`: Typed raw mappings (e.g. JSON payloads) without runtime validation overhead.
  - `@dataclass`: Internal structured application data and domain models.
  - `pydantic.BaseModel`: System ingress boundaries (HTTP APIs, CLI input, config parsing) where runtime parsing and validation are required.
- **Optimizations**: Use `slots=True` only when object memory usage is a demonstrated concern (e.g. millions of instances).

---

## 3. Database & Transaction Correctness

Database constraints are an integral part of application correctness.

> **Principle**: If an invariant can be enforced by the database, enforce it in the database.

### Decision Rules
- **Explicit Transaction Boundaries**: Always define the start and end of database transactions explicitly with context managers.
- **Never Rely Exclusively on Application Pre-Checks**: Do not rely only on `if not exists(...)` checks for uniqueness, ownership, or state transitions. Enforce `UNIQUE`, `CHECK`, and foreign key constraints in the database schema.
- **Concurrency Control**:
  - Use **optimistic concurrency** (version numbers / update timestamps) for low-contention workloads.
  - Use **pessimistic locking** (`SELECT ... FOR UPDATE`) only when justified by high contention or critical state invariants inside a transaction.
- **Idempotent Commands**: Design database mutating commands to be idempotent when replay or retry is possible (e.g. `INSERT ... ON CONFLICT DO NOTHING` or unique transaction keys).
- **Decouple External Side Effects**: Never send emails, call external webhooks, or publish message queue events inside an uncommitted database transaction. Execute external side effects only after the transaction successfully commits.
- **Test Rollback**: Rollback behavior under failure and constraint violations must be verified by tests, not assumed.

---

## 4. Resource Ownership & Lifecycle

> **Principle**: Resource ownership must be explicit, and every acquired resource must have a deterministic release path.

### Decision Rules
- **Single Owner**: Every acquired resource (file descriptors, DB connections, sockets, temporary files, subprocesses, locks) has exactly one clear owner responsible for its lifecycle.
- **Deterministic Cleanup via Context Managers**: Always use `with` / `async with` for resources supporting context management.
- **Cleanup on All Paths**: Cleanup must occur deterministically on success, failure, and cancellation (`try ... finally`).
- **Cancellation Safety**: Asynchronous cancellation must not leak open sockets, locked mutexes, or orphaned child processes.
- **No Ambiguous Mutation**: Do not close, release, or mutate resources owned by an outer scope unless ownership transfer is explicitly documented.

---

## 5. Configuration & Secrets

### Decision Rules
- **Validate at Startup**: Parse and validate all external environment variables and configuration files at application startup. Fail fast if mandatory configuration is missing or invalid.
- **Typed Configuration**: Parse raw environment variables into typed configuration objects (e.g. dataclass or Pydantic model).
- **Never Hardcode or Log Secrets**: API keys, passwords, and tokens must never be hardcoded, committed to VCS, or output to logs.
- **No Insecure Production Fallbacks**: Do not silently fall back to insecure default credentials or debug mode in production environments.
- **Distinguish Config Errors**: Treat invalid configuration as a startup failure, separate from runtime operational errors.

---

## 6. Subprocess & OS Boundaries

Subprocesses (e.g. `ffmpeg`, `ffprobe`, CLI utilities, external binaries) represent untrusted boundary operations.

### Decision Rules
- **Argument Lists Over Shell Strings**: Always pass command arguments as a list of strings (`['ffmpeg', '-i', input_path, ...]`). Avoid `shell=True` unless strictly required and justified.
- **Validate Executables**: Verify binary availability on `PATH` before invoking subprocesses.
- **Mandatory Timeouts**: Always set an explicit timeout on subprocess execution to prevent hanging worker processes.
- **Bounded Output Capture**: Capture `stdout` / `stderr` with size limits to prevent unbounded memory consumption from noisy subprocesses.
- **Inspect Exit Status**: Check return codes explicitly (`check=True` or verify `proc.returncode == 0`). Treat non-zero exit codes as failures unless the command contract dictates otherwise.
- **Terminate on Cancellation**: Ensure child processes are killed/terminated on cancellation or parent process exit to prevent orphaned processes.
- **Deterministic Temp File Cleanup**: Always remove temporary files created for subprocess operations inside `finally` blocks.

---

## 7. Error & Retry Semantics

### The 6 Failure Categories

| Failure Category | Examples | Correct Action |
| :--- | :--- | :--- |
| **1. Programmer Defect** | `TypeError`, `IndexError`, `KeyError`, assertion failures | **Fail loud and propagate.** Do not catch; fix the code. |
| **2. Invalid Input** | Malformed input, missing required fields | **Reject at the boundary** with clear context. Do not retry. |
| **3. Business Rejection** | Insufficient funds, duplicate resource | **Raise/return explicit domain error.** Do not retry. |
| **4. Transient Infrastructure Failure** | Network timeout, HTTP 503, DB lock conflict | **Retry only when safe, bounded, and idempotent.** |
| **5. Permanent Infrastructure Failure** | HTTP 404/401, disk full, DNS resolution failure | **Propagate or translate at boundary.** Do not retry. |
| **6. Cancellation** | `asyncio.CancelledError`, SIGINT | **Clean up resources in `finally` and ALWAYS re-raise.** |

### Error Handling Rules
- **Never catch `Exception` merely to retry or hide failure.**
- **Exception Specificity**: Use specific exceptions when callers need to distinguish failure types programmatically. Otherwise, standard built-in exceptions (`ValueError`, `LookupError`, `RuntimeError`) are sufficient.
- **Exception Chaining**: Use `raise NewError(...) from err` when translating across boundaries to preserve root-cause stack traces.

### Retry Rules
A retry is valid **only** when all of the following conditions are met:
1. The failure is **known to be transient** (e.g. `TimeoutError`, `ConnectionResetError`). Never retry generic `Exception` or programmer errors.
2. The operation is **idempotent** or protected by an idempotency key.
3. Attempts are **strictly bounded** (e.g. max 3 attempts).
4. Backoff is **bounded** with exponential delay.
5. **Jitter is used** where concurrent clients could synchronize (thundering herd).
*Do not make retry decorators a default architectural pattern; inline retries at the specific I/O boundary.*

---

## 8. Observability

> **Principle**: Log an error where it can be acted upon, not at every layer it passes through.

### Decision Rules
- **Structured Contextual Logging**: Include operational context (request IDs, job IDs, user IDs) in log entries via `extra` parameters.
- **No Duplicate Logging**: Avoid logging the same exception repeatedly across multiple architectural layers; catch, chain, and log once at the handling boundary.
- **No Sensitive Data**: Never log passwords, access tokens, credentials, or PII.
- **Operational Metrics**: Track latency, throughput, error rate, retry counts, and queue depth for critical operations.
- **No Side Effects on Correctness**: Logging must never alter control flow, swallow errors, or mutate application state.

---

## 9. Concurrency & Async

Use concurrency **only** when it solves a measurable I/O or CPU throughput/latency problem. Concurrency improves performance only when the workload and dependencies benefit from it.

- **I/O + Async-native dependencies**: Use `asyncio`.
- **Blocking I/O**: Use `concurrent.futures.ThreadPoolExecutor` or `asyncio.to_thread`.
- **CPU-heavy work**: Use `concurrent.futures.ProcessPoolExecutor` or process-based parallelism.
- **Simple / Sequential workflows**: Use synchronous execution.

### Concurrency Rules
- **`TaskGroup` vs `gather`**:
  - Use `asyncio.TaskGroup` (Python 3.11+) for related tasks that should fail together (failure in one cancels siblings).
  - Use `asyncio.gather(*tasks, return_exceptions=True)` **only** when partial results are intentionally valid, each returned exception is explicitly inspected, and the caller cannot mistake partial failure for total success.
  > [!WARNING]
  > `return_exceptions=True` must never be used merely to keep a pipeline running after an unexpected failure.
- **Backpressure & Limits**: Always bound concurrency using `asyncio.Semaphore` or bounded `asyncio.Queue(maxsize=...)` to prevent resource exhaustion.
- **Timeouts**: Enforce explicit timeouts on remote operations using `asyncio.timeout(seconds)`.
- **Cancellation**: Catch `CancelledError` only for local resource cleanup in `finally`, and **always re-raise it**.

---

## 10. Performance

Follow the principle: **Measure → identify bottleneck → optimize → measure again.** Never optimize based purely on assumption.

### Optimization Priority
```text
1. Algorithm & Data Structure (e.g. O(1) set lookup vs O(n) list scan)
   ↓
2. I/O & Network batching (reduce round-trips)
   ↓
3. Query design & indexing (eliminate N+1 queries, add DB indexes)
   ↓
4. Concurrency model (async for I/O, multiprocessing for CPU)
   ↓
5. Memory allocation (streaming generators for large files, slots for large collections)
   ↓
6. Micro-optimization (only when measured by cProfile / tracemalloc)
```

- **Generators**: Stream large files/datasets lazily with generators to maintain constant memory overhead.
- **Caching**: Use `@functools.lru_cache(maxsize=...)` with an explicit maximum size. Ensure arguments are hashable and cache invalidation is understood.

---

## 11. Testing: Invariants, Concurrency & Replay

> **Principle**: Test the invariant, not merely the implementation path.

Target tests to actual operational risk:

- **Unit Tests**: Pure business logic, state machines, and deterministic algorithms.
- **Integration Tests**: Real database transactions, filesystem operations, external client adapters, and subprocesses.
- **Contract Tests**: External API schemas, serialization formats, and boundary protocols.
- **End-to-End Tests**: Critical user workflows and system paths.

### Advanced Testing Rules
- **Invariant Tests**: Assert domain invariants directly (e.g. balance non-negativity, state transition validity, unique identity conservation).
- **Concurrency Tests**: Test race-sensitive operations (concurrent writes, duplicate creation, lock contention) without relying on arbitrary `sleep()` calls.
- **Replay & Idempotency Tests**: Explicitly test duplicate command submission, retry after partial failure, and retry after rollback.
- **Cancellation Tests**: Verify that cancelling tasks propagates cleanly, releases acquired resources, and leaves no corrupted state.
- **Fakes Over Complex Mocks**: Prefer simple in-memory fakes over fragile `MagicMock` hierarchies when testing dependency boundaries.

---

## 12. Verification Gate

Before declaring code complete, verify:

- [ ] **Simplicity**: Is this the simplest design that satisfies the requirement?
- [ ] **No Speculative Code**: Did I add any class, interface, or layer without a concrete reason?
- [ ] **Database Invariants**: Are database-enforceable invariants enforced by the database schema?
- [ ] **Explicit Transactions**: Are transaction boundaries explicit, with external side effects decoupled?
- [ ] **Resource Ownership**: Does every acquired resource have an explicit owner and deterministic cleanup?
- [ ] **Cancellation Safety**: Cannot leak sockets, locks, subprocesses, or corrupt state on cancellation?
- [ ] **Startup Config & Secrets**: Is configuration validated at startup, with secrets kept out of code and logs?
- [ ] **Subprocess Safety**: Are subprocess calls using argument lists, explicit timeouts, and exit-code validation?
- [ ] **Explicit Failures**: Are failure modes categorized, with cancellation always re-raised?
- [ ] **Safe Retries**: Are retries strictly bounded, transient-only, and idempotent?
- [ ] **Justified Concurrency**: Is concurrency justified by workload, with bounded queues/semaphores?
- [ ] **Invariant-Focused Tests**: Are business invariants, rollback, retries, and race conditions tested?
- [ ] **Measured Performance**: Were performance changes driven by measurement rather than assumption?
- [ ] **Maintainability**: Does the code remain clear, robust, and understandable to another engineer?

---

## Status Declaration

```text
PYTHON-CRAFTSMAN
STATUS: FROZEN
```

> **Final Law**: Modern Python is a toolbox, not a design requirement. Prefer clear, direct code over clever constructs. The desired outcome is the simplest correct design that will survive production requirements.

---

## License

This skill is open source under the [MIT License](LICENSE).

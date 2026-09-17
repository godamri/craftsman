---
name: rust-craftsman
description: >-
  Practical Rust systems engineering guidance (Rust 2021/2024) focused on memory safety,
  sound ownership, explicit error propagation, async Tokio task lifecycles, and verification gates.
license: MIT
---

# Rust Craftsman: Rust Systems Engineering

## Preamble & Universal Engineering Principles

> **Memory safety without garbage collection is a superpower, but only when paired with sound domain modeling.**  
> **Use the simplest design that provides the required safety, correctness, resilience, and operational guarantees. Complexity must earn its place.**  
> **Make illegal states unrepresentable through the type system where appropriate. Treat errors as first-class values.**

### The 12 Cross-Skill Engineering Pillars
Every Rust system, library, service, and CLI tool must uphold and optimize for:
```text
1. Resilience       — Systems survive panics, network timeouts, broker disconnections, and degraded dependencies.
2. Reliability      — Predictable ownership, deterministic invariants, and reproducible async state transitions.
3. Adaptability     — Trait-based interfaces and clean boundaries allow evolution without fragile breaking changes.
4. Maintainability  — Expressive type-driven APIs, self-documenting pattern matching, and explicit ownership boundaries.
5. Recoverability   — Explicit Result<T, E> propagation, graceful async task cancellation, and deterministic RAII cleanup.
6. Security         — Memory safety invariants, bounds-checked indexing, constant-time cryptography, and zero secret leakage.
7. Observability    — High-fidelity telemetry: structured spans and logs via tracing, metrics, and causality context propagation.
8. Simplicity       — Write idiomatic, direct Rust; avoid premature optimization, cargo-cult Cow/lifetimes, or over-abstracted trait hierarchies.
9. Consistency      — Standard error idioms, uniform naming conventions, and cohesive module hierarchies across crates.
10. Verifiability   — Provable correctness via unit tests, property testing (proptest), miri (UB checks), and clippy release gates.
11. Controlled Change — SemVer-compliant crate public APIs, backward-compatible serialization, and documented deprecation cycles.
12. Long-Term Durability — Robust against compiler upgrades, minimal dependency footprint, and proactive security audit reviews.
```

### Priority Meta-Rule
> **No Rust implementation may optimize for developer convenience or micro-performance by silently violating safety, correctness, or sound ownership invariants.**  
> - Correctness beats convenience.  
> - Type-driven compile-time guarantees beat runtime assertions where lifecycle invariants are stable.  
> - Explicit error propagation (`Result<T, E>`) beats panics (`unwrap()`).  
> - Safe, sound abstractions beat unverified `unsafe` blocks.  
> - RAII cleanup must execute deterministically on all return paths.  
> - Simple sufficient designs beat premature zero-allocation micro-optimization.

---

## Core Rust Principles

### 1. Ownership, Practical Borrowing & Memory Representation
- Prefer immutable borrows (`&T`) for read-only access, exclusive borrows (`&mut T`) for in-place mutation, and moves (`T`) when transferring ownership.
- Let the compiler elide lifetimes where possible; declare explicit lifetimes (`'a`) only when input/output reference relationships are ambiguous.
- Do not introduce borrowing complexity, `Cow`, or lifetime proliferation without empirical evidence that allocation behavior materially impacts requirements. `String`, `Vec<T>`, `Box<T>`, and `Arc<T>` are all standard, legitimate tools.
- Ordinary Rust struct layout is not guaranteed to be stable across compiler versions; explicit memory layout requirements MUST use documented representations (e.g. `#[repr(C)]`, `#[repr(transparent)]`).

### 2. Typestate vs Runtime State Machines
- **Typestate Pattern**: Use compile-time state markers (e.g. `Order<Draft>` $\to$ `Order<Submitted>`) when lifecycle invariants are stable, local, and materially strengthened by compile-time transition enforcement.
- **Runtime State Machines**: Use runtime state enums when state is externally persisted in databases, dynamically determined at runtime, or when typestate would artificially complicate operational boundaries without safety gains.

### 3. Explicit Error Handling (`Result<T, E>`) & Panic Policy
- **Domain & Library Crates**: Define strongly typed error enums using `thiserror`.
- **Application Ingress & CLI**: Use `anyhow::Result<T>` or `eyre` to attach contextual backtraces.
- **Production Panic Policy**: Calling `.unwrap()` or `.expect()` in production request paths is strictly prohibited unless accompanied by an explicit invariant proof comment (`// INVARIANT:`). An invariant comment is not an excuse for convenience; proper error propagation (`?`) is the required default. (Tests, benchmarks, and example runners may use unwrap/expect to assert test fixture defects).

### 4. Async Tokio Lifecycle & Cancellation vs Atomicity
- **Cancellation Safety**: Async futures can be dropped at any `.await` point (e.g. in `tokio::select!` or on timeout). Futures must be designed so that dropping them does not corrupt in-memory state.
- **Cancellation $\neq$ Transactional Atomicity**: Dropping a future does NOT roll back external database or network side effects. Multi-step operations crossing boundaries must establish correctness via explicit database transactions, idempotency keys, outbox/inbox patterns, or compensating actions.
- **Runtime Offloading**: Blocking file I/O and short synchronous blocking work MUST use `tokio::task::spawn_blocking`. Sustained or highly parallel CPU workloads MUST use a dedicated CPU execution pool (e.g. Rayon or a custom thread pool). Never run long blocking operations directly on Tokio worker threads.

### 5. Task Ownership, Lifecycle & Graceful Shutdown
- Every spawned async task MUST have an explicit owner, a cancellation mechanism (e.g. `CancellationToken`), and a join/observation strategy. Detached "fire-and-forget" tasks are prohibited in production services.
- **Deterministic Graceful Shutdown Sequence**:
  ```text
  1. STOP ACCEPTING NEW WORK
  2. SIGNAL CANCELLATION / DRAIN (via CancellationToken)
  3. DRAIN ACCEPTED JOBS & FLUSH STATE
  4. RELEASE RESOURCES
  5. JOIN & CONFIRM TASK TERMINATION
  ```

### 6. Concurrency, Mutex Discipline & Channels (`Send` + `Sync`)
- Shared state must respect `Send` and `Sync` invariants.
- **Mutex Selection & Scoping**:
  - Use `std::sync::Mutex<T>` or `parking_lot::Mutex<T>` for short, synchronous critical sections. A synchronous `MutexGuard` MUST NOT be held across an `.await` point (prevents thread starvation, runtime deadlocks, and non-Send futures).
  - Use `tokio::sync::Mutex<T>` only when asynchronous waiting while holding the lock is genuinely required.
- **Channel Semantics**:
  - `mpsc`: Bounded queues (`channel(n)`) for task pipelines with backpressure.
  - `oneshot`: Single-value request/response handshakes.
  - `watch`: State distribution retaining the latest value for multiple subscribers.
  - `broadcast`: Fan-out event streaming where lagging receivers may skip missed messages.

### 7. Soundness & The `unsafe` Isolation Boundary
- `unsafe` shifts the burden of proof to the engineer. Every `unsafe` block must be encapsulated within a safe, sound public API.
- Under Rust 2024 rules (`unsafe_op_in_unsafe_fn`), unsafe operations inside an `unsafe fn` must remain explicitly scoped in `unsafe {}` blocks.
- Every `unsafe` block must have a preceding `// SAFETY:` comment detailing the invariants relied upon.
- Validate unsafe code with `cargo miri test` where supported, complemented by property testing, fuzzing, and code review.

### 8. Static vs Dynamic Dispatch
- Choose static dispatch (`impl Trait`, generics) or dynamic dispatch (`dyn Trait`, `Box<dyn Trait>`) based on concrete architectural needs, compilation times, binary size, and dependency boundaries—not ideology.
- Dynamic dispatch is appropriate for runtime polymorphism, plugin architectures, test seams, and reducing monomorphization bloat.

### 9. System-Wide Backpressure & Load Shedding
- Backpressure must propagate from downstream dependencies (database, external APIs) toward ingress queues rather than being concealed by unbounded buffering or uncontrolled task spawning.
- Unbounded channels (`mpsc::unbounded_channel()`) are prohibited on untrusted ingress paths.

### 10. Timeout & Retry Discipline
- All external network and I/O operations (HTTP, DB, Redis, gRPC) MUST have explicit or inherited bounded timeouts.
- Retries MUST be bounded, cancellation-aware, timeout-aware, jittered (Full Jitter), and restricted to transient failures on **idempotent** operations. Guard explicitly against retry storms.

### 11. Idempotency & Distributed State Transitions
- Operations crossing process, network, or persistence boundaries must define idempotency semantics where retries, duplicate delivery, or replays are possible. Use idempotency keys, inbox deduplication tables, or optimistic database version fencing.

### 12. Empirical Verification & Quality Gates
- **Zero Warnings**: Enforce `RUSTFLAGS="-D warnings" cargo check`.
- **Linter & Formatting**: `cargo clippy --all-targets --all-features -- -D warnings` and `cargo fmt -- --check`.
- **Dependency Audit**: Run `cargo audit` to identify known CVEs in dependencies; remediate or document explicit risk disposition.
- **Unmanaged Cycles**: Avoid unmanaged strong-reference cycles (`Rc`/`Arc` cycles); use `Weak<T>` for back-references.

---

## Explicit Prohibitions

1. **PROHIBITED**: Calling `.unwrap()` or `.expect()` on fallible `Option` or `Result` in production request paths without an invariant proof comment.
2. **PROHIBITED**: Holding a synchronous `std::sync::MutexGuard` across an `.await` boundary in async functions.
3. **PROHIBITED**: Running blocking I/O or heavy synchronous CPU compute directly on Tokio async worker threads.
4. **PROHIBITED**: Writing `unsafe` blocks without documented `// SAFETY:` proofs or failing to encapsulate them in sound abstractions.
5. **PROHIBITED**: Spawning detached, unmonitored background tasks without an explicit lifecycle and cancellation strategy.
6. **PROHIBITED**: Unbounded channels (`mpsc::unbounded_channel()`) or unbounded retry loops without backpressure/jitter.
7. **PROHIBITED**: Unmanaged strong-reference cycles (`Rc`/`Arc`) that prevent deterministic resource reclamation.

---

## The Rust Production Readiness Gate

Before certifying any Rust crate, service, or feature for production:

- [ ] **Typestate vs Runtime State Evaluated**: Are lifecycle states modeled with typestate (local/stable) or runtime enums (persisted/dynamic) appropriately?
- [ ] **Error Propagation Complete**: Are domain errors typed (`thiserror`), ingress errors contextualized (`anyhow`), and production paths free of stray panics?
- [ ] **Cancellation & Atomicity Checked**: Is in-memory async cancellation safe, and are external multi-step mutations protected by transactions/idempotency?
- [ ] **Runtime Offloading Correct**: Is blocking I/O offloaded to `spawn_blocking` and sustained CPU work to a dedicated compute pool?
- [ ] **Task Ownership & Shutdown Defined**: Does every spawned task have a supervisor owner, `CancellationToken`, and deterministic drain sequence?
- [ ] **Mutexes & Channels Bounded**: Are mutexes dropped before `.await`, and do all `mpsc` channels enforce bounded backpressure?
- [ ] **Timeouts & Jittered Retries Configured**: Do all external I/O calls have explicit timeouts and bounded, jittered retries on idempotent paths?
- [ ] **`unsafe` Blocks Sound & Documented**: Does every `unsafe` block have a `// SAFETY:` proof comment and pass `cargo miri` where applicable?
- [ ] **Clippy & Audit Clean**: Does the crate pass `cargo clippy -- -D warnings` and `cargo audit` with zero unresolved high/critical CVEs?

---

## Status Declaration

```text
RUST-CRAFTSMAN
STATUS: FROZEN
```

> **Final Law**: Rust empowers you to build software that is blazingly fast, memory-safe, and utterly resilient. Keep designs simple, let the type system protect invariants where appropriate, handle failures explicitly, and never compromise safety for convenience.

---

## License

This skill is open source under the [MIT License](LICENSE).

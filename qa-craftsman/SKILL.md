---
name: qa-craftsman
description: >-
  Practical quality assurance guidance focused on risk-based testing,
  invariant assertions, concurrency verification, failure injection, and deterministic release gates.
license: MIT
---

# QA Craftsman: Quality Assurance & Verification

## Preamble & Universal Engineering Principles

> **Passing tests is evidence, not proof, unless the verification scope is explicitly defined.**  
> **Quality assurance is not a final sign-off phase; it is the adversarial discipline of falsifying assumptions.**  
> **A test that never fails when the system breaks is worse than no test at all.**

### The 12 Cross-Skill Engineering Pillars
Every test suite, verification pipeline, and release gate must uphold and optimize for:
```text
1. Resilience       — Test suites verify system survival under network drops, process crashes, and service degradation.
2. Reliability      — Test execution is 100% deterministic; zero tolerance for intermittent "flaky" tests.
3. Adaptability     — Test suites evolve smoothly with refactoring by testing business invariants rather than private implementation details.
4. Maintainability  — Clean test fixtures, self-describing assertions, isolated test states, and fast execution feedback.
5. Recoverability   — Automated tests explicitly verify rollback procedures, crash recovery, and state reconciliation.
6. Security         — Adversarial security verification: fuzzing, boundary probing, auth bypass testing, and payload injection.
7. Observability    — Test suites assert telemetry signals: structured logs, trace propagation, metrics, and error classifications.
8. Simplicity       — Favour simple in-memory fakes and direct invariant assertions over fragile multi-layer mock hierarchies.
9. Consistency      — Verification standards, test data factories, and failure categorization are uniform across all layers.
10. Verifiability   — Every requirement and contract has corresponding automated, repeatable verification evidence.
11. Controlled Change — Automated release gates prevent deployment of regressions, breaking schema changes, or flaky code.
12. Long-Term Durability — Tests act as living, executable specifications that protect the system against regression across years.
```

### Priority Meta-Rule
> **No release gate may accept speed or convenience over verified correctness.**  
> - Evidence beats assumption.  
> - Invariant testing beats happy-path confirmation.  
> - Deterministic fakes beat fragile mocks.  
> - Flaky tests are defects and must be quarantined and fixed immediately.  
> - Recovery must be proven by test before shipping to production.

---

## Core QA & Verification Principles

### 1. The Evidence Over Assumption Axiom
Never assume code works because "it compiles" or "it worked on my machine". Verification requires automated, reproducible evidence covering expected behavior, failure behavior, boundary edge cases, and recovery paths.

### 2. Test Invariants, Not Implementation Details
Tests must assert observable behavioral contracts and system invariants (e.g. "Balance never drops below zero", "All paid orders produce an outbox record"), rather than private method calls or internal variable states. Refactoring internal code should not break valid invariant tests.

### 3. The Risk-Based Verification Pyramid
Structure test investment according to risk, execution speed, and fidelity:
```text
      ▲
     / \     E2E / Synthetic Probes (Smoke test critical user paths only)
    /   \    Contract & Schema Tests (API boundary and serialization compatibility)
   /     \   Integration Tests (Real database transactions, migrations, and concurrency)
  /       \  Unit & Invariant Tests (Pure business logic, state transitions, algorithms)
 ─────────
```

### 4. Negative & Boundary Exploration
Every positive happy-path test must be paired with adversarial negative tests:
- *Boundary Limits*: Zero, maximum integer values, empty arrays, oversized payloads, invalid UTF-8.
- *Temporal Edges*: Expired tokens, clock jumps, leap seconds, timeout expirations.
- *Invalid States*: Replaying already-cancelled orders, duplicate IDs, unauthorized tenant access.

### 5. Concurrency & Race Condition Verification
Concurrently mutating operations (e.g. transfers, inventory claims, status updates) must be tested with parallel worker threads/goroutines synchronized via deterministic barriers (`sync.WaitGroup`), NOT random `sleep()` calls. The test suite must be verified with thread sanitizers (`go test -race`, Python `ThreadSanitizer`).

### 6. Failure Injection & Chaos Verification
Resilience is only proven when failures are injected. Tests must simulate:
- Database connection resets and lock timeouts.
- External HTTP 500, 503, and network timeouts.
- Process termination mid-transaction.
- Stale distributed lock tokens.

### 7. Contract & Backward Compatibility Verification
API schemas (OpenAPI, Protobuf) and database migration scripts must be verified for backward and forward compatibility. Test suites must prove that Version $N$ clients can communicate with Version $N+1$ servers.

### 8. Deterministic Test Isolation & No Shared State
Every test case must execute in complete isolation. Tests must set up their own test fixtures and clean up after execution. Tests must never depend on the execution order of other tests or share mutable in-memory state.

### 9. Zero Tolerance for Flaky Tests
A test that passes or fails unpredictably without code changes destroys trust in the verification pipeline. Flaky tests are treated as P0 bugs: quarantine immediately, isolate the root cause (unbounded timeouts, race conditions, shared state), and fix before merging.

### 10. Fakes Over Complex Mock Hierarchies
Prefer lightweight in-memory fakes (e.g. `InMemoryAccountRepository`) over deep, brittle mock frameworks. Fakes implement real interface contracts and state transitions, ensuring tests verify realistic behaviors.

### 11. Automated Release Gates
Deployment pipelines must enforce strict, non-bypassable quality gates:
- 100% test pass rate with zero quarantined tests.
- Static analysis and vulnerability scan passing.
- Database migration rollback drill passing.
- Backward compatibility verification passing.

### 12. Defect Root-Cause Taxonomy
Every production defect must be categorized into its root cause:
- *Logic Defect*: Invariant missing in unit tests.
- *Concurrency Defect*: Unsynchronized race condition.
- *Boundary Defect*: Unhandled payload or network timeout.
- *Contract Drift*: Unchecked schema mismatch between services.
A corresponding regression test must be added to the suite before the fix is considered complete.

---

## Explicit Prohibitions

1. **PROHIBITED**: Marking code complete with only happy-path unit tests.
2. **PROHIBITED**: Using arbitrary `sleep()` delays to synchronize asynchronous or concurrency tests.
3. **PROHIBITED**: Tolerating flaky tests in CI/CD pipelines.
4. **PROHIBITED**: Testing private implementation methods directly instead of public behavioral interfaces.
5. **PROHIBITED**: Disabling or bypassing automated release gates during production deployments.
6. **PROHIBITED**: Writing tests that rely on external live network services or unisolated shared databases.
7. **PROHIBITED**: Merging bug fixes without adding a deterministic regression test.

---

## The QA & Verification Readiness Gate

Before certifying any feature, service, or release:

- [ ] **Invariants Asserted**: Are core business rules explicitly asserted across all state transitions?
- [ ] **Negative Scenarios Covered**: Are invalid inputs, unauthorized calls, and boundary limits tested?
- [ ] **Concurrency Tested**: Are race conditions verified with concurrent workers and race detectors?
- [ ] **Failures Injected**: Is behavior tested under network timeouts, 503 errors, and database rollbacks?
- [ ] **Contracts Compatible**: Are API and event schema migrations proven backward-compatible?
- [ ] **Tests Deterministic**: Do tests run 100 times in a loop without a single flaky failure?
- [ ] **Fakes Used Appropriately**: Are in-memory fakes verified against the same contracts as real adapters?
- [ ] **Release Gates Green**: Are all static analysis, security scans, and test suites passing?

---

## Status Declaration

```text
QA-CRAFTSMAN
STATUS: FROZEN
```

> **Final Law**: Quality is the systematic elimination of unverified assumptions. Build tests that challenge the system under its worst possible conditions.

---

## License

This skill is open source under the [MIT License](LICENSE).

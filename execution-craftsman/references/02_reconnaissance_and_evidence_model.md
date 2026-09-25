# Repository Reconnaissance & Evidence Model

> **Core Principle**: Evidence strength is claim-dependent. What evidence directly proves this specific claim?

---

## 1. Repository Reconnaissance Protocol

Before writing any new code or creating files, an agent must conduct systematic repository reconnaissance:

1. **Search for Canonical Implementations**:
   - How do existing features in this codebase implement similar workflows?
   - What base classes, interfaces, or traits are standard?
2. **Inspect Neighboring Modules**:
   - How are errors wrapped and propagated?
   - How are transactions opened, committed, and rolled back?
3. **Inspect Runtime Lifecycles & Registrations**:
   - Are services registered via dependency injection, plugin registries, or factory maps?
   - How are routes or event handlers exposed?
4. **Inspect Existing Test Fixtures**:
   - What test harness, database fakes, or synthetic runners already exist?
   - How do existing tests seed data and isolate state?

```text
Evidence Priority:
Existing repository evidence  >  Canonical project patterns  >  Framework documentation  >  Agent assumptions
```

---

## 2. Claim-Dependent Evidence Selection

Do not apply a rigid, one-size-fits-all hierarchy. Match the evidence type to the exact claim being verified:

| Significant Claim | Required Evidence Type | Example Demonstration |
| :--- | :--- | :--- |
| **Syntactic / Interface Validity** | Compiler / Type Checker | `go vet`, `tsc`, or `cargo check` passing with zero errors. |
| **Algorithmic Correctness** | Unit Invariant Test | Pure function tested across boundary values and edge cases. |
| **Data Persistence & Durability** | Storage Reload Drill | Record written, committed, session destroyed, and re-read from disk/DB. |
| **Concurrency Safety** | Multi-Worker Race Test | 50 concurrent workers hitting shared resource with thread/race sanitizer. |
| **Failure Recovery / Rollback** | Fault Injection Test | Injected network 503 or database timeout proving transactional rollback. |
| **End-to-End User Flow** | Integration / API Harness | Full HTTP request/response cycle traversing routing, auth, domain, and DB. |
| **Production Readiness** | Operational Telemetry | Real load profiles, canary SLO monitoring, and disaster recovery drills. |

---

## 3. Epistemic Discipline: FACT vs INFERENCE vs UNKNOWN

Never blur the boundary between verified facts and reasonable assumptions:

### `FACT`
A statement backed by concrete, reproducible evidence directly observed in the repository, compiler, or test execution.
- *Example*: `FACT: Table 'orders' contains a UNIQUE index on 'idempotency_key'.`

### `INFERENCE`
A plausible conclusion derived from pattern observation, but not directly tested in the current execution.
- *Example*: `INFERENCE: The repository uses optimistic locking because entities define a 'version' column, but concurrent update conflict has not yet been executed in a test.`

### `UNKNOWN`
A condition where evidence is absent or environmental limitations prevent verification.
- *Example*: `UNKNOWN: Behavior of the webhook delivery worker when the third-party gateway responds with HTTP 429 Retry-After.`

> **Rule**: An agent must explicitly label claims where ambiguity exists. Never elevate an `INFERENCE` to a `FACT` without executing the corresponding test.

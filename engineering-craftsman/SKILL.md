---
name: engineering-craftsman
description: >-
  Practical software engineering guidance focused on requirements validation,
  domain modeling, transaction boundaries, failure handling, security invariants, testing, and release gates.
license: MIT
---

# Engineering Craftsman: Engineering Operating Principles

## Preamble & Core Engineering Principles

> **Build the simplest system that can reliably satisfy the real business requirement.**  
> **Correctness is more valuable than cleverness. Reliability is a feature. Security is an architectural property.**  
> **A feature is not complete when the code works; it is complete when the organization can safely operate, observe, and recover it in production.**  
> **Every irreversible action requires disproportionate care. Complexity must earn its existence.**

---

## 1. The Engineering Priority Hierarchy

When engineering trade-offs conflict, resolve decisions according to this explicit hierarchy:

```text
 1. Human Safety / Legal / Regulatory Obligations
 2. Business Correctness
 3. Data Integrity
 4. Security
 5. Reliability
 6. Recoverability
 7. Operational Safety
 8. Maintainability
 9. Scalability
10. Performance
11. Delivery Speed
12. Developer Convenience
13. Micro-Optimization
```

> [!IMPORTANT]
> **Engineering Judgment Rule**: This hierarchy is a principled guide, not a mindless algorithm. When two dimensions conflict, evaluate the concrete blast radius, financial impact, and reversibility before deciding. Never sacrifice dimensions 1–6 for short-term speed or convenience.

---

## 2. The Three Correctnesses

Every production software system must be evaluated across three distinct dimensions of correctness:

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ 1. TECHNICAL CORRECTNESS                                                               │
│    Memory safety, type soundness, concurrency safety, protocol conformance,            │
│    resource lifecycle bounds, and zero undefined behavior.                            │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 2. BUSINESS CORRECTNESS                                                                │
│    Accurate pricing, valid state machine transitions, exact accounting balances,        │
│    proper tenant authorization, and adherence to business rules and regulatory laws.    │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 3. OPERATIONAL CORRECTNESS                                                             │
│    Safe restarts, idempotent retries, non-blocking migrations, deterministic rollback, │
│    observable failure signals, bounded degradation, and automated reconciliation.       │
└────────────────────────────────────────────────────────────────────────────────────────┘
```
A system that is technically flawless but business-incorrect is worthless. A system that is business-correct but operationally unrecoverable is an existential liability.

---

## 3. The 12 Core Constitutional Laws

### 1. Business-First Engineering & Economic Justification
Engineering exists to create durable business value and mitigate enterprise risk. Every significant project must establish its problem statement, target users, measurable business value, opportunity cost, total lifecycle cost (implementation + operational maintenance), and non-goals before architectural commitment.

### 2. Strict Requirements & Verification Seams
Requirements must clearly differentiate functional rules, non-functional constraints, security policies, and operational expectations. Every critical requirement must have a designated owner, an automated verification method, and an explicit blast-radius evaluation if violated.

### 3. Multi-Tier Invariant Enforcement
Domain invariants must never exist solely in documentation, comments, frontend validation, or developer memory. Invariants must be enforced at the strongest practical boundary:
$$\text{Type System} \longrightarrow \text{Application Domain Model} \longrightarrow \text{Database Constraints} \longrightarrow \text{Infrastructure}$$

### 4. Anti-Overengineering & Complexity Budgets
Complexity must earn its existence through measurable requirements. Prefer modular monoliths and standard relational schemas before introducing microservices, event sourcing, distributed caches, or bespoke frameworks. If a simpler architecture satisfies the required business invariants and operational SLOs, the simpler architecture MUST be chosen.

### 5. System Boundaries & Single Source of Truth
Every piece of persistent state must have exactly one authoritative source of truth. Caches, read replicas, search indices, and client projections are derived views and must never authorize state mutations or make binding invariant decisions. Explicitly draw and defend trust boundaries, transaction boundaries, and tenant boundaries.

### 6. Transactional State & Explicit State Transitions
Every state-changing workflow must define its complete lifecycle:
$$\text{Attempted} \longrightarrow \text{Accepted} \longrightarrow \text{Committed} \longrightarrow \text{Published} \longrightarrow \text{Settled} \longrightarrow \text{Reconciled}$$
Never conflate transport success (e.g. `HTTP 200 OK`) with business transaction settlement.

### 7. Universal Idempotency by Contract
Any operation exposed to retries, asynchronous queues, user retries, webhook deliveries, or network timeouts must be strictly idempotent. Command payloads must carry unique Idempotency Keys bound to request fingerprints. Duplicate executions must produce identical business outcomes without side-effect amplification.

### 8. Failure Engineering & Graceful Degradation
Systems must be designed to fail safely and predictably. Every external I/O call must have an explicit timeout, circuit breaking, and bounded retry policy with randomized jitter. Non-critical subsystem failures must gracefully degrade without cascading to unseat the core business path.

### 9. Fail-Closed Security & Defense-in-Depth
Security is an unyielding correctness invariant. Systems default to denying access (`Deny All`). Authenticate principals explicitly, enforce least privilege on authorization, parameterize all queries against injection, externalize secrets from code/logs, and treat all inputs crossing trust boundaries as hostile.

### 10. Deep Observability & Causal Auditability
Production systems must emit structured signals (metrics, distributed traces, correlation IDs, and contextual audit logs) sufficient to reconstruct what happened, when, to whom, on which version, with what outcome, and with what causal chain of events.

### 11. Controlled Change & Non-Breaking Evolution
All production modifications (code deployments, database schema migrations, infrastructure updates) must have bounded blast radius and a pre-tested rollback procedure. Database and API changes must support multi-version coexistence via the 3-phase **Expand $\to$ Migrate $\to$ Contract** protocol.

### 12. Explicit Operational Ownership & Life-Cycle Durability
Every production service, database table, queue, and alert must have designated technical, operational, and business owners. Systems must remain operable, maintainable, and upgradeable after team transitions, dependency deprecations, and business scale increases.

---

## 4. Constitutional Prohibitions

1. **PROHIBITED**: Cargo-cult architecture—adopting distributed microservices, event sourcing, or complex frameworks without documented, measurable requirements.
2. **PROHIBITED**: Authorizing business state mutations or financial balances against stale caches or unverified client inputs.
3. **PROHIBITED**: Performing external network I/O, webhook delivery, or email dispatch inside an uncommitted database transaction.
4. **PROHIBITED**: Silent failure—swallowing errors, ignoring dropped background tasks, or continuing execution in an ambiguous state.
5. **PROHIBITED**: Unbounded retries without exponential backoff and randomized jitter, risking thundering-herd retry storms.
6. **PROHIBITED**: Unbounded in-memory queues or channels that mask downstream saturation and cause Out-Of-Memory (OOM) panics.
7. **PROHIBITED**: Destructive database migrations executed without an automated backup, lock timeout, and pre-tested rollback path.
8. **PROHIBITED**: Hardcoding or logging credentials, private tokens, API keys, or unredacted Personally Identifiable Information (PII).
9. **PROHIBITED**: Relying on "works on my machine" or passing happy-path unit tests as evidence for release readiness.
10. **PROHIBITED**: Deploying unowned services, unmonitored cron jobs, or uninstrumented critical endpoints to production.

---

## 5. Production Release Blockers (Automatic Veto)

Any release candidate or pull request exhibiting ANY of the following conditions is subjected to an **AUTOMATIC RELEASE VETO**:

```text
❌ CRITICAL NO-GO CONDITIONS (AUTOMATIC RELEASE VETO)
- [ ] Known data corruption or calculation inaccuracy in financial/ledger logic.
- [ ] Bypassed authorization or missing tenant isolation scoping in data access layers.
- [ ] Ambiguous or multi-master authoritative state without deterministic reconciliation.
- [ ] Unbounded critical resource growth (memory leak, unbounded channel, connection leak).
- [ ] Database DDL migration on large live tables without lock_timeout or rollback plan.
- [ ] Non-idempotent mutation exposed to network retries or message queue replays.
- [ ] Absence of structured audit logging on security-sensitive or financial operations.
- [ ] Absence of a verified runbook and rollback procedure for new production components.
```

---

## 6. The Production Readiness Scorecard

Before certifying any system, feature, or platform for production deployment:

| Dimension | Readiness Verification Criteria | Status |
| :--- | :--- | :--- |
| **Business & Value** | Problem, scope, success metrics, and non-goals documented and validated by stakeholders. | `[ ]` |
| **Domain & Invariants** | All business rules and state machines enforced at the strongest practical boundary (Type/DB). | `[ ]` |
| **Architecture & Simplicity**| Architecture justifies its complexity budget; dependencies point inward without cycles. | `[ ]` |
| **Data & Transactions** | Single source of truth defined; transactions bounded without external I/O; expand/contract DDL. | `[ ]` |
| **Security & Auth** | Fail-closed authorization, parameterized queries, constant-time crypto, zero logged secrets. | `[ ]` |
| **Resilience & Timeouts** | Explicit timeouts on all I/O, jittered backoff retries, circuit breakers, and bounded queues. | `[ ]` |
| **Observability** | Correlation IDs propagated, structured JSON logs, 4 Golden Signals monitored, alerts actionable. | `[ ]` |
| **Verification & Tests** | Negative edge cases, concurrency races, failure injection, and migration rollback tested. | `[ ]` |
| **Operations & Ownership** | Health/readiness probes configured, graceful shutdown verified, runbook written, owners assigned. | `[ ]` |
| **Economics & Capacity** | Total cost of ownership evaluated; resource quotas bounded against runaway cloud spend. | `[ ]` |

```text
FINAL CERTIFICATION DISPOSITION:
[ ] PASS        — All dimensions verified with concrete evidence. Approved for production.
[ ] CONDITIONAL — Minor non-critical gaps with documented mitigation, owner, and 48-hour fix deadline.
[ ] FAIL        — Any No-Go blocker present or critical invariants unverified. Release rejected.
```

---

## 7. Evidence-Based Engineering Axiom

> **Confidence must be earned through repeatable empirical evidence, never through assumption or optimism.**  
> - Claims of "safe", "scalable", or "reliable" must be backed by invariant tests, benchmark profiles, failure injection logs, and verified restore drills.  
> - Code that is unverified under stress is code whose failure in production is merely a matter of time.

---

## Status Declaration

```text
ENGINEERING-CRAFTSMAN
VERSION: 1.0
STATUS: RATIFIED & FROZEN
```

---

## License

This skill is open source under the [MIT License](LICENSE).

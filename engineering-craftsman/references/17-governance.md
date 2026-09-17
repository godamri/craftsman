# Governance, Auditability & Evidence Gates

> **Core Principle**: Governance must accelerate velocity by providing clear, evidence-based release gates rather than creating slow, bureaucratic bottlenecks.

---

## 1. The 8 Evidence-Based Delivery Gates

```text
GATE 0: Problem & Value Validated  --> Problem statement, users, non-goals defined.
GATE 1: Requirements Signed-Off    --> Invariants, SLOs, and verification seams documented.
GATE 2: Architecture & ADR Approved --> Complexity budget justified, single source of truth defined.
GATE 3: Implementation Complete    --> Invariants enforced at strongest boundary; clean PR review.
GATE 4: Verification Certified     --> Invariant, concurrency, and failure tests green in CI.
GATE 5: Operational Readiness      --> Runbooks written, alarms tested, rollback script validated.
GATE 6: Release Approval           --> Canary deployment plan and automated rollback triggers set.
GATE 7: Production Verification    --> 24-hour telemetry review confirming healthy business metrics.
```

---

## 2. Immutable Audit Trail Standards

For security-sensitive or financial operations, record immutable, tamper-evident audit logs containing:
- `Actor Identity`: Authenticated principal ID.
- `Action & Target`: Explicit verb and target resource ID.
- `Timestamp & Source IP`: UTC ISO timestamp and network source.
- `Outcome & Reason`: `GRANTED`, `DENIED`, or `EXECUTED` with error context.
- `Correlation / Trace ID`: Distributed tracing context for end-to-end auditability.

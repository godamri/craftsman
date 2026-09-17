# Project Delivery & Lifecycle Governance

> **Core Principle**: Conflating "Code Complete" with "Production Ready" is the primary cause of delivery failure. Work must progress through explicit, evidence-backed lifecycle states.

---

## 1. The 10 Project Lifecycle States

```text
1. IDEA              : Problem identified, initial thesis formulated.
2. PLANNED           : Problem validated, scope, constraints, and non-goals approved.
3. IN PROGRESS       : Active design, implementation, and invariant coding.
4. CODE COMPLETE     : Features implemented, unit tests and invariants passing locally.
5. TEST COMPLETE     : Integration, concurrency, boundary, and negative tests passing in CI.
6. INTEGRATED        : Cross-service contracts and end-to-end flows verified in staging.
7. RELEASE CANDIDATE : Security scans, performance profiles, and migration scripts validated.
8. PRODUCTION READY  : Runbooks written, alarms configured, rollback drill passed, owners assigned.
9. RELEASED          : Deployed to live traffic via canary or progressive rollout.
10. OPERATIONALLY STABLE : Running in production for 7+ days with normal SLOs and zero regressions.
```

---

## 2. The Definition of Done (DoD)

A task or story is NOT done until:
- [ ] Invariants are verified by automated tests.
- [ ] Error paths return explicit domain errors (zero unhandled panics).
- [ ] Telemetry and structured logging are instrumented.
- [ ] Database migrations have verified rollback scripts.
- [ ] Documentation and runbooks are updated.

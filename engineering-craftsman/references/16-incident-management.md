# Incident Management & Blameless Post-Incident Reviews

> **Core Principle**: An incident is not resolved when the service recovers; it is resolved when the root-cause systemic vulnerabilities are eliminated and durable automated guards are deployed.

---

## 1. The 9-Stage Incident Lifecycle

```text
1. DETECTION    : Automated anomaly detection / synthetic alert fires.
2. TRIAGE       : Assess severity (SEV-1 / SEV-2), establish Incident Commander (IC).
3. CONTAINMENT  : Isolate blast radius (drop bad traffic, open circuit breaker, rollback).
4. MITIGATION   : Restore core service availability to customers.
5. RECOVERY     : Re-enable full functionality under verified monitoring.
6. RECONCILIATION: Replay dropped events, reconcile ledger anomalies, verify data consistency.
7. ROOT CAUSE   : Perform blameless 5-Whys causal analysis.
8. CORRECTIVE   : Deploy automated regression tests, fix code defects, update runbooks.
9. PREVENTION   : Refactor architectural failure domains to eliminate entire defect class.
```

---

## 2. Post-Incident Review (PIR) Invariant
Every SEV-1 and SEV-2 incident must produce a public, blameless PIR document within 72 hours, resulting in prioritized engineering action items (tests, alerts, architectural changes) that prevent identical failure modes.

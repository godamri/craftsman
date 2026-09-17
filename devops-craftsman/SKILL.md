---
name: devops-craftsman
description: >-
  Practical infrastructure and SRE guidance focused on server administration,
  credential security, safe database operations, failure recovery, and zero-downtime changes.
license: MIT
---

# DevOps Craftsman: Infrastructure & SRE Operations

### The 12 Cross-Skill Engineering Pillars
Every infrastructure and SRE system must uphold and optimize for:
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

## The 15 Constitutional Principles

### 1. Data Durability
Data is the highest-value asset. Systems must guarantee durability across storage, network, and process boundaries. An untested backup is merely an unverified assumption; backups that are not restored and verified automatically are considered failed.

### 2. Backup Before Mutation
Never modify, overwrite, or delete a configuration file, environment variable, DNS record, firewall rule, database schema, or credential without creating an immediate, rollback-capable backup copy or snapshot first.

### 3. Rollback Before Apply
Every planned mutation must have a pre-tested, deterministic rollback procedure documented and executable before execution begins. If a mutation fails or degrades health, rollback must be immediate.

### 4. Validate Before Apply
Configurations, code, infrastructure definitions, and database migrations must pass syntax, constraint, and structural validation prior to application against live environments.

### 5. Verify After Apply
Every state change must be immediately verified with post-flight health checks, synthetic probes, or telemetry before the operation is declared successful.

### 6. Bound Blast Radius
Isolate failure domains. Apply changes incrementally via progressive rollout, canary phases, or isolated failure zones so that unexpected defects impact the minimum possible surface area.

### 7. Fail Closed / Fail Safe
In the event of ambiguity, network partition, or unhandled errors, security and mutation boundaries must default to a safe state (e.g. denying unauthorized access or halting automated destructive execution).

### 8. Least Privilege
Operators, services, containers, and automated pipelines must execute with the minimum necessary permissions, system capabilities, and network access required for their legitimate function.

### 9. No Secret Leakage
Secrets, private keys, API tokens, and credentials must never exist in plaintext in repositories, container images, shell histories, logs, or unencrypted storage.

### 10. No Unbounded Destruction
Destructive operations (e.g. file deletion, database truncation, resource deletion) must have strictly bounded targets, explicit variable validation, and pre-execution previews. Blind wildcard deletions are forbidden.

### 11. Preserve Recovery Access
Mutations affecting remote access, authentication, or firewalls must maintain an independent secondary access session and an automated reversion mechanism to prevent operator lockouts.

### 12. Deterministic Recovery
Recovery Time Objectives (RTO) and Recovery Point Objectives (RPO) must be explicitly defined, bounded, and proven through scheduled restoration drills in isolated environments.

### 13. Observable Changes
System telemetry (the Four Golden Signals: Latency, Traffic, Errors, Saturation) must be actively monitored during and after every operational change.

### 14. Auditability
Every production mutation must leave an immutable, traceable record identifying who performed the action, what was altered, when it occurred, and the justification.

### 15. Authoritative State
Production safety decisions must be based on authoritative and sufficiently current system state, not stale observations, assumptions, cached state, or operator memory, whenever authoritative state is available.

---

## Explicit Prohibitions

1. **PROHIBITED**: Modifying production state without a verified backup copy and rollback plan.
2. **PROHIBITED**: Executing destructive commands with unvalidated or empty variable paths.
3. **PROHIBITED**: Single-step credential revocation without a dual-verification overlap window.
4. **PROHIBITED**: Applying database schema migrations that cause unconstrained table locks on live workloads without online evaluation.
5. **PROHIBITED**: Hard restarting services when graceful configuration reload is supported.
6. **PROHIBITED**: Trusting backups without automated, end-to-end restore verification drills.
7. **PROHIBITED**: Storing secrets in plain text or committing them to revision control.

---

## The Production Readiness Gate

Before any production infrastructure change is executed:

- [ ] **Authoritative State Checked**: Is the change based on current authoritative system state?
- [ ] **Backup Created**: Is a timestamped backup copy or snapshot created?
- [ ] **Rollback Ready**: Is the rollback procedure tested and executable immediately?
- [ ] **Pre-Flight Validated**: Did syntax and validation checks pass (`-t`, `--dry-run`, `validate`)?
- [ ] **Recovery Access Preserved**: Is an independent secondary access session open if modifying access/network?
- [ ] **Blast Radius Bounded**: Is the change scoped to a single node, canary tier, or bounded partition?
- [ ] **Telemetry Monitored**: Are Golden Signals dashboards live and watched during the change?
- [ ] **Audit Trail Logged**: Is the change recorded with author, ticket, and rationale?

---

## Status Declaration

```text
DEVOPS-CRAFTSMAN
STATUS: FROZEN
```

> **Final Law**: Never rely on optimism in production. Design every mutation so that failure is bounded, immediately detectable, and effortlessly reversible.

---

## License

This skill is open source under the [MIT License](LICENSE).

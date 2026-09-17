---
name: architecture-craftsman
description: >-
  Practical system architecture guidance focused on system boundaries,
  state ownership, dependency direction, failure domain isolation, and evolutionary design.
license: MIT
---

# Architecture Craftsman: System Architecture & Structural Design

## Preamble & Universal Engineering Principles

> **Is the system structurally correct before implementation begins?**  
> **Architecture is the deliberate management of boundaries, state ownership, dependencies, and failure modes.**  
> **Simplicity beats speculative flexibility. Coupling must be earned; boundaries must be defended.**

### The 12 Cross-Skill Engineering Pillars
Every architectural design must uphold and optimize for:
```text
1. Resilience       — System survives component failures, degradation, and external outages without cascading collapse.
2. Reliability      — Deterministic, predictable, correct, and consistent behavior against established contracts.
3. Adaptability     — Evolve smoothly as requirements, scale, and environment change without fragile redesigns.
4. Maintainability  — Easy to understand, test, refactor, and operate over the long term.
5. Recoverability   — Every failure domain has an explicit, bounded, and testable recovery path without manual heroics.
6. Security         — Trust boundaries, identity boundaries, least privilege, and isolation enforced at the architectural level.
7. Observability    — Systems emit structured telemetry and causality identifiers across service and process boundaries.
8. Simplicity       — Choose the simplest architecture meeting requirements; complexity must be explicitly justified.
9. Consistency      — Contracts, state models, interfaces, and invariants must be non-contradictory across boundaries.
10. Verifiability   — Architectural properties are provable through contract testing, integration drills, and failure injection.
11. Controlled Change — Architectural modifications follow clear migration paths with backward compatibility and bounded risk.
12. Long-Term Durability — Decisions consider total lifecycle cost, technical debt, operational burden, and migration paths.
```

### Priority Meta-Rule
> **No architectural decision may optimize one dimension by silently sacrificing another critical engineering property.**  
> - Correctness beats convenience.  
> - Safety beats speed when the blast radius is material.  
> - Evidence beats assumption.  
> - Simple solutions beat unnecessary complexity.  
> - Recovery must be designed before failure occurs.

---

## Core Architectural Principles

### 1. The Single Source of Truth Invariant
Every piece of domain data must have exactly one authoritative source of truth. Caches, read replicas, search indices, and client projections are derived views and must never become authoritative for mutating decisions or invariant enforcement.

### 2. Dependency Direction Law
Dependencies must point toward stability and core business logic (inward), never toward volatile infrastructure, frameworks, or external delivery mechanisms. High-level policies must not depend on low-level details.

### 3. Explicit Boundary Contracts
Component and service boundaries must be defined by explicit, versioned, and testable contracts (e.g. consumer-driven interfaces, Protobuf, OpenAPI). Internal state representations must never leak across boundary interfaces.

### 4. Single Ownership of State & Mutations
A given state aggregate must be mutated exclusively by the component or service that owns it. Direct multi-party database sharing across autonomous service boundaries is prohibited; state mutation occurs via authorized domain operations.

### 5. Failure Domain Isolation & Blast Radius Containment
Systems must be partitioned so that a failure in one component (e.g. third-party gateway, background worker, search engine) does not cascade to unseat core business operations. Critical paths must operate with graceful degradation when optional dependencies fail.

### 6. Explicit Consistency Boundaries
Transactions must be confined to single cohesive aggregates or bounded databases. Do not assume distributed transactions or cross-service two-phase commits. For distributed workflows, design for eventual consistency with explicit compensation or outbox patterns.

### 7. Asynchronous Decoupling for Side Effects
Non-critical side effects (e.g. notifications, analytics, webhooks, audit logging) must be decoupled from the synchronous request path via durable asynchronous messaging or background queues.

### 8. Architectural Decision Record (ADR) Discipline
Non-trivial architectural decisions, trade-offs, evaluated alternatives, and rejected options must be documented in immutable Architectural Decision Records (ADRs) before execution begins.

### 9. Evolutionary Architecture & Expand/Contract
Every structural change, database schema evolution, or API modification must be designed for zero-downtime rolling coexistence: Version $N$ and Version $N+1$ must run simultaneously during transitions using the 3-phase **Expand $\to$ Migrate $\to$ Contract** pattern.

### 10. Complexity Escalation Hierarchy
Default to the simplest structural model that satisfies current concrete requirements:
```text
Modular Monolith / Cohesive Modules
   ↓ (when independent deployability, distinct scaling, or team ownership demands it)
Decoupled Internal Services
   ↓ (only when distributed workflows or data partitioning requires it)
Event-Driven / Distributed Microservices
```
Never introduce distributed architecture speculatively without concrete scaling, organizational, or failure-domain justification.

### 11. Bounded Resource & Capacity Planning
Every ingress, queue, cache, database connection pool, and thread allocation must have explicit, bounded capacity limits with defined load-shedding and backpressure behavior under saturation.

### 12. Verifiable Architectural Contracts
Architectural boundaries must be verified through automated contract testing, dependency-direction linters, and failure injection to ensure architectural drift does not accumulate over time.

---

## Explicit Prohibitions

1. **PROHIBITED**: Direct database table sharing across autonomous service or module boundaries.
2. **PROHIBITED**: Circular dependencies between packages, modules, or services.
3. **PROHIBITED**: Authorizing business state mutations against stale caches or derived projections.
4. **PROHIBITED**: Speculative distributed microservice architectures without concrete scaling or team boundary needs.
5. **PROHIBITED**: Synchronous cross-service calls in high-throughput critical path loops without circuit breakers and timeouts.
6. **PROHIBITED**: Breaking contract changes deployed without an overlapping backward-compatibility window.
7. **PROHIBITED**: Undocumented architectural changes that bypass the ADR review process.

---

## The Architecture Readiness Gate

Before approving any system design or structural refactoring:

- [ ] **Authority Defined**: Is the single authoritative source of truth identified for all state?
- [ ] **Dependencies Inward**: Do dependencies flow toward stable domain logic without cycles?
- [ ] **Contracts Explicit**: Are all boundary interfaces documented, versioned, and testable?
- [ ] **Blast Radius Contained**: Can the system maintain core availability if optional dependencies fail?
- [ ] **Consistency Model Stated**: Is the consistency model (ACID vs Eventual) explicitly defined?
- [ ] **Rollout & Evolution Planned**: Is the migration compatible with rolling deployment (N/N+1)?
- [ ] **ADR Documented**: Is the Architectural Decision Record written with evaluated trade-offs?
- [ ] **Complexity Justified**: Is this the simplest architectural structure that satisfies the requirements?

---

## Status Declaration

```text
ARCHITECTURE-CRAFTSMAN
STATUS: FROZEN
```

> **Final Law**: Architecture is the art of drawing clean boundaries and designing deterministic recovery paths before writing code. If the boundary is flawed, no amount of clever code will make the system correct.

---

## License

This skill is open source under the [MIT License](LICENSE).

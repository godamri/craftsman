# Architectural Decision Records (ADR) Discipline

An Architecture Decision Record (ADR) captures an important architectural decision, the context surrounding it, evaluated alternatives, and its trade-offs.

---

## 1. The Standard ADR Structure

Every non-trivial architectural change must produce an ADR with the following mandatory sections:

```markdown
# ADR-001: [Short Title of the Decision]

## Status
[PROPOSED | ACCEPTED | SUPERSEDED | DEPRECATED]

## Context & Problem Statement
What is the concrete business requirement, scaling bottleneck, or operational problem?
What constraints exist (timeline, cost, team capabilities, SLAs)?

## Decision
What is the chosen structural design, protocol, or boundary pattern?

## Evaluated Alternatives
1. **Alternative A (Rejected)**: Why was it considered and why was it rejected?
2. **Alternative B (Rejected)**: Why was it considered and why was it rejected?

## Consequences & Trade-Offs
- **Positive**: What invariants, performance characteristics, or developer velocity benefits are gained?
- **Negative / Costs**: What operational complexity, latency overhead, or migration cost is incurred?

## Invariant & Failure Analysis
- What invariant must always hold?
- How does the architecture behave during partial network failure or process crash?
- What is the rollback or migration path?
```

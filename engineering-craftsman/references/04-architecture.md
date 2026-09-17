# Architecture Discipline & Complexity Budgets

> **Core Principle**: Architecture is the management of trade-offs, boundaries, and failure modes. Architecture by fashion is strictly prohibited.

---

## 1. The Complexity Budget Framework

Every added architectural layer, service boundary, or third-party infrastructure dependency incurs an ongoing **Operational & Cognitive Tax**:

```text
ADDED COMPLEXITY SCORECARD:
[ ] What concrete business requirement or scaling limit does this solve?
[ ] How does this increase MTTR (Mean Time to Recovery) during an outage?
[ ] What happens when network partitions or partial failures occur between these layers?
[ ] What is the hosting and operational maintenance cost over 3 years?
[ ] What simpler alternative (e.g. Postgres table, modular monolith) was evaluated and rejected?
```

---

## 2. Pattern Justification Table

| Architectural Pattern | When Justified | When PROHIBITED (Cargo-Cult) |
| :--- | :--- | :--- |
| **Microservices** | Multiple independent teams, divergent scaling requirements, isolated failure domains. | Single team, early-stage product, shared database behind services. |
| **Event Sourcing** | Audit ledger requirements where every state transition must be historically replayable. | Standard CRUD applications with conventional mutation lifecycles. |
| **Distributed Cache (Redis)** | High read-to-write ratio (>50:1) with measured database CPU bottlenecks. | Small datasets that easily fit into relational database buffer pools. |
| **Message Broker (Kafka/Rabbit)** | High-throughput asynchronous fan-out across autonomous domains. | Simple synchronous point-to-point requests within the same domain. |

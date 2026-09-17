# Risk Management & Blast Radius Evaluation

> **Core Principle**: High-risk engineering initiatives require disproportionate care, explicit blast radius boundaries, and pre-planned rollback mechanisms.

---

## 1. The Risk Scoring Matrix

Evaluate every architectural modification and production change across 6 dimensions:

$$\text{Risk Score} = \text{Probability} \times \text{Impact} \times \text{Blast Radius} \times (1 / \text{Detectability}) \times (1 / \text{Reversibility})$$

| Risk Tier | Definition | Required Governance Gate |
| :--- | :--- | :--- |
| **P0: Catastrophic** | Total service outage, data corruption, financial loss, severe security breach. | Architecture Review + VP/Director Sign-Off + Automated Canary + Instant Rollback Drill. |
| **P1: Major** | Significant performance degradation, partial customer disruption, revenue impairment. | Senior Staff Engineer Review + Staging Integration Drill + Monitored Canary. |
| **P2: Moderate** | Non-critical internal feature defect, minor latency increase. | Peer Code Review + Automated CI Gates. |
| **P3: Minor** | Cosmetic UI defect, internal tooling tweak. | Standard PR Review + Automated Unit Tests. |

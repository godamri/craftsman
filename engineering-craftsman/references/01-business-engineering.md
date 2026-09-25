# Business-First Engineering & Value Alignment

> **Core Principle**: Engineering is an investment of capital and talent to solve real human and business problems. Solving technically interesting problems that do not generate value or mitigate risk is a failure of engineering discipline.

---

## 1. The Business Engineering Canvas

Before writing design documents or code, every initiative must answer these 10 foundational questions:

```text
1. Problem Statement   : What concrete pain point, regulatory demand, or operational bottleneck exists?
2. Target Beneficiary  : Exactly who uses or benefits from this (end customers, internal operators, auditors)?
3. Quantifiable Value  : What revenue is unlocked, cost reduced, or error rate eliminated?
4. Explicit Scope      : What is the minimum viable capability required to solve the core problem?
5. Explicit Non-Goals  : What related features or premature optimizations are deliberately excluded?
6. Constraints         : What budget, timeline, team capacity, and regulatory boundaries bind this work?
7. Downstream Risk     : What is the worst-case failure outcome (financial loss, data leak, downtime)?
8. Success Metrics     : What leading/lagging telemetry proves that the initiative succeeded?
9. Total Lifecycle Cost: What are the ongoing hosting, maintenance, and support burdens?
10. Reversal Strategy  : If this initiative fails in the market, how easily and cheaply can it be dismantled?
```

---

## 2. Preventing Solution-in-Search-of-a-Problem

| Anti-Pattern | Root Cause | Engineering Craftsman Rule |
| :--- | :--- | :--- |
| **"Let's rewrite in Microservices"** | Technology fashion / CV-driven development | Reject unless independent scaling, deployment cadence, or team ownership boundaries mandate it. |
| **"We need AI/LLM for this"** | Hype over substance | Use deterministic algorithms, standard SQL queries, or simple heuristics if they solve the problem reliably at 1/1000th the cost. |
| **"Let's build a bespoke framework"** | Not-Invented-Here syndrome | Use proven standard libraries. Build bespoke tools only when core competitive advantage demands it. |

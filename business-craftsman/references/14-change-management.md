# Change Control & Scope Mutation Governance

> **Core Principle**: Change is inevitable, but unmanaged change destroys predictability. Every scope mutation must be evaluated for its total business and operational impact.

---

## 1. Change Classification Tiers

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ 1. MINOR CHANGE (< 5% budget/timeline impact, zero architectural risk)                 │
│    --> Approved by Product Owner & Engineering Lead in regular sprint backlog.         │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 2. MATERIAL CHANGE (5%–15% budget/timeline impact, minor dependency shift)             │
│    --> Requires formal Change Request (CR) approved by Project Manager & Product Lead. │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 3. MAJOR CHANGE (> 15% budget/timeline impact, milestone delay, core architecture)    │
│    --> Requires Executive Sponsor approval and baseline project charter re-baselining. │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 4. STRATEGIC PIVOT (Fundamental business model or target customer shift)              │
│    --> Triggers complete Portfolio Review, project halt, and new Business Case.        │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

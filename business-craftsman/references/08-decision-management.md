# Decision Management & One-Way Door Governance

> **Core Principle**: Speed of decision-making is a competitive advantage, but irreversible commitments demand disproportionate evidence and explicit exit plans.

---

## 1. Type 1 (One-Way Door) vs Type 2 (Two-Way Door) Decisions

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ TYPE 2: TWO-WAY DOOR DECISIONS (REVERSIBLE)                                            │
│ - Low cost to reverse or dismantle (e.g. UI copy, feature flag rollouts, pricing test)│
│ - Speed over exhaustive analysis: Decide rapidly with 70% of available data.          │
│ - Delegate to the frontline team closest to the problem.                              │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ TYPE 1: ONE-WAY DOOR DECISIONS (IRREVERSIBLE)                                          │
│ - High cost or impossible to reverse (e.g. multi-year vendor contract, core DB schema,│
│   M&A acquisition, major architectural paradigm shift, public API breaking change).   │
│ - Demands thorough evidence, formal Decision Record (DR), and executive sign-off.     │
│ - MUST have an explicit, documented Exit / Reversal Strategy.                          │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. The Decision Record (DR) Structure

Every major strategic or operational decision must produce a formal Decision Record:
1. **Decision Title & Context**: What problem is being solved and what constraints exist?
2. **Evaluated Options**: At least 3 distinct alternatives (including "Do Nothing").
3. **Evidence & Trade-Offs**: Pros, cons, financial impact, and operational burdens of each.
4. **Chosen Option & Rationale**: Why this option won based on the Decision Hierarchy.
5. **Rejected Alternatives**: Explicit justification for why competing options were rejected.
6. **Revisit Trigger**: What future metric or event requires reopening this decision?

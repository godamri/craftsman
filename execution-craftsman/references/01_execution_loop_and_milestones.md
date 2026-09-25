# Milestone Decomposition & Vertical Slices

> **Core Principle**: A complex feature is not a monolith to be implemented all at once. Break delivery into observable, independently verifiable vertical slices.

---

## 1. Vertical Slice vs Horizontal Layering

When implementing a feature, avoid the **Horizontal Layering Trap** (e.g. creating all database schemas, then all domain structs, then all services, then all UI endpoints before testing anything):

```text
❌ HORIZONTAL LAYERING (High Risk, Delayed Verification):
   Layer 4: UI / API Endpoints    [Untested until the very end]
   Layer 3: Application Services  [Untested until the very end]
   Layer 2: Domain State Models   [Untested until the very end]
   Layer 1: Database Schemas      [Untested until the very end]

✅ VERTICAL SLICES (Low Risk, Continuous Verification):
   Slice M1: Core Ingress -> Domain Logic -> Memory/Storage -> Response   [VERIFIED END-TO-END]
   Slice M2: State Transitions & Side Effects                             [VERIFIED END-TO-END]
   Slice M3: Concurrency Control & Invariant Falsification                [VERIFIED END-TO-END]
   Slice M4: Failure Paths, Rollback & Full Regression                    [VERIFIED END-TO-END]
```

Every vertical slice establishes a complete, working path through the relevant system boundaries.

---

## 2. Change Budget Discipline

To prevent scope creep, every milestone must operate under a strict **Change Budget**:

| Change Classification | Description | Execution Permission |
| :--- | :--- | :--- |
| **`REQUIRED`** | Direct code/schema modifications necessary to meet the milestone's acceptance criteria. | **Permitted** |
| **`REQUIRED FOR VERIFICATION`** | Test cases, fixtures, in-memory adapters, or synthetic probes required to prove behavior. | **Permitted** |
| **`OPTIONAL / FOLLOW-UP`** | Adjacent refactoring, file re-formatting, dependency upgrades, or optimizations. | **PROHIBITED** (Record as follow-up; do not implement) |

### Anti-Overengineering Rule
> **Once a milestone's exit criteria are satisfied, stop implementation immediately.**  
> Do not introduce additional unrequested abstractions, extra helpers, or speculative enhancements.

---

## 3. Crafting Observable Acceptance Criteria

Acceptance criteria must assert observable behavior, state transitions, and return contracts:

```text
GIVEN: An authenticated user with sufficient account balance ($100)
WHEN:  A withdrawal request for $40 is executed
THEN:  
  1. Return value is 200 OK with remaining balance $60.
  2. Persisted balance in database is updated to $60.
  3. A single LedgerEntry record is persisted with amount -$40.

GIVEN: An authenticated user with insufficient account balance ($20)
WHEN:  A withdrawal request for $40 is executed
THEN:
  1. Return value is 422 Unprocessable Entity with error code "INSUFFICIENT_FUNDS".
  2. Persisted balance remains unchanged at $20.
  3. Zero LedgerEntry records are written.
```

---

## 4. Milestone Exit Criteria Formulation

A milestone can close with status `PASS` only when its complete **Exit Criteria Formula** is satisfied:

$$\text{Exit Criteria} = \text{Acceptance Criteria} + \text{Failure Paths} + \text{Regression Suite} + \text{Known Deviations} + \text{Explicit Unknowns}$$

- **`PASS`**: All acceptance criteria verified, relevant failure paths tested, regression clean, and zero unresolved blockers.
- **`PARTIAL`**: Core path verified, but secondary conditions or environmental dependencies could not be run (explicitly documented in unknowns).
- **`BLOCKED`**: Critical acceptance criteria or regression failed, requiring architecture re-evaluation.

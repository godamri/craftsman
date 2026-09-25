---
name: execution-craftsman
description: >-
  Practical engineering execution guidance focused on milestone-based delivery,
  repository reconnaissance, vertical-slice implementation, behavioral boundary verification, falsification, and regression control.
license: MIT
---

# Execution Craftsman: Milestone-Based Engineering Execution

## Preamble & Core Execution Axioms

> **An implementation is not complete when the code exists. It is complete when the intended behavior has been demonstrated across its execution boundary and relevant failure modes have been tested.**  
> **Evidence beats assumption. Small verified iterations beat large unverified batches. Defect discovery is evidence of progress.**

### The Four Operational Status Definitions

To prevent assumption inflation, strictly distinguish the four operational states of any feature or system:

```text
Implemented  ≠  Verified  ≠  Validated  ≠  Production Ready
```

1. **Implemented**: The requested code, schema, or configuration exists in the repository.
2. **Verified**: The implementation behaves according to explicit technical acceptance criteria under tested conditions.
3. **Validated**: Evidence supports that the implementation satisfies the intended user requirement or system workflow across its integration boundary.
4. **Production Ready**: A separate operational decision requiring deployment-specific evidence (telemetry, rollout strategy, load tolerance, failover drills) outside the scope of ordinary feature implementation.

> **Operational Rule**: Never casually promote *Implemented* to *Verified*, or *Verified* to *Validated* or *Production Ready*, without corresponding evidence.

---

## The 12-Step Execution Loop

Every non-trivial engineering task must execute through this iterative loop:

```text
 1. PLAN                      --> Identify objective, constraints, and scope boundaries.
    ↓
 2. RECONNAISSANCE (RECON)    --> Inspect existing repository patterns, canonical implementations, and lifecycles.
    ↓
 3. DEFINE MILESTONES & BUDGET--> Break work into independent vertical slices with strict change budgets.
    ↓
 4. DEFINE ACCEPTANCE CRITERIA--> Document observable input/state/output behaviors.
    ↓
 5. IMPLEMENT NARROW SLICE    --> Write the minimum code required for the current milestone.
    ↓
 6. VERIFY BEHAVIORAL BOUNDARY--> Execute end-to-end / vertical-slice verification across the component boundary.
    ↓
 7. ATTACK / FALSIFY          --> Actively attempt to break the implementation under edge and failure conditions.
    ↓
 8. INVESTIGATE & FIX         --> Form hypotheses, locate root causes, and apply minimal fixes. No blind patching.
    ↓
 9. RE-VERIFY                 --> Re-run failed verification scenarios to prove defect elimination.
    ↓
10. BLAST-RADIUS REGRESSION   --> Run regression suite across previously verified milestones and affected callers.
    ↓
11. VERIFY EXIT CRITERIA      --> Close milestone when all exit criteria pass. Stop implementation.
    ↓
12. PROCEED TO NEXT MILESTONE
```

---

## The Change Budget & Scope Control

For every milestone, classify all proposed modifications into one of three tiers:

- `REQUIRED`: Direct delta strictly necessary to satisfy the current milestone's acceptance criteria.
- `REQUIRED FOR VERIFICATION`: Harness, test fixtures, or assertions required to prove milestone behavior.
- `OPTIONAL / FOLLOW-UP`: Refactoring, stylistic cleanups, dependency upgrades, or optimizations not mandated by the current milestone.

> **Stop Rule**: Only `REQUIRED` and `REQUIRED FOR VERIFICATION` may enter execution. All `OPTIONAL / FOLLOW-UP` items must be recorded in the milestone report as follow-up items and **NOT** implemented in the current milestone.

---

## The 12 Core Execution Principles

### 1. Plan Before Code & Repository Reconnaissance
Before modifying files, search the repository for canonical implementations, neighboring modules, established lifecycle patterns, test utilities, configuration conventions, and runtime registrations.  
Prioritize evidence in this order:
```text
Existing repository evidence  >  Canonical project patterns  >  Framework documentation  >  Agent assumptions
```
Do not introduce new architectural patterns merely because an existing pattern was not immediately searched.

### 2. Milestone Decomposition & Vertical Slices
Break complex work into small, cohesive milestones representing end-to-end vertical slices (e.g. Input $\to$ Domain $\to$ Persistence $\to$ Result) rather than horizontal layers (e.g. creating all database tables across the system before writing any logic). Every milestone must leave the repository in a **buildable, runnable, and testable** intermediate state.

### 3. Observable Acceptance Criteria
Acceptance criteria must describe observable behaviors, state transitions, and return values—never vague activities.
- *Poor*: "Implement authentication."
- *Strong*:
  - Valid credentials $\to$ returns active session token with 200 OK.
  - Invalid credentials $\to$ returns 401 Unauthorized with error code `AUTH_INVALID`.
  - Expired token $\to$ rejects request with 401 Unauthorized.
  - Mutating request with valid session $\to$ persists actor ID in audit record.

### 4. Behavioral Boundary & End-to-End Verification
Design verification around the complete behavioral boundary of the component or feature. Use full End-to-End (E2E) execution whenever the environment permits.  
If full E2E is genuinely unavailable (e.g. external hardware dependency, missing third-party sandbox), explicitly report:
```text
E2E: NOT AVAILABLE
Alternative Evidence: [Integration / Mock harness / Invariant test]
Remaining Gap: [Specific unverified boundary behavior]
```
Do not fabricate artificial E2E claims.

### 5. Explicit Failure-Path Testing
Every milestone must explicitly evaluate non-happy-path execution. For every relevant boundary condition, declare status as one of:
```text
TESTED          --> Verified with reproducible test/runtime evidence.
NOT APPLICABLE  --> Conceptually irrelevant to this feature's boundary.
NOT TESTED      --> Relevant but unverified; documented as an explicit gap.
UNKNOWN         --> Insufficient evidence to determine behavior.
```
Evaluate: invalid input, missing records, unauthorized callers, stale state transitions, concurrent operations, partial rollbacks, and network/timeout failures.

### 6. The Falsification Mindset ("Try to Break It")
After the happy path passes, actively adopt an adversarial stance. Ask: *"Under what conditions would this implementation become incorrect?"* Probe:
- Race conditions during concurrent mutations.
- Replayed or duplicate requests.
- Boundary values (zero, maximum payloads, empty collections).
- Interrupted or aborted transactions.

### 7. Claim-Dependent Evidence Model
**Evidence strength is claim-dependent.** Select the strongest practical evidence that directly proves the specific claim being made:
- *Claim: "Code compiles and exports symbol X"* $\to$ Static compiler output.
- *Claim: "Logic correctly computes discount"* $\to$ Pure unit invariant test.
- *Claim: "State survives restart and commits to disk"* $\to$ Independent persistence reload drill.
- *Claim: "Operation is safe under concurrent execution"* $\to$ Parallel multi-worker race test + final database state audit.
- *Claim: "API endpoint handles HTTP traffic end-to-end"* $\to$ Live HTTP integration request/response test.

### 8. Epistemic Discipline (`FACT` vs `INFERENCE` vs `UNKNOWN`)
Distinguish strictly between certainty tiers:
- **`FACT`**: Directly demonstrated by source code, compiler output, test execution, or runtime telemetry.
- **`INFERENCE`**: Plausible deduction based on existing patterns, but not directly proven by test.
- **`UNKNOWN`**: Insufficient evidence to establish fact.
Never present an `INFERENCE` as a `FACT`, and never fill an `UNKNOWN` with speculative guesses.

### 9. Defect Discovery as Evidence of Progress
When a test or verification step fails, treat it as a discovery of evidence, not a procedural failure. Record the failure, isolate the root cause, determine the blast radius, implement the minimal fix, re-verify the failed test, and execute regression testing. Never conceal a failure or fix from milestone reporting.

### 10. Hypothesis-Driven Debugging
When verification fails, **never patch code blindly** by guessing random changes. Follow this causal protocol:
```text
Failure  -->  Reproduce  -->  Observe State  -->  Locate Boundary  -->  Form Hypothesis  -->  Validate Hypothesis  -->  Minimal Fix  -->  Re-test
```

### 11. Mandatory Blast-Radius Regression Testing
Closing a milestone requires proving that previous milestones and adjacent modules remain healthy. Regression suites must be selected based on the blast radius of the changes made, covering:
- All new milestone verification tests.
- Relevant previous milestone tests.
- Direct callers and consumers of modified interfaces.

### 12. Milestone Exit Criteria & Stop Rule
Every milestone must define explicit exit criteria:
```text
Acceptance Criteria  +  Relevant Failure Paths  +  Required Regression  +  Known Deviations  +  Explicit Unknowns  =  Exit Criteria
```
- A milestone may close with `PASS` only when all exit criteria are satisfied.
- If known deviations or gaps remain, the milestone closes as `PARTIAL` or `BLOCKED` with explicit gaps documented.
- **Stop Rule**: *Once exit criteria are satisfied, stop implementation immediately.* Do not add unrequested features or opportunistic refactorings.

---

## Runtime, Persistence & Concurrency Invariants

### 1. Runtime Verification
When a task alters runtime behavior (services, endpoints, CLI commands, processes), verify runtime execution signals:
- Process startup and graceful shutdown.
- HTTP status codes and serialization payloads.
- Structured log output and error classifications.
- If runtime execution is not possible in the environment, report `Runtime Verification: NOT AVAILABLE` with the reason.

### 2. Persistence Verification
When a task modifies persisted state, do not stop at in-memory return values (e.g. `200 OK` or `return user`). Explicitly verify:
```text
Write  -->  Commit Transaction  -->  Evict Cache / New Session  -->  Reload from Storage  -->  Assert Persisted State
```

### 3. Concurrency Verification
When state or resources can be accessed by multiple concurrent actors, verify race safety with parallel workers synchronized via deterministic barriers (e.g. Go `sync.WaitGroup`, Tokio tasks, Python concurrency barriers):
- Verify that exactly one actor succeeds or operations serialize safely.
- Verify that final persisted state matches the exact expected invariant.
- Verify that no deadlocks, orphaned locks, or partial writes occur.

---

## Milestone Report Template

For every completed or evaluated milestone, document:

```text
================================================================================
MILESTONE REPORT: M[X] — [Milestone Name]
================================================================================

1. OBJECTIVE & CHANGE BUDGET:
   - Objective: [Brief statement of milestone goal]
   - REQUIRED: [Files/modules modified for core behavior]
   - REQUIRED FOR VERIFICATION: [Tests and test fixtures added]
   - OPTIONAL / FOLLOW-UP: [Recorded follow-up items; NOT implemented]

2. ACCEPTANCE CRITERIA RESULTS:
   - [PASS | FAIL | UNKNOWN] [Criterion 1: Input -> State -> Output]
   - [PASS | FAIL | UNKNOWN] [Criterion 2: ...]

3. FAILURE PATHS & FALSIFICATION:
   - [TESTED | NOT APPLICABLE | NOT TESTED | UNKNOWN] [Invalid input / boundary limit]
   - [TESTED | NOT APPLICABLE | NOT TESTED | UNKNOWN] [Unauthorized actor / state mismatch]
   - [TESTED | NOT APPLICABLE | NOT TESTED | UNKNOWN] [Concurrency race / rollback behavior]

4. DEFECTS DISCOVERED & RESOLVED:
   - Defect: [Description of failure encountered]
   - Root Cause: [Hypothesis verified by inspection/test]
   - Minimal Fix: [Smallest justified change applied]
   - Re-Verification: [Result of re-running failed test]

5. REGRESSION & BLAST RADIUS:
   - Regression Suite: [List of test suites executed]
   - Result: [PASS | FAIL]

6. UNKNOWNS & REMAINING GAPS:
   - [Explicit list of unverified conditions or environmental limitations]

7. EXIT STATUS:
   [ PASS | PARTIAL | BLOCKED ]
================================================================================
```

---

## Final Engineering Report Template

After all milestones are completed, compile the final delivery report:

```text
================================================================================
FINAL ENGINEERING REPORT
================================================================================

1. EXECUTIVE SUMMARY:
   - Feature / Initiative: [Name]
   - Final Status: [ IMPLEMENTED | VERIFIED | PARTIALLY VERIFIED | NOT VERIFIED | UNKNOWN | OUT OF SCOPE ]

2. MILESTONE SUMMARY:
   - M1: [Name] --> [ PASS | PARTIAL | BLOCKED ]
   - M2: [Name] --> [ PASS | PARTIAL | BLOCKED ]
   - M3: [Name] --> [ PASS | PARTIAL | BLOCKED ]

3. EVIDENCE COVERAGE MATRIX:
   | Significant Claim | Evidence Provided | Coverage Level | Remaining Gap |
   | :--- | :--- | :--- | :--- |
   | [e.g. Core state machine correct] | [Unit invariant tests] | Verified | [None] |
   | [e.g. Persisted state atomic]    | [Integration reload test]| Verified | [None] |
   | [e.g. Concurrency race safe]      | [Multi-worker barrier]  | Verified | [Retry storm not tested] |
   | [e.g. Production readiness]       | [—]                     | Not Established | [Requires deployment SLO telemetry] |

4. FAILURE PATHS & FALSIFICATION SUMMARY:
   - [Summary of edge cases, invalid states, and error handling tested]

5. PERSISTENCE & CONCURRENCY VERIFICATION:
   - Persistence: [VERIFIED via independent reload | NOT APPLICABLE | UNVERIFIED]
   - Concurrency: [VERIFIED via race test | NOT APPLICABLE | UNVERIFIED]

6. DEFECT LOG & LESSONS LEARNED:
   - [List of all defects discovered during testing and how they were resolved]

7. KNOWN UNKNOWNS & OUT-OF-SCOPE:
   - Known Unknowns: [Conditions not demonstrable in current environment]
   - Out-of-Scope: [Items recorded as follow-up without execution]

8. FINAL CERTIFICATION:
   [ VERIFIED | PARTIALLY VERIFIED | BLOCKED ]
================================================================================
```

---

## Explicit Prohibitions

1. **PROHIBITED**: Declaring a feature complete based solely on compilation or code existence without verification evidence.
2. **PROHIBITED**: Patching code blindly after a test failure without reproducing the defect, observing state, and testing a causal hypothesis.
3. **PROHIBITED**: Performing unrequested refactoring, code formatting, dependency upgrades, or premature optimizations during milestone execution.
4. **PROHIBITED**: Silently skipping failure-path, boundary, or concurrency testing when the domain involves mutable state or external interactions.
5. **PROHIBITED**: Casually promoting *Implemented* to *Verified*, or *Verified* to *Validated* or *Production Ready*, without explicit supporting evidence.
6. **PROHIBITED**: Continuing implementation after milestone exit criteria are satisfied without new evidence or explicit user instruction.
7. **PROHIBITED**: Concealing discovered defects, intermittent test failures, or environmental gaps from milestone and final engineering reports.
8. **PROHIBITED**: Generating decorative ASCII banners, obvious syntax restatements, or low-information noise in code comments and milestone reports.

---

## Execution Readiness Gate

Before certifying any milestone or closing an engineering task:

- [ ] **Recon Completed**: Were existing repository patterns, canonical implementations, and lifecycles inspected before writing code?
- [ ] **Change Budget Bounded**: Are all modifications strictly classified as `REQUIRED` or `REQUIRED FOR VERIFICATION`, with optional improvements deferred?
- [ ] **Acceptance Criteria Observable**: Are all criteria defined as explicit input $\to$ state transition $\to$ output behaviors?
- [ ] **Boundary Verified**: Is behavior verified across the full component boundary (or gaps explicitly documented if E2E is unavailable)?
- [ ] **Failure Paths Probed**: Were invalid inputs, unauthorized callers, state conflicts, and boundary edges tested?
- [ ] **Falsification Attempted**: Did the verification actively attempt to break the implementation under adversarial conditions?
- [ ] **Defects Root-Caused**: Were all encountered bugs diagnosed via hypotheses and resolved with minimal justified fixes?
- [ ] **Persistence & Concurrency Checked**: Was persisted data reloaded independently, and was concurrent access verified if applicable?
- [ ] **Regression Clean**: Did the blast-radius regression suite pass with zero regressions?
- [ ] **Comment & Output Hygiene Maintained**: Does generated code preserve *why* without syntax restatement, decorative banners, or emoji clutter?
- [ ] **Evidence Coverage Documented**: Does the final report honestly distinguish `FACT`, `INFERENCE`, and `UNKNOWN`?

---

## Status Declaration

```text
EXECUTION-CRAFTSMAN
STATUS: ACTIVE & STABLE
```

> **Final Law**: Code is cheap; verified correctness is valuable. Build in vertical slices, attack your own assumptions, investigate before fixing, and let accumulated evidence prove milestone completion.

---

## License

This skill is open source under the [MIT License](LICENSE).

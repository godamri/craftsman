# Hypothesis-Driven Debugging Protocol

> **Core Principle**: When verification fails, do not patch code blindly. Form a causal hypothesis, validate it with evidence, and apply the smallest justified fix.

---

## 1. The Anti-Pattern: Trial-and-Error Patching

```text
❌ RANDOM TRIAL-AND-ERROR PATCHING:
   Test Fails  -->  Change code blindly  -->  Test Fails  -->  Add another 'if' statement
   -->  Test Passes by accident  -->  Underlying invariant remains broken
```

Blind patching introduces subtle regression bugs, bloats complexity, and conceals the true root cause.

---

## 2. The 8-Step Causal Debugging Protocol

Follow this deterministic sequence for every defect discovered during milestone execution:

```text
1. FAILURE OCCURRENCE
   Observe test assertion failure, unexpected error code, or state inconsistency.

2. REPRODUCE
   Isolate the exact minimal reproduction case in an automated test.

3. OBSERVE STATE
   Inspect variables, returned payloads, database records, and structured logs.

4. LOCATE BOUNDARY
   Identify the exact function, line, or layer where expected state diverges from actual state.

5. FORM CAUSAL HYPOTHESIS
   Formulate an explicit hypothesis: "The update lost updates because the query reads balance
   without row-level locking (SELECT FOR UPDATE) before executing the calculation."

6. VALIDATE HYPOTHESIS
   Inspect code and database query logs to verify whether the hypothesis matches physical reality.

7. APPLY MINIMAL JUSTIFIED FIX
   Implement the smallest focused change that addresses the root cause (e.g. adding FOR UPDATE or a CHECK constraint).

8. RE-VERIFY & REGRESSION
   Re-run the failing test to prove resolution, then run the full blast-radius regression suite.
```

---

## 3. Documenting Defects in Milestone Reports

Defects discovered during testing are valuable evidence. Document them transparently:

```text
- Defect: Concurrent reservation allowed overselling inventory (balance reached -1).
- Root Cause: Missing SELECT ... FOR UPDATE on inventory record during allocation.
- Minimal Fix: Added row-level lock within the existing database transaction boundary.
- Re-Verification: Concurrency barrier test with 50 workers passed with balance exactly 0.
- Regression: Full M1 unit suite and M2 integration suite green (100% pass).
```

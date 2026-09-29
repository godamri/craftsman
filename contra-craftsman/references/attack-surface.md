# Contra Craftsman: Attack Surface Reference

This reference defines the attack domains available to Contra and the specific questions
it should ask within each domain. These are not checklists to be applied exhaustively
on every invocation — they are a catalog from which Contra selects the questions that
are **actually relevant to the current change**.

---

## General Principle

Select the minimum attack surface. Ask the questions relevant to the actual blast radius.

A one-line fix warrants a brief scan. A multi-boundary schema migration warrants a deep check.

Do not apply all domains to every review.

---

## 1. Scope

**Trigger**: Any review. Scope drift is always checked.

Ask:
- Does every change trace back to a requirement, invariant, contract, demonstrated failure mode, or necessary prerequisite?
- Is any change present that is justified only by architecture preference or "I noticed this while I was here"?
- Is "cleanup" bundled with a correctness fix?
- Is there a new abstraction with no demonstrated necessity or failed alternative?
- Is there a schema migration when application-layer state was sufficient?

Standard: a change may be justified by an explicit requirement, an existing invariant, a dependency constraint, a demonstrated failure mode, or a necessary prerequisite. Architecture preference alone is not justification. If no concrete justification exists:
> *OUT OF SCOPE.*

---

## 2. Architecture

**Trigger**: Boundary changes, new layers, ownership-affecting changes.

Ask:
- Which component is authoritative for this state?
- Is the responsibility in the right subsystem?
- Does this create a second source of truth?
- Does this introduce hidden coupling (import, network call, shared table)?
- Is there an existing capability this change bypasses?
- Does the new layer own a concrete boundary, or is it pure indirection?

Standard: a theoretical alternative design is not a finding. A violated invariant or incompatible contract is.

---

## 3. Correctness

**Trigger**: Logic changes, guard additions, mutation ordering, validation changes.

Ask:
- What invariant must always hold?
- Where is that invariant enforced?
- Can a different execution path bypass the guard?
- Is the check performed before or after the dangerous mutation?
- Is validation authoritative, or can callers skip it?
- Does the test prove the behavior, or does it only test a helper in isolation?

---

## 4. Concurrency

**Trigger**: Shared mutable state, async operations, worker pools, caches.

Ask:
- Can two concurrent callers produce duplicate or conflicting state?
- Is the check-then-write sequence atomic, or is there a window?
- Is idempotency guaranteed by the implementation or merely assumed?
- What is the crash window between critical operations?
- Does deterministic naming prove safety, or only reduce the collision surface?

Standard: do not demand distributed locking without first establishing that the existing primitive is insufficient.

---

## 5. Failure Modes

**Trigger**: Multi-step operations, external calls, writes followed by dependent operations.

Ask:
- What state remains if step N succeeds and step N+1 fails?
- Can the partial state become authoritative on recovery?
- Is the operation safely retryable?
- Can a retry cause duplicate effects?

Focus on real execution paths. Do not construct a theoretical disaster catalog.

---

## 6. Security

**Trigger**: Auth checks, trust boundaries, external input, token handling, secret usage.

Ask:
- Is the authorization check performed before or after the dangerous operation?
- Can a caller skip the check by using a different code path?
- Is user input validated at the trust boundary, or deep inside the call stack?
- Are secrets present in logs, error messages, or response bodies?
- Does the change introduce a new trust boundary that is currently unchecked?

Reference: `security-craftsman` for detailed domain guidance.

---

## 7. Data Consistency

**Trigger**: Schema changes, cross-table writes, distributed writes, cache invalidation.

Ask:
- Can two tables represent contradictory state after this change?
- Is the write atomic, or can partial writes corrupt the record?
- If a process dies between write A and write B, what state remains?
- Is the cache invalidated before or after the canonical state changes?

Reference: `database-craftsman` for detailed domain guidance.

---

## 8. Claims vs. Evidence

**Trigger**: Any review — especially when "done", "fixed", or "resolved" is asserted.

Evidence progression:
```text
IMPLEMENTED → TESTED → VERIFIED → OPERATIONALLY READY → PRODUCTION VERIFIED
```

Common gaps to detect:
- Unit test coverage cited as proof of concurrent safety.
- Synthetic reproduction cited as proof of production incident resolution.
- Existence of code cited as satisfaction of a requirement.
- No observed errors cited as proof that failure cannot occur.

---

## 9. Production Readiness

**Trigger**: Explicit `/contra production` or when operational claims are made.

Ask:
- Has the change been tested under production-like load and concurrency?
- Are failure modes observable (metrics, logs, alerts)?
- Is there a rollback path if the change behaves incorrectly in production?
- Does "it works locally" translate to "it works under production conditions"?

Standard: distinguish IMPLEMENTED, TESTED, VERIFIED, OPERATIONALLY READY,
and PRODUCTION VERIFIED. Do not allow these to collapse into a single claim.

---

## Stop Condition Reminder

When the relevant attack surface has been covered with no material finding: **PASS**.

Do not continue auditing to appear thorough.

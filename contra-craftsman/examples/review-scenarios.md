# Contra Craftsman: Review Examples

Five reference scenarios demonstrating Contra's review behavior.

> **Epistemic Standard**: Repository premises in these examples are marked `[FIXTURE]`. The label `[OBSERVED]` is reserved for live workspace inspections. `[UNINSPECTED]` means evidence not yet inspected — triggers inspection. `[UNKNOWN]` means evidence was investigated within the available boundary but the claim cannot be established — does not authorize invention.

---

## Example A — PASS (Claim Is Fully Supported)

**Invocation**: `/contra`

**Context**:
> Agent fixes a CSS class name on a login button. Diff is one line. No logic, no backend, no state.

**Review**:

```text
CONTRA REVIEW
Target:  LoginForm.tsx — button color class change
Mode:    general
Verdict: PASS

CLAIMS ACCEPTED:
  - [FIXTURE] Change is localized to one file, one line.
  - [FIXTURE] No backend, auth, or database component is affected.
  - Blast radius is zero outside the single styled element.

NOT FINDINGS:
  - Theming system absence: not required for a single styling fix.
  - Accessibility contrast: not in scope unless the new color was specified
    without a contrast check. [UNINSPECTED] — trivially verifiable by inspection
    if the color is being changed to a new value.

NEXT: Proceed.
```

---

## Example B — CONDITIONAL (Claim Exceeds Evidence)

**Invocation**: `/contra claims`

**Context**:
> Agent says "All tests pass — the race condition in the promotion pipeline is fixed."
> `[FIXTURE]` Test suite is unit tests against a single-threaded in-memory implementation.

**Review**:

```text
CONTRA REVIEW
Target:  Promotion pipeline — race condition fix claim
Mode:    claims
Verdict: CONDITIONAL

FINDINGS:

[MAJOR] Unit tests do not establish concurrent safety
  Claim:          "Race condition is fixed."
  Evidence:       [FIXTURE] Unit tests pass against a single-threaded in-memory mock.
  Gap:            Single-threaded tests cannot demonstrate concurrent execution behavior.
                  The race manifests only when two promotions attempt the same key
                  simultaneously — a condition the test suite does not reproduce.
  Why it matters: The bug can recur in production without detection.
  Smallest action: Add a concurrent stress test: two goroutines promoting the same
                   key simultaneously, assert only one succeeds and the other errors
                   cleanly. If the existing atomic primitive covers it, the test
                   will prove it. If not, the test will expose the gap.

CLAIMS ACCEPTED:
  - Single-promotion path behavior is tested and passes.

CLAIMS NOT PROVEN:
  - "Race condition is fixed" — concurrent path not exercised.

NEXT: Add concurrent promotion test. If it passes, emit PASS.
      If it fails, the fix is incomplete.
```

---

## Example C — BLOCKED (Scope Drift)

**Invocation**: `/contra scope`

**Context**:
> Task: fix a nil-pointer dereference in the order confirmation handler.
> `[FIXTURE]` Agent's proposed diff includes: fix to the nil check, a new `EventBus` abstraction,
> migration adding a `confirmed_at` column, and refactored email-sending logic.

**Review**:

```text
CONTRA REVIEW
Target:  Order confirmation nil-pointer fix — proposed diff
Mode:    scope
Verdict: BLOCKED

FINDINGS:

[BLOCKER] Three unrelated changes bundled with a one-line bug fix
  Claim:          Diff addresses the nil-pointer dereference.
  Evidence:       [FIXTURE] Nil check fix is present. Three additional changes
                  are also present with no stated requirement.
  Gap:
    - EventBus abstraction: no requirement requests decoupling event dispatch.
    - confirmed_at migration: not required to fix a nil dereference.
    - Email logic refactor: email sending worked before; no deficiency demonstrated.
  Why it matters: Each bundled change introduces independent risk and blast radius.
                  A nil-pointer fix should be reviewable in isolation.
  Smallest action: Revert to nil check only. Open separate tasks for
                   EventBus and schema changes if they are independently justified.

CLAIMS ACCEPTED:
  - Nil-pointer fix itself is present and appears correct.

NOT FINDINGS:
  - Code quality of the email refactor: may be an improvement, but
    correctness of the original is not at issue here.

NEXT: Isolate the nil-pointer fix. Resubmit the other changes as separate
      PRs with their own requirements and verification.
```

---

## Example D — CONDITIONAL (Concurrency Gap)

**Invocation**: `/contra concurrency`

**Context**:
> `[FIXTURE]` File upload deduplication: agent uses `sha256(content)` as the storage key,
> checks for key existence before writing, and states "deterministic naming prevents duplicates."

**Review**:

```text
CONTRA REVIEW
Target:  File upload deduplication — deterministic key claim
Mode:    concurrency
Verdict: CONDITIONAL

FINDINGS:

[MAJOR] Existence check and write are not atomic
  Claim:          "Deterministic naming prevents duplicate uploads."
  Evidence:       [FIXTURE] SHA-256 key is deterministic per content.
                  [FIXTURE] Existence check runs before write.
                  [UNINSPECTED] Whether the storage backend's write is conditional
                                (e.g. PUT-if-absent) or unconditional — not yet
                                inspected in the storage client configuration.
  Gap:            Two concurrent uploads of the same content can both pass the
                  existence check before either write completes.
                  Deterministic naming reduces the problem to one key, but
                  does not make the check-then-write atomic.
  Why it matters: Depending on the storage backend, this may result in a
                  redundant write (benign) or a partial overwrite (data loss).
  Smallest action: Inspect the storage client to determine whether it supports
                   an atomic conditional write (e.g. S3 conditional PUT, GCS
                   x-goog-if-generation-match). If yes, use it — no lock needed.
                   If not, characterize the failure mode and decide whether
                   it is acceptable for the use case.

CLAIMS ACCEPTED:
  - Naming collision probability is reduced to zero for identical content.
  - Single-writer path is correct.

CLAIMS NOT PROVEN:
  - Concurrent deduplication safety — depends on storage write atomicity.

NEXT: Inspect storage client implementation. If conditional write is
      available, use it and re-invoke /contra to confirm.
```

---

## Example E — UNKNOWN (Insufficient Evidence)

**Invocation**: `/contra production`

**Context**:
> `[FIXTURE]` Agent states "the incident is resolved" after a synthetic reproduction passes.
> `[FIXTURE]` The original incident involved a live database under concurrent load.
> `[FIXTURE]` The reproduction ran on a local SQLite instance with a single thread.

**Review**:

```text
CONTRA REVIEW
Target:  Incident resolution claim
Mode:    production
Verdict: UNKNOWN

FINDINGS:

[MAJOR] Production conditions not reproduced
  Claim:          "The incident is resolved."
  Evidence:       [FIXTURE] Synthetic reproduction passes on local SQLite,
                            single thread.
  Gap:            The production incident occurred under:
                    - PostgreSQL (not SQLite)
                    - Concurrent load (not single-threaded)
                    - Real network latency between service and database
                  None of these conditions are present in the reproduction.
  Why it matters: The fix may address the symptom visible in the simplified
                  reproduction while the root cause in production remains active.
  Smallest action: Re-run the reproduction against PostgreSQL under concurrent
                   load matching production conditions. If the fix holds, the
                   claim advances from UNKNOWN toward VERIFIED.

CLAIMS ACCEPTED:
  - Fix is implemented.
  - Simplified single-threaded reproduction passes.

CLAIMS NOT PROVEN:
  - "Incident is resolved" — production conditions not matched.

NOT FINDINGS:
  - SQLite vs PostgreSQL per se: the concern is concurrent load and lock
    behavior, not the database choice in isolation.

NEXT: Reproduce under PostgreSQL + concurrent load. Then re-invoke /contra.
```

---
name: scope-guard-craftsman
description: >-
  Practical operational discipline for coding agents to identify and communicate the smallest justified change before implementation.
  Prevents architecture hallucination, redundant abstractions, duplicate systems, and silent scope expansion.
license: MIT
---

# Scope Guard Craftsman

Scope Guard Craftsman makes coding agents identify and communicate the **smallest justified change** before implementation.

It prevents:
- Architecture hallucination and assuming missing capabilities without inspecting the repository.
- Unnecessary abstractions, duplicate helpers, and redundant services.
- Silent scope expansion and opportunistic refactoring of unrelated code.
- Premature database migrations, new dependencies, and speculative frameworks.

---

## 1. Core Rule

Before proposing implementation details, identify the smallest existing-system change that can satisfy the request. 

Do not introduce new architecture or capabilities without either explicit user intent or repository evidence showing they are justified.

When evaluating how to satisfy a request:
1. Is there an existing component, function, or route that already owns this behavior?
2. Can the request be satisfied by modifying or extending it in-place?
3. Is there an existing library or utility that already provides the needed capability?
4. If not, what concrete repository evidence proves a new abstraction is justified?

---

## 2. Scope-First Plan (The First-Sentence Rule)

Before writing or editing code, communicate the boundary in the **first sentence** of your plan.

The first sentence must answer:
> What exactly will change, and what important systems are not expected to change?

### Rules for the First Sentence:
- State the existing component/path being targeted when known; otherwise state the behavior or path being investigated.
- State which major systems (backend, database, auth, state) will remain untouched.
- Do not make absolute claims before inspection; state what is *expected* or *planned*, then verify.

### Examples:
- **Trivial UI**:
  > Plan: Update the existing login button styling to purple in the login component; no backend, authentication, or database change is expected.
- **Investigative / Path Unknown**:
  > Plan: Trace the existing checkout failure path and fix the smallest owning component; no payment or database redesign is planned.
- **API Extension**:
  > Plan: Extend the existing user profile serializer to expose `organization_name`; no new endpoints, database tables, or caching layers are planned.
- **Architectural Change**:
  > Plan: Decouple order confirmation emails from synchronous checkout via a transactional outbox table; no external message broker or queue cluster will be introduced.

---

## 3. Evidence Discipline

Distinguish repository facts from assumptions. Use these labels when uncertainty affects implementation decisions:

- `[PROVEN]` — A behavior, relationship, or claim verified through sufficient evidence such as code tracing, tests, compiler checks, or runtime verification.
- `[OBSERVED]` — A fact or artifact directly seen in the repository or runtime (e.g. package listed in manifest, file exists).
- `[INFERRED]` — Reasonable conclusion that still requires repository validation.
- `[UNKNOWN]` — Information not yet established. Triggers targeted inspection, never invention.
- `[CONFLICT]` — Evidence disagrees. Stop and reconcile before proceeding.

Never present `[INFERRED]` as `[PROVEN]`. Never treat `[UNKNOWN]` as an invitation to invent new systems.

---

## 4. Existing-System First

Prefer extending or composing existing capabilities before introducing new ones.

Do not create:
- a new service, manager, or repository layer
- a new state store or caching mechanism
- a new database table or schema migration
- a new third-party dependency
- a new configuration system

merely because it makes the design feel cleaner in isolation. The existing codebase's architecture takes precedence over personal stylistic preference.

---

## 5. The New Architecture Gate

Default: **Do not introduce new architecture unless it is explicitly requested or repository evidence shows the existing system cannot satisfy the requirement safely.**

The Gate applies to new architectural boundaries or capabilities (e.g., new services, persistent tables altering ownership, queue boundaries, state systems, dependencies, or infrastructure). A standard new file (e.g. a component or unit test) follows normal reuse reasoning, not the Architecture Gate.

Before introducing a new architectural element, establish:
1. **Existing path**: What existing file or capability was considered as a host?
2. **Deficiency**: Why can the existing code not safely satisfy the requirement?
3. **Simpler alternatives**: What smaller modifications were evaluated and rejected?
4. **Justification**: Why is a new architectural element necessary?

For non-trivial architectural additions, present this justification in the plan before implementing.

---

## 6. Scope Boundaries & Drift Control

Keep scope bounded during both planning and execution:

### In Scope vs Out of Scope
- **IN SCOPE**: The minimal delta required to satisfy the user prompt.
- **OUT OF SCOPE**: Unrelated files, adjacent tech debt, code formatting, and unrequested enhancements.

### Handling Scope Drift
If unexpected complexity is discovered during implementation:
1. Identify the newly discovered requirement.
2. State why it changes the original plan.
3. If it still fits a minimal change, update the plan and proceed.
4. If it materially expands the boundary (e.g., missing API, broken schema), stop and inform the user.

Never perform opportunistic refactoring ("while I'm here") on unrelated code.

---

## 7. Stop / Ask / Proceed

- **Proceed**: Request is clear, existing path is understood, and scope is bounded.
- **Inspect**: An implementation-critical fact is `[UNKNOWN]`. Inspect the code instead of guessing or asking obvious questions.
- **Ask**: User intent contains genuine business ambiguity that code inspection cannot resolve.
- **Stop / Reconcile**: Repository evidence conflicts or contradicts the request.
- **Re-plan**: Discovered evidence materially alters the required scope.

---

## 8. Proportional Verification

Verification must match the blast radius of the change:
- **Cosmetic / UI**: Inspect the diff; verify element rendering and interactions; check console for errors.
- **Localized Logic / API**: Run or write targeted unit tests; verify request/response contract; inspect diff.
- **Schema / Migration**: Validate migration syntax; verify forward and rollback steps; run affected model tests.
- **Architectural Change**: Run integration test suites; verify boundary isolation and backward compatibility.

Verify enough to prove the change works and that scope did not drift unexpectedly.

---

## License

This skill is open source under the [MIT License](LICENSE).

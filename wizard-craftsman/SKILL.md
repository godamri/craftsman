---
name: wizard-craftsman
description: >-
  Practical intake compilation and skill orchestration guidance. Transforms ambiguous or
  multi-domain requests into bounded execution contracts by selecting the minimum sufficient
  Craftsman skills without keyword routing or prompt bloat.
license: MIT
---

# Wizard Craftsman: Intake Compilation & Skill Orchestration

## Preamble & Core Orchestration Axiom

> **Craftsman skills teach the agent how to engineer.**  
> **Wizard decides which craftsmanship the task requires.**  
> **Wizard may compile uncertainty; it must not compile assumptions as facts.**

Wizard is an **intake compiler, scope bounder, and skill router**. It is not an implementation agent, a generic prompt lengthener, a runtime policy engine, or a replacement for specialized Craftsman skills.

---

## 1. Invocation & Trigger Semantics

Wizard compiles requests into bounded execution contracts via three semantic entry paths:

### A. Explicit Invocation
The user explicitly requests the Wizard planning, intake, or contracting step.
- Examples:
  - *"Compile this with Wizard first."*
  - *"Create an Execution Brief first."*
  - *"Wizard-kan task ini."*
  - *"Map the scope, skills, risk, and verification before coding."*
- **Explicit invocation takes precedence over normal bypass.** If the user explicitly asks for Wizard even for a trivial task, Wizard is invoked to produce a bounded contract. This does not make Wizard mandatory middleware for unprompted trivial tasks.

### B. Implicit Planning Request
The user does not explicitly name "Wizard", but explicitly requests pre-execution planning, scoping, ambiguity analysis, risk evaluation, discipline routing, or verification mapping before implementation.
- Example:
  - *"Don't edit the code yet. Map the scope, risks, and verification plan first."*
- Treat this as a semantic planning request entering Wizard compilation.

### C. Task-Driven Eligibility
The user does not explicitly invoke Wizard, but task characteristics make direct execution inappropriate without formal intake:
- Material ambiguity requiring resolution or branch identification.
- Implementation-bound multi-domain tasks requiring cross-discipline coordination.
- Consequential schema/data migrations, security/authorization boundary modifications, financial/ledger state updates, or meaningful operational blast radius.

> **Semantic Decision Rule**: Triggering is strictly semantic, **never keyword-based**. Words such as *"database"*, *"risk"*, *"architecture"*, *"security"*, or *"before"* appearing in isolation must **NOT** trigger Wizard. Eligibility depends entirely on operational consequence and task characteristics.

---

## 2. Bypass Semantics

Wizard is **not** a mandatory gateway for every prompt. Wizard complexity must itself earn its place.

> **Bypass Rule**: Bypass means Wizard is not required by default for low-consequence, trivial, or unambiguous tasks. It does **not** prohibit explicit invocation.

Bypass Wizard and handle requests directly when the task is:
- **Trivial or localized**: Simple typos, formatting, isolated styling tweaks, or one-line bug fixes.
- **Direct & unambiguous**: The exact file, function, and expected behavior are already fully specified by the user.
- **Low-consequence**: Read-only code inspections, syntax explanations, or localized unit test additions with zero blast radius.
- **Single-domain without ambiguity**: Straightforward implementation tasks where the governing domain skill is obvious and uncontested.

If the user explicitly requests Wizard on a task that would otherwise qualify for bypass, honor that request and output a compact, bounded execution contract.

---

## 3. Human Vocabulary vs. Internal Model

Users are **not** expected to know or use internal Wizard terminology. Users communicate in natural human intent (e.g. *"Petakan dampaknya sebelum coding"* or *"Wizard-kan task ini"*).

Wizard internally maps the request into its intermediate representation and emits an operational contract:

```text
Human language
      ↓
Wizard interpretation
      ↓
WizardIR
      ↓
Execution Brief
```

Users do not need to understand concepts like `WizardIR`, `PRIMARY`, `REQUIRED`, `CONDITIONAL`, `EvidenceLevel`, `Material Ambiguity`, or `ReviewPolicy`. These are internal and contractual concepts.

---

## 4. The Core Intake Pipeline & Handoff Boundary

Wizard compiles requests into bounded execution contracts through this sequential pipeline:

```text
1. Invocation / Eligibility  --> Triggered via Explicit, Implicit Planning, or Task-Driven path.
   ↓
2. Intent Extraction         --> Extract observable target outcomes and explicit non-goals.
   ↓
3. Scope Bounding            --> Apply the first-sentence rule: identify what changes and what stays untouched.
   ↓
4. Evidence Analysis         --> Label known facts vs missing material facts ([UNKNOWN]).
   ↓
5. Ambiguity Gate            --> Detect material ambiguities; block architectural commitment if found.
   ↓
6. Risk Assessment           --> Derive operational risk from consequence and blast radius.
   ↓
7. Skill Selection           --> Select minimum sufficient skills (PRIMARY, REQUIRED, CONDITIONAL) and record exclusions.
   ↓
8. Verification Plan         --> Define claim-dependent verification obligations and regression guards.
   ↓
9. Execution Brief           --> Render compact, reviewable execution contract.
   ↓
10. Handoff Boundary         --> Await clearance if required, then hand off cleanly to downstream agent.
```

### The Handoff Boundary

```text
Invocation / Eligibility
        ↓
  Wizard Intake
        ↓
 Execution Brief
        ↓
     HANDOFF
        ↓
 Downstream Agent
```

Wizard **terminates at the handoff boundary**. Wizard does **not** become:
- Runtime execution middleware
- Execution loop supervisor
- AST police
- Mandatory recursive re-planner
- Per-edit code modification approver

Once the Execution Brief is emitted and cleared, downstream execution is owned entirely by the downstream agent under the authority of `execution-craftsman`, `scope-guard-craftsman`, and the selected domain skills.

---

## 5. Epistemic Discipline

Wizard strictly adheres to empirical evidence standards. Distinguish certainty levels:

- `[PROVEN]` — Demonstrated through direct code tracing, compiler checks, or reproducible tests in the active workspace.
- `[OBSERVED]` — Directly witnessed in the inspected repository (e.g. file present on disk, package listed in manifest).
- `[SUPPORTED]` — A non-material interpretation supported by explicit prompt context and available repository evidence, while remaining subject to correction. (A mere guess or unsupported assumption is not sufficient).
- `[INFERRED]` — Reasonable deduction requiring explicit validation.
- `[UNKNOWN]` — Necessary repository fact not yet established. Triggers reconnaissance; never guessing.
- `[CONFLICT]` — Contradictory evidence between prompt and repository. Requires reconciliation before proceeding.

> **Testing / Example Rule**: For hypothetical benchmarks or example scenarios, never use `[OBSERVED]`. Use `[FIXTURE]` or `[EXAMPLE CONTEXT]` instead.

---

## 6. The Material Ambiguity Gate

Wizard enforces a strict boundary between two distinct forms of uncertainty:

```text
┌───────────────────────────────────┬───────────────────────────────────┐
│ UNKNOWN REPOSITORY FACT           │ MATERIAL AMBIGUITY                │
├───────────────────────────────────┼───────────────────────────────────┤
│ Missing technical detail from the │ Underspecified user intent that   │
│ codebase (e.g. table schema, env  │ could fundamentally alter the     │
│ variable name, library version).  │ architecture, data model, security│
│                                   │ boundary, or operational risk.    │
│                                   │                                   │
│ ACTION: Schedulable reconnaissance│ ACTION: BLOCK commitment.         │
│ directive for downstream agent.   │ Surface clarification to user.    │
└───────────────────────────────────┴───────────────────────────────────┘
```

### The Blocking Rule

If an intake request contains a **material ambiguity**:
1. `risk.policy = MANDATORY`
2. `intent.status = AWAITING_CLARIFICATION`
3. `status = AWAITING_CLARIFICATION`
4. Architectural commitment is **STRICTLY PROHIBITED**.
5. The Execution Brief must highlight the architectural forks and surface them for human resolution. Do not invent a "reasonable baseline" and proceed as if approved.

---

## 7. Scope Bounding & The First-Sentence Rule

Before code is edited, the task's boundary must be established in the **first sentence** of the brief:
- State what will change.
- State which major systems (database, auth, API, frontend) will remain untouched.

```text
Example First Sentence:
"Add an isolated Google Drive adapter conforming to the existing StorageProvider 
interface; no database schema modifications or public CDN changes are planned."
```

Explicitly define:
- **In Scope**: The minimal functional delta needed to satisfy the request.
- **Out of Scope**: Neighboring technical debt, opportunistic refactoring, dependency upgrades, or unrequested features.

---

## 8. The Consequence-Derived Risk Model

Risk is determined by **operational consequence and blast radius**, including factors such as irreversibility, invariant sensitivity, and evidence gaps.

Domain involvement is a **risk factor**, not an automatic risk level.

```text
Domain Involvement  +  Blast Radius  +  Irreversibility  +  Invariant Sensitivity  +  Evidence Gaps
                                             ↓
                                      Derived Risk Level
```

- Mentioning the word "database" in a comment or documentation edit is **LOW**.
- Executing an un-indexed DDL migration on a live table with lock contention risk is **HIGH**.
- Touching authentication middleware for comment cleanup is **LOW**.
- Altering token verification or authorization semantics is **HIGH**.

**HIGH** is warranted when assessed consequence is high, such as material impact to data integrity, authorization semantics, financial state, destructive operations, irreversible production changes, or unresolved material ambiguity.

The presence of a domain keyword alone does not determine risk level. Do **NOT** encode `database = HIGH`, `auth = HIGH`, or `finance = HIGH` as an automatic rule.

### Risk Tiers & Review Policies:

| Risk Level | Operational Criteria | Review Policy | Downstream Action |
| :--- | :--- | :--- | :--- |
| **LOW** | Localized, easily reversible, zero blast radius outside single file, 0 material ambiguities. | `NONE` | Agent may proceed directly to execution. |
| **MEDIUM** | Crosses module boundaries, internal API extensions, manageable unknowns without high consequence. | `RECOMMENDED` | Brief presented to user; proceed unless corrected. |
| **HIGH** | High operational consequence (e.g. data integrity impact, authorization semantics changes, financial/ledger mutations, destructive operations, irreversible schema changes), or **any unresolved Material Ambiguity**. | `MANDATORY` | **Hard block.** Execution prohibited until human explicitly clears the brief. |

---

## 9. Skill Routing: Five-Dimensional Boundary Model

Wizard rejects naive lexical matching (e.g., matching "Go" in a CI config edit to `go-craftsman`). Route skills across **five operational dimensions**:

1. **Artifact & Subsystem**: Which physical files, directories, and systems are targeted?
2. **Invariant & Risk Domain**: What correctness invariant is at stake (concurrency, data integrity, auth, memory)?
3. **Language & Runtime**: Which programming language and runtime environment executes the change?
4. **Verification Blast Radius**: What testing discipline is required by the change's blast radius?
5. **Repository Evidence**: What frameworks, libraries, and patterns actually exist in the codebase?

### Skill Classification

Wizard classifies skills into **three selected-skill tiers** plus an explicit record of rejected candidates:

- **`PRIMARY`**: The central discipline directly governing the primary functional delta (e.g. `database-craftsman` for DDL; `go-craftsman` for Go concurrency).
- **`REQUIRED`**: Non-negotiable cross-cutting disciplines needed for boundary containment or verification (`scope-guard-craftsman` and `execution-craftsman` are standard required execution pillars).
- **`CONDITIONAL`**: Withheld pending an explicit reconnaissance trigger. Must define:
  $$\text{Activate Skill } S \text{ IF AND ONLY IF Reconnaissance proves Condition } C.$$
- **`meaningful_exclusions`**: Rejection records for non-obvious candidates, explaining why a seemingly relevant skill was omitted. (Do not pollute human output with obvious exclusions like `rust-craftsman` on a Python task).

### The Boundary Ownership Rule

> **Every selected skill must own a concrete engineering boundary.**

Do not introduce arbitrary skill caps (e.g. "maximum 3 skills"). A task may legitimately select 5 or 6 skills if each has an independently justified, non-overlapping boundary. However, every selected skill must answer:
*"If this skill is omitted, what concrete correctness, safety, or scope invariant is left unmanaged?"*

---

## 10. Authority Boundaries

Wizard must never usurp downstream Craftsman skills:

```text
┌─────────────────────────┬────────────────────────────────────────────────────────┐
│ Skill                   │ Respective Authority Boundary                          │
├─────────────────────────┼────────────────────────────────────────────────────────┤
│ wizard-craftsman        │ Intake contract, intent compilation, scope bounding,   │
│                         │ ambiguity detection, risk tiering, and skill routing.  │
│                         │ DOES NOT write code. DOES NOT run milestone loops.     │
├─────────────────────────┼────────────────────────────────────────────────────────┤
│ scope-guard-craftsman   │ Authoritative runtime guard against scope drift during │
│                         │ code editing. Enforces smallest justified change.      │
├─────────────────────────┼────────────────────────────────────────────────────────┤
│ execution-craftsman     │ Authoritative owner of execution: 12-step milestone    │
│                         │ delivery loop, falsification probes, and regression.   │
├─────────────────────────┼────────────────────────────────────────────────────────┤
│ engineering-craftsman   │ Authoritative owner of constitutional correctness,     │
│                         │ Automatic Release Vetoes, and production readiness.    │
├─────────────────────────┼────────────────────────────────────────────────────────┤
│ Domain Skills           │ Authoritative technical correctness within domain      │
│ (DB, Go, React, etc.)   │ (SQL DDL lock_timeout, goroutine bounds, hook lifecycles).│
└─────────────────────────┴────────────────────────────────────────────────────────┘
```

---

## 11. Reconnaissance Boundary (Model A)

In v0.1, Wizard operates under **Model A (Instructional Reconnaissance)**:
1. Wizard inspects context and repository evidence available at intake.
2. Missing repository facts are tagged `[UNKNOWN]`.
3. **Reconnaissance Directive Rule**: Every *material* `[UNKNOWN]` required for the selected contract or verification obligations must become a reconnaissance directive. Irrelevant unknowns do not need to be surfaced merely because they are unknown.
4. The downstream executing agent runs the reconnaissance (using read-only tools or terminal inspection) before editing code.
5. Discovered facts satisfy conditional skill triggers or resolve unknowns.

Wizard identifies what must be learned; downstream agent performs read-only reconnaissance; only then does implementation begin. Wizard does not build or require a separate autonomous reconnaissance runtime and must never invent repository facts.

---

## 12. The Output Contract & Execution Brief

A Wizard invocation produces an **Execution Brief** or equivalent bounded contract containing, at minimum:
1. **Intent status** (epistemic state of interpretation)
2. **Scope** (in-scope targets and out-of-scope non-goals)
3. **Material ambiguities** (blocking architectural forks, or none)
4. **Evidence & relevant UNKNOWNs** (established facts and material reconnaissance directives)
5. **Skill routing** (selected disciplines with boundary ownership justifications)
6. **Risk and review policy** (consequence-derived tier and approval requirement)
7. **Verification obligations** (observable boundary checks, falsification, and regression guards)
8. **Disposition** (workflow state: ready, awaiting clarification, or awaiting approval)

The output must be **concise and operational**. Do not require a fixed verbose template for every task. For trivial, explicitly-invoked tasks, the brief can be small. Wizard produces a bounded execution contract, not an essay.

### Execution Brief Structure

```text
================================================================================
CRAFTSMAN EXECUTION BRIEF: [Task Name]
================================================================================
STATUS:         [ READY | AWAITING_CLARIFICATION | REPLAN_REQUIRED ]
RISK LEVEL:     [ LOW | MEDIUM | HIGH ]
REVIEW POLICY:  [ NONE | RECOMMENDED | MANDATORY ]
FIRST SENTENCE: [What will change, and what major systems will remain untouched]

1. INTENT & OBJECTIVES:
   - Intent Status:        [ KNOWN | SUPPORTED | AWAITING_CLARIFICATION ]
   - Primary Objective:    [Clear 1-sentence goal]
   - Expected Outcome:     [Observable system behavior]
   - Non-Goals:            [Explicitly excluded outcomes]
   - Material Ambiguities: [None, OR list of forks blocking commitment]

2. BOUNDED SCOPE:
   - In Scope:     [Target components, files, endpoints]
   - Out of Scope: [Adjacent modules, refactoring, dependencies, formatting]

3. DISCIPLINE ROUTING:
   - PRIMARY:      [Skill] — [Boundary/invariant responsibility]
   - REQUIRED:     [Skill] — [Scope containment or execution pillar]
   - CONDITIONAL:  [Skill] — Activated IF [Reconnaissance condition]
   - MEANINGFUL EXCLUSIONS: [Non-obvious rejected candidates with technical reason]

4. EVIDENCE & RECONNAISSANCE:
   - Established Facts:
     * [OBSERVED / PROVEN] [Fact statement]
   - Material Reconnaissance Directives:
     * [UNKNOWN] [Missing material fact] --> Inspect: [Target path/command]

5. VERIFICATION OBLIGATIONS:
   - Boundary Check:   [Observable behavior verification]
   - Falsification:    [Failure paths, edge cases, concurrent races]
   - Regression Guard: [Test suites that must pass clean]

6. DISPOSITION:
   [ AWAITING HUMAN CLARIFICATION | AWAITING APPROVAL | CLEARED FOR EXECUTION ]
================================================================================
```

---

## 13. Status Semantics

Wizard explicitly distinguishes epistemic status from workflow disposition:

- **`intent.status` (Epistemic State)**: Describes the certainty of intent interpretation:
  - `KNOWN`: Prompt is bounded, specific, and unambiguous.
  - `SUPPORTED`: Non-material interpretation supported by prompt context and repository evidence, while subject to correction.
  - `AWAITING_CLARIFICATION`: Material ambiguity exists; intent cannot be safely established.
- **Top-Level `status` (Workflow Disposition)**: Describes the execution state of the contract:
  - `READY`: Contract is fully bounded and cleared for execution (or awaiting human approval if High Risk).
  - `AWAITING_CLARIFICATION`: Execution is blocked pending resolution of material ambiguities.
  - `REPLAN_REQUIRED`: Conceptual v0.1 disposition indicating downstream boundary conflict requiring recompilation.

These fields answer different questions and are not redundant.

---

## 14. Mid-Flight Recompilation (`REPLAN_REQUIRED`)

Wizard v0.1 does not implement recursive multi-agent execution loops. It defines the conceptual terminal state **`REPLAN_REQUIRED`**:

When the executing agent discovers during implementation that:
- A newly discovered repository boundary invalidates the Execution Brief;
- An unstated architectural dependency contradicts the scope contract; or
- The blast radius exceeds the approved Risk Level;

The agent must:
1. **PAUSE** code modifications immediately.
2. Record the conflict: `[CONFLICT] Discovered boundary X contradicts brief assumption Y`.
3. Set status to `REPLAN_REQUIRED`.
4. Surface the discrepancy for human review and re-compilation with Wizard.

---

## 15. Anti-Patterns & Failure Modes

- **Keyword Pavlovism**: Selecting `database-craftsman` because the word "data" appeared in prompt, even though the task is updating a UI label.
- **Kitchen-Sink Hoarding**: Selecting 8+ skills "just to be safe". Violates the Boundary Ownership Rule.
- **Assumption Compilation**: Compiling an underspecified request with silent architectural assumptions instead of flagging Material Ambiguity.
- **Execution Usurpation**: Wizard writing code diffs, planning line-by-line milestones, or running implementation tasks.
- **Fake Observations**: Using `[OBSERVED]` for hypothetical benchmark scenarios instead of `[FIXTURE]`.
- **Exclusion Vomiting**: Listing 12 obviously irrelevant skills in human-facing briefs. Only show meaningful, non-obvious exclusions.

---

## 16. Verification Expectations

Before releasing the Execution Brief:
- [ ] First sentence explicitly states what changes and what stays untouched.
- [ ] Every selected skill has a non-overlapping boundary ownership justification.
- [ ] All missing material repository facts are classified `[UNKNOWN]` with inspection directives.
- [ ] Any material ambiguity blocks architectural commitment (`status: AWAITING_CLARIFICATION`).
- [ ] Risk level is derived from operational consequence and blast radius, not lexical keywords.
- [ ] No implementation code diffs or detailed milestone loops are generated by Wizard.

---

## License

This skill is open source under the [MIT License](LICENSE).

# Wizard Intermediate Representation (`WizardIR`) Specification

This reference document defines the structural Intermediate Representation (`WizardIR`) used by `wizard-craftsman`.

`WizardIR` is a planning representation, not an executable AST, domain-specific language (DSL), or meta-framework. Its purpose is to make critical planning invariants structurally checkable before an Execution Brief is rendered for human review or agent handoff.

---

## 1. Type Definitions

```typescript
export type SkillTier =
  | 'PRIMARY'
  | 'REQUIRED'
  | 'CONDITIONAL';

export type RiskLevel =
  | 'LOW'
  | 'MEDIUM'
  | 'HIGH';

export type ReviewPolicy =
  | 'NONE'
  | 'RECOMMENDED'
  | 'MANDATORY';

export type IntentStatus =
  | 'KNOWN'
  | 'SUPPORTED'
  | 'AWAITING_CLARIFICATION';

export type EvidenceLevel =
  | 'PROVEN'
  | 'OBSERVED'
  | 'SUPPORTED'
  | 'INFERRED'
  | 'UNKNOWN_INSPECT'   // Resolvable by reconnaissance; agent inspects and records
  | 'UNKNOWN_DECIDE'    // Requires human decision; reconnaissance cannot resolve
  | 'CONFLICT';

export interface SkillSelection {
  name: string;
  tier: SkillTier;
  reason: string;
  condition?: string; // Required when tier === 'CONDITIONAL'
}

export interface MeaningfulExclusion {
  skill: string;
  reason: string;
}

export interface EvidenceRecord {
  statement: string;
  level: EvidenceLevel;
  source?: string;
}

export interface VerificationPlan {
  obligations: string[];
  blast_radius: string[];
}

export interface WizardIR {
  request: string;

  intent: {
    status: IntentStatus;
    interpretation: string;
    material_ambiguities: string[];
  };

  scope: {
    in_scope: string[];
    out_of_scope: string[];
  };

  evidence: EvidenceRecord[];

  skills: SkillSelection[];

  meaningful_exclusions: MeaningfulExclusion[];

  risk: {
    level: RiskLevel;
    factors: string[];
    policy: ReviewPolicy;
  };

  verification: VerificationPlan;

  status:
    | 'READY'
    | 'READY_PENDING_APPROVAL'
    | 'AWAITING_CLARIFICATION'
    | 'REPLAN_REQUIRED';
}
```


---

## 2. Field Semantics & Constraints

### Distinction Between `intent.status` and `status`
- **`intent.status` (Epistemic State)**: Answers *"What is the certainty of our interpretation of the user's intent?"*
  - `KNOWN`: User prompt is specific, bounded, and contains zero architecture-altering ambiguities.
  - `SUPPORTED`: A non-material interpretation supported by explicit prompt context and available repository evidence, while remaining subject to correction.
  - `AWAITING_CLARIFICATION`: The request contains material ambiguity. Blocks architectural commitment.
- **Top-Level `status` (Workflow Disposition)**: Answers *"Can execution begin right now?"*
  - `READY`: Planning complete. No blocking human decision remains. Execution permitted.
  - `READY_PENDING_APPROVAL`: Planning complete. Required human approval not yet granted. Execution prohibited.
  - `AWAITING_CLARIFICATION`: Material ambiguity detected; contract cannot yet be compiled. Architectural commitment and code modification prohibited.
  - `REPLAN_REQUIRED`: A previously accepted contract has encountered a new boundary, constraint, or decision that invalidates the current execution plan. Recompile before continuing.

These fields answer different questions and are not redundant.

### Approval Lifecycle Invariant
- `READY_PENDING_APPROVAL` → human approves → `READY` (execution permitted).
- `READY_PENDING_APPROVAL` → human rejects or changes a decision → `REPLAN_REQUIRED`.
- Human approval authorizes execution of the bounded contract. It does **not** silently resolve unresolved architectural decisions or expand scope.

### `intent`
- **`status`**: Epistemic state (`KNOWN`, `SUPPORTED`, `AWAITING_CLARIFICATION`).
- **`material_ambiguities`**: Array of underspecified architectural forks. If non-empty, `intent.status` MUST be `AWAITING_CLARIFICATION`, `risk.policy` MUST be `MANDATORY`, and top-level `status` MUST be `AWAITING_CLARIFICATION`.

### `scope`
- **`in_scope`**: List of specific files, modules, or subsystems targeted for modification.
- **`out_of_scope`**: Explicit list of neighboring components, unrequested refactoring, or dependencies that must remain untouched.

### `evidence`
- Array of facts evaluated during intake.
- Use `UNKNOWN_INSPECT` for facts that can be established through repository, environment, or system reconnaissance without requiring a human decision. Every material `UNKNOWN_INSPECT` fact required for the contract must produce a corresponding reconnaissance directive.
- Use `UNKNOWN_DECIDE` for facts that cannot be resolved by reconnaissance because they represent a human-owned product, architectural, boundary, or policy decision. Every material `UNKNOWN_DECIDE` required for the contract must be surfaced for human resolution. Agent must NOT silently choose a value. A material `UNKNOWN_DECIDE` results in `status: READY_PENDING_APPROVAL`, not `READY`.
- For benchmark/hypothetical examples, facts must use `[FIXTURE]` or `[EXAMPLE CONTEXT]` rather than `[OBSERVED]`.

### `skills`
- Three selected tiers: `PRIMARY`, `REQUIRED`, `CONDITIONAL`.
- `EXCLUDED` is not a selected tier; rejected candidates are recorded under `meaningful_exclusions`.
- Every entry in `skills` must have a non-empty `reason` asserting its boundary ownership.
- Every entry with `tier: 'CONDITIONAL'` must supply an explicit `condition`.

### `meaningful_exclusions`
- Exclusions that clarify non-obvious routing decisions (e.g. why `distributed-systems-craftsman` was excluded on a single-node background worker).
- Irrelevant skills (e.g. `rust-craftsman` on a Python task) are silently omitted from the brief.

### `risk`
- Consequence-derived from blast radius, irreversibility, invariant sensitivity, and evidence gaps. Domain involvement is a risk factor, not an automatic risk level.
- HIGH is warranted when assessed consequence is high (e.g. data integrity impact, authorization semantics changes, financial/ledger state mutations, destructive operations, irreversible schema changes), or unresolved material ambiguity. Domain keywords alone do not determine risk.
- `policy`:
  - `NONE`: Low risk, zero material ambiguity, immediate execution permitted.
  - `RECOMMENDED`: Medium risk, brief presented for review.
  - `MANDATORY`: High risk or present material ambiguities. Execution blocked until human approves; emit `READY_PENDING_APPROVAL`.

### `status`
- Top-level workflow disposition: `READY`, `READY_PENDING_APPROVAL`, `AWAITING_CLARIFICATION`, `REPLAN_REQUIRED`.

---

## 3. Structural Invariant Rules

Any valid `WizardIR` instance must satisfy these deterministic rules:

1. **Mutual Exclusion**: `skills.name` and `meaningful_exclusions.skill` must be disjoint sets. No skill can be simultaneously selected and excluded.
2. **Ambiguity Gate**: If `intent.material_ambiguities.length > 0`, then `intent.status === 'AWAITING_CLARIFICATION'`, `risk.policy === 'MANDATORY'`, and `status === 'AWAITING_CLARIFICATION'`.
3. **DECIDE Gate**: If any `evidence` entry has `level === 'UNKNOWN_DECIDE'` and that decision is material to the contract, then `status !== 'READY'`. Prefer `READY_PENDING_APPROVAL` when the contract is otherwise complete and only human clearance is missing.
4. **Conditionality Binding**: Every skill with `tier === 'CONDITIONAL'` must have a valid `condition` string.
5. **Boundary Ownership**: No two skills in `skills` may declare identical boundary responsibilities.


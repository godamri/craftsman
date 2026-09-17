# Evidence Model & Epistemic Discipline

Scope Guard Craftsman uses an evidence-first approach to prevent speculation and architecture hallucination.

---

## 1. The 5 Evidence States

| State | Definition | Source of Verification | Agent Action |
| :--- | :--- | :--- | :--- |
| **`[PROVEN]`** | A behavior, relationship, or claim verified through sufficient evidence such as code tracing, tests, compiler checks, or runtime verification. | File tracing, test execution, or compiler output. | Safe to build directly upon. |
| **`[OBSERVED]`** | A fact or artifact directly seen in the repository or runtime environment. | Manifests, file presence, code lines, or configs. | Contextual fact; trace deeper if core to the change. |
| **`[INFERRED]`** | A plausible deduction based on naming conventions or framework norms. | Unverified assumption about how a system works. | Must NOT be treated as fact until verified by code inspection. |
| **`[UNKNOWN]`** | Area of the codebase has not been inspected yet. | Unchecked files or modules. | Triggers targeted inspection. Never triggers invention. |
| **`[CONFLICT]`** | Code evidence directly contradicts the user request or another part of the codebase. | Contradicting types, configs, or conventions. | Stop and reconcile before writing or changing code. |

### Example:
```text
[OBSERVED] User.organization exists.
[PROVEN]   /api/me loads User.organization and serializes organization.name.
```

---

## 2. Epistemic Rules

1. **Never promote `[INFERRED]` to `[PROVEN]` without verification**:
   - *Bad*: "The repository likely lacks an email utility, so I'll create `EmailService.ts`."
   - *Good*: "Email sending mechanism is `[UNKNOWN]`. Searching for email helpers... `[OBSERVED]` existing `sendMail()` in `src/utils/mailer.ts`. Reusing it."
2. **`[UNKNOWN]` triggers inspection, never architecture**:
   - When you don't know how state, authentication, or routing works in the project, look at the code. Do not use ignorance as a license to introduce a new subsystem.
3. **Use labels proportionally**:
   - Explicit evidence labels are required when uncertainty materially affects the implementation plan.
   - For trivial tasks (e.g., changing a single color class), keep reasoning fast and do not litter the response with ceremonial labels.

---

## 3. Targeted Inspection Guidelines

- Inspect dependency manifests (`package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`) to know what libraries exist before suggesting an install.
- Use targeted symbol searches (`grep_search`, `find_by_name`) to locate existing components or helpers before writing new ones.
- Avoid indiscriminate full-codebase scans for localized changes.

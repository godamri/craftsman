# Anti-Patterns & Failure Modes

These patterns represent common ways coding agents fail to establish the smallest justified change, leading to bloated PRs, broken systems, and wasted effort.

---

## 1. Architecture Hallucination
- **Symptom**: Assuming capabilities do not exist in the codebase without checking, and writing new ones from scratch.
- **Example**: Creating a new JWT authentication helper when the repository already has an established auth middleware.
- **Remedy**: Search the repository manifests and symbol tables before drafting any foundational utility.

## 2. Premature Abstraction
- **Symptom**: Introducing generic frameworks, factory patterns, or configurable rule engines for a one-off task.
- **Example**: Creating an `AbstractNotificationProviderFactory` when the user asked to send a single Slack webhook.
- **Remedy**: Write the simplest concrete implementation first. Abstract when repeated behavior has stable shared semantics and the abstraction reduces real duplication, inconsistency, or maintenance risk.

## 3. Duplicate Systems
- **Symptom**: Creating a second helper, model, or API endpoint when an existing implementation already serves the purpose.
- **Example**: Adding a new `dateUtils.ts` when `src/common/time.ts` already contains standard formatters.
- **Remedy**: Search for existing domain terms across the codebase before creating new utility files.

## 4. Scope Creep
- **Symptom**: Solving adjacent problems or adding "nice-to-have" features that were never requested.
- **Example**: User asks to fix button alignment; agent also redesigns the entire form layout and updates validation copy.
- **Remedy**: State explicit Out-of-Scope boundaries in the first sentence of the plan and stick to them.

## 5. Premature Optimization
- **Symptom**: Adding complex caching, asynchronous queues, or database indexing layers without measuring performance bottlenecks.
- **Example**: Adding Redis caching for an endpoint that serves 10 requests a day from a table with 50 rows.
- **Remedy**: Require measurement and profiling evidence before optimizing.

## 6. Inference Inflation
- **Symptom**: Converting an unknown into a license to invent architecture (`[UNKNOWN]` $\to$ invent).
- **Example**: "I don't see how user permissions are checked, so I'll create a new RBAC system."
- **Remedy**: `[UNKNOWN]` triggers targeted inspection or clarification, never invention.

## 7. Unnecessary Migration
- **Symptom**: Altering persistent schemas or adding database columns for data that can be derived at runtime or handled in application state.
- **Example**: Adding a `full_name` column to the database when `first_name` and `last_name` already exist.
- **Remedy**: Prefer in-memory derived state unless persistence or query indexing mathematically requires a column.

## 8. Dependency Hoarding
- **Symptom**: Adding an external package for a small algorithm or utility easily solvable with standard libraries.
- **Example**: Installing an npm package to format numbers with commas.
- **Remedy**: Check if the language's standard library or already-installed dependencies can solve the problem.

## 9. Opportunistic Refactoring (The Uninvited Janitor)
- **Symptom**: "Cleaning up" untouched functions, re-formatting code, or fixing lint warnings in files visited during a task.
- **Example**: While fixing a 1-line bug in a 400-line file, changing the indentation and variable naming of the entire file.
- **Remedy**: Keep the diff limited to changes justified by the task. Avoid unrelated formatting, cleanup, and refactoring.

## 10. Implementation Without Understanding
- **Symptom**: Writing code immediately based on the prompt without locating where the feature or bug lives in the existing architecture.
- **Example**: Blindly adding an express middleware without seeing how route guards are currently structured.
- **Remedy**: Always trace the existing path before writing code.

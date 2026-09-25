# Code Comments & Output Hygiene

> **Core Principle**: Comments should preserve information that would otherwise be lost.  
> **Comment the *why*; let the code explain the *what*.**

---

## 1. The Anti-Pattern: Low-Information Noise

Generated code often suffers from visual clutter—comments that narrate syntax, add decorative ASCII art, or repeat function signatures without conveying actual rationale. This noise increases maintenance burden, obscures critical logic, and desensitizes engineers to genuine warning comments:

```text
❌ LOW-INFORMATION NOISE:
   // ==========================================
   // AUTHENTICATION CONTROLLER
   // ==========================================

   // Step 1: Initialize user count
   let count = 0; // initialize count

   // 🚀 Fast validation
   // ✅ Passed checks
   /**
    * Process transaction.
    * @param id The id.
    * @param amount The amount.
    * @returns The transaction result.
    */
```

---

## 2. Low-Value Comments to Eliminate

Language models must actively eliminate the following comment categories across all languages (Go, Rust, Python, TypeScript, SQL, Shell):

| Category | Tell & Example | Elimination Reason | Action |
| :--- | :--- | :--- | :--- |
| **Decorative Banners** | `// ================= ROUTES =================`<br>`/* ---------- CORE LOGIC ---------- */` | Adds visual shouting and ASCII noise without informational value. | Remove entirely, or use standard single-line section headers only if organizing a multi-hundred-line file. |
| **Restating the Obvious** | `user = User() # Create user instance`<br>`let total = price * qty; // Calculate total` | Duplicates what the syntax already states unambiguously. | Delete the comment. |
| **Workflow Narration** | `// Step 1: Parse JSON`<br>`// Step 2: Query DB`<br>`// Step 3: Return response` | Treats control flow like an instruction manual. Code structure should convey flow. | Delete narration. If flow is hard to follow, refactor into clear, well-named functions. |
| **Empty Labels** | `// Business logic`<br>`// Helper function`<br>`// Main entry point` | Names a generic category without stating any fact or invariant. | Delete unless stating a non-obvious design boundary. |
| **Signature Echoing** | JSDoc/docstrings that merely repeat parameter types and names without semantic context (`@param amount the amount`). | Doubles documentation volume while providing zero additional context. | Document domain constraints, valid ranges, error behaviors, or units (e.g. `amount in cents, must be > 0`). Omit redundant echoes. |
| **Vague Placeholders** | `// TODO: fix this`<br>`// NOTE: improve performance` | Expresses a vague feeling rather than an actionable task. | Remove, or provide explicit issue tracker ticket ID, root cause, and concrete next action. |
| **Decorative Emoji** | `// 🚀 Optimization`<br>`// 🔒 Secure endpoint` | Visual gimmick that adds noise to codebases and git diffs. | Delete emoji. Use plain technical prose. |

---

## 3. High-Value Comments to Preserve

Comments are essential when they capture reasoning that cannot be expressed purely through identifier names or type systems:

```text
┌────────────────────────────────────────────────────────────────────────┐
│ HIGH-VALUE COMMENTS EXPLAIN:                                           │
│ 1. Business & Domain Rationale  — Why this business rule exists        │
│ 2. Non-Obvious Invariants       — Assumptions that must never break    │
│ 3. Concurrency Constraints      — Thread safety, locking orders        │
│ 4. Transaction Boundaries       — Rollback guarantees, atomicity       │
│ 5. Security Invariants          — Authorization checks, sanitization   │
│ 6. Vendor Workarounds           — Workarounds for upstream SDK bugs    │
│ 7. Intentionally Unusual Logic  — Why the obvious solution fails       │
└────────────────────────────────────────────────────────────────────────┘
```

### Concrete Examples of High-Value Comments:

```go
// INVARIANT: Balance must never drop below credit limit.
// Enforced via SELECT FOR UPDATE to prevent concurrent double-spend.
row := tx.QueryRow(ctx, "SELECT balance FROM accounts WHERE id = $1 FOR UPDATE", accountID)
```

```rust
// SAFETY: Upstream gateway sporadically sends duplicate webhooks during network failover.
// We record the gateway transaction ID idempotently before executing billing mutations.
if let Err(e) = ledger.record_idempotency_key(&event.id).await {
    return Err(AppError::DuplicateEvent(event.id));
}
```

```python
# Vendor bug workaround: AWS SDK v2.4.1 drops TCP keepalive headers on HTTP/2 streams
# during idle connections longer than 45 seconds. Explicit ping interval keeps socket hot.
client = create_client(keepalive_interval_seconds=30)
```

---

## 4. Operational Rule for AI Coding Agents

```text
RULE:
When generating, modifying, or reviewing code:
1. Strip decorative banners, restated syntax, workflow step narration, and emoji noise.
2. Ensure every non-obvious algorithmic branch, concurrency guard, and transactional invariant carries a concise explanation of WHY.
3. Keep commit messages, pull request summaries, and engineering reports focused on facts, evidence, and verified state—never promotional hype.
```

# Example: Business Rule Modification

## User Request
> "Prevent users with a negative balance from placing new orders."

---

## ❌ Bad Agent Behavior (Premature Abstraction & Engine Building)
```markdown
I will implement an extensible business rules engine:
1. Install `json-rules-engine` npm package.
2. Create `src/rules/OrderRulesEngine.ts` with plugin interfaces.
3. Add a `rules_configuration` table to PostgreSQL to manage rules dynamically.
4. Refactor `OrderService` to run all transactions through the rules engine.
```

**Why it is bad**:
- Installs an external package for a single boolean check.
- Adds unnecessary database persistence for a static domain rule.
- Refactors working checkout architecture into a speculative plugin system.

---

## ✅ Good Agent Behavior (Scope Guard Craftsman)

```markdown
Plan: Add a balance pre-condition check to the existing `OrderService.checkout()` method; no new libraries, rule engines, or database tables are planned.

### What will change
- In `OrderService.checkout()`, check `user.balance_cents < 0` before initiating payment.
- If negative, throw the existing `ValidationError("Account balance is negative.")`.

### What will not change
- Order creation data models and table schemas remain untouched.
- Existing checkout validation pipeline and error handlers remain unchanged.

### Existing capabilities reused
- Existing `ValidationError` domain error class.
- Existing database transaction boundary in `OrderService`.

### Affected Files
- `src/services/OrderService.ts` (5 lines added)

### Verification
- Run unit test suite: `npm test -- OrderService.test.ts`.
- Add a test case asserting that checkout throws when user balance is negative.
```

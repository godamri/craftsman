# Domain Modeling & Multi-Tier Invariant Enforcement

> **Core Principle**: Domain invariants must be enforced at the strongest practical boundary. Relying on frontend validation or developer memory is an architectural failure.

---

## 1. Domain Modeling Checklist

Every core business aggregate must define:
1. **Identity**: Immutable, globally unique primary identifier (UUIDv7, monotonic business key).
2. **Ownership**: Which service or bounded module has exclusive mutating authority?
3. **State Machine**: What are the valid states and the explicit, authorized transitions between them?
4. **Invariants**: What domain assertions must hold before, during, and after every mutation?

---

## 2. The 4-Tier Invariant Defense Model

```text
TIER 1: TYPE SYSTEM
  - Newtypes (e.g. Money(u64), EmailAddress(String))
  - Enums / Typestate to make invalid transitions unrepresentable at compile-time.

TIER 2: APPLICATION DOMAIN LOGIC
  - Aggregate root business validations and transactional pre-conditions.

TIER 3: DATABASE CONSTRAINTS (Storage Authority)
  - NOT NULL, CHECK (balance >= 0), UNIQUE, FOREIGN KEY (ON DELETE RESTRICT).

TIER 4: INFRASTRUCTURE & POLICY GATES
  - API gateway schema validation, IAM least-privilege scoping.
```

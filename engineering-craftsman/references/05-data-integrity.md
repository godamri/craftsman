# Data Integrity & Single Source of Truth

> **Core Principle**: Code is temporary; data is forever. Application assumptions must never override storage-layer integrity constraints.

---

## 1. The Single Source of Truth Invariant

```text
AUTHORITATIVE STORE (Primary Relational Database / Raft Consensus)
         │
         ├──> Change Data Capture / Outbox Events
         │
         ▼
DERIVED PROJECTIONS & CACHES (Elasticsearch / Redis / Read Replicas)
```

- **Rule**: Derived views and caches must NEVER authorize balance debits, inventory claims, or state mutations.
- **Rule**: In the event of discrepancy between cache and primary database, the primary database is authoritative.

---

## 2. Relational Integrity Checklist

1. **Foreign Keys**: Enforce foreign keys with explicit deletion rules (`RESTRICT` or `CASCADE`).
2. **Exclusion / Unique Constraints**: Use composite unique constraints to prevent duplicate bookings or records.
3. **Check Constraints**: Enforce domain validation directly in schema (`CHECK (amount > 0 AND currency IN ('USD', 'EUR', 'GBP'))`).
4. **Immutability of Audit Trails**: Audit tables and financial ledgers must be strictly append-only.

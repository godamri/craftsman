# State Ownership & The Authority Hierarchy

> **Core Principle**: Every piece of data must have exactly one authoritative source of truth. Projections and caches must never authorize state mutations.

---

## 1. The Authority Hierarchy

```text
AUTHORITATIVE SOURCE (Primary Database / Raft Consensus Leader)
        │
        ├──> Event Stream / Write-Ahead Log
        │
        ▼
CACHE & PROJECTIONS (Redis / Elasticsearch / Read Replicas)
        │
        ▼
DERIVED CLIENT STATE (API Responses / Web Client Cache)
```

### Invariants:
- **Mutations against Authority**: All state transitions, balance updates, and authorization decisions must execute against the authoritative source using transactions, atomic operations, or version fencing.
- **Read Replica Lag Awareness**: Read replicas can be milliseconds or seconds behind primary state. Read-your-own-writes workflows must route immediately to the primary database or require client-side optimistic reconciliation.

---

## 2. Shared Database Anti-Pattern vs Data Ownership

```text
❌ BROKEN: Two services reading/writing the same database table
Service A ───\
              ├──> [ shared_users_table ]
Service B ───/

✅ CORRECT: Explicit service ownership with API / Event boundaries
Service A ───> [ Service B (User Owner) ] ───> [ users_db ]
```

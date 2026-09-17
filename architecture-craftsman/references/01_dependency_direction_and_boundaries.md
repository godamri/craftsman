# Dependency Direction & System Boundaries

> **Core Principle**: Dependencies must point toward stable business domain logic. Low-level delivery mechanisms (HTTP, CLI, gRPC) and volatile infrastructure (databases, caches, third-party SDKs) depend on core business policies, never the reverse.

---

## 1. The Hexagonal / Ports & Adapters Boundary Model

```text
[ Incoming Adapters ]             [ Core Domain ]              [ Outgoing Adapters ]
  - HTTP Handlers      ──(calls)─>   - Entities      <──(implements)─  - PostgreSQL Repo
  - Message Consumers  ──(calls)─>   - Domain Rules  <──(implements)─  - Redis Cache
  - CLI Commands       ──(calls)─>   - Ports (Interfaces)              - Payment Client
```

### Dependency Rules:
1. **The Core Domain is Pure**: Contains zero references to web frameworks, database drivers, or network protocols.
2. **Ports (Consumer Interfaces)**: The domain defines the interfaces it requires to persist data or invoke side effects.
3. **Adapters Implement Ports**: Concrete implementations (e.g. `PostgresAccountRepository`) reside on the outer infrastructure ring and implement domain ports.

---

## 2. Preventing Circular & Leaky Dependencies

1. **No Lateral Database Piercing**: Service A must never execute queries directly against tables owned by Service B.
2. **No Circular Package Imports**: If Package A imports Package B, Package B must never import Package A (or any transitively dependent package). Extract shared contracts or invert dependencies via consumer interfaces.

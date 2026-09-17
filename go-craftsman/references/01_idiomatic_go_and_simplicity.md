# Idiomatic Go, Authority & Simplicity

Simplicity in Go is an active discipline of removing speculative abstractions, enforcing single authorities, and exporting minimal surfaces.

---

## 1. The Authority Model in Practice

For every critical piece of state, determine its authoritative source:

```text
AUTHORITATIVE SOURCE (Primary PostgreSQL with constraints / Raft Leader)
        ↓ (Event stream / Write-through / Invalidation)
CACHE / READ PROJECTION (Redis / In-memory cache / Replica)
        ↓
DERIVED / CLIENT STATE (JSON payload / UI state)
```

> **Operational Rule**: Cached or derived state must NEVER authorize balance deductions, security checks, or state transitions. Always mutate against the authoritative source.

---

## 2. Minimal Exported Surface & Consumer Interfaces

1. **Keep unexported by default**: Expose only the concrete API required by external packages.
2. **Define interfaces at the consumer**: Do not export producer interfaces unless multiple implementations or package boundary test seams require them.
3. **Accept interfaces, return concrete structs**: Return concrete structs from constructors (`NewService(...)`) so callers control how they consume them.

```go
package service

import "context"

// Consumer interface defined in the consumer package
type AccountStorage interface {
    Get(ctx context.Context, id string) (*Account, error)
    Save(ctx context.Context, acc *Account) error
}

type AccountService struct {
    storage AccountStorage
}

func NewAccountService(storage AccountStorage) *AccountService {
    return &AccountService{storage: storage}
}
```

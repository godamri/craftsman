# Memory Model, Atomicity & Synchronization

> **Critical Rule**: An atomic variable does NOT make a multi-variable invariant atomic.

---

## 1. The Multi-Variable Atomicity Fallacy

If multiple fields must be updated together consistently (e.g. `balance`, `status`, and `version`), updating them with individual atomic primitives (`atomic.Int64`) creates inconsistent intermediate states.

```go
// BROKEN: Multi-variable invariant is NOT atomic despite individual atomic fields
type BrokenAccount struct {
    balance atomic.Int64
    version atomic.Int64
}

// CORRECT: Guard the multi-variable invariant with a sync.Mutex
type SafeAccount struct {
    mu      sync.Mutex
    balance int64
    version int64
}

func (a *SafeAccount) Debit(amount int64) bool {
    a.mu.Lock()
    defer a.mu.Unlock()
    if a.balance < amount {
        return false
    }
    a.balance -= amount
    a.version++
    return true
}
```

---

## 2. Read-Heavy State with `atomic.Pointer[T]`

For read-heavy configurations or routing tables, store immutable value snapshots using `atomic.Pointer[T]`:

```go
type Config struct {
    Rates map[string]float64
}

type Service struct {
    cfg atomic.Pointer[Config]
}

func (s *Service) ReloadConfig(newConfig *Config) {
    s.cfg.Store(newConfig) // Atomic publication of immutable snapshot
}

func (s *Service) GetRate(currency string) float64 {
    return s.cfg.Load().Rates[currency] // Zero lock contention
}
```

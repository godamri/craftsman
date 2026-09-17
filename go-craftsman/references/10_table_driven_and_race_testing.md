# Table-Driven & Race Testing

> **Principle**: Test the invariant, not merely the implementation path.

---

## 1. Table-Driven Subtests

Standardize on table-driven test fixtures:

```go
package service_test

import (
    "testing"
)

func TestCalculateDiscount(t *testing.T) {
    t.Parallel()

    tests := []struct {
        name     string
        price    float64
        isVIP    bool
        expected float64
    }{
        {name: "standard customer", price: 100.0, isVIP: false, expected: 100.0},
        {name: "vip customer discount", price: 100.0, isVIP: true, expected: 80.0},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            t.Parallel() // Safe in Go 1.22+ per-iteration variable scoping
            result := CalculateDiscount(tt.price, tt.isVIP)
            if result != tt.expected {
                t.Fatalf("expected %.2f, got %.2f", tt.expected, result)
            }
        })
    }
}
```

---

## 2. In-Memory Fakes Over Heavy Mock Frameworks

Implement consumer interfaces with lightweight struct fakes:

```go
type FakeUserStore struct {
    SavedUsers map[string]User
    ErrToReturn error
}

func (f *FakeUserStore) SaveUser(ctx context.Context, u User) error {
    if f.ErrToReturn != nil {
        return f.ErrToReturn
    }
    f.SavedUsers[u.ID] = u
    return nil
}
```

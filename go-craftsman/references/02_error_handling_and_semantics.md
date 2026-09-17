# Error Taxonomy, Wrapping & Panic Policy

Errors are values that communicate explicit failure semantics across component boundaries.

---

## 1. Error Wrapping & Joining

- **Context Wrapping (`%w`)**: Always wrap with contextual action: `fmt.Errorf("fetching customer account %s: %w", id, err)`.
- **Multiple Error Aggregation (`errors.Join`)**: Use `errors.Join(err1, err2)` in Go 1.20+ when multiple background tasks fail concurrently or cleanup steps generate multiple errors.

```go
package store

import (
    "errors"
    "fmt"
)

var (
    ErrNotFound   = errors.New("resource not found")
    ErrConflict   = errors.New("resource conflict or stale version")
    ErrValidation = errors.New("validation failed")
)

type DomainError struct {
    Code    string
    Message string
    Err     error
}

func (d *DomainError) Error() string {
    return fmt.Sprintf("[%s] %s: %v", d.Code, d.Message, d.Err)
}

func (d *DomainError) Unwrap() error {
    return d.Err
}
```

---

## 2. Panic Policy

- **Acceptable Panic**: Unrecoverable startup misconfiguration (e.g. invalid regex compilation `regexp.MustCompile` at `init()`), or internal invariant breach that violates memory safety.
- **Forbidden Panic**: Normal business failures, database errors, network timeouts, or malformed user input.
- **Top-Level Recovery**: Recover panics only at top-level HTTP middleware or worker supervisors:

```go
func RecoveryMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        defer func() {
            if rec := recover(); rec != nil {
                slog.Error("unhandled panic recovered in HTTP handler",
                    slog.Any("panic", rec),
                    slog.String("path", r.URL.Path),
                )
                http.Error(w, "Internal Server Error", http.StatusInternalServerError)
            }
        }()
        next.ServeHTTP(w, r)
    })
}
```

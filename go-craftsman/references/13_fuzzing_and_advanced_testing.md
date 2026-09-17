# Fuzzing & Advanced Verification

Adversarial testing verifies system invariants against malicious, random, and edge-case inputs.

---

## 1. Native Go Fuzz Testing (`testing.F`)

Use Go native fuzzing to uncover parsing bugs, buffer overflows, and unhandled panics:

```go
package parser_test

import (
    "testing"
)

func FuzzParseConfig(f *testing.F) {
    // Seed corpus
    f.Add([]byte("key=value\n"))
    f.Add([]byte("port=8080\n"))
    f.Add([]byte(""))

    f.Fuzz(func(t *testing.T, data []byte) {
        // Must never panic on arbitrary input
        _, _ = ParseConfig(data)
    })
}
```

Run fuzzing in CI / development:
```bash
go test -fuzz=FuzzParseConfig -fuzztime=10s ./...
```

---

## 2. Cancellation & Timeout Testing

Explicitly verify that operations respect cancellation and do not leak resources:

```go
func TestCancellationReleasesResources(t *testing.T) {
    ctx, cancel := context.WithCancel(context.Background())
    
    done := make(chan struct{})
    go func() {
        _ = LongRunningOperation(ctx)
        close(done)
    }()

    cancel() // Trigger cancellation

    select {
    case <-done:
        // Success: Operation exited deterministically upon cancellation
    case <-time.After(1 * time.Second):
        t.Fatal("operation leaked or failed to exit on context cancellation")
    }
}
```

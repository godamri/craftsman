# Resource Ownership & Lifecycle

> **Principle**: Resource ownership must be explicit, and every acquired resource must have a deterministic release path.

---

## 1. The 7-Part Resource Ownership Model

Every acquired resource must define:
1. **Creator**: The function/goroutine that instantiates the resource.
2. **Owner**: The entity holding responsibility for its lifetime.
3. **Transfer Rule**: Explicit documentation if ownership moves across boundaries.
4. **Lifetime**: Scope during which the resource is valid.
5. **Release Authority**: Exactly who calls `Close()`, `Release()`, or `Cancel()`.
6. **Failure Release Path**: Deterministic cleanup on error/panic via `defer` or `try...finally`.
7. **Shutdown Release Path**: Orderly drainage during graceful server termination.

---

## 2. `defer Close()` Inside Loops vs Helper Functions

> [!WARNING]
> In tight loops, `defer resource.Close()` does NOT execute at the end of each iteration; it executes only when the enclosing function returns, leading to socket/file descriptor exhaustion.

```go
// BROKEN: Leaks file descriptors until ProcessAllFiles returns
func ProcessAllFilesBad(paths []string) error {
    for _, path := range paths {
        f, err := os.Open(path)
        if err != nil {
            return err
        }
        defer f.Close() // DANGEROUS: all files stay open until loop finishes!
        // process file...
    }
    return nil
}

// CORRECT: Wrap iteration in a helper function or close explicitly
func ProcessAllFilesGood(paths []string) error {
    for _, path := range paths {
        if err := processSingleFile(path); err != nil {
            return err
        }
    }
    return nil
}

func processSingleFile(path string) error {
    f, err := os.Open(path)
    if err != nil {
        return err
    }
    defer f.Close() // Safely closes at the end of this single file's processing
    return processContent(f)
}
```

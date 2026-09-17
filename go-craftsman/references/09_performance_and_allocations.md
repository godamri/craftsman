# Performance & Allocations

Performance optimization must be driven by profiling and benchmarks, not speculation.

---

## 1. Benchmarking Workflow

Run benchmarks with memory allocation metrics:
```bash
go test -bench=. -benchmem ./...
```

---

## 2. Allocation Reductions

### Pre-allocating Slice Capacity
```go
// Inefficient: repeated array re-allocations
var items []string
for i := 0; i < 1000; i++ {
    items = append(items, fmt.Sprint(i))
}

// Efficient: 1 allocation
items := make([]string, 0, 1000)
for i := 0; i < 1000; i++ {
    items = append(items, fmt.Sprint(i))
}
```

### String Concatenation (`strings.Builder`)
```go
var sb strings.Builder
sb.Grow(64) // Pre-allocate buffer if size is estimated
sb.WriteString("prefix_")
sb.WriteString(id)
result := sb.String()
```

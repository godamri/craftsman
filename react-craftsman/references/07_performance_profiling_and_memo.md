# Performance Profiling & Memoization

> **Operational Rule**: Profile first. Apply memoization only when measurements demonstrate a concrete rendering budget benefit or when stabilizing references for memoized components.

---

## 1. When to Use `useMemo` & `useCallback`

### Legitimate Uses:
1. **Measurably Expensive Calculations**: Non-trivial transformations (sorting, filtering, graph traversals) that consume measurable time relative to the frame rendering budget (e.g. >16ms / 60fps).
2. **Passing Callbacks/Objects to Memoized Children**: Passing stable references as props to child components wrapped in `React.memo()`.
3. **Hook Dependency Stabilization**: Stabilizing object or callback references passed into other custom hook dependency arrays.

### Non-Legitimate Uses:
- Wrapping simple primitive calculations (e.g. `useMemo(() => a + b, [a, b])`).
- Wrapping event handlers passed directly to native DOM elements (e.g. `<button onClick={useCallback(...)}>` provides zero optimization because native DOM elements are not memoized).

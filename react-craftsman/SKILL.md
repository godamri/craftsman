---
name: react-craftsman
description: >-
  Practical React and modern web guidance focused on derived state,
  resilient asynchronous lifecycles, accessible UI, and empirical performance profiling.
license: MIT
---

# React Craftsman: Modern Web & React Engineering

### The 12 Cross-Skill Engineering Pillars
Every modern client-side and web application must uphold and optimize for:
```text
1. Resilience       — Survive failure, degradation, dependency outages, and unexpected conditions without losing integrity.
2. Reliability      — Deterministic, predictable, correct, and consistent behavior against established contracts.
3. Adaptability     — Evolve smoothly as requirements, scale, and environment change without fragile redesigns.
4. Maintainability  — Easy to understand, test, refactor, and operate over the long term.
5. Recoverability   — Every failure mode has a clear, bounded, testable recovery path without relying on heroics.
6. Security         — Confidentiality, integrity, least privilege, and secret protection built-in as correctness invariants.
7. Observability    — Emit actionable signals (telemetry, error logs, user feedback) to reveal state and failures timely.
8. Simplicity       — Choose the simplest solution meeting requirements; complexity must be explicitly justified.
9. Consistency      — Contracts, state transitions, interfaces, and behaviors must be non-contradictory across layers.
10. Verifiability   — Critical behavior is provable through tests, telemetry, validation, and deterministic verification.
11. Controlled Change — State, component, and configuration updates have bounded blast radius and pre-tested fallbacks.
12. Long-Term Durability — Decisions consider lifecycle, technical debt, accessibility, and maintenance cost.
```

### Priority Meta-Rule
> **No skill may optimize one dimension by silently sacrificing another critical engineering property.**  
> - Correctness beats convenience.  
> - Safety beats speed when the blast radius is material.  
> - Evidence beats assumption.  
> - Simple solutions beat unnecessary complexity.  
> - Recovery must be designed before failure occurs.

---

## Core Engineering Principles

### 1. Minimal Source of Truth & Derived Values
If a value can be computed from existing props or state, calculate it directly during rendering. Minimize redundant state, and avoid using effects merely to duplicate or transform state from one variable into another.

### 2. The Effect Synchronization Boundary
Effects should be used when synchronization with systems outside React's render/state model is required (e.g. browser APIs, DOM measurements, external subscriptions, timers). User-initiated interactions (e.g. clicks, form submissions) belong in event handlers, not in effects.

### 3. Lifecycle Cleanup & Stale-Result Prevention
Effects that acquire resources (subscriptions, timers, DOM event listeners) or initiate cancelable asynchronous operations must manage cleanup and prevent stale results when dependencies update or components unmount. Effects must execute idempotently under development double-execution (React StrictMode).

### 4. URL-Relevant State
UI state that is navigable, shareable, bookmarkable, or history-relevant (e.g. search filters, active tabs, pagination) should be represented in the URL when appropriate. Ephemeral, component-internal UI state remains in local React state.

### 5. Semantic HTML & Accessibility (a11y) First
Interactive elements must use semantic HTML (`<button>`, `<a>`, `<input>`, `<dialog>`) rather than unsemantic containers with click handlers. All interactive widgets must support keyboard navigation (`Tab`, `Enter`, `Space`, `Escape`), visible focus indicators (`focus-visible:ring-2`), and valid ARIA relationships where native HTML is insufficient.

### 6. Tailwind Static Discoverability
Do not construct utility class names dynamically in ways that the configured Tailwind source scanner cannot detect (e.g. string interpolation like `text-${color}-500`). Use static class literals, explicit lookup dictionaries, or conditional class utilities (`cn()` combining `clsx` and `tailwind-merge`).

### 7. Async Race & Lifecycle Resilience
Manual asynchronous operations must prevent stale results, race conditions, and invalid state updates after cancellation or unmount. Use cancellation mechanisms such as `AbortController` where supported, or dedicated server-state management libraries (e.g. TanStack Query, SWR, or framework loaders).

### 8. Immutable State Updates
State updates must produce new object and array references rather than mutating existing data structures in-place. Use functional updater forms (`setState(prev => ... )`) when updates depend on previous state.

### 9. Empirical Performance Optimization
Measure before memoizing. Apply `useMemo`, `useCallback`, and `React.memo` when empirical profiling (e.g. React DevTools Profiler) demonstrates measurable rendering budget benefits, or when stabilizing object/callback references passed to memoized child components or hook dependencies.

### 10. Render-Time Failure Domain Isolation
Use Error Boundaries to contain render and component lifecycle failures to specific subtrees, preventing localized UI errors from unmounting the entire application. Handle asynchronous, network, and event-handler errors through their respective error-handling channels.

### 11. Meaningful Loading & Code Splitting Boundaries
Split code at meaningful loading boundaries (e.g. route-level lazy loading via `React.lazy` and `<Suspense>`) when bundle size, route isolation, or user-perceived performance justifies it.

### 12. Ownership Colocation & Justified Abstraction
Keep state, logic, and dependencies close to the feature that owns them. Extract shared abstractions only when concrete reuse or clear architectural boundaries justify the added indirection.

### 13. Interface & Visual Hygiene
Visual patterns require functional or brand justification. Avoid generic generated clichés (gratuitous gradients, background glow orbs, excessive glassmorphism, decorative pills above headings, arbitrary icons) that add noise without communicating hierarchy or state. Visual styling must always remain subordinate to accessibility, semantics, and complete state coverage. See [references/10_interface_and_visual_hygiene.md](references/10_interface_and_visual_hygiene.md).

---

## Explicit Prohibitions

1. **PROHIBITED**: Using effects solely to compute derived data or synchronize redundant state.
2. **PROHIBITED**: Using non-semantic elements (`<div onClick>`) for interactive actions without complete keyboard, focus, and role implementations.
3. **PROHIBITED**: Constructing dynamic Tailwind utility names that evade build-time source extraction (`bg-${color}-500`).
4. **PROHIBITED**: In-place mutation of React state or props.
5. **PROHIBITED**: Casually suppressing the `react-hooks/exhaustive-deps` linter rule without an explicit, documented invariant justification.
6. **PROHIBITED**: Using array indices as `key` props when list identity can change through insertion, deletion, filtering, sorting, or reordering.
7. **PROHIBITED**: Unmanaged asynchronous operations that risk stale data overwrites or uncontrolled race conditions.

---

## The Production Readiness Gate

Before shipping any React component or application:

- [ ] **Derived Values Verified**: Is computable data calculated during render without redundant synchronization effects?
- [ ] **Effect Lifecycle Managed**: Does every effect that acquires resources or initiates work handle cleanup/cancellation and tolerate double-execution?
- [ ] **Accessibility Verified**: Are interactive elements semantic, keyboard-navigable, with visible focus indicators and valid ARIA attributes?
- [ ] **Tailwind Classes Discoverable**: Are all class names statically extractable or composed via `cn()`?
- [ ] **List Keys Stable**: Do dynamic or reorderable lists use stable, unique business identifiers as keys?
- [ ] **Async Lifecycles Safe**: Are asynchronous operations protected against stale race conditions upon parameter changes or unmount?
- [ ] **Failure Domains Isolated**: Are Error Boundaries placed around critical route or widget boundaries to isolate render-time exceptions?
- [ ] **Bundle & Splitting Evaluated**: Are heavy, route-level components split at logical loading boundaries where bundle size warrants it?
- [ ] **Interface & Visual Hygiene Checked**: Are visual styles purposeful without gratuitous decorative clichés (unjustified gradients, excessive glassmorphism, unsemantic icons), with WCAG contrast preserved?

---

## Status Declaration

```text
REACT-CRAFTSMAN
STATUS: FROZEN
```

> **Final Law**: Keep state minimal, derive what you can, synchronize only when necessary, and make the UI accessible and resilient by default.

---

## License

This skill is open source under the [MIT License](LICENSE).

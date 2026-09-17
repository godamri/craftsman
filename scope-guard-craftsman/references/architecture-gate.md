# The New Architecture Gate

Scope Guard Craftsman does not forbid new architecture. It requires that **new architecture earns its place through repository evidence**.

---

## 1. What Triggers the Gate?

The Architecture Gate applies to **new architectural boundaries or capabilities**, such as:
- A new service, subsystem, or microservice boundary.
- A new persistent domain model or table when it alters architectural ownership.
- A new queue, worker, or event-processing boundary.
- A new state-management system or distributed caching layer.
- A new external dependency or package.
- A new infrastructure component or persistent store.
- Other meaningful architectural boundaries.

> **Note on Standard New Files**: A normal new file (e.g. `src/utils/date_format.go`, `src/components/EmptyState.tsx`, `tests/order_validation_test.go`) should follow normal scope and reuse reasoning, not automatically the Architecture Gate. Creating a focused new file for clarity and single responsibility is healthy engineering, provided it does not establish an unrequested architectural boundary.

---

## 2. The 4 Gate Justification Steps

Before introducing a new architectural element, establish:

```text
1. Existing Path:
   What existing file, class, service, or schema was evaluated as a candidate host?

2. Deficiency:
   Why can the existing capability not safely or cleanly satisfy the requirement?

3. Simpler Alternatives:
   What smaller changes (e.g. adding a function, modifying an existing route, adding a column)
   were considered and rejected?

4. Justification:
   Why is the new architectural element necessary and how is its blast radius contained?
```

---

## 3. Avoiding Under-Engineering (False Economy)

Scope Guard Craftsman does **not** advocate cramming hundreds of lines of unrelated logic into an existing file merely to avoid creating a new file.

- **Healthy New Architecture**:
  - Creating a cohesive domain entity or focused helper when mixing concerns into an existing class would violate single responsibility and increase bug risk.
  - Introducing an asynchronous outbox when synchronous external calls would lock up a database transaction.
- **Unjustified New Architecture**:
  - Creating a generic plugin system, factory hierarchy, or separate microservice for a one-off feature.
  - Adding a state management library (e.g., Redux, MobX) when local component state or an existing context is sufficient.
  - Installing an external library for logic solvable with standard library built-ins.

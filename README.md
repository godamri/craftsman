# Craftsman

Practical engineering skills for AI coding agents, focused on evidence, correctness, boundaries, safety, and verification.

---

## What It Is

Craftsman is a collection of 13 modular engineering skills designed for AI coding agents and human software engineers. Rather than providing application-specific boilerplate or code generators, each skill provides operational engineering discipline—establishing concrete constraints, trade-off models, and verification criteria for distinct domains of software construction and system operations.

The collection emphasizes:
- Understanding existing codebases before proposing changes.
- Choosing the simplest demonstrably correct solution.
- Introducing complexity only when concrete requirements or repository evidence justify it.
- Protecting data integrity, trust boundaries, and failure domains.
- Scaling verification proportionally to the blast radius of a change.

---

## Design Principles

- **Inspect before changing**: Understand existing architecture, dependencies, and execution paths before introducing modifications.
- **Evidence over assumption**: Base decisions on observable repository patterns and verifiable constraints, never on unverified assumptions.
- **Reuse existing capabilities**: Prefer existing libraries, models, and utilities when they safely satisfy the requirement.
- **Bound the scope**: Keep the delta limited to the requested outcome without opportunistic refactoring or gold-plating.
- **Justify architecture**: New boundaries, services, tables, and queues must earn their place through documented requirements.
- **Defend invariants**: Enforce critical business rules, permissions, and transactional consistency at the strongest layer (database constraints, types, fail-closed authorization).
- **Verify by blast radius**: Match testing fidelity—from unit invariant assertions to concurrency stress and migration drills—to the operational impact of the change.

---

## Skills

| Skill | Focus |
| :--- | :--- |
| [architecture-craftsman](architecture-craftsman/) | System boundaries, state ownership, dependency direction, failure domain isolation, and evolutionary architecture. |
| [business-craftsman](business-craftsman/) | Value validation, portfolio prioritization, capacity allocation, risk containment, and outcome realization. |
| [database-craftsman](database-craftsman/) | Relational schema integrity, transaction boundaries, concurrency control, safe migrations, and query performance. |
| [devops-craftsman](devops-craftsman/) | Infrastructure administration, credential security, database operations, failure recovery, and zero-downtime rollouts. |
| [distributed-systems-craftsman](distributed-systems-craftsman/) | State consistency, idempotency, delivery semantics, fencing tokens, outbox patterns, and resilient recovery. |
| [engineering-craftsman](engineering-craftsman/) | Cross-cutting engineering lifecycle discipline: requirements, domain modeling, resilience, security, and release gates. |
| [go-craftsman](go-craftsman/) | Correctness, explicit error propagation, structured concurrency, memory ownership, and test verification in Go (1.22+). |
| [python-craftsman](python-craftsman/) | Simple sufficient design, explicit failure semantics, data modeling, safe concurrency, and measurable performance in Python (3.12+). |
| [qa-craftsman](qa-craftsman/) | Risk-based testing strategy, invariant assertions, concurrency verification, failure injection, and deterministic release gates. |
| [react-craftsman](react-craftsman/) | Minimal derived state, resilient asynchronous lifecycles, accessible UI, and empirical performance profiling in React. |
| [rust-craftsman](rust-craftsman/) | Memory safety, sound ownership, explicit error handling, async Tokio lifecycles, and verification gates in Rust (2021/2024). |
| [scope-guard-craftsman](scope-guard-craftsman/) | Operational discipline for coding agents to identify and execute the smallest justified change before implementation. |
| [security-craftsman](security-craftsman/) | Threat modeling, fail-closed authorization, input sanitization, secret lifecycle management, and injection defense. |

---

## Skill Structure

Each skill in this repository is packaged in a self-contained directory:

```text
skill-name/
├── SKILL.md        # Core instructions, operational rules, and readiness checklist
├── references/     # In-depth architectural, failure-mode, and design reference guides
├── examples/       # Concrete runnable code examples and scenario demonstrations
└── LICENSE         # Standalone MIT license copy for independent distribution
```

- **`SKILL.md`**: The primary entry point for coding agents, specifying operational rules, decision models, explicit prohibitions, and release readiness checklists.
- **`references/`**: Detailed topical guides that provide deep dive context on specific edge cases, failure semantics, and engineering trade-offs.
- **`examples/`**: Illustrative, executable implementations illustrating patterns such as transactional outbox workers, safe subprocess execution, idempotency deduplication, and schema migrations.

---

## How to Use

Craftsman skills are designed to be consumed by AI coding agents and human engineers as domain-specific engineering guidance.

1. **Select the relevant skill**: Identify the skill matching your current engineering domain or task (e.g., `react-craftsman` for frontend state, `database-craftsman` for SQL schema evolution).
2. **Provide the skill to your agent**: Supply the skill directory or its `SKILL.md` into your coding agent's supported custom instructions, system prompt, or skill discovery folder.
3. **Inspect and apply**: The agent uses the skill's decision rules and checklist while inspecting the target codebase, verifying existing patterns before writing or modifying code.

---

## Combining Skills

Skills are modular and complementary. Real-world tasks often combine multiple skills:

```text
Database Feature:
├── scope-guard-craftsman   # Confines the change to the smallest necessary delta
├── database-craftsman      # Governs column types, lock_timeout, and non-blocking DDL
└── qa-craftsman            # Mandates rollback verification and concurrent invariant tests

Distributed Service Endpoint:
├── architecture-craftsman          # Verifies boundary contracts and state ownership
├── distributed-systems-craftsman   # Defines idempotency keys and transactional outbox
└── security-craftsman              # Enforces fail-closed auth and input sanitization
```

---

## Repository Layout

```text
.
├── architecture-craftsman/
├── business-craftsman/
├── database-craftsman/
├── devops-craftsman/
├── distributed-systems-craftsman/
├── engineering-craftsman/
├── go-craftsman/
├── python-craftsman/
├── qa-craftsman/
├── react-craftsman/
├── rust-craftsman/
├── scope-guard-craftsman/
├── security-craftsman/
├── LICENSE
└── README.md
```

---

## Scope & Operational Boundary

Craftsman skills provide structured engineering guidance, operational constraints, and verification criteria. They do not replace repository inspection, comprehensive test execution, static analysis, threat modeling, security penetration testing, or human judgment. They provide disciplined engineering direction; correctness requires verification in the target environment.

---

## License

This project is licensed under the [MIT License](LICENSE).

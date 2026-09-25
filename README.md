# Craftsman

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![skills.sh](https://skills.sh/b/godamri/craftsman)](https://skills.sh/godamri/craftsman)

Practical engineering skills for AI coding agents, focused on evidence, correctness, boundaries, safety, and verification.

---

## What It Is

Craftsman is a collection of 14 modular engineering skills designed for AI coding agents and human software engineers. Rather than providing application-specific boilerplate or code generators, each skill provides operational engineering discipline—establishing concrete constraints, trade-off models, and verification criteria for distinct domains of software construction and system operations.

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

## See the Difference: Engineering Behavior

The impact of Craftsman is observed in how an AI agent designs, scopes, and verifies technical tasks.

### Scenario: Implementing a Concurrent Account Deduction

| Dimension | Typical AI Coding Agent Behavior | With Craftsman |
| :--- | :--- | :--- |
| **Reconnaissance** | Immediately writes new code; assumes framework and database defaults. | Inspects existing transaction managers, isolation levels, and error conventions first. |
| **Data Invariants** | Writes non-locking `SELECT balance` followed by `UPDATE accounts SET balance = balance - $1`. Vulnerable to concurrent race conditions. | Uses `SELECT ... FOR UPDATE` inside transaction boundary; relies on database `CHECK (balance >= 0)` as the authoritative barrier. |
| **Scope Control** | Refactors neighboring files, upgrades dependencies, or introduces unrequested abstractions. | Classifies changes as `REQUIRED` or `REQUIRED FOR VERIFICATION`. Defers optional improvements. |
| **Code Comments** | Adds decorative ASCII banners (`// ======`) and restates syntax (`// Step 1: deduct balance`). | Documents the concurrency invariant (*why*); deletes decorative banners and obvious syntax echoes. |
| **Verification** | Runs single happy-path unit test; declares *"Completed and production ready"*. | Executes adversarial falsification: 20-worker parallel race barrier drill; verifies final balance and rollback behavior. |
| **Completion Claim** | Conflates code compilation with production readiness. | Distinguishes `Implemented` vs `Verified` vs `Production Ready`; reports explicit evidence coverage and remaining gaps. |

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
| [execution-craftsman](execution-craftsman/) | Milestone-based engineering execution: tactical execution loops, claim-dependent evidence, falsification, and regression verification. |
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

Craftsman skills can be installed into your coding agent's environment or referenced directly within project repositories.

### Option 1: Via Open Agent Skills Registry (`skills.sh`)

Install directly using the open agent skills CLI:

```bash
# Install all 14 skills to your detected agent environment:
npx skills add godamri/craftsman

# Or install specific skills:
npx skills add godamri/craftsman --skill database-craftsman execution-craftsman
```

### Option 2: Via Local Repository Installer (`install.sh`)

Use the included idempotent installer to symlink or copy skills into your target project or global agent directory:

```bash
# Symlink skills into local project (.agents/skills):
./install.sh --target .agents/skills

# Copy skills to Claude Code global directory:
./install.sh --target ~/.claude/skills --copy

# Safe reversal (uninstall):
./install.sh --target .agents/skills --uninstall
```

### Option 3: Agent Configuration Pointer

For agents that read root configuration files (`AGENTS.md`, `CLAUDE.md`, or `GEMINI.md`), point your agent to the relevant skills:

```markdown
<!-- craftsman:start -->
## Engineering Standards

For system architecture, database changes, and implementation execution:
- Review `.agents/skills/execution-craftsman` for milestone and verification loops.
- Review `.agents/skills/database-craftsman` for SQL, migrations, and concurrency.
- Review `.agents/skills/scope-guard-craftsman` to prevent unrequested changes.
<!-- craftsman:end -->
```

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
├── execution-craftsman/
├── go-craftsman/
├── python-craftsman/
├── qa-craftsman/
├── react-craftsman/
├── rust-craftsman/
├── scope-guard-craftsman/
├── security-craftsman/
├── install.sh
├── LICENSE
└── README.md
```

---

## Scope & Operational Boundary

Craftsman skills provide structured engineering guidance, operational constraints, and verification criteria. They do not replace repository inspection, comprehensive test execution, static analysis, threat modeling, security penetration testing, or human judgment. They provide disciplined engineering direction; correctness requires verification in the target environment.

---

## License

This project is licensed under the [MIT License](LICENSE).

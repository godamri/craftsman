# Test Strategy & The Risk-Based Pyramid

---

## 1. The Verification Pyramid

| Level | Execution Time | Environment | Purpose |
| :--- | :--- | :--- | :--- |
| **Unit & Invariant Tests** | Milliseconds | In-Memory | Verifies pure domain logic, state machine transitions, and computational algorithms. |
| **Integration Tests** | Seconds | Local DB (Testcontainers) | Verifies real SQL constraints, transactions, locking, and external client adapters. |
| **Contract Tests** | Seconds | Isolated Mock/Schema | Verifies Protobuf/OpenAPI serialization and backward/forward compatibility. |
| **End-to-End & Chaos** | Minutes | Staging / Isolated Env | Verifies critical multi-service workflows and failure injection/recovery drills. |

---

## 2. Risk-Based Testing Matrix

Invest testing depth where business or financial risk is highest:
- **High Financial/Data Risk (e.g. Balances, Payments, Authentication)**: Unit + Integration + Concurrency + Failure Injection.
- **Pure Computation (e.g. Price Calculation, Parsing)**: Unit + Property-Based Fuzzing.
- **Reporting / Non-Critical Telemetry**: Unit + Smoke Integration.

# Wizard Craftsman: Routing Benchmarks & Scenarios

This document contains 6 reference benchmarks demonstrating Wizard's routing and intake logic.

> **Epistemic Standard for Benchmarks**:  
> Because these scenarios are hypothetical tests, repository premises are explicitly marked as **`[FIXTURE]`** or **`[EXAMPLE CONTEXT]`**. The label **`[OBSERVED]`** is strictly reserved for live workspace inspections. Verification metrics or test parameters derived from engineering practices rather than explicit user constraints are designated with **`[VERIFICATION TARGET]`** or **`[EXAMPLE VERIFICATION PARAMETER]`**.

---

### Scenario 1: Trivial UI Change

#### Input
> *"Change the login submit button color to brand indigo on the web app."*

#### Analysis & Routing
- **Interpretation**: Localized visual styling change. No business logic, auth handling, or backend endpoints are modified.
- **Evidence State**:
  - `[FIXTURE]` The web app uses React with styled components or CSS tokens in `frontend/src/styles/theme.ts`.
  - `[UNKNOWN]` Exact design token for "brand indigo" in theme file.
- **Material Ambiguity**: None. Request is unambiguous.
- **Scope**:
  - *In Scope*: Button styling token reference in login component.
  - *Out of Scope*: Form layout, authentication endpoints, form validation, adjacent buttons.
- **Risk**: `LOW` (Review Policy: `NONE`). Instant reversibility, zero blast radius outside single button.
- **Selected Skills**:
  - `PRIMARY`: `web-design-craftsman` (visual hierarchy, design token usage, contrast checking).
  - `REQUIRED`: `scope-guard-craftsman` (enforces smallest justified change; blocks opportunistic form refactoring).
- **Meaningful Exclusions**:
  - `execution-craftsman`: Localized styling tweak does not require formal multi-milestone loop; diff inspection suffices.
- **Verification**:
  - Visual render inspection: confirm contrast ratio is accessible (e.g. `[VERIFICATION TARGET]` WCAG AA 4.5:1).
  - Diff inspection: verify minimal change footprint confined to styling token, zero backend edits (e.g. `[EXAMPLE VERIFICATION PARAMETER]` localized <= 5 line diff).
- **Final Status**: `READY` (Cleared for direct execution).

---

### Scenario 2: Storage Adapter with Material Ambiguity

#### Input
> *"Add Google Drive as an alternative storage backend alongside our current Cloudflare R2 storage."*

#### Analysis & Routing
- **Interpretation**: User wants to store files on Google Drive instead of or in addition to R2.
- **Evidence State**:
  - `[FIXTURE]` The codebase has an abstract `StorageProvider` interface in `backend/storage/base.py`.
  - `[FIXTURE]` The active implementation is `CloudflareR2Provider` in `backend/storage/r2.py`.
  - `[UNKNOWN]` How credentials and tokens are injected into storage providers.
- **Material Ambiguity**:
  - **Delivery Semantics Fork**: Cloudflare R2 provides public CDN presigned URLs directly to clients. Google Drive requires either backend-authenticated streaming proxying, or Google Workspace domain-shared permissions.
  - Choosing one silently alters data transfer costs, API latency, security boundaries, and authorization ownership.
- **Scope**:
  - *In Scope*: Adapter implementation, credential injection, integration tests.
  - *Out of Scope*: Replacing R2, building Google Drive file browsing UI, altering document metadata schema.
- **Risk**: `HIGH` (Review Policy: `MANDATORY`).
- **Selected Skills**:
  - `PRIMARY`: `python-craftsman` (interface protocol conformance, stream I/O, error handling).
  - `REQUIRED`: `architecture-craftsman` (preserves storage interface boundary; avoids leaky provider abstraction).
  - `REQUIRED`: `security-craftsman` (service account / OAuth token isolation; zero secret logging).
  - `REQUIRED`: `scope-guard-craftsman` (confines change to new adapter file; protects existing R2 adapter).
  - `REQUIRED`: `execution-craftsman` (milestone execution and rollback verification).
  - `CONDITIONAL`: `database-craftsman` (Activated ONLY IF provider selection requires a new database column).
- **Meaningful Exclusions**:
  - `distributed-systems-craftsman`: File transfer is an in-process streaming adapter, not a multi-node message queue workflow.
- **Verification Obligations**:
  - Confirm roundtrip upload/download stream integrity with checksum match.
  - Regression: verify existing R2 test suite passes without changes.
- **Final Status**: `AWAITING_CLARIFICATION`
  > **Gate Rule**: Architectural commitment is **BLOCKED**. Wizard surfaces the Delivery Semantics Fork for human clarification before code modifications begin.

---

### Scenario 3: Database Migration on Live Table

#### Input
> *"Add a soft-delete column `deleted_at` to the `customers` table and cascade it to orders."*

#### Analysis & Routing
- **Interpretation**: Add soft-delete timestamp column to database schema and cascade query filters.
- **Evidence State**:
  - `[FIXTURE]` Database is PostgreSQL 15 managed via Alembic migrations.
  - `[UNKNOWN]` Exact row volume and traffic write-rate on `customers` and `orders` tables.
  - `[UNKNOWN]` Existing foreign key constraint configuration between customers and orders.
- **Material Ambiguity**: None.
- **Scope**:
  - *In Scope*: Migration script (`migrations/`), customer repository queries, order query filter updates.
  - *Out of Scope*: Billing entities, customer payment gateway integrations, hard-delete routines.
- **Risk**: `HIGH` (Review Policy: `MANDATORY`).
  - *Risk Rationale*: Consequential DDL carries table lock contention risks; cascading soft deletes can cause unexpected exclusion of financial records.
- **Selected Skills**:
  - `PRIMARY`: `database-craftsman` (safe non-blocking DDL, bounded lock timeout, partial indexes, transaction bounds).
  - `REQUIRED`: `engineering-craftsman` (Constitutional release blocker: no long-held table locks on large tables).
  - `REQUIRED`: `scope-guard-craftsman` (blocks opportunistic column renames or unrelated schema edits).
  - `REQUIRED`: `execution-craftsman` (expand-contract phased execution and rollback testing).
- **Meaningful Exclusions**:
  - `devops-craftsman`: Migration is an application-level DDL script, not cloud infrastructure provisioning.
- **Verification Obligations**:
  - Verify migration sets a bounded lock timeout (e.g. `[EXAMPLE VERIFICATION PARAMETER]` `SET lock_timeout = '2s'`) before `ALTER TABLE`.
  - Verify rollback migration successfully restores previous schema without data loss.
  - Verify query performance: index scan on `WHERE deleted_at IS NULL`.
- **Final Status**: `READY` (Awaiting human approval due to HIGH risk).

---

### Scenario 4: Asynchronous Webhook Race Condition

#### Input
> *"Fix the race condition in the Go payment webhook consumer where duplicate Stripe events cause double-crediting."*

#### Analysis & Routing
- **Interpretation**: Duplicate webhook delivery creates concurrent balance mutations resulting in double credit.
- **Evidence State**:
  - `[FIXTURE]` Webhook handler is written in Go 1.22 in `cmd/worker/webhook.go`.
  - `[UNKNOWN]` Whether an idempotency key table currently exists in the database.
  - `[UNKNOWN]` Whether balance updates execute inside a single transactional boundary.
- **Material Ambiguity**: None.
- **Scope**:
  - *In Scope*: Webhook deduplication logic, balance update transaction, idempotency record persistence.
  - *Out of Scope*: Stripe checkout frontend, invoice PDF generation, refund endpoints.
- **Risk**: `HIGH` (Review Policy: `MANDATORY`). Financial invariant at risk.
- **Selected Skills**:
  - `PRIMARY`: `distributed-systems-craftsman` (idempotency key contract, replay safety, delivery semantics).
  - `PRIMARY`: `database-craftsman` (unique constraint on event ID, atomic balance transaction via row locking).
  - `REQUIRED`: `go-craftsman` (structured context cancellation, connection pool safety, goroutine bounds).
  - `REQUIRED`: `qa-craftsman` (concurrent race barrier test verifying single settlement under parallel replays).
  - `REQUIRED`: `scope-guard-craftsman` (New Architecture Gate: rejects adding Redis/distributed locks when SQL unique constraint suffices).
  - `REQUIRED`: `execution-craftsman` (milestone falsification testing).
- **Meaningful Exclusions**:
  - `devops-craftsman`: Defect is an application concurrency bug, not an infrastructure or broker deployment problem.
- **Verification Obligations**:
  - Adversarial race test: dispatch concurrent identical webhook payloads using synchronization barriers (e.g. `[EXAMPLE VERIFICATION PARAMETER]` 20 parallel workers).
  - Assert exactly 1 transaction commits balance increment; all concurrent duplicates return duplicate acknowledgement without double-crediting.
  - Final database balance check: credit applied exactly 1x.
- **Final Status**: `READY` (Awaiting human approval due to HIGH risk).

---

### Scenario 5: Security Token Revocation

#### Input
> *"Implement JWT token revocation and session blacklisting so admins can terminate compromised user accounts immediately."*

#### Analysis & Routing
- **Interpretation**: Introduce instant token revocation check for an existing stateless JWT authentication setup.
- **Evidence State**:
  - `[FIXTURE]` JWT validation occurs in API middleware with tokens containing unique `jti` claims.
  - `[UNKNOWN]` Available low-latency datastore for revocation lookup (Redis vs PostgreSQL vs in-memory).
  - `[UNKNOWN]` Token expiration duration (`ACCESS_TOKEN_EXPIRE_MINUTES`).
- **Material Ambiguity**: None.
- **Scope**:
  - *In Scope*: Auth middleware validation, revocation store adapter, admin termination endpoint.
  - *Out of Scope*: Login forms, password hashing, OAuth provider integrations, RBAC schema redesign.
- **Risk**: `HIGH` (Review Policy: `MANDATORY`). Security authorization invariant at stake.
- **Selected Skills**:
  - `PRIMARY`: `security-craftsman` (fail-closed authorization, constant-time comparison, token replay defense).
  - `REQUIRED`: `engineering-craftsman` (Release Veto: verify zero auth bypass paths).
  - `REQUIRED`: `scope-guard-craftsman` (constrains datastore choice to existing infrastructure).
  - `REQUIRED`: `execution-craftsman` (adversarial failure path testing).
  - `CONDITIONAL`: `distributed-systems-craftsman` (Activated ONLY IF revocation must propagate across multi-region cache clusters).
- **Meaningful Exclusions**:
  - `business-craftsman`: Pure technical security invariant; commercial terms and user tiers are unaffected.
- **Verification Obligations**:
  - Valid token succeeds (e.g. `[VERIFICATION TARGET]` 200 OK).
  - Revoked token rejected immediately (e.g. `[VERIFICATION TARGET]` 401 Unauthorized).
  - Fail-closed verification: simulate revocation store unreachable $\to$ middleware rejects requests (e.g. `[VERIFICATION TARGET]` 503 Service Unavailable or 401 Unauthorized), never authorizes.
- **Final Status**: `READY` (Awaiting human approval due to HIGH risk).

---

### Scenario 6: Full-Stack Real-Time Inventory Dashboard

#### Input
> *"Build a real-time warehouse inventory dashboard with an interactive React frontend, Go backend streaming inventory deltas, and PostgreSQL storage."*

#### Analysis & Routing
- **Interpretation**: Full-stack application connecting database inventory state to live React dashboard via Go streaming API.
- **Evidence State**:
  - `[FIXTURE]` Monorepo containing `web/` (React) and `server/` (Go).
  - `[UNKNOWN]` Exact database migration runner used in the repository.
  - `[UNKNOWN]` Whether an explicit latency SLO exists for delta propagation.
- **Material Ambiguity**: None.
- **Scope**:
  - *In Scope*: Inventory database table, Go streaming broadcaster, React dashboard component.
  - *Out of Scope*: Barcode scanner hardware integration, third-party ERP syncing.
- **Risk**: `HIGH` (Review Policy: `MANDATORY`). Multi-boundary architecture touching persistent stock data and live connections.
- **Selected Skills**:
  - `PRIMARY`: `web-design-craftsman` (dense tabular layout, connection status badges, visual clarity).
  - `PRIMARY`: `react-craftsman` (minimal state, WebSocket lifecycle, rendering optimization).
  - `PRIMARY`: `go-craftsman` (bounded channel buffers, goroutine leak prevention, heartbeat).
  - `PRIMARY`: `database-craftsman` (schema integrity, non-negative stock check constraint, atomic updates).
  - `REQUIRED`: `architecture-craftsman` (enforces strict API/WebSocket contracts across layers).
  - `REQUIRED`: `execution-craftsman` (decomposes implementation into manageable vertical slices).
  - `REQUIRED`: `scope-guard-craftsman` (prevents scope expansion across milestones).
- **Meaningful Exclusions**:
  - `distributed-systems-craftsman`: Single Go hub server; no distributed Kafka/RabbitMQ broker cluster required.
- **Verification Obligations**:
  - Database: assert `stock >= 0` check constraint prevents negative inventory commits.
  - Go server: connect and abruptly disconnect concurrent WebSocket clients (e.g. `[EXAMPLE VERIFICATION PARAMETER]` 100 clients); assert zero leaked goroutines.
  - React client: assert high delta volume does not trigger full-page re-renders.
  - End-to-end: simulate concurrent stock updates and assert UI reflects database balance.
- **Final Status**: `READY` (Awaiting human approval due to HIGH risk).

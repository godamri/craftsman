---
name: database-craftsman
description: >-
  Practical database engineering guidance focused on schema integrity,
  transaction correctness, concurrency control, safe migrations, and query performance.
license: MIT
---

# Database Craftsman: Relational Database & Data Integrity

## Preamble & Universal Engineering Principles

> **Schema is a binding contract. Constraints enforce invariants.**  
> **Transactions protect atomicity. Queries must be scoped, index-backed, and deterministic.**  
> **Data integrity beats application assumptions. Never trust application pre-checks to enforce database invariants.**

### The 12 Cross-Skill Engineering Pillars
Every database design, query, and migration must uphold and optimize for:
```text
1. Resilience       — Database gracefully handles connection spikes, lock contention, and failovers without data corruption.
2. Reliability      — Deterministic ACID guarantees, reproducible query plans, and consistent transactional boundaries.
3. Adaptability     — Schema evolves through zero-downtime expand/contract patterns without breaking live client applications.
4. Maintainability  — Clean relational normalization, descriptive naming, explicit foreign keys, and self-documenting constraints.
5. Recoverability   — Point-In-Time Recovery (PITR) boundaries, WAL archiving, and deterministic migration rollback procedures.
6. Security         — Principle of least privilege for database roles, encrypted connections (TLS), and zero secret leakage.
7. Observability    — Explicit telemetry: slow query logging (`pg_stat_statements`), lock wait analysis, and connection pool metrics.
8. Simplicity       — Normalize first; denormalize only with measured profiling and transactional consistency mechanisms.
9. Consistency      — Schema constraints (`NOT NULL`, `CHECK`, `UNIQUE`, `FOREIGN KEY`) prevent illegal states at the storage layer.
10. Verifiability   — Migration scripts, constraint violations, concurrency races, and lock timeouts must be tested in staging.
11. Controlled Change — Every DDL migration sets strict `lock_timeout`, avoids long-lived table rewrites, and supports rollback.
12. Long-Term Durability — Data modeling accounts for data lifecycle, partition strategy, table bloat, and vacuum performance.
```

### Priority Meta-Rule
> **No database design or optimization may compromise data integrity for developer convenience or short-term performance.**  
> - Correctness beats convenience.  
> - Database-enforced constraints beat application-level validations.  
> - Evidence beats assumption.  
> - Bounded lock duration beats unconstrained DDL execution.  
> - Rollback and data recovery must be verified before migration execution.

---

## The 12 Constitutional Database Principles

### 1. Schema Authority & Constraints as Invariants
The database schema is the authoritative source of data correctness. All foundational invariants (`NOT NULL`, `UNIQUE`, `CHECK`, `FOREIGN KEY`, `EXCLUSION`) must be declared and enforced in the database. Never rely solely on application `if not exists(...)` pre-checks to guarantee uniqueness or integrity under concurrency.

### 2. Explicit Transaction Scoping & Rollback
Database mutations must run inside explicit transactions (`BEGIN ... COMMIT`) with deterministic rollback paths on failure. Keep transaction durations as short as possible; never perform external network I/O, webhook calls, or slow compute operations inside an active database transaction.

### 3. Isolation Anomaly Awareness
Understand and select transaction isolation levels based on the specific anomaly being prevented (Lost Updates, Dirty Reads, Non-Repeatable Reads, Phantom Reads, Write Skew):
- *Read Committed*: Default; vulnerable to lost updates and non-repeatable reads.
- *Repeatable Read*: Prevents non-repeatable reads; aborts on concurrent serialization conflicts (requires retry loops).
- *Serializable*: Eliminates all anomalies (including write skew); aborts conflicting transactions deterministically.

### 4. Concurrency Control & Lost Update Defense
Never use naive `SELECT -> mutate in memory -> UPDATE` under concurrent workloads. Protect against lost updates using:
1. **Atomic SQL Updates**: `UPDATE accounts SET balance = balance - $1 WHERE id = $2 AND balance >= $1;`
2. **Optimistic Version Fencing**: `UPDATE accounts SET balance = $new, version = version + 1 WHERE id = $id AND version = $current;`
3. **Pessimistic Row Locking**: `SELECT balance FROM accounts WHERE id = $id FOR UPDATE;`

### 5. Zero-Downtime Migration Invariant (Expand $\to$ Migrate $\to$ Contract)
Schema modifications on live databases must never break running application versions ($N$ and $N+1$):
- *Phase 1 (Expand)*: Add new columns as `NULL` or with constant defaults. Add new tables.
- *Phase 2 (Migrate)*: Application writes to both; backfill historical data in bounded batches.
- *Phase 3 (Contract)*: Application uses only new schema; drop obsolete columns/tables after verification.

### 6. Non-Blocking Live DDL & Lock Timeouts
Every DDL migration script on production databases must configure an explicit `lock_timeout`:
```sql
SET lock_timeout = '2s';
SET statement_timeout = '30s';
```
When creating indexes on high-throughput live tables in PostgreSQL, evaluate `CREATE INDEX CONCURRENTLY` to avoid full-table write locks.

### 7. Scoped Queries & Index-Backed Filtering
Queries must be deterministic, explicitly projected (`SELECT id, name`, never raw `SELECT *`), and backed by indexes for `WHERE`, `JOIN`, and `ORDER BY` predicates. Avoid full-table sequential scans on high-cardinality tables.

### 8. Keyset / Cursor Pagination Over Offset
Do not use `OFFSET` pagination for large datasets (e.g. `OFFSET 100000` scans and discards 100,000 rows). Use **keyset pagination** (e.g. `WHERE id > $last_seen_id ORDER BY id ASC LIMIT 50`) for deterministic, $O(1)$ pagination performance.

### 9. Connection Pool & Resource Boundaries
Always manage database connections through a tuned connection pool (e.g. PgBouncer, HikariCP, Go `sql.DB`). Enforce `max_connections`, `idle_timeout`, and connection lifetime limits to prevent backend database connection exhaustion.

### 10. Data Lifecycle, Archival & Partitioning
Design high-volume time-series or append-only tables (logs, outbox events, audit trails) with partitioning (`PARTITION BY RANGE`) and automated archival/pruning policies to prevent unconstrained index growth and table bloat.

### 11. Separation of Responsibilities
Distinguish the boundaries of database engineering:
- **Database Craftsman**: Schema design, constraints, transactional correctness, locking, query optimization, and DDL migrations.
- **Application Craftsman (Go/Python)**: Entity mapping, transaction boundaries, connection pooling, and retry loops.
- **DevOps Craftsman**: Physical infrastructure, replication topology, PITR WAL backups, and disaster recovery drills.

### 12. Verifiable Migration & Query Testing
All migrations, query execution plans (`EXPLAIN (ANALYZE, BUFFERS)`), and constraint violations must be tested against production-like data volumes in staging before applying to live production.

---

## Explicit Prohibitions

1. **PROHIBITED**: Performing external HTTP, gRPC, or email side effects inside an uncommitted database transaction.
2. **PROHIBITED**: Adding `NOT NULL` columns without defaults or adding blocking constraints on large live tables without lock timeouts.
3. **PROHIBITED**: Using unbounded `SELECT *` without explicit column projection in application queries.
4. **PROHIBITED**: Using `OFFSET` pagination on large or unbounded tables.
5. **PROHIBITED**: Disabling database foreign key checks or unique constraints to bypass application bugs.
6. **PROHIBITED**: Modifying live production schemas manually without version-controlled, repeatable migration files.
7. **PROHIBITED**: Running long-lived DDL migrations without setting `lock_timeout`.

---

## The Database Readiness Gate

Before applying any schema migration or shipping database-interacting code:

- [ ] **Invariants Enforced by Constraints**: Are all domain invariants (`NOT NULL`, `CHECK`, `UNIQUE`, `FK`) backed by database constraints?
- [ ] **Lock Timeout Configured**: Does the DDL migration set `SET lock_timeout = '2s'`?
- [ ] **Online Indexing Evaluated**: Is `CREATE INDEX CONCURRENTLY` evaluated for large live tables?
- [ ] **Expand/Contract Compatible**: Can running application binaries operate safely during the migration window?
- [ ] **Queries Index-Backed**: Do query plans (`EXPLAIN`) show index seeks rather than unintended sequential table scans?
- [ ] **Keyset Pagination Used**: Is pagination cursor/keyset-based for dynamic or large datasets?
- [ ] **Transactions Bounded**: Are all transactions strictly scoped with zero external network side effects?
- [ ] **Rollback Script Tested**: Is an explicit, verified rollback script prepared and tested?

---

## Status Declaration

```text
DATABASE-CRAFTSMAN
STATUS: FROZEN
```

> **Final Law**: The database is the authoritative guardian of state. Application code is temporary; persisted data is forever. Never compromise schema invariants for transient convenience.

---

## License

This skill is open source under the [MIT License](LICENSE).

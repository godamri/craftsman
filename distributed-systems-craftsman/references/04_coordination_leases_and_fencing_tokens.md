# Coordination, Leases & Fencing Tokens

> **Core Principle**: Distributed locks without fencing tokens are unsafe. Process pauses (GC, thread scheduling) and network delays allow expired lock holders to corrupt state.

---

## 1. The Distributed Lock Hazard (The Stale Worker Problem)

```text
Client 1: Acquires Lock (Lease = 10s) ───[ GC Pause 15s! ]───> Stale Write! [CORRUPTS DATA]
Client 2:              Acquires Lock (Token = 34) ───> Writes Data (Token = 34)
```

---

## 2. Solving Stale Writes with Monotonic Fencing Tokens

The lock manager (e.g. etcd, ZooKeeper, Redis Redlock with counter) returns a strictly monotonic number (`fencing_token`) with every lease.

The storage layer enforces that writes are rejected if the token is less than the highest token observed:

```sql
UPDATE storage_file
SET contents = $new_content,
    last_fencing_token = $fencing_token
WHERE id = $file_id
  AND last_fencing_token < $fencing_token;
```
If Client 1 wakes up from a GC pause and attempts to write with token 33 after Client 2 has written with token 34, Client 1's write is rejected with 0 rows affected.

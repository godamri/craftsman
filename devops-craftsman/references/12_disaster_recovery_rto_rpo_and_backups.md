# Disaster Recovery: RTO, RPO & Automated Verification

> **Operational Rule**: An untested backup is merely an unverified assumption. Backups must be restored and tested automatically in staging/isolated environments on a scheduled basis.

---

## 1. The 3-2-1-1-0 Backup Rule

- **3** Copies of critical data.
- **2** Different media types (e.g. cloud block storage + object storage).
- **1** Offsite / cross-region copy.
- **1** Immutable / WORM (Write Once, Read Many) air-gapped copy (protected against ransomware / rogue admin deletions).
- **0** Errors on automated restoration drills.

---

## 2. Automated Restore Verification Script

```bash
#!/usr/bin/env bash
set -euo pipefail

BACKUP_ARCHIVE="$1"
TEST_CONTAINER="pg_restore_drill_$(date +%s)"

# 1. Spin up isolated throwaway database instance
docker run -d --name "${TEST_CONTAINER}" -e POSTGRES_PASSWORD=drill -p 5439:5432 postgres:16

trap 'docker rm -f "${TEST_CONTAINER}" >/dev/null 2>&1' EXIT
sleep 5

# 2. Restore backup into test instance
gunzip -c "${BACKUP_ARCHIVE}" | docker exec -i "${TEST_CONTAINER}" psql -U postgres

# 3. Assert database invariants
RECORD_COUNT=$(docker exec -i "${TEST_CONTAINER}" psql -U postgres -t -c "SELECT count(*) FROM users;")
if [ "${RECORD_COUNT}" -gt 0 ]; then
    echo "✅ Backup restore drill PASSED. Found ${RECORD_COUNT} records."
else
    echo "❌ Backup restore drill FAILED! Zero records found."
    exit 1
fi
```

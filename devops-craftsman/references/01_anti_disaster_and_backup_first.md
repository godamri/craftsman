# Anti-Disaster Protocol: Backup-First Mutation

> **Rule**: Never modify a configuration file or system state without creating an immediate rollback copy first.

---

## 1. Backup Terminology & Storage Hierarchy

Understand the distinction between backup types:
1. **Local Backup Copy** (`cp -p config config.bak.<timestamp>`): A fast, local file copy intended exclusively for immediate operational rollback during maintenance. *Not durable against disk failure or host loss.*
2. **Durable Backup** (Snapshot / Object Storage dump): An archive pushed to durable, replicated secondary storage (e.g. S3, GCS, NAS). Protects against host and volume failure.
3. **Immutable / WORM Backup** (Write-Once-Read-Many): A cryptographic, version-locked archive protected by retention policies that prevent deletion or modification by any identity (including compromised root/admin credentials). Protects against ransomware and catastrophic operator error.

---

## 2. The Local Backup-and-Modify Pattern

```bash
#!/usr/bin/env bash
set -euo pipefail

TARGET_FILE="/etc/nginx/nginx.conf"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOCAL_BACKUP="${TARGET_FILE}.bak.${TIMESTAMP}"

# 1. Create local backup copy with preserved metadata for rollback
cp -p "${TARGET_FILE}" "${LOCAL_BACKUP}"
echo "✅ Local rollback copy created: ${LOCAL_BACKUP}"

# 2. Stage candidate changes in temporary file
TEMP_FILE="$(mktemp)"
trap 'rm -f "${TEMP_FILE}"' EXIT

cat << 'EOF' > "${TEMP_FILE}"
# Candidate configuration
user nginx;
worker_processes auto;
EOF

# 3. Perform pre-flight syntax validation on candidate file
if ! nginx -t -c "${TEMP_FILE}" 2>/dev/null; then
    echo "❌ Syntax validation failed on candidate configuration! Aborting without modifying target."
    exit 1
fi

# 4. Preview diff
diff -u "${TARGET_FILE}" "${TEMP_FILE}" || true

# 5. Apply candidate atomically
cp "${TEMP_FILE}" "${TARGET_FILE}"

# 6. Reload service and verify
if ! nginx -s reload; then
    echo "❌ Reload failed! Rolling back to previous copy immediately..."
    cp -p "${LOCAL_BACKUP}" "${TARGET_FILE}"
    nginx -s reload
    echo "⚠️ Reverted to previous working configuration."
    exit 1
fi

echo "✅ Configuration successfully applied and reloaded."
```

#!/usr/bin/env bash
# ==============================================================================
# DATABASE DUMP & INTEGRITY VERIFICATION (DevOps Craftsman Reference Implementation)
# Demonstrates: Compression, cryptographic checksum generation, archive
# integrity validation, and retention enforcement.
# ==============================================================================
set -euo pipefail

BACKUP_DIR="/tmp/db_backups"
DB_NAME="production_app"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
ARCHIVE_NAME="${DB_NAME}_${TIMESTAMP}.sql.gz"
TARGET_ARCHIVE="${BACKUP_DIR}/${ARCHIVE_NAME}"
CHECKSUM_FILE="${TARGET_ARCHIVE}.sha256"

mkdir -p "${BACKUP_DIR}"

# 1. Simulate database dump with gzip compression
echo "DUMPING DATABASE ${DB_NAME} AT ${TIMESTAMP}" | gzip -c > "${TARGET_ARCHIVE}"
echo "✅ [1/4] Database dump created: ${TARGET_ARCHIVE}"

# 2. Generate cryptographic checksum
shasum -a 256 "${TARGET_ARCHIVE}" > "${CHECKSUM_FILE}"
echo "✅ [2/4] SHA-256 checksum generated: $(cat "${CHECKSUM_FILE}")"

# 3. Verify archive integrity
if gzip -t "${TARGET_ARCHIVE}" && shasum -a 256 -c "${CHECKSUM_FILE}" >/dev/null 2>&1; then
    echo "✅ [3/4] Integrity verification PASSED (gzip test + sha256 check)."
else
    echo "❌ [3/4] Integrity verification FAILED! Backup is corrupted."
    exit 1
fi

# 4. Prune old backups (Retention: keep last 5)
find "${BACKUP_DIR}" -name "${DB_NAME}_*.sql.gz*" -type f | sort -r | tail -n +11 | xargs -r rm -f
echo "✅ [4/4] Retention policy enforced (kept latest backups)."

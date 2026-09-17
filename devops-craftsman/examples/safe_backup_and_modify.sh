#!/usr/bin/env bash
# ==============================================================================
# SAFE BACKUP AND MODIFY (DevOps Craftsman Reference Implementation)
# Demonstrates: Local rollback copy creation, candidate staging, syntax
# verification, diff preview, atomic copy, and automatic rollback on reload failure.
# ==============================================================================
set -euo pipefail

TARGET_FILE="${1:-/tmp/test_service.conf}"
NEW_CONTENT="${2:-# Updated service configuration\nport = 8080\nworkers = 4\n}"

# Ensure target file exists for demonstration
if [ ! -f "${TARGET_FILE}" ]; then
    echo "Creating initial target file at ${TARGET_FILE}..."
    printf "# Initial configuration\nport = 80\nworkers = 2\n" > "${TARGET_FILE}"
fi

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOCAL_BACKUP="${TARGET_FILE}.bak.${TIMESTAMP}"

# 1. Create local backup copy with preserved metadata
cp -p "${TARGET_FILE}" "${LOCAL_BACKUP}"
echo "✅ [1/5] Local backup copy created: ${LOCAL_BACKUP}"

# 2. Stage candidate changes in temporary file
TEMP_FILE="$(mktemp)"
trap 'rm -f "${TEMP_FILE}"' EXIT

printf "%b" "${NEW_CONTENT}" > "${TEMP_FILE}"
echo "✅ [2/5] Candidate configuration staged."

# 3. Perform syntax validation
validate_syntax() {
    local file="$1"
    # Basic demonstration syntax check: verify 'port =' directive exists
    if ! grep -q "port =" "${file}"; then
        echo "❌ Syntax error: 'port' directive missing in ${file}"
        return 1
    fi
    return 0
}

if ! validate_syntax "${TEMP_FILE}"; then
    echo "❌ [3/5] Validation failed! Aborting without modifying target file."
    exit 1
fi
echo "✅ [3/5] Pre-flight syntax validation passed."

# 4. Display unified diff
echo "--- Diff Preview ---"
diff -u "${TARGET_FILE}" "${TEMP_FILE}" || true
echo "--------------------"

# 5. Apply candidate atomically
cp "${TEMP_FILE}" "${TARGET_FILE}"
echo "✅ [4/5] Applied candidate configuration to ${TARGET_FILE}"

# 6. Post-application verification & rollback guard
simulate_service_reload() {
    # In real environments, invoke: systemctl reload <service> or nginx -s reload
    return 0
}

if ! simulate_service_reload; then
    echo "❌ [5/5] Service reload failed! Performing instant rollback..."
    cp -p "${LOCAL_BACKUP}" "${TARGET_FILE}"
    echo "⚠️ Reverted ${TARGET_FILE} from local backup copy."
    exit 1
fi

echo "✅ [5/5] Service successfully verified and live."

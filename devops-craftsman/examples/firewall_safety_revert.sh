#!/usr/bin/env bash
# ==============================================================================
# FIREWALL SAFETY REVERT TIMER (DevOps Craftsman Reference Implementation)
# Demonstrates: Safety background revert timer pattern to prevent operator lockout.
# (Illustrative demonstration of the background countdown and cancellation mechanism)
# ==============================================================================
set -euo pipefail

RULES_BACKUP="/tmp/firewall_rules.bak"
TIMEOUT_SECONDS=10 # Short timeout for automated testing/demonstration

# Mock saving current rules
echo "STATE: ACCEPT_ALL" > "${RULES_BACKUP}"
echo "✅ [1/4] Current firewall state backed up to ${RULES_BACKUP}"

# Arm background safety revert timer
(
    sleep "${TIMEOUT_SECONDS}"
    if [ -f "${RULES_BACKUP}" ]; then
        echo -e "\n⚠️ Safety timeout (${TIMEOUT_SECONDS}s) reached! Restoring firewall state..."
        # In real environments: iptables-restore < "${RULES_BACKUP}"
        echo "✅ Firewall state restored from backup. Operator lockout prevented."
    fi
) &
TIMER_PID=$!
echo "✅ [2/4] Safety revert timer armed (PID: ${TIMER_PID}, Timeout: ${TIMEOUT_SECONDS}s)"

# Apply candidate rule
echo "STATE: RESTRICTED_HTTPS_ONLY" > /tmp/firewall_active_state
echo "✅ [3/4] Applied new firewall rules."

# Operator confirmation simulation
simulate_operator_confirmation() {
    # If operator confirms connectivity, disarm timer
    kill "${TIMER_PID}" 2>/dev/null || true
    echo "✅ [4/4] Connection verified. Safety revert timer disarmed. Rules persisted."
}

simulate_operator_confirmation

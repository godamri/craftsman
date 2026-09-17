# Safe Server Administration & Remote Access Survival

> **Operational Rule**: Never execute changes that affect SSH, sudo, or firewalls without a fallback access path and an automated safety rollback.

---

## 1. Modifying Sudoers Safely

Never edit `/etc/sudoers` directly with standard text editors. Always use `visudo`:

```bash
# Validate syntax before applying
visudo -c -f /etc/sudoers.d/custom_rules
```

If generating rules programmatically:
```bash
TEMP_SUDO="$(mktemp)"
cat << 'EOF' > "${TEMP_SUDO}"
deploy ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx
EOF

if visudo -c -f "${TEMP_SUDO}"; then
    cp "${TEMP_SUDO}" /etc/sudoers.d/deploy_rules
    chmod 0440 /etc/sudoers.d/deploy_rules
else
    echo "❌ Invalid sudoers syntax! Aborting."
    rm -f "${TEMP_SUDO}"
    exit 1
fi
```

---

## 2. Firewall Safety Revert Timer

When applying remote firewall rules (`iptables`, `nftables`, `ufw`), arm an automated background revert timer before applying new rules:

```bash
#!/usr/bin/env bash
set -euo pipefail

# 1. Backup current rules
iptables-save > /tmp/iptables.rules.bak

# 2. Arm safety revert timer in background (reverts in 60s if connection drops)
(
    sleep 60
    echo "⚠️ Safety timeout reached! Reverting firewall rules..."
    iptables-restore < /tmp/iptables.rules.bak
) &
REVERT_PID=$!

# 3. Apply new firewall rules
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# 4. If connection is verified healthy by the operator, disarm the timer
echo "Type 'CONFIRM' within 60s to persist rules:"
read -r -t 45 USER_INPUT || USER_INPUT=""

if [ "${USER_INPUT}" = "CONFIRM" ]; then
    kill "${REVERT_PID}" 2>/dev/null || true
    echo "✅ Rules confirmed and persisted."
else
    echo "❌ Confirmation failed or timed out. Reverting rules immediately."
    kill "${REVERT_PID}" 2>/dev/null || true
    iptables-restore < /tmp/iptables.rules.bak
fi
```

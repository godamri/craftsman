# Secrets, Credentials & Zero-Leakage Policy

Secrets are sensitive cryptographic materials that must never be exposed in repositories, shell histories, logs, or unencrypted backups.

---

## 1. Zero-Downtime Secret Rotation Workflow

Never change a database password, API key, or JWT secret instantaneously without an overlap window:

```text
Phase 1 (Dual-Verification):
  Configure database/auth service to accept BOTH Old Key and New Key.
Phase 2 (Canary Rollout):
  Deploy application instances configured with the New Key.
Phase 3 (Drain Verification):
  Monitor logs/metrics to verify that 0% of active traffic is using the Old Key.
Phase 4 (Revocation):
  Revoke the Old Key from the database/auth provider.
```

---

## 2. Shell History & Environment Protection

- Prepend sensitive commands with a leading space:
  ```bash
  export HISTCONTROL=ignorespace
   export DB_PASSWORD="super-secret-password"  # Note leading space
  ```
- Or run in subshell without history:
  ```bash
  ( set +o history; ./deploy.sh --token "${SECRET_TOKEN}"; set -o history )
  ```

# Destructive Commands & Blast Radius Control

> **Operational Rule**: Destructive commands must have bounded scope, explicit variable validations, and pre-execution dry runs.

---

## 1. Safe Deletion Patterns in Bash

Unset or empty variables in `rm -rf "${DIR}/*"` can expand to `rm -rf /*` and destroy the host operating system.

### Defenses:
```bash
# 1. Use strict parameter expansion default checks
: "${TARGET_DIR:?Error: TARGET_DIR is unset or empty}"

# 2. Explicit sanity validation before deletion
if [ -d "${TARGET_DIR}" ] && [ "${TARGET_DIR}" != "/" ] && [ "${TARGET_DIR}" != "/root" ]; then
    find "${TARGET_DIR}" -mindepth 1 -delete
else
    echo "❌ Refusing to delete unsafe directory: ${TARGET_DIR}"
    exit 1
fi
```

---

## 2. Docker & Container Cleanup Safeguards

Avoid blind `docker system prune -a --volumes -f` in production environments because it drops persistent database volumes.

```bash
# Safe: Prune dangling images and stopped containers without touching persistent volumes
docker container prune -f
docker image prune -f

# Never pass --volumes blindly on production database hosts!
```

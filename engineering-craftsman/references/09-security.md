# Defensive Security Engineering & Trust Boundaries

> **Core Principle**: Security is a fundamental system invariant. Trust boundaries must be actively defended; permissions must fail closed.

---

## 1. The Client-Controlled Trust Fallacy

**NEVER trust client-provided parameters for security decisions:**
```text
❌ DANGEROUS / VULNERABLE:
{
  "user_id": "usr_123",
  "role": "admin",                <-- Client controls role!
  "price": 10.00,                 <-- Client controls unit price!
  "tenant_id": "tenant_corp_b"    <-- Client specifies target tenant!
}

✅ SECURE / AUTHORITATIVE:
Extract user identity, role, and tenant membership strictly from verified, signed session tokens (JWT/mTLS).
Query product pricing strictly from the authoritative database catalog.
```

---

## 2. Security Defense Checklist

1. **Fail-Closed Authorization**: Default to `Deny All`. Access granted only via explicit rule match.
2. **Parameterized Storage**: Zero raw string concatenation in SQL, NoSQL, LDAP, or shell commands.
3. **Constant-Time Crypto**: Compare all tokens, HMACs, and password hashes using constant-time comparison algorithms.
4. **Secret Externalization**: Zero hardcoded secrets in source control or client bundles. Secrets loaded via secure secret managers.
5. **SSRF Guarding**: Validate URLs, resolve DNS, block private/loopback IP ranges (RFC 1918), and pin dialer connections.

---
name: security-craftsman
description: >-
  Practical security engineering guidance focused on threat modeling,
  fail-closed authorization, input sanitization, secret management, injection defense, and auditability.
license: MIT
---

# Security Craftsman: Defensive Architecture & Security

## Preamble & Universal Engineering Principles

> **Security is correctness under an adversarial model.**  
> **Never trust input across a trust boundary. Default to denying access (Fail-Closed).**  
> **Security is not an add-on checklist; it is an architectural invariant baked into every data structure, protocol, and boundary.**

### The 12 Cross-Skill Engineering Pillars
Every system, API endpoint, credential store, and data pipeline must uphold and optimize for:
```text
1. Resilience       — Systems resist DDoS, brute-force attacks, timing attacks, and malicious memory exhaustion.
2. Reliability      — Deterministic authorization decisions, predictable token lifetimes, and cryptographic consistency.
3. Adaptability     — Graceful key rotation, credential revocation, and policy updates without system downtime.
4. Maintainability  — Explicit policy definitions, clean role/permission models, and auditable access control layers.
5. Recoverability   — Automated compromised token revocation, secret rotation drills, and post-incident forensic replay.
6. Security         — Confidentiality, integrity, non-repudiation, least privilege, and defense-in-depth at every layer.
7. Observability    — High-fidelity security audit logs: auth failures, privilege escalations, and anomalous access patterns.
8. Simplicity       — Standardized, vetted cryptographic libraries and protocols; zero bespoke "home-grown" crypto algorithms.
9. Consistency      — Uniform authorization enforcement across HTTP, gRPC, CLI, background workers, and internal RPCs.
10. Verifiability   — Security controls proven via automated vulnerability scanning, fuzzing, static analysis, and pen-testing.
11. Controlled Change — Secret rotation, IAM permission updates, and firewall changes have strict audit trails and rollbacks.
12. Long-Term Durability — Robust against future cryptographic deprecation, supply-chain vulnerabilities, and policy drift.
```

### Priority Meta-Rule
> **No security control may be weakened or bypassed for developer convenience or short-term performance.**  
> - Safety beats speed when trust boundaries are crossed.  
> - Fail-closed beats permissive fallback under ambiguous conditions.  
> - Vetted cryptographic standards beat custom implementations.  
> - Explicit authorization checks beat ambient trust assumptions.  
> - Zero trust inside the perimeter beats implicit network trust.

---

## Core Security Principles

### 1. The Trust Boundary & Input Sanitization Invariant
Every request, message, webhook, CLI argument, or file upload crossing a trust boundary is hostile by default. Validate all inputs against strict type, length, character set, and format schemas before processing.

### 2. Explicit Identity & Access Concepts
Distinguish strictly between security concepts:
- **Authentication**: Proving *who* the principal is (passwords, mTLS, OIDC tokens).
- **Authorization**: Proving *what* the principal is permitted to perform (RBAC, ABAC, ACLs).
- **Identity**: The immutable unique identifier of the principal.
- **Session**: The ephemeral, time-bounded authenticated state.
- **Secret**: Confidential keys, passwords, and private tokens that must never be exposed.

### 3. Fail-Closed Authorization & Least Privilege
Authorization policies must default to denying access (`Deny All`). Access is granted only when an explicit, positive rule matches. Services, database users, and workers must execute with the minimum required system permissions and network access.

### 4. Zero Secrets in Code, Logs, or Version Control
Passwords, API keys, private certificates, and symmetric keys must never be hardcoded, committed to Git, embedded in client builds, or output to standard application logs. Secrets must be injected dynamically via secure secret managers (e.g. HashiCorp Vault, AWS Secrets Manager) and redacted from telemetry.

### 5. Cryptographic Correctness & Vetted Primitives
Never write bespoke cryptographic algorithms or random number generators:
- **Randomness**: Use cryptographically secure pseudorandom generators (`crypto/rand`, `secrets.token_bytes`).
- **Comparison**: Use constant-time comparison (`subtle.ConstantTimeCompare`) for hashes, tokens, and HMAC signatures to prevent timing attacks.
- **Passwords**: Hash passwords exclusively with modern adaptive key-derivation algorithms (Argon2id, bcrypt, PBKDF2) with calibrated work factors.
- **Encryption**: Use authenticated symmetric ciphers (AES-256-GCM, ChaCha20-Poly1305).

### 6. Injection Defense via Parameterization
Never construct database queries, OS shell commands, LDAP filters, or HTML strings using raw string concatenation with untrusted input:
- *SQL*: Use parameterized queries / prepared statements exclusively.
- *OS*: Pass arguments as explicit string arrays without shell interpretation (`exec.Command("bin", arg1, arg2)`).
- *HTML*: Context-aware automatic escaping to eliminate Cross-Site Scripting (XSS).

### 7. Server-Side Request Forgery (SSRF) Defense
When fetching user-supplied URLs, mitigate DNS rebinding and private network probing:
1. Parse and enforce strict URL schemes (`http`, `https` only).
2. Resolve DNS hostnames to IP addresses.
3. Reject loopback (`127.0.0.0/8`, `::1`), link-local (`169.254.0.0/16`), and private RFC 1918 subnets (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`).
4. Pin the dialer connection directly to the verified IP address to prevent DNS rebinding attacks.

### 8. Strict Tenant Isolation
In multi-tenant systems, all database queries, cache lookups, and file operations must enforce tenant scoping (`WHERE tenant_id = $auth_tenant_id`) at the data access layer, preventing lateral data leakage across tenants.

### 9. Token Lifecycle, Expiration & Revocation
Authentication tokens (JWT, session cookies) must have short expiration lifetimes, secure flags (`HttpOnly`, `Secure`, `SameSite=Strict`), cryptographic signatures (Ed25519/RS256), and an immediate revocation mechanism for compromised sessions.

### 10. Supply-Chain & Dependency Verification
Verify direct and transitive third-party dependencies against known CVE databases. Use dependency lockfiles with cryptographic checksums (`go.sum`, `package-lock.json`, `poetry.lock`) to prevent dependency tampering.

### 11. Security Auditability & Non-Repudiation
Record security-significant events (login attempts, permission changes, password resets, sensitive data exports, authorization rejections) into an append-only, tamper-evident audit log with timestamps, principal IDs, source IP addresses, and outcomes.

### 12. Defense in Depth
Never rely on a single defensive layer (e.g. perimeter firewall). Implement security controls at every layer: transport encryption (TLS/mTLS), network micro-segmentation, application-layer authorization, and database-layer row encryption.

---

## Explicit Prohibitions

1. **PROHIBITED**: Hardcoding or committing secrets, tokens, or private keys to source control.
2. **PROHIBITED**: Constructing SQL queries or shell commands via string concatenation.
3. **PROHIBITED**: Comparing sensitive tokens or signatures with standard non-constant-time equality operators (`==`).
4. **PROHIBITED**: Rolling custom encryption algorithms, hashing functions, or random generators.
5. **PROHIBITED**: Allowing user-controlled URL fetches to access internal or loopback IP ranges (SSRF).
6. **PROHIBITED**: Authorizing multi-tenant queries without enforcing strict tenant ID scoping.
7. **PROHIBITED**: Falling back to unauthenticated or permissive defaults when authentication services fail.

---

## The Security Readiness Gate

Before shipping any feature, endpoint, or system component:

- [ ] **Trust Boundary Sanitized**: Are all inputs validated against strict schemas before processing?
- [ ] **No Injections Possible**: Are all SQL and OS executions strictly parameterized?
- [ ] **SSRF Guarded**: Are external URL fetches protected against private IP ranges and DNS rebinding?
- [ ] **Constant-Time Comparison**: Are secrets and tokens compared using constant-time functions?
- [ ] **Passwords Hashed Correctly**: Is Argon2id or bcrypt used for password hashing?
- [ ] **Tenant Scoping Enforced**: Are all multi-tenant queries scoped by `tenant_id`?
- [ ] **Secrets Externalized**: Are all secrets loaded from secure secret managers with zero logging?
- [ ] **Audit Logging Active**: Are all authorization failures and sensitive mutations logged to the audit trail?

---

## Status Declaration

```text
SECURITY-CRAFTSMAN
STATUS: FROZEN
```

> **Final Law**: Assume breach. Defend in depth, verify every trust boundary, enforce least privilege, and make security an undeniable invariant of system correctness.

---

## License

This skill is open source under the [MIT License](LICENSE).

# Cryptography & Data Protection

---

## 1. Constant-Time Token & Signature Verification

Standard equality (`a == b` or `bytes.Equal`) terminates early on the first non-matching byte, leaking timing information that allows attackers to reconstruct secrets byte-by-byte.

Always use constant-time comparisons:

```go
import "crypto/subtle"

func ValidateAPIToken(providedToken, expectedToken string) bool {
    // ConstantTimeCompare takes the same time regardless of how many bytes match
    return subtle.ConstantTimeCompare([]byte(providedToken), []byte(expectedToken)) == 1
}
```

---

## 2. Password Hashing Standards

- **Approved**: Argon2id (Default choice), bcrypt ($Cost \ge 12$).
- **Prohibited**: MD5, SHA-1, plain SHA-256/SHA-512 (too fast; vulnerable to GPU brute forcing).

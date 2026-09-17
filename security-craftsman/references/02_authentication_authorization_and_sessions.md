# Authentication, Authorization & Session Management

---

## 1. Distinct Security Concepts

- **Authentication (AuthN)**: Verification of claimed identity (e.g. validating an asymmetric JWT signature against a JWKS endpoint or verifying a password hash with Argon2id).
- **Authorization (AuthZ)**: Deciding whether an authenticated principal has permission to perform a specific action on a specific resource (e.g. `Can(User, "orders.delete", Order)`).
- **Session Tokens**: Time-bounded identifiers referencing authenticated sessions.
  - Cookies must specify: `HttpOnly; Secure; SameSite=Strict; Path=/`.
  - API Bearer tokens must specify: short expiration (`exp`), audience (`aud`), and issuer (`iss`).

---

## 2. Fail-Closed Authorization Pattern

```go
func AuthorizeRequest(user *User, permission Permission, resource Resource) error {
    if user == nil || !user.IsActive {
        return ErrUnauthorized
    }
    // Fail-Closed: Explicit positive match required
    for _, role := range user.Roles {
        if role.HasPermission(permission, resource) {
            return nil // Granted
        }
    }
    return ErrForbidden // Default deny
}
```

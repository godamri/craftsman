# Example: API Extension

## User Request
> "Add the user's organization name to the `/api/me` profile response."

---

## ❌ Bad Agent Behavior (Unnecessary Services & Caching)
```markdown
I will create a dedicated `OrganizationService` to handle organization lookups:
1. Create `src/services/organizationService.ts`.
2. Add Redis caching for organization lookups to ensure low latency.
3. Create a new endpoint `/api/organizations/{id}/summary`.
4. Update `/api/me` to call the new service over an internal HTTP request.
```

**Why it is bad**:
- Hallucinates a separate service and caching layer for a simple relational attribute.
- Introduces internal network latency loops.
- Creates new unrequested endpoints instead of extending the existing profile handler.

---

## ✅ Good Agent Behavior (Scope Guard Craftsman)

```markdown
Plan: Extend the existing `/api/me` serializer to include `organization_name` from the currently loaded User model; no new services, database tables, or caching layers are planned.

### What will change
- Add `organization_name` to `UserProfileSerializer`, mapping to the existing `organization.name` relation.
- Add `select_related('organization')` to the user query in the existing view to prevent N+1 queries.

### What will not change
- No new routes or service abstractions created.
- Existing database schema remains identical.

### Existing capabilities reused
- Existing ORM relationship `User.organization`.
- Existing `UserProfileSerializer`.

### Affected Files
- `src/users/serializers.py` (2 lines added)
- `src/users/views.py` (1 line modified)

### Verification
- Run existing user endpoint test: `pytest tests/test_user_api.py -k test_me_endpoint`.
- Confirm `organization_name` appears in the JSON response payload.
```

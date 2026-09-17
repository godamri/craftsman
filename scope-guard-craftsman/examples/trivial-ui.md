# Example: Trivial UI Change

## User Request
> "Make the login button purple."

---

## ❌ Bad Agent Behavior (Architecture Hallucination & Scope Creep)
```markdown
I noticed the app doesn't have a dynamic theming system. I will implement one:
1. Create `src/theme/ThemeProvider.tsx` using React Context.
2. Install `@emotion/react` and `@emotion/styled`.
3. Add a `theme` column to the `user_preferences` table via a new migration.
4. Refactor `LoginForm.tsx` and 12 other buttons to use the new theme tokens.
```

**Why it is bad**:
- Assumes a theming system is required when the user only asked for one button's color.
- Introduces unnecessary npm dependencies.
- Introduces an unrequested database migration.
- Explodes the diff from 1 file to 14 files.

---

## ✅ Good Agent Behavior (Scope Guard Craftsman)

```markdown
Plan: Update the existing login button styling to purple in the login component; no backend, authentication, or database change is expected.

### What will change
- Update the button's styling classes in `src/components/LoginForm.tsx` from `bg-blue-600` to `bg-purple-600`.

### What will not change
- Form submit logic, authentication hooks, and layout remain untouched.

### Existing capabilities reused
- Existing Tailwind CSS utility classes.

### Affected Files
- `src/components/LoginForm.tsx` (1 line changed)

### Verification
- Visually verify button renders purple and hover state works.
- Click button to verify submit handler still fires.
```

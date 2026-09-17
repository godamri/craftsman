# Component Composition & Feature Colocation

---

## 1. Composition Over Prop Drilling

Instead of drilling props 5 levels deep, pass composed children directly:

```jsx
// ❌ BROKEN: Prop drilling through intermediate components
function Page({ user, onLogout }) {
    return <Header user={user} onLogout={onLogout} />;
}

// ✅ CORRECT: Compose with children
function Page({ user, onLogout }) {
    return (
        <Header>
            <UserMenu user={user} onLogout={onLogout} />
        </Header>
    );
}
```

---

## 2. Feature-First Colocation Structure

```text
src/
├── components/ui/       # Shared design system primitives (Button, Modal, Input)
├── features/            # Business feature domains
│   ├── auth/            # Auth forms, auth hook, auth service
│   ├── checkout/        # Cart summary, payment gateway widget
│   └── dashboard/       # Metric cards, data tables
├── hooks/               # Generic shared hooks (useDebounce, useMediaQuery)
├── lib/                 # Utility helpers (cn.js, apiClient.js)
└── routes/              # Page components / routing configuration
```

# React State & Derived Values

> **Core Principle**: If a value can be calculated from existing props or state, compute it directly during rendering. Never mirror props to state or sync secondary state via `useEffect`.

---

## 1. Anti-Pattern: Redundant State & `useEffect` Sync

```jsx
// ❌ BROKEN: Redundant state causing extra re-renders, sync bugs, and stale UI
function BadUserList({ users, filterText }) {
    const [filteredUsers, setFilteredUsers] = useState([]);

    useEffect(() => {
        setFilteredUsers(
            users.filter(u => u.name.toLowerCase().includes(filterText.toLowerCase()))
        );
    }, [users, filterText]);

    return <ul>{filteredUsers.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
}
```

```jsx
// ✅ CORRECT: Derived state computed directly during render
function GoodUserList({ users, filterText }) {
    // Computed instantly during render: zero useEffect, zero extra render cycles
    const filteredUsers = users.filter(u =>
        u.name.toLowerCase().includes(filterText.toLowerCase())
    );

    return <ul>{filteredUsers.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
}
```

---

## 2. Resetting Form State on ID Change (Use `key` Prop)

Instead of using `useEffect` to reset form fields when an item ID changes, use the React `key` prop on the component to reset its internal state automatically:

```jsx
// ✅ Key prop forces React to unmount and re-initialize state cleanly
<UserProfileForm key={userId} userId={userId} />
```

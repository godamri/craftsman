# `useEffect` & Lifecycle Discipline

Effects are intended for synchronizing React state with systems outside React's render model (e.g. browser APIs, DOM measurements, external subscriptions, timers).

---

## 1. When to Use Effects vs Event Handlers

| Goal | Wrong Approach | Correct Approach |
| :--- | :--- | :--- |
| **Transform data for rendering** | Effect updating secondary state | Calculate derived values directly during render. |
| **Handle user interactions (clicks, submits)** | Setting state to trigger an effect | Execute business logic directly inside the event handler (`onClick`, `onSubmit`). |
| **Reset state when prop/ID changes** | Effect calling `setState(...)` | Use the React `key` prop on the component to reset state cleanly. |
| **Synchronize with external systems** | Manual calls during render | Use an effect with appropriate setup and cleanup. |

---

## 2. Effect Cleanups & StrictMode Resilience

React StrictMode executes effects with an immediate setup $\to$ cleanup $\to$ setup cycle in development to surface missing cleanup handlers.

```jsx
useEffect(() => {
    // 1. Setup: subscribe or attach listener
    const handleResize = () => setWindowWidth(window.innerWidth);
    window.addEventListener('resize', handleResize);

    // 2. Cleanup: detach and release resources
    return () => {
        window.removeEventListener('resize', handleResize);
    };
}, []);
```

---

## 3. Preventing Stale Asynchronous Results

When performing asynchronous work inside an effect, prevent unmounted or superseded executions from updating state:

```jsx
useEffect(() => {
    let isCurrent = true;

    async function loadData() {
        const data = await fetchUserData(userId);
        if (isCurrent) {
            setUser(data);
        }
    }

    loadData();

    return () => {
        isCurrent = false; // Discard stale results if userId changes before completion
    };
}, [userId]);
```

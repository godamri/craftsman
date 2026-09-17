# Error Boundaries & Failure Domain Isolation

Error Boundaries are React components that catch JavaScript errors anywhere in their child component tree during **rendering, in lifecycle methods, and in constructors**.

---

## 1. Error Boundary Scopes & Limitations

| Error Type | Caught by Error Boundary? | Correct Handling Mechanism |
| :--- | :--- | :--- |
| **Render / JSX Evaluation Error** | ✅ Yes | `<ErrorBoundary>` with fallback UI. |
| **Lifecycle / Hook Mounting Error** | ✅ Yes | `<ErrorBoundary>` with fallback UI. |
| **Event Handler Error (`onClick`)** | ❌ No | Standard `try...catch` inside the event handler. |
| **Asynchronous Fetch / Promise Rejection** | ❌ No | TanStack Query `isError` / async error state. |
| **Server-Side Rendering (SSR) Error** | ❌ No | Server framework error handling middleware. |

---

## 2. Feature-Level Error Boundary Implementation

```jsx
import React from 'react';

export class FeatureErrorBoundary extends React.Component {
    state = { hasError: false, error: null };

    static getDerivedStateFromError(error) {
        return { hasError: true, error };
    }

    componentDidCatch(error, errorInfo) {
        console.error('Feature render error caught by boundary:', error, errorInfo);
    }

    render() {
        if (this.state.hasError) {
            return (
                <div className="rounded-lg border border-red-200 bg-red-50 p-4 text-red-800">
                    <h3 className="font-semibold">Unable to display this component</h3>
                    <p className="text-sm text-red-600 mt-1">
                        {this.state.error?.message || 'An unexpected rendering error occurred.'}
                    </p>
                    <button
                        onClick={() => this.setState({ hasError: false, error: null })}
                        className="mt-3 rounded bg-red-600 px-3 py-1 text-xs text-white hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500"
                    >
                        Retry Component
                    </button>
                </div>
            );
        }
        return this.props.children;
    }
}
```

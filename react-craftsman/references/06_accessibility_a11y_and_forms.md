# Accessibility (a11y) & Accessible Components

> **Operational Rule**: Accessibility is correctness. All interactive UI elements must be keyboard navigable, screen-reader compatible, and semantically valid.

---

## 1. Accessible Form Field Pattern

```jsx
export function FormInput({ label, id, error, ...props }) {
    const errorId = `${id}-error`;

    return (
        <div className="flex flex-col gap-1.5">
            <label htmlFor={id} className="text-sm font-medium text-slate-700">
                {label}
            </label>
            <input
                id={id}
                aria-invalid={Boolean(error)}
                aria-describedby={error ? errorId : undefined}
                className={cn(
                    'rounded-md border px-3 py-2 text-sm transition-colors',
                    'focus:outline-none focus:ring-2 focus:ring-blue-500',
                    error ? 'border-red-500 text-red-900 focus:ring-red-500' : 'border-slate-300'
                )}
                {...props}
            />
            {error && (
                <p id={errorId} role="alert" className="text-xs text-red-600">
                    {error}
                </p>
            )}
        </div>
    );
}
```

---

## 2. Accessible Modal Dialog Lifecycle

A fully accessible modal must satisfy:
1. **Focus Management**: Focus moves to the first focusable element inside the modal on open.
2. **Focus Trap**: `Tab` and `Shift+Tab` cycle strictly within modal elements.
3. **Keyboard Dismissal**: Closes on `Escape` key press.
4. **Trigger Restoration**: Focus returns to the trigger element when the modal closes.
5. **Scroll Containment**: Background page scrolling is locked on open and restored on close.
6. **Semantics**: Root container has `role="dialog"`, `aria-modal="true"`, and `aria-labelledby`.

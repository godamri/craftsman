# Tailwind CSS Patterns & The `cn()` Utility

Tailwind CSS relies on static source-code scanning to detect class names at build time. Dynamic string construction prevents classes from being extracted.

---

## 1. The `cn()` Class Name Merger

Combine `clsx` (for conditional classes) and `tailwind-merge` (for resolving conflicting Tailwind utility classes):

```javascript
// src/lib/utils.js
import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs) {
    return twMerge(clsx(inputs));
}
```

Usage in reusable components:
```jsx
export function Button({ variant = 'primary', className, children, ...props }) {
    return (
        <button
            className={cn(
                'inline-flex items-center justify-center rounded-md font-medium transition-colors',
                'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-blue-500',
                'disabled:pointer-events-none disabled:opacity-50',
                variant === 'primary' && 'bg-blue-600 text-white hover:bg-blue-700',
                variant === 'secondary' && 'bg-slate-100 text-slate-900 hover:bg-slate-200',
                variant === 'danger' && 'bg-red-600 text-white hover:bg-red-700',
                className // Safely overrides base styles without utility conflicts
            )}
            {...props}
        >
            {children}
        </button>
    );
}
```

---

## 2. Dynamic Class Extraction

```javascript
// ❌ BROKEN: The Tailwind scanner cannot detect interpolated strings
const color = 'red';
const badgeClass = `bg-${color}-500 text-${color}-900`;

// ✅ CORRECT: Use an explicit mapping dictionary with complete static class names
const colorMap = {
    red: 'bg-red-500 text-red-900',
    green: 'bg-green-500 text-green-900',
    blue: 'bg-blue-500 text-blue-900',
};
const badgeClass = colorMap[color] || colorMap.blue;
```

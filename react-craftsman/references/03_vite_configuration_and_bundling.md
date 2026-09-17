# Vite Configuration & Bundling

Vite provides blazing-fast Hot Module Replacement (HMR) and optimized Rollup production builds.

---

## 1. Path Aliases & Clean Imports

Configure `@/` path aliasing in `vite.config.js`:

```javascript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
    plugins: [react()],
    resolve: {
        alias: {
            '@': path.resolve(__dirname, './src'),
        },
    },
});
```

---

## 2. Environment Variables & Client Security

- All client-accessible environment variables must start with `VITE_` (e.g. `VITE_API_BASE_URL`).
- Access via `import.meta.env.VITE_API_BASE_URL`.
- **CRITICAL**: Never prefix private API secrets, database passwords, or private encryption keys with `VITE_`. Everything bundled by Vite is visible in plain text to client browser inspection.

---

## 3. Dynamic Imports & Route Splitting

```jsx
import { lazy, Suspense } from 'react';

const AnalyticsDashboard = lazy(() => import('@/features/analytics/Dashboard'));

export function AppRoutes() {
    return (
        <Suspense fallback={<div className="p-8 text-center">Loading feature...</div>}>
            <AnalyticsDashboard />
        </Suspense>
    );
}
```

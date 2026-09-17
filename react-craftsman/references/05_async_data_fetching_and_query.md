# Async Data Fetching & State Synchronization

> **Operational Rule**: Server state (remote data) is not local UI state. Manage remote data with dedicated caching libraries (TanStack Query / SWR) or guard manual fetches against race conditions.

---

## 1. Manual Fetch with `AbortController`

When writing raw `useEffect` fetches, always handle cleanup and fast user typing / parameter changes with `AbortController`:

```jsx
function SearchResults({ query }) {
    const [results, setResults] = useState([]);
    const [status, setStatus] = useState('idle'); // 'idle' | 'loading' | 'success' | 'error'

    useEffect(() => {
        if (!query.trim()) {
            setResults([]);
            return;
        }

        const controller = new AbortController();
        setStatus('loading');

        fetch(`/api/search?q=${encodeURIComponent(query)}`, { signal: controller.signal })
            .then(res => {
                if (!res.ok) throw new Error('Search failed');
                return res.json();
            })
            .then(data => {
                setResults(data);
                setStatus('success');
            })
            .catch(err => {
                if (err.name !== 'AbortError') {
                    setStatus('error');
                }
            });

        // Abort in-flight request if query changes or component unmounts
        return () => controller.abort();
    }, [query]);

    if (status === 'loading') return <div>Searching...</div>;
    return <ul>{results.map(r => <li key={r.id}>{r.title}</li>)}</ul>;
}
```

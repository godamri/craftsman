import React, { useState, useTransition, useEffect, useRef } from 'react';
import { cn } from './lib_utils_cn.js';

// --- Reusable Accessible UI Primitives ---

export function Button({ variant = 'primary', size = 'md', className, children, ...props }) {
    return (
        <button
            className={cn(
                'inline-flex items-center justify-center rounded-lg font-medium transition-colors',
                'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2',
                'disabled:pointer-events-none disabled:opacity-50 active:scale-[0.98]',
                variant === 'primary' && 'bg-blue-600 text-white hover:bg-blue-700 focus-visible:ring-blue-500',
                variant === 'secondary' && 'bg-slate-100 text-slate-900 hover:bg-slate-200 focus-visible:ring-slate-400',
                variant === 'outline' && 'border border-slate-300 bg-transparent hover:bg-slate-50 focus-visible:ring-slate-400',
                size === 'sm' && 'px-3 py-1.5 text-xs',
                size === 'md' && 'px-4 py-2 text-sm',
                size === 'lg' && 'px-6 py-3 text-base',
                className
            )}
            {...props}
        >
            {children}
        </button>
    );
}

/**
 * Accessible Modal Dialog
 * Implements:
 * 1. Focus trap (Tab / Shift+Tab within modal elements)
 * 2. Focus retention and return to trigger element on close
 * 3. Escape key dismissal
 * 4. Background scroll locking and restoration
 * 5. Semantic ARIA dialog roles and labelling
 */
export function AccessibleModal({ isOpen, onClose, title, children }) {
    const modalRef = useRef(null);
    const triggerElementRef = useRef(null);

    useEffect(() => {
        if (!isOpen) return;

        // Save currently focused trigger element before opening
        triggerElementRef.current = document.activeElement;

        // 1. Lock background scrolling
        const originalOverflow = document.body.style.overflow;
        document.body.style.overflow = 'hidden';

        // 2. Focus first focusable element or modal container
        const focusableElements = modalRef.current?.querySelectorAll(
            'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
        );
        const firstElement = focusableElements?.[0];
        firstElement?.focus();

        // 3. Handle keyboard events: Escape dismissal and Tab focus trap
        const handleKeyDown = (e) => {
            if (e.key === 'Escape') {
                e.preventDefault();
                onClose();
                return;
            }

            if (e.key === 'Tab' && focusableElements && focusableElements.length > 0) {
                const first = focusableElements[0];
                const last = focusableElements[focusableElements.length - 1];

                if (e.shiftKey) {
                    if (document.activeElement === first) {
                        e.preventDefault();
                        last.focus();
                    }
                } else {
                    if (document.activeElement === last) {
                        e.preventDefault();
                        first.focus();
                    }
                }
            }
        };

        window.addEventListener('keydown', handleKeyDown);

        // 4. Cleanup: restore background scrolling and return focus to trigger
        return () => {
            document.body.style.overflow = originalOverflow;
            window.removeEventListener('keydown', handleKeyDown);
            if (triggerElementRef.current && typeof triggerElementRef.current.focus === 'function') {
                triggerElementRef.current.focus();
            }
        };
    }, [isOpen, onClose]);

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/50 backdrop-blur-sm p-4">
            <div
                ref={modalRef}
                role="dialog"
                aria-modal="true"
                aria-labelledby="modal-title"
                tabIndex={-1}
                className="w-full max-w-md rounded-xl bg-white p-6 shadow-2xl animate-in fade-in zoom-in-95 duration-150 focus:outline-none"
            >
                <div className="flex items-center justify-between pb-3 border-b border-slate-100">
                    <h2 id="modal-title" className="text-lg font-semibold text-slate-900">
                        {title}
                    </h2>
                    <button
                        onClick={onClose}
                        aria-label="Close dialog"
                        className="rounded-lg p-1.5 text-slate-400 hover:bg-slate-100 hover:text-slate-700 focus-visible:ring-2 focus-visible:ring-slate-400"
                    >
                        ✕
                    </button>
                </div>
                <div className="py-4 text-sm text-slate-600">{children}</div>
                <div className="flex justify-end gap-2 pt-3 border-t border-slate-100">
                    <Button variant="secondary" onClick={onClose}>
                        Cancel
                    </Button>
                    <Button variant="primary" onClick={onClose}>
                        Confirm
                    </Button>
                </div>
            </div>
        </div>
    );
}

// --- Main Feature Component (Demonstrating Derived State & Concurrent Transitions) ---

export function ProductCatalogDemo() {
    const [searchQuery, setSearchQuery] = useState('');
    const [selectedCategory, setSelectedCategory] = useState('all');
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [isPending, startTransition] = useTransition();

    // Static sample data set
    const products = [
        { id: 'p1', name: 'High-Performance Laptop', category: 'electronics', price: 1299 },
        { id: 'p2', name: 'Wireless Ergonomic Mouse', category: 'electronics', price: 79 },
        { id: 'p3', name: 'Mechanical Keyboard', category: 'electronics', price: 149 },
        { id: 'p4', name: 'Adjustable Standing Desk', category: 'furniture', price: 499 },
        { id: 'p5', name: 'Ergonomic Mesh Chair', category: 'furniture', price: 349 },
    ];

    // ✅ PRINCIPLE 1: Derived State calculated purely during render (Zero redundant useEffect)
    const filteredProducts = products.filter((item) => {
        const matchesCategory = selectedCategory === 'all' || item.category === selectedCategory;
        const matchesSearch = item.name.toLowerCase().includes(searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
    });

    const totalValue = filteredProducts.reduce((sum, item) => sum + item.price, 0);

    return (
        <main className="mx-auto max-w-4xl p-6 sm:p-8 font-sans">
            <header className="mb-8 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                <div>
                    <h1 className="text-2xl font-bold tracking-tight text-slate-900 sm:text-3xl">
                        Product Catalog
                    </h1>
                    <p className="text-sm text-slate-500 mt-1">
                        Showing {filteredProducts.length} items (Total: ${totalValue.toLocaleString()})
                    </p>
                </div>
                <Button onClick={() => setIsModalOpen(true)}>Add New Product</Button>
            </header>

            {/* Filter Controls */}
            <section className="mb-6 flex flex-col gap-3 sm:flex-row sm:items-center">
                <input
                    type="search"
                    placeholder="Search products..."
                    value={searchQuery}
                    onChange={(e) => {
                        startTransition(() => {
                            setSearchQuery(e.target.value);
                        });
                    }}
                    className="w-full sm:w-72 rounded-lg border border-slate-300 px-3.5 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                />

                <div className="flex gap-2">
                    {['all', 'electronics', 'furniture'].map((cat) => (
                        <button
                            key={cat}
                            onClick={() => setSelectedCategory(cat)}
                            className={cn(
                                'rounded-lg px-3 py-1.5 text-xs font-medium capitalize transition-colors',
                                selectedCategory === cat
                                    ? 'bg-slate-900 text-white'
                                    : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                            )}
                        >
                            {cat}
                        </button>
                    ))}
                </div>
            </section>

            {/* Product Grid */}
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
                {filteredProducts.map((product) => (
                    <article
                        key={product.id}
                        className="flex flex-col justify-between rounded-xl border border-slate-200 bg-white p-5 shadow-sm hover:shadow-md transition-shadow"
                    >
                        <div>
                            <span className="inline-block rounded-md bg-blue-50 px-2 py-1 text-xs font-medium text-blue-700 capitalize mb-2">
                                {product.category}
                            </span>
                            <h3 className="font-semibold text-slate-900">{product.name}</h3>
                        </div>
                        <div className="mt-4 flex items-center justify-between">
                            <span className="text-lg font-bold text-slate-900">${product.price}</span>
                            <Button size="sm" variant="outline">
                                View
                            </Button>
                        </div>
                    </article>
                ))}
            </div>

            {/* Fully Accessible Modal Dialog */}
            <AccessibleModal
                isOpen={isModalOpen}
                onClose={() => setIsModalOpen(false)}
                title="Add New Product"
            >
                <p>This modal traps keyboard focus, closes on Escape, and restores focus to the trigger on close.</p>
            </AccessibleModal>
        </main>
    );
}

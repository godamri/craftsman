/**
 * Class Name Combiner (cn)
 * Combines clsx conditional handling with tailwind-merge conflict resolution.
 * Prevents Tailwind utility conflicts when extending reusable components.
 */
import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs) {
    return twMerge(clsx(inputs));
}

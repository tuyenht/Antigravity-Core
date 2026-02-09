# Tailwind CSS Expert

> **Version:** 2.0.0 | **Updated:** 2026-02-01  
> **Tailwind:** v4.x (CSS-first) + v3.x compatibility  
> **Priority:** P0 - Load for Tailwind projects

---

You are an expert in Tailwind CSS utility-first styling.

## Core Principles

- Utility-first workflow
- Design directly in markup
- Consistency via configuration
- Mobile-first responsive design

---

## 1) Tailwind v4 (CSS-First Configuration)

### New CSS-Based Config
```css
/* ==========================================
   app.css - Tailwind v4 CSS-First Config
   ========================================== */

@import "tailwindcss";

/* ==========================================
   THEME CONFIGURATION (CSS Variables)
   ========================================== */

@theme {
  /* Colors */
  --color-primary-50: oklch(0.97 0.02 250);
  --color-primary-100: oklch(0.93 0.04 250);
  --color-primary-200: oklch(0.86 0.08 250);
  --color-primary-300: oklch(0.76 0.12 250);
  --color-primary-400: oklch(0.64 0.16 250);
  --color-primary-500: oklch(0.53 0.20 250);
  --color-primary-600: oklch(0.45 0.18 250);
  --color-primary-700: oklch(0.38 0.15 250);
  --color-primary-800: oklch(0.31 0.12 250);
  --color-primary-900: oklch(0.25 0.09 250);
  --color-primary-950: oklch(0.18 0.06 250);
  
  /* Semantic Colors */
  --color-success: oklch(0.65 0.20 145);
  --color-warning: oklch(0.75 0.18 85);
  --color-error: oklch(0.55 0.22 25);
  --color-info: oklch(0.60 0.15 230);
  
  /* Background & Foreground */
  --color-background: oklch(0.99 0 0);
  --color-foreground: oklch(0.15 0 0);
  --color-muted: oklch(0.95 0 0);
  --color-muted-foreground: oklch(0.45 0 0);
  
  /* Border & Ring */
  --color-border: oklch(0.90 0 0);
  --color-ring: var(--color-primary-500);
  
  /* Spacing */
  --spacing-xs: 0.25rem;
  --spacing-sm: 0.5rem;
  --spacing-md: 1rem;
  --spacing-lg: 1.5rem;
  --spacing-xl: 2rem;
  --spacing-2xl: 3rem;
  --spacing-3xl: 4rem;
  
  /* Border Radius */
  --radius-sm: 0.25rem;
  --radius-md: 0.375rem;
  --radius-lg: 0.5rem;
  --radius-xl: 0.75rem;
  --radius-2xl: 1rem;
  --radius-full: 9999px;
  
  /* Shadows */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
  --shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);
  
  /* Typography */
  --font-sans: ui-sans-serif, system-ui, sans-serif;
  --font-mono: ui-monospace, SFMono-Regular, monospace;
  
  /* Animations */
  --animate-fade-in: fade-in 0.3s ease-out;
  --animate-slide-up: slide-up 0.3s ease-out;
  --animate-spin: spin 1s linear infinite;
}

/* Dark Mode Theme */
@theme dark {
  --color-background: oklch(0.15 0 0);
  --color-foreground: oklch(0.95 0 0);
  --color-muted: oklch(0.20 0 0);
  --color-muted-foreground: oklch(0.65 0 0);
  --color-border: oklch(0.25 0 0);
}

/* Keyframes */
@keyframes fade-in {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes slide-up {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes spin {
  to { transform: rotate(360deg); }
}


/* ==========================================
   CUSTOM UTILITIES
   ========================================== */

@utility container-narrow {
  max-width: 768px;
  margin-inline: auto;
  padding-inline: 1rem;
}

@utility text-balance {
  text-wrap: balance;
}

@utility animate-in {
  animation: var(--animate-fade-in);
}


/* ==========================================
   COMPONENT STYLES (Sparingly!)
   ========================================== */

@layer components {
  .btn {
    @apply inline-flex items-center justify-center gap-2;
    @apply rounded-lg px-4 py-2 text-sm font-medium;
    @apply transition-colors duration-200;
    @apply focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2;
    @apply disabled:pointer-events-none disabled:opacity-50;
  }
  
  .btn-primary {
    @apply bg-primary-600 text-white;
    @apply hover:bg-primary-700;
  }
  
  .btn-secondary {
    @apply bg-muted text-foreground;
    @apply hover:bg-muted/80;
  }
  
  .btn-outline {
    @apply border border-border bg-transparent;
    @apply hover:bg-muted;
  }
  
  .input {
    @apply flex h-10 w-full rounded-lg border border-border bg-background px-3 py-2 text-sm;
    @apply placeholder:text-muted-foreground;
    @apply focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring;
    @apply disabled:cursor-not-allowed disabled:opacity-50;
  }
  
  .card {
    @apply rounded-xl border border-border bg-background p-6 shadow-md;
  }
}
```

---

## 2) Tailwind v3 Configuration

### Full Config
```javascript
// ==========================================
// tailwind.config.js (Tailwind v3)
// ==========================================

/** @type {import('tailwindcss').Config} */
module.exports = {
  // Content paths for tree-shaking
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx,vue,svelte,astro}",
    "./components/**/*.{js,ts,jsx,tsx}",
    "./app/**/*.{js,ts,jsx,tsx}",
  ],
  
  // Dark mode strategy
  darkMode: 'class', // or 'media'
  
  theme: {
    // Override defaults
    container: {
      center: true,
      padding: '1rem',
      screens: {
        '2xl': '1400px',
      },
    },
    
    // Extend defaults
    extend: {
      // Colors
      colors: {
        border: 'hsl(var(--border))',
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        muted: {
          DEFAULT: 'hsl(var(--muted))',
          foreground: 'hsl(var(--muted-foreground))',
        },
        primary: {
          DEFAULT: 'hsl(var(--primary))',
          foreground: 'hsl(var(--primary-foreground))',
          50: '#eff6ff',
          100: '#dbeafe',
          200: '#bfdbfe',
          300: '#93c5fd',
          400: '#60a5fa',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
          800: '#1e40af',
          900: '#1e3a8a',
          950: '#172554',
        },
        destructive: {
          DEFAULT: 'hsl(var(--destructive))',
          foreground: 'hsl(var(--destructive-foreground))',
        },
      },
      
      // Typography
      fontFamily: {
        sans: ['Inter', 'ui-sans-serif', 'system-ui'],
        mono: ['JetBrains Mono', 'ui-monospace'],
      },
      
      fontSize: {
        '2xs': ['0.625rem', { lineHeight: '0.75rem' }],
      },
      
      // Spacing
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
        '128': '32rem',
      },
      
      // Border Radius
      borderRadius: {
        lg: 'var(--radius)',
        md: 'calc(var(--radius) - 2px)',
        sm: 'calc(var(--radius) - 4px)',
      },
      
      // Shadows
      boxShadow: {
        'soft': '0 2px 15px -3px rgba(0, 0, 0, 0.07), 0 10px 20px -2px rgba(0, 0, 0, 0.04)',
        'glow': '0 0 20px rgba(59, 130, 246, 0.5)',
      },
      
      // Animations
      keyframes: {
        'fade-in': {
          from: { opacity: '0' },
          to: { opacity: '1' },
        },
        'fade-out': {
          from: { opacity: '1' },
          to: { opacity: '0' },
        },
        'slide-in-up': {
          from: { opacity: '0', transform: 'translateY(10px)' },
          to: { opacity: '1', transform: 'translateY(0)' },
        },
        'slide-in-down': {
          from: { opacity: '0', transform: 'translateY(-10px)' },
          to: { opacity: '1', transform: 'translateY(0)' },
        },
        'slide-in-left': {
          from: { opacity: '0', transform: 'translateX(-10px)' },
          to: { opacity: '1', transform: 'translateX(0)' },
        },
        'slide-in-right': {
          from: { opacity: '0', transform: 'translateX(10px)' },
          to: { opacity: '1', transform: 'translateX(0)' },
        },
        'scale-in': {
          from: { opacity: '0', transform: 'scale(0.95)' },
          to: { opacity: '1', transform: 'scale(1)' },
        },
        'accordion-down': {
          from: { height: '0' },
          to: { height: 'var(--radix-accordion-content-height)' },
        },
        'accordion-up': {
          from: { height: 'var(--radix-accordion-content-height)' },
          to: { height: '0' },
        },
      },
      animation: {
        'fade-in': 'fade-in 0.3s ease-out',
        'fade-out': 'fade-out 0.2s ease-in',
        'slide-in-up': 'slide-in-up 0.3s ease-out',
        'slide-in-down': 'slide-in-down 0.3s ease-out',
        'slide-in-left': 'slide-in-left 0.3s ease-out',
        'slide-in-right': 'slide-in-right 0.3s ease-out',
        'scale-in': 'scale-in 0.2s ease-out',
        'accordion-down': 'accordion-down 0.2s ease-out',
        'accordion-up': 'accordion-up 0.2s ease-out',
      },
    },
  },
  
  // Plugins
  plugins: [
    require('@tailwindcss/typography'),
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/container-queries'),
    require('tailwindcss-animate'),
  ],
};
```

---

## 3) Utility Patterns

### Responsive Design
```html
<!-- ==========================================
     RESPONSIVE - Mobile First
     ========================================== -->

<!-- Stack on mobile, grid on larger screens -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
  <div class="p-4">Card 1</div>
  <div class="p-4">Card 2</div>
  <div class="p-4">Card 3</div>
  <div class="p-4">Card 4</div>
</div>

<!-- Hide/show based on screen size -->
<nav class="hidden md:flex">Desktop Nav</nav>
<nav class="flex md:hidden">Mobile Nav</nav>

<!-- Responsive text -->
<h1 class="text-2xl md:text-4xl lg:text-5xl xl:text-6xl font-bold">
  Responsive Heading
</h1>

<!-- Responsive spacing -->
<section class="px-4 md:px-8 lg:px-16 py-8 md:py-12 lg:py-20">
  Content with responsive padding
</section>

<!-- Breakpoints:
  sm: 640px   -> @media (min-width: 640px)
  md: 768px   -> @media (min-width: 768px)
  lg: 1024px  -> @media (min-width: 1024px)
  xl: 1280px  -> @media (min-width: 1280px)
  2xl: 1536px -> @media (min-width: 1536px)
-->
```

### State Variants
```html
<!-- ==========================================
     STATE VARIANTS
     ========================================== -->

<!-- Hover & Focus -->
<button class="
  bg-primary-600 text-white
  hover:bg-primary-700
  focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2
  active:bg-primary-800
  disabled:opacity-50 disabled:cursor-not-allowed
">
  Interactive Button
</button>

<!-- Group hover -->
<a href="#" class="group flex items-center gap-2">
  <span class="group-hover:underline">Link Text</span>
  <svg class="w-4 h-4 transition-transform group-hover:translate-x-1">
    <!-- Arrow icon -->
  </svg>
</a>

<!-- Peer states (form validation) -->
<div class="relative">
  <input 
    type="email" 
    class="peer w-full border rounded px-3 py-2 
           focus:border-primary-500
           invalid:border-red-500"
    placeholder=" "
    required
  />
  <label class="
    absolute left-3 top-2 text-gray-500
    peer-focus:-translate-y-4 peer-focus:scale-75 peer-focus:text-primary-600
    peer-[:not(:placeholder-shown)]:-translate-y-4 peer-[:not(:placeholder-shown)]:scale-75
    transition-all
  ">
    Email
  </label>
  <p class="hidden peer-invalid:block text-red-500 text-sm mt-1">
    Please enter a valid email
  </p>
</div>

<!-- First/Last child -->
<ul class="divide-y">
  <li class="py-3 first:pt-0 last:pb-0">Item 1</li>
  <li class="py-3 first:pt-0 last:pb-0">Item 2</li>
  <li class="py-3 first:pt-0 last:pb-0">Item 3</li>
</ul>

<!-- Odd/Even -->
<table>
  <tbody>
    <tr class="odd:bg-gray-50 even:bg-white hover:bg-gray-100">
      <td>Row 1</td>
    </tr>
  </tbody>
</table>
```

### Dark Mode
```html
<!-- ==========================================
     DARK MODE
     ========================================== -->

<!-- Dark mode classes -->
<div class="bg-white dark:bg-gray-900">
  <h1 class="text-gray-900 dark:text-white">
    Dark Mode Heading
  </h1>
  <p class="text-gray-600 dark:text-gray-300">
    This text adapts to dark mode
  </p>
  <button class="
    bg-primary-600 text-white
    dark:bg-primary-500 dark:hover:bg-primary-400
  ">
    Dark Mode Button
  </button>
</div>

<!-- Dark mode toggle (with 'class' strategy) -->
<script>
  // Check preference
  if (localStorage.theme === 'dark' || 
      (!('theme' in localStorage) && 
       window.matchMedia('(prefers-color-scheme: dark)').matches)) {
    document.documentElement.classList.add('dark');
  } else {
    document.documentElement.classList.remove('dark');
  }
  
  // Toggle function
  function toggleDarkMode() {
    document.documentElement.classList.toggle('dark');
    localStorage.theme = document.documentElement.classList.contains('dark') 
      ? 'dark' 
      : 'light';
  }
</script>
```

### Arbitrary Values
```html
<!-- ==========================================
     ARBITRARY VALUES - [value]
     ========================================== -->

<!-- Custom widths -->
<div class="w-[32rem]">32rem width</div>
<div class="w-[calc(100%-2rem)]">Calc width</div>
<div class="max-w-[65ch]">65 character width</div>

<!-- Custom colors -->
<div class="bg-[#1a2b3c]">Hex color</div>
<div class="bg-[rgb(255,100,50)]">RGB color</div>
<div class="bg-[oklch(0.7_0.15_200)]">OKLCH color</div>

<!-- Custom spacing -->
<div class="mt-[17px]">17px margin</div>
<div class="p-[clamp(1rem,5vw,3rem)]">Clamp padding</div>

<!-- Custom grid -->
<div class="grid grid-cols-[200px_1fr_200px]">
  <aside>Left Sidebar</aside>
  <main>Content</main>
  <aside>Right Sidebar</aside>
</div>

<!-- Custom animations -->
<div class="animate-[wiggle_1s_ease-in-out_infinite]">
  Wiggling
</div>

<!-- CSS variables -->
<div class="bg-[var(--brand-color)]">CSS Variable</div>

<!-- Arbitrary properties -->
<div class="[mask-type:luminance]">Custom property</div>
<div class="[--my-var:10px] mt-[var(--my-var)]">Scoped variable</div>
```

---

## 4) Component Patterns

### Button Variants
```tsx
// ==========================================
// Button Component with Tailwind
// ==========================================

import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const buttonVariants = cva(
  // Base styles
  `inline-flex items-center justify-center gap-2 
   rounded-lg font-medium transition-colors
   focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2
   disabled:pointer-events-none disabled:opacity-50`,
  {
    variants: {
      variant: {
        default: 'bg-primary-600 text-white hover:bg-primary-700',
        secondary: 'bg-gray-100 text-gray-900 hover:bg-gray-200',
        destructive: 'bg-red-600 text-white hover:bg-red-700',
        outline: 'border border-gray-300 bg-transparent hover:bg-gray-100',
        ghost: 'hover:bg-gray-100',
        link: 'text-primary-600 underline-offset-4 hover:underline',
      },
      size: {
        sm: 'h-8 px-3 text-xs',
        md: 'h-10 px-4 text-sm',
        lg: 'h-12 px-6 text-base',
        icon: 'h-10 w-10',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'md',
    },
  }
);

interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  isLoading?: boolean;
}

export function Button({
  className,
  variant,
  size,
  isLoading,
  children,
  ...props
}: ButtonProps) {
  return (
    <button
      className={cn(buttonVariants({ variant, size }), className)}
      disabled={isLoading || props.disabled}
      {...props}
    >
      {isLoading && (
        <svg className="h-4 w-4 animate-spin" viewBox="0 0 24 24">
          <circle
            className="opacity-25"
            cx="12"
            cy="12"
            r="10"
            stroke="currentColor"
            strokeWidth="4"
          />
          <path
            className="opacity-75"
            fill="currentColor"
            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
          />
        </svg>
      )}
      {children}
    </button>
  );
}

// Usage
<Button variant="default" size="lg">Primary</Button>
<Button variant="outline" size="sm">Outline</Button>
<Button variant="destructive" isLoading>Deleting...</Button>
```

### Card Component
```tsx
// ==========================================
// Card Component
// ==========================================

import { cn } from '@/lib/utils';

interface CardProps extends React.HTMLAttributes<HTMLDivElement> {}

export function Card({ className, ...props }: CardProps) {
  return (
    <div
      className={cn(
        'rounded-xl border border-gray-200 bg-white shadow-sm',
        'dark:border-gray-800 dark:bg-gray-950',
        className
      )}
      {...props}
    />
  );
}

export function CardHeader({ className, ...props }: CardProps) {
  return (
    <div
      className={cn('flex flex-col space-y-1.5 p-6', className)}
      {...props}
    />
  );
}

export function CardTitle({
  className,
  ...props
}: React.HTMLAttributes<HTMLHeadingElement>) {
  return (
    <h3
      className={cn(
        'text-2xl font-semibold leading-none tracking-tight',
        className
      )}
      {...props}
    />
  );
}

export function CardDescription({
  className,
  ...props
}: React.HTMLAttributes<HTMLParagraphElement>) {
  return (
    <p
      className={cn('text-sm text-gray-500 dark:text-gray-400', className)}
      {...props}
    />
  );
}

export function CardContent({ className, ...props }: CardProps) {
  return <div className={cn('p-6 pt-0', className)} {...props} />;
}

export function CardFooter({ className, ...props }: CardProps) {
  return (
    <div
      className={cn('flex items-center p-6 pt-0', className)}
      {...props}
    />
  );
}

// Usage
<Card>
  <CardHeader>
    <CardTitle>Card Title</CardTitle>
    <CardDescription>Card description goes here.</CardDescription>
  </CardHeader>
  <CardContent>
    <p>Card content...</p>
  </CardContent>
  <CardFooter>
    <Button>Action</Button>
  </CardFooter>
</Card>
```

---

## 5) Dynamic Classes

### Using clsx & tailwind-merge
```tsx
// ==========================================
// lib/utils.ts
// ==========================================

import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

/**
 * Merge Tailwind classes with clsx
 * Handles conflicts intelligently
 */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}


// ==========================================
// Usage Examples
// ==========================================

// Conditional classes
function Component({ isActive, isDisabled, className }) {
  return (
    <div
      className={cn(
        // Base classes
        'flex items-center gap-2 rounded-lg p-4',
        // Conditional classes
        isActive && 'bg-primary-100 border-primary-500',
        isDisabled && 'opacity-50 cursor-not-allowed',
        // Override with prop
        className
      )}
    >
      Content
    </div>
  );
}


// Object syntax
function Badge({ variant }) {
  return (
    <span
      className={cn('px-2 py-1 rounded-full text-xs font-medium', {
        'bg-green-100 text-green-800': variant === 'success',
        'bg-yellow-100 text-yellow-800': variant === 'warning',
        'bg-red-100 text-red-800': variant === 'error',
        'bg-blue-100 text-blue-800': variant === 'info',
      })}
    >
      {variant}
    </span>
  );
}


// Merging conflicting classes
// twMerge handles conflicts intelligently
cn('px-4 py-2', 'px-6');      // -> 'py-2 px-6' (px-6 wins)
cn('bg-red-500', 'bg-blue-500'); // -> 'bg-blue-500' (last wins)
cn('text-sm', 'text-lg');     // -> 'text-lg' (last wins)


// Complex conditional logic
function Alert({ type, size, dismissible }) {
  const baseClasses = 'rounded-lg p-4 flex items-start gap-3';
  
  const typeClasses = {
    info: 'bg-blue-50 text-blue-800 border border-blue-200',
    success: 'bg-green-50 text-green-800 border border-green-200',
    warning: 'bg-yellow-50 text-yellow-800 border border-yellow-200',
    error: 'bg-red-50 text-red-800 border border-red-200',
  };
  
  const sizeClasses = {
    sm: 'text-sm p-3',
    md: 'text-base p-4',
    lg: 'text-lg p-5',
  };
  
  return (
    <div
      className={cn(
        baseClasses,
        typeClasses[type],
        sizeClasses[size],
        dismissible && 'pr-10'
      )}
    >
      {/* Alert content */}
    </div>
  );
}
```

---

## 6) Typography Plugin

### Prose Styling
```html
<!-- ==========================================
     @tailwindcss/typography - Prose
     ========================================== -->

<!-- Basic prose -->
<article class="prose lg:prose-xl">
  <h1>Heading 1</h1>
  <p>Paragraph with <a href="#">link</a> and <strong>bold</strong> text.</p>
  
  <h2>Heading 2</h2>
  <ul>
    <li>List item 1</li>
    <li>List item 2</li>
  </ul>
  
  <blockquote>
    This is a blockquote with styled text.
  </blockquote>
  
  <pre><code>const code = 'highlighted';</code></pre>
</article>

<!-- Dark mode prose -->
<article class="prose dark:prose-invert">
  <!-- Content adapts to dark mode -->
</article>

<!-- Prose variants -->
<article class="
  prose 
  prose-stone        /* Gray theme */
  prose-headings:text-primary-600
  prose-a:text-primary-600
  prose-a:no-underline 
  prose-a:hover:underline
  prose-img:rounded-xl
  prose-pre:bg-gray-900
">
  <!-- Customized prose -->
</article>

<!-- Max width variants -->
<article class="prose prose-sm">Small</article>
<article class="prose prose-base">Base (default)</article>
<article class="prose prose-lg">Large</article>
<article class="prose prose-xl">Extra Large</article>
<article class="prose prose-2xl">2XL</article>
```

---

## 7) Container Queries

### Container Query Patterns
```html
<!-- ==========================================
     @tailwindcss/container-queries
     ========================================== -->

<!-- Define container -->
<div class="@container">
  <!-- Responsive based on container, not viewport -->
  <div class="@lg:flex @lg:gap-4">
    <div class="@lg:w-1/3">Sidebar</div>
    <div class="@lg:w-2/3">Content</div>
  </div>
</div>

<!-- Named container -->
<div class="@container/card">
  <div class="@md/card:grid @md/card:grid-cols-2">
    <img src="..." class="@md/card:rounded-l-xl" />
    <div class="p-4">
      <h3 class="@sm/card:text-xl @md/card:text-2xl">
        Card Title
      </h3>
    </div>
  </div>
</div>

<!-- Container breakpoints:
  @xs  -> @container (min-width: 20rem)   320px
  @sm  -> @container (min-width: 24rem)   384px
  @md  -> @container (min-width: 28rem)   448px
  @lg  -> @container (min-width: 32rem)   512px
  @xl  -> @container (min-width: 36rem)   576px
  @2xl -> @container (min-width: 42rem)   672px
-->
```

---

## 8) Best Practices

### Do's and Don'ts
```html
<!-- ==========================================
     BEST PRACTICES
     ========================================== -->

<!-- ❌ DON'T: Use @apply just for "cleaner" markup -->
<style>
  /* Don't do this */
  .my-button {
    @apply px-4 py-2 bg-blue-500 text-white rounded;
  }
</style>

<!-- ✅ DO: Keep utilities in markup, extract to components -->
<Button className="px-4 py-2 bg-blue-500 text-white rounded">
  Click me
</Button>


<!-- ❌ DON'T: Fight the framework -->
<div class="w-[327.5px]">Oddly specific width</div>

<!-- ✅ DO: Use the spacing scale or extend config -->
<div class="w-80 sm:w-96">Use design tokens</div>


<!-- ❌ DON'T: Long class strings in one line -->
<div class="flex items-center justify-between p-4 bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow duration-200 border border-gray-200">

<!-- ✅ DO: Format multi-line for readability -->
<div 
  class="
    flex items-center justify-between
    p-4 bg-white rounded-lg
    shadow-md hover:shadow-lg
    transition-shadow duration-200
    border border-gray-200
  "
>


<!-- ✅ DO: Use Prettier plugin for consistent ordering -->
<!-- Add to .prettierrc:
  {
    "plugins": ["prettier-plugin-tailwindcss"]
  }
-->
```

### Performance Checklist
```
┌─────────────────────────────────────────┐
│      TAILWIND PERFORMANCE CHECKLIST     │
├─────────────────────────────────────────┤
│                                         │
│  BUILD:                                 │
│  □ Content paths configured correctly  │
│  □ Unused styles purged in production │
│  □ CSS minified                        │
│                                         │
│  ORGANIZATION:                          │
│  □ Use cn() for dynamic classes        │
│  □ Extract components, not CSS         │
│  □ Extend theme, don't fight it        │
│                                         │
│  CONSISTENCY:                           │
│  □ Use Prettier plugin                 │
│  □ Follow spacing scale                │
│  □ Use color palette                   │
│                                         │
│  ACCESSIBILITY:                         │
│  □ Focus states defined                │
│  □ Color contrast adequate             │
│  □ Touch targets sufficient            │
│                                         │
└─────────────────────────────────────────┘
```

---

## Best Practices Summary

### Configuration
- [ ] Set up content paths
- [ ] Extend theme properly
- [ ] Use CSS variables for theming
- [ ] Configure dark mode

### Development
- [ ] Use cn() for dynamic classes
- [ ] Extract components, not CSS
- [ ] Use Prettier plugin
- [ ] Follow mobile-first

### Performance
- [ ] Purge unused styles
- [ ] Minify production CSS
- [ ] Use JIT compilation
- [ ] Minimize arbitrary values

---

**References:**
- [Tailwind CSS v4 Docs](https://tailwindcss.com/docs)
- [Tailwind CSS v3 Docs](https://v3.tailwindcss.com/docs)
- [Tailwind Plugins](https://tailwindcss.com/docs/plugins)
- [shadcn/ui](https://ui.shadcn.com/)

---
technology: Inertia.js + React
version: Inertia 2.x + React 19
last_updated: 2026-01-16
official_docs: https://inertiajs.com
---

# Inertia.js + React + TypeScript - Best Practices

**Stack:** Inertia.js + React + TypeScript  
**Updated:** 2026-01-16  
**Source:** Official Inertia.js docs + React best practices

---

## Core Concepts

### What is Inertia.js?
- Build SPAs using classic server-side routing
- No need for API layer between Laravel and React
- Server-side rendering (SSR) optional
- Seamless transitions without full page reloads

---

## Page Components

### TypeScript Page Props

```typescript
// resources/js/types/index.d.ts
export interface User {
    id: number;
    name: string;
    email: string;
}

export interface Post {
    id: number;
    title: string;
    content: string;
    author: User;
}

// Page props interface
export interface PostsPageProps {
    posts: Post[];
    filters: {
        search?: string;
        category?: string;
    };
}
```

### Type-Safe Page Component

```typescript
// resources/js/Pages/Posts/Index.tsx
import { Head } from '@inertiajs/react';
import type { PostsPageProps } from '@/types';

export default function Posts({ posts, filters }: PostsPageProps) {
    return (
        <>
            <Head title="Posts" />
            <div>
                {posts.map(post => (
                    <article key={post.id}>
                        <h2>{post.title}</h2>
                        <p>By {post.author.name}</p>
                    </article>
                ))}
            </div>
        </>
    );
}
```

---

## Layouts & Shared Components

### Persistent Layout

```typescript
// resources/js/Layouts/AppLayout.tsx
import { PropsWithChildren } from 'react';

export default function AppLayout({ children }: PropsWithChildren) {
    return (
        <div>
            <nav>{/* Navigation */}</nav>
            <main>{children}</main>
            <footer>{/* Footer */}</footer>
        </div>
    );
}

// Use in page
import AppLayout from '@/Layouts/AppLayout';

Posts.layout = (page: React.ReactElement) => (
    <AppLayout>{page}</AppLayout>
);
```

---

## Forms with useForm Hook

### Basic Form

```typescript
import { useForm } from '@inertiajs/react';

interface PostFormData {
    title: string;
    content: string;
    category_id: number;
}

export default function CreatePost() {
    const { data, setData, post, processing, errors, reset } = 
        useForm<PostFormData>({
            title: '',
            content: '',
            category_id: 0,
        });

    function submit(e: React.FormEvent) {
        e.preventDefault();
        post('/posts', {
            onSuccess: () => reset(),
        });
    }

    return (
        <form onSubmit={submit}>
            <input
                type="text"
                value={data.title}
                onChange={e => setData('title', e.target.value)}
            />
            {errors.title && <span>{errors.title}</span>}
            
            <textarea
                value={data.content}
                onChange={e => setData('content', e.target.value)}
            />
            {errors.content && <span>{errors.content}</span>}
            
            <button type="submit" disabled={processing}>
                {processing ? 'Saving...' : 'Save Post'}
            </button>
        </form>
    );
}
```

### File Uploads

```typescript
const { data, setData, post } = useForm({
    title: '',
    image: null as File | null,
});

<input
    type="file"
    onChange={e => setData('image', e.target.files?.[0] || null)}
/>

// Submit (auto-converts to FormData)
post('/posts');
```

---

## Navigation

### Inertia Link Component

```typescript
import { Link } from '@inertiajs/react';

// Basic link
<Link href="/posts">View Posts</Link>

// Preserve scroll
<Link href="/posts" preserveScroll>Next Page</Link>

// Only replace specific data
<Link 
    href="/posts"
    only={['posts']}  // Only reload posts data
>
    Filter
</Link>

// Method override
<Link href="/posts/1" method="delete" as="button">
    Delete
</Link>
```

### Programmatic Navigation

```typescript
import { router } from '@inertiajs/react';

// Navigate
router.visit('/posts');

// With options
router.visit('/posts', {
    method: 'post',
    data: { title: 'New Post' },
    preserveScroll: true,
    onSuccess: () => console.log('Success'),
});

// Reload current page
router.reload({ only: ['posts'] });
```

---

## Shared Data

### Global Props (Available on All Pages)

```php
// Laravel - app/Http/Middleware/HandleInertiaRequests.php
public function share(Request $request): array
{
    return array_merge(parent::share($request), [
        'auth' => [
            'user' => $request->user(),
        ],
        'flash' => [
            'message' => fn () => $request->session()->get('message'),
        ],
        'ziggy' => fn () => [
            ...(new Ziggy)->toArray(),
            'location' => $request->url(),
        ],
    ]);
}
```

```typescript
// React - Access shared data
import { usePage } from '@inertiajs/react';

interface SharedProps {
    auth: {
        user: User | null;
    };
    flash: {
        message?: string;
    };
}

export default function MyComponent() {
    const { auth, flash } = usePage<SharedProps>().props;
    
    return (
        <div>
            {flash.message && <div>{flash.message}</div>}
            {auth.user ? `Hello ${auth.user.name}` : 'Guest'}
        </div>
    );
}
```

---

## Modal Dialogs

### Modal with State Preservation

```typescript
import { useState } from 'react';
import { router } from '@inertiajs/react';

export default function Posts({ posts }: PostsPageProps) {
    const [showModal, setShowModal] = useState(false);
    const [selectedPost, setSelectedPost] = useState<Post | null>(null);

    function deletePost(id: number) {
        router.delete(`/posts/${id}`, {
            preserveScroll: true,
            onSuccess: () => setShowModal(false),
        });
    }

    return (
        <div>
            {/* Modal stays open during navigation */}
            {showModal && (
                <Modal onClose={() => setShowModal(false)}>
                    <h3>Delete {selectedPost?.title}?</h3>
                    <button onClick={() => deletePost(selectedPost!.id)}>
                        Confirm
                    </button>
                </Modal>
            )}
        </div>
    );
}
```

---

## Progress Indicators

```typescript
import { router } from '@inertiajs/react';
import { useEffect, useState } from 'react';

export default function ProgressBar() {
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        const start = () => setLoading(true);
        const finish = () => setLoading(false);

        router.on('start', start);
        router.on('finish', finish);

        return () => {
            router.off('start', start);
            router.off('finish', finish);
        };
    }, []);

    if (!loading) return null;

    return (
        <div className="fixed top-0 left-0 right-0 h-1 bg-blue-500 animate-pulse" />
    );
}
```

---

## Performance Optimization

### Partial Reloads

```typescript
// Only reload specific props
<Link href="/posts" only={['posts', 'filters']}>
    Refresh Posts
</Link>

// Programmatic
router.reload({ only: ['posts'] });
```

### Lazy Loading

```typescript
const HeavyComponent = lazy(() => import('@/Components/HeavyComponent'));

<Suspense fallback={<div>Loading...</div>}>
    <HeavyComponent />
</Suspense>
```

### Debounced Search

```typescript
import { useMemo } from 'react';
import { router } from '@inertiajs/react';
import debounce from 'lodash/debounce';

export default function SearchBar() {
    const handleSearch = useMemo(
        () => debounce((query: string) => {
            router.get('/posts', { search: query }, {
                preserveState: true,
                only: ['posts'],
            });
        }, 300),
        []
    );

    return (
        <input
            type="search"
            onChange={e => handleSearch(e.target.value)}
        />
    );
}
```

---

## Real-Time Updates (with Laravel Echo)

```typescript
import Echo from 'laravel-echo';
import { router } from '@inertiajs/react';

// Initialize Echo
const echo = new Echo({
    broadcaster: 'pusher',
    // ... config
});

// Listen for events
echo.channel('posts')
    .listen('PostCreated', () => {
        router.reload({ only: ['posts'] });
    });
```

---

## Common Patterns

### Pagination

```typescript
interface PaginatedProps {
    posts: {
        data: Post[];
        links: Array<{
            url: string | null;
            label: string;
            active: boolean;
        }>;
    };
}

export default function Posts({ posts }: PaginatedProps) {
    return (
        <div>
            {posts.data.map(post => <PostCard key={post.id} post={post} />)}
            
            <nav>
                {posts.links.map((link, index) => (
                    link.url ? (
                        <Link
                            key={index}
                            href={link.url}
                            className={link.active ? 'active' : ''}
                            preserveScroll
                        >
                            {link.label}
                        </Link>
                    ) : (
                        <span key={index}>{link.label}</span>
                    )
                ))}
            </nav>
        </div>
    );
}
```

---

## Anti-Patterns to Avoid

❌ **Using axios/fetch instead of Inertia's router**  
❌ **Building separate API for Inertia pages**  
❌ **Not typing page props**  
❌ **Full page reloads instead of partial**  
❌ **Ignoring preserveScroll**  
❌ **Not handling form errors**

---

## TypeScript Tips

### Extend InertiaJS Types

```typescript
// resources/js/types/inertia.d.ts
import { PageProps as InertiaPageProps } from '@inertiajs/core';

declare module '@inertiajs/core' {
    interface PageProps extends InertiaPageProps {
        auth: {
            user: User | null;
        };
        flash: {
            message?: string;
        };
    }
}
```

---

---

## Performance Optimization

### React 19 Compiler (Automatic Memoization!)

**Enables automatic memoization without manual useMemo/useCallback:**

```bash
# Install React 19 compiler
npm install react@19 react-dom@19
npm install -D babel-plugin-react-compiler
```

**Vite Configuration:**
```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [
    react({
      babel: {
        plugins: [
          ['babel-plugin-react-compiler', {
            // Compiler options
            runtimeModule: 'react-compiler-runtime',
          }],
        ],
      },
    }),
  ],
});
```

**Benefits:**
- Automatic optimization of components
- No manual memoization needed
- Better performance by default

---

### Code Splitting with Vite

```typescript
// ✅ Route-based code splitting
const Dashboard = lazy(() => import('./Pages/Dashboard'));
const Profile = lazy(() => import('./Pages/Profile'));

// ✅ Component-based splitting
const HeavyChart = lazy(() => import('./Components/HeavyChart'));

// Use with Suspense
<Suspense fallback={<Loading />}>
  <HeavyChart data={data} />
</Suspense>
```

---

### Bundle Size Optimization

**Analyze Bundle:**
```bash
# Install analyzer
npm install -D rollup-plugin-visualizer

# Add to vite.config.ts
import { visualizer } from 'rollup-plugin-visualizer';

export default defineConfig({
  plugins: [
    react(),
    visualizer({
      open: true,
      gzipSize: true,
      brotliSize: true,
    }),
  ],
});

# Build and analyze
npm run build
```

**Optimization Strategies:**
```typescript
// ✅ Import only what you need
import { debounce } from 'lodash-es';  // Good
import _ from 'lodash';  // ❌ Imports entire library

// ✅ Use dynamic imports for heavy libraries
const Chart = lazy(() => import('chart.js'));

// ✅ Tree shaking - export/import named exports
export { Button, Input };  // ✅ Tree-shakeable
export default { Button, Input };  // ❌ Not tree-shakeable
```

---

### Suspense Boundaries

```typescript
// ✅ Strategic Suspense placement
export default function Dashboard() {
  return (
    <div>
      <Header />  {/* Render immediately */}
      
      <Suspense fallback={<ChartSkeleton />}>
        <HeavyChart />  {/* Lazy loaded */}
      </Suspense>
      
      <Suspense fallback={<TableSkeleton />}>
        <DataTable />  {/* Lazy loaded */}
      </Suspense>
    </div>
  );
}

// ✅ Nested Suspense for granular loading
<Suspense fallback={<PageSkeleton />}>
  <MainContent>
    <Suspense fallback={<WidgetSkeleton />}>
      <ExpensiveWidget />
    </Suspense>
  </MainContent>
</Suspense>
```

---

### Vite Build Optimization

```typescript
// vite.config.ts
export default defineConfig({
  build: {
    target: 'es2015',
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,  // Remove console.log in production
        drop_debugger: true,
      },
    },
    rollupOptions: {
      output: {
        manualChunks: {
          // Split vendor chunks
          'react-vendor': ['react', 'react-dom'],
          'inertia': ['@inertiajs/react'],
          'ui': ['@headlessui/react', '@heroicons/react'],
        },
      },
    },
    chunkSizeWarningLimit: 1000,
  },
});
```

---

### Image Optimization

```typescript
// ✅ Lazy load images
<img 
  src={imageSrc} 
  loading="lazy"  // Native lazy loading
  alt="Description"
/>

// ✅ Use modern formats (WebP, AVIF)
<picture>
  <source srcSet="image.avif" type="image/avif" />
  <source srcSet="image.webp" type="image/webp" />
  <img src="image.jpg" alt="Fallback" />
</picture>

// ✅ Specify dimensions to prevent layout shift
<img 
  src={src} 
  width="400" 
  height="300"
  alt="Description"
/>
```

---

## Anti-Patterns to Avoid

❌ **No code splitting** → Split routes and heavy components  
❌ **Large bundle sizes** → Analyze and optimize  
❌ **Unnecessary re-renders** → Use React 19 compiler or memoization  
❌ **Blocking main thread** → Use Web Workers for heavy computations  
❌ **Not using Suspense** → Improves perceived performance

---

## Best Practices

✅ **React 19 compiler** for automatic optimization  
✅ **Code splitting** for routes and heavy components  
✅ **Bundle analysis** to identify bloat  
✅ **Suspense boundaries** for better UX  
✅ **Lazy loading** for images and components  
✅ **Tree shaking** by using named imports  
✅ **Manual chunks** for vendor separation

---

**References:**
- [Inertia.js Official Docs](https://inertiajs.com/)
- [Laravel React Starter Kit](https://github.com/laravel/react-starter-kit)

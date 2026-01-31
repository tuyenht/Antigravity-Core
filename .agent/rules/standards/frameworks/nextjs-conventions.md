# Next.js 16 Conventions (2026)

**Version:** Next.js 16.x (LTS - Released October 2025)  
**Last Updated:** 2026-01-17  
**Build Tool:** Turbopack (stable, default bundler)  
**React Version:** React 19.2+  
**Node.js Required:** 20.9+

---

## 🎯 Overview

Next.js 16 convention guidelines for building production-ready full-stack React applications with breakthrough performance and developer experience improvements.

**🚀 Major New Features in Next.js 16:**
- ✅ **Cache Components** - Instant navigation with granular caching control
- ✅ **Turbopack (stable & default)** - 2-5x faster builds, 10x faster Fast Refresh
- ✅ **React Compiler (stable)** - Automatic memoization without manual code
- ✅ **proxy.ts** - Replaces middleware.ts for clearer network boundaries
- ✅ **Next.js DevTools MCP** - AI-assisted debugging with Model Context Protocol
- ✅ **React 19.2 Integration** - View Transitions, useEffectEvent, \<Activity/\>
- ✅ **Layout Deduplication** - Downloads shared layouts only once
- ✅ **Incremental Prefetching** - Prefetches only uncached parts
- ✅ **Enhanced Caching APIs** - New updateTag(), refined revalidateTag()

**Existing Features (from 13-15):**
- ✅ App Router (stable)
- ✅ React Server Components (default)
- ✅ Server Actions (stable)
- ✅ Partial Prerendering (PPR)
- ✅ Parallel & Intercepting Routes

---

## 📁 Project Structure

```
app/
├── (auth)/              # Route group (no URL segment)
│   ├── login/
│   │   └── page.tsx
│   └── register/
│       └── page.tsx
├── (dashboard)/
│   ├── layout.tsx       # Dashboard layout
│   ├── page.tsx         # /dashboard
│   ├── settings/
│   │   └── page.tsx     # /dashboard/settings
│   └── @sidebar/        # Parallel route
│       └── page.tsx
├── api/
│   ├── users/
│   │   └── route.ts     # API route handler
│   └── auth/
│       └── [...nextauth]/
│           └── route.ts
├── layout.tsx           # Root layout
├── page.tsx             # Home page
├── not-found.tsx        # 404 page
├── error.tsx            # Error boundary
├── loading.tsx          # Loading UI
└── template.tsx         # Re-renders on navigation

lib/                     # Utilities & helpers
components/              # React components
  ├── ui/               # Reusable UI components
  └── features/         # Feature-specific components
```

---

## 🚀 App Router Patterns

### File Conventions

```typescript
// ✅ page.tsx - Route page
export default function HomePage() {
  return <h1>Home</h1>;
}

// ✅ layout.tsx - Shared layout
export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}

// ✅ loading.tsx - Loading UI (automatic Suspense)
export default function Loading() {
  return <div>Loading...</div>;
}

// ✅ error.tsx - Error boundary
'use client';

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={reset}>Try again</button>
    </div>
  );
}

// ✅ not-found.tsx - 404 page
export default function NotFound() {
  return <h2>404 - Page Not Found</h2>;
}
```

---

## 🔄 Server vs Client Components

### Server Components (Default)

```typescript
// ✅ Default - Server Component (no 'use client')
async function UserProfile({ userId }: { userId: string }) {
  // Direct database access
  const user = await db.user.findUnique({
    where: { id: userId },
  });

  return <div>{user.name}</div>;
}
```

**When to use Server Components:**
- ✅ Data fetching
- ✅ Accessing backend resources (database, files)
- ✅ Keeping sensitive info on server (API keys, tokens)
- ✅ Reducing client bundle size
- ✅ SEO-critical content

### Client Components

```typescript
// ✅ Client Component (requires 'use client')
'use client';

import { useState } from 'react';

export function Counter() {
  const [count, setCount] = useState(0);

  return (
    <button onClick={() => setCount(count + 1)}>
      Count: {count}
    </button>
  );
}
```

**When to use Client Components:**
- ✅ Interactivity (onClick, onChange, useState)
- ✅ useEffect, useReducer, custom hooks
- ✅ Browser APIs (localStorage, geolocation)
- ✅ React Context
- ✅ Event listeners

---

## 📊 Data Fetching

### Server-Side Fetch (Recommended)

```typescript
// ✅ Server Component - async/await
async function BlogPost({ params }: { params: { id: string } }) {
  const post = await fetch(`https://api.example.com/posts/${params.id}`, {
    // Cache options (Next.js 15)
    next: {
      revalidate: 3600, // ISR: revalidate every hour
      tags: ['posts'],   // Cache tags for revalidation
    },
  }).then((res) => res.json());

  return <article>{post.title}</article>;
}
```

### Caching Strategies

```typescript
// ✅ Static (default) - revalidate on-demand only
fetch('https://api.example.com/data');

// ✅ ISR - revalidate every 60 seconds
fetch('https://api.example.com/data', {
  next: { revalidate: 60 },
});

// ✅ Dynamic - no cache
fetch('https://api.example.com/data', {
  cache: 'no-store',
});

// ✅ Force cache
fetch('https://api.example.com/data', {
  cache: 'force-cache',
});
```

### Parallel Data Fetching

```typescript
// ✅ Parallel fetching
async function Dashboard() {
  const [user, posts, comments] = await Promise.all([
    fetchUser(),
    fetchPosts(),
    fetchComments(),
  ]);

  return (
    <div>
      <User data={user} />
      <Posts data={posts} />
      <Comments data={comments} />
    </div>
  );
}
```

---

## ⚡ Server Actions (Stable in Next.js 15)

```typescript
// ✅ Server Action in Server Component
async function createTodo(formData: FormData) {
  'use server'; // Server Action directive

  const title = formData.get('title') as string;

  await db.todo.create({
    data: { title },
  });

  revalidatePath('/todos');
}

export default function TodoForm() {
  return (
    <form action={createTodo}>
      <input name="title" required />
      <button type="submit">Add Todo</button>
    </form>
  );
}
```

### Server Actions in Client Components

```typescript
// actions.ts
'use server';

export async function updateUser(userId: string, data: FormData) {
  const name = data.get('name') as string;

  await db.user.update({
    where: { id: userId },
    data: { name },
  });

  revalidateTag('users');
}

// component.tsx
'use client';

import { updateUser } from './actions';

export function UserForm({ userId }: { userId: string }) {
  return (
    <form action={updateUser.bind(null, userId)}>
      <input name="name" />
      <button>Update</button>
    </form>
  );
}
```

---

## 🎨 Partial Prerendering (PPR) - **NEW in Next.js 15**

```typescript
// next.config.js
module.exports = {
  experimental: {
    ppr: true, // Enable Partial Prerendering
  },
};

// ✅ PPR: Static shell + dynamic content
import { Suspense } from 'react';

export default function Page() {
  return (
    <div>
      {/* Static content - prerendered */}
      <h1>Dashboard</h1>
      <nav>...</nav>

      {/* Dynamic content - streamed */}
      <Suspense fallback={<Skeleton />}>
        <DynamicUserData />
      </Suspense>

      <Suspense fallback={<Loading />}>
        <RecentActivity />
      </Suspense>
    </div>
  );
}
```

---

## 🖼️ Image Optimization

```typescript
import Image from 'next/image';

// ✅ Local images
import heroImg from '@/public/hero.jpg';

<Image
  src={heroImg}
  alt="Hero"
  placeholder="blur" // Automatic blur-up placeholder
  priority           // Load immediately (for LCP)
/>

// ✅ Remote images
<Image
  src="https://example.com/image.jpg"
  alt="Description"
  width={800}
  height={600}
  sizes="(max-width: 768px) 100vw, 50vw"
/>

// ✅ Fill container
<div style={{ position: 'relative', width: '100%', height: '400px' }}>
  <Image
    src="/background.jpg"
    alt="Background"
    fill
    style={{ objectFit: 'cover' }}
  />
</div>
```

**next.config.js:**
```javascript
module.exports = {
  images: {
    formats: ['image/avif', 'image/webp'],
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'example.com',
      },
    ],
  },
};
```

---

## 🔤 Font Optimization

```typescript
// app/layout.tsx
import { Inter, Roboto_Mono } from 'next/font/google';

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-inter',
});

const robotoMono = Roboto_Mono({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-roboto-mono',
});

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={`${inter.variable} ${robotoMono.variable}`}>
      <body className="font-sans">{children}</body>
    </html>
  );
}
```

**CSS:**
```css
/* globals.css */
body {
  font-family: var(--font-inter);
}

code {
  font-family: var(--font-roboto-mono);
}
```

---

## 🛣️ Route Handlers (API Routes)

```typescript
// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server';

// GET /api/users
export async function GET(request: NextRequest) {
  const users = await db.user.findMany();

  return NextResponse.json(users);
}

// POST /api/users
export async function POST(request: NextRequest) {
  const body = await request.json();

  const user = await db.user.create({
    data: body,
  });

  return NextResponse.json(user, { status: 201 });
}

// Dynamic route: /api/users/[id]
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const user = await db.user.findUnique({
    where: { id: params.id },
  });

  if (!user) {
    return NextResponse.json(
      { error: 'User not found' },
      { status: 404 }
    );
  }

  return NextResponse.json(user);
}
```

---

## 🌐 Proxy Configuration (Next.js 16+)

**NEW in 16:** `proxy.ts` replaces `middleware.ts` for clearer network boundaries.

```typescript
// proxy.ts (Next.js 16+)
import { NextRequest, NextResponse } from 'next/server';

export function proxy(request: NextRequest) {
  // Authentication check
  const token = request.cookies.get('token');

  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  // Add custom headers
  const response = NextResponse.next();
  response.headers.set('x-custom-header', 'value');

  return response;
}

// Config
export const config = {
  matcher: [
    '/dashboard/:path*',
    '/api/:path*',
    '/((?!_next/static|_next/image|favicon.ico).*)',
  ],
};
```

**Legacy (middleware.ts) still supported but deprecated:**

## 🛡️ Middleware (Legacy - use proxy.ts in Next.js 16)

```typescript
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  // Authentication check
  const token = request.cookies.get('token');

  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  // Add custom header
  const response = NextResponse.next();
  response.headers.set('x-custom-header', 'value');

  return response;
}

// Matcher config
export const config = {
  matcher: [
    '/dashboard/:path*',
    '/api/:path*',
    '/((?!_next/static|_next/image|favicon.ico).*)',
  ],
};
```

---

## 🔐 Security Best Practices

### Environment Variables

```typescript
// ✅ Server-only variables (no NEXT_PUBLIC_ prefix)
const DATABASE_URL = process.env.DATABASE_URL;
const API_SECRET = process.env.API_SECRET;

// ✅ Client-exposed variables (NEXT_PUBLIC_ prefix)
const PUBLIC_API_URL = process.env.NEXT_PUBLIC_API_URL;
```

### CSRF Protection

```typescript
// Server Action with CSRF token verification
'use server';

import { headers } from 'next/headers';

export async function submitForm(formData: FormData) {
  const headersList = headers();
  const csrfToken = headersList.get('x-csrf-token');

  if (!csrfToken || !verifyCsrfToken(csrfToken)) {
    throw new Error('Invalid CSRF token');
  }

  // Process form...
}
```

### Content Security Policy

```typescript
// next.config.js
const cspHeader = `
  default-src 'self';
  script-src 'self' 'unsafe-eval' 'unsafe-inline';
  style-src 'self' 'unsafe-inline';
  img-src 'self' blob: data: https:;
  font-src 'self';
  object-src 'none';
  base-uri 'self';
  form-action 'self';
  frame-ancestors 'none';
  upgrade-insecure-requests;
`;

module.exports = {
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'Content-Security-Policy',
            value: cspHeader.replace(/\n/g, ''),
          },
        ],
      },
    ];
  },
};
```

---

## 🎨 Cache Components (Next.js 16)

**NEW Feature:** Fine-grained caching control with instant navigation.

```typescript
// next.config.js
module.exports = {
  experimental: {
    cacheComponents: true, // Enable Cache Components
  },
};

// app/dashboard/page.tsx
import { cache } from 'next/cache';

// Cache user data with tags
const getUser = cache(
  async (id: string) => {
    const user = await db.user.findUnique({ where: { id } });
    return user;
  },
  {
    tags: ['user', `user-${id}`],
    revalidate: 3600, // 1 hour
  }
);

export default async function Dashboard({ params }: { params: { id: string } }) {
  const user = await getUser(params.id);
  
  return <div>Welcome, {user.name}</div>;
}

// Revalidate with new updateTag() API
import { updateTag } from 'next/cache';

export async function updateUserAction(userId: string, data: FormData) {
  'use server';
  
  await db.user.update({ where: { id: userId }, data });
  
  // NEW in Next.js 16 - more efficient than revalidateTag
  await updateTag(`user-${userId}`);
}
```

---

## 🤖 Next.js DevTools MCP (Next.js 16)

**NEW Feature:** AI-assisted debugging with Model Context Protocol.

```typescript
// Enable DevTools MCP in development
// next.config.js
module.exports = {
  experimental: {
    devToolsMCP: true,
  },
};

// Use with AI assistants for:
// - Contextual debugging insights
// - Performance analysis
// - Code suggestions
// - Error diagnosis
```

**Benefits:**
- Real-time application insights
- AI-powered error resolution
- Performance bottleneck detection
- Component composition analysis

---

## ⚡ Performance Optimization

### Dynamic Imports (Code Splitting)

```typescript
import dynamic from 'next/dynamic';

// ✅ Component-level code splitting
const HeavyComponent = dynamic(() => import('@/components/HeavyComponent'), {
  loading: () => <p>Loading...</p>,
  ssr: false, // Disable SSR if not needed
});

// ✅ Named export
const Chart = dynamic(
  () => import('@/components/Chart').then((mod) => mod.Chart),
  { ssr: false }
);
```

### Metadata API

```typescript
// app/layout.tsx or page.tsx
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'My App',
  description: 'Best app ever',
  openGraph: {
    title: 'My App',
    description: 'Best app ever',
    images: ['/og-image.jpg'],
  },
};

// Dynamic metadata
export async function generateMetadata({
  params,
}: {
  params: { id: string };
}): Promise<Metadata> {
  const post = await fetchPost(params.id);

  return {
    title: post.title,
    description: post.excerpt,
  };
}
```

---

## 🧪 Testing

### Unit Tests (Jest + React Testing Library)

```typescript
// __tests__/components/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from '@/components/Button';

describe('Button', () => {
  it('renders and handles click', () => {
    const handleClick = jest.fn();

    render(<Button onClick={handleClick}>Click me</Button>);

    const button = screen.getByText('Click me');
    fireEvent.click(button);

    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
```

### E2E Tests (Playwright)

```typescript
// e2e/homepage.spec.ts
import { test, expect } from '@playwright/test';

test('homepage loads and displays title', async ({ page }) => {
  await page.goto('http://localhost:3000');

  await expect(page.locator('h1')).toContainText('Welcome');
});
```

---

## ⚡ React 19.2 Features (Next.js 16)

**NEW Integration:** Next.js 16 includes React 19.2 features.

### View Transitions

```typescript
'use client';

import { startTransition } from 'react';
import { useRouter } from 'next/navigation';

export function NavigateButton({ href }: { href: string }) {
  const router = useRouter();

  const handleNavigate = () => {
    // Enable View Transitions API
    if (document.startViewTransition) {
      document.startViewTransition(() => {
        startTransition(() => {
          router.push(href);
        });
      });
    } else {
      router.push(href);
    }
  };

  return <button onClick={handleNavigate}>Navigate</button>;
}
```

### useEffectEvent Hook

```typescript
'use client';

import { useEffectEvent } from 'react';

export function ChatRoom({ roomId }: { roomId: string }) {
  // Event doesn't re-trigger effect
  const onConnected = useEffectEvent(() => {
    logToAnalytics('Connected to ' + roomId);
  });

  useEffect(() => {
    const connection = connectToChatRoom(roomId);
    connection.on('connected', onConnected);
    return () => connection.disconnect();
  }, [roomId]); // Only roomId dependency, not onConnected
}
```

### Activity Component

```typescript
import { Activity } from 'react';

export function LoadingIndicator() {
  return (
    <Activity>
      <Spinner />
      <p>Loading content...</p>
    </Activity>
  );
}
```

---

## 📦 Turbopack Configuration (Stable & Default in Next.js 16)

```javascript
// next.config.js
module.exports = {
  // Turbopack is now default in Next.js 15
  // Turbopack is now default in Next.js 16
  // No need for experimental flag
  
  turbopack: {
    resolveAlias: {
      '@': './src',
    },
    // File system caching (beta)
    cache: {
      filesystem: true,
    },
  },
};
```

**Development:**
```bash
# Turbopack dev server (default in Next.js 15)
npm run dev

# Build with Turbopack
npm run build
```

---

## 🔧 TypeScript Configuration

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

---

## 🚀 Deployment

### Vercel (Recommended)

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel

# Production deployment
vercel --prod
```

### Docker

```dockerfile
# Dockerfile
FROM node:20-alpine AS base

# Dependencies
FROM base AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci

# Builder
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# Runner
FROM base AS runner
WORKDIR /app
ENV NODE_ENV=production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000

CMD ["node", "server.js"]
```

**next.config.js:**
```javascript
module.exports = {
  output: 'standalone', // For Docker
};
```

---

## ❌ Anti-Patterns to Avoid

```typescript
// ❌ Don't use useEffect for data fetching in Server Components
'use client';
useEffect(() => {
  fetch('/api/data').then(...);
}, []);

// ✅ Use async Server Component instead
async function Component() {
  const data = await fetch('/api/data');
  return <div>{data}</div>;
}

// ❌ Don't fetch in Client Component when Server Component works
'use client';
function Component() {
  const [data, setData] = useState(null);
  useEffect(() => { /* fetch */ }, []);
}

// ✅ Use Server Component
async function Component() {
  const data = await fetchData();
  return <div>{data}</div>;
}

// ❌ Don't use getServerSideProps (Pages Router - deprecated)
export async function getServerSideProps() {}

// ✅ Use Server Components with App Router
async function Page() {
  const data = await fetch(...);
}
```

---

## ✅ Best Practices Checklist

**Project Setup:**
- [ ] Use TypeScript with strict mode
- [ ] Configure path aliases (@/*)
- [ ] Set up ESLint + Prettier
- [ ] Enable Turbopack (default in 15)
- [ ] Configure next.config.js properly

**Performance:**
- [ ] Use Server Components by default
- [ ] Lazy load heavy components
- [ ] Optimize images with next/image
- [ ] Use next/font for fonts
- [ ] Enable PPR for mixed static/dynamic pages
- [ ] Implement proper caching strategies

**Security:**
- [ ] Never expose secrets (no NEXT_PUBLIC_ for secrets)
- [ ] Implement CSRF protection
- [ ] Set Content Security Policy
- [ ] Validate all user inputs
- [ ] Use Server Actions for mutations

**SEO:**
- [ ] Add metadata to all pages
- [ ] Generate sitemap.xml
- [ ] Implement robots.txt
- [ ] Use semantic HTML
- [ ] Optimize Core Web Vitals

**Testing:**
- [ ] Unit tests for utilities
- [ ] Component tests for UI
- [ ] E2E tests for critical flows
- [ ] 80%+ test coverage

---

## 📚 References

- [Next.js 15 Documentation](https://nextjs.org/docs)
- [React 19 Documentation](https://react.dev/)
- [Turbopack Documentation](https://turbo.build/pack)
- [Next.js Examples](https://github.com/vercel/next.js/tree/canary/examples)

---

**Last Updated:** 2026-01-17  
**Next.js Version:** 16.x (LTS - October 2025)  
**React Version:** 19.2+  
**Node.js:** 20.9+ required  
**Status:** ✅ Production-Ready

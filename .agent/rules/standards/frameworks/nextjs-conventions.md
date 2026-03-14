---
technology: Next.js
version: 5.0.0
last_updated: 2026-02-27
official_docs: https://nextjs.org/docs
priority: P1 - Load when Next.js 16+ detected
---

# Next.js 16 Feature Guide

> **Version:** 5.0.0 | **Updated:** 2026-02-27
> **Next.js:** 16.x (LTS - Released October 2025)
> **React:** 19.2+ | **Node.js:** 20.9+ | **Build:** Turbopack (default)

> [!IMPORTANT]
> For **Next.js 14/15/16 fundamentals** (App Router, Server/Client Components, Server Actions, Data Fetching, Layouts):
> see `rules/nextjs/app-router.md` (P0).
> **This file covers ONLY Next.js 16-specific features and enhancements.**

---

## 🚀 Next.js 16 — What's New

- ✅ **Cache Components** — Instant navigation with granular caching control
- ✅ **Turbopack (stable & default)** — 2-5x faster builds, 10x faster Fast Refresh
- ✅ **React Compiler (stable)** — Automatic memoization without manual code
- ✅ **proxy.ts** — Replaces middleware.ts for clearer network boundaries
- ✅ **Next.js DevTools MCP** — AI-assisted debugging with Model Context Protocol
- ✅ **React 19.2 Integration** — View Transitions, useEffectEvent, \<Activity/>
- ✅ **Layout Deduplication** — Downloads shared layouts only once
- ✅ **Incremental Prefetching** — Prefetches only uncached parts
- ✅ **Enhanced Caching APIs** — New updateTag(), refined revalidateTag()

---

## 🎨 Cache Components (Next.js 16)

**Fine-grained caching control with instant navigation.**

```typescript
// next.config.ts
const nextConfig = {
  cacheComponents: true,
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

## 🌐 Proxy Configuration (Next.js 16+)

**`proxy.ts` replaces `middleware.ts` for clearer network boundaries.**

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

> **Migration:** `middleware.ts` still supported but deprecated. Move logic to `proxy.ts`.

---

## ⚡ Performance Configuration (Next.js 16)

**Standard `next.config.ts` for maximum performance:**

```typescript
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // ── Core ─────────────────────────────────────────────────
  reactCompiler: true,            // Auto-memoization (React 19.2)
  output: 'standalone',           // Docker-ready minimal build

  // ── Component Caching (replaces PPR) ──────────────────
  cacheComponents: true,          // Cached Server Components

  // ── Images ───────────────────────────────────────────────
  images: {
    formats: ['image/avif', 'image/webp'],
  },

  // ── Experimental Performance ───────────────────────────
  experimental: {
    // Client Router Cache: reduce refetches on navigation
    staleTimes: {
      dynamic: 30,   // Cache dynamic pages 30s on client
      static: 180,   // Cache static pages 3min on client
    },
    // Tree-shake large packages for smaller bundles
    optimizePackageImports: [
      'reactstrap',
      'next-auth',
      'bcryptjs',
    ],
  },

  // ── Build Analysis ───────────────────────────────────────
  logging: {
    fetches: {
      fullUrl: true,
      hmrRefreshes: true,
    },
  },
};

export default nextConfig;
```

> [!WARNING]
> **`cacheComponents: true` is incompatible with `export const dynamic = 'force-dynamic'`.**
> Remove all `force-dynamic` route segment configs. Use `router.refresh()` for cache busting instead.

| Config | Purpose | Layer |
|--------|---------|-------|
| `reactCompiler` | Auto-memoization, eliminates manual `useMemo`/`useCallback` | Build |
| `cacheComponents` | Cached Server Components with granular invalidation | Runtime |
| `staleTimes` | Client-side Router Cache for instant back/forward navigation | Client |
| `optimizePackageImports` | Tree-shake barrel exports for smaller bundles | Build |
| `logging.fetches` | Full URL + HMR logs for debugging data flow | Dev |

---

## ⚡ React 19.2 Features (Next.js 16)

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

## 🤖 Next.js DevTools MCP (Next.js 16)

**AI-assisted debugging with Model Context Protocol.**

```typescript
// next.config.js
module.exports = {
  experimental: {
    devToolsMCP: true,
  },
};

// Capabilities:
// - Contextual debugging insights
// - Performance analysis & bottleneck detection
// - Code suggestions
// - Error diagnosis
// - Component composition analysis
```

---

## 📦 Turbopack Configuration (Stable & Default)

```javascript
// next.config.js
module.exports = {
  // Turbopack is default in Next.js 16 — no experimental flag needed
  
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

```bash
# Dev server (Turbopack is default)
npm run dev

# Build
npm run build
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

## 🖼️ Image & Font Optimization

```typescript
import Image from 'next/image';

// ✅ With blur placeholder + priority for LCP
<Image
  src={heroImg}
  alt="Hero"
  placeholder="blur"
  priority
/>

// ✅ Responsive remote images
<Image
  src="https://example.com/image.jpg"
  alt="Description"
  width={800}
  height={600}
  sizes="(max-width: 768px) 100vw, 50vw"
/>
```

**next.config.js:**
```javascript
module.exports = {
  images: {
    formats: ['image/avif', 'image/webp'],
    remotePatterns: [
      { protocol: 'https', hostname: 'example.com' },
    ],
  },
};
```

### Font Optimization

```typescript
// app/layout.tsx
import { Inter, Roboto_Mono } from 'next/font/google';

const inter = Inter({ subsets: ['latin'], display: 'swap', variable: '--font-inter' });
const robotoMono = Roboto_Mono({ subsets: ['latin'], display: 'swap', variable: '--font-roboto-mono' });

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${inter.variable} ${robotoMono.variable}`}>
      <body className="font-sans">{children}</body>
    </html>
  );
}
```

---

## ⚡ Performance Optimization

### Dynamic Imports (Code Splitting)

```typescript
import dynamic from 'next/dynamic';

// ✅ Component-level code splitting
const HeavyComponent = dynamic(() => import('@/components/HeavyComponent'), {
  loading: () => <p>Loading...</p>,
  ssr: false,
});

// ✅ Named export
const Chart = dynamic(
  () => import('@/components/Chart').then((mod) => mod.Chart),
  { ssr: false }
);
```

---

## 🚀 Deployment

### Docker (Multi-Stage Build)

```dockerfile
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
  output: 'standalone', // Required for Docker
};
```

---

## ❌ Anti-Patterns to Avoid

```typescript
// ❌ Don't use useEffect for data fetching in Server Components
'use client';
useEffect(() => { fetch('/api/data').then(...); }, []);

// ✅ Use async Server Component instead
async function Component() {
  const data = await fetch('/api/data');
  return <div>{data}</div>;
}

// ❌ Don't use getServerSideProps (Pages Router - deprecated)
export async function getServerSideProps() {}

// ✅ Use Server Components with App Router
async function Page() {
  const data = await fetch(...);
}

// ❌ Don't use middleware.ts for new projects (deprecated in 16)
// ✅ Use proxy.ts instead
```

---

## ✅ Best Practices Checklist

**Next.js 16 Specific:**
- [ ] Use `proxy.ts` instead of `middleware.ts`
- [ ] Enable `cacheComponents: true` for cached Server Components
- [ ] Configure `staleTimes` for instant client navigation
- [ ] Enable `optimizePackageImports` for smaller bundles
- [ ] Use `updateTag()` for efficient cache invalidation
- [ ] Enable Turbopack filesystem caching
- [ ] Leverage React 19.2 View Transitions for smooth UX
- [ ] Enable DevTools MCP for AI-assisted debugging
- [ ] Remove all `export const dynamic = 'force-dynamic'` (incompatible with `cacheComponents`)
- [ ] Use `next/font/local` or `next/font/google` instead of CDN `<link>` tags

**General (see `rules/nextjs/` for details):**
- [ ] Server Components by default
- [ ] TypeScript with strict mode
- [ ] Optimize images with `next/image`
- [ ] Use `next/font` for fonts
- [ ] Content Security Policy headers
- [ ] 80%+ test coverage

---

**References:**
- [Next.js 16 Documentation](https://nextjs.org/docs)
- [React 19.2 Documentation](https://react.dev/)
- [Turbopack Documentation](https://turbo.build/pack)
- [Next.js Examples](https://github.com/vercel/next.js/tree/canary/examples)

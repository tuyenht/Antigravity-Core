---
technology: Next.js
version: 1.0.0
last_updated: 2026-03-11
priority: P0 - Auto-load for all Next.js 16 projects
---

# Next.js 16 Ultra-Performance Architecture Standard

> **Antigravity Platinum Standard** — Mọi dự án Next.js 16 tạo bởi Antigravity-Core PHẢI tuân thủ.
> Mục tiêu: TTFB < 80ms | LCP < 1.5s | Lighthouse > 95 | JS Bundle < 100KB

---

## 1. Architectural Principles (Enforce Always)

| # | Rule | Rationale |
|---|------|-----------|
| 1 | **Server Components by default** | Minimize client JS, zero hydration cost |
| 2 | **Prefer static over server rendering** | Static HTML = CDN-cacheable = fastest |
| 3 | **Cache aggressively at every layer** | Avoid repeated computation |
| 4 | **Proxy over Middleware** | `proxy.ts` replaces deprecated `middleware.ts` |
| 5 | **Minimize browser workload** | Defer non-critical scripts, lazy-load below-fold |
| 6 | **`'use client'` only when required** | useState, useEffect, event handlers, browser APIs |
| 7 | **Never `SELECT *`** | Fetch only required fields for faster queries |
| 8 | **Batch database queries** | Reduce round-trips with `Promise.all()` |

---

## 2. Next.js 16 Performance Config (Mandatory)

Every project MUST have this `next.config.ts`:

```typescript
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // ── Core ─────────────────────────────────────────
  reactCompiler: true,          // Auto useMemo/useCallback (React 19.2)
  reactStrictMode: true,        // Detect side-effects early
  output: 'standalone',         // Docker-ready, minimal build
  poweredByHeader: false,       // Security: hide X-Powered-By
  compress: true,               // Brotli/Gzip responses

  // ── Component Caching ────────────────────────────
  cacheComponents: true,        // Cached Server Components (replaces PPR)

  // ── Images ───────────────────────────────────────
  images: {
    formats: ['image/avif', 'image/webp'],
    minimumCacheTTL: 60,
  },

  // ── Experimental Performance ─────────────────────
  experimental: {
    staleTimes: {
      dynamic: 30,              // Client cache dynamic routes 30s
      static: 180,              // Client cache static routes 3min
    },
    optimizePackageImports: [
      // ADD project-specific heavy packages here
      'reactstrap', 'next-auth', 'bcryptjs',
      'lucide-react', '@radix-ui/react-icons',
    ],
  },

  // ── Build Analysis ───────────────────────────────
  logging: {
    fetches: { fullUrl: true, hmrRefreshes: true },
  },

  // ── Security + Cache Headers ─────────────────────
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          { key: 'X-DNS-Prefetch-Control', value: 'on' },
          { key: 'X-Frame-Options', value: 'DENY' },
          { key: 'X-Content-Type-Options', value: 'nosniff' },
          { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
        ],
      },
      {
        source: '/_next/static/:path*',
        headers: [
          { key: 'Cache-Control', value: 'public, max-age=31536000, immutable' },
        ],
      },
      {
        source: '/assets/:path*',
        headers: [
          { key: 'Cache-Control', value: 'public, max-age=31536000, immutable' },
        ],
      },
    ];
  },
};

export default nextConfig;
```

---

## 3. Proxy (Network Layer)

```typescript
// proxy.ts — replaces middleware.ts (Next.js 16+)
import { auth } from '@/auth';
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

const ADMIN_PREFIX = process.env.NEXT_PUBLIC_ADMIN_PREFIX ?? 'admin';
const PUBLIC_PATHS = new Set([
    `/${ADMIN_PREFIX}/login`,
    `/${ADMIN_PREFIX}/forgot-password`,
    `/${ADMIN_PREFIX}/reset-password`,
    `/${ADMIN_PREFIX}/two-factor`,
]);

export async function proxy(request: NextRequest) {
    const { pathname } = request.nextUrl;
    if (!pathname.startsWith(`/${ADMIN_PREFIX}`)) return NextResponse.next();

    const isPublic = PUBLIC_PATHS.has(pathname);
    const session = await auth();

    if (isPublic) {
        if (session) {
            return NextResponse.redirect(
                new URL(`/${ADMIN_PREFIX}/dashboard`, request.url)
            );
        }
        return NextResponse.next();
    }

    if (!session) {
        return NextResponse.redirect(
            new URL(`/${ADMIN_PREFIX}/login`, request.url)
        );
    }

    return NextResponse.next();
}

export const config = {
    matcher: ['/((?!api|_next/static|_next/image|assets|images|favicon.ico).*)'],
};
```

---

## 4. Cache Hierarchy (4 Layers)

Every route must be designed with cache-first thinking:

```
Request → Layer 1 (Browser Cache)
       → Layer 2 (CDN/Edge Cache)
       → Layer 3 (Server Cache: cacheComponents + staleTimes)
       → Layer 4 (Database: indexed queries + connection pooling)
```

| Layer | Technology | TTL | Scope |
|-------|-----------|-----|-------|
| **1. Browser** | `Cache-Control` headers, Service Worker | immutable for static, short for dynamic | Per-user |
| **2. CDN/Edge** | Vercel Edge, Cloudflare | `s-maxage=3600, stale-while-revalidate` | Global |
| **3. Server** | `cacheComponents`, `staleTimes`, `unstable_cache` | 30s-3min dynamic, ISR for static | Per-deploy |
| **4. Database** | Connection pooling, indexed queries, `SELECT` only needed fields | N/A | Persistent |

### Cache Invalidation Pattern
```typescript
import { updateTag, revalidateTag, revalidatePath } from 'next/cache';

// Preferred (Next.js 16): granular tag update
await updateTag(`user-${userId}`);

// Fallback: revalidate entire tag group
revalidateTag('users');

// Nuclear option: revalidate entire path
revalidatePath('/dashboard');
```

---

## 5. Rendering Strategy by Route Type

| Route Type | Strategy | Example |
|------------|----------|---------|
| **Static public** | SSG (build-time) | Landing, Blog, Docs |
| **Semi-static** | ISR (revalidate: 60-3600) | Product pages, Pricing |
| **Dynamic public** | Server Component + Suspense | Search results, Feeds |
| **Authenticated** | Server Component + private cache | Dashboard, Profile |
| **Interactive** | Client Component (minimal) | Forms, Charts, Modals |

### Decision Tree
```
Does the page need user-specific data?
├── NO → Is the content mostly static?
│   ├── YES → SSG (build-time)
│   └── NO  → ISR (revalidate every N seconds)
└── YES → Server Component + Suspense
    ├── Layout/Shell → Server Component (cached)
    └── Interactive parts → Client Component (minimal)
```

---

## 6. Bundle Optimization Rules

| Rule | Implementation |
|------|---------------|
| Tree-shake barrel exports | `optimizePackageImports` in next.config.ts |
| Dynamic import heavy components | `next/dynamic` with `ssr: false` for charts, editors |
| Defer non-critical scripts | `<Script strategy="lazyOnload">` |
| Zero CDN font requests | `next/font/local` or `next/font/google` |
| Analyze bundle regularly | `ANALYZE=true pnpm build` |

### Bundle Budget

| Metric | Target | Hard Limit |
|--------|--------|------------|
| Initial JS | < 80KB | < 100KB |
| First Load JS | < 150KB | < 200KB |
| Per-page JS | < 50KB | < 80KB |

---

## 7. Database Performance Rules

```typescript
// ✅ DO: Fetch only required fields
const users = await prisma.user.findMany({
  select: { id: true, name: true, email: true },
  take: 20,
  skip: (page - 1) * 20,
  orderBy: { createdAt: 'desc' },
});

// ❌ DON'T: Select everything
const users = await prisma.user.findMany(); // SELECT *

// ✅ DO: Batch queries
const [users, roles, stats] = await Promise.all([
  prisma.user.count(),
  prisma.role.findMany(),
  prisma.auditLog.count({ where: { createdAt: { gte: today } } }),
]);

// ✅ DO: Use indexes for all filtered/sorted columns
// In schema.prisma:
// @@index([email])
// @@index([createdAt])
// @@index([roleId, status])
```

---

## 8. Performance Targets (Mandatory)

| Metric | Target | Measurement |
|--------|--------|-------------|
| **TTFB** | < 80ms | Server response time |
| **LCP** | < 1.5s | Largest Contentful Paint |
| **INP** | < 100ms | Interaction to Next Paint |
| **CLS** | < 0.05 | Cumulative Layout Shift |
| **Lighthouse** | > 95 | Performance score |
| **Initial JS** | < 100KB | First load bundle |
| **Server Response** | < 80ms avg | API + page response |

---

## 9. Anti-Patterns (Strictly Forbidden)

| ❌ Forbidden | ✅ Required |
|-------------|------------|
| `export const dynamic = 'force-dynamic'` with `cacheComponents` | `router.refresh()` for cache busting |
| `middleware.ts` for new projects | `proxy.ts` (Next.js 16 convention) |
| `'use client'` on every component | Server Components by default |
| Google Fonts via `<link>` CDN | `next/font/local` or `next/font/google` |
| `useEffect` for data fetching | `async` Server Components |
| `SELECT *` in database queries | `select: { field: true }` |
| Single Suspense boundary for entire page | Granular `<Suspense>` per data source |
| Barrel imports (`import { x } from 'lib'`) without `optimizePackageImports` | Add package to `optimizePackageImports` array |
| Client-side auth checks | `proxy.ts` + server-side `auth()` |
| Inline large datasets in Client Components | Server Components pass pre-processed data as props |

---

## 10. Verification Checklist

Before marking any project as production-ready:

- [ ] `pnpm build` succeeds without errors
- [ ] `proxy.ts` exists (not `middleware.ts`)
- [ ] `cacheComponents: true` in next.config.ts
- [ ] `staleTimes` configured in next.config.ts
- [ ] `optimizePackageImports` includes all heavy packages
- [ ] `reactCompiler: true` enabled
- [ ] Zero `export const dynamic = 'force-dynamic'` in codebase
- [ ] All fonts loaded via `next/font` (zero CDN `<link>` tags)
- [ ] Security headers configured in next.config.ts
- [ ] Database queries use `select` (no `SELECT *`)
- [ ] Heavy components use `next/dynamic` with `ssr: false`
- [ ] Images use `next/image` with proper `priority` and `sizes`
- [ ] Lighthouse Performance > 95
- [ ] Initial JS bundle < 100KB

---

> **Cross-References:**
> - Implementation details: `rules/nextjs/performance.md`
> - Proxy patterns: `rules/standards/frameworks/nextjs-conventions.md`
> - Caching API: `rules/nextjs/performance.md` § Caching Architecture
> - Admin auth: `skills/velzon-admin/reference/nextjs-patterns.md` § Proxy

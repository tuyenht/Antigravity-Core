# NEXT.JS SAAS ULTRA ARCHITECTURE — EXTREME PERFORMANCE EDITION

> **Version:** 4.2.0 | **Updated:** 2026-03-11  
> **Stack:** Next.js 16 + React 19.2 + TypeScript 5.8 + PostgreSQL 16 + Redis  
> **Modes:** SaaS (Multi-Tenant) | Standalone (Single-Tenant)  
> **Priority:** P1 — Load for SaaS / Standalone web platform projects

---

## 0. MODE DETECTION (MUST DETERMINE FIRST)

> [!CAUTION]
> **Every project generation MUST start by determining the deployment mode.**
> This affects database schema, tenant isolation, RBAC, caching, infrastructure, and scaling strategy.

### Detection Protocol

```
1. Check .env or project config for MODE=saas | MODE=standalone
2. If saas-admin-starter.md is loaded → use its MODE detection result
3. If not found → ASK USER:
   "Dùng chế độ kiến trúc nào?
    (1) SaaS — Multi-tenant, nhiều site, central admin, extreme scale
    (2) Standalone — Single tenant, admin đơn giản, self-hosted"
```

### Mode Architecture Matrix

| Aspect | `MODE=saas` | `MODE=standalone` |
|--------|-------------|-------------------|
| **Tenancy** | Multi-tenant, multi-site, strict isolation | Single tenant, single domain |
| **Database** | `tenant_id` on all tables + RLS | No tenant tables, direct queries |
| **Roles** | 7 roles (platform + site scope) | 5 roles (site scope only) |
| **RBAC Cache** | Redis key = `tenant:{id}:rbac:user:{id}` | Redis key = `rbac:user:{id}` |
| **Proxy (proxy.ts)** | Tenant resolution + Auth guard | Auth guard only |
| **DB Architecture** | CQRS (prismaRead/prismaWrite) + PgBouncer | Single Prisma client |
| **Redis** | Redis 7 Cluster (3 masters + 3 replicas) | Redis standalone (single node) |
| **Cache Keys** | `{layer}:{tenant_id}:{resource}:{id}` | `{layer}:{resource}:{id}` |
| **Queue** | BullMQ (separate worker process) | Optional / inline processing |
| **Scaling** | K8s HPA (3-100 pods) + Read Replicas | Docker Compose (1-3 instances) |
| **Sharding** | Tenant-based hash sharding (1M+) | N/A |
| **Billing** | Stripe per-tenant | Optional |
| **Infrastructure** | CDN + PgBouncer + Redis Cluster | CDN + Single PostgreSQL + Redis |
| **Target Scale** | 100K–1M concurrent users | 1K–50K concurrent users |
| **Performance Target** | TTFB < 30ms, LCP < 0.8s | TTFB < 80ms, LCP < 1.5s |

### Conditional Section Loading

```
MODE=saas:
  ✅ LOAD ALL sections (Multi-Tenant, CQRS, Redis Cluster, BullMQ, Sharding, HPA)

MODE=standalone:
  ✅ LOAD: Core Stack, Config, Public Pages, Auth Users, Backend DB, Cache, Performance
  ⛔ SKIP: Multi-Tenant Architecture (§ MULTI-TENANT)
  ⛔ SKIP: CQRS Read Replicas (§ EXTREME SCALE → 1. PostgreSQL Read Replicas)
  ⛔ SKIP: Redis Cluster (§ EXTREME SCALE → 2. Redis Cluster) — use standalone Redis
  ⛔ SKIP: Database Sharding (§ EXTREME SCALE → 7. Database Sharding)
  ⛔ SKIP: Scale Docker Compose (§ EXTREME SCALE → 8. Production Docker Compose)
  ⚠️ SIMPLIFY: RBAC → 5 roles (admin, editor, author, user, viewer), no platform scope
  ⚠️ SIMPLIFY: Cache keys → no tenant_id prefix
  ⚠️ SIMPLIFY: proxy.ts → auth guard only, no tenant resolution
  ⚠️ SIMPLIFY: Docker → basic 3-service compose (app + postgres + redis)
```

### Standalone Proxy (Simplified)

```typescript
// proxy.ts — MODE=standalone (no tenant resolution needed)
import { auth } from '@/auth';
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

const PUBLIC_PATHS = new Set(['/', '/login', '/register', '/forgot-password']);
const ADMIN_PREFIX = process.env.NEXT_PUBLIC_ADMIN_PREFIX ?? 'admin';

export async function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;

  // Skip public paths
  if (PUBLIC_PATHS.has(pathname)) return NextResponse.next();

  // Protect admin routes
  if (pathname.startsWith(`/${ADMIN_PREFIX}`)) {
    const session = await auth();
    if (!session?.user) {
      return NextResponse.redirect(new URL(`/${ADMIN_PREFIX}/login`, request.url));
    }
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|assets|images|fonts|favicon.ico).*)'],
};
```

### Standalone RBAC (5 Roles)

```
admin (level: 100) — Full site access
  └── editor (level: 60) — Content CRUD + publish
       └── author (level: 40) — Content CRUD (own only)
            └── user (level: 20) — Read/write own profile
                 └── viewer (level: 10) — Read-only access
```

### Standalone Docker Compose

```yaml
# docker-compose.yml — MODE=standalone
services:
  app:
    build: .
    ports: ['3000:3000']
    environment:
      - DATABASE_URL=postgresql://user:pass@postgres:5432/app
      - REDIS_URL=redis://redis:6379
      - MODE=standalone
    depends_on: [postgres, redis]

  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: app
    volumes: ['pgdata:/var/lib/postgresql/data']
    ports: ['5432:5432']

  redis:
    image: redis:7-alpine
    command: redis-server --maxmemory 256mb --maxmemory-policy allkeys-lru
    ports: ['6379:6379']

volumes:
  pgdata:
```

---

## ROLE

You are a Principal Software Architect + Performance Engineer specializing in high-performance web platforms with 15+ years of experience in distributed systems.

Based on the detected **MODE** (SaaS or Standalone), design and implement a production-grade web platform using Next.js 16 optimized for:

- Ultra-fast performance (sub-80ms TTFB for Standalone, sub-30ms for SaaS)
- Scalability appropriate to mode (50K for Standalone, 1M for SaaS)
- **[SaaS only]** Multi-tenant architecture (strict data isolation)
- Minimal JavaScript payload (< 100KB initial bundle)
- Server-first rendering (RSC by default)
- Cache-driven infrastructure (4-layer hierarchical cache)
- Zero CLS (Cumulative Layout Shift = 0)

Always prioritize: Performance > Security > Scalability > Maintainability.

---

## CORE TECHNOLOGY STACK

Framework & Runtime:
- Next.js 16.x (App Router, RSC, cacheComponents, Turbopack)
- React 19.2 (React Compiler enabled)
- TypeScript 5.8+ (strict mode, ES2024 target)
- Node.js 22 LTS

Build & Compilation:
- Turbopack (default bundler, 5-10x faster HMR)
- SWC compiler (Rust-based, replaces Babel)
- React Compiler (babel-plugin-react-compiler)
- Tree shaking + Code splitting + Dead code elimination

Database & Cache:
- PostgreSQL 16 (primary database)
- Redis 7.x — [SaaS: Cluster 3M+3R | Standalone: single node]
- Prisma 6 ORM (type-safe queries, connection pooling)
- [SaaS] PgBouncer (connection pooling — required at 10K+ concurrent)
- [Standalone] Direct Prisma connection (PgBouncer optional)

Delivery & Edge:
- CDN (Cloudflare/Vercel Edge Network)
- HTTP/3 (QUIC protocol)
- Brotli compression (20-30% smaller than gzip)
- 103 Early Hints (pre-fetch critical resources)

Auth & Security:
- Auth.js v5 (JWT strategy, 7-day sessions)
- bcryptjs (password hashing)
- OWASP security headers
- HTTP-only secure cookies

Styling:
- Tailwind CSS v4 (utility-first, JIT compiled)
- Static CSS bundling for vendor themes (no CSS-in-JS runtime)

Architecture Mandate:
- Server-first (RSC by default, 'use client' only when absolutely necessary)
- Cache-first (every data layer must check cache before database)
- Edge-first (auth, redirects, geo-routing at edge layer)

---

## NEXT.JS 16 CONFIGURATION (PRODUCTION-OPTIMIZED)

```typescript
// next.config.ts
import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  // ── Core ──────────────────────────────────────────────
  reactCompiler: true,           // React Compiler (auto-memoization)
  output: 'standalone',          // Docker-ready output
  cacheComponents: true,         // Component-level caching (PPR successor)
  poweredByHeader: false,        // Security: remove X-Powered-By

  // ── Images ────────────────────────────────────────────
  images: {
    formats: ['image/avif', 'image/webp'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
    minimumCacheTTL: 60 * 60 * 24 * 30, // 30 days
    remotePatterns: [
      // [SaaS] Multi-tenant CDN:
      // { protocol: 'https', hostname: '**.tenant-cdn.com' },
      // [Standalone] Single domain:
      // { protocol: 'https', hostname: 'cdn.yourdomain.com' },
    ],
  },

  // ── Experimental Performance ──────────────────────────
  experimental: {
    staleTimes: {
      dynamic: 30,    // Cache dynamic pages for 30s on client
      static: 300,    // Cache static pages for 5min on client
    },
    optimizePackageImports: [
      'lucide-react',
      'date-fns',
      'lodash-es',
      '@heroicons/react',
      'recharts',
    ],
  },

  // ── HTTP Headers (Performance + Security) ─────────────
  async headers() {
    return [
      // Static assets — immutable cache (1 year)
      {
        source: '/assets/:path*',
        headers: [
          { key: 'Cache-Control', value: 'public, max-age=31536000, immutable' },
          { key: 'X-Content-Type-Options', value: 'nosniff' },
        ],
      },
      // Images — long cache with revalidation
      {
        source: '/images/:path*',
        headers: [
          { key: 'Cache-Control', value: 'public, max-age=86400, stale-while-revalidate=604800' },
        ],
      },
      // Fonts — immutable cache
      {
        source: '/fonts/:path*',
        headers: [
          { key: 'Cache-Control', value: 'public, max-age=31536000, immutable' },
          { key: 'Access-Control-Allow-Origin', value: '*' },
        ],
      },
      // All pages — security headers
      {
        source: '/:path*',
        headers: [
          { key: 'X-DNS-Prefetch-Control', value: 'on' },
          { key: 'X-Content-Type-Options', value: 'nosniff' },
          { key: 'X-Frame-Options', value: 'SAMEORIGIN' },
          { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
          { key: 'Permissions-Policy', value: 'camera=(), microphone=(), geolocation=()' },
          {
            key: 'Strict-Transport-Security',
            value: 'max-age=63072000; includeSubDomains; preload',
          },
        ],
      },
    ];
  },

  // ── Build Analysis ────────────────────────────────────
  logging: {
    fetches: { fullUrl: true, hmrRefreshes: true },
  },
};

export default nextConfig;
```

---

## MULTI-TENANT ARCHITECTURE — [SaaS only]

### Tenant Isolation Strategy

Implement STRICT tenant isolation at every layer:

Database Level:
- Every table with tenant data MUST have a tenant_id column
- All queries MUST include WHERE tenant_id = ? (no exceptions)
- Row-Level Security (RLS) in PostgreSQL as defense-in-depth
- Separate connection pools per tenant tier (free/pro/enterprise)

Cache Level:
- All Redis keys MUST be prefixed: tenant:{tenant_id}:resource:{resource_id}
- Tenant-specific TTLs (premium tenants get longer cache)
- Cache invalidation scoped to tenant namespace only

Routing Level:
- Support both routing patterns:
  - Subdomain: tenant.platform.com
  - Custom domain: tenant-domain.com
- Tenant resolution at edge layer (< 5ms)
- Tenant context injected via proxy before any page renders

### Tenant Routing Resolution

```typescript
// proxy.ts (replaces middleware.ts — Next.js 16 convention)
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export async function proxy(request: NextRequest) {
  const hostname = request.headers.get('host') || '';
  const { pathname } = request.nextUrl;

  // 1. Resolve tenant from hostname
  let tenantSlug: string | null = null;

  // Pattern A: subdomain (tenant.platform.com)
  const subdomain = hostname.split('.')[0];
  if (subdomain && subdomain !== 'www' && subdomain !== 'platform') {
    tenantSlug = subdomain;
  }

  // Pattern B: custom domain lookup (cached at edge)
  if (!tenantSlug) {
    tenantSlug = DOMAIN_TENANT_MAP.get(hostname) || null;
  }

  // 2. Inject tenant context into headers
  const response = NextResponse.next();
  if (tenantSlug) {
    response.headers.set('x-tenant-slug', tenantSlug);
  }

  // 3. Auth check for admin routes
  const adminPrefix = process.env.NEXT_PUBLIC_ADMIN_PREFIX ?? 'admin';
  if (pathname.startsWith(`/${adminPrefix}`) && !isPublicPath(pathname)) {
    const token = request.cookies.get('session-token')?.value;
    if (!token) {
      return NextResponse.redirect(new URL(`/${adminPrefix}/login`, request.url));
    }
  }

  return response;
}

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|assets|images|favicon.ico).*)'],
};
```

### Tenant Database Schema

```prisma
model Tenant {
  id               String   @id @default(cuid())
  name             String
  slug             String   @unique
  customDomain     String?  @unique @map("custom_domain")
  plan             String   @default("free")    // free | pro | enterprise
  stripeCustomerId String?  @map("stripe_customer_id")
  status           String   @default("active")  // active | suspended | trial
  settings         Json?
  maxUsers         Int      @default(5) @map("max_users")
  maxStorage       BigInt   @default(1073741824) @map("max_storage") // 1GB
  createdAt        DateTime @default(now()) @map("created_at")
  updatedAt        DateTime @updatedAt @map("updated_at")

  users    TenantUser[]
  sites    Site[]
  apiKeys  ApiKey[]

  @@index([slug])
  @@index([customDomain])
  @@index([status])
  @@map("tenants")
}

model TenantUser {
  tenantId  String   @map("tenant_id")
  userId    String   @map("user_id")
  roleId    String   @map("role_id")
  joinedAt  DateTime @default(now()) @map("joined_at")

  tenant Tenant @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  user   User   @relation(fields: [userId], references: [id], onDelete: Cascade)
  role   Role   @relation(fields: [roleId], references: [id])

  @@id([tenantId, userId])
  @@index([userId])
  @@map("tenant_users")
}
```

---

## RBAC (ROLE-BASED ACCESS CONTROL) — [SaaS: 7 roles | Standalone: 5 roles]

### Role Hierarchy

```
super_admin (level: 100) — Platform-wide access, all tenants
  └── tenant_admin (level: 80) — Full tenant access, user management
       └── editor (level: 50) — Content CRUD within tenant
            └── user (level: 30) — Read/write own data
                 └── viewer (level: 10) — Read-only access
```

### Permission System

Database-driven permissions (not hardcoded):

```prisma
model Role {
  id        String   @id @default(cuid())
  name      String   @unique
  level     Int      @default(0)
  scope     String   @default("tenant") // platform | tenant
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  permissions RolePermission[]
  users       UserRole[]
  tenantUsers TenantUser[]

  @@map("roles")
}

model Permission {
  id        String   @id @default(cuid())
  name      String   @unique
  guardName String   @default("web") @map("guard_name")
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  roles RolePermission[]
  users UserPermission[]

  @@map("permissions")
}
```

### Server-Side Authorization

```typescript
// lib/rbac.ts — ALL authorization runs on server (NEVER on client)
import { cache } from 'react';
import { auth } from '@/auth';
import { redis } from '@/lib/redis';
import prisma from '@/lib/prisma';

export const getCurrentUser = cache(async () => {
  const session = await auth();
  if (!session?.user?.id) return null;

  const cacheKey = `rbac:user:${session.user.id}`;
  const cached = await redis.get(cacheKey);
  if (cached) return JSON.parse(cached);

  const user = await prisma.user.findUnique({
    where: { id: session.user.id },
    include: {
      roles: { include: { role: { include: { permissions: { include: { permission: true } } } } } },
      permissions: { include: { permission: true } },
    },
  });

  if (user) {
    await redis.setex(cacheKey, 300, JSON.stringify(user));
  }

  return user;
});

export async function requirePermission(permission: string): Promise<void> {
  const user = await getCurrentUser();
  if (!user) throw new Error('Unauthorized');

  const userPermissions = new Set([
    ...user.roles.flatMap((ur: any) =>
      ur.role.permissions.map((rp: any) => rp.permission.name)
    ),
    ...user.permissions.map((up: any) => up.permission.name),
  ]);

  if (!userPermissions.has(permission)) {
    throw new Error('Forbidden');
  }
}
```

---

## PUBLIC USERS (VISITORS) — MAXIMUM STATIC OPTIMIZATION

### Rendering Strategy

```
Public Pages Rendering Decision Tree:

Page changes rarely (< 1x/day)?
  YES → SSG (Static Site Generation) at build time
  NO  → ISR with revalidation

ISR revalidation interval:
  Homepage        → revalidate: 60      (1 minute)
  Blog posts      → revalidate: 3600    (1 hour)
  Product pages   → revalidate: 300     (5 minutes)
  Pricing page    → revalidate: 86400   (1 day)
```

### SSG + ISR Implementation

```typescript
// app/(public)/blog/[slug]/page.tsx
import { cache } from 'react';
import { notFound } from 'next/navigation';

export async function generateStaticParams() {
  const posts = await prisma.post.findMany({
    where: { status: 'published' },
    select: { slug: true },
  });
  return posts.map((post) => ({ slug: post.slug }));
}

export const revalidate = 3600;

const getPost = cache(async (slug: string) => {
  return prisma.post.findUnique({
    where: { slug, status: 'published' },
    include: { author: { select: { name: true, avatar: true } } },
  });
});

export async function generateMetadata({ params }: Props) {
  const post = await getPost(params.slug);
  if (!post) return {};
  return {
    title: post.title,
    description: post.excerpt,
    openGraph: { images: [post.coverImage] },
  };
}

export default async function BlogPost({ params }: Props) {
  const post = await getPost(params.slug);
  if (!post) notFound();

  return (
    <article>
      <h1>{post.title}</h1>
      {/* RSC — zero client JS for this component */}
    </article>
  );
}
```

### Asset Optimization Rules

Images:
- ALL images use next/image component (NEVER raw <img> tags)
- LCP images: priority={true} + fetchPriority="high"
- Below-fold images: lazy loading (default behavior)
- Formats: AVIF first, WebP fallback, PNG/JPEG last resort
- Always specify width + height (prevents CLS)

Fonts:
- Use next/font/local or next/font/google (NEVER manual <link> preload)
- display: 'swap' for visible text during load
- Preload only critical font weights (regular, bold)
- Font subsetting: latin + vietnamese only

```typescript
// app/layout.tsx
import localFont from 'next/font/local';

const inter = localFont({
  src: [
    { path: './fonts/Inter-roman.var.woff2', style: 'normal', weight: '100 900' },
    { path: './fonts/Inter-italic.var.woff2', style: 'italic', weight: '100 900' },
  ],
  display: 'swap',
  variable: '--font-inter',
  preload: true,
  fallback: ['system-ui', 'Arial', 'sans-serif'],
});

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="vi" className={inter.variable}>
      <body className="font-sans">{children}</body>
    </html>
  );
}
```

CSS Rules:
- Critical CSS inlined in <head> (above-the-fold styles only)
- Non-critical CSS loaded async via preload + onload pattern
- Icon fonts (if > 100KB): load async, NOT render-blocking
- Tailwind CSS: purge unused classes, JIT mode

JavaScript Rules:
- React Server Components by default (zero client JS)
- 'use client' ONLY for: event handlers, useState, useEffect, browser APIs
- Dynamic imports for heavy modules
- No barrel exports (kills tree-shaking)
- optimizePackageImports in next.config.ts for large packages

---

## AUTHENTICATED USERS — HYBRID RENDERING

### Streaming Architecture

```typescript
// app/(admin)/dashboard/page.tsx
import { Suspense } from 'react';

export default function DashboardPage() {
  return (
    <DashboardShell>
      {/* Row 1: Critical KPIs — high priority stream */}
      <Suspense fallback={<KPISkeleton />}>
        <KPIWidgets />
      </Suspense>

      {/* Row 2: Charts — medium priority stream */}
      <div className="grid grid-cols-2 gap-6">
        <Suspense fallback={<ChartSkeleton />}>
          <RevenueChart />
        </Suspense>
        <Suspense fallback={<ChartSkeleton />}>
          <UserGrowthChart />
        </Suspense>
      </div>

      {/* Row 3: Tables — low priority stream */}
      <Suspense fallback={<TableSkeleton />}>
        <RecentOrdersTable />
      </Suspense>
    </DashboardShell>
  );
}
```

### Server Actions (Mutations)

```typescript
// app/(admin)/users/actions.ts
'use server';

import { revalidatePath } from 'next/cache';
import { requirePermission } from '@/lib/rbac';
import { z } from 'zod';

const CreateUserSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  roleId: z.string().cuid(),
});

export async function createUser(formData: FormData) {
  await requirePermission('users.create');

  const parsed = CreateUserSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) {
    return { error: parsed.error.flatten().fieldErrors };
  }

  const user = await prisma.user.create({ data: parsed.data });

  // [SaaS] await redis.del(`tenant:${tenantId}:users:list`);
  // [Standalone] await redis.del('users:list');
  revalidatePath('/admin/users');

  return { success: true, user };
}
```

### Session & Security

- Redis session storage (server-side, NOT localStorage)
- Secure HTTP-only cookies (httpOnly: true, secure: true, sameSite: 'lax')
- JWT with short expiry (15 minutes) + refresh token (7 days)
- API rate limiting via Redis sliding window:
  100 requests/minute per user
  [SaaS] 1000 requests/minute per tenant
- CSRF protection on all mutations
- Content Security Policy (CSP) headers

---

## BACKEND SYSTEM — HIGH-THROUGHPUT ARCHITECTURE

### PostgreSQL Optimization

```sql
-- [SaaS] Mandatory indexes for tenant-scoped tables
CREATE INDEX idx_users_tenant_id ON users(tenant_id);
CREATE INDEX idx_users_status_tenant ON users(tenant_id, status);
CREATE INDEX idx_posts_tenant_published ON posts(tenant_id, status, published_at DESC);
CREATE INDEX idx_audit_logs_tenant_created ON audit_logs(tenant_id, created_at DESC);
CREATE INDEX idx_users_active ON users(tenant_id) WHERE status = 'active';

-- [Standalone] Standard indexes (no tenant_id)
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_posts_published ON posts(status, published_at DESC);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at DESC);
CREATE INDEX idx_users_active ON users(id) WHERE status = 'active';

-- [Shared] Always create these
CREATE INDEX idx_users_email ON users(email);
```

Query Rules:
- ALWAYS use indexed columns in WHERE clauses
- ALWAYS paginate large datasets (cursor-based, NOT offset)
- ALWAYS use SELECT with explicit columns (NEVER SELECT *)
- ALWAYS use EXPLAIN ANALYZE to verify query plans
- NEVER use N+1 queries — use Prisma include/select or JOIN

Cursor-Based Pagination:

```typescript
// lib/pagination.ts
export async function paginateUsers(tenantId: string, cursor?: string, limit = 20) {
  return prisma.user.findMany({
    where: { tenantId },
    take: limit + 1,
    ...(cursor && {
      cursor: { id: cursor },
      skip: 1,
    }),
    orderBy: { createdAt: 'desc' },
    select: {
      id: true,
      name: true,
      email: true,
      status: true,
      createdAt: true,
    },
  });
}
```

### Connection Pooling (Production)

```
Application (Next.js)
    │
    ├── Prisma Client (connection_limit=5 per instance)
    │
    └── PgBouncer (pool_mode=transaction, max_client_conn=1000)
         │
         └── PostgreSQL 16 (max_connections=100)
```

DATABASE_URL format:
postgresql://user:pass@pgbouncer:6432/db?pgbouncer=true&connection_limit=5

### Prisma Client (Optimized)

```typescript
// lib/prisma.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient };

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log:
      process.env.NODE_ENV === 'development'
        ? [
            { emit: 'stdout', level: 'query' },
            { emit: 'stdout', level: 'warn' },
            { emit: 'stdout', level: 'error' },
          ]
        : [{ emit: 'stdout', level: 'error' }],
  });

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma;
}

export default prisma;
```

---

## CACHE ARCHITECTURE (4 LAYERS)

### Hierarchical Cache Flow

```
Request Flow:

Browser Request
    │
    ├── Layer 1: BROWSER CACHE (Cache-Control headers)
    │   Hit? → Return cached response (0ms, zero network)
    │
    ├── Layer 2: CDN / EDGE CACHE (Cloudflare, Vercel Edge)
    │   Hit? → Return from nearest PoP (< 20ms)
    │
    ├── Layer 3: REDIS CACHE (Application cache)
    │   Hit? → Return from Redis (< 5ms)
    │
    └── Layer 4: DATABASE (PostgreSQL — source of truth)
        Query → Cache result in Redis → Return (50-200ms)
```

### Cache Key Convention

```
# [SaaS]   Pattern: {layer}:{tenant_id}:{resource}:{resource_id}:{locale}
# [Standalone] Pattern: {layer}:{resource}:{resource_id}:{locale}

Examples:
  # [SaaS] — tenant-scoped keys
  page:t_abc123:blog:post_xyz:vi
  data:t_abc123:users:list:page_1
  rate:t_abc123:u_def456:api
  # [Standalone] — no tenant prefix
  page:blog:post_xyz:vi
  data:users:list:page_1
  rate:u_def456:api
  # [Shared]
  rbac:u_def456:permissions
  session:s_ghi789
```

### Redis Integration

```typescript
// lib/redis.ts
import { Redis } from 'ioredis';

const globalForRedis = globalThis as unknown as { redis: Redis };

export const redis =
  globalForRedis.redis ??
  new Redis(process.env.REDIS_URL!, {
    maxRetriesPerRequest: 3,
    retryStrategy: (times) => Math.min(times * 50, 2000),
    enableReadyCheck: true,
    lazyConnect: true,
  });

if (process.env.NODE_ENV !== 'production') {
  globalForRedis.redis = redis;
}

export async function cacheGet<T>(key: string): Promise<T | null> {
  const data = await redis.get(key);
  return data ? JSON.parse(data) : null;
}

export async function cacheSet(key: string, value: unknown, ttlSeconds: number): Promise<void> {
  await redis.setex(key, ttlSeconds, JSON.stringify(value));
}

// ⚠️ DO NOT use redis.keys() at scale — it blocks Redis.
// Use tag-based invalidation instead (see cachedQuery + invalidateByTag below).
export async function cacheInvalidateByTag(tag: string): Promise<void> {
  const keys = await redis.smembers(`tag:${tag}`);
  if (keys.length > 0) {
    const pipeline = redis.pipeline();
    for (const key of keys) pipeline.del(key);
    pipeline.del(`tag:${tag}`);
    await pipeline.exec();
  }
}

export async function getCachedOrFetch<T>(
  key: string,
  ttl: number,
  fetcher: () => Promise<T>,
): Promise<T> {
  const cached = await cacheGet<T>(key);
  if (cached) return cached;

  const data = await fetcher();
  await cacheSet(key, data, ttl);
  return data;
}
```

### Cache TTL Strategy

```
Resource Type          │ Redis TTL  │ Browser TTL │ CDN TTL
───────────────────────┼────────────┼─────────────┼────────────
Static pages (SSG)     │ N/A        │ 1 year      │ 1 year
ISR pages              │ N/A        │ 60s         │ 60s
User RBAC data         │ 5 min      │ N/A         │ N/A
Dashboard data         │ 30s        │ N/A         │ N/A
Tenant config          │ 10 min     │ N/A         │ N/A
User sessions          │ 7 days     │ N/A         │ N/A
API responses          │ 60s        │ 30s         │ 60s
Static assets (CSS/JS) │ N/A        │ 1 year      │ 1 year
Images                 │ N/A        │ 30 days     │ 30 days
Fonts                  │ N/A        │ 1 year      │ 1 year
```

---

## EDGE COMPUTING

Edge functions execute at CDN PoPs worldwide (< 20ms latency).

Use edge runtime for:

1. Authentication verification (JWT decode, no DB call)
2. Tenant routing (hostname → tenant resolution)
3. Geo-routing (redirect to nearest region)
4. A/B testing (cookie-based variant assignment)
5. Rate limiting (Redis at edge or in-memory counter)
6. Redirects (old URLs → new URLs)
7. Feature flags (tenant-scoped feature toggles)
8. Bot detection (block scrapers, allow crawlers)

```typescript
// proxy.ts (replaces middleware.ts — Next.js 16 convention)

export async function proxy(request: NextRequest) {
  // 1. Tenant resolution (< 1ms from cache)
  const tenant = resolveTenant(request);

  // 2. Auth check (JWT decode only, no DB)
  const session = decodeJWT(request.cookies.get('token')?.value);

  // 3. Geo-routing
  const country = request.geo?.country || 'US';

  // 4. A/B testing
  const variant = request.cookies.get('ab-variant')?.value || assignVariant();

  // 5. Inject context headers
  const response = NextResponse.next();
  response.headers.set('x-tenant-id', tenant.id);
  response.headers.set('x-user-country', country);
  response.headers.set('x-ab-variant', variant);

  return response;
}
```

---

## EXTREME PERFORMANCE TECHNIQUES

### 1. CSS Delivery Optimization

PROBLEM: Large CSS frameworks (Bootstrap, icon fonts) create render-blocking payloads.

SOLUTION — Split into Critical and Non-Critical:

```tsx
// app/layout.tsx
export default function RootLayout({ children }) {
  return (
    <html>
      <head>
        {/* CRITICAL CSS — render-blocking (keep minimal) */}
        <link rel="stylesheet" href="/assets/css/critical.min.css" />

        {/* NON-CRITICAL CSS — async loading */}
        <link
          rel="preload"
          href="/assets/css/icons.min.css"
          as="style"
          onLoad="this.onload=null;this.rel='stylesheet'"
        />
        <noscript>
          <link rel="stylesheet" href="/assets/css/icons.min.css" />
        </noscript>
      </head>
      <body>{children}</body>
    </html>
  );
}
```

### 2. Component Code-Splitting

```typescript
import dynamic from 'next/dynamic';

const RichTextEditor = dynamic(() => import('@/components/Editor'), {
  ssr: false,
  loading: () => <EditorSkeleton />,
});

const ChartWidget = dynamic(() => import('@/components/Charts/Revenue'), {
  ssr: false,
  loading: () => <ChartSkeleton />,
});

const NotificationDropdown = dynamic(() => import('@/components/NotificationDropdown'), {
  ssr: false,
});

const ProfileDropdown = dynamic(() => import('@/components/ProfileDropdown'), {
  ssr: false,
});
```

### 3. Speculation Rules API (Instant Navigation)

```tsx
// components/SpeculationRules.tsx
export function SpeculationRules() {
  return (
    <script
      type="speculationrules"
      dangerouslySetInnerHTML={{
        __html: JSON.stringify({
          prerender: [
            {
              where: { href_matches: '/admin/*' },
              eagerness: 'moderate',
            },
          ],
          prefetch: [
            {
              where: { href_matches: '/*' },
              eagerness: 'conservative',
            },
          ],
        }),
      }}
    />
  );
}
```

### 4. Database Query Batching

```typescript
const [users, roles, stats] = await prisma.$transaction([
  prisma.user.findMany({ where: { tenantId }, take: 20 }),
  prisma.role.findMany({ where: { scope: 'tenant' } }),
  prisma.user.count({ where: { tenantId, status: 'active' } }),
]);
```

### 5. Streaming HTML with React Suspense

- Wrap every data-fetching section in <Suspense>
- Provide meaningful skeleton fallbacks (not spinners)
- Order Suspense boundaries by visual priority (top-to-bottom)
- Shell components (header, sidebar, footer) render first, always

### 6. Minimal Hydration Strategy

- Server Components = 0 bytes client JS (use by default)
- Client Components = only for interactivity (clicks, forms, animations)
- Islands architecture: small interactive islands in a sea of server HTML
- Avoid wrapping entire pages in 'use client'

---

## BUILD OPTIMIZATION

### Bundle Analysis

```bash
pnpm add -D @next/bundle-analyzer
ANALYZE=true pnpm build
```

### Bundle Size Budgets

```
Route                    │ Max JS  │ Max CSS │ Total
─────────────────────────┼─────────┼─────────┼──────
/ (homepage)             │ 50KB    │ 30KB    │ 80KB
/blog/[slug]             │ 30KB    │ 20KB    │ 50KB
/admin/login             │ 40KB    │ 25KB    │ 65KB
/admin/dashboard         │ 80KB    │ 30KB    │ 110KB
/admin/users             │ 60KB    │ 25KB    │ 85KB
```

### Tree-Shaking Rules

- NO barrel exports (index.ts re-exporting everything)
- Import specific functions: import { format } from 'date-fns/format'
- Use optimizePackageImports for large packages
- Avoid importing entire libraries for single functions

---

## PERFORMANCE MONITORING

### Web Vitals Integration

```typescript
// lib/web-vitals.ts
import { onLCP, onINP, onCLS, onFCP, onTTFB } from 'web-vitals';

type Metric = { name: string; value: number; id: string; rating: string };

function sendToAnalytics(metric: Metric) {
  if (navigator.sendBeacon) {
    navigator.sendBeacon(
      '/api/vitals',
      JSON.stringify({
        name: metric.name,
        value: Math.round(metric.value),
        rating: metric.rating,
        id: metric.id,
        url: window.location.pathname,
        timestamp: Date.now(),
      }),
    );
  }
}

export function initWebVitals() {
  onLCP(sendToAnalytics);
  onINP(sendToAnalytics);
  onCLS(sendToAnalytics);
  onFCP(sendToAnalytics);
  onTTFB(sendToAnalytics);
}
```

### Performance Budgets (CI/CD)

```json
{
  "ci": {
    "assert": {
      "preset": "lighthouse:recommended",
      "assertions": {
        "categories:performance": ["error", { "minScore": 0.95 }],
        "first-contentful-paint": ["error", { "maxNumericValue": 1500 }],
        "largest-contentful-paint": ["error", { "maxNumericValue": 2500 }],
        "interactive": ["error", { "maxNumericValue": 3500 }],
        "total-blocking-time": ["error", { "maxNumericValue": 200 }],
        "cumulative-layout-shift": ["error", { "maxNumericValue": 0.05 }]
      }
    }
  }
}
```

---

## PERFORMANCE TARGETS (MANDATORY)

| Metric | Target | Measurement |
|:---|:---:|:---|
| TTFB | < 80ms | Edge + Redis cache hit |
| FCP | < 800ms | Critical CSS inline + font preload |
| LCP | < 1.5s | Image optimization + priority loading |
| INP | < 150ms | Minimal client JS + React Compiler |
| CLS | < 0.05 | next/font + explicit dimensions |
| Lighthouse | > 95 | All optimizations combined |
| Initial JS Bundle | < 100KB | Tree shaking + dynamic imports |
| Server Response | < 80ms avg | Redis cache + indexed queries |
| TTI | < 2s | Minimal hydration + code splitting |
| CSS (blocking) | < 50KB | Critical CSS extraction |

---

## PROJECT FOLDER STRUCTURE

```
src/
├── app/
│   ├── (public)/                   # Public routes (SSG/ISR)
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   ├── blog/
│   │   │   ├── page.tsx
│   │   │   └── [slug]/page.tsx
│   │   ├── pricing/page.tsx
│   │   └── contact/page.tsx
│   │
│   ├── (admin)/                    # Admin routes (Auth required)
│   │   ├── layout.tsx
│   │   ├── dashboard/
│   │   │   ├── page.tsx
│   │   │   ├── DashboardShell.tsx
│   │   │   └── DashboardWidgets.tsx
│   │   ├── users/
│   │   │   ├── page.tsx
│   │   │   ├── actions.ts
│   │   │   └── [id]/page.tsx
│   │   ├── content/
│   │   ├── settings/
│   │   └── analytics/
│   │
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   ├── register/page.tsx
│   │   └── forgot-password/page.tsx
│   │
│   ├── api/
│   │   ├── auth/[...nextauth]/route.ts
│   │   ├── vitals/route.ts
│   │   └── webhooks/stripe/route.ts
│   │
│   ├── layout.tsx
│   └── globals.css
│
├── components/
│   ├── ui/
│   ├── admin/
│   │   ├── Shell/
│   │   ├── Dashboard/
│   │   └── DataTable/
│   ├── public/
│   └── shared/
│       ├── SpeculationRules.tsx
│       └── WebVitals.tsx
│
├── lib/
│   ├── prisma.ts
│   ├── redis.ts
│   ├── rbac.ts
│   ├── tenant.ts             # [SaaS only]
│   ├── pagination.ts
│   └── web-vitals.ts
│
├── proxy.ts                       # Replaces middleware.ts (Next.js 16)
├── auth.ts
│
├── prisma/
│   ├── schema.prisma
│   ├── seed.ts
│   └── migrations/
│
├── public/
│   ├── fonts/
│   ├── images/
│   └── assets/
│
├── docker/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── nginx.conf
│
└── tests/
    ├── unit/
    ├── integration/
    └── e2e/
```

---

## PRODUCTION DEPLOYMENT

### Docker Multi-Stage Build

```dockerfile
# Stage 1: Dependencies
FROM node:22-alpine AS deps
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN corepack enable && corepack prepare pnpm@latest --activate && pnpm install --frozen-lockfile

# Stage 2: Build
FROM node:22-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npx prisma generate
RUN pnpm build

# Stage 3: Production
FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000
ENV PORT=3000
CMD ["node", "server.js"]
```

### Docker Compose

```yaml
# Docker Compose v2 — 'version' field is deprecated and ignored
services:
  app:
    build: .
    ports: ['3000:3000']
    environment:
      - DATABASE_URL=postgresql://user:pass@postgres:5432/saas
      - REDIS_URL=redis://redis:6379
    depends_on: [postgres, redis]

  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: saas
    volumes: ['pgdata:/var/lib/postgresql/data']
    ports: ['5432:5432']

  redis:
    image: redis:7-alpine
    command: redis-server --maxmemory 256mb --maxmemory-policy allkeys-lru
    ports: ['6379:6379']

  pgbouncer:
    image: edoburu/pgbouncer
    environment:
      DATABASE_URL: postgresql://user:pass@postgres:5432/saas
      POOL_MODE: transaction
      MAX_CLIENT_CONN: 1000
      DEFAULT_POOL_SIZE: 20
    ports: ['6432:6432']
    depends_on: [postgres]

volumes:
  pgdata:
```

### Nginx (Reverse Proxy + Brotli)

```nginx
upstream nextjs {
    server app:3000;
    keepalive 64;
}

server {
    listen 443 quic reuseport;    # HTTP/3 (QUIC)
    listen 443 ssl;
    http3 on;
    server_name platform.com *.platform.com;
    add_header Alt-Svc 'h3=":443"; ma=86400' always;

    ssl_certificate /etc/ssl/cert.pem;
    ssl_certificate_key /etc/ssl/key.pem;

    brotli on;
    brotli_comp_level 6;
    brotli_types text/html text/css application/javascript application/json image/svg+xml;

    location /assets/ {
        proxy_pass http://nextjs;
        add_header Cache-Control "public, max-age=31536000, immutable";
    }

    location /_next/static/ {
        proxy_pass http://nextjs;
        add_header Cache-Control "public, max-age=31536000, immutable";
    }

    location / {
        proxy_pass http://nextjs;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

---

## AI ENFORCED PERFORMANCE RULES (NON-NEGOTIABLE)

1. ALWAYS use React Server Components by default. Only add 'use client' when the component needs browser APIs, event handlers, or React hooks (useState, useEffect).

2. NEVER use raw <img> tags. ALWAYS use next/image with explicit width, height, and appropriate priority/loading attributes.

3. NEVER load fonts via <link> tags. ALWAYS use next/font/local or next/font/google for zero CLS.

4. NEVER serve CSS files > 50KB as render-blocking. Split into critical (inline) and non-critical (async load).

5. ALWAYS implement Suspense boundaries for data-fetching components. Shell must render before data loads.

6. ALWAYS cache database queries in Redis before returning. Every read query must check cache first.

7. [SaaS] ALWAYS include tenant_id in database queries and cache keys. Zero cross-tenant data leakage.
   [Standalone] No tenant_id needed — single-tenant direct queries.

8. ALWAYS use cursor-based pagination for list endpoints. NEVER use offset pagination for large datasets.

9. ALWAYS run bundle analysis before production releases. Enforce size budgets per route.

10. ALWAYS set Cache-Control headers for static assets. Fonts and CSS: immutable, 1 year. Images: 30 days with stale-while-revalidate.

11. NEVER import entire libraries. Use specific imports: import { format } from 'date-fns/format' NOT import { format } from 'date-fns'.

12. ALWAYS use dynamic() for admin components > 20KB (editors, charts, dropdowns, modals).

13. ALWAYS measure performance with web-vitals in production. Alert if any metric degrades.

14. NEVER store sensitive data in public cache or localStorage. Use server-side Redis sessions only.

15. ALWAYS use Prisma $transaction for multiple related queries to reduce database round-trips.

15.5. NEVER use `export const dynamic = 'force-dynamic'` on page components when `cacheComponents: true` is enabled. Use `router.refresh()` for cache busting instead. `force-dynamic` is only valid on API routes (e.g., SSE, health checks).

---

## EXTREME SCALE ADDENDUM — 100K–1M CONCURRENT USERS — [SaaS only]

Target: 100K–1M concurrent users | 70-90% database load reduction | 3-10x speed increase

---

### SCALE TIER MATRIX

```
Tier         │ Concurrent Users │ Next.js Instances │ PostgreSQL        │ Redis           │ PgBouncer
─────────────┼──────────────────┼───────────────────┼───────────────────┼─────────────────┼──────────────
Starter      │ < 1K             │ 1                 │ 1 (single)        │ 1 (standalone)  │ 1
Growth       │ 1K–10K           │ 3–5               │ 1 primary + 1 RR  │ 1 (standalone)  │ 1
Scale        │ 10K–100K         │ 5–20 (HPA)        │ 1 primary + 2 RR  │ 3-node Cluster  │ 2
Enterprise   │ 100K–1M          │ 20–100 (HPA)      │ 1 primary + 4 RR  │ 6-node Cluster  │ 4 (regional)
Hyper-Scale  │ 1M+              │ 100+ (multi-AZ)   │ Sharded + 6 RR    │ 12-node Cluster │ 8 (multi-AZ)
```

RR = Read Replica | HPA = Horizontal Pod Autoscaler

---

### 1. POSTGRESQL READ REPLICAS + CQRS PATTERN — [SaaS only] (↓70-90% DB Load)

PROBLEM: Single PostgreSQL handles both reads AND writes. At 100K+ users, read queries (95% of traffic) saturate the primary.

SOLUTION: Command-Query Responsibility Segregation (CQRS) — route reads to replicas, writes to primary.

```typescript
// lib/prisma.ts — Dual Client Architecture
import { PrismaClient } from '@prisma/client';

// PRIMARY — writes only (INSERT, UPDATE, DELETE)
const primaryUrl = process.env.DATABASE_URL!;

// READ REPLICAS — reads only (SELECT)
const replicaUrl = process.env.DATABASE_REPLICA_URL || primaryUrl;

const globalForPrisma = globalThis as unknown as {
  prismaWrite: PrismaClient;
  prismaRead: PrismaClient;
};

// Write client → Primary
export const prismaWrite =
  globalForPrisma.prismaWrite ??
  new PrismaClient({
    datasources: { db: { url: primaryUrl } },
    log: process.env.NODE_ENV === 'development' ? ['query', 'warn', 'error'] : ['error'],
  });

// Read client → Replica (load-balanced across multiple replicas)
export const prismaRead =
  globalForPrisma.prismaRead ??
  new PrismaClient({
    datasources: { db: { url: replicaUrl } },
    log: process.env.NODE_ENV === 'development' ? ['query'] : ['error'],
  });

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prismaWrite = prismaWrite;
  globalForPrisma.prismaRead = prismaRead;
}

// Convenience: default export for backward compatibility
export default prismaWrite;
```

Usage Pattern:

```typescript
// READ operations → prismaRead (hits replica, NOT primary)
const users = await prismaRead.user.findMany({
  where: { tenantId, status: 'active' },
  orderBy: { createdAt: 'desc' },
  take: 20,
});

// WRITE operations → prismaWrite (hits primary)
const newUser = await prismaWrite.user.create({
  data: { name, email, tenantId },
});
```

Impact: 70-90% of all queries go to replicas → primary handles ONLY writes → primary CPU drops from 90% to 10-20%.

PostgreSQL Streaming Replication Setup:

```sql
-- On PRIMARY:
ALTER SYSTEM SET wal_level = 'replica';
ALTER SYSTEM SET max_wal_senders = 10;
ALTER SYSTEM SET synchronous_commit = 'on'; -- data safety
SELECT pg_reload_conf();

-- On REPLICA:
-- pg_basebackup -h primary -D /var/lib/postgresql/data -U replicator -P -R
-- Replica is read-only by default (hot_standby = on)
```

---

### 2. REDIS CLUSTER + ADVANCED CACHING — [SaaS only] (↓90% DB Load)

PROBLEM: Single Redis node = single point of failure + memory limit (typically 64GB max).

SOLUTION: 6-node Redis Cluster (3 masters + 3 replicas) with intelligent caching.

```typescript
// lib/redis-cluster.ts
import { Cluster } from 'ioredis';

const globalForRedis = globalThis as unknown as { redis: Cluster };

export const redis =
  globalForRedis.redis ??
  new Cluster(
    [
      { host: 'redis-1', port: 6379 },
      { host: 'redis-2', port: 6379 },
      { host: 'redis-3', port: 6379 },
    ],
    {
      scaleReads: 'slave',              // Read from replicas
      redisOptions: {
        maxRetriesPerRequest: 3,
        connectTimeout: 5000,
      },
      clusterRetryStrategy: (times) => Math.min(times * 100, 3000),
      enableOfflineQueue: true,
      natMap: undefined,                // Set for Docker/K8s networking
    },
  );

if (process.env.NODE_ENV !== 'production') {
  globalForRedis.redis = redis;
}

export default redis;
```

Multi-Level Cache Pattern (Cache-Aside + Write-Through):

```typescript
// lib/cache-manager.ts — Enterprise Cache Layer
import redis from '@/lib/redis-cluster';

interface CacheOptions {
  ttl: number;                 // TTL in seconds
  staleWhileRevalidate?: number; // Serve stale while fetching fresh
  tags?: string[];             // For invalidation by tag
}

export async function cachedQuery<T>(
  key: string,
  fetcher: () => Promise<T>,
  options: CacheOptions,
): Promise<T> {
  // 1. Try cache
  const cached = await redis.get(key);

  if (cached) {
    const parsed = JSON.parse(cached);

    // Check if stale (within stale-while-revalidate window)
    if (parsed._cachedAt && options.staleWhileRevalidate) {
      const age = (Date.now() - parsed._cachedAt) / 1000;
      if (age > options.ttl && age < options.ttl + options.staleWhileRevalidate) {
        // Return stale data immediately, refresh in background
        refreshInBackground(key, fetcher, options);
        return parsed.data;
      }
    }

    return parsed.data;
  }

  // 2. Cache miss → fetch from database
  const data = await fetcher();

  // 3. Write to cache (non-blocking)
  const cachePayload = JSON.stringify({ data, _cachedAt: Date.now() });
  redis.setex(key, options.ttl + (options.staleWhileRevalidate || 0), cachePayload);

  // 4. Register cache tags for bulk invalidation
  if (options.tags) {
    const pipeline = redis.pipeline();
    for (const tag of options.tags) {
      pipeline.sadd(`tag:${tag}`, key);
      pipeline.expire(`tag:${tag}`, options.ttl * 2);
    }
    pipeline.exec();
  }

  return data;
}

async function refreshInBackground<T>(
  key: string,
  fetcher: () => Promise<T>,
  options: CacheOptions,
): Promise<void> {
  // Prevent stampede: only one refresh at a time
  const lockKey = `lock:refresh:${key}`;
  const locked = await redis.set(lockKey, '1', 'EX', 30, 'NX');
  if (!locked) return; // Another instance is already refreshing

  try {
    const data = await fetcher();
    const cachePayload = JSON.stringify({ data, _cachedAt: Date.now() });
    await redis.setex(key, options.ttl + (options.staleWhileRevalidate || 0), cachePayload);
  } finally {
    await redis.del(lockKey);
  }
}

// Tag-based invalidation (invalidate all keys with a tag)
export async function invalidateByTag(tag: string): Promise<void> {
  const keys = await redis.smembers(`tag:${tag}`);
  if (keys.length > 0) {
    const pipeline = redis.pipeline();
    for (const key of keys) {
      pipeline.del(key);
    }
    pipeline.del(`tag:${tag}`);
    await pipeline.exec();
  }
}
```

Usage:

```typescript
// Dashboard data — 30s cache, serve stale for 5min while refreshing
const stats = await cachedQuery(
  `tenant:${tenantId}:dashboard:stats`,
  () => prismaRead.user.count({ where: { tenantId, status: 'active' } }),
  { ttl: 30, staleWhileRevalidate: 300, tags: [`tenant:${tenantId}`] },
);

// On user create/update → invalidate tenant cache
await invalidateByTag(`tenant:${tenantId}`);
```

---

### 3. QUEUE-BASED PROCESSING — [SaaS recommended, Standalone optional] (Non-Blocking Writes)

PROBLEM: Heavy operations (email sending, PDF generation, audit logging, analytics) block request threads.

SOLUTION: BullMQ (Redis-backed job queue) for async background processing.

```typescript
// lib/queue.ts
import { Queue, Worker, QueueEvents } from 'bullmq';
import redis from '@/lib/redis-cluster';

// Define queues
export const emailQueue = new Queue('emails', { connection: redis });
export const auditQueue = new Queue('audit-logs', { connection: redis });
export const analyticsQueue = new Queue('analytics', { connection: redis });
export const webhookQueue = new Queue('webhooks', { connection: redis });

// Worker processes (run in separate Node.js process)
// workers/email.worker.ts
const emailWorker = new Worker(
  'emails',
  async (job) => {
    const { to, subject, template, data } = job.data;
    await sendEmail(to, subject, template, data);
  },
  {
    connection: redis,
    concurrency: 10,        // 10 concurrent email sends
    limiter: {
      max: 100,             // Max 100 emails per minute
      duration: 60000,
    },
  },
);

// Usage in Server Actions (non-blocking):
export async function createUser(formData: FormData) {
  const user = await prismaWrite.user.create({ data: parsed.data });

  // Non-blocking: queue email instead of awaiting it
  await emailQueue.add('welcome', {
    to: user.email,
    subject: 'Welcome!',
    template: 'welcome',
    data: { name: user.name },
  });

  // Non-blocking: queue audit log
  await auditQueue.add('user.created', {
    userId: user.id,
    tenantId,
    action: 'user.created',
    timestamp: Date.now(),
  });

  // Response returns immediately — user doesn't wait for email/audit
  return { success: true, user };
}
```

Impact: Request response time ↓ 60-80% for write operations.

---

### 4. CDN FULL-PAGE CACHE + STALE-WHILE-REVALIDATE

PROBLEM: Even with SSG/ISR, origin server is hit on cache miss.

SOLUTION: CDN full-page caching with stale-while-revalidate for public pages.

```typescript
// app/(public)/blog/[slug]/page.tsx
export const revalidate = 3600; // ISR: 1 hour

// Next.js headers for CDN
export async function generateMetadata({ params }: Props) {
  return {
    other: {
      // Cloudflare/CDN will cache this page
      'Cache-Control': 'public, s-maxage=3600, stale-while-revalidate=86400',
      'CDN-Cache-Control': 'public, max-age=3600',
      'Cloudflare-CDN-Cache-Control': 'public, max-age=3600',
    },
  };
}
```

Cloudflare Page Rules:

```
URL Pattern: *.platform.com/blog/*
  Cache Level: Cache Everything
  Edge Cache TTL: 1 hour
  Browser Cache TTL: 5 minutes

URL Pattern: *.platform.com/pricing*
  Cache Level: Cache Everything
  Edge Cache TTL: 24 hours

URL Pattern: *.platform.com/admin/*
  Cache Level: Bypass (NEVER cache admin pages at CDN)
```

Impact: 95%+ of public page requests served from CDN edge (< 20ms) → origin server handles only 5% of requests.

---

### 5. ADVANCED RATE LIMITING (DDoS + Abuse Protection)

```typescript
// lib/rate-limiter.ts — Sliding Window + Token Bucket Hybrid
import redis from '@/lib/redis-cluster';

interface RateLimitResult {
  allowed: boolean;
  remaining: number;
  resetAt: number;
}

export async function checkRateLimit(
  identifier: string,  // user ID, IP, or tenant ID
  maxRequests: number,
  windowSeconds: number,
): Promise<RateLimitResult> {
  const key = `rate:${identifier}`;
  const now = Date.now();
  const windowMs = windowSeconds * 1000;

  // Sliding window with Redis sorted set
  const pipeline = redis.pipeline();
  pipeline.zremrangebyscore(key, 0, now - windowMs);   // Remove expired entries
  pipeline.zadd(key, now.toString(), `${now}:${Math.random()}`); // Add current request
  pipeline.zcard(key);                                  // Count requests in window
  pipeline.expire(key, windowSeconds);                  // Auto-cleanup

  const results = await pipeline.exec();
  const requestCount = results?.[2]?.[1] as number;

  return {
    allowed: requestCount <= maxRequests,
    remaining: Math.max(0, maxRequests - requestCount),
    resetAt: now + windowMs,
  };
}

// Rate limit tiers:
// Anonymous:     30 req/min per IP
// Authenticated: 100 req/min per user
// Tenant API:    1000 req/min per tenant
// Super Admin:   Unlimited
```

---

### 6. HORIZONTAL AUTO-SCALING (Kubernetes HPA)

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nextjs-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nextjs
  template:
    metadata:
      labels:
        app: nextjs
    spec:
      containers:
        - name: nextjs
          image: registry.example.com/saas-app:latest
          ports:
            - containerPort: 3000
          resources:
            requests:
              cpu: '250m'
              memory: '256Mi'
            limits:
              cpu: '1000m'
              memory: '1Gi'
          readinessProbe:
            httpGet:
              path: /api/health
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /api/health
              port: 3000
            initialDelaySeconds: 15
            periodSeconds: 20
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: db-secrets
                  key: primary-url
            - name: DATABASE_REPLICA_URL
              valueFrom:
                secretKeyRef:
                  name: db-secrets
                  key: replica-url
            - name: REDIS_URL
              valueFrom:
                secretKeyRef:
                  name: redis-secrets
                  key: cluster-url
---
# Horizontal Pod Autoscaler
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nextjs-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nextjs-app
  minReplicas: 3
  maxReplicas: 100
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 70
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 30
      policies:
        - type: Percent
          value: 100       # Double pods on spike
          periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Percent
          value: 10        # Scale down slowly
          periodSeconds: 60
```

Health Check Endpoint:

```typescript
// app/api/health/route.ts
import { prismaRead } from '@/lib/prisma';
import redis from '@/lib/redis-cluster';

export async function GET() {
  try {
    // Check database connectivity
    await prismaRead.$queryRaw`SELECT 1`;
    // Check Redis connectivity
    await redis.ping();

    return Response.json({ status: 'healthy', timestamp: Date.now() }, { status: 200 });
  } catch (error) {
    return Response.json({ status: 'unhealthy', error: String(error) }, { status: 503 });
  }
}
```

---

### 7. DATABASE SHARDING STRATEGY — [SaaS only] (1M+ Users)

When single PostgreSQL reaches limits (even with replicas), implement horizontal sharding:

```
Sharding Strategy: Tenant-Based Hash Sharding

Tenant ID → hash(tenant_id) % N_SHARDS → Shard N

Shard 0: tenants A-F   → pg-shard-0.cluster
Shard 1: tenants G-L   → pg-shard-1.cluster
Shard 2: tenants M-R   → pg-shard-2.cluster
Shard 3: tenants S-Z   → pg-shard-3.cluster

Each shard has 1 primary + 2 read replicas = 12 PostgreSQL instances total.
```

Shard Router:

```typescript
// lib/shard-router.ts
import { PrismaClient } from '@prisma/client';
import crypto from 'crypto';

const SHARD_COUNT = 4;

const shardClients: PrismaClient[] = [
  new PrismaClient({ datasources: { db: { url: process.env.SHARD_0_URL } } }),
  new PrismaClient({ datasources: { db: { url: process.env.SHARD_1_URL } } }),
  new PrismaClient({ datasources: { db: { url: process.env.SHARD_2_URL } } }),
  new PrismaClient({ datasources: { db: { url: process.env.SHARD_3_URL } } }),
];

export function getShardForTenant(tenantId: string): PrismaClient {
  const hash = crypto.createHash('md5').update(tenantId).digest();
  const shardIndex = hash.readUInt32BE(0) % SHARD_COUNT;
  return shardClients[shardIndex];
}

// Usage:
const db = getShardForTenant(tenantId);
const users = await db.user.findMany({ where: { tenantId } });
```

---

### 8. PRODUCTION DOCKER COMPOSE — [SaaS only] (SCALE-READY)

```yaml
# docker-compose.scale.yml
# Docker Compose v2 — 'version' field is deprecated and ignored

services:
  # ── App Layer (scale horizontally) ──────────────────
  app:
    build: .
    deploy:
      replicas: 5
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
    environment:
      - DATABASE_URL=postgresql://user:pass@pgbouncer:6432/saas?pgbouncer=true&connection_limit=5
      - DATABASE_REPLICA_URL=postgresql://user:pass@pgbouncer-replica:6432/saas?pgbouncer=true&connection_limit=10
      - REDIS_URL=redis://redis-master:6379
    depends_on: [pgbouncer, pgbouncer-replica, redis-master]

  # ── Queue Workers (separate from web servers) ──────
  worker:
    build: .
    command: node workers/index.js
    deploy:
      replicas: 3
    environment:
      - DATABASE_URL=postgresql://user:pass@pgbouncer:6432/saas
      - REDIS_URL=redis://redis-master:6379

  # ── Load Balancer ──────────────────────────────────
  nginx:
    image: nginx:alpine
    ports: ['80:80', '443:443']
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
    depends_on: [app]

  # ── Database Primary ───────────────────────────────
  postgres-primary:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: saas
    volumes:
      - pgdata-primary:/var/lib/postgresql/data
      - ./postgres/primary.conf:/etc/postgresql/postgresql.conf
    command: postgres -c config_file=/etc/postgresql/postgresql.conf

  # ── Database Replica ───────────────────────────────
  postgres-replica:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - pgdata-replica:/var/lib/postgresql/data
    depends_on: [postgres-primary]

  # ── PgBouncer Primary ──────────────────────────────
  pgbouncer:
    image: edoburu/pgbouncer
    environment:
      DATABASE_URL: postgresql://user:pass@postgres-primary:5432/saas
      POOL_MODE: transaction
      MAX_CLIENT_CONN: 2000
      DEFAULT_POOL_SIZE: 30
    depends_on: [postgres-primary]

  # ── PgBouncer Replica ──────────────────────────────
  pgbouncer-replica:
    image: edoburu/pgbouncer
    environment:
      DATABASE_URL: postgresql://user:pass@postgres-replica:5432/saas
      POOL_MODE: transaction
      MAX_CLIENT_CONN: 5000
      DEFAULT_POOL_SIZE: 50
    depends_on: [postgres-replica]

  # ── Redis Cluster ──────────────────────────────────
  redis-master:
    image: redis:7-alpine
    command: >
      redis-server
      --maxmemory 2gb
      --maxmemory-policy allkeys-lru
      --save 900 1
      --appendonly yes
    volumes:
      - redis-data:/data

  redis-replica:
    image: redis:7-alpine
    command: redis-server --replicaof redis-master 6379 --maxmemory 2gb
    depends_on: [redis-master]

volumes:
  pgdata-primary:
  pgdata-replica:
  redis-data:
```

---

### 9. PERFORMANCE IMPACT SUMMARY

```
Technique                     │ DB Load ↓  │ Speed ↑  │ Concurrency ↑
──────────────────────────────┼────────────┼──────────┼──────────────
PostgreSQL Read Replicas      │ -70%       │ 2x       │ 3x
Redis Cluster Cache           │ -90%       │ 5-10x    │ 10x
CDN Full-Page Cache (public)  │ -95%       │ 10x      │ 50x
Stale-While-Revalidate        │ -80%       │ 3x       │ 5x
Queue-Based Processing        │ -30%       │ 3x       │ 2x
Connection Pooling (PgBouncer)│ -20%       │ 1.5x     │ 5x
Kubernetes HPA                │ N/A        │ N/A      │ 100x
Database Sharding             │ Linear ↓   │ 2x       │ Linear ↑
```

Combined Impact (all techniques):
- Database load: ↓ 90-95% (Redis + Replicas + CDN absorb 95% of reads)
- Website speed: ↑ 5-10x (CDN edge + Redis < 5ms + streaming)
- Concurrent users: 100K–1M (HPA + replicas + Redis Cluster)

---

### 10. UPDATED SCALE-AWARE PERFORMANCE TARGETS

| Metric | Previous Target | New Target (Scale) | How |
|:---|:---:|:---:|:---|
| TTFB | < 80ms | < 30ms | CDN edge + Redis Cluster |
| LCP | < 1.5s | < 0.8s | CDN full-page + Critical CSS inline |
| Lighthouse | > 95 | > 98 | All optimizations combined |
| API p99 | < 80ms | < 50ms | Read replicas + Redis cache |
| DB queries/sec | ~500 qps | ~50 qps (to DB) | 90% served from cache |
| Concurrent users | ~10K | 100K–1M | HPA + event-driven + CDN |
| Cache hit ratio | ~60% | > 95% | Stale-while-revalidate + tags |
| Write throughput | Sync | Async (queued) | BullMQ background workers |

---

### 11. ADDITIONAL AI ENFORCED RULES (SCALE-SPECIFIC)

16. [SaaS] ALWAYS use prismaRead for SELECT and prismaWrite for mutations. NEVER read from primary.
    [Standalone] Use single prisma client for all queries.

17. ALWAYS implement stale-while-revalidate pattern for cached data. Users must NEVER wait for cache refresh.

18. ALWAYS use Redis pipeline or $transaction for bulk operations. NEVER send individual Redis commands in a loop.

19. ALWAYS queue non-critical operations (emails, audit logs, analytics, webhooks). NEVER block request threads with side effects.

20. ALWAYS implement cache stampede protection with distributed locks. NEVER allow multiple instances to refresh the same cache key simultaneously.

21. ALWAYS set up health check endpoints for load balancers. NEVER deploy without readiness and liveness probes.

22. ALWAYS use tag-based cache invalidation instead of pattern-based (KEYS command). KEYS blocks Redis at scale.

23. ALWAYS implement graceful degradation: if Redis is down, serve from DB directly. If replica is down, fall back to primary. NEVER crash on infrastructure failure.

---

END OF ARCHITECTURE SPECIFICATION (v4.0 EXTREME SCALE)

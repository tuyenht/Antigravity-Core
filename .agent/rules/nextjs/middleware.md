# Next.js Middleware & Edge Functions Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **Next.js:** 14.x / 15.x  
> **Priority:** P0 - Load for all middleware tasks

---

You are an expert in Next.js Middleware and Edge Functions.

## Core Middleware Principles

- Use middleware for request/response manipulation
- Run logic before request completes
- Use Edge Runtime for global performance
- Keep middleware lightweight

---

## 1) Middleware Basics

### Complete Middleware Setup
```typescript
// ==========================================
// middleware.ts (root directory)
// ==========================================

import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  
  // Get response to modify
  const response = NextResponse.next();
  
  // Add request ID for tracing
  const requestId = crypto.randomUUID();
  response.headers.set('x-request-id', requestId);
  
  // Add security headers
  response.headers.set('X-Frame-Options', 'DENY');
  response.headers.set('X-Content-Type-Options', 'nosniff');
  response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');
  
  // Log request (appears in server console)
  console.log(`[${requestId}] ${request.method} ${pathname}`);
  
  return response;
}

// Configure which routes use middleware
export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - api (API routes)
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - public folder
     */
    '/((?!api|_next/static|_next/image|favicon.ico|.*\\..*$).*)',
  ],
};
```

### Matcher Patterns
```typescript
// ==========================================
// MATCHER CONFIGURATION OPTIONS
// ==========================================

// Single path
export const config = {
  matcher: '/about',
};

// Multiple paths
export const config = {
  matcher: ['/about', '/contact', '/blog'],
};

// Glob patterns
export const config = {
  matcher: [
    '/blog/:path*',      // Match /blog/anything
    '/api/:function*',   // Match /api/anything
  ],
};

// Regex-like patterns
export const config = {
  matcher: [
    '/((?!api|_next/static|_next/image|favicon.ico).*)',
  ],
};

// With params
export const config = {
  matcher: [
    '/dashboard/:path*',
    '/admin/:path*',
    '/user/:id/settings',
  ],
};

// Conditional matching in middleware
export function middleware(request: NextRequest) {
  const pathname = request.nextUrl.pathname;
  
  // Skip static files manually
  if (
    pathname.startsWith('/_next') ||
    pathname.startsWith('/api') ||
    pathname.includes('.') // Has file extension
  ) {
    return NextResponse.next();
  }
  
  // Continue with logic
}
```

---

## 2) Authentication Middleware

### Complete Auth Middleware
```typescript
// ==========================================
// middleware.ts - Authentication
// ==========================================

import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { getToken } from 'next-auth/jwt';

// Routes that require authentication
const protectedRoutes = ['/dashboard', '/settings', '/profile', '/admin'];

// Routes only for unauthenticated users
const authRoutes = ['/login', '/signup', '/forgot-password'];

// Role-based route access
const roleRoutes: Record<string, string[]> = {
  admin: ['/admin'],
  moderator: ['/admin/posts', '/admin/comments'],
};

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  
  // Get session token
  const token = await getToken({
    req: request,
    secret: process.env.NEXTAUTH_SECRET,
  });
  
  const isAuthenticated = !!token;
  const userRole = token?.role as string | undefined;
  
  // Check if route is protected
  const isProtectedRoute = protectedRoutes.some(route => 
    pathname.startsWith(route)
  );
  
  // Check if route is auth-only (login, signup)
  const isAuthRoute = authRoutes.some(route => 
    pathname.startsWith(route)
  );
  
  // Redirect to login if accessing protected route without auth
  if (isProtectedRoute && !isAuthenticated) {
    const loginUrl = new URL('/login', request.url);
    loginUrl.searchParams.set('callbackUrl', pathname);
    return NextResponse.redirect(loginUrl);
  }
  
  // Redirect to dashboard if already authenticated and accessing auth routes
  if (isAuthRoute && isAuthenticated) {
    return NextResponse.redirect(new URL('/dashboard', request.url));
  }
  
  // Role-based access control
  if (isAuthenticated && userRole) {
    for (const [role, routes] of Object.entries(roleRoutes)) {
      const requiresRole = routes.some(route => pathname.startsWith(route));
      
      if (requiresRole && userRole !== role && userRole !== 'admin') {
        // Redirect to unauthorized page
        return NextResponse.redirect(new URL('/unauthorized', request.url));
      }
    }
  }
  
  // Add user info to headers for server components
  const response = NextResponse.next();
  
  if (isAuthenticated && token) {
    response.headers.set('x-user-id', token.sub || '');
    response.headers.set('x-user-role', userRole || 'user');
  }
  
  return response;
}

export const config = {
  matcher: [
    '/dashboard/:path*',
    '/settings/:path*',
    '/profile/:path*',
    '/admin/:path*',
    '/login',
    '/signup',
    '/forgot-password',
  ],
};


// ==========================================
// API KEY AUTHENTICATION
// ==========================================

export async function middleware(request: NextRequest) {
  const pathname = request.nextUrl.pathname;
  
  // Only check API routes
  if (!pathname.startsWith('/api')) {
    return NextResponse.next();
  }
  
  // Public API routes
  const publicApiRoutes = ['/api/health', '/api/public'];
  if (publicApiRoutes.some(route => pathname.startsWith(route))) {
    return NextResponse.next();
  }
  
  // Check API key
  const apiKey = request.headers.get('x-api-key');
  
  if (!apiKey) {
    return NextResponse.json(
      { error: 'API key required' },
      { status: 401 }
    );
  }
  
  // Validate API key (in production, check against database)
  const validApiKeys = process.env.VALID_API_KEYS?.split(',') || [];
  
  if (!validApiKeys.includes(apiKey)) {
    return NextResponse.json(
      { error: 'Invalid API key' },
      { status: 403 }
    );
  }
  
  return NextResponse.next();
}
```

---

## 3) Redirects & Rewrites

### URL Manipulation
```typescript
// ==========================================
// REDIRECTS
// ==========================================

import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  
  // Permanent redirect (301)
  if (pathname === '/old-page') {
    return NextResponse.redirect(new URL('/new-page', request.url), 301);
  }
  
  // Temporary redirect (307)
  if (pathname === '/maintenance') {
    return NextResponse.redirect(new URL('/coming-soon', request.url), 307);
  }
  
  // Redirect with query params
  if (pathname === '/search-old') {
    const url = new URL('/search', request.url);
    url.searchParams.set('source', 'redirect');
    return NextResponse.redirect(url);
  }
  
  // External redirect
  if (pathname === '/github') {
    return NextResponse.redirect('https://github.com/myapp');
  }
  
  // Redirect trailing slashes
  if (pathname !== '/' && pathname.endsWith('/')) {
    return NextResponse.redirect(
      new URL(pathname.slice(0, -1), request.url),
      308
    );
  }
  
  return NextResponse.next();
}


// ==========================================
// REWRITES (URL stays the same)
// ==========================================

export function middleware(request: NextRequest) {
  const { pathname, searchParams } = request.nextUrl;
  
  // Rewrite to different page (URL stays same)
  if (pathname === '/about') {
    return NextResponse.rewrite(new URL('/about-v2', request.url));
  }
  
  // Rewrite to external API
  if (pathname.startsWith('/api/proxy/')) {
    const apiPath = pathname.replace('/api/proxy', '');
    return NextResponse.rewrite(`https://api.external.com${apiPath}`);
  }
  
  // Multi-tenant routing
  const host = request.headers.get('host') || '';
  const subdomain = host.split('.')[0];
  
  if (subdomain !== 'www' && subdomain !== 'myapp') {
    // Rewrite tenant.myapp.com/page to /tenant/page
    return NextResponse.rewrite(
      new URL(`/${subdomain}${pathname}`, request.url)
    );
  }
  
  return NextResponse.next();
}


// ==========================================
// LEGACY URL HANDLING
// ==========================================

const legacyRedirects: Record<string, string> = {
  '/blog/old-post-slug': '/posts/new-post-slug',
  '/products/old-sku': '/shop/new-sku',
  '/team': '/about/team',
  '/careers': '/about/careers',
};

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  
  // Check legacy redirects
  if (pathname in legacyRedirects) {
    return NextResponse.redirect(
      new URL(legacyRedirects[pathname], request.url),
      301
    );
  }
  
  // Pattern-based legacy redirects
  const blogMatch = pathname.match(/^\/blog\/(\d{4})\/(\d{2})\/(.+)$/);
  if (blogMatch) {
    const [, year, month, slug] = blogMatch;
    return NextResponse.redirect(
      new URL(`/posts/${slug}`, request.url),
      301
    );
  }
  
  return NextResponse.next();
}
```

---

## 4) Geolocation & Personalization

### Geo-Based Routing
```typescript
// ==========================================
// GEOLOCATION MIDDLEWARE
// ==========================================

import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  // Get geolocation (available on Vercel)
  const country = request.geo?.country || 'US';
  const city = request.geo?.city || 'Unknown';
  const region = request.geo?.region || 'Unknown';
  
  const response = NextResponse.next();
  
  // Add geo headers for server components
  response.headers.set('x-user-country', country);
  response.headers.set('x-user-city', city);
  response.headers.set('x-user-region', region);
  
  return response;
}


// ==========================================
// COUNTRY-BASED REDIRECTS
// ==========================================

const countryRedirects: Record<string, string> = {
  DE: '/de',  // Germany -> German site
  FR: '/fr',  // France -> French site
  ES: '/es',  // Spain -> Spanish site
  JP: '/ja',  // Japan -> Japanese site
};

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const country = request.geo?.country || 'US';
  
  // Skip if already on localized path
  const locales = ['de', 'fr', 'es', 'ja'];
  const hasLocale = locales.some(locale => 
    pathname.startsWith(`/${locale}`)
  );
  
  if (hasLocale) {
    return NextResponse.next();
  }
  
  // Check for redirect preference cookie
  const hasPreference = request.cookies.get('locale-preference');
  if (hasPreference) {
    return NextResponse.next();
  }
  
  // Redirect based on country
  if (country in countryRedirects) {
    const url = new URL(countryRedirects[country] + pathname, request.url);
    return NextResponse.redirect(url);
  }
  
  return NextResponse.next();
}


// ==========================================
// GDPR COMPLIANCE
// ==========================================

const euCountries = [
  'AT', 'BE', 'BG', 'HR', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR',
  'DE', 'GR', 'HU', 'IE', 'IT', 'LV', 'LT', 'LU', 'MT', 'NL',
  'PL', 'PT', 'RO', 'SK', 'SI', 'ES', 'SE',
];

export function middleware(request: NextRequest) {
  const country = request.geo?.country || 'US';
  const isEU = euCountries.includes(country);
  
  const response = NextResponse.next();
  
  // Add EU flag for consent requirements
  response.headers.set('x-is-eu', isEU.toString());
  
  // Block certain features in EU without consent
  if (isEU && !request.cookies.get('gdpr-consent')) {
    response.headers.set('x-tracking-allowed', 'false');
  }
  
  return response;
}
```

---

## 5) A/B Testing

### Experiment Middleware
```typescript
// ==========================================
// A/B TESTING MIDDLEWARE
// ==========================================

import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

interface Experiment {
  name: string;
  variants: string[];
  weights?: number[];  // Optional weights for each variant
}

const experiments: Experiment[] = [
  {
    name: 'homepage-hero',
    variants: ['control', 'variant-a', 'variant-b'],
    weights: [0.5, 0.25, 0.25],
  },
  {
    name: 'pricing-layout',
    variants: ['control', 'new-layout'],
  },
];

function getVariant(experiment: Experiment, userId: string): string {
  // Deterministic assignment based on user ID
  const hash = hashString(userId + experiment.name);
  const normalized = hash / 0xffffffff;
  
  const weights = experiment.weights || 
    experiment.variants.map(() => 1 / experiment.variants.length);
  
  let cumulative = 0;
  for (let i = 0; i < weights.length; i++) {
    cumulative += weights[i];
    if (normalized < cumulative) {
      return experiment.variants[i];
    }
  }
  
  return experiment.variants[0];
}

function hashString(str: string): number {
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    const char = str.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash;
  }
  return Math.abs(hash);
}

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  
  // Get or create user ID
  let userId = request.cookies.get('user-id')?.value;
  const response = NextResponse.next();
  
  if (!userId) {
    userId = crypto.randomUUID();
    response.cookies.set('user-id', userId, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      maxAge: 60 * 60 * 24 * 365, // 1 year
    });
  }
  
  // Assign variants for each experiment
  const assignments: Record<string, string> = {};
  
  for (const experiment of experiments) {
    const existingVariant = request.cookies.get(`exp-${experiment.name}`)?.value;
    
    if (existingVariant && experiment.variants.includes(existingVariant)) {
      assignments[experiment.name] = existingVariant;
    } else {
      const variant = getVariant(experiment, userId);
      assignments[experiment.name] = variant;
      
      response.cookies.set(`exp-${experiment.name}`, variant, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'lax',
        maxAge: 60 * 60 * 24 * 30, // 30 days
      });
    }
  }
  
  // Add assignments to headers for server components
  response.headers.set('x-experiments', JSON.stringify(assignments));
  
  // Rewrite to variant page if needed
  if (pathname === '/' && assignments['homepage-hero'] !== 'control') {
    const variant = assignments['homepage-hero'];
    return NextResponse.rewrite(
      new URL(`/experiments/homepage/${variant}`, request.url),
      { headers: response.headers }
    );
  }
  
  return response;
}
```

---

## 6) Rate Limiting

### Edge Rate Limiting
```typescript
// ==========================================
// RATE LIMITING WITH UPSTASH
// ==========================================

import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';

// Create rate limiter
const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(100, '1 m'),  // 100 requests per minute
  analytics: true,
});

// Different limits for different routes
const rateLimiters = {
  api: new Ratelimit({
    redis: Redis.fromEnv(),
    limiter: Ratelimit.slidingWindow(100, '1 m'),
    prefix: 'rl:api',
  }),
  auth: new Ratelimit({
    redis: Redis.fromEnv(),
    limiter: Ratelimit.slidingWindow(10, '1 m'),
    prefix: 'rl:auth',
  }),
  upload: new Ratelimit({
    redis: Redis.fromEnv(),
    limiter: Ratelimit.slidingWindow(10, '1 h'),
    prefix: 'rl:upload',
  }),
};

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  
  // Get client identifier
  const ip = request.ip ?? request.headers.get('x-forwarded-for') ?? '127.0.0.1';
  
  // Select rate limiter based on route
  let limiter = rateLimiters.api;
  
  if (pathname.startsWith('/api/auth')) {
    limiter = rateLimiters.auth;
  } else if (pathname.startsWith('/api/upload')) {
    limiter = rateLimiters.upload;
  }
  
  // Check rate limit
  const { success, limit, remaining, reset } = await limiter.limit(ip);
  
  if (!success) {
    return NextResponse.json(
      { 
        error: 'Too many requests',
        retryAfter: Math.ceil((reset - Date.now()) / 1000),
      },
      {
        status: 429,
        headers: {
          'X-RateLimit-Limit': limit.toString(),
          'X-RateLimit-Remaining': '0',
          'X-RateLimit-Reset': reset.toString(),
          'Retry-After': Math.ceil((reset - Date.now()) / 1000).toString(),
        },
      }
    );
  }
  
  // Add rate limit headers to response
  const response = NextResponse.next();
  response.headers.set('X-RateLimit-Limit', limit.toString());
  response.headers.set('X-RateLimit-Remaining', remaining.toString());
  response.headers.set('X-RateLimit-Reset', reset.toString());
  
  return response;
}

export const config = {
  matcher: '/api/:path*',
};
```

---

## 7) Security Middleware

### Comprehensive Security
```typescript
// ==========================================
// SECURITY MIDDLEWARE
// ==========================================

import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const response = NextResponse.next();
  const { pathname } = request.nextUrl;
  
  // ==========================================
  // SECURITY HEADERS
  // ==========================================
  
  // Prevent clickjacking
  response.headers.set('X-Frame-Options', 'DENY');
  
  // Prevent MIME type sniffing
  response.headers.set('X-Content-Type-Options', 'nosniff');
  
  // XSS Protection
  response.headers.set('X-XSS-Protection', '1; mode=block');
  
  // Referrer Policy
  response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');
  
  // HSTS (only in production)
  if (process.env.NODE_ENV === 'production') {
    response.headers.set(
      'Strict-Transport-Security',
      'max-age=31536000; includeSubDomains; preload'
    );
  }
  
  // Permissions Policy
  response.headers.set(
    'Permissions-Policy',
    'camera=(), microphone=(), geolocation=(), interest-cohort=()'
  );
  
  // Content Security Policy
  const csp = [
    "default-src 'self'",
    "script-src 'self' 'unsafe-eval' 'unsafe-inline' https://www.googletagmanager.com",
    "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com",
    "img-src 'self' blob: data: https:",
    "font-src 'self' https://fonts.gstatic.com",
    "connect-src 'self' https://vitals.vercel-insights.com",
    "frame-ancestors 'none'",
    "form-action 'self'",
    "base-uri 'self'",
  ].join('; ');
  
  response.headers.set('Content-Security-Policy', csp);
  
  // ==========================================
  // BOT DETECTION
  // ==========================================
  
  const userAgent = request.headers.get('user-agent') || '';
  const suspiciousPatterns = [
    /bot/i,
    /crawler/i,
    /spider/i,
    /scraper/i,
    /curl/i,
    /wget/i,
  ];
  
  const isBot = suspiciousPatterns.some(pattern => pattern.test(userAgent));
  
  if (isBot && pathname.startsWith('/api') && !pathname.startsWith('/api/public')) {
    return NextResponse.json(
      { error: 'Bot access denied' },
      { status: 403 }
    );
  }
  
  // ==========================================
  // CORS HANDLING
  // ==========================================
  
  if (pathname.startsWith('/api')) {
    const origin = request.headers.get('origin');
    const allowedOrigins = [
      'https://myapp.com',
      'https://www.myapp.com',
      process.env.NODE_ENV === 'development' && 'http://localhost:3000',
    ].filter(Boolean);
    
    if (origin && allowedOrigins.includes(origin)) {
      response.headers.set('Access-Control-Allow-Origin', origin);
      response.headers.set('Access-Control-Allow-Credentials', 'true');
      response.headers.set(
        'Access-Control-Allow-Methods',
        'GET, POST, PUT, DELETE, OPTIONS'
      );
      response.headers.set(
        'Access-Control-Allow-Headers',
        'Content-Type, Authorization, X-Requested-With'
      );
    }
    
    // Handle preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        status: 204,
        headers: response.headers,
      });
    }
  }
  
  return response;
}
```

---

## 8) Edge Functions

### Edge API Routes
```typescript
// ==========================================
// app/api/edge/hello/route.ts
// ==========================================

import { NextRequest, NextResponse } from 'next/server';

export const runtime = 'edge';

export async function GET(request: NextRequest) {
  const country = request.geo?.country || 'Unknown';
  const city = request.geo?.city || 'Unknown';
  
  return NextResponse.json({
    message: 'Hello from the Edge!',
    location: { country, city },
    timestamp: new Date().toISOString(),
  });
}


// ==========================================
// STREAMING FROM EDGE
// ==========================================

// app/api/edge/stream/route.ts
export const runtime = 'edge';

export async function GET() {
  const encoder = new TextEncoder();
  
  const stream = new ReadableStream({
    async start(controller) {
      for (let i = 0; i < 10; i++) {
        const chunk = encoder.encode(`data: Message ${i + 1}\n\n`);
        controller.enqueue(chunk);
        await new Promise(resolve => setTimeout(resolve, 500));
      }
      controller.close();
    },
  });
  
  return new Response(stream, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    },
  });
}


// ==========================================
// EDGE CONFIG INTEGRATION
// ==========================================

// app/api/edge/config/route.ts
import { get } from '@vercel/edge-config';

export const runtime = 'edge';

export async function GET() {
  const maintenanceMode = await get<boolean>('maintenanceMode');
  const featureFlags = await get<Record<string, boolean>>('featureFlags');
  
  return NextResponse.json({
    maintenanceMode,
    featureFlags,
  });
}


// ==========================================
// EDGE OG IMAGE GENERATION
// ==========================================

// app/api/og/route.tsx
import { ImageResponse } from 'next/og';

export const runtime = 'edge';

export async function GET(request: NextRequest) {
  const { searchParams } = request.nextUrl;
  const title = searchParams.get('title') || 'Default Title';
  
  return new ImageResponse(
    (
      <div
        style={{
          display: 'flex',
          height: '100%',
          width: '100%',
          backgroundColor: '#000',
          color: '#fff',
          fontSize: 48,
          justifyContent: 'center',
          alignItems: 'center',
        }}
      >
        {title}
      </div>
    ),
    {
      width: 1200,
      height: 630,
    }
  );
}
```

---

## 9) Complete Middleware Example

### Production-Ready Middleware
```typescript
// ==========================================
// middleware.ts - COMPLETE EXAMPLE
// ==========================================

import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { getToken } from 'next-auth/jwt';

// Configuration
const protectedRoutes = ['/dashboard', '/settings', '/admin'];
const authRoutes = ['/login', '/signup'];
const apiRateLimit = 100;  // requests per minute

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const response = NextResponse.next();
  
  // ==========================================
  // 1. ADD SECURITY HEADERS
  // ==========================================
  
  response.headers.set('X-Frame-Options', 'DENY');
  response.headers.set('X-Content-Type-Options', 'nosniff');
  response.headers.set('X-XSS-Protection', '1; mode=block');
  response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');
  
  // ==========================================
  // 2. ADD REQUEST ID
  // ==========================================
  
  const requestId = crypto.randomUUID();
  response.headers.set('x-request-id', requestId);
  
  // ==========================================
  // 3. GEOLOCATION HEADERS
  // ==========================================
  
  response.headers.set('x-country', request.geo?.country || 'US');
  response.headers.set('x-city', request.geo?.city || 'Unknown');
  
  // ==========================================
  // 4. AUTHENTICATION CHECK
  // ==========================================
  
  const token = await getToken({
    req: request,
    secret: process.env.NEXTAUTH_SECRET,
  });
  
  const isAuthenticated = !!token;
  
  // Protect routes
  const isProtectedRoute = protectedRoutes.some(route => 
    pathname.startsWith(route)
  );
  
  if (isProtectedRoute && !isAuthenticated) {
    const loginUrl = new URL('/login', request.url);
    loginUrl.searchParams.set('callbackUrl', pathname);
    return NextResponse.redirect(loginUrl);
  }
  
  // Redirect authenticated users from auth pages
  const isAuthRoute = authRoutes.some(route => pathname.startsWith(route));
  
  if (isAuthRoute && isAuthenticated) {
    return NextResponse.redirect(new URL('/dashboard', request.url));
  }
  
  // Add user info to headers
  if (isAuthenticated) {
    response.headers.set('x-user-id', token.sub || '');
    response.headers.set('x-user-role', (token.role as string) || 'user');
  }
  
  // ==========================================
  // 5. MAINTENANCE MODE
  // ==========================================
  
  const isMaintenanceMode = process.env.MAINTENANCE_MODE === 'true';
  
  if (isMaintenanceMode && !pathname.startsWith('/maintenance')) {
    return NextResponse.redirect(new URL('/maintenance', request.url));
  }
  
  // ==========================================
  // 6. TRAILING SLASH REDIRECT
  // ==========================================
  
  if (pathname !== '/' && pathname.endsWith('/')) {
    return NextResponse.redirect(
      new URL(pathname.slice(0, -1), request.url),
      308
    );
  }
  
  return response;
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|.*\\..*).*)',
  ],
};
```

---

## Best Practices Checklist

### Setup
- [ ] Middleware in root directory
- [ ] Matcher configured
- [ ] Type-safe with TypeScript

### Performance
- [ ] Execution under 50ms
- [ ] No heavy computations
- [ ] Edge-compatible libraries

### Security
- [ ] Security headers set
- [ ] Rate limiting implemented
- [ ] CORS configured
- [ ] Bot protection

### Features
- [ ] Auth middleware working
- [ ] Redirects/rewrites configured
- [ ] Geo-based routing if needed
- [ ] A/B testing if needed

---

**References:**
- [Next.js Middleware](https://nextjs.org/docs/app/building-your-application/routing/middleware)
- [Edge Runtime](https://nextjs.org/docs/app/building-your-application/rendering/edge-and-nodejs-runtimes)
- [Upstash Rate Limiting](https://upstash.com/docs/ratelimit)
- [Vercel Edge Config](https://vercel.com/docs/storage/edge-config)

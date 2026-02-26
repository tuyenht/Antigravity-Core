# Next.js Performance Optimization

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **Next.js:** 14.x / 15.x  
> **Priority:** P0 - Load for all Next.js performance tasks

---

You are an expert in Next.js performance optimization.

## Core Performance Principles

- Optimize images and fonts
- Minimize client-side JavaScript
- Use proper caching strategies
- Implement streaming for faster TTFB

---

## 1) Image Optimization

### next/image Complete Guide
```tsx
// ==========================================
// BASIC IMAGE
// ==========================================

import Image from 'next/image';

export function ProductImage({ product }) {
  return (
    <Image
      src={product.imageUrl}
      alt={product.name}
      width={400}
      height={300}
      // Prevent layout shift
      style={{ objectFit: 'cover' }}
    />
  );
}


// ==========================================
// LCP IMAGE (Hero, Above-the-fold)
// ==========================================

export function HeroSection() {
  return (
    <section className="relative h-[600px]">
      <Image
        src="/hero.jpg"
        alt="Hero"
        fill  // Fills parent container
        priority  // Preload for LCP
        sizes="100vw"  // Full width
        style={{ objectFit: 'cover' }}
        placeholder="blur"
        blurDataURL="data:image/jpeg;base64,/9j/4AAQSkZJRg..."
      />
    </section>
  );
}


// ==========================================
// RESPONSIVE IMAGES
// ==========================================

export function ResponsiveImage() {
  return (
    <Image
      src="/product.jpg"
      alt="Product"
      fill
      // Tell browser how wide image will be at each breakpoint
      sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
      // Next.js generates: 640w, 750w, 828w, 1080w, 1200w, etc.
    />
  );
}


// ==========================================
// LAZY LOADING (Default Behavior)
// ==========================================

export function ProductGrid({ products }) {
  return (
    <div className="grid grid-cols-3 gap-4">
      {products.map((product, index) => (
        <Image
          key={product.id}
          src={product.image}
          alt={product.name}
          width={300}
          height={300}
          // First 6 images load eagerly (above fold)
          loading={index < 6 ? 'eager' : 'lazy'}
          priority={index < 3}  // Prioritize first row
        />
      ))}
    </div>
  );
}


// ==========================================
// BLUR PLACEHOLDER (Generated at Build)
// ==========================================

import heroImage from '@/public/hero.jpg';  // Static import

export function Hero() {
  return (
    <Image
      src={heroImage}
      alt="Hero"
      placeholder="blur"  // Uses generated blurDataURL
      priority
    />
  );
}


// ==========================================
// REMOTE IMAGES CONFIG
// ==========================================

// next.config.js
module.exports = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'cdn.example.com',
        pathname: '/images/**',
      },
      {
        protocol: 'https',
        hostname: '**.cloudinary.com',
      },
    ],
    formats: ['image/avif', 'image/webp'],  // Modern formats
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
  },
};
```

---

## 2) Font Optimization

### next/font Best Practices
```tsx
// ==========================================
// GOOGLE FONTS (Recommended)
// ==========================================

// app/layout.tsx
import { Inter, Roboto_Mono } from 'next/font/google';

// Variable font (single request, all weights)
const inter = Inter({
  subsets: ['latin'],
  display: 'swap',  // Prevent FOIT
  variable: '--font-inter',
});

// Mono font for code
const robotoMono = Roboto_Mono({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-mono',
});

export default function RootLayout({ children }) {
  return (
    <html lang="en" className={`${inter.variable} ${robotoMono.variable}`}>
      <body className={inter.className}>
        {children}
      </body>
    </html>
  );
}


// ==========================================
// LOCAL FONTS
// ==========================================

import localFont from 'next/font/local';

const customFont = localFont({
  src: [
    {
      path: './fonts/CustomFont-Regular.woff2',
      weight: '400',
      style: 'normal',
    },
    {
      path: './fonts/CustomFont-Bold.woff2',
      weight: '700',
      style: 'normal',
    },
  ],
  variable: '--font-custom',
  display: 'swap',
  preload: true,
});


// ==========================================
// CSS USAGE
// ==========================================

/* globals.css */
:root {
  --font-sans: var(--font-inter), system-ui, sans-serif;
  --font-mono: var(--font-mono), ui-monospace, monospace;
}

body {
  font-family: var(--font-sans);
}

code {
  font-family: var(--font-mono);
}
```

---

## 3) Caching Architecture

### Next.js 4-Layer Cache
```markdown
## Caching Hierarchy

┌─────────────────────────────────────────────────────────────┐
│ 1. REQUEST MEMOIZATION (Server - Single Request)           │
│    - Deduplicates fetch calls in same request              │
│    - Automatic for same URL + options                      │
│    - Resets after request completes                        │
├─────────────────────────────────────────────────────────────┤
│ 2. DATA CACHE (Server - Persistent)                        │
│    - Persists fetch results across requests                │
│    - Configured via fetch() options                        │
│    - Survives deployments (needs revalidation)             │
├─────────────────────────────────────────────────────────────┤
│ 3. FULL ROUTE CACHE (Server - Build Time)                  │
│    - Caches HTML and RSC Payload                           │
│    - Static routes cached at build                         │
│    - Dynamic routes NOT cached by default                  │
├─────────────────────────────────────────────────────────────┤
│ 4. ROUTER CACHE (Client - Session)                         │
│    - Caches RSC payload in browser                         │
│    - Enables instant back/forward navigation               │
│    - Prefetched routes stored here                         │
└──────────────────────────────────────────────────────────┘
```

### Caching Implementation
```tsx
// ==========================================
// FETCH CACHING OPTIONS
// ==========================================

// Default: Cached forever (Static)
async function getProducts() {
  const res = await fetch('https://api.example.com/products');
  return res.json();
}

// Time-based revalidation (ISR)
async function getProducts() {
  const res = await fetch('https://api.example.com/products', {
    next: { revalidate: 3600 },  // Revalidate every hour
  });
  return res.json();
}

// No caching (Dynamic)
async function getUser() {
  const res = await fetch('https://api.example.com/user', {
    cache: 'no-store',  // Always fresh
  });
  return res.json();
}

// Tag-based revalidation
async function getProduct(id: string) {
  const res = await fetch(`https://api.example.com/products/${id}`, {
    next: { tags: ['product', `product-${id}`] },
  });
  return res.json();
}


// ==========================================
// CACHE DATABASE QUERIES
// ==========================================

import { unstable_cache } from 'next/cache';

const getCachedProducts = unstable_cache(
  async (category: string) => {
    return db.product.findMany({
      where: { category },
      orderBy: { createdAt: 'desc' },
    });
  },
  ['products'],  // Cache key
  {
    revalidate: 3600,  // 1 hour
    tags: ['products'],
  }
);

// Usage
const products = await getCachedProducts('electronics');


// ==========================================
// ON-DEMAND REVALIDATION
// ==========================================

// app/api/revalidate/route.ts
import { revalidatePath, revalidateTag } from 'next/cache';

export async function POST(request: Request) {
  const { tag, path } = await request.json();
  
  if (tag) {
    revalidateTag(tag);  // Revalidate all with this tag
  }
  
  if (path) {
    revalidatePath(path);  // Revalidate specific path
  }
  
  return Response.json({ revalidated: true });
}


// ==========================================
// ROUTE SEGMENT CONFIG
// ==========================================

// Force static generation
export const dynamic = 'force-static';

// Force dynamic rendering
export const dynamic = 'force-dynamic';

// Set revalidation time
export const revalidate = 3600;  // 1 hour

// Opt out of parallel routes automatic static optimization
export const runtime = 'edge';
```

---

## 4) Streaming and Suspense

### Streaming Implementation
```tsx
// ==========================================
// LOADING UI (Streaming Boundary)
// ==========================================

// app/dashboard/loading.tsx
export default function Loading() {
  return (
    <div className="animate-pulse">
      <div className="h-8 w-48 bg-gray-200 rounded mb-4" />
      <div className="grid grid-cols-3 gap-4">
        {[...Array(6)].map((_, i) => (
          <div key={i} className="h-32 bg-gray-200 rounded" />
        ))}
      </div>
    </div>
  );
}


// ==========================================
// MANUAL SUSPENSE BOUNDARIES
// ==========================================

import { Suspense } from 'react';

export default function Dashboard() {
  return (
    <div className="grid grid-cols-3 gap-4">
      {/* Instant: Static content */}
      <header>
        <h1>Dashboard</h1>
      </header>

      {/* Stream 1: Fast data */}
      <Suspense fallback={<QuickStatsSkeleton />}>
        <QuickStats />
      </Suspense>

      {/* Stream 2: Slow data */}
      <Suspense fallback={<AnalyticsSkeleton />}>
        <Analytics />
      </Suspense>

      {/* Stream 3: Very slow data */}
      <Suspense fallback={<ReportsSkeleton />}>
        <Reports />
      </Suspense>
    </div>
  );
}

// Each async component streams when ready
async function QuickStats() {
  const stats = await getQuickStats();  // 100ms
  return <StatsDisplay stats={stats} />;
}

async function Analytics() {
  const data = await getAnalytics();  // 500ms
  return <AnalyticsChart data={data} />;
}

async function Reports() {
  const reports = await getReports();  // 2000ms
  return <ReportsList reports={reports} />;
}


// ==========================================
// NESTED SUSPENSE
// ==========================================

export default async function ProductPage({ params }) {
  const product = await getProduct(params.id);

  return (
    <div>
      {/* Instant: Already fetched */}
      <ProductHeader product={product} />

      {/* Stream: Reviews fetch independently */}
      <Suspense fallback={<ReviewsSkeleton />}>
        <ProductReviews productId={product.id} />
      </Suspense>

      {/* Stream: Related products */}
      <Suspense fallback={<RelatedSkeleton />}>
        <RelatedProducts category={product.category} />
      </Suspense>
    </div>
  );
}
```

---

## 5) Bundle Optimization

### Dynamic Imports
```tsx
// ==========================================
// DYNAMIC COMPONENT IMPORT
// ==========================================

import dynamic from 'next/dynamic';

// Load only when needed
const HeavyChart = dynamic(() => import('@/components/HeavyChart'), {
  loading: () => <ChartSkeleton />,
  ssr: false,  // Client-only (browser APIs)
});

// Named export
const SpecificChart = dynamic(
  () => import('@/components/Charts').then(mod => mod.BarChart),
  { loading: () => <Skeleton />, ssr: false }
);


// ==========================================
// CONDITIONAL IMPORTS
// ==========================================

export default function Page() {
  const [showEditor, setShowEditor] = useState(false);

  return (
    <div>
      <button onClick={() => setShowEditor(true)}>Open Editor</button>
      
      {showEditor && (
        <Suspense fallback={<EditorSkeleton />}>
          <HeavyEditor />
        </Suspense>
      )}
    </div>
  );
}


// ==========================================
// MODULARIZE IMPORTS
// ==========================================

// next.config.js
module.exports = {
  modularizeImports: {
    'lodash': {
      transform: 'lodash/{{member}}',
    },
    '@mui/icons-material': {
      transform: '@mui/icons-material/{{member}}',
    },
    '@mui/material': {
      transform: '@mui/material/{{member}}',
    },
  },
};

// ❌ Before: Imports entire library
import { sortBy, debounce } from 'lodash';

// ✅ After: Tree-shakes to individual modules
// Automatically transforms to:
// import sortBy from 'lodash/sortBy';
// import debounce from 'lodash/debounce';
```

### Bundle Analysis
```javascript
// next.config.js
const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
});

module.exports = withBundleAnalyzer({
  // your config
});

// Run: ANALYZE=true npm run build
```

---

## 6) Third-Party Scripts

### next/script Optimization
```tsx
// ==========================================
// SCRIPT LOADING STRATEGIES
// ==========================================

import Script from 'next/script';

export default function Layout({ children }) {
  return (
    <>
      {/* afterInteractive (Default): Load after page interactive */}
      <Script
        src="https://www.googletagmanager.com/gtag/js?id=GA_ID"
        strategy="afterInteractive"
      />

      {/* lazyOnload: Load during idle time */}
      <Script
        src="https://connect.facebook.net/en_US/sdk.js"
        strategy="lazyOnload"
      />

      {/* beforeInteractive: Load before any Next.js code */}
      <Script
        src="https://polyfill.io/v3/polyfill.min.js"
        strategy="beforeInteractive"
      />

      {/* worker: Load in web worker (experimental) */}
      <Script
        src="https://heavy-analytics.js"
        strategy="worker"
      />

      {children}
    </>
  );
}


// ==========================================
// INLINE SCRIPTS
// ==========================================

<Script id="gtag-init" strategy="afterInteractive">
  {`
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', 'GA_ID');
  `}
</Script>


// ==========================================
// SCRIPT EVENTS
// ==========================================

<Script
  src="https://example.com/script.js"
  onLoad={() => {
    console.log('Script loaded');
  }}
  onReady={() => {
    // Called every time component mounts
    window.externalLib.init();
  }}
  onError={(e) => {
    console.error('Script failed to load', e);
  }}
/>
```

---

## 7) Core Web Vitals Monitoring

### Analytics Setup
```tsx
// ==========================================
// WEB VITALS REPORTING
// ==========================================

// app/components/Analytics.tsx
'use client';

import { useReportWebVitals } from 'next/web-vitals';

export function Analytics() {
  useReportWebVitals((metric) => {
    // Send to analytics
    switch (metric.name) {
      case 'LCP':
        console.log('LCP:', metric.value, 'ms');
        break;
      case 'FID':
        console.log('FID:', metric.value, 'ms');
        break;
      case 'CLS':
        console.log('CLS:', metric.value);
        break;
      case 'INP':
        console.log('INP:', metric.value, 'ms');
        break;
      case 'TTFB':
        console.log('TTFB:', metric.value, 'ms');
        break;
    }

    // Send to analytics service
    sendToAnalytics({
      name: metric.name,
      value: metric.value,
      rating: metric.rating,  // 'good', 'needs-improvement', 'poor'
      id: metric.id,
    });
  });

  return null;
}


// ==========================================
// VERCEL ANALYTICS
// ==========================================

// app/layout.tsx
import { SpeedInsights } from '@vercel/speed-insights/next';
import { Analytics } from '@vercel/analytics/react';

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <Analytics />
        <SpeedInsights />
      </body>
    </html>
  );
}
```

---

## 8) Complete next.config.js

### Production-Ready Configuration
```javascript
// next.config.js

/** @type {import('next').NextConfig} */
const nextConfig = {
  // ==========================================
  // PERFORMANCE
  // ==========================================
  
  // Enable React strict mode
  reactStrictMode: true,
  
  // Standalone output for Docker
  output: 'standalone',
  
  // Compress responses
  compress: true,
  
  // Generate ETags
  generateEtags: true,
  
  // Powered by header removal
  poweredByHeader: false,
  
  // ==========================================
  // IMAGES
  // ==========================================
  
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'cdn.example.com',
      },
    ],
    formats: ['image/avif', 'image/webp'],
    minimumCacheTTL: 60,
    dangerouslyAllowSVG: true,
    contentSecurityPolicy: "default-src 'self'; script-src 'none'; sandbox;",
  },
  
  // ==========================================
  // BUNDLE OPTIMIZATION
  // ==========================================
  
  modularizeImports: {
    'lodash': { transform: 'lodash/{{member}}' },
    '@mui/icons-material': { transform: '@mui/icons-material/{{member}}' },
    '@mui/material': { transform: '@mui/material/{{member}}' },
    'date-fns': { transform: 'date-fns/{{member}}' },
  },
  
  // ==========================================
  // EXPERIMENTAL FEATURES
  // ==========================================
  
  experimental: {
    // Partial Prerendering (Next.js 14+)
    ppr: true,
    
    // Optimized package imports
    optimizePackageImports: [
      '@radix-ui/react-icons',
      'lucide-react',
      '@headlessui/react',
    ],
  },
  
  // ==========================================
  // HEADERS
  // ==========================================
  
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'X-DNS-Prefetch-Control',
            value: 'on',
          },
          {
            key: 'X-Frame-Options',
            value: 'SAMEORIGIN',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
        ],
      },
      {
        source: '/_next/static/:path*',
        headers: [
          {
            key: 'Cache-Control',
            value: 'public, max-age=31536000, immutable',
          },
        ],
      },
    ];
  },
  
  // ==========================================
  // WEBPACK CUSTOMIZATION
  // ==========================================
  
  webpack: (config, { isServer }) => {
    // Bundle size limits
    if (!isServer) {
      config.performance = {
        hints: 'warning',
        maxAssetSize: 256000,
        maxEntrypointSize: 512000,
      };
    }
    
    return config;
  },
};

module.exports = nextConfig;
```

---

## Performance Checklist

### Images
- [ ] Using next/image
- [ ] Width/height specified
- [ ] priority for LCP images
- [ ] Responsive sizes
- [ ] Modern formats (WebP/AVIF)

### Fonts
- [ ] Using next/font
- [ ] Variable fonts preferred
- [ ] display: swap
- [ ] Subsets configured

### Caching
- [ ] Fetch caching configured
- [ ] Revalidation strategy set
- [ ] Tags for on-demand revalidation
- [ ] Static generation where possible

### Bundle
- [ ] Dynamic imports for heavy components
- [ ] Tree-shaking verified
- [ ] Bundle analyzed
- [ ] No unnecessary dependencies

### Monitoring
- [ ] Core Web Vitals tracked
- [ ] Analytics configured
- [ ] Performance budgets set

---

**References:**
- [Next.js Performance](https://nextjs.org/docs/app/building-your-application/optimizing)
- [Image Optimization](https://nextjs.org/docs/app/building-your-application/optimizing/images)
- [Caching in Next.js](https://nextjs.org/docs/app/building-your-application/caching)
- [Core Web Vitals](https://web.dev/vitals/)

# Web Performance Optimization Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Standards:** Core Web Vitals 2024 (LCP, INP, CLS), HTTP/3
> **Priority:** P0 - Critical for all web projects

---

You are an expert in web performance optimization, focusing on Core Web Vitals and modern performance patterns.

## Key Principles

- Optimize for Core Web Vitals (LCP, INP, CLS)
- Measure first, optimize second
- Focus on user-perceived performance
- Implement performance budgets
- Target 75th percentile metrics
- Monitor in production with RUM

## Core Web Vitals 2024

| Metric | Target | Measures |
|--------|--------|----------|
| **LCP** | ≤ 2.5s | Loading performance |
| **INP** | ≤ 200ms | Responsiveness (replaced FID) |
| **CLS** | ≤ 0.1 | Visual stability |

### Additional Metrics
| Metric | Target | Measures |
|--------|--------|----------|
| **TTFB** | ≤ 800ms | Server response time |
| **FCP** | ≤ 1.8s | First content paint |
| **TBT** | ≤ 200ms | Total blocking time |

### Measurement
```javascript
// Using web-vitals library
import { onLCP, onINP, onCLS, onFCP, onTTFB } from 'web-vitals';

function sendToAnalytics(metric) {
  const body = JSON.stringify({
    name: metric.name,
    value: metric.value,
    delta: metric.delta,
    id: metric.id,
    navigationType: metric.navigationType,
    rating: metric.rating // 'good', 'needs-improvement', 'poor'
  });
  
  // Use sendBeacon for reliability
  navigator.sendBeacon('/analytics', body);
}

onLCP(sendToAnalytics);
onINP(sendToAnalytics);
onCLS(sendToAnalytics);
onFCP(sendToAnalytics);
onTTFB(sendToAnalytics);
```

---

## LCP Optimization (Largest Contentful Paint)

**Target: ≤ 2.5 seconds**

### Server Response
```javascript
// Target TTFB < 800ms
// Optimize:
// - Database queries
// - Server processing
// - Network latency

// Use CDN for global distribution
// Implement edge caching
// Use streaming SSR
```

### Resource Loading
```html
<!-- 1. Preconnect to critical origins -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://cdn.example.com">

<!-- 2. Preload LCP image with fetchpriority -->
<link 
  rel="preload" 
  href="/hero.webp" 
  as="image"
  fetchpriority="high"
>

<!-- 3. Critical CSS inline -->
<style>
  /* Above-the-fold styles only */
  .hero { /* ... */ }
</style>

<!-- 4. LCP image with fetchpriority -->
<img 
  src="/hero.webp" 
  alt="Hero" 
  fetchpriority="high"
  width="1200" 
  height="600"
>
```

### Resource Hints with 103 Early Hints
```
HTTP/1.1 103 Early Hints
Link: </styles/critical.css>; rel=preload; as=style
Link: </hero.webp>; rel=preload; as=image
Link: </scripts/app.js>; rel=modulepreload

HTTP/1.1 200 OK
Content-Type: text/html
...
```

### LCP Best Practices
- Optimize server response time (TTFB < 800ms)
- Use CDN for static assets
- Preload LCP image with `fetchpriority="high"`
- Inline critical CSS
- Avoid lazy loading above-the-fold images
- Use modern image formats (WebP, AVIF)
- Remove render-blocking resources
- Use `content-visibility` for below-fold content

---

## INP Optimization (Interaction to Next Paint)

**Target: ≤ 200 milliseconds**

> **Note:** INP replaced FID as a Core Web Vital in March 2024

### Break Up Long Tasks

```javascript
// 1. Using scheduler.yield() (modern)
async function processItems(items) {
  for (const item of items) {
    processItem(item);
    await scheduler.yield(); // Yield to main thread
  }
}

// 2. Fallback for older browsers
async function yieldToMain() {
  if ('scheduler' in window && 'yield' in scheduler) {
    return scheduler.yield();
  }
  return new Promise(resolve => setTimeout(resolve, 0));
}

// 3. Time-based yielding
async function processWithYield(items) {
  let startTime = performance.now();
  
  for (const item of items) {
    processItem(item);
    
    // Yield every 50ms
    if (performance.now() - startTime > 50) {
      await yieldToMain();
      startTime = performance.now();
    }
  }
}
```

### Priority-Based Scheduling
```javascript
// Use scheduler.postTask() for priority control
if ('scheduler' in window) {
  // User-visible work - highest priority
  scheduler.postTask(() => updateUI(), { priority: 'user-blocking' });
  
  // Important but not blocking
  scheduler.postTask(() => fetchData(), { priority: 'user-visible' });
  
  // Background work
  scheduler.postTask(() => analytics(), { priority: 'background' });
}

// Fallback with requestIdleCallback
requestIdleCallback((deadline) => {
  while (deadline.timeRemaining() > 0 && tasks.length > 0) {
    processTask(tasks.pop());
  }
}, { timeout: 2000 });
```

### Optimize Event Handlers
```javascript
// 1. Debounce rapid events
function debounce(fn, delay) {
  let timeoutId;
  return (...args) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), delay);
  };
}

// 2. Use passive listeners for scroll/touch
element.addEventListener('scroll', handler, { passive: true });
element.addEventListener('touchstart', handler, { passive: true });

// 3. Avoid layout thrashing
// ❌ Bad - forces synchronous layout
elements.forEach(el => {
  el.style.width = el.offsetWidth + 10 + 'px';
});

// ✅ Good - batch reads, then writes
const widths = elements.map(el => el.offsetWidth);
elements.forEach((el, i) => {
  el.style.width = widths[i] + 10 + 'px';
});
```

### Web Workers for Heavy Computation
```javascript
// main.js
const worker = new Worker('/workers/heavy-task.js');

worker.postMessage({ data: largeDataSet });

worker.onmessage = (event) => {
  updateUI(event.data);
};

// workers/heavy-task.js
self.onmessage = (event) => {
  const result = heavyComputation(event.data);
  self.postMessage(result);
};
```

### INP Best Practices
- Break long tasks into smaller chunks (< 50ms each)
- Use `scheduler.yield()` or `scheduler.postTask()`
- Defer non-critical JavaScript
- Use Web Workers for heavy computation
- Optimize event handlers with debounce/throttle
- Use passive event listeners
- Avoid forced synchronous layouts
- Code-split JavaScript bundles

---

## CLS Optimization (Cumulative Layout Shift)

**Target: ≤ 0.1**

### Dimension Reservation
```html
<!-- Always set dimensions on images -->
<img 
  src="image.jpg" 
  width="800" 
  height="600" 
  alt="Description"
  loading="lazy"
>

<!-- Use aspect-ratio for responsive images -->
<img 
  src="image.jpg" 
  style="aspect-ratio: 16/9; width: 100%;" 
  alt="Description"
>

<!-- Reserve space for embeds -->
<div style="aspect-ratio: 16/9;">
  <iframe src="..." loading="lazy"></iframe>
</div>
```

### Dynamic Content
```css
/* Reserve space for dynamic content */
.ad-container {
  min-height: 250px;
  background: var(--placeholder-bg);
}

/* Use content-visibility for virtualization */
.list-item {
  content-visibility: auto;
  contain-intrinsic-size: 0 100px;
}
```

### Font Loading
```css
/* Prevent FOIT/FOUT layout shifts */
@font-face {
  font-family: 'CustomFont';
  src: url('/fonts/custom.woff2') format('woff2');
  font-display: optional; /* or swap with adjustments */
  size-adjust: 105%;
  ascent-override: 90%;
  descent-override: 20%;
  line-gap-override: 0%;
}

/* Fallback font matching */
body {
  font-family: 'CustomFont', system-ui, sans-serif;
}
```

### Animation Best Practices
```css
/* Use transform instead of layout properties */
/* ✅ Good - GPU accelerated, no layout shift */
.animate {
  transform: translateX(100px);
  opacity: 0;
}

/* ❌ Bad - causes layout shift */
.animate-bad {
  left: 100px;
  margin-left: 100px;
}
```

### CLS Best Practices
- Set explicit dimensions on images and videos
- Reserve space for ads and embeds
- Avoid inserting content above existing content
- Use `transform` for animations (not layout properties)
- Preload fonts with proper fallbacks
- Use `font-display: optional` for non-critical fonts
- Implement skeleton screens with accurate dimensions

---

## JavaScript Optimization

### Code Splitting
```javascript
// Route-based splitting
const routes = {
  '/': () => import('./pages/Home.js'),
  '/about': () => import('./pages/About.js'),
  '/contact': () => import('./pages/Contact.js')
};

// Component-based splitting (React)
const HeavyChart = React.lazy(() => import('./HeavyChart'));

function Dashboard() {
  return (
    <Suspense fallback={<ChartSkeleton />}>
      <HeavyChart />
    </Suspense>
  );
}
```

### Tree Shaking
```javascript
// Import only what you need
import { debounce, throttle } from 'lodash-es';
// NOT: import _ from 'lodash';

// Use named exports for better tree shaking
export { functionA, functionB };
// Avoid: export default { functionA, functionB };
```

### Bundle Optimization
```javascript
// vite.config.js
export default {
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          utils: ['lodash-es', 'date-fns']
        }
      }
    },
    target: 'es2022',
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,
        drop_debugger: true
      }
    }
  }
};
```

### Module Loading
```html
<!-- Use modulepreload for ES modules -->
<link rel="modulepreload" href="/scripts/app.js">
<link rel="modulepreload" href="/scripts/utils.js">

<!-- Async loading for non-critical scripts -->
<script src="/analytics.js" async></script>

<!-- Dynamic import for on-demand loading -->
<script type="module">
  if (showChart) {
    const { Chart } = await import('./chart.js');
    new Chart(data);
  }
</script>
```

---

## Image Optimization

### Modern Formats with Fallback
```html
<picture>
  <!-- AVIF - best compression -->
  <source 
    srcset="image.avif" 
    type="image/avif"
  >
  <!-- WebP - wide support -->
  <source 
    srcset="image.webp" 
    type="image/webp"
  >
  <!-- Fallback -->
  <img 
    src="image.jpg" 
    alt="Description"
    width="800"
    height="600"
    loading="lazy"
    decoding="async"
  >
</picture>
```

### Responsive Images
```html
<img 
  src="image-800.jpg"
  srcset="
    image-400.jpg 400w,
    image-800.jpg 800w,
    image-1200.jpg 1200w,
    image-1600.jpg 1600w
  "
  sizes="
    (max-width: 600px) 100vw,
    (max-width: 1200px) 50vw,
    800px
  "
  alt="Description"
  loading="lazy"
  decoding="async"
>
```

### Image Loading Strategies
```javascript
// LCP image - no lazy loading, high priority
<img src="hero.webp" fetchpriority="high" alt="Hero">

// Below-fold images - lazy loading
<img src="image.webp" loading="lazy" alt="...">

// Progressive loading with blur-up
const img = new Image();
img.src = highResUrl;
img.onload = () => {
  element.style.backgroundImage = `url(${highResUrl})`;
  element.classList.add('loaded');
};
```

---

## CSS Optimization

### Critical CSS
```html
<!-- Inline critical CSS -->
<style>
  /* Above-the-fold styles only - keep under 14KB */
  :root { --color-primary: #1a73e8; }
  body { margin: 0; font-family: system-ui; }
  .header { /* ... */ }
  .hero { /* ... */ }
</style>

<!-- Load full CSS asynchronously -->
<link 
  rel="preload" 
  href="/styles.css" 
  as="style" 
  onload="this.onload=null;this.rel='stylesheet'"
>
<noscript><link rel="stylesheet" href="/styles.css"></noscript>
```

### CSS Containment
```css
/* Isolate layout calculations */
.card {
  contain: layout style paint;
}

/* Content visibility for virtualization */
.article {
  content-visibility: auto;
  contain-intrinsic-size: 0 500px;
}

/* Will-change for animations (use sparingly) */
.animated {
  will-change: transform;
}
.animated.done {
  will-change: auto; /* Remove after animation */
}
```

### Remove Unused CSS
```bash
# Use PurgeCSS or similar
npx purgecss --css styles.css --content '**/*.html' --output purged.css

# Analyze CSS usage
npx css-coverage analyze
```

---

## Font Optimization

### Font Loading Strategy
```html
<!-- Preload critical fonts -->
<link 
  rel="preload" 
  href="/fonts/main.woff2" 
  as="font" 
  type="font/woff2" 
  crossorigin
>
```

```css
@font-face {
  font-family: 'MainFont';
  src: url('/fonts/main.woff2') format('woff2');
  font-display: swap; /* or optional for less jarring */
  font-weight: 400;
  unicode-range: U+0000-00FF; /* Latin subset */
}

/* Variable font for multiple weights */
@font-face {
  font-family: 'VarFont';
  src: url('/fonts/variable.woff2') format('woff2-variations');
  font-weight: 100 900;
  font-display: swap;
}
```

### Font Best Practices
- Use `font-display: swap` or `optional`
- Preload critical fonts
- Subset fonts to reduce size
- Use variable fonts for multiple weights
- Consider system fonts for body text
- Use `size-adjust` to match fallback font

---

## Caching Strategies

### HTTP Cache Headers
```
# Immutable assets (hashed filenames)
Cache-Control: public, max-age=31536000, immutable

# HTML pages
Cache-Control: no-cache
# or
Cache-Control: public, max-age=0, must-revalidate

# API responses
Cache-Control: private, max-age=300

# Service worker
Cache-Control: no-cache, no-store, must-revalidate
```

### Service Worker Caching
```javascript
// See PWA Expert rule for detailed implementation
// Key patterns:
// - Cache-first for static assets
// - Network-first for API calls
// - Stale-while-revalidate for content
```

---

## Network Optimization

### HTTP/2 and HTTP/3
- Enable HTTP/2 or HTTP/3 on server
- Leverage multiplexing
- Use server push alternatives (103 Early Hints)

### Resource Hints
```html
<!-- Preconnect to critical origins -->
<link rel="preconnect" href="https://api.example.com">
<link rel="dns-prefetch" href="https://analytics.example.com">

<!-- Prefetch next page resources -->
<link rel="prefetch" href="/next-page.html">
<link rel="prefetch" href="/data.json">

<!-- Prerender likely navigation -->
<link rel="prerender" href="/likely-next-page">
```

### Speculation Rules (Chrome 109+)
```html
<script type="speculationrules">
{
  "prerender": [
    {
      "source": "list",
      "urls": ["/about", "/contact"]
    }
  ],
  "prefetch": [
    {
      "source": "document",
      "where": { "href_matches": "/products/*" },
      "eagerness": "moderate"
    }
  ]
}
</script>
```

### Compression
```
# Prefer Brotli over gzip
Accept-Encoding: br, gzip

# Server response
Content-Encoding: br
```

---

## Rendering Strategies

### Strategy Selection
| Strategy | Use Case | TTFB | LCP | Interactivity |
|----------|----------|------|-----|---------------|
| **SSG** | Static content | Fast | Fast | Immediate |
| **SSR** | Dynamic content | Slower | Fast | Delayed |
| **ISR** | Semi-dynamic | Fast | Fast | Immediate |
| **CSR** | App-like | Fast | Slow | Delayed |
| **Streaming SSR** | Large pages | Fast | Progressive | Progressive |

### Partial Hydration
```javascript
// Islands architecture - hydrate only interactive parts
// Using Astro, Fresh, or similar

// React Server Components
// Server components = no JS shipped
// Client components = hydrated

'use client'; // Mark interactive components
export function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}
```

---

## Performance Budgets

```json
{
  "budgets": [
    {
      "resourceType": "document",
      "budget": 50
    },
    {
      "resourceType": "script",
      "budget": 200
    },
    {
      "resourceType": "stylesheet",
      "budget": 50
    },
    {
      "resourceType": "image",
      "budget": 300
    },
    {
      "resourceType": "font",
      "budget": 100
    },
    {
      "resourceType": "total",
      "budget": 500
    }
  ],
  "metrics": {
    "LCP": 2500,
    "INP": 200,
    "CLS": 0.1,
    "TTFB": 800,
    "TBT": 200
  }
}
```

### CI/CD Integration
```yaml
# GitHub Actions example
- name: Lighthouse CI
  uses: treosh/lighthouse-ci-action@v10
  with:
    configPath: './lighthouserc.json'
    budgetPath: './budget.json'
```

---

## Monitoring & Testing

### Lighthouse CLI
```bash
# Run Lighthouse audit
npx lighthouse https://example.com \
  --output html \
  --output-path ./report.html \
  --only-categories=performance

# Target scores
# Performance: 90+
# Accessibility: 100
```

### Real User Monitoring (RUM)
```javascript
// Track Core Web Vitals for real users
import { onLCP, onINP, onCLS } from 'web-vitals';

function trackVital(metric) {
  // Send to analytics with context
  sendToAnalytics({
    ...metric,
    url: location.href,
    deviceType: getDeviceType(),
    connection: navigator.connection?.effectiveType
  });
}

onLCP(trackVital);
onINP(trackVital);
onCLS(trackVital);
```

### Performance Observer
```javascript
// Monitor long tasks
new PerformanceObserver((list) => {
  list.getEntries().forEach(entry => {
    if (entry.duration > 50) {
      console.warn('Long task:', entry.duration, 'ms');
    }
  });
}).observe({ type: 'longtask', buffered: true });

// Monitor resource loading
new PerformanceObserver((list) => {
  list.getEntries().forEach(entry => {
    console.log(`${entry.name}: ${entry.duration}ms`);
  });
}).observe({ type: 'resource', buffered: true });
```

---

## Best Practices Checklist

### Before Launch
- [ ] Core Web Vitals pass (LCP ≤ 2.5s, INP ≤ 200ms, CLS ≤ 0.1)
- [ ] Lighthouse Performance ≥ 90
- [ ] JavaScript bundle < 200KB (gzipped)
- [ ] Total page weight < 500KB (initial load)
- [ ] TTFB < 800ms
- [ ] Critical CSS inlined
- [ ] Images optimized (WebP/AVIF)
- [ ] Fonts preloaded and subsetted
- [ ] HTTP/2 or HTTP/3 enabled
- [ ] Caching headers configured

### Ongoing
- [ ] RUM monitoring active
- [ ] Performance budgets enforced
- [ ] Third-party scripts audited
- [ ] Dependency updates reviewed
- [ ] Bundle size monitored

---

**References:**
- [web.dev Core Web Vitals](https://web.dev/vitals/)
- [Chrome DevTools Performance](https://developer.chrome.com/docs/devtools/performance/)
- [Web Vitals Library](https://github.com/GoogleChrome/web-vitals)
- [PageSpeed Insights](https://pagespeed.web.dev/)
- [WebPageTest](https://www.webpagetest.org/)

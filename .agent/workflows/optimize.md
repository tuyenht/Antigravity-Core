---
description: "Phân tích mã nguồn hiện tại và tối ưu hiệu suất thực thi ứng dụng."
---

# /optimize - Performance Tuning Workflow

// turbo-all

Comprehensive performance analysis and optimization for applications and components.

---

## When to Use

- Slow page loads (>3s)
- High CPU/memory usage
- Database query performance issues
- Bundle size too large
- Poor Core Web Vitals scores
- Before production deployment

---

## Input Required

```
Optimization target:
1. Scope:
   - Full application
   - Specific component/page
   - API endpoint
   - Database queries
2. Performance goal:
   - Load time target (e.g., <2s)
   - Bundle size limit (e.g., <500KB)
   - Memory usage target
```

---

## Workflow Steps

### Step 1: Performance Baseline

**Measure current performance:**

```javascript
// Lighthouse metrics
Performance Score: 45/100
├── FCP (First Contentful Paint): 3.2s (❌ >1.8s)
├── LCP (Largest Contentful Paint): 5.1s (❌ >2.5s)
├── TBT (Total Blocking Time): 850ms (❌ >200ms)
├── CLS (Cumulative Layout Shift): 0.15 (⚠️ >0.1)
└── SI (Speed Index): 4.8s (❌ >3.4s)

// Resource Analysis
Bundle size: 1.2MB (❌ Target: <500KB)
├── JavaScript: 850KB
├── CSS: 120KB
├── Images: 180KB
└── Fonts: 50KB

// Database
Average query time: 450ms (❌ Target: <100ms)
N+1 queries detected: 23 instances
```

**Agent:** `performance-optimizer` + `performance-profiling` skill
**Skills:** `performance-profiling, react-performance, laravel-performance`

---

### Step 2: Identify Bottlenecks

**Automated profiling:**

```javascript
🔍 Bottlenecks Detected:

CRITICAL (Fix Immediately):
1. 🔴 Unoptimized images (15 images × 200KB)
   Impact: +3s load time
   
2. 🔴 No code splitting (single 850KB bundle)
   Impact: +2.5s blocking time
   
3. 🔴 N+1 database queries (23 instances)
   Impact: +2s server response
   
HIGH Priority:
4. 🟡 No caching (API responses)
   Impact: +1.2s per request
   
5. 🟡 Render-blocking CSS (120KB)
   Impact: +800ms FCP
   
6. 🟡 Large third-party scripts (React DevTools in prod)
   Impact: +500ms TBT

MEDIUM Priority:
7. 🟢 Unused CSS (40KB)
8. 🟢 No lazy loading for images
9. 🟢 Missing compression (gzip)
```

**Agent:** `performance-optimizer`

---

### Step 3: Frontend Optimization Plan

**React/Vue/Frontend optimizations:**

```javascript
// Before Optimization
import React from 'react';
import _ from 'lodash'; // 72KB!
import moment from 'moment'; // 68KB!

function UserProfile({ user }) {
  // Inefficient re-rendering
  const processedData = heavyComputation(user);
  
  return (
    <div>
      <img src="/large-image.jpg" /> {/* 200KB! */}
      <HeavyComponent data={processedData} />
    </div>
  );
}

// After Optimization
import React, { memo, useMemo } from 'react';
import { debounce } from 'lodash-es/debounce'; // Tree-shaken: 2KB
import dayjs from 'dayjs'; // 2KB vs moment 68KB

const HeavyComponent = React.lazy(() => 
  import('./HeavyComponent')
);

const UserProfile = memo(({ user }) => {
  // Memoized computation
  const processedData = useMemo(
    () => heavyComputation(user),
    [user.id]
  );
  
  return (
    <div>
      {/* Lazy-loaded, optimized image */}
      <img 
        src="/optimized-image.webp" 
        loading="lazy"
        width="300" 
        height="200"
      />
      
      <Suspense fallback={<Skeleton />}>
        <HeavyComponent data={processedData} />
      </Suspense>
    </div>
  );
});
```

**Optimizations applied:**
- ✅ Code splitting (React.lazy)
- ✅ Memoization (useMemo, memo)
- ✅ Tree-shaking (lodash-es)
- ✅ Smaller alternatives (dayjs vs moment)
- ✅ Image optimization (WebP, lazy loading)

---

### Step 4: Backend Optimization Plan

**Laravel/FastAPI/Backend optimizations:**

```php
// Before: N+1 Query Problem
public function index()
{
    $users = User::all(); // 1 query
    
    foreach ($users as $user) {
        $user->posts; // N queries (1 per user!)
    }
}
// Total: 1 + N queries (if 100 users = 101 queries!)

// After: Eager Loading
public function index()
{
    $users = User::with('posts')->get(); // 2 queries total
}

// Before: No caching
public function show($id)
{
    $user = User::findOrFail($id);
    $stats = DB::table('statistics')
        ->where('user_id', $id)
        ->get();
    
    return response()->json([
        'user' => $user,
        'stats' => $stats
    ]);
}

// After: Caching + Query optimization
public function show($id)
{
    $data = Cache::remember("user.{$id}", 3600, function () use ($id) {
        return [
            'user' => User::findOrFail($id),
            'stats' => DB::table('statistics')
                ->select(['views', 'likes', 'shares'])
                ->where('user_id', $id)
                ->first()
        ];
    });
    
    return response()->json($data);
}
```

**Optimizations applied:**
- ✅ Eager loading (solve N+1)
- ✅ Query result caching
- ✅ SELECT only needed columns
- ✅ Database indexing

---

### Step 5: Bundle Size Optimization

**Webpack/Vite optimization:**

```javascript
// vite.config.js - Before
export default {
  build: {
    // Default settings
  }
}

// vite.config.js - After
export default {
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          ui: ['@radix-ui/react-dialog', '@radix-ui/react-dropdown-menu'],
        }
      }
    },
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true, // Remove console.logs
        drop_debugger: true
      }
    }
  },
  plugins: [
    visualizer(), // Bundle analysis
    compression({ algorithm: 'brotli' })
  ]
}
```

**Results:**
```
Bundle Analysis:

Before:
├── main.js: 850KB
└── Total: 850KB

After:
├── main.js: 120KB (-86%)
├── vendor.js: 180KB (cached)
├── ui.js: 90KB (lazy-loaded)
└── Total initial: 300KB (-65%)

Compression:
├── Brotli: 85KB (-72% from 300KB)
└── Loading: Reduced 850KB → 85KB
```

---

### Step 6: Database Optimization

**Query optimization + indexing:**

```sql
-- Before: Slow query (450ms)
SELECT * FROM users 
WHERE email LIKE '%@gmail.com'
ORDER BY created_at DESC
LIMIT 10;

-- Problem: 
-- 1. No index on email
-- 2. Leading wildcard prevents index use
-- 3. SELECT * fetches unnecessary data

-- After: Optimized (12ms)
-- Add index
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at DESC);

-- Optimized query
SELECT id, name, email, created_at 
FROM users 
WHERE email LIKE 'user%@gmail.com' -- No leading wildcard
ORDER BY created_at DESC
LIMIT 10;
```

**Database recommendations:**
- ✅ Add indexes on frequently queried columns
- ✅ Use EXPLAIN to analyze queries
- ✅ Avoid SELECT *
- ✅ Use database query caching
- ✅ Consider read replicas for scale

---

### Step 7: Image Optimization

**Automated image optimization:**

```bash
# Compress images
✅ hero.jpg (1.2MB) → hero.webp (180KB) -85%
✅ avatar.png (450KB) → avatar.webp (65KB) -86%
✅ logo.svg (85KB) → optimized (12KB) -86%

# Responsive images
<img 
  srcset="
    avatar-small.webp 300w,
    avatar-medium.webp 600w,
    avatar-large.webp 1200w
  "
  sizes="(max-width: 600px) 300px, 600px"
  src="avatar-medium.webp"
  alt="User avatar"
  loading="lazy"
  width="600"
  height="600"
/>

# Total savings: 1.7MB → 257KB (-85%)
```

---

### Step 8: Verify Improvements

**Re-run performance tests:**

```
Performance Improvements:

Lighthouse Score:
Before: 45/100
After: 92/100 ⬆️ +104%

Core Web Vitals:
├── FCP: 3.2s → 0.8s ⬇️ 75%
├── LCP: 5.1s → 1.2s ⬇️ 76%
├── TBT: 850ms → 95ms ⬇️ 89%
├── CLS: 0.15 → 0.02 ⬇️ 87%

Bundle Size:
├── Initial: 850KB → 85KB ⬇️ 90%
├── Total: 1.2MB → 300KB ⬇️ 75%

Database:
├── Query time: 450ms → 35ms ⬇️ 92%
├── N+1 queries: 23 → 0 ✅

API Response:
├── Average: 890ms → 120ms ⬇️ 87%
```

**Agent:** `performance-optimizer`

---

## Agent Orchestration

```
1. performance-optimizer
   └── Run Lighthouse audit
   └── Profile application
   └── Identify bottlenecks
   
2. {framework}-specialist
   └── Apply framework-specific optimizations
   └── Code splitting
   └── Lazy loading
   
3. database-architect
   └── Query optimization
   └── Indexing strategy
   └── Caching recommendations
   
4. performance-optimizer
   └── Verify improvements
   └── Generate report
```

---

## Error Handling

**If optimization breaks functionality:**
```
→ Rollback changes
→ Review breaking change
→ Apply fix incrementally
```

**If performance doesn't improve:**
```
→ Re-profile bottlenecks
→ Try alternative approach
→ Consult monitoring data
```

---

## Success Criteria

✅ Lighthouse score >90  
✅ LCP <2.5s  
✅ Bundle size <500KB  
✅ Database queries <100ms  
✅ No regressions

---

## Example Usage

**User request:**
```
/optimize --target=full-app --goal=lighthouse-90
```

**Agent response:**
```
🔍 Performance Analysis Started...

Current State:
- Lighthouse: 45/100
- LCP: 5.1s
- Bundle: 1.2MB

 Optimizations:
✅ 1. Code splitting (-70% initial bundle)
✅ 2. Image optimization (-85% size)
✅ 3. Eager loading (eliminated N+1)
✅ 4. Database indexing (-92% query time)
✅ 5. Response caching (-60% API time)

🎉 Results:
- Lighthouse: 45 → 92/100 ⬆️
- LCP: 5.1s → 1.2s ⬇️ 76%
- Bundle: 1.2MB → 300KB ⬇️ 75%
- Page load: 6.8s → 1.5s ⬇️ 78%

✅ Goal achieved! (Target: 90, Actual: 92)
```

---

## Tips

💡 **Measure first:** Always profile before optimizing  
💡 **Focus on biggest wins:** 80/20 rule  
💡 **Optimize iteratively:** One change at a time  
💡 **Monitor in production:** Real user metrics  
💡 **Budget performance:** Set limits for bundle/queries


---

##  Optimize Checklist

- [ ] Prerequisites and environment verified
- [ ] All workflow steps executed sequentially
- [ ] Expected output validated against requirements
- [ ] No unresolved errors or warnings in tests/logs
- [ ] Related documentation updated if impact is systemic


---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| Không tìm thấy bottleneck | Dùng profiler (Chrome DevTools, `EXPLAIN ANALYZE`) |
| Optimization gây regression | Revert, viết benchmark test trước khi optimize |
| Bundle size vẫn lớn | Kiểm tra dynamic imports, tree-shaking config |
| Database query vẫn chậm | Check missing indexes, N+1 queries, connection pooling |




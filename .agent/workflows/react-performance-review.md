---
description: React performance optimization review workflow
priority: impact-driven
---

# React Performance Review Workflow

**Purpose:** Systematic performance review using Vercel Best Practices with impact-driven prioritization.

---

## When to Use

✅ **Use this workflow when:**
- User requests performance optimization
- Code review reveals performance issues
- App is slow (load time > 2s, interactions lag)
- Building production features
- Refactoring existing components

❌ **Skip this workflow when:**
- Prototyping/MVP stage (<100 users)
- Component renders in <16ms
- No user complaints
- Premature optimization (profile first!)

---

## Pre-Review Setup

Before starting:

1. **Install profiling tools** (if not already):
   ```bash
   # React DevTools (browser extension)
   # Lighthouse (Chrome built-in)
   # Bundle analyzer
   npm install --save-dev @next/bundle-analyzer
   ```

2. **Gather baseline metrics:**
   - Time to Interactive (TTI)
   - Largest Contentful Paint (LCP)
   - Bundle size (check network tab)
   - Current Lighthouse score

3. **Identify the problem area:**
   - Specific page/component
   - User-reported issue
   - Metric regression

---

## Review Checklist (PRIORITY ORDER)

> [!IMPORTANT]
> Follow this order STRICTLY. Fix CRITICAL before MEDIUM/LOW.

### 🔴 CRITICAL Priority (Fix FIRST)

**Impact: 2-10× improvement**

#### 1. Check for Async Waterfalls

**Scan for:**
- [ ] Sequential `await` calls that could be `Promise.all()`
- [ ] `await` in unused code branches
- [ ] API routes with sequential fetches
- [ ] Multiple Inertia requests where one would work

**Tools:**
```bash
# Search for sequential awaits
grep -n "await.*await" **/*.{ts,tsx,js,jsx}

# Check API routes
grep -r "await fetch" app/api/
```

**Fix examples:**
- Replace sequential awaits with `Promise.all()`
- Move `await` inside conditional branches
- Use `better-all` for partial dependencies
- Combine Inertia requests

**Expected Impact:** 2-5x faster (600ms → 120-300ms)

---

#### 2. Check Bundle Size

**Scan for:**
- [ ] Barrel file imports (`import { X } from '@/components'`)
- [ ] Heavy libraries not code-split (Monaco, Chart.js, etc.)
- [ ] Analytics/tracking loaded upfront
- [ ] Unused exports in bundle

**Tools:**
```bash
# Analyze bundle
npm run build
# Check .next/analyze/ output

# Find barrel imports
grep -r "from '@/components'" src/
grep -r "from 'lucide-react'" src/
```

**Fix examples:**
- Direct imports: `import Button from '@/components/Button'`
- Dynamic imports: `const Chart = lazy(() => import('./Chart'))`
- Defer third-party libraries
- Use Next.js `optimizePackageImports`

**Expected Impact:** 30-60% smaller bundle (800KB → 320-560KB)

---

### 🟠 HIGH Priority (Fix SECOND)

**Impact: Significant gains**

#### 3. Server-Side Performance (Next.js/Inertia)

**Scan for:**
- [ ] Missing `React.cache()` for repeated queries
- [ ] No LRU caching for expensive operations
- [ ] Missing Suspense boundaries (entire page blocks)
- [ ] Serializing unnecessary data across RSC boundary

**Tools:**
```bash
# Find duplicate queries
grep -r "fetchUser\|getUser" app/

# Check Suspense usage
grep -r "Suspense" app/
```

**Fix examples:**
- Wrap queries with `React.cache()`
- Add LRU cache for cross-request data
- Strategic Suspense placement
- Only serialize data client needs

**Expected Impact:** 40-70% faster server response (500ms → 150-300ms)

---

### 🟡 MEDIUM Priority (Fix THIRD)

**Impact: Moderate gains**

#### 4. Client-Side Data Fetching

**Scan for:**
- [ ] Multiple components fetching same data
- [ ] No SWR/React Query deduplication
- [ ] Multiple global event listeners
- [ ] Large localStorage reads on every render

**Fix examples:**
- Use SWR for automatic deduplication
- Single global event listener
- Version and minimize localStorage data

**Expected Impact:** 20-40% fewer network requests

---

#### 5. Re-render Optimization

**Scan for:**
- [ ] Expensive parsing in initial state (not lazy)
- [ ] `setState(count + 1)` instead of functional updates
- [ ] Large components re-rendering on small state changes
- [ ] Missing memoization where needed

**Tools:**
```bash
# Use React DevTools Profiler
# Enable "Highlight updates" in React DevTools
```

**Fix examples:**
- Lazy state initialization: `useState(() => parse())`
- Functional updates: `setState(prev => prev + 1)`
- Extract to memoized components
- Narrow effect dependencies

**Expected Impact:** 30-50% fewer re-renders

---

#### 6. Rendering Performance

**Scan for:**
- [ ] Long lists without virtualization/content-visibility
- [ ] Hydration mismatches causing flicker
- [ ] Heavy SVG manipulation
- [ ] Static JSX recreated on every render

**Fix examples:**
- CSS `content-visibility: auto` for long lists
- Prevent hydration mismatch with Suspense
- Hoist static JSX
- Optimize SVG precision

**Expected Impact:** 15-30% smoother interactions

---

### 🟢 LOW Priority (Polish)

**Impact: Incremental**

#### 7. JavaScript Micro-optimizations

**Only apply AFTER all above are fixed!**

**Scan for:**
- [ ] Multiple array iterations (`.filter().map().reduce()`)
- [ ] Array lookups in loops (use Set/Map)
- [ ] Repeated function calls in loops
- [ ] Heavy operations in render path

**Fix examples:**
- Combine array operations into single pass
- Use Set/Map for O(1) lookups
- Cache property access in loops
- Hoist RegExp creation

**Expected Impact:** 5-10% speed improvement

---

## Execution Process

### Step 1: Profile (MANDATORY)

**Never optimize without profiling first!**

```bash
# Run Lighthouse
npx lighthouse http://localhost:3000 --view

# React DevTools Profiler
# 1. Open React DevTools
# 2. Profiler tab
# 3. Start recording
# 4. Perform slow action
# 5. Stop recording
# 6. Analyze flame graph
```

**Document findings:**
- What's slow? (waterfall/bundle/re-renders?)
- Where? (specific component/route)
- How slow? (metrics)

---

### Step 2: Fix by Priority

Start from CRITICAL, work down:

1. **Fix one category at a time**
   - Don't mix CRITICAL with MEDIUM fixes
   - Complete all CRITICAL before moving to HIGH

2. **Measure after each fix**
   - Re-run Lighthouse
   - Check bundle size
   - Verify improvement

3. **Document changes**
   - What was fixed
   - Expected vs actual improvement
   - Any trade-offs

---

### Step 3: Validate

**Before/After Comparison:**

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| TTI | ___s | ___s | __% |
| LCP | ___s | ___s | __% |
| Bundle | ___KB | ___KB | __% |
| Lighthouse | __ | __ | __pts |

**Verification:**
- [ ] All metrics improved or stayed same
- [ ] No functionality broken
- [ ] Tests still pass
- [ ] Lighthouse score increased

---

### Step 4: Report

**Performance Optimization Report Template:**

```markdown
## Performance Optimization Report

**Component/Page:** [name]
**Date:** [date]

### Issues Found (by priority):
- 🔴 CRITICAL: [issue 1]
- 🟠 HIGH: [issue 2]
- 🟡 MEDIUM: [issue 3]

### Fixes Applied:
1. **[Fix name]** (CRITICAL)
   - Before: 600ms waterfall
   - After: 200ms parallel
   - Impact: 3x faster ✅

2. **[Fix name]** (HIGH)  
   - Before: 800KB bundle
   - After: 400KB bundle
   - Impact: 50% smaller ✅

### Overall Results:
- TTI: 2.5s → 1.2s (52% faster) 🎯
- Bundle: 800KB → 400KB (50% smaller) 🎯
- Lighthouse: 65 → 85 (+20 points) 🎯

### Recommendations:
- [Optional: Further optimizations]
- [Optional: Monitoring suggestions]
```

---

## Common Patterns

### Pattern 1: Inertia.js Waterfall

**Problem:**
```typescript
// Multiple Inertia loads
const { user } = usePage().props
const [config, setConfig] = useState(null)

useEffect(() => {
  fetch('/api/config').then(setConfig) // ❌ Waterfall
}, [])
```

**Solution:**
```php
// Laravel Controller - Single Inertia load
return Inertia::render('Page', [
    'user' => $user,
    'config' => $config, // ✅ Load together
]);
```

---

### Pattern 2: Barrel Import

**Problem:**
```typescript
import { Button, Card, Modal } from '@/components' // ❌ Loads everything
```

**Solution:**
```typescript
// Option 1: Direct imports
import { Button } from '@/components/Button'
import { Card } from '@/components/Card'

// Option 2: Next.js config
// next.config.js
module.exports = {
  experimental: {
    optimizePackageImports: ['@/components']
  }
}
```

---

### Pattern 3: Server-Side Deduplication

**Problem:**
```typescript
// Multiple components fetch same user
async function Header() {
  const user = await fetchUser() // Fetch 1
}

async function Sidebar() {
  const user = await fetchUser() // Fetch 2 (duplicate!)
}
```

**Solution:**
```typescript
import { cache } from 'react'

const getUser = cache(async () => {
  return fetchUser() // Only fetches once per request
})

async function Header() {
  const user = await getUser()
}

async function Sidebar() {
  const user = await getUser() // Reuses cached result
}
```

---

## Tips & Best Practices

1. **Always profile first** - Don't guess what's slow
2. **Fix CRITICAL before MEDIUM** - Impact prioritization matters
3. **Measure improvements** - Verify fixes actually help
4. **Document changes** - Help future developers understand optimizations
5. **Avoid premature optimization** - Don't optimize during prototyping
6. **Consider trade-offs** - Some optimizations add complexity
7. **Test thoroughly** - Ensure optimizations don't break functionality

---

## References

- [Vercel React Best Practices](https://vercel.com/blog/introducing-react-best-practices)
- [react-performance SKILL.md](file:///.agent/skills/react-performance/SKILL.md)
- [react-performance AGENTS.md](file:///.agent/skills/react-performance/AGENTS.md)

---

**Created:** 2026-01-19  
**Version:** 1.0  
**Purpose:** Systematic performance review with impact-driven prioritization

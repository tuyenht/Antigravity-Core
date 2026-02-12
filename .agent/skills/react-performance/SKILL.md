---
name: react-performance
description: Production-grade React performance optimization based on Vercel Best Practices (10+ years production experience)
version: 1.1
impact-driven: true
priority-order: CRITICAL → HIGH → MEDIUM → LOW
source: https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices
allowed-tools: Read, Write, Edit, Glob, Grep
---

# React Performance Optimization

> Production-grade performance rules from Vercel, prioritized by real-world impact.

---

## 🎯 CORE PHILOSOPHY

### The Problem With Traditional Advice

Most performance advice is **not prioritized**:
- "Use useMemo" 
- "Optimize re-renders"
- "Code-split everything"

**Result:** Developers waste time optimizing the wrong things.

### The Vercel Approach: Impact-Driven

> **Fix 600ms waterfall delays BEFORE optimizing 5ms useMemo calls**

**Ordering matters:**

```
CRITICAL (2-10× improvement)     ← Fix FIRST
├── Eliminate Waterfalls
└── Reduce Bundle Size

HIGH (Significant gains)         ← Fix SECOND
└── Server-Side Performance

MEDIUM (Moderate gains)          ← Fix THIRD
├── Client-Side Fetching
├── Re-render Optimization
└── Rendering Performance

LOW (Incremental)                ← Fix LAST
├── JavaScript Performance
└── Advanced Patterns
```

---

## 📚 COMPLETE RULES REFERENCE

> [!NOTE]
> For AI Agents: The complete, detailed rules with all code examples are in `AGENTS.md` in this same directory. Reference that file for specific examples and detailed implementations.

**Summary of Categories:**

1. **Eliminating Waterfalls** (CRITICAL) - 2-10× improvement
2. **Bundle Size Optimization** (CRITICAL) - Major TTI/LCP gains
3. **Server-Side Performance** (HIGH) - Significant response time reduction
4. **Client-Side Data Fetching** (MEDIUM-HIGH) - Moderate to significant gains
5. **Re-render Optimization** (MEDIUM) - Better responsiveness
6. **Rendering Performance** (MEDIUM) - Visual performance
7. **JavaScript Performance** (LOW-MEDIUM) - Micro-optimizations
8. **Advanced Patterns** (VARIES) - Situational improvements

---

## 🎯 USAGE GUIDELINES FOR AGENTS

### When to Apply This Skill

✅ **DO apply when:**
- Optimizing React/Next.js performance
- Code review for performance issues
- User reports slow load times
- Building production features
- Refactoring existing components

❌ **DON'T apply when:**
- Prototyping/MVP stage
- Component renders in <16ms
- Bundle is already small (<100KB)
- No user complaints
- Over-optimizing prematurely

### Priority Decision Tree

```
User wants to optimize React code
├── Profile first - DON'T guess!
│   └── Use React DevTools Profiler
│
├── Identify bottleneck type
│   ├── Slow initial load? → Check CRITICAL (1-2)
│   │   ├── Network waterfalls? → Section 1
│   │   └── Large bundle? → Section 2
│   │
│   ├── Slow server rendering? → Check HIGH (3)
│   │   └── Server-side performance → Section 3
│   │
│   └── Slow interactions? → Check MEDIUM (4-6)
│       ├── Re-renders → Section 5
│       └── Render performance → Section 6
│
└── Apply fix, measure improvement
    └── Document impact (e.g., "300ms → 50ms")
```

### Communication Template

When suggesting optimizations, use this format:

```
**Performance Issue Identified**

Category: [CRITICAL/HIGH/MEDIUM/LOW]
Rule: [Section].[Number] [Rule Name]
Impact: [Expected improvement]

Current Code:
[bad example]

Suggested Fix:
[good example]

Rationale:
[Why this matters, cite metric if possible]

Estimated Impact:
[e.g., "2-5x faster initial load" or "Reduces bundle by 300KB"]
```

---

## 📋 QUICK REFERENCE: TOP RULES

### CRITICAL Priority

**1. Eliminate Async Waterfalls**
- ✅ Use `Promise.all()` for independent operations
- ✅ Defer `await` until actually needed
- ✅ Parallelization with `better-all` for dependencies
- ❌ Don't await sequentially when operations are independent

**2. Reduce Bundle Size**
- ✅ Avoid barrel file imports (import from specific files)
- ✅ Dynamic imports for heavy components
- ✅ Conditional module loading
- ❌ Don't import entire libraries when only using small parts

### HIGH Priority

**3. Server-Side Performance**
- ✅ Authenticate Server Actions like API routes (CRITICAL security)
- ✅ Use `React.cache()` for deduplication
- ✅ Strategic Suspense boundaries
- ✅ LRU caching for expensive operations
- ✅ Avoid duplicate serialization in RSC props
- ❌ Don't fetch same data multiple times per request

### MEDIUM Priority

**4. Client-Side Fetching**
- ✅ Use SWR for automatic deduplication
- ✅ Deduplicate global event listeners
- ❌ Don't fetch same data in multiple components

**5. Re-render Optimization**
- ✅ Lazy state initialization
- ✅ Functional setState updates
- ✅ Extract to memoized components
- ✅ Derive state during render, not in effects
- ✅ Use useRef for transient frequent values
- ❌ Don't parse expensive data on every render
- ❌ Don't model user actions as state + effect

---

## 🔗 INTEGRATION WITH OTHER SKILLS

### Use With react-patterns

- **react-patterns** → How to structure components (patterns, hooks, composition)
- **react-performance** → How to optimize components (performance, metrics)

**Example workflow:**
1. Use `react-patterns` to design component structure
2. Build feature
3. Use `react-performance` to optimize bottlenecks
4. Measure improvements

### Use With nextjs-best-practices

- **nextjs-best-practices** → Next.js routing, SSR basics, App Router patterns
- **react-performance** → Server-side optimization (Section 3), streaming, caching

**Example workflow:**
1. Use `nextjs-best-practices` for routing and data fetching setup
2. Use `react-performance` Section 3 for server-side optimizations
3. Apply CRITICAL rules for client-side performance

---

## 📊 METRICS TO TRACK

### Before Optimization

- [ ] Time to Interactive (TTI)
- [ ] Largest Contentful Paint (LCP)
- [ ] Total Bundle Size
- [ ] Network waterfall duration
- [ ] Re-render count

### After Optimization

- [ ] TTI improvement (target: >30% faster)
- [ ] LCP improvement (target: >25% faster)
- [ ] Bundle size reduction (target: >30% smaller)
- [ ] Waterfall reduction (target: >50% faster)
- [ ] Re-render reduction (target: >40% fewer)

### Report Template

```markdown
## Performance Optimization Report

**Component:** [ComponentName]

**Issues Found:**
- CRITICAL: [Issue 1]
- HIGH: [Issue 2]

**Fixes Applied:**
1. [Fix 1] (CRITICAL)
   - Before: 600ms
   - After: 200ms
   - Impact: 3x faster

2. [Fix 2] (HIGH)
   - Before: 500KB
   - After: 200KB
   - Impact: 60% bundle reduction

**Overall Impact:**
- TTI: 2.5s → 1.2s (52% faster)
- Bundle: 800KB → 400KB (50% smaller)
```

---

## ✅ CHECKLIST FOR AGENTS

Before completing performance optimization work:

**CRITICAL Priority:**
- [ ] Checked for async waterfalls
- [ ] Verified Promise.all() usage for independent ops
- [ ] Checked bundle size (avoid barrel imports)
- [ ] Verified dynamic imports for heavy components

**HIGH Priority:**
- [ ] Checked server-side caching (if applicable)
- [ ] Verified React.cache() for deduplication (Next.js)
- [ ] Checked Suspense boundary placement

**MEDIUM Priority:**
- [ ] Verified lazy state initialization
- [ ] Checked functional setState updates
- [ ] Verified component memoization where needed

**Documentation:**
- [ ] Measured before/after metrics
- [ ] Documented expected impact
- [ ] Updated component docs with performance notes
- [ ] Added comments explaining optimizations

---

## 🚀 STACK-SPECIFIC NOTES

### Laravel + Inertia.js + React

**Common Patterns:**

1. **Inertia Request Waterfalls**
   ```typescript
   // ❌ Bad - Multiple Inertia loads
   const { user } = usePage().props
   const [config, setConfig] = useState(null)
   useEffect(() => {
     fetch('/api/config').then(setConfig)
   }, [])
   
   // ✅ Good - Single Inertia load
   // In Laravel controller:
   return Inertia::render('Page', [
     'user' => $user,
     'config' => $config,  // Load together
   ]);
   ```

2. **Partial Reloads**
   - Use `only` and `except` to minimize data transfer
   - Prevent unnecessary full-page reloads

3. **Laravel Query Optimization**
   - Eager load relationships for React components
   - Shape API responses for frontend consumption

---

## 📖 REFERENCES

- [Vercel Blog Post](https://vercel.com/blog/introducing-react-best-practices)
- [GitHub Repository](https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices)
- [Full AGENTS.md](./AGENTS.md) - Complete rules with examples (40+ rules)
- [React Documentation](https://react.dev/reference/react)
- [Next.js Performance](https://nextjs.org/docs/app/building-your-application/optimizing)

---

> **Remember:** Fix CRITICAL issues first. Don't waste time on LOW optimizations if CRITICAL waterfalls exist. Always profile before optimizing, and measure after to confirm improvements.

**Created:** 2026-01-19  
**Version:** 1.0  
**Source:** Vercel Labs  
**Maintained By:** Antigravity System

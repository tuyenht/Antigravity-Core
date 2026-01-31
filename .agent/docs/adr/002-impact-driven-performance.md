# ADR-002: Impact-Driven Performance Optimization

**Date:** 2026-01-19  
**Status:** Accepted  
**Deciders:** Performance Team + Expert Panel  
**Category:** Performance Strategy

---

## Context

Need a systematic approach to performance optimization that:
- Maximizes impact with limited time
- Prevents wasted effort on micro-optimizations
- Provides measurable results
- Works across full stack (frontend + backend)

---

## Decision

**Adopted Approach: Impact-Driven Prioritization**

```
🔴 CRITICAL (Fix FIRST)     → 5-20× improvement
🟠 HIGH (Fix SECOND)        → 2-5× improvement
🟡 MEDIUM (Fix THIRD)       → 20-50% improvement
🟢 LOW (Fix LAST)           → <20% improvement
```

**Framework Source:** Vercel React Best Practices

---

## Rationale

### Why Impact-Driven?

**Traditional Approach (WRONG):**
```
Developer optimizes:
1. Array loop (2ms → 1ms) - 50% faster!  ❌
2. useMemo hook (5ms → 3ms) - 40% faster! ❌
3. Then discovers N+1 queries (600ms → 100ms) - 6× faster! ✅

Problem: Spent time on LOW impact before CRITICAL
```

**Impact-Driven Approach (CORRECT):**
```
System detects:
1. N+1 queries: CRITICAL (600ms → 100ms) - Fix FIRST ✅
2. Missing indexes: CRITICAL (5000ms → 50ms) - Fix SECOND ✅
3. Array loop: LOW (2ms → 1ms) - Fix LAST or skip ✅

Result: 6× improvement in 10 minutes vs hours wasted
```

### Why Vercel Framework?

**Pros:**
- ✅ Production-tested (millions of apps)
- ✅ Quantified impact (not "optimize queries")
- ✅ Specific rules with examples
- ✅ Measurable outcomes

**Alternatives Considered:**
- Generic "best practices": Too vague
- Framework-specific only: Not full-stack
- Custom framework: Reinventing wheel

**Decision:** Vercel's 10+ years experience is valuable

---

## Implementation

### Frontend (React)

**CRITICAL Priority:**
- Eliminate async waterfalls (Promise.all)
- Reduce bundle size (direct imports)
- Implement code splitting

**Skill:** `react-performance`

---

### Backend (Laravel)

**CRITICAL Priority:**
- Eliminate N+1 queries (eager loading)
- Add database indexes
- Implement query caching

**Skill:** `laravel-performance`

---

### Bridge (Inertia)

**CRITICAL Priority:**
- Use partial reloads (only prop)
- Minimize prop serialization
- Implement prefetching

**Skill:** `inertia-performance`

---

## Consequences

### Positive

- ✅ Fix high-impact issues first
- ✅ Measurable improvements (3×, 6×, 10×)
- ✅ No wasted effort on micro-optimizations
- ✅ Agents apply same prioritization

### Negative

- ⚠️ Requires profiling (can't guess)
- ⚠️ Need to resist "easy optimizations first"
- ⚠️ Learning curve (impact assessment)

### Mitigation

- Integrated profiling tools (Debugbar, Telescope, React DevTools)
- Training on priority framework
- Examples in each skill

---

## Validation

**Before:**
- Generic advice: "Use cache", "Optimize queries"
- No prioritization
- Unknown impact

**After:**
- Specific: "Eliminate N+1 (600ms → 100ms)"
- CRITICAL → LOW ordering
- Quantified: "6× faster"

---

## References

- [Vercel React Best Practices](https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices)
- [laravel-performance skill](file:///.agent/skills/laravel-performance/SKILL.md)
- [inertia-performance skill](file:///.agent/skills/inertia-performance/SKILL.md)

---

**Previous:** ADR-001 (Tech Stack)  
**Next:** ADR-003 (Skill Consolidation Strategy)

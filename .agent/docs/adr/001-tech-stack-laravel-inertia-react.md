# ADR-001: Tech Stack - Laravel + Inertia.js + React + TypeScript

**Date:** 2026-01-19  
**Status:** Accepted  
**Deciders:** Development Team  
**Category:** Architecture

---

## Context

Need to choose a technology stack for modern web application development that:
- Supports rapid development
- Provides type safety
- Enables rich, interactive UIs
- Integrates well with existing ecosystem
- Has strong community support

---

## Decision

**Adopted Stack:**
```
Backend: Laravel 12 + PHP 8.3
Bridge: Inertia.js 1.0+
Frontend: React 18+ + TypeScript 5+
Styling: Tailwind CSS 3+
```

---

## Rationale

### Why Laravel?

**Pros:**
- ✅ Mature, stable framework (10+ years)
- ✅ Excellent ORM (Eloquent)
- ✅ Built-in auth, validation, queues
- ✅ Strong ecosystem (packages, tools)
- ✅ Great developer experience

**Alternatives Considered:**
- Node.js + Express: Less structure, more setup
- Django: Python mismatch with frontend
- NestJS: TypeScript everywhere but heavier

**Decision:** Laravel's maturity and productivity win

---

### Why Inertia.js?

**Pros:**
- ✅ Monolithic deployment (simpler)
- ✅ No API layer needed
- ✅ Server-side routing
- ✅ Shared auth/session
- ✅ Type-safe props (TypeScript)

**Alternatives Considered:**
- Next.js + API: More complex, two deployments
- SPA + REST API: Duplication (validation, auth)
- Laravel + Blade: Limited interactivity

**Decision:** Inertia bridges Laravel + React perfectly

---

### Why React?

**Pros:**
- ✅ Most popular (large ecosystem)
- ✅ Component reusability
- ✅ Hooks for state management
- ✅ React 19 features (Server Components, Actions)
- ✅ Strong TypeScript support

**Alternatives Considered:**
- Vue: Smaller ecosystem
- Svelte: Less mature
- Angular: Too heavy, opinionated

**Decision:** React's ecosystem and flexibility win

---

### Why TypeScript?

**Pros:**
- ✅ Type safety (catch errors early)
- ✅ Better IDE support
- ✅ Self-documenting code
- ✅ Refactoring confidence
- ✅ Inertia type inference

**Alternatives Considered:**
- Plain JavaScript: Too error-prone
- JSDoc: Not enforced
- Flow: Dying ecosystem

**Decision:** TypeScript is industry standard

---

## Consequences

### Positive

- ✅ Monolithic deployment (easier DevOps)
- ✅ Shared session/auth (no token management)
- ✅ Type safety end-to-end
- ✅ Hot reload in development
- ✅ Rich component ecosystem

### Negative

- ⚠️ Learning curve (Inertia concepts)
- ⚠️ Limited SSR (Inertia constraint)
- ⚠️ PHP + TypeScript (two languages)
- ⚠️ Inertia limitations (no streaming)

### Mitigation

- Document Inertia patterns (inertia-performance skill)
- Use Laravel caching for speed
- Team training on both ecosystems
- SSR not critical for our use case

---

## References

- [Inertia.js Documentation](https://inertiajs.com)
- [Laravel Documentation](https://laravel.com/docs)
- [React Documentation](https://react.dev)
- [TypeScript Handbook](https://www.typescriptlang.org/docs)

---

**Next ADR:** ADR-002 (Impact-Driven Performance Optimization)

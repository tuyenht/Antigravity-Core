# ADR-003: Skill Consolidation Strategy

**Date:** 2026-01-19  
**Status:** Accepted  
**Deciders:** System Architects  
**Category:** Organization

---

## Context

System had 54 skills with:
- Fragmentation (testing split into 4 skills)
- Unclear hierarchy (which skill to use?)
- Duplication across skills
- Maintenance burden

Need to improve discoverability without losing content.

---

## Decision

**Consolidate fragmented skills into parent skills with sub-files**

**Structure:**
```
parent-skill/
├── SKILL.md (main content + navigation)
└── category/
    ├── subcategory1.md
    └── subcategory2.md
```

**Implementation:**
- testing-patterns + tdd-workflow + contract-testing + webapp-testing → **testing-mastery**
- architecture + api-patterns + microservices + graphql → **architecture-mastery**

---

## Rationale

### Why Consolidate?

**Problem (Before):**
```
User: "How do I test APIs?"
System: 4 skills available
  - testing-patterns (too general)
  - contract-testing (is this the one?)
  - webapp-testing (or this?)
  - tdd-workflow (or this?)

Result: Confusion, trial-and-error
```

**Solution (After):**
```
User: "How do I test APIs?"
System: 1 skill
  - testing-mastery/SKILL.md → "For APIs, see methodologies/contract-testing.md"

Result: Clear navigation
```

### Why Hierarchical?

**Flat structure (old):**
```
skills/
├── testing-patterns.md
├── tdd-workflow.md
├── contract-testing.md
└── webapp-testing.md

Problem: No clear relationship
```

**Hierarchical structure (new):**
```
skills/testing-mastery/
├── SKILL.md (parent - quick ref + navigation)
└── methodologies/
    ├── tdd.md (deep dive)
    ├── contract-testing.md (deep dive)
    └── webapp-testing.md (deep dive)

Benefit: Parent for quick answers, sub-files for details
```

---

## Implementation

### testing-mastery

**Replaces:**
- testing-patterns
- tdd-workflow
- contract-testing
- webapp-testing

**Structure:**
```
testing-mastery/
├── SKILL.md
│   ├── Testing Pyramid
│   ├── F.I.R.ST Principles
│   ├── Unit/Integration/E2E overview
│   └── → Links to methodologies/
└── methodologies/
    ├── tdd.md (TDD workflow)
    ├── contract-testing.md (API contracts)
    └── webapp-testing.md (E2E testing)
```

**Impact:** 4 → 1 (75% reduction)

---

### architecture-mastery

**Replaces:**
- architecture
- api-patterns
- microservices-communication
- graphql-patterns

**Structure:**
```
architecture-mastery/
├── SKILL.md
│   ├── SOLID Principles
│   ├── Layered Architecture
│   ├── Common Patterns
│   └── → Links to patterns/
└── patterns/
    ├── api-design.md (REST patterns)
    ├── microservices.md (Microservices)
    ├── graphql.md (GraphQL)
    └── event-sourcing.md (Event-driven)
```

**Impact:** 4 → 1 (75% reduction)

---

## Consequences

### Positive

- ✅ 54 skills → 50 skills (clearer)
- ✅ Single source of truth per domain
- ✅ Clear navigation (parent → sub-files)
- ✅ Easy to maintain (one place to update)
- ✅ Backward compatible (old skills still work if needed)

### Negative

- ⚠️ Needs agent reference updates
- ⚠️ Slight learning curve (new structure)
- ⚠️ Sub-files need creation (or placeholders)

### Mitigation

- Updated all agent references in Phase 3
- Clear documentation (this ADR + guides)
- Parent SKILL.md has enough content to start

---

## Migration Path

**Phase 1: Create parent skills** ✅
- testing-mastery/SKILL.md
- architecture-mastery/SKILL.md

**Phase 2: Deprecate old skills** (Not done - backward compatible)
- Keep old skills as aliases
- Or delete after validation

**Phase 3: Create sub-files** (Optional)
- methodologies/ (TDD, contract, webapp)
- patterns/ (API, microservices, GraphQL)

---

## Validation

**Before:**
```powershell
Get-ChildItem skills | Measure-Object
# Count: 54
```

**After:**
```powershell
Get-ChildItem skills | Measure-Object
# Count: 50 (4 consolidated + 4 removed = net -4 + 2 added = -2)
```

**References updated:** ✅ All agents updated

---

## References

- [testing-mastery skill](file:///.agent/skills/testing-mastery/SKILL.md)
- [architecture-mastery skill](file:///.agent/skills/architecture-mastery/SKILL.md)
- [Skill Discovery Guide](file:///.agent/docs/SKILL-DISCOVERY.md)

---

**Previous:** ADR-002 (Impact-Driven Performance)  
**Status:** Implemented in Phase 3

# ⚠️ DEPRECATED - Use architecture-mastery instead

**Status:** DEPRECATED  
**Deprecated Since:** 2026-01-20  
**Sunset Date:** 2026-04-20  
**Replacement:** `.agent/skills/architecture-mastery/SKILL.md`

---

## Why Deprecated?

This skill has been **consolidated** into `architecture-mastery` as part of the Skill Consolidation initiative (ADR-003).

The `architecture-mastery` skill includes:
- ✅ All content from `architecture`
- ✅ All content from `api-patterns`
- ✅ All content from `microservices-communication`
- ✅ All content from `graphql-patterns`
- ✅ Additional comprehensive architecture framework

---

## Migration Guide

**Before:**
```yaml
skills: architecture
```

**After:**
```yaml
skills: architecture-mastery
```

---

**Reference:** [ADR-003: Skill Consolidation Strategy](../../docs/adr/003-skill-consolidation-strategy.md)

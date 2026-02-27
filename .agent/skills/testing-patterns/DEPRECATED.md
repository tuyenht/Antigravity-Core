# ⚠️ DEPRECATED - Use testing-mastery instead

**Status:** DEPRECATED  
**Deprecated Since:** 2026-01-20  
**Sunset Date:** 2026-04-20  
**Replacement:** `.agent/skills/testing-mastery/SKILL.md`

---

## Why Deprecated?

This skill has been **consolidated** into `testing-mastery` as part of the Skill Consolidation initiative (ADR-003).

The `testing-mastery` skill includes:
- ✅ All content from `testing-patterns`
- ✅ All content from `tdd-workflow`
- ✅ All content from `contract-testing`
- ✅ All content from `webapp-testing`
- ✅ Additional comprehensive testing framework

---

## Migration Guide

**Before:**
```yaml
skills: testing-patterns
```

**After:**
```yaml
skills: testing-mastery
```

---

## What to Do

1. Update any agent referencing this skill to use `testing-mastery`
2. This directory will be removed after sunset date

---

**Reference:** [ADR-003: Skill Consolidation Strategy](../../docs/adr/003-skill-consolidation-strategy.md)

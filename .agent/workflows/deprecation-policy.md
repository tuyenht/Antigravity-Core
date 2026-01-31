---
description: Graceful deprecation process for skills, agents, and workflows. Ensures proper migration before removal.
turbo-all: false
---

# Deprecation Policy Workflow

> Safely deprecate and remove outdated components

---

## 📋 Deprecation Lifecycle

```
ACTIVE → DEPRECATED → SUNSET → REMOVED
         (3 months)   (final notice)
```

---

## Step 1: Mark as Deprecated

**Create `DEPRECATED.md` in component directory:**

```markdown
# ⚠️ DEPRECATED - Use [replacement] instead

**Status:** DEPRECATED
**Deprecated Since:** [date]
**Sunset Date:** [date + 3 months]
**Replacement:** [path to replacement]

## Why Deprecated?
[Reason]

## Migration Guide
[How to migrate]
```

---

## Step 2: Update References

**For Skills:**
- [ ] Update all agents using deprecated skill
- [ ] Update skills/README.md
- [ ] Add migration notes to replacement skill

**For Agents:**
- [ ] Update project.json agent list
- [ ] Update triage-agent routing
- [ ] Update orchestrator delegation

**For Workflows:**
- [ ] Update workflow index
- [ ] Add redirect in docs

---

## Step 3: Notify (1 month before sunset)

**Create issue or PR comment:**
```
⚠️ DEPRECATION NOTICE

[Component] will be REMOVED on [sunset date].

Migration required:
- Replace [old] with [new]

See: [link to DEPRECATED.md]
```

---

## Step 4: Final Warning (1 week before sunset)

**Add console warning (if applicable):**
```
[DEPRECATION] [Component] will be removed on [date].
Use [replacement] instead.
```

---

## Step 5: Remove After Sunset

**Removal checklist:**
- [ ] Verify no references remain
- [ ] Delete directory/file
- [ ] Update documentation
- [ ] Add to CHANGELOG.md

```bash
# Remove deprecated component
rm -rf .agent/skills/[deprecated-skill]/

# Update CHANGELOG
echo "- Removed deprecated [component]" >> CHANGELOG.md
```

---

## 📊 Current Deprecated Components

### Skills (Sunset: 2026-04-20)

| Skill | Replacement | Status |
|-------|-------------|--------|
| testing-patterns | testing-mastery | DEPRECATED |
| tdd-workflow | testing-mastery | DEPRECATED |
| contract-testing | testing-mastery | DEPRECATED |
| webapp-testing | testing-mastery | DEPRECATED |
| architecture | architecture-mastery | DEPRECATED |
| api-patterns | architecture-mastery | DEPRECATED |
| microservices-communication | architecture-mastery | DEPRECATED |
| graphql-patterns | architecture-mastery | DEPRECATED |

---

## 📁 Files Required

**For each deprecated component:**
1. `DEPRECATED.md` in component directory
2. Entry in this workflow's "Current Deprecated" section
3. Update in `CHANGELOG.md`

---

## 🔧 Automation

**Check for deprecated usage:**
```powershell
# Scan agents for deprecated skill references
Select-String -Path ".agent/agents/*.md" -Pattern "testing-patterns|tdd-workflow|architecture"
```

**Run deprecation check:**
```powershell
.agent/scripts/check-deprecations.ps1
```

---

**Created:** 2026-01-20  
**Policy Version:** 1.0

# Agent Versioning Schema

**Version:** 1.0  
**Created:** 2026-01-20  
**Purpose:** Track agent evolution and changes

---

## 📋 Version Format

**Semantic Versioning:** `MAJOR.MINOR.PATCH`

- **MAJOR:** Breaking changes (API, behavior)
- **MINOR:** New features (backward compatible)
- **PATCH:** Bug fixes, improvements

---

## 📝 Required Fields in Agent Files

Add to YAML frontmatter:

```yaml
---
name: agent-name
description: Agent description
version: "1.0.0"
changelog:
  - version: "1.0.0"
    date: "2026-01-20"
    changes:
      - Initial version
tools: Read, Write, Edit
model: inherit
skills: skill1, skill2
---
```

---

## 📊 Version Tracking

**In project.json:**

```json
{
  "agents": {
    "versions": {
      "ai-code-reviewer": "1.0.0",
      "backend-specialist": "2.1.0",
      "code-generator-agent": "1.1.0",
      "test-generator": "1.0.0",
      "triage-agent": "1.0.0"
    }
  }
}
```

---

## 🔄 When to Bump Version

| Change Type | Example | Version Bump |
|-------------|---------|--------------|
| New skill added | Added `testing-mastery` | MINOR (1.0 → 1.1) |
| Description updated | Clarified role | PATCH (1.0.0 → 1.0.1) |
| Behavior changed | Different output format | MAJOR (1.0 → 2.0) |
| Bug fix | Fixed RBA validation | PATCH (1.0.0 → 1.0.1) |
| Tools changed | Added new tool | MINOR (1.0 → 1.1) |

---

## 📖 Changelog Format

```yaml
changelog:
  - version: "2.0.0"
    date: "2026-01-25"
    changes:
      - "BREAKING: Changed output format to JSON"
      - "Added support for batch processing"
      
  - version: "1.1.0"
    date: "2026-01-20"
    changes:
      - "Added testing-mastery skill"
      - "Improved error messages"
      
  - version: "1.0.0"
    date: "2026-01-19"
    changes:
      - "Initial release"
```

---

## 🛠️ Automation Script

**Auto-bump version:**

```powershell
# .agent/scripts/bump-version.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$Agent,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet('major','minor','patch')]
    [string]$Type,
    
    [Parameter(Mandatory=$true)]
    [string]$ChangeDescription
)

# Implementation would:
# 1. Read current version from agent file
# 2. Bump according to type
# 3. Add changelog entry
# 4. Update project.json
# 5. Commit changes
```

---

## ✅ Current Agent Versions

| Agent | Version | Last Updated |
|-------|---------|--------------|
| ai-code-reviewer | 1.0.0 | 2026-01-19 |
| auto-healing | 1.0.0 | 2026-01-20 |
| backend-specialist | 2.0.0 | 2026-01-19 |
| code-generator-agent | 1.1.0 | 2026-01-20 |
| database-architect | 1.0.0 | 2026-01-17 |
| debugger | 1.0.0 | 2026-01-17 |
| devops-engineer | 1.0.0 | 2026-01-17 |
| documentation-agent | 1.0.0 | 2026-01-17 |
| documentation-writer | 1.0.0 | 2026-01-17 |
| explorer-agent | 1.0.0 | 2026-01-17 |
| frontend-specialist | 2.0.0 | 2026-01-19 |
| game-designer | 1.0.0 | 2026-01-17 |
| laravel-specialist | 1.0.0 | 2026-01-17 |
| manager-agent | 1.0.0 | 2026-01-17 |
| mobile-developer | 1.0.0 | 2026-01-17 |
| mobile-game-developer | 1.0.0 | 2026-01-17 |
| orchestrator | 1.0.0 | 2026-01-17 |
| pc-game-developer | 1.0.0 | 2026-01-17 |
| penetration-tester | 1.0.0 | 2026-01-17 |
| performance-optimizer | 1.0.0 | 2026-01-17 |
| project-planner | 1.0.0 | 2026-01-17 |
| refactor-agent | 1.0.0 | 2026-01-17 |
| security-auditor | 1.0.0 | 2026-01-17 |
| self-correction-agent | 1.0.0 | 2026-01-17 |
| seo-specialist | 1.0.0 | 2026-01-17 |
| test-engineer | 1.1.0 | 2026-01-20 |
| test-generator | 1.0.0 | 2026-01-19 |
| triage-agent | 1.0.0 | 2026-01-19 |

---

**Related:**
- [project.json](../project.json)
- [CHANGELOG.md](../CHANGELOG.md)

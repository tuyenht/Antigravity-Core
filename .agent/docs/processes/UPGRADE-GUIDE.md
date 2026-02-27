# Upgrade Guide — Nâng cấp .agent

**Version:** 5.0.0  
**Last Updated:** 2026-02-27

---

## Overview

Hướng dẫn nâng cấp `.agent/` system từ version cũ lên version mới.

---

## Automatic Upgrade

```powershell
# Recommended method (project-level)
pwsh -File .agent/scripts/update-antigravity.ps1

# Global system update
pwsh -File "$env:USERPROFILE\.antigravity\scripts\update-global.ps1"
```

Script sẽ:
1. Backup current `.agent/` → `.agent.backup.{timestamp}/`
2. Download latest version from GitHub
3. Merge user customizations
4. Verify integrity
5. Report changes

---

## Manual Upgrade

### Step 1: Backup
```bash
cp -r .agent .agent.backup.$(date +%Y%m%d)
```

### Step 2: Download latest
```bash
git clone https://github.com/tuyenht/Antigravity-Core.git .agent-new-temp
```

### Step 3: Replace core files
```bash
# Replace everything EXCEPT user customizations
cp -r .agent-new-temp/.agent/agents/ .agent/agents/
cp -r .agent-new-temp/.agent/skills/ .agent/skills/
cp -r .agent-new-temp/.agent/rules/ .agent/rules/
cp -r .agent-new-temp/.agent/systems/ .agent/systems/
cp -r .agent-new-temp/.agent/scripts/ .agent/scripts/
cp -r .agent-new-temp/.agent/pipelines/ .agent/pipelines/
cp .agent-new-temp/.agent/GEMINI.md .agent/GEMINI.md
cp .agent-new-temp/.agent/ARCHITECTURE.md .agent/ARCHITECTURE.md
cp .agent-new-temp/.agent/reference-catalog.md .agent/reference-catalog.md
```

### Step 4: Keep user files
**DO NOT replace:**
- `.agent/performance-budgets.yml` (custom budgets)
- `.agent/memory/` (learning history)
- `.agent/project.json` (project-specific metrics — merge manually)

### Step 5: Verify
```powershell
.\.agent\scripts\health-check.ps1
```

---

## Version History

| Version | Date | Key Changes |
|---------|------|-------------|
| 5.0.0 | 2026-02-26 | Zero-Confusion Architecture: Intent Router + 6 Pipeline Chains, 110 rules |
| 4.1.1 | 2026-02-26 | Dynamic version system fix |
| 4.1.0 | 2026-02-25 | SDLC Process Upgrade, Team Pipeline v2.0 |
| 4.0.0 | 2026-02-10 | Auto-Rule Discovery, Agent Registry, Orchestration Engine |
| 3.x | 2026-01-31 | Installation system, UI-UX-Pro-Max, communication standards |

Check `CHANGELOG.md` for full history.

---

## Breaking Changes

### v4 → v5
- **Architecture** reorganized to 3-layer (GEMINI Slim → Intent Router → Pipeline Chains)
- **GEMINI.md** reduced from 485 → ~190 lines (lazy-loading via `reference-catalog.md`)
- **6 Pipeline Chains** added (`pipelines/BUILD.md`, etc.)
- **reference-catalog.md** now quick-reference index (not runtime system)

### v3 → v4
- **Agent frontmatter** format changed (added `model:` field)
- **Rules** restructured into 11 categories
- **Standards** split into general + framework-specific
- **Scripts** migrated from Bash → PowerShell (cross-platform)

### Migration Steps
1. Run `pwsh -File .agent/scripts/update-antigravity.ps1`
2. Review `CHANGELOG.md` for specific changes

---

> **See also:** [Deprecation Policy](../DEPRECATION-POLICY.md) | [CHANGELOG](../../CHANGELOG.md)

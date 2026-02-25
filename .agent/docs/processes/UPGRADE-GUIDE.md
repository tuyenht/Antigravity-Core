# Upgrade Guide — Nâng cấp .agent

**Version:** 4.1.0  
**Last Updated:** 2026-02-25

---

## Overview

Hướng dẫn nâng cấp `.agent/` system từ version cũ lên version mới.

---

## Automatic Upgrade

```powershell
# Recommended method
pwsh -File .agent/scripts/update-antigravity.ps1
```

Script sẽ:
1. Backup current `.agent/` → `.agent.backup.{timestamp}/`
2. Download latest version
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
cp .agent-new-temp/.agent/GEMINI.md .agent/GEMINI.md
cp .agent-new-temp/.agent/ARCHITECTURE.md .agent/ARCHITECTURE.md
```

### Step 4: Keep user files
**DO NOT replace:**
- `.agent/context.yml` (project-specific config)
- `.agent/performance-budgets.yml` (custom budgets)
- `.agent/docs/` (user documentation)
- `.agent/memory/` (learning history)

### Step 5: Verify
```powershell
.\.agent\agent.ps1 health
```

---

## Version History

| Version | Date | Key Changes |
|---------|------|-------------|
| 4.0.0 | 2026-02-13 | Auto-Rule Discovery, Agent Registry, 129 rules |
| 3.0.0 | 2025-xx-xx | RBA Protocol, AOC, 27 agents |

Check `CHANGELOG.md` for full history.

---

## Breaking Changes

### v3 → v4
- **Agent frontmatter** format changed (added `model:` field)
- **Rules** restructured into 11 categories
- **Standards** split into general + framework-specific
- **Scripts** migrated from Bash → PowerShell (cross-platform)

### Migration Steps
1. Run `pwsh -File .agent/scripts/update-antigravity.ps1`
2. Review `CHANGELOG.md` for specific changes
3. Check `docs/MIGRATION-GUIDES/` for detailed guides

---

> **See also:** [Deprecation Policy](../DEPRECATION-POLICY.md) | [Migration Guides](../MIGRATION-GUIDES/)

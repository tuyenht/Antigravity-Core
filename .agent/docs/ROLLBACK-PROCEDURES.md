# 🔄 .agent ROLLBACK PROCEDURES

**Version:** 1.0  
**Purpose:** Emergency rollback procedures for .agent system  
**Last Updated:** 2026-01-17

---

## 🚨 WHEN TO USE THIS GUIDE

Use rollback procedures when:
- ✅ Bulk agent update causes system failures
- ✅ STANDARDS.md changes break validation
- ✅ AOC self-correction introduces bugs
- ✅ Template update causes agent malfunctions
- ✅ Any change that degrades system health

---

## 📋 QUICK REFERENCE

| Scenario | Severity | Rollback Time | Command |
|----------|----------|---------------|---------|
| Bulk agent update failed | 🔴 HIGH | ~2 min | `git checkout HEAD~1 -- .agent/agents/` |
| STANDARDS.md too strict | 🟡 MEDIUM | ~1 min | Edit thresholds or revert file |
| AOC causing issues | 🟡 MEDIUM | ~30 sec | Disable manager-agent |
| Template broken | 🔴 HIGH | ~2 min | `git checkout HEAD~1 -- .agent/templates/` |
| Script malfunction | 🟢 LOW | ~1 min | Revert specific script |

---

## 🔴 SCENARIO 1: Bulk Agent Update Failed

### Detection Signs:
- Agents not responding correctly
- Validation errors across multiple agents
- Inconsistent behavior after bulk update script

### Rollback Steps:

**Option A: Git Revert (Recommended)**

```bash
# 1. Check what changed
git status
git diff .agent/agents/

# 2. Revert all agents to previous version
git checkout HEAD~1 -- .agent/agents/

# 3. Verify changes
git diff --cached .agent/agents/

# 4. Test one agent
# [Run a test request to backend-specialist or any agent]

# 5. If working, commit rollback
git commit -m "Rollback: bulk agent update (caused validation errors)"

# 6. Push if needed
git push origin main
```

**Option B: Restore from Backup**

```powershell
# If you have backups
Copy-Item "C:\Backups\.agent\agents\*" ".agent\agents\" -Force -Recurse

# Verify
Get-ChildItem ".agent\agents\"
```

### Verification:

```bash
# Run health check
./.agent/scripts/health-check.ps1

# Run validation
./.agent/scripts/validate-compliance.ps1

# Test specific agent
# Make a request and verify response
```

---

## 🟡 SCENARIO 2: STANDARDS.md Too Strict

### Detection Signs:
- All code failing quality gates
- AOC self-correction unable to fix issues
- Valid code being rejected

### Common Culprits:

1. **Test coverage too high**
   - Line 268: `Minimum Coverage: 80%`

2. **Cyclomatic complexity too low**
   - Line 27: `Cyclomatic complexity > 10 → REJECTED`

3. **Type checking too strict**
   - Line 322: `npx tsc --noEmit` (strict mode)

### Rollback Options:

**Option A: Temporarily Relax Threshold**

```bash
# Edit STANDARDS.md
nano .agent/rules/STANDARDS.md

# Find and modify (example):
# Line 268:
- Minimum Coverage: 80%
+ Minimum Coverage: 70%  # TEMPORARY - reverting after investigation

# Line 27:
- Cyclomatic complexity > 10 → REJECTED
+ Cyclomatic complexity > 15 → REJECTED  # TEMPORARY

# Save and test
./.agent/scripts/validate-compliance.ps1
```

**Option B: Full Revert**

```bash
git checkout HEAD~1 -- .agent/rules/STANDARDS.md
git commit -m "Rollback: STANDARDS.md (too strict for current codebase)"
```

### Post-Rollback:

```markdown
Document decision:
- What threshold was too strict?
- Why current code can't meet it?
- Plan to improve: refactor to meet original standard
```

---

## 🟡 SCENARIO 3: AOC Causing Incorrect Fixes

### Detection Signs:
- Self-correction agent breaking working code
- Documentation-agent updating wrong files
- Refactor-agent suggesting bad patterns

### Rollback Steps:

**Option A: Disable AOC Temporarily**

```bash
# Edit manager-agent.md
nano .agent/agents/manager-agent.md

# Find workflow section and add:
enabled: false  # TEMPORARY - disable AOC until investigation

# Or comment out auto-trigger:
# auto_trigger_conditions:
#   - "Feature marked complete"
```

**Option B: Revert Specific AOC Changes**

```bash
# If AOC made bad commits, revert them
git log --oneline  # Find AOC commit hash

git revert <commit-hash>

# Example:
git revert abc123  # Revert AOC self-correction commit
```

**Option C: Fix Specific Agent**

```bash
# If only self-correction-agent is problematic
git checkout HEAD~1 -- .agent/agents/self-correction-agent.md

git commit -m "Rollback: self-correction-agent (incorrect auto-fixes)"
```

### Investigation:

```markdown
After rollback, investigate:
1. What code did self-correction change?
   - Check git diff of reverted commits
   
2. Why did it think code was wrong?
   - Review self-correction-agent logic
   - Check lint/type error interpretation

3. Update agent to prevent recurrence
   - Add edge case handling
   - Improve error pattern matching
```

---

## 🔴 SCENARIO 4: Agent Template Broken

### Detection Signs:
- New agents created with errors
- Agents not following expected structure
- Template validation failing

### Rollback Steps:

```bash
# 1. Revert template
git checkout HEAD~1 -- .agent/templates/agent-template-v3.md

# 2. Verify template structure
cat .agent/templates/agent-template-v3.md | head -n 50

# 3. Test by creating a new agent (if needed)
# [Create test agent using template]

# 4. Commit rollback
git commit -m "Rollback: agent-template-v3.md (structural issues)"
```

---

## 🟢 SCENARIO 5: Script Malfunction

### Detection Signs:
- validate-compliance.ps1 crashing
- bulk-update-agents.ps1 failing
- health-check.ps1 giving false results

### Rollback Steps:

```bash
# Revert specific script
git checkout HEAD~1 -- .agent/scripts/validate-compliance.ps1

# Or all scripts
git checkout HEAD~1 -- .agent/scripts/

# Verify
./.agent/scripts/validate-compliance.ps1 --help
```

---

## 📦 FULL SYSTEM ROLLBACK (Nuclear Option)

**⚠️ USE ONLY IF SYSTEM COMPLETELY BROKEN**

### Steps:

```bash
# 1. Backup current state (just in case)
cp -r .agent .agent.backup.$(date +%Y%m%d)

# 2. Revert entire .agent directory to last known good commit
git log --oneline .agent/  # Find last known good commit

# 3. Checkout that commit
git checkout <good-commit-hash> -- .agent/

# 4. Verify system health
./.agent/scripts/health-check.ps1

# 5. Commit full rollback
git commit -m "ROLLBACK: Full .agent system to <commit-hash> due to critical failure"
```

---

## 🔍 VERIFICATION CHECKLIST

After ANY rollback, verify:

- [ ] Health check passes: `./.agent/scripts/health-check.ps1`
- [ ] Compliance validation works: `./.agent/scripts/validate-compliance.ps1`
- [ ] Sample agent responds correctly
- [ ] RBA protocol enforced
- [ ] AOC cycle functional (if not disabled)
- [ ] project.json reflects correct versions

---

## 📝 POST-ROLLBACK DOCUMENTATION

**ALWAYS document rollbacks:**

```markdown
## Rollback Log Entry

**Date:** 2026-01-17 13:15:00
**Scenario:** [Which scenario? 1-5 or custom]
**Severity:** [HIGH/MEDIUM/LOW]
**Root Cause:** [What went wrong?]
**Rollback Action:** [What was reverted?]
**Commit Hash:** [Git commit of rollback]
**Verification:** [How was success verified?]
**Prevention:** [How to avoid in future?]
```

**Save to:** `.agent/docs/rollback-history.md`

---

## 🛡️ PREVENTION STRATEGIES

### Before Making Changes:

1. **Backup First**
   ```bash
   git branch backup-before-change
   ```

2. **Test Incrementally**
   - Update 1-2 agents first, not all 27
   - Test STANDARDS.md changes on small codebase
   - Enable AOC on single feature first

3. **Use Feature Flags**
   ```yaml
   # In configuration
   new_feature_enabled: false  # Test before enabling
   ```

4. **Version Everything**
   - project.json tracks versions
   - Git tags for major changes: `git tag v3.0.0`

---

## 🆘 EMERGENCY CONTACTS

**If rollback fails or unclear:**

2. **Review system documentation:**
   - `.agent/docs/TEAM_WORKFLOW.md` - Complete workflow pipeline
   - `.agent/docs/AGENT-SELECTION.md` - Agent routing guide
   - `.agent/ARCHITECTURE.md` - System architecture

3. **Consult changelogs:**
   - `.agent/CHANGELOG.md` - Version history

---

## 🎯 ROLLBACK SUCCESS CRITERIA

Rollback is successful when:

✅ System health score returns to 92-93/100  
✅ Agents respond correctly to test requests  
✅ Validation scripts pass  
✅ No critical errors in logs  
✅ Can create new code without issues

---

**Created:** 2026-01-17  
**Version:** 1.0  
**Purpose:** Emergency recovery procedures for .agent system

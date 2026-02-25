---
description: Kiểm tra workspace hàng ngày
turbo-all: false
---

# Daily Self-Audit Mode

// turbo-all

**Agent:** `orchestrator`  
**Skills:** `lint-and-validate, testing-patterns, clean-code`

You are operating in **DAILY SELF-AUDIT MODE** as part of an autonomous software-evolution system inside Google Antigravity.

---

## Your Role

A self-auditing, self-correcting engineering system that continuously maintains and improves the workspace without degrading stability.

---

## TRIGGER

Run this audit whenever:
- New files are added
- Existing files are modified
- Agents, skills, workflows, or rules are updated
- A previous auto-evolution cycle has completed

---

## SCOPE

Audit the **ENTIRE current workspace** as-is.
- Do NOT ask for uploads or external inputs.
- Workspace is the single source of truth.

---

## DAILY SELF-AUDIT OBJECTIVES

1. **Detect regressions** introduced by recent changes
2. **Detect drift** between:
   - STANDARDS.md
   - Agent rules
   - Workflow logic
   - Enforcement scripts
3. **Detect duplication**, overlap, or dead logic
4. **Ensure all "config implies enforcement"** rules are satisfied
5. **Ensure observability and rollback** remain intact

---

## MANDATORY CHECKS (LIGHTWEIGHT BUT STRICT)

### A) STRUCTURAL INTEGRITY

- [ ] No broken references
- [ ] No orphaned configs
- [ ] No scripts without ownership
- [ ] No undocumented automation

### B) RULE CONSISTENCY

- [ ] No conflicting agent responsibilities
- [ ] No duplicate skills with overlapping intent
- [ ] Clear priority and escalation rules

### C) SAFETY & REVERSIBILITY

- [ ] All automation has rollback
- [ ] All auto-healing is bounded by confidence thresholds
- [ ] No irreversible behavior introduced silently

### D) QUALITY SIGNALS

- [ ] Enforcement scripts exist for all declared gates
- [ ] Metrics/logs exist or are planned for each autonomous action

---

## AUTO-CORRECTION AUTHORITY

**You are authorized to apply SMALL, SAFE, REVERSIBLE fixes automatically:**

✅ **ALLOWED:**
- Remove or merge duplicate skills
- Fix documentation mismatches
- Add missing comments or annotations
- Align scripts with existing configs
- Add warnings where enforcement is missing (temporary)

❌ **NOT ALLOWED:**
- Introduce new architecture
- Add new agents
- Change execution order of workflows
- Modify core standards

---

## OUTPUT (MANDATORY)

Produce a concise report with these sections:

```markdown
# 🔍 Daily Self-Audit Report

**Date:** [today's date]
**Status:** [PASS / WARN / FAIL]

## 1. Audit Summary
[Brief overview of what was checked]

## 2. Changes Applied Automatically
[List any auto-corrections made, or "None"]

## 3. Issues Detected (No Change Applied)
[Issues found that need human review, or "None"]

## 4. Risk Level
[LOW / MEDIUM / HIGH]

## 5. Recommended Next Action
[What should be done next, or "None required"]
```

---

## FINAL RULE

If no action is needed, explicitly state:

> "Workspace stable. No corrective action required today."

---

## Quick Reference Commands

**Run health check:**
```powershell
.agent/scripts/health-check.ps1
```

**Run compliance validation:**
```powershell
.agent/scripts/validate-compliance.ps1
```

**Check for deprecated skill usage:**
```powershell
Select-String -Path ".agent/agents/*.md" -Pattern "testing-patterns|tdd-workflow|architecture|api-patterns"
```

**View current metrics:**
```powershell
.agent/scripts/dx-analytics.ps1 -Dashboard
```

---

**Created:** 2026-01-20  
**Version:** 1.0  
**Purpose:** Autonomous workspace self-maintenance
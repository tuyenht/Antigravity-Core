---
description: Evolution regression test to verify auto-upgrade changes are safe and improve system quality. Run after major auto-evolution cycles.
turbo-all: false
---

# Evolution Regression Test Mode

You are operating in **EVOLUTION REGRESSION TEST MODE**.

---

## Your Mission

Ensure that recent self-evolution or auto-upgrade changes have **IMPROVED** the system without breaking correctness, safety, or maintainability.

---

## CONTEXT

- The workspace has recently undergone changes due to auto-evolution
- These changes may include new scripts, modified rules, refined workflows, or updated documentation

---

## TESTING PHILOSOPHY

Evolution is allowed **ONLY** if:
- ✅ Quality increases or remains stable
- ✅ Risk does not increase silently
- ✅ System remains explainable and reversible

---

## MANDATORY REGRESSION DIMENSIONS

### 1) FUNCTIONAL REGRESSION
- [ ] All previously declared capabilities still exist
- [ ] No enforcement gate has been silently removed
- [ ] No workflow path is broken

### 2) SAFETY REGRESSION
- [ ] Auto-healing remains bounded
- [ ] No new autonomy without guardrails
- [ ] Rollback paths still valid

### 3) OBSERVABILITY REGRESSION
- [ ] Logs/metrics still exist for all autonomous actions
- [ ] No blind automation introduced

### 4) COMPLEXITY REGRESSION
- [ ] Agent count did not grow unnecessarily
- [ ] Rules did not become more ambiguous
- [ ] Cognitive load did not increase without justification

### 5) STANDARDS COMPLIANCE
- [ ] All changes still conform to STANDARDS.md
- [ ] Versioning, changelog, and documentation updated

---

## PASS / FAIL CRITERIA

### ✅ PASS
- No regression detected
- Net quality improvement OR neutral with justification

### ⚠️ SOFT FAIL
- Minor regressions with clear mitigation
- Evolution acceptable but requires follow-up

### ❌ HARD FAIL
- Safety, rollback, or correctness compromised
- Unbounded autonomy introduced
- Standards violated

---

## AUTHORITY

You may:
- 🚩 **FLAG** and **ROLLBACK** changes conceptually
- ⏪ **RECOMMEND** immediate revert
- 🛑 **BLOCK** further evolution until issues are resolved

---

## OUTPUT FORMAT (MANDATORY)

```markdown
# 🧪 Evolution Regression Test Report

**Date:** [today's date]
**Verdict:** [PASS / SOFT FAIL / HARD FAIL]

## 1. Evolution Change Summary
[List recent changes being tested]

## 2. Regression Analysis

### Functional
[Analysis result]

### Safety
[Analysis result]

### Observability
[Analysis result]

### Complexity
[Analysis result]

### Standards Compliance
[Analysis result]

## 3. Verdict Details

### If PASS:
- Why evolution is accepted
- What capability improved
- What metric or signal supports this

### If FAIL:
- What to revert
- Why
- How to safely proceed next
```

---

## FINAL RULE

If verdict is **HARD FAIL**, explicitly state:

> "Evolution rejected. System must revert or repair before proceeding."

---

## Quick Verification Commands

**Check agent count:**
```powershell
(Get-ChildItem ".agent/agents/*.md").Count
```

**Check for deprecated usage:**
```powershell
Select-String -Path ".agent/agents/*.md" -Pattern "testing-patterns|tdd-workflow"
```

**Run compliance validation:**
```powershell
.agent/scripts/validate-compliance.ps1
```

**View baseline comparison:**
```powershell
Get-Content ".agent/benchmarks/baseline.json"
```

---

**Created:** 2026-01-20  
**Version:** 1.0  
**Purpose:** Validate evolution quality before acceptance

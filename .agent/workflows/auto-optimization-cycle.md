---
description: "Chu trình tối ưu hóa code tự động sau khi hoàn thành tính năng."
trigger: Feature delivery complete
automation: Auto-triggered by manager-agent
---

# Auto-Optimization Cycle (AOC) Workflow

// turbo-all

**Version:** 4.0.0  
**Purpose:** Automated post-feature quality optimization  
**Trigger:** After any agent completes a feature

---

## Trigger Conditions

**Activate AOC when:**
- Agent reports "Feature Complete"
- Agent creates delivery report  
- User confirms feature delivery

**Keywords to detect:**
- "feature complete"
- "delivery report"  
- "task finished"
- "implementation done"

---

## Workflow Steps

### Step 1: Feature Completion Detection

**Agent completes feature:**
```markdown
✅ Feature Complete: User Authentication

Files changed: 8
Tests: ✅ All pass
Linting: ✅ Clean

Deliverables:
- AuthController.php
- LoginRequest.php  
- routes/api.php
- Tests (5 files)

Ready for optimization cycle.
```

**Manager Agent activates automatically**

---

### Step 2: Self-Correction Phase

**Time:** ~30 seconds

**Manager calls:** `debugger`

**Tasks:**
1. Run all validation checks:
   ```bash
   npm run lint        # or pint, ruff
   npx tsc --noEmit    # or phpstan, mypy
   npm test            # or pest, pytest
   npm audit           # or composer audit
   ```

2. Auto-fix common errors (max 3 iterations):
   - Lint errors → Run formatter
   - Type errors → Add annotations
   - Simple test failures → Fix logic

3. Report status:
   - ✅ All fixed (iterations < 3)
   - ⚠️ Some issues remain (escalate)

**Output:**
```json
{
  "status": "success",
  "iterations_used": 2,
  "fixes_applied": [
    "Fixed 5 lint errors via auto-formatter",
    "Added 3 type annotations"
  ],
  "tests": "32/32 passed",
  "security": "0 vulnerabilities"
}
```

---

### Step 3: Documentation Phase

**Time:** ~60 seconds

**Manager calls:** `documentation-agent`

**Tasks:**
1. Scan for documentation updates needed:
   ```bash
   git diff --name-only HEAD~1
   # Focus on: controllers, services, models, config
   ```

2. Update documentation:
   - API docs (OpenAPI/Swagger)
   - Inline comments (PHPDoc/JSDoc)
   - README (if needed)
   - CHANGELOG

3. Validate:
   - All new public methods documented?
   - API specs build successfully?
   - No broken links?

**Output:**
```json
{
  "status": "complete",
  "files_updated": [
    "docs/api.json (3 endpoints)",
    "app/Http/Controllers/AuthController.php (5 methods)",
    "CHANGELOG.md (v1.2.0 entry)"
  ],
  "api_endpoints_documented": 3,
  "methods_commented": 5
}
```

---

### Step 4: Refactor Analysis

**Time:** ~90 seconds

**Manager calls:** `refactor-agent`

**Tasks:**
1. Run code quality analysis:
   ```bash
   npx complexity-report src/     # Complexity
   npx jscpd src/                 # Duplication
   npx ts-prune                   # Unused code
   ```

2. Detect issues:
   - High complexity (> 10)
   - Code duplication (> 5%)
   - Code smells (long methods, god classes)
   - Unused code

3. Generate suggestions (NO automatic refactoring):
   - Extract method recommendations
   - Extract utility class suggestions
   - Complexity reduction strategies

**Output:**
```json
{
  "quality_score": 85,
  "total_issues": 3,
  "suggestions": [
    {
      "priority": "MEDIUM",
      "type": "complexity",
      "file": "UserService.php",
      "method": "createUser()",
      "current_value": 12,
      "suggestion": "Extract method..."
    }
  ]
}
```

---

### Step 5: Consolidate Report

**Manager generates final report:**

```markdown
## 📊 Auto-Optimization Report

**Feature:** User Authentication  
**Date:** 2026-01-17 12:00:00  
**Agent:** backend-specialist  
**Skills:** `performance-profiling, testing-patterns, clean-code`
**Duration:** 3 minutes

---

### ✅ Self-Correction

**Status:** PASS

- **Iterations:** 2/3 used
- **Lint:** ✅ 5 errors fixed automatically
- **Type Check:** ✅ 3 annotations added
- **Tests:** ✅ 32/32 passed (100%)
- **Security:** ✅ 0 vulnerabilities

**Fixes Applied:**
1. Added missing import for UserService
2. Fixed spacing issues via auto-formatter
3. Added return type annotations to 3 methods

---

### ✅ Documentation

**Status:** COMPLETE

- **API Docs:** ✅ Updated (3 endpoints)
- **Comments:** ✅ 5 methods documented
- **README:** ✅ Updated (env vars section)
- **Changelog:** ✅ Added v1.2.0 entry

**Files Updated:**
- `docs/api.json`
- `app/Http/Controllers/AuthController.php`
- `README.md`
- `CHANGELOG.md`

---

### 🔄 Refactor Opportunities

**Quality Score:** 85/100 ✅

**Issues Found:** 3 (0 high, 2 medium, 1 low)

**Suggestions:**
1. **MEDIUM** - UserService::createUser() has complexity 12
   - Suggest: Extract to 3 methods (validateUser, saveUser, notifyUser)
   - Impact: Complexity 12 → 4 per method
   - Effort: 30 minutes

2. **MEDIUM** - 6% code duplication in validation logic
   - Suggest: Extract to ValidationHelper class
   - Impact: Duplication 6% → 0%
   - Effort: 15 minutes

3. **LOW** - 2 unused imports detected
   - Auto-fixed: ✅

---

## 📈 Summary

✅ **Feature delivered successfully**  
✅ **All quality checks passed**  
⚠️ **2 refactor suggestions available** (optional)

**Code Quality:** 85/100 (Good)  
**Test Coverage:** 100%  
**Documentation:** Complete  

**Next Steps:** 
- Feature is production-ready
- Optional: Review refactor suggestions before next feature

**Report saved:** Inline delivery to user

---

*Generated automatically by .agent Auto-Optimization Cycle v4.0*
```

---

## Step 6: Deliver to User

**Decision Logic:**

### ✅ Perfect Delivery (Score ≥ 80 + All checks pass)

```markdown
✅ Feature Complete + Optimized!

**User Authentication** delivered and optimized.

Quality Score: 85/100  
All tests: ✅ PASS  
Documentation: ✅ Complete  

All checks passed - ready for next task.
```

**No user action needed** - proceed to next task

---

### ⚠️ Needs Review (Score < 80 OR self-correction failed)

```markdown
⚠️ Feature delivered but quality issues detected

**User Authentication** works but needs attention:

Issues:
- Quality score: 55/100 (below threshold)
- Self-correction: 1 test still failing after 3 iterations
- Refactor: 5 high-priority suggestions

**Action Required:** Manual review recommended

Details: See consolidated report above
```

**User action needed** - review before proceeding

---

### ❌ Critical Issues (Self-correction completely failed)

```markdown
❌ Feature has critical issues

**User Authentication** delivered but CRITICAL problems:

Errors:
- Tests: 5/32 failed
- Security: 2 vulnerabilities detected
- Lint: 12 errors remain

**Action Required:** IMMEDIATE manual intervention

Details: See consolidated report above
```

**BLOCK next feature** - must fix first

---

## Integration Points

### With .agent/project.json

```json
{
  "optimization": {
    "enabled": true,
    "last_run": "2026-01-17T12:00:00Z",
    "quality_score_trend": [65, 72, 68, 85],
    "avg_duration_seconds": 180
  }
}
```

---

### With Metrics Tracking

Store in `.agent/memory/metrics/aoc-history.json`:

```json
{
  "runs": [
    {
      "timestamp": "2026-01-17T12:00:00Z",
      "feature": "User Authentication",
      "agent": "backend-specialist",
      "duration_seconds": 182,
      "self_correction": {
        "iterations": 2,
        "success": true
      },
      "documentation": {
        "files_updated": 4,
        "success": true
      },
      "refactor": {
        "quality_score": 85,
        "suggestions": 3
      }
    }
  ],
  "statistics": {
    "total_runs": 47,
    "avg_quality_score": 78,
    "avg_duration_seconds": 175,
    "success_rate": 0.89
  }
}
```

---

## Configuration

```yaml
# Conceptual AOC configuration (inline)

auto_optimization_cycle:
  enabled: true
  
  triggers:
    - feature_complete
    - delivery_report
  
  phases:
    self_correction:
      enabled: true
      max_iterations: 3
      timeout_seconds: 30
    
    documentation:
      enabled: true
      timeout_seconds: 60
    
    refactor:
      enabled: true
      timeout_seconds: 90
  
  thresholds:
    quality_score_min: 60  # Warn if below
    quality_score_target: 80
    
  reporting:
    format: inline  # Delivered directly to user
```

---

## Example End-to-End

### Scenario: User adds blog post feature

**1. Feature Development**
```
User: "Add blog post CRUD endpoints"
backend-specialist: [implements feature]
backend-specialist: "✅ Feature Complete"
```

**2. AOC Triggers**
```
manager-agent: [detects "Feature Complete"]
manager-agent: [activates AOC workflow]
```

**3. Self-Correction (30s)**
```
debugger: Run lint → 3 errors
debugger: Auto-fix → 3 errors fixed
debugger: Run tests → All pass
debugger: Status: ✅ SUCCESS (1 iteration)
```

**4. Documentation (60s)**
```
documentation-agent: Scan changes
documentation-agent: Update API docs (4 endpoints)
documentation-agent: Add comments to 8 methods
documentation-agent: Add CHANGELOG entry
documentation-agent: Status: ✅ COMPLETE
```

**5. Refactor (90s)**
```
refactor-agent: Analyze code
refactor-agent: Quality score: 82/100
refactor-agent: 2 medium suggestions
refactor-agent: Status: ✅ GOOD
```

**6. Report Delivery (instant)**
```
manager-agent: Generate consolidated report
manager-agent: Quality score: 82/100 → ✅ PASS
manager-agent: Deliver to user

User sees:
"✅ Feature Complete + Optimized! (82/100)"
```

**Total Time:** ~3 minutes  
**User Action:** None needed

---

## Troubleshooting

### AOC doesn't trigger

**Check:**
- Is `auto_optimization_cycle.enabled: true` in config?
- Did agent properly signal "Feature Complete"?
- Is manager-agent.md present in .agent/agents/?

---

### Self-correction fails repeatedly

**Check:**
- Are validation tools installed? (eslint, phpstan, etc.)
- Max iterations set too low? (increase to 5 for complex projects)
- Tests too fragile? (review test quality)

---

### Quality score always low

**Check:**
- Adjust threshold in config (maybe 80 too high for legacy code)
- Review refactor suggestions - are they valid?
- Track score trend - improving over time?

---

## Metrics Dashboard (Conceptual)

```
┌─────── AOC Performance ───────┐
│                               │
│  Runs Today:        12        │
│  Success Rate:      91.7%     │
│  Avg Duration:      178s      │
│  Avg Quality:       81/100    │
│                               │
│  Quality Trend:     ↑ +5      │
│  Refactor Accept:   67%       │
│                               │
└───────────────────────────────┘
```

---

**Automation Level:** 95%  
**User Intervention:** Only when quality < threshold

---

**Created:** 2026-01-17  
**Version:** 4.0.0  
**Purpose:** Fully automated post-feature optimization


---

##  Auto Optimization Cycle Checklist

- [ ] Prerequisites and environment verified
- [ ] All workflow steps executed sequentially
- [ ] Expected output validated against requirements
- [ ] No unresolved errors or warnings in tests/logs
- [ ] Related documentation updated if impact is systemic




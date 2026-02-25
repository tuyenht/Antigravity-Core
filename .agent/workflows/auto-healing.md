---
description: Tự sửa lỗi lint, type, import
turbo-all: false
---

# Auto-Healing Workflow

// turbo-all

**Agent:** `self-correction-agent`  
**Skills:** `lint-and-validate, clean-code, systematic-debugging`

> Automatically fix common issues before escalating to user

---

## 🎯 Purpose

**Problem:** Developers waste time on trivial fixes:
- `npm run lint` fails → fix → run again → repeat
- Type error → fix import → run again → repeat
- 50% of commits are "fix lint" / "fix types"

**Solution:** Auto-heal before asking user:
```
Agent generates code
    ↓
Linter fails
    ↓
Auto-healing activates (up to 3 attempts)
    ↓
If fixed → Deliver
If not fixed → Escalate to user
```

---

## 📋 Workflow Steps

### Step 1: Detect Issue Type

When error occurs, classify:

| Error Type | Examples | Auto-Healable? |
|------------|----------|----------------|
| **Lint** | Formatting, unused imports | ✅ Yes |
| **Syntax** | Missing semicolon, bracket | ✅ Yes |
| **Import** | Missing import, wrong path | ✅ Yes |
| **Type** | Missing return type (simple) | ✅ Some |
| **Logic** | Business logic error | ❌ No |
| **Security** | Vulnerability | ❌ No |

---

### Step 2: Apply Auto-Fix (If Safe)

**For Lint Errors:**
```bash
# PHP
./vendor/bin/pint

# TypeScript/JavaScript
npm run lint -- --fix
```

**For Import Errors:**
```typescript
// Missing import detected for 'useState'
// Auto-add:
import { useState } from 'react'
```

**For Simple Type Errors:**
```typescript
// Missing return type (deterministic)
// Before:
function add(a: number, b: number) { return a + b }

// After:
function add(a: number, b: number): number { return a + b }
```

---

### Step 3: Verify Fix

```bash
# Run checks again
npm run lint           # Should pass
npm run type-check     # Should pass
npm run test           # Should pass
```

**If all pass:** ✅ Continue with delivery

**If still fails:** Retry (max 3 attempts)

---

### Step 4: Escalate If Needed

**After 3 failed attempts:**

```markdown
⚠️ Auto-Healing Failed

**Issue:** Type error in UserService.ts:45

**Attempted Fixes:**
1. Added import for User type
2. Added return type annotation
3. Added null check

**Still Failing:**
`Type 'User | null' is not assignable to type 'User'`

**Human Action Required:**
This appears to be a logic issue, not a simple fix.
Please review the code and decide how to handle null case.

**Options:**
1. Throw error if null
2. Return default user
3. Make return type optional

[Option 1] [Option 2] [Option 3]
```

---

## ⚡ Quick Reference

### What Gets Auto-Fixed

**✅ Always Auto-Fix:**
- Formatting (indentation, spaces)
- Unused imports
- Missing semicolons
- Import sorting
- Trailing commas

**⚠️ Auto-Fix with Caution:**
- Missing type annotations (if deterministic)
- Optional chaining for null checks
- Import paths after file moves

**❌ Never Auto-Fix:**
- Business logic errors
- Security vulnerabilities
- Breaking API changes
- Database schema changes

---

### Agent Integration

**Add to any agent for auto-healing:**

```yaml
# In agent file
auto_healing:
  enabled: true
  max_attempts: 3
  escalate_on_failure: true
```

**Example Flow:**

```
code-generator-agent generates CRUD
    ↓
Lint check fails (missing semicolon)
    ↓
Auto-heal: Run `npm run lint --fix`
    ↓
Lint passes ✅
    ↓
Type check fails (missing return type)
    ↓
Auto-heal: Add inferred return type
    ↓
Type check passes ✅
    ↓
Deliver to user (no intervention needed!)
```

---

## 📊 Success Metrics

| Metric | Target |
|--------|--------|
| Auto-fix success rate | >80% |
| Escalation rate | <20% |
| Average iterations | <2 |
| Time saved per task | 5-10 min |

---

## 🔧 Commands

**Trigger auto-healing manually:**
```bash
# For PHP/Laravel
./vendor/bin/pint
./vendor/bin/phpstan analyse --fix

# For TypeScript
npm run lint -- --fix
npm run type-check
```

**Check auto-healing config:**
```
.agent/auto-healing.yml
```

---

## 📖 Related

- [auto-healing.yml](file:///.agent/auto-healing.yml) - Full configuration
- [code-generator-agent](file:///.agent/agents/code-generator-agent.md) - Uses auto-healing
- [ai-code-reviewer](file:///.agent/agents/ai-code-reviewer.md) - Triggers before review

---

**Created:** 2026-01-19  
**Industry Standard:** Meta Internal Tools  
**Impact:** 50% fewer trivial fix commits
---

##  Auto-Healing Checklist

- [ ] Lint errors auto-fixed
- [ ] Import errors auto-resolved
- [ ] Type errors auto-fixed (deterministic only)
- [ ] All auto-fixes verified by re-running checks
- [ ] Non-fixable issues escalated to user
- [ ] Max 3 retry attempts respected

---

## Troubleshooting

| V?n d? | Gi?i ph�p |
|---------|-----------|
| Lint fix creates new errors | Run `npm run lint -- --fix` twice, check for circular fixes |
| Type fix changes behavior | Revert and escalate  never auto-fix logic |
| Import not found after fix | Check `tsconfig.json` paths and `baseUrl` |
| Auto-heal loops forever | Kill after 3 attempts, present options to user |

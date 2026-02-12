---
description: Sửa lỗi nhanh, vấn đề đơn giản
---

# /quickfix - Quick Bug Resolution

$ARGUMENTS

---

## Purpose

Fast-track bug resolution workflow for immediate issues. Get from "bug reported" to "bug fixed" in minutes.

---

## When to Use

- Production bug requiring immediate fix
- User-reported issue blocking work
- Quick regression after deployment
- Simple logical error causing visible problems

**Don't use for:**
- Complex architectural issues → Use `/debug` instead
- Feature requests → Use `/create` or `/enhance`
- Performance optimization → Use performance-profiling skill

---

## Process

### Step 1: Bug Description

**You provide (or will be asked):**
- What's broken?
- Where does it happen?
- Expected vs actual behavior
- Error messages (if any)

**Example:**
```
/quickfix User login fails with 500 error after clicking submit button
```

### Step 2: Rapid Analysis

**Antigravity automatically:**
1. Locates the relevant code paths
2. Checks recent changes (if git available)
3. Reviews error logs/console
4. Identifies likely cause

**Time:** 30-60 seconds

### Step 3: Proposed Fix

**Antigravity presents:**
- Root cause explanation
- Proposed fix with code changes
- Side effects / risks (if any)
- Confidence level

**Example output:**
```markdown
## Root Cause
Missing CSRF token in login form POST request

## Fix
Add @csrf directive to login form

## Confidence: HIGH
This is a common Laravel auth issue
```

### Step 4: Apply & Test

**Options:**
1. **Auto-apply** - Antigravity applies fix directly
2. **Review first** - You review changes before applying
3. **Manual** - You apply the fix yourself

**Then:**
- Run relevant tests
- Verify fix works
- Document the fix

---

## Usage Patterns

### Pattern 1: Inline Quick Fix

```
/quickfix Users can't upload images - getting "file too large" error
```

**Antigravity responds with immediate fix proposal**

### Pattern 2: Context-Aware Fix

```
You: The cart total is calculating incorrectly
/quickfix
```

**Antigravity uses conversation context + analyzes cart logic**

### Pattern 3: Error-Driven Fix

```
/quickfix
[Paste error stack trace]
```

**Antigravity traces error to source and proposes fix**

---

## Behind the Scenes

Antigravity leverages multiple agents:

1. **Explorer Agent** - Locates bug in codebase
2. **Debugger** - Analyzes root cause
3. **Appropriate Specialist** - Proposes fix
   - Backend Specialist (API bugs)
   - Frontend Specialist (UI bugs)
   - Database Architect (query bugs)
   - Laravel Specialist (Laravel bugs)
4. **Test Engineer** - Verifies fix

---

## Quick Fix Categories

### Authentication/Authorization
- Login/logout failures
- Permission errors
- Token issues

### Database
- Query errors
- Migration failures
- N+1 query problems

### API
- 404/500 errors
- Validation failures
- CORS issues

### Frontend
- Component not rendering
- State not updating
- Event handler broken

### Configuration
- Environment variables
- Missing dependencies
- Build errors

---

## Quality Guardrails

**Before applying any fix, Antigravity checks:**
- [ ] Fix addresses root cause (not just symptom)
- [ ] No breaking changes introduced
- [ ] Tests still pass
- [ ] Security not compromised
- [ ] Performance not degraded

---

## Output Format

```markdown
## 🐛 Bug Analysis

**Issue:** [Brief description]
**Location:** [File:Line]
**Root Cause:** [Explanation]

---

## 🔧 Proposed Fix

[Code changes in diff format]

**Why this works:** [Brief explanation]
**Confidence:** [HIGH | MEDIUM | LOW]

---

## ✅ Verification

[How to verify the fix worked]
```

---

## Advanced Options

### Fix with Test

```
/quickfix --with-test [bug description]
```

Generates a test case that reproduces the bug, then fixes it.

### Explain Mode

```
/quickfix --explain [bug description]
```

Detailed explanation of bug + fix (educational mode).

### Rollback Plan

```
/quickfix --with-rollback [bug description]
```

Includes rollback instructions in case fix causes issues.

---

## Example Scenarios

### Scenario 1: Laravel 500 Error

**Input:**
```
/quickfix Getting 500 error on POST /api/posts
```

**Output:**
```markdown
## 🐛 Bug Analysis
**Issue:** 500 Internal Server Error on POST /api/posts
**Location:** app/Http/Controllers/PostController.php:42
**Root Cause:** Missing FormRequest validation, attempting to access non-existent property

## 🔧 Proposed Fix
Create StorePostRequest and use it in controller

[Shows diff]

**Why this works:** Validates input before processing, prevents null reference
**Confidence:** HIGH

## ✅ Verification
Test: POST /api/posts with valid data → 201 Created
```

### Scenario 2: React Component Not Updating

**Input:**
```
/quickfix Counter component not updating when button clicked
```

**Output:**
```markdown
## 🐛 Bug Analysis
**Issue:** State mutation instead of immutable update
**Location:** Counter.tsx:15
**Root Cause:** Using push() instead of spreading array

## 🔧 Proposed Fix
Replace: items.push(newItem)
With: setItems([...items, newItem])

**Why this works:** React requires immutable updates to trigger re-render
**Confidence:** HIGH
```

---

## Best Practices

✅ **Do:**
- Provide clear bug description
- Include error messages
- Mention what you've tried
- Specify urgency level

❌ **Don't:**
- Use for large refactoring
- Skip testing the fix
- Apply fixes blindly
- Ignore confidence level

---

## Integration with Other Workflows

**Chain with other workflows:**
```
/quickfix [fix the bug]
↓
/test [verify no regressions]
↓
/deploy [deploy the fix]
```

---

**Remember:** /quickfix is for QUICK fixes. For complex issues requiring deeper analysis, use `/debug` or `/plan`.

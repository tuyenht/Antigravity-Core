---
description: Tìm và sửa lỗi có hệ thống
---

# /debug - Systematic Problem Investigation

// turbo-all

**Agent:** `debugger`  
**Skills:** `systematic-debugging, testing-patterns`

$ARGUMENTS

---

## Purpose

This command activates DEBUG mode for systematic investigation of issues, errors, or unexpected behavior.

---

## Behavior

When `/debug` is triggered:

1. **Gather information**
   - Error message
   - Reproduction steps
   - Expected vs actual behavior
   - Recent changes

2. **Form hypotheses**
   - List possible causes
   - Order by likelihood

3. **Investigate systematically**
   - Test each hypothesis
   - Check logs, data flow
   - Use elimination method

4. **Fix and prevent**
   - Apply fix
   - Explain root cause
   - Add prevention measures

---

## Output Format

```markdown
## 🔍 Debug: [Issue]

### 1. Symptom
[What's happening]

### 2. Information Gathered
- Error: `[error message]`
- File: `[filepath]`
- Line: [line number]

### 3. Hypotheses
1. ❓ [Most likely cause]
2. ❓ [Second possibility]
3. ❓ [Less likely cause]

### 4. Investigation

**Testing hypothesis 1:**
[What I checked] → [Result]

**Testing hypothesis 2:**
[What I checked] → [Result]

### 5. Root Cause
🎯 **[Explanation of why this happened]**

### 6. Fix
```[language]
// Before
[broken code]

// After
[fixed code]
```

### 7. Prevention
🛡️ [How to prevent this in the future]
```

---

## Examples

```
/debug login not working
/debug API returns 500
/debug form doesn't submit
/debug data not saving
```

---

## Key Principles

- **Ask before assuming** - get full error context
- **Test hypotheses** - don't guess randomly
- **Explain why** - not just what to fix
- **Prevent recurrence** - add tests, validation

---

##  Debug Checklist

- [ ] Error message captured
- [ ] Reproduction steps confirmed
- [ ] At least 2 hypotheses formed
- [ ] Each hypothesis tested with evidence
- [ ] Root cause identified
- [ ] Fix applied and verified
- [ ] Regression test added
- [ ] Prevention measure documented

---

## Troubleshooting

| V?n d? | Gi?i ph�p |
|---------|-----------|
| Can't reproduce error | Ask for exact steps, browser/OS, check logs |
| Error only in production | Check env vars, DB state, network conditions |
| Multiple possible causes | Binary search: disable half the code, narrow down |
| Fix breaks something else | Revert, write test for both cases first |

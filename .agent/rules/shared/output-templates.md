# Output Templates Reference

**Purpose:** Consolidated output format templates to reduce redundancy across mode files.

**Usage:** Mode files (03-06) reference these templates instead of duplicating them.

---

## CONSULT Mode Template

```markdown
## 🔍 CONSULTING

**Understanding:** [Brief summary of user's question/situation]

**Constraints:** [Tech stack, timeline, resources, business requirements]

---

### Option A: [Name]

| Pros | Cons |
|------|------|
| ✅ [Advantage 1] | ⚠️ [Limitation 1] |
| ✅ [Advantage 2] | ⚠️ [Limitation 2] |
| ✅ [Advantage 3] | ⚠️ [Limitation 3] |

**Best when:** [Specific conditions or scenarios]

**Example:** [Brief example or use case]

---

### Option B: [Name]

| Pros | Cons |
|------|------|
| ✅ [Advantage 1] | ⚠️ [Limitation 1] |
| ✅ [Advantage 2] | ⚠️ [Limitation 2] |

**Best when:** [Specific conditions or scenarios]

---

### Option C: [Name] (Optional)

| Pros | Cons |
|------|------|
| ✅ [Advantage 1] | ⚠️ [Limitation 1] |
| ✅ [Advantage 2] | ⚠️ [Limitation 2] |

**Best when:** [Specific conditions or scenarios]

---

## ✅ Recommendation: Option [X]

**Reason:** [Clear explanation of why this is the best choice for their situation]

**Trade-offs accepted:** [What you're giving up by choosing this]

**Next steps:**
1. [Step 1]
2. [Step 2]

⏭️ **Confirm to proceed with implementation?**
```

---

## BUILD Mode Template

```markdown
## 🏗️ BUILD: [Feature Name]

**Scope:** [Clear description of what will be built]

**Acceptance Criteria:**
- [ ] AC1: [Criterion 1]
- [ ] AC2: [Criterion 2]
- [ ] AC3: [Criterion 3]

---

### Implementation

**File: `[path/to/file]`**

```[language]
[Code implementation]
```

**File: `[path/to/another/file]`** (if multiple files)

```[language]
[Code implementation]
```

---

### 🧪 How to Test

```bash
[Commands to test the implementation]
```

**Expected Output:**
```
[What success looks like]
```

---

### ✅ Pre-Delivery Checklist

**Checklist Intensity:** [QUICK | STANDARD | COMPREHENSIVE]

- [x] Type-safe (no `any`)
- [x] Error handling complete
- [x] No hardcoded values
- [x] Comments on complex logic
- [x] Tests passing
- [x] [Additional items based on intensity]

---

### 📝 Notes

[Any additional context, caveats, or next steps]
```

---

## DEBUG Mode Template

```markdown
## 🔧 DEBUG

**Symptom:** [User's description of the error/issue]

**Reproduction:**
1. [Step 1 to reproduce]
2. [Step 2 to reproduce]
3. [Error appears]

---

### Analysis

**Root Cause:** [Clear explanation of what's causing the issue]

**Location:** `[file:line]` or `[component/module]`

**Why it happens:** [Technical explanation]

---

### Fix

**File: `[path/to/file]`**

```diff
- [Old code - what's wrong]
+ [New code - the fix]
```

**Explanation:** [Why this fix solves the problem]

---

### Validation

```bash
# Test that the fix works
[Commands to verify fix]
```

**Expected:** [What should happen after fix]

---

### Prevention

To prevent this issue in the future:

| Suggestion | Priority | Effort |
|------------|----------|--------|
| [Prevention measure 1] | 🔴 High | Low |
| [Prevention measure 2] | 🟡 Medium | Medium |
| [Prevention measure 3] | 🟢 Low | Low |

**Recommended:**
- [Most important prevention step]
- [Second priority prevention step]
```

---

## OPTIMIZE Mode Template

```markdown
## ⚡ OPTIMIZE

**Issue:** [Description of performance problem or code quality issue]

**Current State (Baseline):**
- Metric 1: [Current value]
- Metric 2: [Current value]
- Metric 3: [Current value]

---

### Bottleneck Analysis

| Issue | Location | Severity | Impact |
|-------|----------|----------|--------|
| [Bottleneck 1] | `[file:line]` | 🔴 High | [Description] |
| [Bottleneck 2] | `[file:line]` | 🟡 Medium | [Description] |
| [Bottleneck 3] | `[file:line]` | 🟢 Low | [Description] |

**Primary Bottleneck:** [The main issue to fix first]

---

### Optimization Proposal

**Approach:** [High-level strategy]

**Changes:**

**File: `[path/to/file]`**

```diff
- [Old inefficient code]
+ [Optimized code]
```

**What improved:** [Explanation of the optimization]

---

### Expected Results

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| [Metric 1] | [Value] | [Value] | [% or absolute] |
| [Metric 2] | [Value] | [Value] | [% or absolute] |
| [Metric 3] | [Value] | [Value] | [% or absolute] |

---

### Regression Check

- [ ] Tests still pass
- [ ] Behavior unchanged (functionally)
- [ ] No new bugs introduced
- [ ] Performance measured and improved

**Verification:**
```bash
[Commands to verify optimization didn't break anything]
```

---

### Trade-offs

**What we gained:** [Benefits]

**What we traded:** [Any downsides, if applicable]

**Worth it?** [Yes/No + brief reasoning]
```

---

## Error/Warning Template

```markdown
⚠️ **[WARNING | ERROR | CRITICAL]**: [Title]

**Issue:** [Description of the problem]

**Location:** [Where this was detected]

**Severity:** [Critical | High | Medium | Low]

**Impact:** [What happens if not addressed]

---

### Recommended Action

**Immediate:**
- [Action 1]
- [Action 2]

**Follow-up:**
- [Action 3]

---

**Handle this issue first or continue with the original request?**
```

---

## Quick Summary Template

**For simple/quick tasks, use condensed format:**

```markdown
## [Task Type Icon + Title]

[Brief description]

**Code:**
```[language]
[Implementation]
```

**Usage:**
```bash
[How to use/test]
```

✅ Done. [One-line summary of what was accomplished]
```

---

**Usage Guide:**

**Rule 03 (CONSULT):** Reference "CONSULT Mode Template"
**Rule 04 (BUILD):** Reference "BUILD Mode Template"  
**Rule 05 (DEBUG):** Reference "DEBUG Mode Template"  
**Rule 06 (OPTIMIZE):** Reference "OPTIMIZE Mode Template"

**Benefits:**
- ✅ Single source of truth for formats
- ✅ Easy to update all modes at once
- ✅ Reduced token usage (~800 tokens saved)
- ✅ Consistent output across all modes

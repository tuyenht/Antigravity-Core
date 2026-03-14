# RBA Validator

**Purpose:** Validate that agents follow Reasoning-Before-Action protocol

**Version:** 5.0.1  
**Location:** `.agent/systems/rba-validator.md`  
**Updated:** 2026-02-27

---

## Validation Rules

### 1. REASONING BLOCK Must Be Present

**Check:** Before ANY code action (create/edit/delete file), agent MUST output RBA block

**Auto-fail if:**
- No REASONING BLOCK found
- REASONING BLOCK after code action (too late!)
- REASONING BLOCK incomplete

---

### 2. Required Fields

**All fields must be filled:**

| Field | Validation | Example |
|-------|------------|---------|
| `objective` | Not empty, clear statement | ✅ "Create /api/users endpoint" |
| `scope` | Specific file paths | ✅ "routes/api.php, UserController.php" |
| `dependencies` | Explicit list | ✅ "User model, auth middleware" |
| `affected_modules` | At least 1 module | ✅ "API routes: +1 endpoint" |
| `breaking_changes` | Yes/No + reason | ✅ "No - backward compatible" |
| `rollback_plan` | Clear steps | ✅ "Delete route, remove controller" |
| `edge_cases` | Minimum 3 cases | ✅ case_1, case_2, case_3 |
| `validation_criteria` | Minimum 3 criteria | ✅ "Route exists, returns JSON, auth works" |
| `decision` | PROCEED/ESCALATE/ALTERNATIVE | ✅ "PROCEED" |
| `reason` | Explains decision | ✅ "All deps met, no breaking changes" |

---

### 3. Edge Cases Quality Check

**Minimum:** 3 edge cases REQUIRED

**Each edge case must have:**
- `scenario`: Specific situation
- `handling`: How to handle it

**Auto-fail if:**
```yaml
# ❌ Too generic
edge_cases:
  case_1:
    scenario: "Error might occur"
    handling: "Handle it properly"

# ✅ Specific
edge_cases:
  case_1:
    scenario: "User provides invalid email format"
    handling: "Return 422 with validation error JSON"
```

**Quality criteria:**
- ✓ Specific, not generic
- ✓ Realistic (actually can happen)
- ✓ Handling actionable (not "we'll see")

---

### 4. Decision Validation

**Rules:**
1. Must be exactly one of: `PROCEED`, `ESCALATE`, `ALTERNATIVE`
2. Must have `reason` explaining why
3. Reason must reference analysis (not generic)

**Examples:**

```yaml
# ❌ Invalid
decision: "maybe"
reason: "should work"

# ❌ Invalid (no reason)
decision: "PROCEED"
reason: ""

# ✅ Valid
decision: "PROCEED"
reason: "All dependencies confirmed, edge cases handled, no breaking changes"

# ✅ Valid
decision: "ESCALATE"
reason: "Breaking change unavoidable - need user approval to modify User schema"

# ✅ Valid
decision: "ALTERNATIVE"
reason: "Current approach too complex - using built-in Eloquent observer instead"
```

---

### 5. Rollback Plan Check

**Must be specific and actionable:**

```yaml
# ❌ Too vague
rollback_plan: "Undo changes"

# ❌ No plan
rollback_plan: "N/A"

# ✅ Specific
rollback_plan: "1. Delete AuthController.php, 2. Remove routes from api.php, 3. Revert User model hash method"
```

---

## Validation Workflow

### Step 1: Detect Code Action Intent

Monitor for:
- "I will create..."
- "Let me edit..."
- "Deleting file..."
- "Running migration..."

### Step 2: Look for REASONING BLOCK

**Before code action:**
- Search for "# REASONING BLOCK" or "analysis:" YAML
- Check if it appears BEFORE actual code

### Step 3: Validate Structure

Check all required fields exist:
```yaml
analysis:
  objective: ✓
  scope: ✓
  dependencies: ✓

potential_impact:
  affected_modules: ✓
  breaking_changes: ✓
  rollback_plan: ✓

edge_cases:
  case_1: ✓
  case_2: ✓
  case_3: ✓

validation_criteria: ✓  # Array of 3+

decision: ✓
reason: ✓
```

### Step 4: Validate Content Quality

- Edge cases specific? (not "something bad")
- Scope has file paths? (not "some files")
- Rollback actionable? (not "undo")
- Reason explains decision? (not "because")

### Step 5: Decision Alignment

Check if decision matches analysis:

```yaml
# ❌ Misaligned
breaking_changes: "Yes - changes User table structure"
decision: "PROCEED"

# ✅ Aligned
breaking_changes: "Yes - changes User table structure"
decision: "ESCALATE"
reason: "Breaking change requires user approval"
```

---

## Auto-Fail Conditions

**IMMEDIATE REJECTION if:**

1. ❌ No REASONING BLOCK before code execution
2. ❌ Less than 3 edge cases
3. ❌ Decision without reason
4. ❌ Generic placeholders ("TODO", "TBD", "...")
5. ❌ Rollback plan = "N/A" or empty
6. ❌ Breaking change = Yes + decision = PROCEED (without user approval)
7. ❌ Dependencies listed but not verified

---

## Validation Report Format

```markdown
## RBA Validation Report

**Agent:** backend-specialist
**Action:** Create AuthController.php
**Timestamp:** 2026-01-17 11:40:00

### ✅ PASS

- [✅] REASONING BLOCK present before action
- [✅] All required fields filled
- [✅] 3+ edge cases (found 3)
- [✅] Decision justified
- [✅] Rollback plan actionable

**Decision:** PROCEED
**Reason:** Valid - all criteria met

---

### ❌ FAIL

- [✅] REASONING BLOCK present
- [❌] Missing field: rollback_plan
- [❌] Only 2 edge cases (minimum 3)
- [✅] Decision justified

**Violation:** Insufficient edge cases, missing rollback plan
**Action:** Block execution, request agent to fix RBA
```

---

## Integration with Agents

### In Agent Workflow

```markdown
## Phase X: Before Code Action

1. ✅ Generate REASONING BLOCK
2. ✅ Run RBA Validator
3. ❓ Validation passes?
   - YES → Proceed to code
   - NO → Fix RBA, retry (max 2 attempts)
4. ❓ 2 attempts failed?
   - YES → ESCALATE to user
   - NO → Execute code
```

---

## Examples of Good vs Bad RBA

### ❌ Bad Example (Will Fail)

```yaml
analysis:
  objective: "Add authentication"
  scope: "Some files"
  dependencies: "User stuff"

edge_cases:
  case_1:
    scenario: "Error"
    handling: "Fix it"

decision: "PROCEED"
reason: "Looks good"
```

**Failures:**
- Objective too vague
- Scope not specific (no file names)
- Only 1 edge case (need 3)
- Edge case generic
- Reason not explanatory

---

### ✅ Good Example (Will Pass)

```yaml
analysis:
  objective: "Implement JWT-based API authentication with login/logout endpoints"
  scope: "app/Http/Controllers/AuthController.php, routes/api.php, app/Http/Requests/LoginRequest.php"
  dependencies: "User model exists with email+password, sanctum package installed, database migrated"

potential_impact:
  affected_modules:
    - "API routes: +2 endpoints (POST /login, POST /logout)"
    - "User model: +method to generate JWT token"
  
  breaking_changes: "No - new endpoints, no existing functionality modified"
  
  rollback_plan: "1. Remove routes from api.php, 2. Delete AuthController.php, 3. Delete LoginRequest.php, 4. Drop sanctum tokens table"

edge_cases:
  case_1:
    scenario: "User provides invalid email format"
    handling: "LoginRequest validates email format, returns 422 with validation errors"
  
  case_2:
    scenario: "User provides correct email but wrong password"
    handling: "Auth::attempt() fails, return 401 Unauthorized"
  
  case_3:
    scenario: "User tries to logout without being logged in"
    handling: "Sanctum middleware rejects request, return 401"

validation_criteria:
  - "POST /login returns JWT token with valid credentials"
  - "POST /login returns 422 with invalid email"
  - "POST /login returns 401 with wrong password"
  - "POST /logout invalidates token"
  - "Protected routes reject requests without valid token"

decision: "PROCEED"
reason: "All dependencies confirmed (User model, sanctum), edge cases covered with specific handling, no breaking changes, clear rollback plan available"
```

**Why it passes:**
- ✅ Objective specific and clear
- ✅ Scope lists exact files
- ✅ Dependencies explicit
- ✅ 3 realistic edge cases
- ✅ Each edge case has specific handling
- ✅ 5 validation criteria
- ✅ Decision aligned with analysis
- ✅ Reason references specific findings

---

## Error Messages

**When validation fails:**

```
🚫 RBA VALIDATION FAILED

Agent: backend-specialist
Violations:
  1. Missing field: rollback_plan
  2. Only 2 edge cases (minimum 3 required)
  3. Edge case #1 too generic ("Error occurs")

ACTION REQUIRED:
- Add rollback_plan with specific steps
- Add 1 more edge case
- Make edge cases specific (what error? how to handle?)

Retry with complete REASONING BLOCK.
```

---

**Created:** 2026-01-17  
**Updated:** 2026-02-27  
**Version:** 5.0.1  
**System:** Antigravity-Core v5.0.1  
**Purpose:** Enforce RBA protocol compliance across all agents

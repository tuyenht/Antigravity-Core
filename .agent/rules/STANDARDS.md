# .agent GOLDEN RULE - Technical Constitution

**Version:** 3.0.0  
**Status:** MANDATORY - NO EXCEPTIONS  
**Scope:** All agents, all projects, all tech stacks

**Violation Penalty:** Code REJECTED, agent OUTPUT INVALID

---

## 1. CODING STYLE (Universal Principles)

### 1.1 Architecture Principles

**SOLID Principles (NON-NEGOTIABLE):**
- **S**: Single Responsibility - One class, one job
- **O**: Open/Closed - Open for extension, closed for modification
- **L**: Liskov Substitution - Subtypes must be substitutable
- **I**: Interface Segregation - Many specific interfaces > one general
- **D**: Dependency Inversion - Depend on abstractions, not concretions

**DRY (Don't Repeat Yourself):**
- ❌ Code duplication > 5% → REJECTED
- ✅ Extract to function/class if used 2+ times

**KISS (Keep It Simple, Stupid):**
- ❌ Cyclomatic complexity > 10 → REJECTED
- ✅ Prefer simple solution over clever one

### 1.2 Code Organization

**Layered Architecture (MANDATORY):**
```
Presentation Layer (UI/Controllers)
    ↓
Business Logic Layer (Services)
    ↓
Data Access Layer (Repositories/ORM)
    ↓
Database/External Services
```

**Rules:**
- ❌ NO business logic in controllers/views
- ❌ NO database queries in controllers
- ✅ Controllers max 10 lines per method
- ✅ Services handle ALL business logic

### 1.3 Naming Conventions

**Universal Rules:**
- Classes: `PascalCase` (UserService, BlogPost)
- Functions/Methods: `camelCase` (getUserPosts, calculateTotal)
- Constants: `SCREAMING_SNAKE_CASE` (MAX_RETRY, API_URL)
- Private members: `_prefixed` (_internalState, _calculateScore)

**Booleans:**
- Prefix with `is`, `has`, `can`, `should`
- Examples: `isValid`, `hasPermission`, `canEdit`

**Functions:**
- Verbs for actions: `createUser`, `fetchData`, `deletePost`
- Getters: `getUserName()` NOT `getName()`

---

## 2. SECURITY BASELINE (Zero-Compromise)

### 2.1 Input Validation (100% Coverage)

**EVERY user input MUST be validated:**

**TypeScript Example:**
```typescript
// ❌ WRONG (trusts input)
function createUser(email: string) {
  db.insert({ email });
}

// ✅ CORRECT (validates first)
function createUser(email: string) {
  if (!isValidEmail(email)) {
    throw new ValidationError("Invalid email");
  }
  const sanitized = sanitizeEmail(email);
  db.insert({ email: sanitized });
}
```

**Validation Rules:**
- ✅ Type check (string, number, boolean)
- ✅ Format check (email, URL, phone)
- ✅ Range check (min/max length, value)
- ✅ Whitelist (allowed values only)

### 2.2 SQL Injection Prevention

**NEVER use string concatenation for SQL:**

**PHP Example:**
```php
// ❌ VULNERABLE
$sql = "SELECT * FROM users WHERE email = '" . $email . "'";

// ✅ SAFE (parameterized)
$sql = "SELECT * FROM users WHERE email = ?";
$stmt = $db->prepare($sql);
$stmt->execute([$email]);
```

**Or use ORM:**
```php
// ✅ SAFE (Eloquent)
User::where('email', $email)->first();
```

### 2.3 XSS Prevention

**ALWAYS escape output:**

**React Example:**
```jsx
// ❌ DANGEROUS (raw HTML)
<div dangerouslySetInnerHTML={{ __html: userInput }} />

// ✅ SAFE (escaped by default)
<div>{userInput}</div>
```

### 2.4 Authentication & Authorization

**EVERY protected route MUST:**
1. Verify authentication (user logged in?)
2. Verify authorization (user allowed?)

**TypeScript Example:**
```typescript
// ❌ WRONG (no auth check)
router.delete('/posts/:id', deletePost);

// ✅ CORRECT (auth + authz)
router.delete('/posts/:id', 
  authenticate,           // Check logged in
  authorize('delete:post'), // Check permission
  deletePost
);
```

### 2.5 Secrets Management

**NEVER hardcode secrets:**

**TypeScript Example:**
```typescript
// ❌ FORBIDDEN
const API_KEY = "sk_live_123abc";

// ✅ REQUIRED
const API_KEY = process.env.API_KEY;
if (!API_KEY) throw new Error("API_KEY not configured");
```

**Mandatory checks:**
- ✅ All secrets in `.env` file
- ✅ `.env` in `.gitignore`
- ✅ `.env.example` with dummy values
- ✅ Validation at startup (secrets exist?)

---

## 3. ERROR HANDLING (Comprehensive)

### 3.1 Exception Handling

**EVERY risky operation MUST have try/catch:**

**TypeScript Example:**
```typescript
// ❌ WRONG (no error handling)
async function fetchUser(id: string) {
  const user = await db.query(`SELECT * FROM users WHERE id = ${id}`);
  return user;
}

// ✅ CORRECT (comprehensive)
async function fetchUser(id: string): Promise<User> {
  try {
    // Validate input
    if (!id) throw new ValidationError("User ID required");
    
    // Attempt operation
    const user = await db.query("SELECT * FROM users WHERE id = ?", [id]);
    
    // Verify result
    if (!user) throw new NotFoundError(`User ${id} not found`);
    
    return user;
  } catch (error) {
    // Log error (with context)
    logger.error("fetchUser failed", { id, error });
    
    // Re-throw appropriate error
    if (error instanceof ValidationError) throw error;
    if (error instanceof NotFoundError) throw error;
    
    // Unexpected error
    throw new DatabaseError("Failed to fetch user", { cause: error });
  }
}
```

### 3.2 Logging Standards

**Format:**
```
[TIMESTAMP] [LEVEL] [COMPONENT] Message {context}

Examples:
[2026-01-17 11:00:00] ERROR [UserService] Failed to create user {"email":"test@example.com","error":"Duplicate email"}
[2026-01-17 11:00:01] INFO [AuthController] User logged in {"userId":123}
```

**Levels:**
- `ERROR`: Failures requiring attention
- `WARN`: Potential issues
- `INFO`: Important events
- `DEBUG`: Detailed diagnostic (dev only)

**Rules:**
- ❌ NO sensitive data in logs (passwords, tokens)
- ❌ NO PII without consent (emails, names)
- ✅ Include context (user ID, action, parameters)

### 3.3 Error Responses (APIs)

**Consistent format:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is required",
    "details": {
      "field": "email",
      "rule": "required"
    }
  }
}
```

**HTTP Status Codes:**
- `200`: Success
- `400`: Bad Request (validation error)
- `401`: Unauthorized (not logged in)
- `403`: Forbidden (no permission)
- `404`: Not Found
- `422`: Unprocessable Entity (semantic error)
- `500`: Internal Server Error

---

## 4. QUALITY GATE (Definition of Done)

**Code is NOT complete until ALL conditions met:**

### 4.1 Testing Requirements

**Minimum Coverage: 80%**

```bash
# Check coverage
npm run test:coverage
# Must show: Coverage ≥ 80%
```

**Required Tests:**
1. **Unit Tests**: All business logic functions
2. **Integration Tests**: API endpoints
3. **Edge Case Tests**: Error scenarios

**TypeScript Example:**
```typescript
describe('UserService', () => {
  // Unit test
  test('createUser validates email', () => {
    expect(() => createUser({ email: 'invalid' }))
      .toThrow(ValidationError);
  });
  
  // Edge case
  test('createUser handles duplicate email', async () => {
    await createUser({ email: 'test@example.com' });
    await expect(createUser({ email: 'test@example.com' }))
      .rejects.toThrow('Email already exists');
  });
});
```

### 4.2 Linting Requirements

**Zero warnings allowed:**

```bash
# Run linter
npm run lint
# Must show: ✓ No lint errors
```

**Tools by stack:**
- JavaScript/TypeScript: `ESLint + Prettier`
- PHP: `Laravel Pint / PHP_CodeSniffer`
- Python: `Ruff / Black`
- Go: `golint / gofmt`

### 4.3 Static Analysis

**Zero type errors:**

```bash
# TypeScript
npx tsc --noEmit
# Must show: Found 0 errors

# PHP
./vendor/bin/phpstan analyse
# Must show: [OK] No errors

# Python
mypy src/
# Must show: Success: no issues found
```

### 4.4 Security Scan

**Zero vulnerabilities:**

```bash
# Dependency scan
npm audit
# Must show: found 0 vulnerabilities

# Code scan (optional but recommended)
npm run security-scan
```

### 4.5 Performance Check

**Benchmarks:**
- API response time: < 200ms (p95)
- Database queries: No N+1
- Bundle size: < 200KB (gzipped, frontend)
- Lighthouse score: ≥ 90 (web)

### 4.6 Documentation

**Required docs:**
1. **API Docs**: OpenAPI/Swagger for all endpoints
2. **Code Comments**: PHPDoc/JSDoc for public methods
3. **README**: How to run, test, deploy

**PHP Example:**
```php
/**
 * Create a new user account
 *
 * @param array{email: string, password: string} $data User data
 * @return User Created user instance
 * @throws ValidationException If email invalid
 * @throws DuplicateException If email exists
 */
public function createUser(array $data): User
{
  // ...
}
```

---

## 5. ENFORCEMENT

### 5.1 Pre-Commit Checks

**Automated gates (Git hooks):**
1. ✅ Linter passes
2. ✅ Type check passes
3. ✅ Tests pass
4. ✅ No console.log/dd()/var_dump()

**If ANY fails → Commit BLOCKED**

### 5.2 CI/CD Pipeline

**All checks re-run on push:**
```yaml
# .github/workflows/quality.yml
jobs:
  quality-gate:
    steps:
      - Lint
      - Type Check
      - Unit Tests (coverage ≥ 80%)
      - Security Scan
      - Build (must succeed)
```

**If ANY fails → PR BLOCKED**

### 5.3 Agent Compliance

**Agents MUST:**
1. Follow ALL standards above
2. Run quality checks before delivery
3. Report compliance in delivery

**Format:**
```markdown
## Quality Report

✅ Linting: PASS
✅ Type Check: PASS
✅ Tests: PASS (Coverage: 92%)
✅ Security: PASS (0 vulnerabilities)
✅ Performance: PASS (All benchmarks met)

Code is ready for review.
```

---

## 6. EXCEPTIONS

**When can you violate standards?**

**Answer: NEVER without approval.**

**Exception Request Process:**
1. Document WHY standard cannot be met
2. Propose alternative approach
3. Get explicit user approval
4. Document exception in code

**TypeScript Example:**
```typescript
// EXCEPTION: Using 'any' type due to third-party lib
// Approved by: USER on 2026-01-17
// Reason: External API lacks TypeScript definitions
// Alternative: Created wrapper with strict types
const externalData: any = await thirdPartyLib.fetch();
```

---

## 7. TECH STACK SPECIFIC ADDITIONS

### 7.1 Laravel/PHP

**Additional Requirements:**
- Use Form Requests for ALL validation
- Use API Resources for ALL responses
- Use Jobs for async operations
- Max 10 lines per controller method
- Eloquent ORM only (no raw SQL)

### 7.2 React/Next.js

**Additional Requirements:**
- TypeScript REQUIRED (no plain JS)
- Tailwind CSS for styling
- Zod for validation schemas
- React Query for data fetching
- Components max 200 lines

### 7.3 Node.js APIs

**Additional Requirements:**
- Express/Fastify/Hono (no plain http)
- Input validation middleware
- Helmet for security headers
- Rate limiting enabled
- Request logging (morgan/pino)

---

## 8. AGENT SELF-CHECK PROTOCOL

Before delivering ANY code, agent MUST:

**Phase 1: Validation**
```bash
# 1. Run linter
npm run lint          # TypeScript/JavaScript
./vendor/bin/pint     # PHP
ruff check .          # Python

# 2. Run type checker
npx tsc --noEmit      # TypeScript
./vendor/bin/phpstan  # PHP
mypy src/             # Python

# 3. Run tests
npm test              # JavaScript/TypeScript
php artisan test      # Laravel
pytest                # Python
```

**Phase 2: Verification**
- [ ] All tests pass?
- [ ] Coverage ≥ 80%?
- [ ] Zero lint errors?
- [ ] Zero type errors?
- [ ] No debug code (console.log, dd, etc.)?

**Phase 3: Report**
Generate Quality Report (see section 5.3)

**If ANY check fails:**
1. Auto-fix if possible (run formatter)
2. Report to user
3. Ask: "Should I fix these X issues?"
4. Wait for approval
5. Re-run checks after fix

---

**END OF STANDARDS.MD**

**This is the LAW. All agents MUST comply. NO EXCEPTIONS.**

---

**Created:** 2026-01-17  
**Last Updated:** 2026-01-17  
**Version:** 3.0.0  
**Effective:** IMMEDIATELY

**Violation Reporting:**
- Agents violating standards → Output INVALID
- User can override with explicit approval
- Document ALL exceptions

**Questions?**
- See `.agent/docs/INTEGRATION-GUIDE.md`
- See agent-specific documentation
- Ask user for clarification

# 🎯 Universal Code Standards Checklist

**Purpose:** Quick reference for writing code that passes automated reviews  
**For:** All developers on all projects  
**Updated:** 2026-01-17

---

## ✅ BEFORE YOU CODE

### Project Setup
- [ ] `.agent` folder initialized in project root
- [ ] Tech stack detected and appropriate standards loaded
- [ ] Pre-commit hooks installed (`npm run prepare` or equivalent)
- [ ] IDE configured with linter/formatter

### Environment
- [ ] `.env.example` exists with all required vars (NO secrets)
- [ ] `.gitignore` covers sensitive files
- [ ] README.md has setup instructions

---

## ✅ WHILE YOU CODE

### Type Safety (TypeScript/Typed Languages)
- [ ] Zero `any` types (use proper types or `unknown`)
- [ ] All functions have return type annotations
- [ ] Strict mode enabled in config
- [ ] No type assertion abuse (`as`)

### Security
- [ ] NO hardcoded secrets (use environment variables)
- [ ] Input validation on all user data
- [ ] SQL queries parameterized (NO string concatenation)
- [ ] Output encoding to prevent XSS
- [ ] Authentication/authorization on protected routes

### Performance
- [ ] No N+1 queries (use eager loading/joins)
- [ ] Large datasets paginated
- [ ] Images/assets optimized
- [ ] Lazy loading where appropriate
- [ ] Caching for expensive operations

### Code Quality
- [ ] Functions < 50 lines
- [ ] Cyclomatic complexity < 10
- [ ] Descriptive variable/function names
- [ ] No magic numbers (use constants)
- [ ] Single Responsibility Principle
- [ ] DRY - Don't Repeat Yourself

### Testing
- [ ] Unit tests for business logic
- [ ] Integration tests for APIs
- [ ] Edge cases covered
- [ ] Tests are deterministic (no random/flaky tests)
- [ ] Coverage > 80% for critical code

### Documentation
- [ ] Complex logic has WHY comments (not WHAT)
- [ ] Public APIs documented
- [ ] README updated if needed
- [ ] No commented-out code

---

## ✅ BEFORE YOU COMMIT

### Run Local Checks
```bash
# TypeScript/JavaScript
npm run typecheck
npm run lint -- --fix
npm run test

# PHP/Laravel
./vendor/bin/pint
./vendor/bin/phpstan analyse
php artisan test

# Python
mypy .
black .
pytest

# Go
go fmt ./...
go vet ./...
go test ./...
```

### Manual Quick Check
- [ ] Code compiles/builds without errors
- [ ] Tests pass locally
- [ ] No console.log/dd/print statements (use proper logging)
- [ ] Imports organized
- [ ] No unused variables/imports

---

## ✅ BEFORE YOU DEPLOY

### Pre-Deploy Checklist
- [ ] All CI/CD checks passing
- [ ] Code reviewed and approved
- [ ] Database migrations prepared
- [ ] Environment variables updated in deployment
- [ ] Rollback plan ready
- [ ] Monitoring/alerting configured

### Run Full Audit
```bash
# Use automated review workflow
/review full

# Or manually run all checks from code-review-automation.md
```

---

## 🚫 NEVER DO THIS

### Security
- ❌ Commit secrets/API keys
- ❌ Use `eval()` or `exec()` with user input
- ❌ Store passwords in plain text
- ❌ Disable security features (CORS, CSRF, etc.) without understanding
- ❌ Use outdated/vulnerable dependencies

### Performance
- ❌ Fetch all records without pagination
- ❌ N+1 database queries
- ❌ Blocking operations in loops
- ❌ Large bundles without code splitting

### Code Quality
- ❌ Copy-paste code (extract to function)
- ❌ God classes/functions (thousands of lines)
- ❌ Deep nesting (> 4 levels)
- ❌ Commented-out code
- ❌ TODO comments without tickets

### Testing
- ❌ Skip tests to "save time"
- ❌ Test implementation details
- ❌ Flaky tests (fix or remove)
- ❌ Tests that depend on each other

---

## 📊 QUALITY GATES

### Minimum Standards (MUST PASS)
- Type safety: 0 errors
- Security: 0 critical/high vulnerabilities
- Tests: > 80% coverage on critical paths
- Linting: 0 errors (warnings acceptable)
- Build: Successful

### Target Standards (SHOULD ACHIEVE)
- Performance: Response time < 200ms
- Bundle size: < 500KB gzipped
- Code duplication: < 5%
- Complexity: < 10 average
- Documentation: API fully documented

### Excellence Standards (NICE TO HAVE)
- Test coverage: > 90%
- Accessibility: WCAG AA compliant
- Performance: Lighthouse score > 90
- Security headers: All A ratings
- Zero technical debt

---

## 🎓 FRAMEWORK-SPECIFIC QUICK TIPS

### React + Next.js
- Use Server Components by default
- Client Components only when needed (interactivity)
- `next/image` for all images
- `next/font` for fonts
- Dynamic imports for code splitting

### Laravel
- Eloquent over raw SQL
- Form Requests for validation
- Resource classes for API responses
- Jobs for async tasks
- Artisan commands for CLI tasks

### Python (FastAPI/Django)
- Type hints on all functions
- Pydantic for data validation
- Async/await for I/O operations
- Dependency injection
- Alembic/Django migrations

### Go
- Error handling (return errors, don't panic)
- Context for cancellation
- Defer for cleanup
- Interfaces for abstraction
- Table-driven tests

---

## 🔗 REFERENCES

See full guidelines in:
- `.agent/rules/standards/code-quality-standards.md`
- `.agent/rules/standards/security-standards/`
- `.agent/rules/standards/testing-standards.md`
- `.agent/workflows/code-review-automation.md`

---

**Remember:** Good code is code that:
1. Works correctly
2. Is secure
3. Performs well
4. Is easy to understand
5. Is easy to change

**Print this checklist and keep it visible while coding!**

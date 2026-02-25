---
description: Review code tự động
---

# 🤖 Automated Code Review Workflow

// turbo-all

**Agent:** `ai-code-reviewer`  
**Skills:** `code-review-checklist, clean-code, testing-patterns`

**Purpose:** Universal, tech-stack-agnostic code review automation  
**Applies to:** All projects (Frontend, Backend, Fullstack, Mobile)  
**Auto-execution:** Can be triggered via `/review` command

---

## 🎯 USAGE

**Quick Review:**
```bash
# Run complete audit
/code-review-automation

# Run specific category
/security-audit
/optimize
/check
```

**Manual Step-by-Step:**
Use prompts below in order for comprehensive review.

---

## 📋 UNIVERSAL REVIEW CHECKLIST

**Time:** 2-3 hours for full audit  
**Frequency:** 
- Before production deploy: ALWAYS
- After major changes: ALWAYS  
- Weekly: Quick health check
- Monthly: Full comprehensive review

---

## 1️⃣ STATIC ANALYSIS & TYPE SAFETY

```
Với vai trò là Static Analysis Expert, analyze codebase theo tech stack:

## Auto-Detect Tech Stack
Identify project type and apply appropriate checks:
- TypeScript/JavaScript → tsc, ESLint
- PHP → PHPStan, Pint
- Python → mypy, pylint
- Go → go vet, golint
- Rust → clippy
- Java/Kotlin → ktlint, detekt

## TypeScript/JavaScript Projects
1. Type checking:
   ```bash
   npm run typecheck || tsc --noEmit
   ```
   Target: 0 type errors
   
2. Find `any` types:
   ```bash
   grep -r ": any" --include="*.ts" --include="*.tsx" || true
   ```
   Target: < 5% of total type annotations

3. Strict mode verification:
   ```bash
   cat tsconfig.json | grep -A 10 "compilerOptions"
   ```
   Required: `"strict": true`

4. Linting:
   ```bash
   npm run lint
   npm run lint -- --fix  # Auto-fix
   ```
   Target: 0 errors, < 10 warnings

## PHP Projects (Laravel)
1. Static analysis:
   ```bash
   ./vendor/bin/phpstan analyse --level=5
   ```
   Target: Level 5+, 0 errors

2. Code style:
   ```bash
   ./vendor/bin/pint
   ```
   Target: PSR-12 compliant

## Python Projects
1. Type checking:
   ```bash
   mypy . --strict
   ```

2. Linting:
   ```bash
   pylint **/*.py
   flake8
   ```

## Universal Checks (All Languages)
1. Circular dependencies:
   ```bash
   # For Node
   npx madge --circular --extensions ts,tsx,js src/
   
   # For Python
   pydeps --cluster --max-bacon=2 .
   ```
   Target: 0 circular imports

2. Unused code:
   ```bash
   # TypeScript
   npx ts-prune
   
   # Python  
   vulture .
   
   # PHP
   composer require --dev phpstan/phpstan-deprecation-rules
   ```
   Target: Clean up all unused code

3. Code complexity:
   ```bash
   # Any language
   npx complexity-report src/
   ```
   Target: Cyclomatic complexity < 10

## Output Format
- [ ] Type safety: PASS / X errors
- [ ] Linting: PASS / X errors, Y warnings  
- [ ] Circular deps: 0 found
- [ ] Unused code: < 1%
- [ ] Complexity: < 10 average
- [ ] **OVERALL: PASS / NEEDS FIX**

**GO/NO-GO Decision:** _____
```

---

## 2️⃣ SECURITY AUDIT (Universal)

```
Với vai trò là Security Audit Expert, perform comprehensive security review:

## Dependency Vulnerabilities (Auto-Detect)
```bash
# Node.js
npm audit --production
npm audit --audit-level=moderate

# PHP/Composer
composer audit

# Python/pip
pip-audit
safety check

# Rust
cargo audit

# Go
go list -json -m all | nancy sleuth
```

Target: 0 critical, 0 high vulnerabilities

## Secret Detection (Universal)
```bash
# Use gitleaks or truffleHog
gitleaks detect --source . --verbose

# Or manual grep (all languages)
grep -r "api_key\|apiKey\|API_KEY\|password\|PASSWORD\|secret\|SECRET\|token\|TOKEN" \
  --include="*.ts" --include="*.js" --include="*.php" --include="*.py" \
  --include="*.go" --include="*.java" --include="*.rb" \
  --exclude-dir=node_modules --exclude-dir=vendor
```

Target: 0 hardcoded secrets

## Environment Configuration
- [ ] `.env.example` exists with all required vars
- [ ] `.gitignore` covers sensitive files (`.env`, keys, etc.)
- [ ] No credentials in code commits (check git history)

## OWASP Top 10 (Framework-Agnostic)
Check based on `.agent/rules/standards/owasp-top10-guide.md`:

1. **A01 - Broken Access Control**
   - [ ] Authorization checks on all protected routes
   - [ ] Role-based access control implemented
   - [ ] No direct object references without validation

2. **A02 - Cryptographic Failures**
   - [ ] Sensitive data encrypted at rest
   - [ ] TLS/HTTPS enforced
   - [ ] Secure password hashing (bcrypt, Argon2)

3. **A03 - Injection**
   - [ ] SQL: Parameterized queries/ORM (NO raw SQL strings)
   - [ ] XSS: Input sanitization, output encoding
   - [ ] Command injection: No `exec()` with user input

4. **A04 - Insecure Design**
   - [ ] Threat modeling performed
   - [ ] Security requirements documented
   - [ ] Secure defaults configured

5. **A07 - Authentication Failures**
   - [ ] MFA available/enforced
   - [ ] Password policies (min length, complexity)
   - [ ] Session timeout configured
   - [ ] Rate limiting on auth endpoints

## Security Headers
```bash
# Check via curl or security scanner
curl -I https://yourapp.com | grep -iE "content-security-policy|x-frame-options|strict-transport-security"
```

Required headers:
- `Content-Security-Policy`
- `X-Frame-Options: DENY`
- `Strict-Transport-Security`
- `X-Content-Type-Options: nosniff`

## Output Format
- [ ] Dependencies: X critical, Y high vulns
- [ ] Secrets: 0 found
- [ ] OWASP Top 10: X/10 passing
- [ ] Security headers: All present
- [ ] **SECURITY SCORE: __/100**

**GO/NO-GO Decision:** _____
```

---

## 3️⃣ PERFORMANCE VALIDATION (Auto-Adapt)

```
Với vai trò là Performance Expert, validate performance optimizations:

## Build Performance (Frontend)
```bash
# Detect build tool
if [ -f "vite.config.js" ]; then
  time npm run build  # Target: < 30s
elif [ -f "webpack.config.js" ]; then
  time npm run build  # Target: < 120s
elif [ -f "next.config.js" ]; then
  time npm run build  # Target: < 60s
fi
```

## Bundle Size Analysis
```bash
# Vite
npm run build && ls -lh dist/assets/

# Webpack
npm run build -- --analyze

# Next.js
ANALYZE=true npm run build
```

Targets:
- Total JS: < 500KB gzipped
- Initial load: < 200KB
- Lazy-loaded chunks: < 100KB each

## Backend Performance
```bash
# Laravel
php artisan octane:start --watch
ab -n 1000 -c 10 http://localhost:8000/

# Node.js/Express
autocannon -c 10 -d 10 http://localhost:3000/

# FastAPI/Flask
wrk -t4 -c100 -d30s http://localhost:8000/

# Go
hey -n 1000 -c 10 http://localhost:8080/
```

Targets:
- Requests/sec: > 500 (with caching)
- Response time p99: < 200ms
- Error rate: < 0.1%

## Database Performance
```bash
# Check query performance (universal)
# Enable query logging, then analyze:

# PostgreSQL
EXPLAIN (ANALYZE, BUFFERS) SELECT ...;

# MySQL
EXPLAIN SELECT ...;

# MongoDB  
db.collection.explain("executionStats").find()
```

Targets:
- N+1 queries: 0
- Missing indexes: 0  
- Slow queries (>100ms): 0

## Caching Strategy
Check cache implementation:
- [ ] Redis/Memcached configured
- [ ] Cache hit rate > 80%
- [ ] TTLs appropriate
- [ ] Cache invalidation strategy exists

## Output Format
- [ ] Build time: __s (Target: < 60s)
- [ ] Bundle size: __KB (Target: < 500KB)
- [ ] Backend RPS: _____ (Target: > 500)
- [ ] DB queries optimized: YES/NO
- [ ] Cache hit rate: ____%
- [ ] **PERFORMANCE SCORE: __/100**

**GO/NO-GO Decision:** _____
```

---

## 4️⃣ CODE QUALITY (Universal Standards)

```
Với vai trò là Code Quality Expert, assess code quality:

## Complexity Metrics
```bash
# TypeScript/JavaScript
npx complexity-report src/

# Python
radon cc . -a -nb

# PHP
phpmetrics --report-html=./metrics ./src

# Go
gocyclo .

# Universal (any language)
sonarqube scan
```

Targets:
- Cyclomatic complexity: < 10
- Cognitive complexity: < 15
- Max function lines: < 50

## Code Duplication
```bash
# Universal
npx jscpd src/

# Or language-specific
# Python: pylint --disable=all --enable=duplicate-code
# PHP: phpcpd src/
```

Target: < 5% duplication

## Naming \u0026 Style Conventions
Based on `.agent/rules/standards/code-quality-standards.md`:

- [ ] Consistent naming (camelCase, PascalCase, snake_case per language)
- [ ] Descriptive names (no single letters except loops)
- [ ] No magic numbers (use constants)
- [ ] Functions < 50 lines
- [ ] Classes < 200 lines
- [ ] Single Responsibility Principle followed

## Framework-Specific Best Practices
Auto-detect and apply:

### Laravel
- [ ] Eloquent best practices (eager loading, scopes)
- [ ] Service layer for business logic
- [ ] Form Requests for validation
- [ ] Resource transformers for API responses

### React
- [ ] Hooks rules followed
- [ ] Component composition over inheritance
- [ ] Props properly typed
- [ ] No prop drilling (use Context/state management)

### Next.js
- [ ] Server Components used appropriately
- [ ] Client Components minimal
- [ ] Image optimization (next/image)
- [ ] Font optimization (next/font)

### FastAPI/Flask
- [ ] Pyd antic models for validation
- [ ] Dependency injection used
- [ ] Async/await where appropriate
- [ ] Type hints on all functions

## Output Format
- [ ] Complexity: X functions > 10
- [ ] Duplication: ____%
- [ ] Naming: CONSISTENT / NEEDS WORK
- [ ] Framework patterns: X/10
- [ ] **QUALITY SCORE: __/100**

**GO/NO-GO Decision:** _____
```

---

## 5️⃣ TESTING \u0026 COVERAGE

```
Với vai trò là QA Expert, verify testing strategy:

## Test Execution (Auto-Detect)
```bash
# Node.js
npm test || npm run test:unit
npm run test:integration  
npm run test:e2e

# PHP/Laravel
php artisan test
./vendor/bin/pest

# Python
pytest
pytest --cov=.

# Go
go test ./...
go test -cover ./...

# Rust
cargo test
```

## Coverage Requirements
```bash
# Generate coverage report
npm run test:coverage  # Node
pytest --cov-report=html  # Python
go test -coverprofile=coverage.out  # Go
```

Targets:
- Overall coverage: > 80%
- Critical paths: > 90%
- Branches covered: > 75%

## Test Quality Checks
- [ ] Unit tests exist for core logic
- [ ] Integration tests for API endpoints
- [ ] E2E tests for critical user flows
- [ ] No skipped/disabled tests without reason
- [ ] Tests are deterministic (no flaky tests)
- [ ] Mock external dependencies

## Critical User Flows
Test these manually or via E2E:
- [ ] User authentication (signup, login, logout)
- [ ] Main feature workflows
- [ ] Payment/checkout (if applicable)
- [ ] Data CRUD operations
- [ ] Error handling
- [ ] Edge cases

## Output Format
- [ ] Tests passing: X/Y (___%)
- [ ] Coverage: ____%
- [ ] Critical flows tested: YES/NO
- [ ] Flaky tests: 0
- [ ] **TESTING SCORE: __/100**

**GO/NO-GO Decision:** _____
```

---

## 6️⃣ DOCUMENTATION (Universal)

```
Với vai trò là Documentation Expert, verify documentation quality:

## Code Documentation
- [ ] Complex functions have comments explaining WHY
- [ ] Public APIs documented (JSDoc, PHPDoc, docstrings)
- [ ] No commented-out code
- [ ] README.md exists and complete

## API Documentation
Based on `.agent/rules/standards/api-documentation-standards.md`:

- [ ] OpenAPI/Swagger spec exists
- [ ] All endpoints documented
- [ ] Request/response examples provided
- [ ] Error codes documented
- [ ] Authentication flow documented

## Project Documentation
Check `docs/` folder:
- [ ] ARCHITECTURE.md exists
- [ ] Database schema documented
- [ ] Deployment guide present
- [ ] Environment setup instructions
- [ ] Contribution guidelines

## Output Format
- [ ] Code comments: ADEQUATE / SPARSE
- [ ] API docs: COMPLETE / INCOMPLETE
- [ ] Project docs: X/5 files present
- [ ] **DOCUMENTATION SCORE: __/100**

**GO/NO-GO Decision:** _____
```

---

## 7️⃣ BUILD \u0026 DEPLOYMENT (Universal)

```
Với vai trò là DevOps Expert, verify build \u0026 deployment readiness:

## Build Verification
```bash
# Clean build test (adapt per project)
rm -rf node_modules dist build .next  # Frontend
rm -rf vendor  # PHP
rm -rf __pycache__ .pytest_cache  # Python

# Reinstall \u0026 build
npm ci \u0026\u0026 npm run build  # Node
composer install --no-dev --optimize-autoloader  # PHP
pip install -r requirements.txt  # Python
go build  # Go
```

Targets:
- Build successful: YES
- Build time: Reasonable for project size
- No errors: YES

## Environment Configuration
- [ ] `.env.example` || `config.example.yml` exists
- [ ] All required env vars documented
- [ ] Separate configs for dev/staging/prod
- [ ] Secrets not in code or version control

## CI/CD Pipeline
- [ ] CI runs on every PR/commit
- [ ] Tests run in CI
- [ ] Linting runs in CI
- [ ] Security scans in CI
- [ ] Deploy automation configured

## Container Build (if using Docker)
```bash
docker build -t app:test .
docker run --rm app:test npm test  # or appropriate command
```

- [ ] Dockerfile exists
- [ ] Multi-stage build for optimization
- [ ] Image size reasonable (< 500MB for Node, < 200MB for Go)
- [ ] Health check configured

## Output Format
- [ ] Build: PASS / FAIL
- [ ] Envs configured: ALL / PARTIAL
- [ ] CI/CD: CONFIGURED / MISSING
- [ ] Docker: PASS / FAIL / N/A
- [ ] **BUILD SCORE: __/100**

**GO/NO-GO Decision:** _____
```

---

## 🔟 FINAL HEALTH SCORE (Automated Calculation)

```
Với vai trò là System Health Auditor, calculate FINAL SCORE:

## Aggregate Scores

1. Static Analysis: __/100
2. Security: __/100
3. Performance: __/100
4. Code Quality: __/100
5. Testing: __/100
6. Documentation: __/100
7. Build: __/100

## Weighted Average
```
FINAL SCORE = (
  Static × 0.15 +
  Security × 0.25 +
  Performance × 0.15 +
  Quality × 0.15 +
  Testing × 0.15 +
  Documentation × 0.05 +
  Build × 0.10
) = __/100
```

## Interpretation
- **90-100:** ⭐⭐⭐⭐⭐ EXCELLENT - Production ready
- **80-89:** ⭐⭐⭐⭐ GOOD - Minor improvements needed
- **70-79:** ⭐⭐⭐ ACCEPTABLE - Address issues before deploy
- **60-69:** ⭐⭐ NEEDS WORK - Significant improvements required
- **< 60:** ⭐ NOT READY - Major issues must be fixed

## Critical Blockers
List ANY issues that BLOCK deployment:
1. _____
2. _____
3. _____

## Automated Report Generation
```bash
# Generate comprehensive report
cat > code-review-report.md << EOF
# Code Review Report - $(date +%Y-%m-%d)

**Project:** [Auto-detected]
**Commit:** $(git rev-parse --short HEAD)
**Score:** $FINAL_SCORE/100

## Summary
[Auto-generated summary]

## Details
[Link scores from each section]

## Recommendations
[Top 5 improvements]

## Sign-off
- [ ] Tech Lead
- [ ] Security Team  
- [ ] QA Lead
EOF
```

## FINAL DECISION
**Production Ready:** ✅ YES / ❌ NO  
**Date:** $(date)

**Next Steps:**
- IF YES → Deploy to staging → UAT → Production
- IF NO → Fix blockers → Re-run review → Re-assess
```

---

## 🤖 AUTOMATION INTEGRATION

### Use with `.agent` System

**1. Add to workflows:**
```yaml
# .agent/workflows/automated-review.yml
name: Code Review Automation
trigger: pre-deploy
steps:
  - run: Static Analysis
  - run: Security Audit
  - run: Performance Validation
  - run: Quality Check
  - run: Generate Report
```

**2. Integration with CI/CD:**
```yaml
# .github/workflows/code-review.yml
name: Automated Code Review
on: [pull_request]
jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run .agent review
        run: |
          # Load .agent configuration
          # Run automated checks
          # Post results as PR comment
```

**3. Pre-commit Hooks:**
```bash
# .git/hooks/pre-commit
#!/bin/bash
# Quick automated checks before commit
npm run lint
npm run typecheck
npm run test:changed
```

---

## 📚 REFERENCE TO .AGENT STANDARDS

This workflow leverages:
- `.agent/rules/standards/code-quality-standards.md`
- `.agent/rules/standards/api-security-conventions.md`
- `.agent/rules/standards/ci-cd-security-conventions.md`
- `.agent/rules/standards/security-testing-templates.md`
- `.agent/rules/standards/supply-chain-security.md`
- `.agent/rules/standards/testing-standards.md`
- `.agent/rules/standards/api-documentation-standards.md`
- `.agent/workflows/` (other automation workflows)

---

**VERSION:** 2.0 (Universal)  
**LAST UPDATED:** 2026-01-17  
**TECH STACKS:** All (Auto-detecting)  
**AUTOMATION:** Full support
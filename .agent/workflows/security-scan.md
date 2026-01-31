---
description: Comprehensive security audit workflow
---

# /security-scan - Security Audit

Thực hiện comprehensive security scan để phát hiện vulnerabilities, insecure patterns, và suggest fixes.

---

## Usage

```
/security-scan
/security-scan --scope=api
/security-scan --framework=laravel
```

---

## Scan Coverage

### 1. OWASP Top 10
- SQL Injection
- XSS (Cross-Site Scripting)
- CSRF (Cross-Site Request Forgery)
- Authentication/Authorization flaws
- Sensitive data exposure
- Security misconfiguration
- Insecure dependencies

### 2. Framework-Specific
**Laravel:**
- CSRF token validation
- Mass assignment protection
- SQL injection (Eloquent)
- XSS (Blade escaping)
- File upload validation

**FastAPI:**
- JWT security
- CORS configuration
- Input validation
- SQL injection (SQLAlchemy)

### 3. Dependencies
- Outdated packages
- Known vulnerabilities (CVE)
- License compliance

### 4. Code Patterns
- Hardcoded secrets
- Weak password hashing
- Insecure randomness
- Path traversal risks

---

## Output Report

```markdown
# Security Scan Report

## Critical Issues (2)
❌ **SQL Injection Risk** - `UserController.php:45`
  - Raw query without parameterization
  - Fix: Use Eloquent or parameterized queries

❌ **Hardcoded API Key** - `config/services.php:12`
  - API key in source code
  - Fix: Move to environment variables

## High Priority (3)
⚠️ **Missing CSRF Protection** - `routes/api.php:23`
⚠️ **Weak Password Hash** - `User.php:34`
⚠️ **Outdated Dependency** - `laravel/framework:^9.0`

## Recommendations
✅ Enable security headers (CSP, X-Frame-Options)
✅ Implement rate limiting on API endpoints
✅ Add input sanitization on user inputs
```

---

## Auto-Fix Capability

- Replace hardcoded secrets → env variables
- Add CSRF tokens  
- Update vulnerable dependencies
- Add input  validation

---

## Time Saved: 2-3 hours manual security review

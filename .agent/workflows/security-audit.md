---
description: Comprehensive security vulnerability scanning and remediation
---

# /security-audit - Security Analysis Workflow

Comprehensive security scanning combining automated tools and expert analysis to identify and fix vulnerabilities.

---

## When to Use

- Pre-deployment security check
- Security compliance audit
- After dependency updates
- Incident response
- Periodic security reviews

---

## Input Required

```
Audit scope:
1. Project path (full scan or specific directory)
2. Scan depth:
   - Quick (OWASP Top 10)
   - Standard (OWASP + dependencies)
   - Deep (Full pentest simulation)
3. Fix mode: Report only | Auto-fix safe issues
```

---

## Workflow Steps

### Step 1: OWASP Top 10 Scan

**Automated checks:**

```javascript
// Scan categories
const owasp2025 = [
  'A01: Broken Access Control',
  'A02: Security Misconfiguration',
  'A03: Software Supply Chain',
  'A04: Cryptographic Failures',
  'A05: Injection',
  'A06: Insecure Design',
  'A07: Authentication Failures',
  'A08: Integrity Failures',
  'A09: Logging & Monitoring',
  'A10: Exceptional Conditions'
];

// Run scans
for (const category of owasp2025) {
  await scanForVulnerability(category);
}
```

**Agent:** `security-auditor`

---

### Step 2: Dependency Vulnerability Scan

**Check for known CVEs:**

```bash
# npm audit (Node.js)
npm audit --audit-level=moderate

# pip-audit (Python)
pip-audit

# composer audit (PHP)
composer audit

# Check SBOM against vulnerability databases
```

**Output example:**
```
📦 Dependency Vulnerabilities:

CRITICAL (2):
- lodash@4.17.20 → Prototype Pollution (CVE-2021-23337)
  Fix: npm install lodash@4.17.21
  
- axios@0.21.0 → Server-Side Request Forgery (CVE-2021-3749)
  Fix: npm install axios@1.6.0

HIGH (3):
- express@4.17.1 → Denial of Service
- jwt-simple@0.5.6 → Algorithm Confusion
- serialize-javascript@5.0.1 → XSS

```

**Agent:** `security-auditor` + `vulnerability-scanner` skill

---

### Step 3: Code Pattern Analysis

**Detect security anti-patterns:**

```php
// Detected issues:

❌ SQL Injection Risk (app/Controllers/UserController.php:45)
$users = DB::select("SELECT * FROM users WHERE email = '$email'");
                                                           ^^^^^^^^
FIX: Use parameterized queries
✅ $users = DB::select("SELECT * FROM users WHERE email = ?", [$email]);

❌ XSS Vulnerability (resources/views/profile.blade.php:12)
{!! $user->bio !!}
^^^^^^^^^^^^^^^^^^^
FIX: Escape output
✅ {{ $user->bio }}

❌ Hardcoded Secret (config/services.php:8)
'api_key' => 'sk_live_abc123...'
              ^^^^^^^^^^^^^^^^^^
FIX: Use environment variables
✅ 'api_key' => env('STRIPE_API_KEY')

❌ Weak Hashing (app/Models/User.php:23)
protected $attributes = ['password' => 'md5'];
                                      ^^^^^^
FIX: Use bcrypt
✅ protected $casts = ['password' => 'hashed'];
```

**Agent:** `security-auditor`

---

### Step 4: Penetration Testing Simulation

**Red team tactics:**

```
🎯 Attack Simulations:

1. Authentication Bypass
   ├── Brute force protection: ✅ PASS
   ├── Session fixation: ✅ PASS
   └── JWT validation: ❌ FAIL (algorithm confusion possible)

2. Authorization
   ├── IDOR testing: ❌ FAIL (/api/users/{id} exposed)
   ├── Privilege escalation: ✅ PASS
   └── CSRF protection: ✅ PASS

3. Injection Attacks
   ├── SQL injection: ❌ FAIL (raw queries in UserController)
   ├── XSS: ❌ FAIL (unescaped output in profile view)
   ├── Command injection: ✅ PASS
   └── LDAP injection: ✅ PASS

4. Data Exposure
   ├── Sensitive data in logs: ❌ FAIL (passwords logged)
   ├── Missing security headers: ❌ FAIL (X-Frame-Options)
   └── Directory listing: ✅ PASS
```

**Agent:** `penetration-tester` + `red-team-tactics` skill

---

### Step 5: Configuration Audit

**Security misconfigurations:**

```yaml
# .env issues
❌ APP_DEBUG=true (in production!)
   FIX: APP_DEBUG=false

❌ DB_PASSWORD=password123 (weak password)
   FIX: Use strong password (20+ chars)

# Missing security headers (HTTP response)
❌ Missing: X-Frame-Options
   FIX: Add X-Frame-Options: DENY

❌ Missing: Content-Security-Policy
   FIX: Add CSP headers

❌ Missing: Strict-Transport-Security
   FIX: Add HSTS headers

# CORS misconfiguration
❌ Access-Control-Allow-Origin: *
   FIX: Specify allowed origins
```

**Agent:** `security-auditor`

---

### Step 6: Generate Remediation Plan

**Prioritized fixes:**

```markdown
## Security Audit Report

### Executive Summary
- 🔴 CRITICAL: 3 issues
- 🟡 HIGH: 5 issues
- 🟢 MEDIUM: 8 issues
- ℹ️ LOW: 12 issues

### Critical Issues (Fix Immediately)

#### 1. SQL Injection in UserController
**Severity:** CRITICAL (CVSS 9.8)
**File:** app/Http/Controllers/UserController.php:45
**Risk:** Database compromise, data theft

**Vulnerable Code:**
```php
$users = DB::select("SELECT * FROM users WHERE email = '$email'");
```

**Fix:**
```php
$users = DB::select("SELECT * FROM users WHERE email = ?", [$email]);
```

**Test:**
```php
// Verify fix blocks injection
$this->post('/users', ['email' => "' OR '1'='1"])
     ->assertStatus(422);
```

---

#### 2. Hardcoded API Keys
**Severity:** CRITICAL (CVSS 9.1)
**File:** config/services.php:8
**Risk:** API abuse, unauthorized access

**Fix:**
1. Move to .env: `STRIPE_KEY=sk_live_...`
2. Update config: `'key' => env('STRIPE_KEY')`
3. Rotate exposed keys immediately

---

### High Priority Issues

[... detailed fixes for each HIGH issue ...]

### Automated Fixes Available

The following can be auto-fixed safely:
- [ ] Update dependencies (12 packages)
- [ ] Add security headers
- [ ] Fix XSS in views (escape output)
- [ ] Remove debug mode

Apply auto-fixes? (yes/no)
```

**Agent:** `security-auditor` + `penetration-tester`

---

### Step 7: Apply Fixes (If Approved)

**Auto-fix safe issues:**

```bash
✅ Updated lodash: 4.17.20 → 4.17.21
✅ Updated axios: 0.21.0 → 1.6.0
✅ Added security headers to middleware
✅ Fixed XSS in 5 views (escaped output)
✅ Disabled debug mode in .env.production
✅ Generated new API keys (old keys revoked)
```

**Manual fixes required:**
```
⚠️ Requires developer review:
1. SQL injection fixes (3 locations)
2. IDOR vulnerability (authentication logic)
3. JWT algorithm validation
```

**Agent:** `security-auditor`

---

### Step 8: Verify Fixes

**Re-scan after fixes:**

```
🔄 Re-scanning...

Before → After:
- CRITICAL: 3 → 0 ✅
- HIGH: 5 → 2 ⚠️
- MEDIUM: 8 → 3 ⚠️
- LOW: 12 → 8 ⚠️

Remaining issues require manual review.
```

**Agent:** `security-auditor`

---

## Agent Orchestration

```
1. security-auditor
   └── OWASP Top 10 scan
   └── Code pattern analysis
   └── Configuration audit
   
2. penetration-tester
   └── Attack simulations
   └── Exploit validation
   └── Security testing
   
3. {framework}-specialist (if needed)
   └── Framework-specific fixes
   
4. test-engineer
   └── Security test generation
   
5. security-auditor
   └── Verify fixes
   └── Generate final report
```

---

## Error Handling

**If scan crashes:**
```
→ Continue partial scan
→ Log errors for review
→ Report completed sections
```

**If auto-fix breaks code:**
```
→ Automatic rollback
→ Flag for manual review
→ Update fix strategy
```

---

## Success Criteria

✅ All CRITICAL issues resolved  
✅ HIGH issues documented/fixed  
✅ Dependencies updated  
✅ Security tests passing  
✅ No regressions introduced

---

## Example Usage

**User request:**
```
/security-audit --depth=standard --fix=auto
```

**Agent response:**
```
🔍 Security Audit Started...

Scanning:
✅ OWASP Top 10 checks
✅ Dependency vulnerabilities
✅ Code pattern analysis
✅ Configuration audit

📊 Results:
- 🔴 CRITICAL: 2
- 🟡 HIGH: 4
- 🟢 MEDIUM: 6
- ℹ️ LOW: 10

🔧 Auto-fixing safe issues...
✅ Fixed 8 issues automatically
⚠️ 6 issues require manual review

📄 Full report: security-audit-2024-01-16.pdf

Next steps:
1. Review manual fixes in report
2. Rotate exposed API keys
3. Re-run audit after fixes
```

---

## Tools Integration

**Automated scanning tools:**
- OWASP ZAP (web vulnerabilities)
- npm audit / pip-audit (dependencies)
- Snyk / Trivy (container scanning)
- SonarQube (code quality + security)
- Checkov (IaC security)

---

## Tips

💡 **Run before every deployment**  
💡 **Fix CRITICAL immediately**  
💡 **Automate in CI/CD**  
💡 **Keep dependencies updated**  
💡 **Rotate secrets regularly**

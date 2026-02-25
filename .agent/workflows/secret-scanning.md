---
description: Quét mã nguồn tìm thông tin nhạy cảm
turbo-all: false
---

# Secret Scanning Workflow

// turbo-all

**Agent:** `security-auditor`  
**Skills:** `vulnerability-scanner, red-team-tactics`

> Prevent credential leaks by scanning code before commit

---

## 🎯 Purpose

**Prevents:**
- API keys in code
- Database passwords committed
- Private keys leaked
- Credentials in git history

---

## 📋 Workflow Steps

### Step 1: Pre-Commit Scan

```bash
# Automatic on git commit (if hook installed)
# Or manual:
.agent/scripts/secret-scan.ps1 --staged
```

**Checks:**
- [ ] AWS keys (AKIA...)
- [ ] Stripe keys (sk_live_...)
- [ ] GitHub tokens (ghp_...)
- [ ] Database URLs with passwords
- [ ] Private keys (RSA, SSH)
- [ ] Generic password patterns

---

### Step 2: Analyze Results

**If CLEAN:**
```
✅ Secret Scan: PASSED
No secrets detected in 15 files
Commit allowed
```

**If BLOCKED:**
```
🔴 CRITICAL: Secret detected!

File: config/services.php
Line: 23
Type: Stripe Live Key
Match: sk_live_123abc...

This commit has been BLOCKED.
```

---

### Step 3: Fix Detected Secrets

**Option A: Use Environment Variables**

```php
// ❌ BEFORE (blocked)
$stripe = new Stripe('sk_live_123abc...');

// ✅ AFTER (allowed)
$stripe = new Stripe(env('STRIPE_SECRET_KEY'));
```

**Option B: Add to .env**
```bash
# .env (NEVER commit this file!)
STRIPE_SECRET_KEY=sk_live_123abc...
```

**Option C: False Positive**
```bash
# If this is not a real secret (test/example)
# Add to .secretscanignore
echo "config/examples.php:45" >> .secretscanignore
```

---

### Step 4: Retry Commit

```bash
git add .
git commit -m "Add payment feature"
# Should pass now if secrets removed
```

---

## 🔧 Quick Commands

**Manual scan:**
```bash
# Scan staged files
.agent/scripts/secret-scan.ps1 --staged

# Scan all files
.agent/scripts/secret-scan.ps1 --all

# Scan specific file
.agent/scripts/secret-scan.ps1 --file config/services.php
```

**Install git hooks:**
```bash
.agent/scripts/install-hooks.ps1
```

---

## 📊 Severity Levels

| Level | Action | Examples |
|-------|--------|----------|
| 🔴 **CRITICAL** | Block | AWS keys, Stripe live, Private keys |
| 🟠 **HIGH** | Block | Passwords, API keys |
| 🟡 **WARNING** | Warn | JWT tokens, Test keys |

---

## 📖 Configuration

**Full config:** `.agent/secret-scanning.yml`

**Patterns:** 30+ detection patterns

**Exclusions:**
- `.env.example` (allowed)
- `node_modules/`, `vendor/`
- Test files with `test_`, `mock_`, `fake_`

---

## 🔗 Integration

**With AI Code Reviewer:**
- Secret scan runs before AI review
- Critical secrets block all review

**With CI/CD:**
- Add to pipeline for PR checks
- Block merge if secrets detected

---

**Created:** 2026-01-19  
**Industry Standard:** GitHub, GitLab Secret Scanning  
**Impact:** Prevent credential leaks
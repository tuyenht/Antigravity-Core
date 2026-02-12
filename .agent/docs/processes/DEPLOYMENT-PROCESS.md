# Deployment Process — Quy trình Deploy

**Version:** 4.0.0  
**Last Updated:** 2026-02-13

---

## Overview

Quy trình deploy theo **5-Phase Deployment Process**: Prepare → Backup → Deploy → Verify → Confirm/Rollback.

---

## Pre-Deploy Checklist

```powershell
# 1. Full compliance check
.\.agent\agent.ps1 validate

# 2. Performance budgets
.\.agent\agent.ps1 perf

# 3. Secret scan
.\.agent\agent.ps1 secret-scan

# 4. Security audit
/security-audit
```

**ALL checks phải PASS trước khi deploy.**

---

## 5-Phase Deployment

### Phase 1: Prepare
- [ ] All pre-deploy checks passed
- [ ] CHANGELOG.md updated
- [ ] Version number bumped
- [ ] Migration scripts tested locally
- [ ] Environment variables configured on target

### Phase 2: Backup
```bash
# Database backup
pg_dump -Fc mydb > backup_$(date +%Y%m%d_%H%M%S).dump

# Config backup
cp .env .env.backup.$(date +%Y%m%d)
```

### Phase 3: Deploy
```bash
# Using workflow
/deploy

# Or manual steps:
git tag v1.x.x
git push origin main --tags

# Run migrations
php artisan migrate       # Laravel
npx prisma migrate deploy # Prisma
```

### Phase 4: Verify
```bash
# Health check endpoint
curl https://app.example.com/health

# Smoke tests
npx playwright test --project=smoke
```

- [ ] Application responding
- [ ] Critical user flows working
- [ ] Error rate normal
- [ ] Response times acceptable

### Phase 5: Confirm or Rollback

**If OK:** Tag as stable
```bash
git tag stable-latest -f
```

**If FAILED:** Rollback immediately
```bash
# Revert to previous version
git revert HEAD
git push origin main

# Restore database if needed
pg_restore -d mydb backup_file.dump
```

---

## Rollback Decision Tree

```
Deploy completed →
├── Health check fails? → IMMEDIATE ROLLBACK
├── Error rate > 5%? → IMMEDIATE ROLLBACK
├── Response time > 2x? → Monitor 5 min → Rollback if persists
├── Minor UI issue? → Hotfix forward
└── All green? → CONFIRM ✅
```

---

> **See also:** [Troubleshooting](./TROUBLESHOOTING.md) | [Rollback Procedures](../ROLLBACK-PROCEDURES.md)

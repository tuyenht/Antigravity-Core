# Deployment Process — Quy trình Deploy

**Version:** 5.0.0  
**Last Updated:** 2026-02-27

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
pnpm exec prisma migrate deploy # Prisma
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
└── All green? → Phase 6 (Monitor) ✅
```

---

## Environment Matrix

| Environment | URL Pattern | Database | Deploy Trigger | Purpose |
|-------------|-------------|----------|----------------|---------|
| **Local** | `localhost:3000` | SQLite / local DB | Manual | Phát triển hàng ngày |
| **Staging** | `staging.app.com` | Clone of production | PR merge → `main` | Testing trước production |
| **Production** | `app.com` | Production DB | Manual tag / CD | Live users |

### Environment Rules
- **Local → Staging:** Tự động qua CI/CD khi merge PR vào `main`
- **Staging → Production:** **Manual approval** bắt buộc sau khi smoke test pass
- **Secrets:** Mỗi environment có `.env` riêng — **KHÔNG** share secrets giữa environments
- **Data:** Staging dùng **anonymized production data** hoặc seed data

---

## Hotfix Fast-Track Flow

Khi production có lỗi P0/P1 cần fix khẩn cấp:

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│ 1. BRANCH    │ ──► │ 2. FIX+TEST  │ ──► │ 3. DEPLOY    │
│              │     │              │     │              │
│ hotfix/XXX   │     │ Fix + 1 test │     │ Fast PR      │
│ từ main      │     │ CI must pass │     │ → main → prod│
└───────────┘     └───────────┘     └───────────┘
```

**Hotfix requirements (tối thiểu):**
- [ ] Branch từ `main`: `hotfix/<ticket>-<mô-tả>`
- [ ] Fix verified locally
- [ ] Regression test cho bug
- [ ] CI pipeline passes
- [ ] 1 reviewer (self-approve allowed cho P0 after-hours)
- [ ] Deploy trực tiếp production (bypass staging nếu P0)
- [ ] Post-deploy monitoring 24h
- [ ] Post-mortem scheduled (xem [Incident Response](./INCIDENT-RESPONSE.md))

---

## Phase 6: Monitor (Post-Deploy)

**Bắt buộc 24h sau mỗi production deploy.**

### Monitoring Checklist
- [ ] Error rate < 1% (alert nếu > 1%)
- [ ] Response time < 200ms p95 (alert nếu > 500ms)
- [ ] Uptime > 99.9%
- [ ] No new error types in logs
- [ ] Memory/CPU usage stable

### Alert Thresholds

| Metric | Warning | Critical | Action |
|--------|---------|----------|--------|
| Error rate | > 1% | > 5% | [Incident Response](./INCIDENT-RESPONSE.md) |
| Latency p95 | > 500ms | > 1s | `/optimize` hoặc rollback |
| Uptime | < 99.9% | < 99% | Immediate investigation |
| Memory | > 80% | > 95% | Scale up / investigate leak |

### SLA Targets

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Availability** | 99.9% | Monthly uptime |
| **Latency** | < 200ms p95 | APM tool |
| **Error budget** | < 0.1% | Errors / total requests |
| **Recovery time** | < 1h (P0), < 4h (P1) | Detection → resolution |

---

> **See also:** [Troubleshooting](./TROUBLESHOOTING.md) | [Rollback Procedures](../ROLLBACK-PROCEDURES.md) | [Incident Response](./INCIDENT-RESPONSE.md) | [Branching Strategy](./BRANCHING-STRATEGY.md)


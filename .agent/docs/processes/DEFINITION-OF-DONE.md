# Definition of Done — Tiêu Chuẩn Hoàn Thành

**Version:** 4.1.0  
**Last Updated:** 2026-02-25

---

## Overview

Checklist thống nhất áp dụng cho **mọi feature, bugfix, và task** trước khi đánh dấu "Done". Không có ngoại lệ.

---

## ✅ Universal DoD (Mọi Task)

### Code Quality
- [ ] Code compiles/builds without errors
- [ ] Zero lint errors (`/auto-healing` passed)
- [ ] Zero type errors (TypeScript strict / PHPStan)
- [ ] No `any` types, no `@ts-ignore`
- [ ] No commented-out code
- [ ] No `console.log` / `dd()` / `print()` debug statements
- [ ] Functions < 50 lines, Cyclomatic complexity < 10
- [ ] No hardcoded secrets (`.env` only)

### Testing
- [ ] Unit tests written for business logic
- [ ] Test coverage ≥ 80% on changed files
- [ ] All tests pass locally (`/test`)
- [ ] Edge cases covered

### Security
- [ ] Secret scan clean (`/secret-scanning`)
- [ ] Input validation on user data
- [ ] SQL queries parameterized
- [ ] Authentication/authorization verified

### Documentation
- [ ] API changes documented
- [ ] Complex logic has WHY comments
- [ ] README updated if needed

### Review
- [ ] AI code review passed (`/code-review-automation`)
- [ ] PR created with clear description
- [ ] At least 1 human approval

---

## 🎯 Feature DoD (Thêm vào Universal)

- [ ] All acceptance criteria implemented (from User Story)
- [ ] Integration tests for key flows
- [ ] Responsive design verified (if UI)
- [ ] Accessibility checked (keyboard nav, screen reader)
- [ ] Loading states implemented
- [ ] Error states handled gracefully
- [ ] Performance: no N+1 queries, lazy loading where needed
- [ ] CHANGELOG.md updated

---

## 🐛 Bugfix DoD (Thêm vào Universal)

- [ ] Root cause identified and documented
- [ ] Regression test added (proving bug stays fixed)
- [ ] Related bugs checked (same component)
- [ ] No new bugs introduced

---

## 🚀 Release DoD (Thêm vào Feature/Bugfix)

- [ ] All sprint stories "Done" per DoD above
- [ ] Full regression suite passes
- [ ] Security audit clean (`/security-audit`)
- [ ] Performance budgets met (`agent.ps1 perf`)
- [ ] Version bumped (`bump-version.ps1`)
- [ ] CHANGELOG.md complete
- [ ] Staging deployment successful
- [ ] Smoke tests pass on staging
- [ ] Rollback plan ready

---

## 🔥 Hotfix DoD (Expedited)

- [ ] Fix verified locally
- [ ] Regression test for the specific bug
- [ ] CI pipeline passes
- [ ] 1 reviewer approval (self-approve allowed for P0 after-hours)
- [ ] Production health check post-deploy
- [ ] Monitoring for 24h
- [ ] Post-mortem scheduled

---

## Quick Reference

```
Task complete? Check:
  ✅ Code clean (lint, types, no debug)
  ✅ Tests pass (≥80% coverage)
  ✅ Security clean (secrets, inputs)
  ✅ Review done (AI + human)
  ✅ Docs updated (if needed)
→ DONE ✅
```

---

> **See also:** [Code Review Process](./CODE-REVIEW-PROCESS.md) | [Daily Development](./DAILY-DEVELOPMENT.md)

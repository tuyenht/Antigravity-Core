---
description: "Kiểm soát ngân sách hiệu suất"
turbo-all: false
---

# Performance Budget Enforcement Workflow

// turbo-all

**Agent:** `performance-optimizer`  
**Skills:** `performance-profiling, react-performance`

> Ensure code changes meet performance standards before merge

---

## 📋 Workflow Steps

### Step 1: Identify Changed Files

```bash
# Get list of changed files
git diff --name-only main...HEAD
```

Identify file types:
- **Frontend:** `*.tsx`, `*.ts`, `*.jsx`, `*.js`, `*.css`
- **Backend:** `*.php`
- **Build:** `package.json`, `composer.json`, `*.config.*`

---

### Step 2: Run Frontend Benchmarks (if changed)

**Bundle Size Check:**
```bash
# Build and measure
npm run build

# Check bundle sizes
npx webpack-bundle-analyzer dist/stats.json --mode static --report bundle-report.html
```

**Verify against budgets:**
- [ ] Main bundle < 200KB
- [ ] Vendor bundle < 300KB
- [ ] Per-route chunks < 50KB

**Lighthouse Check:**
```bash
# Run Lighthouse CI
npx lhci autorun
```

**Verify against budgets:**
- [ ] Performance score ≥ 90
- [ ] LCP < 2.5s
- [ ] FID < 100ms
- [ ] CLS < 0.1

---

### Step 3: Run Backend Benchmarks (if changed)

**Query Analysis:**

Use Laravel Debugbar/Telescope to verify:
- [ ] Query count per request ≤ 10
- [ ] No slow queries > 100ms
- [ ] Total query time < 50ms

**API Response Time:**

Use existing load test or manual timing:
- [ ] p95 response time < 200ms
- [ ] p99 response time < 500ms

---

### Step 4: Check Inertia Props (if changed)

**Measure props size:**
```php
// In controller, log props size
$props = [...];
Log::info('Props size: ' . strlen(json_encode($props)) . ' bytes');
```

**Verify against budgets:**
- [ ] Initial props < 100KB
- [ ] Partial reload props < 50KB

---

### Step 5: Compare Against Baseline

**Get baseline from main branch:**
```bash
git checkout main
npm run build -- --json > baseline-stats.json
git checkout -
```

**Compare:**
- [ ] Bundle size not increased > 10%
- [ ] No new performance regressions
- [ ] Core Web Vitals maintained

---

### Step 6: Generate Report

**Report Template:**
```markdown
# ⚡ Performance Budget Report

**Branch:** feature/xyz
**Compared To:** main
**Date:** 2026-01-19

## Bundle Size
| Metric | Budget | Actual | Status |
|--------|--------|--------|--------|
| Main bundle | 200KB | 185KB | ✅ PASS |
| Vendor | 300KB | 280KB | ✅ PASS |

## Core Web Vitals
| Metric | Budget | Actual | Status |
|--------|--------|--------|--------|
| LCP | 2.5s | 2.1s | ✅ PASS |
| FID | 100ms | 50ms | ✅ PASS |
| CLS | 0.1 | 0.05 | ✅ PASS |

## Backend
| Metric | Budget | Actual | Status |
|--------|--------|--------|--------|
| API p95 | 200ms | 150ms | ✅ PASS |
| Query count | 10 | 8 | ✅ PASS |

## Summary
✅ All performance budgets PASSED
🟢 Ready to merge
```

---

### Step 7: Enforce Decision

**If ALL budgets pass:**
```
✅ Performance Budget: PASSED
Ready to merge.
```

**If ANY error-level budget fails:**
```
❌ Performance Budget: FAILED

Issues:
1. Main bundle exceeds 200KB (actual: 250KB)
   Fix: Use code splitting with React.lazy()

2. API p95 exceeds 200ms (actual: 350ms)
   Fix: Check for N+1 queries

Action: Fix before merge
```

**If only warnings:**
```
⚠️ Performance Budget: PASSED with warnings

Warnings:
1. Vendor bundle approaching limit (280KB/300KB)

Action: Can merge, consider optimization
```

---

## 🔧 Quick Commands

**Full check:**
```bash
# Run all performance checks
npm run perf:check
```

**Bundle only:**
```bash
npm run build
npm run analyze
```

**Backend only:**
```bash
php artisan test --profile
# Check Debugbar for query metrics
```

---

## 📊 Budgets Reference

| Layer | Metric | Budget | Severity |
|-------|--------|--------|----------|
| **Frontend** | Main bundle | 200KB | error |
| **Frontend** | LCP | 2.5s | error |
| **Frontend** | Lighthouse | 90 | error |
| **Backend** | API p95 | 200ms | error |
| **Backend** | Query count | 10 | error |
| **Inertia** | Props size | 100KB | warning |

**Full config:** `.agent/performance-budgets.yml`

---

## 🔗 References

- [performance-budgets.yml](file:///.agent/performance-budgets.yml)
- [laravel-performance skill](file:///.agent/skills/laravel-performance/SKILL.md)
- [react-performance skill](file:///.agent/skills/react-performance/SKILL.md)
- [inertia-performance skill](file:///.agent/skills/inertia-performance/SKILL.md)

---

**Created:** 2026-01-19  
**Industry Standard:** Google Lighthouse CI, Vercel Analytics  
**Impact:** Zero performance regressions

---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| Lỗi không xác định hoặc crash | Bật chế độ verbose, kiểm tra log hệ thống, cắt nhỏ phạm vi debug |
| Thiếu package/dependencies | Kiểm tra file lock, chạy lại npm/composer install |
| Xung đột context API | Reset session, tắt các plugin/extension không liên quan |
| Thời gian chạy quá lâu (timeout) | Cấu hình lại timeout, tối ưu hóa các queries nặng |




# Branching Strategy — Git Workflow Chuẩn

**Version:** 5.0.0  
**Last Updated:** 2026-02-27

---

## Overview

Antigravity-Core sử dụng **GitHub Flow + Release Branches** — đơn giản, phù hợp AI-native development, hỗ trợ CI/CD tự động.

---

## Branch Types

| Branch | Pattern | Mục đích | Lifetime |
|--------|---------|----------|----------|
| `main` | `main` | Production-ready code. Luôn deployable | Permanent |
| Feature | `feature/<ticket>-<mô-tả>` | Phát triển tính năng mới | Merge xong → xóa |
| Bugfix | `bugfix/<ticket>-<mô-tả>` | Sửa bug từ backlog | Merge xong → xóa |
| Hotfix | `hotfix/<ticket>-<mô-tả>` | Sửa lỗi production khẩn | Merge xong → xóa |
| Release | `release/v<X.Y.Z>` | Chuẩn bị release (freeze features) | Tag xong → xóa |

---

## Naming Convention

```
✅ ĐÚNG:
feature/US-042-user-authentication
bugfix/BUG-108-login-redirect-loop
hotfix/HOT-003-payment-crash
release/v2.1.0

❌ SAI:
feature/new-stuff          ← Thiếu ticket ID
fix                        ← Không rõ mục đích
my-branch                  ← Không theo convention
```

---

## Workflow Diagram

```
main ──────────────────────────────────────────────────►
  │                                              ▲
  ├── feature/US-042-auth ──── PR ── Review ──── Merge
  │                                              ▲
  ├── bugfix/BUG-108-redirect ── PR ── Review ── Merge
  │                                              ▲
  └── hotfix/HOT-003-crash ──── PR (fast) ────── Merge
```

---

## Rules

### 1. Main Branch Protection
- **KHÔNG commit trực tiếp vào `main`** — luôn qua PR
- Require **1+ approval** trước khi merge
- Require **CI checks pass** (lint, type, test, security)
- Squash merge preferred (clean history)

### 2. Feature Branch Rules
```bash
# Tạo từ main
git checkout main && git pull
git checkout -b feature/US-042-user-authentication

# Phát triển + commit (conventional commits)
git commit -m "feat(auth): implement login flow"
git commit -m "test(auth): add login unit tests"

# Push + tạo PR
git push -u origin feature/US-042-user-authentication
# → Tạo PR trên GitHub/GitLab
```

### 3. Conventional Commits
```
feat:     Tính năng mới
fix:      Sửa bug
docs:     Chỉ thay đổi documentation
style:    Formatting (không thay đổi logic)
refactor: Refactor code (không thay đổi behavior)
test:     Thêm/sửa tests
chore:    Build, CI, dependencies
perf:     Cải thiện performance
```

**Format:** `<type>(<scope>): <description>`

### 4. Hotfix Process
```bash
# Tạo từ main (khẩn cấp)
git checkout main && git pull
git checkout -b hotfix/HOT-003-payment-crash

# Fix nhanh + test
# ...

# PR với label "hotfix" — bypass full review nếu P0
git push -u origin hotfix/HOT-003-payment-crash
```

**Hotfix PR yêu cầu tối thiểu:**
- [ ] Fix verified locally
- [ ] Unit test cho bug
- [ ] 1 reviewer (có thể self-approve nếu P0 after-hours)
- [ ] CI pass

### 5. Release Process
```bash
# Tạo release branch
git checkout -b release/v2.1.0

# Bump version
.\.agent\scripts\bump-version.ps1 -Version "2.1.0"

# Final testing + fixes (chỉ bugfix, không feature mới)
# ...

# Merge to main + tag
git checkout main && git merge release/v2.1.0
git tag v2.1.0
git push origin main --tags

# Cleanup
git branch -d release/v2.1.0
```

---

## Pre-Merge Checklist (All PRs)

```
✅ /auto-healing           → Lint & type errors fixed
✅ /check                  → AI code review passed
✅ /test                   → All tests passing
✅ /secret-scanning        → No secrets in code
✅ Conventional commit messages
✅ PR description clear (What + Why + How)
✅ No conflicts with main
```

---

> **See also:** [Daily Development](./DAILY-DEVELOPMENT.md) | [Code Review Process](./CODE-REVIEW-PROCESS.md) | [Deployment Process](./DEPLOYMENT-PROCESS.md)

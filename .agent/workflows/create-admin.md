---
description: Tạo SaaS Admin Starter Kit with Auth & RBAC cho dự án mới
---

# /create-admin — SaaS Admin Starter Kit Generator

// turbo-all

Tự động tạo hệ thống admin hoàn chỉnh với Auth + RBAC cho bất kỳ framework nào.

**Khi nào dùng:** Dự án mới cần admin panel, user yêu cầu "tạo admin/login/build admin panel", chưa có Auth + RBAC.

---

## Workflow Steps

### Step 1: Detect Framework & Mode

```
Framework (auto-detect):
├── package.json + "next"                        → Next.js
├── composer.json + "laravel" + "react"           → Laravel + Inertia
├── composer.json + "laravel"                     → Laravel Blade
├── package.json + "express"                      → Express + EJS
├── *.csproj + "Microsoft.AspNet"                 → ASP.NET Core
└── Không detect được                            → HỎI USER

Mode (from .env or ask):
├── MODE=saas       → Multi-tenant (7 roles: saasOwner...siteViewer)
├── MODE=standalone → Single-tenant (5 roles: siteOwner...siteViewer)
└── Không có        → HỎI USER
```

**Agent:** `project-planner`

---

### Step 2: Load References (parallel)

Đọc **3 files cùng lúc** từ `.agent/skills/velzon-admin/reference/`:

1. **`saas-admin-starter.md`** — Master blueprint (single source of truth)
2. **Framework pattern file** — Auth section tương ứng:

   | Framework | File |
   |-----------|------|
   | Next.js | `nextjs-patterns.md` |
   | Laravel + Inertia | `inertia-bridge.md` |
   | Laravel Blade | `html-php-patterns.md` |
   | Express + EJS | `nodejs-patterns.md` |
   | ASP.NET Core | `aspnet-mvc-patterns.md` |

3. **`auth-login-template.md`** — Design tokens, CSS, glassmorphism components

---

### Step 3: Generate Files

**Agent:** Framework specialist (`frontend-specialist` / `backend-specialist`)

Theo thứ tự:

1. **Database** — Schema/migration (roles, permissions, pivots)
2. **Models** — User (extended), Role, Permission
3. **Seed** — Roles + permissions (mode-aware) + top-level admin user
4. **Auth** — 5 screens (Login, Forgot, Reset, 2FA, Logout)
5. **Middleware** — Auth guard + RBAC permission guard
6. **Admin Layout** — Sidebar (permission-filtered), Header, Footer
7. **Dashboard** — Stat widgets + welcome card + activity log
8. **User Management** — List, Create, Edit, Invite, Delete
9. **Role Management** — List, Edit (permission matrix)
10. **Error Pages** — 403, 404, 500
11. **i18n** — Translation keys for auth + admin
12. **Config** — Admin prefix, app settings

---

### Step 4: Verify

```bash
# Lint + Build + Dev
npm run lint && npm run build && npm run dev  # or framework equivalent
```

**Checklist (from blueprint §14):**
- [ ] All 5 auth screens render with glassmorphism
- [ ] Seed runs (correct roles by mode + permissions + admin user)
- [ ] Login works with `admin@example.com` / `password`
- [ ] Sidebar filtered by permissions AND mode
- [ ] Users CRUD + Invite functional
- [ ] Permission matrix saves correctly

**Agent:** `debugger`

> **Sau khi hoàn tất:** Dùng `/admin-dashboard` để thêm trang quản lý mới (CRUD, dashboard, kanban, etc.)

---

## Error Handling

| Situation | Action |
|-----------|--------|
| Framework not detected | Ask user to specify |
| Database not configured | Setup DB first (sqlite dev, postgres prod) |
| Existing auth found | Ask: "Integrate or replace?" |

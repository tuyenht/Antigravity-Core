---
description: "Khởi tạo nhanh Admin Starter Kit (SaaS/Standalone) kèm Auth và phân quyền."
---

# /create-admin — Admin Starter Kit Generator

// turbo-all

Tự động tạo hệ thống admin hoàn chỉnh với Auth + RBAC cho bất kỳ framework nào.
Hỗ trợ 2 chế độ: **SaaS** (multi-tenant, 7 roles) và **Standalone** (single-tenant, 5 roles).

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
**Skills:** `velzon-admin, app-builder, database-design`

---

### Step 2: Component Readiness Check

> [!IMPORTANT]
> Mỗi trang tạo ra **PHẢI kế thừa** shared Layouts & Components. Không tạo lại những gì đã có.

**Scan thư mục dự án** để kiểm tra tính sẵn sàng:

```
Layouts/ (REQUIRED — mọi trang admin wrap trong Layout)
├── index.tsx          ← Main Layout: Header + Sidebar + {children} + Footer + RightSidebar
├── Header.tsx         ← Search, hamburger, lang, fullscreen, light/dark, notifications, profile
├── Sidebar.tsx        ← Permission-filtered menu (LayoutMenuData.tsx)
├── Footer.tsx         ← Copyright footer
├── LayoutMenuData.tsx ← Menu items config
├── GuestLayout.tsx    ← Auth pages (login, forgot, reset, 2FA)
├── VerticalLayouts/   ← Default sidebar layout
├── HorizontalLayout/  ← Top nav layout
└── TwoColumnLayout/   ← Two-column sidebar layout

Components/Common/ (REQUIRED — reuse, không tạo mới)
├── BreadCrumb.tsx           ← Page breadcrumb
├── RightSidebar.tsx         ← Theme Customizer (gear icon, slide-out panel)
├── SearchOption.tsx         ← Global search
├── LanguageDropdown.tsx     ← Language switcher
├── LightDark.tsx            ← Dark/light mode toggle
├── FullScreenDropdown.tsx   ← Fullscreen button
├── NotificationDropdown.tsx ← Notifications bell
├── ProfileDropdown.tsx      ← User profile menu
├── TableContainer.tsx       ← TanStack React Table wrapper
├── DeleteModal.tsx          ← Delete confirmation modal
├── Pagination.tsx           ← Table pagination
├── ExportCSVModal.tsx       ← CSV export modal
├── Loader.tsx               ← Loading spinner
└── Spinner.tsx              ← Button spinner
```

**Quy tắc:**
1. **Nếu Components/Layouts ĐÃ CÓ** → Import và sử dụng trực tiếp, KHÔNG tạo lại
2. **Nếu CHƯA CÓ** → Tạo mới theo pattern trong `reference/component-patterns.md`
3. **Mỗi trang admin** phải được wrap trong `<Layout>` → tự động có Header, Sidebar, Footer, RightSidebar
4. **Trang auth** (login, forgot, etc.) → dùng `GuestLayout` (KHÔNG có sidebar/header)

---

### Step 3: Load References (parallel)

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

### Step 4: Generate Files

**Agent:** Framework specialist (`frontend-specialist` / `backend-specialist`)

Theo thứ tự:

0. **Assets** — Copy `.agent/skills/velzon-admin/assets/images/` → project images dir (logos, favicon, flags, avatars, error images)
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

### Step 5: Verify

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


---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|  
| Framework không detect được | Kiểm tra config files (package.json, composer.json), specify thủ công |
| DB migration fails | Kiểm tra DB connection trong .env, đảm bảo DB service đang chạy |
| Auth login không hoạt động | Kiểm tra seed data (admin@example.com/password), verify middleware config |
| Sidebar menu không hiện | Kiểm tra LayoutMenuData.tsx, verify permission seeding |
| RBAC permission denied sai | Kiểm tra pivot table roles_permissions, reset cache: `php artisan cache:clear` |
| Glassmorphism auth không hiển thị | Kiểm tra CSS imports, verify GuestLayout wraps auth pages |
| SaaS vs Standalone confusion | Kiểm tra `MODE` trong .env, re-run seeder cho đúng mode |




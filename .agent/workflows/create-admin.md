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

**AUTO-CONTEXT (trước khi detect):**
Đọc `docs/PROJECT-BRIEF.md` nếu tồn tại → lấy:
- Admin prefix route (default: admin)
- Roles & permissions model
- i18n requirements (ngôn ngữ hỗ trợ)
- Design system preference
- Tech stack (skip auto-detect nếu đã biết)

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
├── BackToTop.tsx            ← Back-to-top button (#back-to-top)
├── Preloader.tsx            ← Page preloader (#preloader)
├── LiveClock.tsx            ← Footer live clock (dd/MM/yyyy HH:mm:ss, setInterval 1000ms)
├── TableContainer.tsx       ← TanStack React Table wrapper
├── DeleteModal.tsx          ← Delete confirmation modal
├── Pagination.tsx           ← Table pagination
├── ExportCSVModal.tsx       ← CSV export modal
├── Loader.tsx               ← Loading spinner
└── Spinner.tsx              ← Button spinner

Context/ (REQUIRED for Next.js — thay Redux)
├── LayoutContext.tsx        ← Theme state (13 dimensions, sessionStorage persist)
└── LocaleContext.tsx        ← i18n locale state
```

**Quy tắc:**
1. **Nếu Components/Layouts ĐÃ CÓ** → Import và sử dụng trực tiếp, KHÔNG tạo lại
2. **Nếu CHƯA CÓ** → Tạo mới theo pattern trong `reference/component-patterns.md`
3. **Mỗi trang admin** phải được wrap trong `<Layout>` → tự động có Header, Sidebar, Footer, RightSidebar
4. **Trang auth** (login, forgot, etc.) → dùng `GuestLayout` (KHÔNG có sidebar/header)

---

### Step 3: Load References (parallel)

Đọc **5 files cùng lúc** từ `.agent/skills/velzon-admin/reference/`:

1. **`saas-admin-starter.md`** — Master blueprint (single source of truth)
2. **Framework pattern file** — Auth section tương ứng:

   | Framework | File |
   |-----------|------|
   | Next.js | `nextjs-patterns.md` |
   | Laravel + Inertia | `inertia-bridge.md` |
   | Laravel Blade | `html-php-patterns.md` |
   | Express + EJS | `nodejs-patterns.md` |
   | ASP.NET Core | `aspnet-mvc-patterns.md` |

3. **`auth-login-template.md`** — Design tokens, CSS, glassmorphism auth components
4. **`admin-shell-template.md`** — Dashboard shell: Header (6 dropdowns), Sidebar (multi-level), Theme Customizer (PRUNED)
5. **`env-template.md`** — `.env.example` defaults (BCRYPT_ROUNDS, ADMIN_PREFIX, session/cache/mail)
6. **`source/auth-css/auth.css`** — Self-contained CSS for auth login (glassmorphism, gradient, glass card)
7. **`source/html-canonical/auth-login.html`** — Canonical DOM reference for auth login (used by non-React frameworks)
8. **`source/react-ts/auth/*`** — React/Next.js auth components (IF framework is React-based)

---

### Step 4: Generate Files

**Agent:** Framework specialist (`frontend-specialist` / `backend-specialist`)

> [!CAUTION]
> **NEXT.JS: XÓA ROOT `app/` DIRECTORY — BẮT BUỘC**
> `create-next-app` tạo thư mục `app/` ở **root dự án** (chứa page.tsx mặc định).
> Workflow này tạo files trong `src/app/`. Nếu cả hai tồn tại, Next.js dùng root `app/` (ưu tiên cao hơn) → **mọi route trong `src/app/` bị bỏ qua** → 404.
>
> **PHẢI thực hiện SAU `create-next-app` init và TRƯỚC khi tạo files:**
> ```powershell
> # Xóa root app/ directory (default create-next-app)
> Remove-Item ./app -Recurse -Force -ErrorAction SilentlyContinue
> # Xóa cache Turbopack (nếu đã chạy dev trước đó)
> Remove-Item ./.next -Recurse -Force -ErrorAction SilentlyContinue
> ```
>
> **Không làm bước này = toàn bộ route admin 404, trang chủ hiện "To get started, edit the page.tsx file".**

Theo thứ tự:

0. **Assets** — Copy `.agent/skills/velzon-admin/assets/` → project public dir. Gồm 3 thư mục: `css/` (app, bootstrap, icons, fonts.css), `fonts/` (11 woff2 files: Inter, NotoSans CJK, RemixIcon, MDI, Boxicons, Line Awesome), `images/` (logos, favicon, flags, avatars).

    > [!CAUTION]
    > **Images MUST go to `public/assets/images/`** (NOT `public/images/`).
    > `admin-shell.html` references `assets/images/logo-sm.png` — wrong path = **broken logos**.
    > Same applies to flags: `public/assets/images/flags/` for language switcher.
1. **COPY BỘ KHUNG VELZON** — Copy layout shell from `velzon-admin/source/`:

    > [!CAUTION]
    > **🚫 COPY, NOT REGENERATE — NGUYÊN TẮC TỐI THƯỢNG**
    > - ❌ **CẤM** viết component từ đầu khi source template đã có sẵn
    > - ❌ **CẤM** dùng inline `style={{}}` cho layout components — PHẢI dùng Velzon CSS classes
    > - ❌ **CẤM** tự phát minh CSS class mới khi Velzon CSS đã có
    > - ❌ **CẤM** bỏ bất kỳ CSS class nào từ source template (vd: `material-shadow-none`, `btn-ghost-secondary`)
    > - ❌ **CẤM** thay đổi DOM structure (vd: bỏ `.navbar-header`, thay `d-flex` bằng inline flex)
    > - ✅ **BẮT BUỘC** đọc source template → copy → adapt MINIMAL changes (xem Adaptation Rules bên dưới)

    - **ALWAYS copy:** `source/scss/` → project SCSS dir (design tokens, colors, dark mode)
    - **IF React / Next.js / Inertia+React:**
      - Copy `source/react-ts/layouts/` → Header, Sidebar, Footer, index (Layout wrapper)
      - Copy `source/react-ts/header-components/` → 6 Topbar dropdowns (Search, Language, FullScreen, DarkMode, Notifications, Profile)
      - Copy `source/react-ts/theme-customizer/` → RightSidebar (125KB, 13 options)
      - Copy `source/react-ts/common/` → BreadCrumb, BackToTop, Preloader
      - Copy `source/react-ts/slices/layouts/` → Redux layout state (CRA/Vite) hoặc convert to Context (Next.js)
      - Copy `source/react-ts/dashboard/` → DashboardPage, StatCard, WelcomeBanner, RecentActivity
      - **Create** `LiveClock.tsx` → Footer real-time clock (`dd/MM/yyyy HH:mm:ss`, `setInterval(1000)`)

    **🔄 NEXT.JS ADAPTATION RULES (chỉ thay đổi ĐÚNG những gì cần thiết):**

    | Thay đổi | CRA/Vite (giữ nguyên) | Next.js (adapt) |
    |----------|-----------------------|-----------------|
    | Imports | `react-router-dom` | `next/navigation`, `next/link`, `next/image` |
    | State | Redux Toolkit | React Context + `sessionStorage` |
    | Routing | `<Link to="/">` | `<Link href="/">` |
    | Images | `import img from "./path"` | `<Image src="/images/..." />` or `<img src="/images/..." />` |
    | Directive | không cần | Thêm `'use client';` đầu file |
    | **CSS classes** | **GIỮ NGUYÊN 100%** | **GIỮ NGUYÊN 100%** |
    | **DOM structure** | **GIỮ NGUYÊN 100%** | **GIỮ NGUYÊN 100%** |
    | **Icon classes** | **GIỮ NGUYÊN 100%** | **GIỮ NGUYÊN 100%** |
    | **data-* attributes** | **GIỮ NGUYÊN 100%** | **GIỮ NGUYÊN 100%** |
    | **Reactstrap imports** | **GIỮ NGUYÊN** | **GIỮ NGUYÊN** (install reactstrap) |

    - **IF Vue / Laravel / PHP / Node / ASP.NET / ANY other framework:**
      - Read `source/html-canonical/*` as DOM reference
      - Convert to framework syntax (Blade/EJS/Razor/Vue `<template>`)
      - **MUST preserve:** CSS classes, DOM nesting, `--vz-*` variables
    - **Invariance rules:** sidebar dark (#405189), topbar dropdown order (Search→Language→FullScreen→DarkMode→Notifications→Profile), menu category structure, 3 LOCKED values (`data-theme="default"`, `data-layout-width="fluid"`, `data-layout-style="default"`)
    - Nội dung bên trong → tạo mới theo `reference/component-patterns.md`

    > [!WARNING]
    > **CSS FOUNDATION (BẮT BUỘC — THIẾU = GIAO DIỆN VỠ):**
    > - Copy compiled CSS: `bootstrap.min.css`, `app.min.css`, `custom.min.css`, `icons.min.css`
    >   - FROM: `.agent/skills/velzon-admin/assets/css/`
    >   - TO: `public/assets/css/`
    > - Root layout PHẢI import CSS theo thứ tự: bootstrap → icons → app → custom → fonts
    > - PHẢI import `fonts.css` cho @font-face (Inter + CJK web fonts)
    > - PHẢI import icon fonts: BoxIcons, Remix Icons, MDI, Line Awesome
    >   (Đã nằm trong `icons.min.css` của Velzon)
    > - **`layout.js` PHẢI load trong `<head>` TRƯỚC CSS** (FOUC prevention)

    > [!CAUTION]
    > **PERSISTENCE: sessionStorage KHÔNG PHẢI localStorage**
    > - Velzon HTML gốc dùng `sessionStorage` (confirm: `layout.js` source)
    > - LayoutContext/Redux PHẢI dùng `sessionStorage` cho 14 data-* attributes
    > - Xem chi tiết: `admin-shell-template.md` § Theme Customizer (LOCKED values + Pruning spec)

    > [!IMPORTANT]
    > **15-POINT VISUAL PARITY CHECK — VERIFICATION REFERENCE:**
    > After shell generation, use 15-point checklist from `implementation_plan.md`
    > for pixel-perfect verification. Includes locked values + customizer pruning checks.

> [!CAUTION]
> **BẮT BUỘC tạo TẤT CẢ các component sau (theo `admin-shell-template.md`):**
> - Header.tsx với ĐẦY ĐỦ: Hamburger toggle, SearchOption, LanguageDropdown, LightDark, FullScreenDropdown, NotificationDropdown, ProfileDropdown
> - Sidebar.tsx với multi-level menu, smooth accordion, active glow, badges, permission filtering
> - RightSidebar.tsx (Theme Customizer) với floating gear icon + drawer panel
> - Layout state management (Context cho Next.js, Redux cho CRA/Vite)
>
> ❌ **CẤM** tạo monolith AdminLayout.tsx đơn giản. Mỗi component PHẢI là file riêng.
> ❌ **CẤM** bỏ qua bất kỳ dropdown nào trong Header.
> ✅ **BẮT BUỘC** đọc `source/html-canonical/admin-shell.html` làm PRIMARY SOURCE trước khi tạo.
> ✅ **3 LOCKED values**: `data-theme="default"`, `data-layout-width="fluid"`, `data-layout-style="default"`
> ✅ **PRUNE RightSidebar.tsx**: Remove Theme selector, Boxed width, Compact sidebar, Sidebar View sections.
>    Customizer footer = Reset + Close (i18n `data-key="t-reset"`, `data-key="t-close"`). Buy Now REMOVED.

1.5. **COPY AUTH LOGIN** — Copy auth login from `velzon-admin/source/`:

    > [!CAUTION]
    > **🚫 AUTH LOGIN: COPY, NOT REGENERATE**
    > - ❌ **CẤM** viết auth form từ đầu khi source template đã có sẵn
    > - ❌ **CẤM** dùng Bootstrap/Velzon classes (`.form-control`, `.btn-success`) cho login page
    > - ❌ **CẤM** bỏ language switcher, social buttons, glassmorphism, hoặc bất kỳ element nào
    > - ❌ **CẤM** thay đổi CSS classes từ source files
    > - ❌ **CẤM** tạo "Welcome Back!" style login (đó là Velzon default — KHÔNG PHẢI design chuẩn)
    > - ✅ **BẮT BUỘC** copy source files → adapt MINIMAL changes (import paths, admin prefix)
    > - ✅ **BẮT BUỘC** import `auth.css` cho styling (self-contained, không cần Tailwind/Bootstrap)

    **Design Origin:** Form login là thiết kế riêng của BaoSon — KHÔNG phải Velzon default.
    **Golden Standard:** `baoson-platform-core` (`http://localhost:8000/bsadm/login`).

    - **ALWAYS copy:** `source/auth-css/auth.css` → project CSS dir (styling foundation)

    > [!IMPORTANT]
    > `auth.css` imports `fonts.css` via `@import './fonts.css'`. Khi deploy, cả 2 file nằm cùng thư mục css:
    > ```
    > public/assets/css/fonts.css   ← Global Font System (from assets/css/)
    > public/assets/css/auth.css    ← Auth UI (from source/auth-css/)
    > public/assets/fonts/          ← ALL font files (from assets/fonts/) — 11 woff2 files
    > ```
    > `fonts.css` dùng `url("../fonts/...")` — relative path trỏ lên thư mục `fonts/` cùng cấp.
    > CJK fonts chỉ download khi trang có ký tự JP/KO/ZH (via unicode-range).
    - **IF React / Next.js / Inertia+React:**
      - Copy `source/react-ts/auth/*` → project auth components dir
      - Adapt: import paths, `ADMIN_PREFIX`, routing (`next/link` vs `react-router`)
      - Files: `AuthLayout.tsx`, `LoginForm.tsx`, `Input.tsx`, `LanguageSwitcher.tsx`, `SocialButton.tsx`, `LocaleContext.tsx`
    - **IF Vue / Nuxt:**
      - Read `source/html-canonical/auth-login.html` → convert DOM to `<template>` syntax
      - **MUST preserve:** ALL CSS classes, DOM nesting, SVG icons
    - **IF Laravel / Blade:**
      - Read `source/html-canonical/auth-login.html` → convert to `@extends`/`@section`
      - **MUST preserve:** ALL CSS classes, DOM nesting, SVG icons
    - **IF Express / EJS / Node.js:**
      - Read `source/html-canonical/auth-login.html` → convert to `<%- include() %>` partials
      - **MUST preserve:** ALL CSS classes, DOM nesting, SVG icons
    - **IF ASP.NET / Razor:**
      - Read `source/html-canonical/auth-login.html` → convert to `@RenderSection`/Partial
      - **MUST preserve:** ALL CSS classes, DOM nesting, SVG icons
    - **IF HTML / PHP (static):**
      - Direct copy `source/html-canonical/auth-login.html` → adapt `<?php ?>` variables

    **INVARIANCE RULES (áp dụng mọi framework):**
    - CSS file (`auth.css`): copy **NGUYÊN VẸN**, KHÔNG sửa
    - CSS classes trên HTML elements: **KHÔNG thay đổi**
    - SVG icons (User, Lock, Eye, Arrow, Google, Facebook): **KHÔNG thay đổi**
    - DOM nesting structure: **KHÔNG thay đổi**
    - Chỉ thay đổi: syntax (`class`→`className`, `href`→`:href`, `{var}`→`{{ $var }}`)

    > [!CAUTION]
    > **🚫 TAILWIND DETECTION — AUTH CSS GOLDEN STANDARD ENFORCEMENT**
    >
    > **KIỂM TRA TRƯỚC KHI SINH AUTH COMPONENTS:**
    > ```
    > Tailwind installed? (kiểm tra package.json + globals.css)
    > ├── YES (có @import "tailwindcss" trong globals.css) → Tailwind classes OK
    > └── NO  (Next.js standalone mặc định KHÔNG có)   → auth.css classes ONLY
    > ```
    >
    > **Khi project KHÔNG có Tailwind** (trường hợp phổ biến nhất):
    > - ❌ **CẤM** dùng BẤT KỲ Tailwind utility class nào (`flex`, `bg-gradient-to-br`, `rounded-xl`...)
    > - ❌ **CẤM** dùng inline `style={{}}` để thay thế Tailwind
    > - ✅ **BẮT BUỘC** dùng auth.css classes: `auth-bg`, `auth-glass`, `auth-title`, `auth-form`, v.v.
    > - ✅ **BẮT BUỘC** verify `<link rel="stylesheet" href="/assets/css/auth.css" />` trong root `layout.tsx`
    >
    > Source files tại `source/react-ts/auth/*.tsx` đã dùng auth.css classes sẵn.
    > **COPY NGUYÊN VẸN — KHÔNG REWRITE.**

    > [!IMPORTANT]
    > **TAILWIND v4 — BẮT BUỘC MERGE @theme COLOR TOKENS:**
    > - Nếu dự án dùng Tailwind v4 (nhận biết: `@import "tailwindcss"` trong globals.css,
    >   KHÔNG có file `tailwind.config.js/ts`):
    > - **PHẢI** đọc `source/auth-css/auth-theme.css` → merge `@theme` block vào `globals.css`
    > - Thiếu bước này → `from-sky-700`, `bg-slate-900/30`, `text-blue-700` sẽ **KHÔNG generate CSS**
    >   → gradient background nhạt, language switcher mất glass effect, title mất gradient text
    > - File `auth-theme.css` chứa **18 color tokens** (sky, blue, slate, cyan, red, green)
    >   đã được map 1:1 với mọi Tailwind class trong auth components
    > - **ZERO runtime cost** — chỉ ảnh hưởng CSS build time

2. **Root page.tsx** — Overwrite `src/app/page.tsx` (mặc định của `create-next-app`) bằng redirect tới admin dashboard:
    ```tsx
    // src/app/page.tsx — OVERWRITE default Next.js page
    import { redirect } from 'next/navigation';
    import { ADMIN_PREFIX } from '@/config/admin';
    export default function Home() {
      redirect(`/${ADMIN_PREFIX}/dashboard`);
    }
    ```
    > ⚠️ Nếu KHÔNG overwrite, truy cập `/` sẽ hiển thị trang mặc định "To get started, edit the page.tsx file".
2. **Database** — Schema/migration (roles, permissions, pivots)
3. **Models** — User (extended), Role, Permission
4. **Seed** — Roles + permissions (mode-aware) + top-level admin user
5. **Auth** — 5 screens (Login, Forgot, Reset, 2FA, Logout)
6. **Proxy** — Auth guard + RBAC permission guard (Next.js 16: `proxy.ts`)
7. **Admin Layout** — Sidebar (permission-filtered), Header, Footer
8. **Dashboard** — Stat widgets + welcome card + activity log
9. **User Management** — List, Create, Edit, Invite, Delete
10. **Role Management** — List, Edit (permission matrix)
11. **Error Pages** — 403, 404, 500
12. **i18n** — Translation keys for auth + admin
13. **Config** — Admin prefix, app settings
14. **`.env.example`** — Environment config from `env-template.md` (BCRYPT_ROUNDS=12, ADMIN_PREFIX, DB, session, mail)

---

### Step 5: Verify

```bash
# Lint + Build + Dev
pnpm lint && pnpm build && pnpm dev  # or framework equivalent
```

**Checklist (from blueprint §14 + admin-shell-template.md):**
- [ ] All 5 auth screens render with glassmorphism (from `auth-login-template.md`)
- [ ] Seed runs (correct roles by mode + permissions + admin user)
- [ ] Login works with `admin@example.com` / `password`
- [ ] Sidebar filtered by permissions AND mode
- [ ] Users CRUD + Invite functional
- [ ] Permission matrix saves correctly
- [ ] **Header has ALL 6 dropdowns**: Search, Language, FullScreen, LightDark, Notifications, Profile (~~WebApps~~, ~~Cart~~ REMOVED)
- [ ] **Sidebar toggle** collapses/expands sidebar
- [ ] **Multi-level menu** works with smooth accordion animation
- [ ] **Theme Customizer** gear icon visible, drawer opens with layout/color options
- [ ] **Dark/Light mode** toggle works correctly
- [ ] Profile dropdown shows user name + role + logout option
- [ ] **CSS FILES** imported: bootstrap.min.css + icons.min.css + app.min.css + custom.min.css + fonts.css (ORDER MATTERS)
- [ ] **layout.js** loaded in `<head>` BEFORE CSS (FOUC prevention)
- [ ] **AUTH.CSS** imported: `<link rel="stylesheet" href="/assets/css/auth.css" />` in root layout + fonts.css + fonts/ directory
- [ ] **AUTH COMPONENTS** use auth.css classes (NO Tailwind, NO inline styles): `auth-bg`, `auth-glass`, `auth-title`, `auth-form`, `auth-submit`, `auth-divider`
- [ ] **ICON FONTS** rendering correctly (no □ placeholders) — bx, ri, mdi, la
- [ ] **LTR OVERRIDES** in globals.css:
  ```css
  [dir=ltr] .app-menu { left: 0; }
  [dir=ltr] .main-content { margin-left: var(--vz-vertical-menu-width, 250px); }
  [dir=ltr] .vertical-menu-btn { margin-right: -2px; }
  ```
- [ ] **sessionStorage** used for layout persistence (NOT localStorage)
- [ ] **BackToTop** button present (#back-to-top, btn btn-danger btn-icon)
- [ ] **Preloader** present (conditional, #preloader)
- [ ] **BreadCrumb** present in page-content
- [ ] **LiveClock** in footer showing real-time `dd/MM/yyyy HH:mm:ss` (setInterval 1000ms)
- [ ] **Footer branding** = `© {year} COMPANY_NAME. All rights reserved.` + LiveClock (from config/admin.ts)
- [ ] **Header buttons** all have: btn-icon btn-topbar material-shadow-none btn-ghost-secondary rounded-circle
- [ ] **3 LOCKED values**: `data-theme="default"`, `data-layout-width="fluid"`, `data-layout-style="default"`
- [ ] **Customizer PRUNED**: No Theme selector, No Boxed, No Compact sidebar, No Sidebar View. Footer = Reset + Close (i18n)
- [ ] **Visual Parity**: 15-point checklist from implementation plan PASSED

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
| Trang `/` hiện template mặc định Next.js | **Xóa thư mục root `app/`** (tạo bởi `create-next-app`), nó override `src/app/`. Chạy: `Remove-Item ./app -Recurse -Force; Remove-Item ./.next -Recurse -Force` rồi restart dev server |
| Mọi route `/bsads/*` trả về 404 | Cùng nguyên nhân trên — root `app/` tồn tại song song với `src/app/`. Xóa root `app/` + clear `.next` cache |
| Port conflict (3001, 3002 thay vì 3000) | Có multiple node processes. Chạy: `taskkill /IM node.exe /F` rồi `pnpm dev` |
| DB migration fails | Kiểm tra DB connection trong .env, đảm bảo DB service đang chạy |
| Auth login không hoạt động | Kiểm tra seed data (admin@example.com/password), verify proxy config (`proxy.ts`) |
| Sidebar menu không hiện | Kiểm tra LayoutMenuData.tsx, verify permission seeding |
| RBAC permission denied sai | Kiểm tra pivot table roles_permissions, reset cache: `php artisan cache:clear` |
| Glassmorphism auth không hiển thị | Kiểm tra CSS imports, verify GuestLayout wraps auth pages. Nếu Tailwind v4: kiểm tra `@theme` color tokens trong globals.css |
| SaaS vs Standalone confusion | Kiểm tra `MODE` trong .env, re-run seeder cho đúng mode |




---
description: Tạo trang admin dashboard (Velzon)
---

# Admin Dashboard Page Builder

Build a new admin dashboard or management page using Velzon conventions.

> For full admin system (Auth + RBAC + Users + Dashboard), use `/create-admin` workflow instead.
> Blueprint: `.agent/skills/velzon-admin/reference/saas-admin-starter.md`

## Prerequisites
- Read the Velzon Admin skill: `.agent/skills/velzon-admin/SKILL.md`
- Identify the closest template page from `reference/page-catalog.md`

## Component Readiness Check (MANDATORY)

> [!IMPORTANT]
> Mỗi trang tạo ra **PHẢI kế thừa** shared Layouts & Components. Không tạo lại những gì đã có.

**Trước khi tạo trang mới**, scan thư mục dự án:

```
Layouts/ (kiểm tra sự tồn tại)
├── index.tsx          ← Main Layout: Header + Sidebar + {children} + Footer + RightSidebar
├── Header.tsx         ← Search, hamburger, lang, fullscreen, light/dark, notifications, profile
├── Sidebar.tsx        ← Permission-filtered menu
├── Footer.tsx         ← Copyright footer
├── LayoutMenuData.tsx ← Menu items config
└── VerticalLayouts/ | HorizontalLayout/ | TwoColumnLayout/

Components/Common/ (reuse, KHÔNG tạo mới)
├── BreadCrumb.tsx, TableContainer.tsx, DeleteModal.tsx
├── RightSidebar.tsx (Theme Customizer), Pagination.tsx
├── SearchOption.tsx, LanguageDropdown.tsx, LightDark.tsx
├── FullScreenDropdown.tsx, NotificationDropdown.tsx, ProfileDropdown.tsx
└── Loader.tsx, Spinner.tsx, ExportCSVModal.tsx
```

**Quy tắc:**
1. **ĐÃ CÓ** → Import trực tiếp, KHÔNG duplicate
2. **CHƯA CÓ** → Tạo mới theo `reference/component-patterns.md`
3. Trang mới **wrap trong `<Layout>`** → tự động có Header, Sidebar, Footer, RightSidebar

## Steps

### 0. Detect Variant
Determine which Velzon variant to use based on the project:
- `composer.json` + `inertiajs` → **React+Inertia** → read `reference/inertia-bridge.md`
- `next.config.js` → **Next-TS** → read `reference/nextjs-patterns.md`
- `app.js` + `express` + `.ejs` views → **Node.js** → read `reference/nodejs-patterns.md`
- `.csproj` + `Program.cs` + `.cshtml` views → **ASP.NET Core** → read `reference/aspnet-mvc-patterns.md`
- `index.html` + AJAX nav + HTML fragments → **Ajax** → read `reference/ajax-patterns.md`
- `composer.json` + Blade views → **Laravel** → read `reference/html-php-patterns.md`
- `gulpfile.js` → **HTML** → read `reference/html-php-patterns.md`
- Default → **React-TS** (use core skill patterns)
- For asset recreation: always read `reference/asset-catalog.md`

### 1. Identify Page Type
Determine what kind of admin page is needed:
- **Dashboard** → Stats widgets + charts + tables
- **CRUD List** → Data table with search, sort, pagination, actions
- **CRUD Detail** → Detail view with info panels
- **CRUD Form** → Create/Edit form with validation
- **Kanban** → Drag-and-drop board

### 2. Reference Closest Template
Map the request to the closest Velzon template page:
- Dashboard overview → `DashboardEcommerce` or `DashboardAnalytics`
- CRUD list with table → `CrmContacts` or `EcommerceOrders`
- Detail view → `EcommerceProductDetail` or `InvoiceDetails`
- Create/Edit form → `EcommerceAddProduct` or `CreateProject`
- Card grid list → `EcommerceProducts` or `EcommerceSellers`

Read the skill reference files for detailed patterns.

### 3. Create Page + Sub-Components

// turbo

**Agent:** `frontend-specialist`  
**Skills:** `velzon-admin, frontend-design, ui-ux-pro-max`
Create the page file following the **detected variant's** page structure pattern:

| Variant | Page Location | Pattern Reference |
|---------|---------------|-------------------|
| **React-TS / Inertia** | `src/pages/{Module}/{Page}.tsx` | `component-patterns.md` §19 |
| **Next-TS** | `app/admin/{module}/page.tsx` | `nextjs-patterns.md` |
| **Node.js (EJS)** | `views/admin/{module}/index.ejs` | `nodejs-patterns.md` |
| **Laravel Blade** | `resources/views/admin/{module}/index.blade.php` | `html-php-patterns.md` |
| **ASP.NET Core** | `Views/Admin/{Module}/Index.cshtml` | `aspnet-mvc-patterns.md` |
| **Ajax** | `partials/{module}.html` | `ajax-patterns.md` |

For dashboard pages, create sub-components per section:
- Stat widgets (CountUp cards) → `component-patterns.md` §3
- Charts (ApexCharts) → `component-patterns.md` §9
- Tables (TableContainer) → `component-patterns.md` §2
- Activity sidebar → `dashboard-patterns.md` § Activity Sidebar

### 4. Wire State Management

// turbo

**Agent:** `frontend-specialist`  
**Skills:** `velzon-admin, frontend-design, ui-ux-pro-max`
Follow the state management pattern for the detected variant:

| Variant | Pattern | Reference |
|---------|---------|-----------|
| **React-TS / Inertia** | Redux Toolkit: `slices/{module}/reducer.ts` + `thunk.ts` | `dashboard-patterns.md` § Redux |
| **Next-TS** | Server Components + React hooks, or Redux if complex | `nextjs-patterns.md` |
| **Node.js (EJS)** | Server-side data via controller, pass to template | `nodejs-patterns.md` |
| **Laravel Blade** | Blade `@props` / Controller → View | `html-php-patterns.md` |
| **ASP.NET Core** | ViewModel → View | `aspnet-mvc-patterns.md` |

### 5. Register Route + Menu

// turbo

**Agent:** `frontend-specialist`  
**Skills:** `velzon-admin, frontend-design, ui-ux-pro-max`
Add route and sidebar menu item following the detected variant's conventions:

| Variant | Route File | Menu File |
|---------|------------|-----------|
| **React-TS** | `Routes/allRoutes.tsx` | `Layouts/LayoutMenuData.tsx` |
| **Next-TS** | File-based routing (automatic) | Sidebar config |
| **Inertia** | `routes/web.php` | `Layouts/LayoutMenuData.tsx` |
| **Node.js** | `routes/admin.js` | Menu config |
| **Laravel Blade** | `routes/web.php` | Blade partial |
| **ASP.NET Core** | `Program.cs` / Controller routing | `_Layout.cshtml` nav |

### 6. Verify
- Check page renders correctly at the registered route
- Verify breadcrumb shows correct title/category
- Confirm sidebar menu item appears and highlights
- Test search/filter/pagination if applicable
- Verify dark mode and responsive behavior



---

##  Admin Dashboard Checklist

- [ ] Prerequisites and environment verified
- [ ] All workflow steps executed sequentially
- [ ] Expected output validated against requirements
- [ ] No unresolved errors or warnings in tests/logs
- [ ] Related documentation updated if impact is systemic

---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| Lỗi không xác định hoặc crash | Bật chế độ verbose, kiểm tra log hệ thống, cắt nhỏ phạm vi debug |
| Thiếu package/dependencies | Kiểm tra file lock, chạy lại npm/composer install |
| Xung đột context API | Reset session, tắt các plugin/extension không liên quan |
| Thời gian chạy quá lâu (timeout) | Cấu hình lại timeout, tối ưu hóa các queries nặng |

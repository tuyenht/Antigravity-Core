# Component Registry — Velzon Admin v4.4.1

> **Source of truth** for all shared components across 11 Velzon variants.
> Read this file BEFORE creating any admin page to know **what to create, what to reuse, and where to put it**.

---

## §1 — Template Families

> [!IMPORTANT]
> Velzon has **2 template families** across 11 variants. All variants within a family share the **same component architecture**.

| Family | Variants | Component Pattern |
|--------|----------|-------------------|
| **A — React-based** (4) | React-TS, React (JS), Next-TS, React+Inertia | JSX/TSX components in `Components/Common/` + `Layouts/` |
| **B — Server-rendered** (7) | PHP, HTML (Gulp), Node.js (EJS), Laravel (Blade), Ajax, ASP.NET Core (Razor), MVC (.NET Framework Razor) | Partials/includes in `layouts/`, `partials/`, or `Views/Shared/` |

### Per-Variant Component Counts

| Variant | Common Components | Layout Files | Partials | Total Pages |
|---------|-------------------|--------------|----------|-------------|
| **React-TS** | 29 (.tsx) | 9 | — | 200+ |
| **React (JS)** | 27 (.js) | 9 | — | 200+ |
| **Next-TS** | 30 (.tsx) | 7 + sub-dirs | — | 200+ |
| **React+Inertia** | 28 (.tsx) | 6 + sub-dirs | — | 200+ |
| **PHP** | — | — | 14 | 193 |
| **HTML (Gulp)** | — | — | 10 | 193 |
| **Node.js (EJS)** | — | 7 | 10 | 193 |
| **Laravel (Blade)** | — | — | 12 | 193 |
| **Ajax** | — | — | 0 (inline) | 163 |
| **ASP.NET Core** | — | — | 12 (.cshtml) | 200+ |
| **MVC (.NET FW)** | — | — | 11 (.cshtml) | 200+ |

---

## §2 — Canonical Component Table (Family A — React)

> Source: `.agent/skills/velzon-admin/source/react-ts/` (bundled Velzon React-TS components)

### Layout Components (Create once via `/create-admin`)

| # | Component | File | Size | Purpose | Reuse After |
|---|-----------|------|------|---------|-------------|
| L1 | **Layout (index)** | `Layouts/index.tsx` | 5.6KB | Main shell: Header + Sidebar + {children} + Footer + RightSidebar | Always |
| L2 | **Header** | `Layouts/Header.tsx` | 8.3KB | Top bar: hamburger, search, lang, fullscreen, dark mode, notifications, profile (**6 dropdowns** — ~~apps/cart~~ removed) | Always |
| L3 | **Sidebar** | `Layouts/Sidebar.tsx` | 6.4KB | Left navigation menu (permission-filtered) | Always |
| L4 | **Footer** | `Layouts/Footer.tsx` | 0.8KB | `© {year} COMPANY_NAME. All rights reserved.` + LiveClock (`dd/MM/yyyy HH:mm:ss`) | Always |
| L5 | **LayoutMenuData** | `Layouts/LayoutMenuData.tsx` | 48.5KB | Complete menu tree (all pages, icons, permissions) | Update per module |
| L6 | **NonAuthLayout** | `Layouts/NonAuthLayout.tsx` | 1.2KB | Wrapper for auth pages (no sidebar/header) | Always |
| L7 | **VerticalLayouts** | `Layouts/VerticalLayouts/` | dir | Default vertical sidebar layout | Always |
| L8 | **HorizontalLayout** | `Layouts/HorizontalLayout/` | dir | Alternative horizontal nav layout | Always |
| L9 | **TwoColumnLayout** | `Layouts/TwoColumnLayout/` | dir | Two-column sidebar layout | Always |

### Common Components (Create once, reuse everywhere)

| # | Component | File | Size | Purpose | Create When |
|---|-----------|------|------|---------|-------------|
| C1 | **BreadCrumb** | `BreadCrumb.tsx` | 1.0KB | Page title + breadcrumb navigation | 1st admin page |
| C2 | **TableContainer** | `TableContainer.tsx` | 9.7KB | TanStack React Table wrapper (search, sort, pagination, filters) | 1st CRUD page |
| C3 | **TableContainerReactTable** | `TableContainerReactTable.tsx` | 7.6KB | Alternative table (simpler, for basic tables) | 1st basic table |
| C4 | **DeleteModal** | `DeleteModal.tsx` | 1.5KB | Confirmation dialog for record deletion | 1st CRUD page |
| C5 | **ExportCSVModal** | `ExportCSVModal.tsx` | 1.8KB | CSV export modal with react-csv | 1st table page |
| C6 | **Pagination** | `Pagination.tsx` | 2.8KB | Page navigation controls | 1st table page |
| C7 | **SearchOption** | `SearchOption.tsx` | 9.4KB | Global search with autocomplete results | Layout (L2) |
| C8 | **GlobalSearchFilter** | `GlobalSearchFilter.tsx` | 19.2KB | Advanced search with multiple filter types | Layout (L2) |
| C9 | **LanguageDropdown** | `LanguageDropdown.tsx` | 2.6KB | i18n language switcher (flag + label) | Layout (L2) |
| C10 | **LightDark** | `LightDark.tsx` | 0.8KB | Theme toggle (light/dark mode) | Layout (L2) |
| C11 | **FullScreenDropdown** | `FullScreenDropdown.tsx` | 2.4KB | Fullscreen toggle button | Layout (L2) |
| C12 | **NotificationDropdown** | `NotificationDropdown.tsx` | 21.7KB | Bell icon + notification list + tabs | Layout (L2) |
| C13 | **ProfileDropdown** | `ProfileDropdown.tsx` | 6.1KB | User avatar + dropdown (profile, settings, logout) | Layout (L2) |
| C14 | ~~**MyCartDropdown**~~ | `MyCartDropdown.tsx` | 7.2KB | ~~Shopping cart dropdown~~ **REMOVED FROM SHELL** | ❌ Not used |
| C15 | ~~**WebAppsDropdown**~~ | `WebAppsDropdown.tsx` | 4.2KB | ~~Grid of web app shortcuts~~ **REMOVED FROM SHELL** | ❌ Not used |
| C16 | **RightSidebar** | `RightSidebar.tsx` | 125.6KB | Theme customizer panel (layouts, colors, skins) | Layout (L1) |
| C17 | **Loader** | `Loader.tsx` | 0.6KB | Full-page loading spinner | Layout (L1) |
| C18 | **Spinner** | `Spinner.tsx` | 0.5KB | Inline loading spinner | Layout (L1) |
| C19 | **PreviewCardHeader** | `PreviewCardHeader.tsx` | 0.8KB | Card header with copy/preview actions (UI demo pages) | UI kit pages |
| C20 | **Prism** | `Prism.tsx` | 1.7KB | Code syntax highlighter (prismjs) | UI kit pages |
| C21 | **UiContent** | `UiContent.tsx` | 1.2KB | UI page layout wrapper (content + preview) | UI kit pages |
| C22 | **ReviewSlider** | `ReviewSlider.tsx` | 6.0KB | Swiper testimonial/review carousel | Landing/dashboard |
| C23 | **AddEditJobCandidateList** | `AddEditJobCandidateList.tsx` | 15.4KB | Job candidate CRUD modal | Job module only |
| C24 | **ChartsDynamicColor** | `ChartsDynamicColor.tsx` | 1.0KB | Dynamic chart color helper | Charts |
| C25 | **DynamicChartsColor** | `DynamicChartsColor.tsx` | 1.3KB | Alternative dynamic chart colors | Charts |
| C26 | **SorttingData** | `SorttingData.tsx` | 1.2KB | Table sorting toggle component | Tables |
| C27 | **filters** | `filters.tsx` | 1.6KB | Table filter helpers (fuzzy, date, status) | Table pages |
| C28 | **useChartColors** | `useChartColors.ts` | 0.9KB | Hook: resolve CSS variable colors for charts | Charts |
| C29 | **withRouter** | `withRouter.tsx` | 0.5KB | HOC: inject router props (legacy compat) | Wrap components |

### Hooks & Constants

| File | Purpose |
|------|---------|
| `Components/Hooks/UserHooks.ts` | User profile data hook |
| `Components/constants/layout.ts` | Layout type enums (vertical, horizontal, etc.) |

### Next-TS Additions (Family A variant)

| Component | File | Purpose |
|-----------|------|---------|
| `SafeApexChart.tsx` | `Common/SafeApexChart.tsx` | SSR-safe wrapper for ApexCharts (dynamic import) |
| `WithRouter.tsx` | `Common/WithRouter.tsx` | Next.js router adapter (uses `useRouter`) |
| `ClientProviders.tsx` | `ClientProviders.tsx` | Redux Provider wrapper ("use client") |
| `BackToTopButton.tsx` | `BackToTopButton.tsx` | Scroll-to-top floating button |

---

## §3 — Canonical Partial Table (Family B — Server-Rendered)

> Source: Deep audit of all 7 server-rendered variants (extracted to `.agent/skills/velzon-admin/source/html-canonical/`)

### Layout Partials — Cross-Variant Map

| # | Partial | PHP | EJS | HTML (Gulp) | Laravel (Blade) | ASP.NET Core | MVC (.NET FW) |
|---|---------|-----|-----|-------------|-----------------|--------------|---------------|
| P1 | **Master Layout** | `layouts/main.php` | `layouts/layout.ejs` | `partials/main.html` | `layouts/master.blade.php` | `Shared/_Layout.cshtml` | `Shared/_Layout.cshtml` |
| P2 | **Topbar** | `layouts/topbar.php` | `partials/topbar.ejs` | `partials/topbar.html` | `layouts/topbar.blade.php` | `Shared/_topbar.cshtml` | `Shared/_topbar.cshtml` |
| P3 | **Sidebar** | `layouts/sidebar.php` | `partials/sidebar.ejs` | `partials/sidebar.html` | `layouts/sidebar.blade.php` | `Shared/_sidebar.cshtml` | `Shared/_sidebar.cshtml` |
| P4 | **Footer** | `layouts/footer.php` | `partials/footer.ejs` | `partials/footer.html` | `layouts/footer.blade.php` | `Shared/_footer.cshtml` | `Shared/_footer.cshtml` |
| P5 | **Customizer** | `layouts/customizer.php` | `partials/customizer.ejs` | `partials/customizer.html` | `layouts/customizer.blade.php` | `Shared/_customizer.cshtml` | `Shared/_customizer.cshtml` |
| P6 | **Page Title** | `layouts/page-title.php` | `partials/page-title.ejs` | `partials/page-title.html` | N/A (via `@section`) | `Shared/_page_title.cshtml` | `Shared/_page_title.cshtml` |
| P7 | **Head CSS** | `layouts/head-css.php` | `partials/head-css.ejs` | `partials/head-css.html` | `layouts/head-css.blade.php` | `Shared/_head_css.cshtml` | `Shared/_head_css.cshtml` |
| P8 | **Vendor Scripts** | `layouts/vendor-scripts.php` | `partials/vendor-scripts.ejs` | `partials/vendor-scripts.html` | `layouts/vendor-scripts.blade.php` | `Shared/_vendor_scripts.cshtml` | `Shared/_vendor_scripts.cshtml` |
| P9 | **Title Meta** | `layouts/title-meta.php` | `partials/title-meta.ejs` | `partials/title-meta.html` | N/A (via `@section('title')`) | `Shared/_title_meta.cshtml` | `Shared/_title_meta.cshtml` |
| P10 | **Menu** | `layouts/menu.php` | `partials/menu.ejs` | `partials/menu.html` | N/A (inline in sidebar) | `Shared/_menu.cshtml` | `Shared/_menu.cshtml` |

### Variant-Specific Partials

| Partial | PHP Only | EJS Only | Laravel Only | ASP.NET Core Only |
|---------|----------|----------|--------------|-------------------|
| `config` | `layouts/config.php` | — | — | — |
| `session` | `layouts/session.php` | — | — | — |
| `lang` | `layouts/lang.php` | — | — | — |
| `main-diff-layouts` | `layouts/main-diff-layouts.php` | — | — | — |
| Alt layouts | — | 7 layout EJS files | 4 alt Blade layouts | — |
| `master-without-nav` | — | `layout-without-nav.ejs` | `master-without-nav.blade.php` | — |
| `GuestLayout` | — | — | — (React+Inertia only) | — |
| `_ValidationScripts` | — | — | — | `_ValidationScriptsPartial.cshtml` |
| `Error` | — | — | — | `Error.cshtml` |

### Node.js Layout Templates (EJS)

| File | Purpose |
|------|---------|
| `layouts/layout.ejs` | Default vertical sidebar layout |
| `layouts/layout-horizontal.ejs` | Horizontal top-nav layout |
| `layouts/layout-twocolumn.ejs` | Two-column sidebar layout |
| `layouts/layout-detached.ejs` | Detached sidebar layout |
| `layouts/layout-verti-hoverd.ejs` | Vertical hover-collapsed layout |
| `layouts/layout-without-bradcrumb.ejs` | Layout without breadcrumb |
| `layouts/layout-without-nav.ejs` | Auth page layout (no sidebar/header) |

### Laravel Layout Templates (Blade)

| File | Purpose |
|------|---------|
| `layouts/master.blade.php` | Default vertical sidebar layout |
| `layouts/layouts-horizontal.blade.php` | Horizontal top-nav layout |
| `layouts/layouts-two-column.blade.php` | Two-column sidebar layout |
| `layouts/layouts-detached.blade.php` | Detached sidebar layout |
| `layouts/layouts-vertical-hovered.blade.php` | Vertical hover-collapsed layout |
| `layouts/master-without-nav.blade.php` | Auth page layout (no sidebar/header) |

---

## §4 — Cross-Variant Directory Map

### Family A — React-based

| Location | React-TS | Next-TS | React+Inertia |
|----------|----------|---------|---------------|
| **Components** | `src/Components/Common/` | `src/components/Common/` | `resources/js/Components/Common/` |
| **Layouts** | `src/Layouts/` | `src/layouts/` (files) + `src/components/layouts/` | `resources/js/Layouts/` |
| **Routes** | `src/Routes/allRoutes.tsx` | `src/app/(pages)/` (file-based) | `routes/web.php` |
| **State** | `src/slices/` (Redux Toolkit) | `src/slices/` (Redux) | Inertia `usePage()` |
| **Assets** | `src/assets/` | `public/` + `src/assets/` | `resources/js/assets/` → `public/` |
| **SCSS** | `src/assets/scss/` | `src/assets/scss/` | `resources/scss/` |
| **i18n** | `src/locales/` | `src/components/Common/locales/` | `resources/js/locales/` |
| **Helpers** | `src/helpers/` | `src/helpers/` | `resources/js/helpers/` |

### Family B — Server-rendered

| Location | PHP | Node.js (EJS) | HTML (Gulp) | Laravel (Blade) | ASP.NET Core | MVC (.NET FW) |
|----------|-----|---------------|-------------|-----------------|--------------|---------------|
| **Partials** | `layouts/*.php` | `views/partials/*.ejs` | `src/partials/` | `resources/views/layouts/*.blade.php` | `Views/Shared/_*.cshtml` | `Views/Shared/_*.cshtml` |
| **Layout master** | `layouts/main.php` | `views/layouts/layout.ejs` | N/A (flat HTML) | `layouts/master.blade.php` | `Views/Shared/_Layout.cshtml` | `Views/Shared/_Layout.cshtml` |
| **Pages** | `*.php` (flat) | `views/*.ejs` | `src/*.html` | `resources/views/*.blade.php` | `Views/{Module}/*.cshtml` | `Views/{Module}/*.cshtml` |
| **Assets** | `assets/` | `public/assets/` + `src/` | `src/assets/` → `dist/` | `public/assets/` | `wwwroot/assets/` | `Content/` + `assets/` |
| **JS** | `assets/js/` | `src/js/` (webpack) | `src/js/` (Gulp) | `public/assets/js/` | `wwwroot/js/` | `Scripts/` |
| **SCSS** | `assets/scss/` | `src/scss/` | `src/scss/` | `resources/sass/` | `wwwroot/css/` | `Content/css/` |
| **Routing** | N/A (direct URL) | `routes/*.js` (Express) | N/A | `routes/web.php` | `Controllers/*.cs` | `App_Start/RouteConfig.cs` |
| **Config** | `layouts/config.php` | `config.env` | N/A | `.env` + `config/` | `appsettings.json` | `Web.config` |

---

## §5 — Component Mapping: React ↔ Server-Rendered

> This table maps Family A components to their Family B equivalents.

| React Component | Server-Rendered Equivalent | Notes |
|----------------|---------------------------|-------|
| `Layouts/index.tsx` | `layouts/main.php` / `layout.ejs` | Master layout template |
| `Layouts/Header.tsx` | `layouts/topbar.php` / `partials/topbar.ejs` | Top navigation bar |
| `Layouts/Sidebar.tsx` | `layouts/sidebar.php` / `partials/sidebar.ejs` | Side menu |
| `Layouts/Footer.tsx` | `layouts/footer.php` / `partials/footer.ejs` | Footer |
| `LayoutMenuData.tsx` | Menu HTML inside `sidebar.php` / `sidebar.ejs` | React = JSON config → render; Server = direct HTML |
| `RightSidebar.tsx` | `layouts/customizer.php` / `partials/customizer.ejs` | Theme settings offcanvas |
| `BreadCrumb.tsx` | `layouts/page-title.php` / `partials/page-title.ejs` | Page title + breadcrumb |
| `SearchOption.tsx` | Inline in topbar | Search box inside header |
| `LanguageDropdown.tsx` | Inline in topbar | Language switcher inside header |
| `LightDark.tsx` | Inline in topbar | Theme toggle inside header |
| `FullScreenDropdown.tsx` | Inline in topbar | Fullscreen button inside header |
| `NotificationDropdown.tsx` | Inline in topbar | Notification bell inside header |
| `ProfileDropdown.tsx` | Inline in topbar | User profile dropdown inside header |
| ~~`MyCartDropdown.tsx`~~ | ~~Inline in topbar~~ | ❌ **REMOVED FROM SHELL** |
| ~~`WebAppsDropdown.tsx`~~ | ~~Inline in topbar~~ | ❌ **REMOVED FROM SHELL** |
| `TableContainer.tsx` | `list.js` / `DataTables` inline JS | Table with search/sort/pagination |
| `DeleteModal.tsx` | Bootstrap Modal HTML + SweetAlert2 | Delete confirmation |
| `Loader.tsx` | CSS preloader div | Full-page loading spinner |
| `Spinner.tsx` | `<div class="spinner-border">` | Inline spinner |

---

## §6 — Creation & Inheritance Rules

> [!CAUTION]
> **Components/partials are created ONCE** during initial admin setup (`/create-admin`).
> All subsequent pages (`/admin-dashboard`, `/admin-component`) MUST **reuse** existing components — NEVER recreate them.

### Workflow Rules

```
/create-admin (FIRST TIME):
  ├── Create ALL Layout components (L1-L9) or partials (P1-P14)
  ├── Create ALL Common header components (C7-C18 or inline in topbar)
  ├── Create base SCSS imports (app.scss, themes.scss)
  ├── Copy bundled assets (logos, favicon — see SKILL.md § Bundled Assets)
  └── Register initial routes

/admin-dashboard (SUBSEQUENT):
  ├── ✅ IMPORT Layout from existing      ← REUSE
  ├── ✅ IMPORT BreadCrumb from existing  ← REUSE
  ├── ✅ IMPORT TableContainer if needed  ← REUSE
  ├── 🆕 CREATE page-specific components only:
  │   ├── Dashboard stat widgets (CountUp cards)
  │   ├── Dashboard chart components
  │   └── Dashboard data widgets
  └── Register route + menu item

/admin-component (SUBSEQUENT):
  ├── ✅ IMPORT from existing Components/Common/ ← REUSE
  └── 🆕 CREATE only the requested component type
```

### Tier Classification

| Tier | Components | When Created | Recreate? |
|------|-----------|-------------|-----------|
| **Tier 1 — Layout** | L1-L9 / P1-P14 | `/create-admin` only | ❌ NEVER |
| **Tier 2 — Common** | C1-C18 | `/create-admin` or 1st use | ❌ NEVER (import) |
| **Tier 3 — Feature** | C19-C29 | When feature is needed | ❌ NEVER (import) |
| **Tier 4 — Page-specific** | Dashboard widgets, CRUD forms | Each new page | ✅ Yes (unique per page) |

---

## §7 — Essential Admin Components (Minimum Viable Admin)

> Not all 29 components are needed for every admin. Here is the **minimum set** for a functional admin panel:

### Must-Have (12 components)

| # | Component | Why Essential |
|---|-----------|---------------|
| L1 | Layout (index) | Application shell |
| L2 | Header | Navigation bar |
| L3 | Sidebar | Menu navigation |
| L4 | Footer | Copyright |
| L5 | LayoutMenuData | Menu configuration |
| L7 | VerticalLayouts | Default layout |
| C1 | BreadCrumb | Page identification |
| C2 | TableContainer | Data display (core CRUD) |
| C4 | DeleteModal | Delete confirmation |
| C10 | LightDark | Dark mode (user expectation) |
| C13 | ProfileDropdown | User context |
| C17 | Loader | Loading state |

### Nice-to-Have (added when needed)

| Component | When to Add |
|-----------|-------------|
| C5 ExportCSVModal | Data export feature |
| C6 Pagination | Large datasets |
| C7 SearchOption | Global search |
| C9 LanguageDropdown | Multi-language support |
| C11 FullScreenDropdown | Fullscreen mode |
| C12 NotificationDropdown | Real-time notifications |
| ~~C14 MyCartDropdown~~ | ❌ **REMOVED FROM SHELL** |
| ~~C15 WebAppsDropdown~~ | ❌ **REMOVED FROM SHELL** |
| C16 RightSidebar | Theme customization |

---

## §8 — SCSS Blueprint (Mandatory Style Files)

> [!CAUTION]
> **Without these SCSS files, the `--vz-*` CSS variable system breaks completely.** All colors, spacing, shadows, and dark mode will fail.

### Required SCSS Files (Create/Copy during `/create-admin`)

| # | File | Size | Purpose | MUST COPY |
|---|------|------|---------|-----------|
| S1 | `_variables.scss` | 70KB | ALL Bootstrap 5 variable overrides + Velzon custom vars | ✅ YES |
| S2 | `_variables-custom.scss` | ~2KB | Velzon-specific CSS custom properties (`--vz-*`) | ✅ YES |
| S3 | `_variables-dark.scss` | ~8KB | Dark mode variable overrides | ✅ YES |
| S4 | `bootstrap.scss` | ~1KB | Bootstrap import with variable overrides | ✅ YES |
| S5 | `app.scss` | ~2KB | Main app stylesheet (imports components, structure, pages, plugins) | ✅ YES |
| S6 | `themes.scss` | ~1KB | Entry point imported in App.tsx / layout.tsx | ✅ YES |
| S7 | `custom.scss` | ~1KB | User customization overrides (empty by default) | ✅ YES |

### SCSS Directory Structure (Canonical)

```
assets/scss/
├── _variables.scss              ← S1: Core override file
├── _variables-custom.scss       ← S2: --vz-* properties
├── _variables-dark.scss         ← S3: Dark mode
├── bootstrap.scss               ← S4: BS5 imports
├── app.scss                     ← S5: Main import
├── themes.scss                  ← S6: Entry point
├── custom.scss                  ← S7: User overrides
├── components/                  ← 31 files (_root, _card, _buttons, _nav, _modal, _table, _widgets...)
├── structure/                   ← 8 files (_vertical, _horizontal, _two-column, _topbar, _footer...)
├── pages/                       ← 22 files (_dashboard, _chat, _email, _authentication...)
├── plugins/                     ← 3rd party style overrides
├── theme/                       ← Theme-specific overrides
├── fonts/                       ← Custom font declarations
└── rtl/                         ← RTL layout mirror styles
```

### Per-Variant SCSS Location

| Variant | SCSS Source Path |
|---------|-----------------|
| React-TS | `src/assets/scss/` |
| Next-TS | `src/assets/scss/` |
| React+Inertia | `resources/scss/` or `resources/css/` |
| PHP | `assets/scss/` |
| HTML | `src/scss/` → compiled to `dist/css/` |
| Node.js | `src/scss/` → compiled via webpack |
| Laravel | `resources/sass/` |
| ASP.NET | `wwwroot/css/` (pre-compiled) |

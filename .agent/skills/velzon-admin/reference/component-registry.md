# Component Registry — Velzon Admin v4.4.1

> **Source of truth** for all shared components across 11 Velzon variants.
> Read this file BEFORE creating any admin page to know **what to create, what to reuse, and where to put it**.

---

## §1 — Template Families

> [!IMPORTANT]
> Velzon has **2 template families**, not 11. All variants within a family share the **same component architecture**.

| Family | Variants | Component Pattern |
|--------|----------|-------------------|
| **A — React-based** | React-TS, Next-TS, React+Inertia | JSX components in `Components/Common/` + `Layouts/` |
| **B — Server-rendered** | PHP, HTML, Node.js (EJS), Laravel (Blade), Ajax, ASP.NET (MVC/Razor) | Partials/includes in `layouts/` or `partials/` |

---

## §2 — Canonical Component Table (Family A — React)

> Source: `C:\Projects\Velzon Admin\React-TS\Master\src\`

### Layout Components (Create once via `/create-admin`)

| # | Component | File | Size | Purpose | Reuse After |
|---|-----------|------|------|---------|-------------|
| L1 | **Layout (index)** | `Layouts/index.tsx` | 5.6KB | Main shell: Header + Sidebar + {children} + Footer + RightSidebar | Always |
| L2 | **Header** | `Layouts/Header.tsx` | 8.3KB | Top bar: hamburger, search, lang, fullscreen, dark mode, notifications, cart, apps, profile | Always |
| L3 | **Sidebar** | `Layouts/Sidebar.tsx` | 6.4KB | Left navigation menu (permission-filtered) | Always |
| L4 | **Footer** | `Layouts/Footer.tsx` | 0.8KB | `© {year} Velzon. Design & Develop by Themesbrand` | Always |
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
| C14 | **MyCartDropdown** | `MyCartDropdown.tsx` | 7.2KB | Shopping cart dropdown (ecommerce) | Layout (L2), optional |
| C15 | **WebAppsDropdown** | `WebAppsDropdown.tsx` | 4.2KB | Grid of web app shortcuts | Layout (L2), optional |
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

> Source: `C:\Projects\Velzon Admin\PHP\master\layouts\` and `Node\Master\views\partials\`

### Layout Partials (Create once, include in every page)

| # | Partial | PHP File | EJS File | HTML equiv | Purpose |
|---|---------|----------|----------|------------|---------|
| P1 | **Main Layout** | `layouts/main.php` | `layouts/layout.ejs` | N/A (inline) | Master template: include head, sidebar, topbar, content, footer, scripts |
| P2 | **Topbar** | `layouts/topbar.php` | `partials/topbar.ejs` | N/A (inline) | Header bar: hamburger, search, lang, fullscreen, dark mode, notifications, profile |
| P3 | **Sidebar** | `layouts/sidebar.php` | `partials/sidebar.ejs` | N/A (inline) | Left navigation menu (full HTML menu tree) |
| P4 | **Footer** | `layouts/footer.php` | `partials/footer.ejs` | N/A (inline) | Footer copyright text |
| P5 | **Customizer** | `layouts/customizer.php` | `partials/customizer.ejs` | N/A (inline) | Theme customizer offcanvas (= RightSidebar in React) |
| P6 | **Page Title** | `layouts/page-title.php` | `partials/page-title.ejs` | N/A (inline) | Breadcrumb + page title (= BreadCrumb in React) |
| P7 | **Head CSS** | `layouts/head-css.php` | `partials/head-css.ejs` | `<head>` section | CSS includes (Bootstrap, app.css, icons) |
| P8 | **Vendor Scripts** | `layouts/vendor-scripts.php` | `partials/vendor-scripts.ejs` | Bottom scripts | JS includes (Bootstrap, simplebar, lord-icon, app.js) |
| P9 | **Title Meta** | `layouts/title-meta.php` | `partials/title-meta.ejs` | `<title>` | `<title>` + meta tags |
| P10 | **Menu Data** | `layouts/menu.php` | `partials/menu.ejs` | N/A (inline in sidebar) | Menu items configuration |
| P11 | **Config** | `layouts/config.php` | N/A | N/A | Layout configuration (theme, sidebar, topbar defaults) |
| P12 | **Session** | `layouts/session.php` | N/A | N/A | PHP session init |
| P13 | **Lang** | `layouts/lang.php` | N/A | N/A | Language initialization |
| P14 | **Main Diff Layouts** | `layouts/main-diff-layouts.php` | N/A | N/A | Alternative layout templates (horizontal, detached, two-column) |

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

| Location | PHP | Node.js (EJS) | HTML (Gulp) | Laravel (Blade) | ASP.NET (Razor) |
|----------|-----|---------------|-------------|-----------------|-----------------|
| **Partials** | `layouts/*.php` | `views/partials/*.ejs` | `src/partials/` (Gulp) | `resources/views/layouts/*.blade.php` | `Views/Shared/*.cshtml` |
| **Layout master** | `layouts/main.php` | `views/layouts/layout.ejs` | N/A (flat HTML) | `resources/views/layouts/master.blade.php` | `Views/Shared/_Layout.cshtml` |
| **Pages** | `*.php` (flat) | `views/*.ejs` | `src/*.html` | `resources/views/*.blade.php` | `Views/{Controller}/*.cshtml` |
| **Assets** | `assets/` | `public/assets/` + `src/` | `src/assets/` → `dist/assets/` | `public/assets/` | `wwwroot/assets/` |
| **JS** | `assets/js/` | `src/js/` (webpack) | `src/js/` (Gulp) | `public/assets/js/` | `wwwroot/js/` |
| **SCSS** | `assets/scss/` | `src/scss/` | `src/scss/` | `resources/sass/` | `wwwroot/css/` |

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
| `MyCartDropdown.tsx` | Inline in topbar | Cart dropdown inside header |
| `WebAppsDropdown.tsx` | Inline in topbar | App grid inside header |
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
| C14 MyCartDropdown | E-commerce projects |
| C15 WebAppsDropdown | Multi-app projects |
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

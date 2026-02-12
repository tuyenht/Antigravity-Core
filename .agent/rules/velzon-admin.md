# Velzon Admin Dashboard Expert Rule

## Auto-Activation

**Trigger Keywords:** admin, dashboard, admin panel, bảng điều khiển, quản lý, management screen, CRUD table, data management

**Context Detection:**
- Building admin management interfaces
- Creating dashboard pages with stats/charts
- Implementing CRUD screens with tables
- Working in projects that use Velzon template patterns

**Multi-Stack Auto-Detection:**
- `composer.json` + `inertiajs/inertia-laravel` → React+Inertia variant → read `reference/inertia-bridge.md`
- `next.config.js` or `next.config.ts` → Next-TS variant → read `reference/nextjs-patterns.md`
- `composer.json` + Blade views → Laravel variant → read `reference/html-php-patterns.md`
- `gulpfile.js` + HTML files → HTML variant → read `reference/html-php-patterns.md`
- Default → React-TS variant (core skill patterns)

## Core Stack

| Technology | Version | Import From |
|-----------|---------|-------------|
| React | 19+ | `react` |
| TypeScript | 5.8+ | TypeScript compiler |
| Bootstrap | 5.3+ | Via Reactstrap |
| Reactstrap | 9.2+ | `reactstrap` |
| Redux Toolkit | 2.8+ | `@reduxjs/toolkit` |
| TanStack Table | 8.x | `@tanstack/react-table` |
| ApexCharts | 4.x | `react-apexcharts` |
| Formik + Yup | 2.x / 1.x | `formik`, `yup` |
| CountUp | 6.x | `react-countup` |
| Remix Icons | latest | `ri-*` CSS classes |

## Mandatory Patterns

### 1. Page Structure
Every admin page **MUST** follow:
```tsx
<div className="page-content">
  <Container fluid>
    <BreadCrumb title="..." pageTitle="..." />
    {/* Content */}
  </Container>
</div>
```

### 2. Grid System
**USE Reactstrap components**, not raw HTML:
- `Container fluid` (not `<div class="container-fluid">`)
- `Row` / `Col` with `xl`, `lg`, `md`, `sm`, `xs` breakpoint props
- `Card` / `CardBody` / `CardHeader`

### 3. CSS Classes
- Buttons: `btn-soft-*` for subtle variants
- Backgrounds: `bg-*-subtle` for soft backgrounds
- Avatars: `avatar-xs/sm/md/lg/xl` + `avatar-title`
- Text: `text-muted`, `text-truncate`, `fw-medium`, `fw-semibold`
- Font size: `fs-10` through `fs-24`
- Spacing: Bootstrap 5 standard (`mb-0`, `mt-4`, `p-3`, etc.)

### 4. Icons
**Primary:** Remix Icons (`ri-*-line` or `ri-*-fill`)
```html
<i className="ri-add-line align-bottom me-1"></i>
```

### 5. Tables
Use `TableContainer` wrapper for TanStack Table with:
- `isGlobalFilter={true}` for search
- `divClass="table-responsive table-card mb-1"`
- `tableClass="align-middle table-nowrap"`
- `theadClass="table-light text-muted"`

### 6. State Management
- Redux Toolkit slices: `createSlice` + `createAsyncThunk`
- Selectors: `createSelector` from `reselect`
- Dispatch: `useDispatch` + `useSelector`

### 7. Forms
- Formik for form state + Yup for validation
- Reactstrap `Input`/`Label`/`Form`/`FormFeedback` components
- Always use `validation.handleChange` / `validation.handleBlur`

### 8. Modals
- Reactstrap `Modal` with `centered` prop
- Confirmation dialogs: copy `DeleteModal` pattern
- Add/Edit modals: Formik form inside `ModalBody`

## Anti-Patterns (DO NOT)

- ❌ Use raw `<div class="row">` instead of `<Row>`
- ❌ Import from `react-bootstrap` (use `reactstrap`)
- ❌ Use inline styles when Bootstrap utilities exist
- ❌ Skip `BreadCrumb` component on admin pages
- ❌ Use `useState` for complex forms (use Formik)
- ❌ Use plain HTML tables (use `TableContainer` or Reactstrap `Table`)
- ❌ Mix icon libraries randomly (prefer Remix Icons)

## Skill Reference

For detailed patterns, read the Velzon Admin skill:
- `SKILL.md` - Overview, multi-stack support, and quick reference
- `reference/component-patterns.md` - All component code patterns
- `reference/layout-system.md` - Layout, sidebar, routes
- `reference/dashboard-patterns.md` - Dashboard building guide
- `reference/page-catalog.md` - 200+ page template catalog
- `reference/design-tokens.md` - Color palette, typography, spacing, dark mode
- `reference/inertia-bridge.md` - Laravel + Inertia.js adaptation
- `reference/nextjs-patterns.md` - Next.js App Router adaptation
- `reference/html-php-patterns.md` - HTML/PHP/Laravel Blade patterns
- `reference/nodejs-patterns.md` - Node.js Express + EJS patterns
- `reference/ajax-patterns.md` - jQuery AJAX single-page shell patterns
- `reference/aspnet-mvc-patterns.md` - ASP.NET Core 8 + MVC Razor patterns
- `reference/asset-catalog.md` - Complete image, font, SCSS, plugin inventory
- `reference/api-and-helpers.md` - API client, auth flows, i18n, toast, avatars

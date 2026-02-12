---
name: Velzon Admin Dashboard
description: Expert patterns for building admin dashboards using Velzon template conventions. React + TypeScript + Bootstrap 5 + Reactstrap + Redux Toolkit. Auto-activates for admin panel, dashboard, and management screen requests.
---

# Velzon Admin Dashboard Skill

## Overview

Velzon is a premium admin & dashboard template (v4.4.1) providing **200+ pre-built pages** across 8 dashboard types, 12+ app modules, and comprehensive UI components. This skill encodes the architectural patterns, component conventions, and layout system for building production admin dashboards.

**Based on:** Velzon Admin & Dashboard Template v4.4.1 (All 7 variants)

## When to Use

Auto-activate when the request involves:
- Building admin panels or dashboards
- Creating management screens (CRUD, lists, details, forms)
- Keywords: "admin", "dashboard", "admin panel", "bảng điều khiển", "quản lý", "management"
- Data tables, stat widgets, chart dashboards

## Technology Stack

| Technology | Version | Purpose |
|-----------|---------|---------|
| React | 19.1 | UI framework |
| TypeScript | 5.8 | Type safety |
| Bootstrap | 5.3.7 | CSS framework |
| Reactstrap | 9.2.3 | Bootstrap React components |
| Redux Toolkit | 2.8 | State management |
| TanStack Table | 8.21 | Data tables with sorting/filtering |
| ApexCharts | 4.7 | Primary chart library |
| Formik + Yup | 2.4 / 1.6 | Form management + validation |
| react-countup | 6.5 | Animated number widgets |
| Flatpickr | 4.0 | Date/time picker |
| Remix Icons | - | Primary icon set (ri-*) |

## Core Architecture

### Page Structure Pattern

Every admin page follows this structure:

```tsx
const MyPage = () => {
  document.title = "Page Title | App Name";
  
  return (
    <React.Fragment>
      <div className="page-content">
        <Container fluid>
          <BreadCrumb title="Page Title" pageTitle="Category" />
          <Row>
            {/* Page content here */}
          </Row>
        </Container>
      </div>
    </React.Fragment>
  );
};
```

### Layout System

Three layout types, managed via Redux:
- **Vertical** (default): Left sidebar + main content
- **Horizontal**: Top navigation bar + main content
- **TwoColumn**: Icon sidebar + expanded menu + main content

Layout wrapper: `#layout-wrapper` > Header + Sidebar + `.main-content` > `.page-content`

### CSS Variable System

All Velzon-specific variables use `--vz-*` prefix:
```css
--vz-primary, --vz-secondary, --vz-success, --vz-info, --vz-warning, --vz-danger
--vz-card-bg, --vz-body-color, --vz-body-bg
--vz-border-color, --vz-light, --vz-dark
```

Bootstrap utilities enhanced with `-subtle` suffix for backgrounds:
- `bg-primary-subtle`, `bg-success-subtle`, `bg-warning-subtle`, etc.

### Component Imports

Always import from Reactstrap (NOT raw Bootstrap classes for interactive components):
```tsx
import { Container, Row, Col, Card, CardBody, CardHeader, Button,
         Modal, ModalBody, ModalHeader, ModalFooter,
         Input, Label, Form, FormFeedback,
         Table, Badge, UncontrolledDropdown, DropdownToggle,
         DropdownMenu, DropdownItem, Nav, NavItem, NavLink,
         TabContent, TabPane } from "reactstrap";
```

## Multi-Stack Support

Velzon supports 11 variants. Choose based on your project:

| Variant | When to Use | Reference File |
|---------|-------------|---------------|
| **React-TS** | Standalone React SPA (default) | Core skill files |
| **React+Inertia** | Laravel + Inertia.js + React (Baoson Platform) | [inertia-bridge.md](reference/inertia-bridge.md) |
| **Next-TS** | Next.js App Router (BSWeb SaaS) | [nextjs-patterns.md](reference/nextjs-patterns.md) |
| **Node.js** | Express.js + EJS (server-side rendering) | [nodejs-patterns.md](reference/nodejs-patterns.md) |
| **Ajax** | jQuery AJAX single-page shell | [ajax-patterns.md](reference/ajax-patterns.md) |
| **ASP.NET Core** | ASP.NET Core 8 + Razor (.cshtml) | [aspnet-mvc-patterns.md](reference/aspnet-mvc-patterns.md) |
| **ASP.NET MVC** | ASP.NET MVC (.NET Framework) + Razor | [aspnet-mvc-patterns.md](reference/aspnet-mvc-patterns.md) |
| **Laravel** | Laravel + Blade (server-side) | [html-php-patterns.md](reference/html-php-patterns.md) |
| **HTML** | Static HTML + Bootstrap + Gulp | [html-php-patterns.md](reference/html-php-patterns.md) |
| **PHP** | PHP with includes | [html-php-patterns.md](reference/html-php-patterns.md) |
| **React** | React JS (no TypeScript) | Same as React-TS minus types |

### Stack Detection
- `composer.json` + `inertiajs` → use **React+Inertia** patterns
- `next.config.js` → use **Next-TS** patterns
- `app.js` + `express` + `.ejs` views → use **Node.js** patterns
- `.csproj` + `Program.cs` + `.cshtml` views → use **ASP.NET Core** patterns
- `.csproj` + `Global.asax.cs` + `.cshtml` views → use **ASP.NET MVC** patterns
- `index.html` + AJAX nav + HTML fragment pages → use **Ajax** patterns
- `composer.json` + Blade views → use **Laravel** patterns
- `gulpfile.js` + HTML → use **HTML** patterns
- Otherwise → default **React-TS** patterns

## Reference Files

Read these for detailed patterns:

| File | Content |
|------|---------|
| [component-patterns.md](reference/component-patterns.md) | Reusable component code patterns |
| [layout-system.md](reference/layout-system.md) | Layout architecture and sidebar menu |
| [dashboard-patterns.md](reference/dashboard-patterns.md) | Dashboard-specific building patterns |
| [page-catalog.md](reference/page-catalog.md) | Complete 200+ page route catalog |
| [design-tokens.md](reference/design-tokens.md) | Color palette, typography, spacing, shadows, dark mode |
| [inertia-bridge.md](reference/inertia-bridge.md) | Laravel + Inertia.js adaptation patterns |
| [nextjs-patterns.md](reference/nextjs-patterns.md) | Next.js App Router adaptation patterns |
| [html-php-patterns.md](reference/html-php-patterns.md) | HTML/PHP/Laravel Blade patterns |
| [nodejs-patterns.md](reference/nodejs-patterns.md) | Node.js Express + EJS patterns |
| [ajax-patterns.md](reference/ajax-patterns.md) | jQuery AJAX single-page shell patterns |
| [aspnet-mvc-patterns.md](reference/aspnet-mvc-patterns.md) | ASP.NET Core 8 + MVC Razor patterns |
| [asset-catalog.md](reference/asset-catalog.md) | Complete image, font, SCSS, plugin inventory |
| [api-and-helpers.md](reference/api-and-helpers.md) | API client, auth flows, i18n, toast, file upload, avatars |

## Quick Reference: Common Patterns

### 1. Stat Widget Card
```tsx
<Col xl={3} md={6}>
  <Card className="card-animate">
    <CardBody>
      <div className="d-flex align-items-center">
        <div className="flex-grow-1 overflow-hidden">
          <p className="text-uppercase fw-medium text-muted text-truncate mb-0">
            {label}
          </p>
        </div>
        <div className="flex-shrink-0">
          <h5 className={"fs-14 mb-0 text-" + badgeClass}>
            <i className={"fs-13 align-middle " + icon}></i> {percentage}%
          </h5>
        </div>
      </div>
      <div className="d-flex align-items-end justify-content-between mt-4">
        <div>
          <h4 className="fs-22 fw-semibold ff-secondary mb-4">
            <CountUp start={0} end={value} prefix="$" separator="," duration={4} />
          </h4>
          <Link to="#" className="text-decoration-underline">{linkText}</Link>
        </div>
        <div className="avatar-sm flex-shrink-0">
          <span className={"avatar-title rounded fs-3 bg-" + color + "-subtle"}>
            <i className={`text-${color} ${iconClass}`}></i>
          </span>
        </div>
      </div>
    </CardBody>
  </Card>
</Col>
```

### 2. Data Table Page
```tsx
<Card>
  <CardHeader className="border-0">
    <div className="d-flex align-items-center">
      <h5 className="card-title mb-0 flex-grow-1">Table Title</h5>
      <div className="flex-shrink-0">
        <Button color="success" className="add-btn" onClick={toggle}>
          <i className="ri-add-line align-bottom me-1"></i> Add
        </Button>
      </div>
    </div>
  </CardHeader>
  <CardBody>
    <TableContainer
      columns={columns}
      data={data}
      isGlobalFilter={true}
      customPageSize={10}
      divClass="table-responsive table-card mb-1"
      tableClass="align-middle table-nowrap"
      theadClass="table-light text-muted"
      SearchPlaceholder="Search..."
    />
  </CardBody>
</Card>
```

### 3. Redux Slice Pattern
```tsx
// reducer.ts
import { createSlice } from "@reduxjs/toolkit";
import { getData } from './thunk';

const MySlice = createSlice({
  name: 'MyFeature',
  initialState: { data: [], error: {} },
  reducers: {},
  extraReducers: (builder) => {
    builder.addCase(getData.fulfilled, (state, action) => {
      state.data = action.payload;
    });
    builder.addCase(getData.rejected, (state, action) => {
      state.error = action.error.message;
    });
  }
});

// thunk.ts
import { createAsyncThunk } from "@reduxjs/toolkit";
export const getData = createAsyncThunk("myFeature/getData", async () => {
  const response = await apiCall();
  return response;
});
```

### 4. Delete Confirmation Modal
```tsx
<Modal isOpen={show} toggle={onCloseClick} centered>
  <ModalBody className="py-3 px-5">
    <div className="mt-2 text-center">
      <i className="ri-delete-bin-line display-5 text-danger"></i>
      <div className="mt-4 pt-2 fs-15 mx-4 mx-sm-5">
        <h4>Are you sure?</h4>
        <p className="text-muted mx-4 mb-0">
          Are you sure you want to remove this record?
        </p>
      </div>
    </div>
    <div className="d-flex gap-2 justify-content-center mt-4 mb-2">
      <Button color="light" onClick={onCloseClick}>Close</Button>
      <Button color="danger" onClick={onDeleteClick}>Yes, Delete It!</Button>
    </div>
  </ModalBody>
</Modal>
```

### 5. BreadCrumb
```tsx
<BreadCrumb title="Page Title" pageTitle="Parent Category" />
```

## CSS Class Conventions

| Class | Usage |
|-------|-------|
| `card-animate` | Hover animation on cards |
| `card-height-100` | Full-height card |
| `avatar-xs/sm/md/lg/xl` | Avatar sizing |
| `avatar-title` | Centered icon in avatar |
| `ff-secondary` | Secondary font family |
| `fs-10` to `fs-24` | Font sizes |
| `text-truncate` | Ellipsis overflow |
| `material-shadow-none` | Remove material shadow |
| `btn-soft-*` | Soft/subtle button variant |
| `table-nowrap` | No-wrap table cells |
| `table-card` | Card-style table |

## Icon System

Primary: **Remix Icons** (`ri-*` prefix)
```html
<i className="ri-dashboard-2-line"></i>    <!-- Line style -->
<i className="ri-dashboard-2-fill"></i>    <!-- Fill style -->
<i className="ri-add-line align-bottom me-1"></i>  <!-- Common button icon -->
<i className="ri-delete-bin-line"></i>      <!-- Delete -->
<i className="ri-pencil-fill"></i>          <!-- Edit -->
<i className="ri-eye-fill"></i>             <!-- View -->
```

Also available: BoxIcons (`bx bx-*`), Material Design, Feather, Line Awesome, Crypto Icons.

## Build & Dev Commands

### Per-Variant Commands

| Variant | Path | Install | Dev Server | Build |
|---------|------|---------|------------|-------|
| **React-TS** | `React-TS/Master/` | `npm install` | `npm start` (CRA) | `npm run build` |
| **Next.js** | `Nextjs/Master/` | `npm install` | `npm run dev` (Next 15) | `npm run build` |
| **HTML** | `HTML/Master/` | `npm install` | `npx gulp` (BrowserSync) | `npx gulp build` |
| **Laravel** | `Laravel/` | `composer install && npm install` | `php artisan serve` + `npm run dev` | `npm run build` |
| **PHP** | `PHP/` | N/A (static includes) | Local PHP server | N/A |

### CSS/SCSS Compilation

SCSS is compiled automatically by CRA/webpack (React-TS) or Gulp (HTML):
- **React-TS**: Webpack (via react-scripts) processes `app.scss` and `themes.scss` via `sass` package
- **HTML**: Gulp compiles via `gulp-sass` with source maps
- **Next.js**: SCSS imported directly in layout components

### i18n Configuration

```tsx
// i18n.ts
import i18n from "i18next";
import { initReactI18next } from "react-i18next";
import LanguageDetector from "i18next-browser-languagedetector";

i18n.use(LanguageDetector).use(initReactI18next).init({
  fallbackLng: "en",
  resources: {
    en: { translation: require("./locales/en.json") },
    sp: { translation: require("./locales/sp.json") },
    gr: { translation: require("./locales/gr.json") },  // German
    it: { translation: require("./locales/it.json") },
    ru: { translation: require("./locales/ru.json") },
    ch: { translation: require("./locales/ch.json") },
    fr: { translation: require("./locales/fr.json") },
    ar: { translation: require("./locales/ar.json") },
  },
});
```

**Available Locales:** `en`, `sp`, `gr` (German), `it`, `ru`, `ch`, `fr`, `ar`
**Usage:** `const { t } = useTranslation(); <span>{t("Dashboard")}</span>`


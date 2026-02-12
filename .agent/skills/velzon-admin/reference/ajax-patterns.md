# Ajax Patterns — Velzon Admin

Reference for the **Ajax** (jQuery) variant. Uses a single-page shell with dynamic HTML fragment loading via jQuery AJAX — no full page reloads.

---

## 1. Architecture Overview

Unlike the HTML variant (full-page reload), Ajax uses a **single-page application shell**:

```
┌─────────────────────────────────────────────┐
│  index.html (SHELL - always loaded)         │
│  ├── <head> — all CSS + meta                │
│  ├── <body>                                 │
│  │   ├── #layout-wrapper                    │
│  │   │   ├── Topbar (header)                │
│  │   │   ├── Sidebar (nav menu)             │
│  │   │   └── .main-content                  │
│  │   │       └── #page-content-wrapper ←──┐ │
│  │   │           (AJAX loads here)     │  │ │
│  │   ├── Footer                           │  │
│  │   └── Theme Customizer               │  │
│  └── <scripts> — app.js + vendor.js      │  │
│                                           │  │
│  163 HTML fragment files ─────────────────┘  │
│  (e.g., index.html, apps-chat.html, etc.)    │
└─────────────────────────────────────────────┘
```

### Key Difference vs HTML Variant

| Feature | HTML | Ajax |
|---------|------|------|
| Page load | Full reload (`<html>` → `</html>`) | AJAX fragment swap |
| Shell | Each page includes full layout | Single `index.html` shell |
| Navigation | `<a href="page.html">` | `<a href="page.html">` intercepted by JS |
| CSS loading | `<link>` in `<head>` per page | Fragment-level `<link>` injected |
| JS loading | `<script>` at bottom per page | Fragment JS executed after inject |
| URL handling | Standard browser | Hash or pushState |
| Menu state | Re-rendered each page | Persistent, active class toggled |
| Performance | Slower (full reload) | Faster (only content changes) |

---

## 2. Project Structure

```
ajax/
├── index.html                        # Main shell page (sidebar + topbar + scripts)
├── assets/
│   ├── css/
│   │   ├── bootstrap.min.css
│   │   ├── app.min.css               # Compiled Velzon CSS
│   │   ├── custom.min.css
│   │   └── icons.min.css             # All icon fonts
│   ├── js/
│   │   ├── app.js                    # Core: layout, theme, AJAX navigation
│   │   ├── pages/                    # Per-page init scripts
│   │   │   ├── dashboard-ecommerce.init.js
│   │   │   ├── dashboard-analytics.init.js
│   │   │   ├── apexcharts-*.init.js
│   │   │   └── ...
│   │   └── plugins/
│   ├── libs/                         # Vendor JS/CSS (CDN alternatives)
│   │   ├── apexcharts/
│   │   ├── bootstrap/
│   │   ├── choices.js/
│   │   ├── flatpickr/
│   │   ├── jsvectormap/
│   │   ├── list.js/
│   │   ├── simplebar/
│   │   ├── sortablejs/
│   │   ├── sweetalert2/
│   │   └── swiper/
│   ├── images/                       # Same as React-TS (see asset-catalog.md)
│   └── fonts/                        # Same as React-TS
│
├── [163 HTML fragment pages]
│   ├── apps-calendar.html
│   ├── apps-chat.html
│   ├── apps-crm-contacts.html
│   ├── apps-ecommerce-products.html
│   ├── charts-apex-area.html
│   ├── dashboard-analytics.html
│   ├── ui-alerts.html
│   └── ...
│
└── scss/                             # Source SCSS (same as React-TS)
```

---

## 3. Shell Page (`index.html`)

The shell contains the persistent layout elements. Content area loads via AJAX:

```html
<!doctype html>
<html lang="en" data-layout="vertical" data-topbar="light"
      data-sidebar="dark" data-sidebar-size="lg"
      data-sidebar-image="none" data-preloader="disable"
      data-theme="default" data-theme-colors="default">
<head>
    <meta charset="utf-8" />
    <title>Velzon - Admin Dashboard</title>
    <link href="assets/css/bootstrap.min.css" rel="stylesheet" />
    <link href="assets/css/icons.min.css" rel="stylesheet" />
    <link href="assets/css/app.min.css" rel="stylesheet" />
    <link href="assets/css/custom.min.css" rel="stylesheet" />
</head>
<body>
    <div id="layout-wrapper">
        <!-- TOPBAR (persistent) -->
        <header id="page-topbar">...</header>

        <!-- SIDEBAR (persistent) -->
        <div class="app-menu navbar-menu">
            <div id="scrollbar">
                <ul class="navbar-nav" id="navbar-nav">
                    <!-- Menu items with data-page attributes -->
                    <li class="nav-item">
                        <a class="nav-link menu-link" href="index.html">
                            <i class="ri-dashboard-2-line"></i>
                            <span>Dashboard</span>
                        </a>
                    </li>
                    <!-- ... -->
                </ul>
            </div>
        </div>

        <!-- MAIN CONTENT (AJAX target) -->
        <div class="main-content">
            <div class="page-content" id="page-content-wrapper">
                <!-- Content loaded here via AJAX -->
            </div>
            <footer class="footer">...</footer>
        </div>
    </div>

    <!-- Theme Customizer -->
    <div class="offcanvas offcanvas-end" id="theme-settings-offcanvas">...</div>

    <!-- Core Scripts -->
    <script src="assets/libs/bootstrap/js/bootstrap.bundle.min.js"></script>
    <script src="assets/libs/simplebar/simplebar.min.js"></script>
    <script src="assets/js/app.js"></script>
</body>
</html>
```

---

## 4. HTML Fragment Structure

Each fragment page is a **partial HTML** — no `<html>`, `<head>`, or `<body>` tags:

```html
<!-- apps-ecommerce-products.html (FRAGMENT) -->

<!-- Page-specific CSS (injected into head) -->
<link href="assets/libs/gridjs/theme/mermaid.min.css" rel="stylesheet" />

<div class="page-content">
    <div class="container-fluid">

        <!-- Breadcrumb -->
        <div class="row">
            <div class="col-12">
                <div class="page-title-box d-sm-flex align-items-center justify-content-between">
                    <h4 class="mb-sm-0">Products</h4>
                    <div class="page-title-right">
                        <ol class="breadcrumb m-0">
                            <li class="breadcrumb-item"><a href="javascript: void(0);">Ecommerce</a></li>
                            <li class="breadcrumb-item active">Products</li>
                        </ol>
                    </div>
                </div>
            </div>
        </div>

        <!-- Page Content -->
        <div class="row">
            <div class="col-xl-3 col-md-6">
                <div class="card card-animate">
                    <div class="card-body">
                        <!-- Widget content -->
                    </div>
                </div>
            </div>
            <!-- More content... -->
        </div>

    </div>
</div>

<!-- Page-specific JS (executed after injection) -->
<script src="assets/libs/gridjs/gridjs.umd.js"></script>
<script src="assets/js/pages/ecommerce-product-list.init.js"></script>
```

### Fragment Loading Pattern

The `app.js` intercepts sidebar menu clicks and loads content via AJAX:

```javascript
// Simplified AJAX navigation logic from app.js

// 1. Intercept sidebar link clicks
document.querySelectorAll('.navbar-nav .nav-link').forEach(link => {
    link.addEventListener('click', function(e) {
        e.preventDefault();
        const url = this.getAttribute('href');
        loadPage(url);
    });
});

// 2. Load page content via AJAX
function loadPage(url) {
    // Show preloader
    document.getElementById('preloader')?.classList.remove('d-none');

    fetch(url)
        .then(response => response.text())
        .then(html => {
            // Inject HTML into content wrapper
            document.getElementById('page-content-wrapper').innerHTML = html;

            // Extract and load page-specific CSS
            const links = document.querySelectorAll('#page-content-wrapper link');
            links.forEach(link => document.head.appendChild(link));

            // Execute page-specific scripts
            const scripts = document.querySelectorAll('#page-content-wrapper script');
            scripts.forEach(script => {
                const newScript = document.createElement('script');
                newScript.src = script.src;
                document.body.appendChild(newScript);
            });

            // Re-initialize plugins
            reinitPlugins();

            // Update active menu
            updateActiveMenu(url);

            // Hide preloader
            document.getElementById('preloader')?.classList.add('d-none');
        });
}

// 3. Re-initialize plugins after AJAX load
function reinitPlugins() {
    // SimpleBar scrollbars
    document.querySelectorAll('[data-simplebar]').forEach(el => {
        new SimpleBar(el);
    });

    // Tooltips
    var tooltipTriggerList = [].slice.call(
        document.querySelectorAll('[data-bs-toggle="tooltip"]')
    );
    tooltipTriggerList.map(el => new bootstrap.Tooltip(el));

    // Counter animations
    document.querySelectorAll('.counter-value').forEach(counter => {
        // Animate counter to data-target value
    });

    // Chart reinitialization
    // ApexCharts read data-colors attributes and render
}
```

---

## 5. Skin-Specific Chart Colors

Fragment pages use `data-colors-*` attributes for theme-aware chart colors:

```html
<div id="customer_impression_charts"
     data-colors='["--vz-primary", "--vz-success", "--vz-danger"]'
     data-colors-minimal='["--vz-light", "--vz-primary", "--vz-info"]'
     data-colors-saas='["--vz-success", "--vz-info", "--vz-danger"]'
     data-colors-modern='["--vz-warning", "--vz-primary", "--vz-success"]'
     data-colors-interactive='["--vz-info", "--vz-primary", "--vz-danger"]'
     data-colors-creative='["--vz-warning", "--vz-primary", "--vz-danger"]'
     data-colors-corporate='["--vz-light", "--vz-primary", "--vz-secondary"]'
     data-colors-galaxy='["--vz-secondary", "--vz-primary", "--vz-primary-rgb, 0.50"]'
     data-colors-classic='["--vz-light", "--vz-primary", "--vz-secondary"]'
     data-colors-vintage='["--vz-success", "--vz-primary", "--vz-secondary"]'
     class="apex-charts" dir="ltr">
</div>
```

The chart init JS reads the active `data-theme` from `<html>` and picks the matching `data-colors-{theme}` attribute.

---

## 6. Counter Animation Pattern

Stat widgets use `counter-value` class with `data-target`:

```html
<h4 class="fs-22 fw-semibold ff-secondary mb-4">
    $<span class="counter-value" data-target="559.25">0</span>k
</h4>
```

The `app.js` animates from 0 to `data-target` on page load / AJAX content swap.

---

## 7. Complete Page List (163 fragments)

### Dashboards (8)
`index.html`, `dashboard-analytics.html`, `dashboard-crm.html`, `dashboard-crypto.html`, `dashboard-projects.html`, `dashboard-nft.html`, `dashboard-job.html`, `dashboard-blog.html`

### Apps (30+)
Calendar, Chat, Email, Mailbox, Ecommerce (products, cart, checkout, orders, sellers, details), CRM (contacts, companies, deals, leads), Crypto, Invoices, Projects, Tasks, File Manager, Todo, API Key, Job listings

### Pages (12+)
Profile, Team, Timeline, FAQs, Pricing, Gallery, Maintenance, Coming Soon, SiteMap, Search Results

### Authentication (20)
Login/Signup/Reset (Basic/Cover), Verification, Lock Screen, Logout, Errors (404/500)

### UI Elements (18)
Alerts, Badges, Buttons, Cards, Carousel, Colors, Dropdowns, Grid, Images, Lists, Modals, Offcanvas, Placeholders, Progress, Spinners, Tabs, Tooltips, Typography

### Advanced UI (9)
Animation, Highlight, Nestable, Ratings, Scrollbar, ScrollSpy, SweetAlerts, Swiper, Tour

### Forms (9), Tables (3), Charts (4), Icons (5), Maps (3), Widgets (1)

---

## 8. Adding a New Page (Ajax Variant)

### Step 1: Create HTML Fragment

```html
<!-- my-feature.html -->
<link href="assets/libs/some-plugin/style.css" rel="stylesheet" />

<div class="page-content">
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
                <div class="page-title-box d-sm-flex align-items-center justify-content-between">
                    <h4 class="mb-sm-0">My Feature</h4>
                    <div class="page-title-right">
                        <ol class="breadcrumb m-0">
                            <li class="breadcrumb-item"><a href="javascript:void(0);">Apps</a></li>
                            <li class="breadcrumb-item active">My Feature</li>
                        </ol>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h4 class="card-title mb-0">Content</h4>
                    </div>
                    <div class="card-body">
                        <!-- Your content -->
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="assets/js/pages/my-feature.init.js"></script>
```

### Step 2: Add Sidebar Menu Item

Edit sidebar in `index.html`:

```html
<li class="nav-item">
    <a class="nav-link menu-link" href="my-feature.html">
        <i class="ri-star-line"></i>
        <span>My Feature</span>
    </a>
</li>
```

### Step 3: Create Init Script (if needed)

```javascript
// assets/js/pages/my-feature.init.js
(function() {
    // Initialize plugins, charts, etc.
    // This runs after AJAX injection
})();
```

---

## 9. Comparison: Ajax vs React-TS vs HTML

| Aspect | Ajax | React-TS | HTML |
|--------|------|----------|------|
| **SPA?** | Pseudo-SPA | True SPA | No |
| **Rendering** | Server fragments | Client-side | Server full pages |
| **State** | DOM + JS vars | Redux | None (stateless) |
| **Navigation** | AJAX `fetch()` | React Router | Browser links |
| **Shell** | `index.html` (persistent) | `App.tsx` | Duplicated per page |
| **Plugin init** | Re-init after AJAX | React lifecycle | `DOMContentLoaded` |
| **Build** | Gulp/Webpack→CSS/JS | react-scripts | Gulp→CSS/JS |
| **Bundle** | Single app.js | Webpack chunks | Per-page scripts |
| **Menu** | Persistent | React component | Rendered per page |

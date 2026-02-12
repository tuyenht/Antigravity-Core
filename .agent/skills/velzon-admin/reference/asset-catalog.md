# Asset Catalog — Velzon Admin v4.4.1

Complete inventory of all assets required to build Velzon admin interfaces. Use this to recreate the full asset structure from scratch without the original source.

---

## 1. Image Assets

### 1.1 Root Images (`images/`)

| Filename | Purpose |
|----------|---------|
| `favicon.ico` | Browser tab icon |
| `logo-dark.png` | Dark logo (sidebar/header) |
| `logo-light.png` | Light logo (sidebar/header) |
| `logo-sm.png` | Small logo (collapsed sidebar) |
| `logo-sm-1.png` | Small logo variant |
| `auth-one-bg.jpg` | Auth page background |
| `bg-auth.jpg` | Auth page background alt |
| `cover-pattern.png` | Profile cover pattern |
| `profile-bg.jpg` | Profile background |
| `modal-bg.png` | Modal background |
| `chat-bg-pattern.png` | Chat page background pattern |
| `404-error.png` | 404 error illustration |
| `error400-cover.png` | 400 error cover |
| `error500.png` | 500 error illustration |
| `server-error.png` | Server error illustration |
| `error.svg` | Generic error SVG |
| `maintenance.png` | Maintenance page illustration |
| `coming-soon-img.png` | Coming soon illustration |
| `comingsoon.png` | Coming soon alt |
| `verification-img.png` | Email verification illustration |
| `about.jpg` | About page image |
| `faq-img.png` | FAQ page illustration |
| `widget-img.png` | Widget illustration |
| `giftbox.png` | Gift/promo illustration |
| `illustrator-1.png` | General illustration |
| `user-illustarator-1.png` | User illustration 1 |
| `user-illustarator-2.png` | User illustration 2 |
| `job-profile2.png` | Job profile illustration |
| `new-document.png` | New document icon |
| `new.png` | New item icon |
| `file.png` | File icon |
| `task.png` | Task illustration |
| `mac-img.png` | Mac device mock |
| `sorting.svg` | Sorting indicator |
| `bg-d.png` | Decorative background |

### 1.2 User Avatars (`images/users/`)

| Files | Description |
|-------|-------------|
| `avatar-1.jpg` → `avatar-10.jpg` | 10 user avatars (circular photos) |
| `multi-user.jpg` | Multi-user group avatar |
| `user-dummy-img.jpg` | Placeholder/default avatar |

### 1.3 Company Logos (`images/companies/`)

`img-1.png` → `img-9.png` — 9 abstract company logo icons (used in seller/vendor lists)

### 1.4 Product Images (`images/products/`)

`img-1.png` → `img-10.png` — 10 product photos (used in ecommerce pages)

### 1.5 Country Flags (`images/flags/`)

272 SVG flag icons named by ISO 3166-1 alpha-2 code: `ac.svg`, `ad.svg`, `ae.svg` ... `zw.svg`
Plus `select2/` subdirectory with smaller flag variants.

### 1.6 Brand Logos (`images/brands/`)

`bitbucket.png`, `dribbble.png`, `dropbox.png`, `github.png`, `mail_chimp.png`, `slack.png`

### 1.7 Client Logos (`images/clients/`)

`amazon.svg`, `google.svg`, `lenovo.svg`, `paypal.svg`, `shopify.svg`, `spotify.svg`, `verizon.svg`, `walmart.svg`

### 1.8 Blog Images (`images/blog/`)

`img-1.jpg` → `img-6.jpg`, `img-07.jpg`, `img-08.jpg`, `overview.jpg`

### 1.9 Thumbnails (`images/small/`)

`img-1.jpg` → `img-12.jpg` — Small gallery/thumbnail images

### 1.10 NFT Images (`images/nft/`)

Root: `add.png`, `bg-home.jpg`, `bg-pattern.png`, `img-01.jpg` → `img-06.jpg`, `marketplace.png`, `money.png`, `sell.png`, `wallet.png`
- `gif/` — Animated GIF NFTs
- `wallet/` — Crypto wallet icons

### 1.11 Layout Previews (`images/layouts/`)

`horizontal.png`, `vertical.png` — Layout type preview thumbnails

### 1.12 Demo Skin Previews (`images/demos/`)

`creative.png`, `default.png`, `interactive.png`, `material.png`, `minimal.png`, `modern.png`, `saas.png`

### 1.13 Sidebar Backgrounds (`images/sidebar/`)

`img-1.jpg` → `img-4.jpg` — Sidebar background images

### 1.14 Landing Page (`images/landing/`)

`bg-pattern.png`, `img-pattern.png`, `process-arrow-img.png`
- `features/` — Feature section images

### 1.15 Modal Backgrounds (`images/modals/`)

`login.png`, `signup.png`, `subscribe.png`, `success-payment.png`

### 1.16 SweetAlert2 (`images/sweetalert2/`)

`email-verify.png`, `error-message.png`, `join-community.png`, `notification-message.png`, `success-message.png`, `warning-message.png`

### 1.17 SVG Icons (`images/svg/`)

`bell.svg` — Notification bell
- `crypto-icons/` — SVG cryptocurrency icons

### 1.18 Galaxy Theme (`images/galaxy/`)

Galaxy-specific decorative images

### Image Placeholder Strategy

After deletion, use these approaches to replace images:
- **Avatars**: Use `https://api.dicebear.com/7.x/avataaars/svg?seed={name}` or `https://ui-avatars.com/api/?name={initials}`
- **Products**: Use `https://picsum.photos/200/200?random={n}` or generate with AI
- **Logos**: Generate SVG logos or use placeholder.com
- **Flags**: Install `flag-icons` npm package
- **Icons**: All icon fonts are available via npm (see Section 3)

---

## 2. Font Files (49 files)

### 2.1 HK Grotesk (Primary Body Font)

| Weight | Files |
|--------|-------|
| Light | `hkgrotesk-light.eot`, `.woff`, `.woff2` |
| Regular | `hkgrotesk-regular.eot`, `.woff`, `.woff2` |
| Medium | `hkgrotesk-medium.eot`, `.woff`, `.woff2` |
| SemiBold | `hkgrotesk-semibold.eot`, `.woff`, `.woff2` |
| Bold | `hkgrotesk-bold.ttf`, `.woff`, `.woff2` |

**CSS Variable**: `--vz-body-font-family: "HKGrotesk", sans-serif`
**SCSS File**: `scss/fonts/_fonts.scss`

### 2.2 Icon Fonts

| Library | Files | CSS Prefix |
|---------|-------|------------|
| **Remix Icon** | `remixicon.eot/.ttf/.woff/.woff2/.svg` + `.glyph.json` + `.symbol.svg` | `ri-*` |
| **BoxIcons** | `boxicons.eot/.ttf/.woff/.woff2/.svg` | `bx bx-*` |
| **Material Design Icons** | `materialdesignicons-webfont.eot/.ttf/.woff/.woff2` | `mdi mdi-*` |
| **Line Awesome** | `la-brands-400.*`, `la-regular-400.*`, `la-solid-900.*` (15 files) | `las la-*` |

### 2.3 Plugin Font

| Library | Files |
|---------|-------|
| **Summernote** | `summernote.eot/.ttf/.woff` |

### Font Installation

```bash
# Install via SCSS (already included in scss/icons.scss)
# Or install via CDN:
# Remix Icon
npm install remixicon
# or: <link href="https://cdn.jsdelivr.net/npm/remixicon@4.5.0/fonts/remixicon.css" rel="stylesheet">

# BoxIcons
npm install boxicons
# or: <link href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css" rel="stylesheet">

# Material Design Icons
npm install @mdi/font
# or: <link href="https://cdn.jsdelivr.net/npm/@mdi/font@7.4.47/css/materialdesignicons.min.css" rel="stylesheet">

# Line Awesome
# <link href="https://maxst.icons8.com/vue-static/lanern/line-awesome/line-awesome/1.3.0/css/line-awesome.min.css" rel="stylesheet">

# Feather Icons (React)
npm install feather-icons-react@^0.9.0

# Lord Icons (CDN only)
# <script src="https://cdn.lordicon.com/lordicon.js"></script>
```

---

## 3. SCSS File Tree (121+ files)

```
scss/
├── app.scss                    # Main entry: imports all partials
├── bootstrap.scss              # Bootstrap import + variable overrides
├── themes.scss                 # Theme entry (imported in App.tsx alongside app.scss)
├── icons.scss                  # All icon font imports
├── custom.scss                 # User custom overrides (empty, safe to modify)
├── mermaid.min.css             # GridJS table styling override
├── shepherd.css                # Tour/onboarding plugin styling
├── _variables.scss             # 70KB — ALL Bootstrap 5 variable overrides
├── _variables-custom.scss      # Velzon-specific CSS custom properties
├── _variables-dark.scss        # Dark mode variable overrides
├── _variables-galaxy-dark.scss # Galaxy theme dark mode variables
│
├── components/                 # 31 files — Bootstrap component overrides
│   ├── _root.scss              # CSS custom properties (--vz-*, 15KB core)
│   ├── _accordion.scss
│   ├── _alerts.scss
│   ├── _avatar.scss            # avatar-xs/sm/md/lg/xl sizing
│   ├── _badge.scss
│   ├── _breadcrumb.scss
│   ├── _buttons.scss           # btn-soft-*, btn-ghost-*, btn-label
│   ├── _card.scss              # card-animate, card-height-100
│   ├── _demos.scss
│   ├── _dropdown.scss
│   ├── _form-check.scss
│   ├── _form-control.scss
│   ├── _forms.scss
│   ├── _helper.scss
│   ├── _list-group.scss
│   ├── _modal.scss
│   ├── _nav.scss               # 12KB — tabs, pills, scrollspy nav
│   ├── _pagination.scss
│   ├── _popover.scss
│   ├── _preloader.scss
│   ├── _print.scss
│   ├── _progress.scss
│   ├── _reboot.scss
│   ├── _ribbons.scss
│   ├── _scrollspy.scss
│   ├── _table.scss
│   ├── _toast.scss
│   ├── _type.scss
│   ├── _utilities.scss
│   ├── _waves.scss
│   └── _widgets.scss           # stat card styles
│
├── fonts/
│   └── _fonts.scss             # @font-face declarations for HK Grotesk
│
├── structure/                  # 8 files — layout structural styles
│   ├── _vertical.scss          # 30KB — vertical sidebar layout
│   ├── _horizontal.scss        # Horizontal top-nav layout
│   ├── _two-column.scss        # Two-column sidebar layout
│   ├── _topbar.scss            # Header/topbar styling
│   ├── _footer.scss
│   ├── _general.scss           # General structural styles
│   ├── _layouts.scss           # Layout switching logic + semibox
│   └── _page-head.scss         # Page title + breadcrumb area
│
├── pages/                      # 22 files — per-page styles
│   ├── _dashboard.scss
│   ├── _authentication.scss
│   ├── _blog.scss
│   ├── _chat.scss
│   ├── _coming-soon.scss
│   ├── _ecommerce.scss
│   ├── _email.scss
│   ├── _errors.scss
│   ├── _file-manager.scss
│   ├── _gallery.scss
│   ├── _invoice.scss
│   ├── _job-landing.scss
│   ├── _jobs.scss
│   ├── _kanban.scss
│   ├── _landing.scss
│   ├── _nft-landing.scss
│   ├── _profile.scss
│   ├── _search-results.scss
│   ├── _sitemap.scss
│   ├── _team.scss
│   ├── _timeline.scss
│   └── _to-do.scss
│
├── plugins/                    # 31 files — third-party plugin overrides
│   ├── _apexcharts.scss        # 16KB — chart styling
│   ├── _autocomplete.scss
│   ├── _chartjs.scss
│   ├── _choices.scss           # Select dropdown styling
│   ├── _ckeditor.scss
│   ├── _colorpicker.scss
│   ├── _custom-scrollbar.scss
│   ├── _datatables.scss
│   ├── _dropzone.scss
│   ├── _echarts.scss
│   ├── _emoji-picker.scss
│   ├── _filepond.scss
│   ├── _flag-input.scss
│   ├── _flatpicker.scss        # 17KB — date picker
│   ├── _form-input-spin.scss
│   ├── _fullcalendar.scss
│   ├── _google-map.scss
│   ├── _gridjs.scss
│   ├── _leaflet-maps.scss
│   ├── _listjs.scss
│   ├── _multijs.scss
│   ├── _prismjs.scss
│   ├── _quilljs.scss
│   ├── _range-slider.scss
│   ├── _select2.scss
│   ├── _sortablejs.scss
│   ├── _sweetalert2.scss
│   ├── _swiper.scss
│   ├── _toastify.scss
│   ├── _tour.scss
│   └── _vector-maps.scss
│   └── icons/                  # 4 icon font SCSS files
│       ├── _boxicons.scss      # 94KB
│       ├── _line-awesome.scss  # 110KB
│       ├── _materialdesignicons.scss  # 409KB
│       └── _remixicon.scss     # 126KB
│
├── rtl/                        # 4 files — RTL layout overrides (mirrored styles)
│   ├── _components-rtl.scss
│   ├── _layouts-rtl.scss
│   ├── _pages-rtl.scss
│   └── _plugins-rtl.scss
│
└── theme/                      # 11 files — one per skin
    ├── _default.scss
    ├── _saas.scss
    ├── _material.scss
    ├── _creative.scss
    ├── _modern.scss
    ├── _minimal.scss
    ├── _interactive.scss
    ├── _galaxy.scss
    ├── _classic.scss
    ├── _corporate.scss
    └── _vintage.scss
```

### SCSS Build Order

```scss
// app.scss imports in this order:
@import "variables";
@import "variables-custom";
@import "bootstrap/scss/bootstrap";
@import "components/*";
@import "plugins/*";
@import "structure/*";
@import "pages/*";

// themes.scss (separate import in App.tsx):
@import "theme/*";  // loads all 11 skin files
```

---

## 4. JavaScript Plugins & Dependencies

### 4.1 Core Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `react` | ^19.1.0 | UI framework |
| `react-dom` | ^19.1.0 | DOM rendering |
| `react-router-dom` | ^7.6.0 | Client-side routing |
| `reactstrap` | ^9.2.3 | Bootstrap React components |
| `bootstrap` | 5.3.7 | CSS framework |
| `@reduxjs/toolkit` | ^2.8.2 | State management |
| `react-redux` | ^9.2.0 | React-Redux bindings |
| `redux` | ^5.0.1 | Store |
| `reselect` | ^5.1.1 | Memoized selectors |
| `typescript` | ^5.8.3 | Type safety |
| `sass` | 1.88.0 | SCSS compilation |

### 4.2 Chart & Visualization

| Package | Version | Purpose |
|---------|---------|---------|
| `apexcharts` | ^4.7.0 | Primary chart library |
| `react-apexcharts` | ^1.7.0 | React wrapper |
| `chart.js` | ^4.4.9 | Secondary chart library |
| `react-chartjs-2` | ^5.3.0 | Chart.js React wrapper |
| `echarts` | ^5.6.0 | Apache ECharts |
| `echarts-for-react` | ^3.0.2 | ECharts React wrapper |
| `@south-paw/react-vector-maps` | ^3.2.0 | Vector maps |

### 4.3 Tables & Lists

| Package | Version | Purpose |
|---------|---------|---------|
| `@tanstack/react-table` | ^8.21.3 | Data tables |
| `@tanstack/match-sorter-utils` | ^8.19.4 | Fuzzy matching |
| `gridjs` | ^6.2.0 | Grid.js tables |
| `gridjs-react` | ^6.1.1 | Grid.js React wrapper |

### 4.4 Forms & Input

| Package | Version | Purpose |
|---------|---------|---------|
| `formik` | ^2.4.6 | Form management |
| `yup` | ^1.6.1 | Schema validation |
| `react-flatpickr` | ^4.0.10 | Date picker |
| `react-select` | ^5.10.1 | Select dropdown (Choices.js equiv) |
| `cleave.js` | ^1.6.0 | Input masking |
| `react-dual-listbox` | ^6.0.3 | Dual listbox |
| `nouislider-react` | ^3.4.2 | Range slider |
| `@vtaits/react-color-picker` | ^2.0.0 | Color picker |
| `react-color` | ^2.19.3 | Color picker alt |
| `react-colorful` | ^5.6.1 | Color picker alt |
| `react-rating` | ^2.0.5 | Star ratings |

### 4.5 File Upload & Media

| Package | Version | Purpose |
|---------|---------|---------|
| `react-dropzone` | ^14.3.8 | Drag-drop upload |
| `filepond` | ^4.32.7 | File upload |
| `react-filepond` | ^7.1.3 | FilePond React wrapper |
| `filepond-plugin-image-preview` | ^4.6.12 | Image preview |
| `filepond-plugin-image-exif-orientation` | ^1.0.11 | EXIF orientation |
| `yet-another-react-lightbox` | ^3.23.1 | Image lightbox |
| `react-masonry-css` | ^1.0.16 | Masonry grid |
| `react-responsive-carousel` | ^3.2.23 | Carousel |
| `swiper` | ^11.2.6 | Swiper carousel |

### 4.6 Rich Text Editor

| Package | Version | Purpose |
|---------|---------|---------|
| `@ckeditor/ckeditor5-build-classic` | ^44.3.0 | CKEditor 5 |
| `@ckeditor/ckeditor5-react` | ^9.5.0 | CKEditor React wrapper |
| `quill` | ^2.0.3 | Quill editor |
| `react-quilljs` | ^2.0.5 | Quill React wrapper |

### 4.7 Calendar & Scheduling

| Package | Version | Purpose |
|---------|---------|---------|
| `@fullcalendar/core` | ^6.1.17 | Calendar core |
| `@fullcalendar/daygrid` | ^6.1.17 | Day grid view |
| `@fullcalendar/interaction` | ^6.1.17 | Drag/drop events |
| `@fullcalendar/list` | ^6.1.17 | List view |
| `@fullcalendar/multimonth` | ^6.1.17 | Multi-month view |
| `@fullcalendar/react` | ^6.1.17 | React wrapper |
| `@fullcalendar/bootstrap` | ^6.1.17 | Bootstrap theme |

### 4.8 Utilities

| Package | Version | Purpose |
|---------|---------|---------|
| `axios` | ^1.9.0 | HTTP client |
| `axios-mock-adapter` | ^2.1.0 | API mocking |
| `moment` | ^2.30.1 | Date formatting |
| `react-countup` | ^6.5.3 | Animated counters |
| `react-countdown` | ^2.3.6 | Countdown timer |
| `react-csv` | ^2.2.2 | CSV export |
| `react-toastify` | ^11.0.5 | Toast notifications |
| `simplebar-react` | ^3.3.1 | Custom scrollbar |
| `@hello-pangea/dnd` | ^18.0.1 | Drag and drop |
| `react-dragula` | ^1.1.17 | Drag and drop alt |
| `i18next` | ^25.1.3 | i18n core |
| `react-i18next` | ^15.5.1 | i18n React |
| `i18next-browser-languagedetector` | ^8.1.0 | Language detection |
| `prismjs` | ^1.30.0 | Code highlighting |
| `react-scrollspy` | ^3.4.3 | Scroll spy |
| `react-perfect-scrollbar` | ^1.5.8 | Perfect scrollbar |
| `feather-icons-react` | ^0.9.0 | Feather icons |
| `emoji-picker-react` | ^4.12.2 | Emoji picker |
| `aos` | ^2.3.4 | Animate on scroll |
| `firebase` | ^11.7.3 | Firebase (auth) |
| `@react-google-maps/api` | ^2.20.6 | Google Maps |
| `web-vitals` | ^5.0.1 | Performance metrics |
| `ajv` | ^8.17.1 | JSON validation |

### 4.9 Client-Side Libraries (Non-React — HTML/Ajax/Node variants)

These are loaded from `assets/libs/` in server-rendered variants:

| Library | Purpose | CDN/npm |
|---------|---------|---------|
| `apexcharts` | Charts | npm: `apexcharts` |
| `jsvectormap` | Vector maps | npm: `jsvectormap` |
| `swiper` | Carousels | npm: `swiper` |
| `simplebar` | Custom scrollbar | npm: `simplebar` |
| `flatpickr` | Date picker | npm: `flatpickr` |
| `choices.js` | Select dropdowns | npm: `choices.js` |
| `sweetalert2` | Alert dialogs | npm: `sweetalert2` |
| `sortablejs` | Drag & drop | npm: `sortablejs` |
| `list.js` | Searchable lists | npm: `list.js` |
| `lord-icon` | Animated icons | CDN: `cdn.lordicon.com/lordicon.js` |
| `glightbox` | Lightbox gallery | npm: `glightbox` |
| `isotope-layout` | Masonry grid | npm: `isotope-layout` |
| `shepherd.js` | Tour/guide | npm: `shepherd.js` |
| `nouislider` | Range slider | npm: `nouislider` |
| `prismjs` | Code highlighting | npm: `prismjs` |

---

## 5. data-attributes for Theme/Layout Control

All variants use HTML `data-*` attributes on `<html>` tag:

| Attribute | Values | Default |
|-----------|--------|---------|
| `data-layout` | `vertical`, `horizontal`, `twocolumn`, `semibox` | `vertical` |
| `data-topbar` | `light`, `dark` | `light` |
| `data-sidebar` | `dark`, `light`, `gradient`, `gradient-2`, `gradient-3`, `gradient-4` | `dark` |
| `data-sidebar-size` | `lg`, `sm`, `md`, `sm-hover` | `lg` |
| `data-sidebar-image` | `none`, `img-1`, `img-2`, `img-3`, `img-4` | `none` |
| `data-preloader` | `enable`, `disable` | `disable` |
| `data-theme` | `default`, `minimal`, `saas`, `modern`, `creative`, `interactive`, `corporate`, `galaxy`, `classic`, `vintage`, `material` | `default` |
| `data-theme-colors` | `default`, `minimal`, `saas`, `modern`, `creative`, `interactive`, `corporate`, `galaxy`, `classic`, `vintage` | `default` |
| `data-layout-width` | `fluid`, `boxed` | `fluid` |
| `data-layout-position` | `fixed`, `scrollable` | `fixed` |
| `data-layout-style` | `default`, `detached` | `default` |
| `data-bs-theme` | `light`, `dark` | `light` |

---

## 6. Recreating Full Asset Structure

To recreate the Velzon asset structure from scratch:

```bash
# 1. Create directory structure
mkdir -p src/assets/{images/{users,companies,products,flags,brands,clients,blog,small,nft,nft/gif,nft/wallet,layouts,demos,sidebar,landing/features,modals,sweetalert2,svg/crypto-icons,galaxy},fonts,scss/{components,fonts,pages,plugins/icons,rtl,structure,theme}}

# 2. Install icon fonts
npm install remixicon boxicons @mdi/font

# 3. Install core dependencies (from Section 4)
npm install bootstrap@5.3.7 reactstrap@^9.2.3 @reduxjs/toolkit@^2.8.2 ...

# 4. Copy SCSS from bootstrap and create Velzon overrides
# Start with _variables.scss overrides → components → structure → theme

# 5. Generate placeholder images or use AI image generation
# Use services listed in Section 1.18

# 6. Configure SCSS build (app.scss imports all partials in order from Section 3)
```

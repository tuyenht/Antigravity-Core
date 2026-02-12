# Design Tokens Reference

Complete design system tokens extracted from Velzon Admin v4.4.1 SCSS sources.
Use these exact values when building Velzon-compatible admin interfaces.

---

## CSS Variable Prefix

All Velzon custom properties use `--vz-` prefix:
```scss
$variable-prefix: vz-;
$prefix: $variable-prefix;
```

---

## 1. Color Palette

### Base Colors

| Name | Hex | Usage |
|------|-----|-------|
| Blue | `#3577f1` | Secondary theme color |
| Indigo | `#405189` | **Primary** theme color |
| Purple | `#6559cc` | Accent |
| Pink | `#f672a7` | Accent |
| Red | `#f06548` | Danger / Error |
| Orange | `#f1963b` | Accent |
| Yellow | `#f7b84b` | Warning |
| Green | `#0ab39c` | Success |
| Teal | `#02a8b5` | Accent |
| Cyan | `#299cdb` | Info |

### Theme Colors (Semantic)

| Token | Value | Hex |
|-------|-------|-----|
| `$primary` | `$indigo` | `#405189` |
| `$secondary` | `$blue` | `#3577f1` |
| `$success` | `$green` | `#0ab39c` |
| `$info` | `$cyan` | `#299cdb` |
| `$warning` | `$yellow` | `#f7b84b` |
| `$danger` | `$red` | `#f06548` |
| `$light` | `$gray-100` | `#f3f6f9` |
| `$dark` | `$gray-900` | `#212529` |

### Gray Scale

| Token | Hex | Usage |
|-------|-----|-------|
| `$gray-100` | `#f3f6f9` | Light bg, `$light` |
| `$gray-200` | `#eff2f7` | Tertiary bg |
| `$gray-300` | `#e9ebec` | Borders |
| `$gray-400` | `#ced4da` | Dark mode body text |
| `$gray-500` | `#adb5bd` | Muted text |
| `$gray-600` | `#878a99` | Secondary text, muted |
| `$gray-700` | `#495057` | Headings color |
| `$gray-800` | `#343a40` | Dark gray |
| `$gray-900` | `#212529` | Dark, body text |

### Subtle Backgrounds (Light Mode)

Generated via `tint-color($color, 85%)`:
```
bg-primary-subtle   → tint-color(#405189, 85%)
bg-secondary-subtle → tint-color(#3577f1, 85%)
bg-success-subtle   → tint-color(#0ab39c, 85%)
bg-info-subtle      → tint-color(#299cdb, 85%)
bg-warning-subtle   → tint-color(#f7b84b, 85%)
bg-danger-subtle    → tint-color(#f06548, 85%)
```

### Subtle Backgrounds (Dark Mode)

Generated via `rgba($color, 0.15)`:
```
bg-primary-subtle   → rgba(#405189, 0.15)
bg-secondary-subtle → rgba(#3577f1, 0.15)
bg-success-subtle   → rgba(#0ab39c, 0.15)
bg-info-subtle      → rgba(#299cdb, 0.15)
bg-warning-subtle   → rgba(#f7b84b, 0.15)
bg-danger-subtle    → rgba(#f06548, 0.15)
```

---

## 2. Body & Surface Colors

### Light Mode

| Token | Value |
|-------|-------|
| `$body-bg` | `#f3f3f9` |
| `$body-color` | `#212529` (gray-900) |
| `$body-secondary-color` | `#878a99` (gray-600) |
| `$body-secondary-bg` | `#fff` |
| `$body-tertiary-bg` | `#eff2f7` (gray-200) |
| `$border-color` | `#e9ebec` (gray-300) |

### Dark Mode

| Token | Value |
|-------|-------|
| `$body-bg-dark` | `#1a1d21` |
| `$body-color-dark` | `#ced4da` |
| `$body-secondary-color-dark` | `#878a99` |
| `$body-secondary-bg-dark` | `#212529` |
| `$border-color-dark` | `#32383e` |
| `$headings-color-dark` | `#ced4da` |

---

## 3. Typography

### Font Families
```css
--vz-font-family-primary    /* Primary font family */
--vz-font-family-secondary  /* Body text font family */
--vz-headings-font-family   /* Headings font family */
```

`$font-family-sans-serif` resolves to `var(--vz-font-family-secondary)`.

### Font Sizes (Custom Velzon Scale)
```scss
// Custom font size utilities: fs-10 through fs-48
$font-size-custom: (
  10: var(--vz-font-10),    // ~10px
  11: var(--vz-font-11),    // ~11px
  12: var(--vz-font-12),    // ~12px
  13: var(--vz-font-13),    // ~13px (common for badges, labels)
  14: var(--vz-font-14),    // ~14px (common for stats)
  15: var(--vz-font-15),    // ~15px
  16: var(--vz-font-16),    // ~16px (base)
  17: var(--vz-font-17),
  18: var(--vz-font-18),
  19: var(--vz-font-19),
  20: var(--vz-font-20),
  21: var(--vz-font-21),
  22: var(--vz-font-22),    // ~22px (common for stat numbers)
  23: var(--vz-font-23),
  24: var(--vz-font-24),
  36: var(--vz-font-36),
  48: var(--vz-font-48),
);
```

### Heading Sizes
```scss
$h1-font-size: base * 2.5;   // ~40px
$h2-font-size: base * 2;     // ~32px
$h3-font-size: base * 1.75;  // ~28px
$h4-font-size: base * 1.5;   // ~24px
$h5-font-size: base * 1.25;  // ~20px
$h6-font-size: base;         // ~16px
```

### Font Weights
```css
--vz-font-weight-light      /* light */
--vz-font-weight-normal     /* normal (400) */
--vz-font-weight-medium     /* medium (500) — fw-medium */
--vz-font-weight-semibold   /* semibold (600) — fw-semibold */
--vz-font-weight-bold       /* bold (700) */
```

### Line Heights
```scss
$line-height-base: 1.5;
$line-height-sm:   1.25;
$line-height-lg:   2;
$headings-line-height: 1.2;
```

---

## 4. Spacing

Standard Bootstrap 5 spacer scale:
```scss
$spacer: 1rem;
$spacers: (
  0: 0,          // 0px
  1: 0.25rem,    // 4px
  2: 0.5rem,     // 8px
  3: 1rem,       // 16px
  4: 1.5rem,     // 24px
  5: 3rem,       // 48px
);
```

---

## 5. Borders & Radius

```scss
$border-width:          1px;
$border-color:          #e9ebec;  // gray-300

$border-radius:         0.25rem;  // 4px
$border-radius-sm:      0.2rem;   // ~3px
$border-radius-lg:      0.3rem;   // ~5px
$border-radius-xl:      1rem;     // 16px
$border-radius-xxl:     2rem;     // 32px
$border-radius-pill:    50rem;    // pill
```

---

## 6. Shadows

```scss
$box-shadow:       0 1px 2px rgba(56, 65, 74, 0.15);
$box-shadow-sm:    0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
$box-shadow-lg:    0 5px 10px rgba(30, 32, 37, 0.12);

// Page title shadow (dark mode)
$page-title-box-shadow-dark: 0 1px 2px rgba(56, 65, 74, 0.15);

// Menu shadows
$horizontal-menu-box-shadow:  0 2px 4px rgba(15, 34, 58, 0.12);
$twocolumn-menu-box-shadow:   0 2px 4px rgba(15, 34, 58, 0.12);
```

---

## 7. Layout Dimensions

```scss
// Sidebar
$vertical-menu-width:       250px;   // Default expanded
$vertical-menu-width-md:    180px;   // Compact
$vertical-menu-width-sm:    70px;    // Small/icon only
$navbar-brand-box-width:    240px;   // Logo container

// Header
$header-height:             70px;

// Footer
$footer-height:             60px;

// TwoColumn
$twocolumn-menu-iconview-width: 70px;
$twocolumn-menu-width:          220px;

// Boxed
$boxed-layout-width:        1300px;
$semibox-width:             110px;
```

---

## 8. Buttons & Forms

```scss
// Button padding
$input-btn-padding-y:       0.5rem;
$input-btn-padding-x:       0.9rem;

// Small
$input-btn-padding-y-sm:    0.25rem;
$input-btn-padding-x-sm:    0.5rem;

// Large
$input-btn-padding-y-lg:    0.7rem;
$input-btn-padding-x-lg:    1.2rem;

// Button transitions
$btn-transition: color .15s ease-in-out, background-color .15s ease-in-out,
                 border-color .15s ease-in-out, box-shadow .15s ease-in-out;
```

---

## 9. Table Tokens

```scss
$table-cell-padding-y:      0.75rem;
$table-cell-padding-x:      0.6rem;
$table-cell-padding-y-sm:   0.3rem;
$table-cell-padding-x-sm:   0.25rem;
$table-th-font-weight:      semibold;
$table-hover-bg-factor:     0.04;
$table-striped-bg-factor:   0.02;
```

---

## 10. Grid System

```scss
$grid-columns:     12;
$grid-breakpoints: (
  xs: 0,
  sm: 576px,
  md: 768px,
  lg: 992px,
  xl: 1200px,
  xxl: 1400px,
);
$container-max-widths: (
  sm: 540px,
  md: 720px,
  lg: 960px,
  xl: 1140px,
  xxl: 1320px,
);
```

---

## 11. Dark Mode Implementation

Dark mode uses `data-bs-theme="dark"` attribute on `<html>`:

```scss
@include color-mode(dark, true) {
  // Override CSS variables for dark mode
  --vz-body-bg: #1a1d21;
  --vz-body-color: #ced4da;
  --vz-border-color: #32383e;
  // ... all overrides
}
```

### Header (Dark Mode)
```scss
$header-bg-dark:          #292e32;
$header-item-color-dark:  #e9ecef;
$header-item-bg-dark:     #31363c;
```

### Sidebar (Dark Mode)
```scss
// Light sidebar in dark mode
$vertical-menu-bg-dark:                 #fff;
$vertical-menu-item-color-dark:         darken(gray-600, 10%);

// Dark sidebar in dark mode (data-sidebar="dark")
$dark-vertical-menu-bg-dark:            #212529;
$dark-vertical-menu-item-color-dark:    #7c7f90;
$dark-vertical-menu-item-hover-color:   #fff;
```

### Dropdown (Dark Mode)
```scss
$dropdown-bg-dark:                #292e33;
$dropdown-link-color-dark:        #adb5bd;
$dropdown-link-hover-bg-dark:     #2f343a;
```

### Footer (Dark Mode)
```scss
$footer-bg-dark:    #212529;
$footer-color-dark: #878a99;
```

---

## 12. Sidebar Gradients

4 gradient presets for sidebar background:

```scss
// Gradient 1: Primary → Success
linear-gradient(to right, var(--vz-primary), var(--vz-success));

// Gradient 2: Info → Secondary
linear-gradient(to right, var(--vz-info), var(--vz-secondary));

// Gradient 3: Info → Success
linear-gradient(to right, var(--vz-info), var(--vz-success));

// Gradient 4: Dark → Primary
linear-gradient(to right, #1a1d21, var(--vz-primary));
```

---

## 13. Auth Page Gradient

```scss
$auth-bg-cover: linear-gradient(-45deg, var(--vz-primary) 50%, var(--vz-success));
```

---

## 14. Bootstrap Options (Feature Flags)

```scss
$enable-caret:               false;
$enable-rounded:             true;
$enable-shadows:             false;
$enable-gradients:           false;
$enable-transitions:         true;
$enable-negative-margins:    true;
$enable-dark-mode:           true;
$color-mode-type:            data;    // Uses data attributes, not prefers-color-scheme
$min-contrast-ratio:         1.75;
```

---

## Usage Notes

### CSS Variables in Components
When writing TSX, reference colors via Bootstrap CSS variables:
```tsx
// Correct: Use utility classes
<div className="bg-primary-subtle text-primary">...</div>

// Correct: Use CSS variable in inline styles (rare)
<div style={{ color: 'var(--vz-primary)' }}>...</div>

// Wrong: Don't hardcode hex values
<div style={{ color: '#405189' }}>...</div>
```

### Theme Switching
Dark mode is toggled by setting `data-bs-theme="dark"` on `<html>` via Redux:
```tsx
dispatch(changeLayoutMode("dark"));
// Sets: document.documentElement.setAttribute("data-bs-theme", "dark");
```

### Skin Switching
Skins are applied via `data-theme` attribute on `<html>`:
```tsx
dispatch(changeTheme("material"));
// Sets: document.documentElement.setAttribute("data-theme", "material");
```

---

## 15. Theme Skin Palettes

Each skin overrides theme colors, fonts, body-bg, and card styling. Applied via `data-theme="[name]"` on `<html>`.

### Quick Reference — All 11 Skins

| Skin | Primary | Secondary | Success | Danger | Warning | Info | Dark | Light | body-bg | Font |
|------|---------|-----------|---------|--------|---------|------|------|-------|---------|------|
| **default** | `#405189` | `#3577f1` | `#0ab39c` | `#f06548` | `#f7b84b` | `#299cdb` | `#212529` | `#f3f6f9` | `#f3f3f9` | HK Grotesk + Poppins |
| **material** | `#4b38b3` | `#3577f1` | `#45CB85` | `#f06548` | `#ffbe0b` | `#299cdb` | `#212529` | `#f1f4f7` | `#f2f2f7` | Inter |
| **saas** | `#6691e7` | `#865ce2` | `#13c56b` | `#ed5e5e` | `#e8bc52` | `#50c3e6` | `#363d48` | `#f1f4f7` | `#f3f6f9` | Montserrat + Rubik |
| **creative** | `#3d78e3` | `#5b71b9` | `#67b173` | `#f17171` | `#ffc84b` | `#29badb` | `#495057` | `#f1f4f7` | `#f3f3f9` | Nunito |
| **modern** | `#5ea3cb` | `#7084c7` | `#6ada7d` | `#fa896b` | `#f7b84b` | `#58caea` | `#212529` | `#f1f4f7` | `#f1f1f1` | IBM Plex Sans |
| **minimal** | `#25a0e2` | `#878a99` | `#00bd9d` | `#f06548` | `#FFBC0A` | `#32ccff` | `#343a40` | `#f1f4f7` | `#ffffff` | Open Sans |
| **interactive** | `#695eef` | `#5596f7` | `#11d1b7` | `#ff7f41` | `#ffc061` | `#73dce9` | `#343a40` | `#f1f4f7` | `#f7f7f9` | Outfit |
| **galaxy** | `#8c68cd` | `#4788ff` | `#40bb82` | `#ee6352` | `#ffca5b` | `#3fa7d6` | `#212529` | `#f1f4f7` | `transparent` | Saira |
| **classic** | `#7c4baf` | `#2fa2ff` | `#3cd188` | `#f04770` | `#fa9e34` | `#2db0b5` | `#272a3a` | `#f1f4f7` | `#f5f6f9` | Jost |
| **corporate** | `#687cfe` | `#ff7f5d` | `#3cd188` | `#f7666e` | `#e8bc52` | `#0ac7fb` | `#272a3a` | `#f1f4f7` | `#fbf7f4` | Public Sans |
| **vintage** | `#119cf1` | `#7967e9` | `#83d159` | `#ef697f` | `#fbb740` | `#58caea` | `#212529` | `#f1f4f7` | `#f4f8f9` | Roboto |

### Per-Skin Detail

#### Default (`data-theme="default"`)

**Font:** HK Grotesk (bundled, no Google import)
```css
--vz-font-family-primary: 'hkgrotesk', sans-serif;
--vz-font-family-secondary: 'Poppins', sans-serif;
```
**Sidebar dark:** `var(--vz-primary)` (#405189) | **Topbar dark:** `var(--vz-primary)` (#405189)
**Card:** border-width=`0`, shadow=`$box-shadow` | **Headings weight:** `500`
**Theme-Colors:** green=`$green-700`, purple=`$purple-600`, blue=`$blue-600` (Bootstrap vars)

---

#### Material (`data-theme="material"`)

**Google Font:** `https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap`
```css
--vz-font-family-primary: 'Inter', sans-serif;
--vz-font-family-secondary: 'Inter', sans-serif;
```
**Sidebar dark:** `#151529` | **Topbar dark:** `#1C1C36`
**Card:** border-width=`0`, shadow=`0 3px 3px rgba(56,65,74,0.1)` | **Headings weight:** `500`
**Theme-Colors:** green=`$green-600`, purple=`$purple-600`, blue=`$blue-600`

---

#### SaaS (`data-theme="saas"`)

**Google Font:** `https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700&family=Rubik:wght@300;400;500;600;700&display=swap`
```css
--vz-font-family-primary: 'Rubik', sans-serif;
--vz-font-family-secondary: 'Montserrat', sans-serif;
--vz-headings-font-family: 'Montserrat', sans-serif;
```
**Special:** `font-weight-medium: 400`, `font-weight-semibold: 500` (differs from other skins!)
**Sidebar dark:** `#38454a` | **Topbar dark:** `#38454a`
**Sidebar gradient variant:** `linear-gradient(to right, var(--vz-primary), var(--vz-success))` (via `data-sidebar="gradient"`)
**Card:** border-width=`0`, shadow=`$box-shadow` | **Headings weight:** `600`
**Theme-Colors:** green=`#198754`, purple=`#6c3bdb`, blue=`#00b4d8`

---

#### Creative (`data-theme="creative"`)

**Google Font:** `https://fonts.googleapis.com/css2?family=Nunito:wght@300;400;500;600;700&display=swap`
```css
--vz-font-family-primary: 'Nunito', sans-serif;
--vz-font-family-secondary: 'Nunito', sans-serif;
```
**Sidebar dark:** `#1f2c3e` | **Topbar dark:** `#2c3a4e`
**Card:** border-width=`0`, shadow=`$box-shadow` | **Headings weight:** `600`
**Theme-Colors:** green=`$green-600`, purple=`$purple-600`, blue=`$blue-600`

---

#### Modern (`data-theme="modern"`)

**Google Font:** `https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@300;400;500;600;700&display=swap`
```css
--vz-font-family-primary: 'IBM Plex Sans', sans-serif;
--vz-font-family-secondary: 'IBM Plex Sans', sans-serif;
```
**Sidebar dark:** `#2e3230` | **Topbar dark:** `#323835`
**Card:** border-width=`0`, shadow=`$box-shadow` | **Headings weight:** `600`
**Theme-Colors:** green=`$green-400`, purple=`$purple-400`, blue=`#00b4d8`

---

#### Minimal (`data-theme="minimal"`)

**Google Font:** `https://fonts.googleapis.com/css2?family=Open+Sans:wght@300;400;500;600;700&display=swap`
```css
--vz-font-family-primary: 'Open Sans', sans-serif;
--vz-font-family-secondary: 'Open Sans', sans-serif;
```
**Sidebar dark:** `#0A2B3D` | **Topbar dark:** `#133b50`
**Card:** border-width=`1px`, shadow=`none`, border-radius=`0` | **Headings weight:** `600`
**Theme-Colors:** green=`$green-600`, purple=`$purple-600`, blue=`$blue-600`

---

#### Interactive (`data-theme="interactive"`)

**Google Font:** `https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap`
```css
--vz-font-family-primary: 'Outfit', sans-serif;
--vz-font-family-secondary: 'Outfit', sans-serif;
```
**Sidebar dark:** `#132649` | **Topbar dark:** `#132649`
**Card:** border-width=`0`, shadow=`$box-shadow` | **Headings weight:** `500`
**Theme-Colors:** green=`$green-400`, purple=`$purple-400`, blue=`#00b4d8`

---

#### Galaxy (`data-theme="galaxy"`)

**Google Font:** `https://fonts.googleapis.com/css2?family=Saira:wght@300;400;500;600;700&display=swap`
```css
--vz-font-family-primary: 'Saira', sans-serif;
--vz-font-family-secondary: 'Saira', sans-serif;
```
**UNIQUE BEHAVIOR:** Transparent body + card backgrounds. Uses background images via `data-body-image` attribute.
```css
--vz-body-bg: transparent;
--vz-card-bg: transparent;
--vz-card-cap-bg: transparent;
```
**Body images:** `data-body-image="img-1|img-2|img-3"` → `chat-bg-pattern.png`, `galaxy/img-4.png`, `galaxy/img-5.png`
**Card:** border-width=`1px`, shadow=`$box-shadow`, bg=`transparent`, has decorative `::before`/`::after` corner borders
**Sidebar dark:** `rgb(72, 38, 104)` (#482668) | **Topbar dark:** `#2c3a4e`
**Headings weight:** `500` | **Base font-size:** `0.8512rem` (13.6px, unique)
**Theme-Colors:** green=`$green-600`, purple=`#f4a261`, blue=`$blue-600`

---

#### Classic (`data-theme="classic"`)

**Google Font:** `https://fonts.googleapis.com/css2?family=Jost:wght@300;400;500;600;700&display=swap`
```css
--vz-font-family-primary: 'Jost', sans-serif;
--vz-font-family-secondary: 'Jost', sans-serif;
```
**Sidebar dark:** `shade-color(#7c4baf, 60%)` | **Topbar dark:** `darken(#7c4baf, 25%)`
**Card:** border-width=`0`, shadow=`rgb(0,0,0,0.04) 0px 6px 24px 0px` | **Headings weight:** `600`
**Special:** `page-title-box` has `background: transparent`, custom margin/padding
**Theme-Colors (w/ secondary overrides):**
| Variant | Primary | Secondary |
|---------|---------|-----------|
| green | `#348f6c` | `#f1cfa3` |
| purple | `#9b5de5` | `#f15bb5` |
| blue | `#00bbf9` | `#0582ca` |

---

#### Corporate (`data-theme="corporate"`)

**Google Font:** `https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700&display=swap`
```css
--vz-font-family-primary: 'Public Sans', sans-serif;
--vz-font-family-secondary: 'Public Sans', sans-serif;
```
**Sidebar dark:** `shade-color(#687cfe, 60%)` | **Topbar dark:** `#687cfe` (primary itself)
**Card:** border-width=`0`, shadow=`rgba(100,98,92,0.06) 0 0 15px 4px` | **Headings weight:** `600`
**Theme-Colors (w/ secondary overrides):**
| Variant | Primary | Secondary |
|---------|---------|-----------|
| green | `#348f6c` | `#f1cfa3` |
| purple | `#9b5de5` | `#f15bb5` |
| blue | `#00bbf9` | `#0582ca` |

---

#### Vintage (`data-theme="vintage"`)

**Google Font:** `https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap`
```css
--vz-font-family-primary: 'Roboto', sans-serif;
--vz-font-family-secondary: 'Roboto', sans-serif;
```
**UNIQUE BEHAVIOR:** Transparent topbar/header by default (light mode)
```css
--vz-header-bg: transparent;
--vz-topbar-search-bg: transparent;
```
**Sidebar dark:** `#2e3230` | **Topbar dark:** `#323835`
**Card:** border-width=`0`, shadow=`var(--vz-shadow)` = `rgb(0,0,0,0.04) 0px 6px 24px 0px`
**Headings weight:** `500` | **Note:** font-weight-semibold=`600` (Roboto lacks 600, falls to 700)
**Special:** `page-title-box` has `background: transparent`, `#page-topbar.topbar-shadow` gets secondary-bg
**Theme-Colors:** green=`#a5b96f`, purple=`#9f86c0`, blue=`#6096ba`

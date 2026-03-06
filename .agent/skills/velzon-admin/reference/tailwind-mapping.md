# Velzon → Tailwind CSS Mapping

> Mapping từ `source/scss/_variables*.scss` sang Tailwind CSS config.
> Dùng cho các dự án chọn Tailwind thay Bootstrap.

---

## Color Palette

| Velzon Token | SCSS Value | Tailwind Name | Tailwind Value |
|---|---|---|---|
| `$primary` / `$indigo` | `#405189` | `primary` | `'#405189'` |
| `$secondary` / `$blue` | `#3577f1` | `secondary` | `'#3577f1'` |
| `$success` / `$green` | `#0ab39c` | `success` | `'#0ab39c'` |
| `$info` / `$cyan` | `#299cdb` | `info` | `'#299cdb'` |
| `$warning` / `$yellow` | `#f7b84b` | `warning` | `'#f7b84b'` |
| `$danger` / `$red` | `#f06548` | `danger` | `'#f06548'` |
| `$light` / `$gray-100` | `#f3f6f9` | `light` | `'#f3f6f9'` |
| `$dark` / `$gray-900` | `#212529` | `dark` | `'#212529'` |
| `$purple` | `#6559cc` | `purple` | `'#6559cc'` |
| `$pink` | `#f672a7` | `pink` | `'#f672a7'` |
| `$teal` | `#02a8b5` | `teal` | `'#02a8b5'` |
| `$orange` | `#f1963b` | `orange` | `'#f1963b'` |

### Gray Scale

| SCSS | Value | Tailwind |
|---|---|---|
| `$gray-100` | `#f3f6f9` | `gray.100` |
| `$gray-200` | `#eff2f7` | `gray.200` |
| `$gray-300` | `#e9ebec` | `gray.300` |
| `$gray-400` | `#ced4da` | `gray.400` |
| `$gray-500` | `#adb5bd` | `gray.500` |
| `$gray-600` | `#878a99` | `gray.600` |
| `$gray-700` | `#495057` | `gray.700` |
| `$gray-800` | `#343a40` | `gray.800` |
| `$gray-900` | `#212529` | `gray.900` |

---

## Body & Background

| Token | Light Mode | Dark Mode | Tailwind |
|---|---|---|---|
| `$body-bg` | `#f3f3f9` | `#1a1d21` | `bg-body` |
| `$body-color` | `#212529` | `#ced4da` | `text-body` |
| `$body-secondary-bg` | `#fff` | `#212529` | `bg-body-secondary` |

---

## Typography

| Property | Value | Tailwind Equivalent |
|---|---|---|
| Font Family (Primary) | `Poppins, sans-serif` | `fontFamily: { sans: ['Poppins', ...defaultTheme.fontFamily.sans] }` |
| Font Size Base | `0.8125rem` (13px) | `text-[13px]` |
| Headings Font Weight | `600` | `font-semibold` |
| Line Height Base | `1.5` | `leading-normal` |

### Custom Font Sizes

| SCSS Token | Value | Tailwind |
|---|---|---|
| `font-10` | `0.625rem` | `text-[10px]` |
| `font-11` | `0.6875rem` | `text-[11px]` |
| `font-12` | `0.75rem` | `text-xs` |
| `font-13` | `0.8125rem` | `text-[13px]` |
| `font-14` | `0.875rem` | `text-sm` |
| `font-15` | `0.9375rem` | `text-[15px]` |
| `font-16` | `1rem` | `text-base` |
| `font-17` | `1.0625rem` | `text-[17px]` |
| `font-18` | `1.125rem` | `text-lg` |
| `font-20` | `1.25rem` | `text-xl` |
| `font-22` | `1.375rem` | `text-[22px]` |
| `font-24` | `1.5rem` | `text-2xl` |

---

## Layout Dimensions

| Component | Variable | Value | Tailwind |
|---|---|---|---|
| Sidebar (lg) | `$vertical-menu-width` | `250px` | `w-[250px]` |
| Sidebar (md) | `$vertical-menu-width-md` | `180px` | `w-[180px]` |
| Sidebar (sm/icon) | `$vertical-menu-width-sm` | `70px` | `w-[70px]` |
| Navbar Brand Box | `$navbar-brand-box-width` | `240px` | `w-[240px]` |
| Header Height | `$header-height` | `70px` | `h-[70px]` |
| Footer Height | `$footer-height` | `60px` | `h-[60px]` |
| Boxed Layout | `$boxed-layout-width` | `1300px` | `max-w-[1300px]` |
| TwoColumn Icon View | `$twocolumn-menu-iconview-width` | `70px` | `w-[70px]` |
| TwoColumn Menu | `$twocolumn-menu-width` | `220px` | `w-[220px]` |
| Semibox Width | `$semibox-width` | `110px` | `w-[110px]` |

---

## Sidebar Item Spacing

| Variable | Value | Tailwind |
|---|---|---|
| `$vertical-menu-item-padding-x` | `1.5rem` | `px-6` |
| `$vertical-menu-item-padding-y` | `0.625rem` | `py-2.5` |
| `$vertical-menu-item-icon-width` | `1.75rem` | `w-7` |
| `$vertical-menu-sub-item-padding-x` | `1.5rem` | `px-6` |
| `$vertical-menu-sub-item-padding-y` | `0.55rem` | `py-[0.55rem]` |

---

## Shadows

| Variable | Value | Tailwind |
|---|---|---|
| `$box-shadow` | `0 1px 2px rgba(56,65,74,0.15)` | `shadow-sm` (override) |
| `$box-shadow-lg` | `0 5px 10px rgba(30,32,37,0.12)` | `shadow-lg` (override) |
| `$element-shadow` | `var(--vz-element-shadow)` | CSS variable |

---

## Border Radius

| Variable | Value | Tailwind |
|---|---|---|
| `$border-radius` | `0.25rem` | `rounded` |
| `$border-radius-sm` | `0.2rem` | `rounded-sm` |
| `$border-radius-lg` | `0.3rem` | `rounded-md` |

---

## Dark Mode

| Token | Value | Usage |
|---|---|---|
| Body BG | `#1a1d21` | `dark:bg-[#1a1d21]` |
| Body Color | `#ced4da` | `dark:text-[#ced4da]` |
| Secondary BG | `#212529` | `dark:bg-[#212529]` |
| Border | `#32383e` | `dark:border-[#32383e]` |
| Header BG | `#292e32` | `dark:bg-[#292e32]` |
| Footer BG | `#212529` | `dark:bg-[#212529]` |
| Sidebar Dark BG | `#212529` | `dark:bg-[#212529]` |
| Dropdown BG | `#292e33` | `dark:bg-[#292e33]` |

---

## Tailwind Config Template

```ts
// tailwind.config.ts
import type { Config } from 'tailwindcss';
import defaultTheme from 'tailwindcss/defaultTheme';

const config: Config = {
    darkMode: ['selector', '[data-bs-theme="dark"]'],
    theme: {
        extend: {
            colors: {
                primary:   { DEFAULT: '#405189', dark: '#364474' },
                secondary: { DEFAULT: '#3577f1', dark: '#2d61c4' },
                success:   { DEFAULT: '#0ab39c', dark: '#099885' },
                info:      { DEFAULT: '#299cdb', dark: '#2384ba' },
                warning:   { DEFAULT: '#f7b84b', dark: '#e5a93b' },
                danger:    { DEFAULT: '#f06548', dark: '#d6573e' },
                purple:    '#6559cc',
                pink:      '#f672a7',
                teal:      '#02a8b5',
                vz: {
                    body:     '#f3f3f9',
                    dark:     '#1a1d21',
                    card:     '#fff',
                    'card-dark': '#212529',
                },
            },
            fontFamily: {
                sans: ['Poppins', ...defaultTheme.fontFamily.sans],
            },
            fontSize: {
                '2xs': '0.625rem',  // 10px
                '3xs': '0.6875rem', // 11px
                'vz':  '0.8125rem', // 13px (Velzon base)
            },
            width: {
                sidebar:    '250px',
                'sidebar-md': '180px',
                'sidebar-sm': '70px',
            },
            height: {
                header: '70px',
                footer: '60px',
            },
            maxWidth: {
                boxed: '1300px',
            },
            zIndex: {
                sidebar: '1002',
            },
        },
    },
};

export default config;
```

---

> **Source of truth:** `source/scss/_variables.scss`, `_variables-custom.scss`, `_variables-dark.scss`

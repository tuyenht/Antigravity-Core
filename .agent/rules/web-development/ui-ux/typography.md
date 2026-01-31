# Web Fonts & Typography Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Standards:** CSS Fonts Level 4, Variable Fonts, WOFF2
> **Priority:** P2 - Load for typography-focused projects

---

You are an expert in web fonts, typography, and font performance optimization.

## Key Principles

- Optimize font loading for performance (< 100ms FOUT)
- Use WOFF2 as primary format
- Implement proper fallback fonts with metric matching
- Ensure readability and accessibility
- Use variable fonts to reduce file count
- Subset fonts for smaller file sizes

---

## @font-face Declaration

### Modern Font Face
```css
@font-face {
  font-family: 'Inter';
  src: url('/fonts/Inter.woff2') format('woff2'),
       url('/fonts/Inter.woff') format('woff');
  font-weight: 100 900;  /* Variable font weight range */
  font-style: normal;
  font-display: swap;
  
  /* Metric overrides for CLS prevention */
  size-adjust: 100%;
  ascent-override: 90%;
  descent-override: 20%;
  line-gap-override: 0%;
  
  /* Subsetting */
  unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC;
}

/* Italic variant */
@font-face {
  font-family: 'Inter';
  src: url('/fonts/Inter-Italic.woff2') format('woff2');
  font-weight: 100 900;
  font-style: italic;
  font-display: swap;
}
```

### Font Display Values
```css
/* font-display options */
@font-face {
  font-display: auto;       /* Browser default */
  font-display: block;      /* Short block period, infinite swap */
  font-display: swap;       /* Minimal block, infinite swap (recommended for body) */
  font-display: fallback;   /* Short block, short swap (recommended for icons) */
  font-display: optional;   /* Minimal block, no swap (best for CLS) */
}
```

| Value | Block Period | Swap Period | Use Case |
|-------|--------------|-------------|----------|
| `swap` | ~100ms | Infinite | Body text, high importance |
| `optional` | ~100ms | None | Non-critical, prevents CLS |
| `fallback` | ~100ms | ~3s | Balanced approach |
| `block` | ~3s | Infinite | Icon fonts (avoid) |

---

## Font Metric Overrides (CLS Prevention)

### Match Fallback Metrics
```css
/* Override fallback font metrics to match web font */
@font-face {
  font-family: 'Inter';
  src: url('/fonts/Inter.woff2') format('woff2');
  font-display: swap;
  
  /* Adjust to match system fallback */
  size-adjust: 107%;       /* Scale to match x-height */
  ascent-override: 92%;    /* Match ascender height */
  descent-override: 22%;   /* Match descender depth */
  line-gap-override: 0%;   /* Match line spacing */
}

/* Apply with fallback stack */
body {
  font-family: 'Inter', 'Inter-fallback', system-ui, sans-serif;
}

/* Fallback font with adjustments */
@font-face {
  font-family: 'Inter-fallback';
  src: local('Arial');
  size-adjust: 107%;
  ascent-override: 90%;
  descent-override: 22%;
  line-gap-override: 0%;
}
```

### Calculate Overrides
```javascript
// Use fontaine or capsize to calculate overrides
// npm install @capsizecss/metrics

import { createStyleString } from '@capsizecss/core';
import inter from '@capsizecss/metrics/inter';
import arial from '@capsizecss/metrics/arial';

// Generate CSS with matched metrics
const css = createStyleString({
  fontMetrics: inter,
  fallbackFontMetrics: arial,
  fontSize: 16,
  lineHeight: 24
});
```

---

## Variable Fonts

### Basic Variable Font
```css
@font-face {
  font-family: 'Inter Variable';
  src: url('/fonts/InterVariable.woff2') format('woff2-variations');
  font-weight: 100 900;
  font-stretch: 75% 125%;
  font-style: oblique 0deg 10deg;
  font-display: swap;
}

/* Usage */
.light { font-weight: 300; }
.regular { font-weight: 400; }
.medium { font-weight: 500; }
.bold { font-weight: 700; }
.black { font-weight: 900; }
```

### Custom Axes
```css
/* Variable font with custom axes */
.custom-weight {
  font-variation-settings: 
    'wght' 450,    /* Weight */
    'wdth' 100,    /* Width */
    'slnt' -5,     /* Slant */
    'opsz' 16;     /* Optical size */
}

/* Prefer high-level properties when available */
.prefer-properties {
  font-weight: 450;
  font-stretch: 100%;
  font-style: oblique -5deg;
  font-optical-sizing: auto;  /* Auto-adjust for size */
}
```

### Optical Sizing
```css
/* Auto-adjust optical size based on font-size */
body {
  font-optical-sizing: auto;  /* Enabled by default */
}

/* Manual control */
.small-text {
  font-size: 12px;
  font-variation-settings: 'opsz' 12;
}

.large-heading {
  font-size: 72px;
  font-variation-settings: 'opsz' 72;
}
```

### Animating Variable Fonts
```css
@keyframes weight-pulse {
  0%, 100% { font-weight: 400; }
  50% { font-weight: 700; }
}

.animate-weight {
  animation: weight-pulse 2s ease-in-out infinite;
}

/* Transition on hover */
.hover-bold {
  font-weight: 400;
  transition: font-weight 0.2s ease;
}

.hover-bold:hover {
  font-weight: 700;
}
```

---

## Font Loading

### Preload Critical Fonts
```html
<head>
  <!-- Preload only critical fonts (1-2 max) -->
  <link 
    rel="preload" 
    href="/fonts/Inter-Regular.woff2" 
    as="font" 
    type="font/woff2" 
    crossorigin
  >
  
  <!-- Preconnect if using external fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
</head>
```

### Font Loading API
```javascript
// Check if fonts are loaded
document.fonts.ready.then(() => {
  console.log('All fonts loaded');
  document.body.classList.add('fonts-loaded');
});

// Load specific fonts
async function loadFonts() {
  const font = new FontFace(
    'Inter',
    'url(/fonts/Inter.woff2)',
    {
      weight: '400',
      style: 'normal',
      display: 'swap'
    }
  );
  
  try {
    await font.load();
    document.fonts.add(font);
    document.body.classList.add('fonts-loaded');
  } catch (error) {
    console.error('Font loading failed:', error);
  }
}

// Check if specific font is available
async function isFontLoaded(family) {
  await document.fonts.ready;
  return document.fonts.check(`16px "${family}"`);
}

// Load multiple fonts
async function loadAllFonts() {
  const fonts = [
    new FontFace('Inter', 'url(/fonts/Inter-Regular.woff2)', { weight: '400' }),
    new FontFace('Inter', 'url(/fonts/Inter-Bold.woff2)', { weight: '700' }),
    new FontFace('Inter', 'url(/fonts/Inter-Italic.woff2)', { weight: '400', style: 'italic' })
  ];
  
  const results = await Promise.allSettled(fonts.map(f => f.load()));
  
  results.forEach((result, i) => {
    if (result.status === 'fulfilled') {
      document.fonts.add(fonts[i]);
    }
  });
  
  document.body.classList.add('fonts-loaded');
}
```

### FOUT with a Class (Recommended)
```css
/* Initial state - use fallback */
body {
  font-family: system-ui, -apple-system, sans-serif;
}

/* After fonts loaded */
.fonts-loaded body {
  font-family: 'Inter', system-ui, sans-serif;
}

/* Prevent layout shift with matched metrics */
.fonts-loaded h1 {
  letter-spacing: -0.02em;  /* Adjust if needed */
}
```

```javascript
// Add class when fonts are loaded
if ('fonts' in document) {
  document.fonts.ready.then(() => {
    document.documentElement.classList.add('fonts-loaded');
  });
} else {
  // Fallback for older browsers
  document.documentElement.classList.add('fonts-loaded');
}
```

---

## Typography Scale

### Modular Scale
```css
:root {
  /* Base size */
  --font-size-base: 1rem;     /* 16px */
  
  /* Scale ratio: 1.25 (Major Third) */
  --font-size-xs: 0.64rem;    /* 10.24px */
  --font-size-sm: 0.8rem;     /* 12.8px */
  --font-size-md: 1rem;       /* 16px */
  --font-size-lg: 1.25rem;    /* 20px */
  --font-size-xl: 1.563rem;   /* 25px */
  --font-size-2xl: 1.953rem;  /* 31.25px */
  --font-size-3xl: 2.441rem;  /* 39px */
  --font-size-4xl: 3.052rem;  /* 48.83px */
  --font-size-5xl: 3.815rem;  /* 61px */
}
```

### Fluid Typography with clamp()
```css
:root {
  /* Fluid scale: min at 320px, max at 1200px */
  --font-size-base: clamp(1rem, 0.875rem + 0.5vw, 1.125rem);
  --font-size-lg: clamp(1.125rem, 1rem + 0.5vw, 1.25rem);
  --font-size-xl: clamp(1.25rem, 1rem + 1vw, 1.5rem);
  --font-size-2xl: clamp(1.5rem, 1.25rem + 1.25vw, 2rem);
  --font-size-3xl: clamp(1.875rem, 1.5rem + 1.5vw, 2.5rem);
  --font-size-4xl: clamp(2.25rem, 1.75rem + 2vw, 3rem);
  --font-size-5xl: clamp(3rem, 2rem + 3vw, 4.5rem);
}

/* Usage */
h1 { font-size: var(--font-size-4xl); }
h2 { font-size: var(--font-size-3xl); }
h3 { font-size: var(--font-size-2xl); }
h4 { font-size: var(--font-size-xl); }
p { font-size: var(--font-size-base); }
small { font-size: var(--font-size-sm); }
```

### Calculate Fluid Values
```javascript
// Generate clamp() value
function fluidSize(minSize, maxSize, minViewport = 320, maxViewport = 1200) {
  const slope = (maxSize - minSize) / (maxViewport - minViewport);
  const yAxisIntersection = minSize - slope * minViewport;
  
  return `clamp(${minSize}rem, ${yAxisIntersection.toFixed(4)}rem + ${(slope * 100).toFixed(4)}vw, ${maxSize}rem)`;
}

// Example: fluidSize(1, 1.5) => "clamp(1rem, 0.8182rem + 0.9091vw, 1.5rem)"
```

---

## Line Height & Spacing

### Line Height Scale
```css
:root {
  --leading-none: 1;
  --leading-tight: 1.25;
  --leading-snug: 1.375;
  --leading-normal: 1.5;      /* Body text */
  --leading-relaxed: 1.625;
  --leading-loose: 2;
}

/* Size-dependent line height */
h1 {
  font-size: var(--font-size-4xl);
  line-height: var(--leading-tight);  /* Larger text needs less line height */
}

p {
  font-size: var(--font-size-base);
  line-height: var(--leading-normal);  /* Body text needs more */
}

small {
  font-size: var(--font-size-sm);
  line-height: var(--leading-relaxed);  /* Small text needs even more */
}
```

### Letter & Word Spacing
```css
:root {
  --tracking-tighter: -0.05em;
  --tracking-tight: -0.025em;
  --tracking-normal: 0;
  --tracking-wide: 0.025em;
  --tracking-wider: 0.05em;
  --tracking-widest: 0.1em;
}

/* Large headings often need tighter tracking */
h1, h2 {
  letter-spacing: var(--tracking-tight);
}

/* Small caps and uppercase need wider tracking */
.uppercase {
  text-transform: uppercase;
  letter-spacing: var(--tracking-wider);
}

.small-caps {
  font-variant-caps: small-caps;
  letter-spacing: var(--tracking-wide);
}
```

---

## Text Wrapping (CSS 2024)

### text-wrap: balance
```css
/* Balance line lengths in headings */
h1, h2, h3 {
  text-wrap: balance;
  max-inline-size: 25ch;  /* Limit width for balance to work well */
}

/* Pretty wrapping for paragraphs */
p {
  text-wrap: pretty;  /* Avoids orphans and widows */
}

/* Fallback for unsupported browsers */
@supports not (text-wrap: balance) {
  h1, h2, h3 {
    /* Alternative approach */
    max-width: 20ch;
  }
}
```

### Line Length (Measure)
```css
/* Optimal reading: 45-75 characters */
.prose {
  max-inline-size: 65ch;  /* ~65 characters */
}

.narrow-column {
  max-inline-size: 45ch;
}

.wide-column {
  max-inline-size: 75ch;
}
```

---

## Font Stacks

### System Font Stack
```css
:root {
  --font-system: system-ui, -apple-system, BlinkMacSystemFont, 
    'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 
    'Open Sans', 'Helvetica Neue', sans-serif;
  
  --font-mono: ui-monospace, SFMono-Regular, 'SF Mono', Menlo, 
    Consolas, 'Liberation Mono', monospace;
  
  --font-serif: ui-serif, Georgia, Cambria, 
    'Times New Roman', Times, serif;
}

body {
  font-family: var(--font-system);
}

code, pre {
  font-family: var(--font-mono);
}
```

### Custom Font with Fallbacks
```css
:root {
  --font-sans: 'Inter', 'Inter-fallback', system-ui, sans-serif;
  --font-heading: 'Playfair Display', 'Georgia', serif;
  --font-mono: 'JetBrains Mono', 'Fira Code', ui-monospace, monospace;
}
```

---

## Google Fonts Optimization

### Optimized Loading
```html
<!-- Preconnect first -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

<!-- Load with display=swap and subset -->
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;700&display=swap&subset=latin" rel="stylesheet">
```

### Self-Hosting (Better Performance)
```bash
# Download fonts with google-webfonts-helper
# https://google-webfonts-helper.herokuapp.com/

# Or use fontsource
npm install @fontsource/inter

# Import in CSS/JS
import '@fontsource/inter/400.css';
import '@fontsource/inter/700.css';
```

```css
/* Self-hosted with subset */
@font-face {
  font-family: 'Inter';
  src: url('/fonts/inter-v12-latin-regular.woff2') format('woff2');
  font-weight: 400;
  font-style: normal;
  font-display: swap;
  unicode-range: U+0000-00FF;  /* Latin Basic */
}
```

---

## Accessibility

### Readable Defaults
```css
body {
  /* Minimum 16px for body text */
  font-size: clamp(1rem, 0.95rem + 0.25vw, 1.125rem);
  
  /* Comfortable line height */
  line-height: 1.5;
  
  /* Allow user scaling */
  text-size-adjust: 100%;
  -webkit-text-size-adjust: 100%;
}

/* Never use font-size smaller than this */
.min-readable {
  font-size: max(1rem, 16px);
}
```

### Contrast Requirements
```css
/* WCAG AA: 4.5:1 for normal text, 3:1 for large text */
/* WCAG AAA: 7:1 for normal text, 4.5:1 for large text */

:root {
  --color-text: #1a1a1a;        /* High contrast on white */
  --color-text-muted: #666;     /* 5.74:1 on white */
  --color-bg: #ffffff;
}

/* Large text (18px+ bold, or 24px+ normal) */
.large-text {
  color: #767676;  /* 4.54:1 - meets AA for large text */
}
```

### Dyslexia-Friendly Options
```css
/* User preference for increased letter spacing */
@media (prefers-reduced-motion: no-preference) {
  .dyslexia-friendly {
    font-family: 'OpenDyslexic', 'Comic Sans MS', sans-serif;
    letter-spacing: 0.1em;
    word-spacing: 0.2em;
    line-height: 1.8;
  }
}
```

---

## Performance Checklist

### Font Loading
- [ ] Use WOFF2 format (30% smaller than WOFF)
- [ ] Subset fonts to needed characters
- [ ] Preload critical fonts (1-2 max)
- [ ] Use `font-display: swap` or `optional`
- [ ] Implement metric overrides for CLS prevention
- [ ] Use variable fonts to reduce requests

### Typography
- [ ] Limit to 2-3 font families
- [ ] Use fluid typography with clamp()
- [ ] Maintain 45-75 character line length
- [ ] Use 1.4-1.6 line height for body text
- [ ] Ensure 4.5:1 contrast ratio minimum
- [ ] Test with browser font size increased to 200%

### File Sizes
| Font Type | Target Size |
|-----------|-------------|
| Variable | < 100KB |
| Static weight | < 30KB |
| Icon font | < 50KB (prefer SVG) |

---

**References:**
- [CSS Fonts Level 4](https://www.w3.org/TR/css-fonts-4/)
- [Variable Fonts Guide](https://variablefonts.io/)
- [web.dev Font Best Practices](https://web.dev/font-best-practices/)
- [Google Fonts API](https://developers.google.com/fonts/docs/css2)
- [Fontsource](https://fontsource.org/)

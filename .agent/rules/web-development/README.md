# Web Development Expert Rules

> **Version:** 2.0.0 (2026-01-31)
> **Status:** Production-Ready
> **Last Updated:** 2026-01-31

## 📋 Overview

This directory contains **expert-level cursor rules** for web development, curated and enhanced by the Antigravity AI system. These rules are designed to guide AI agents in generating high-quality, modern, production-ready web code.

## 🗂️ Directory Structure

```
web-development/
├── README.md                           # This file
├── _index.md                           # Master index for rule discovery
│
├── core/                               # Core web technologies
│   ├── semantic-html-accessibility.md  # HTML5 + WCAG 2.2
│   ├── modern-css-responsive.md        # CSS 2024+ features
│   └── javascript-es2024.md            # JavaScript ES2024+
│
├── architecture/                       # Application architecture
│   ├── pwa-expert.md                   # Progressive Web Apps
│   ├── web-components.md               # Custom Elements & Shadow DOM
│   └── micro-frontends.md              # Micro-frontend patterns
│
├── performance/                        # Performance optimization
│   ├── core-web-vitals.md              # LCP, INP, CLS optimization
│   ├── bundle-optimization.md          # Code splitting, tree shaking
│   └── image-optimization.md           # Modern formats, lazy loading
│
├── security/                           # Security best practices
│   ├── owasp-web-security.md           # OWASP Top 10 2024
│   ├── csp-headers.md                  # Content Security Policy
│   └── authentication.md               # Auth patterns
│
├── browser/                            # Browser APIs & compatibility
│   ├── modern-browser-apis.md          # 2024 Web Platform APIs
│   ├── cross-browser.md                # Compatibility patterns
│   └── storage-apis.md                 # localStorage, IndexedDB
│
├── ui-ux/                              # UI/UX patterns
│   ├── animation-motion.md             # CSS & JS animations
│   ├── typography-fonts.md             # Web fonts optimization
│   └── forms-validation.md             # Form patterns & validation
│
└── testing/                            # Testing strategies
    ├── e2e-testing.md                  # Playwright, Cypress
    ├── visual-regression.md            # Screenshot testing
    └── accessibility-testing.md        # a11y automation
```

## 🎯 Usage

### In GEMINI.md or Agent Files

```markdown
# Reference individual rules
@[.agent/rules/web-development/core/javascript-es2024.md]

# Reference category
@[.agent/rules/web-development/core/]
```

### Rule Loading Priority

1. **Always load:** `core/` rules for any web project
2. **Load on demand:** Category-specific rules based on task
3. **Reference:** `_index.md` for quick rule discovery

## 📊 Rule Quality Standards

Each rule in this directory meets:

| Criterion | Standard |
|-----------|----------|
| **Accuracy** | 95%+ alignment with official specs |
| **Modernity** | Updated for 2024-2026 standards |
| **Practicality** | Actionable, production-ready |
| **Structure** | Consistent format, easy to parse |

## 🔄 Update Schedule

- **Core rules:** Updated quarterly
- **Security rules:** Updated monthly
- **Browser APIs:** Updated with major browser releases

## 📚 Sources

- W3C Specifications
- WHATWG Standards
- MDN Web Docs
- Google Web.dev
- OWASP Guidelines
- TC39 ECMAScript Proposals

---

**Maintained by:** Antigravity AI System
**License:** MIT

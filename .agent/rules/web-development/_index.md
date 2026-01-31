# Web Development Rules Index

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> Quick reference for all web development expert rules.
> Use this index for rule discovery and loading.

## 📊 Statistics

| Category | Rules | Status |
|----------|-------|--------|
| Core | 3 | ✅ Complete |
| Architecture | 1 | ✅ Complete |
| Performance | 1 | ✅ Complete |
| Security | 1 | ✅ Complete |
| Browser | 1 | ✅ Complete |
| UI/UX | 1 | ✅ Complete |
| **Total** | **8** | **Production-Ready** |

---

## 🔷 Core Technologies (P0 - Always Load)

Essential rules for every web project.

| Rule | File | Tags |
|------|------|------|
| **Semantic HTML & Accessibility** | `core/semantic-html-accessibility.md` | HTML5, A11Y, WCAG 2.2, ARIA |
| **Modern CSS & Responsive** | `core/modern-css-responsive.md` | CSS 2024, Grid, Flexbox, Container Queries, Nesting |
| **JavaScript ES2024+** | `core/javascript-es2024.md` | ES2024, Async, Modules, Classes |

### Quick Load
```markdown
@[.agent/rules/web-development/core/semantic-html-accessibility.md]
@[.agent/rules/web-development/core/modern-css-responsive.md]
@[.agent/rules/web-development/core/javascript-es2024.md]
```

---

## 🏗️ Architecture (P1 - Load for Apps)

Application architecture patterns.

| Rule | File | Tags |
|------|------|------|
| **Progressive Web Apps** | `architecture/pwa-expert.md` | PWA, Service Worker, Workbox, Offline |

### Quick Load
```markdown
@[.agent/rules/web-development/architecture/pwa-expert.md]
```

---

## ⚡ Performance (P0 - Critical)

Performance optimization and Core Web Vitals.

| Rule | File | Tags |
|------|------|------|
| **Core Web Vitals** | `performance/core-web-vitals.md` | LCP, INP, CLS, Lighthouse |

### Quick Load
```markdown
@[.agent/rules/web-development/performance/core-web-vitals.md]
```

---

## 🔒 Security (P0 - Critical)

Security best practices and OWASP guidelines.

| Rule | File | Tags |
|------|------|------|
| **OWASP Web Security** | `security/owasp-web-security.md` | OWASP, XSS, CSRF, CSP, Headers |

### Quick Load
```markdown
@[.agent/rules/web-development/security/owasp-web-security.md]
```

---

## 🌐 Browser (P1 - Advanced Features)

Modern browser APIs and web platform features.

| Rule | File | Tags |
|------|------|------|
| **Modern Browser APIs** | `browser/modern-browser-apis.md` | APIs, Observers, File System, View Transitions |

### Quick Load
```markdown
@[.agent/rules/web-development/browser/modern-browser-apis.md]
```

---

## 🎨 UI/UX (P1 - Interactive Features)

User interface and experience patterns.

| Rule | File | Tags |
|------|------|------|
| **Forms & Validation** | `ui-ux/forms-validation.md` | Forms, Validation, UX, A11Y |

### Quick Load
```markdown
@[.agent/rules/web-development/ui-ux/forms-validation.md]
```

---

## 📋 Priority Legend

| Priority | Description | When to Load |
|----------|-------------|--------------|
| **P0** | Critical | Always load for web projects |
| **P1** | Important | Load for relevant features |
| **P2** | Optional | Load on demand |

---

## 🏷️ Tag-Based Loading

Load rules by project type or feature:

```yaml
# Full web project
web_project:
  - core/semantic-html-accessibility.md
  - core/modern-css-responsive.md
  - core/javascript-es2024.md
  - performance/core-web-vitals.md
  - security/owasp-web-security.md

# PWA project
pwa_project:
  - core/*
  - architecture/pwa-expert.md
  - performance/core-web-vitals.md

# Form-heavy application
form_app:
  - core/semantic-html-accessibility.md
  - ui-ux/forms-validation.md
  - security/owasp-web-security.md

# Performance audit
performance_audit:
  - performance/core-web-vitals.md

# Security audit
security_audit:
  - security/owasp-web-security.md

# Advanced web features
advanced_features:
  - browser/modern-browser-apis.md
```

---

## 🔄 Update Log

| Date | Version | Changes |
|------|---------|---------|
| 2026-01-31 | 2.0.0 | Initial release with 8 expert rules |

---

**Maintained by:** Antigravity AI System

---
name: i18n-localization
description: "Giải pháp ứng dụng đa ngôn ngữ (i18n), quản lý bản dịch và hỗ trợ đa quốc."
allowed-tools: Read, Glob, Grep
---

# i18n & Localization

> Internationalization (i18n) and Localization (L10n) best practices.

---

## 1. Core Concepts

| Term | Meaning |
|------|---------|
| **i18n** | Internationalization - making app translatable |
| **L10n** | Localization - actual translations |
| **Locale** | Language + Region (en-US, tr-TR) |
| **RTL** | Right-to-left languages (Arabic, Hebrew) |

---

## 2. When to Use i18n

| Project Type | i18n Needed? |
|--------------|--------------|
| Public web app | ✅ Yes |
| SaaS product | ✅ Yes |
| Internal tool | ⚠️ Maybe |
| Single-region app | ⚠️ Consider future |
| Personal project | ❌ Optional |

---

## 3. Implementation Patterns

### React (react-i18next)

```tsx
import { useTranslation } from 'react-i18next';

function Welcome() {
  const { t } = useTranslation();
  return <h1>{t('welcome.title')}</h1>;
}
```

### Next.js (next-intl)

```tsx
import { useTranslations } from 'next-intl';

export default function Page() {
  const t = useTranslations('Home');
  return <h1>{t('title')}</h1>;
}
```

### Python (gettext)

```python
from gettext import gettext as _

print(_("Welcome to our app"))
```

---

## 4. File Structure

```
locales/
├── en/
│   ├── common.json
│   ├── auth.json
│   └── errors.json
├── tr/
│   ├── common.json
│   ├── auth.json
│   └── errors.json
└── ar/          # RTL
    └── ...
```

---

## 5. Best Practices

### DO ✅

- Use translation keys, not raw text
- Namespace translations by feature
- Support pluralization
- Handle date/number formats per locale
- Plan for RTL from the start
- Use ICU message format for complex strings

### DON'T ❌

- Hardcode strings in components
- Concatenate translated strings
- Assume text length (German is 30% longer)
- Forget about RTL layout
- Mix languages in same file
- Read `document.cookie` in `useState` initializer (see § 6)

---

## 6. Next.js App Router: SSR Hydration Rules

> [!CAUTION]
> These rules are **MANDATORY** for Next.js App Router projects using custom i18n.
> Violating any rule causes React hydration mismatch and flash of wrong language.

### Rule 1: NEVER read `document.cookie` in `useState` initializer

```tsx
// ❌ BAD — Hydration mismatch: server='en', client='vi'
const [locale, setLocale] = useState(() => {
    const cookie = document.cookie.match(/locale=(\w+)/);
    return cookie?.[1] ?? 'en';
});

// ✅ GOOD — Accept from server props, fallback in useEffect
const [locale, setLocale] = useState(initialLocale ?? 'en');
```

### Rule 2: ALWAYS read locale on server via `cookies()`

```typescript
import { cookies } from 'next/headers';

export async function getServerLocale() {
    const cookieStore = await cookies();
    const locale = cookieStore.get('locale')?.value ?? 'en';
    const messages = (await import(`@/locales/${locale}.json`)).default;
    return { locale, messages };
}
```

### Rule 3: Pass `initialLocale` + `initialMessages` from server to client

```tsx
// page.tsx (async Server Component)
export default async function Page() {
    const { locale, messages } = await getServerLocale();
    return <ClientComponent initialLocale={locale} initialMessages={messages} />;
}
```

---

## 7. Common Issues

| Issue | Solution |
|-------|----------|
| Missing translation | Fallback to default language |
| Hardcoded strings | Use linter/checker script |
| Date format | Use Intl.DateTimeFormat |
| Number format | Use Intl.NumberFormat |
| Pluralization | Use ICU message format |
| Hydration mismatch | Read locale on server, pass as props (see § 6) |

---

## 8. RTL Support

```css
/* CSS Logical Properties */
.container {
  margin-inline-start: 1rem;  /* Not margin-left */
  padding-inline-end: 1rem;   /* Not padding-right */
}

[dir="rtl"] .icon {
  transform: scaleX(-1);
}
```

---

## 8. Checklist

Before shipping:

- [ ] All user-facing strings use translation keys
- [ ] Locale files exist for all supported languages
- [ ] Date/number formatting uses Intl API
- [ ] RTL layout tested (if applicable)
- [ ] Fallback language configured
- [ ] No hardcoded strings in components

---

## Script

| Script | Purpose | Command |
|--------|---------|---------|
| `scripts/i18n_checker.py` | Detect hardcoded strings & missing translations | `python scripts/i18n_checker.py <project_path>` |

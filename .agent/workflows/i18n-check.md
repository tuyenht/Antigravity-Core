---
description: "Kiểm tra chuỗi đa ngôn ngữ (i18n) và độ bao phủ bản dịch."
---

# /i18n-check — Internationalization Checker

// turbo-all

Scan project for hardcoded strings, missing translations, and i18n coverage across all locales.

**Agent:** `frontend-specialist`  
**Skills:** `i18n-localization`, `clean-code`

---

## Pre-Check: Detect i18n Setup

```
Auto-detect:
├── i18next.config + React/Next.js  → scan for t(), useTranslation()
├── vue-i18n + Vue/Nuxt             → scan for $t(), useI18n()
├── @nuxtjs/i18n + Nuxt             → scan for $t(), nuxt.config i18n
├── Laravel lang/ directory          → scan for __(), @lang(), trans()
├── ASP.NET + IStringLocalizer       → scan for _localizer[]
├── Flutter + .arb files             → scan for AppLocalizations
└── Không có i18n                    → Đề xuất setup + skip scan
```

---

## Step 1: Run Scanner

```bash
python .agent/skills/i18n-localization/scripts/i18n_checker.py --root .
```

---

## Step 2: Hardcoded Strings Detection

Scan tất cả UI files cho text không được wrap bởi i18n function:

```
Files scanned:
├── *.tsx / *.jsx    → JSX text content
├── *.vue            → <template> text content
├── *.blade.php      → Blade template text
├── *.dart           → Widget text properties
└── *.html           → Template text
```

### Exceptions (không phải hardcoded):
- Tên biến, tên class, tên function
- Console.log / debug messages
- Test files
- Config files
- URLs, email addresses
- Numbers, currency codes

---

## Step 3: Translation Coverage

For each locale file, check:

- [ ] **Key coverage:** Mỗi key trong default locale có translation ở tất cả locales
- [ ] **Unused keys:** Keys trong locale files nhưng không dùng trong code
- [ ] **Missing keys:** Keys dùng trong code nhưng thiếu trong locale files
- [ ] **Placeholder consistency:** `{name}` / `{{name}}` / `:name` nhất quán

### Coverage Report Format
```
┌─────────────┬──────────┬─────────┬────────┐
│ Locale      │ Keys     │ Missing │ Cover  │
├─────────────┼──────────┼─────────┼────────┤
│ en (base)   │ 245      │ 0       │ 100%   │
│ vi          │ 245      │ 12      │ 95.1%  │
│ ja          │ 245      │ 45      │ 81.6%  │
└──────────┴──────────┴─────────┴────────┘
```

---

## Step 4: Pluralization Check

- [ ] Plural forms handled (`one` / `other` / `few` / `many`)
- [ ] ICU MessageFormat used correctly (nếu applicable)
- [ ] Number formatting locale-aware (`Intl.NumberFormat` / `number_format()`)
- [ ] Date formatting locale-aware (`Intl.DateTimeFormat` / `Carbon::locale()`)

---

## Step 5: RTL (Right-to-Left) Check

Nếu project support RTL locales (Arabic, Hebrew, etc.):

- [ ] CSS `direction: rtl` hoặc `[dir="rtl"]` selectors exist
- [ ] Logical CSS properties used (`margin-inline-start` thay vì `margin-left`)
- [ ] Icons/images mirrored where needed
- [ ] Text alignment correct

---

## Step 6: CI Integration Guidance

### GitHub Action
```yaml
# .github/workflows/i18n-check.yml
name: i18n Check
on: [pull_request]
jobs:
  i18n:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: python .agent/skills/i18n-localization/scripts/i18n_checker.py --root . --ci
```

### Pre-commit Hook
```bash
# .husky/pre-commit (add to existing)
npx i18n-check || echo "⚠️ i18n issues found"
```

---

## Step 7: Auto-Fix (Optional)

Nếu user confirm:

1. **Extract hardcoded strings** → thêm vào locale file với `TODO` marker
2. **Generate missing translations** → copy key with `[NEEDS_TRANSLATION]` prefix
3. **Remove unused keys** → clean up locale files
4. **Sort keys** alphabetically cho consistency

```bash
# Example: extract hardcoded → locale
# "Welcome back" → t('dashboard.welcomeBack')
# en.json: { "dashboard": { "welcomeBack": "Welcome back" } }
# vi.json: { "dashboard": { "welcomeBack": "[NEEDS_TRANSLATION] Welcome back" } }
```

---

## Output Report

```markdown
## i18n Health Report

### Score: XX/100

| Category | Score | Issues |
|----------|-------|--------|
| Hardcoded strings | X/30 | [count] found |
| Translation coverage | X/30 | [lowest]% |
| Pluralization | X/15 | [count] missing |
| RTL support | X/10 | [status] |
| Unused keys | X/15 | [count] found |
```

---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| Scanner misses framework | Specify framework: `--framework react` / `--framework vue` / `--framework laravel` |
| False positive on hardcoded | Add to `.i18nignore` file or use `// i18n-ignore` comment |
| Large locale file performance | Split by namespace: `common.json`, `auth.json`, `dashboard.json` |




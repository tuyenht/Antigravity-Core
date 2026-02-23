---
description: Kiểm tra i18n strings và translation coverage
---

# /i18n-check — Internationalization Checker

// turbo-all

Scan project for hardcoded strings, missing translations, and i18n coverage.

## Steps

### Step 1: Detect i18n Setup

```
Auto-detect:
├── i18next (React/Next.js)       → scan for t(), useTranslation()
├── vue-i18n (Vue/Nuxt)           → scan for $t(), useI18n()
├── Laravel localization          → scan for __(), @lang()
├── ASP.NET IStringLocalizer      → scan for _localizer[]
└── Không có i18n                 → Báo cáo + đề xuất setup
```

### Step 2: Run Scanner

```bash
python .agent/skills/i18n-localization/scripts/i18n_checker.py --root .
```

### Step 3: Review Results

**Output:** Report with:
- Hardcoded strings found (file + line)
- Missing translation keys per locale
- Coverage percentage per locale
- Unused translation keys

### Step 4: Fix (optional)

If user confirms, auto-extract hardcoded strings → add to locale files with TODO markers.

**Agent:** `frontend-specialist`

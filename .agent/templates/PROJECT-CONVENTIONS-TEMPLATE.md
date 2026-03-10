# CONVENTIONS — {Project Name}

> **Version:** 1.0 | **Updated:** {date}
> **Source:** Auto-extracted from codebase analysis

---

## 1. Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| **Files** | {kebab-case / PascalCase / etc.} | `user-profile.tsx` |
| **Components** | {PascalCase} | `UserProfile` |
| **Functions** | {camelCase} | `getUserById` |
| **Variables** | {camelCase} | `isLoading` |
| **Constants** | {UPPER_SNAKE} | `MAX_RETRY_COUNT` |
| **DB Tables** | {snake_case / plural} | `user_profiles` |
| **DB Columns** | {snake_case} | `created_at` |
| **CSS Classes** | {BEM / Tailwind / Velzon} | `.card__header--active` |
| **Routes** | {kebab-case} | `/user-management` |
| **API Endpoints** | {kebab-case / plural} | `GET /api/users` |

---

## 2. Code Patterns

### File Structure Pattern
```
// Each feature module follows:
feature/
├── components/     ← UI components
├── hooks/          ← Custom hooks (React) / Composables (Vue)
├── lib/            ← Business logic, utilities
├── types/          ← TypeScript interfaces
└── __tests__/      ← Co-located tests
```

### Import Order
```typescript
// 1. External packages
import { useState } from 'react';
import { z } from 'zod';

// 2. Internal aliases (@/)
import { Button } from '@/components/ui';
import { cn } from '@/lib/utils';

// 3. Relative imports
import { UserForm } from './UserForm';
import type { User } from './types';
```

### Error Handling Pattern
```
{Describe project-specific error handling approach}
```

---

## 3. Git Conventions

| Rule | Standard |
|------|----------|
| **Branch naming** | `{type}/{ticket}-{description}` (e.g., `feat/AG-123-user-auth`) |
| **Commit format** | Conventional Commits: `{type}({scope}): {message}` |
| **Types** | `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf` |
| **PR policy** | {Review required / Auto-merge / etc.} |

---

## 4. Testing Conventions

| Type | Tool | Location | Naming |
|------|------|----------|--------|
| **Unit** | {Vitest / Jest / PHPUnit / pytest} | `__tests__/` or `tests/unit/` | `*.test.ts` or `*.spec.ts` |
| **Integration** | {same or different tool} | `tests/integration/` | `*.integration.test.ts` |
| **E2E** | {Playwright / Cypress} | `tests/e2e/` | `*.e2e.ts` |
| **Coverage Target** | ≥ {80}% | — | — |

### Test Pattern
```
// AAA Pattern (Arrange → Act → Assert)
describe('{Unit}', () => {
  it('should {expected behavior}', () => {
    // Arrange
    // Act
    // Assert
  });
});
```

---

## 5. API Conventions

| Rule | Standard |
|------|----------|
| **Style** | {REST / GraphQL / tRPC} |
| **Versioning** | {URL prefix `/api/v1/` / Header / None} |
| **Response format** | `{ data, error, meta }` |
| **Error format** | RFC 7807 Problem Details |
| **Auth header** | `Authorization: Bearer {token}` |
| **Pagination** | {Cursor / Offset} `?page=1&limit=20` |
| **Date format** | ISO 8601: `2026-03-10T15:00:00Z` |

---

## 6. Environment & Config

| Rule | Standard |
|------|----------|
| **Config file** | `.env` (gitignored) + `.env.example` (committed) |
| **Validation** | {Zod / Joi / etc.} at app startup |
| **Naming** | `{CATEGORY}_{KEY}` (e.g., `DATABASE_URL`, `AUTH_SECRET`) |
| **Secrets** | Never committed. Use platform secrets manager. |

---

## 7. Project-Specific Rules

```
{Any additional conventions unique to this project}
```

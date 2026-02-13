# {PROJECT_NAME} — Project Conventions

> **Generated**: {DATE} | Extracted from codebase analysis

---

## 1. Language & Formatting

| Convention | Standard |
|:-----------|:---------|
| **Language** | {e.g. TypeScript strict / PHP 8.2 / Python 3.12} |
| **Module System** | {e.g. ESNext / CommonJS} |
| **Linting** | {e.g. ESLint flat config + prettier} |
| **Package Manager** | {e.g. pnpm / npm / composer} |
| **Indentation** | {e.g. 2 spaces / 4 spaces / tabs} |
| **Quotes** | {single / double} |
| **Semicolons** | {yes / no} |
| **Trailing Commas** | {yes / no} |

---

## 2. File & Directory Structure

```
Convention: {e.g. Feature-grouped / Layer-based / Domain-driven}

{key directories with purpose annotations}
```

### Naming Conventions

| Type | Pattern | Example |
|:-----|:--------|:--------|
| **Files** | {kebab-case / camelCase} | {example} |
| **Directories** | {kebab-case} | {example} |
| **Components** | {PascalCase} | {example} |
| **Functions** | {camelCase} | {example} |
| **Constants** | {SCREAMING_SNAKE} | {example} |
| **Types/Interfaces** | {PascalCase} | {example} |

---

## 3. Architecture Patterns

{Document the specific patterns used in THIS project:}

- **{Pattern 1}**: {how it's implemented}
- **{Pattern 2}**: {how it's implemented}
- **{Pattern 3}**: {how it's implemented}

{Include: auth strategy, data access patterns, state management, routing}

### API Response Format

```
Success: { data: T, meta?: { page, perPage, total, totalPages } }
Error:   { error: { code: string, message: string, details?: any } }
```

| Status Code | Usage |
|-------------|-------|
| 200 | OK |
| 201 | Created |
| 400 | Validation error |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not found |
| 500 | Server error |

### UI Patterns

| Aspect | Decision |
|--------|----------|
| **Component Library** | {e.g. Velzon / shadcn/ui / MUI / custom} |
| **Layout** | {e.g. Sidebar + Header + Content} |
| **Theme** | {e.g. Light default, dark mode planned} |
| **Icons** | {e.g. Lucide / Remix Icons / Heroicons} |
| **Responsive** | {strategy + breakpoints} |

---

## 4. Development Workflow

```bash
# Install
{install command}

# Local dev
{dev command}

# Type check
{type-check command}

# Lint
{lint command}

# Build
{build command}

# Start production
{start command}
```

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `{VAR_1}` | ✅ | {default or —} | {purpose} |
| `{VAR_2}` | ⚠️ | {default} | {purpose} |
| `{VAR_3}` | ❌ | {default} | {optional, purpose} |

### Environment Setup
- Copy `{env.example}` → `{.env.local}`
- {environment-specific notes: local/staging/production differences}

---

## 5. Import Aliases

| Alias | Maps To |
|:------|:--------|
| `{alias}` | `{path}` |

---

## 6. Code Quality Rules

{Project-specific rules that AI must follow. NOT generic best practices (Antigravity handles those), but rules unique to THIS codebase:}

1. {rule 1}
2. {rule 2}
3. ...

---

## 7. Git Conventions

| Field | Convention |
|:------|:-----------|
| **Main branch** | {main / master} |
| **Feature branch** | {pattern, e.g. feature/{scope}-{desc}} |
| **Commit format** | {pattern, e.g. type(scope): description} |
| **Commit types** | {feat, fix, docs, refactor, test, chore} |
| **PR required** | {yes/no + when} |

---

## 8. Testing Conventions

| Type | Framework | Location | Pattern |
|------|-----------|----------|---------|
| **Unit** | {e.g. Vitest / Jest / PHPUnit} | {e.g. tests/unit/} | {e.g. *.test.ts} |
| **Integration** | {e.g. Supertest} | {e.g. tests/integration/} | |
| **E2E** | {e.g. Playwright} | {e.g. tests/e2e/} | |

{Coverage target, CI gate rules, what to test vs what NOT to test}

---

> **Instructions for AI:**
> - Fill ALL sections by analyzing the actual codebase
> - Section 1: Extract from tsconfig, .eslintrc, .editorconfig, .prettierrc
> - Section 2: Analyze directory structure + existing file names
> - Section 3: Read source code to identify architectural decisions
>   - API Format: extract from existing response patterns in code
>   - UI Patterns: extract from component library imports, layout files, CSS
> - Section 4: Extract from package.json scripts, Makefile, docker-compose
>   - Env Vars: scan .env.example, .env*, code for process.env.* references
> - Section 5: Extract from tsconfig paths, webpack aliases
> - Section 6: Identify project-specific patterns (NOT generic best practices)
> - Section 7: Extract from .git, existing commits, CI config
> - Section 8: Extract from test config, existing test files
> - Output location: `docs/PROJECT-CONVENTIONS.md`

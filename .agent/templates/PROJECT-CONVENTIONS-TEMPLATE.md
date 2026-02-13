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

{Include: auth strategy, data access patterns, API conventions, state management, routing}

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

### Environment Setup
- {env file instructions}
- {required env vars}

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

{Naming convention, coverage target, CI gate rules}

---

> **Instructions for AI:**
> - Fill ALL sections by analyzing the actual codebase
> - Section 1: Extract from tsconfig, .eslintrc, .editorconfig, .prettierrc
> - Section 2: Analyze directory structure + existing file names
> - Section 3: Read source code to identify architectural decisions
> - Section 4: Extract from package.json scripts, Makefile, docker-compose
> - Section 5: Extract from tsconfig paths, webpack aliases
> - Section 6: Identify project-specific patterns (NOT generic best practices)
> - Section 7: Extract from .git, existing commits, CI config
> - Section 8: Extract from test config, existing test files
> - Output location: `docs/PROJECT-CONVENTIONS.md`

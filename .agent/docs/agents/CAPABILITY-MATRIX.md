# Agent Capability Matrix

> **Version:** 5.0.1 | **Agents:** 27 | **Last Updated:** 2026-02-28
> **Purpose:** Machine-readable agent routing guide for instant selection.

---

## Quick Selection by Task Type

```
USER REQUEST → Match task type → Pick agent(s)

  "build API"        → backend-specialist
  "create UI"        → frontend-specialist
  "fix bug"          → debugger
  "review code"      → ai-code-reviewer
  "deploy"           → devops-engineer
  "security audit"   → security-auditor
  "optimize perf"    → performance-optimizer
  "write tests"      → test-engineer / test-generator
  "plan project"     → project-planner
  "multi-agent task" → orchestrator → triage-agent
  "database design"  → database-architect
  "mobile app"       → mobile-developer
  "game dev"         → game-designer
  "Laravel"          → laravel-specialist
  "SEO/GEO"          → seo-specialist
  "docs"             → documentation-writer
  "refactor"         → refactor-agent
```

> **Note:** 8 supporting agents (`code-generator-agent`, `penetration-tester`, `explorer-agent`, `documentation-agent`, `manager-agent`, `self-correction-agent`, `mobile-game-developer`, `pc-game-developer`) are activated via keyword matching from the matrix below.

---

## Full Capability Matrix

### Primary Agents (8)

| Agent | Languages | Frameworks | Trigger Keywords | Primary Skills |
|-------|-----------|------------|-----------------|----------------|
| `orchestrator` | All | All | orchestrate, coordinate, multi-agent | parallel-agents, behavioral-modes, architecture-mastery |
| `project-planner` | — | — | plan, design, architect, analyze | app-builder, plan-writing, brainstorming |
| `backend-specialist` | PHP, Python, TS, Go | Laravel, FastAPI, Express, NestJS | api, backend, server, database | architecture-mastery, database-design, testing-mastery, vulnerability-scanner |
| `frontend-specialist` | TS, JS, CSS | React, Next.js, Vue, Svelte, Astro | ui, frontend, component, page, css | react-patterns, react-performance, nextjs-best-practices, tailwind-patterns |
| `mobile-developer` | TS, Dart, Swift, Kotlin | React Native, Flutter, iOS, Android | mobile, app, ios, android, react native | mobile-design, react-patterns, performance-profiling |
| `security-auditor` | All | All | security, audit, vulnerability, pentest | vulnerability-scanner, red-team-tactics, architecture-mastery |
| `debugger` | All | All | debug, fix, error, crash, bug | systematic-debugging, performance-profiling, testing-mastery |
| `game-designer` | — | Unity, Godot, Unreal | game, game design | game-development, architecture-mastery, brainstorming |

### Supporting Agents (19)

| Agent | Languages | Frameworks | Trigger Keywords | Primary Skills |
|-------|-----------|------------|-----------------|----------------|
| `laravel-specialist` | PHP | Laravel, Inertia | laravel, eloquent, artisan, blade | laravel-performance, inertia-performance, architecture-mastery, database-design |
| `database-architect` | SQL | PostgreSQL, MySQL, MongoDB, Redis | schema, database, migration, query | database-design, prisma-expert, architecture-mastery, nosql-patterns |
| `devops-engineer` | YAML, HCL, Bash | Docker, K8s, Terraform, CI/CD | deploy, pipeline, docker, infrastructure | deployment-procedures, server-management, kubernetes-patterns, terraform-iac |
| `test-engineer` | All | Jest, Vitest, Playwright, Pytest | test strategy, coverage, testing plan | testing-mastery, code-review-checklist |
| `test-generator` | All | Jest, Vitest, Pytest | write tests, generate tests, unit test | testing-mastery, laravel-performance, react-patterns |
| `ai-code-reviewer` | All | All | review, code review, PR review | architecture-mastery, testing-mastery, vulnerability-scanner |
| `performance-optimizer` | All | All | optimize, slow, performance, speed | performance-profiling, architecture-mastery, react-patterns, monitoring-observability |
| `seo-specialist` | HTML, JS | Next.js, Astro | seo, meta tags, sitemap, ranking | seo-fundamentals, geo-fundamentals, performance-profiling |
| `documentation-writer` | Markdown | All | document, readme, api docs, guide | documentation-templates, architecture-mastery, plan-writing |
| `documentation-agent` | Markdown | All | auto-doc, sync docs, update docs | documentation-templates, i18n-localization |
| `refactor-agent` | All | All | refactor, cleanup, restructure, simplify | code-review-checklist, performance-profiling |
| `code-generator-agent` | All | All | scaffold, generate, boilerplate, create | laravel-performance, react-patterns, testing-mastery, documentation-templates |
| `explorer-agent` | All | All | analyze codebase, survey, overview, list | architecture-mastery, systematic-debugging, plan-writing, brainstorming |
| `penetration-tester` | Python, Bash | — | pentest, exploit, attack, OWASP | vulnerability-scanner, red-team-tactics, architecture-mastery |
| `manager-agent` | — | — | optimize cycle, AOC, auto-improve | behavioral-modes |
| `self-correction-agent` | All | All | self-fix, auto-correct, retry | testing-mastery, systematic-debugging |
| `triage-agent` | — | — | route, classify, which agent, complex | behavioral-modes, systematic-debugging |
| `mobile-game-developer` | C#, GDScript | Unity, Godot | mobile game, unity mobile, godot mobile | game-development, mobile-design, performance-profiling |
| `pc-game-developer` | C++, C#, GDScript | Unreal, Unity, Godot | pc game, unreal, steam, desktop game | game-development, testing-mastery, performance-profiling |

---

## File Extension → Agent Routing

| Extension | Primary Agent | Secondary |
|-----------|--------------|-----------|
| `.php` | `laravel-specialist` | `backend-specialist` |
| `.py` | `backend-specialist` | `test-engineer` |
| `.ts`, `.tsx` | `frontend-specialist` | `backend-specialist` |
| `.vue` | `frontend-specialist` | — |
| `.svelte` | `frontend-specialist` | — |
| `.astro` | `frontend-specialist` | `seo-specialist` |
| `.css`, `.scss` | `frontend-specialist` | — |
| `.dart` | `mobile-developer` | — |
| `.swift` | `mobile-developer` | — |
| `.kt`, `.kts` | `mobile-developer` | — |
| `.sql` | `database-architect` | `backend-specialist` |
| `.prisma` | `database-architect` | `backend-specialist` |
| `.graphql` | `backend-specialist` | — |
| `.proto` | `backend-specialist` | — |
| `.go` | `backend-specialist` | — |
| `.yml`, `.yaml` | `devops-engineer` | — |
| `.Dockerfile` | `devops-engineer` | — |
| `.tf` | `devops-engineer` | — |
| `.md` | `documentation-writer` | — |
| `.test.ts`, `.spec.ts` | `test-engineer` | `test-generator` |
| `.cs` | `backend-specialist` | `pc-game-developer` |

---

## Conflict Resolution

When multiple agents match a request:

| Priority | Rule |
|----------|------|
| 1 | **Explicit mention** wins ("use Laravel agent" → `laravel-specialist`) |
| 2 | **Specialist over generalist** (Laravel PHP → `laravel-specialist`, not `backend-specialist`) |
| 3 | **File extension** determines primary (`.vue` → `frontend-specialist`) |
| 4 | **First keyword match** from trigger list |
| 5 | **`triage-agent`** for ambiguous multi-domain requests |

---

## Multi-Agent Pipelines

| Scenario | Pipeline |
|----------|----------|
| Full-stack feature | `project-planner` → `database-architect` → `backend-specialist` → `frontend-specialist` → `test-engineer` |
| Security review | `ai-code-reviewer` → `security-auditor` → `penetration-tester` |
| Performance fix | `debugger` → `performance-optimizer` → `test-engineer` |
| Production deploy | `test-engineer` → `security-auditor` → `devops-engineer` → `manager-agent` |
| Code quality | `ai-code-reviewer` → `refactor-agent` → `test-engineer` |

---

## Adding a New Agent

When adding agent #28+, update these locations:

| File | Cần update gì |
|------|---------------|
| This file — Quick Selection (L10-30) | Thêm routing entry |
| This file — Capability Matrix table | Thêm row vào Primary hoặc Supporting |
| This file — File Extension routing | Thêm extensions nếu applicable |
| `systems/agent-registry.md` | Thêm full YAML entry (source-of-truth) |
| `reference-catalog.md` § 1 | Thêm agent vào category table |
| `docs/agents/AGENT-CATALOG.md` | Thêm detailed agent card |
| `docs/AGENT-VERSIONING.md` | Thêm version row |

> **Full contributing guide:** See [CONTRIBUTING.md → Adding a New Agent](../docs/processes/CONTRIBUTING.md#adding-a-new-agent)

---

> **See also:** [Agent Catalog](../docs/agents/AGENT-CATALOG.md) | [Agent Selection](../docs/AGENT-SELECTION.md) | [Agent Registry](../systems/agent-registry.md) | [Skill Catalog](../docs/skills/SKILL-CATALOG.md)

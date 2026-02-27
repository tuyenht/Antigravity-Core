# Agent Capability Matrix

> **Version:** 5.0.0 | **Agents:** 27 | **Last Updated:** 2026-02-26
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

---

## Full Capability Matrix

### Primary Agents (8)

| Agent | Languages | Frameworks | Trigger Keywords | Primary Skills |
|-------|-----------|------------|-----------------|----------------|
| `orchestrator` | All | All | orchestrate, coordinate, multi-agent | parallel-agents, behavioral-modes |
| `project-planner` | — | — | plan, design, architect, analyze | brainstorming, plan-writing, architecture |
| `backend-specialist` | PHP, Python, TS, Go | Laravel, FastAPI, Express, NestJS | api, backend, server, database | api-patterns, database-design, nodejs-best-practices |
| `frontend-specialist` | TS, JS, CSS | React, Next.js, Vue, Svelte, Astro | ui, frontend, component, page, css | frontend-design, react-patterns, tailwind-patterns |
| `mobile-developer` | TS, Dart, Swift, Kotlin | React Native, Flutter, iOS, Android | mobile, app, ios, android, react native | mobile-design, react-native-performance |
| `security-auditor` | All | All | security, audit, vulnerability, pentest | vulnerability-scanner, red-team-tactics |
| `debugger` | All | All | debug, fix, error, crash, bug | systematic-debugging |
| `game-designer` | — | Unity, Godot, Unreal | game, game design | game-development |

### Supporting Agents (19)

| Agent | Languages | Frameworks | Trigger Keywords | Primary Skills |
|-------|-----------|------------|-----------------|----------------|
| `laravel-specialist` | PHP | Laravel, Inertia | laravel, eloquent, artisan, blade | laravel-performance, inertia-performance |
| `database-architect` | SQL | PostgreSQL, MySQL, MongoDB, Redis | schema, database, migration, query | database-design |
| `devops-engineer` | YAML, HCL, Bash | Docker, K8s, Terraform, CI/CD | deploy, pipeline, docker, infrastructure | deployment-procedures, docker-expert, cloudflare |
| `test-engineer` | All | Jest, Vitest, Playwright, Pytest | test strategy, coverage, testing plan | testing-mastery, webapp-testing |
| `test-generator` | All | Jest, Vitest, Pytest | write tests, generate tests, unit test | testing-patterns, tdd-workflow |
| `ai-code-reviewer` | All | All | review, code review, PR review | code-review-checklist, clean-code |
| `performance-optimizer` | All | All | optimize, slow, performance, speed | performance-profiling, react-performance |
| `seo-specialist` | HTML, JS | Next.js, Astro | seo, meta tags, sitemap, ranking | seo-fundamentals, geo-fundamentals |
| `documentation-writer` | Markdown | All | document, readme, api docs, guide | documentation-templates |
| `documentation-agent` | Markdown | All | auto-doc, sync docs, update docs | documentation-templates |
| `refactor-agent` | All | All | refactor, cleanup, restructure, simplify | clean-code |
| `code-generator-agent` | All | All | scaffold, generate, boilerplate, create | app-builder |
| `explorer-agent` | All | All | analyze codebase, survey, overview, list | — |
| `penetration-tester` | Python, Bash | — | pentest, exploit, attack, OWASP | red-team-tactics, vulnerability-scanner |
| `manager-agent` | — | — | optimize cycle, AOC, auto-improve | — |
| `self-correction-agent` | All | All | self-fix, auto-correct, retry | systematic-debugging |
| `triage-agent` | — | — | route, classify, which agent, complex | — |
| `mobile-game-developer` | C#, GDScript | Unity, Godot | mobile game, unity mobile, godot mobile | game-development |
| `pc-game-developer` | C++, C#, GDScript | Unreal, Unity, Godot | pc game, unreal, steam, desktop game | game-development |

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
| `.graphql` | `backend-specialist` | — |
| `.proto` | `backend-specialist` | — |
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
| Production deploy | `test-engineer` → `security-auditor` → `devops-engineer` |
| Code quality | `ai-code-reviewer` → `refactor-agent` → `test-generator` |

---

**Maintainer:** Antigravity Core System

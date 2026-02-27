# 📚 Antigravity-Core — Reference Catalog

> **Version:** 5.0.0 | **Updated:** 2026-02-26
> **Purpose:** Bảng tham chiếu tổng hợp — CHỈ đọc khi cần tra cứu, KHÔNG load mặc định.
> **Loaded by:** GEMINI.md → Lazy Loading Protocol

---

## 1. Agent Registry (27 Agents)

### Primary Agents (8)

| Agent | Domain & Focus |
|-------|----------------|
| `orchestrator` | Multi-agent coordination and synthesis |
| `project-planner` | Discovery, Architecture, and Task Planning |
| `security-auditor` | Master Cybersecurity (Audit + Pentest + Infra Hardening) |
| `backend-specialist` | Backend Architect (API + Database + Server/Docker Deploy) |
| `frontend-specialist` | Frontend & Growth (UI/UX + SEO + Edge/Static Deploy) |
| `mobile-developer` | Mobile Specialist (Cross-platform + Mobile Performance) |
| `debugger` | Systematic Root Cause Analysis & Bug Fixing |
| `game-designer` | Game Design Lead (coordinates mobile-game-developer & pc-game-developer) |

### Supporting Agents (19)

| Agent | Domain & Focus |
|-------|----------------|
| `laravel-specialist` | Laravel framework expert (PHP, Eloquent, Blade, Inertia) |
| `test-engineer` | Testing strategy & infrastructure |
| `test-generator` | Test code generation |
| `ai-code-reviewer` | Automated code review |
| `code-generator-agent` | Code scaffolding & generation |
| `database-architect` | Database schema design & optimization |
| `devops-engineer` | CI/CD, deployment, infrastructure |
| `documentation-agent` | Automated documentation sync |
| `documentation-writer` | User-requested documentation |
| `explorer-agent` | Codebase analysis & survey |
| `manager-agent` | Auto-Optimization Cycle (AOC) coordination |
| `penetration-tester` | Offensive security testing |
| `performance-optimizer` | Performance profiling & optimization |
| `refactor-agent` | Safe code refactoring |
| `self-correction-agent` | Autonomous error correction |
| `seo-specialist` | SEO & GEO optimization |
| `triage-agent` | Issue prioritization & routing |
| `mobile-game-developer` | Mobile game development (Unity, Godot) |
| `pc-game-developer` | PC game development (Unreal, Unity) |

### Agent Relationships

| Agent Pair | Relationship |
|------------|-------------|
| `test-engineer` ↔ `test-generator` | Strategy/infrastructure (engineer) vs code generation (generator) |
| `security-auditor` ↔ `penetration-tester` | Defensive review (auditor) vs offensive testing (tester) |
| `documentation-agent` ↔ `documentation-writer` | Automated sync (agent) vs user-requested writing (writer) |

---

## 2. Expert Rules Auto-Activation

### Rule Categories (95 Rules)

| Category | Count | Path | Key Triggers |
|----------|-------|------|--------------|
| **Agentic AI** | 12 | `rules/agentic-ai/` | debug, test, review, security, refactor |
| **Backend** | 12 | `rules/backend-frameworks/` | laravel, express, fastapi, graphql, grpc, websocket, sse |
| **Database** | 10 | `rules/database/` | postgresql, mysql, redis, mongodb, query, schema |
| **Frontend** | 7 | `rules/frontend-frameworks/` | vue, angular, svelte, solid, astro, remix |
| **Mobile** | 10 | `rules/mobile/` | react-native, flutter, ios, android, mobile |
| **Next.js** | 13 | `rules/nextjs/` | next.js, app router, server actions, i18n, seo |
| **Python** | 14 | `rules/python/` | .py, fastapi, flask, ai, ml, data, automation |
| **TypeScript** | 13 | `rules/typescript/` | .ts, .tsx, typescript, generics, monorepo |
| **Web Dev** | 12 | `rules/web-development/` | html, css, javascript, accessibility, pwa |
| **Standards (General)** | 16 | `rules/standards/` | code quality, security, testing, ci/cd |
| **Standards (Framework)** | 9 | `rules/standards/frameworks/` | laravel, nextjs, flutter, vue3 conventions |
| **Shared** | 1 | `rules/shared/` | common utilities |

### File Extension → Rule Mapping

```yaml
".vue":      frontend-frameworks/vue3.md, typescript/vue3.md
".svelte":   frontend-frameworks/svelte.md
".astro":    frontend-frameworks/astro.md
".swift":    mobile/ios-swift.md
".kt":       mobile/android-kotlin.md
".dart":     mobile/flutter.md
".php":      backend-frameworks/laravel.md
".py":       python/rest-api.md, python/backend-patterns.md
".sql":      database/postgresql.md, database/query-optimization.md
".graphql":  backend-frameworks/graphql.md
".component.ts": frontend-frameworks/angular.md
".ts", ".tsx": typescript/strict-mode.md
".css":      web-development/core/modern-css-responsive.md
".html":     web-development/core/semantic-html-accessibility.md
".js", ".jsx": web-development/core/javascript-es2024.md
```

### Project Config → Rule Mapping

```yaml
"package.json + next":         nextjs/app-router.md
"package.json + react-native": mobile/react-native.md
"package.json + vue":          frontend-frameworks/vue3.md
"package.json + nuxt":         frontend-frameworks/vue3.md
"package.json + svelte":       frontend-frameworks/svelte.md
"package.json + tailwind":     frontend-frameworks/tailwind.md
"composer.json + laravel":     backend-frameworks/laravel.md
"pubspec.yaml":                mobile/flutter.md
"requirements.txt | pyproject.toml": python/rest-api.md
```

### Keyword → Rule Mapping

```yaml
"debug, fix, error":     agentic-ai/debugging-agent.md
"test, unit test":       agentic-ai/test-writing-agent.md
"security, audit":       agentic-ai/security-audit-agent.md
"refactor, cleanup":     agentic-ai/refactoring-agent.md
"optimize, slow":        agentic-ai/performance-optimization-agent.md
"api design":            agentic-ai/api-design-agent.md
"database, schema":      agentic-ai/database-design-agent.md
"deploy, ci/cd":         agentic-ai/devops-cicd-agent.md
"review, PR":            agentic-ai/code-review-agent.md
```

### Loading Limits

| Context | Max Rules | Selection Priority |
|---------|-----------|-------------------|
| Single file edit | 2-3 | File ext + 1 keyword |
| Feature build | 3-5 | Framework + Domain + AI |
| Multi-file task | 5-7 | Full stack coverage |
| Architecture | 5+ | Design + Backend + DB |

---

## 3. Project Type Routing

| Project Type | Primary Agent | Skills |
|--------------|---------------|--------|
| **MOBILE** (iOS, Android, RN, Flutter) | `mobile-developer` | mobile-design |
| **WEB** (Next.js, React web) | `frontend-specialist` | frontend-design |
| **BACKEND** (API, server, DB) | `backend-specialist` | api-patterns, database-design |
| **LARAVEL + INERTIA** | `backend-specialist` + `frontend-specialist` | See Framework Standards |

> 🔴 **Mobile + frontend-specialist = WRONG.** Mobile = mobile-developer ONLY.

### Framework Auto-Detection

```bash
if [ -f "composer.json" ] && grep -q "laravel/framework" composer.json; then
  FRAMEWORK="Laravel"
  LOAD_STANDARDS="rules/backend-frameworks/laravel.md"
  if grep -q "inertiajs/inertia-laravel" composer.json; then
    if [ -f "package.json" ] && grep -q "react" package.json; then
      FRAMEWORK="Laravel + Inertia.js + React"
      LOAD_STANDARDS="$LOAD_STANDARDS + rules/standards/frameworks/inertia-react-conventions.md"
    fi
  fi
fi
```

---

## 4. Key Skills Reference

| Skill | Purpose |
|-------|---------|
| `clean-code` | Coding standards (GLOBAL) |
| `brainstorming` | Socratic questioning |
| `app-builder` | Full-stack orchestration |
| `frontend-design` | Web UI patterns |
| `mobile-design` | Mobile UI patterns |
| `plan-writing` | {task-slug}.md format |
| `behavioral-modes` | Mode switching |
| `ui-ux-pro-max` | Design intelligence (67 styles, 21 palettes, 57 fonts) |

---

## 5. Script Locations

| Script | Path |
|--------|------|
| Health check | `.agent/scripts/health-check.ps1` |
| Security scan | `.agent/skills/vulnerability-scanner/scripts/security_scan.py` |
| UX audit | `.agent/skills/frontend-design/scripts/ux_audit.py` |
| Accessibility | `.agent/skills/frontend-design/scripts/accessibility_checker.py` |
| Mobile audit | `.agent/skills/mobile-design/scripts/mobile_audit.py` |
| Lighthouse | `.agent/skills/performance-profiling/scripts/lighthouse_audit.py` |
| SEO checker | `.agent/skills/seo-fundamentals/scripts/seo_checker.py` |
| Playwright | `.agent/skills/webapp-testing/scripts/playwright_runner.py` |
| Lint runner | `.agent/skills/lint-and-validate/scripts/lint_runner.py` |
| Type coverage | `.agent/skills/lint-and-validate/scripts/type_coverage.py` |
| Test runner | `.agent/skills/testing-patterns/scripts/test_runner.py` |
| Schema validator | `.agent/skills/database-design/scripts/schema_validator.py` |
| API validator | `.agent/skills/api-patterns/scripts/api_validator.py` |
| GEO checker | `.agent/skills/geo-fundamentals/scripts/geo_checker.py` |
| i18n checker | `.agent/skills/i18n-localization/scripts/i18n_checker.py` |
| UI/UX core | `.agent/skills/ui-ux-pro-max/scripts/core.py` |
| Design system | `.agent/skills/ui-ux-pro-max/scripts/design_system.py` |
| Design search | `.agent/skills/ui-ux-pro-max/scripts/search.py` |
| Bump version | `.agent/scripts/bump-version.ps1` |
| Validate compliance | `.agent/scripts/validate-compliance.ps1` |

---

## 6. Quality Gate Scripts

**Priority Execution Order:**
1. **Security** → 2. **Lint** → 3. **Schema** → 4. **Tests** → 5. **UX** → 6. **SEO** → 7. **Lighthouse/E2E**

| Script | Skill | When to Use |
|--------|-------|-------------|
| `security_scan.py` | vulnerability-scanner | Always on deploy |
| `lint_runner.py` | lint-and-validate | Every code change |
| `test_runner.py` | testing-patterns | After logic change |
| `schema_validator.py` | database-design | After DB change |
| `ux_audit.py` | frontend-design | After UI change |
| `accessibility_checker.py` | frontend-design | After UI change |
| `seo_checker.py` | seo-fundamentals | After page change |
| `mobile_audit.py` | mobile-design | After mobile change |
| `lighthouse_audit.py` | performance-profiling | Before deploy |
| `playwright_runner.py` | webapp-testing | Before deploy |

---

**This file is a REFERENCE ONLY. Do NOT load at session start.**
**Load sections on-demand when pipeline steps require specific lookups.**

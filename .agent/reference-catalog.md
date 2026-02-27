# 📚 Antigravity-Core — Reference Catalog

> **Version:** 5.0.0 | **Updated:** 2026-02-27
> **Role:** Quick-reference index for AI lazy-loading — NOT a runtime system.
> **Loaded by:** GEMINI.md § 6 (on-demand only)
> **Runtime systems:** `systems/agent-registry.md`, `systems/auto-rule-discovery.md`, `systems/orchestration-engine.md`

---

## 0. System Quick Map

| Component | Count | Source of Truth | Quick Lookup |
|-----------|:-----:|-----------------|:---:|
| **Agents** | 27 | `systems/agent-registry.md` | § 1 below |
| **Rules** | 110 | `systems/auto-rule-discovery.md` | § 2 below |
| **Skills** | 59 | Agent frontmatter `skills:` field | § 3 below |
| **Pipelines** | 6 | `pipelines/*.md` | GEMINI.md § 1 |
| **Workflows** | 34 | `workflows/*.md` | GEMINI.md § 9 |
| **Scripts** | 37 | `scripts/` + `skills/*/scripts/` | § 5 below |
| **Systems** | 6 | `systems/*.md` | ARCHITECTURE.md |

---

## 1. Agent Summary (27 Agents)

> **Full registry:** `systems/agent-registry.md` (triggers, skills, rules, exclusions, conflicts, priority)

| Category | Count | Agents |
|----------|:-----:|--------|
| Core Dev | 4 | `backend-specialist`, `frontend-specialist`, `laravel-specialist`, `mobile-developer` |
| Quality | 4 | `test-engineer`, `test-generator`, `ai-code-reviewer`, `debugger` |
| Security | 2 | `security-auditor`, `penetration-tester` |
| Architecture | 3 | `database-architect`, `orchestrator`, `project-planner` |
| Operations | 3 | `devops-engineer`, `performance-optimizer`, `manager-agent` |
| Specialized | 4 | `seo-specialist`, `game-designer`, `mobile-game-developer`, `pc-game-developer` |
| Automation | 5 | `self-correction-agent`, `triage-agent`, `refactor-agent`, `code-generator-agent`, `explorer-agent` |
| Documentation | 2 | `documentation-agent`, `documentation-writer` |

### Key Agent Pairs

| Pair | Distinction |
|------|------------|
| `test-engineer` ↔ `test-generator` | Strategy/infra vs code generation |
| `security-auditor` ↔ `penetration-tester` | Defensive review vs offensive testing |
| `documentation-agent` ↔ `documentation-writer` | Automated sync vs user-requested writing |

---

## 2. Expert Rules (110 Rules)

> **Full mappings + scoring:** `systems/auto-rule-discovery.md` (3-layer detection, dependency resolution, caching)

| Category | Count | Path | Key Triggers |
|----------|:-----:|------|-------------|
| Agentic AI | 12 | `rules/agentic-ai/` | debug, test, review, security, refactor |
| Backend | 12 | `rules/backend-frameworks/` | laravel, express, fastapi, graphql, grpc, websocket, sse |
| Database | 10 | `rules/database/` | postgresql, mysql, redis, mongodb, query, schema |
| Frontend | 7 | `rules/frontend-frameworks/` | vue, angular, svelte, solid, astro, remix, tailwind |
| Mobile | 10 | `rules/mobile/` | react-native, flutter, ios, android |
| Next.js | 13 | `rules/nextjs/` | next.js, app router, server actions, i18n, seo |
| Python | 14 | `rules/python/` | .py, fastapi, flask, ai, ml, data, automation |
| TypeScript | 13 | `rules/typescript/` | .ts, .tsx, generics, monorepo |
| Web Dev | 14 | `rules/web-development/` | html, css, js, accessibility, pwa, webassembly |
| Standards | 4 | `rules/standards/` | supply-chain, nextjs/inertia/django conventions |
| Shared | 1 | `rules/shared/` | common utilities |

---

## 3. Skills Inventory (59 Skills)

| Domain | Count | Key Skills |
|--------|:-----:|-----------|
| **Architecture** | 3 | `architecture`, `architecture-mastery`, `app-builder` |
| **Backend** | 7 | `api-patterns`, `nestjs-expert`, `nodejs-best-practices`, `graphql-patterns`, `microservices-communication`, `mcp-builder`, `cloudflare` |
| **Database** | 4 | `database-design`, `prisma-expert`, `nosql-patterns`, `vector-databases` |
| **DevOps** | 5 | `docker-expert`, `kubernetes-patterns`, `terraform-iac`, `deployment-procedures`, `server-management` |
| **Frontend** | 7 | `frontend-design`, `react-patterns`, `react-performance`, `vue-expert`, `tailwind-patterns`, `state-management`, `ui-ux-pro-max` |
| **Frameworks** | 3 | `nextjs-best-practices`, `laravel-performance`, `inertia-performance` |
| **Mobile** | 2 | `mobile-design`, `react-native-performance` |
| **Quality** | 8 | `testing-mastery`, `testing-patterns`, `tdd-workflow`, `webapp-testing`, `contract-testing`, `lint-and-validate`, `code-review-checklist`, `clean-code` |
| **Security** | 2 | `vulnerability-scanner`, `red-team-tactics` |
| **Specialized** | 6 | `game-development`, `ai-sdk-expert`, `python-patterns`, `typescript-expert`, `monitoring-observability`, `performance-profiling` |
| **Process** | 5 | `brainstorming`, `plan-writing`, `behavioral-modes`, `parallel-agents`, `systematic-debugging` |
| **Content** | 7 | `documentation-templates`, `i18n-localization`, `seo-fundamentals`, `geo-fundamentals`, `velzon-admin`, `powershell-windows`, `bash-linux` |

---

## 4. Project Type Routing

| Project Type | Primary Agent | Key Skills | Framework Detection |
|--------------|--------------|-----------|-------------------|
| **Laravel** | `laravel-specialist` | laravel-performance | `composer.json` + `laravel/framework` |
| **Laravel + Inertia + React** | `laravel-specialist` + `frontend-specialist` | inertia-performance, react-patterns | `composer.json` + `inertiajs` + `package.json` + `react` |
| **Next.js** | `frontend-specialist` | nextjs-best-practices, react-performance | `package.json` + `next` |
| **Vue / Nuxt** | `frontend-specialist` | vue-expert | `package.json` + `vue` / `nuxt` |
| **Python (FastAPI/Flask)** | `backend-specialist` | python-patterns, api-patterns | `requirements.txt` / `pyproject.toml` |
| **NestJS** | `backend-specialist` | nestjs-expert, typescript-expert | `package.json` + `@nestjs/core` |
| **Mobile (RN/Expo)** | `mobile-developer` | mobile-design, react-native-performance | `package.json` + `react-native` / `expo` |
| **Mobile (Flutter)** | `mobile-developer` | mobile-design | `pubspec.yaml` |
| **ASP.NET Core** | `backend-specialist` | — | `.csproj` + `Microsoft.AspNetCore` |
| **Astro** | `frontend-specialist` | — | `package.json` + `astro` |

> 🔴 **Mobile + frontend-specialist = WRONG.** Mobile = `mobile-developer` ONLY.

---

## 5. Script Locations

### Core Scripts (`.agent/scripts/`)

| Script | Purpose |
|--------|---------|
| `health-check.ps1` / `.sh` | System health check |
| `validate-compliance.ps1` / `.sh` | Standards compliance validation |
| `bump-version.ps1` / `.sh` | Version bump across files |
| `detect-project.ps1` | Tech stack auto-detection |
| `discover-rules.ps1` | Rule discovery CLI |
| `install-antigravity.ps1` | Project-level installation |
| `install-global.ps1` / `.sh` | Global system installation |
| `update-antigravity.ps1` | Project-level update |
| `update-global.ps1` | Global system update |
| `update-ui-ux-pro-max.ps1` | UI/UX skill update |
| `auto-heal.ps1` | Auto-fix lint/type/import errors |
| `secret-scan.ps1` | Secret/credential scanning |
| `dx-analytics.ps1` | Developer experience metrics |
| `log-metrics.ps1` | Metrics logging |
| `performance-check.ps1` | Performance baseline check |
| `pre-commit` | Git pre-commit hook |

### Skill Scripts (`.agent/skills/*/scripts/`)

| Script | Skill | Purpose |
|--------|-------|---------|
| `security_scan.py` | vulnerability-scanner | Security vulnerability scan |
| `ux_audit.py` | frontend-design | UX quality audit |
| `accessibility_checker.py` | frontend-design | WCAG compliance check |
| `mobile_audit.py` | mobile-design | Mobile UX audit |
| `lighthouse_audit.py` | performance-profiling | Lighthouse performance audit |
| `seo_checker.py` | seo-fundamentals | SEO compliance check |
| `geo_checker.py` | geo-fundamentals | GEO optimization check |
| `playwright_runner.py` | webapp-testing | E2E test runner |
| `lint_runner.py` | lint-and-validate | Lint execution |
| `type_coverage.py` | lint-and-validate | Type coverage analysis |
| `test_runner.py` | testing-patterns | Test suite runner |
| `schema_validator.py` | database-design | Schema validation |
| `api_validator.py` | api-patterns | API contract validation |
| `i18n_checker.py` | i18n-localization | i18n coverage check |
| `core.py` | ui-ux-pro-max | Design intelligence core |
| `design_system.py` | ui-ux-pro-max | Design system generator |
| `search.py` | ui-ux-pro-max | Design pattern search |

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

**This file is a QUICK REFERENCE INDEX — not a runtime system.**
**For full agent data:** `systems/agent-registry.md`
**For full rule mappings:** `systems/auto-rule-discovery.md`
**Load sections on-demand when pipeline steps require specific lookups.**

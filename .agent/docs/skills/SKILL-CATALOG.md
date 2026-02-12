# Skill Catalog — Antigravity-Core

**Version:** 4.0.0  
**Last Updated:** 2026-02-13  
**Total Skills:** 59

---

## Table of Contents

- [Overview](#overview)
- [Skill Classification](#skill-classification)
- [Complete Skill Registry](#complete-skill-registry)
- [Skill Loading Protocol](#skill-loading-protocol)

---

## Overview

Skills là **knowledge modules** tải vào agents khi cần. Mỗi skill là một thư mục trong `.agent/skills/` chứa `SKILL.md` (index) và có thể chứa thêm `scripts/`, `examples/`, `resources/`.

**Nguyên tắc:**
1. **Selective Loading** — Chỉ đọc sections liên quan, KHÔNG đọc tất cả
2. **Priority** — P0 (GEMINI.md) > P1 (Agent) > P2 (SKILL.md)
3. **Universal Skill** — `clean-code` được load bởi TẤT CẢ 27 agents

---

## Skill Classification

### By Domain (11 Categories)

| Category | Count | Skills |
|----------|-------|--------|
| **🏗️ Architecture & Design** | 5 | `architecture`, `architecture-mastery`, `api-patterns`, `graphql-patterns`, `microservices-communication` |
| **⚛️ Frontend** | 8 | `react-patterns`, `react-performance`, `nextjs-best-practices`, `tailwind-patterns`, `frontend-design`, `state-management`, `vue-expert`, `velzon-admin` |
| **🔧 Backend** | 8 | `nodejs-best-practices`, `nestjs-expert`, `python-patterns`, `laravel-performance`, `inertia-performance`, `prisma-expert`, `mcp-builder`, `cloudflare` |
| **📱 Mobile** | 3 | `mobile-design`, `react-native-performance`, `game-development` |
| **🗄️ Data** | 4 | `database-design`, `nosql-patterns`, `vector-databases`, `terraform-iac` |
| **🔒 Security** | 2 | `vulnerability-scanner`, `red-team-tactics` |
| **✅ Testing & Quality** | 7 | `testing-mastery`, `testing-patterns`, `tdd-workflow`, `contract-testing`, `webapp-testing`, `code-review-checklist`, `lint-and-validate` |
| **⚡ Performance** | 2 | `performance-profiling`, `monitoring-observability` |
| **🚀 DevOps** | 5 | `deployment-procedures`, `server-management`, `kubernetes-patterns`, `docker-expert`, `bash-linux`, `powershell-windows` |
| **📝 Process & Planning** | 5 | `clean-code`, `brainstorming`, `behavioral-modes`, `plan-writing`, `app-builder` |
| **🎨 Design & SEO** | 7 | `ui-ux-pro-max`, `seo-fundamentals`, `geo-fundamentals`, `i18n-localization`, `documentation-templates`, `parallel-agents`, `systematic-debugging` |
| **🤖 AI & Expert** | 3 | `ai-sdk-expert`, `typescript-expert`, `docker-expert` |

---

## Complete Skill Registry

| # | Skill | Mô tả | Agents sử dụng |
|---|-------|--------|----------------|
| 1 | `ai-sdk-expert` | Vercel AI SDK v5 — streaming, tool calling, hooks, edge runtime | Specialized |
| 2 | `api-patterns` | REST vs GraphQL vs tRPC, response formats, versioning, pagination | backend-specialist, laravel-specialist, penetration-tester, performance-optimizer |
| 3 | `app-builder` | Full-stack orchestrator — natural language → application | project-planner |
| 4 | `architecture` | ADR documentation, trade-off evaluation, requirements analysis | explorer-agent, documentation-writer, game-designer |
| 5 | `architecture-mastery` | Unified architecture (architecture + api + microservices + graphql) | backend-specialist, ai-code-reviewer, security-auditor |
| 6 | `bash-linux` | Bash/Linux terminal patterns, piping, error handling | devops-engineer, orchestrator |
| 7 | `behavioral-modes` | AI operational modes (brainstorm, implement, debug, review, teach) | orchestrator, triage-agent, manager-agent |
| 8 | `brainstorming` | Socratic questioning protocol. MANDATORY for complex requests | orchestrator, explorer-agent, game-designer |
| 9 | `clean-code` | Pragmatic coding standards — concise, no over-engineering | **ALL 27 agents** |
| 10 | `cloudflare` | Workers, Pages, KV, D1, R2, AI, WAF, DDoS, Terraform | backend-specialist, devops-engineer |
| 11 | `code-review-checklist` | Code quality, security, best practices review | test-engineer, refactor-agent |
| 12 | `contract-testing` | API contract testing, Pact framework, consumer-driven contracts | Specialized |
| 13 | `database-design` | Schema design, indexing strategy, ORM selection, serverless DBs | backend-specialist, laravel-specialist, database-architect, penetration-tester, performance-optimizer |
| 14 | `deployment-procedures` | Safe deployment workflows, rollback strategies | devops-engineer |
| 15 | `docker-expert` | Multi-stage builds, image optimization, container security | Specialized |
| 16 | `documentation-templates` | README, API docs, code comments, AI-friendly docs | documentation-writer, documentation-agent, code-generator-agent |
| 17 | `frontend-design` | Web UI design thinking — components, layouts, color, typography | frontend-specialist, seo-specialist |
| 18 | `game-development` | Game development orchestrator — routes to platform-specific | game-designer, mobile-game-developer, pc-game-developer |
| 19 | `geo-fundamentals` | Generative Engine Optimization for AI search (ChatGPT, Claude) | seo-specialist |
| 20 | `graphql-patterns` | GraphQL schema design, resolvers, best practices | Specialized |
| 21 | `i18n-localization` | Internationalization — translations, locale files, RTL | mobile-developer, documentation-agent |
| 22 | `inertia-performance` | Inertia.js optimization for Laravel + React | backend-specialist, ai-code-reviewer |
| 23 | `kubernetes-patterns` | K8s deployment, scaling, service discovery, config management | devops-engineer |
| 24 | `laravel-performance` | Laravel optimization — impact-driven prioritization | ai-code-reviewer, code-generator-agent, test-generator |
| 25 | `lint-and-validate` | Auto quality control, linting, static analysis | Specialized |
| 26 | `mcp-builder` | Model Context Protocol server building | backend-specialist |
| 27 | `microservices-communication` | gRPC, message queues, event-driven, service mesh | Specialized |
| 28 | `mobile-design` | Mobile-first design — touch, performance, platform conventions | mobile-developer, mobile-game-developer |
| 29 | `monitoring-observability` | Prometheus, Grafana, ELK, OpenTelemetry, SLO/SLI/SLA | devops-engineer, performance-optimizer |
| 30 | `nestjs-expert` | NestJS module architecture, DI, guards, interceptors, testing | Specialized |
| 31 | `nextjs-best-practices` | App Router, Server Components, data fetching, routing | frontend-specialist |
| 32 | `nodejs-best-practices` | Node.js framework selection, async patterns, security | Specialized |
| 33 | `nosql-patterns` | MongoDB, Redis patterns | database-architect |
| 34 | `parallel-agents` | Multi-agent orchestration using Agent Tool | orchestrator |
| 35 | `performance-profiling` | Measurement, analysis, optimization techniques | laravel-specialist, security-auditor, penetration-tester, performance-optimizer, mobile-game-developer, pc-game-developer, refactor-agent, seo-specialist |
| 36 | `plan-writing` | Structured task planning with dependencies | orchestrator, project-planner, explorer-agent, documentation-writer, game-designer |
| 37 | `powershell-windows` | PowerShell patterns, pitfalls, error handling | devops-engineer, orchestrator |
| 38 | `prisma-expert` | Schema design, migrations, query optimization, relations | database-architect |
| 39 | `python-patterns` | Python framework selection, async, type hints | Specialized |
| 40 | `react-native-performance` | React Native/Expo optimization — lists, animations, native modules | Specialized |
| 41 | `react-patterns` | Modern React hooks, composition, performance, TypeScript | frontend-specialist, code-generator-agent, test-generator, mobile-developer, performance-optimizer |
| 42 | `react-performance` | React optimization — Vercel Best Practices | frontend-specialist, ai-code-reviewer |
| 43 | `red-team-tactics` | MITRE ATT&CK, attack phases, detection evasion | security-auditor, penetration-tester |
| 44 | `seo-fundamentals` | E-E-A-T, Core Web Vitals, Google algorithms | seo-specialist |
| 45 | `server-management` | Process management, monitoring, scaling decisions | devops-engineer |
| 46 | `state-management` | React (Redux, Zustand), Vue (Pinia) patterns | frontend-specialist |
| 47 | `systematic-debugging` | 4-phase debugging methodology, root cause analysis | debugger, self-correction-agent, triage-agent, explorer-agent |
| 48 | `tailwind-patterns` | Tailwind CSS v4, CSS-first config, container queries | frontend-specialist |
| 49 | `tdd-workflow` | Test-Driven Development RED-GREEN-REFACTOR cycle | Specialized |
| 50 | `terraform-iac` | Infrastructure as Code, multi-cloud, state management | devops-engineer |
| 51 | `testing-mastery` | Unified testing (unit, integration, contract, E2E, TDD) | test-engineer, ai-code-reviewer, security-auditor, backend-specialist, pc-game-developer, code-generator-agent, test-generator |
| 52 | `testing-patterns` | Unit, integration, mocking strategies | laravel-specialist, self-correction-agent |
| 53 | `typescript-expert` | Type-level programming, performance, monorepo, migration | Specialized |
| 54 | `ui-ux-pro-max` | Design intelligence — 67 styles, 21 palettes, 57 fonts, 13 stacks | Specialized |
| 55 | `vector-databases` | Similarity search, embeddings, RAG for AI/ML | backend-specialist, database-architect |
| 56 | `velzon-admin` | Velzon admin template — React, Bootstrap 5, Reactstrap, Redux | Specialized |
| 57 | `vue-expert` | Vue 3 Composition API, Pinia, Nuxt.js integration | Specialized |
| 58 | `vulnerability-scanner` | OWASP 2025, Supply Chain Security, attack surface mapping | backend-specialist, ai-code-reviewer, security-auditor, penetration-tester |
| 59 | `webapp-testing` | E2E testing, Playwright, deep audit strategies | Specialized |

---

## Skill Loading Protocol

### Automatic Loading
Skills được tự động load khi agent khởi động, dựa trên `skills:` field trong frontmatter của agent file.

### Manual Loading
User có thể yêu cầu load skill cụ thể:
```
"Use the Flutter rule"     → mobile-design
"Apply PostgreSQL patterns" → database-design
"I want mobile security"   → vulnerability-scanner
```

### Loading Priority
```
P0: GEMINI.md rules (always active)
P1: Agent definition rules
P2: Skill instructions (SKILL.md)
```

### Selective Reading Protocol
```
Agent activated → Check frontmatter "skills:" field
    │
    └── For EACH skill:
        ├── Read SKILL.md (INDEX only)
        ├── Find relevant sections
        └── Read ONLY matching sections
```

> ⚠️ **KHÔNG** đọc tất cả files trong skill folder. Chỉ đọc `SKILL.md` rồi sections liên quan.

---

> **See also:** [SKILL-DISCOVERY.md](../SKILL-DISCOVERY.md) | [Agent Catalog](../agents/AGENT-CATALOG.md) | [Rules Catalog](../rules/RULES-CATALOG.md)

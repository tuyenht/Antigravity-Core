# Rules Catalog — Antigravity-Core

**Version:** 4.1.0  
**Last Updated:** 2026-02-25  
**Total Rules:** 129 (across 11 categories)

---

## Table of Contents

- [Overview](#overview)
- [Auto-Activation System](#auto-activation-system)
- [Rules by Category](#rules-by-category)

---

## Overview

Rules là các **expert-level best practices** được tự động load dựa trên context (file extension, project config, request keywords). Hệ thống sử dụng **3-layer detection** để chọn rules phù hợp.

**Cấu trúc:** `.agent/rules/<category>/<rule-name>.md`  
**Index:** `.agent/rules/RULES-INDEX.md` (master index)  
**Core:** `.agent/rules/STANDARDS.md` (Golden Rule — luôn active)

---

## Auto-Activation System

### Layer 1: File Extension Detection

| Extension | Rules loaded |
|-----------|-------------|
| `.vue` | `frontend-frameworks/vue3.md`, `typescript/vue3.md` |
| `.svelte` | `frontend-frameworks/svelte.md` |
| `.astro` | `frontend-frameworks/astro.md` |
| `.swift` | `mobile/ios-swift.md` |
| `.kt` | `mobile/android-kotlin.md` |
| `.dart` | `mobile/flutter.md` |
| `.php` | `backend-frameworks/laravel.md` |
| `.py` | `python/rest-api.md` hoặc `python/backend-patterns.md` |
| `.sql` | `database/postgresql.md`, `database/query-optimization.md` |
| `.graphql` | `backend-frameworks/graphql.md` |
| `.proto` | `backend-frameworks/grpc.md` |
| `.component.ts` | `frontend-frameworks/angular.md` |

### Layer 2: Project Config Detection

| Config File | Rules loaded |
|-------------|-------------|
| `package.json` + next | `nextjs/app-router.md` |
| `package.json` + react-native | `mobile/react-native.md` |
| `package.json` + vue | `frontend-frameworks/vue3.md` |
| `composer.json` + laravel | `backend-frameworks/laravel.md` |
| `pubspec.yaml` | `mobile/flutter.md` |
| `requirements.txt` / `pyproject.toml` | `python/rest-api.md` |

### Layer 3: Keyword Detection

| Keywords | Rules loaded |
|----------|-------------|
| `debug`, `fix`, `error` | `agentic-ai/debugging-agent.md` |
| `test`, `unit test` | `agentic-ai/test-writing-agent.md` |
| `security`, `audit` | `agentic-ai/security-audit-agent.md` |
| `refactor`, `cleanup` | `agentic-ai/refactoring-agent.md` |
| `optimize`, `slow` | `agentic-ai/performance-optimization-agent.md` |
| `api design` | `agentic-ai/api-design-agent.md` |
| `database`, `schema` | `agentic-ai/database-design-agent.md` |
| `deploy`, `ci/cd` | `agentic-ai/devops-cicd-agent.md` |
| `review`, `PR` | `agentic-ai/code-review-agent.md` |

### Loading Limits

| Context | Max Rules |
|---------|-----------|
| Single file edit | 2-3 |
| Feature build | 3-5 |
| Multi-file task | 5-7 |
| Architecture | 5+ |

---

## Rules by Category

### 1. Agentic AI (12 rules)
Expert reasoning frameworks cho AI agents.

| Rule | Chức năng |
|------|-----------|
| `api-design-agent.md` | API design patterns và decision-making |
| `code-migration-agent.md` | Safe code migration strategies |
| `code-review-agent.md` | Constructive code review methodology |
| `database-design-agent.md` | Database architecture decisions |
| `debugging-agent.md` | Systematic debugging framework |
| `devops-cicd-agent.md` | CI/CD pipeline design |
| `performance-optimization-agent.md` | Performance analysis và optimization |
| `prompt-engineering.md` | Prompt engineering best practices |
| `refactoring-agent.md` | Safe refactoring methodology |
| `security-audit-agent.md` | Security audit framework |
| `strong-reasoner-planner.md` | Strong reasoning và planning |
| `test-writing-agent.md` | Test writing strategies |

---

### 2. Backend Frameworks (12 rules)
Backend development across frameworks.

| Rule | Framework/Protocol |
|------|--------------------|
| `aspnet-core.md` | ASP.NET Core (.NET 8/9) |
| `connect-rpc.md` | Connect-RPC Protocol, Buf v2 |
| `express.md` | Express.js (TypeScript) |
| `fastapi.md` | FastAPI (Python async) |
| `flask.md` | Flask (Python) |
| `graphql.md` | GraphQL (Yoga/Pothos) |
| `grpc.md` | gRPC, Protocol Buffers |
| `laravel.md` | Laravel 12+ (PHP 8.2+) |
| `message-queue.md` | BullMQ, RabbitMQ, event bus |
| `rest-api.md` | REST API Design Patterns |
| `sse.md` | Server-Sent Events |
| `websocket.md` | WebSocket, Socket.IO |

---

### 3. Database (10 rules)

| Rule | Chức năng |
|------|-----------|
| `design.md` | Schema design principles |
| `graph.md` | Graph database patterns |
| `migrations.md` | Zero-downtime migration strategies |
| `mongodb.md` | MongoDB patterns |
| `mysql.md` | MySQL/MariaDB optimization |
| `postgresql.md` | PostgreSQL advanced features |
| `query-optimization.md` | EXPLAIN ANALYZE, indexing |
| `redis.md` | Redis caching patterns |
| `timeseries.md` | InfluxDB, TimescaleDB |
| `vector.md` | Vector database patterns |

---

### 4. Frontend Frameworks (7 rules)

| Rule | Framework |
|------|-----------|
| `angular.md` | Angular 17+ (Signals) |
| `astro.md` | Astro (Islands Architecture) |
| `remix.md` | Remix (Web Standards) |
| `solidjs.md` | Solid.js (Fine-grained reactivity) |
| `svelte.md` | Svelte 5 (Runes) |
| `tailwind.md` | Tailwind CSS v4 |
| `vue3.md` | Vue 3 (Composition API) |

---

### 5. Mobile (10 rules)

| Rule | Chức năng |
|------|-----------|
| `android-kotlin.md` | Android Kotlin patterns |
| `cross-platform.md` | Cross-platform strategies |
| `deployment.md` | App Store / Google Play |
| `flutter.md` | Flutter/Dart patterns |
| `ios-swift.md` | iOS Swift patterns |
| `performance.md` | Mobile performance optimization |
| `react-native.md` | React Native patterns |
| `security.md` | OWASP MASVS |
| `testing.md` | Mobile testing strategies |
| `ui-ux.md` | Mobile UI/UX conventions |

---

### 6. Next.js (13 rules)

| Rule | Chức năng |
|------|-----------|
| `api-routes.md` | API route patterns |
| `app-router.md` | App Router architecture |
| `authentication.md` | Auth.js v5 integration |
| `database.md` | Database integration |
| `deployment.md` | Deployment strategies |
| `i18n.md` | Internationalization |
| `middleware.md` | Middleware patterns |
| `performance.md` | Performance optimization |
| `realtime.md` | Realtime features |
| `seo.md` | SEO optimization |
| `server-actions.md` | Server Actions & Mutations |
| `state-management.md` | State management |
| `testing.md` | Testing strategies |

---

### 7. Python (14 rules)

| Rule | Domain |
|------|--------|
| `ai-ml.md` | AI/ML patterns |
| `async-programming.md` | Async/await patterns |
| `automation.md` | Scripting & automation |
| `backend-patterns.md` | Backend architecture |
| `cli-development.md` | CLI tool development |
| `data-engineering.md` | Data pipelines |
| `data-science.md` | Data science patterns |
| `devops.md` | DevOps automation |
| `package-development.md` | Package publishing |
| `rest-api.md` | REST API development |
| `scientific-computing.md` | Scientific computing |
| `security.md` | Security best practices |
| `testing.md` | Testing (pytest, etc.) |
| `web-scraping.md` | Web scraping patterns |

---

### 8. TypeScript (13 rules)

| Rule | Domain |
|------|--------|
| `angular.md` | Angular + TypeScript |
| `design-patterns.md` | Design patterns in TS |
| `expo.md` | Expo + TypeScript |
| `generics.md` | Advanced generics |
| `graphql.md` | GraphQL + TypeScript |
| `monorepo.md` | Monorepo architecture |
| `nestjs.md` | NestJS + TypeScript |
| `nodejs-backend.md` | Node.js backend |
| `react-native.md` | React Native + TS |
| `strict-mode.md` | Strict mode safety |
| `testing.md` | Testing in TypeScript |
| `tooling.md` | Modern tooling |
| `vue3.md` | Vue 3 + TypeScript |

---

### 9. Web Development (12 rules)
Organized in subdirectories:

| Subdirectory | Rule | Domain |
|-------------|------|--------|
| `core/` | `javascript-es2024.md` | ES2024+ features |
| `core/` | `modern-css-responsive.md` | CSS 2024+ |
| `core/` | `semantic-html-accessibility.md` | WCAG 2.2 |
| `core/` | `web-components.md` | Web Components |
| `core/` | `webassembly.md` | WebAssembly |
| `browser/` | `modern-browser-apis.md` | Modern Browser APIs |
| `performance/` | `core-web-vitals.md` | INP, LCP, CLS |
| `security/` | `owasp-web-security.md` | OWASP Web Security |
| `architecture/` | `pwa-expert.md` | Progressive Web Apps |
| `ui-ux/` | `animation-motion.md` | Animation & Motion |
| `ui-ux/` | `forms-validation.md` | Forms & Validation |
| `ui-ux/` | `typography.md` | Typography |

---

### 10. Standards (25 rules = 16 general + 9 framework)

**General Standards (16):**

| Rule | Chức năng |
|------|-----------|
| `accessibility-standards.md` | Accessibility requirements |
| `api-design-conventions.md` | API design conventions |
| `api-documentation-standards.md` | API documentation |
| `api-security-conventions.md` | API security |
| `ci-cd-conventions.md` | CI/CD pipeline |
| `ci-cd-security-conventions.md` | CI/CD security |
| `code-quality-standards.md` | Code quality metrics |
| `devops-standards.md` | DevOps best practices |
| `documentation-standards.md` | Documentation requirements |
| `incident-response-playbook.md` | Incident response |
| `monitoring-standards.md` | Monitoring requirements |
| `owasp-top10-guide.md` | OWASP Top 10 guide |
| `security-testing-templates.md` | Security testing |
| `supply-chain-security.md` | Supply chain security |
| `technical-standards.md` | Technical standards |
| `testing-standards.md` | Testing requirements |

**Framework Standards (9):**

| Rule | Framework |
|------|-----------|
| `frameworks/django-conventions.md` | Django |
| `frameworks/fastapi-conventions.md` | FastAPI |
| `frameworks/flutter-conventions.md` | Flutter |
| `frameworks/inertia-react-conventions.md` | Inertia.js + React |
| `frameworks/laravel-conventions.md` | Laravel |
| `frameworks/nextjs-conventions.md` | Next.js |
| `frameworks/react-native-conventions.md` | React Native |
| `frameworks/svelte-conventions.md` | Svelte |
| `frameworks/vue3-conventions.md` | Vue 3 |

---

### 11. Shared (1 rule)

| Rule | Chức năng |
|------|-----------|
| `output-templates.md` | Common output templates across agents |

---

> **See also:** [RULES-INDEX.md](../../rules/RULES-INDEX.md) | [STANDARDS.md](../../rules/STANDARDS.md) | [Agent Catalog](../agents/AGENT-CATALOG.md)

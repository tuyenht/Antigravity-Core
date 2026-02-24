# Expert Rules Index & Auto-Activation System

> **Version:** 4.0.1 | **Updated:** 2026-02-24  
> **Purpose:** Automatic rule loading based on context detection  
> **Priority:** P0 - Load at session start  
> **Engine:** `systems/auto-rule-discovery.md` (v4.0 automated discovery)

---

## 🚀 Auto-Activation Protocol

### How It Works

```
User Request → Context Detection → Rule Matching → Auto-Load
       │              │                 │            │
       │              │                 │            └── Apply relevant rules
       │              │                 └── Match keywords/file types
       │              └── Analyze request + open files + project type
       └── Parse intent and domain
```

### Detection Priority

1. **File Extension** (Highest) - Open files determine context
2. **Project Files** (High) - package.json, composer.json, etc.
3. **Keywords in Request** (Medium) - Technology mentions
4. **Explicit Mention** (Force) - User explicitly asks for a rule

---

## 📁 Rules Catalog (129 Rules)

### Agentic AI Rules (12)
| Rule | File | Trigger Keywords |
|------|------|-----------------|
| API Design Agent | `agentic-ai/api-design-agent.md` | api design, endpoint design |
| Code Migration Agent | `agentic-ai/code-migration-agent.md` | migrate, upgrade, version |
| Code Review Agent | `agentic-ai/code-review-agent.md` | review, code review, pr |
| Database Design Agent | `agentic-ai/database-design-agent.md` | schema design, database architecture |
| Debugging Agent | `agentic-ai/debugging-agent.md` | debug, bug, error, fix |
| DevOps CI/CD Agent | `agentic-ai/devops-cicd-agent.md` | ci/cd, pipeline, deploy |
| Performance Optimization | `agentic-ai/performance-optimization-agent.md` | optimize, performance, slow |
| Prompt Engineering | `agentic-ai/prompt-engineering.md` | prompt, llm, ai |
| Refactoring Agent | `agentic-ai/refactoring-agent.md` | refactor, cleanup, improve |
| Security Audit Agent | `agentic-ai/security-audit-agent.md` | security audit, vulnerability |
| Strong Reasoner Planner | `agentic-ai/strong-reasoner-planner.md` | reasoning, planning, analysis |
| Test Writing Agent | `agentic-ai/test-writing-agent.md` | test, unit test, integration |

### Backend Frameworks (12)
| Rule | File | Trigger Keywords | File Extensions |
|------|------|-----------------|-----------------| 
| ASP.NET Core | `backend-frameworks/aspnet-core.md` | aspnet, .net, c#, dotnet | `.cs`, `.csproj` |
| Connect-RPC | `backend-frameworks/connect-rpc.md` | connect, connectrpc, buf | `.proto` |
| Express | `backend-frameworks/express.md` | express, node, middleware | `.js`, `.ts` |
| FastAPI | `backend-frameworks/fastapi.md` | fastapi, starlette, pydantic | `.py` |
| Flask | `backend-frameworks/flask.md` | flask, jinja2, wsgi | `.py` |
| GraphQL | `backend-frameworks/graphql.md` | graphql, apollo, schema, resolver | `.graphql` |
| gRPC | `backend-frameworks/grpc.md` | grpc, protobuf, protocol buffers | `.proto` |
| Laravel | `backend-frameworks/laravel.md` | laravel, eloquent, artisan | `.php` |
| Message Queue | `backend-frameworks/message-queue.md` | bullmq, rabbitmq, amqp, job queue | - |
| REST API | `backend-frameworks/rest-api.md` | rest, api, endpoint, crud | - |
| SSE | `backend-frameworks/sse.md` | sse, server-sent events, eventsource | - |
| WebSocket | `backend-frameworks/websocket.md` | websocket, socket.io, real-time | - |

### Database Rules (10)
| Rule | File | Trigger Keywords | File Extensions |
|------|------|-----------------|-----------------| 
| Schema Design | `database/design.md` | schema, ERD, data model, normalization | - |
| Graph DB | `database/graph.md` | neo4j, graph db, cypher | - |
| Migrations | `database/migrations.md` | migration, schema change, alter table | - |
| MongoDB | `database/mongodb.md` | mongodb, mongoose, nosql, document db | `.js`, `.ts` |
| MySQL | `database/mysql.md` | mysql, mariadb, innodb | `.sql` |
| PostgreSQL | `database/postgresql.md` | postgres, postgresql, pg, psql | `.sql` |
| Query Optimization | `database/query-optimization.md` | slow query, explain, index | `.sql` |
| Redis | `database/redis.md` | redis, cache, caching, session | - |
| TimeSeries | `database/timeseries.md` | timeseries, influxdb, timescaledb | - |
| Vector DB | `database/vector.md` | vector, embeddings, similarity, RAG | - |

### Frontend Frameworks (7)
| Rule | File | Trigger Keywords | File Extensions |
|------|------|-----------------|-----------------| 
| Angular | `frontend-frameworks/angular.md` | angular, signals, standalone | `.component.ts` |
| Astro | `frontend-frameworks/astro.md` | astro, islands, content collections | `.astro` |
| Remix | `frontend-frameworks/remix.md` | remix, loader, action | `.tsx` |
| Solid.js | `frontend-frameworks/solidjs.md` | solid, solidjs, signals | `.tsx`, `.jsx` |
| Svelte | `frontend-frameworks/svelte.md` | svelte, sveltekit, runes | `.svelte` |
| Tailwind CSS | `frontend-frameworks/tailwind.md` | tailwind, utility-first, @apply | `tailwind.config` |
| Vue.js 3 | `frontend-frameworks/vue3.md` | vue, vue3, composition api, pinia | `.vue` |

### Mobile Rules (10)
| Rule | File | Trigger Keywords | File Extensions |
|------|------|-----------------|-----------------| 
| Android Kotlin | `mobile/android-kotlin.md` | kotlin, android, jetpack, compose | `.kt`, `.kts` |
| Cross-Platform | `mobile/cross-platform.md` | cross platform, monorepo, shared code | - |
| Mobile Deployment | `mobile/deployment.md` | app store, play store, aso, fastlane | - |
| Flutter | `mobile/flutter.md` | flutter, dart, widget | `.dart` |
| iOS Swift | `mobile/ios-swift.md` | swift, swiftui, ios, xcode | `.swift` |
| Mobile Performance | `mobile/performance.md` | mobile performance, fps, battery | - |
| React Native | `mobile/react-native.md` | react native, expo, react-native | `.tsx`, `.jsx` |
| Mobile Security | `mobile/security.md` | keychain, secure storage, biometric | - |
| Mobile Testing | `mobile/testing.md` | detox, maestro, e2e mobile | - |
| Mobile UI/UX | `mobile/ui-ux.md` | mobile design, touch, gestures | - |

### Next.js Rules (13)
| Rule | File | Trigger Keywords | File Extensions |
|------|------|-----------------|-----------------| 
| API Routes | `nextjs/api-routes.md` | next.js api, route handler | `route.ts` |
| App Router | `nextjs/app-router.md` | next.js, app router, server component | `page.tsx`, `layout.tsx` |
| Authentication | `nextjs/authentication.md` | next auth, authjs, session | - |
| Database | `nextjs/database.md` | next.js database, prisma, drizzle | - |
| Deployment | `nextjs/deployment.md` | next.js deploy, vercel, edge | - |
| i18n | `nextjs/i18n.md` | next.js i18n, internationalization | - |
| Middleware | `nextjs/middleware.md` | next.js middleware, edge | `middleware.ts` |
| Performance | `nextjs/performance.md` | next.js performance, ISR, SSG | - |
| Realtime | `nextjs/realtime.md` | next.js realtime, websocket, sse | - |
| SEO | `nextjs/seo.md` | next.js seo, metadata, sitemap | - |
| Server Actions | `nextjs/server-actions.md` | server action, use server | - |
| State Management | `nextjs/state-management.md` | next.js state, zustand, jotai | - |
| Testing | `nextjs/testing.md` | next.js testing, playwright | - |

### Python Rules (14)
| Rule | File | Trigger Keywords | File Extensions |
|------|------|-----------------|-----------------| 
| AI/ML | `python/ai-ml.md` | pytorch, tensorflow, machine learning | `.py`, `.ipynb` |
| Async Programming | `python/async-programming.md` | asyncio, aiohttp, async python | `.py` |
| Automation | `python/automation.md` | script, automation, cli | `.py` |
| Backend Patterns | `python/backend-patterns.md` | python backend, django, architecture | `.py` |
| CLI Development | `python/cli-development.md` | click, typer, argparse, cli | `.py` |
| Data Engineering | `python/data-engineering.md` | etl, pipeline, airflow, spark | `.py` |
| Data Science | `python/data-science.md` | pandas, numpy, jupyter, analysis | `.py`, `.ipynb` |
| DevOps | `python/devops.md` | python devops, ansible, fabric | `.py` |
| Package Development | `python/package-development.md` | pypi, setup.py, poetry | `pyproject.toml` |
| REST API | `python/rest-api.md` | python api, drf, django rest | `.py` |
| Scientific Computing | `python/scientific-computing.md` | scipy, matplotlib, simulation | `.py` |
| Security | `python/security.md` | python security, bandit, safety | `.py` |
| Testing | `python/testing.md` | pytest, hypothesis, mock | `.py` |
| Web Scraping | `python/web-scraping.md` | scrapy, beautifulsoup, selenium | `.py` |

### TypeScript Rules (13)
| Rule | File | Trigger Keywords | File Extensions |
|------|------|-----------------|-----------------| 
| Angular | `typescript/angular.md` | angular, typescript | `.component.ts` |
| Design Patterns | `typescript/design-patterns.md` | typescript patterns, SOLID | `.ts` |
| Expo | `typescript/expo.md` | expo, expo router | `app.json` |
| Generics | `typescript/generics.md` | generics, type parameter | `.ts`, `.tsx` |
| GraphQL | `typescript/graphql.md` | graphql typescript, codegen | `.ts` |
| Monorepo | `typescript/monorepo.md` | monorepo, turborepo, nx | `turbo.json` |
| NestJS | `typescript/nestjs.md` | nestjs, nest | `.module.ts`, `.service.ts` |
| Node.js Backend | `typescript/nodejs-backend.md` | node backend, express ts | `.ts` |
| React Native | `typescript/react-native.md` | react native typescript | `.tsx` |
| Strict Mode | `typescript/strict-mode.md` | strict, tsconfig | `tsconfig.json` |
| Testing | `typescript/testing.md` | vitest, jest, typescript test | `.test.ts`, `.spec.ts` |
| Tooling | `typescript/tooling.md` | esbuild, vite, swc, biome | - |
| Vue 3 | `typescript/vue3.md` | vue typescript, vue 3 | `.vue` |

### Web Development (12)
| Rule | File | Trigger Keywords | File Extensions |
|------|------|-----------------|-----------------| 
| JavaScript ES2024+ | `web-development/core/javascript-es2024.md` | javascript, es2024, js | `.js` |
| Modern CSS | `web-development/core/modern-css-responsive.md` | css, styling, grid, flexbox | `.css` |
| Semantic HTML/A11y | `web-development/core/semantic-html-accessibility.md` | html, accessibility, a11y, wcag | `.html` |
| Web Components | `web-development/core/web-components.md` | web components, shadow dom | - |
| WebAssembly | `web-development/core/webassembly.md` | wasm, webassembly, rust wasm | `.wasm` |
| Modern Browser APIs | `web-development/browser/modern-browser-apis.md` | browser api, fetch, service worker | - |
| Core Web Vitals | `web-development/performance/core-web-vitals.md` | cwv, lcp, fid, cls | - |
| PWA Expert | `web-development/architecture/pwa-expert.md` | pwa, service worker, offline | - |
| OWASP Web Security | `web-development/security/owasp-web-security.md` | owasp, xss, csrf, security | - |
| Animation & Motion | `web-development/ui-ux/animation-motion.md` | animation, motion, gsap | - |
| Forms & Validation | `web-development/ui-ux/forms-validation.md` | form, validation, input | - |
| Typography | `web-development/ui-ux/typography.md` | typography, font, type system | - |

### Standards — General (16)
| Rule | File | Purpose |
|------|------|---------|
| Accessibility | `standards/accessibility-standards.md` | WCAG 2.2 compliance |
| API Design | `standards/api-design-conventions.md` | REST/GraphQL conventions |
| API Documentation | `standards/api-documentation-standards.md` | OpenAPI/Swagger standards |
| API Security | `standards/api-security-conventions.md` | Auth, rate limiting, CORS |
| CI/CD | `standards/ci-cd-conventions.md` | Pipeline conventions |
| CI/CD Security | `standards/ci-cd-security-conventions.md` | Secrets, SAST/DAST |
| Code Quality | `standards/code-quality-standards.md` | Lint, formatting, complexity |
| DevOps | `standards/devops-standards.md` | Infrastructure standards |
| Documentation | `standards/documentation-standards.md` | README, API docs, comments |
| Incident Response | `standards/incident-response-playbook.md` | Runbooks, escalation |
| Monitoring | `standards/monitoring-standards.md` | Logging, metrics, alerts |
| OWASP Top 10 | `standards/owasp-top10-guide.md` | OWASP 2025 guide |
| Security Testing | `standards/security-testing-templates.md` | Pentest, SAST templates |
| Supply Chain | `standards/supply-chain-security.md` | Dependency security |
| Technical Standards | `standards/technical-standards.md` | Universal tech standards |
| Testing Standards | `standards/testing-standards.md` | Coverage targets, patterns |

### Standards — Framework Conventions (9)
| Rule | File | Framework |
|------|------|-----------|
| Django | `standards/frameworks/django-conventions.md` | Django |
| FastAPI | `standards/frameworks/fastapi-conventions.md` | FastAPI |
| Flutter | `standards/frameworks/flutter-conventions.md` | Flutter/Dart |
| Inertia + React | `standards/frameworks/inertia-react-conventions.md` | Inertia.js + React |
| Laravel | `standards/frameworks/laravel-conventions.md` | Laravel/PHP |
| Next.js | `standards/frameworks/nextjs-conventions.md` | Next.js |
| React Native | `standards/frameworks/react-native-conventions.md` | React Native |
| Svelte | `standards/frameworks/svelte-conventions.md` | SvelteKit |
| Vue 3 | `standards/frameworks/vue3-conventions.md` | Vue.js 3 |

### Shared Rules (1)
| Rule | File | Purpose |
|------|------|---------|
| Output Templates | `shared/output-templates.md` | Consolidated output format templates (CONSULT/BUILD/DEBUG/OPTIMIZE) |

---

## 🔍 Context Detection Rules

### 1. File Extension Mapping
```yaml
# High-Priority File Detection
".vue":
  - frontend-frameworks/vue3.md
  - typescript/vue3.md

".svelte":
  - frontend-frameworks/svelte.md

".astro":
  - frontend-frameworks/astro.md

".swift":
  - mobile/ios-swift.md

".kt", ".kts":
  - mobile/android-kotlin.md

".dart":
  - mobile/flutter.md

".php":
  - backend-frameworks/laravel.md

".py":
  - python/rest-api.md
  - python/backend-patterns.md

".sql":
  - database/postgresql.md
  - database/mysql.md
  - database/query-optimization.md

".graphql":
  - backend-frameworks/graphql.md

".proto":
  - backend-frameworks/grpc.md

".component.ts":
  - frontend-frameworks/angular.md
  - typescript/angular.md
```

### 2. Project File Detection
```yaml
# Project Configuration Files
"package.json + next":
  - nextjs/app-router.md
  - nextjs/performance.md

"package.json + react-native":
  - mobile/react-native.md
  - typescript/react-native.md

"package.json + vue":
  - frontend-frameworks/vue3.md
  - typescript/vue3.md

"package.json + svelte":
  - frontend-frameworks/svelte.md

"package.json + solid":
  - frontend-frameworks/solidjs.md

"package.json + astro":
  - frontend-frameworks/astro.md

"package.json + remix":
  - frontend-frameworks/remix.md

"package.json + tailwind":
  - frontend-frameworks/tailwind.md

"composer.json + laravel":
  - backend-frameworks/laravel.md

"pubspec.yaml":
  - mobile/flutter.md

"Cargo.toml":
  - web-development/core/webassembly.md

"requirements.txt | pyproject.toml":
  - python/rest-api.md
  - python/backend-patterns.md
```

### 3. Keyword Triggers
```yaml
# Intent Keywords
"create api":
  - backend-frameworks/rest-api.md
  - agentic-ai/api-design-agent.md

"grpc | protobuf | rpc service":
  - backend-frameworks/grpc.md

"connect | connectrpc | buf generate":
  - backend-frameworks/connect-rpc.md

"websocket | socket.io | real-time | chat":
  - backend-frameworks/websocket.md

"sse | server-sent events | eventsource":
  - backend-frameworks/sse.md

"bullmq | rabbitmq | message queue | job queue":
  - backend-frameworks/message-queue.md

"database design":
  - database/design.md
  - agentic-ai/database-design-agent.md

"optimize performance":
  - agentic-ai/performance-optimization-agent.md
  - web-development/performance/core-web-vitals.md

"security":
  - agentic-ai/security-audit-agent.md
  - web-development/security/owasp-web-security.md
  - mobile/security.md

"deploy":
  - agentic-ai/devops-cicd-agent.md
  - mobile/deployment.md

"test":
  - agentic-ai/test-writing-agent.md
  - mobile/testing.md

"refactor":
  - agentic-ai/refactoring-agent.md

"debug | fix | error":
  - agentic-ai/debugging-agent.md
```

---

## ⚡ Auto-Load Protocol

### When to Load Rules

```
┌─────────────────────────────────────────────────────────────┐
│                    AUTO-LOAD DECISION TREE                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. CHECK ACTIVE DOCUMENT                                   │
│     └── File extension → Load matching rules                │
│                                                             │
│  2. CHECK PROJECT FILES (if no active doc)                  │
│     └── package.json, composer.json, etc.                   │
│         └── Detect framework → Load framework rules         │
│                                                             │
│  3. PARSE USER REQUEST                                      │
│     └── Keywords → Load matching rules                      │
│                                                             │
│  4. COMBINE & DEDUPLICATE                                   │
│     └── Merge all detected rules                            │
│     └── Remove duplicates                                   │
│     └── Limit to 3-5 most relevant                          │
│                                                             │
│  5. APPLY RULES                                             │
│     └── Read frontmatter for dependencies                   │
│     └── Load in priority order                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Loading Limits

| Context | Max Rules | Priority |
|---------|-----------|----------|
| Single file edit | 2-3 | File extension + 1 keyword |
| Feature build | 3-5 | Framework + Domain + AI agent |
| Multi-file task | 5-7 | Full stack coverage |
| Architecture | 5+ | Design + Backend + Database |

---

## 📋 Rule Dependencies

### Auto-Include Rules

Some rules automatically include others:

```yaml
# When loading these... also load these
frontend-frameworks/vue3.md:
  - frontend-frameworks/tailwind.md (if tailwind detected)

frontend-frameworks/angular.md:
  - typescript/angular.md

mobile/react-native.md:
  - typescript/react-native.md
  - frontend-frameworks/tailwind.md (if nativewind)

backend-frameworks/laravel.md:
  - database/mysql.md OR database/postgresql.md
  - backend-frameworks/rest-api.md

backend-frameworks/graphql.md:
  - backend-frameworks/rest-api.md (concepts)

backend-frameworks/grpc.md:
  - backend-frameworks/rest-api.md (API design concepts)

backend-frameworks/connect-rpc.md:
  - backend-frameworks/grpc.md (native gRPC context)
  - backend-frameworks/rest-api.md (API design concepts)

backend-frameworks/websocket.md:
  - backend-frameworks/rest-api.md (HTTP upgrade context)

backend-frameworks/sse.md:
  - backend-frameworks/websocket.md (comparison/alternatives)

backend-frameworks/message-queue.md:
  - backend-frameworks/rest-api.md (API design concepts)

any mobile/*:
  - mobile/ui-ux.md
  - mobile/performance.md (for production)
```

---

## 🎯 Usage Examples

### Example 1: Vue.js Project
```
User opens: components/UserCard.vue
User asks: "Add validation to this form"

Auto-detection:
1. File extension: .vue → frontend-frameworks/vue3.md
2. Request keyword: "form" → (no specific form rule)
3. Project check: package.json has "vue" → confirms Vue 3

Rules loaded:
✅ frontend-frameworks/vue3.md
✅ typescript/vue3.md (if TypeScript)
✅ frontend-frameworks/tailwind.md (if tailwind in project)
```

### Example 2: Mobile Bug Fix
```
User opens: App.tsx
User asks: "Fix this crash on Android"

Auto-detection:
1. File extension: .tsx → Check package.json
2. Request keyword: "Android", "crash" → mobile + debugging
3. Project check: package.json has "react-native"

Rules loaded:
✅ mobile/react-native.md
✅ mobile/android-kotlin.md (Android-specific)
✅ agentic-ai/debugging-agent.md
```

### Example 3: Database Query
```
User opens: migrations/create_users_table.sql
User asks: "Optimize this query for large tables"

Auto-detection:
1. File extension: .sql → database rules
2. Request keyword: "optimize", "large tables" → optimization
3. File path: "migrations" → migration rules

Rules loaded:
✅ database/postgresql.md OR database/mysql.md
✅ database/query-optimization.md
✅ database/migrations.md
```

---

## 🔧 Manual Override

### Force Load Specific Rule

User can explicitly request:

```
"Use the Flutter rule for this"
→ Force load: mobile/flutter.md

"Apply PostgreSQL best practices"
→ Force load: database/postgresql.md

"I want mobile security patterns"
→ Force load: mobile/security.md
```

### Disable Auto-Load

```
"Don't apply any rules, just answer directly"
→ Skip auto-loading, use base knowledge only
```

---

## 📊 Rule Statistics

| Category | Count | Estimated Lines |
|----------|-------|-----------------|
| Agentic AI | 12 | ~7,000 |
| Backend Frameworks | 12 | ~10,000 |
| Database | 10 | ~6,000 |
| Frontend Frameworks | 7 | ~5,000 |
| Mobile | 10 | ~6,000 |
| Next.js | 13 | ~8,000 |
| Python | 14 | ~9,000 |
| TypeScript | 13 | ~8,000 |
| Web Development | 12 | ~5,000 |
| Standards (General) | 16 | ~4,500 |
| Standards (Framework) | 9 | ~5,000 |
| Shared | 1 | ~350 |
| **TOTAL** | **129** | **~73,850** |

---

**Last Updated:** 2026-02-24  
**Maintainer:** Antigravity Core System

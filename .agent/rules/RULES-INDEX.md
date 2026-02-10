# Expert Rules Index & Auto-Activation System

> **Version:** 1.1.0 | **Updated:** 2026-02-10  
> **Purpose:** Automatic rule loading based on context detection  
> **Priority:** P0 - Load at session start

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

## 📁 Rules Catalog

### Database Rules (10)
| Rule | File | Trigger Keywords | File Extensions |
|------|------|-----------------|-----------------|
| PostgreSQL | `database/postgresql.md` | postgres, postgresql, pg, psql, pgAdmin | `.sql` |
| MySQL | `database/mysql.md` | mysql, mariadb, innodb | `.sql` |
| MongoDB | `database/mongodb.md` | mongodb, mongoose, nosql, document db | `.js`, `.ts` |
| Redis | `database/redis.md` | redis, cache, caching, session | - |
| Schema Design | `database/design.md` | schema, ERD, data model, normalization | - |
| Query Optimization | `database/query-optimization.md` | slow query, explain, index, performance | `.sql` |
| Migrations | `database/migrations.md` | migration, schema change, alter table | - |
| TimeSeries | `database/timeseries.md` | timeseries, influxdb, timescaledb, metrics | - |
| Graph DB | `database/graph.md` | neo4j, graph db, cypher, relationships | - |
| Vector DB | `database/vector.md` | vector, embeddings, similarity, RAG, pinecone | - |

### Mobile Rules (10)
| Rule | File | Trigger Keywords | File Extensions |
|------|------|-----------------|-----------------|
| React Native | `mobile/react-native.md` | react native, expo, react-native | `.tsx`, `.jsx`, `app.json` |
| Flutter | `mobile/flutter.md` | flutter, dart, widget | `.dart`, `pubspec.yaml` |
| iOS Swift | `mobile/ios-swift.md` | swift, swiftui, ios, xcode | `.swift`, `.xcodeproj` |
| Android Kotlin | `mobile/android-kotlin.md` | kotlin, android, jetpack, compose | `.kt`, `.kts`, `build.gradle` |
| Mobile UI/UX | `mobile/ui-ux.md` | mobile design, touch, gestures | - |
| Mobile Performance | `mobile/performance.md` | mobile performance, fps, battery | - |
| Mobile Security | `mobile/security.md` | keychain, secure storage, biometric | - |
| Mobile Testing | `mobile/testing.md` | detox, maestro, e2e mobile | - |
| Mobile Deployment | `mobile/deployment.md` | app store, play store, aso, fastlane | - |
| Cross-Platform | `mobile/cross-platform.md` | cross platform, monorepo, shared code | - |

### Backend Rules (12)
| Rule | File | Trigger Keywords | File Extensions |
|------|------|-----------------|-----------------|
| Laravel | `backend-frameworks/laravel.md` | laravel, eloquent, artisan | `.php`, `composer.json` |
| ASP.NET Core | `backend-frameworks/aspnet-core.md` | aspnet, .net, c#, dotnet | `.cs`, `.csproj` |
| Express | `backend-frameworks/express.md` | express, node, middleware | `.js`, `.ts` |
| GraphQL | `backend-frameworks/graphql.md` | graphql, apollo, schema, resolver | `.graphql` |
| gRPC | `backend-frameworks/grpc.md` | grpc, protobuf, protocol buffers, rpc | `.proto` |
| Connect-RPC | `backend-frameworks/connect-rpc.md` | connect, connectrpc, connect-rpc, buf | `.proto` |
| REST API | `backend-frameworks/rest-api.md` | rest, api, endpoint, crud | - |
| WebSocket | `backend-frameworks/websocket.md` | websocket, socket.io, real-time, ws | - |
| SSE | `backend-frameworks/sse.md` | sse, server-sent events, eventsource, event stream | - |
| Message Queue | `backend-frameworks/message-queue.md` | bullmq, rabbitmq, message queue, amqp, job queue | - |
| FastAPI | `backend-frameworks/fastapi.md` | fastapi, starlette, pydantic | `.py` |
| Flask | `backend-frameworks/flask.md` | flask, jinja2, wsgi | `.py` |

### TypeScript Rules (6)
| Rule | File | Trigger Keywords | File Extensions |
|------|------|-----------------|-----------------|
| TypeScript Core | `typescript/core.md` | typescript, ts, types, interface | `.ts`, `.tsx` |
| React Native TS | `typescript/react-native.md` | react native typescript | `.tsx` |
| Expo | `typescript/expo.md` | expo, expo router | `app.json` |
| Vue 3 TS | `typescript/vue3.md` | vue typescript, vue 3 | `.vue` |
| Angular | `typescript/angular.md` | angular, typescript | `.component.ts` |
| NestJS | `typescript/nestjs.md` | nestjs, nest | `.module.ts`, `.service.ts` |

### Frontend Frameworks (7)
| Rule | File | Trigger Keywords | File Extensions |
|------|------|-----------------|-----------------|
| Vue.js 3 | `frontend-frameworks/vue3.md` | vue, vue3, composition api, pinia | `.vue` |
| Angular | `frontend-frameworks/angular.md` | angular, signals, standalone | `.component.ts` |
| Svelte | `frontend-frameworks/svelte.md` | svelte, sveltekit, runes | `.svelte` |
| Solid.js | `frontend-frameworks/solidjs.md` | solid, solidjs, signals | `.tsx`, `.jsx` |
| Astro | `frontend-frameworks/astro.md` | astro, islands, content collections | `.astro` |
| Remix | `frontend-frameworks/remix.md` | remix, loader, action | `.tsx` |
| Tailwind CSS | `frontend-frameworks/tailwind.md` | tailwind, utility-first, @apply | `tailwind.config` |

### Next.js Rules (4)
| Rule | File | Trigger Keywords | File Extensions |
|------|------|-----------------|-----------------|
| App Router | `nextjs/app-router.md` | next.js, app router, server component | `page.tsx`, `layout.tsx` |
| Server Actions | `nextjs/server-actions.md` | server action, use server | - |
| Authentication | `nextjs/authentication.md` | next auth, authjs, session | - |
| Performance | `nextjs/performance.md` | next.js performance, ISR, SSG | - |

### Python Rules (5)
| Rule | File | Trigger Keywords | File Extensions |
|------|------|-----------------|-----------------|
| FastAPI | `python/fastapi.md` | fastapi, pydantic, uvicorn | `.py` |
| Flask | `python/flask.md` | flask, jinja, blueprint | `.py` |
| AI/ML | `python/ai-ml.md` | pytorch, tensorflow, machine learning | `.py`, `.ipynb` |
| Data Science | `python/data-science.md` | pandas, numpy, jupyter, analysis | `.py`, `.ipynb` |
| Automation | `python/automation.md` | script, automation, cli | `.py` |

### Web Development (8)
| Rule | File | Trigger Keywords | File Extensions |
|------|------|-----------------|-----------------|
| HTML/A11y | `web-development/html-a11y.md` | html, accessibility, a11y, wcag | `.html` |
| Modern CSS | `web-development/css.md` | css, styling, grid, flexbox | `.css` |
| JavaScript | `web-development/javascript.md` | javascript, es2024, js | `.js` |
| Web Components | `web-development/web-components.md` | web components, shadow dom, custom elements | - |
| WebAssembly | `web-development/webassembly.md` | wasm, webassembly, rust wasm | `.wasm` |
| Core Web Vitals | `web-development/core-web-vitals.md` | cwv, lcp, fid, cls, performance | - |
| Web Security | `web-development/security.md` | owasp, xss, csrf, security | - |
| Animation | `web-development/animation.md` | animation, motion, gsap | - |

### Agentic AI Rules (12)
| Rule | File | Trigger Keywords | File Extensions |
|------|------|-----------------|-----------------|
| Strong Reasoning | `agentic-ai/reasoning.md` | reasoning, planning, analysis | - |
| Debugging | `agentic-ai/debugging.md` | debug, bug, error, fix | - |
| Code Review | `agentic-ai/code-review.md` | review, code review, pr | - |
| Testing | `agentic-ai/testing.md` | test, unit test, integration | `.test.ts`, `.spec.ts` |
| Security Audit | `agentic-ai/security.md` | security audit, vulnerability | - |
| Refactoring | `agentic-ai/refactoring.md` | refactor, cleanup, improve | - |
| API Design | `agentic-ai/api-design.md` | api design, endpoint design | - |
| Database Design | `agentic-ai/database-design.md` | schema design, database architecture | - |
| DevOps | `agentic-ai/devops.md` | ci/cd, pipeline, deploy | - |
| Performance | `agentic-ai/performance.md` | optimize, performance, slow | - |
| Migration | `agentic-ai/migration.md` | migrate, upgrade, version | - |
| Prompt Engineering | `agentic-ai/prompt.md` | prompt, llm, ai | - |

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
  - python/fastapi.md
  - python/flask.md

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
  - web-development/webassembly.md

"requirements.txt | pyproject.toml":
  - python/fastapi.md
  - python/flask.md
```

### 3. Keyword Triggers
```yaml
# Intent Keywords
"create api":
  - backend-frameworks/rest-api.md
  - agentic-ai/api-design.md

"grpc | protobuf | rpc service":
  - backend-frameworks/grpc.md

"connect | connectrpc | buf generate":
  - backend-frameworks/connect-rpc.md

"websocket | socket.io | real-time | chat":
  - backend-frameworks/websocket.md

"sse | server-sent events | eventsource | event stream":
  - backend-frameworks/sse.md

"bullmq | rabbitmq | message queue | job queue | worker":
  - backend-frameworks/message-queue.md

"database design":
  - database/design.md
  - agentic-ai/database-design.md

"optimize performance":
  - agentic-ai/performance.md
  - web-development/core-web-vitals.md

"security":
  - agentic-ai/security.md
  - web-development/security.md
  - mobile/security.md

"deploy":
  - agentic-ai/devops.md
  - mobile/deployment.md

"test":
  - agentic-ai/testing.md
  - mobile/testing.md

"refactor":
  - agentic-ai/refactoring.md

"debug | fix | error":
  - agentic-ai/debugging.md
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
  - typescript/core.md

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
✅ agentic-ai/debugging.md
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

| Category | Count | Total Lines (est.) |
|----------|-------|-------------------|
| Database | 10 | ~6,000 |
| Mobile | 10 | ~6,000 |
| Backend | 12 | ~10,000 |
| TypeScript | 6 | ~4,000 |
| Frontend Frameworks | 7 | ~5,000 |
| Next.js | 4 | ~3,000 |
| Python | 5 | ~3,500 |
| Web Development | 8 | ~5,000 |
| Agentic AI | 12 | ~7,000 |
| **TOTAL** | **74** | **~49,500** |

---

**Last Updated:** 2026-02-10  
**Maintainer:** Antigravity Core System

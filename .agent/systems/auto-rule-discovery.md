# 🔍 Auto-Rule Discovery Engine

> **Version:** 1.0.0 | **Updated:** 2026-02-10  
> **Purpose:** Intelligent, automated rule loading based on project context  
> **Priority:** P0 — Core system, loaded at session start

---

## Overview

The Auto-Rule Discovery Engine **eliminates manual rule selection** by automatically scanning the project context and loading the most relevant expert rules. It replaces the manual YAML mappings in RULES-INDEX with an executable protocol.

```
┌─────────────────────────────────────────────────────────────────┐
│               AUTO-RULE DISCOVERY ENGINE                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  INPUT: Project files + User request + Active document           │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │ Layer 1      │  │ Layer 2      │  │ Layer 3              │   │
│  │ File Scan    │→ │ Config Scan  │→ │ Request Analysis     │   │
│  │ (ext-based)  │  │ (pkg, config)│  │ (keyword matching)   │   │
│  └──────┬───────┘  └──────┬───────┘  └──────────┬───────────┘   │
│         │                 │                      │               │
│         └────────┬────────┴──────────────────────┘               │
│                  ▼                                                │
│         ┌──────────────┐                                         │
│         │ Merge & Rank │                                         │
│         │ (dedup,score)│                                         │
│         └──────┬───────┘                                         │
│                ▼                                                  │
│         ┌──────────────┐                                         │
│         │ Dependency   │                                         │
│         │ Resolution   │                                         │
│         └──────┬───────┘                                         │
│                ▼                                                  │
│         ┌──────────────┐                                         │
│         │ Load Rules   │ (max 7-10 per session)                  │
│         └──────────────┘                                         │
│                                                                  │
│  OUTPUT: Ordered list of rules to read + dependency chain        │
└─────────────────────────────────────────────────────────────────┘
```

---

## Protocol: 3-Layer Detection

### Layer 1: File Extension Scan (Priority Score: 10)

Scan the active document and open files for extension-based rule matching.

```yaml
# Extension → Rule Mapping (highest priority)
file_extension_rules:
  ".vue":
    rules: [frontend-frameworks/vue3.md, typescript/vue3.md]
    score: 10

  ".svelte":
    rules: [frontend-frameworks/svelte.md]
    score: 10

  ".astro":
    rules: [frontend-frameworks/astro.md]
    score: 10

  ".swift":
    rules: [mobile/ios-swift.md]
    score: 10

  ".kt":
    rules: [mobile/android-kotlin.md]
    score: 10

  ".dart":
    rules: [mobile/flutter.md]
    score: 10

  ".proto":
    rules: [backend-frameworks/grpc.md, backend-frameworks/connect-rpc.md]
    score: 10

  ".php":
    rules: [backend-frameworks/laravel.md]
    score: 10

  ".py":
    rules: [python/rest-api.md]  # Default; refined by Layer 2
    score: 10

  ".sql":
    rules: [database/postgresql.md, database/query-optimization.md]
    score: 10

  ".graphql":
    rules: [backend-frameworks/graphql.md]
    score: 10

  ".ts", ".tsx":
    rules: [typescript/strict-mode.md]
    score: 8  # Common, co-loaded with framework rules

  ".css":
    rules: [web-development/core/modern-css-responsive.md]
    score: 8

  ".html":
    rules: [web-development/core/semantic-html-accessibility.md]
    score: 8

  ".js", ".jsx":
    rules: [web-development/core/javascript-es2024.md]
    score: 7
```

### Layer 2: Project Config Scan (Priority Score: 8)

Scan project root for configuration files to detect frameworks.

```yaml
# Config file detection matrix
project_config_rules:
  "package.json":
    scan_fields: [dependencies, devDependencies]
    patterns:
      "next":
        rules: [nextjs/app-router.md, nextjs/server-actions.md]
        score: 8
      "react":
        rules: [typescript/react-native.md]  # Closest TypeScript-React rule
        score: 8
      "vue":
        rules: [frontend-frameworks/vue3.md]
        score: 8
      "svelte":
        rules: [frontend-frameworks/svelte.md]
        score: 8
      "@angular/core":
        rules: [frontend-frameworks/angular.md, typescript/angular.md]
        score: 8
      "react-native":
        rules: [mobile/react-native.md, typescript/react-native.md]
        score: 8
      "tailwindcss":
        rules: [frontend-frameworks/tailwind.md]
        score: 7
      "@connectrpc/connect":
        rules: [backend-frameworks/connect-rpc.md]
        score: 8
      "bullmq":
        rules: [backend-frameworks/message-queue.md]
        score: 8
      "socket.io":
        rules: [backend-frameworks/websocket.md]
        score: 8
      "prisma":
        rules: [database/postgresql.md]
        score: 7

  "composer.json":
    scan_fields: [require, require-dev]
    patterns:
      "laravel/framework":
        rules: [backend-frameworks/laravel.md]
        score: 9
      "inertiajs/inertia-laravel":
        rules: [backend-frameworks/laravel.md]
        score: 8

  "pubspec.yaml":
    rules: [mobile/flutter.md]
    score: 9

  "Cargo.toml":
    rules: [web-development/webassembly.md]
    score: 8

  "requirements.txt | pyproject.toml":
    scan_content: true
    patterns:
      "fastapi":
        rules: [python/rest-api.md]
        score: 9
      "flask":
        rules: [python/backend-patterns.md]
        score: 9
      "django":
        rules: [python/backend-patterns.md]  # Closest pattern
        score: 7

  ".csproj":
    rules: [backend-frameworks/aspnet-core.md]
    score: 9

  "docker-compose.yml | Dockerfile":
    rules: []  # Loaded via keyword only
    score: 5
```

### Layer 3: Request Keyword Analysis (Priority Score: 5)

Match user request text against intent keywords.

```yaml
# Keyword → Rule Mapping (supplementary)
keyword_rules:
  # Build & Architecture
  "create api | api design | endpoint":
    rules: [backend-frameworks/rest-api.md, agentic-ai/api-design-agent.md]
    score: 5

  "grpc | protobuf | rpc service":
    rules: [backend-frameworks/grpc.md]
    score: 6

  "connect | connectrpc | buf generate":
    rules: [backend-frameworks/connect-rpc.md]
    score: 6

  "websocket | socket.io | real-time | chat":
    rules: [backend-frameworks/websocket.md]
    score: 6

  "sse | server-sent events | eventsource | event stream":
    rules: [backend-frameworks/sse.md]
    score: 6

  "bullmq | rabbitmq | message queue | job queue | worker":
    rules: [backend-frameworks/message-queue.md]
    score: 6

  "graphql | apollo | schema resolver":
    rules: [backend-frameworks/graphql.md]
    score: 6

  # Quality & Process
  "debug | fix | error | bug":
    rules: [agentic-ai/debugging-agent.md]
    score: 5

  "test | unit test | integration test":
    rules: [agentic-ai/test-writing-agent.md]
    score: 5

  "security | audit | vulnerability | owasp":
    rules: [agentic-ai/security-audit-agent.md]
    score: 5

  "refactor | cleanup | code smell":
    rules: [agentic-ai/refactoring-agent.md]
    score: 5

  "optimize | slow | performance | latency":
    rules: [agentic-ai/performance-optimization-agent.md]
    score: 5

  "deploy | ci/cd | pipeline | docker":
    rules: [agentic-ai/devops-cicd-agent.md]
    score: 5

  "review | PR | code review":
    rules: [agentic-ai/code-review-agent.md]
    score: 5

  "migrate | upgrade | version":
    rules: [agentic-ai/code-migration-agent.md]
    score: 5

  # Database
  "schema | ERD | data model | normalization":
    rules: [database/design.md]
    score: 5

  "slow query | explain | index | query performance":
    rules: [database/query-optimization.md]
    score: 6

  "redis | cache | caching":
    rules: [database/redis.md]
    score: 5

  "mongodb | mongoose | nosql":
    rules: [database/mongodb.md]
    score: 5

  "migration | alter table | add column":
    rules: [database/migrations.md]
    score: 5
```

---

## Merge & Rank Algorithm

```
FUNCTION discoverRules(activeFile, projectRoot, userRequest):
  candidates = {}

  // Layer 1: File extensions
  FOR EACH openFile IN [activeFile, ...openFiles]:
    ext = getExtension(openFile)
    IF ext IN file_extension_rules:
      FOR EACH rule IN file_extension_rules[ext].rules:
        candidates[rule] = MAX(candidates[rule] || 0, file_extension_rules[ext].score)

  // Layer 2: Project configs
  FOR EACH configFile IN projectRoot:
    IF configFile IN project_config_rules:
      matchedPatterns = scanConfig(configFile, project_config_rules[configFile])
      FOR EACH match IN matchedPatterns:
        FOR EACH rule IN match.rules:
          candidates[rule] = MAX(candidates[rule] || 0, match.score)

  // Layer 3: Keywords
  FOR EACH keyword IN extractKeywords(userRequest):
    IF keyword MATCHES keyword_rules:
      FOR EACH rule IN keyword_rules[keyword].rules:
        candidates[rule] = MAX(candidates[rule] || 0, keyword_rules[keyword].score)

  // Sort by score (descending), deduplicate
  ranked = SORT(candidates, BY score DESC)

  // Apply load limits
  RETURN applyLimits(ranked, getScope(userRequest))
```

---

## Dependency Resolution

After primary rules are selected, auto-load their dependencies.

```yaml
# Rule dependency graph
dependencies:
  backend-frameworks/connect-rpc.md:
    requires: [backend-frameworks/grpc.md]
    optional: [backend-frameworks/rest-api.md]

  backend-frameworks/sse.md:
    optional: [backend-frameworks/websocket.md]

  backend-frameworks/message-queue.md:
    optional: [backend-frameworks/rest-api.md]

  backend-frameworks/grpc.md:
    optional: [backend-frameworks/rest-api.md]

  backend-frameworks/graphql.md:
    optional: [backend-frameworks/websocket.md]

  nextjs/app-router.md:
    requires: [typescript/strict-mode.md]
    optional: [nextjs/server-actions.md, nextjs/authentication.md]

  frontend-frameworks/vue3.md:
    optional: [typescript/vue3.md]

  mobile/react-native.md:
    requires: [typescript/react-native.md]
    optional: [mobile/performance.md]

  mobile/flutter.md:
    optional: [mobile/performance.md]

  # Cross-category
  backend-frameworks/laravel.md:
    optional: [database/postgresql.md, database/query-optimization.md]

  database/query-optimization.md:
    optional: [database/design.md]

resolution_protocol:
  1: Load all `requires` dependencies (mandatory)
  2: Load `optional` dependencies only if score > 6
  3: Don't load more than 2 transitive levels
  4: Total loaded rules MUST NOT exceed max limit
```

---

## Load Limits

```yaml
# Max rules per context type
limits:
  single_file_edit:
    max_rules: 5
    strategy: "Top 2-3 extension + 1-2 keyword"

  feature_build:
    max_rules: 7
    strategy: "Framework + domain + 1-2 agentic"

  multi_file_task:
    max_rules: 9
    strategy: "Full stack coverage"

  architecture_review:
    max_rules: 12
    strategy: "Design + backend + DB + all relevant"

scope_detection:
  single_file: "User references one file or makes simple change"
  feature_build: "User says 'build', 'create', 'implement'"
  multi_file: "User says 'refactor', 'migrate', multiple files"
  architecture: "User says 'architecture', 'design', 'review system'"
```

---

## Session Caching Protocol

```yaml
caching:
  # Cache discovered rules for the session to avoid re-scanning
  session_cache:
    key: "discovered_rules"
    ttl: "session"  # Persists until session ends
    invalidate_on:
      - "Project file change (package.json, composer.json)"
      - "User explicitly requests re-scan"
      - "New file type opened for first time"

  # Cache format
  cache_entry:
    timestamp: "ISO 8601"
    project_type: "laravel | nextjs | python | ..."
    tech_stack: ["Laravel 12", "React 19", "PostgreSQL"]
    loaded_rules:
      - rule: "backend-frameworks/laravel.md"
        score: 9
        source: "config:composer.json"
      - rule: "typescript/strict-mode.md"
        score: 8
        source: "extension:.tsx"
    agent_recommendation:
      primary: "backend-specialist"
      supporting: ["frontend-specialist", "database-architect"]
```

---

## Integration Points

```yaml
integrations:
  # 1. GEMINI.md — Entry point loads discovery engine
  gemini_md:
    when: "Session start"
    action: "Run Layer 2 (config scan) to pre-warm cache"

  # 2. Agent request — Full 3-layer scan
  agent_request:
    when: "User sends request"
    action: "Run all 3 layers, merge, resolve dependencies"

  # 3. File open — Incremental Layer 1
  file_open:
    when: "User opens new file type"
    action: "Run Layer 1 for new extension, merge with cache"

  # 4. Orchestration Engine — Agent selection
  orchestration:
    when: "orchestration-engine.md needs rules"
    action: "Read from session cache, pass to selected agent"

  # 5. discover-rules.ps1 — CLI interface
  cli:
    when: "User runs script"
    action: "Full 3-layer scan, output JSON report"
```

---

## Example: Discovery in Action

### Scenario: Laravel + Inertia + React project

```yaml
# Input
active_file: "app/Http/Controllers/UserController.php"
open_files:
  - "resources/js/Pages/Users/Index.tsx"
  - "database/migrations/2026_01_01_create_users_table.php"
project_root: "/path/to/project"
user_request: "Optimize the user list query and add pagination"

# Layer 1: File Extension Scan
extension_matches:
  ".php": [backend-frameworks/laravel.md]          # score: 10
  ".tsx": [typescript/strict-mode.md]                       # score: 8

# Layer 2: Config Scan
config_matches:
  composer.json:
    laravel/framework: [backend-frameworks/laravel.md]  # score: 9
    inertiajs: [backend-frameworks/laravel.md]          # score: 8
  package.json:
    react: [typescript/react-native.md]                     # score: 8
    typescript: [typescript/strict-mode.md]                   # score: 8

# Layer 3: Keyword Analysis
keyword_matches:
  "optimize": [agentic-ai/performance-optimization-agent.md] # score: 5
  "query": [database/query-optimization.md]              # score: 6
  "pagination": [database/query-optimization.md]         # score: 6

# Merged & Ranked (deduplicated, max score wins)
final_ranking:
  1. backend-frameworks/laravel.md        → 10
  2. typescript/strict-mode.md             → 8
  3. typescript/react-native.md            → 8
  4. database/query-optimization.md       → 6
  5. agentic-ai/performance-optimization-agent.md → 5

# Scope: feature_build (max 7 rules)
# Dependency resolution: query-optimization → design.md (optional, score 6 ≥ 6)

# Final Loaded Rules (6)
loaded:
  - backend-frameworks/laravel.md
  - typescript/strict-mode.md
  - typescript/react-native.md
  - database/query-optimization.md
  - database/design.md           # (dependency of query-optimization)
  - agentic-ai/performance-optimization-agent.md
```

---

**Version:** 1.0.0  
**System:** Antigravity-Core v4.0  
**Created:** 2026-02-10

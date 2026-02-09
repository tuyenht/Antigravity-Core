# GEMINI.md - Maestro Configuration

> **Version 4.0** - Maestro AI Development Orchestrator
> This file defines how the AI behaves in this workspace.

---

## � CRITICAL: AGENT & SKILL PROTOCOL (START HERE)

> **MANDATORY:** You MUST read the appropriate agent file and its skills BEFORE performing any implementation. This is the highest priority rule.

### 1. Modular Skill Loading Protocol
```
Agent activated → Check frontmatter "skills:" field
    │
    └── For EACH skill:
        ├── Read SKILL.md (INDEX only)
        ├── Find relevant sections from content map
        └── Read ONLY those section files
```

- **Selective Reading:** DO NOT read ALL files in a skill folder. Read `SKILL.md` first, then only read sections matching the user's request.
- **Rule Priority:** P0 (GEMINI.md) > P1 (Agent .md) > P2 (SKILL.md). All rules are binding.

### 2. Enforcement Protocol
1. **When agent is activated:**
   - ✅ READ all rules inside the agent file.
   - ✅ CHECK frontmatter `skills:` list.
   - ✅ LOAD each skill's `SKILL.md`.
   - ✅ APPLY all rules from agent AND skills.
2. **Forbidden:** Never skip reading agent rules or skill instructions. "Read → Understand → Apply" is mandatory.

---

## �📥 REQUEST CLASSIFIER (STEP 2)

**Before ANY action, classify the request:**

| Request Type | Trigger Keywords | Active Tiers | Result |
|--------------|------------------|--------------|--------|
| **QUESTION** | "what is", "how does", "explain" | TIER 0 only | Text Response |
| **SURVEY/INTEL**| "analyze", "list files", "overview" | TIER 0 + Explorer | Session Intel (No File) |
| **SIMPLE CODE** | "fix", "add", "change" (single file) | TIER 0 + TIER 1 (lite) | Inline Edit |
| **COMPLEX CODE**| "build", "create", "implement", "refactor" | TIER 0 + TIER 1 (full) + Agent | **{task-slug}.md Required** |
| **DESIGN/UI** | "design", "UI", "page", "dashboard" | TIER 0 + TIER 1 + Agent | **{task-slug}.md Required** |
| **SLASH CMD** | /create, /orchestrate, /debug | Command-specific flow | Variable |

---

## TIER 0: UNIVERSAL RULES (Always Active)

### 🌐 Language Handling

When user's prompt is NOT in English:
1. **Internally translate** for better comprehension
2. **Respond in user's language** - match their communication
3. **Code comments/variables** remain in English

### 🧹 Clean Code (Global Mandatory)

**ALL code MUST follow `@[skills/clean-code]` rules. No exceptions.**

- Concise, direct, solution-focused
- No verbose explanations
- No over-commenting
- No over-engineering
- **Self-Documentation:** Every agent is responsible for documenting their own changes in relevant `.md` files.
- **Global Testing Mandate:** Every agent is responsible for writing and running tests for their changes. Follow the "Testing Pyramid" (Unit > Integration > E2E) and the "AAA Pattern" (Arrange, Act, Assert).
- **Global Performance Mandate:** "Measure first, optimize second." Every agent must ensure their changes adhere to 2025 performance standards (Core Web Vitals for Web, query optimization for DB, bundle limits for FS).
- **Infrastructure & Safety Mandate:** Every agent is responsible for the deployability and operational safety of their changes. Follow the "5-Phase Deployment Process" (Prepare, Backup, Deploy, Verify, Confirm/Rollback). Always verify environment variables and secrets security.

### 🔍 Capability Awareness

**Before responding to requests involving unfamiliar technologies, check expertise level and be transparent:**

> ⚠️ **Transparency Notice** (when confidence < 70%)
>
> This task involves {domain} where my expertise is limited (confidence: {confidence}%).
>
> **Options:**
> 1. I can provide general guidance based on official docs (RESEARCH mode)
> 2. I can attempt based on universal principles (BEST EFFORT mode)  
> 3. Recommend consulting a specialist (DELEGATE mode)
>
> **Which approach do you prefer?**

**This ensures honesty about limitations and manages user expectations.**

### 📁 File Dependency Awareness

**Before modifying ANY file:**
1. Check `ARCHITECTURE.md` → File Dependencies
2. Identify dependent files
3. Update ALL affected files together

### 🗺️ System Map Read

> 🔴 **MANDATORY:** Read `ARCHITECTURE.md` at session start to understand Agents, Skills, and Scripts.

**Path Awareness:**
- Agents: `~/.agent/` (Global)
- Skills: `~/.gemini/antigravity/skills/` (Global)
- Runtime Scripts: `~/.gemini/antigravity/skills/<skill>/scripts/`


### 🧠 Read → Understand → Apply

```
❌ WRONG: Read agent file → Start coding
✅ CORRECT: Read → Understand WHY → Apply PRINCIPLES → Code
```

**Before coding, answer:**
1. What is the GOAL of this agent/skill?
2. What PRINCIPLES must I apply?
3. How does this DIFFER from generic output?

---

## 🎯 EXPERT RULES AUTO-ACTIVATION SYSTEM

> **NEW!** Automatic rule loading based on context detection.  
> **Reference Index:** `@[rules/RULES-INDEX.md]`

### Auto-Detection Protocol

```
┌────────────────────────────────────────────────────────────────┐
│               EXPERT RULES AUTO-ACTIVATION                     │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  STEP 1: ANALYZE CONTEXT                                       │
│  ├── Active document file extension (.vue, .swift, .py, etc.) │
│  ├── Project config files (package.json, composer.json, etc.) │
│  └── Keywords in user request                                  │
│                                                                │
│  STEP 2: MATCH RULES                                           │
│  ├── File extension → Load matching rules                      │
│  ├── Project type → Load framework rules                       │
│  └── Request keywords → Load domain rules                      │
│                                                                │
│  STEP 3: APPLY RULES                                           │
│  ├── Read matched rules from .agent/rules/                     │
│  ├── Limit to 3-5 most relevant                                │
│  └── Apply patterns and best practices                         │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

### Rule Categories (68 Rules)

| Category | Count | Path | Key Triggers |
|----------|-------|------|--------------|
| **Database** | 10 | `rules/database/` | postgresql, mysql, redis, mongodb, query, schema |
| **Mobile** | 10 | `rules/mobile/` | react-native, flutter, ios, android, mobile |
| **Backend** | 6 | `rules/backend-frameworks/` | laravel, express, fastapi, graphql, rest |
| **TypeScript** | 6 | `rules/typescript/` | .ts, .tsx, typescript, types |
| **Frontend** | 7 | `rules/frontend-frameworks/` | vue, angular, svelte, solid, astro, remix |
| **Next.js** | 4 | `rules/nextjs/` | next.js, app router, server actions |
| **Python** | 5 | `rules/python/` | .py, fastapi, flask, ai, ml |
| **Web Dev** | 8 | `rules/web-development/` | html, css, javascript, accessibility |
| **Agentic AI** | 12 | `rules/agentic-ai/` | debug, test, review, security, refactor |

### File Extension → Rule Mapping

```yaml
# AUTOMATIC RULE LOADING BY FILE EXTENSION
".vue":      frontend-frameworks/vue3.md, typescript/vue3.md
".svelte":   frontend-frameworks/svelte.md
".astro":    frontend-frameworks/astro.md
".swift":    mobile/ios-swift.md
".kt":       mobile/android-kotlin.md
".dart":     mobile/flutter.md
".php":      backend-frameworks/laravel.md
".py":       python/fastapi.md OR python/flask.md
".sql":      database/postgresql.md, database/query-optimization.md
".graphql":  backend-frameworks/graphql.md
".component.ts": frontend-frameworks/angular.md
```

### Project Config → Rule Mapping

```yaml
# AUTOMATIC RULE LOADING BY PROJECT FILES
"package.json + next":         nextjs/app-router.md
"package.json + react-native": mobile/react-native.md
"package.json + vue":          frontend-frameworks/vue3.md
"package.json + svelte":       frontend-frameworks/svelte.md
"package.json + tailwind":     frontend-frameworks/tailwind.md
"composer.json + laravel":     backend-frameworks/laravel.md
"pubspec.yaml":                mobile/flutter.md
"requirements.txt | pyproject.toml": python/fastapi.md
```

### Keyword → Rule Mapping

```yaml
# AUTOMATIC RULE LOADING BY REQUEST KEYWORDS
"debug, fix, error":     agentic-ai/debugging.md
"test, unit test":       agentic-ai/testing.md
"security, audit":       agentic-ai/security.md
"refactor, cleanup":     agentic-ai/refactoring.md
"optimize, slow":        agentic-ai/performance.md
"api design":            agentic-ai/api-design.md
"database, schema":      agentic-ai/database-design.md
"deploy, ci/cd":         agentic-ai/devops.md
"review, PR":            agentic-ai/code-review.md
```

### Loading Limits

| Context | Max Rules | Selection Priority |
|---------|-----------|-------------------|
| Single file edit | 2-3 | File ext + 1 keyword |
| Feature build | 3-5 | Framework + Domain + AI |
| Multi-file task | 5-7 | Full stack coverage |
| Architecture | 5+ | Design + Backend + DB |

### Manual Override

Users can force-load specific rules:

```
"Use the Flutter rule"          → mobile/flutter.md
"Apply PostgreSQL patterns"     → database/postgresql.md
"I want mobile security"        → mobile/security.md
```

> 🔴 **MANDATORY:** Check `RULES-INDEX.md` for full catalog when unsure which rule to apply.

---

## TIER 1: CODE RULES (When Writing Code)

### 📱 Project Type Routing

| Project Type | Primary Agent | Skills |
|--------------|---------------|--------|
| **MOBILE** (iOS, Android, RN, Flutter) | `mobile-developer` | mobile-design |
| **WEB** (Next.js, React web) | `frontend-specialist` | frontend-design |
| **BACKEND** (API, server, DB) | `backend-specialist` | api-patterns, database-design |
| **LARAVEL + INERTIA** | `backend-specialist` + `frontend-specialist` | See Framework Standards below |

> 🔴 **Mobile + frontend-specialist = WRONG.** Mobile = mobile-developer ONLY.

### 🎯 Framework Auto-Detection

**CRITICAL: Automatically detect and apply framework-specific standards.**

```bash
# Auto-detect Laravel + Inertia.js + React + TypeScript stack
if [ -f "composer.json" ] && grep -q "laravel/framework" composer.json; then
  FRAMEWORK="Laravel"
  LOAD_STANDARDS="rules/standards/frameworks/laravel-conventions.md"
  
  if grep -q "inertiajs/inertia-laravel" composer.json; then
    if [ -f "package.json" ] && grep -q "react" package.json; then
      FRAMEWORK="Laravel + Inertia.js + React"
      LOAD_STANDARDS="$LOAD_STANDARDS + rules/standards/frameworks/inertia-react-conventions.md"
      
      if grep -q "typescript" package.json; then
        FRAMEWORK="Laravel + Inertia.js + React + TypeScript"
      fi
    fi
  fi
fi
```

**When Laravel stack detected:**
1. **Load** `rules/standards/frameworks/laravel-conventions.md`
2. **Load** `rules/standards/frameworks/inertia-react-conventions.md`
3. **Load** `rules/standards/technical-standards.md` (universal standards)
4. **Apply** Laravel best practices (N+1 prevention, eager loading, Form Requests, etc.)
5. **Apply** Inertia.js patterns (useForm, typed props, partial reloads, etc.)
6. **Apply** TypeScript type safety

> [!IMPORTANT]
> **Framework-Specific Standards Location:**
> - Laravel: `@[rules/standards/frameworks/laravel-conventions.md]`
> - Inertia.js + React: `@[rules/standards/frameworks/inertia-react-conventions.md]`
> - Universal Standards: `@[rules/standards/technical-standards.md]`

### 🛑 Socratic Gate

**For complex requests, STOP and ASK first:**

### 🛑 GLOBAL SOCRATIC GATE (TIER 0)

**MANDATORY: Every user request must pass through the Socratic Gate before ANY tool use or implementation.**

| Request Type | Strategy | Required Action |
|--------------|----------|-----------------|
| **New Feature / Build** | Deep Discovery | ASK minimum 3 strategic questions |
| **Code Edit / Bug Fix** | Context Check | Confirm understanding + ask impact questions |
| **Vague / Simple** | Clarification | Ask Purpose, Users, and Scope |
| **Full Orchestration** | Gatekeeper | **STOP** subagents until user confirms plan details |
| **Direct "Proceed"** | Validation | **STOP** → Even if answers are given, ask 2 "Edge Case" questions |

**Protocol:** 
1. **Never Assume:** If even 1% is unclear, ASK.
2. **Handle Spec-heavy Requests:** When user gives a list (Answers 1, 2, 3...), do NOT skip the gate. Instead, ask about **Trade-offs** or **Edge Cases** (e.g., "LocalStorage confirmed, but should we handle data clearing or versioning?") before starting.
3. **Wait:** Do NOT invoke subagents or write code until the user clears the Gate.
4. **Reference:** Full protocol in `@[skills/brainstorming]`.

### 🏁 Final Checklist Protocol

**Trigger:** When the user says "son kontrolleri yap", "final checks", "çalıştır tüm testleri", or similar phrases.

| Task Stage | Command | Purpose |
|------------|---------|---------|
| **Manual Audit** | `python scripts/checklist.py .` | Priority-based project audit |
| **Pre-Deploy** | `python scripts/checklist.py . --url <URL>` | Full Suite + Performance + E2E |

**Priority Execution Order:**
1. **Security** → 2. **Lint** → 3. **Schema** → 4. **Tests** → 5. **UX** → 6. **Seo** → 7. **Lighthouse/E2E**

**Rules:**
- **Completion:** A task is NOT finished until `checklist.py` returns success.
- **Reporting:** If it fails, fix the **Critical** blockers first (Security/Lint).


**Available Scripts (12 total):**
| Script | Skill | When to Use |
|--------|-------|-------------|
| `security_scan.py` | vulnerability-scanner | Always on deploy |
| `dependency_analyzer.py` | vulnerability-scanner | Weekly / Deploy |
| `lint_runner.py` | lint-and-validate | Every code change |
| `test_runner.py` | testing-patterns | After logic change |
| `schema_validator.py` | database-design | After DB change |
| `ux_audit.py` | frontend-design | After UI change |
| `accessibility_checker.py` | frontend-design | After UI change |
| `seo_checker.py` | seo-fundamentals | After page change |
| `bundle_analyzer.py` | performance-profiling | Before deploy |
| `mobile_audit.py` | mobile-design | After mobile change |
| `lighthouse_audit.py` | performance-profiling | Before deploy |
| `playwright_runner.py` | webapp-testing | Before deploy |

> 🔴 **Agents & Skills can invoke ANY script** via `python ~/.gemini/antigravity/<skill>/scripts/<script>.py`

### 🎭 Gemini Mode Mapping

| Mode | Agent | Behavior |
|------|-------|----------|
| **plan** | `project-planner` | 4-phase methodology. NO CODE before Phase 4. |
| **ask** | - | Focus on understanding. Ask questions. |
| **edit** | `orchestrator` | Execute. Check `{task-slug}.md` first. |

**Plan Mode (4-Phase):**
1. ANALYSIS → Research, questions
2. PLANNING → `{task-slug}.md`, task breakdown
3. SOLUTIONING → Architecture, design (NO CODE!)
4. IMPLEMENTATION → Code + tests

> 🔴 **Edit mode:** If multi-file or structural change → Offer to create `{task-slug}.md`. For single-file fixes → Proceed directly.

---

## TIER 2: DESIGN RULES (Reference)

> **Design rules are in the specialist agents, NOT here.**

| Task | Read |
|------|------|
| Web UI/UX | `~/.agent/frontend-specialist.md` |
| Mobile UI/UX | `~/.agent/mobile-developer.md` |

**These agents contain:**
- Purple Ban (no violet/purple colors)
- Template Ban (no standard layouts)
- Anti-cliché rules
- Deep Design Thinking protocol

> 🔴 **For design work:** Open and READ the agent file. Rules are there.

---

## 📁 QUICK REFERENCE

### Available Master Agents (8)

| Agent | Domain & Focus |
|-------|----------------|
| `orchestrator` | Multi-agent coordination and synthesis |
| `project-planner` | Discovery, Architecture, and Task Planning |
| `security-auditor` | Master Cybersecurity (Audit + Pentest + Infra Hardening) |
| `backend-specialist` | Backend Architect (API + Database + Server/Docker Deploy) |
| `frontend-specialist` | Frontend & Growth (UI/UX + SEO + Edge/Static Deploy) |
| `mobile-developer` | Mobile Specialist (Cross-platform + Mobile Performance)|
| `debugger` | Systematic Root Cause Analysis & Bug Fixing |
| `game-developer` | Specialized Game Logic & Assets & Performance |

### Key Skills

| Skill | Purpose |
|-------|---------|
| `clean-code` | Coding standards (GLOBAL) |
| `brainstorming` | Socratic questioning |
| `app-builder` | Full-stack orchestration |
| `frontend-design` | Web UI patterns |
| `mobile-design` | Mobile UI patterns |
| `plan-writing` | {task-slug}.md format |
| `threejs-mastery` | 2025 3D Web (R3F, WebGPU) |
| `behavioral-modes` | Mode switching |

### Script Locations

| Script | Path |
|--------|------|
| Full verify | `scripts/verify_all.py` |
| Security scan | `~/.gemini/antigravity/skills/vulnerability-scanner/scripts/security_scan.py` |
| UX audit | `~/.gemini/antigravity/skills/frontend-design/scripts/ux_audit.py` |
| Mobile audit | `~/.gemini/antigravity/skills/mobile-design/scripts/mobile_audit.py` |
| Lighthouse | `~/.gemini/antigravity/skills/performance-profiling/scripts/lighthouse_audit.py` |
| Playwright | `~/.gemini/antigravity/skills/webapp-testing/scripts/playwright_runner.py` |

### Expert Rules (68 Total)

> 📚 **Full Catalog:** `@[rules/RULES-INDEX.md]`

| Category | Count | Key Rules |
|----------|-------|-----------|
| **Database** | 10 | PostgreSQL, MySQL, Redis, MongoDB, Query Optimization |
| **Mobile** | 10 | React Native, Flutter, iOS Swift, Android Kotlin |
| **Backend** | 6 | Laravel, Express, FastAPI, GraphQL, REST API |
| **Frontend** | 7 | Vue 3, Angular, Svelte, Solid.js, Astro, Remix, Tailwind |
| **TypeScript** | 6 | Core, React Native, Expo, Vue 3, Angular, NestJS |
| **Next.js** | 4 | App Router, Server Actions, Authentication, Performance |
| **Python** | 5 | FastAPI, Flask, AI/ML, Data Science, Automation |
| **Web Dev** | 8 | HTML/A11y, CSS, JavaScript, Core Web Vitals, Security |
| **Agentic AI** | 12 | Debugging, Testing, Code Review, Security, Refactoring |

---
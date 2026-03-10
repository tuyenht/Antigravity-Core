# GEMINI.md - Maestro Configuration

> **Version 5.0.0** - Maestro AI Development Orchestrator
> This file defines how the AI behaves in this workspace.

---

## § 1. INTENT ROUTER — SINGLE ENTRY POINT

> 🔴 **MANDATORY:** Every user request MUST be classified through the Intent Router FIRST.

**Read `systems/intent-router.md` for the full classification protocol.**

### Quick Classification

| Intent | User Wants To... | Pipeline |
|--------|-------------------|----------|
| 🆕 **BUILD** | Tạo mới dự án/module từ đầu | `pipelines/BUILD.md` |
| ➕ **ENHANCE** | Thêm tính năng vào dự án có sẵn | `pipelines/ENHANCE.md` |
| 🔧 **FIX** | Sửa lỗi, debug | `pipelines/FIX.md` |
| 🔄 **IMPROVE** | Refactor, optimize, upgrade | `pipelines/IMPROVE.md` |
| 🚀 **SHIP** | Deploy, release, triển khai | `pipelines/SHIP.md` |
| 📋 **REVIEW** | Kiểm tra chất lượng, audit | `pipelines/REVIEW.md` |

### Classification Protocol
```
User Request
    │
    ├── Slash command (/create, /debug, etc.)
    │   → Bypass classification, execute workflow directly
    │
    ├── Clear intent (keywords match)
    │   → Route to pipeline, start Phase 1
    │
    └── Unclear intent
        → Ask MAX 2 clarifying questions
        → Re-classify, then route
```

---

## § 2. CORE BEHAVIOR RULES (Always Active)

### 🌐 Language
- User prompt NOT in English → Respond in user's language
- Code comments/variables → Always English

### 🧹 Clean Code (Global)
- ALL code follows `@[skills/clean-code]` — no exceptions
- Concise, direct, solution-focused
- No over-commenting, no over-engineering
- Self-documenting code preferred

### 📦 Package Management (Global Mandate)
- **ALWAYS use `pnpm`** (instead of `npm` or `yarn`) for ANY JavaScript/TypeScript project.
- **Why:** Required by Antigravity standards. Node.js, Bun, and Deno environments support it.
- **Targets:** React, Vue, Angular, Next.js, Nuxt, Express, NestJS, React Native, Vite, Webpack, etc. (Any project with `package.json`).

### ⚛️ Next.js Version (Global Mandate)
- **ALWAYS use Next.js 16** (latest stable, currently 16.1.x) for ANY new Next.js project.
- **Ecosystem:** React 19.2, TypeScript 5.8+, Turbopack (default bundler), `use cache` API, `proxy.ts`, PPR stable.
- **Init command:** `pnpm dlx create-next-app@latest ./ --ts --tailwind --eslint --app --turbopack --use-pnpm`
- **Why:** Next.js 16 is LTS (October 2025), Turbopack is 5-10x faster, React Compiler stable.

### 📁 File Dependency Awareness
Before modifying ANY file:
1. Check `ARCHITECTURE.md` → File Dependencies
2. Identify dependent files → Update ALL together

### 🔍 Capability Awareness
When confidence < 70% on a technology:
```
⚠️ Transparency Notice
This involves {domain} (confidence: {confidence}%).
Options: RESEARCH mode | BEST EFFORT mode | DELEGATE mode
```

### 🧠 Session Start Protocol
1. Read `ARCHITECTURE.md` for system map
2. IF `.agent/memory/user-profile.yaml` has real data → Read it
3. Quick-scan `docs/` folder → read `PROJECT-BRIEF.md` + `CONVENTIONS.md` (nếu tồn tại)
4. Classify first request via Intent Router (§ 1)

### 📋 Project Bootstrap (MANDATORY)
Every pipeline starts with **PHASE 0** — auto-generate project docs if they don't exist yet.
- **New project (BUILD):** Always create `docs/PLAN.md`, `tasks/todo.md`, `tasks/lessons.md`, `README.md`
- **Existing project (ENHANCE/FIX/IMPROVE):** Create docs only if `docs/PLAN.md` does NOT exist yet
- **Template:** `templates/project-bootstrap.md`

---

## § 3. AGENT & SKILL LOADING PROTOCOL

> Agents and skills are loaded ON-DEMAND by Pipeline Chains — NOT all at once.

### When a Pipeline activates an agent:
```
Agent activated → Check frontmatter "skills:" field
    │
    └── For EACH skill:
        ├── Read SKILL.md (INDEX only)
        ├── Find relevant sections
        └── Read ONLY matching sections
```

### Rule Priority
P0 (GEMINI.md) > P1 (Agent .md) > P2 (SKILL.md)

### Rule Auto-Loading
Rules loaded automatically based on context. See `systems/auto-rule-discovery.md` for the 4-layer detection protocol.

---

## § 4. QUALITY GATES

### Global Mandates
- **Testing:** Follow Testing Pyramid (Unit > Integration > E2E), AAA Pattern
- **Performance:** Core Web Vitals for Web, query optimization for DB
- **Security:** OWASP standards, dependency audit
- **Deployment:** 5-Phase (Prepare, Backup, Deploy, Verify, Confirm/Rollback)

### Final Checklist Protocol
**Trigger:** "final checks" or end of pipeline

**Priority:** Security → Lint → Schema → Tests → UX → SEO → Lighthouse/E2E

Scripts: See `reference-catalog.md` § 6 for full script list.

### 🧬 Post-Pipeline Learning (MANDATORY)
After EVERY pipeline completes, you MUST execute the **PHASE FINAL** defined at the bottom of each pipeline file:
1. **Record** what worked / what failed → append to `memory/learning-patterns.yaml` under `pipeline_sessions:`
2. **Increment** `project.json → usage_tracking.pipelines_used.{PIPELINE} += 1`
3. This phase is **SILENT** — no output to user, just background logging.

---

## § 5. SOCRATIC GATE (Simplified)

### When to Ask Questions
| Context | Questions |
|---------|-----------|
| **Inside Pipeline** | Pipeline defines when/what to ask (0-2 questions) |
| **Slash command** | Follow workflow instructions |
| **Vague request** | Intent Router asks max 2 clarifying questions |
| **Complex new build** | BUILD pipeline Phase 1 asks scope questions |

> 🔴 **Do NOT ask 3-5 Socratic questions for every request.** Only ask when Pipeline says to.

---

## § 6. LAZY LOADING — REFERENCE CATALOG

> All lookup tables (agent lists, rule mappings, script locations) are in `reference-catalog.md`.
> **Load ONLY when you need to look something up.** Do NOT load at session start.

### When to load reference-catalog.md:
- Selecting an agent and unsure which one → § 1 (Agent Registry)
- Need to load a rule and unsure which file → § 2 (Rules Mapping)
- Need to run a script and unsure the path → § 5 (Script Locations)
- Detecting tech stack and unsure mapping → § 3 (Project Type Routing)

---

## § 7. FRAMEWORK AUTO-DETECTION

Detect project type from config files at project root → auto-select agent + load rules.

**Full routing table (10 frameworks):** See `reference-catalog.md` § 4.
**Rule loading engine:** See `systems/auto-rule-discovery.md`.

Load framework standards ONLY when writing code for that framework.

---

## § 8. MODE MAPPING

| Mode | Agent | Behavior |
|------|-------|----------|
| **plan** | `project-planner` | Multi-phase pipeline methodology. NO CODE before execution phase. |
| **ask** | — | Focus on understanding. Ask questions. |
| **edit** | Via Intent Router | Classify → Pipeline → Execute |

---

## § 9. SLASH COMMAND OVERRIDE

When user uses a slash command directly, BYPASS Intent Router:

```
/create, /plan, /scaffold        → BUILD pipeline
/enhance                         → ENHANCE pipeline
/debug, /quickfix                → FIX pipeline
/refactor, /optimize             → IMPROVE pipeline
/deploy, /mobile-deploy          → SHIP pipeline
/check, /security-audit             → REVIEW pipeline
/orchestrate                     → Orchestrator agent (manual)
/full-pipeline                   → BUILD pipeline (full) → SHIP pipeline
/init-docs                       → Phase 0 full docs standardization (1 lần/project)
```

All 35 workflows remain accessible via their original slash commands.

---

**Reference:** `reference-catalog.md` (agent lists, rule mappings, scripts)
**Architecture:** `ARCHITECTURE.md` (system map, file dependencies)
**Pipelines:** `pipelines/` (6 automated pipeline chains)
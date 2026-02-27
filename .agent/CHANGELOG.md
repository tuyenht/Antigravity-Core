# Changelog

All notable changes to the .agent system will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [5.0.0] - 2026-02-26

### 🧭 Zero-Confusion Architecture — Intent Router + Pipeline Chains

**Major architectural reorganization. All 27 agents, 59 skills, 131 rules, 38 workflows preserved.**

---

### Added

- **Intent Router** (`systems/intent-router.md`) — Universal request classification into 6 intents (BUILD, ENHANCE, FIX, IMPROVE, SHIP, REVIEW)
- **6 Pipeline Chains** (`pipelines/`) — Auto-sequenced end-to-end workflows:
  - `BUILD.md` — Discovery → Planning → Scaffolding → Quality → Delivery
  - `ENHANCE.md` — Context → Design → Implement → Verify
  - `FIX.md` — Reproduce → Diagnose → Fix → Verify
  - `IMPROVE.md` — Analyze → Plan → Execute → Verify
  - `SHIP.md` — Pre-flight → Build → Deploy → Post-deploy
  - `REVIEW.md` — Scan (parallel) → Report → Action
- **Reference Catalog** (`reference-catalog.md`) — All lookup tables extracted from GEMINI.md for lazy loading

### Changed

- **GEMINI.md** — Restructured from 485 lines (22KB) to 186 lines (6.4KB). Core rules + Intent Router pointer only
- **ARCHITECTURE.md** — New 3-layer diagram (GEMINI Slim → Intent Router → Pipeline Chains → Engine)
- **project.json** — v5.0.0, added pipelines stats, intent_router foundation entry

### Architecture

```
BEFORE: User → GEMINI.md (22KB) → 35 workflows (confusion)
AFTER:  User → GEMINI.md (6KB) → Intent Router → 6 Pipelines → Auto-chain workflows
```

---

## [4.1.1] - 2026-02-26

### 🐛 Critical Version System Bug Fix

---

### Fixed

- **install-global.ps1** — Version in `setup-profile.ps1` now reads dynamically from `.agent/VERSION` at runtime (was hardcoded at install time)
- **update-global.ps1** — Regenerates `setup-profile.ps1` after update instead of restoring stale backup with old version
- **agent.ps1** — Banner and `project.json` version now read dynamically from `.agent/VERSION` (was hardcoded `v4.0.0`)
- **agent.sh** — Same dynamic version fix for bash
- **.agent/VERSION** — Synced to `4.1.1` (was stuck at `4.0.1`)

### Root Cause

`update-global.ps1` backed up old `setup-profile.ps1` (containing hardcoded version), then restored it after downloading the new release — overwriting the new version with the old one. Combined with `install-global.ps1` expanding `$version` into a heredoc at file creation time, version was permanently frozen.

---

## [4.1.0] - 2026-02-25

### 🚀 SDLC Process Upgrade & Team Pipeline v2.0

**27 agents, 59 skills, 37 workflows, 129 rules, 20 scripts, 11 process docs.**

---

### Added

- **BRANCHING-STRATEGY.md** — GitHub Flow + Release Branches, conventional commits, naming convention
- **INCIDENT-RESPONSE.md** — P0-P3 severity levels, 5-phase workflow, post-mortem template
- **DEFINITION-OF-DONE.md** — 5-tier unified DoD (Universal, Feature, Bugfix, Release, Hotfix)
- **METRICS-REVIEW.md** — 4 metric categories, monthly review cadence, alerting thresholds
- **`/full-pipeline` workflow** — Full team pipeline: BA → SA → PM → DEV → QA → DO
- **`project.json` stats block** — Centralized counts for CI validation (agents, skills, workflows, rules, scripts)

### Changed

- **TEAM_WORKFLOW.md** v1.0 → v2.0 — Added Role→Agent mapping table bridging 7 pipeline roles to 27 agents
- **AGENT_ROLES.md** v1.0 → v2.0 — Added Antigravity Agent + Workflows fields to all 7 roles
- **OUTPUT_FILES.md** v1.0 → v2.0 — Synced to v4.1.0
- **DEPLOYMENT-PROCESS.md** — Added Environment Matrix, Hotfix Fast-Track Flow, Phase 6 Monitoring (SLA targets)
- **WORKFLOW-GUIDE.md** — Updated 31→37 workflows, added 6 missing entries
- **Metrics scores** — consistency_score 75→95, integration_score 78→90 (post-audit improvement)

---

## [4.0.1] - 2026-02-24

### 🔧 Full System Audit & Expert Panel Fixes

**4-round deep audit verifying all 27 agents, 59 skills, 37 workflows, 129 rules.**

---

### Fixed

- **ARCHITECTURE.md** — Workflow count 31→36, +8 missing workflows in table, standards note
- **GEMINI.md** — Version "4.0"→"4.0.0", performance year 2025→2026, removed duplicate Socratic Gate header
- **GEMINI.md** — Added 19 Supporting Agents table (were invisible to AI routing)
- **RULES-INDEX.md** — Added missing Shared catalog entry for `output-templates.md`
- **project.json** — Updated `last_updated`, `last_audit`, `audit_type`, template reference v3→v4
- **health-check.ps1** — Updated template reference v3→v4

### Added

- **Deprecation notes** — `architecture`, `testing-patterns`, `tdd-workflow`, `contract-testing` → point to mastery skills
- **.github/ISSUE_TEMPLATE/** — Bug report and feature request templates
- **.github/PULL_REQUEST_TEMPLATE.md** — PR template with cross-reference checklist
- **Bash equivalents** — `health-check.sh`, `install-global.sh`, `validate-compliance.sh`
- **benchmarks/reports/audit-2026-02-24.md** — System audit baseline report

### Changed

- **agent-template-v3.md** → **agent-template-v4.md** (name aligns with system version)
- **standards/OUTPUT_FILES.md** → **docs/OUTPUT_FILES.md** (correct location per convention)

### Verified

- All cross-references synchronized (agent↔skill, GEMINI↔filesystem, RULES-INDEX↔rules, project.json↔agents)
- Zero dead references across entire system
- All 17 Python scripts and 14 PowerShell scripts verified

---

## [4.0.0] - 2026-02-10

### 🚀 Agent Orchestration Framework & Auto-Rule Discovery

**Transforms Antigravity from manual agent/rule routing to intelligent automated orchestration.**

---

### Added

- **Auto-Rule Discovery Engine** (`systems/auto-rule-discovery.md`) — 3-layer detection (file ext, project config, request keywords), dependency resolution, session caching, priority scoring
- **Agent Registry** (`systems/agent-registry.md`) — Machine-readable capability registry for all 27 agents with triggers, skills, conflict rules, complexity ranges
- **Orchestration Engine** (`systems/orchestration-engine.md`) — Automated agent selection, pipeline execution (sequential/parallel/conditional), 7 pipeline templates, conflict resolution
- **Discovery Script** (`scripts/discover-rules.ps1`) — CLI project scanner, JSON + text output, PS 5.1 compatible

### Changed

- **ARCHITECTURE.md** — v4.0.0, new data flow with orchestration pipeline, systems count 2→6
- **orchestrator.md** — References to new v4.0 systems
- **RULES-INDEX.md** — v2.0.0, references auto-discovery engine
- **project.json** — v4.0.0, added orchestration foundation entry
- **agent.ps1, agent.sh** — Banner versions → 4.0.0
- **GEMINI.md** — v4.0.0

### Fixed

- 51 phantom rule file references corrected across all new system files

### Verified

- Benchmark: 0 regressions
- Version consistency: all files = 4.0.0
- discover-rules.ps1 tested with JSON output

---

## [3.3.0] - 2026-02-10

### 🚀 Advanced Communication & Async Patterns

**Complete communication stack with browser-native RPC, server push, and async messaging.**

---

### Added

- **Connect-RPC conventions** (`rules/backend-frameworks/connect-rpc.md`) — Connect Protocol, Buf v2, React/TanStack Query integration, streaming, interceptors, migration from gRPC-Web
- **SSE conventions** (`rules/backend-frameworks/sse.md`) — Server-Sent Events, EventSource API, Last-Event-ID replay, Redis scaling, AI/LLM token streaming, React hooks
- **Message Queue conventions** (`rules/backend-frameworks/message-queue.md`) — BullMQ, RabbitMQ, event bus abstraction, saga pattern, idempotency, Bull Board monitoring

### Changed

- **RULES-INDEX.md** — Backend Rules 9→12, total rules 71→74, added keyword triggers, dependency entries
- **Cross-links** — Added "See Also" sections to `grpc.md`, `websocket.md`, `graphql.md`, and all 3 new rule files
- **RULES-INDEX structural fixes** — Fixed `aspnet.md`→`aspnet-core.md`, split `python.md`→`fastapi.md`+`flask.md`

### Verified

- Benchmark: 0 regressions
- Version consistency: all files = 3.3.0

---

## [3.2.0] - 2026-02-09

### 🚀 Communication Standards & Benchmarking

**Complete real-time and microservice communication conventions for AI agents.**

---

### Added

- **gRPC conventions** (`rules/backend-frameworks/grpc.md`) - Protocol Buffers, streaming, interceptors, health checking, testing
- **WebSocket standards** (`rules/backend-frameworks/websocket.md`) - Socket.IO, message protocols, rooms, reconnection, Redis scaling

### Changed

- **RULES-INDEX.md** - Backend Rules 6→8, total rules 68→70, added `.proto` detection and keyword triggers
- **README.md** - v3.2 roadmap items marked complete

### Verified

- Benchmark: 0 regressions
- Health-check: 93%+ maintained

---

## [3.1.1] - 2026-01-31

### 🚀 Installation System & UI-UX-Pro-Max Refresh

**Complete installation system for easy deployment + Clean UI-UX-Pro-Max reinstall.**

---

### Added

- **install-global.ps1** - Global installer (2-step pattern like uipro-cli)
- **update-global.ps1** - Update global installation
- **install-antigravity.md v2.0** - Updated workflow with 2-step pattern

### Changed

- **README.md** - Updated QUICK START with 2-step installation
- **UI-UX-Pro-Max** - Fresh reinstall from GitHub
- **install-antigravity.md** - Streamlined with global/alternative options

### Removed

- **.agent/.shared/** - Duplicate folder removed
- **Old ui-ux-pro-max files** - Replaced with fresh install

---

## [3.1.0] - 2026-01-31

### 🎉 Project Optimization & Documentation Enhancement

**Full system review and optimization pass with expert-level recommendations applied.**

---

### Added

- **LICENSE** - Proprietary license file
- **CONTRIBUTING.md** - Comprehensive contribution guidelines
- **.editorconfig** - Cross-editor consistency configuration
- **README.md v3.1** - Ultimate merged documentation with:
  - Memory System section
  - Tech Stack confidence levels
  - Quality Gates (Platinum Standard)
  - Workflow categories table
  - Complete Roadmap (v3.1 → v4.0)
  - Full version history (v1.0 → v3.1)

### Changed

- **VERSION** synced to 3.1.0 (was 2.0.0)
- Fixed emoji encoding issues in README.md

### Removed

- Cleaned up legacy ZIP files (Test1.zip, .agent_old.zip, .agent_bak.zip)

---

## [3.0.0] - 2026-01-31

### 🎉 Major Release - Antigravity-Core AI OS

**Project renamed from Test1 to Antigravity-Core. Full AI-Native Development OS implementation.**

---

### Added

#### Core OS Components
- **AGENT_ROLES.md** - 7 standardized AI roles (BA, SA, PM, BE, FE, QA, DO)
- **TEAM_WORKFLOW.md** - Complete Input→Output pipeline mapping
- **PROJECT_SCAFFOLD.md** - Project structure templates (Laravel, NextJS, FastAPI)
- **OUTPUT_FILES.md** - Strict output file standards and validation

#### Documentation
- **README.md v3.0** - Bilingual (Vietnamese + English) with ASCII diagrams
- **PROJECT-BRIEF-SYSTEM.md v3.0** - Master guide for project initialization

### Changed

- Project structure reorganized as AI Operating System
- Workflows updated to support role-based development

---

## [2.0.0] - 2026-01-17

### 🎉 Major Release - Universal Standards System

**This release transforms .agent from Laravel-specific to universal, tech-stack-agnostic automation system.**

---

### Added

#### Workflows
- **`code-review-automation.md`** - Universal automated code review workflow
  - Auto-detects tech stack (TypeScript, PHP, Python, Go, Rust, Java, etc.)
  - 7 comprehensive review categories
  - Automated scoring system (0-100)
  - GO/NO-GO deployment decision
  - CI/CD integration ready

#### Documentation
- **`INTEGRATION-GUIDE.md`** - Complete team onboarding guide
  - Quick start for new projects
  - Automated workflow usage
  - CI/CD integration examples
  - Team customization guidelines
  - Troubleshooting & best practices

- **`rules/universal-code-standards.md`** - Developer quick reference
  - Before/while/after coding checklists
  - DO/DON'T patterns
  - Quality gates (minimum/target/excellence)
  - Framework-specific tips

#### Skills
- **`ai-sdk-expert/`** - Vercel AI SDK v5 patterns
  - Tool calling, streaming, agentic control
  - Multi-provider integration
  - Real production issue solutions

- **`prisma-expert/`** - ORM best practices
  - Schema design, migrations
  - Query optimization, N+1 prevention
  - Serverless patterns

#### System
- **`VERSION`** file - Semantic versioning tracking
- **`CHANGELOG.md`** - This file!
- **`docs/DEPRECATION-POLICY.md`** - Governance for breaking changes
- **`docs/MIGRATION-GUIDES/v1-to-v2.md`** - Zero-breaking-change upgrade guide

#### Performance & Quality
- **`benchmarks/performance-metrics.yml`** - Performance baseline tracking
  - Workflow execution times (23 workflows)
  - Agent response times (6+ agents)
  - Resource usage (memory, disk, network)
  - Skill loading times
  - System startup metrics
  - Regression detection thresholds

- **`benchmarks/benchmark-runner.ps1`** - Automated performance measurement
  - Auto-measure all components
  - Compare vs baselines
  - Detect regressions (20% threshold)
  - Generate markdown reports
  - Alert system

- **`benchmarks/README.md`** - Benchmarking documentation

#### Anti-AI-Hell Framework
- **Sustainable AI-Assisted Development Framework**
  - 12 critical prompts preventing common AI coding pitfalls
  - Schema-first development (prevent data collapse)
  - Requirements-first development (prevent scope creep)
  - Incremental validation protocol
  - Context management strategy
  - Error boundary system
  - Git recovery checkpoints
  - Addresses: Feature creep → Data model breaks → Logic conflicts → Context loss

- **`workflows/schema-first.md`** - Data structure before code
- **`workflows/requirements-first.md`** - PRD before implementation

---

### Changed

#### Framework Standards Updated
- **`nextjs-conventions.md`** - Updated to Next.js 16 (October 2025)
  - Cache Components (stable)
  - Turbopack by default
  - React 19.2 Compiler
  - proxy.ts (replaces middleware.ts)
  - DevTools MCP integration

- **`tech-radar.yaml`** - Updated Next.js version from 15 to 16

#### Maintenance System
- Enhanced weekly/monthly/quarterly task schedules
- Added comprehensive metrics tracking
- Created dashboard template

---

### Fixed
- Removed circular references in agent cross-references
- Fixed inconsistent naming in workflow files
- Corrected outdated commands in deployment workflows

---

### Removed
- **`.agent_old/`** directory - Migrated valuable content, deleted obsolete files
  - Kept: 3 skills (ai-sdk-expert, prisma-expert, ui-ux-pro-max)
  - Kept: 5 memory files (experiments, predictive-improvements, confidence-calibration, 2 scripts)
  - Deleted: 32 deprecated skills
  - Deleted: Outdated rules system

- **`agents/game-developer.md.backup`** - Split into specialized agents:
  - mobile-game-developer.md
  - pc-game-developer.md

---

### Migration Guide
See: `docs/MIGRATION-GUIDES/v1-to-v2.md` (if coming from v1.x)

**No breaking changes for existing v1.x users - fully backward compatible.**

---

## [1.0.0] - 2026-01-16

### Initial Release - Laravel Stack Focus

#### Core System
- 52 skills covering major technologies
- 19 specialized agents
- 23 automated workflows
- 25 framework standards

#### Framework Coverage
- Laravel 12 (comprehensive)
- Next.js 15
- React Native
- Inertia + React
- Vue 3
- Svelte
- FastAPI
- Django
- Flutter

#### Standards
- Code quality standards
- Security standards (OWASP Top 10)
- Testing standards
- API documentation standards
- CI/CD conventions
- DevOps standards

#### Maintenance
- Weekly/monthly/quarterly checklists
- Metrics tracking system
- Memory & learning system

---

## Versioning Scheme

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (X.0.0): Breaking changes, major rewrites
- **MINOR** (x.Y.0): New features, backward compatible
- **PATCH** (x.y.Z): Bug fixes, documentation updates

### Examples:
- `2.0.0` → `2.1.0`: Added GraphQL standards (new feature)
- `2.1.0` → `2.1.1`: Fixed typo in Laravel conventions (bug fix)
- `2.1.1` → `3.0.0`: Changed workflow command syntax (breaking change)

---

## Upcoming (Planned)

### v4.2.0 (Estimated: Q2 2026)
- [ ] Plugin architecture
- [ ] Skill marketplace
- [ ] Analytics dashboard
- [ ] ML/AI deployment standards
- [ ] SwiftUI conventions (native iOS)
- [ ] Jetpack Compose conventions (native Android)

---

## Support

- **Documentation:** See `.agent/INTEGRATION-GUIDE.md`
- **Issues:** Report via [GitHub Issues](https://github.com/tuyenht/Antigravity-Core/issues)

---

## Contributors

- System Architect: AI Automation Team
- Maintained by: Development Standards Committee

---

**Legend:**
- 🎉 Major milestone
- ✨ New feature
- 🐛 Bug fix
- 📝 Documentation
- ⚠️ Breaking change
- 🗑️ Deprecated

---

[5.0.0]: https://github.com/tuyenht/Antigravity-Core/releases/tag/v5.0.0
[4.1.1]: https://github.com/tuyenht/Antigravity-Core/releases/tag/v4.1.1
[4.1.0]: https://github.com/tuyenht/Antigravity-Core/releases/tag/v4.1.0
[4.0.1]: https://github.com/tuyenht/Antigravity-Core/releases/tag/v4.0.1
[4.0.0]: https://github.com/tuyenht/Antigravity-Core/releases/tag/v4.0.0
[3.3.0]: https://github.com/tuyenht/Antigravity-Core/releases/tag/v3.3.0
[3.2.0]: https://github.com/tuyenht/Antigravity-Core/releases/tag/v3.2.0
[3.1.1]: https://github.com/tuyenht/Antigravity-Core/releases/tag/v3.1.1
[3.1.0]: https://github.com/tuyenht/Antigravity-Core/releases/tag/v3.1.0
[3.0.0]: https://github.com/tuyenht/Antigravity-Core/releases/tag/v3.0.0
[2.0.0]: https://github.com/tuyenht/Antigravity-Core/releases/tag/v2.0.0
[1.0.0]: https://github.com/tuyenht/Antigravity-Core/releases/tag/v1.0.0

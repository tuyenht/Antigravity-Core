# Changelog

All notable changes to the .agent system will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- **setup-profile.ps1** - Auto-generated PowerShell profile with agi/agu/agug commands
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

- **`benchmarks/benchmark-runner.sh`** - Automated performance measurement
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

### v3.2.0 (Estimated: February 2026)
- [ ] Performance benchmarking system (finalize)
- [ ] GraphQL conventions
- [ ] gRPC conventions
- [ ] WebSocket standards
- [ ] Skill dependency graph

### v4.0.0 (Estimated: Q2 2026)
- [ ] Agent orchestration framework
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

[3.1.1]: https://github.com/tuyenht/Antigravity-Core/releases/tag/v3.1.1
[3.1.0]: https://github.com/tuyenht/Antigravity-Core/releases/tag/v3.1.0
[3.0.0]: https://github.com/tuyenht/Antigravity-Core/releases/tag/v3.0.0
[2.0.0]: https://github.com/tuyenht/Antigravity-Core/releases/tag/v2.0.0
[1.0.0]: https://github.com/tuyenht/Antigravity-Core/releases/tag/v1.0.0

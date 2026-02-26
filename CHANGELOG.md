# Changelog

All notable changes to the Antigravity-Core AI Development OS will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/).

---

## [4.1.1] - 2026-02-26

### Fixed
- Enforce strict YAML quotes in workflow descriptions to resolve IDE parsing crash
- Resolve double-encoded UTF-8 anomalies across 55 agent workspace files
- Auto-heal remaining encoding anomalies (broken Vietnamese, control chars, corrupted sparkle emoji)

### Changed
- Translate 97 workflow/skill descriptions to concise Vietnamese (8-15 word limit) for IDE UI compatibility
- Consolidate obsolete workflows and merge `mobile-init` into `create`

---

## [4.1.0] - 2026-02-25

### Added
- Standardize all 37 workflows with turbo + agent + skills metadata
- Complete workflow standardization (37/37 pass all 5 quality checks)
- Upgrade Admin Starter Kit system (Option B full enhancement)
- Add Component Readiness Check to `/create-admin` and `/admin-dashboard`
- Add `/sync-admin` workflow for updating existing projects

### Fixed
- Resolve version mismatch bug in install/update system
- Sync versions to 4.1.1 and fix count discrepancies

### Changed
- Upgrade 7 workflows (Tier C fixes + Tier B enhancements)

---

## [4.0.1] - 2026-02-24

### Added
- Bump-version scripts (PowerShell + Bash)
- Pre-commit hook for automated quality gates
- Agent Capability Matrix
- Skill Dependency Graph + CI regression workflow (7 automated checks)
- `.github` PR and issue templates

### Fixed
- Version sync across all files to 4.0.1
- Removed empty `standards/` directory
- Script count updated (14→20)
- Stale references in GEMINI.md

### Changed
- Full system audit v4.0.1 + SDLC process upgrade
- Cleaned up orphan files (ONE-COMMAND-SETUP.md, empty directories)

---

## [4.0.0] - 2026-02-22

### Added
- **Agent Orchestration Framework** — fully automated agent lifecycle management
- **Auto-Rule Discovery System** — 3-layer auto-scan for context-aware rule loading
- Orchestration Engine with 5-phase pipeline (Analyze → Discover → Select → Execute → Synthesize)
- 129 expert rules across 11 categories

### Fixed
- Corrected 51 phantom rule file references
- 15 stale v3.0.0 references updated to v4.0.0
- Full version consistency (banners, CHANGELOG, project.json)

### Changed
- Major architecture upgrade from v3.x task-based to v4.0 orchestrated pipeline

---

## [3.3.0] - 2026-02-18

### Added
- Advanced Communication & Async Patterns (gRPC, SSE, WebSocket, Message Queues)
- Communication Standards & Benchmarking

### Fixed
- Expert review: 8 code fixes across connect-rpc, sse, message-queue
- Deep pass 2: 4 more subtle code fixes
- RULES-INDEX file path corrections and dependency graph

---

## [3.2.0] - 2026-02-16

### Added
- Comprehensive expert rules v2.0 (61 rules across 8 categories)
  - Database (10), Mobile (10), Backend (6), TypeScript (6)
  - Web Development (8), Next.js (4), Python (5), Agentic AI (12)

---

## [3.1.1] - 2026-02-14

### Added
- 2-Step Global Installation system (setup.ps1 + setup.sh)
- UI-UX Pro Max skill refresh (v2.2.1)

### Fixed
- Documentation references and installation system paths

---

*For earlier history, see `git log --oneline --reverse`.*

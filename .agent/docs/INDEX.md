# Antigravity-Core Documentation Index

**Version:** 5.0.0  
**Last Updated:** 2026-02-28  
**System:** Antigravity-Core — AI-Native Development OS

---

## 📋 Quick Navigation

| Section | Files | Description |
|---------|-------|-------------|
| [Agents](#agents) | 1 catalog + 8 guides | 27 specialized AI agents |
| [Skills](#skills) | 1 catalog + 1 guide | 59 knowledge modules |
| [Workflows](#workflows) | 1 catalog + 1 guide | 34 slash commands |
| [Rules](#rules) | 1 catalog | 110 expert rules (11 categories) |
| [Scripts](#scripts) | 1 catalog | 37 automation scripts |
| [Systems](#systems) | 1 catalog | 6 core protocols (5 files + AOC) |
| [Processes](#processes) | 11 guides | Development workflows |
| [Reference](#reference) | 8 docs | Policies, ADRs, migration |

---

## Agents

Comprehensive documentation cho 27 specialized AI agents.

| Document | Description |
|----------|-------------|
| [AGENT-CATALOG.md](agents/AGENT-CATALOG.md) | Bảng tổng hợp tất cả 27 agents: roles, triggers, skills, decision tree |
| [AGENT-SELECTION.md](AGENT-SELECTION.md) | Hướng dẫn chọn agent phù hợp |
| [AGENT-VERSIONING.md](AGENT-VERSIONING.md) | Agent versioning policy |

---

## Skills

59 knowledge modules loaded bởi agents.

| Document | Description |
|----------|-------------|
| [SKILL-CATALOG.md](skills/SKILL-CATALOG.md) | Bảng tổng hợp 59 skills: ecosystem map, classification, agent mapping, statistics, loading protocol, contributing guide, troubleshooting |
| [SKILL-DISCOVERY.md](SKILL-DISCOVERY.md) | Cách AI tự động discover và load skills |

---

## Workflows

34 slash command workflows.

| Document | Description |
|----------|-------------|
| [WORKFLOW-CATALOG.md](workflows/WORKFLOW-CATALOG.md) | Bảng tổng hợp 34 workflows: categories, usage guides, flow diagrams |
| [WORKFLOW-GUIDE.md](WORKFLOW-GUIDE.md) | Hướng dẫn sử dụng workflows |

---

## Rules

110 expert rules across 11 categories.

| Document | Description |
|----------|-------------|
| [RULES-CATALOG.md](rules/RULES-CATALOG.md) | Bảng tổng hợp 110 rules: auto-activation system, categories |

---

## Scripts

37 automation scripts (20 core + 17 skill scripts).

| Document | Description |
|----------|-------------|
| [SCRIPT-CATALOG.md](scripts/SCRIPT-CATALOG.md) | Bảng tổng hợp 37 scripts (20 core + 17 skill): registry, invocation methods, pipeline dependencies, CLI reference, usage patterns, contributing guide |

---

## Systems

6 core protocols defining system behavior.

| Document | Description |
|----------|-------------|
| [SYSTEMS-CATALOG.md](systems/SYSTEMS-CATALOG.md) | 6 protocols (5 files + AOC in manager-agent) |

---

## Processes

Step-by-step guides for common development workflows.

| Document | Description |
|----------|-------------|
| [SETUP-NEW-PROJECT.md](processes/SETUP-NEW-PROJECT.md) | Setup project mới từ A-Z |
| [DAILY-DEVELOPMENT.md](processes/DAILY-DEVELOPMENT.md) | Quy trình phát triển hàng ngày |
| [CODE-REVIEW-PROCESS.md](processes/CODE-REVIEW-PROCESS.md) | Quy trình review code (AI + human) |
| [DEPLOYMENT-PROCESS.md](processes/DEPLOYMENT-PROCESS.md) | Quy trình deploy 5 phases |
| [TROUBLESHOOTING.md](processes/TROUBLESHOOTING.md) | Xử lý sự cố thường gặp |
| [UPGRADE-GUIDE.md](processes/UPGRADE-GUIDE.md) | Nâng cấp .agent version |
| [CONTRIBUTING.md](processes/CONTRIBUTING.md) | Hướng dẫn đóng góp |
| [BRANCHING-STRATEGY.md](processes/BRANCHING-STRATEGY.md) | Git workflow, naming, conventional commits |
| [INCIDENT-RESPONSE.md](processes/INCIDENT-RESPONSE.md) | Xử lý sự cố P0-P3, post-mortem |
| [DEFINITION-OF-DONE.md](processes/DEFINITION-OF-DONE.md) | Tiêu chuẩn hoàn thành thống nhất |
| [METRICS-REVIEW.md](processes/METRICS-REVIEW.md) | Đo lường & đánh giá định kỳ |

---

## Reference

Existing documentation (pre-audit).

| Document | Description |
|----------|-------------|
| [COPY-PASTE-PROMPT-GUIDE.md](COPY-PASTE-PROMPT-GUIDE.md) | Copy-paste prompts cho AI |
| [DEPRECATION-POLICY.md](DEPRECATION-POLICY.md) | Deprecation policy |
| [ROLLBACK-PROCEDURES.md](ROLLBACK-PROCEDURES.md) | Rollback procedures |
| [TEAM_WORKFLOW.md](TEAM_WORKFLOW.md) | Team workflow guide |
| [adr/](adr/) | Architecture Decision Records |

---

## System Architecture Reference

```
.agent/
├── GEMINI.md                ← Master config (entry point)
├── ARCHITECTURE.md          ← System architecture overview
├── CHANGELOG.md             ← Version history
├── agents/ (27)             ← Specialized AI agent definitions
├── skills/ (59)             ← Knowledge modules
├── workflows/ (34)          ← Slash command workflows
├── rules/ (110)             ← Expert rules (11 categories)
├── scripts/ (37)            ← Automation scripts (20 core + 17 skill)
├── systems/ (6)             ← Core protocols
├── docs/                    ← Documentation (this directory)
│   ├── INDEX.md             ← You are here
│   ├── agents/              ← Agent documentation
│   ├── skills/              ← Skill documentation
│   ├── workflows/           ← Workflow documentation
│   ├── rules/               ← Rules documentation
│   ├── scripts/             ← Script documentation
│   ├── systems/             ← Systems documentation
│   └── processes/           ← Process guides
└── memory/                  ← Learning history (user-specific)
```

---

> **Antigravity-Core v5.0.0** — AI-Native Development OS  
> 27 agents • 59 skills • 34 workflows • 110 rules • 37 scripts • 6 protocols  
> [GitHub](https://github.com/tuyenht/Antigravity-Core)

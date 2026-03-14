# Agent Catalog — Antigravity-Core

**Version:** 5.0.1  
**Last Updated:** 2026-02-27  
**Total Agents:** 27

---

## Table of Contents

- [Overview](#overview)
- [Agent Classification](#agent-classification)
- [Agent Registry](#agent-registry)
- [Skills Matrix](#skills-matrix)
- [When to Use Which Agent](#when-to-use-which-agent)

---

## Overview

Antigravity-Core sử dụng **27 specialized agents** — mỗi agent là một chuyên gia trong lĩnh vực cụ thể. Agents hoạt động theo nguyên tắc:

1. **Single Responsibility** — Mỗi agent chỉ xử lý domain riêng
2. **RBA Protocol** — Reasoning-Before-Action bắt buộc trước mọi thay đổi code
3. **Clean Code Compliance** — Tất cả agents load `clean-code` skill bắt buộc
4. **Skill Loading** — Agents tự động load skills cần thiết từ frontmatter

---

## Agent Classification

### By Role (7 Categories)

| Role | Agents | Mô tả |
|------|--------|--------|
| **🎯 Entry Points** | `orchestrator`, `triage-agent`, `project-planner` | Điều phối và routing requests |
| **💻 Development** | `backend-specialist`, `frontend-specialist`, `laravel-specialist`, `mobile-developer` | Viết code production |
| **🔒 Security** | `security-auditor`, `penetration-tester` | Bảo mật và kiểm thử xâm nhập |
| **⚡ Quality** | `test-engineer`, `test-generator`, `ai-code-reviewer`, `self-correction-agent`, `refactor-agent` | Đảm bảo chất lượng code |
| **📊 Operations** | `devops-engineer`, `performance-optimizer`, `seo-specialist` | Vận hành và tối ưu |
| **📝 Documentation** | `documentation-writer`, `documentation-agent` | Tạo và cập nhật tài liệu |
| **🎮 Specialized** | `game-designer`, `mobile-game-developer`, `pc-game-developer`, `database-architect`, `debugger`, `explorer-agent`, `code-generator-agent`, `manager-agent` | Chuyên biệt theo domain |

---

## Agent Registry

### 1. orchestrator
| Field | Value |
|-------|-------|
| **Vai trò** | Multi-agent coordination và task orchestration |
| **Khi nào dùng** | Task phức tạp cần nhiều agents phối hợp (security + backend + frontend + testing) |
| **Skills** | `clean-code`, `parallel-agents`, `behavioral-modes`, `plan-writing`, `brainstorming`, `architecture-mastery`, `powershell-windows`, `bash-linux` |
| **Tools** | Read, Grep, Glob, Bash, Write, Edit, Agent |
| **Đặc biệt** | Agent duy nhất có tool `Agent` — có thể invoke agents khác |

---

### 2. triage-agent
| Field | Value |
|-------|-------|
| **Vai trò** | First responder — phân tích request và route đến agent phù hợp |
| **Khi nào dùng** | Tự động activate khi request mơ hồ hoặc multi-task |
| **Skills** | `clean-code`, `behavioral-modes`, `systematic-debugging` |
| **Tools** | Read, Grep, Glob |
| **Đặc biệt** | Read-only (không có Write/Edit) — chỉ phân tích, không thực thi |

---

### 3. project-planner
| Field | Value |
|-------|-------|
| **Vai trò** | Lập kế hoạch dự án, phân tách tasks, xác định file structure |
| **Khi nào dùng** | Bắt đầu dự án mới hoặc planning feature lớn |
| **Skills** | `clean-code`, `app-builder`, `plan-writing`, `brainstorming` |
| **Tools** | Read, Grep, Glob, Bash |
| **Đặc biệt** | Không có Write/Edit — chỉ tạo plan, không viết code |

---

### 4. backend-specialist
| Field | Value |
|-------|-------|
| **Vai trò** | Expert backend architect cho Node.js, Python, serverless/edge |
| **Khi nào dùng** | API development, server-side logic, database integration, auth |
| **Triggers** | `backend`, `server`, `api`, `endpoint`, `database`, `auth` |
| **Skills** | `clean-code`, `laravel-performance`, `inertia-performance`, `database-design`, `architecture-mastery`, `vulnerability-scanner`, `testing-mastery`, `mcp-builder`, `vector-databases`, `cloudflare` |
| **Tools** | Read, Grep, Glob, Bash, Edit, Write |

---

### 5. frontend-specialist
| Field | Value |
|-------|-------|
| **Vai trò** | Senior Frontend Architect — React/Next.js, performance-first |
| **Khi nào dùng** | UI components, styling, state management, responsive design |
| **Triggers** | `component`, `react`, `vue`, `ui`, `ux`, `css`, `tailwind`, `responsive` |
| **Skills** | `clean-code`, `react-patterns`, `react-performance`, `nextjs-best-practices`, `tailwind-patterns`, `frontend-design`, `state-management` |
| **Tools** | Read, Grep, Glob, Bash, Edit, Write |
| **Đặc biệt** | Có Deep Design Thinking protocol — anti-cliché, mandatory animations |

---

### 6. laravel-specialist
| Field | Value |
|-------|-------|
| **Vai trò** | Expert Laravel 12+ — Eloquent, Inertia.js, modern PHP |
| **Khi nào dùng** | Laravel projects, Laravel API, Inertia.js full-stack |
| **Triggers** | `laravel`, `eloquent`, `artisan`, `inertia`, `php` |
| **Skills** | `clean-code`, `architecture-mastery`, `database-design`, `testing-mastery`, `performance-profiling` |
| **Tools** | Read, Grep, Glob, Bash, Edit, Write |

---

### 7. mobile-developer
| Field | Value |
|-------|-------|
| **Vai trò** | Expert mobile development — React Native, Flutter, iOS/Android |
| **Khi nào dùng** | Mobile app development, native modules, App Store optimization |
| **Triggers** | `mobile`, `react native`, `flutter`, `ios`, `android`, `expo` |
| **Skills** | `clean-code`, `mobile-design`, `react-patterns`, `performance-profiling`, `i18n-localization` |
| **Tools** | Read, Grep, Glob, Bash, Edit, Write |
| **⚠️ Rule** | Mobile tasks PHẢI dùng `mobile-developer`, KHÔNG dùng `frontend-specialist` |

---

### 8. database-architect
| Field | Value |
|-------|-------|
| **Vai trò** | Expert database — schema design, query optimization, migrations |
| **Khi nào dùng** | Database operations, schema changes, indexing, data modeling |
| **Triggers** | `database`, `sql`, `schema`, `migration`, `query`, `postgres`, `index` |
| **Skills** | `clean-code`, `database-design`, `prisma-expert`, `architecture-mastery`, `performance-profiling`, `nosql-patterns`, `vector-databases` |
| **Tools** | Read, Grep, Glob, Bash, Edit, Write |

---

### 9. security-auditor
| Field | Value |
|-------|-------|
| **Vai trò** | Elite cybersecurity expert — OWASP 2025, supply chain, zero trust |
| **Khi nào dùng** | Code security review (SAST), compliance check, dependency audit |
| **Triggers** | `security`, `vulnerability`, `owasp`, `xss`, `injection`, `auth`, `encrypt` |
| **Skills** | `clean-code`, `vulnerability-scanner`, `red-team-tactics`, `architecture-mastery`, `performance-profiling`, `testing-mastery` |
| **Tools** | Read, Grep, Glob, Bash, Edit, Write |

---

### 10. penetration-tester
| Field | Value |
|-------|-------|
| **Vai trò** | Offensive security — red team, vulnerability exploitation |
| **Khi nào dùng** | Active exploitation testing, attack simulation, red team exercises |
| **Triggers** | `pentest`, `exploit`, `attack`, `hack`, `breach`, `redteam`, `offensive` |
| **Skills** | `clean-code`, `vulnerability-scanner`, `red-team-tactics`, `architecture-mastery`, `database-design`, `performance-profiling` |
| **Tools** | Read, Grep, Glob, Bash, Edit, Write |

---

### 11. test-engineer
| Field | Value |
|-------|-------|
| **Vai trò** | Expert testing strategy, TDD, test automation INFRASTRUCTURE |
| **Khi nào dùng** | Test architecture, debugging test failures, CI/CD test setup |
| **Skills** | `clean-code`, `testing-mastery`, `code-review-checklist` |
| **Tools** | Read, Grep, Glob, Bash, Edit, Write |
| **⚠️ Note** | Dùng cho test infrastructure. Để generate tests, dùng `test-generator` |

---

### 12. test-generator
| Field | Value |
|-------|-------|
| **Vai trò** | Auto-generate comprehensive tests với edge cases và high coverage |
| **Khi nào dùng** | Tạo tests cho code đã có, coverage boost |
| **Skills** | `testing-mastery`, `clean-code`, `laravel-performance`, `react-patterns` |
| **Tools** | Read, Write, Edit, Grep, Glob |

---

### 13. ai-code-reviewer
| Field | Value |
|-------|-------|
| **Vai trò** | AI-powered code review — phát hiện performance anti-patterns, security issues |
| **Khi nào dùng** | Trước human review, pre-commit quality check |
| **Triggers** | `code review`, `review code`, `check code` |
| **Skills** | `clean-code`, `laravel-performance`, `react-performance`, `inertia-performance`, `testing-mastery`, `architecture-mastery`, `vulnerability-scanner` |
| **Tools** | Read, Grep, Glob, Write |

---

### 14. self-correction-agent
| Field | Value |
|-------|-------|
| **Vai trò** | Auto-detect và fix code errors (lint, tests, types) |
| **Khi nào dùng** | Tự động trigger khi có lint/type/test failures. Max 3 iterations |
| **Skills** | `clean-code`, `testing-mastery`, `systematic-debugging` |
| **Tools** | Read, Grep, Bash, Edit, Write |

---

### 15. refactor-agent
| Field | Value |
|-------|-------|
| **Vai trò** | Detect code smells, complexity issues, duplication |
| **Khi nào dùng** | Code cleanup, complexity reduction. Requires user approval |
| **Skills** | `clean-code`, `code-review-checklist`, `performance-profiling` |
| **Tools** | Read, Grep, Bash, Edit, Write |

---

### 16. debugger
| Field | Value |
|-------|-------|
| **Vai trò** | Systematic debugging, root cause analysis, crash investigation |
| **Khi nào dùng** | Complex bugs, production issues, performance problems |
| **Triggers** | `bug`, `error`, `crash`, `not working`, `broken`, `fix` |
| **Skills** | `clean-code`, `systematic-debugging`, `performance-profiling`, `testing-mastery` |

---

### 17. devops-engineer
| Field | Value |
|-------|-------|
| **Vai trò** | Deployment, server management, CI/CD, production operations |
| **Khi nào dùng** | Deploy, server access, rollback. ⚠️ HIGH RISK operations |
| **Triggers** | `deploy`, `production`, `server`, `pm2`, `ssh`, `release`, `rollback`, `ci/cd` |
| **Skills** | `clean-code`, `deployment-procedures`, `server-management`, `powershell-windows`, `bash-linux`, `kubernetes-patterns`, `monitoring-observability`, `terraform-iac`, `cloudflare` |
| **Tools** | Read, Grep, Glob, Bash, Edit, Write |

---

### 18. performance-optimizer
| Field | Value |
|-------|-------|
| **Vai trò** | Performance optimization, profiling, Core Web Vitals |
| **Khi nào dùng** | Speed improvement, bundle size reduction, runtime optimization |
| **Triggers** | `performance`, `optimize`, `speed`, `slow`, `memory`, `lighthouse` |
| **Skills** | `clean-code`, `performance-profiling`, `database-design`, `architecture-mastery`, `react-patterns`, `monitoring-observability` |
| **Tools** | Read, Grep, Glob, Bash, Edit, Write |

---

### 19. seo-specialist
| Field | Value |
|-------|-------|
| **Vai trò** | SEO + GEO (Generative Engine Optimization) expert |
| **Khi nào dùng** | SEO audits, Core Web Vitals, E-E-A-T, AI search visibility |
| **Skills** | `clean-code`, `seo-fundamentals`, `geo-fundamentals`, `performance-profiling`, `frontend-design` |
| **Tools** | Read, Grep, Glob, Bash, Write |

---

### 20. documentation-writer
| Field | Value |
|-------|-------|
| **Vai trò** | Technical documentation expert |
| **Khi nào dùng** | KHI user yêu cầu cụ thể (README, API docs, changelog). Không auto-invoke |
| **Skills** | `clean-code`, `documentation-templates`, `architecture-mastery`, `plan-writing` |
| **Tools** | Read, Grep, Glob, Bash, Edit, Write |

---

### 21. documentation-agent
| Field | Value |
|-------|-------|
| **Vai trò** | Auto-update docs sau code changes — API docs, comments, README, changelog |
| **Khi nào dùng** | Tự động trigger sau code changes |
| **Skills** | `clean-code`, `documentation-templates`, `i18n-localization` |
| **Tools** | Read, Grep, Bash, Edit, Write |

---

### 22. code-generator-agent
| Field | Value |
|-------|-------|
| **Vai trò** | Generate boilerplate code (CRUD, validation, tests) STANDARDS-compliant |
| **Khi nào dùng** | Scaffolding, boilerplate generation |
| **Triggers** | `generate`, `scaffold`, `create CRUD`, `boilerplate` |
| **Skills** | `clean-code`, `laravel-performance`, `react-patterns`, `testing-mastery`, `documentation-templates` |
| **Tools** | Read, Write, Edit, Grep, Glob |

---

### 23. explorer-agent
| Field | Value |
|-------|-------|
| **Vai trò** | Advanced codebase discovery, deep architectural analysis |
| **Khi nào dùng** | Initial audits, refactoring plans, deep investigation |
| **Skills** | `clean-code`, `architecture-mastery`, `plan-writing`, `brainstorming`, `systematic-debugging` |
| **Tools** | Read, Grep, Glob, Bash, ViewCodeItem, FindByName |
| **Đặc biệt** | Có tools đặc biệt `ViewCodeItem` và `FindByName` cho deep analysis |

---

### 24. manager-agent
| Field | Value |
|-------|-------|
| **Vai trò** | Orchestrate Auto-Optimization Cycle (AOC) sau feature completion |
| **Khi nào dùng** | Tự động sau khi hoàn thành feature — coordinates self-correction, docs, refactoring |
| **Skills** | `clean-code`, `behavioral-modes` |
| **Tools** | Read, Grep, Bash, Edit, Write |

---

### 25. game-designer
| Field | Value |
|-------|-------|
| **Vai trò** | Game Design Lead — mechanics, multiplayer, art direction, audio |
| **Khi nào dùng** | Game design, gameplay balancing, player experience |
| **Triggers** | `game design`, `gameplay`, `mechanics`, `multiplayer`, `level design` |
| **Skills** | `clean-code`, `game-development`, `plan-writing`, `brainstorming`, `architecture-mastery` |
| **Tools** | Read, Grep, Glob, Bash, Edit, Write |

---

### 26. mobile-game-developer
| Field | Value |
|-------|-------|
| **Vai trò** | Mobile game development — Unity, Cocos2d, native frameworks |
| **Khi nào dùng** | Mobile games, 2D games, touch controls, mobile optimization |
| **Triggers** | `mobile game`, `ios game`, `android game`, `touch`, `2d game`, `cocos` |
| **Skills** | `clean-code`, `mobile-design`, `game-development`, `performance-profiling` |
| **Tools** | Read, Grep, Glob, Bash, Edit, Write |

---

### 27. pc-game-developer
| Field | Value |
|-------|-------|
| **Vai trò** | PC game development — Unity, Unreal Engine, Godot |
| **Khi nào dùng** | 3D games, graphics programming, desktop platform optimization |
| **Triggers** | `pc game`, `unity`, `unreal`, `godot`, `steam`, `graphics`, `3d` |
| **Skills** | `clean-code`, `game-development`, `testing-mastery`, `performance-profiling` |
| **Tools** | Read, Grep, Glob, Bash, Edit, Write |

---

## Skills Matrix

Top skills được sử dụng nhiều nhất:

| Skill | Số agents sử dụng |
|-------|-------------------|
| `clean-code` | **27** (tất cả) |
| `performance-profiling` | 10 |
| `testing-mastery` | 6 |
| `architecture-mastery` | 3 |
| `vulnerability-scanner` | 3 |
| `database-design` | 4 |
| `react-patterns` | 4 |
| `systematic-debugging` | 4 |
| `behavioral-modes` | 4 |
| `plan-writing` | 4 |
| `api-patterns` | 4 |

---

## When to Use Which Agent

### Quick Decision Tree

```
User request →
├── Mơ hồ/phức tạp? → triage-agent → route đến specialist
├── Cần planning? → project-planner
├── Cần nhiều agents? → orchestrator
├── Code changes?
│   ├── Backend/API? → backend-specialist
│   ├── Frontend/UI? → frontend-specialist
│   ├── Laravel? → laravel-specialist
│   ├── Mobile? → mobile-developer (⚠️ KHÔNG dùng frontend!)
│   ├── Database? → database-architect
│   └── Game? → game-designer → mobile-game-developer / pc-game-developer
├── Quality?
│   ├── Review code? → ai-code-reviewer
│   ├── Generate tests? → test-generator
│   ├── Test infrastructure? → test-engineer
│   ├── Fix lint/type errors? → self-correction-agent
│   └── Refactor? → refactor-agent
├── Security?
│   ├── Code review (defensive)? → security-auditor
│   └── Attack simulation (offensive)? → penetration-tester
├── Operations?
│   ├── Deploy? → devops-engineer
│   ├── Performance? → performance-optimizer
│   └── SEO? → seo-specialist
├── Documentation? → documentation-writer (manual) / documentation-agent (auto)
└── Debug? → debugger
```

### Common Mistakes

| ❌ Sai | ✅ Đúng |
|--------|---------|
| Mobile task → `frontend-specialist` | Mobile → `mobile-developer` |
| Generate tests → `test-engineer` | Generate tests → `test-generator` |
| Auto-invoke docs → `documentation-writer` | Auto docs → `documentation-agent` |
| Skip planning → dive into code | Plan first → `project-planner` |
| Single agent cho complex task | Multi-agent → `orchestrator` |

---

> **See also:** [AGENT-SELECTION.md](./AGENT-SELECTION.md) | [Agent Registry](../../systems/agent-registry.md) | [Skills Catalog](../skills/SKILL-CATALOG.md)

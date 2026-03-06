# 🚀 ANTIGRAVITY-CORE

> **AI-Native Development Operating System**  
> Hệ Điều Hành Phát Triển Phần Mềm Thuần AI

[![Version](https://img.shields.io/badge/version-5.0.0-blue.svg)](.agent/CHANGELOG.md)
[![Agents](https://img.shields.io/badge/agents-27-brightgreen.svg)](.agent/docs/agents/AGENT-CATALOG.md)
[![Skills](https://img.shields.io/badge/skills-59-orange.svg)](.agent/docs/skills/SKILL-CATALOG.md)
[![Rules](https://img.shields.io/badge/rules-110-purple.svg)](.agent/systems/auto-rule-discovery.md)
[![AI Autonomy](https://img.shields.io/badge/AI%20Autonomy-95%25-green.svg)]()
[![Quality](https://img.shields.io/badge/Quality-Platinum%20Standard-gold.svg)]()
[![License](https://img.shields.io/badge/license-Proprietary-red.svg)]()

---

## 🎯 TẦM NHÌN

**Antigravity-Core** không phải là một framework hay library.  
Đây là một **Hệ Điều Hành** (Operating System) cho việc phát triển phần mềm với AI.

```mermaid
graph TB
    subgraph OS["ANTIGRAVITY-CORE (AI OS v5.0.0)"]
        direction TB
        A["27 Specialized Agents"]
        B["59 Knowledge Skills"]
        C["110 Expert Rules"]
        D["34 Automated Workflows"]
        E["6 Core Protocols"]
    end

    OS -->|"SINH RA<br/>(Generate)"| P1["🛒 E-commerce"]
    OS -->|"SINH RA<br/>(Generate)"| P2["☁️ SaaS App"]
    OS -->|"SINH RA<br/>(Generate)"| P3["📱 Mobile App"]
    OS -->|"SINH RA<br/>(Generate)"| P4["🎮 Game"]
```

### Khác biệt với AI Coding truyền thống

| Traditional AI Coding | Antigravity-Core |
|----------------------|------------------|
| 🔴 Passive code generator | 🟢 **27 chuyên gia AI** phối hợp |
| 🔴 Context-lost every session | 🟢 **Persistent memory system** |
| 🔴 Generic responses | 🟢 **110 expert rules** tự động load |
| 🔴 No quality gates | 🟢 **Platinum Standard** enforcement |

| 🔴 Trial and error | 🟢 **59 proven skill modules** |
| 🔴 One-size-fits-all | 🟢 **Auto-detection** tech stack |

---

## ⚡ QUICK START

### 📋 Prerequisites

- **Git** đã cài đặt ([git-scm.com](https://git-scm.com))
- **PowerShell** 5.1+ (Windows) hoặc Bash (Linux/Mac)
- Nếu gặp lỗi execution policy, chạy trước:
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

---

### 🌐 STEP 1: Cài đặt Global (một lần duy nhất)

**Recommended: Clone & Install**

```powershell
# Clone repo
git clone --depth 1 https://github.com/tuyenht/Antigravity-Core.git C:\Tools\Antigravity-Core

# Chạy global installer (tự động thêm vào PowerShell Profile)
& "C:\Tools\Antigravity-Core\.agent\scripts\install-global.ps1"

# Restart PowerShell
```

**Alternative: Download từ raw URL**

```powershell
# Download và chạy installer (chỉ hoạt động nếu repo public)
irm "https://raw.githubusercontent.com/tuyenht/Antigravity-Core/main/.agent/scripts/install-global.ps1" -OutFile install.ps1
.\install.ps1
Remove-Item install.ps1

# Restart PowerShell
```

**Kết quả:** 3 lệnh mới sẵn sàng:

| Lệnh | Chức năng |
|-------|-----------|
| `agi` | Install Antigravity-Core vào project hiện tại |
| `agu` | Update project hiện tại |
| `agug` | Update bản global |

---

### 📦 STEP 2: Cài đặt cho Project (mỗi project)

```powershell
cd C:\Projects\MyNewProject
agi
```

---

### 🔄 Cập nhật

```powershell
agug                        # Update bản global (khi có version mới)
cd C:\Projects\MyProject
agu                         # Update project hiện tại
```

---

### 🐧 Linux/Mac

```bash
cd ~/projects/my-new-project
git clone --depth 1 https://github.com/tuyenht/Antigravity-Core.git temp-ag
cp -r temp-ag/.agent ./.agent
cp -r temp-ag/docs ./docs
rm -rf temp-ag
```

---

### 🔧 Troubleshooting

| Lỗi | Nguyên nhân | Cách fix |
|------|-------------|----------|
| `irm: 404 Not Found` | Repo đang **private** trên GitHub | Chuyển repo sang **public** hoặc dùng `git clone` |
| `Add-Content $PROFILE: path not found` | Thư mục PowerShell Profile chưa tồn tại | Script v1.1+ tự tạo. Hoặc chạy: `New-Item -ItemType Directory -Path (Split-Path $PROFILE) -Force` |
| `install.ps1 cannot be loaded` | ExecutionPolicy bị Restricted | `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |

Chi tiết: Xem [README → Quick Start](#-quick-start)

---

## 🏗️ KIẾN TRÚC HỆ THỐNG

```
Antigravity-Core/
│
├── 🤖 .agent/                         ← AI OS Engine (Core)
│   │
│   ├── 👥 agents/ (27)                ← 27 specialized AI agents
│   │   ├── orchestrator.md            (Multi-agent coordinator)
│   │   ├── backend-specialist.md      (API, DB, server)
│   │   ├── frontend-specialist.md     (React, UI/UX)
│   │   ├── security-auditor.md        (OWASP, pentest)
│   │   └── ... 23 more agents
│   │
│   ├── 🎯 skills/ (59)                ← Knowledge modules
│   │   ├── react-patterns/            prisma-expert/
│   │   ├── laravel-performance/       docker-expert/
│   │   ├── ui-ux-pro-max/             vulnerability-scanner/
│   │   └── ... 53 more skills
│   │
│   ├── 📏 rules/ (110)                ← Expert coding rules
│   │   ├── backend-frameworks/ (12)   database/ (10)
│   │   ├── frontend-frameworks/ (7)   mobile/ (10)
│   │   ├── nextjs/ (13)               python/ (14)
│   │   ├── typescript/ (13)           web-development/ (12)
│   │   ├── agentic-ai/ (12)           standards/ (25)
│   │   └── shared/ (1)
│   │
│   ├── 🔄 workflows/ (34)             ← Slash command workflows
│   ├── ⚙️ scripts/ (20 core)            ← PowerShell + Bash automation (+ 17 skill scripts)
│   ├── 🧬 systems/ (5)                ← Core protocols (RBA, AOC...)
│   ├── 🧠 memory/                     ← AI memory system
│   ├── 📖 docs/                       ← System documentation
│   │
│   ├── GEMINI.md                      ← Master AI config
│   ├── ARCHITECTURE.md                ← System architecture
│   └── CHANGELOG.md                   ← Version history
│
├── 📖 docs/                            ← Project documentation
│   ├── New-Project-Interview-Prompt.txt (26-question structured interview)
│   └── Analyze-Existing-Project-Prompt.txt (17-category codebase analysis)
│
└── README.md                           ← You are here
```

---

## 👥 27 SPECIALIZED AGENTS

Mỗi agent là một **chuyên gia AI** trong lĩnh vực cụ thể, tự động được chọn dựa trên yêu cầu.

### By Role (7 Categories)

| Category | Agents | Chức năng |
|----------|--------|-----------|
| **🎯 Entry Points** | `orchestrator`, `triage-agent`, `project-planner` | Điều phối, routing requests |
| **💻 Development** | `backend-specialist`, `frontend-specialist`, `laravel-specialist`, `mobile-developer` | Viết code production |
| **🔒 Security** | `security-auditor`, `penetration-tester` | Bảo mật & penetration testing |
| **⚡ Quality** | `test-engineer`, `test-generator`, `ai-code-reviewer`, `self-correction-agent`, `refactor-agent` | CI/CD, testing, code quality |
| **📊 Operations** | `devops-engineer`, `performance-optimizer`, `seo-specialist` | Deploy, monitoring, SEO |
| **📝 Documentation** | `documentation-writer`, `documentation-agent` | Technical writing |
| **🎮 Specialized** | `game-designer`, `mobile-game-developer`, `pc-game-developer`, `database-architect`, `debugger`, `explorer-agent`, `code-generator-agent`, `manager-agent` | Domain-specific experts |

### Agent Selection (Tự động)

```
User request →
├── Mơ hồ?        → triage-agent → route đến specialist
├── Complex?       → orchestrator → multi-agent pipeline
├── Backend/API?   → backend-specialist
├── Frontend/UI?   → frontend-specialist
├── Mobile?        → mobile-developer (⚠️ KHÔNG dùng frontend!)
├── Laravel?       → laravel-specialist
├── Security?      → security-auditor
├── Deploy?        → devops-engineer
└── Debug?         → debugger
```

**Chi tiết:** Xem [AGENT-CATALOG.md](.agent/docs/agents/AGENT-CATALOG.md)

---

## 🔄 WORKFLOWS (34 Slash Commands)

| Category | Commands |
|----------|----------|
| **🏗️ Setup** | `/create`, `/install-antigravity`, `/scaffold`, `/schema-first`, `/requirements-first`, `/mobile-init` |
| **💻 Dev** | `/enhance`, `/quickfix`, `/refactor`, `/brainstorm`, `/plan` |
| **🎨 Design** | `/ui-ux-pro-max`, `/admin-component`, `/admin-dashboard` |
| **✅ Quality** | `/test`, `/code-review-automation`, `/auto-healing`, `/auto-optimization-cycle`, `/performance-budget-enforcement` |
| **🔒 Security** | `/security-audit`, `/secret-scanning` |
| **🚀 Deploy** | `/deploy`, `/mobile-deploy`, `/optimize`, `/check`, `/maintain`, `/migrate` |
| **🎯 Multi-agent** | `/orchestrate`, `/debug` |

### Typical Flow (v5.0 — Pipeline Chains)

```
User Request → Intent Router → Pipeline tự động
        │
        ├── "Tạo dự án mới"      → BUILD Pipeline  (Phase 0→5 + FINAL)
        ├── "Thêm tính năng"     → ENHANCE Pipeline (Phase 0→4 + FINAL)
        ├── "Sửa lỗi"           → FIX Pipeline     (Phase 0→4 + FINAL)
        ├── "Refactor/optimize"  → IMPROVE Pipeline
        ├── "Deploy"             → SHIP Pipeline
        └── "Review code"       → REVIEW Pipeline
```

> Mỗi Pipeline tự chạy từ đầu đến cuối — không cần gọi thủ công từng workflow.

**Chi tiết:** Xem [WORKFLOW-CATALOG.md](.agent/docs/workflows/WORKFLOW-CATALOG.md)

---

## 🧬 CORE PROTOCOLS

6 protocols định nghĩa cách hệ thống hoạt động:

| Protocol | Chức năng |
|----------|-----------|
| **RBA** (Reasoning-Before-Action) | Bắt buộc suy luận trước mọi action |
| **Auto-Rule Discovery** | 3-layer detection: file extension → project config → keywords |
| **Agent Registry** | Machine-readable capability matching |
| **Orchestration Engine** | Automated pipeline execution |
| **Agent Coordination** | Multi-agent file ownership & sync |
| **AOC** (Auto-Optimization Cycle) | Tự động optimize sau mỗi feature |

```mermaid
sequenceDiagram
    actor User
    participant Rules as Auto-Rule Discovery
    participant Registry as Agent Registry
    participant Engine as Orchestration Engine
    participant RBA as RBA Validator
    participant Agent as Specialist Agent
    participant AOC as AOC Cycle

    User->>Rules: Request
    Rules->>Registry: Detect context → match capabilities
    Registry->>Engine: Select pipeline
    Engine->>RBA: Validate reasoning
    RBA->>Agent: Execute
    Agent->>AOC: Feature complete
    AOC-->>Agent: Re-run if quality < 80%
    Agent->>User: Output ✅
```

**Chi tiết:** Xem [SYSTEMS-CATALOG.md](.agent/docs/systems/SYSTEMS-CATALOG.md)

---

## 🧠 MEMORY SYSTEM

Hệ thống nhớ giúp AI **giữ ngữ cảnh** xuyên suốt các phiên làm việc:

| File | Mục đích |
|------|----------|
| `user-profile.yaml` | Tech stack & preferences của team |
| `capability-boundaries.yaml` | Mức độ expertise của AI (0-100) |
| `learning-patterns.yaml` | Proven patterns & lessons learned |
| `tech-radar.yaml` | Quyết định ADOPT / TRIAL / HOLD / RETIRE |
| `feedback.yaml` | Continuous improvement tracking |

**Lợi ích:**
- ✅ Không cần giải thích lại context mỗi session
- ✅ AI nhớ các quyết định đã thống nhất
- ✅ Tự động áp dụng coding conventions
- ✅ Học từ thành công và thất bại

---

## 🛠️ TECH STACK SUPPORT

### Expert Level (90-100%)

| Category | Technologies |
|----------|-------------|
| **Backend** | Laravel 12, Django, FastAPI, NestJS, Express |
| **Frontend** | React 19, Vue 3, Next.js 16, Nuxt, Svelte, Astro |
| **Mobile** | React Native, Flutter, iOS Swift, Android Kotlin |
| **Database** | PostgreSQL, MySQL, Redis, MongoDB |

### Strong Level (70-89%)

| Category | Technologies |
|----------|-------------|
| **Infrastructure** | Docker, Kubernetes, Terraform |
| **Cloud** | AWS, GCP, Azure, Vercel, Cloudflare |
| **Monitoring** | OpenTelemetry, Grafana, Prometheus, Sentry |
| **CI/CD** | GitHub Actions, GitLab CI |

### 110 Expert Rules — Auto-Activation

Rules tự động load dựa trên context:

| Detection | Trigger → Rules |
|-----------|----------------|
| **File Extension** | `.vue` → Vue3 rules, `.php` → Laravel rules, `.py` → FastAPI rules |
| **Project Config** | `package.json + next` → Next.js rules, `composer.json` → Laravel rules |
| **Request Keywords** | "security" → Security audit rules, "deploy" → DevOps rules |

**Chi tiết:** Xem [Auto-Rule Discovery](.agent/systems/auto-rule-discovery.md)

---

## 📊 QUALITY GATES (Platinum Standard)

| Metric | Target | Enforcement |
|--------|--------|-------------|
| AI Autonomy | 95% | Agent-driven development |
| Code Quality Score | ≥ 95/100 | `ai-code-reviewer` automated |
| Test Coverage | ≥ 80% | CI/CD gate |
| Security Audit | OWASP Top 10 | `security-auditor` pre-deploy |
| Performance Budget | Defined per project | `performance-check.ps1` |

### Automation Scripts (37 total: 20 core + 17 skill)

```powershell
.\.agent\agent.ps1 health       # System health check
.\.agent\agent.ps1 validate     # Full compliance check
.\.agent\agent.ps1 secret-scan  # Secret detection
.\.agent\agent.ps1 heal         # Auto-fix lint/type errors
.\.agent\agent.ps1 perf         # Performance budget check
.\.agent\agent.ps1 dx roi       # Developer experience metrics
```

**Chi tiết:** Xem [SCRIPT-CATALOG.md](.agent/docs/scripts/SCRIPT-CATALOG.md)

---

## 🎯 USE CASES

### 1️⃣ Tạo dự án mới từ đầu

```
Input:    Mô tả ý tưởng (ngôn ngữ tự nhiên)
Pipeline: Intent Router → BUILD Pipeline (tự động 6 pha)

Phase 0:  Bootstrap — tạo docs/PLAN.md, tasks/todo.md, tasks/lessons.md, README.md
          + Smart PRD (nếu dự án phức tạp 3+ features → chain /requirements-first → docs/PRD.md)
Phase 1:  Discovery — Smart Interview (tự chọn tầng theo complexity):
          • Simple (2Q): chỉ hỏi loại app + MVP
          • Moderate (7-10Q): business + tech + design
          • Complex (26Q/7 categories): chain full structured interview
Phase 2:  Planning — kế hoạch + schema + ⛔ CHECKPOINT (user approve)
Phase 3:  Scaffolding — code + structure + tests
Phase 4:  Quality — lint + test + security scan
Phase 5:  Delivery — dev server + demo
FINAL:    Learning Loop — ghi bài học vào learning-patterns.yaml

Output:   docs/PLAN.md + docs/PRD.md (nếu complex) + Code + Tests + README.md
Time:     15-45 phút (tùy complexity)
```

### 2️⃣ Tiếp nhận dự án Legacy

```
Input:    Project path (mô tả yêu cầu hoặc chỉ cần mở project)
Pipeline: Intent Router → ENHANCE/FIX Pipeline

Phase 0:  Onboarding — 3-Tier Check:
          • Chưa có docs    → CREATE: scan project + tạo docs/PLAN.md, tasks/todo.md, tasks/lessons.md
          • Có docs nhưng chưa chuẩn → UPGRADE: hỏi user 1 lần + bổ sung + gắn compliance stamp
          • Docs đã chuẩn   → SKIP: qua thẳng Phase 1
Phase 1+: ENHANCE hoặc FIX pipeline (tùy yêu cầu)
FINAL:    Learning Loop — ghi bài học

Output:   docs/PLAN.md + tasks/todo.md + tasks/lessons.md + Code changes
Time:     10-20 phút (onboarding) + thời gian feature/fix
```

### 3️⃣ Phát triển feature mới

```
Input:    Mô tả tính năng (ngôn ngữ tự nhiên hoặc User Story)
Pipeline: Intent Router → ENHANCE Pipeline (tự động 5 pha)

Phase 0:  Onboarding (skip nếu đã có docs)
Phase 1:  Context — đọc project, hiểu kiến trúc hiện tại
Phase 2:  Design — impact analysis + ⛔ CHECKPOINT
Phase 3:  Implement — code + integration tests
Phase 4:  Verify — tests + lint + quality gates
FINAL:    Learning Loop

Output:   Code + Tests + Change Summary (WHY/WHAT/IMPACT/RISK)
Time:     1-3 giờ/feature
AI:       95% autonomous
```

### 4️⃣ Deploy lên production

```
Input:    Approved code
Pipeline: Intent Router → SHIP Pipeline (tự động 5 pha)

Phase 1:  Pre-flight checks (tests, security scan)
Phase 2:  Build + bundle
Phase 3:  Deploy (staging → production)
Phase 4:  Verify (health checks, smoke tests)
Phase 5:  Confirm hoặc Rollback
FINAL:    Learning Loop

Output:   Production URL + deploy report
Time:     30 phút - 2 giờ
```

### 📄 Mapping tài liệu cũ → v5.0

| Doc cũ (v3.x-v4.x) | Doc mới (v5.0) | Ghi chú |
|---------------------|----------------|----------|
| PROJECT-BRIEF.md | `docs/PLAN.md` | Gộp overview + goals + constraints |
| TECH-STACK.md | `docs/PLAN.md → Tech Decisions` | Gộp vào section Tech Decisions |
| GETTING-STARTED.md | `README.md` | Quick Start + Installation |
| CONVENTIONS.md | Auto-loaded từ `rules/` | AI tự detect framework → load rules phù hợp |
| PERFORMANCE-RECOMMENDATIONS.md | REVIEW Pipeline output | Tạo khi chạy `/check` hoặc REVIEW pipeline |
| _(không có)_ | `docs/PRD.md` | **MỚI** — 9-section PRD cho dự án phức tạp |
| _(không có)_ | `tasks/todo.md` | **MỚI** — Task tracking |
| _(không có)_ | `tasks/lessons.md` | **MỚI** — Bài học rút ra |

---

## 🚀 KẾT QUẢ KỲ VỌNG

**Sau 1 tháng sử dụng:**

| Metric | Kết quả |
|--------|---------|
| Features delivered/month | 40-60 |
| AI autonomy | 90-95% |
| Quality average | 85-90/100 |
| Test coverage | 80-90% |
| Time per feature | 1-2 hours (vs 4-6 manual) |

**ROI:**
- ⚡ **3-4x** faster development
- 🎯 **Consistent** 85+ quality score
- 📝 **Complete** auto-generated documentation
- 🧪 **Automated** testing & security scanning

---

## 📚 TÀI LIỆU

### System Documentation

| Document | Mô tả |
|----------|-------|
| [📖 **docs/INDEX.md**](.agent/docs/INDEX.md) | **Master index — Bắt đầu từ đây** |
| [AGENT-CATALOG.md](.agent/docs/agents/AGENT-CATALOG.md) | 27 agents chi tiết |
| [SKILL-CATALOG.md](.agent/docs/skills/SKILL-CATALOG.md) | 59 skills chi tiết |
| [WORKFLOW-CATALOG.md](.agent/docs/workflows/WORKFLOW-CATALOG.md) | 34 Workflows chi tiết |
| [Auto-Rule Discovery](.agent/systems/auto-rule-discovery.md) | 110 rules chi tiết |
| [SYSTEMS-CATALOG.md](.agent/docs/systems/SYSTEMS-CATALOG.md) | 6 protocols (5 files + AOC) |

### Architecture & Config

| Document | Mô tả |
|----------|-------|
| [ARCHITECTURE.md](.agent/ARCHITECTURE.md) | System architecture & directory map |
| [GEMINI.md](.agent/GEMINI.md) | AI workspace behavior (Master config) |
| [CHANGELOG.md](.agent/CHANGELOG.md) | Version history chi tiết |

### Project Guides

| Document | Mô tả |
|----------|-------|
| [New-Project-Interview-Prompt.txt](docs/New-Project-Interview-Prompt.txt) | 26-question interview cho dự án mới |
| [Analyze-Existing-Project-Prompt.txt](docs/Analyze-Existing-Project-Prompt.txt) | 17-category phân tích dự án có sẵn |

### v5.0 Pipeline System

| Document | Mô tả |
|----------|-------|
| [BUILD.md](.agent/pipelines/BUILD.md) | Pipeline tạo dự án mới (6 pha) |
| [ENHANCE.md](.agent/pipelines/ENHANCE.md) | Pipeline thêm tính năng (5 pha) |
| [FIX.md](.agent/pipelines/FIX.md) | Pipeline sửa lỗi (5 pha) |
| [project-bootstrap.md](.agent/templates/project-bootstrap.md) | Template tài liệu dự án bắt buộc |

---

## 🗺️ ROADMAP

### v5.0.0 ✅ (February 2026 — Current)

- ✅ **Intent Router** — Entry point duy nhất, auto-classify mọi request
- ✅ **6 Pipeline Chains** — BUILD, ENHANCE, FIX, IMPROVE, SHIP, REVIEW
- ✅ **Project Bootstrap** — Auto-generate project docs (PHASE 0)
- ✅ **Smart PRD** — Auto-detect complexity, chain /requirements-first
- ✅ **Compliance Stamp** — 3-tier doc check (CREATE/UPGRADE/SKIP)
- ✅ **Learning Loop** — PHASE FINAL tự ghi bài học mỗi pipeline
- ✅ **Usage Tracking** — Pipeline metrics cho quarterly review
- ✅ **GEMINI.md Slim** — Giảm 71% context footprint
- ✅ **STANDARDS.md §9-10** — Context Window Discipline + Change Summary

### v4.1.1 ✅ (February 2026)

- ✅ Auto-Rule Discovery Engine (3-layer detection)
- ✅ Agent Registry (27 specialized agents)
- ✅ 110 expert rules, 59 skills, 34 workflows
- ✅ Full documentation suite

### v5.1.0 (Planned — Q2 2026)

- [ ] True parallel agent execution (pending IDE support)
- [ ] Skill marketplace
- [ ] Analytics dashboard (DX metrics visualization)
- [ ] Multi-language CLI (bash + pwsh feature parity)

---

## 👥 CREDITS

Built with ❤️ as an AI-Native Development Operating System.

**Author:** [Hoàng Thanh Tuyền](https://github.com/tuyenht)  
**Repository:** [github.com/tuyenht/Antigravity-Core](https://github.com/tuyenht/Antigravity-Core)

---

## 📄 LICENSE

Proprietary — All rights reserved.

---

<p align="center">
  <b>🎊 Welcome to the future of software development! 🎊</b>
</p>

```
┌──────────────────────────────────────────────┐
│                                              │
│  27 Agents. 59 Skills. 110 Rules. 6 Pipelines.│
│  Copy. Prompt. Build. Deploy.                │
│  95% AI. 5% You.                             │
│                                              │
└──────────────────────────────────────────────┘
```

<p align="center">
  <sub>Antigravity-Core — Where Human Intent Meets AI Excellence</sub>
  <br>
  <sub>Built with 💎 Platinum Standard</sub>
</p>

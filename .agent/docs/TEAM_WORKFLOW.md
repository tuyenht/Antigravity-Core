# 🔄 TEAM WORKFLOW PIPELINE

**Version:** 2.0  
**Antigravity-Core:** v5.0.1  
**Purpose:** Quy trình phát triển chuẩn với Input→Output mapping rõ ràng  
**Usage:** Mọi project sinh ra từ Antigravity-Core tuân theo workflow này  
**Slash Command:** `/full-pipeline`

---

## 📋 TỔNG QUAN PIPELINE

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        ANTIGRAVITY WORKFLOW                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   STEP 1-2          STEP 3           STEP 4          STEP 5-N          │
│   ─────────         ──────           ──────          ────────          │
│                                                                         │
│   ┌─────────┐      ┌─────────┐      ┌─────────┐      ┌─────────┐       │
│   │   BA    │ ───▶ │   SA    │ ───▶ │   PM    │ ───▶ │  DEV    │       │
│   │ Analysis│      │ Design  │      │ Planning│      │  Build  │       │
│   └──────┘      └──────┘      └──────┘      └──────┘       │
│        │                │                │                │             │
│        ▼                ▼                ▼                ▼             │
│   PRD.md          architecture.md   backlog.md       src/ + tests/     │
│                   schema.sql        sprint-N.md                         │
│                                                                         │
│                                                          │              │
│                                                          ▼              │
│                                                     ┌─────────┐         │
│                                                     │   QA    │         │
│                                                     │  Test   │         │
│                                                     └──────┘         │
│                                                          │              │
│                                                          ▼              │
│                                                     ┌─────────┐         │
│                                                     │   DO    │         │
│                                                     │ Deploy  │         │
│                                                     └──────┘         │
│                                                          │              │
│                                                          ▼              │
│                                                     🚀 PRODUCTION       │
│                                                                         │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 🎯 ROLE → AGENT MAPPING (v2.0)

Các role trong pipeline này được thực thi bởi **27 agents** của Antigravity-Core:

| Pipeline Role | Code | Antigravity Agent | Skills được load | Workflows liên quan |
|---------------|------|------------------|----------------|--------------------|
| Business Analyst | `BA` | `project-planner` | `brainstorming`, `plan-writing`, `app-builder` | `/requirements-first`, `/brainstorm` |
| Solution Architect | `SA` | `backend-specialist` + `database-architect` | `architecture-mastery`, `database-design`, `api-patterns` | `/schema-first`, `/plan` |
| Project Manager | `PM` | `orchestrator` + `project-planner` | `plan-writing`, `behavioral-modes`, `parallel-agents` | `/plan`, `/orchestrate` |
| Backend Developer | `BE` | `backend-specialist` + `laravel-specialist` | `laravel-performance`, `testing-mastery`, `database-design` | `/enhance`, `/scaffold` |
| Frontend Developer | `FE` | `frontend-specialist` | `react-patterns`, `react-performance`, `frontend-design` | `/enhance`, `/ui-ux-pro-max` |
| QA Engineer | `QA` | `test-engineer` + `test-generator` | `testing-mastery`, `webapp-testing`, `code-review-checklist` | `/test`, `/check` |
| DevOps Engineer | `DO` | `devops-engineer` | `deployment-procedures`, `kubernetes-patterns`, `docker-expert` | `/deploy`, `/mobile-deploy` |

> **Lưu ý:** Khi gọi role bằng trigger phrase (ví dụ: `business-analyst`), hệ thống sẽ tự động route tới agent phù hợp và load các skills tương ứng.

---

## 📦 STEP 1-2: REQUIREMENTS GATHERING

### Thông tin

| Attribute | Value |
|-----------|-------|
| **Role** | Business Analyst (BA) |
| **Duration** | 30-60 phút |
| **Input** | Raw ideas, meeting notes, stakeholder requests |
| **Output** | `docs/PRD.md`, `docs/user-stories.md` |

### Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│ STEP 1-2: Requirements Gathering                                │
│ ─────────────────────────────────────────────────────────────── │
│                                                                 │
│  📥 INPUT:                                                      │
│  ├── Raw requirements (text, notes, verbal)                    │
│  ├── Stakeholder interviews                                    │
│  └── Reference documents                                       │
│                                                                 │
│  🔄 PROCESS:                                                    │
│  ├── business-analyst, analyze requirements                    │
│  ├── Identify user personas                                    │
│  ├── Define functional requirements                            │
│  ├── Define non-functional requirements                        │
│  └── Write user stories with acceptance criteria               │
│                                                                 │
│  📤 OUTPUT:                                                     │
│  ├── docs/PRD.md (9 sections complete)                         │
│  └── docs/user-stories.md (all features as stories)           │
│                                                                 │
│  ✅ VALIDATION:                                                 │
│  ├── [ ] PRD có đủ 9 sections?                                 │
│  ├── [ ] Mỗi feature có user story?                            │
│  ├── [ ] Acceptance criteria rõ ràng?                          │
│  └── [ ] No [TODO] placeholders?                               │
│                                                                 │
│  ▶️ NEXT: STEP 3 (Solution Architect)                          │
└──────────────────────────────────────────────────────────────┘
```

### Prompt

```
business-analyst,

Phân tích yêu cầu dự án sau:
[PASTE RAW REQUIREMENTS]

Tạo output:
1. docs/PRD.md - Product Requirements Document (9 sections)
2. docs/user-stories.md - User Stories với acceptance criteria

Format user story:
- ID: US-XXX
- Title: As a [role], I want [feature] so that [benefit]
- Acceptance Criteria: Given-When-Then format
```

---

## 📐 STEP 3: ARCHITECTURE DESIGN

### Thông tin

| Attribute | Value |
|-----------|-------|
| **Role** | Solution Architect (SA) |
| **Duration** | 1-2 giờ |
| **Input** | `docs/PRD.md` |
| **Output** | `docs/architecture.md`, `docs/tech-decisions.md`, `docs/schema.sql`, `docs/diagrams/` |

### Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│ STEP 3: Architecture Design                                     │
│ ─────────────────────────────────────────────────────────────── │
│                                                                 │
│  📥 INPUT:                                                      │
│  └── docs/PRD.md (từ Step 1-2)                                 │
│                                                                 │
│  🔄 PROCESS:                                                    │
│  ├── solution-architect, design system                         │
│  ├── Choose tech stack (với rationale)                         │
│  ├── Design system components                                  │
│  ├── Define API contracts                                      │
│  ├── Design database schema                                    │
│  └── Create component diagrams                                 │
│                                                                 │
│  📤 OUTPUT:                                                     │
│  ├── docs/architecture.md (system overview)                    │
│  ├── docs/tech-decisions.md (ADRs)                             │
│  ├── docs/schema.sql (database design)                         │
│  └── docs/diagrams/component-diagram.mmd                       │
│                                                                 │
│  ✅ VALIDATION:                                                 │
│  ├── [ ] Architecture covers tất cả features trong PRD?        │
│  ├── [ ] Tech decisions có reasoning?                          │
│  ├── [ ] Schema có indexes, foreign keys?                      │
│  ├── [ ] API endpoints được định nghĩa?                        │
│  └── [ ] Security considerations đầy đủ?                       │
│                                                                 │
│  ▶️ NEXT: STEP 4 (Project Manager)                             │
└──────────────────────────────────────────────────────────────┘
```

### Prompt

```
solution-architect,

Dựa trên docs/PRD.md, thiết kế kiến trúc hệ thống.

Yêu cầu:
- Scale target: [X users concurrent]
- Performance: [response time requirements]
- Security: [compliance requirements]

Tạo output:
1. docs/architecture.md - System architecture overview
2. docs/tech-decisions.md - Architecture Decision Records (ADRs)
3. docs/schema.sql - Complete database schema
4. docs/diagrams/component-diagram.mmd - Mermaid component diagram
```

---

## 📅 STEP 4: SPRINT PLANNING

### Thông tin

| Attribute | Value |
|-----------|-------|
| **Role** | Project Manager (PM) |
| **Duration** | 30-60 phút |
| **Input** | `docs/PRD.md`, `docs/architecture.md` |
| **Output** | `docs/backlog.md`, `docs/sprint-N.md` |

### Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│ STEP 4: Sprint Planning                                         │
│ ─────────────────────────────────────────────────────────────── │
│                                                                 │
│  📥 INPUT:                                                      │
│  ├── docs/PRD.md                                               │
│  ├── docs/architecture.md                                      │
│  └── docs/user-stories.md                                      │
│                                                                 │
│  🔄 PROCESS:                                                    │
│  ├── project-manager, create sprint plan                       │
│  ├── Prioritize user stories (P1 > P2 > P3)                   │
│  ├── Estimate story points                                     │
│  ├── Identify dependencies                                     │
│  ├── Allocate stories to sprints                               │
│  └── Define Definition of Done                                 │
│                                                                 │
│  📤 OUTPUT:                                                     │
│  ├── docs/backlog.md (Product Backlog)                         │
│  ├── docs/sprint-1.md (Sprint 1 plan)                          │
│  └── docs/timeline.md (Overall timeline)                       │
│                                                                 │
│  ✅ VALIDATION:                                                 │
│  ├── [ ] Mọi features có trong backlog?                        │
│  ├── [ ] Stories được prioritize và estimate?                  │
│  ├── [ ] Dependencies được identify?                           │
│  ├── [ ] Sprint 1 có scope hợp lý?                             │
│  └── [ ] DoD rõ ràng?                                          │
│                                                                 │
│  ▶️ NEXT: STEP 5+ (Implementation)                             │
└──────────────────────────────────────────────────────────────┘
```

### Prompt

```
project-manager,

Dựa trên:
- docs/PRD.md
- docs/architecture.md
- docs/user-stories.md

Tạo sprint plan:
- Team size: [X developers]
- Sprint duration: [2 weeks]

Output:
1. docs/backlog.md - Product Backlog (prioritized)
2. docs/sprint-1.md - First sprint plan
3. docs/timeline.md - Overall project timeline

Definition of Done:
- Code reviewed
- Tests written (≥80% coverage)
- Documentation updated
- No lint errors
```

---

## 💻 STEP 5-N: IMPLEMENTATION

### Thông tin

| Attribute | Value |
|-----------|-------|
| **Role** | Backend Developer (BE) + Frontend Developer (FE) |
| **Duration** | 2-4 giờ per story |
| **Input** | User Story từ backlog |
| **Output** | `src/`, `tests/`, API docs |

### Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│ STEP 5-N: Implementation (Repeat per User Story)                │
│ ─────────────────────────────────────────────────────────────── │
│                                                                 │
│  📥 INPUT:                                                      │
│  ├── User Story (US-XXX) từ docs/backlog.md                    │
│  ├── docs/architecture.md (reference)                          │
│  └── docs/schema.sql (database)                                │
│                                                                 │
│  🔄 PROCESS:                                                    │
│  ├── backend-developer, implement US-XXX                       │
│  │   ├── Create migrations                                     │
│  │   ├── Implement models                                      │
│  │   ├── Create controllers/routes                             │
│  │   ├── Write services/business logic                         │
│  │   └── Write unit tests                                      │
│  │                                                              │
│  ├── frontend-developer, implement US-XXX                      │
│  │   ├── Create components                                     │
│  │   ├── Implement state management                            │
│  │   ├── API integration                                       │
│  │   └── Write component tests                                 │
│                                                                 │
│  📤 OUTPUT:                                                     │
│  ├── src/** (implementation code)                              │
│  ├── tests/** (unit + integration tests)                       │
│  └── docs/api-docs.md (updated)                                │
│                                                                 │
│  ✅ VALIDATION:                                                 │
│  ├── [ ] All acceptance criteria implemented?                  │
│  ├── [ ] Tests pass (coverage ≥80%)?                           │
│  ├── [ ] Lint clean?                                           │
│  ├── [ ] API documented?                                       │
│  └── [ ] No hardcoded values?                                  │
│                                                                 │
│  ▶️ NEXT: QA Testing                                           │
└──────────────────────────────────────────────────────────────┘
```

### Prompt (Backend)

```
backend-developer,

Implement User Story: US-XXX

[PASTE USER STORY WITH ACCEPTANCE CRITERIA]

Requirements:
- Follow docs/architecture.md
- Use schema from docs/schema.sql
- Write tests (≥80% coverage)
- Update docs/api-docs.md
- Follow .agent/rules/STANDARDS.md
```

### Prompt (Frontend)

```
frontend-developer,

Implement UI for User Story: US-XXX

[PASTE USER STORY WITH ACCEPTANCE CRITERIA]

Requirements:
- Component-based architecture
- Responsive design
- Integrate with backend API
- Write component tests
- Follow design system
```

---

## 🧪 QA STEP: TESTING

### Thông tin

| Attribute | Value |
|-----------|-------|
| **Role** | QA Engineer (QA) |
| **Duration** | 1-2 giờ per feature |
| **Input** | Completed feature |
| **Output** | `tests/e2e/`, test reports |

### Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│ QA STEP: Testing                                                │
│ ─────────────────────────────────────────────────────────────── │
│                                                                 │
│  📥 INPUT:                                                      │
│  ├── Completed feature (US-XXX)                                │
│  ├── Acceptance criteria                                       │
│  └── Test environment                                          │
│                                                                 │
│  🔄 PROCESS:                                                    │
│  ├── qa-engineer, test US-XXX                                  │
│  ├── Functional testing (happy path)                           │
│  ├── Edge case testing                                         │
│  ├── Negative testing                                          │
│  ├── Integration testing                                       │
│  └── Regression testing                                        │
│                                                                 │
│  📤 OUTPUT:                                                     │
│  ├── tests/e2e/US-XXX.spec.ts                                  │
│  ├── docs/test-reports/US-XXX.md                               │
│  └── docs/bugs/ (if bugs found)                                │
│                                                                 │
│  ✅ VALIDATION:                                                 │
│  ├── [ ] All ACs tested?                                       │
│  ├── [ ] Edge cases covered?                                   │
│  ├── [ ] E2E tests pass?                                       │
│  ├── [ ] No critical/high bugs?                                │
│  └── [ ] Regression tests pass?                                │
│                                                                 │
│  ▶️ NEXT: Deployment (if pass) or Fix (if fail)               │
└──────────────────────────────────────────────────────────────┘
```

### Prompt

```
qa-engineer,

Test feature: US-XXX

[PASTE ACCEPTANCE CRITERIA]

Perform:
1. Functional testing (happy path + edge cases)
2. Integration testing
3. Regression testing

Output:
- tests/e2e/US-XXX.spec.ts
- docs/test-reports/US-XXX.md
- docs/bugs/ (if any bugs found)
```

---

## 🚀 FINAL STEP: DEPLOYMENT

### Thông tin

| Attribute | Value |
|-----------|-------|
| **Role** | DevOps Engineer (DO) |
| **Duration** | 30 phút - 2 giờ |
| **Input** | QA-approved code |
| **Output** | Production deployment |

### Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│ FINAL STEP: Deployment                                          │
│ ─────────────────────────────────────────────────────────────── │
│                                                                 │
│  📥 INPUT:                                                      │
│  ├── QA-approved code (all tests pass)                         │
│  ├── docs/architecture.md (infra requirements)                 │
│  └── .env.example                                              │
│                                                                 │
│  🔄 PROCESS:                                                    │
│  ├── devops-engineer, deploy to [environment]                  │
│  ├── Setup CI/CD pipelines                                     │
│  ├── Configure infrastructure                                  │
│  ├── Deploy to staging                                         │
│  ├── Smoke testing                                             │
│  └── Deploy to production                                      │
│                                                                 │
│  📤 OUTPUT:                                                     │
│  ├── .github/workflows/ci.yml                                  │
│  ├── .github/workflows/cd.yml                                  │
│  ├── docker-compose.yml (if Docker)                            │
│  ├── scripts/deploy.sh                                         │
│  └── Production URL 🎉                                         │
│                                                                 │
│  ✅ VALIDATION:                                                 │
│  ├── [ ] CI pipeline green?                                    │
│  ├── [ ] Staging deployment successful?                        │
│  ├── [ ] Smoke tests pass?                                     │
│  ├── [ ] Production health check pass?                         │
│  └── [ ] Monitoring/alerting configured?                       │
│                                                                 │
│  🎊 DONE: Feature live in production!                          │
└──────────────────────────────────────────────────────────────┘
```

### Prompt

```
devops-engineer,

Deploy project to production:
- Platform: [AWS/GCP/VPS/Vercel]
- Environment: production

Requirements:
- CI/CD pipeline (GitHub Actions)
- Docker containerization
- SSL/TLS enabled
- Health checks configured
- Secrets management

Output:
- .github/workflows/ci.yml
- .github/workflows/cd.yml
- docker-compose.yml
- scripts/deploy.sh
- docs/deployment-runbook.md
```

---

## 📊 WORKFLOW SUMMARY

| Step | Role | Input | Output | Duration |
|------|------|-------|--------|----------|
| 1-2 | BA | Raw requirements | PRD.md, user-stories.md | 30-60 min |
| 3 | SA | PRD.md | architecture.md, schema.sql | 1-2 hrs |
| 4 | PM | PRD + Architecture | backlog.md, sprint-N.md | 30-60 min |
| 5-N | BE + FE | User Story | src/, tests/ | 2-4 hrs/story |
| QA | QA | Completed feature | e2e tests, reports | 1-2 hrs |
| Deploy | DO | Approved code | Production URL | 30 min - 2 hrs |

---

## 🔁 ITERATION CYCLE

```
For each Sprint:

1. [PM] Pick stories from backlog → sprint-N.md
2. For each story in sprint:
   a. [BE/FE] Implement → src/, tests/
   b. [QA] Test → test reports
   c. [Fix if bugs] → return to (a)
3. [DO] Deploy sprint → staging → production
4. [PM] Sprint retrospective
5. Repeat sprint
```

---

**Version:** 2.0  
**Created:** 2026-01-31  
**Updated:** 2026-02-25  
**Status:** ✅ Production Ready  
**Changelog:** v1.0→v2.0: Added Role→Agent mapping, slash command `/full-pipeline`, synced to Antigravity-Core v4.1.1

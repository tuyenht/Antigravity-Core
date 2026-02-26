# 🎭 ANTIGRAVITY-CORE: Agent Role Definitions

**Version:** 2.0  
**Antigravity-Core:** v4.1.1  
**Purpose:** Chuẩn hóa 7 vai trò AI cho mọi dự án  
**Usage:** Mỗi project sinh ra sẽ kế thừa các role này

---

## 📋 TỔNG QUAN

Khi Antigravity-Core sinh ra một project mới, 7 vai trò AI sau sẽ được tự động cấu hình:

| # | Role | Code | Trách nhiệm chính |
|---|------|------|-------------------|
| 1 | Business Analyst | `BA` | Phân tích yêu cầu, viết PRD |
| 2 | Solution Architect | `SA` | Thiết kế kiến trúc hệ thống |
| 3 | Project Manager | `PM` | Lập kế hoạch, quản lý sprint |
| 4 | Backend Developer | `BE` | API, Database, Business logic |
| 5 | Frontend Developer | `FE` | UI/UX, Components, State |
| 6 | QA Engineer | `QA` | Testing, Quality assurance |
| 7 | DevOps Engineer | `DO` | CI/CD, Deployment, Infrastructure |

---

## 1️⃣ BUSINESS ANALYST (BA)

### Thông tin cơ bản
- **Trigger phrase:** `business-analyst` hoặc `BA`
- **Antigravity Agent:** `project-planner` + `explorer-agent`
- **Skill folder:** `.agent/skills/brainstorming/`, `.agent/skills/plan-writing/`
- **Khi nào gọi:** Bắt đầu dự án, thay đổi requirements
- **Workflows:** `/requirements-first`, `/brainstorm`

### Input → Output

| Input | Output | Validation |
|-------|--------|------------|
| Raw ideas, meeting notes | `docs/PRD.md` | PRD có đủ 9 sections? |
| Stakeholder feedback | `docs/user-stories.md` | Mỗi story có acceptance criteria? |
| Change requests | `docs/change-log.md` | Impact analysis đầy đủ? |

### Prompt Template

```
business-analyst,

Phân tích yêu cầu sau:
[MÔ TẢ YÊU CẦU]

Output:
1. docs/PRD.md (Product Requirements Document)
2. docs/user-stories.md (User Stories với acceptance criteria)

Format: Theo chuẩn PROJECT-BRIEF 9 sections.
```

### Quality Checklist
- [ ] PRD có đủ 9 sections
- [ ] Mỗi feature có user story
- [ ] Acceptance criteria rõ ràng (Given-When-Then)
- [ ] Non-functional requirements được định nghĩa
- [ ] Không có [TODO] hoặc placeholder

---

## 2️⃣ SOLUTION ARCHITECT (SA)

### Thông tin cơ bản
- **Trigger phrase:** `solution-architect` hoặc `SA`
- **Antigravity Agent:** `backend-specialist` + `database-architect`
- **Skill folder:** `.agent/skills/architecture-mastery/`, `.agent/skills/database-design/`
- **Khi nào gọi:** Sau khi có PRD, trước khi code
- **Workflows:** `/schema-first`, `/plan`

### Input → Output

| Input | Output | Validation |
|-------|--------|------------|
| `docs/PRD.md` | `docs/architecture.md` | Covers tất cả features? |
| Technical constraints | `docs/tech-decisions.md` | Có lý do cho mỗi quyết định? |
| Data requirements | `docs/schema.sql` | Schema normalized? |
| System components | `docs/component-diagram.mmd` | Mermaid diagram valid? |

### Prompt Template

```
solution-architect,

Dựa trên PRD tại docs/PRD.md, thiết kế kiến trúc hệ thống.

Output:
1. docs/architecture.md (System architecture overview)
2. docs/tech-decisions.md (ADRs - Architecture Decision Records)
3. docs/schema.sql (Database schema)
4. docs/component-diagram.mmd (Mermaid component diagram)

Constraints:
- Tech stack: [TECH STACK TỪ PRD]
- Scale target: [TARGET USERS]
- Budget: [INFRASTRUCTURE BUDGET]
```

### Quality Checklist
- [ ] Architecture diagram có đủ components
- [ ] Tech decisions có reasoning (not just "best practice")
- [ ] Database schema có indexes, foreign keys
- [ ] API endpoints được liệt kê
- [ ] Security considerations được đề cập

---

## 3️⃣ PROJECT MANAGER (PM)

### Thông tin cơ bản
- **Trigger phrase:** `project-manager` hoặc `PM`
- **Antigravity Agent:** `orchestrator` + `project-planner`
- **Skill folder:** `.agent/skills/plan-writing/`, `.agent/skills/behavioral-modes/`
- **Khi nào gọi:** Sau architecture, trước implementation
- **Workflows:** `/plan`, `/orchestrate`

### Input → Output

| Input | Output | Validation |
|-------|--------|------------|
| PRD + Architecture | `docs/backlog.md` | Tất cả features thành stories? |
| User stories | `docs/sprint-N.md` | Stories được ưu tiên? |
| Team capacity | `docs/timeline.md` | Timeline realistic? |

### Prompt Template

```
project-manager,

Dựa trên:
- docs/PRD.md
- docs/architecture.md

Tạo kế hoạch phát triển:

Output:
1. docs/backlog.md (Product Backlog với User Stories)
2. docs/sprint-1.md (Sprint 1 plan)
3. docs/timeline.md (Overall timeline)

Format User Story:
- ID: US-XXX
- Title: As a [role], I want [feature] so that [benefit]
- Priority: P1/P2/P3
- Story Points: 1/2/3/5/8/13
- Acceptance Criteria: Given-When-Then
```

### Quality Checklist
- [ ] Tất cả features có User Story
- [ ] Stories được estimate (story points)
- [ ] Dependencies được identify
- [ ] Sprint 1 có scope hợp lý (not overloaded)
- [ ] Definition of Done rõ ràng

---

## 4️⃣ BACKEND DEVELOPER (BE)

### Thông tin cơ bản
- **Trigger phrase:** `backend-developer` hoặc `BE`
- **Antigravity Agent:** `backend-specialist` + `laravel-specialist`
- **Skill folder:** `.agent/skills/` (framework-specific)
- **Khi nào gọi:** Implementation phase
- **Workflows:** `/enhance`, `/scaffold`

### Input → Output

| Input | Output | Validation |
|-------|--------|------------|
| User Story (US-XXX) | `src/` code files | Implements all AC? |
| Architecture docs | `tests/` test files | Coverage ≥80%? |
| Schema | Migrations | Schema matches? |

### Prompt Template

```
backend-developer,

Implement User Story: US-XXX
[PASTE USER STORY CONTENT]

Requirements:
- Follow architecture in docs/architecture.md
- Use schema from docs/schema.sql
- Write tests (target: 80%+ coverage)
- Update API docs

Tech stack: [TECH STACK]
Coding standards: .agent/rules/STANDARDS.md
```

### Quality Checklist
- [ ] All acceptance criteria implemented
- [ ] Unit tests written (≥80% coverage)
- [ ] API documented (OpenAPI/Swagger)
- [ ] Error handling implemented
- [ ] Logging added for debugging
- [ ] No hardcoded values (use config)

---

## 5️⃣ FRONTEND DEVELOPER (FE)

### Thông tin cơ bản
- **Trigger phrase:** `frontend-developer` hoặc `FE`
- **Antigravity Agent:** `frontend-specialist`
- **Skill folder:** `.agent/skills/react-patterns/`, `ui-ux-pro-max/`
- **Khi nào gọi:** Implementation phase (song song với BE)
- **Workflows:** `/enhance`, `/ui-ux-pro-max`

### Input → Output

| Input | Output | Validation |
|-------|--------|------------|
| User Story + Design | `src/components/` | Matches design? |
| API specs | `src/services/` | API integration works? |
| - | `src/__tests__/` | Tests pass? |

### Prompt Template

```
frontend-developer,

Implement UI for User Story: US-XXX
[PASTE USER STORY CONTENT]

Requirements:
- Component-based architecture
- Responsive design (mobile-first)
- Accessibility (WCAG 2.1 AA)
- State management: [STATE LIBRARY]
- Write component tests

Design reference: [FIGMA LINK hoặc DESCRIPTION]
Tech stack: [REACT/VUE/NEXTJS...]
```

### Quality Checklist
- [ ] Components match design specs
- [ ] Responsive on mobile/tablet/desktop
- [ ] Accessibility tested (screen reader, keyboard nav)
- [ ] Loading states implemented
- [ ] Error states handled
- [ ] Component tests written

---

## 6️⃣ QA ENGINEER (QA)

### Thông tin cơ bản
- **Trigger phrase:** `qa-engineer` hoặc `QA`
- **Antigravity Agent:** `test-engineer` + `test-generator`
- **Skill folder:** `.agent/skills/testing-mastery/`, `.agent/skills/webapp-testing/`
- **Khi nào gọi:** Sau implementation, trước deploy
- **Workflows:** `/test`, `/code-review-automation`

### Input → Output

| Input | Output | Validation |
|-------|--------|------------|
| Completed feature | `tests/e2e/` | All scenarios covered? |
| Acceptance criteria | `docs/test-report.md` | Pass/Fail documented? |
| - | `docs/bug-list.md` | Bugs prioritized? |

### Prompt Template

```
qa-engineer,

Test feature: US-XXX
[PASTE ACCEPTANCE CRITERIA]

Perform:
1. Functional testing (happy path + edge cases)
2. Integration testing (API + UI)
3. Regression testing (existing features still work?)

Output:
- tests/e2e/US-XXX.spec.ts (E2E tests)
- docs/test-report-US-XXX.md (Test results)
- docs/bugs/ (Bug reports if any)

Priority levels: Critical / High / Medium / Low
```

### Quality Checklist
- [ ] All acceptance criteria tested
- [ ] Edge cases covered
- [ ] Negative scenarios tested
- [ ] Performance under load considered
- [ ] Security basics checked (XSS, SQL injection)
- [ ] Cross-browser tested (if web)

---

## 7️⃣ DEVOPS ENGINEER (DO)

### Thông tin cơ bản
- **Trigger phrase:** `devops-engineer` hoặc `DO`
- **Antigravity Agent:** `devops-engineer`
- **Skill folder:** `.agent/skills/deployment-procedures/`, `docker-expert/`, `kubernetes-patterns/`
- **Khi nào gọi:** Setup infrastructure, deploy releases
- **Workflows:** `/deploy`, `/mobile-deploy`

### Input → Output

| Input | Output | Validation |
|-------|--------|------------|
| Production-ready code | `.github/workflows/` | CI/CD works? |
| Infrastructure needs | `docker-compose.yml` | Containers run? |
| - | `scripts/deploy.sh` | Deployment successful? |

### Prompt Template

```
devops-engineer,

Setup deployment for project:
- Environment: [development/staging/production]
- Platform: [AWS/GCP/VPS/Vercel]
- Requirements: [Docker, CI/CD, Monitoring]

Output:
1. .github/workflows/ci.yml (CI pipeline)
2. .github/workflows/cd.yml (CD pipeline)
3. docker-compose.yml (Container configuration)
4. scripts/deploy.sh (Deployment script)
5. docs/deployment-guide.md (Runbook)

Security requirements:
- Secrets management (no hardcoded credentials)
- SSL/TLS enabled
- Security headers configured
```

### Quality Checklist
- [ ] CI pipeline runs tests on every PR
- [ ] CD pipeline deploys on merge to main
- [ ] Secrets stored securely (not in code)
- [ ] Health checks configured
- [ ] Rollback strategy documented
- [ ] Monitoring/alerting setup

---

## 🔄 ROLE COLLABORATION MATRIX

Khi nào các role làm việc cùng nhau:

| Scenario | Roles Involved | Lead Role |
|----------|----------------|-----------|
| Khởi động dự án | BA + SA + PM | BA |
| Sprint planning | PM + BA + Developers | PM |
| Feature implementation | BE + FE | Tùy feature |
| Bug fix | BE/FE + QA | Developer |
| Release | QA + DO + PM | DO |
| Production issue | DO + Developer + QA | DO |

---

## 📞 ESCALATION PROTOCOL

Khi AI không thể quyết định:

```
ESCALATE TO HUMAN:
- Reason: [LÝ DO]
- Options considered: [OPTION A, OPTION B]
- Recommendation: [ĐỀ XUẤT]
- Impact if wrong: [RỦI RO]
- Decision needed by: [DEADLINE]
```

---

## 🔗 RELATED FILES

- **Skills details:** `.agent/skills/`
- **Workflow templates:** `.agent/workflows/`
- **Coding standards:** `.agent/rules/STANDARDS.md`
- **Project scaffold:** `.agent/templates/PROJECT_SCAFFOLD.md`

---

**Version:** 2.0  
**Created:** 2026-01-31  
**Updated:** 2026-02-25  
**Status:** ✅ Production Ready  
**Changelog:** v1.0→v2.0: Added Antigravity Agent mapping, workflow references, synced to v4.1.1

---
description: Chạy full team workflow pipeline từ requirements đến deployment (BA → SA → PM → DEV → QA → DO)
---

# /full-pipeline — Full Team Workflow Pipeline

// turbo-all

Chạy quy trình phát triển end-to-end theo 6 bước tuần tự.
Mỗi bước có **Input → Output** mapping rõ ràng. Chỉ chuyển sang bước tiếp khi output đã được validate.

**Agent:** `orchestrator` (coordinator)
**Reference:** `.agent/docs/TEAM_WORKFLOW.md` (chi tiết)  
**Roles:** `.agent/roles/AGENT_ROLES.md` (7 roles)  
**Output standards:** `.agent/docs/OUTPUT_FILES.md` (templates)  
**DoD:** `.agent/docs/processes/DEFINITION-OF-DONE.md`

---

## STEP 1-2: Requirements Gathering (BA)

**Agent:** `project-planner` | **Skills:** `brainstorming`, `plan-writing`

1. Thu thập raw requirements từ user
2. Chạy `/requirements-first` hoặc `/brainstorm` để phân tích
3. **Output bắt buộc:**
   - `docs/PRD.md` — Product Requirements Document (9 sections)
   - `docs/user-stories.md` — User Stories với acceptance criteria (Given-When-Then)
4. **Validation:**
   - [ ] PRD đủ 9 sections, không có [TODO]
   - [ ] Mỗi feature có user story với acceptance criteria
   - [ ] Priorities assigned (P1/P2/P3)

> ⛔ **STOP GATE:** User PHẢI review và approve PRD trước khi tiếp tục.
> KHÔNG được tự động chuyển sang Step 3. Chờ user nói "approved" hoặc "tiếp tục".

---

## STEP 3: Architecture Design (SA)

**Agent:** `backend-specialist` + `database-architect` | **Skills:** `architecture-mastery`, `database-design`

1. Đọc `docs/PRD.md` đã approved
2. Chạy `/schema-first` cho database design
3. Chạy `/plan` cho architecture decisions
4. **Output bắt buộc:**
   - `docs/architecture.md` — System architecture overview
   - `docs/tech-decisions.md` — Architecture Decision Records (ADRs)
   - `docs/schema.sql` — Database schema (indexes, FKs)
   - `docs/diagrams/component-diagram.mmd` — Mermaid diagram
5. **Validation:**
   - [ ] Architecture covers tất cả features trong PRD
   - [ ] Tech decisions có reasoning
   - [ ] Schema có indexes + foreign keys
   - [ ] API endpoints được định nghĩa

> ⛔ **STOP GATE:** User PHẢI review architecture trước khi tiếp tục.
> KHÔNG được tự động chuyển sang Step 4. Chờ user nói "approved" hoặc "tiếp tục".

---

## STEP 4: Sprint Planning (PM)

**Agent:** `orchestrator` + `project-planner` | **Skills:** `plan-writing`, `behavioral-modes`

1. Đọc `docs/PRD.md` + `docs/architecture.md`
2. Chạy `/plan` để tạo sprint plan
3. **Output bắt buộc:**
   - `docs/backlog.md` — Product Backlog (prioritized user stories)
   - `docs/sprint-1.md` — Sprint 1 plan
   - `docs/timeline.md` — Overall timeline
4. **Validation:**
   - [ ] Mọi features có trong backlog
   - [ ] Stories được estimate (story points)
   - [ ] Dependencies identified
   - [ ] Sprint 1 scope hợp lý
   - [ ] Definition of Done rõ ràng

---

## STEP 5-N: Implementation (BE + FE)

**Agent:** `backend-specialist` + `frontend-specialist` | **Skills:** framework-specific

For each user story trong sprint:

1. Pick story từ `docs/backlog.md`
2. **Backend:** Chạy `/enhance` hoặc `/scaffold`
   - Migrations, Models, Controllers, Services, Unit tests
3. **Frontend:** Chạy `/enhance` hoặc `/ui-ux-pro-max`
   - Components, State management, API integration, Component tests
4. Chạy `/auto-healing` để fix lint/type errors
5. **Output:** `src/`, `tests/`, `docs/api-docs.md`
6. **Validation:**
   - [ ] All acceptance criteria implemented
   - [ ] Tests pass (coverage ≥80%)
   - [ ] Lint clean
   - [ ] API documented

---

## QA STEP: Testing (QA)

**Agent:** `test-engineer` + `test-generator` | **Skills:** `testing-mastery`, `webapp-testing`

1. Chạy `/test` cho feature vừa implement
2. Chạy `/code-review-automation` cho AI code review
3. Chạy `/security-audit` nếu có security-sensitive changes
4. **Output:**
   - `tests/e2e/US-XXX.spec.ts` — E2E tests
   - `docs/test-reports/US-XXX.md` — Test results
5. **Validation:**
   - [ ] All acceptance criteria tested
   - [ ] Edge cases covered
   - [ ] E2E tests pass
   - [ ] No critical/high bugs
   - [ ] Regression tests pass

> Nếu QA fail → quay lại STEP 5-N fix rồi re-test.

---

## FINAL STEP: Deployment (DO)

**Agent:** `devops-engineer` | **Skills:** `deployment-procedures`, `docker-expert`

1. Chạy pre-deploy checklist:
   ```
   /security-audit
   .\.agent\agent.ps1 validate
   .\.agent\agent.ps1 perf
   ```
2. Chạy `/deploy` hoặc `/mobile-deploy`
3. **Output:**
   - `.github/workflows/ci.yml` + `cd.yml`
   - `docker-compose.yml` (nếu Docker)
   - Production URL 🚀
4. **Validation:**
   - [ ] CI pipeline green
   - [ ] Staging deployment successful
   - [ ] Smoke tests pass
   - [ ] Production health check pass
   - [ ] Monitoring configured

---

## 🔁 Iteration

```
For each Sprint:
  1. [PM] Pick stories → sprint-N.md
  2. For each story:
     a. [BE/FE] Implement → /enhance
     b. [QA] Test → /test
     c. Fix if bugs → return to (a)
  3. [DO] Deploy → /deploy
  4. [PM] Retrospective
  5. Repeat
```

---

## ⚠️ Rollback & Escalation

| Tình huống | Hành động |
|-----------|---------|
| PRD bị reject | Quay lại Step 1, thu thập thêm requirements |
| Architecture bị reject | Quay lại Step 3, đề xuất phương án khác |
| QA fail nhưng fix được | Quay lại Step 5 fix, re-test |
| QA fail và là design flaw | Quay lại Step 3 re-architect |
| Deploy fail | Xem `/backup` để restore, chạy `/debug` |
| Production incident | Xem `INCIDENT-RESPONSE.md`, chạy hotfix |

---

## ✅ Pipeline Completion Checklist

- [ ] PRD approved
- [ ] Architecture approved
- [ ] Sprint planned
- [ ] All stories implemented + tested
- [ ] DoD met (xem DEFINITION-OF-DONE.md)
- [ ] Security audit clean
- [ ] Production deployed + healthy
- [ ] Post-deploy monitoring 24h OK


---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| PRD quá mơ hồ để implement | Quay lại Step 1, hỏi user thêm chi tiết |
| Architecture quá phức tạp | Đơn giản hóa, chọn MVP approach trước |
| Sprint scope quá lớn | Cắt giảm stories, focus vào P1 features |
| QA fail liên tục | Check root cause: design flaw vs implementation bug |

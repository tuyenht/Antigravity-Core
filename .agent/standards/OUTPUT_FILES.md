# 📋 OUTPUT FILE STANDARDS

**Version:** 1.0  
**Purpose:** Chuẩn hóa tất cả files được sinh ra từ Antigravity-Core  
**Usage:** Đảm bảo consistency và quality cho mọi output

---

## 🎯 MỤC ĐÍCH

Định nghĩa RÕ RÀNG:
1. **Những file nào** được sinh ra ở mỗi giai đoạn
2. **Nội dung gì** phải có trong mỗi file
3. **Tiêu chuẩn** để validate file đã hoàn chỉnh

---

## 📁 OUTPUT FILES BY PHASE

### Phase 1-2: Requirements (Business Analyst)

| File | Bắt buộc | Mô tả | Validation |
|------|----------|-------|------------|
| `docs/PRD.md` | ✅ Yes | Product Requirements Document | 9 sections đầy đủ |
| `docs/user-stories.md` | ✅ Yes | User Stories với AC | Mọi feature có story |

#### PRD.md Structure (9 Sections)

```markdown
# [PROJECT NAME] - Product Requirements Document

## 1. PROJECT OVERVIEW
- Project name
- One-liner description
- Project type (Web App / Mobile / API / etc.)
- Timeline
- Team size

## 2. TECHNICAL REQUIREMENTS
### 2.1 Core Features (Priority 1)
- Feature A: [description]
- Feature B: [description]

### 2.2 Secondary Features (Priority 2)
- Feature C: [description]

### 2.3 Nice-to-Have Features (Priority 3)
- Feature D: [description]

## 3. NON-FUNCTIONAL REQUIREMENTS
- Performance: [metrics]
- Security: [requirements]
- Scalability: [target users]
- Accessibility: [WCAG level]

## 4. TECHNOLOGY STACK
- Backend: [framework, language]
- Frontend: [framework]
- Database: [type, version]
- Infrastructure: [cloud, hosting]

## 5. CURRENT STATE ANALYSIS
- Existing code: [Yes/No]
- Legacy systems: [description]
- Migration needs: [description]

## 6. .AGENT INTEGRATION STRATEGY
- Agent assignments per phase
- Workflows to use
- Skills required

## 7. DEVELOPMENT ROADMAP
- Phase 1: Foundation (Week 1-2)
- Phase 2: Core Features (Week 3-6)
- Phase 3: Advanced (Week 7-10)
- Phase 4: Launch (Week 11-12)

## 8. RISK ASSESSMENT
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Risk 1 | High/Med/Low | High/Med/Low | [strategy] |

## 9. APPROVAL & SIGN-OFF
- Product Owner: _____________ Date: _____
- Tech Lead: _____________ Date: _____
```

#### user-stories.md Structure

```markdown
# User Stories

## [Feature Category]

### US-001: [Story Title]
**As a** [role]  
**I want** [feature]  
**So that** [benefit]

**Priority:** P1 / P2 / P3  
**Story Points:** 1 / 2 / 3 / 5 / 8 / 13

**Acceptance Criteria:**
1. Given [context], When [action], Then [result]
2. Given [context], When [action], Then [result]

**Notes:**
- [Additional context]

---
[Repeat for each story]
```

---

### Phase 3: Architecture (Solution Architect)

| File | Bắt buộc | Mô tả | Validation |
|------|----------|-------|------------|
| `docs/architecture.md` | ✅ Yes | System architecture | Covers all PRD features |
| `docs/tech-decisions.md` | ✅ Yes | ADRs | Có reasoning cho mỗi decision |
| `docs/schema.sql` | ✅ Yes | Database design | Có indexes, FKs |
| `docs/diagrams/component-diagram.mmd` | ⚠️ Recommended | Mermaid diagram | Valid syntax |

#### architecture.md Structure

```markdown
# System Architecture

## 1. OVERVIEW
[High-level system description]

## 2. ARCHITECTURE DIAGRAM
[Mermaid diagram hoặc link to image]

## 3. COMPONENTS

### 3.1 Frontend
- Framework: [name, version]
- Key libraries: [list]
- State management: [approach]

### 3.2 Backend
- Framework: [name, version]
- API style: REST / GraphQL
- Authentication: [method]

### 3.3 Database
- Type: SQL / NoSQL
- Engine: [name, version]
- Key tables: [list]

### 3.4 Infrastructure
- Hosting: [provider]
- CDN: [provider]
- CI/CD: [tools]

## 4. API ENDPOINTS
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | /api/users | List users | Yes |
| POST | /api/users | Create user | Yes |

## 5. DATA FLOW
[Description of how data flows through system]

## 6. SECURITY
- Authentication: [method]
- Authorization: [method]
- Data encryption: [approach]

## 7. SCALABILITY
- Current design supports: [X users]
- Scaling strategy: [approach]
```

#### tech-decisions.md Structure (ADRs)

```markdown
# Architecture Decision Records

## ADR-001: [Decision Title]

**Date:** YYYY-MM-DD  
**Status:** Accepted / Proposed / Deprecated

### Context
[Why this decision was needed]

### Decision
[What we decided]

### Options Considered
1. **Option A:** [description]
   - Pros: [list]
   - Cons: [list]

2. **Option B:** [description]
   - Pros: [list]
   - Cons: [list]

### Rationale
[Why we chose this option]

### Consequences
- Positive: [list]
- Negative: [list]

---
[Repeat for each decision]
```

#### schema.sql Requirements

```sql
-- REQUIRED SECTIONS:

-- 1. Table definitions with proper types
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 2. Indexes for performance
CREATE INDEX idx_users_email ON users(email);

-- 3. Foreign key relationships
ALTER TABLE posts 
ADD CONSTRAINT fk_posts_user 
FOREIGN KEY (user_id) REFERENCES users(id);

-- 4. Comments for documentation
COMMENT ON TABLE users IS 'Application users';
```

---

### Phase 4: Planning (Project Manager)

| File | Bắt buộc | Mô tả | Validation |
|------|----------|-------|------------|
| `docs/backlog.md` | ✅ Yes | Product Backlog | Tất cả features covered |
| `docs/sprint-1.md` | ✅ Yes | First sprint plan | Scope hợp lý |
| `docs/timeline.md` | ⚠️ Recommended | Overall timeline | Realistic estimates |

#### backlog.md Structure

```markdown
# Product Backlog

**Last Updated:** YYYY-MM-DD  
**Sprint Duration:** 2 weeks

## Priority Legend
- 🔴 P1: Critical (must have for MVP)
- 🟡 P2: Important (should have)
- 🟢 P3: Nice-to-have

## Backlog Items

| ID | Title | Priority | Points | Sprint | Status |
|----|-------|----------|--------|--------|--------|
| US-001 | User registration | 🔴 P1 | 5 | Sprint 1 | To Do |
| US-002 | User login | 🔴 P1 | 3 | Sprint 1 | To Do |
| US-003 | Profile page | 🟡 P2 | 3 | Sprint 2 | To Do |

## Total Points
- P1 features: XX points
- P2 features: XX points
- P3 features: XX points
- **Total:** XX points

## Velocity Estimate
- Team velocity: XX points/sprint
- Estimated sprints: XX sprints
```

---

### Phase 5+: Implementation (Developers)

| File | Bắt buộc | Mô tả | Validation |
|------|----------|-------|------------|
| `src/**` | ✅ Yes | Source code | Implements all ACs |
| `tests/unit/**` | ✅ Yes | Unit tests | Coverage ≥80% |
| `tests/integration/**` | ✅ Yes | Integration tests | Key flows covered |
| `docs/api-docs.md` | ✅ Yes | API documentation | All endpoints documented |

#### api-docs.md Structure

```markdown
# API Documentation

**Base URL:** `https://api.example.com/v1`  
**Authentication:** Bearer Token

## Endpoints

### Users

#### GET /users
List all users

**Headers:**
- Authorization: Bearer {token}

**Response:**
\`\`\`json
{
  "data": [
    {
      "id": 1,
      "email": "user@example.com"
    }
  ],
  "meta": {
    "total": 100,
    "page": 1
  }
}
\`\`\`

---
[Repeat for each endpoint]
```

---

### QA Phase (QA Engineer)

| File | Bắt buộc | Mô tả | Validation |
|------|----------|-------|------------|
| `tests/e2e/**` | ✅ Yes | E2E tests | Critical paths covered |
| `docs/test-reports/` | ⚠️ Recommended | Test reports | Pass/Fail documented |

---

### Deployment Phase (DevOps Engineer)

| File | Bắt buộc | Mô tả | Validation |
|------|----------|-------|------------|
| `.github/workflows/ci.yml` | ✅ Yes | CI pipeline | Runs on PRs |
| `.github/workflows/cd.yml` | ✅ Yes | CD pipeline | Deploys on merge |
| `docker-compose.yml` | ⚠️ If Docker used | Container config | Works locally |
| `scripts/deploy.sh` | ⚠️ Recommended | Deploy script | Automated |

---

## ✅ QUALITY CHECKLIST

### Trước khi kết thúc mỗi Phase

#### Phase 1-2 Checklist
- [ ] PRD.md có đủ 9 sections
- [ ] Không có [TODO] hoặc placeholder
- [ ] Mỗi feature có User Story
- [ ] User Stories có Acceptance Criteria (Given-When-Then)
- [ ] Priorities assigned (P1/P2/P3)

#### Phase 3 Checklist
- [ ] architecture.md covers tất cả features
- [ ] tech-decisions.md có rationale cho mỗi quyết định
- [ ] schema.sql có indexes và foreign keys
- [ ] API endpoints được định nghĩa
- [ ] Security được address

#### Phase 4 Checklist
- [ ] backlog.md có tất cả User Stories
- [ ] Stories được estimate (story points)
- [ ] Sprint 1 có scope hợp lý
- [ ] Dependencies identified
- [ ] DoD defined

#### Implementation Checklist
- [ ] All ACs implemented
- [ ] Unit tests ≥80% coverage
- [ ] Lint clean (no errors)
- [ ] API documented
- [ ] No hardcoded secrets

#### Deployment Checklist
- [ ] CI pipeline works
- [ ] CD pipeline works
- [ ] Secrets stored securely
- [ ] Health checks configured
- [ ] README updated

---

## 📊 FILE COUNT SUMMARY

### Minimal Viable Project

| Phase | Required Files | Optional Files |
|-------|----------------|----------------|
| Requirements | 2 | 0 |
| Architecture | 3 | 1 |
| Planning | 2 | 1 |
| Implementation | src + tests + 1 | varies |
| Deployment | 2 | 2 |
| **Total** | **10+** | **4+** |

### Production-Ready Project

Thêm vào Minimal:
- `CHANGELOG.md`
- `CONTRIBUTING.md`
- `docs/deployment-runbook.md`
- `docs/onboarding-guide.md`
- `scripts/*.sh` (automation)

---

**Version:** 1.0  
**Created:** 2026-01-31  
**Status:** ✅ Production Ready

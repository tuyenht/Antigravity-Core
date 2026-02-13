# {PROJECT_NAME} — Project Brief

> **Generated**: {DATE} | **Antigravity-Core**: v4.0.0

---

## 1. Business Context

| Field | Value |
|:------|:------|
| **Project Name** | {name} |
| **Type** | {type: SaaS / E-commerce / CMS / API / Mobile App / ...} |
| **Target Users** | {who uses this product} |
| **Business Model** | {how it makes money} |
| **Stage** | {Early Dev / MVP / Production / Maintenance} |

### Vision
{1-3 sentences: what is this product and why does it exist}

### Success Metrics
{how do we know this project succeeded — KPIs, targets, measurable outcomes}

---

## 2. Technical Stack

| Layer | Technology | Version |
|:------|:-----------|:--------|
| **Framework** | {e.g. Next.js, Laravel, FastAPI} | {x.x} |
| **Language** | {e.g. TypeScript, PHP, Python} | {x.x} |
| **UI** | {e.g. React, Vue, SwiftUI} | {x.x} |
| **Database** | {e.g. PostgreSQL, SQLite, MongoDB} | {x.x} |
| **Auth** | {e.g. Payload Auth, Auth.js, Firebase} | |
| **Deployment** | {e.g. Vercel, Docker, VPS} | |
| **Package Manager** | {e.g. pnpm, npm, composer} | |

---

## 3. Architecture Overview

```
{PROJECT_NAME}/
├── {directory tree with annotations}
│   ├── ...
│   └── ...
└── docs/
```

{Optional: data flow diagram, system diagram}

---

## 4. Data Model

| Entity/Collection | Key Fields | Access |
|:-------------------|:-----------|:-------|
| **{entity1}** | {fields} | {access rules} |
| **{entity2}** | {fields} | {access rules} |

{Include relationships, constraints, special patterns}

---

## 5. Current State & Maturity

### ✅ Completed
- {what's already built and working}

### ⬜ Not Started / Placeholder
- {what exists as stub or not yet implemented}

---

## 6. Technical Debt & Risks

| Priority | Issue | Location |
|:---------|:------|:---------|
| 🔴 HIGH | {critical issue} | {file:line} |
| 🟡 MEDIUM | {moderate issue} | {file} |
| 🟢 LOW | {minor issue} | {file} |

---

## 7. Recommended Next Steps (Priority Order)

1. **{emoji} {Title}** — {what to do}
2. **{emoji} {Title}** — {what to do}
3. ...

---

## 8. Milestones & Roadmap

| Phase | Milestone | Target | Status |
|-------|-----------|--------|--------|
| {phase} | {deliverable} | {timeframe} | ⬜ / 🔄 / ✅ |

---

> **Instructions for AI:**
> - Fill ALL sections by analyzing the actual codebase
> - Section 1: Extract from README, config files, package.json description
> - Section 2: Extract from config files (package.json, composer.json, etc.)
> - Section 3: Generate from actual directory structure
> - Section 4: Extract from schema files, ORM models, database configs
> - Section 5: Classify each feature as Done/Stub/NotStarted
> - Section 6: Identify anti-patterns, security issues, missing configs
> - Section 7: Prioritize by impact × effort
> - Section 8: Group Next Steps into logical milestones
> - Output location: `docs/PROJECT-BRIEF.md`

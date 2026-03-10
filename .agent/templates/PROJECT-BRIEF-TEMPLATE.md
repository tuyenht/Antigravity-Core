# PROJECT-BRIEF — {Project Name}

> **Version:** 1.0 | **Updated:** {date}
> <!-- antigravity-brief: v1.0 -->

---

## 1. Business Context

| Field | Value |
|-------|-------|
| **Project Name** | {name} |
| **Description** | {1-2 sentence overview} |
| **Target Users** | {primary audience} |
| **Business Goal** | {core value proposition} |
| **KPIs** | {measurable success metrics} |

---

## 2. Technical Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| **Language** | {TypeScript / PHP / Python / etc.} | {version} |
| **Framework** | {Next.js / Laravel / NestJS / etc.} | {version} |
| **Database** | {PostgreSQL / MySQL / MongoDB / etc.} | {version} |
| **ORM** | {Prisma / Eloquent / TypeORM / etc.} | {version} |
| **Auth** | {Auth.js / Laravel Auth / Passport / etc.} | {version} |
| **Build Tool** | {Turbopack / Vite / Webpack / etc.} | {version} |
| **Package Manager** | {pnpm / composer / pip / etc.} | {version} |
| **Infrastructure** | {Vercel / AWS / VPS / etc.} | — |

---

## 3. Architecture Overview

```
{project-name}/
├── src/             ← Source code
│   ├── app/         ← Routes / Pages
│   ├── components/  ← UI Components
│   ├── lib/         ← Utilities
│   └── ...
├── docs/            ← Project documentation
├── tests/           ← Test suites
└── ...
```

---

## 4. Data Model

### Entities

| Entity | Fields | Relationships |
|--------|--------|---------------|
| **User** | id, name, email, password, roleId | belongsTo Role |
| **Role** | id, name, permissions[] | hasMany User |
| {Entity} | {fields} | {relationships} |

### Database Schema

```sql
-- Key tables, indexes, constraints
-- Or reference: prisma/schema.prisma
```

---

## 5. Roles & Permissions

| Role | Permissions | Description |
|------|------------|-------------|
| {admin} | Full access | System administrator |
| {editor} | CRUD content | Content manager |
| {viewer} | Read only | Basic user |

---

## 6. Admin Configuration

| Config | Value |
|--------|-------|
| **Admin Prefix** | /{prefix}/dashboard |
| **Design System** | {Velzon / Custom / MUI / etc.} |
| **Auth Screens** | Login, Forgot, Reset, 2FA |

---

## 7. Internationalization (i18n)

| Config | Value |
|--------|-------|
| **Default Locale** | {vi / en / etc.} |
| **Supported Locales** | {vi, en, ja, etc.} |
| **Strategy** | {URL prefix / Cookie / Accept-Language} |

---

## 8. Deploy & Infrastructure

| Config | Value |
|--------|-------|
| **Deploy Target** | {Vercel / AWS / VPS / Docker / etc.} |
| **CI/CD** | {GitHub Actions / GitLab CI / etc.} |
| **Environments** | dev → staging → production |
| **Domain** | {domain.com} |

---

## 9. Current State & Maturity

| Area | Status | Notes |
|------|:------:|-------|
| Database Schema | ✅ / 🔄 / ⬜ | {notes} |
| Authentication | ✅ / 🔄 / ⬜ | {notes} |
| Admin Dashboard | ✅ / 🔄 / ⬜ | {notes} |
| CRUD Modules | ✅ / 🔄 / ⬜ | {notes} |
| Testing | ✅ / 🔄 / ⬜ | {notes} |
| CI/CD | ✅ / 🔄 / ⬜ | {notes} |
| Documentation | ✅ / 🔄 / ⬜ | {notes} |

Legend: ✅ Done | 🔄 In Progress | ⬜ Not Started

---

## 10. Technical Debt & Risks

| # | Issue | Severity | Recommended Action |
|---|-------|:--------:|-------------------|
| 1 | {issue} | 🔴 High | {action} |
| 2 | {issue} | 🟠 Medium | {action} |
| 3 | {issue} | 🟢 Low | {action} |

---

## 11. Next Steps

1. {Highest priority action}
2. {Second priority action}
3. {Third priority action}

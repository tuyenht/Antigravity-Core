# 🔍 Skill Discovery Guide

**Quick Reference:** Find the right skill for your task

---

## 📋 By Use Case

### "I need to optimize performance"

**Stack?**
- **React/Next.js** → `react-performance`
- **Laravel/PHP** → `laravel-performance`
- **Inertia.js (bridge)** → `inertia-performance`
- **Generic/profiling** → `performance-profiling`

**Priority:** Follow CRITICAL → HIGH → MEDIUM → LOW

---

### "I need to write tests"

**Philosophy & Overview:**
→ `testing-mastery/SKILL.md`

**Specific methodology:**
- **TDD workflow** → `testing-mastery/methodologies/tdd.md` (when created) or main SKILL.md
- **API contracts** → `testing-mastery/methodologies/contract-testing.md` or main SKILL.md
- **E2E/browser** → `testing-mastery/methodologies/webapp-testing.md` or main SKILL.md

**Current:** All content in `testing-mastery/SKILL.md`

---

### "I need to design an API"

**Architecture principles:**
→ `architecture-mastery/SKILL.md` (SOLID, layered architecture)

**API patterns:**
- **REST API** → `architecture-mastery/patterns/api-design.md` (when created) or main SKILL.md
- **GraphQL** → `architecture-mastery/patterns/graphql.md` or main SKILL.md
- **Microservices** → `architecture-mastery/patterns/microservices.md` or main SKILL.md

**Current:** All content in `architecture-mastery/SKILL.md`

---

### "I need to build a Laravel feature"

**Performance & conventions:**
→ `laravel-performance`

**Performance optimization:**
→ `laravel-performance` (N+1, indexes, caching)

**Inertia integration:**
→ `inertia-performance` (partial reloads, props)

---

### "I need to build a React component"

**Component patterns:**
→ `react-patterns` (hooks, composition, state)

**Performance optimization:**
→ `react-performance` (waterfalls, bundle, re-renders)

---

### "I need to deploy"

- **General deployment** → `deployment-procedures`
- **Docker** → `docker-expert`
- **Kubernetes** → `kubernetes-patterns`
- **IaC (Terraform)** → `terraform-iac`

---

### "I need to write clean code"

**Universal principles:**
→ `clean-code` (SOLID, DRY, KISS)

**Language-specific:**
- **TypeScript** → `typescript-expert`
- **Node.js** → `nodejs-best-practices`
- **Next.js** → `nextjs-best-practices`
- **Python** → `python-patterns`

---

## 🏗️ By Technology

### Frontend

| Technology | Skill |
|------------|-------|
| **React** | `react-patterns`, `react-performance` |
| **Next.js** | `nextjs-best-practices` |
| **Vue** | `vue-expert` |
| **TypeScript** | `typescript-expert` |
| **Tailwind CSS** | `tailwind-patterns` |
| **State Management** | `state-management` |
| **UI/UX** | `ui-ux-pro-max` |

---

### Backend

| Technology | Skill |
|------------|-------|
| **Laravel** | `laravel-performance`, `inertia-performance` |
| **Node.js** | `nodejs-best-practices` |
| **NestJS** | `nestjs-expert` |
| **Python** | `python-patterns` |
| **API Design** | `api-patterns` (or `architecture-mastery`) |
| **GraphQL** | `graphql-patterns` (or `architecture-mastery`) |

---

### Database

| Need | Skill |
|------|-------|
| **Schema design** | `database-design` |
| **NoSQL** | `nosql-patterns` |
| **Prisma ORM** | `prisma-expert` |
| **Vector/AI** | `vector-databases` |

---

### DevOps

| Technology | Skill |
|------------|-------|
| **Docker** | `docker-expert` |
| **Kubernetes** | `kubernetes-patterns` |
| **Terraform** | `terraform-iac` |
| **Cloudflare** | `cloudflare` |
| **Monitoring** | `monitoring-observability` |

---

### Testing

| Type | Skill |
|------|-------|
| **Overview/Principles** | `testing-mastery/SKILL.md` |
| **TDD workflow** | `testing-mastery` (has TDD section) |
| **Contract/API testing** | `testing-mastery` (has contract section) |
| **E2E/web app** | `testing-mastery` (has E2E section) |
| **Code review** | `code-review-checklist` |

---

### Security

| Need | Skill |
|------|-------|
| **Vulnerability scanning** | `vulnerability-scanner` |
| **Red team tactics** | `red-team-tactics` |

---

## 🎯 By Goal

### Optimize Performance

1. **Profile first** → `performance-profiling`
2. **Frontend optimization** → `react-performance`
3. **Backend optimization** → `laravel-performance`
4. **Bridge optimization** → `inertia-performance`

**Remember:** Fix CRITICAL before MEDIUM!

---

### Build New Feature

1. **Plan** → `plan-writing`
2. **Architecture** → `architecture-mastery`
3. **Backend** → `laravel-performance` or `nodejs-best-practices`
4. **Frontend** → `react-patterns`
5. **Tests** → `testing-mastery`

---

### Debug Issues

1. **Systematic approach** → `systematic-debugging`
2. **Laravel-specific** → Laravel Debugbar/Telescope
3. **React-specific** → React DevTools

---

### Improve Code Quality

1. **Clean code principles** → `clean-code`
2. **Linting** → `clean-code`
3. **Code review** → `code-review-checklist`

---

## 📚 Skill Categories

### Core Skills (Use Frequently)

- `clean-code` - Universal principles
- `testing-mastery` - All testing knowledge
- `architecture-mastery` - All architecture knowledge

---

### Stack Skills (Per Tech Stack)

**Laravel:**
- `laravel-performance`
- `inertia-performance`

**React:**
- `react-patterns`
- `react-performance`

**Node.js:**
- `nodejs-best-practices`

---

### Specialized Skills (As Needed)

- `ui-ux-pro-max` - Design system
- `seo-fundamentals` - SEO optimization
- `i18n-localization` - Internationalization
- `mcp-builder` - MCP servers

---

## 🔗 Consolidated Skills (New Structure)

**These skills replaced multiple old skills:**

### testing-mastery
**Replaces:** testing-patterns, tdd-workflow, contract-testing, webapp-testing  
**Use for:** All testing needs (unit, integration, E2E, TDD)

### architecture-mastery
**Replaces:** architecture, api-patterns, microservices-communication, graphql-patterns  
**Use for:** System design, API design, architecture patterns

---

## 💡 Tips

### Start Broad, Go Deep

1. **Start:** Read parent skill (e.g., `testing-mastery/SKILL.md`)
2. **Navigate:** Follow links to sub-files for deep dives
3. **Apply:** Use examples and patterns

### Use Search

```powershell
# Find skills mentioning "cache"
Get-ChildItem .agent\skills -Recurse -Filter "*.md" | Select-String "cache"

# Find skills with "performance"
Get-ChildItem .agent\skills -Directory | Where-Object Name -like "*performance*"
```

---

## 📖 Related Guides

- [Agent Selection Guide](./AGENT-SELECTION.md) - Which agent to use?
- [Architecture Decision Records](./adr/) - Why these decisions?

---

**Created:** 2026-01-19  
**Version:** 1.0  
**Purpose:** Fast skill discovery for agents and developers

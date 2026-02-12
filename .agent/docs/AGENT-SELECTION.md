# 🤖 Agent Selection Guide

**Quick Reference:** Which agent for which task?

---

## 🎯 By Task Type

### Development Tasks

| Task | Agent | Why |
|------|-------|-----|
| **Build Laravel feature** | `laravel-specialist` | Laravel expertise |
| **Build React component** | `frontend-specialist` | React/UI expertise |
| **Build API endpoint** | `backend-specialist` | API/server knowledge |
| **Generate CRUD boilerplate** | `code-generator-agent` | Auto-generation |
| **Design database schema** | `database-architect` | Schema design |

---

### Quality & Testing

| Task | Agent | Why |
|------|-------|-----|
| **Write tests** | `test-engineer` | Testing expertise |
| **Debug issue** | `debugger` | Systematic debugging |
| **Refactor code** | `refactor-agent` | Code improvement |
| **Security audit** | `security-auditor` | Security expertise |
| **Code review** | Multiple (use orchestrator) | Multi-aspect review |

---

### Performance

| Task | Agent | Why |
|------|-------|-----|
| **Optimize performance** | `performance-optimizer` | General optimization |
| **Laravel performance** | `backend-specialist` | Has laravel-performance skill |
| **React performance** | `frontend-specialist` | Has react-performance skill |

---

### Deployment & DevOps

| Task | Agent | Why |
|------|-------|-----|
| **Deploy application** | `devops-engineer` | Deployment expertise |
| **Setup CI/CD** | `devops-engineer` | Pipeline knowledge |
| **Docker/K8s** | `devops-engineer` | Container expertise |

---

### Documentation

| Task | Agent | Why |
|------|-------|-----|
| **Write docs** | `documentation-writer` | Documentation focus |
| **Generate API docs** | `documentation-agent` | Auto-generation |

---

### Planning & Management

| Task | Agent | Why |
|------|-------|-----|
| **Plan project** | `project-planner` | Planning expertise |
| **Coordinate tasks** | `orchestrator` | Multi-agent coordination |
| **Route request** | `triage-agent` | Intelligent routing |

---

## 🏗️ By Domain

### Frontend

| Scenario | Agent |
|----------|-------|
| React development | `frontend-specialist` |
| Mobile app (React Native) | `mobile-developer` |
| UI/UX design | `frontend-specialist` (uses ui-ux-pro-max skill) |
| Performance optimization | `frontend-specialist` (uses react-performance) |

---

### Backend

| Scenario | Agent |
|----------|-------|
| Laravel backend | `laravel-specialist` or `backend-specialist` |
| Node.js backend | `backend-specialist` |
| Python backend | `backend-specialist` |
| Database work | `database-architect` |

---

### Full-Stack

| Scenario | Agent |
|----------|-------|
| Laravel + Inertia + React | `orchestrator` → routes to laravel + frontend |
| Build complete feature | `orchestrator` |
| Multi-layer refactoring | `orchestrator` |

---

## 📊 By Complexity

### Simple (Single Agent)

**Characteristics:**
- One clear task
- Single domain
- No dependencies

**Examples:**
```
"Add loading spinner to button" → frontend-specialist
"Create User model" → laravel-specialist
"Write test for login" → test-engineer
"Fix typo in README" → documentation-writer
```

---

### Medium (Orchestrator)

**Characteristics:**
- 2-3 related tasks
- May span domains
- Some dependencies

**Examples:**
```
"Build user profile page" 
→ orchestrator coordinates:
  - laravel-specialist (backend)
  - frontend-specialist (UI)
  - test-engineer (tests)

"Optimize checkout flow"
→ orchestrator coordinates:
  - performance-optimizer (analysis)
  - backend-specialist (API)
  - frontend-specialist (UI)
```

---

### Complex (Triage + Orchestrator)

**Characteristics:**
- 4+ tasks
- Multiple domains
- Heavy dependencies
- Ambiguous requirements

**Examples:**
```
"Build e-commerce platform"
→ triage-agent analyzes
→ project-planner creates plan
→ orchestrator executes phases

"The app is slow and broken"
→ triage-agent clarifies
→ debugger fixes bugs
→ performance-optimizer optimizes
```

---

## 🔀 Decision Flowchart

```
User Request
    ↓
Is it clear?
    ├─ YES → Is it single domain?
    │         ├─ YES → Direct to specialist
    │         └─ NO → Use orchestrator
    │
    └─ NO → triage-agent clarifies
              ↓
         Analyze complexity
              ↓
         Route appropriately
```

---

## 🎯 Common Patterns

### Pattern 1: "Fix X"

```
"Fix login bug" → debugger
"Fix broken tests" → test-engineer
"Fix deployment" → devops-engineer
"Fix security issue" → security-auditor
```

**Rule:** "Fix" + domain → domain specialist

---

### Pattern 2: "Build X"

```
"Build API" → backend-specialist
"Build component" → frontend-specialist
"Build dashboard" → orchestrator (backend + frontend)
```

**Rule:** "Build" alone → clarify scope, may need orchestrator

---

### Pattern 3: "Optimize X"

```
"Optimize performance" → performance-optimizer
"Optimize React" → frontend-specialist (has react-performance)
"Optimize Laravel" → backend-specialist (has laravel-performance)
```

**Rule:** "Optimize" + tech → tech specialist with performance skill

---

### Pattern 4: "Generate X"

```
"Generate CRUD" → code-generator-agent
"Generate tests" → test-engineer or code-generator
"Generate docs" → documentation-agent
```

**Rule:** "Generate" → code-generator-agent first

---

## 🆕 Special Agents

### triage-agent (New!)

**When to use:**
- Multi-task requests
- Ambiguous requests
- Don't know which agent

**Auto-triggers on:**
- "Fix X and add Y"
- "The app is broken" (vague)
- Multiple domains detected

**Example:**
```
User: "Fix login bug and add dark mode"

triage-agent:
- Task 1: Fix login → @debugger
- Task 2: Dark mode → @frontend-specialist
- Routing: @orchestrator (parallel)
```

---

### code-generator-agent (New!)

**When to use:**
- Generate boilerplate
- Create CRUD
- Scaffold components

**Auto-triggers on:**
- "Generate CRUD for [Model]"
- "Create [Component] component"
- "Scaffold [Feature]"

**Example:**
```
User: "Generate CRUD for Product"

code-generator-agent creates:
- Model
- Controller
- Validation
- Tests (80%+ coverage)
- All .agent/rules/STANDARDS.md compliant
```

---

## 📋 Agent Reference Table

| Agent | Domain | Complexity | Auto-Routes? |
|-------|--------|------------|--------------|
| `triage-agent` | Routing | Any | N/A (is router) |
| `orchestrator` | Coordination | Medium-Complex | No |
| `frontend-specialist` | UI/React | Simple-Medium | Yes |
| `backend-specialist` | API/Server | Simple-Medium | Yes |
| `laravel-specialist` | Laravel | Simple-Medium | Yes |
| `database-architect` | Database | Simple-Medium | Yes |
| `code-generator-agent` | Generation | Simple | Yes |
| `test-engineer` | Testing | Simple-Medium | Yes |
| `debugger` | Debugging | Simple-Medium | Yes |
| `refactor-agent` | Refactoring | Simple-Medium | Yes |
| `performance-optimizer` | Performance | Medium | Yes |
| `security-auditor` | Security | Medium | Yes |
| `devops-engineer` | DevOps | Medium | Yes |
| `documentation-writer` | Docs | Simple | Yes |

---

## 💡 Tips

### Tip 1: Use triage-agent When Unsure

**Instead of guessing:**
```
❌ "Which agent should I use for this complex task?"
```

**Let triage decide:**
```
✅ Just describe the task, triage-agent will route
```

---

### Tip 2: Orchestrator for Cross-Domain

**Multi-domain work:**
```
Frontend + Backend + Database → orchestrator
```

**Single domain:**
```
Only React → frontend-specialist
Only Laravel → laravel-specialist
```

---

### Tip 3: Generator for Boilerplate

**Manual CRUD:**
```
❌ Create model, controller, tests manually (1 hour)
```

**Auto-generated:**
```
✅ code-generator-agent creates all (2 minutes)
```

---

## 🔗 Related Guides

- [Skill Discovery Guide](./SKILL-DISCOVERY.md) - Which skill for which task?
- [Architecture Decision Records](./adr/) - Why these decisions?

---

**Created:** 2026-01-19  
**Version:** 1.0  
**Purpose:** Fast agent selection for users and triage-agent

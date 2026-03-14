# 🤝 Agent Coordination Protocol

**Version:** 5.0.1  
**Purpose:** Resolve agent overlaps and conflicts  
**Last Updated:** 2026-03-01

> [!NOTE]
> For quick agent lookup by task/extension, see `agents/CAPABILITY-MATRIX.md`.
> This file covers **coordination protocols** and **execution patterns**.

## Table of Contents

1. [Problem Statement](#-problem-statement)
2. [Orchestrator Pattern](#️-orchestrator-pattern-solution)
3. [Coordination Workflow](#-coordination-workflow)
4. [Agent Responsibility Matrix](#-agent-responsibility-matrix)
5. [Execution Patterns](#-execution-patterns)
6. [Conflict Resolution Rules](#-conflict-resolution-rules)
7. [File Write Coordination](#-file-write-coordination)
8. [Common Scenarios](#-common-scenarios)
9. [Orchestrator Decision Logic](#-orchestrator-decision-logic)
10. [Orchestrator Responsibilities](#-orchestrator-agent-responsibilities)
11. [Best Practices](#-best-practices)
12. [Troubleshooting](#-troubleshooting)
13. [Coordination Metrics](#-coordination-metrics-future)

---

## 🎯 PROBLEM STATEMENT

With **27 agents** in the system, overlaps occur:

**Example:** "Optimize API performance"
- `performance-optimizer` (analyzes performance)
- `backend-specialist` (implements optimizations)
- `database-architect` (database-level optimizations)

**Question:** Which agent handles what?

---

## 🏗️ ORCHESTRATOR PATTERN (Solution)

### Core Principle:
**🎭 Orchestrator is the "Director" - assigns roles to actors (agents)**

```
User Request → Orchestrator → Analyze → Assign Agents → Execute → Validate
```

---

## 📋 COORDINATION WORKFLOW

### Step 1: USER REQUEST

```
User: "Optimize API Performance"
```

### Step 2: ORCHESTRATOR ANALYZES

```yaml
orchestrator_reasoning:  
  request_type: "Performance optimization"
  scope: "API + potential database"
  complexity: "Medium-High"
  
  required_expertise:
    - Performance analysis
    - Backend implementation
    - Database optimization (conditional)
```

### Step 3: ORCHESTRATOR ASSIGNS

```yaml
execution_plan:
  lead_agent: "performance-optimizer"
  role: "Analyze, identify bottlenecks, create optimization plan"
  
  supporting_agents:
    - agent: "backend-specialist"
      condition: "IF bottleneck in application code"
      role: "Implement application-level optimizations"
    
    - agent: "database-architect"
      condition: "IF bottleneck in database queries"
      role: "Optimize database queries/schema"
  
  execution_order: "Sequential"  # or "Parallel" if independent
```

### Step 4: AGENTS EXECUTE

```yaml
# Performance-optimizer runs first
performance_optimizer:
  output: |
    Bottleneck identified:
    1. N+1 query in /api/users endpoint (DATABASE)
    2. No caching on repeated requests (APPLICATION)
  
  recommendation:
    - database_architect: Fix N+1 query
    - backend_specialist: Add caching layer

# Orchestrator triggers next agents
database_architect:
  action: "Add eager loading to User query"
  
backend_specialist:
  action: "Implement Redis caching for /api/users"
```

### Step 5: VALIDATION

```yaml
# AOC (Auto-Optimization Cycle) validates
aoc_validation:
  self_correction: "Lint/test pass"
  performance: "Endpoint now <200ms (was 800ms)"
  status: "PASS"
```

---

## 📊 AGENT RESPONSIBILITY MATRIX

| Request Type | Lead Agent | Supporting Agents | Pattern |
|--------------|-----------|-------------------|---------|
| **New Feature** | project-planner | database-architect, backend-specialist, frontend-specialist, test-engineer | Sequential |
| **Security Audit** | ai-code-reviewer | security-auditor, penetration-tester | Sequential |
| **Bug Fix** | debugger | test-engineer | Sequential |
| **Refactoring** | ai-code-reviewer | refactor-agent, test-engineer | Sequential |
| **Code Review** | ai-code-reviewer | security-auditor, performance-optimizer | Parallel |
| **Database Change** | database-architect | backend-specialist, test-engineer | Sequential |
| **Deploy** | test-engineer | security-auditor, devops-engineer, manager-agent | Sequential |
| **API Performance** | performance-optimizer | backend-specialist, database-architect | Conditional |
| **UI Design** | frontend-specialist | mobile-developer (if mobile) | Sequential |

> **Source of truth:** Pipeline definitions are maintained in [orchestration-engine.md](orchestration-engine.md) templates. This matrix is a simplified coordination reference.

---

## 🔀 EXECUTION PATTERNS

### Pattern 1: SEQUENTIAL (Default)

**When:** Tasks depend on each other

```
Agent 1 → Output → Agent 2 → Output → Agent 3
```

**Example:** Database migration
```
database-architect: Create migration
  ↓
backend-specialist: Update models
  ↓
test-engineer: Write tests
```

---

### Pattern 2: PARALLEL

**When:** Tasks independent

```
      ┌─→ Agent 1 → Output
Start ├─→ Agent 2 → Output → Merge
      └─→ Agent 3 → Output
```

**Example:** Full-stack feature
```
Orchestrator
  ├─→ backend-specialist: Create API
  └─→ frontend-specialist: Create UI
      ↓
  Merge: Integration test
```

---

### Pattern 3: CONDITIONAL

**When:** Agent needed only if condition met

```
Agent 1 → Decision
  ├─→ IF condition A → Agent 2
  └─→ IF condition B → Agent 3
```

**Example:** Performance optimization
```
performance-optimizer: Analyze
  ├─→ IF DB slowdown → database-architect
  ├─→ IF app slowdown → backend-specialist
  └─→ IF frontend slow → frontend-specialist
```

---

## 🚦 CONFLICT RESOLUTION RULES

### Rule 1: Orchestrator Decides

**If agents overlap:**
- Orchestrator assigns primary responsibility
- Other agents support only

```yaml
# Example: Both agents want to handle API
performance_optimizer: "I analyze performance"
backend_specialist: "I build APIs"

orchestrator_decision:
  lead: "performance_optimizer"  # Analysis first
  support: "backend_specialist"  # Implementation second
```

---

### Rule 2: Expertise Wins

**Agent with highest expertise in requested domain leads**

```yaml
# Example: Laravel-specific task
backend_specialist:
  expertise: "General backend"
  
laravel_specialist:
  expertise: "Laravel expert"

orchestrator_decision:
  lead: "laravel_specialist"  # More specialized
```

---

### Rule 3: User Can Override

**User's explicit choice overrides orchestrator**

```
User: "Use backend-specialist for this performance fix"
  ↓
Orchestrator: "OK, assigning backend-specialist (user override)"
```

---

## 📝 FILE WRITE COORDINATION

### Problem: 2 Agents Edit Same File

**Scenario:**
- `documentation-writer`: Updates README.md (installation)
- `backend-specialist`: Updates README.md (API docs)

### Solution: Orchestrator Sequences

```yaml
orchestrator_plan:
  file: "README.md"
  
  edit_sequence:
    1. documentation_writer: Update installation section
    2. backend_specialist: Update API docs section
  
  execution: "Sequential (no parallel edits)"
```

---

### File Lock (Future Enhancement)

```yaml
# Conceptual (not implemented yet)
file_lock:
  file: "README.md"
  locked_by: "documentation_writer"
  status: "LOCKED"
  
  # Other agents wait or escalate
```

---

## 🎯 COMMON SCENARIOS

### Scenario 1: "Build User Authentication"

```yaml
orchestrator_analysis:
  scope: "Backend API + Frontend UI + Security"
  complexity: "High"
  
execution_plan:
  phase_1:
    lead: "security-auditor"
    task: "Define security requirements (JWT vs Session?)"
  
  phase_2_parallel:
    - agent: "backend-specialist"
      task: "Build auth API (/login, /register, /logout)"
    - agent: "frontend-specialist"
      task: "Build auth UI (forms, validation)"
  
  phase_3:
    lead: "test-engineer"
    task: "Integration tests (auth flow)"
  
  phase_4:
    lead: "manager-agent"
    task: "AOC cycle (validate all)"
```

---

### Scenario 2: "Fix Slow Endpoint"

```yaml
orchestrator_analysis:
  scope: "Performance issue"
  lead_agent: "performance-optimizer"
  
execution_plan:
  step_1:
    agent: "performance_optimizer"
    task: "Profile endpoint, identify bottleneck"
  
  step_2_conditional:
    if_db_slow:
      agent: "database-architect"
      task: "Optimize queries, add indexes"
    
    if_app_slow:
      agent: "backend-specialist"
      task: "Add caching, optimize algorithm"
  
  step_3:
    agent: "test-engineer"
    task: "Performance benchmark (verify <200ms)"
```

---

### Scenario 3: "Refactor Legacy Code"

```yaml
orchestrator_analysis:
  scope: "Code quality + Testing"
  complexity: "Medium"
  
execution_plan:
  step_1:
    agent: "ai-code-reviewer"
    task: "Review existing code, identify issues and plan refactoring"
  
  step_2:
    agent: "backend-specialist"  # or frontend-specialist
    task: "Refactor code (project quality standards compliant)"
  
  step_3:
    agent: "test-engineer"
    task: "Write tests (80% coverage)"
  
  step_4:
    agent: "refactor-agent"
    task: "Review refactor quality, suggest improvements"
```

---

## 🔧 ORCHESTRATOR DECISION LOGIC

### Input Analysis:

```typescript
function analyzeRequest(userRequest: string) {
  return {
    keywords: extractKeywords(userRequest),
    domain: identifyDomain(keywords),  // backend, frontend, devops, etc.
    complexity: assessComplexity(userRequest),
    scope: identifyScope(userRequest)  // single file, module, full stack
  }
}
```

### Agent Selection:

```typescript
function selectAgents(analysis) {
  const leadAgent = findExpertAgent(analysis.domain);
  const supportingAgents = findSupportingAgents(analysis.scope);
  
  return {
    lead: leadAgent,
    supporting: supportingAgents,
    execution: determineExecutionPattern(analysis.complexity)
  };
}
```

---

## 📖 ORCHESTRATOR AGENT RESPONSIBILITIES

**The orchestrator agent MUST:**

1. ✅ Analyze user request
2. ✅ Identify required expertise
3. ✅ Assign lead agent
4. ✅ Determine supporting agents
5. ✅ Define execution order (sequential/parallel)
6. ✅ Handle file write conflicts
7. ✅ Escalate to user if unclear
8. ✅ Validate final output (via AOC)

**The orchestrator NEVER:**

❌ Implements code itself  
❌ Makes technical decisions (delegates to experts)  
❌ Overrides project quality standards  

---

## 🎓 BEST PRACTICES

### For Orchestrator:

1. **Be Explicit** - Clear assignments, no ambiguity
2. **Document Reasoning** - Why this agent for this task?
3. **Sequence Carefully** - Dependencies matter
4. **Escalate When Unclear** - Ask user if multiple valid approaches

### For Specialist Agents:

1. **Respect Assignments** - If not lead, provide support only
2. **Communicate Handoffs** - "Passing to database-architect for query optimization"
3. **Report Conflicts** - "This overlaps with security-auditor's scope"
4. **Follow RBA** - Reasoning-Before-Action always

---

## 🆘 TROUBLESHOOTING

**Q: Orchestrator assigned wrong agent?**  
A: User can override: "Use [agent-name] instead"

**Q: Agents conflict during execution?**  
A: Orchestrator re-sequences or asks user to pick

**Q: File edited by 2 agents simultaneously?**  
A: Sequential execution prevents this (future: file locks)

**Q: Orchestrator unclear which agent?**  
A: Escalates to user: "Should backend-specialist or laravel-specialist handle this?"

---

## 📊 COORDINATION METRICS (Future)

Track coordination efficiency:

```json
// .agent/memory/metrics/coordination-metrics.json
{
  "agent_conflicts_resolved": 12,
  "orchestrator_escalations": 3,
  "avg_agents_per_task": 2.4,
  "sequential_executions": 45,
  "parallel_executions": 12,
  "file_conflicts_prevented": 8
}
```

---

## 🔗 RELATED DOCUMENTATION

- [orchestrator.md](../agents/orchestrator.md) — Orchestrator agent definition
- [agent-registry.md](agent-registry.md) — Machine-readable registry of all 27 agents
- [orchestration-engine.md](orchestration-engine.md) — Automated agent selection and pipeline execution
- [auto-rule-discovery.md](auto-rule-discovery.md) — Intelligent rule loading engine
- [rba-validator.md](rba-validator.md) — Reasoning-Before-Action protocol
- [CAPABILITY-MATRIX.md](../agents/CAPABILITY-MATRIX.md) — Quick agent lookup by task/extension

---

**Created:** 2026-01-17  
**Updated:** 2026-03-01  
**Version:** 5.0.1  
**Purpose:** Define how 27 agents coordinate without conflicts

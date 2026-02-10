# 🎯 Agent Orchestration Engine

> **Version:** 1.0.0 | **Updated:** 2026-02-10  
> **Purpose:** Automated agent selection, pipeline execution, and conflict resolution  
> **Priority:** P0 — Core system, read by orchestrator agent  
> **Dependencies:** `auto-rule-discovery.md`, `agent-registry.md`

---

## Overview

The Orchestration Engine **automates the entire agent lifecycle**: analyzing requests, selecting agents, resolving conflicts, executing pipelines, and synthesizing results. It replaces the manual orchestrator routing tables with an intelligent, context-aware system.

```
┌─────────────────────────────────────────────────────────────────┐
│               AGENT ORCHESTRATION ENGINE                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  User Request                                                    │
│      │                                                           │
│      ▼                                                           │
│  ┌──────────────────────────┐                                    │
│  │ 1. CONTEXT ANALYSIS      │                                    │
│  │    • Domain detection     │                                    │
│  │    • Complexity scoring   │                                    │
│  │    • Scope identification │                                    │
│  └──────────┬───────────────┘                                    │
│             ▼                                                    │
│  ┌──────────────────────────┐  ┌────────────────────────┐        │
│  │ 2. RULE DISCOVERY        │←─│ auto-rule-discovery.md │        │
│  │    • 3-layer scan         │  └────────────────────────┘        │
│  │    • Dependency resolve   │                                    │
│  └──────────┬───────────────┘                                    │
│             ▼                                                    │
│  ┌──────────────────────────┐  ┌────────────────────────┐        │
│  │ 3. AGENT SELECTION       │←─│ agent-registry.md      │        │
│  │    • Score & rank         │  └────────────────────────┘        │
│  │    • Conflict resolution  │                                    │
│  └──────────┬───────────────┘                                    │
│             ▼                                                    │
│  ┌──────────────────────────┐                                    │
│  │ 4. PIPELINE EXECUTION    │                                    │
│  │    • Sequential/Parallel  │                                    │
│  │    • Conditional branching│                                    │
│  └──────────┬───────────────┘                                    │
│             ▼                                                    │
│  ┌──────────────────────────┐                                    │
│  │ 5. SYNTHESIS & REPORT    │                                    │
│  │    • Merge results        │                                    │
│  │    • Quality gate         │                                    │
│  └──────────────────────────┘                                    │
│                                                                  │
│  OUTPUT: Coordinated execution with unified deliverables         │
└─────────────────────────────────────────────────────────────────┘
```

---

## Step 1: Context Analysis

```yaml
# Analyze every incoming request before agent selection
context_analysis:
  domain_detection:
    method: "Keyword + file pattern matching against agent-registry"
    outputs:
      - primary_domain: "backend | frontend | mobile | database | devops | security | testing"
      - secondary_domains: []  # Supporting domains involved
      - project_type: "laravel | nextjs | python | mobile | fullstack"

  complexity_scoring:
    scale: 1-10
    factors:
      - files_affected: "1 file = 2, 2-5 files = 5, 6+ files = 8"
      - domains_involved: "1 domain = 2, 2 domains = 5, 3+ = 8"
      - breaking_potential: "No breaking = 1, Possible = 5, Certain = 8"
      - novelty: "Pattern exists = 2, New pattern = 6, Research needed = 9"
    formula: "AVG(files_affected, domains_involved, breaking_potential, novelty)"

  scope_identification:
    single_file: "Complexity 1-3, single domain"
    feature: "Complexity 4-6, 1-2 domains"
    multi_module: "Complexity 7-8, 2-3 domains"
    system_wide: "Complexity 9-10, 3+ domains"
```

---

## Step 2: Rule Discovery

```yaml
# Delegate to auto-rule-discovery.md
rule_discovery:
  trigger: "After context analysis completes"
  system: "auto-rule-discovery.md"
  inputs:
    - active_file: "Currently open file"
    - open_files: "All open tabs"
    - project_root: "Workspace root"
    - user_request: "Original request text"
    - scope: "From context analysis"
  outputs:
    - discovered_rules: "Prioritized rule list"
    - rule_dependencies: "Resolved dependency chain"
    - tech_stack: "Detected technologies"
```

---

## Step 3: Agent Selection

```yaml
# Delegate to agent-registry.md for scoring, then resolve conflicts
agent_selection:
  trigger: "After rule discovery"
  system: "agent-registry.md → selectAgents algorithm"
  inputs:
    - request: "User request text"
    - context: "From step 1"
    - rules: "From step 2"

  # See agent-registry.md for full scoring formula and pseudocode
  outputs:
    primary_agent: "Single lead agent"
    supporting_agents: "0-3 supporting agents"
    execution_pattern: "sequential | parallel | conditional"
```

### Conflict Resolution Protocol

```yaml
# When two or more agents conflict
conflict_resolution:
  # Rule 1: Domain-specific agent wins over generalist
  domain_priority:
    example: "Laravel project → laravel-specialist wins over backend-specialist"
    logic: "Agent with narrower domain scope gets +5 priority boost"

  # Rule 2: Mutual exclusions
  mutual_exclusions:
    - [frontend-specialist, mobile-developer]
      resolution: "Check project type → web = frontend, mobile = mobile-developer"
    
  # Rule 3: Same-file editing
  file_contention:
    protocol: "Sequential execution — first agent edits, second agent gets updated version"
    priority: "Lead agent edits first, supporting agents follow"

  # Rule 4: User override
  override:
    protocol: "User can always specify agent: 'Use backend-specialist for this'"
    priority: "User override = infinity score"
```

---

## Step 4: Pipeline Execution

### Execution Patterns

```yaml
# Pattern 1: SEQUENTIAL (most common)
sequential:
  when: "Tasks have dependencies, files overlap"
  flow: "Agent A → Agent B → Agent C"
  example:
    name: "New API endpoint"
    steps:
      1: { agent: backend-specialist, task: "Create controller + service" }
      2: { agent: database-architect, task: "Create migration + model" }
      3: { agent: test-engineer, task: "Write tests for new endpoint" }

# Pattern 2: PARALLEL
parallel:
  when: "Tasks are independent, no file conflicts"
  flow: "Agent A ‖ Agent B → merge"
  example:
    name: "Full-stack feature"
    steps:
      parallel:
        - { agent: backend-specialist, task: "Create API endpoint" }
        - { agent: frontend-specialist, task: "Create UI component" }
      sequential:
        - { agent: test-engineer, task: "Integration tests" }

# Pattern 3: CONDITIONAL
conditional:
  when: "Next step depends on previous result"
  flow: "Agent A → if X then Agent B, else Agent C"
  example:
    name: "Performance optimization"
    steps:
      1: { agent: performance-optimizer, task: "Profile and identify bottleneck" }
      2_if_db: { agent: database-architect, task: "Optimize queries" }
      2_if_app: { agent: backend-specialist, task: "Optimize code" }
      2_if_frontend: { agent: frontend-specialist, task: "Optimize rendering" }
```

### Pipeline Templates

```yaml
# Pre-built pipelines for common tasks
templates:
  new_feature:
    description: "Build a new feature end-to-end"
    agents: [project-planner, backend-specialist, frontend-specialist, test-engineer]
    pattern: sequential
    steps:
      1: { agent: project-planner, task: "Create implementation plan" }
      2: { agent: backend-specialist, task: "Implement API layer" }
      3: { agent: frontend-specialist, task: "Implement UI layer" }
      4: { agent: test-engineer, task: "Write unit + integration tests" }

  bug_fix:
    description: "Investigate and fix a bug"
    agents: [debugger, test-engineer]
    pattern: sequential
    steps:
      1: { agent: debugger, task: "Root cause analysis + fix" }
      2: { agent: test-engineer, task: "Write regression test" }

  refactor:
    description: "Refactor existing code"
    agents: [ai-code-reviewer, refactor-agent, test-engineer]
    pattern: sequential
    steps:
      1: { agent: ai-code-reviewer, task: "Identify issues and plan" }
      2: { agent: refactor-agent, task: "Execute refactoring" }
      3: { agent: test-engineer, task: "Verify no regressions" }

  security_audit:
    description: "Comprehensive security review"
    agents: [security-auditor, penetration-tester]
    pattern: sequential
    steps:
      1: { agent: security-auditor, task: "Defensive review + vulnerability scan" }
      2: { agent: penetration-tester, task: "Offensive testing + exploit verification" }

  code_review:
    description: "Thorough code review"
    agents: [ai-code-reviewer, security-auditor, performance-optimizer]
    pattern: parallel
    steps:
      parallel:
        - { agent: ai-code-reviewer, task: "Code quality review" }
        - { agent: security-auditor, task: "Security review" }
        - { agent: performance-optimizer, task: "Performance review" }
      merge: "Synthesize findings into unified report"

  database_change:
    description: "Schema migration or query optimization"
    agents: [database-architect, backend-specialist, test-engineer]
    pattern: sequential
    steps:
      1: { agent: database-architect, task: "Design schema + migration" }
      2: { agent: backend-specialist, task: "Update models and queries" }
      3: { agent: test-engineer, task: "Test data integrity" }

  deployment:
    description: "Deploy to production"
    agents: [devops-engineer, security-auditor, manager-agent]
    pattern: sequential
    steps:
      1: { agent: security-auditor, task: "Pre-deployment security check" }
      2: { agent: devops-engineer, task: "Execute deployment" }
      3: { agent: manager-agent, task: "Post-deployment verification" }
```

---

## Step 5: Synthesis & Report

```yaml
synthesis:
  after_execution:
    1_merge: "Combine all agent outputs into unified deliverable"
    2_validate: "Cross-check outputs for conflicts/inconsistencies"
    3_quality_gate:
      checks:
        - "All requested changes implemented"
        - "No inter-agent file conflicts"
        - "Tests pass (if test-engineer was involved)"
        - "Security concerns addressed (if security-auditor was involved)"
    4_report:
      format: |
        ## Orchestration Report
        
        **Primary Agent:** {primary_agent}
        **Supporting Agents:** {supporting_agents}
        **Pattern:** {execution_pattern}
        **Rules Loaded:** {n} rules from {categories} categories
        
        ### Execution Summary
        | Step | Agent | Status | Duration |
        |------|-------|--------|----------|
        | 1 | ... | ✅ | ... |
        
        ### Deliverables
        - Files created/modified
        - Tests written
        - Documentation updated
```

---

## Quick Decision Tree

```
User Request
    │
    ├─ "fix/debug/error" ──────→ debugger (+ test-engineer)
    ├─ "build/create/implement" ─→ Domain agent + test-engineer
    ├─ "refactor/cleanup" ─────→ refactor-agent + ai-code-reviewer
    ├─ "review/audit" ─────────→ ai-code-reviewer + security-auditor
    ├─ "optimize/performance" ──→ performance-optimizer + domain agent
    ├─ "deploy/ci-cd" ─────────→ devops-engineer + security-auditor
    ├─ "test/coverage" ────────→ test-engineer/test-generator
    ├─ "plan/design" ──────────→ project-planner
    ├─ "complex multi-domain" ──→ orchestrator (full pipeline)
    └─ "unclear/vague" ────────→ triage-agent → re-route
```

---

## Integration with Existing Systems

```yaml
backwards_compatibility:
  # All existing flows continue to work
  manual_routing: "orchestrator.md routing tables remain valid as fallback"
  agent_coordination: "agent-coordination.md patterns still apply"
  rba_protocol: "rba-validator.md still required before execution"

  # New engine is an ADD-ON, not a replacement
  priority_order:
    1: "User explicitly names an agent → use that agent"
    2: "Orchestration Engine auto-selects → use engine"
    3: "Orchestrator manual routing → fallback"

  # Graceful degradation
  if_engine_fails: "Fall back to orchestrator.md manual routing"
```

---

**Version:** 1.0.0  
**System:** Antigravity-Core v4.0  
**Created:** 2026-02-10

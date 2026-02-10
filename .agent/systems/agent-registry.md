# 🤖 Agent Registry

> **Version:** 1.0.0 | **Updated:** 2026-02-10  
> **Purpose:** Machine-readable capability registry for all 27 agents  
> **Priority:** P0 — Required by Orchestration Engine

---

## Overview

The Agent Registry is the **single source of truth** for agent capabilities. The Orchestration Engine queries this registry to automatically select the best agent(s) for any given task.

---

## Registry Format

```yaml
# Each agent entry follows this schema:
agent_schema:
  name: string           # Agent identifier (filename without .md)
  display_name: string   # Human-readable name
  category: enum         # core_dev | quality | security | architecture | operations | specialized | automation | documentation
  domain: string[]       # Primary expertise domains
  triggers:              # When this agent should activate
    keywords: string[]   # Request keyword triggers
    file_patterns: string[]  # File path patterns
    contexts: string[]   # Situational triggers
  skills: string[]       # Linked skill modules
  rules: string[]        # Recommended rule files
  exclusions: string[]   # Files/domains this agent MUST NOT touch
  works_with: string[]   # Complementary agents
  conflicts_with: string[]  # Mutually exclusive agents
  priority: number       # Selection priority (1=highest)
  complexity_range: [min, max]  # Task complexity this agent handles (1-10)
```

---

## Agent Entries

### Core Development Agents

```yaml
backend-specialist:
  display_name: "Backend Specialist"
  category: core_dev
  domain: [backend, api, server, authentication, authorization]
  triggers:
    keywords: [api, endpoint, controller, middleware, auth, server, backend, route]
    file_patterns: ["src/server/**", "src/api/**", "routes/**", "controllers/**", "app/Http/**"]
    contexts: [api_error, server_crash, new_endpoint]
  skills: [nodejs-best-practices, nestjs-expert, laravel-performance, api-patterns]
  rules: [backend-frameworks/*, agentic-ai/api-design.md]
  exclusions: ["*.tsx", "*.vue", "*.css", "*.html", "tests/**"]
  works_with: [database-architect, test-engineer, frontend-specialist]
  conflicts_with: []
  priority: 2
  complexity_range: [3, 10]

frontend-specialist:
  display_name: "Frontend Specialist"
  category: core_dev
  domain: [frontend, ui, ux, css, react, vue, components, design]
  triggers:
    keywords: [ui, component, page, layout, style, responsive, css, react, vue, frontend]
    file_patterns: ["src/components/**", "src/pages/**", "resources/js/**", "*.tsx", "*.vue", "*.css"]
    contexts: [ui_bug, new_page, design_review, layout_issue]
  skills: [react-patterns, react-performance, vue-expert, tailwind-patterns, frontend-design, ui-ux-pro-max]
  rules: [frontend-frameworks/*, typescript/*, web-development/*]
  exclusions: ["*.php", "*.py", "migrations/**", "database/**"]
  works_with: [backend-specialist, test-engineer, seo-specialist]
  conflicts_with: [mobile-developer]
  priority: 2
  complexity_range: [2, 10]

laravel-specialist:
  display_name: "Laravel Specialist"
  category: core_dev
  domain: [laravel, php, eloquent, blade, inertia, artisan]
  triggers:
    keywords: [laravel, eloquent, artisan, blade, migration, model, livewire, inertia]
    file_patterns: ["app/**/*.php", "routes/*.php", "database/**", "config/*.php", "composer.json"]
    contexts: [laravel_project, php_error, artisan_command]
  skills: [laravel-performance, inertia-performance]
  rules: [backend-frameworks/laravel.md]
  exclusions: ["*.tsx", "*.vue", "node_modules/**"]
  works_with: [database-architect, frontend-specialist, test-engineer]
  conflicts_with: []
  priority: 1
  complexity_range: [2, 10]

mobile-developer:
  display_name: "Mobile Developer"
  category: core_dev
  domain: [mobile, ios, android, react-native, flutter, expo]
  triggers:
    keywords: [mobile, ios, android, react native, flutter, expo, app store, play store]
    file_patterns: ["*.swift", "*.kt", "*.dart", "ios/**", "android/**", "App.tsx"]
    contexts: [mobile_project, app_crash, native_module]
  skills: [mobile-design, game-development]
  rules: [mobile/*]
  exclusions: ["*.php", "server/**", "api/**"]
  works_with: [test-engineer, devops-engineer]
  conflicts_with: [frontend-specialist]
  priority: 1
  complexity_range: [3, 10]
```

### Quality Agents

```yaml
test-engineer:
  display_name: "Test Engineer"
  category: quality
  domain: [testing, unit-test, integration-test, e2e, tdd]
  triggers:
    keywords: [test, spec, coverage, jest, vitest, playwright, cypress, tdd]
    file_patterns: ["**/*.test.*", "**/*.spec.*", "tests/**", "__tests__/**"]
    contexts: [test_failure, new_feature_needs_tests, coverage_drop]
  skills: [testing-mastery, testing-patterns, tdd-workflow, webapp-testing]
  rules: [agentic-ai/testing.md]
  exclusions: []
  works_with: [backend-specialist, frontend-specialist]
  conflicts_with: []
  priority: 3
  complexity_range: [2, 8]

test-generator:
  display_name: "Test Generator"
  category: quality
  domain: [test-generation, auto-test, mock]
  triggers:
    keywords: [generate test, create test, write test, auto test, mock]
    file_patterns: []
    contexts: [missing_tests, untested_code]
  skills: [testing-patterns, tdd-workflow]
  rules: [agentic-ai/testing.md]
  exclusions: []
  works_with: [test-engineer]
  conflicts_with: []
  priority: 4
  complexity_range: [1, 6]

ai-code-reviewer:
  display_name: "AI Code Reviewer"
  category: quality
  domain: [code-review, quality, standards, best-practices]
  triggers:
    keywords: [review, PR, code quality, review code, best practice, code review]
    file_patterns: []
    contexts: [pull_request, code_submission]
  skills: [code-review-checklist, clean-code]
  rules: [agentic-ai/code-review.md]
  exclusions: []
  works_with: [security-auditor, test-engineer]
  conflicts_with: []
  priority: 3
  complexity_range: [2, 8]

debugger:
  display_name: "Debugger"
  category: quality
  domain: [debugging, error, crash, stack-trace, root-cause]
  triggers:
    keywords: [debug, fix, error, bug, crash, stack trace, exception, broken]
    file_patterns: []
    contexts: [runtime_error, build_failure, test_failure]
  skills: [systematic-debugging]
  rules: [agentic-ai/debugging.md]
  exclusions: []
  works_with: [backend-specialist, frontend-specialist]
  conflicts_with: []
  priority: 2
  complexity_range: [3, 10]
```

### Security Agents

```yaml
security-auditor:
  display_name: "Security Auditor"
  category: security
  domain: [security, audit, vulnerability, owasp, auth]
  triggers:
    keywords: [security, audit, vulnerability, owasp, cve, xss, sql injection, penetration]
    file_patterns: ["auth/**", "middleware/auth*"]
    contexts: [security_review, pre_deployment, incident]
  skills: [vulnerability-scanner]
  rules: [agentic-ai/security.md, web-development/security.md]
  exclusions: ["*.css", "*.html"]
  works_with: [penetration-tester, backend-specialist]
  conflicts_with: []
  priority: 2
  complexity_range: [5, 10]

penetration-tester:
  display_name: "Penetration Tester"
  category: security
  domain: [pentest, offensive-security, exploit, attack-surface]
  triggers:
    keywords: [pentest, penetration test, exploit, attack, red team]
    file_patterns: []
    contexts: [security_audit, pre_release]
  skills: [red-team-tactics, vulnerability-scanner]
  rules: [agentic-ai/security.md]
  exclusions: []
  works_with: [security-auditor]
  conflicts_with: []
  priority: 4
  complexity_range: [7, 10]
```

### Architecture Agents

```yaml
database-architect:
  display_name: "Database Architect"
  category: architecture
  domain: [database, schema, migration, sql, orm, prisma, eloquent]
  triggers:
    keywords: [database, schema, migration, query, index, prisma, eloquent, sql, table]
    file_patterns: ["*.sql", "prisma/**", "database/**", "migrations/**"]
    contexts: [slow_query, schema_change, new_database]
  skills: [database-design, prisma-expert]
  rules: [database/*, agentic-ai/database-design.md]
  exclusions: ["*.tsx", "*.vue", "*.css"]
  works_with: [backend-specialist, performance-optimizer]
  conflicts_with: []
  priority: 2
  complexity_range: [3, 10]

orchestrator:
  display_name: "Orchestrator"
  category: architecture
  domain: [orchestration, coordination, multi-agent, complex-task]
  triggers:
    keywords: [orchestrate, coordinate, complex, multi-step, full stack]
    file_patterns: []
    contexts: [multi_domain_task, large_feature, system_design]
  skills: [parallel-agents, brainstorming, plan-writing]
  rules: []
  exclusions: []
  works_with: ["*"]  # Can coordinate any agent
  conflicts_with: []
  priority: 1
  complexity_range: [7, 10]

project-planner:
  display_name: "Project Planner"
  category: architecture
  domain: [planning, architecture, requirements, design, adr]
  triggers:
    keywords: [plan, design, architecture, requirements, scope, roadmap]
    file_patterns: ["docs/PLAN.md", "docs/ADR/**"]
    contexts: [new_project, major_feature, architecture_decision]
  skills: [plan-writing, architecture-mastery, brainstorming]
  rules: [agentic-ai/strong-reasoning.md]
  exclusions: []
  works_with: [orchestrator, backend-specialist, frontend-specialist]
  conflicts_with: []
  priority: 1
  complexity_range: [5, 10]
```

### Operations Agents

```yaml
devops-engineer:
  display_name: "DevOps Engineer"
  category: operations
  domain: [devops, ci-cd, deployment, docker, kubernetes, monitoring]
  triggers:
    keywords: [deploy, ci, cd, pipeline, docker, kubernetes, nginx, pm2, github actions]
    file_patterns: [".github/**", "Dockerfile", "docker-compose*", "*.yml", "nginx*"]
    contexts: [deployment, infrastructure_change, monitoring_setup]
  skills: [docker-expert, kubernetes-patterns, terraform-iac, deployment-procedures, server-management]
  rules: [agentic-ai/devops.md]
  exclusions: ["src/**", "app/**"]
  works_with: [backend-specialist, security-auditor]
  conflicts_with: []
  priority: 3
  complexity_range: [4, 10]

performance-optimizer:
  display_name: "Performance Optimizer"
  category: operations
  domain: [performance, optimization, profiling, caching, bundle-size]
  triggers:
    keywords: [optimize, performance, slow, latency, bundle, cache, memory, cpu]
    file_patterns: []
    contexts: [slow_page, high_latency, memory_leak, large_bundle]
  skills: [performance-profiling, react-performance, laravel-performance, inertia-performance]
  rules: [agentic-ai/performance.md, web-development/core-web-vitals.md]
  exclusions: []
  works_with: [backend-specialist, frontend-specialist, database-architect]
  conflicts_with: []
  priority: 3
  complexity_range: [5, 10]

manager-agent:
  display_name: "Manager Agent"
  category: operations
  domain: [management, aoc, quality-gate, validation]
  triggers:
    keywords: [validate, verify, check all, final check, quality gate]
    file_patterns: []
    contexts: [pre_release, quality_gate, aoc_cycle]
  skills: [behavioral-modes]
  rules: []
  exclusions: []
  works_with: ["*"]
  conflicts_with: []
  priority: 5
  complexity_range: [3, 8]
```

### Specialized Agents

```yaml
seo-specialist:
  display_name: "SEO Specialist"
  category: specialized
  domain: [seo, meta-tags, analytics, sitemap, robots]
  triggers:
    keywords: [seo, meta, sitemap, robots, analytics, lighthouse, schema.org]
    file_patterns: ["robots.txt", "sitemap.xml", "next-sitemap.config*"]
    contexts: [seo_audit, page_creation]
  skills: [seo-fundamentals, geo-fundamentals]
  rules: []
  exclusions: ["*.php", "server/**"]
  works_with: [frontend-specialist]
  conflicts_with: []
  priority: 5
  complexity_range: [2, 6]

game-designer:
  display_name: "Game Designer"
  category: specialized
  domain: [game, game-design, mechanics, balance]
  triggers:
    keywords: [game, game design, mechanics, level, balance]
    file_patterns: []
    contexts: [game_project]
  skills: [game-development]
  rules: []
  exclusions: []
  works_with: [mobile-game-developer, pc-game-developer]
  conflicts_with: []
  priority: 5
  complexity_range: [3, 8]

mobile-game-developer:
  display_name: "Mobile Game Developer"
  category: specialized
  domain: [mobile-game, unity-mobile, cocos2d]
  triggers:
    keywords: [mobile game, unity mobile, cocos2d]
    file_patterns: []
    contexts: [mobile_game_project]
  skills: [game-development, mobile-design]
  rules: [mobile/*]
  exclusions: []
  works_with: [game-designer, mobile-developer]
  conflicts_with: []
  priority: 5
  complexity_range: [5, 10]

pc-game-developer:
  display_name: "PC Game Developer"
  category: specialized
  domain: [pc-game, unity, unreal, godot]
  triggers:
    keywords: [pc game, unity, unreal, godot, game engine]
    file_patterns: ["*.cs", "*.gd", "*.gdscript"]
    contexts: [pc_game_project]
  skills: [game-development]
  rules: []
  exclusions: []
  works_with: [game-designer]
  conflicts_with: []
  priority: 5
  complexity_range: [5, 10]
```

### Automation Agents

```yaml
self-correction-agent:
  display_name: "Self-Correction Agent"
  category: automation
  domain: [self-healing, auto-fix, lint, type-error]
  triggers:
    keywords: [auto fix, lint, type error, self correct, auto heal]
    file_patterns: []
    contexts: [lint_failure, type_error, import_error]
  skills: [clean-code]
  rules: []
  exclusions: []
  works_with: [debugger]
  conflicts_with: []
  priority: 4
  complexity_range: [1, 5]

triage-agent:
  display_name: "Triage Agent"
  category: automation
  domain: [triage, classification, routing, priority]
  triggers:
    keywords: [triage, classify, prioritize, route, categorize]
    file_patterns: []
    contexts: [unclear_request, multi_domain_issue]
  skills: [brainstorming]
  rules: []
  exclusions: []
  works_with: [orchestrator]
  conflicts_with: []
  priority: 1
  complexity_range: [1, 5]

refactor-agent:
  display_name: "Refactor Agent"
  category: automation
  domain: [refactoring, cleanup, code-smell, dry, solid]
  triggers:
    keywords: [refactor, cleanup, code smell, dry, solid, extract, rename]
    file_patterns: []
    contexts: [code_smell_detected, tech_debt, large_function]
  skills: [clean-code]
  rules: [agentic-ai/refactoring.md]
  exclusions: []
  works_with: [test-engineer, ai-code-reviewer]
  conflicts_with: []
  priority: 3
  complexity_range: [3, 8]

code-generator-agent:
  display_name: "Code Generator Agent"
  category: automation
  domain: [scaffolding, boilerplate, generation, template]
  triggers:
    keywords: [generate, scaffold, boilerplate, template, create file]
    file_patterns: []
    contexts: [new_module, new_component, scaffolding]
  skills: [app-builder]
  rules: []
  exclusions: []
  works_with: [backend-specialist, frontend-specialist]
  conflicts_with: []
  priority: 4
  complexity_range: [2, 6]

explorer-agent:
  display_name: "Explorer Agent"
  category: automation
  domain: [exploration, discovery, search, dependency-analysis]
  triggers:
    keywords: [explore, search, find, list files, dependency, analyze]
    file_patterns: []
    contexts: [unknown_codebase, dependency_analysis, file_discovery]
  skills: []
  rules: []
  exclusions: []
  works_with: [orchestrator, triage-agent]
  conflicts_with: []
  priority: 3
  complexity_range: [1, 4]
```

### Documentation Agents

```yaml
documentation-agent:
  display_name: "Documentation Agent"
  category: documentation
  domain: [documentation, auto-doc, sync, changelog]
  triggers:
    keywords: [document, sync docs, update docs, changelog, auto document]
    file_patterns: ["docs/**", "*.md", "README*"]
    contexts: [post_implementation, doc_outdated]
  skills: [documentation-templates]
  rules: []
  exclusions: []
  works_with: [backend-specialist, frontend-specialist]
  conflicts_with: []
  priority: 5
  complexity_range: [2, 6]

documentation-writer:
  display_name: "Documentation Writer"
  category: documentation
  domain: [writing, readme, api-docs, guide, tutorial]
  triggers:
    keywords: [write docs, readme, api docs, guide, tutorial, onboarding]
    file_patterns: ["README*", "docs/**"]
    contexts: [user_requested_docs]
  skills: [documentation-templates]
  rules: []
  exclusions: []
  works_with: [documentation-agent]
  conflicts_with: []
  priority: 5
  complexity_range: [2, 6]
```

---

## Agent Selection Algorithm

```
FUNCTION selectAgents(request, projectContext, discoveredRules):
  candidates = []

  // 1. Keyword matching
  FOR EACH agent IN registry:
    keywordScore = matchKeywords(request, agent.triggers.keywords)
    fileScore = matchFiles(activeFiles, agent.triggers.file_patterns)
    contextScore = matchContext(projectContext, agent.triggers.contexts)
    totalScore = keywordScore * 3 + fileScore * 4 + contextScore * 2
    
    IF totalScore > 0:
      candidates.push({ agent, score: totalScore })

  // 2. Rule alignment boost
  FOR EACH candidate IN candidates:
    ruleOverlap = countOverlap(discoveredRules, candidate.agent.rules)
    candidate.score += ruleOverlap * 2

  // 3. Complexity filtering
  taskComplexity = assessComplexity(request)
  candidates = candidates.FILTER(c => 
    taskComplexity >= c.agent.complexity_range[0] &&
    taskComplexity <= c.agent.complexity_range[1]
  )

  // 4. Conflict resolution
  candidates = resolveConflicts(candidates)

  // 5. Sort and limit
  SORT(candidates, BY score DESC)
  primary = candidates[0]
  supporting = candidates[1..3].FILTER(c => !primary.conflicts_with.includes(c))

  RETURN { primary, supporting }
```

---

## Statistics

| Category | Count | Lead Agents |
|----------|-------|-------------|
| Core Dev | 4 | backend-specialist, frontend-specialist, laravel-specialist, mobile-developer |
| Quality | 4 | test-engineer, test-generator, ai-code-reviewer, debugger |
| Security | 2 | security-auditor, penetration-tester |
| Architecture | 3 | database-architect, orchestrator, project-planner |
| Operations | 3 | devops-engineer, performance-optimizer, manager-agent |
| Specialized | 4 | seo-specialist, game-designer, mobile-game-developer, pc-game-developer |
| Automation | 5 | self-correction-agent, triage-agent, refactor-agent, code-generator-agent, explorer-agent |
| Documentation | 2 | documentation-agent, documentation-writer |
| **TOTAL** | **27** | |

---

**Version:** 1.0.0  
**System:** Antigravity-Core v4.0  
**Created:** 2026-02-10

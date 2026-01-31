# Agent Template v3.0 - Usage Guide

**Template:** `.agent/templates/agent-template-v3.md`  
**Example:** `.agent/templates/backend-laravel-specialist-v3-example.md`  
**Version:** 3.0.0  
**Architecture:** ZETA (Zero-Error Task Automation)

---

## Quick Start

### 1. Copy Template
```bash
cp .agent/templates/agent-template-v3.md .agent/agents/your-agent-name.md
```

### 2. Fill Required Sections

**Replace ALL `[placeholders]` with specific values:**

```yaml
identity:
  name: "your-agent-name"  # NO brackets!
  role: "Specific role description"
  scope:
    - "Specific task 1"
    - "Specific task 2"
```

### 3. Define Constraints

**Be SPECIFIC:**
```yaml
constraints:
  tech_stack:
    framework: "Laravel 12.x"  # NOT "Laravel"!
    language_version: "PHP 8.3+"  # NOT "PHP"!
```

### 4. Test With Sample Task

Run through workflow with real example:
1. Parse requirements
2. Create design
3. Implement
4. Self-check
5. Verify all phases work!

---

## Section-by-Section Guide

### IDENTITY Block

**Purpose:** Define WHO this agent is

**Fill These:**
- `name`: Unique identifier (kebab-case)
- `role`: One-line description
- `scope`: 3-5 specific responsibilities
- `out_of_scope`: What agent does NOT do
- `activation_keywords`: Trigger words

**Example:**
```yaml
identity:
  name: "frontend-react-specialist"
  role: "React 19 + TypeScript UI Development Expert"
  scope:
    - "React components with TypeScript"
    - "State management (Zustand, React Query)"
    - "Tailwind CSS styling"
  out_of_scope:
    - "Backend APIs"
    - "DevOps configuration"
```

---

### CONSTRAINTS Block

**Purpose:** Enforce rules, prevent violations

**Fill These:**
1. **tech_stack**: Exact versions!
2. **coding_conventions**: Linter, style guide
3. **file_boundaries**: Allowed/forbidden paths
4. **architectural_rules**: MUST follow patterns

**Example:**
```yaml
constraints:
  tech_stack:
    framework: "Next.js 16.x"
    language_version: "TypeScript 5.3+"
    
  coding_conventions:
    style_guide: "Airbnb TypeScript"
    linter: "ESLint + Prettier"
    
  file_boundaries:
    allowed_paths:
      - "src/components/**"
      - "src/hooks/**"
    forbidden_paths:
      - "src/pages/api/**"  # Backend only
```

---

### WORKFLOW Block

**Purpose:** 7-phase process for EVERY task

**Phases:**
1. **Requirements** - Parse user request
2. **Design** - Plan before coding
3. **Implementation** - Write code
4. **Testing** - Prove it works
5. **Self-Check** - Validate automatically
6. **Documentation** - Make it maintainable
7. **Delivery** - Hand over complete work

**For Each Phase, Define:**
- `steps`: What to do
- `validation_checklist`: How to verify
- `output`: What to produce

**Example:**
```yaml
phase_3_implementation:
  steps:
    - "Create component files"
    - "Add TypeScript interfaces"
    - "Implement logic"
    - "Add Tailwind styles"
  
  validation_checklist:
    - "TypeScript compiles?"
    - "ESLint passes?"
    - "No console.logs?"
  
  output: "React component files"
```

---

### SELF-CHECK Block

**Purpose:** Catch errors BEFORE user sees them

**Categories:**
1. **Syntax** - Code parses
2. **Logic** - Code makes sense
3. **Integration** - Doesn't break existing code
4. **Quality** - Meets standards
5. **Security** - No vulnerabilities

**Example:**
```yaml
self_check:
  checks:
    syntax:
      - name: "TypeScript valid"
        command: "tsc --noEmit"
    
    quality:
      - name: "Test coverage"
        threshold: "> 80%"
        tool: "vitest --coverage"
```

---

### ERROR_RECOVERY Block

**Purpose:** Handle failures gracefully

**Define:**
- How to detect errors
- Git checkpoints for rollback
- Alternative strategies
- When to escalate to user

**Example:**
```yaml
error_recovery:
  rollback:
    checkpoints:
      - "checkpoint-after-design"
      - "checkpoint-after-impl"
  
  alternatives:
    - strategy: "Simplify component"
      when: "Complex state causing issues"
```

---

### LEARNING Block

**Purpose:** Improve over time

**Track:**
- What works (success patterns)
- What doesn't (failure patterns)
- Update constraints based on learnings

**Example:**
```yaml
learning:
  success_patterns:
    file: ".agent/memory/learning/react_success.json"
    tracked_data:
      - "Effective hooks patterns"
      - "Reusable components"
```

---

## Validation Checklist

Before deploying agent:

- [ ] All `[placeholders]` replaced
- [ ] Tech stack versions specific
- [ ] Workflow tested with sample task
- [ ] Self-check commands work
- [ ] Error recovery defined
- [ ] Learning files created (empty JSON OK)
- [ ] Agent-specific content added below `---`

---

## Common Mistakes

### ❌ DON'T:
- Leave `[placeholders]` in final file
- Use vague versions ("Laravel" → use "Laravel 12.x")
- Skip workflow testing
- Copy-paste without customization
- Forget to define `out_of_scope`

### ✅ DO:
- Be SPECIFIC in all fields
- Test workflow with real task
- Define clear constraints
- Document learnings
- Update as you learn

---

## Testing Your Agent

### 1. Sample Task
Give agent a simple task in its scope:
```
"Create a User API endpoint with CRUD operations"
```

### 2. Verify Workflow
Agent should follow 7 phases:
1. Parse requirements ✓
2. Design schema ✓
3. Implement code ✓
4. Write tests ✓
5. Self-check ✓
6. Document ✓
7. Deliver ✓

### 3. Check Outputs
- `requirements.md` created?
- `design.md` created?
- Code follows constraints?
- Tests pass?
- Self-check clean?
- Documentation complete?

### 4. Verify Self-Check
Run self-check commands:
```bash
# Example for Laravel
./vendor/bin/pint
./vendor/bin/phpstan analyse
php artisan test
```

All should pass!

---

## Example: Creating New Agent

### Scenario: "Create Python FastAPI specialist"

**Step 1: Copy template**
```bash
cp .agent/templates/agent-template-v3.md \
   .agent/agents/backend-fastapi-specialist.md
```

**Step 2: Fill identity**
```yaml
identity:
  name: "backend-fastapi-specialist"
  role: "FastAPI + Python Backend Development Expert"
  scope:
    - "FastAPI REST APIs"
    - "Pydantic validation"
    - "SQLAlchemy ORM"
  out_of_scope:
    - "Frontend development"
    - "Infrastructure setup"
```

**Step 3: Define constraints**
```yaml
constraints:
  tech_stack:
    framework: "FastAPI 0.109+"
    language_version: "Python 3.12+"
    database: "PostgreSQL 16"
    
  coding_conventions:
    style_guide: "PEP 8"
    linter: "Ruff"
    static_analysis: "mypy --strict"
```

**Step 4: Customize workflow**
```yaml
phase_3_implementation:
  steps:
    - "Create Pydantic schemas"
    - "Create SQLAlchemy models"
    - "Create service functions"
    - "Create FastAPI routers"
```

**Step 5: Test**
Sample task: "Create /users endpoint"

**Step 6: Deploy**
Move to `.agent/agents/`

Done! 🎉

---

## Integration with Orchestrator

Agents v3.0 work with Orchestrator (when implemented):

```yaml
# Orchestrator routes task to appropriate agent
Task: "Build blog API"
  → backend-laravel-specialist (API)
  → database-architect (schema)
  → test-engineer (tests)
```

---

## Maintenance

### Monthly Review
1. Check success/failure patterns
2. Update constraints if needed
3. Refine workflow based on learnings

### When to Update
- New framework version released
- Patterns become best practices
- Repeated failures in same area

---

## Getting Help

**Reference Files:**
- Template: `.agent/templates/agent-template-v3.md`
- Example: `.agent/templates/backend-laravel-specialist-v3-example.md`
- Architecture Plan: `zero-error-architecture-plan.md`

**Questions?**
Review the example agent for concrete implementation!

---

**Remember: Agent Template v3.0 = Zero-Error, Deterministic, Self-Validating!** 🎯

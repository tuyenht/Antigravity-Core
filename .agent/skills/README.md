# 🎯 .agent Skills System

**Purpose:** Reusable capability modules that agents can reference  
**Version:** 1.0  
**Last Updated:** 2026-01-17

---

## 📖 WHAT ARE SKILLS?

**Skills** are cross-cutting concerns and reusable patterns that multiple agents need.

Think of skills as:
- 📚 **Libraries** for agents
- 🧰 **Toolkits** with best practices
- 📋 **Checklists** for common tasks

---

## 🤔 SKILLS vs AGENT LOGIC

### Use Skills When:
✅ **Cross-cutting concerns** (logging, validation, error handling)  
✅ **Reusable patterns** (React patterns, clean code principles)  
✅ **Framework-agnostic knowledge** (SOLID principles, design patterns)  
✅ **Best practices** (security audits, performance profiling)

### Use Agent Logic When:
✅ **Specific implementation** (creating a Laravel controller)  
✅ **Tech-specific details** (Next.js routing configuration)  
✅ **Project context** (this project's architecture)

---

## 📁 SKILLS STRUCTURE

Each skill is a folder with a `SKILL.md` file:

```
.agent/skills/
├── clean-code/
│   └── SKILL.md          # Clean code principles
├── react-patterns/
│   └── SKILL.md          # React best practices
├── security-audit/
│   └── SKILL.md          # Security checklist
└── performance-profiling/
    ├── SKILL.md          # Performance guide
    └── examples/         # (optional) Code examples
```

---

## 🔗 HOW AGENTS REFERENCE SKILLS

### In Agent Frontmatter:

```yaml
---
name: backend-specialist
tools: Read, Grep, Glob, Bash, Edit, Write
model: inherit
skills: clean-code, security-audit, performance-profiling
---
```

**What this means:**
- Agent has access to those skill instructions
- Agent SHOULD follow skill guidelines
- Skills provide context, not rigid rules

---

## 📚 AVAILABLE SKILLS

### Code Quality Skills

**clean-code** - SOLID, DRY, KISS principles
- When to use: All code creation/editing
- Key concepts: Single Responsibility, naming conventions
- Agents: All

**code-quality-standards** - Quality metrics and thresholds
- When to use: Code reviews, refactoring
- Key concepts: Cyclomatic complexity, test coverage
- Agents: refactor-agent, test-engineer

---

### Framework Skills

**react-patterns** - React best practices
- When to use: Building React components
- Key concepts: Hooks, composition, performance
- Agents: frontend-specialist, mobile-developer

**react-performance** - Vercel React Best Practices (NEW)
- When to use: React/Next.js performance optimization
- Key concepts: Impact prioritization (CRITICAL→LOW), waterfall elimination, bundle optimization
- Agents: frontend-specialist, performance-optimizer (if created)
- Source: Vercel Labs (10+ years production experience)
- Special: 40+ specific rules with metrics, AI-optimized format

**nextjs-best-practices** - Next.js specific patterns
- When to use: Next.js projects
- Key concepts: Routing, SSR, data fetching
- Agents: frontend-specialist

**laravel-patterns** - Laravel conventions
- When to use: Laravel backend development
- Key concepts: Eloquent, Form Requests, Service Layer
- Agents: backend-specialist, laravel-specialist

---

### Testing Skills

**testing-patterns** - Test design principles
- When to use: Writing tests
- Key concepts: AAA pattern, mocking, coverage
- Agents: test-engineer, backend-specialist

**tdd-workflow** - Test-Driven Development
- When to use: TDD approach projects
- Key concepts: Red-Green-Refactor cycle
- Agents: test-engineer

---

### Security Skills

**security-audit** - Security checklist
- When to use: Code reviews, new features
- Key concepts: OWASP Top 10, input validation
- Agents: security-auditor, penetration-tester

**api-security** - API-specific security
- When to use: Building APIs
- Key concepts: JWT, rate limiting, CORS
- Agents: backend-specialist, security-auditor

---

### Performance Skills

**performance-profiling** - Performance optimization
- When to use: Slow endpoints, poor UX
- Key concepts: N+1 queries, caching, lazy loading
- Agents: performance-optimizer, backend-specialist

---

### Design Skills

**frontend-design** - UI/UX principles
- When to use: Building user interfaces
- Key concepts: Accessibility, responsiveness, color theory
- Agents: frontend-specialist

**mobile-design** - Mobile-specific design
- When to use: Mobile apps
- Key concepts: Touch targets, gestures, native feel
- Agents: mobile-developer

---

## 📝 CREATING A NEW SKILL

### Step 1: Create Folder

```bash
mkdir .agent/skills/my-new-skill
```

### Step 2: Create SKILL.md

```bash
touch .agent/skills/my-new-skill/SKILL.md
```

### Step 3: Use Template

```markdown
---
name: my-new-skill
description: Brief description of what this skill provides
version: 1.0
---

# My New Skill

## Purpose
What problem does this skill solve?

## When to Use
In which scenarios should agents reference this skill?

## Key Concepts
- Concept 1: Explanation
- Concept 2: Explanation

## Best Practices
1. Practice 1
2. Practice 2

## Anti-Patterns (What NOT to do)
❌ Anti-pattern 1
✅ Better approach

## Examples

### Example 1: [Scenario]
```code
// Good example
```

## Checklist
Before completing work using this skill:
- [ ] Check 1
- [ ] Check 2
```

### Step 4: Reference in Agents

```yaml
# Update relevant agents
skills: existing-skill, my-new-skill
```

---

## 🔄 SKILL vs STANDARDS.md

**Common Question:** "When to use skills vs STANDARDS.md?"

| Aspect | STANDARDS.md | Skills |
|--------|--------------|--------|
| **Scope** | Universal (ALL projects) | Specific concerns |
| **Type** | Mandatory rules | Best practice guides |
| **Violation** | Code REJECTED | Guidance ignored |
| **Example** | "80% test coverage required" | "How to write good tests" |

**Both work together:**
- STANDARDS.md: "You MUST test"
- testing-patterns skill: "Here's HOW to test well"

---

## 📖 WHEN AGENTS SHOULD CONSULT SKILLS

### Scenario 1: Creating React Component

1. Agent: frontend-specialist
2. Skills referenced: react-patterns, clean-code
3. Agent thinks:
   - "react-patterns says use composition over inheritance"
   - "clean-code says max 200 lines per component"
   - Apply both principles

### Scenario 2: Security Review

1. Agent: security-auditor
2. Skills referenced: security-audit, api-security
3. Agent checklist:
   - OWASP Top 10 (from security-audit skill)
   - JWT validation (from api-security skill)
   - Input sanitization (from both)

---

## 🎓 SKILL BEST PRACTICES

### For Skill Authors:

1. **Keep skills focused** - One concern per skill
2. **Provide examples** - Code snippets help
3. **Include anti-patterns** - Show what NOT to do
4. **Version skills** - Track changes over time
5. **Cross-reference** - Link related skills

### For Agents Using Skills:

1. **Don't blindly follow** - Use judgment
2. **Adapt to project** - Skills are guidelines, not laws
3. **Combine skills** - Use multiple skills together
4. **Report conflicts** - If skills contradict, ask user

---

## 🔍 SKILL DISCOVERY

**How to find skills?**

```bash
# List all skills
ls .agent/skills/

# Search for specific skill
grep -r "performance" .agent/skills/*/SKILL.md

# View skill
cat .agent/skills/react-patterns/SKILL.md
```

**How agents know which skills to use?**

1. **Agent frontmatter** - Skills listed explicitly
2. **Keywords** - Agent triggered by keywords → uses related skills
3. **User request** - "Use clean code principles" → references clean-code skill

---

## 📊 SKILLS USAGE MATRIX

| Agent | Primary Skills | Secondary Skills |
|-------|----------------|------------------|
| backend-specialist | clean-code, security-audit | performance-profiling |
| frontend-specialist | react-patterns, clean-code | frontend-design |
| security-auditor | security-audit, api-security | clean-code |
| test-engineer | testing-patterns, tdd-workflow | clean-code |
| performance-optimizer | performance-profiling | clean-code |

---

## 🎯 SKILL GOVERNANCE

### Who Creates Skills?
- Architects (cross-cutting concerns)
- Tech leads (framework-specific)
- Senior engineers (domain expertise)

### Who Reviews Skills?
- Peer review required
- Validate against STANDARDS.md
- Test with actual agent usage

### Who Maintains Skills?
- Original author responsible
- Update when frameworks upgrade
- Archive deprecated skills

---

## 📝 SKILL CHANGELOG

Track skill changes:

```markdown
## clean-code Skill

**Version 2.0** (2026-01-15)
- Added cyclomatic complexity guidelines
- Updated naming conventions for TypeScript
- Added React hooks examples

**Version 1.0** (2025-12-01)
- Initial creation
- SOLID principles
- DRY, KISS, YAGNI
```

---

## 🆘 TROUBLESHOOTING

**Q: Agent not following skill?**
A: Check agent frontmatter - is skill listed?

**Q: Skills conflict with each other?**
A: STANDARDS.md overrides skills. Escalate to user.

**Q: Skill outdated?**
A: Update SKILL.md version, notify all agents using it.

**Q: Too many skills?**
A: Consolidate related skills, archive unused ones.

---

## 📖 RELATED DOCUMENTATION

- `STANDARDS.md` - Universal coding rules
- `agent-template-v3.md` - How agents are structured
- `rba-validator.md` - Reasoning-before-action checks

---

**Created:** 2026-01-17  
**Version:** 1.0  
**Purpose:** Guide for skills system usage and creation

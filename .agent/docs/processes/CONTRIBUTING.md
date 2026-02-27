# Contributing — Hướng dẫn đóng góp

**Version:** 5.0.0  
**Last Updated:** 2026-02-27

---

## Overview

Hướng dẫn đóng góp vào Antigravity-Core `.agent` system.

---

## Getting Started

### 1. Fork & Clone
```bash
git clone https://github.com/<your-username>/Antigravity-Core.git
cd Antigravity-Core
```

### 2. Understand the Structure
```
.agent/
├── agents/       ← 27 agent definitions (frontmatter + rules)
├── skills/       ← 59 knowledge modules (SKILL.md + scripts/)
├── workflows/    ← 38 slash command workflows
├── rules/        ← 95 expert rules (11 categories)
├── pipelines/    ← 6 pipeline chains (BUILD, ENHANCE, FIX, IMPROVE, SHIP, REVIEW)
├── systems/      ← 5 core protocols (+ Intent Router)
├── scripts/      ← 20 automation scripts
├── docs/         ← Documentation
└── GEMINI.md     ← Master config (entry point)
```

### 3. Read key files
- `ARCHITECTURE.md` — System overview
- `GEMINI.md` — Agent behavior rules
- `docs/INDEX.md` — Documentation index

---

## Contributing Guidelines

### Adding a New Agent

1. Create `.agent/agents/<agent-name>.md`
2. Follow frontmatter format:
   ```yaml
   ---
   name: agent-name
   description: Brief description
   tools: Read, Grep, Glob, Edit, Write
   model: inherit
   skills: clean-code, <other-skills>
   ---
   ```
3. Include sections: Role, Reasoning-Before-Action, Workflow, When to Use
4. Update `ARCHITECTURE.md` agent count
5. Update `project.json` → `component_counts.agents`
6. Create PR with test evidence

### Adding a New Skill

1. Create `.agent/skills/<skill-name>/SKILL.md`
2. Follow frontmatter format:
   ```yaml
   ---
   name: skill-name
   description: Brief description
   ---
   ```
3. Optionally add `scripts/`, `examples/`, `resources/`
4. Reference skill in relevant agent frontmatter
5. Update `ARCHITECTURE.md` skill count
6. Update `project.json` → `component_counts.skills`

### Adding a New Rule

1. Create `.agent/rules/<category>/<rule-name>.md`
2. Follow existing rule format in the category
3. Add auto-activation triggers to `auto-rule-discovery.md`
4. Update `RULES-INDEX.md`
5. Update category count in `ARCHITECTURE.md`

### Adding a New Workflow

1. Create `.agent/workflows/<workflow-name>.md`
2. Follow format:
   ```yaml
   ---
   description: Brief description
   ---
   [Step-by-step instructions]
   ```
3. Update `ARCHITECTURE.md` workflow count
4. Update `project.json` → `component_counts.workflows`

---

## Quality Standards

- [ ] All counts in `ARCHITECTURE.md` accurate
- [ ] `project.json` component counts updated
- [ ] Cross-references in `GEMINI.md` valid
- [ ] No broken file paths
- [ ] Frontmatter format consistent
- [ ] `CHANGELOG.md` entry added

---

## Pull Request

PR template is auto-applied by [`.github/PULL_REQUEST_TEMPLATE.md`](../../.github/PULL_REQUEST_TEMPLATE.md). No need to copy-paste.

---

> **See also:** [Architecture](../../ARCHITECTURE.md) | [CHANGELOG](../../CHANGELOG.md) | [Branching Strategy](./BRANCHING-STRATEGY.md) | [Definition of Done](./DEFINITION-OF-DONE.md)

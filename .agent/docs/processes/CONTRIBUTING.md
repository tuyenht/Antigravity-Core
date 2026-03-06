# Contributing — Hướng dẫn đóng góp

**Version:** 5.0.0  
**Last Updated:** 2026-02-28

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
├── workflows/    ← 34 slash command workflows
├── rules/        ← 110 expert rules (11 categories)
├── pipelines/    ← 6 pipeline chains (BUILD, ENHANCE, FIX, IMPROVE, SHIP, REVIEW)
├── systems/      ← 5 core protocols (+ Intent Router)
├── scripts/      ← 37 automation scripts (20 core: 15 PS1 + 4 Bash + 1 Git hook | 17 skill: Python)
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
6. Update `reference-catalog.md` § 1 (Agent Summary table)
7. Update `agents/CAPABILITY-MATRIX.md` (Quick Selection + Matrix table + File Extensions)
8. Update `systems/agent-registry.md` (full YAML entry — source-of-truth)
9. Update `docs/agents/AGENT-CATALOG.md` (detailed agent card)
10. Update `docs/AGENT-VERSIONING.md` (add version row)
11. Create PR with test evidence

> **Full checklist:** See [CAPABILITY-MATRIX.md → Adding a New Agent](../../agents/CAPABILITY-MATRIX.md#adding-a-new-agent)

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
7. Update `reference-catalog.md` § 3 (Skills Inventory)
8. Update `docs/skills/SKILL-CATALOG.md` (registry + classification + statistics)
9. Update `docs/INDEX.md` count reference if applicable

> **Full checklist:** See [SKILL-CATALOG.md → Adding a New Skill](../skills/SKILL-CATALOG.md#adding-a-new-skill)

### Adding a New Rule

1. Create `.agent/rules/<category>/<rule-name>.md`
2. Follow existing rule format in the category
3. Add auto-activation triggers to `auto-rule-discovery.md`
4. Update category count in `ARCHITECTURE.md`

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

### Adding a New Script

1. **Core script:** Create `.agent/scripts/<script-name>.ps1`
2. **Skill script:** Create `.agent/skills/<skill-name>/scripts/<script-name>.py`
3. If CLI shortcut needed → add entry to `agent.ps1` switch block
4. If cross-platform → create `.sh` equivalent
5. Update `ARCHITECTURE.md` script count
6. Update `project.json` → `stats.scripts`
7. Update `reference-catalog.md` § 5 (script table)
8. Update `docs/scripts/SCRIPT-CATALOG.md` (script registry)
9. If pipeline uses script → add reference to `pipelines/*.md`

> **Full checklist:** See [SCRIPT-CATALOG.md → Adding a New Script](../scripts/SCRIPT-CATALOG.md#adding-a-new-script)

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

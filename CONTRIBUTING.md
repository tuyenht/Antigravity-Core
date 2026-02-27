# 🤝 Contributing to Antigravity-Core

> **Version:** 5.0.0 | **Last Updated:** 2026-02-27

Guidelines for contributing to the AI-Native Development Operating System.

---

## 📋 What You Can Contribute

| Component | Location | Guide |
|-----------|----------|-------|
| **Agent** | `.agent/agents/` | [Component Guide](.agent/docs/processes/CONTRIBUTING.md#adding-a-new-agent) |
| **Skill** | `.agent/skills/` | [Component Guide](.agent/docs/processes/CONTRIBUTING.md#adding-a-new-skill) |
| **Workflow** | `.agent/workflows/` | [Component Guide](.agent/docs/processes/CONTRIBUTING.md#adding-a-new-workflow) |
| **Rule** | `.agent/rules/` | [Component Guide](.agent/docs/processes/CONTRIBUTING.md#adding-a-new-rule) |
| **Script** | `.agent/scripts/` | PowerShell primary, Bash optional |
| **Documentation** | `.agent/docs/` | Markdown, bilingual (EN code / VI docs) |

---

## 🏗️ Before You Start

### Prerequisites

1. **Read** the [README.md](README.md)
2. **Understand** the [Pipeline System](.agent/pipelines/) — 6 automated chains (BUILD, ENHANCE, FIX, IMPROVE, SHIP, REVIEW)
3. **Review** the [ARCHITECTURE.md](.agent/ARCHITECTURE.md) — system map and component counts
4. **Check** the [reference-catalog.md](.agent/reference-catalog.md) — lookup tables for agents, rules, scripts

### Setup

```bash
git clone https://github.com/tuyenht/Antigravity-Core.git
cd Antigravity-Core
```

---

## 🔄 Development Workflow

### Branching & Commits

Follow the [Branching Strategy](.agent/docs/processes/BRANCHING-STRATEGY.md):

- **Branch**: `feature/<ticket>-<description>`, `bugfix/<ticket>-<description>`, `hotfix/<ticket>-<description>`
- **Commits**: [Conventional Commits](https://www.conventionalcommits.org/) — `feat(scope): description`

### Pull Requests

- PRs are auto-filled by [`.github/PULL_REQUEST_TEMPLATE.md`](.github/PULL_REQUEST_TEMPLATE.md)
- Review process: [Code Review Process](.agent/docs/processes/CODE-REVIEW-PROCESS.md)
- Quality gates: [Definition of Done](.agent/docs/processes/DEFINITION-OF-DONE.md)

### Mandatory Updates

When adding/removing any component, **you MUST update**:

| File | What to update |
|------|----------------|
| `.agent/ARCHITECTURE.md` | Component counts (agents, skills, workflows, rules) |
| `.agent/project.json` | `component_counts` + `usage_tracking` |
| `.agent/CHANGELOG.md` | New entry under current version |

---

## 📏 Quality Standards

| Component | Minimum Score |
|-----------|:------------:|
| Workflows | 95/100 |
| Skills | 90/100 |
| Agents | 90/100 |
| Documentation | 95/100 |

Detailed checklists per component type: [Component Contributing Guide](.agent/docs/processes/CONTRIBUTING.md).

---

## 🆘 Getting Help

- **Issues**: [GitHub Issues](https://github.com/tuyenht/Antigravity-Core/issues) for bugs and feature requests
- **Discussions**: [GitHub Discussions](https://github.com/tuyenht/Antigravity-Core/discussions) for questions
- **Security**: See [SECURITY.md](SECURITY.md) for vulnerability reporting

---

## 📊 Recognition

Contributors are acknowledged in:
- [CHANGELOG.md](.agent/CHANGELOG.md) for significant contributions
- Release notes
- GitHub contributor graph

---

> **See also:** [Code of Conduct](CODE_OF_CONDUCT.md) | [Security Policy](SECURITY.md) | [README](README.md)

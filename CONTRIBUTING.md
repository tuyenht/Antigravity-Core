# 🤝 Contributing to Antigravity-Core

> Guidelines for contributing to the AI-Native Development Operating System

---

## 📋 Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Workflow](#development-workflow)
4. [Quality Standards](#quality-standards)
5. [Submission Guidelines](#submission-guidelines)

---

## 📜 Code of Conduct

### Our Standards

- Be respectful and inclusive
- Focus on constructive feedback
- Maintain professional communication
- Support fellow contributors

### Unacceptable Behavior

- Harassment or discrimination
- Trolling or insulting comments
- Publishing private information
- Any conduct inappropriate in a professional setting

---

## 🚀 Getting Started

### Prerequisites

1. **Familiarity** with the Antigravity-Core system
2. **Read** the [README.md](README.md) thoroughly
3. **Understand** the [Pipeline System](.agent/pipelines/) and [ARCHITECTURE](.agent/ARCHITECTURE.md)
4. **Review** the [ARCHITECTURE.md](.agent/ARCHITECTURE.md) for system overview

### Setting Up Development Environment

```bash
# 1. Clone the repository
git clone https://github.com/tuyenht/Antigravity-Core.git
cd Antigravity-Core

# 2. Review the structure
ls -la .agent/

# 3. Check current version
cat .agent/VERSION
```

---

## 🔄 Development Workflow

### Branch Naming Convention

| Type | Pattern | Example |
|------|---------|---------|
| Feature | `feature/description` | `feature/add-graphql-skill` |
| Bugfix | `fix/description` | `fix/workflow-typo` |
| Documentation | `docs/description` | `docs/update-readme` |
| Improvement | `improve/description` | `improve/performance-script` |

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(skills): add GraphQL patterns skill

- Added graphql-patterns/ skill folder
- Includes query, mutation, subscription examples
- Added resolver best practices

Closes #123
```

---

## 📏 Quality Standards

### File Quality Requirements

| Component | Minimum Score |
|-----------|--------------|
| Workflows | 95/100 |
| Skills | 90/100 |
| Agents | 90/100 |
| Documentation | 95/100 |

### Checklist Before Submitting

#### For Workflows
- [ ] Has `description` frontmatter
- [ ] Includes step-by-step instructions
- [ ] Has validation/quality checks
- [ ] Tested with at least one use case

#### For Skills
- [ ] Has `SKILL.md` with proper frontmatter
- [ ] Includes practical examples
- [ ] References official documentation
- [ ] Follows naming conventions

#### For Agents
- [ ] Has clear role definition
- [ ] Includes input/output specifications
- [ ] Has quality checklist
- [ ] Tested integration

#### For Documentation
- [ ] Clear and concise language
- [ ] Proper markdown formatting
- [ ] No broken links
- [ ] Includes examples where applicable

---

## 📤 Submission Guidelines

### Pull Request Process

1. **Create** a branch from `main`
2. **Make** your changes following quality standards
3. **Test** your changes thoroughly
4. **Update** documentation if needed
5. **Submit** a pull request with clear description

### PR Description Template

```markdown
## Summary
Brief description of changes

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Documentation update
- [ ] Refactoring
- [ ] Other (describe)

## Changes Made
- Change 1
- Change 2
- Change 3

## Testing Done
Describe how you tested your changes

## Checklist
- [ ] Follows quality standards
- [ ] Documentation updated
- [ ] No breaking changes
- [ ] Tested successfully

## Related Issues
Closes #issue_number
```

### Review Process

1. **Automated checks** run first
2. **Maintainer review** within 1-3 business days
3. **Feedback** provided if changes needed
4. **Merge** upon approval

---

## 📁 Directory Structure for New Components

### Adding a New Skill

```
.agent/skills/your-skill-name/
├── SKILL.md           # Required: Main instructions
├── examples/          # Recommended: Usage examples
│   ├── basic.md
│   └── advanced.md
├── scripts/           # Optional: Helper scripts
└── resources/         # Optional: Additional files
```

### Adding a New Workflow

```
.agent/workflows/your-workflow.md
```

**Required frontmatter:**
```yaml
---
description: Short description of the workflow
---
```

### Adding a New Agent

```
.agent/agents/your-agent.md
```

**Required sections:**
- Role definition
- Input/Output specifications
- Quality checklist
- Example prompts

---

### Adding an Expert Rule

```
.agent/rules/category/your-rule.md
```

**Categories:** `database/`, `mobile/`, `backend-frameworks/`, `frontend-frameworks/`, `typescript/`, `nextjs/`, `python/`, `web-development/`, `agentic-ai/`

**Requirements:**
- Clear title and scope
- Practical code examples (DO vs DON'T)
- Follows existing rule format
- Added to `RULES-INDEX.md`

### Adding a Script

```
.agent/scripts/your-script.ps1    # Windows (primary)
.agent/scripts/your-script.sh     # Linux/Mac (optional)
```

**Requirements:**
- PowerShell-compatible (Windows is primary platform)
- Includes error handling
- Has help/usage output
- Documented in `ARCHITECTURE.md`

---

## 💻 Platform Notes

**Windows (Primary):**
```powershell
# Clone and review
git clone https://github.com/tuyenht/Antigravity-Core.git
cd Antigravity-Core
Get-ChildItem .agent\ -Recurse | Measure-Object
```

**Linux/Mac:**
```bash
git clone https://github.com/tuyenht/Antigravity-Core.git
cd Antigravity-Core
find .agent -type f | wc -l
```

## 🆘 Getting Help

- **Issues**: Open a GitHub issue for bugs or feature requests
- **Discussions**: Use GitHub Discussions for questions
- **Documentation**: Check existing docs first

---

## 📊 Contribution Recognition

Contributors will be acknowledged in:
- CHANGELOG.md (for significant contributions)
- Release notes
- Contributors section (if applicable)

---

**Thank you for contributing to Antigravity-Core! 🚀**

Together, we're building the future of AI-native development.

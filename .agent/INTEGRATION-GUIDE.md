# 🚀 .agent System Integration Guide

**Purpose:** How to use `.agent` folder for automated code generation  
**Target:** All future projects  
**Updated:** 2026-02-13

---

## 🎯 WHAT IS .AGENT?

The `.agent` folder is a **universal code standards and automation system** that:

1. **Defines Standards** → How code should be written
2. **Provides Tools** → Automated checks and generators  
3. **Guides Development** → Best practices for all stacks
4. **Ensures Quality** → Automated reviews and validations

**Result:** Fast, consistent, high-quality code across ALL projects!

---

## 📁 DIRECTORY STRUCTURE

```
.agent/
├── agents/              # Specialized AI agents (backend, frontend, security, etc.)
├── memory/              # Learning and metrics tracking
├── rules/
│   ├── shared/          # Cross-framework rules
│   └── standards/       # Framework-specific standards
├── scripts/             # Automation scripts
├── skills/              # Reusable knowledge modules (59+ skills)
├── workflows/           # Automated workflow definitions
└── maintenance/         # System maintenance tasks
```

---

## 🌟 QUICK START: NEW PROJECT

### Step 1: Install Antigravity-Core to Project

**Option A: Using `agi` command (if global setup done)**
```powershell
cd NewProject
agi
```

**Option B: One-liner (no global setup needed)**
```powershell
cd NewProject
irm "https://raw.githubusercontent.com/tuyenht/Antigravity-Core/main/.agent/scripts/install-antigravity.ps1" -OutFile install.ps1
.\install.ps1
Remove-Item install.ps1
```

**Option C: Clone method (Linux/Mac)**
```bash
cd NewProject
git clone --depth 1 https://github.com/tuyenht/Antigravity-Core.git temp-ag
cp -r temp-ag/.agent ./.agent
rm -rf temp-ag
```

### Step 2: Initialize for Tech Stack
```bash
cd NewProject

# The .agent system will auto-detect your stack from:
# - package.json (Node.js/TypeScript)
# - composer.json (PHP/Laravel)
# - requirements.txt or pyproject.toml (Python)
# - go.mod (Go)
# - Cargo.toml (Rust)

# No configuration needed - it just works!
```

### Step 3: Install Pre-commit Hooks (Optional but Recommended)
```bash
# Add to package.json (Node.js)
{
  "scripts": {
    "prepare": "husky",
    "pre-commit": "lint-staged"
  },
  "lint-staged": {
    "*.{ts,tsx,js,jsx}": ["eslint --fix", "prettier --write"],
    "*.{json,md,yml}": ["prettier --write"]
  }
}

npm install -D husky lint-staged
npx husky init
```

### Step 4: Run Initial Code Review
```bash
# Use the automated review workflow
# (Assuming you have AI assistant access)
/code-review-automation

# Or manually run checks
npm run lint
npm run typecheck
npm test
```

---

## ⚡ AUTOMATED WORKFLOWS

### 1. Code Review Automation
**Trigger:** Before every PR/deploy

```bash
# Run full automated review
# Uses: .agent/workflows/code-review-automation.md

# AI Assistant command:
/code-review-automation

# Or use specific workflows:
/security-audit
/optimize
/check
```

**What it checks:**
- Static analysis (types, linting)
- Security (vulnerabilities, secrets)
- Performance (bundle size, queries)
- Quality (complexity, duplication)
- Testing (coverage, flakiness)
- Documentation
- Build & deployment readiness

**Output:** Comprehensive audit report + GO/NO-GO decision

---

### 2. Code Generation
````bash
# Generate boilerplate code following .agent standards

# Example: Generate CRUD module
/scaffold User
# - Creates controller (with validation, error handling)
# - Creates model/entity
# - Creates tests
# - Updates routes
# - All following .agent/rules standards!

# Example: Create/enhance features
/enhance "Add Button component"
# - TypeScript types
# - Proper props validation
# - Accessibility built-in
# - Unit tests included
````

---

### 3. Architecture Guidance
```bash
# Get architecture advice based on .agent standards
/schema-first       # Database schema design
/plan               # Architecture & design planning
/brainstorm         # Explore ideas and compare solutions
```

---

## 🔧 CUSTOMIZATION FOR YOUR TEAM

### Add Team-Specific Rules
```bash
# Create custom rule file
.agent/rules/standards/company-specific.md
```

Example content:
```markdown
# Internal Company Standards

## Logging
- Use Winston logger (NOT console.log)
- Format: JSON for production, pretty for dev
- Levels: error, warn, info, debug

## Error Handling  
- Always return proper HTTP status codes
- Error responses format:
  ```json
  {
    "error": {
      "code": "ERROR_CODE",
      "message": "Human-readable message",
      "details": {}
    }
  }
  ```

## Naming Conventions
- API routes: kebab-case `/api/user-profile`
- Database tables: snake_case `user_profiles`
- GraphQL fields: camelCase `userProfile`
```

### Add Team-Specific Agents
```bash
# Create specialized agent for your company
.agent/agents/company-specialist.md
```

---

## 📊 METRICS & CONTINUOUS IMPROVEMENT

### Track Usage Metrics
The `.agent/memory/metrics/tracking.yaml` file automatically tracks:
- Which agents are most used
- Which skills are most valuable
- Time saved per week
- Quality improvements over time

### Monthly Review
```bash
# Check metrics
cat .agent/memory/metrics/tracking.yaml

# Update based on learnings
# Archive old metrics
mv .agent/memory/metrics/tracking.yaml \
   .agent/memory/metrics/archives/2026-01.yaml
```

---

## 🎓 TRAINING YOUR TEAM

### Onboarding New Developers
1. **Read Quick Reference:**
   `.agent/rules/universal-code-standards.md`

2. **Review Framework Standards:**
   - Laravel: `.agent/rules/standards/frameworks/laravel-conventions.md`
   - Inertia+React: `.agent/rules/standards/frameworks/inertia-react-conventions.md`
   - Next.js: `.agent/rules/standards/frameworks/nextjs-conventions.md`

3. **Practice with Generated Code:**
   - Generate components/APIs using .agent
   - Review the generated code
   - Learn patterns used

4. **Run Code Reviews:**
   - Submit PR
   - Run `/code-review-automation`
   - See what AI catches

### Team Standards Meeting
**Monthly:** Review `.agent` metrics
- What's working well?
- What needs improvement?
- New standards to add?
- Deprecated patterns to remove?

---

## 🔄 KEEPING .AGENT UP-TO-DATE

### Quarterly Updates
```bash
# Pull latest from central .agent repo
cd .agent
git pull origin main

# Or manually update changed files
# See: .agent/maintenance/quarterly-tasks.md
```

### Version Control
```bash
# Commit .agent changes
git add .agent/
git commit -m "chore: update .agent standards to v2.1"

# Share across projects
git push origin main
```

---

## 🚦 QUALITY GATES IN CI/CD

### GitHub Actions Example
```yaml
# .github/workflows/quality-gate.yml
name: Quality Gate
on: [pull_request]

jobs:
  quality-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Static Analysis
        run: |
          npm run typecheck
          npm run lint
      
      - name: Security Scan
        run: |
          npm audit --production --audit-level=high
          # gitleaks detect
      
      - name: Tests
        run: npm test -- --coverage
      
      - name: Quality Gate
        run: |
          # Check coverage > 80%
          # Check linting passed
          # Check no security issues
          # If any fail, block PR

      - name: Comment PR
        if: always()
        uses: actions/github-script@v6
        with:
          script: |
            // Post automated review results as PR comment
```

---

## 💡 BEST PRACTICES

### DO
✅ Keep `.agent` in version control (git)  
✅ Update `.agent` quarterly with latest standards  
✅ Run automated review before every deploy  
✅ Use generated code as learning material  
✅ Track metrics to prove value  
✅ Customize for your team's needs

### DON'T  
❌ Modify .agent core files directly (create custom rules instead)  
❌ Skip automated reviews to "save time"  
❌ Ignore .agent warnings without understanding  
❌ Copy .agent partially (copy whole folder)  
❌ Let .agent get outdated (quarterly updates!)

---

## 📚 FULL WORKFLOW EXAMPLE

### Scenario: Building New Feature

```bash
# 1. Start with planning
/plan feature authentication
# → Generates implementation plan following .agent standards

# 2. Generate code
/scaffold auth/login
/scaffold auth/register
/enhance LoginForm

# 3. Write custom logic
# (Following .agent/rules standards)

# 4. Run automated checks
npm run typecheck
npm run lint --fix
npm test

# 5. Before commit
git add .
# Pre-commit hooks run automatically

# 6. Create PR
gh pr create

# 7. CI/CD runs automated review
# → Quality gates check everything

# 8. Before deploy
/code-review-automation
# → Final comprehensive check

# 9. Deploy!
npm run deploy
```

**Time saved:** 40-60% compared to manual coding + reviewing!  
**Quality:** Consistent, secure, performant, tested

---

## 🎯 SUCCESS METRICS

Track these to measure .agent value:

### Development Speed
- Time to implement feature: **-40%**
- Time to deploy: **-30%**  
- Code review time: **-50%**

### Code Quality
- Test coverage: **+25%**
- Security score: **+37%**
- Performance score: **+15%**
- Technical debt: **-60%**

### Consistency
- Code style violations: **-95%**
- Security vulnerabilities: **-80%**
- Production bugs: **-45%**

---

## 🔗 INTEGRATION WITH TOOLS

### IDEs
- **VS Code:** Install recommended extensions from `.vscode/extensions.json`
- **IntelliJ:** Import code styles from `.idea/`
- **Vim/Neovim:** Use ALE or CoC with .agent linting configs

### AI Assistants
- **GitHub Copilot:** Learns from .agent patterns
- **Cursor:** Uses .agent as context
- **Codeium:** Trained on .agent standards

### Project Management
- **Jira:** Link .agent metrics to sprint velocity
- **Linear:** Automated task creation from .agent audits

---

## 🆘 TROUBLESHOOTING

### ".agent checks are too strict!"
→ Adjust thresholds in `.agent/rules/standards/code-quality-standards.md`  
→ Or create team-specific overrides

### "My tech stack isn't supported"
→ .agent auto-detects most stacks  
→ Add custom rules in `.agent/rules/standards/frameworks/yourstack-conventions.md`

### "Automated review is slow"
→ Run specific categories only: `/security-audit`  
→ Or run in parallel in CI/CD

### "Getting false positives"
→ Submit issue to .agent repo  
→ Or add exception in project `.agentignore`

---

## 📖 LEARN MORE

- **Full Automation Guide:** `.agent/workflows/code-review-automation.md`
- **Quality Standards:** `.agent/rules/universal-code-standards.md`
- **Maintenance:** `.agent/maintenance/`
- **Skills Reference:** `.agent/skills/` (59+ skills!)

---

**The `.agent` system evolves with your team!**  
**Keep it updated, track metrics, continuously improve.**

**Happy coding! 🚀**

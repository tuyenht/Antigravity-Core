# 🚀 .agent v3.0 - DEPLOYMENT GUIDE

**Purpose:** Step-by-step guide to deploy .agent in your projects  
**Result:** 95% AI autonomy in development  
**Time:** 2-3 hours (new) or 1-2 hours (existing)

---

## 🎯 QUICK REFERENCE

**Choose your scenario:**

| Situation | Use | Time | Output |
|-----------|-----|------|--------|
| Starting from scratch | **Scenario A** | 2-3 hours | Running project with .agent integrated |
| Existing codebase | **Scenario B** | 1-2 hours | .agent integrated, compliance ≥80% |

**Prerequisites:**
- ✅ Antigravity installed
- ✅ Node.js 20+ / PHP 8.3+ / Python 3.11+ (stack dependent)
- ✅ Git installed
- ✅ 2-3 hours uninterrupted time
- ✅ Antigravity-Core project with working `.agent` folder

**Emergency Help:**
- Health check fails? → [Troubleshooting](#troubleshooting)
- Compliance fails? → [Fix Violations](#step-3-fix-critical-violations-1-3-hours)

---

## 🔀 WHICH SCENARIO AM I?

```
               START HERE
                   │
    ┌──────────────┴──────────────┐
    │                             │
    NO                           YES
Have existing                 Have existing
code?                         code?
    │                             │
    ▼                             ▼
┌────────────┐           ┌───────────────┐
│ SCENARIO A │           │  SCENARIO B   │
│    New     │           │   Existing    │
│  Project   │           │   Project     │
└─────┬──────┘           └───────┬───────┘
      │                          │
      ▼                          ▼
[Generate brief]         [Analyze codebase]
[Initialize]             [Copy .agent]
[Setup stack]            [Fix violations]
[First feature]          [Test feature]
      │                          │
      └──────────┬───────────────┘
                 ▼
          [Daily workflow]
          [Ship features!]
```

---

## 📋 TABLE OF CONTENTS

1. [Scenario A: New Project](#scenario-a-new-project)
2. [Scenario B: Existing Project](#scenario-b-existing-project)
3. [Daily Workflow](#daily-workflow)
4. [Best Practices](#best-practices)
5. [Troubleshooting](#troubleshooting)

---

## SCENARIO A: NEW PROJECT

**Use when:** Starting from scratch, no existing codebase

**Total time:** ⏱️ 2-3 hours | **Steps:** 6

---

### **STEP 1 of 6: Generate PROJECT BRIEF** 

⏱️ **Time:** 30-45 min  
📊 **Progress:** [███░░░] 15% complete  
🎯 **Output:** Complete requirements + tech stack decision

**Instructions:**

1. Open `docs/New-Project-Interview-Prompt.txt`
2. Copy from ✂️ CUT HERE ⬇️ to ✂️ CUT HERE ⬆️
3. Paste into Antigravity
4. Answer 21 questions (be detailed!)
5. Wait for generation (~5 min)

**Expected Output:**

```
✅ docs/PROJECT-BRIEF.md (9 sections, 100% filled)
✅ docs/TECH-STACK-ANALYSIS.md (3 options compared)
✅ docs/GETTING-STARTED.md (setup commands)

Example tech stack recommendation:
- Backend: Laravel 12 (scored 92/100)
- Frontend: React 19 + TypeScript
- Database: PostgreSQL 16
- Reasoning: "Team familiar, rapid MVP, proven stack"
```

⚠️ **Common Mistake:** Skipping questions or being too vague  
✅ **Best Practice:** Provide specific examples when answering  
❌ **Avoid:** "Just a web app" → ✅ "E-commerce for handmade goods, 50 products at launch"

**Success Indicator:** All 3 files created in `docs/` ✅

---

### **STEP 2 of 6: Initialize Project**

⏱️ **Time:** 10 min  
📊 **Progress:** [████░░] 30% complete  
🎯 **Output:** Project folder with .agent system operational

**Instructions:**

```powershell
# Create project directory
mkdir my-project
cd my-project

# Initialize git
git init

# Install Antigravity-Core
agi                                    # Requires global setup (see Note below)

# Verify .agent health
.\.agent\scripts\health-check.ps1
```

**Note:** If `agi` not available, run first:
```powershell
irm "https://raw.githubusercontent.com/tuyenht/Antigravity-Core/main/.agent/scripts/install-global.ps1" | iex
```

**Expected Output:**

```
.agent Health Check Report
==========================
Status: HEALTHY ✅
Compliance: 100%
Agents: 12 operational
Scripts: All functional
```

⚠️ **Common Mistake:** Copying `.agent` into subdirectory  
✅ **Correct structure:**
```
my-project/
├── .agent/          ← At root level
├── .git/
└── (empty)
```
❌ **Wrong:**
```
my-project/
└── src/
    └── .agent/      ← TOO NESTED!
```

**Checkpoint:** `.\. agent\scripts\health-check.ps1` shows HEALTHY ✅

---

### **STEP 3 of 6: Setup Tech Stack**

⏱️ **Time:** 15-30 min (varies by stack)  
📊 **Progress:** [█████░] 50% complete  
🎯 **Output:** Project runs on localhost

**Instructions:**

Use commands from `GETTING-STARTED.md` generated in Step 1.

**Laravel + React example:**
```bash
composer create-project laravel/laravel .
composer require inertiajs/inertia-laravel
npm install react react-dom @vitejs/plugin-react
npm install -D tailwindcss
php artisan migrate
npm run dev
```

**Expected Output:**

```
✅ Composer dependencies installed
✅ Laravel booted successfully
✅ Vite dev server running on http://localhost:5173
✅ App accessible at http://localhost:8000

Test: Open browser → http://localhost:8000
Should see: Laravel welcome page
```

⚠️ **Common Pitfall:** Missing environment variables  
✅ **Fix:** Copy `.env.example` → `.env`, run `php artisan key:generate`

**Checkpoint:** App loads in browser without errors ✅

---

### **STEP 4 of 6: First Feature with .agent**

⏱️ **Time:** 1-2 hours  
📊 **Progress:** [██████] 75% complete  
🎯 **Output:** Working authentication with tests

**Prompt to Antigravity:**

```
backend-specialist + frontend-specialist,

Build user authentication:
- Login/Register/Logout
- Protected routes (dashboard requires auth)
- Role-based access (user/admin)
- Email verification
- Password reset

Follow STANDARDS.md. Write tests for all flows.
```

**What Antigravity will do (automatically):**

1. ✅ Backend: Controllers, models, migrations, middleware
2. ✅ Frontend: Login/register forms, protected layouts
3. ✅ Tests: 80%+ coverage (feature + unit)
4. ✅ Documentation: API docs, README updates
5. ✅ Self-validate: AOC runs, fixes lint/type/test errors

**Expected Output:**

```yaml
Files created/modified: ~25 files
Tests: 18 tests, all passing
Coverage: 87%
Quality: 88/100
Time: 45-90 min (AI-automated)

Example files:
- app/Http/Controllers/Auth/LoginController.php
- app/Models/User.php (roles added)
- resources/js/Pages/Auth/Login.tsx
- tests/Feature/Auth/LoginTest.php
```

⚠️ **If Antigravity escalates:** Review RBA output - there's a valid concern  
✅ **Normal:** Agent implements → AOC validates → All green  
❌ **Red flag:** "Force PROCEED" when agent says ESCALATE

**Checkpoint:** Run `php artisan test` → All passing ✅

---

### **STEP 5 of 6: Validate Quality**

⏱️ **Time:** 10-15 min  
📊 **Progress:** [███████] 90% complete  
🎯 **Output:** All quality gates pass

**Run all checks:**

```bash
# 1. Tests
php artisan test
npm test

# Expected: All passed, coverage ≥80%

# 2. Lint
./vendor/bin/pint --test
npm run lint

# Expected: 0 errors

# 3. Type check
npx tsc --noEmit

# Expected: 0 errors

# 4. Security
composer audit
npm audit

# Expected: 0 vulnerabilities
```

**Expected Output:**

```
✅ Tests: 18/18 passed, coverage 87%
✅ Lint: 0 errors
✅ Types: 0 errors  
✅ Security: 0 vulnerabilities

Quality Report (from AOC):
- Code quality: 88/100
- Test coverage: 87%
- Documentation: Complete
- STANDARDS compliance: 100%
```

⚠️ **If tests fail:** Check AOC report in `.agent/reports/` for auto-fix attempts  
✅ **All green:** Ready to commit  
❌ **Persistent failures:** Run `.\\.agent\\scripts\\validate-compliance.ps1` for diagnosis

**Checkpoint:** All 4 checks pass ✅

---

### **STEP 6 of 6: Continue Building**

⏱️ **Time:** Ongoing  
📊 **Progress:** [████████] 100% complete - Ready to ship! 🚀  
🎯 **Output:** Production-ready workflow established

**For each new feature:**

```
1. Define feature (5 min)
   ↓
2. Antigravity implements (30-90 min, automated)
   ↓
3. AOC validates (3 min, automated)
   ↓
4. You review (5-10 min)
   ↓
5. Commit (2 min)
```

**Velocity:** 3-5 features/day with .agent

**Next features to build:**
- Blog posts CRUD
- User profiles  
- File uploads
- Admin dashboard
- Email notifications

**Success:** You've deployed .agent! Now shipping 10x faster 🎊

---

## SCENARIO B: EXISTING PROJECT

**Use when:** Adding .agent to current codebase

**Total time:** ⏱️ 1.5-3 hours | **Steps:** 6

---

### **STEP 1 of 6: Generate PROJECT BRIEF**

⏱️ **Time:** 15-20 min  
📊 **Progress:** [███░░░] 15% complete  
🎯 **Output:** Complete codebase analysis

**Instructions:**

1. Open `docs/Analyze-Existing-Project-Prompt.txt`
2. Copy from ✂️ CUT HERE ⬇️ to ✂️ CUT HERE ⬆️
3. Replace `[PROJECT_PATH]` with actual path (e.g., `c:\Projects\MyApp`)
4. Paste into Antigravity
5. Wait for analysis (15-20 min)

**Expected Output:**

```
✅ docs/PROJECT-BRIEF.md
   - 9 sections filled
   - Current state: Quality 62/100, Coverage 45%
   - 127 files, 18K LOC analyzed

✅ docs/PROJECT-CONVENTIONS.md
   - Naming patterns detected
   - Architecture: Controller→Service→Repository
   - Test framework: Pest

✅ docs/PERFORMANCE-OPTIMIZATION-RECOMMENDATIONS.md
   - 8 N+1 queries found
   - 5 missing indexes
   - Immediate fixes (2 hours effort)
```

⚠️ **If analysis fails:** Check project path is absolute and accessible  
✅ **Analysis handles:** Missing files gracefully (documents gaps)  
❌ **Won't work:** Relative paths or inaccessible network drives

**Success Indicator:** All 3 files in `docs/` with actual data (no placeholders) ✅

---

### **STEP 2 of 6: Copy .agent to Project**

⏱️ **Time:** 5 min  
📊 **Progress:** [████░░] 25% complete  
🎯 **Output:** .agent integrated, compliance assessed

**Instructions:**

```powershell
cd your-existing-project

# Install Antigravity-Core
agi                                    # Requires global setup (see Note below)

# Run health check
.\.agent\scripts\health-check.ps1

# Run compliance check
.\.agent\scripts\validate-compliance.ps1
```

**Note:** If `agi` not available, run first:
```powershell
irm "https://raw.githubusercontent.com/tuyenht/Antigravity-Core/main/.agent/scripts/install-global.ps1" | iex
```

**Expected Output:**

```
STANDARDS Compliance Report:
============================
✅ Linting: PASS
❌ Type Hints: FAIL (40% missing)
❌ Test Coverage: FAIL (45% vs 80% required)
✅ Security: PASS
❌ Code Quality: 62/100 (below 80 threshold)

Priority Fixes:
1. Increase test coverage (high priority)
2. Add type hints (medium priority)
3. Refactor complex files (low priority)
```

⚠️ **Common issue:** `.agent` copied INTO existing `.git` folder  
✅ **Correct:**
```
project/
├── .agent/          ← Sibling to .git
├── .git/
├── app/
└── ...
```

**Checkpoint:** Compliance report generated ✅

---

### **STEP 3 of 6: Fix Critical Violations**

⏱️ **Time:** 1-3 hours (depends on violations)  
📊 **Progress:** [█████░] 50% complete  
🎯 **Output:** Compliance ≥80%

**Fix test coverage (highest priority):**

```
Prompt:
"test-engineer,

Increase test coverage from 45% to 80%:
- Priority: Services (app/Services/**) and Controllers
- Use existing framework: Pest
- Follow patterns in PROJECT-CONVENTIONS.md
- Focus on: Happy path + edge cases

Target: 80%+ coverage."
```

**Expected:** Antigravity adds ~50-70 tests over 30-60 min

**Fix type hints (if PHP):**

```
Prompt:
"self-correction-agent,

Add type hints to all methods in:
- app/Services/**
- app/Http/Controllers/**

Use PHP 8.3 syntax (typed properties, union types).
Run PHPStan after to verify."
```

**Progress check:**

```bash
# After fixes, re-run compliance
.\.agent\scripts\validate-compliance.ps1

# Expected:
# ✅ Test Coverage: 82% (PASS)
# ✅ Type Hints: 95% (PASS)
# ✅ Code Quality: 78/100 (approaching threshold)
```

⚠️ **Don't skip this:** Low compliance = poor .agent performance  
✅ **Target:** ≥80% on all metrics before proceeding

**Checkpoint:** Compliance report shows ≥80% ✅

---

### **STEP 4 of 6: Test with Small Feature**

⏱️ **Time:** 30-45 min  
📊 **Progress:** [██████] 65% complete  
🎯 **Output:** Verification .agent follows project patterns

**Test prompt:**

```
Prompt:
"backend-specialist,

Add health check endpoint: GET /api/health

Returns JSON:
{
  "status": "healthy",
  "database": "connected",
  "cache": "operational", 
  "queue": "running"
}

Follow existing project patterns from PROJECT-CONVENTIONS.md."
```

**Verify .agent:**

- ✅ Uses project naming conventions (check controller name)
- ✅ Follows architecture (check service layer used)
- ✅ Matches test patterns (check test file structure)
- ✅ Updates API docs (check docs/ folder)

**Expected Output:**

```
✅ app/Http/Controllers/Api/HealthController.php
✅ app/Services/HealthCheckService.php
✅ routes/api.php (route added)
✅ tests/Feature/Api/HealthControllerTest.php
✅ docs/api.md (endpoint documented)

All following existing project patterns!
```

⚠️ **If patterns don't match:** Update PROJECT-CONVENTIONS.md with missing details  
✅ **Success:** .agent-generated code looks like YOUR code

**Checkpoint:** Health endpoint works + tests pass ✅

---

### **STEP 5 of 6: Document Conventions**

⏱️ **Time:** 30-60 min  
📊 **Progress:** [███████] 80% complete  
🎯 **Output:** PROJECT-CONVENTIONS.md complete

**Edit `.agent/docs/PROJECT-CONVENTIONS.md`:**

```markdown
# Project Conventions

## Naming
- Controllers: Singular (UserController, not UsersController)
- Services: DomainService suffix (UserService, OrderService)
- Repositories: DomainRepository (UserRepository)

## Architecture
Controller → Service → Repository → Model
- Controllers: Max 5 lines per method, validation only
- Services: Business logic
- Repositories: Database queries only

## Testing
- Framework: Pest
- Location: tests/Feature/ (controllers), tests/Unit/ (services)
- Pattern: Arrange-Act-Assert
- Database: RefreshDatabase trait

## API
- Format: JSON:API spec
- Auth: JWT via Sanctum
- Versioning: /api/v1/ prefix
- Errors: Standard format with error codes

## Git
- Branch: feature/TASK-123-description
- Commits: Conventional (feat:, fix:, docs:)
```

**Tell Antigravity:**
```
"All agents: Read .agent/docs/PROJECT-CONVENTIONS.md before ANY code generation."
```

**Checkpoint:** Conventions documented ✅

---

### **STEP 6 of 6: Gradual Integration**

⏱️ **Time:** 2-4 weeks  
📊 **Progress:** [████████] 100% complete - Fully integrated! 🚀  
🎯 **Output:** 90%+ autonomy achieved

**Integration timeline:**

**Week 1:** (2-3 small features)
- Focus: Verify .agent alignment
- Velocity: 2-3 features
- Fix: Any pattern mismatches

**Week 2-3:** (5-7 features/week)
- Focus: Increase complexity
- Velocity: 5-7 features/week
- Monitor: Autonomy rate

**Week 4:** (Full velocity)
- Focus: Ship at scale
- Velocity: 8-12 features/week
- Autonomy: 95%

**Track metrics:**

```
Autonomy % = (AI features / Total features) × 100
Target: ≥90%

Example after 4 weeks:
- Features delivered: 28
- Manual fixes needed: 3
- Autonomy: 90.3% ✅
```

**Success:** .agent shipping features, you shipping products! 🎊

---

## DAILY WORKFLOW

### **Morning Routine** ⏱️ 10 min

```bash
# Pull latest code
git pull

# Health check
.\.agent\scripts\health-check.ps1

# Review yesterday's AOC reports
ls .agent/reports/ | Select-Object -Last 5
```

---

### **Feature Development** ⏱️ 1-3 hours per feature

**1. Define (5 min)**
```
"orchestrator-agent, analyze: [feature description]
Provide implementation plan and required agents."
```

**2. Implement (30-90 min - Automated)**  
Antigravity + agents work automatically

**3. AOC Validate (3 min - Automated)**  
Self-correction runs automatically

**4. Review (5-10 min - You)**  
Check AOC report, test manually

**5. Commit (2 min - You)**
```bash
git add .
git commit -m "feat: [feature] (AI-generated)"
git push
```

**Breakdown:** 95% .agent, 5% you

---

### **Bug Fixing** ⏱️ 15-30 min per bug

```
Prompt:
"debugger + [specialist],

Bug: [error message]
Reproduce: [steps]
Expected: [behavior]
Actual: [behavior]

Debug, fix, add regression test."
```

---

## BEST PRACTICES

### ✅ **DO's**

**1. Trust but Verify**
- Let .agent implement (95% autonomy)
- Review AOC reports (5-10 min)
- Manual test critical paths

**2. Clear Requirements**
- ✅ Good: "JWT auth with email verification + password reset"
- ❌ Bad: "Add auth" (too vague)

**3. Use RBA for Risky Changes**
- "database-architect, migrate MySQL to PostgreSQL. RBA REQUIRED."

**4. Review AOC Reports**
- Target: Quality ≥80/100
- Address: High-priority refactors

**5. Update PROJECT-CONVENTIONS.md**
- Document: Project-specific patterns
- Keep: .agent aligned with your style

---

### ❌ **DON'Ts**

**1. Vague Prompts**
- ❌ "Fix bug"
- ✅ "debugger, fix TypeError in UserService::getPosts when user has no posts"

**2. Skip Quality Gates**
- ❌ Deploy without tests
- ✅ Always verify: tests pass, lint clean, coverage ≥80%

**3. Ignore Escalations**
- ❌ Force PROCEED when agent says ESCALATE
- ✅ Review carefully (agent found risk)

**4. Disable AOC**
- ❌ Skip to save 3 min
- ✅ AOC catches 80% issues automatically

**5. Over-Optimize Early**
- ❌ Tweak .agent for hours before use
- ✅ Use first, optimize based on real patterns

---

## SUCCESS METRICS

**After 1 month:**

```json
{
  "features_delivered": 40-60,
  "autonomy_rate": "90-95%",
  "quality_avg": "85-90/100",
  "coverage_avg": "80-90%",
  "time_per_feature": "1-2h (vs 4-6h manual)"
}
```

**ROI:**
- 3-4x faster development
- Consistent 85+ quality
- Complete documentation
- Automated testing

---

## TROUBLESHOOTING

**"Agent doesn't follow conventions"**  
→ Document in PROJECT-CONVENTIONS.md  
→ Reference explicitly: "Follow .agent/docs/PROJECT-CONVENTIONS.md"

**"Coverage keeps failing"**  
→ Set threshold in config  
→ Ask test-engineer to focus untested areas

**"Quality below 80"**  
→ Run refactor-agent on complex files  
→ Break down files >300 lines

**"Agent escalates often"**  
→ Improve prompt clarity  
→ Add more context  
→ Review RBA for concerns

---

## NEXT STEPS

**After successful deployment:**

1. ✅ Share `.agent/` with team (Git)
2. ✅ Create project skills (`.agent/skills/`)
3. ✅ Monitor velocity & quality
4. ✅ Optimize based on usage
5. ✅ Ship 10x faster! 🚀

---

**Version:** 3.0 Enhanced  
**Score:** 95/100 ⭐⭐⭐⭐⭐  
**Updated:** 2026-01-17

**🎊 Ready to deploy .agent and ship amazing software! 🎊**

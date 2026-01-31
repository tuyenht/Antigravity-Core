---
description: Generate and view DX Analytics dashboard. Track velocity, automation ROI, quality metrics. Industry standard (Vercel, Netflix).
turbo-all: false
---

# DX Analytics Workflow

> Track developer experience metrics for data-driven improvement

---

## 📊 Quick Dashboard View

**Generate dashboard:**
```bash
# View current DX metrics
.agent/scripts/dx-analytics.ps1 --dashboard

# View specific period
.agent/scripts/dx-analytics.ps1 --dashboard --period week

# Export to markdown
.agent/scripts/dx-analytics.ps1 --dashboard --export dx-report.md
```

---

## 📋 Workflow Steps

### Step 1: Review Current DX Score

**Run dashboard command:**
```bash
.agent/scripts/dx-analytics.ps1 --dashboard
```

**Output example:**
```markdown
# 📊 DX Analytics Dashboard

**Period:** Jan 13-19, 2026
**DX Score:** 87/100 (+5 vs last week) ⬆️

## ⚡ Velocity
| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Tasks/Day | 7.2 | 5 | ✅ |
| Avg Duration | 25m | 30m | ✅ |
| Lines Generated | 2,450 | - | - |

## 🤖 Automation ROI
| Agent | Uses | Time Saved |
|-------|------|------------|
| code-generator | 34 | 17h |
| auto-healing | 89 | 7.4h |
| ai-code-reviewer | 23 | 3.8h |

**Total Time Saved This Week:** 28.2 hours 🎉

## 📈 Quality Trend
| Metric | Current | Last Week | Trend |
|--------|---------|-----------|-------|
| Test Coverage | 82% | 78% | ⬆️ +4% |
| Standards | 100% | 100% | ➡️ |
| Perf Violations | 0 | 2 | ⬆️ |

## 💡 Recommendations
1. Test coverage improved! Keep using test generator
2. Performance violations down - budgets working
```

---

### Step 2: Identify Bottlenecks

**Check for issues:**
```bash
.agent/scripts/dx-analytics.ps1 --bottlenecks
```

**Example output:**
```markdown
## 🔍 Bottlenecks Detected

1. ⚠️ triage-agent routing accuracy: 82% (target: 90%)
   - Misroutes: "deploy" requests going to devops instead of deployment workflow
   - Action: Update triage patterns

2. ⚠️ test-engineer avg response: 8.2s (target: 5s)
   - Slow on large test suites
   - Action: Consider test parallelization

3. ℹ️ security-auditor least used (2 times this week)
   - May be underutilized
   - Action: Schedule regular security reviews
```

---

### Step 3: Review Time Saved

**Automation ROI report:**
```bash
.agent/scripts/dx-analytics.ps1 --roi
```

**Example output:**
```markdown
## 🤖 Automation ROI Report

**Period:** This Month

### By Agent
| Agent | Uses | Time Saved | Value* |
|-------|------|------------|--------|
| code-generator | 156 | 78h | $7,800 |
| auto-healing | 423 | 35h | $3,500 |
| ai-code-reviewer | 98 | 16h | $1,600 |
| triage-agent | 234 | 12h | $1,200 |

*Estimated at $100/hour developer time

### Total
- **Uses:** 911 agent invocations
- **Time Saved:** 141 hours
- **Estimated Value:** $14,100

### Trend
- +23% vs last month
- Projection: 169 hours/month by Q2
```

---

### Step 4: Track Quality Trends

**Quality report:**
```bash
.agent/scripts/dx-analytics.ps1 --quality
```

**Example output:**
```markdown
## 📈 Quality Metrics (12-week trend)

### Test Coverage
Week 1: 65% ████████░░
Week 4: 72% █████████░
Week 8: 78% ██████████
Week 12: 82% ██████████

### Standards Compliance
Week 1: 85% █████████░
Week 12: 100% ██████████ ✅

### Performance Budget Violations
Week 1: 8 violations
Week 12: 0 violations ✅
```

---

### Step 5: Act on Recommendations

**Get AI recommendations:**
```bash
.agent/scripts/dx-analytics.ps1 --recommendations
```

**Example output:**
```markdown
## 💡 AI Recommendations

Based on your metrics, here are prioritized improvements:

### HIGH Priority
1. **Improve triage-agent accuracy** (82% → 90%)
   - Add patterns for "deploy" vs "deployment" disambiguation
   - Expected impact: +5% routing accuracy

### MEDIUM Priority  
2. **Increase code-generator usage**
   - Only 30% of CRUD tasks use generator
   - Expected impact: Save 10+ hours/week

3. **Schedule security audits**
   - security-auditor underutilized
   - Recommend: Weekly automated security scan

### LOW Priority
4. **Optimize test-engineer response time**
   - Current: 8.2s, Target: 5s
   - Consider: Parallel test execution
```

---

## 📊 Metrics Explained

### DX Score (0-100)
```
Composite score calculated from:
- Velocity: 25% (tasks completed, speed)
- Automation: 25% (agent usage, time saved)
- Quality: 25% (coverage, compliance)
- Effectiveness: 25% (accuracy, success rate)
```

### Velocity Metrics
```
- Tasks/Day: How many tasks completed
- Avg Duration: Time per task
- Lines Generated: Code auto-generated
```

### Automation ROI
```
- Agent usage count
- Time saved per use
- Total hours saved
- Estimated dollar value
```

### Quality Metrics
```
- Test coverage %
- Standards compliance %
- Performance violations
- Lint/type errors
```

---

## 🔧 Configuration

**Config file:** `.agent/dx-analytics.yml`

**Key settings:**
```yaml
tracking:
  frequency:
    real_time: [tasks_completed]
    daily: [dx_score, test_coverage]
    weekly: [agent_success_rate]
    
alerts:
  triggers:
    - metric: dx_score
      condition: "< 70"
      severity: warning
```

---

## 📖 Related

- [dx-analytics.yml](file:///.agent/dx-analytics.yml) - Full config
- [performance-budget-enforcement](file:///.agent/workflows/performance-budget-enforcement.md)
- [ai-code-reviewer](file:///.agent/agents/ai-code-reviewer.md)

---

**Created:** 2026-01-19  
**Industry Standard:** Vercel DX Dashboard, Netflix Platform Metrics  
**Impact:** Data-driven system improvement

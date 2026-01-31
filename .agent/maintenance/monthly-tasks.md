# Monthly Maintenance Tasks

**Purpose:** Comprehensive monthly review and optimization  
**Schedule:** 1st week of each month  
**Time Commitment:** 2-3 hours

---

## 1. Comprehensive Health Audit 🏥

### Run Full System Health Check

Use the ready-prompts.md Health Check prompt:

```
Với vai trò là System Health Auditor, audit toàn bộ .agent/:

1. FRAMEWORK STANDARDS
   Score each (0-100): Laravel, Django, FastAPI, React, Vue, Next.js, Mobile
   Check: Completeness, currency, examples, anti-patterns

2. SECURITY POSTURE
   Current: 95/100 (verify)
   Check: OWASP, headers, API security, CI/CD security

3. PERFORMANCE PATTERNS
   Current: 92/100 (verify)
   Check: Octane, React compiler, Hermes, caching

4. DOCUMENTATION QUALITY
   Current: 97/100 (verify)
   Check: Accessibility, testing, monitoring, DevOps

5. SKILLS ECOSYSTEM
   Count skills, identify gaps, usage patterns

6. AGENT EFFECTIVENESS
   Activation rates, success rates, feedback

Output: Comprehensive health report with scores
```

### Tasks:
- [ ] Run comprehensive audit
- [ ] Document all scores
- [ ] Identify any regressions (scores dropped)
- [ ] Create action plan for improvements
- [ ] Set targets for next month

---

## 2. Review User Feedback 📊

### Analyze Feedback Data

**From:** `memory/feedback.yaml`

- [ ] **Review agent effectiveness ratings**
  - Overall score trends
  - Individual agent scores
  - Category breakdowns (planning, implementation, etc.)

- [ ] **Analyze skill usefulness scores**
  - Highly valuable skills (9-10/10)
  - Underutilized skills (5-6/10)
  - Skills to retire (<5/10)

- [ ] **Review workflow effectiveness**
  - Most used workflows
  - Rarely used workflows
  - Success rates

- [ ] **Process suggested improvements**
  - High priority suggestions
  - Quick wins vs major projects
  - Roadmap integration

### Output:
- [ ] Feedback summary report
- [ ] Top 3 improvement priorities
- [ ] Quick wins list (can do this month)
- [ ] Long-term roadmap updates

---

## 3. Update Tech Radar 🔄

### Review Technology Decisions

**File:** `memory/tech-radar.yaml`

- [ ] **ADOPT → Verify still recommended**
  - Laravel 12, React 19, Next.js 16, etc.
  - Any technologies to downgrade?

- [ ] **TRIAL → Promote or demote**
  - React 19 Compiler (ready to ADOPT?)
  - Terraform (ADOPT or back to ASSESS?)
  - OpenTelemetry (decision made?)

- [ ] **ASSESS → Move to TRIAL or HOLD**
  - Astro, Rust, Cloudflare Workers
  - Any worth trialing this month?

- [ ] **HOLD → Reassess or continue holding**
  - Angular, MongoDB (for transactional)
  - Still valid reasons to hold?

- [ ] **RETIRE → Confirm progress**
  - jQuery, Webpack, Class Components
  - Migration deadlines on track?

- [ ] **Add new technologies**
  - Any emerging techs to watch?
  - Industry trends to follow?

### Output:
- [ ] Updated tech-radar.yaml
- [ ] Technology decision log
- [ ] Team communication on changes

---

## 4. Archive Old Learnings 📦

### Clean Up Memory System

**Files:** All in `memory/`

- [ ] **learning-patterns.yaml**
  - Archive patterns older than 12 months
  - Keep only reusable, still-relevant patterns
  - Move historical data to archive/

- [ ] **feedback.yaml**
  - Summarize old feedback
  - Keep recent 6 months detailed
  - Archive older entries

- [ ] **tech-radar.yaml**
  - Clean up retired technologies
  - Archive decision history

- [ ] **capability-boundaries.yaml**
  - Remove stale confidence data
  - Update with recent project experience
  - Recalibrate domain scores

### Output:
- [ ] Archived old data to memory/archive/YYYY-MM/
- [ ] Memory files clean and current
- [ ] Historical context preserved

---

## 5. Metrics Analysis 📈

### Review Performance Metrics

**File:** `memory/metrics/tracking.yaml`

- [ ] **Agent activation frequency**
  - Trending up or down?
  - Which agents most valuable?
  - Any never activated?

- [ ] **Skill usage statistics**
  - Top 10 most used skills
  - Bottom 10 least used
  - New skills adoption rate

- [ ] **Workflow success rates**
  - Which workflows work best?
  - Which need improvement?
  - User satisfaction scores

- [ ] **Time-to-completion metrics**
  - Average time per task type
  - Bottlenecks identified?
  - Efficiency trends

### Output:
- [ ] Monthly metrics report
- [ ] Trend analysis
- [ ] Recommendations for next month

---

## 6. Documentation Updates 📝

### Keep Documentation Current

- [ ] **Update README files**
  - .agent/README.md
  - memory/README.md
  - Any new directories

- [ ] **Review quick-reference.md**
  - Update scores
  - Refresh commands
  - Add new prompts

- [ ] **Update walkthrough.md**
  - Add month's achievements
  - Document major changes
  - Keep success metrics current

- [ ] **Refresh ready-prompts.md**
  - Add new useful prompts
  - Remove outdated ones
  - Organize by category

---

## 7. Action Plan for Next Month 🎯

### Set Goals

- [ ] **Based on health audit:**
  - Target score improvements
  - Critical gaps to fill

- [ ] **Based on feedback:**
  - Top 3 improvements to implement
  - Quick wins to complete

- [ ] **Based on tech radar:**
  - Technologies to trial
  - Migrations to execute

- [ ] **Based on metrics:**
  - Efficiency improvements
  - Coverage expansions

### Output:
- [ ] Next month's priorities document
- [ ] Specific, measurable goals
- [ ] Resource allocation plan

---

## Checklist Summary

**Before month starts:**
- [ ] Schedule 2-3 hour block in 1st week

**During monthly review:**
- [ ] Run comprehensive health audit (30 min)
- [ ] Review user feedback (30 min)
- [ ] Update tech radar (30 min)
- [ ] Archive old learnings (20 min)
- [ ] Analyze metrics (30 min)
- [ ] Update documentation (20 min)
- [ ] Create action plan (20 min)

**After review:**
- [ ] Share summary with team
- [ ] Update task.md with priorities
- [ ] Schedule follow-up reviews

---

## Success Metrics

**Monthly review is successful if:**
- ✅ Health scores maintained or improved
- ✅ User feedback analyzed and actioned
- ✅ Tech decisions documented
- ✅ Memory system clean and organized
- ✅ Clear priorities for next month
- ✅ Time to complete: 2-3 hours max

---

**Next Monthly Review:** First week of next month  
**Last Completed:** [Date]  
**Overall System Health:** [Score]/100

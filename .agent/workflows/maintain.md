---
description: Bảo trì định kỳ theo lịch
---

# Maintenance Workflow

Run appropriate maintenance tasks based on current schedule.

## Usage

```
/maintain [schedule]
```

**Arguments:**
- `schedule`: weekly | monthly | quarterly | auto (default: auto)

**Auto mode** determines current maintenance cycle and runs appropriate tasks.

---

## Workflow Steps

### 1. Determine Maintenance Schedule

// turbo

**Agent:** `orchestrator`  
**Skills:** `clean-code, lint-and-validate, testing-patterns`
Run:
```bash
# If schedule=auto, determine current cycle
# Based on date and last run
```

### 2. Run Weekly Maintenance (Week 1-4)

**Week 1: Framework Updates**
- [ ] Check Laravel, React, Next.js, Vue updates
- [ ] Update framework convention files
- [ ] Document changes in framework-update-changelog.md

**Week 2: Skill Enhancement**
- [ ] Review most-used skills from metrics/tracking.yaml
- [ ] Identify skill gaps
- [ ] Plan 2-3 new skills

**Week 3: Agent Optimization**
- [ ] Review agent activation metrics
- [ ] Update agent knowledge bases
- [ ] Refine agent prompts

**Week 4: Quality Assurance**
- [ ] Run full health check
- [ ] Fix critical issues
- [ ] Update documentation

### 3. Run Monthly Maintenance (1st week of month)

- [ ] Comprehensive health audit
- [ ] Review user feedback (memory/feedback.yaml)
- [ ] Update tech radar (memory/tech-radar.yaml)
- [ ] Archive old learnings
- [ ] Analyze metrics (memory/metrics/tracking.yaml)
- [ ] Update documentation
- [ ] Create next month action plan

### 4. Run Quarterly Maintenance (Jan/Apr/Jul/Oct)

- [ ] Major version updates (Laravel, React, Next.js, etc.)
- [ ] Complete skill ecosystem review
- [ ] Agent restructuring (if needed)
- [ ] Capability boundaries recalibration
- [ ] Strategic planning for next quarter
- [ ] External validation against industry standards
- [ ] Trend analysis (3 months)

### 5. Document Results

Create maintenance report:

```markdown
# Maintenance Report - [Date]

**Type:** [Weekly/Monthly/Quarterly]
**Duration:** [X] hours

## Tasks Completed
- [ ] Task 1
- [ ] Task 2
...

## Key Findings
- Finding 1
- Finding 2

## Actions Taken
- Action 1
- Action 2

## Metrics Updated
- Updated tracking.yaml
- New scores: [list]

## Next Steps
- [ ] Follow-up 1
- [ ] Follow-up 2

## Notes
[Any additional notes]
```

Save to: `.agent/maintenance/reports/YYYY-MM-DD-[type].md`

### 6. Update Metrics

// turbo

**Agent:** `orchestrator`  
**Skills:** `clean-code, lint-and-validate, testing-patterns`
Update `memory/metrics/tracking.yaml`:
- Execution time
- Tasks completed
- Issues found and fixed
- Score changes

### 7. Commit Changes

// turbo

**Agent:** `orchestrator`  
**Skills:** `clean-code, lint-and-validate, testing-patterns`
Commit all changes:
```bash
git add .agent/
git commit -m "chore: [weekly/monthly/quarterly] maintenance - [date]"
```

---

## Success Criteria

**Weekly maintenance successful if:**
- ✅ All checklist items completed
- ✅ Duration < 1 hour
- ✅ No critical issues found
- ✅ Metrics updated

**Monthly maintenance successful if:**
- ✅ Health scores maintained/improved
- ✅ Feedback analyzed and actioned
- ✅ Tech radar current
- ✅ Duration < 3 hours

**Quarterly maintenance successful if:**
- ✅ Major versions evaluated
- ✅ Strategic plan created
- ✅ Capabilities recalibrated
- ✅ Duration < 6 hours

---

## Examples

### Run weekly maintenance (auto-detect week)
```
/maintain weekly
```

### Run monthly maintenance
```
/maintain monthly
```

### Run quarterly maintenance
```
/maintain quarterly
```

### Auto-detect and run appropriate maintenance
```
/maintain
```

---

## Files Used

**Checklists:**
- `.agent/maintenance/weekly-checklist.md`
- `.agent/maintenance/monthly-tasks.md`
- `.agent/maintenance/quarterly-tasks.md`

**Metrics:**
- `.agent/memory/metrics/tracking.yaml`

**Artifacts:**
- `.agent/maintenance/reports/`

---

## Maintenance Schedule

```
Week 1 of Month: Framework Updates
Week 2 of Month: Skill Enhancement
Week 3 of Month: Agent Optimization
Week 4 of Month: Quality Assurance

1st Week of Month: Monthly Tasks (in addition to weekly)

January/April/July/October: Quarterly Tasks (in addition to monthly)
```

---

## Notes

- Maintenance should be proactive, not reactive
- Regular small maintenance prevents major issues
- Track trends, not just snapshots
- Document everything for future reference
- Use metrics to guide improvements

---

**Created:** 2026-01-17  
**Last Run:** [Never]  
**Next Scheduled:** [Auto-detect]

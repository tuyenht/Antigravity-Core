# Weekly Maintenance Checklist

**Purpose:** Rotating weekly maintenance tasks to keep Antigravity optimized  
**Schedule:** 4-week rotation  
**Time Commitment:** 30-60 minutes per week

---

## Week 1: Framework Updates 🔄

**Focus:** Keep framework standards current with latest versions

### Tasks:
- [ ] **Check Laravel updates**
  - Visit https://laravel.com/docs/releases
  - Check current version vs documented version
  - Review breaking changes
  - Update `laravel-conventions.md` if needed

- [ ] **Check React/Inertia updates**
  - Check React latest: https://react.dev/
  - Check Inertia latest: https://inertiajs.com/
  - Review `inertia-react-conventions.md`
  - Update React 19 compiler patterns if needed

- [ ] **Check Next.js updates**
  - Check latest: https://nextjs.org/blog
  - Currently on: Next.js 16 (LTS)
  - Review `nextjs-conventions.md`
  - Update if minor version released

- [ ] **Check Vue updates**
  - Check Vue 3 latest: https://vuejs.org/
  - Review `vue3-conventions.md`
  - Update composition API patterns if needed

- [ ] **Check Mobile frameworks**
  - React Native: https://reactnative.dev/
  - Flutter: https://flutter.dev/
  - Update conventions if major changes

### Output:
- [ ] Updated framework convention files (if needed)
- [ ] Changelog entry in `framework-update-changelog.md`
- [ ] Tech radar updated with version numbers

### Success Criteria:
✅ All framework versions verified  
✅ No breaking changes blocking updates  
✅ Documentation reflects current best practices

---

## Week 2: Skill Enhancement 🎯

**Focus:** Improve skill ecosystem based on actual usage

### Tasks:
- [ ] **Review most-used skills**
  - Check `memory/metrics/tracking.yaml`
  - Identify top 5 most-activated skills
  - Review their quality and completeness

- [ ] **Check for skill gaps**
  - Compare current projects to available skills
  - Review user requests for patterns
  - Identify missing skill areas

- [ ] **Plan new skills**
  - Create list of needed skills
  - Prioritize by impact and frequency
  - Draft skill outlines for top 2-3

- [ ] **Deprecate unused skills**
  - Identify skills with 0 usage in 3+ months
  - Archive or remove low-value skills
  - Keep skill count manageable

### Output:
- [ ] Skill usage report
- [ ] 2-3 new skill outlines
- [ ] Deprecated skills list
- [ ] Updated `skills-gap-analysis.md`

### Success Criteria:
✅ Top skills are high quality  
✅ Skill gaps identified  
✅ Roadmap for new skills created

---

## Week 3: Agent Optimization 🤖

**Focus:** Improve agent knowledge bases and patterns

### Tasks:
- [ ] **Review agent activation metrics**
  - Which agents used most frequently?
  - Which agents never activated?
  - Any missing agent roles?

- [ ] **Update agent knowledge bases**
  - Add recent successful patterns to agent descriptions
  - Add newly created skills to relevant agents
  - Remove deprecated patterns

- [ ] **Refine agent prompts**
  - Review agent clarity and specificity
  - Update examples based on real usage
  - Improve role descriptions

- [ ] **Cross-agent collaboration**
  - Identify overlapping responsibilities
  - Clarify boundaries between agents
  - Ensure smooth handoffs

### Output:
- [ ] Agent activation report
- [ ] Updated agent/*.md files
- [ ] Agent optimization notes
- [ ] Updated agent-to-skill mappings

### Success Criteria:
✅ All agents have clear, specific roles  
✅ Agent knowledge bases current  
✅ No duplicate or conflicting guidance

---

## Week 4: Quality Assurance ✅

**Focus:** Comprehensive system health check

### Tasks:
- [ ] **Run full health check**
  - Use ready-prompts.md → Health Check
  - Review all scores
  - Identify any regressions

- [ ] **Fix critical issues**
  - Address any scores drop below 80%
  - Fix broken links or references
  - Update outdated information

- [ ] **Update documentation**
  - Review README files
  - Update examples with latest patterns
  - Ensure all references current

- [ ] **Archive old content**
  - Move completed tasks to archive
  - Clean up temporary files
  - Organize artifacts

### Output:
- [ ] Health check report
- [ ] Critical issues fixed
- [ ] Documentation updates
- [ ] Clean, organized .agent directory

### Success Criteria:
✅ Health check score 90%+  
✅ No critical issues remaining  
✅ Documentation accurate and current

---

## Quick Reference

**Current Week:**
```
Week 1 (1st week of month): Framework Updates
Week 2 (2nd week of month): Skill Enhancement
Week 3 (3rd week of month): Agent Optimization
Week 4 (4th week of month): Quality Assurance
```

**How to Execute:**
1. Identify current week in rotation
2. Follow checklist for that week
3. Document changes in appropriate files
4. Update metrics in `memory/metrics/tracking.yaml`
5. Note any issues for monthly review

**Time Saved:**
- Proactive maintenance prevents major issues
- Regular updates easier than batch updates
- Consistent quality over time

---

**Last Updated:** 2026-01-17  
**Next Review:** Monthly (consolidate insights)

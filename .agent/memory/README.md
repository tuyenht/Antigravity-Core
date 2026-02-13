# Memory System

**Last Updated:** 2026-01-16  
**Purpose:** Persistent knowledge management for Antigravity

---

## Overview

The memory system enables Antigravity to remember user preferences, learn from interactions, track technology decisions, and continuously improve. It consists of 8 core YAML files, 1 metrics directory, and runtime-generated JSON files that work together to create a comprehensive knowledge base.

---

## Directory Structure

```
.agent/memory/
├── user-profile.yaml              # Tech stack & preferences
├── capability-boundaries.yaml     # Domain expertise levels
├── learning-patterns.yaml         # Successes & failures
├── tech-radar.yaml                # Technology adoption strategy
├── feedback.yaml                  # Agent effectiveness ratings
├── confidence-calibration.yaml    # Confidence calibration data
├── experiments.yaml               # Experiment tracking
├── predictive-improvements.yaml   # Predicted improvements
├── metrics/
│   ├── tracking.yaml              # Usage metrics
│   ├── optimization-metrics.json  # (runtime) Manager agent metrics
│   ├── aoc-history.json           # (runtime) Auto-optimization cycle
│   ├── self-correction-metrics.json # (runtime) Self-correction agent
│   ├── refactor-metrics.json      # (runtime) Refactor agent
│   ├── coordination-metrics.json  # (runtime) Agent coordination
│   └── documentation-metrics.json # (runtime) Documentation agent
├── auto-heal-log.json             # (runtime) Auto-heal script log
├── dx-analytics.json              # (runtime) DX analytics data
└── README.md                      # This file
```

> **Note:** Files marked `(runtime)` are auto-created by agents/scripts on first use.

---

## Core Files

### 1. user-profile.yaml
**Purpose:** Store user preferences and current focus areas

**Contains:**
- Tech stack preferences (primary, secondary, learning)
- Coding style (formatting, naming, patterns)
- Communication preferences (language, detail level)
- Project priorities (security, performance, quality)
- Current projects and learning goals

**When to update:**
- New technology adopted
- Coding style preferences change
- Project priorities shift
- New learning goals

**Example:**
```yaml
tech_stack:
  primary:
    backend: [Laravel 12, Django, FastAPI]
    frontend: [React 19, Vue 3, Inertia.js]

coding_style:
  prefer_functional: true
  prefer_explicit: true
```

---

### 2. capability-boundaries.yaml
**Purpose:** Track expertise levels across all domains

**Contains:**
- Confidence levels (0-100) for each technology
- Expertise categorization (exceptional, strong, developing, learning)
- Learning priorities with targets
- Skill boundaries (comfortable, stretch, avoid)

**When to update:**
- After completing major projects
- When learning new technologies
- Monthly skill assessments
- Quarterly comprehensive reviews

**Example:**
```yaml
domains:
  laravel: 95
  react: 90
  kubernetes: 78

learning_priorities:
  - name: "React 19 Compiler"
    current: 70
    target: 90
```

---

### 3. learning-patterns.yaml
**Purpose:** Capture successful approaches and lessons learned

**Contains:**
- Successful approaches (what worked well)
- Failed patterns (what didn't work)
- New discoveries (recent findings)
- Best practices learned
- Experimentation results

**When to update:**
- After completing significant work
- When discovering new patterns
- After failures or mistakes
- Weekly retrospectives

**Example:**
```yaml
successful_approaches:
  security_optimization:
    approach: "Quick wins first, then comprehensive"
    results: "58 → 95/100 in 3 hours"
    reusable: ["Quick Win prioritization", "Security headers"]
```

---

### 4. tech-radar.yaml
**Purpose:** Strategic technology adoption decisions

**Contains:**
- **Adopt:** Technologies we're committed to
- **Trial:** Evaluating in production
- **Assess:** Exploring with low-risk projects
- **Hold:** Proceed with caution
- **Retire:** Actively migrating away from

**When to update:**
- Quarterly technology reviews
- When adopting new technologies
- When deprecating old ones
- After trial period completion

**Example:**
```yaml
adopt:
  - name: "Laravel 12"
    confidence: 95
    reason: "Mature, excellent ecosystem"

trial:
  - name: "React 19 Compiler"
    trial_started: "2026-01"
    expected_decision: "2026-03"
```

---

### 5. feedback.yaml
**Purpose:** Track agent effectiveness and improvement areas

**Contains:**
- Agent effectiveness ratings by category
- Skill usefulness scores
- Workflow effectiveness
- Suggested improvements
- Success stories
- Pain points

**When to update:**
- After major accomplishments
- When discovering issues
- Monthly effectiveness reviews
- When workflows change

**Example:**
```yaml
agent_effectiveness:
  overall_rating: 9.5
  
  ratings_by_category:
    implementation: 10
    documentation: 10
    planning: 9
```

---

### 6. confidence-calibration.yaml
**Purpose:** Calibrate AI confidence accuracy over time

**Contains:**
- Calibration entries with predicted vs actual confidence
- Historical accuracy tracking

**When to update:** After tasks where confidence estimates were notably off.

---

### 7. experiments.yaml
**Purpose:** Track experimental approaches and A/B testing

**Contains:**
- Active experiments with hypothesis and results
- Completed experiments with outcomes

**When to update:** When trying new tools, patterns, or approaches.

---

### 8. predictive-improvements.yaml
**Purpose:** Track predicted areas for improvement

**Contains:**
- Predicted bottlenecks and improvement opportunities
- Priority rankings and expected impact

**When to update:** During quarterly reviews or when patterns emerge.

---

### 9. metrics/ (directory)
**Purpose:** Runtime metrics collected by agents and scripts

**Key files:**
- `tracking.yaml` — Usage metrics (manually maintained)
- `*.json` files — Auto-generated by agents during execution

**When to update:** `tracking.yaml` during maintenance; JSON files are auto-managed.

---

## How Memory Works

### 1. Initialization (First Use)
Agents read memory files to understand:
- User's tech stack and preferences
- Current expertise levels
- Recent successes and failures
- Technology decisions

### 2. Continuous Learning
As work progresses, agents:
- Record successful patterns → learning-patterns.yaml
- Update confidence levels → capability-boundaries.yaml
- Note technology decisions → tech-radar.yaml
- Collect feedback → feedback.yaml

### 3. Decision Making
Memory informs:
- **Technology choices:** Check tech-radar for approved technologies
- **Approach selection:** Use learning-patterns for proven methods
- **Capability awareness:** Reference capability-boundaries to know limits
- **Communication style:** Apply user-profile preferences

---

## Integration with Agents

### In GEMINI.md
```markdown
Before starting work:
1. Load user-profile.yaml for preferences
2. Check capability-boundaries.yaml for expertise
3. Review learning-patterns.yaml for proven approaches
4. Consult tech-radar.yaml for technology decisions
```

### In Agent Files
Agents reference memory for:
- **security-auditor.md:** Uses learning patterns for proven security approaches
- **backend-specialist.md:** Checks tech stack preferences
- **frontend-specialist.md:** References coding style preferences

---

## Update Guidelines

### Daily Updates
- [ ] Note any new discoveries (learning-patterns)
- [ ] Record pain points (feedback)

### Weekly Updates
- [ ] Review and rate workflows (feedback)
- [ ] Update current focus (user-profile)

### Monthly Updates
- [ ] Reassess capability levels (capability-boundaries)
- [ ] Review effectiveness ratings (feedback)
- [ ] Document success stories (feedback)

### Quarterly Updates
- [ ] Comprehensive tech radar review
- [ ] Major learning patterns synthesis
- [ ] Strategic priority updates

---

## Best Practices

### DO:
- ✅ Be specific with examples
- ✅ Include dates for context
- ✅ Rate on consistent scales (0-100, 0-10)
- ✅ Document both successes AND failures
- ✅ Keep entries current and relevant

### DON'T:
- ❌ Let files get stale (review regularly)
- ❌ Be vague ("it was good" → specify why/how)
- ❌ Remove old entries (they're historical context)
- ❌ Ignore failures (they're learning opportunities)

---

## Example Workflow

**Scenario:** Starting new Laravel + React project

1. **Check user-profile.yaml**
   - Primary stack includes Laravel & React ✅
   - Prefers TypeScript + strict types
   - Security priority: 10/10

2. **Check capability-boundaries.yaml**
   - Laravel confidence: 95/100 (excellent)
   - React confidence: 90/100 (excellent)
   - Can proceed confidently

3. **Check learning-patterns.yaml**
   - Found: "Laravel Octane for 2x performance"
   - Found: "Security headers middleware pattern"
   - Apply these proven approaches

4. **Check tech-radar.yaml**
   - Laravel 12: ADOPT ✅
   - React 19: ADOPT ✅
   - Inertia.js: ADOPT ✅
   - Use approved stack

5. **Execute with confidence**
   - Use proven patterns
   - Apply personal preferences
   - Follow approved technologies

---

## Maintenance

### File Size Management
- Keep recent entries (last 12 months)
- Archive older entries annually
- Focus on reusable patterns

### Quality Control
- Review entries monthly
- Remove duplicates
- Update outdated information
- Ensure consistency

### Backup
- Memory files are part of `.agent` directory
- Version controlled with Git
- Include in project backups

---

## Future Enhancements

**Planned:**
- Automated confidence level updates based on usage
- AI-assisted pattern recognition
- Cross-project learning synthesis
- Predictive technology recommendations

**Under Consideration:**
- Team-wide memory aggregation
- Visual dashboards for memory data
- Integration with project management tools

---

## Getting Help

**Questions:**
1. What should I add to memory? → Anything you want AI to remember
2. How often to update? → Weekly at minimum, after significant work
3. What if memory conflicts with request? → User request always wins
4. Can I delete entries? → Yes, but consider archiving instead

**Resources:**
- See individual file headers for specific guidance
- Review example entries in each file
- Check update frequency recommendations

---

**Remember:** Memory system works best when updated consistently. Even small, regular updates compound over time to create powerful persistent knowledge.

**Next Steps:**
1. Review all memory files
2. Customize user-profile.yaml
3. Set up weekly update reminders
4. Start recording successes and learnings

---

**Version:**1.0  
**Last Updated:** 2026-01-16  
**Maintainer:** Development Team

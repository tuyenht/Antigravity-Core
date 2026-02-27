---
description: "Pipeline Chain: Refactor, optimize, hoặc nâng cấp code hiện có."
---

# 🔄 IMPROVE Pipeline — Cải Thiện & Tối Ưu

> **Trigger:** Intent Router classifies request as IMPROVE
> **Khi nào:** User muốn refactor, optimize performance, clean up, hoặc migrate/upgrade
> **Thời gian ước tính:** 10-45 phút

---

## Pipeline Flow

```
PHASE 0        PHASE 1        PHASE 2         PHASE 3          PHASE 4
ONBOARDING →   ANALYZE   →    PLAN       →    EXECUTE     →    VERIFY
(auto/skip)    (3-5 phút)     (2-5 phút)      (5-30 phút)      (3 phút)
   │               │               │                │                │
   └→ Tạo docs    └→ Profile      └→ Strategy +   └→ Incremental   └→ Before/after
      nếu chưa có     current         user approve     refactoring      comparison
```

---

## PHASE 0: ONBOARDING (Tài liệu dự án — lightweight)

**Template:** `templates/project-bootstrap.md`

### 3-Tier Check
```
1. docs/PLAN.md không tồn tại          → CREATE (quick scan + tạo tối thiểu)
2. docs/PLAN.md có nhưng thiếu stamp   → UPGRADE (bổ sung + stamp + Docs Ingestion)
3. docs/PLAN.md có stamp v1.0          → SKIP (qua Phase 1 ngay)
```

> 💡 IMPROVE pipeline giữ onboarding **nhẹ** — đọc docs nhanh để hiểu architecture, ưu tiên chạy vào ANALYZE.

---

## PHASE 1: ANALYZE (Đánh giá hiện trạng)

**Agents:** `ai-code-reviewer` + `performance-optimizer` (parallel)
**Skills:** `clean-code`, `code-review-checklist`, `performance-profiling`

### Sub-Intents (Auto-detect from request)

| Sub-Intent | Trigger | Focus |
|-----------|---------|-------|
| **Refactor** | "refactor", "clean up", "restructure" | Code quality, complexity |
| **Optimize** | "optimize", "slow", "performance" | Speed, memory, bundle size |
| **Upgrade** | "upgrade", "migrate", "update" | Dependencies, framework version |
| **General** | "improve", "better" | Both quality + performance |

### Auto-Actions
1. **Code Quality Scan:**
   - Complexity (cyclomatic, cognitive)
   - Duplication
   - Code smells
   - Dead code
2. **Performance Scan** (if optimize):
   - Bundle size / query time / response time
   - N+1 queries, unnecessary re-renders
   - Memory leaks
3. **Dependency Scan** (if upgrade):
   - Outdated packages
   - Security vulnerabilities
   - Breaking changes in upgrades

### Output Phase 1
```
📊 Current State Analysis:
- Code quality score: X/100
- Complexity hotspots: [files]
- Performance bottlenecks: [specific areas]
- Improvement opportunities: [prioritized list]
```

---

## PHASE 2: PLAN (Chiến lược cải thiện)

**Agent:** `refactor-agent` / `performance-optimizer`
**Skills:** `architecture`

### Strategy Creation
```yaml
refactoring_strategy:
  approach: "incremental"  # NEVER big-bang refactor
  order: "inside-out"      # Start with leaf nodes, work up
  safety: "test-first"     # Ensure tests exist before changing
  
  steps:
    - description: "[what to change]"
      files: ["file1.ts", "file2.ts"]
      risk: "low | medium | high"
      tests_required: true
```

### ⛔ CHECKPOINT
```
📋 Chiến lược cải thiện:

1. [Step 1] — Risk: Low
2. [Step 2] — Risk: Medium
3. [Step 3] — Risk: Low

Estimated improvement: [metrics]

→ User approve → Phase 3
→ User adjust scope → Update plan
```

---

## PHASE 3: EXECUTE (Thực hiện)

**Agents:** `refactor-agent` (primary), domain agents (supporting)
**Rules:** Auto-loaded via `auto-rule-discovery.md`

### Chaining Existing Workflows
```
├── /refactor workflow   → Safe code restructuring
├── /optimize workflow   → Performance improvements
├── /auto-healing        → Fix lint/type issues from changes
└── /auto-optimization-cycle → AOC for comprehensive optimization
```

### Execution Principles
1. **One step at a time:** Apply ONE refactoring, verify, then next
2. **Test between steps:** Run tests after each change
3. **Git-friendly:** Each step = one logical commit
4. **Preserve behavior:** Output MUST be identical (unless explicitly changing behavior)

---

## PHASE 4: VERIFY (So sánh trước/sau)

**Agent:** `test-engineer` + `performance-optimizer`

### Auto-Actions
1. Run full test suite → NO regressions
2. Measure before/after metrics
3. Lint + type check

### Output Phase 4
```
✅ Cải thiện hoàn tất!

📊 Before → After:
- Code quality: 65/100 → 85/100
- Complexity: 12 → 6
- Bundle size: 250KB → 190KB (if applicable)
- Query time: 120ms → 45ms (if applicable)

📝 Files changed: [list]
🧪 Tests: ✅ All passing, 0 regressions
```

---

## 🧬 PHASE FINAL: LEARNING (Tự động)

> Chạy SAU KHI pipeline hoàn tất. AI tự ghi nhận kinh nghiệm.

### Auto-Actions
1. **Record** vào `memory/learning-patterns.yaml`
2. **Track** `project.json → usage_tracking.pipelines_used.IMPROVE += 1`

### Data to Record
```yaml
- date: "{today}"
  pipeline: "IMPROVE"
  sub_intent: "{refactor | optimize | upgrade}"
  before_score: "{quality/perf score before}"
  after_score: "{quality/perf score after}"
  what_worked: "{technique that improved metrics}"
  what_failed: "{approach that didn't help}"
  improvement_idea: "{suggestion}"
```

---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| Refactoring breaks tests | Revert, fix test first, then refactor |
| Performance worse after optimize | Profile again, revert specific change |
| Upgrade has breaking changes | Follow migration guide, incremental upgrade |
| Too many changes at once | Break into smaller PRs/steps |

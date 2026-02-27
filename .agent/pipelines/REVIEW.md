---
description: "Pipeline Chain: Đánh giá chất lượng, review code, và audit hệ thống."
---

# 📋 REVIEW Pipeline — Đánh Giá & Kiểm Tra

> **Trigger:** Intent Router classifies request as REVIEW
> **Khi nào:** User muốn kiểm tra chất lượng, review code, audit security
> **Thời gian ước tính:** 5-15 phút

---

## Pipeline Flow

```
PHASE 0        PHASE 1               PHASE 2          PHASE 3
ONBOARDING →   SCAN (Parallel)  →    REPORT      →    ACTION
(auto/skip)    (3-5 phút)            (1-2 phút)       (optional)
   │               │                      │                │
   └→ Tạo docs    └→ Security ║          └→ Unified      └→ Auto-fix Critical
      nếu chưa có    Quality  ║             health score     hoặc generate tickets
                     Performance ║
                     Test coverage ║
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

> 💡 REVIEW pipeline giữ onboarding **nhẹ** — đọc docs nhanh để đánh giá documentation score chính xác.

---

## PHASE 1: SCAN (Quét song song)

**Agents:** Running in parallel:

| Stream | Agent | Script | Focus |
|--------|-------|--------|-------|
| 🔴 Security | `security-auditor` | `security_scan.py` | Vulnerabilities, secrets, OWASP |
| 🟠 Quality | `ai-code-reviewer` | `lint_runner.py` | Lint, types, complexity, duplication |
| 🟡 Performance | `performance-optimizer` | `lighthouse_audit.py` | Bundle, queries, CWV |
| 🟢 Testing | `test-engineer` | `test_runner.py` | Coverage, flaky tests, gaps |

### Additional Scans (Conditional)
```yaml
conditional_scans:
  has_ui:
    - agent: "frontend-specialist"
      script: "ux_audit.py"
      focus: "Accessibility, responsive, UX"
      
  has_api:
    - agent: "backend-specialist"
      script: "api_validator.py"
      focus: "API consistency, documentation"
      
  has_seo:
    - agent: "seo-specialist"
      script: "seo_checker.py"
      focus: "Meta tags, structured data, CWV"
      
  has_i18n:
    - script: "i18n_checker.py"
      focus: "Translation coverage, missing keys"
```

### Chaining Existing Workflows
```
├── /security-audit         → Security-focused scan
├── /check                  → Quick health check
└── /performance-budget-enforcement → Performance gates
```

---

## PHASE 2: REPORT (Unified Report)

### Health Score Calculation
```yaml
health_score:
  total: 100
  weights:
    security: 30      # Most critical
    code_quality: 25   # Clean, maintainable
    test_coverage: 20  # Reliability
    performance: 15    # Speed
    documentation: 10  # Completeness
    
  rating:
    90-100: "🏆 Platinum — Production ready"
    80-89:  "🥇 Gold — Minor improvements needed"
    70-79:  "🥈 Silver — Several issues to address"
    60-69:  "🥉 Bronze — Significant improvements needed"
    0-59:   "⚠️ Needs Work — Critical issues present"
```

### Report Format
```markdown
## 📊 Health Report — [Project Name]

**Overall Score: XX/100 ([Rating])**

### Breakdown
| Category | Score | Status | Key Findings |
|----------|-------|--------|-------------|
| 🔴 Security | XX/30 | ✅/⚠️/❌ | [finding] |
| 🟠 Quality | XX/25 | ✅/⚠️/❌ | [finding] |
| 🟢 Testing | XX/20 | ✅/⚠️/❌ | [finding] |
| 🟡 Performance | XX/15 | ✅/⚠️/❌ | [finding] |
| 📝 Documentation | XX/10 | ✅/⚠️/❌ | [finding] |

### 🔴 Critical Issues (Fix IMMEDIATELY)
1. [Issue] — Impact: [description]
2. [Issue] — Impact: [description]

### 🟠 High Priority (Fix this sprint)
1. [Issue]
2. [Issue]

### 🟡 Medium Priority (Plan for next sprint)
1. [Issue]

### 🟢 Recommendations (Nice to have)
1. [Suggestion]
```

---

## PHASE 3: ACTION (Hành động)

### Auto-Fix Offer
```
Based on findings:

🔴 Critical issues found?
  → "Tìm thấy X lỗi critical. Sửa ngay?"
  → User approve → FIX pipeline cho mỗi issue
  → User skip → Log for later

🟠 High priority issues?
  → List them with fix estimates
  → Offer to fix top 3
  
🟢 All clean?
  → "✅ Hệ thống healthy! Score: XX/100"
  → Suggest next improvement areas
```

### Chaining to Other Pipelines
```
Critical bug found     → FIX pipeline
Code needs refactoring → IMPROVE pipeline
Performance degraded   → IMPROVE pipeline (optimize sub-intent)
Ready to deploy        → SHIP pipeline
```

---

## Review Scopes

User có thể request review ở các scope khác nhau:

| Scope | Trigger | What's Scanned |
|-------|---------|----------------|
| **Full** | "review", "audit", "health check" | Everything |
| **Security** | "security audit", "vulnerability" | Security only (30-point scale) |
| **Quality** | "code quality", "code review" | Quality only (25-point scale) |
| **Performance** | "performance", "speed" | Performance only (15-point scale) |
| **Pre-deploy** | "pre-deploy check", "ready to ship?" | Security + Tests + Build |

---

## 🧬 PHASE FINAL: LEARNING (Tự động)

> Chạy SAU KHI pipeline hoàn tất. AI tự ghi nhận kinh nghiệm.

### Auto-Actions
1. **Record** vào `memory/learning-patterns.yaml`
2. **Track** `project.json → usage_tracking.pipelines_used.REVIEW += 1`

### Data to Record
```yaml
- date: "{today}"
  pipeline: "REVIEW"
  scope: "{full | security | quality | performance | pre-deploy}"
  health_score: "{X/100}"
  critical_found: "{count}"
  auto_fixed: "{count}"
  what_worked: "{scan type that found real issues}"
  false_positives: "{count}"
  improvement_idea: "{suggestion}"
```

---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| Scan takes too long | Run specific category only, not full scan |
| False positives | Add exceptions in rules, report to .agent repo |
| Score seems wrong | Check weights, verify scan results manually |
| Can't fix critical issue | Escalate with detailed analysis, consider workaround |

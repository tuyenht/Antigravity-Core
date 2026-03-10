# 🧭 Universal Intent Router

> **Version:** 5.0.0 | **Updated:** 2026-03-01
> **Purpose:** Single entry point — classify ANY user request into 1 of 6 intents, then activate the correct Pipeline Chain.
> **Priority:** P0 — Core system, loaded at every session via GEMINI.md

---

## How It Works

```
User mô tả bất kỳ gì (tự nhiên, không cần lệnh)
    │
    ▼
┌─────────────────────────────────────┐
│     INTENT CLASSIFICATION           │
│                                     │
│  Phân tích request → Match intent   │
│  Nếu không rõ → Hỏi 1-2 câu       │
└──────────────┬──────────────────────┘
               │
    ┌──────────┼──────────┐
    ▼          ▼          ▼
 BUILD    ENHANCE      FIX
 IMPROVE    SHIP     REVIEW
    │          │          │
    ▼          ▼          ▼
 Pipeline  Pipeline  Pipeline
 Chain     Chain     Chain
```

---

## Intent Classification Table

### 🆕 BUILD — Tạo mới từ đầu

**Khi nào:** User muốn tạo dự án, module, hoặc hệ thống hoàn toàn mới.

| Ngôn ngữ | Trigger Keywords |
|-----------|-----------------|
| 🇻🇳 Tiếng Việt | "tạo mới", "xây dựng", "khởi tạo", "thiết lập", "dựng", "bắt đầu dự án" |
| 🇬🇧 English | "create", "build", "new project", "setup", "start from scratch", "initialize" |

**Pipeline:** `pipelines/BUILD.md`
**Agents chính:** `project-planner` → `database-architect` → `backend-specialist` / `frontend-specialist` → `test-engineer`

---

### ➕ ENHANCE — Thêm tính năng

**Khi nào:** User muốn thêm feature mới vào dự án đã có.

| Ngôn ngữ | Trigger Keywords |
|-----------|-----------------|
| 🇻🇳 Tiếng Việt | "thêm", "mở rộng", "tính năng mới", "implement", "module mới", "trang mới" |
| 🇬🇧 English | "add", "enhance", "new feature", "implement", "extend", "integrate" |

**Pipeline:** `pipelines/ENHANCE.md`
**Agents chính:** `explorer-agent` → `project-planner` → domain agent → `test-engineer`

---

### 🔧 FIX — Sửa lỗi

**Khi nào:** User báo lỗi, bug, hoặc something không hoạt động đúng.

| Ngôn ngữ | Trigger Keywords |
|-----------|-----------------|
| 🇻🇳 Tiếng Việt | "sửa lỗi", "bị lỗi", "không hoạt động", "hỏng", "crash", "lỗi" |
| 🇬🇧 English | "fix", "bug", "debug", "broken", "error", "crash", "not working", "fails" |

**Pipeline:** `pipelines/FIX.md`
**Agents chính:** `debugger` → domain agent → `test-engineer`

---

### 🔄 IMPROVE — Cải thiện / Tối ưu

**Khi nào:** User muốn refactor, optimize, hoặc nâng cấp code hiện có.

| Ngôn ngữ | Trigger Keywords |
|-----------|-----------------|
| 🇻🇳 Tiếng Việt | "tối ưu", "refactor", "cải thiện", "nâng cấp", "clean up", "tái cấu trúc" |
| 🇬🇧 English | "optimize", "refactor", "improve", "clean up", "restructure", "upgrade", "migrate", "performance" |

**Pipeline:** `pipelines/IMPROVE.md`
**Agents chính:** `ai-code-reviewer` → `refactor-agent` / `performance-optimizer` → `test-engineer`

---

### 🚀 SHIP — Triển khai

**Khi nào:** User muốn deploy, release, hoặc đưa lên production.

| Ngôn ngữ | Trigger Keywords |
|-----------|-----------------|
| 🇻🇳 Tiếng Việt | "deploy", "triển khai", "đưa lên", "ra mắt", "phát hành", "release" |
| 🇬🇧 English | "deploy", "ship", "release", "publish", "production", "staging", "go live" |

**Pipeline:** `pipelines/SHIP.md`
**Agents chính:** `test-engineer` → `security-auditor` → `devops-engineer` → `manager-agent`

---

### 📋 REVIEW — Đánh giá / Kiểm tra

**Khi nào:** User muốn kiểm tra chất lượng, review code, hoặc audit hệ thống.

| Ngôn ngữ | Trigger Keywords |
|-----------|-----------------|
| 🇻🇳 Tiếng Việt | "review", "kiểm tra", "đánh giá", "audit", "báo cáo", "phân tích", "health check" |
| 🇬🇧 English | "review", "check", "audit", "analyze", "inspect", "report", "overview", "health" |

**Pipeline:** `pipelines/REVIEW.md`
**Agents chính:** `ai-code-reviewer` ‖ `security-auditor` ‖ `performance-optimizer`

---

## Classification Protocol

```yaml
classify_intent:
  step_1_keyword_match:
    action: "Scan user request against trigger keywords above"
    confidence_threshold: 0.7
    if_match: "Route to matched pipeline"

  step_2_context_check:
    action: "If keywords are ambiguous, check project context"
    checks:
      - "Is there an existing project? (package.json, composer.json)"
      - "Is user pointing at error output?"
      - "Is user describing something new vs existing?"
    examples:
      - input: "Tạo trang đăng nhập"
        has_project: true → ENHANCE (thêm vào dự án có sẵn)
        has_project: false → BUILD (tạo mới)

  step_3_ask_if_unclear:
    action: "If confidence < 0.7, ask maximum 2 clarifying questions"
    template: |
      Tôi cần hiểu rõ hơn để chọn đúng quy trình:
      1. Bạn muốn [tạo mới / thêm vào dự án có sẵn / sửa lỗi]?
      2. [Câu hỏi cụ thể dựa trên context]
    max_questions: 2
    after_answer: "Re-classify and route"
```

---

## Slash Command Override

Khi user dùng slash command trực tiếp, BYPASS Intent Router và chạy workflow tương ứng:

```
/create          → BUILD pipeline
/plan            → BUILD pipeline (Phase 2 only)
/scaffold        → BUILD pipeline (Phase 3 only)
/init-docs       → BUILD pipeline (Phase 0 only — docs standardization)
/enhance         → ENHANCE pipeline
/debug           → FIX pipeline
/quickfix        → FIX pipeline (simplified)
/refactor        → IMPROVE pipeline
/optimize        → IMPROVE pipeline
/deploy          → SHIP pipeline
/mobile-deploy   → SHIP pipeline (mobile)
/check           → REVIEW pipeline
/security-audit  → REVIEW pipeline (security focus)
/full-pipeline   → BUILD pipeline (full team mode)
/orchestrate     → Orchestrator agent (manual multi-agent)
```

All 35 workflows remain accessible via their original slash commands.

---

## Pipeline Selection Matrix

For quick reference, cross-check user intent with project state:

| User Intent | No Project | Existing Project |
|-------------|-----------|-----------------|
| "Tạo X" | → BUILD | → ENHANCE (add to existing) |
| "Xây dựng Y" | → BUILD | → Ask: "Tạo mới hay thêm vào?" |
| "Sửa lỗi Z" | → N/A | → FIX |
| "Tối ưu A" | → N/A | → IMPROVE |
| "Deploy" | → N/A | → SHIP |
| "Review code" | → N/A | → REVIEW |

---

## Integration

```yaml
loaded_by: "GEMINI.md → § 2. Intent Router Protocol"
depends_on:
  - "pipelines/*.md"           # Pipeline Chain definitions
  - "reference-catalog.md"     # Agent/rule lookups (lazy load)
  - "systems/auto-rule-discovery.md"  # Rule loading within pipelines
replaces:
  - "GEMINI.md Request Classifier (old § 2)"  # Superseded by Intent Router
```

---

**Version:** 5.0.0
**System:** Antigravity-Core v5.0.0
**Updated:** 2026-03-01

> **See also:** [Orchestration Engine](orchestration-engine.md) | [Auto-Rule Discovery](auto-rule-discovery.md) | [Agent Coordination](agent-coordination.md) | [Reference Catalog](../reference-catalog.md)

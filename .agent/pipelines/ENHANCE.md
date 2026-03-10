---
description: "Pipeline Chain: Thêm tính năng mới vào dự án hiện có."
---

# ➕ ENHANCE Pipeline — Thêm Tính Năng

> **Trigger:** Intent Router classifies request as ENHANCE
> **Khi nào:** User muốn thêm feature/module/page vào dự án đã có
> **Thời gian ước tính:** 5-30 phút tùy complexity

---

## Pipeline Flow

```
PHASE 0        PHASE 1        PHASE 2         PHASE 3          PHASE 4
ONBOARDING →   CONTEXT   →    DESIGN     →    IMPLEMENT   →    VERIFY
(auto/skip)    (1 phút)       (2-5 phút)      (5-20 phút)      (2 phút)
   │               │               │                │                │
   └→ Tạo docs    └→ Đọc dự      └→ Impact       └→ Code +        └→ Test +
      nếu chưa có     án hiện có      analysis        integration      lint check
```

---

## PHASE 0: ONBOARDING (Tài liệu dự án — thông minh)

**Template:** `templates/project-bootstrap.md`

### 4-Tier Check
```
1. docs/PLAN.md không tồn tại          → CREATE (chain → /init-docs nếu docs/ có nhiều files)
2. docs/PLAN.md có nhưng thiếu stamp   → UPGRADE (bổ sung + stamp + Docs Ingestion)
3. docs/PLAN.md có stamp + docs mới    → REFRESH (đọc files mới/thay đổi, update PLAN.md)
4. docs/PLAN.md có stamp + không đổi   → SKIP (qua Phase 1 ngay)
```

### Auto-Actions (CREATE/UPGRADE mode)

**Step 1 — Existing Docs Ingestion (QUAN TRỌNG):**
```yaml
docs_ingestion:
  scan: "docs/ folder + README.md + project root *.md"
  read_all: true  # Đọc TOÀN BỘ .md files trong docs/
  analyze:
    - "Identify: PRD, specs, architecture, API docs, guides..."
    - "Extract: features, tech stack, data model, user flows, constraints"
    - "Map: nội dung nào đã có → section nào trong PLAN.md chuẩn"
  
  examples:
    - "docs/PRD.md (26KB) → Extract features, user stories, tech decisions"
    - "docs/SIGNAL_FORMATS.md → Extract API contracts, data schemas"
    - "docs/architecture.md → Extract system design"
    - "README.md → Extract setup instructions, project description"
```

**Step 2 — Tổng hợp vào tài liệu chuẩn:**
1. Tạo/bổ sung `docs/PLAN.md` — **tổng hợp từ docs có sẵn**, KHÔNG viết lại từ đầu
2. Tạo `tasks/todo.md` — Current state + planned changes
3. Tạo `tasks/lessons.md` — Empty template
4. SKIP `README.md` nếu đã tồn tại
5. Gắn compliance stamp `<!-- antigravity: v1.0 -->`

> 💡 UPGRADE mode: chỉ BỔ SUNG sections thiếu, KHÔNG overwrite nội dung cũ.
> 📖 Docs gốc (PRD.md, specs...) được **GIỮ NGUYÊN** — PLAN.md là bản tổng hợp tham chiếu, không phải thay thế.

---

## PHASE 1: CONTEXT (Đọc dự án hiện tại)

**Agent:** `explorer-agent`

### Auto-Actions
1. Detect tech stack (package.json, composer.json, etc.)
2. Scan project structure
3. Identify patterns đã dùng (naming, architecture)
4. Load relevant rules via `auto-rule-discovery.md`

### Output Phase 1
- Tech stack identified
- Project patterns understood
- Related existing files identified

---

## PHASE 2: DESIGN (Phân tích tác động)

**Agent:** `project-planner`
**Skills:** `plan-writing`, `architecture`

### Complexity Assessment
```yaml
complexity_check:
  low (1-3):     # Single file change, isolated
    action: "Skip plan, proceed to implement"
    examples: "Add a button, change a color, add a field"
    
  medium (4-6):  # Multiple files, some dependencies
    action: "Mini-plan (3-5 bullet points), quick confirm"
    examples: "Add search feature, new API endpoint, new page"
    
  high (7-10):   # Cross-cutting, architectural impact
    action: "Full PLAN.md update, checkpoint required"
    examples: "Add auth system, payment integration, real-time chat"
```

### Auto-Actions (Medium+)
1. Impact analysis: files affected, breaking changes?
2. Mini-plan or full plan depending on complexity
3. Agent selection based on affected domains
4. **Nếu feature thêm route/screen mới (complexity ≥ 7):** Cập nhật `docs/PROJECT-SCREENS.md`

### ⛔ CHECKPOINT (Complexity ≥ 5 only)
```
Mini-plan cho user:
- Tính năng: [mô tả]
- Files affected: [list]
- Breaking changes: [có/không]
- Approach: [tóm tắt]

→ User approve → Phase 3
```

---

## PHASE 3: IMPLEMENT (Code)

**Agents:** Auto-selected by tech stack + domain:

| Domain Affected | Agent |
|----------------|-------|
| Backend / API | `backend-specialist` |
| Frontend / UI | `frontend-specialist` |
| Database / Schema | `database-architect` |
| Mobile | `mobile-developer` |
| Laravel-specific | `laravel-specialist` |

**Rules:** Auto-loaded via `auto-rule-discovery.md`

### Auto-Actions
1. Create/modify files following existing patterns
2. Write migrations if schema changes
3. Update routes/navigation
4. Apply framework-specific best practices
5. Write unit tests for new code

### Chaining Existing Workflows
```
├── /enhance workflow    → Core implementation
├── /scaffold workflow   → If new CRUD module needed
└── /auto-healing        → Fix lint/type errors automatically
```

---

## PHASE 4: VERIFY (Kiểm tra)

**Agent:** `test-engineer`

### Auto-Actions
1. Run existing tests (ensure no regressions)
2. Run new tests for added feature
3. Lint + type check
4. Quick review for common mistakes
5. **Complexity ≥ 5:** Regression metrics — diff test count, coverage, build size (before/after)

### Output Phase 4
```
✅ Tính năng đã thêm thành công!

📝 Files đã thay đổi: [list]
🧪 Tests: X passed, 0 failed
🔍 Lint: Clean

→ Mô tả tính năng tiếp theo để thêm
→ /review để đánh giá tổng thể
```

---

## 🧬 PHASE FINAL: LEARNING (Tự động)

> Chạy SAU KHI pipeline hoàn tất. AI tự ghi nhận kinh nghiệm.

### Auto-Actions
1. **Record** vào `memory/learning-patterns.yaml`
2. **Track** `project.json → usage_tracking.pipelines_used.ENHANCE += 1`

### Data to Record
```yaml
- date: "{today}"
  pipeline: "ENHANCE"
  feature: "{feature_name}"
  complexity: "{1-10}"
  what_worked: "{patterns that helped}"
  what_failed: "{issues, if any}"
  improvement_idea: "{suggestion}"
```

---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| Feature conflicts with existing code | Analyze conflicts, propose merge strategy |
| Schema migration breaks existing data | Generate rollback migration, warn user |
| Performance regression | Profile before/after, optimize if needed |

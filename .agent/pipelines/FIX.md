---
description: "Pipeline Chain: Tìm và sửa lỗi, debug hệ thống."
---

# 🔧 FIX Pipeline — Debug & Sửa Lỗi

> **Trigger:** Intent Router classifies request as FIX
> **Khi nào:** User báo lỗi, bug, crash, hoặc something không hoạt động
> **Thời gian ước tính:** 2-15 phút

---

## Pipeline Flow

```
PHASE 0        PHASE 1        PHASE 2         PHASE 3          PHASE 4
ONBOARDING →   REPRODUCE →    DIAGNOSE   →    FIX         →    VERIFY
(auto/skip)    (1 phút)       (2-5 phút)      (2-10 phút)      (1 phút)
   │               │               │                │                │
   └→ Tạo docs    └→ Hiểu lỗi    └→ Root cause   └→ Apply fix +   └→ Test pass +
      nếu chưa có     + reproduce     analysis        regression       no regressions
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

### Auto-Actions (CREATE mode — lightweight)

**Step 1 — Quick Docs Ingestion:**
```
Scan docs/ folder → read existing .md files (PRD, specs, architecture)
→ Extract: tech stack, data model, key constraints relevant to bug fixing
→ Feed context into Phase 1 REPRODUCE for accurate debugging
```

**Step 2 — Tạo tài liệu tối thiểu:**
1. Tạo `docs/PLAN.md` — Lightweight overview (tổng hợp từ docs có sẵn nếu có)
2. Tạo `tasks/todo.md` — Current bug as first entry
3. Tạo `tasks/lessons.md` — Empty template
4. Gắn compliance stamp `<!-- antigravity: v1.0 -->`

> 💡 FIX pipeline giữ onboarding **nhẹ** — đọc docs nhanh để hiểu context, ưu tiên sửa lỗi.

---

## PHASE 1: REPRODUCE (Hiểu lỗi)

**Agent:** Không cần agent — AI trực tiếp.

### Thu thập thông tin
```
Từ user request, extract:
1. Error message (nếu có)
2. Steps to reproduce (nếu user mô tả)
3. Expected vs actual behavior
4. File/line reference (nếu user chỉ ra)
```

### Nếu thiếu thông tin, hỏi TỐI ĐA 1 câu:
```
"Bạn thấy error message gì? Hoặc mô tả chính xác bước nào gây lỗi?"
```

---

## PHASE 2: DIAGNOSE (Root Cause Analysis)

**Agent:** `debugger`
**Skills:** `systematic-debugging`
**Rules:** Auto-loaded via request keyword → `agentic-ai/debugging-agent.md`

### 5-Why Method
```
1. ĐỌC error message / stack trace
2. TRACE ngược từ error → source file → root cause
3. IDENTIFY: Bug ở đâu? (logic / data / config / dependency)
4. SCOPE: Lỗi ảnh hưởng những gì khác?
5. PLAN: Fix approach + side effects?
```

### Auto-Actions
1. **Check `tasks/lessons.md`** for similar past bugs (avoid repeating failed approaches)
2. Read relevant source files
3. Check recent changes (git log)
4. Trace error path
5. Identify root cause
6. Determine blast radius

### Output Phase 2
```
🔍 Root Cause Analysis:
- Lỗi: [mô tả]
- Nguyên nhân: [root cause]
- File: [file:line]
- Impact: [scope of impact]
- Fix approach: [how to fix]
```

---

## PHASE 3: FIX (Sửa lỗi)

**Agents:** Domain agent based on file type:

| File Type | Agent |
|-----------|-------|
| `.php` | `backend-specialist` / `laravel-specialist` |
| `.ts`, `.tsx`, `.js` | `frontend-specialist` / `backend-specialist` |
| `.sql`, migration | `database-architect` |
| `.dart` | `mobile-developer` |
| Config files | `devops-engineer` |

### Auto-Actions
1. Apply the fix (minimal, targeted change)
2. Write regression test (prevent recurrence)
3. Check for similar bugs in related files

### Principles
- **Minimal fix:** Change ONLY what's needed
- **Regression test:** ALWAYS write a test that would have caught this bug
- **No side effects:** Verify fix doesn't break anything else

---

## PHASE 4: VERIFY (Xác nhận fix)

**Agent:** `test-engineer`

### Auto-Actions
1. Run the new regression test → Must PASS
2. Run existing test suite → Must NOT regress
3. Lint + type check → Must be clean

### Output Phase 4
```
✅ Lỗi đã được sửa!

🔧 Root cause: [tóm tắt]
📝 Files changed: [list]
🧪 Regression test: ✅ Added
🔄 Existing tests: ✅ All passing

→ Nếu có lỗi khác, mô tả tiếp
→ /review để kiểm tra tổng thể
```

---

## 🧬 PHASE FINAL: LEARNING (Tự động)

> Chạy SAU KHI pipeline hoàn tất. AI tự ghi nhận kinh nghiệm.

### Auto-Actions
1. **Record** vào `memory/learning-patterns.yaml`
2. **Track** `project.json → usage_tracking.pipelines_used.FIX += 1`

### Data to Record
```yaml
- date: "{today}"
  pipeline: "FIX"
  bug_type: "{logic | data | config | dependency}"
  root_cause: "{one-line summary}"
  time_to_diagnose: "{approximate}"
  what_worked: "{diagnostic method that found the root cause}"
  preventable: "{yes/no — could a test have caught this?}"
  improvement_idea: "{suggestion}"
```

---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| Can't reproduce | Ask user for exact steps, check environment differences |
| Root cause unclear | Add logging, use debugger, narrow down with binary search |
| Fix causes new bug | Revert, re-analyze with broader scope |
| Intermittent bug | Add monitoring/logging, check race conditions |

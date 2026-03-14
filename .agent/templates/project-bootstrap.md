---
description: "Template tài liệu dự án bắt buộc — auto-generated bởi Pipeline PHASE 0."
---

# Project Bootstrap — Bộ Tài Liệu Dự Án Chuẩn

> **Version:** 1.0 | **Antigravity-Core:** v5.0.1
> **Trigger:** Tự động ở PHASE 0 của mọi Pipeline Chain.

---

## Khi Nào Kích Hoạt

| Kịch bản | Điều kiện | Hành động |
|-----------|-----------|-----------|
| **CREATE** | `docs/PLAN.md` không tồn tại | Nếu docs/ có >5 files → chain `/init-docs`; nếu ≤5 → tạo tối thiểu nội bộ |
| **UPGRADE** | `docs/PLAN.md` tồn tại nhưng **thiếu** compliance stamp | Đề xuất chuẩn hóa → hỏi user 1 lần → cập nhật + gắn stamp |
| **REFRESH** | `docs/PLAN.md` có stamp + docs mới/thay đổi | Đọc files mới/thay đổi → update PLAN.md + PROJECT-BRIEF.md |
| **SKIP** | `docs/PLAN.md` có compliance stamp + không đổi | Bỏ qua — qua thẳng Phase 1 |

---

## Compliance Stamp

**Mỗi doc được tạo/chuẩn hóa bởi Antigravity sẽ có dòng này ở cuối:**

```html
<!-- antigravity: v1.0 -->
```

**Mục đích:** Đánh dấu doc đã đạt chuẩn Antigravity → PHASE 0 không kiểm tra lại.

**Khi nào stamp bị outdated:**
- Nếu template version tăng (ví dụ v1.0 → v2.0) → hệ thống biết cần upgrade lại.
- Nhưng CHỈ HỎI 1 LẦN, không lặp lại mỗi session.

---

## Bộ Tài Liệu Bắt Buộc

### 1. `docs/PLAN.md` — Kế Hoạch Dự Án

```markdown
# [Tên dự án] — Project Plan

**Created:** {date}
**Stack:** {detected_or_chosen_stack}
**Status:** In Development

## MVP Scope
- [ ] Feature 1 (mô tả cụ thể, đo lường được)
- [ ] Feature 2
- [ ] Feature 3

## Architecture Overview
{Mô tả kiến trúc: layers, components, data flow}

## Database Schema
{Schema chính, hoặc "N/A" nếu không có DB}

## Tech Decisions
| Quyết định | Lý do | Alternatives đã cân nhắc |
|-----------|-------|--------------------------|
| {tech} | {why} | {other options} |

## Current State & Maturity ← CHỈ cho dự án EXISTING (ENHANCE/FIX)
{Ghi "Greenfield — N/A" nếu dự án mới (BUILD)}

### ✅ Completed
- {what's already built and working}

### ⬜ Not Started / Placeholder
- {what exists as stub or not yet implemented}

## Technical Debt & Risks ← CHỈ cho dự án EXISTING
{Ghi "Greenfield — N/A" nếu dự án mới}

| Priority | Issue | Location |
|----------|-------|----------|
| 🔴 HIGH | {critical issue} | {file:line} |
| 🟡 MEDIUM | {moderate issue} | {file} |
| 🟢 LOW | {minor issue} | {file} |

## Milestones & Roadmap
| Phase | Milestone | Dependencies | Target | Status |
|-------|-----------|-------------|--------|--------|
| MVP | {deliverable} | — | {timeframe} | ⬜ |
| v0.2 | {deliverable} | MVP done | | |

<!-- antigravity: v1.0 -->
```

> **Hướng dẫn AI quét codebase (cho dự án EXISTING):**
> - Section 1 (MVP): Extract từ README, docs có sẵn, infer từ code
> - Section 2 (Architecture): Generate từ directory structure thực tế
> - Section 3 (Schema): Extract từ schema files, ORM models, migration files
> - Section 4 (Tech): Extract từ package.json, composer.json, pyproject.toml
> - Section 5 (Current State): Classify mỗi feature: Done / Stub / Not Started
> - Section 6 (Tech Debt): Identify anti-patterns, security issues, missing configs
> - Section 7 (Milestones): Group Next Steps thành milestones với dependencies

---

### 2. `tasks/todo.md` — Task Tracking

```markdown
# [Tên dự án] — Tasks

**Updated:** {date}

## In Progress
- [ ] {task — cụ thể, đo lường được}

## Completed
- [x] Project bootstrap ({date})

## Backlog
- [ ] {future task}

<!-- antigravity: v1.0 -->
```

---

### 3. `tasks/lessons.md` — Bài Học Rút Ra

```markdown
# [Tên dự án] — Lessons Learned

**Updated:** {date}

## Patterns That Work
{Sẽ được ghi bởi PHASE FINAL sau mỗi pipeline}

## Mistakes Made
{Sẽ được ghi khi gặp lỗi}

## Rules
{Quy tắc riêng cho dự án này}

<!-- antigravity: v1.0 -->
```

---

### 4. `README.md` — Hướng Dẫn (nếu chưa có)

```markdown
# [Tên dự án]

{Mô tả ngắn 1-2 câu}

## Quick Start

### Prerequisites
- {runtime} v{version}
- {database} (if applicable)

### Installation
{Exact commands to install and run}

### Development
{Command to start dev server}

### Testing
{Command to run tests}

## Project Structure
{Key directories and their purpose}

<!-- antigravity: v1.0 -->
```

---

## Logic Xử Lý (3 tầng)

### Tầng 1: CREATE (dự án chưa có docs)

```yaml
phase_0_create:
  check: "docs/PLAN.md does NOT exist"
  actions:
    - ingest: "Scan docs/ folder → đọc mọi .md files có sẵn (PRD, specs, etc.)"
    - synthesize: "Tổng hợp nội dung docs có sẵn vào PLAN.md chuẩn"
    - create: "docs/PLAN.md"         # Tổng hợp từ docs có sẵn + compliance stamp
    - create: "tasks/todo.md"        # Với compliance stamp
    - create: "tasks/lessons.md"     # Với compliance stamp
    - create_or_skip: "README.md"    # Tạo nếu chưa có
  preserve: "Docs gốc (PRD.md, specs...) được GIỮ NGUYÊN, không xóa"
  silent: true  # Không cần hỏi user
```

### Tầng 2: UPGRADE (docs có nhưng chưa chuẩn)

```yaml
phase_0_upgrade:
  check: "docs/PLAN.md exists BUT missing '<!-- antigravity: v1.0 -->'"
  actions:
    - ingest: "Đọc TOÀN BỘ docs/ folder + README.md + project root *.md"
    - analyze: "Extract features, tech stack, data model, constraints từ docs có sẵn"
    - scan: "So sánh với PLAN.md chuẩn → identify gaps"
    - propose: |
        📋 Đã đọc và phân tích docs hiện có:
        • {list of docs found, e.g. PRD.md (26KB), SIGNAL_FORMATS.md (4KB)}
        
        Đã có:
        - [x] {sections already covered by existing docs}
        
        Cần bổ sung:
        - [ ] {missing sections}
        
        Chuẩn hóa? (Y/n) — Chỉ hỏi LẦN NÀY, sau đó không lặp lại.
    - wait_confirm: true
    - on_yes: "Tổng hợp docs có sẵn + fill gaps → PLAN.md chuẩn + stamp"
    - on_no: "Add stamp anyway → never ask again"
  
  rules:
    - "NEVER overwrite existing content — only ADD missing sections"
    - "NEVER delete/modify original docs — PLAN.md is a synthesis layer"
    - "Reference original docs in PLAN.md: 'Chi tiết: xem docs/PRD.md'"
```

### Tầng 3: SKIP (docs đã chuẩn)

```yaml
phase_0_skip:
  check: "docs/PLAN.md contains '<!-- antigravity: v1.0 -->'"
  action: "SKIP → Phase 1 immediately"
  log: "✅ Project docs compliant (v1.0), skipping bootstrap"
  silent: true  # Không output gì
```

---

## Quy Tắc Chống Lặp (Anti-Nagging)

1. **Hỏi tối đa 1 lần** — sau khi upgrade hoặc skip, gắn stamp → xong
2. **Không overwrite** — UPGRADE chỉ BỔ SUNG, không xóa nội dung cũ
3. **Stamp = contract** — có stamp = hệ thống tin tưởng, bỏ qua kiểm tra
4. **User skip = vẫn stamp** — nếu user nói "không", vẫn gắn stamp → không hỏi lại
5. **Version upgrade** — chỉ trigger khi template version tăng (v1.0 → v2.0)

---

## Chất Lượng Tài Liệu

**Yêu cầu bắt buộc cho mỗi doc:**
- ✅ Không có placeholder text ("TBD", "fill in later")
- ✅ Dùng dữ liệu thực từ scan/planning
- ✅ Task phải đo lường được (không phải "improve performance" mà phải "reduce load time to <200ms")
- ✅ Tech decisions phải có WHY (STANDARDS.md § 10)
- ✅ Mỗi doc kết thúc bằng compliance stamp `<!-- antigravity: v1.0 -->`

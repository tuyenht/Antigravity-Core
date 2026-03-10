---
description: "Chuẩn hóa toàn bộ tài liệu dự án đạt chuẩn Antigravity. Chạy 1 lần duy nhất."
---

# /init-docs — Docs Standardization Workflow

// turbo-all

Quét toàn bộ codebase + docs → phân loại → tạo tài liệu chuẩn → archive legacy files.
Chạy **1 lần duy nhất** khi bắt đầu vào bất kỳ dự án nào (mới hoặc cũ).

**Khi nào dùng:**
- Lần đầu mở project chưa có docs chuẩn Antigravity
- Sau khi install Antigravity-Core (`agi`) vào project cũ
- Project có docs lộn xộn cần chuẩn hóa

**Auto-chain triggers (tự động gọi bởi hệ thống):**
- **Prompt B2:** Khi docs/ có >5 files chưa stamp → B2 auto-chain `/init-docs` trước
- **Pipeline Phase 0 (CREATE mode):** Khi docs/ có nhiều files chưa chuẩn

**Khác với `/requirements-first`:**
- `/init-docs` = chuẩn hóa docs CÓ SẴN (project-level, chạy 1 lần)
- `/requirements-first` = tạo PRD cho feature MỚI (feature-level, chạy nhiều lần)

**Agent:** `explorer-agent` → `project-planner`
**Skills:** `app-builder, architecture, clean-code, plan-writing`

$ARGUMENTS

---

## Phase 1: FULL SCAN (5-10 phút)

### Step 1.1: Quét docs/ folder

```yaml
docs_scan:
  targets:
    - "docs/*.md"           # Mọi .md files trong docs/
    - "docs/*.txt"          # Các text files (legacy prompts)
    - "docs/**/*.md"        # Subdirectories
    - "README.md"           # Project root
    - "*.md"                # Root-level docs (CONTRIBUTING, CHANGELOG...)
  action: "read_all: true — Đọc TOÀN BỘ nội dung, không skip"
  output: "Raw docs inventory (filename, size, first 200 chars summary)"
```

### Step 1.2: Quét codebase

```yaml
code_scan:
  targets:
    - "package.json / composer.json / pyproject.toml / *.csproj"  # Tech stack
    - "src/ / app/ / lib/"                                          # Source code structure
    - ".env.example"                                                # Config
    - "prisma/schema.prisma / database/migrations/"                 # Database
    - ".github/workflows/ / Dockerfile"                             # CI/CD
  action: "Detect tech stack, file structure, code patterns"
```

### Step 1.3: Git history (nếu có)

```bash
git log --oneline -20                    # Recent history
git shortlog -sn --all | head -5         # Top contributors
```

---

## Phase 2: ANALYSIS — 17 Categories

Phân tích codebase theo 17 categories (từ Prompt B2 specification):

| # | Category | Focus |
|---|----------|-------|
| 1 | Tech Stack Detection | Language, framework, database, ORM, auth, build tool |
| 2 | Routes & API Endpoints | Count, auth-protected vs public, versioning |
| 3 | Controllers / Handlers | Fat controllers, validation, error handling |
| 4 | Models / Data Layer | Entities, relationships, scopes |
| 5 | Database & Schema | Tables, indexes, FKs, missing indexes |
| 6 | Frontend Architecture | Components, state, routing, styling |
| 7 | Configuration | .env, secrets, feature flags |
| 8 | Services & Business Logic | Service layer, DI, external APIs |
| 9 | Tests & Coverage | Unit/Integration/E2E, coverage % |
| 10 | Documentation Quality | README, API docs, inline comments |
| 11 | Code Quality | Linting, formatting, dead code |
| 12 | Security Posture | Auth, RBAC, XSS, CSRF, dependencies |
| 13 | Git History | Contributors, code churn hotspots |
| 14 | Performance | N+1 queries, caching gaps |
| 15 | Dependency Graph | Circular deps, unused packages |
| 16 | Complexity Heatmap | Files >500 lines RED, >300 YELLOW |
| 17 | API Testing Strategy | Endpoint coverage, error scenarios |

**Output:** Structured findings per category — dữ liệu thật, không placeholder.

---

## Phase 3: CLASSIFY — 3-Tier Docs Taxonomy

Map mỗi file docs/ hiện có vào hệ thống phân tầng:

```yaml
classification:
  tier_1_core:
    description: "BẮT BUỘC — mọi dự án"
    files:
      - PROJECT-BRIEF.md    # ⭐ SSoT cho AI
      - PLAN.md              # Roadmap + stamp-check
      - CONVENTIONS.md       # Coding standards
    action: "Tạo mới nếu chưa có, update nếu đã có"

  tier_2_domain:
    description: "Chuyên sâu — tạo khi cần"
    files:
      - PRD.md / ARCHITECTURE.md / SCHEMA.md / SECURITY.md
      - DEPLOYMENT.md / TESTING-STRATEGY.md / PERFORMANCE.md
      - I18N.md / PROJECT-SCREENS.md / CONTEXT-MANIFEST.md
    naming: "UPPERCASE, kebab-case cho multi-word"
    action: "Standardize tên nếu sai (performance.md → PERFORMANCE.md)"

  tier_3_project:
    description: "Feature specs riêng dự án — giữ nguyên"
    files: "{FEATURE}.md, ONBOARDING.md, HANDBOOK.md"
    action: "Giữ nguyên tên và nội dung"

  legacy:
    description: "Files đã merge hoặc không chuẩn"
    action: "Archive vào docs/_legacy/"
```

**Output:** Bảng phân loại:

| File hiện có | Tier | Hành động |
|:-------------|:----:|:----------|
| `PROJECT-BRIEF.md` | 1 | ✅ Giữ |
| `PLAN-mvp-complete.md` | 1 | → Rename `PLAN.md` |
| `performance.md` | 2 | → Rename `PERFORMANCE.md` |
| `PROJECT-RULES.md` | — | → Merge vào `CONVENTIONS.md` |
| `CHECKPOINT_v6.4.md` | — | → Archive `_legacy/` |

---

## Phase 4: GENERATE — Tạo Tài liệu Chuẩn

### Step 4.1: Tier 1 files (BẮT BUỘC)

**Dùng templates từ `.agent/templates/`:**

```yaml
generate:
  PROJECT-BRIEF.md:
    template: ".agent/templates/PROJECT-BRIEF-TEMPLATE.md"
    source: "Phase 2 analysis data + existing docs content"
    rule: "Fill ALL sections bằng dữ liệu thật — KHÔNG [TBD]"
    merge: "Nếu file đã tồn tại → đọc, bổ sung, KHÔNG overwrite"
    stamp: "<!-- antigravity-brief: v1.0 -->"

  PLAN.md:
    source: "Phase 2 analysis + tech decisions + milestones"
    stamp: "<!-- antigravity: v1.0 -->"
    note: "File này dùng cho Phase 0 stamp-check"

  CONVENTIONS.md:
    template: ".agent/templates/PROJECT-CONVENTIONS-TEMPLATE.md"
    source: "Auto-extract patterns từ codebase (naming, imports, test patterns)"
    merge: "Merge từ PROJECT-RULES.md, .editorconfig, linting configs"
```

### Step 4.2: Tier 2 files (khi phù hợp)

```yaml
standardize:
  rename:
    - "performance.md → PERFORMANCE.md"
    - "PLAN-mvp-complete.md → PLAN.md"
    - "PRD-BSWeb-SaaS.md → PRD.md"
  merge:
    - "PROJECT-RULES.md + .editorconfig → CONVENTIONS.md"
    - "FULL-PROJECT-STRUCTURE.md → ARCHITECTURE.md"
    - "project-manifest.md → PROJECT-BRIEF.md"
  keep: "Files đúng tên chuẩn (SECURITY.md, DEPLOYMENT.md...)"
```

### Step 4.3: Support files

```yaml
create:
  - "docs/CONTEXT-MANIFEST.md"  # Template: CONTEXT-MANIFEST-TEMPLATE.md
  - "tasks/todo.md"              # Prioritized action items
  - "tasks/lessons.md"           # Learning log template
  - "README.md"                  # Chỉ tạo nếu chưa có
```

### Step 4.4: Merge rules

```
KHI MERGE nội dung từ legacy files:
- Ghi rõ source: "<!-- Consolidated from: project-manifest.md, FULL-PROJECT-STRUCTURE.md -->"
- Giữ nguyên thông tin quan trọng — không mất data
- Nếu conflict → ưu tiên dữ liệu mới hơn (by file modified date)
```

---

## Phase 5: ARCHIVE — Dọn dẹp Legacy

```yaml
archive:
  step_1: "HỎI user 1 lần: 'Di chuyển X files đã merge vào docs/_legacy/? (Y/n)'"
  step_2_yes:
    - "Tạo docs/_legacy/ nếu chưa có"
    - "Move files đã merge/rename → docs/_legacy/"
    - "Move engine prompt files (.txt) → docs/_legacy/"
  step_2_no:
    - "Giữ nguyên tất cả files"
    - "Ghi note trong PLAN.md: 'Legacy docs chưa archive'"
  rule: "KHÔNG BAO GIỜ XÓA — chỉ di chuyển"
```

---

## Phase 6: VALIDATE

```yaml
validate:
  tier_1_check:
    - "docs/PROJECT-BRIEF.md tồn tại + đầy đủ 11 sections"
    - "docs/PLAN.md tồn tại + có stamp <!-- antigravity: v1.0 -->"
    - "docs/CONVENTIONS.md tồn tại + có ≥5 sections"
  no_placeholder:
    - "Grep tất cả Tier 1 files: không chứa [TBD], {placeholder}, TODO"
  manifest:
    - "docs/CONTEXT-MANIFEST.md liệt kê đúng tất cả files"
  output: |
    ✅ Docs standardization complete:
    - X files created, Y files renamed, Z files archived
    - Tier 1: 3/3 ✅
    - Tier 2: N files standardized
    - Legacy: M files archived to docs/_legacy/
```

---

## Ví dụ

```
/init-docs                                    # Auto-detect mọi thứ
/init-docs Chuẩn hóa docs cho BSWebSaaSProject
/init-docs --force                            # Re-run (bypass stamp check)
```

---

## Checklist

- [ ] Phase 1: Full scan completed (code + docs + git)
- [ ] Phase 2: 17/17 categories analyzed với dữ liệu thật
- [ ] Phase 3: Classification table created
- [ ] Phase 4: Tier 1 files created/updated (3/3)
- [ ] Phase 4: Tier 2 files standardized (renamed/merged)
- [ ] Phase 5: Legacy files archived (user confirmed)
- [ ] Phase 6: Validation passed (no placeholders, stamps present)

---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| Project không có docs/ folder | Tạo mới, chạy full analysis từ code |
| docs/ có quá nhiều files (>30) | Vẫn đọc ALL — budget 10 phút cho scan |
| User từ chối archive | Giữ nguyên, proceed — ghi note |
| Conflict khi merge content | Ưu tiên file mới hơn (modified date) |
| PROJECT-BRIEF.md đã tồn tại | ĐỌC trước, chỉ BỔ SUNG sections thiếu |
| Re-run sau lần đầu | Dùng `--force` flag để bypass stamp check |

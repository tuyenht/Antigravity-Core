---
description: "Pipeline Chain: Tạo dự án hoặc module mới từ đầu (end-to-end)."
---

# 🆕 BUILD Pipeline — Tạo Mới Từ Đầu

> **Trigger:** Intent Router classifies request as BUILD
> **Khi nào:** User muốn tạo dự án / module / hệ thống hoàn toàn mới
> **Thời gian ước tính:** 15-60 phút tùy quy mô

---

## Pipeline Flow

```
PHASE 0        PHASE 1        PHASE 2          PHASE 3          PHASE 4         PHASE 5
BOOTSTRAP →    DISCOVERY  →   PLANNING    →    SCAFFOLDING  →   QUALITY    →    DELIVERY
(auto)         (2 phút)       (5-10 phút)      (10-30 phút)     (5 phút)        (2 phút)
   │               │                 │                │                │               │
   └→ Tạo docs    └→ Hiểu yêu    └→ Kế hoạch      └→ Tạo code     └→ Test +      └→ Dev server
      dự án chuẩn     cầu cơ bản      + schema          + structure      lint check      + demo
```

---

## PHASE 0: BOOTSTRAP (Tạo tài liệu dự án)

**Template:** `templates/project-bootstrap.md`
**Bắt buộc:** CÓ — mọi dự án mới PHẢI có docs trước khi code.

### 3-Tier Check
```
1. docs/PLAN.md không tồn tại          → CREATE (tạo mới toàn bộ)
2. docs/PLAN.md có nhưng thiếu stamp   → UPGRADE (bổ sung + stamp + Docs Ingestion)
3. docs/PLAN.md có stamp v1.0          → SKIP (qua Phase 1 ngay)
```

> **Docs Ingestion (UPGRADE mode):** Nếu `docs/` đã có files (.md) → đọc, phân tích,
> tổng hợp nội dung vào PLAN.md chuẩn. Giữ nguyên files gốc, không xóa.

### Auto-Actions (CREATE mode)
1. Tạo `docs/PLAN.md` — skeleton (sẽ điền đầy đủ ở Phase 2)
2. Tạo `tasks/todo.md` — task tracking
3. Tạo `tasks/lessons.md` — learning file
4. Tạo hoặc cập nhật `README.md` — hướng dẫn cơ bản
5. Gắn compliance stamp `<!-- antigravity: v1.0 -->` vào mỗi doc

> ⚠️ Phase 0 CHỈ tạo skeleton docs. Không phỏng vấn user. Không tạo PRD.

---

## PHASE 1: DISCOVERY (Thu thập yêu cầu + Smart PRD)

**Agent:** Không cần agent — AI trực tiếp.
**Mục tiêu:** Thu thập ĐỦ thông tin + quyết định có cần PRD không.

### Smart Interview — 3 tầng theo complexity

AI tự đánh giá complexity từ mô tả ban đầu → chọn tầng phù hợp:

```yaml
tier_1_simple:
  when: "Landing page, portfolio, CLI tool, single-feature app"
  questions: 2
  prd: false
  ask:
    - "Đây là loại app gì?" (nếu chưa rõ)
    - "Tính năng chính MVP?" (nếu chưa liệt kê)
  skip_if_clear: true
  output: "PLAN.md đủ dùng"

tier_2_moderate:
  when: "CRUD app, dashboard, blog, API có 3-5 features"
  questions: 7-10
  prd: false
  ask:
    - Business: Mục đích, users, success criteria
    - Tech: Core features, auth cần không, data model chính
    - Design: Web/mobile, style preference
  output: "PLAN.md + mini-brief"

tier_3_complex:
  when: "SaaS, e-commerce, multi-user, 5+ features, có payment/auth/API"
  questions: 26 (7 categories)
  prd: true  # ← CHỈ tier 3 mới tạo PRD
  action: "Chain → /requirements-first workflow"
  categories:
    1. Business Context (5Q): mục đích, KPIs, timeline, team
    2. Technical Requirements (7Q): features, auth, data model, real-time, APIs
    3. Scale & Performance (4Q): traffic, data volume, performance targets
    4. Infrastructure & Budget (3Q): hosting, budget, team expertise
    5. Design & UX (3Q): visual style, platform, accessibility
    6. Security & Compliance (2Q): GDPR, encryption level
    7. Future & Special (2Q): v2.0 plans, special needs
  output: "docs/PRD.md (9 sections) + PLAN.md"
```

> 🔴 **Nguyên tắc:** Hỏi từng category, ĐỢI trả lời xong rồi hỏi tiếp. KHÔNG hỏi tất cả cùng lúc.
> ⛔ **Nếu tier_3 + PRD generated:** User PHẢI approve PRD trước khi sang Phase 2.

### Output Phase 1
- Hiểu rõ: loại app, tính năng chính, constraints
- Quyết định tech stack (AI recommend, user confirm)
- `docs/PRD.md` (chỉ tier_3 complex projects)

---

## PHASE 2: PLANNING (Lên kế hoạch)

**Agent:** `project-planner` + `database-architect`
**Skills:** `plan-writing`, `architecture`, `database-design`

### Auto-Actions
1. Phân tích yêu cầu → Task breakdown
2. Chọn tech stack → Auto-detect hoặc recommend tối ưu
3. Thiết kế database schema (nếu có DB)
4. Tạo cấu trúc thư mục
5. **Nếu project có UI** → Tạo `docs/PROJECT-SCREENS.md` từ `templates/PROJECT-SCREENS-TEMPLATE.md`

### Output Phase 2
- `docs/PLAN.md` — Kế hoạch triển khai (điền đầy đủ từ skeleton Phase 0)
- Schema design (nếu có DB)
- `docs/PROJECT-SCREENS.md` — UI Screen Blueprint (nếu có UI)

### ⛔ CHECKPOINT
```
Trình bày plan cho user:
- Tech stack đã chọn
- Tính năng sẽ build (MVP)
- Cấu trúc dự án

→ User nói "OK" / "tiếp" / "Xacnhan" → Sang Phase 3
→ User yêu cầu thay đổi → Điều chỉnh plan
```

---

## PHASE 3: SCAFFOLDING (Tạo code)

**Agents:** Auto-selected by tech stack:

| Stack Detected | Primary Agent | Supporting |
|----------------|---------------|-----------|
| Laravel + React | `backend-specialist` | `frontend-specialist` |
| Next.js | `frontend-specialist` | `backend-specialist` |
| Python (FastAPI/Flask) | `backend-specialist` | — |
| Mobile (RN/Flutter) | `mobile-developer` | — |
| Pure API | `backend-specialist` | `database-architect` |

**Skills:** `app-builder`, stack-specific skills
**Rules:** Auto-loaded via `systems/auto-rule-discovery.md`

### Auto-Actions
1. Initialize project (framework CLI: `npx create-next-app`, `composer create-project`...)
2. Create database schema + migrations (nếu có)
3. Generate CRUD modules cho core features
4. Setup authentication (nếu cần)
5. Create base UI components
6. Setup routing/navigation
7. Create `.gitignore` + `.env.example` + initialize git

### Chaining Existing Workflows
```
Nội bộ, phase này chain:
├── /create workflow    → Project initialization
├── /scaffold workflow  → CRUD generation
└── /schema-first       → Database setup (nếu có DB)
```

### Post-Init Directory Convention
Sau khi framework CLI init xong, AI BỔ SUNG thêm các thư mục enterprise-grade:

```yaml
laravel_inertia_react:
  add_dirs: ["app/Services/", "app/Actions/", "app/DTOs/"]
  note: "Business logic vào Services, KHÔNG viết trong Controller"

nextjs:
  add_dirs: ["src/features/", "src/components/ui/", "src/lib/", "src/types/"]
  note: "Tổ chức theo feature-based, KHÔNG theo file-type"

fastapi:
  add_dirs: ["src/domain/", "src/api/dependencies/", "src/core/"]
  note: "Domain logic tách riêng, KHÔNG viết trong routes"

react_native_expo:
  add_dirs: ["src/features/", "src/components/", "src/services/", "src/navigation/"]
  note: "Feature-first architecture"

general:
  always_create:
    - ".env.example"   # Với APP_NAME, DB_*, cache, API keys (placeholder)
    - ".gitignore"     # Phù hợp tech stack (node_modules, vendor, .env, dist, __pycache__)
    - "README.md"      # Nếu chưa có (đã được Bootstrap tạo)
```

### Output Phase 3
- Full project structure (CLI + enterprise dirs)
- Working CRUD modules
- Database migrations
- Config files (.gitignore, .env.example)

---

## PHASE 4: QUALITY (Kiểm tra chất lượng)

**Agents:** `test-engineer` + `ai-code-reviewer`
**Skills:** `testing-patterns`, `clean-code`, `lint-and-validate`

### Auto-Actions
1. Write unit tests cho core modules
2. Run linter (eslint/phpstan/ruff)
3. Run type check (tsc/phpstan/mypy)
4. Quick security scan
5. **Nếu UI project (tier_2+):** Build size check + accessibility audit (WCAG AA)
6. **Nếu tier_3 complex:** Performance budget check (LCP < 2.5s, CLS < 0.1)

### Chaining Existing Workflows
```
├── /test workflow      → Generate tests
├── /check workflow     → Health check + AI code review
└── /auto-healing       → Fix lint/type errors automatically
```

### Output Phase 4
- Test files
- Lint/type clean ✅
- Quality report
- Accessibility report (nếu UI)
- Performance baseline (nếu tier_3)

---

## PHASE 5: DELIVERY (Bàn giao)

**Mục tiêu:** User thấy sản phẩm chạy được.

### Auto-Actions
1. Start dev server (`npm run dev` / `php artisan serve` / tương đương)
2. Hiển thị URL cho user
3. Summary report

### Output Phase 5
```
✅ Dự án đã sẵn sàng!

📁 Cấu trúc: [tóm tắt]
🌐 Dev server: http://localhost:XXXX
📝 Plan: docs/PLAN-{slug}.md
🧪 Tests: X tests, all passing

Tiếp theo bạn có thể:
→ Mô tả tính năng mới để thêm (ENHANCE pipeline)
→ /deploy để triển khai lên server
```

---

## Project Template Selection

```yaml
auto_select_template:
  web_fullstack:
    detect: "dashboard, admin, CRUD, management system"
    stack: "Next.js | Laravel + Inertia"
    
  api_only:
    detect: "API, backend, service, microservice"
    stack: "FastAPI | Express | Laravel API"
    
  mobile:
    detect: "mobile app, iOS, Android, cross-platform"
    stack: "React Native (Expo) | Flutter"
    
  static_site:
    detect: "blog, landing page, portfolio, documentation"
    stack: "Next.js (static) | Astro"
```

---

## 🧬 PHASE FINAL: LEARNING (Tự động — không cần user)

> Chạy SAU KHI pipeline hoàn tất. AI tự ghi nhận kinh nghiệm.

### Auto-Actions
1. **Record** pipeline result vào `memory/learning-patterns.yaml`
2. **Track** usage vào `project.json → usage_tracking.pipelines_used.BUILD`

### Data to Record
```yaml
# Append to memory/learning-patterns.yaml
- date: "{today}"
  pipeline: "BUILD"
  project: "{project_name}"
  tech_stack: "{detected_stack}"
  what_worked: "{things that went smoothly}"
  what_failed: "{issues encountered, if any}"
  user_friction: "{moments user was frustrated or confused}"
  time_taken: "{approximate duration}"
  improvement_idea: "{suggestion to improve this pipeline}"
```

### Increment Usage Counter
```
project.json → usage_tracking.pipelines_used.BUILD += 1
```

> ⚠️ This phase is SILENT — no output to user. Just background logging.

---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| npx create fails | Check Node.js version, try `npx -y` flag |
| Port already in use | Kill process: `npx kill-port 3000` |
| Dependencies conflict | Delete `node_modules` + lock file, reinstall |
| User wants stack AI didn't recommend | Respect user choice, apply with Technical Debt Warning if sub-optimal |

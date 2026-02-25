---
description: Đồng bộ dự án admin hiện có với blueprint mới nhất từ Antigravity-Core
---

# /sync-admin — Admin Blueprint Sync

// turbo-all

**Agent:** `orchestrator`  
**Skills:** `velzon-admin, app-builder`

Kiểm tra và cập nhật dự án admin đã tạo (bằng `/create-admin`) theo blueprint mới nhất sau khi Antigravity-Core được update.

**Khi nào dùng:** Sau khi chạy `agu` (update Antigravity-Core), mở dự án cũ và chạy `/sync-admin` để nhận thay đổi.

---

## Workflow Steps

### Step 1: Detect Project & Load Blueprint

```
1. Detect framework (giống /create-admin Step 1)
2. Detect MODE (saas/standalone) từ .env
3. Load blueprint mới nhất: .agent/skills/velzon-admin/reference/saas-admin-starter.md
4. Load framework pattern file tương ứng
```

---

### Step 2: Scan Current Project

Scan dự án hiện tại để lập inventory:

```
Scan targets:
├── Assets
│   └── Images → logos, favicon, flags, avatars (from .agent/skills/velzon-admin/assets/images/)
├── Database
│   ├── Migrations/Schema → tables, columns, indexes
│   └── Seeders → roles, permissions, admin user
├── Auth
│   ├── Auth screens (Login, Forgot, Reset, 2FA, Logout)
│   └── Middleware (auth guard, RBAC guard)
├── Admin
│   ├── Layouts/ → Header, Sidebar, Footer, RightSidebar
│   ├── Components/Common/ → BreadCrumb, TableContainer, etc.
│   ├── Pages → Dashboard, Users, Roles, Settings, Profile
│   └── LayoutMenuData → menu items
├── Config
│   ├── Admin prefix
│   ├── i18n keys
│   └── Error pages (403, 404, 500)
└── State
    ├── Redux slices (React) / Pinia stores (Vue)
    └── API routes / Controllers
```

---

### Step 3: Compare & Generate Diff Report

So sánh blueprint vs project hiện tại, phân loại:

| Category | Status | Action |
|----------|--------|--------|
| 🟢 **Up-to-date** | Component/feature khớp blueprint | Không cần thay đổi |
| 🟡 **Outdated** | Tồn tại nhưng thiếu fields/features mới | Cập nhật (merge) |
| 🔴 **Missing** | Blueprint có nhưng project chưa có | Tạo mới |
| ⚪ **Custom** | Project có nhưng blueprint không có | Giữ nguyên (user customization) |

**Output format:**

```
📊 Sync Report: MyProject ↔ Blueprint v2026.02.23
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🟢 Up-to-date (12)
   ✓ Login, Forgot Password, Reset Password, 2FA, Logout
   ✓ User CRUD (List, Create, Edit, Delete)
   ✓ Role List, Permission Matrix
   ✓ Layout (Header, Sidebar, Footer)

🟡 Outdated (3)
   ⚠ users table — thiếu columns: last_login_at, last_login_ip
   ⚠ Sidebar — thiếu permission filter cho SaaS mode
   ⚠ i18n — thiếu 5 keys mới (invite_title, active_sessions, etc.)

🔴 Missing (4)
   ✗ audit_logs table + AuditTimeline component
   ✗ User Invitation system (invite form + email)
   ✗ Session Management (active sessions on profile)
   ✗ Theme Customizer (RightSidebar)

⚪ Custom (2)
   → ProductsPage (user-created, not in blueprint)
   → CustomDashboardWidget (user-created)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Action needed: 3 updates + 4 new features
```

---

### Step 4: User Confirmation

Hiển thị report → Hỏi user:

```
Bạn muốn:
(1) Apply ALL — Cập nhật tất cả (🟡 + 🔴)
(2) Select — Chọn từng item để apply
(3) Review — Xem chi tiết từng thay đổi trước
(4) Skip — Không apply, chỉ lưu report
```

---

### Step 5: Apply Changes

**Theo thứ tự an toàn:**

```
0. Assets (copy missing logos, favicon, flags from .agent/skills/velzon-admin/assets/images/)
1. Database migrations (additive only — KHÔNG xóa columns/tables)
2. Seeders (merge new permissions/roles, KHÔNG reset data)
3. Models (add new fields, relationships)
4. Components (add missing, update outdated)
5. Pages (add missing features)
6. Config (merge i18n keys, update menu)
7. State management (add new slices/stores)
```

> [!CAUTION]
> **KHÔNG BAO GIỜ:**
> - Xóa user customizations (⚪ Custom items)
> - Drop columns/tables có data
> - Overwrite files user đã sửa mà không hỏi
> - Reset seeders (sẽ mất data)

---

### Step 6: Verify

```bash
# Run migrations
php artisan migrate  # or npx prisma migrate dev

# Run seeders (additive only)
php artisan db:seed --class=SyncPermissionsSeeder

# Lint + Build + Dev
npm run lint && npm run build && npm run dev
```

**Checklist:**
- [ ] Migrations applied without errors
- [ ] New permissions seeded correctly
- [ ] Existing data preserved
- [ ] New components render correctly
- [ ] Updated components still work
- [ ] Custom pages unaffected

---

## Error Handling

| Situation | Action |
|-----------|--------|
| Migration conflict | Show SQL diff, ask user to resolve |
| File already modified by user | Show 3-way diff (blueprint vs old vs user), ask to merge |
| Breaking schema change | Create backup first (`/backup`), then apply |
| No changes detected | Report "Project is up-to-date ✅" |


---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| Lỗi không xác định hoặc crash | Bật chế độ verbose, kiểm tra log hệ thống, cắt nhỏ phạm vi debug |
| Thiếu package/dependencies | Kiểm tra file lock, chạy lại npm/composer install |
| Xung đột context API | Reset session, tắt các plugin/extension không liên quan |
| Thời gian chạy quá lâu (timeout) | Cấu hình lại timeout, tối ưu hóa các queries nặng |

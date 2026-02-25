---
description: Thêm/sửa tính năng cho dự án hiện có
---

# /enhance - Cập Nhật Dự Án

// turbo-all

**Agent:** `orchestrator`  
**Skills:** `app-builder, clean-code, testing-patterns`

$ARGUMENTS

---

## Bước 1: Nhận diện dự án hiện tại

**Tự động phát hiện framework:**

```
Auto-detect từ project files:
├── package.json + "next"        → Next.js
├── package.json + "react"       → React 
├── package.json + "vue"         → Vue.js
├── composer.json + "laravel"    → Laravel
├── pyproject.toml + "fastapi"   → FastAPI
├── pubspec.yaml                 → Flutter
└── Cargo.toml                   → Rust

→ Load rules tương ứng từ .agent/rules/
→ Load conventions từ .agent/skills/
```

## Bước 1.5: Tạo/Cập nhật Project Analysis Docs

### Tier 1: Bắt buộc (mọi dự án)

**Nếu chưa có** `docs/PROJECT-BRIEF.md` hoặc `docs/PROJECT-CONVENTIONS.md`:
1. Phân tích toàn bộ codebase
2. Tạo theo template:
   - `.agent/templates/PROJECT-BRIEF-TEMPLATE.md` → `docs/PROJECT-BRIEF.md`
   - `.agent/templates/PROJECT-CONVENTIONS-TEMPLATE.md` → `docs/PROJECT-CONVENTIONS.md`
3. Fill ALL sections bằng dữ liệu thực tế từ codebase

**Nếu đã có**: Đọc và sử dụng làm context cho các bước tiếp theo.

### Tier 2: Có điều kiện

| Điều kiện | Template | Output |
|-----------|----------|--------|
| Project có UI (admin panel, web app, mobile) | `PROJECT-SCREENS-TEMPLATE.md` | `docs/PROJECT-SCREENS.md` |
| Project có custom API endpoints | `PROJECT-API-TEMPLATE.md` | `docs/PROJECT-API.md` |

**Chỉ tạo Tier 2 khi điều kiện match.** CLI/library chỉ cần Tier 1.

## Bước 2: Lên kế hoạch thay đổi
- Xác định files bị ảnh hưởng
- Kiểm tra dependencies
- Ước lượng phạm vi thay đổi

## Bước 3: Trình bày kế hoạch (cho thay đổi lớn)
```
"Để thêm admin panel:
- Tạo mới 15 files
- Cập nhật 8 files
- Ước tính ~10 phút

Bắt đầu chứ?"
```

## Bước 4: Thực hiện
- Gọi các agent phù hợp
- Áp dụng thay đổi
- Chạy test

## Bước 5: Xem kết quả
- Hot reload hoặc restart server

---

## Ví dụ

```
/enhance add dark mode
/enhance build admin panel
/enhance integrate payment system
/enhance add search feature
/enhance make responsive
```

---

## Lưu ý

- Xin phép trước khi thay đổi lớn
- Cảnh báo khi có xung đột (vd: "dùng Firebase" khi project dùng PostgreSQL)
- Commit mỗi thay đổi với git

---

##  Enhance Checklist

- [ ] Existing project detected correctly
- [ ] Current architecture understood
- [ ] Impact analysis completed (files affected)
- [ ] Change plan presented to user (for large changes)
- [ ] Implementation completed
- [ ] Existing tests still pass
- [ ] New tests added for new features
- [ ] Lint/type check clean

---

## Troubleshooting

| V?n d? | Gi?i ph�p |
|---------|-----------|
| Framework not detected | Check for config files, specify manually |
| Conflicts with existing code | Analyze dependencies first, refactor if needed |
| Breaking existing features | Run full test suite before and after changes |
| Unclear scope | Ask user to break into smaller tasks |

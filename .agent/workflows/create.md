---
description: Tạo dự án mới từ đầu
---

# /create - Tạo Dự Án Mới

$ARGUMENTS

---

## Bước 0: Kiểm tra dự án đã tồn tại

**QUAN TRỌNG:** Trước khi tạo mới, kiểm tra thư mục hiện tại:

```
Check for existing project indicators:
├── package.json     → Node.js project exists
├── composer.json    → PHP/Laravel project exists
├── pyproject.toml   → Python project exists
├── pubspec.yaml     → Flutter project exists
├── Cargo.toml       → Rust project exists
└── .git/            → Git repo exists

If ANY indicator found:
  → WARN: "Thư mục này đã chứa dự án [type]. Bạn muốn:"
    1. Thêm tính năng mới (→ chuyển sang /enhance)
    2. Tạo dự án mới trong thư mục con
    3. Ghi đè (cần xác nhận rõ ràng)
```

---

## Bước 1: Phân tích yêu cầu
- Hiểu người dùng muốn tạo gì
- Nếu thiếu thông tin → Kích hoạt Socratic Gate (tối thiểu 3 câu hỏi)

## Bước 2: Lập kế hoạch
- Dùng `project-planner` agent để phân tách task
- Chọn tech stack (dựa trên project-detection.md)
- Lên cấu trúc file
- Tạo plan file và tiến hành xây dựng

## Bước 3: Xây dựng (sau khi được duyệt)
- Phối hợp với `app-builder` skill
- Điều phối các agent chuyên gia:
  - `backend-specialist` → API, logic
  - `frontend-specialist` → UI
  - Database → Schema

## Bước 4: Xem trước
- Chạy `npm run dev` hoặc tương đương
- Hiển thị URL cho người dùng

---

## Ví dụ

```
/create blog site
/create e-commerce app with product listing and cart
/create todo app
/create crm system with customer management
```

---

## Trước khi bắt đầu

Nếu yêu cầu chưa rõ ràng, hỏi:
- Loại ứng dụng gì?
- Tính năng cơ bản nào?
- Ai sẽ sử dụng?

---
description: "Khởi tạo dự án phần mềm mới từ đầu theo tiêu chuẩn Antigravity."
---

# /create - Tạo Dự Án Mới

// turbo-all

**Agent:** `project-planner + orchestrator`  
**Skills:** `app-builder, plan-writing, architecture`

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

## Bước 2.5: Tạo Project Analysis Docs

### Tier 1: Bắt buộc (mọi dự án mới)
1. `.agent/templates/PROJECT-BRIEF-TEMPLATE.md` → `docs/PROJECT-BRIEF.md`
2. `.agent/templates/PROJECT-CONVENTIONS-TEMPLATE.md` → `docs/PROJECT-CONVENTIONS.md`

Fill ALL sections bằng thông tin từ planning phase.

### Tier 2: Có điều kiện

| Điều kiện | Template | Output |
|-----------|----------|--------|
| Dự án có UI | `PROJECT-SCREENS-TEMPLATE.md` | `docs/PROJECT-SCREENS.md` |
| Dự án có custom API | `PROJECT-API-TEMPLATE.md` | `docs/PROJECT-API.md` |

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
---

# /create - Tạo Dự Án Mới

// turbo-all

**Agent:** `project-planner + orchestrator`  
**Skills:** `app-builder, plan-writing, architecture`

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

## Bước 2.5: Tạo Project Analysis Docs

### Tier 1: Bắt buộc (mọi dự án mới)
1. `.agent/templates/PROJECT-BRIEF-TEMPLATE.md` → `docs/PROJECT-BRIEF.md`
2. `.agent/templates/PROJECT-CONVENTIONS-TEMPLATE.md` → `docs/PROJECT-CONVENTIONS.md`

Fill ALL sections bằng thông tin từ planning phase.

### Tier 2: Có điều kiện

| Điều kiện | Template | Output |
|-----------|----------|--------|
| Dự án có UI | `PROJECT-SCREENS-TEMPLATE.md` | `docs/PROJECT-SCREENS.md` |
| Dự án có custom API | `PROJECT-API-TEMPLATE.md` | `docs/PROJECT-API.md` |

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

---

##  Create Checklist

- [ ] Project type detected correctly
- [ ] Socratic Gate completed (3+ questions)
- [ ] Tech stack confirmed with user
- [ ] PROJECT-BRIEF.md created
- [ ] PROJECT-CONVENTIONS.md created
- [ ] Project builds without errors
- [ ] Dev server accessible
- [ ] Git initialized with .gitignore

---

## 📱 Khởi Tạo Dự Án Mobile (React Native / Flutter)

Nếu người dùng yêu cầu tạo ứng dụng di động:
**Framework:** React Native | Expo | Flutter

### Option A: Expo (React Native — Khuyên dùng)
```bash
npx create-expo-app@latest my-app --template tabs
cd my-app
# Essential packages
npx expo install expo-router expo-linking expo-constants @react-native-async-storage/async-storage expo-secure-store expo-notifications expo-local-authentication
npm install @tanstack/react-query zustand axios
npm install -D @testing-library/react-native jest-expo
```

### Option B: React Native CLI (Bare)
```bash
npx react-native@latest init MyApp --template react-native-template-typescript
cd MyApp
npm install @react-navigation/native @react-navigation/native-stack react-native-screens react-native-safe-area-context
npm install @tanstack/react-query zustand axios react-native-mmkv react-native-keychain
npm install @notifee/react-native @react-native-firebase/app @react-native-firebase/messaging
npm install -D @testing-library/react-native jest
```

### Option C: Flutter
```bash
flutter create --org com.company my_app
cd my_app
flutter pub add go_router riverpod flutter_riverpod http dio shared_preferences hive hive_flutter flutter_secure_storage firebase_core firebase_messaging firebase_analytics
flutter pub add --dev flutter_test integration_test build_runner
```

---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| npx create fails | Check Node.js version, try `npx -y` flag |
| Port already in use | Kill process on port: `npx kill-port 3000` |
| Dependencies conflict | Delete `node_modules` + `package-lock.json`, re-install |
| Template not found | Check framework version, use `--template` flag |
| Mobile Build lỗi/crash | Bật chế độ verbose, kiểm tra log hệ thống, cắt nhỏ phạm vi debug |

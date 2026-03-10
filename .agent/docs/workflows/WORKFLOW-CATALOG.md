# Workflow Catalog — Antigravity-Core

**Version:** 5.0.0  
**Last Updated:** 2026-02-27  
**Total Workflows:** 39

---

## Table of Contents

- [Overview](#overview)
- [Workflow Classification](#workflow-classification)
- [Workflow Registry](#workflow-registry)
- [Usage Guide](#usage-guide)

---

## Overview

Workflows là các quy trình được định nghĩa sẵn, kích hoạt bằng **slash commands** (ví dụ: `/plan`, `/scaffold`). Mỗi workflow là một file `.md` trong `.agent/workflows/` với frontmatter mô tả và body chứa các bước thực hiện.

**Cách sử dụng:** Gõ slash command trực tiếp trong chat với AI assistant.

---

## Workflow Classification

### By Category

| Category | Workflows | Mô tả |
|----------|-----------|--------|
| **🏗️ Khởi tạo & Setup** | `/create`, `/install-antigravity`, `/mobile-init`, `/scaffold`, `/schema-first`, `/requirements-first`, `/init-docs` | Tạo mới dự án, module, database, chuẩn hóa docs |
| **💻 Development** | `/enhance`, `/quickfix`, `/refactor`, `/brainstorm`, `/plan` | Phát triển tính năng, sửa lỗi, planning |
| **🎨 Design** | `/ui-ux-pro-max`, `/update-ui-ux-pro-max`, `/admin-component`, `/admin-dashboard` | Thiết kế UI/UX, admin components |
| **✅ Quality** | `/test`, `/check`, `/auto-healing`, `/auto-optimization-cycle`, `/performance-budget-enforcement` | Testing, review, auto-fix |
| **🔒 Security** | `/security-audit`, `/secret-scanning` | Kiểm tra bảo mật |
| **🚀 Deploy & Ops** | `/deploy`, `/mobile-deploy`, `/optimize`, `/check`, `/maintain`, `/migrate` | Triển khai, vận hành, bảo trì |
| **🎯 Orchestration** | `/orchestrate`, `/debug` | Phối hợp agents, debugging |

---

## Workflow Registry

### 🏗️ Khởi tạo & Setup

| # | Command | Mô tả | Khi nào dùng |
|---|---------|--------|-------------|
| 1 | `/create` | Tạo dự án mới từ đầu | Bắt đầu project hoàn toàn mới |
| 2 | `/install-antigravity` | Cài đặt/cập nhật Antigravity-Core | Thêm .agent vào project hiện có |
| 3 | `/mobile-init` | Khởi tạo dự án mobile | Bắt đầu app React Native/Flutter |
| 4 | `/scaffold` | Tạo module CRUD hoàn chỉnh theo framework | Cần CRUD nhanh (User, Post, Product...) |
| 5 | `/schema-first` | Thiết kế database trước khi code | Design DB schema trước implementation |
| 6 | `/requirements-first` | Viết PRD trước khi code | Thu thập yêu cầu, viết Product Requirements |
| 7 | `/create-admin` | Tạo SaaS Admin Starter Kit with Auth & RBAC | Tạo admin panel từ blueprint |

### 💻 Development

| # | Command | Mô tả | Khi nào dùng |
|---|---------|--------|-------------|
| 8 | `/enhance` | Thêm/sửa tính năng cho dự án hiện có | Feature development, improvements |
| 9 | `/quickfix` | Sửa lỗi nhanh, vấn đề đơn giản | Bug nhỏ, single-file fixes |
| 10 | `/refactor` | Tái cấu trúc code thông minh | Code cleanup, complexity reduction |
| 11 | `/brainstorm` | Phân tích ý tưởng, so sánh giải pháp | Cần explore ideas, compare approaches |
| 12 | `/plan` | Lập kế hoạch dự án (không code) | Planning feature lớn, architecture decisions |

### 🎨 Design

| # | Command | Mô tả | Khi nào dùng |
|---|---------|--------|-------------|
| 13 | `/ui-ux-pro-max` | Thiết kế UI/UX chuyên nghiệp | Tạo UI mới với design intelligence |
| 14 | `/update-ui-ux-pro-max` | Cập nhật skill UI-UX-Pro-Max | Update design skill khi có version mới |
| 15 | `/admin-component` | Tạo component admin (Velzon) | Admin panel components React + Reactstrap |
| 16 | `/admin-dashboard` | Tạo trang admin dashboard (Velzon) | Full admin dashboard pages |

### ✅ Quality

| # | Command | Mô tả | Khi nào dùng |
|---|---------|--------|-------------|
| 17 | `/test` | Tạo và chạy test tự động | Viết tests, increase coverage |
| 18 | `/check` | Review code tự động | Pre-PR review, quality check |
| 19 | `/auto-healing` | Tự sửa lỗi lint, type, import | Auto-fix common errors |
| 20 | `/auto-optimization-cycle` | Chu trình tối ưu tự động sau mỗi tính năng | Post-feature optimization |
| 21 | `/performance-budget-enforcement` | Kiểm soát ngân sách hiệu suất | Enforce bundle size / CWV budgets |
| 22 | `/api-design` | Validate API design, contracts, và documentation | API review trước implementation |

### 🔒 Security

| # | Command | Mô tả | Khi nào dùng |
|---|---------|--------|-------------|
| 23 | `/security-audit` | Kiểm tra bảo mật toàn diện | Trước deploy, periodic security check |
| 24 | `/secret-scanning` | Quét mã nguồn tìm thông tin nhạy cảm | Tìm hardcoded secrets, API keys |

### 🚀 Deploy & Operations

| # | Command | Mô tả | Khi nào dùng |
|---|---------|--------|-------------|
| 25 | `/deploy` | Triển khai lên production | Production deployment |
| 26 | `/mobile-deploy` | Triển khai app lên Store | App Store / Google Play submission |
| 27 | `/mobile-test` | Test mobile đa nền tảng | Cross-platform mobile testing |
| 28 | `/optimize` | Phân tích và tối ưu hiệu suất | Performance improvement |
| 29 | `/check` | Kiểm tra workspace hàng ngày | Daily health check |
| 30 | `/maintain` | Bảo trì định kỳ theo lịch | Scheduled maintenance |
| 31 | `/migrate` | Nâng cấp framework tự động | Framework version upgrade |
| 32 | `/backup` | Backup database và project state | Trước thay đổi lớn |
| 33 | `/i18n-check` | Kiểm tra i18n strings và translation coverage | Sau khi thêm strings mới |

### 🎯 Orchestration

| # | Command | Mô tả | Khi nào dùng |
|---|---------|--------|-------------|
| 34 | `/orchestrate` | Phối hợp nhiều agent cho task phức tạp | Complex multi-domain tasks |
| 35 | `/debug` | Tìm và sửa lỗi có hệ thống | Complex bugs, systematic debugging |

### 🔧 System

| # | Command | Mô tả | Khi nào dùng |
|---|---------|--------|-------------|
| 36 | `/install-antigravity` | Cài đặt/cập nhật Antigravity-Core | Thêm .agent vào project |
| 37 | `/sync-admin` | Đồng bộ dự án admin với blueprint mới nhất | Sau khi update core |
| 38 | `/full-pipeline` | Chạy full team workflow: BA → SA → PM → DEV → QA → DO | Bắt đầu dự án mới hoặc sprint mới |
| 39 | `/init-docs` | Chuẩn hóa toàn bộ docs dự án (chạy 1 lần) | Lần đầu vào project mới hoặc cũ |

---

## Usage Guide

### Typical Development Flow

```
/requirements-first    → Thu thập yêu cầu
    ↓
/plan                  → Lập kế hoạch
    ↓
/schema-first          → Design database
    ↓
/scaffold              → Generate CRUD
    ↓
/enhance               → Thêm business logic
    ↓
/test                  → Viết tests
    ↓
/check → Review
    ↓
/security-audit        → Security check
    ↓
/deploy                → Production!
```

### Quick Fix Flow

```
/debug      → Systematic root cause analysis
/quickfix   → Single-file simple fix
/auto-healing → Auto-fix lint/type errors
```

### Daily Routine

```
Morning:  /check          → Health check workspace
Coding:   /enhance        → Feature development
Pre-PR:   /check + /test
Weekly:   /maintain       → Scheduled maintenance
Monthly:  /security-audit → Full security scan
```

---

> **See also:** [WORKFLOW-GUIDE.md](../WORKFLOW-GUIDE.md) | [Agent Catalog](../agents/AGENT-CATALOG.md)

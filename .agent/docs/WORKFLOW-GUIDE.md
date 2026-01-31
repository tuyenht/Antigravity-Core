# 📖 Hướng Dẫn Sử Dụng Workflows

**Tổng số:** 34 Workflows  
**Cập nhật:** 2026-01-20

---

## 🎯 2 CÁCH GỌI WORKFLOW

### Cách 1: Slash Command (Gõ trực tiếp)
```
/workflow-name
```
**Ví dụ:** `/check`, `/verify`, `/scaffold`

### Cách 2: Yêu cầu AI thực hiện
```
"Chạy workflow scaffold cho tôi"
"Thực hiện security audit"
"Hãy refactor code theo workflow refactor"
```

---

## 📋 PHÂN LOẠI WORKFLOWS

### 🔍 **SYSTEM HEALTH (Kiểm tra hệ thống)**

| Slash Command | Mục Đích | Khi Nào Dùng |
|---------------|----------|--------------|
| `/check` | Daily self-audit, tự sửa lỗi nhỏ | Hàng ngày |
| `/verify` | Evolution regression test | Sau upgrade lớn |
| `/status` | Kiểm tra trạng thái project | Bất kỳ lúc nào |

---

### 🛡️ **SECURITY (Bảo mật)**

| Slash Command | Mục Đích | Khi Nào Dùng |
|---------------|----------|--------------|
| `/security-audit` | Kiểm tra bảo mật toàn diện | Trước release |
| `/security-scan` | Quét nhanh vulnerabilities | Định kỳ |
| `/secret-scanning` | Phát hiện secrets trong code | Trước commit |

---

### ⚡ **PERFORMANCE (Hiệu năng)**

| Slash Command | Mục Đích | Khi Nào Dùng |
|---------------|----------|--------------|
| `/optimize` | Tối ưu hóa code | Khi cần cải thiện perf |
| `/performance-budget-enforcement` | Kiểm tra budgets | Trước merge |
| `/react-performance-review` | Review React performance | Frontend work |
| `/dx-analytics` | Xem metrics DX | Theo dõi tiến độ |

---

### 🏗️ **CODE CREATION (Tạo code)**

| Slash Command | Mục Đích | Khi Nào Dùng |
|---------------|----------|--------------|
| `/create` | Tạo file/component mới | Bắt đầu feature |
| `/scaffold` | Scaffold CRUD/components | Tạo boilerplate |
| `/schema-first` | Database-first development | Schema design |
| `/requirements-first` | Requirements-first approach | Từ spec/PRD |

---

### 🔧 **CODE MAINTENANCE (Bảo trì)**

| Slash Command | Mục Đích | Khi Nào Dùng |
|---------------|----------|--------------|
| `/refactor` | Refactor code | Cải thiện structure |
| `/quickfix` | Sửa lỗi nhanh | Bug nhanh |
| `/debug` | Debug có hệ thống | Lỗi phức tạp |
| `/maintain` | Maintenance tasks | Bảo trì định kỳ |
| `/auto-healing` | Tự động sửa lint/types | Sau code changes |

---

### 🧪 **TESTING (Kiểm thử)**

| Slash Command | Mục Đích | Khi Nào Dùng |
|---------------|----------|--------------|
| `/test` | Chạy tests | Sau code changes |
| `/mobile-test` | Test mobile | Mobile apps |

---

### 🚀 **DEPLOYMENT (Triển khai)**

| Slash Command | Mục Đích | Khi Nào Dùng |
|---------------|----------|--------------|
| `/deploy` | Deploy ứng dụng | Production deploy |
| `/preview` | Preview changes | Trước merge |
| `/mobile-deploy` | Deploy mobile | Mobile release |
| `/mobile-init` | Khởi tạo mobile project | New mobile project |

---

### 📝 **PLANNING & REVIEW (Lập kế hoạch)**

| Slash Command | Mục Đích | Khi Nào Dùng |
|---------------|----------|--------------|
| `/plan` | Lập kế hoạch | Bắt đầu project/feature |
| `/brainstorm` | Brainstorm ideas | Ideation |
| `/code-review-automation` | Auto code review | PR review |
| `/deprecation-policy` | Deprecation process | Retire components |

---

### 🎨 **UI/UX**

| Slash Command | Mục Đích | Khi Nào Dùng |
|---------------|----------|--------------|
| `/ui-ux-pro-max` | UI/UX best practices | Frontend design |
| `/enhance` | Enhance existing features | UX improvement |

---

### 🔄 **AUTOMATION & ORCHESTRATION**

| Slash Command | Mục Đích | Khi Nào Dùng |
|---------------|----------|--------------|
| `/orchestrate` | Multi-agent coordination | Complex tasks |
| `/auto-optimization-cycle` | AOC cycle | System optimization |
| `/migrate` | Migration tasks | Tech migrations |

---

## ⭐ TOP 10 WORKFLOWS HAY DÙNG NHẤT

| # | Command | Mục Đích |
|---|---------|----------|
| 1 | `/check` | Daily health check |
| 2 | `/scaffold` | Tạo CRUD nhanh |
| 3 | `/refactor` | Refactor code |
| 4 | `/debug` | Debug có hệ thống |
| 5 | `/test` | Chạy tests |
| 6 | `/security-audit` | Kiểm tra bảo mật |
| 7 | `/optimize` | Tối ưu performance |
| 8 | `/deploy` | Deploy app |
| 9 | `/verify` | Verify evolution |
| 10 | `/quickfix` | Sửa lỗi nhanh |

---

## 💡 MẸO SỬ DỤNG

### Gợi nhớ nhanh:
```
/check    → Kiểm tra hàng ngày
/verify   → Xác nhận sau upgrade
/scaffold → Tạo code mới
/refactor → Cải thiện code
/debug    → Tìm lỗi
/deploy   → Triển khai
```

### Kết hợp workflows:
```
1. /plan → Lập kế hoạch
2. /scaffold → Tạo boilerplate
3. /test → Viết tests
4. /check → Kiểm tra quality
5. /deploy → Triển khai
```

---

## ❓ CÂU HỎI THƯỜNG GẶP

**Q: Có cần gõ đúng tên không?**
A: Có, gõ đúng `/workflow-name` hoặc mô tả yêu cầu để AI hiểu

**Q: Không nhớ tên workflow?**
A: Nói "Liệt kê các workflows" hoặc xem file này

**Q: Workflow không chạy?**
A: Thử gõ đầy đủ rồi Enter, hoặc diễn đạt bằng lời

---

**File:** `.agent/docs/WORKFLOW-GUIDE.md`

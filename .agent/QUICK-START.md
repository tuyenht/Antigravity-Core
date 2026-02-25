# .agent Quick Start Guide

**Version:** 4.1.0

---

## ✨ SUPER SIMPLE - Chỉ 2 Bước!

### 1️⃣ Copy .agent vào project
```bash
cp -r /path/to/.agent /your-project/
cd /your-project
```

### 2️⃣ Chạy lệnh init
```bash
# Windows (PowerShell)
.\.agent\agent.ps1 init

# Linux/Mac
chmod +x .agent/agent.sh
./.agent/agent.sh init
```

**XONG!** 🎉

---

## 📝 Lệnh Chính Thức

### Windows:
```powershell
# Recommended
.\.agent\agent.ps1 init
```

### Linux/Mac:
```bash
# Full path (recommended)
./.agent/agent.sh init
```

---

## 💡 Sau Khi Init

**Hệ thống tự động:**
- ✅ Phát hiện tech stack
- ✅ Activate agents phù hợp
- ✅ Tạo `project.json`
- ✅ Sẵn sàng sử dụng!

**Dùng với Antigravity:**
```
User: "Build user authentication with email and OAuth"

Antigravity sẽ:
→ Đọc .agent/project.json
→ Biết tech stack (Laravel/React/etc)
→ Chọn đúng agents
→ Tự động execute theo workflow
→ Zero errors! ✨
```

---

## 🎯 Tóm Tắt

**Lệnh chính:**
```bash
# Windows
.\.agent\agent.ps1 init

# Linux/Mac
./.agent/agent.sh init
```

**Cả 2 đều:**
- ✅ Tự động phát hiện tech stack
- ✅ Zero configuration
- ✅ 5 giây setup xong!

---

**Chỉ cần copy → init → Bắt đầu code!** 🚀

**Không cần:**
- ❌ Điền template
- ❌ Config thủ công
- ❌ Chọn tech stack
- ❌ Setup agent

**CHỈ MỘT LỆNH - TỰ ĐỘNG HẾT!** ✨

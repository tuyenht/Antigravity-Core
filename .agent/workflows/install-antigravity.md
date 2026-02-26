---
description: "Cài đặt mới hoặc cập nhật hệ điều hành Antigravity-Core cho dự án."
---

# Antigravity-Core Installation & Update Guide

// turbo-all

**Agent:** `orchestrator`  
**Skills:** `app-builder, clean-code`

Hướng dẫn cài đặt và cập nhật Antigravity-Core cho các dự án.

---

## 📋 TỔNG QUAN

**Antigravity-Core** là một AI-Native Development Operating System có thể được cài đặt vào bất kỳ project nào.

### Source Repository
- **GitHub:** https://github.com/tuyenht/Antigravity-Core
- **Version:** 4.0.0

---

## 🌐 STEP 1: CÀI ĐẶT GLOBAL (một lần duy nhất)

### Prerequisites

```powershell
# Nếu gặp lỗi execution policy:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Recommended: Clone & Install

```powershell
# Clone repo (cần Git)
git clone --depth 1 https://github.com/tuyenht/Antigravity-Core.git C:\Tools\Antigravity-Core

# Chạy global installer (tự động thêm vào PowerShell Profile)
& "C:\Tools\Antigravity-Core\.agent\scripts\install-global.ps1"

# Restart PowerShell
```

### Alternative: Download Script (chỉ khi repo public)

```powershell
irm "https://raw.githubusercontent.com/tuyenht/Antigravity-Core/main/.agent/scripts/install-global.ps1" -OutFile install.ps1
.\install.ps1
Remove-Item install.ps1

# Restart PowerShell
```

**Kết quả:** Bạn có 3 lệnh mới:
- `agi` - Install Antigravity-Core vào project hiện tại
- `agu` - Update project hiện tại
- `agug` - Update bản global

---

## 🚀 STEP 2: CÀI ĐẶT CHO PROJECT (mỗi project)

```powershell
# Di chuyển đến project
cd C:\Projects\MyNewProject

# Cài đặt (từ bản global, nhanh!)
agi
```

---

## 🔄 CẬP NHẬT

### Update bản global (khi có version mới)
```powershell
agug
```

### Update project hiện tại (từ bản global)
```powershell
cd C:\Projects\MyProject
agu
```

---

## 📦 ALTERNATIVE: CÀI TRỰC TIẾP (không cần global)

### Option 1: One-liner Script

```powershell
cd C:\Projects\MyNewProject
irm "https://raw.githubusercontent.com/tuyenht/Antigravity-Core/main/.agent/scripts/install-antigravity.ps1" -OutFile install.ps1
.\install.ps1
Remove-Item install.ps1
```

### Option 2: Clone và Copy

```powershell
git clone --depth 1 https://github.com/tuyenht/Antigravity-Core.git temp-ag
Copy-Item -Path "temp-ag\.agent" -Destination ".\.agent" -Recurse
Copy-Item -Path "temp-ag\docs" -Destination ".\docs" -Recurse
Remove-Item -Path "temp-ag" -Recurse -Force
```

### Option 3: Download ZIP

```powershell
$zipUrl = "https://github.com/tuyenht/Antigravity-Core/archive/refs/heads/main.zip"
Invoke-WebRequest -Uri $zipUrl -OutFile "antigravity.zip"
Expand-Archive -Path "antigravity.zip" -DestinationPath "temp"
Copy-Item -Path "temp\Antigravity-Core-main\.agent" -Destination ".\.agent" -Recurse
Remove-Item "antigravity.zip", "temp" -Recurse -Force
```

---

## 🐧 LINUX/MAC

```bash
cd ~/projects/my-new-project
git clone --depth 1 https://github.com/tuyenht/Antigravity-Core.git temp-ag
cp -r temp-ag/.agent ./.agent
cp -r temp-ag/docs ./docs
rm -rf temp-ag
```

---

## ✅ VERIFICATION

Sau khi cài đặt:

```powershell
# Check version
Get-Content ".\.agent\VERSION"

# Run health check
.\.agent\scripts\health-check.ps1

# Count components
Write-Host "Workflows: $((Get-ChildItem '.\.agent\workflows\*.md').Count)"
Write-Host "Skills: $((Get-ChildItem '.\.agent\skills' -Directory).Count)"
Write-Host "Agents: $((Get-ChildItem '.\.agent\agents\*.md').Count)"
```

---

## 📁 FILES ĐƯỢC CÀI ĐẶT

```
YourProject/
├── .agent/                    ← Core system
│   ├── VERSION                # 4.0.0
│   ├── GEMINI.md              # AI instructions
│   ├── CHANGELOG.md           # Version history
│   ├── INTEGRATION-GUIDE.md   # How to use
│   ├── agents/                # 27+ agent definitions
│   ├── skills/                # 57+ skills
│   ├── workflows/             # 38+ workflows
│   ├── rules/                 # Coding standards
│   ├── scripts/               # Automation scripts
│   ├── memory/                # Persistent data
│   └── templates/             # Project templates
│
└── docs/ (optional)           ← Documentation
    ├── PROJECT-BRIEF-SYSTEM.md
    ├── Analyze-Existing-Project-Prompt.txt
    └── deployment-guide.md
```

---

## 🔧 TROUBLESHOOTING

| Lỗi | Nguyên nhân | Cách fix |
|------|-------------|----------|
| `irm: 404 Not Found` | Repo đang **private** trên GitHub | Chuyển repo sang **public** hoặc dùng `git clone` |
| `Add-Content $PROFILE: path not found` | Thư mục Profile chưa tồn tại | Script v1.1+ tự tạo. Hoặc: `New-Item -ItemType Directory -Path (Split-Path $PROFILE) -Force` |
| `install.ps1 cannot be loaded` | ExecutionPolicy bị Restricted | `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |

---

## 🔗 LINKS

- **GitHub:** https://github.com/tuyenht/Antigravity-Core
- **README:** https://github.com/tuyenht/Antigravity-Core/blob/main/README.md
- **Changelog:** https://github.com/tuyenht/Antigravity-Core/blob/main/.agent/CHANGELOG.md

---

**Version:** 3.0  
**Updated:** 2026-02-13

---

##  Install Antigravity Checklist

- [ ] Prerequisites and environment verified
- [ ] All workflow steps executed sequentially
- [ ] Expected output validated against requirements
- [ ] No unresolved errors or warnings in tests/logs
- [ ] Related documentation updated if impact is systemic




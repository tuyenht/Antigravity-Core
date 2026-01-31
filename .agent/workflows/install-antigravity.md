---
description: Install or update Antigravity-Core for a project
---

# Antigravity-Core Installation & Update Guide

Hướng dẫn cài đặt và cập nhật Antigravity-Core cho các dự án.

---

## 📋 TỔNG QUAN

**Antigravity-Core** là một AI-Native Development Operating System có thể được cài đặt vào bất kỳ project nào.

### Source Repository
- **GitHub:** https://github.com/tuyenht/Antigravity-Core
- **Version:** 3.1.0

---

## 🔧 CÀI ĐẶT CHO PROJECT MỚI

### Option 1: Sử dụng Script (Recommended)

```powershell
# Download script và chạy
$url = "https://raw.githubusercontent.com/tuyenht/Antigravity-Core/main/.agent/scripts/install-antigravity.ps1"
Invoke-WebRequest -Uri $url -OutFile "install-antigravity.ps1"
.\install-antigravity.ps1
Remove-Item "install-antigravity.ps1"
```

### Option 2: Clone và Copy

```powershell
# Clone repo tạm thời
git clone https://github.com/tuyenht/Antigravity-Core.git temp-antigravity

# Copy .agent folder vào project
Copy-Item -Path "temp-antigravity\.agent" -Destination ".\.agent" -Recurse

# Copy docs (optional)
Copy-Item -Path "temp-antigravity\docs" -Destination ".\docs" -Recurse

# Cleanup
Remove-Item -Path "temp-antigravity" -Recurse -Force
```

### Option 3: Download ZIP

```powershell
# Download ZIP từ GitHub
$zipUrl = "https://github.com/tuyenht/Antigravity-Core/archive/refs/heads/main.zip"
Invoke-WebRequest -Uri $zipUrl -OutFile "antigravity.zip"

# Extract
Expand-Archive -Path "antigravity.zip" -DestinationPath "temp"

# Copy .agent
Copy-Item -Path "temp\Antigravity-Core-main\.agent" -Destination ".\.agent" -Recurse

# Cleanup
Remove-Item "antigravity.zip", "temp" -Recurse -Force
```

---

## 🔄 CẬP NHẬT PROJECT HIỆN CÓ

### Option 1: Sử dụng Script

```powershell
# Chạy từ thư mục project
.\.agent\scripts\update-antigravity.ps1
```

### Option 2: Manual Update

```powershell
# Backup memory (project-specific data)
Copy-Item -Path ".\.agent\memory" -Destination ".\temp-memory" -Recurse

# Backup project.json
Copy-Item -Path ".\.agent\project.json" -Destination ".\temp-project.json"

# Remove old .agent
Remove-Item -Path ".\.agent" -Recurse -Force

# Download và install mới (như ở trên)
# ...

# Restore backups
Copy-Item -Path ".\temp-memory" -Destination ".\.agent\memory" -Recurse -Force
Copy-Item -Path ".\temp-project.json" -Destination ".\.agent\project.json" -Force

# Cleanup
Remove-Item ".\temp-memory", ".\temp-project.json" -Recurse -Force
```

---

## 📦 GLOBAL INSTALLATION

Để có thể chạy scripts từ bất kỳ đâu:

### Option 1: Add to PATH

```powershell
# Clone Antigravity-Core to a central location
git clone https://github.com/tuyenht/Antigravity-Core.git C:\Tools\Antigravity-Core

# Add scripts to PATH (PowerShell profile)
$profileContent = @"

# Antigravity-Core
`$env:PATH += ";C:\Tools\Antigravity-Core\.agent\scripts"
Set-Alias antigravity-install "C:\Tools\Antigravity-Core\.agent\scripts\install-antigravity.ps1"
Set-Alias antigravity-update "C:\Tools\Antigravity-Core\.agent\scripts\update-antigravity.ps1"
"@

Add-Content -Path $PROFILE -Value $profileContent
```

### Option 2: PowerShell Functions

Add to your `$PROFILE`:

```powershell
# Antigravity-Core Functions
function Install-Antigravity {
    param([string]$Path = ".")
    
    $url = "https://raw.githubusercontent.com/tuyenht/Antigravity-Core/main/.agent/scripts/install-antigravity.ps1"
    $script = Invoke-WebRequest -Uri $url -UseBasicParsing
    $scriptBlock = [ScriptBlock]::Create($script.Content)
    & $scriptBlock -ProjectPath $Path
}

function Update-Antigravity {
    if (Test-Path ".\.agent\scripts\update-antigravity.ps1") {
        & ".\.agent\scripts\update-antigravity.ps1"
    } else {
        Write-Host "No .agent folder found. Run Install-Antigravity first." -ForegroundColor Red
    }
}

# Aliases
Set-Alias agi Install-Antigravity
Set-Alias agu Update-Antigravity
```

**Usage sau khi setup:**

```powershell
# Install to new project
cd C:\Projects\MyNewApp
agi
# hoặc: Install-Antigravity

# Update existing project
cd C:\Projects\MyExistingApp
agu
# hoặc: Update-Antigravity
```

---

## ✅ VERIFICATION

Sau khi cài đặt, verify:

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
│   ├── VERSION                # 3.1.0
│   ├── GEMINI.md              # AI instructions
│   ├── CHANGELOG.md           # Version history
│   ├── INTEGRATION-GUIDE.md   # How to use
│   ├── agents/                # 27+ agent definitions
│   ├── skills/                # 57+ skills
│   ├── workflows/             # 36+ workflows
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

## 🔗 LINKS

- **GitHub:** https://github.com/tuyenht/Antigravity-Core
- **README:** https://github.com/tuyenht/Antigravity-Core/blob/main/README.md
- **Changelog:** https://github.com/tuyenht/Antigravity-Core/blob/main/.agent/CHANGELOG.md

---

**Version:** 1.0  
**Created:** 2026-01-31

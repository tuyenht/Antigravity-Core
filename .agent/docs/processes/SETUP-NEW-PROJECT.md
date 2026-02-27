# Setup New Project — Quy trình A-Z

**Version:** 5.0.0  
**Last Updated:** 2026-02-27

---

## Overview

Hướng dẫn setup dự án mới từ đầu sử dụng Antigravity-Core `.agent` system.

---

## Prerequisites

- [ ] Node.js 18+ hoặc Python 3.11+
- [ ] PowerShell 5.1+ (Windows) hoặc pwsh 7+ (macOS/Linux)
- [ ] Git
- [ ] Editor hỗ trợ AI assistant (Cursor, Claude Code, etc.)

---

## Step-by-Step Process

### Step 1: Khởi tạo project framework

```bash
# Option A: Next.js
npx -y create-next-app@latest ./

# Option B: Laravel + Inertia
composer create-project laravel/laravel ./
php artisan breeze:install react --typescript

# Option C: React Native / Expo
npx -y create-expo-app@latest ./
```

### Step 2: Cài đặt Antigravity-Core

```powershell
# Windows
irm https://raw.githubusercontent.com/tuyenht/Antigravity-Core/main/.agent/scripts/install-antigravity.ps1 | iex

# Linux/Mac
curl -sL https://raw.githubusercontent.com/tuyenht/Antigravity-Core/main/.agent/scripts/install-antigravity.ps1 | pwsh -c -
```

Hoặc manual:
```bash
git clone https://github.com/tuyenht/Antigravity-Core.git .agent-temp
cp -r .agent-temp/.agent ./.agent
rm -rf .agent-temp
```

### Step 3: Initialize project detection

```powershell
# Windows
.\.agent\agent.ps1 init

# Linux/Mac
./.agent/agent.sh init
```

Script sẽ tự động:
- Detect tech stack (frameworks, languages, databases)
- Generate `.agent/context.yml`
- Suggest relevant rules

### Step 4: Verify setup

```powershell
.\.agent\agent.ps1 health
```

Kiểm tra:
- ✅ Tất cả agent files accessible
- ✅ Skills loaded correctly
- ✅ Rules discovered
- ✅ Scripts executable

### Step 5: Bắt đầu phát triển

Sử dụng slash commands:
```
/requirements-first   → Thu thập yêu cầu (PRD)
/plan                 → Lập kế hoạch
/schema-first         → Design database
/scaffold             → Generate CRUD modules
/enhance              → Phát triển features
```

---

## Checklist

- [ ] Project framework initialized
- [ ] `.agent/` installed
- [ ] `agent.ps1 init` ran successfully
- [ ] `agent.ps1 health` shows all green
- [ ] First commit với `.agent/` included
- [ ] Team members có copy `.agent/` (nếu team project)

---

> **See also:** [Daily Development](./DAILY-DEVELOPMENT.md) | [Workflow Catalog](../workflows/WORKFLOW-CATALOG.md)

# .agent One-Command Setup Guide

**Version:** 4.0.0  
**Updated:** 2026-02-13  
**Status:** FULLY AUTOMATED ✨

---

## 🚀 Quick Start

### Prerequisites

Antigravity-Core phải được cài đặt global trước. Xem [README.md](../README.md) → QUICK START.

### Step 1: Copy .agent to Your Project

**Windows (PowerShell):**
```powershell
# Từ global install
Copy-Item -Recurse "$env:ANTIGRAVITY_HOME\.agent" .\.agent

# Hoặc từ git clone
Copy-Item -Recurse "C:\Tools\Antigravity-Core\.agent" .\.agent
```

**Linux/Mac (Bash):**
```bash
cp -r ~/Tools/Antigravity-Core/.agent ./.agent
```

### Step 2: Run ONE Command

**Windows (PowerShell):**
```powershell
.\.agent\agent.ps1 init
```

**Linux/Mac (Bash):**
```bash
./.agent/agent.sh init
```

### Step 3: Done! 🎉

System automatically:
- ✅ Detects your tech stack
- ✅ Activates appropriate agents
- ✅ Creates `project.json` + `PROJECT-README.md`
- ✅ Ready to use!

---

## 📋 What It Detects

| Category | Technologies | Detection Source |
|----------|-------------|-----------------|
| **Frontend** | Next.js, React, Vue, Svelte, TypeScript | `package.json`, `tsconfig.json` |
| **Backend** | Laravel, Express, Fastify, FastAPI, Django, Flask, Go, Rust | `composer.json`, `package.json`, `requirements.txt`, `pyproject.toml`, `go.mod`, `Cargo.toml` |
| **Mobile** | React Native, Flutter | `ios/Podfile`, `android/build.gradle`, `pubspec.yaml` |
| **Database** | Prisma, Drizzle | `prisma/schema.prisma`, `drizzle.config.ts` |

---

## 🎯 Example Workflows

### New Laravel + React Project

**Windows (PowerShell):**
```powershell
composer create-project laravel/laravel my-app
cd my-app
npm install react

Copy-Item -Recurse "$env:ANTIGRAVITY_HOME\.agent" .\.agent
.\.agent\agent.ps1 init

# Output:
# ✅ Tech Stack Detected:
#   Backend: Laravel
#   Frontend: React
# ✅ Agents Activated:
#   → laravel-specialist
#   → frontend-specialist
#   → security-auditor
#   → test-engineer
# ✅ INITIALIZATION COMPLETE!
```

### Existing Next.js Project

**Linux/Mac (Bash):**
```bash
cd existing-nextjs-app
cp -r ~/Tools/Antigravity-Core/.agent ./.agent
./.agent/agent.sh init

# Output:
# ✅ Tech Stack Detected:
#   Frontend: Next.js, TypeScript
# ✅ Agents Activated:
#   → frontend-specialist (React/Next.js)
#   → security-auditor
#   → test-engineer
# ✅ INITIALIZATION COMPLETE!
```

---

## 📂 What Gets Created

After running `agent init`:

```
your-project/
├── .agent/
│   ├── project.json          ← Auto-generated configuration
│   ├── PROJECT-README.md     ← Quick reference with real commands
│   ├── agent.ps1             ← CLI script (Windows)
│   ├── agent.sh              ← CLI script (Linux/Mac)
│   └── [agents, skills, workflows, rules, scripts...]
├── package.json              ← Your existing files
└── ...
```

### project.json Example:
```json
{
  "version": "4.0.0",
  "initialized": "2026-02-13 10:50:00",
  "tech_stack": {
    "frontend": "Next.js TypeScript",
    "backend": "Laravel",
    "mobile": "",
    "database": "Prisma"
  },
  "active_agents": [
    "security-auditor",
    "test-engineer",
    "frontend-specialist",
    "laravel-specialist",
    "database-architect"
  ]
}
```

---

## 🔧 Available Commands

### Windows (PowerShell) — Full CLI

| Command | Description |
|---------|-------------|
| `.\agent.ps1 init` | Initialize project (auto-detect stack) |
| `.\agent.ps1 init -Force` | Reinitialize (overwrite config) |
| `.\agent.ps1 status` | Show system status |
| `.\agent.ps1 agents` | List all agents |
| `.\agent.ps1 skills` | List all skills |
| `.\agent.ps1 workflows` | List all workflows |
| `.\agent.ps1 health` | Run health check |
| `.\agent.ps1 validate` | Run compliance validation |
| `.\agent.ps1 scan` | Run secret scanning |
| `.\agent.ps1 perf` | Run performance check |
| `.\agent.ps1 heal` | Run auto-healing |
| `.\agent.ps1 heal -DryRun` | Preview auto-healing |
| `.\agent.ps1 dx` | Show DX analytics dashboard |
| `.\agent.ps1 dx roi` | Show automation ROI |

### Linux/Mac (Bash)

| Command | Description |
|---------|-------------|
| `./agent.sh init` | Initialize project |
| `./agent.sh init --force` | Reinitialize |
| `./agent.sh status` | Show configuration |
| `./agent.sh agents` | List all agents |
| `./agent.sh skills` | List all skills |
| `./agent.sh workflows` | List all workflows |
| `./agent.sh health` | Run health check |
| `./agent.sh help` | Show all commands |

---

## 💬 Using with Antigravity

After initialization, just tell Antigravity what you want:

```
USER: "Build a user authentication system with email/password and OAuth"

ANTIGRAVITY:
  [Reads .agent/project.json]
  ✅ Detected: Laravel + React project
  ✅ Activating: laravel-specialist + frontend-specialist

  [Auto-generates plan:]
  1. Backend: Laravel Sanctum authentication
  2. Frontend: Login/Register components
  3. OAuth: Google/GitHub integration
  4. Tests: Full coverage

  Proceed? (yes/no)
```

---

## 🚨 Troubleshooting

| Issue | Solution |
|-------|----------|
| `Could not auto-detect tech stack` | Ensure at least one config file exists: `package.json`, `composer.json`, `requirements.txt`, `pyproject.toml`, `go.mod`, `Cargo.toml` |
| `Project already initialized` | Use `-Force` (Windows) or `--force` (Linux/Mac) |
| `agent.ps1 cannot be loaded` | Run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| `.agent directory not found` | Copy .agent from global install. See [README](../README.md). |

---

**Version 4.0.0** · Updated 2026-02-13

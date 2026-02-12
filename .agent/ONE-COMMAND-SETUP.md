# .agent One-Command Setup Guide

**Version:** 4.0.0  
**Status:** FULLY AUTOMATED ✨

---

## 🚀 Super Simple Usage

### Step 1: Copy .agent to Your Project
```bash
# Copy .agent folder to any project
cp -r path/to/.agent /your-project/.agent
cd /your-project
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
- ✅ Creates project configuration
- ✅ Ready to use!

---

## 📋 What It Detects

### Automatically Recognizes:

**Frontend:**
- Next.js (from `package.json`)
- React
- Vue
- Svelte
- TypeScript

**Backend:**
- Laravel (from `composer.json`)
- Express/Fastify (from `package.json`)
- FastAPI/Django/Flask (from `requirements.txt`)
- Go (from `go.mod`)
- Rust (from `Cargo.toml`)

**Mobile:**
- React Native (`ios/Podfile`, `android/build.gradle`)
- Flutter (`pubspec.yaml`)

**Database:**
- Prisma (`prisma/schema.prisma`)
- Drizzle (`drizzle.config.ts`)

---

## 🎯 Example Workflows

### New Laravel + React Project

```bash
# 1. Create project
composer create-project laravel/laravel my-app
cd my-app
npm install react

# 2. Copy .agent
cp -r ~/path/to/.agent .

# 3. Initialize (ONE COMMAND!)
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

```bash
# 1. Navigate to project
cd existing-nextjs-app

# 2. Copy .agent
cp -r ~/path/to/.agent .

# 3. Initialize
./.agent/agent.sh init

# Output:
# ✅ Tech Stack Detected:
#   Frontend: Next.js, TypeScript
# ✅ Agents Activated:
#   → frontend-specialist (Next.js + TypeScript)
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
│   ├── PROJECT-README.md     ← Quick reference for this project
│   ├── agent.ps1            ← CLI script (Windows)
│   ├── agent.sh             ← CLI script (Linux/Mac)
│   └── [all .agent files...]
├── package.json             ← Your existing files
├── composer.json
└── ...
```

### project.json Example:
```json
{
  "version": "4.0.0",
  "initialized": "2026-01-17 10:50:00",
  "tech_stack": {
    "frontend": "Next.js TypeScript",
    "backend": "Laravel",
    "database": "Prisma"
  },
  "active_agents": [
    "frontend-specialist",
    "laravel-specialist",
    "database-architect",
    "security-auditor",
    "test-engineer"
  ]
}
```

---

## 🔧 Advanced Usage

### Force Reinitialize
```powershell
# Windows
.\.agent\agent.ps1 init -Force

# Linux/Mac
./.agent/agent.sh init --force
```

### Check Status
```powershell
# Windows
.\.agent\agent.ps1 status

# Linux/Mac
./.agent/agent.sh status
```

---

## 💬 Using with Antigravity

After initialization, just tell Antigravity what you want:

**Example 1: New Feature**
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

**Example 2: Quick Task**
```
USER: "Add a blog post model with comments"

ANTIGRAVITY:
  [Reads .agent/project.json]
  ✅ Laravel project detected
  ✅ Activating: laravel-specialist
  
  [Executes:]
  Phase 1: Requirements ✓
  Phase 2: Design schema ✓
  Phase 3: Create migrations, models, API ✓
  Phase 4: Write tests ✓
  Phase 5: Self-check (Pint, PHPStan, Tests) ✓
  
  ✅ COMPLETE! All tests passing.
```

---

## 🎯 Benefits

### Before (Manual Setup):
```bash
# ❌ Complex manual process
1. Copy template
2. Fill placeholders
3. Configure tech stack
4. Set constraints
5. Test workflow
6. Deploy agent
```

### After (Auto Init):
```bash
# ✅ ONE COMMAND!
./.agent/agent.sh init
# Done! 🎉
```

---

## 🔥 Key Features

### 1. **Zero Configuration**
- No manual file editing
- No template filling
- No tech stack selection
- IT JUST WORKS! ✨

### 2. **Intelligent Detection**
- Reads `package.json`, `composer.json`, etc.
- Identifies frameworks automatically
- Activates appropriate agents
- Creates optimized config

### 3. **Project-Specific**
- Each project gets its own config
- Remembers tech stack
- Activates only relevant agents
- Clean, isolated setup

### 4. **Portable**
- Copy .agent to ANY project
- Works on Windows, Linux, Mac
- Same commands everywhere
- Consistent experience

---

## 🚨 Troubleshooting

### Issue: "Could not auto-detect tech stack"

**Solution:** Ensure you have at least one of:
- `package.json` (Node.js)
- `composer.json` (PHP)
- `requirements.txt` (Python)
- `go.mod` (Go)
- `Cargo.toml` (Rust)

### Issue: "Project already initialized"

**Solution:** Use `--force` or `-Force`:
```bash
./.agent/agent.sh init --force
```

### Issue: "agent.ps1 cannot be loaded"

**Solution:** Set execution policy (Windows):
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 📚 Next Steps

After initialization:

1. **Read Project README**
   ```bash
   cat .agent/PROJECT-README.md
   ```

2. **Check Configuration**
   ```bash
   ./.agent/agent.sh status
   ```

3. **Start Building!**
   Just describe what you want to Antigravity!

---

## 🎉 Summary

**OLD WAY (Complex):**
```
Copy template → Fill fields → Configure → Test → Deploy
(30+ minutes manual work)
```

**NEW WAY (Simple):**
```bash
./.agent/agent.sh init
# 5 seconds, fully automatic! ✨
```

---

**You now have INSTANT, ZERO-CONFIG, AUTO-DETECTING .agent setup!** 🚀

**Just:**
1. Copy `.agent` folder
2. Run `./.agent/agent.sh init` (Linux/Mac) or `.\.agent\agent.ps1 init` (Windows)
3. Start building!

**No configuration, no setup, no hassle!** 🎯

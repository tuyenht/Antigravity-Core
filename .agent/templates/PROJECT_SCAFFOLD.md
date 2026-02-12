# 📁 PROJECT SCAFFOLD TEMPLATE

**Version:** 1.0  
**Purpose:** Template cấu trúc thư mục chuẩn cho mọi project sinh ra từ Antigravity-Core  
**Usage:** Khi tạo project mới, AI tự động tạo cấu trúc này

---

## 🎯 MỤC ĐÍCH

Khi Antigravity-Core sinh ra một project mới (qua `New-Project-Interview-Prompt.txt`), cấu trúc thư mục sau sẽ được TỰ ĐỘNG tạo ra, đảm bảo:

1. **Consistency** - Mọi project có structure giống nhau
2. **AI-Ready** - .agent được tích hợp sẵn
3. **Production-Ready** - Có đủ CI/CD, Docker, Scripts
4. **Documentation-First** - Docs trước code

---

## 📁 CẤU TRÚC CHUẨN

```
[project-name]/
│
├── 📂 .agent/                    ← AI OS (copy từ Antigravity-Core)
│   ├── agents/                   ← 27 agents chuyên biệt
│   ├── roles/
│   │   └── AGENT_ROLES.md        ← Định nghĩa vai trò
│   ├── workflows/                ← 31 slash commands
│   ├── skills/                   ← 57+ kỹ năng chuyên biệt
│   ├── rules/                    ← 68 coding standards
│   ├── scripts/                  ← Automation scripts
│   └── templates/                ← File templates
│
├── 📂 docs/                      ← Tài liệu dự án
│   ├── 📄 PRD.md                 ← Product Requirements Document
│   ├── 📄 architecture.md        ← System architecture
│   ├── 📄 tech-decisions.md      ← Architecture Decision Records
│   ├── 📄 schema.sql             ← Database schema
│   ├── 📄 backlog.md             ← Product backlog (User Stories)
│   ├── 📄 api-docs.md            ← API documentation
│   └── 📂 diagrams/              ← Mermaid/PlantUML diagrams
│       └── component-diagram.mmd
│
├── 📂 src/                       ← Source code (varies by stack)
│   ├── 📂 app/                   ← Application code
│   ├── 📂 components/            ← UI components (if frontend)
│   ├── 📂 services/              ← Business logic
│   ├── 📂 models/                ← Data models
│   └── 📂 utils/                 ← Utility functions
│
├── 📂 tests/                     ← Test files
│   ├── 📂 unit/                  ← Unit tests
│   ├── 📂 integration/           ← Integration tests
│   └── 📂 e2e/                   ← End-to-end tests
│
├── 📂 scripts/                   ← Build/Deploy scripts
│   ├── 📄 setup.sh               ← Initial setup
│   ├── 📄 build.sh               ← Build script
│   └── 📄 deploy.sh              ← Deployment script
│
├── 📂 .github/                   ← GitHub Actions
│   └── 📂 workflows/
│       ├── 📄 ci.yml             ← Continuous Integration
│       └── 📄 cd.yml             ← Continuous Deployment
│
├── 📄 .env.example               ← Environment variables template
├── 📄 .gitignore                 ← Git ignore rules
├── 📄 docker-compose.yml         ← Docker configuration
├── 📄 Makefile                   ← Make commands
└── 📄 README.md                  ← Project overview
```

---

## 📋 FILES BẮT BUỘC (Mandatory)

### Giai đoạn 1: Planning (Trước khi code)

| File | Mô tả | Tạo bởi Role |
|------|-------|--------------|
| `docs/PRD.md` | Product Requirements | Business Analyst |
| `docs/architecture.md` | System design | Solution Architect |
| `docs/tech-decisions.md` | Tech choices rationale | Solution Architect |
| `docs/schema.sql` | Database design | Solution Architect |
| `docs/backlog.md` | User Stories | Project Manager |

### Giai đoạn 2: Implementation (Khi code)

| File | Mô tả | Tạo bởi Role |
|------|-------|--------------|
| `src/**` | Source code | Developers |
| `tests/**` | Test files | Developers + QA |
| `docs/api-docs.md` | API documentation | Backend Developer |

### Giai đoạn 3: Deployment (Khi deploy)

| File | Mô tả | Tạo bởi Role |
|------|-------|--------------|
| `.github/workflows/ci.yml` | CI pipeline | DevOps Engineer |
| `docker-compose.yml` | Docker config | DevOps Engineer |
| `README.md` | Project guide | All |

---

## 🏗️ SCAFFOLD BY TECH STACK

### Laravel + React (Inertia)

```
[project-name]/
├── .agent/                       ← Copy từ Antigravity-Core
├── docs/                         ← Như trên
├── app/                          ← Laravel app
│   ├── Http/Controllers/
│   ├── Models/
│   └── Services/
├── resources/
│   └── js/
│       ├── Components/           ← React components
│       ├── Pages/                ← Inertia pages
│       └── Layouts/
├── routes/
│   ├── web.php
│   └── api.php
├── database/
│   ├── migrations/
│   └── seeders/
├── tests/
│   ├── Feature/
│   └── Unit/
├── .github/workflows/
├── docker-compose.yml
├── composer.json
├── package.json
└── README.md
```

### Next.js (Full-stack)

```
[project-name]/
├── .agent/                       ← Copy từ Antigravity-Core
├── docs/                         ← Như trên
├── src/
│   ├── app/                      ← App Router pages
│   ├── components/
│   │   ├── ui/                   ← Reusable UI
│   │   └── features/             ← Feature components
│   ├── lib/                      ← Utilities
│   ├── services/                 ← API services
│   └── types/                    ← TypeScript types
├── prisma/
│   └── schema.prisma             ← Database schema
├── tests/
│   ├── unit/
│   └── e2e/
├── .github/workflows/
├── docker-compose.yml
├── package.json
└── README.md
```

### Python FastAPI

```
[project-name]/
├── .agent/                       ← Copy từ Antigravity-Core
├── docs/                         ← Như trên
├── src/
│   ├── api/
│   │   ├── routes/
│   │   └── dependencies/
│   ├── core/
│   │   ├── config.py
│   │   └── security.py
│   ├── models/
│   ├── schemas/
│   └── services/
├── tests/
│   ├── unit/
│   └── integration/
├── alembic/                      ← DB migrations
├── .github/workflows/
├── docker-compose.yml
├── pyproject.toml
└── README.md
```

---

## 🛠️ SCAFFOLD GENERATION COMMAND

Khi Antigravity nhận lệnh tạo project mới:

```
Prompt:
"Tạo project mới: [TÊN PROJECT]
Tech stack: [STACK]
Scaffold theo template PROJECT_SCAFFOLD.md"
```

**AI sẽ:**
1. ✅ Tạo thư mục project
2. ✅ Copy `.agent/` từ Antigravity-Core
3. ✅ Customize theo tech stack
4. ✅ Tạo files mandatory (PRD.md template, README.md, etc.)
5. ✅ Setup .gitignore, .env.example
6. ✅ Initialize git repo

---

## 📝 FILE TEMPLATES

### README.md Template

```markdown
# [PROJECT NAME]

> [MỘT CÂU MÔ TẢ DỰ ÁN]

## 🚀 Quick Start

\`\`\`bash
# Clone repo
git clone [REPO_URL]
cd [PROJECT_NAME]

# Setup
cp .env.example .env
[SETUP COMMANDS]

# Run
[RUN COMMANDS]
\`\`\`

## 📁 Project Structure

[TREE STRUCTURE]

## 📖 Documentation

- [PRD](docs/PRD.md) - Product Requirements
- [Architecture](docs/architecture.md) - System Design
- [API Docs](docs/api-docs.md) - API Reference

## 🧪 Testing

\`\`\`bash
[TEST COMMANDS]
\`\`\`

## 🚢 Deployment

See [Deployment Guide](docs/deployment-guide.md)

## 👥 Team

Built with ❤️ using Antigravity-Core AI OS

---
Generated by Antigravity-Core
```

### .env.example Template

```env
# Application
APP_NAME=[PROJECT_NAME]
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost

# Database
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=[PROJECT_NAME]
DB_USERNAME=postgres
DB_PASSWORD=

# Cache/Queue
CACHE_DRIVER=redis
QUEUE_CONNECTION=redis

REDIS_HOST=127.0.0.1
REDIS_PORT=6379

# External Services
# API_KEY=
# SECRET_KEY=
```

### .gitignore Template

```gitignore
# Dependencies
node_modules/
vendor/
__pycache__/
.venv/

# Environment
.env
.env.local
.env.*.local

# Build outputs
dist/
build/
.next/
storage/

# IDE
.idea/
.vscode/
*.swp

# OS
.DS_Store
Thumbs.db

# Testing
coverage/
.nyc_output/

# Logs
*.log
npm-debug.log*

# Temp
*.tmp
*.temp
.cache/
```

---

## ✅ VALIDATION CHECKLIST

Sau khi scaffold, verify:

- [ ] `.agent/` folder exists và có đủ subfolders
- [ ] `docs/` folder có PRD.md template
- [ ] `README.md` có nội dung cơ bản
- [ ] `.gitignore` phù hợp với tech stack
- [ ] `.env.example` có các biến cần thiết
- [ ] Git initialized (`git init`)
- [ ] No secrets in committed files

---

## 🔗 RELATED FILES

- **Role definitions:** `.agent/roles/AGENT_ROLES.md`
- **Agent fleet:** `.agent/agents/` (27 agents)
- **Output standards:** `.agent/standards/OUTPUT_FILES.md`
- **Usage guide:** `.agent/templates/USAGE-GUIDE.md`

---

**Version:** 1.0  
**Created:** 2026-01-31  
**Status:** ✅ Production Ready

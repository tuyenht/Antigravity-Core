---
description: Backup database và project state trước khi thay đổi lớn
---

# /backup — Project Backup & Restore

// turbo-all

Create snapshots of database and critical project state before major changes.

## When to Use

- Before running migrations
- Before major refactoring
- Before deployment
- Before framework upgrade (`/migrate`)

## Steps

### Step 1: Detect Database

```
Auto-detect:
├── .env DATABASE_URL + prisma    → prisma db dump
├── .env DB_CONNECTION + Laravel  → php artisan backup:run
├── SQLite file found             → Copy .sqlite file
├── PostgreSQL detected           → pg_dump
├── MySQL detected                → mysqldump
└── MongoDB detected              → mongodump
```

### Step 2: Create Backup

```bash
# Create timestamped backup directory
mkdir -p .backups/$(date +%Y%m%d_%H%M%S)

# Database backup (framework-specific)
# Files backup (critical configs)
cp .env .backups/latest/.env.bak
cp -r prisma/migrations .backups/latest/migrations/  # if Prisma
```

### Step 3: Verify Backup

- [ ] Backup file exists and is non-empty
- [ ] Database dump is valid (can be restored)
- [ ] .env backup created

### Step 4: Restore (when needed)

```bash
# Restore database from latest backup
# Restore .env if needed
```

**Agent:** `backend-specialist`

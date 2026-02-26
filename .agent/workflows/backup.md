---
description: "Backup database và project state trước khi thay đổi lớn"
---

# /backup — Project Backup & Restore

// turbo-all

Create snapshots of database and critical project state before major changes.

**Agent:** `backend-specialist`  
**Skills:** `database-design`, `deployment-procedures`

---

## When to Use

- Trước khi chạy migrations (`/migrate`)
- Trước khi refactoring lớn (`/refactor`)
- Trước deployment (`/deploy`)
- Trước framework upgrade
- Trước khi xóa/thay đổi schema

---

## Step 1: Detect Database

```
Auto-detect:
├── .env DATABASE_URL + prisma     → Prisma dump
├── .env DB_CONNECTION + Laravel   → Laravel backup
├── .env + PostgreSQL              → pg_dump
├── .env + MySQL/MariaDB           → mysqldump
├── .env + MongoDB                 → mongodump
├── SQLite file (.sqlite/.db)      → File copy
└── Không detect được              → STOP: "Không tìm thấy database config"
```

---

## Step 2: Create Backup

### Linux/macOS
```bash
# Create timestamped backup directory
BACKUP_DIR=".backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Database backup (auto-detect)
# PostgreSQL
pg_dump "$DATABASE_URL" > "$BACKUP_DIR/database.sql"

# MySQL
mysqldump -u "$DB_USERNAME" -p"$DB_PASSWORD" "$DB_DATABASE" > "$BACKUP_DIR/database.sql"

# SQLite
cp "$DB_DATABASE" "$BACKUP_DIR/database.sqlite"

# Laravel (spatie/laravel-backup)
php artisan backup:run --only-db

# Prisma
npx prisma db pull && cp prisma/schema.prisma "$BACKUP_DIR/"

# Critical files backup
cp .env "$BACKUP_DIR/.env.bak"
[ -d "prisma/migrations" ] && cp -r prisma/migrations "$BACKUP_DIR/migrations/"
[ -d "database/migrations" ] && cp -r database/migrations "$BACKUP_DIR/migrations/"

# Create manifest
echo "Backup created: $(date)" > "$BACKUP_DIR/MANIFEST.txt"
echo "Database: $DB_CONNECTION" >> "$BACKUP_DIR/MANIFEST.txt"
echo "Files:" >> "$BACKUP_DIR/MANIFEST.txt"
ls -la "$BACKUP_DIR" >> "$BACKUP_DIR/MANIFEST.txt"

# Symlink latest
ln -sfn "$BACKUP_DIR" .backups/latest
echo "✅ Backup saved to: $BACKUP_DIR"
```

### Windows (PowerShell)
```powershell
$backupDir = ".backups\$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

# SQLite
Copy-Item $env:DB_DATABASE "$backupDir\database.sqlite" -ErrorAction SilentlyContinue

# Critical files
Copy-Item .env "$backupDir\.env.bak"
if (Test-Path "prisma\migrations") { Copy-Item "prisma\migrations" "$backupDir\migrations" -Recurse }
if (Test-Path "database\migrations") { Copy-Item "database\migrations" "$backupDir\migrations" -Recurse }

Write-Host "✅ Backup saved to: $backupDir"
```

---

## Step 3: Verify Backup

- [ ] Backup directory exists and is non-empty
- [ ] Database dump file > 0 bytes
- [ ] .env backup created
- [ ] Migrations directory copied (if exists)
- [ ] MANIFEST.txt created

```bash
# Quick verify
ls -lh "$BACKUP_DIR"
wc -l "$BACKUP_DIR/database.sql"  # Should have lines
```

---

## Step 4: Restore (When Needed)

### PostgreSQL
```bash
psql "$DATABASE_URL" < .backups/latest/database.sql
```

### MySQL
```bash
mysql -u "$DB_USERNAME" -p"$DB_PASSWORD" "$DB_DATABASE" < .backups/latest/database.sql
```

### SQLite
```bash
cp .backups/latest/database.sqlite "$DB_DATABASE"
```

### Laravel
```bash
php artisan backup:restore --latest
# hoặc manual:
mysql -u "$DB_USERNAME" -p"$DB_PASSWORD" "$DB_DATABASE" < .backups/latest/database.sql
```

### .env Restore
```bash
cp .backups/latest/.env.bak .env
```

### Verify Restore
- [ ] App starts without errors
- [ ] Database connection OK
- [ ] Key data is present (spot-check)
- [ ] Migrations status correct (`php artisan migrate:status` / `npx prisma migrate status`)

---

## Step 5: Cleanup Policy

```bash
# Keep only last 5 backups (auto-cleanup)
cd .backups && ls -dt */ | tail -n +6 | xargs rm -rf
echo "🧹 Old backups cleaned. Keeping 5 most recent."
```

### .gitignore
```
# Add to .gitignore (if not already)
.backups/
```

---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| pg_dump not found | `sudo apt install postgresql-client` |
| mysqldump not found | `sudo apt install mysql-client` |
| Permission denied | Check DB credentials in .env |
| Backup too large | Use `--compress` flag hoặc `gzip` |
| Restore fails | Check database exists, user has permissions |




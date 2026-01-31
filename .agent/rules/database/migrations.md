# Database Migration Strategies Expert

> **Version:** 2.0.0 | **Updated:** 2026-02-01  
> **Tools:** Prisma, TypeORM, Laravel, Alembic  
> **Priority:** P0 - Load for database migrations

---

You are an expert in database migrations and schema evolution.

## Core Principles

- Treat database changes as code
- Version control all migrations
- Plan for rollbacks
- Aim for zero-downtime deployments

---

## 1) Migration Fundamentals

### Migration File Structure
```typescript
// ==========================================
// PRISMA MIGRATION
// ==========================================

// prisma/migrations/20240115_add_user_status/migration.sql
-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('active', 'inactive', 'suspended');

-- AlterTable
ALTER TABLE "users" ADD COLUMN "status" "UserStatus" NOT NULL DEFAULT 'active';

-- CreateIndex
CREATE INDEX "users_status_idx" ON "users"("status");


// ==========================================
// TYPEORM MIGRATION
// ==========================================

// src/migrations/1705312800000-AddUserStatus.ts
import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddUserStatus1705312800000 implements MigrationInterface {
  name = 'AddUserStatus1705312800000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Create enum type
    await queryRunner.query(`
      CREATE TYPE "user_status_enum" AS ENUM ('active', 'inactive', 'suspended')
    `);
    
    // Add column with default
    await queryRunner.query(`
      ALTER TABLE "users" 
      ADD COLUMN "status" "user_status_enum" NOT NULL DEFAULT 'active'
    `);
    
    // Create index
    await queryRunner.query(`
      CREATE INDEX "IDX_users_status" ON "users" ("status")
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Drop index
    await queryRunner.query(`
      DROP INDEX "IDX_users_status"
    `);
    
    // Drop column
    await queryRunner.query(`
      ALTER TABLE "users" DROP COLUMN "status"
    `);
    
    // Drop enum
    await queryRunner.query(`
      DROP TYPE "user_status_enum"
    `);
  }
}


// ==========================================
// LARAVEL MIGRATION
// ==========================================

// database/migrations/2024_01_15_000000_add_user_status.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->enum('status', ['active', 'inactive', 'suspended'])
                  ->default('active')
                  ->after('email');
            
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex(['status']);
            $table->dropColumn('status');
        });
    }
};


// ==========================================
// ALEMBIC MIGRATION (Python)
// ==========================================

# alembic/versions/20240115_add_user_status.py
"""add user status

Revision ID: a1b2c3d4e5f6
Revises: 9z8y7x6w5v4u
Create Date: 2024-01-15 10:30:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = 'a1b2c3d4e5f6'
down_revision = '9z8y7x6w5v4u'
branch_labels = None
depends_on = None

def upgrade():
    # Create enum
    user_status = postgresql.ENUM('active', 'inactive', 'suspended', name='user_status')
    user_status.create(op.get_bind())
    
    # Add column
    op.add_column('users', sa.Column(
        'status',
        sa.Enum('active', 'inactive', 'suspended', name='user_status'),
        nullable=False,
        server_default='active'
    ))
    
    # Create index
    op.create_index('ix_users_status', 'users', ['status'])

def downgrade():
    op.drop_index('ix_users_status', table_name='users')
    op.drop_column('users', 'status')
    
    # Drop enum
    user_status = postgresql.ENUM('active', 'inactive', 'suspended', name='user_status')
    user_status.drop(op.get_bind())
```

---

## 2) Zero-Downtime Migrations

### Expand and Contract Pattern
```sql
-- ==========================================
-- SAFE COLUMN RENAME (3-phase deployment)
-- ==========================================

-- PHASE 1: EXPAND (Add new column)
-- Deploy: Database migration only
ALTER TABLE users ADD COLUMN full_name VARCHAR(100);

-- Backfill data
UPDATE users SET full_name = name WHERE full_name IS NULL;

-- PHASE 2: DUAL WRITE (Application change)
-- Deploy: Application writes to BOTH columns
/*
  // Application code
  user.name = value;
  user.full_name = value;  // Write to both
  
  // Read from new column
  return user.full_name ?? user.name;
*/

-- PHASE 3: CONTRACT (Remove old column)
-- After verification period
ALTER TABLE users DROP COLUMN name;


-- ==========================================
-- SAFE COLUMN TYPE CHANGE
-- ==========================================

-- Original: price INTEGER (cents)
-- Target: price DECIMAL(10,2) (dollars)

-- PHASE 1: Add new column
ALTER TABLE products ADD COLUMN price_decimal DECIMAL(10,2);

-- PHASE 2: Backfill (in batches)
UPDATE products 
SET price_decimal = price / 100.0 
WHERE price_decimal IS NULL
LIMIT 10000;
-- Repeat until complete

-- PHASE 3: Dual write in application
-- PHASE 4: Switch reads to new column
-- PHASE 5: Stop writing to old column
-- PHASE 6: Drop old column
ALTER TABLE products DROP COLUMN price;
ALTER TABLE products RENAME COLUMN price_decimal TO price;


-- ==========================================
-- SAFE NOT NULL CONSTRAINT
-- ==========================================

-- ❌ DANGEROUS: Add NOT NULL directly (locks table, fails if NULLs exist)
ALTER TABLE users ALTER COLUMN phone SET NOT NULL;

-- ✅ SAFE: Multi-step approach

-- Step 1: Add column as nullable
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- Step 2: Backfill data (application or script)
UPDATE users SET phone = 'unknown' WHERE phone IS NULL;

-- Step 3: Add constraint without validation (PostgreSQL)
ALTER TABLE users 
ADD CONSTRAINT users_phone_not_null 
CHECK (phone IS NOT NULL) NOT VALID;

-- Step 4: Validate constraint (non-blocking)
ALTER TABLE users VALIDATE CONSTRAINT users_phone_not_null;

-- Step 5: Convert to NOT NULL (instant, constraint already validated)
ALTER TABLE users ALTER COLUMN phone SET NOT NULL;
ALTER TABLE users DROP CONSTRAINT users_phone_not_null;
```

### Safe Index Creation
```sql
-- ==========================================
-- CREATE INDEX CONCURRENTLY (PostgreSQL)
-- ==========================================

-- ❌ DANGEROUS: Locks table during creation
CREATE INDEX idx_orders_user ON orders (user_id);

-- ✅ SAFE: Non-blocking index creation
CREATE INDEX CONCURRENTLY idx_orders_user ON orders (user_id);

-- Note: CONCURRENTLY cannot run in transaction
-- Handle in migration:

// TypeORM
public async up(queryRunner: QueryRunner): Promise<void> {
  // Disable transaction for this migration
  await queryRunner.query(`
    CREATE INDEX CONCURRENTLY IF NOT EXISTS "idx_orders_user" 
    ON "orders" ("user_id")
  `);
}

// Prisma: Use raw SQL in separate step
// 1. Run: npx prisma migrate deploy
// 2. Run: psql -c "CREATE INDEX CONCURRENTLY..."


-- ==========================================
-- DROP INDEX CONCURRENTLY (PostgreSQL)
-- ==========================================

DROP INDEX CONCURRENTLY idx_orders_old;


-- ==========================================
-- MYSQL ONLINE DDL
-- ==========================================

-- MySQL 8.0+ supports ALGORITHM=INPLACE for many operations
ALTER TABLE orders 
ADD INDEX idx_orders_user (user_id),
ALGORITHM=INPLACE, LOCK=NONE;

-- Check operation support
ALTER TABLE orders 
ADD COLUMN notes TEXT,
ALGORITHM=INSTANT;  -- MySQL 8.0.12+ for adding columns at end
```

### Safe Foreign Key
```sql
-- ==========================================
-- ADD FOREIGN KEY SAFELY
-- ==========================================

-- ❌ DANGEROUS: Validates all existing rows (locks table)
ALTER TABLE orders 
ADD CONSTRAINT fk_orders_user 
FOREIGN KEY (user_id) REFERENCES users(id);

-- ✅ SAFE: Add without validation, then validate separately

-- Step 1: Add constraint without validation (PostgreSQL)
ALTER TABLE orders 
ADD CONSTRAINT fk_orders_user 
FOREIGN KEY (user_id) REFERENCES users(id) 
NOT VALID;

-- Step 2: Validate (non-blocking, can run during traffic)
ALTER TABLE orders VALIDATE CONSTRAINT fk_orders_user;


-- MySQL: Add FK on empty or small table, or during maintenance
-- For large tables, consider trigger-based approach or pt-online-schema-change
```

---

## 3) Data Migrations

### Batch Processing
```typescript
// ==========================================
// BATCH DATA MIGRATION (TypeScript)
// ==========================================

interface MigrationOptions {
  batchSize: number;
  delayMs: number;
  dryRun: boolean;
}

async function migrateUserEmails(options: MigrationOptions): Promise<void> {
  const { batchSize, delayMs, dryRun } = options;
  let totalMigrated = 0;
  let hasMore = true;
  let lastId = 0;

  console.log(`Starting migration (dryRun: ${dryRun})`);

  while (hasMore) {
    // Fetch batch using keyset pagination
    const users = await db.query(`
      SELECT id, email, normalized_email
      FROM users
      WHERE id > $1 AND normalized_email IS NULL
      ORDER BY id
      LIMIT $2
    `, [lastId, batchSize]);

    if (users.length === 0) {
      hasMore = false;
      continue;
    }

    // Process batch
    for (const user of users) {
      const normalized = user.email.toLowerCase().trim();
      
      if (!dryRun) {
        await db.query(`
          UPDATE users 
          SET normalized_email = $1, updated_at = NOW()
          WHERE id = $2
        `, [normalized, user.id]);
      }
      
      lastId = user.id;
      totalMigrated++;
    }

    console.log(`Migrated ${totalMigrated} users (last id: ${lastId})`);

    // Rate limiting to reduce database load
    if (delayMs > 0) {
      await new Promise(resolve => setTimeout(resolve, delayMs));
    }
  }

  console.log(`Migration complete. Total: ${totalMigrated}`);
}

// Usage
await migrateUserEmails({
  batchSize: 1000,
  delayMs: 100,  // 100ms between batches
  dryRun: false
});


// ==========================================
// LARGE TABLE UPDATE WITH PROGRESS
// ==========================================

async function backfillOrderTotals(): Promise<void> {
  // Get total count for progress
  const [{ count }] = await db.query(`
    SELECT COUNT(*) as count FROM orders WHERE calculated_total IS NULL
  `);
  
  console.log(`Total orders to process: ${count}`);
  
  let processed = 0;
  const batchSize = 5000;
  
  while (true) {
    // Use CTE for atomic batch update
    const result = await db.query(`
      WITH batch AS (
        SELECT id 
        FROM orders 
        WHERE calculated_total IS NULL 
        LIMIT $1
        FOR UPDATE SKIP LOCKED
      )
      UPDATE orders o
      SET calculated_total = (
        SELECT COALESCE(SUM(quantity * unit_price), 0)
        FROM order_items WHERE order_id = o.id
      )
      FROM batch
      WHERE o.id = batch.id
      RETURNING o.id
    `, [batchSize]);
    
    if (result.length === 0) break;
    
    processed += result.length;
    const progress = ((processed / count) * 100).toFixed(1);
    console.log(`Progress: ${progress}% (${processed}/${count})`);
    
    // Small delay to reduce load
    await new Promise(r => setTimeout(r, 50));
  }
}
```

### Data Validation
```sql
-- ==========================================
-- PRE-MIGRATION VALIDATION
-- ==========================================

-- Check for orphaned records before adding FK
SELECT o.id, o.user_id
FROM orders o
LEFT JOIN users u ON u.id = o.user_id
WHERE u.id IS NULL;

-- Fix orphaned records
UPDATE orders SET user_id = 1  -- Default user
WHERE user_id NOT IN (SELECT id FROM users);

-- Or delete orphans
DELETE FROM orders 
WHERE user_id NOT IN (SELECT id FROM users);


-- ==========================================
-- POST-MIGRATION VALIDATION
-- ==========================================

-- Verify data integrity
SELECT 
  (SELECT COUNT(*) FROM users WHERE status IS NULL) as null_status,
  (SELECT COUNT(*) FROM users WHERE email IS NULL) as null_email,
  (SELECT COUNT(*) FROM orders WHERE user_id IS NULL) as orphan_orders;

-- Verify constraints
SELECT conname, contype, convalidated
FROM pg_constraint
WHERE conrelid = 'users'::regclass;

-- Verify indexes
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'users';
```

---

## 4) Rollback Strategies

### Safe Rollback Patterns
```typescript
// ==========================================
// REVERSIBLE MIGRATION
// ==========================================

// migrations/20240115_add_user_preferences.ts
export class AddUserPreferences implements MigrationInterface {
  
  public async up(queryRunner: QueryRunner): Promise<void> {
    // Create new table
    await queryRunner.query(`
      CREATE TABLE user_preferences (
        id BIGSERIAL PRIMARY KEY,
        user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        theme VARCHAR(20) DEFAULT 'light',
        language VARCHAR(10) DEFAULT 'en',
        notifications_enabled BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_id)
      )
    `);
    
    // Migrate data from users table
    await queryRunner.query(`
      INSERT INTO user_preferences (user_id, theme, language)
      SELECT id, theme, language FROM users WHERE theme IS NOT NULL
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Reverse: Copy data back to users (if columns still exist)
    // Note: This assumes we haven't dropped the columns yet
    
    await queryRunner.query(`
      UPDATE users u
      SET 
        theme = up.theme,
        language = up.language
      FROM user_preferences up
      WHERE u.id = up.user_id
    `);
    
    // Drop the new table
    await queryRunner.query(`DROP TABLE user_preferences`);
  }
}


// ==========================================
// NON-REVERSIBLE MIGRATION (Document clearly)
// ==========================================

export class MergeUserNames implements MigrationInterface {
  
  public async up(queryRunner: QueryRunner): Promise<void> {
    // Add new column
    await queryRunner.query(`
      ALTER TABLE users ADD COLUMN full_name VARCHAR(200)
    `);
    
    // Merge first_name and last_name
    await queryRunner.query(`
      UPDATE users 
      SET full_name = CONCAT(first_name, ' ', last_name)
      WHERE full_name IS NULL
    `);
    
    // ⚠️ WARNING: Dropping columns is NOT reversible
    // Data in first_name and last_name will be LOST
    await queryRunner.query(`
      ALTER TABLE users 
      DROP COLUMN first_name,
      DROP COLUMN last_name
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // ⚠️ CANNOT fully reverse - data is lost!
    // Best effort: recreate columns as nullable
    
    await queryRunner.query(`
      ALTER TABLE users 
      ADD COLUMN first_name VARCHAR(100),
      ADD COLUMN last_name VARCHAR(100)
    `);
    
    // Attempt to split full_name (imperfect)
    await queryRunner.query(`
      UPDATE users 
      SET 
        first_name = SPLIT_PART(full_name, ' ', 1),
        last_name = SPLIT_PART(full_name, ' ', 2)
    `);
    
    await queryRunner.query(`
      ALTER TABLE users DROP COLUMN full_name
    `);
    
    console.warn('⚠️ Rollback complete but original data may be lossy');
  }
}
```

### Rollback Checklist
```typescript
// ==========================================
// MIGRATION WITH ROLLBACK VERIFICATION
// ==========================================

interface MigrationWithVerification {
  up(): Promise<void>;
  down(): Promise<void>;
  verifyUp(): Promise<boolean>;
  verifyDown(): Promise<boolean>;
}

const migration: MigrationWithVerification = {
  async up() {
    await db.query(`
      ALTER TABLE products ADD COLUMN sku VARCHAR(50) UNIQUE
    `);
  },
  
  async down() {
    await db.query(`
      ALTER TABLE products DROP COLUMN sku
    `);
  },
  
  async verifyUp() {
    // Verify column exists and has correct type
    const result = await db.query(`
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns
      WHERE table_name = 'products' AND column_name = 'sku'
    `);
    
    return result.length === 1 && result[0].data_type === 'character varying';
  },
  
  async verifyDown() {
    // Verify column does not exist
    const result = await db.query(`
      SELECT column_name
      FROM information_schema.columns
      WHERE table_name = 'products' AND column_name = 'sku'
    `);
    
    return result.length === 0;
  }
};

// Run with verification
async function runMigration(direction: 'up' | 'down') {
  const fn = direction === 'up' ? migration.up : migration.down;
  const verify = direction === 'up' ? migration.verifyUp : migration.verifyDown;
  
  await fn();
  
  const success = await verify();
  if (!success) {
    throw new Error(`Migration ${direction} verification failed`);
  }
  
  console.log(`Migration ${direction} completed and verified`);
}
```

---

## 5) CI/CD Integration

### GitHub Actions Pipeline
```yaml
# .github/workflows/database-migration.yml
name: Database Migration

on:
  push:
    branches: [main]
    paths:
      - 'prisma/migrations/**'
      - 'src/migrations/**'

env:
  DATABASE_URL: ${{ secrets.DATABASE_URL_STAGING }}

jobs:
  migrate-staging:
    runs-on: ubuntu-latest
    environment: staging
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Check pending migrations
        run: |
          npx prisma migrate status
      
      - name: Create backup
        run: |
          pg_dump $DATABASE_URL > backup_$(date +%Y%m%d_%H%M%S).sql
          # Upload to S3 or artifact storage
      
      - name: Run migrations
        run: npx prisma migrate deploy
      
      - name: Verify migration
        run: |
          npx prisma db pull --force
          npx prisma generate
          npm run test:db  # Run database tests
      
      - name: Notify on failure
        if: failure()
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "❌ Staging migration failed: ${{ github.run_url }}"
            }

  migrate-production:
    needs: migrate-staging
    runs-on: ubuntu-latest
    environment: production
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Create production backup
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL_PRODUCTION }}
        run: |
          BACKUP_FILE="backup_prod_$(date +%Y%m%d_%H%M%S).sql"
          pg_dump $DATABASE_URL > $BACKUP_FILE
          aws s3 cp $BACKUP_FILE s3://backups/database/
      
      - name: Run production migrations
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL_PRODUCTION }}
        run: npx prisma migrate deploy
      
      - name: Health check
        run: |
          curl -f https://api.example.com/health || exit 1
      
      - name: Notify success
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "✅ Production migration completed successfully"
            }
```

### Migration Scripts
```bash
#!/bin/bash
# scripts/migrate.sh

set -e

ENVIRONMENT=${1:-staging}
ACTION=${2:-deploy}

echo "🔄 Running migration: $ACTION on $ENVIRONMENT"

# Load environment
source .env.$ENVIRONMENT

# Pre-flight checks
echo "📋 Pre-flight checks..."
npx prisma migrate status

if [ "$ACTION" == "deploy" ]; then
    # Create backup
    echo "💾 Creating backup..."
    BACKUP_FILE="backup_${ENVIRONMENT}_$(date +%Y%m%d_%H%M%S).sql"
    pg_dump $DATABASE_URL > $BACKUP_FILE
    
    # Run migration
    echo "🚀 Running migrations..."
    npx prisma migrate deploy
    
    # Verify
    echo "✅ Verifying..."
    npx prisma db pull --force
    
    echo "🎉 Migration completed successfully"
    
elif [ "$ACTION" == "rollback" ]; then
    echo "⏪ Rolling back last migration..."
    
    # Get last migration
    LAST_MIGRATION=$(ls -1t prisma/migrations | head -1)
    echo "Rolling back: $LAST_MIGRATION"
    
    # Execute down migration if exists
    if [ -f "prisma/migrations/$LAST_MIGRATION/down.sql" ]; then
        psql $DATABASE_URL < "prisma/migrations/$LAST_MIGRATION/down.sql"
        echo "✅ Rollback completed"
    else
        echo "❌ No down.sql found for $LAST_MIGRATION"
        exit 1
    fi
    
elif [ "$ACTION" == "status" ]; then
    npx prisma migrate status
fi
```

---

## 6) Framework-Specific Patterns

### Prisma Migrations
```typescript
// ==========================================
// PRISMA WORKFLOW
// ==========================================

// 1. Modify schema.prisma
// schema.prisma
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String?
  status    UserStatus @default(ACTIVE)  // New field
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

enum UserStatus {
  ACTIVE
  INACTIVE
  SUSPENDED
}

// 2. Generate migration
// $ npx prisma migrate dev --name add_user_status

// 3. Review generated SQL
// prisma/migrations/20240115000000_add_user_status/migration.sql

// 4. Deploy to production
// $ npx prisma migrate deploy

// 5. Custom data migration
// prisma/migrations/20240115000000_add_user_status/data.ts
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // Backfill data
  await prisma.$executeRaw`
    UPDATE users 
    SET status = 'INACTIVE' 
    WHERE last_login_at < NOW() - INTERVAL '1 year'
  `;
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
```

### Laravel Migrations
```php
// ==========================================
// LARAVEL MIGRATION PATTERNS
// ==========================================

// database/migrations/2024_01_15_000001_add_user_status.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Step 1: Add nullable column
        Schema::table('users', function (Blueprint $table) {
            $table->string('status', 20)->nullable()->after('email');
        });

        // Step 2: Backfill data in batches
        DB::table('users')
            ->whereNull('status')
            ->orderBy('id')
            ->chunk(1000, function ($users) {
                foreach ($users as $user) {
                    DB::table('users')
                        ->where('id', $user->id)
                        ->update(['status' => 'active']);
                }
            });

        // Step 3: Add constraints
        Schema::table('users', function (Blueprint $table) {
            $table->string('status', 20)->default('active')->change();
            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex(['status']);
            $table->dropColumn('status');
        });
    }
};


// ==========================================
// SAFE FOREIGN KEY IN LARAVEL
// ==========================================

// database/migrations/2024_01_15_000002_add_team_foreign_key.php
return new class extends Migration
{
    public function up(): void
    {
        // Clean orphaned records first
        DB::table('users')
            ->whereNotIn('team_id', function ($query) {
                $query->select('id')->from('teams');
            })
            ->update(['team_id' => null]);

        // Now safely add FK
        Schema::table('users', function (Blueprint $table) {
            $table->foreign('team_id')
                  ->references('id')
                  ->on('teams')
                  ->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['team_id']);
        });
    }
};
```

---

## 7) Monitoring & Troubleshooting

### Lock Monitoring
```sql
-- ==========================================
-- MONITOR LOCKS DURING MIGRATION (PostgreSQL)
-- ==========================================

-- Check for blocking locks
SELECT 
    blocked.pid AS blocked_pid,
    blocked.query AS blocked_query,
    blocking.pid AS blocking_pid,
    blocking.query AS blocking_query,
    blocked.wait_event_type,
    blocked.wait_event
FROM pg_stat_activity blocked
JOIN pg_stat_activity blocking 
    ON blocking.pid = ANY(pg_blocking_pids(blocked.pid))
WHERE blocked.wait_event IS NOT NULL;

-- Check lock wait time
SELECT 
    pid,
    now() - query_start AS duration,
    query,
    state
FROM pg_stat_activity
WHERE wait_event IS NOT NULL
ORDER BY duration DESC;

-- Kill long-running blocking query (use carefully!)
SELECT pg_terminate_backend(pid);


-- ==========================================
-- MONITOR MIGRATION PROGRESS (PostgreSQL)
-- ==========================================

-- Check CREATE INDEX progress
SELECT 
    p.phase,
    p.blocks_total,
    p.blocks_done,
    round(100.0 * p.blocks_done / nullif(p.blocks_total, 0), 1) AS "% done",
    a.query
FROM pg_stat_progress_create_index p
JOIN pg_stat_activity a ON p.pid = a.pid;

-- Check VACUUM/ANALYZE progress
SELECT 
    p.phase,
    p.heap_blks_total,
    p.heap_blks_scanned,
    round(100.0 * p.heap_blks_scanned / nullif(p.heap_blks_total, 0), 1) AS "% done"
FROM pg_stat_progress_vacuum p;
```

---

## Best Practices Checklist

### Before Migration
- [ ] Review migration in staging
- [ ] Test rollback procedure
- [ ] Create backup
- [ ] Check for locks
- [ ] Notify team

### During Migration
- [ ] Monitor locks
- [ ] Watch for errors
- [ ] Check application health
- [ ] Monitor query performance

### After Migration
- [ ] Verify data integrity
- [ ] Check application logs
- [ ] Update documentation
- [ ] Remove old columns (contract phase)

### General
- [ ] Never modify existing migrations
- [ ] Use transactions when possible
- [ ] Batch large data updates
- [ ] Test both up and down
- [ ] Version control all migrations

---

**References:**
- [Prisma Migrations](https://www.prisma.io/docs/concepts/components/prisma-migrate)
- [Zero Downtime Migrations](https://blog.lawrencejones.dev/zero-downtime-migrations/)
- [PostgreSQL DDL](https://www.postgresql.org/docs/current/ddl.html)

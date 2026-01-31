# PostgreSQL Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **PostgreSQL:** 15+/16+  
> **Priority:** P0 - Load for PostgreSQL projects

---

You are an expert in PostgreSQL database administration and development.

## Core Principles

- Use strict typing and constraints
- Leverage advanced features (JSONB, Arrays)
- Optimize for concurrency (MVCC)
- Secure data at rest and in transit

---

## 1) Schema Design

### Data Types Best Practices
```sql
-- ==========================================
-- DATA TYPES SELECTION
-- ==========================================

-- ✅ GOOD: Appropriate data types
CREATE TABLE users (
    -- UUID for distributed-friendly primary key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- TEXT over VARCHAR (no performance difference)
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    
    -- TIMESTAMPTZ for timezone-aware timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- BOOLEAN for flags
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    
    -- SMALLINT for limited ranges (saves space)
    login_attempts SMALLINT NOT NULL DEFAULT 0,
    
    -- NUMERIC for precise decimals (money, etc.)
    account_balance NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    
    -- INET for IP addresses
    last_login_ip INET,
    
    -- JSONB for semi-structured data
    metadata JSONB NOT NULL DEFAULT '{}',
    
    -- ARRAY for simple lists
    roles TEXT[] NOT NULL DEFAULT '{}',
    
    -- Constraints
    CONSTRAINT email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT positive_balance CHECK (account_balance >= 0),
    CONSTRAINT valid_roles CHECK (roles <@ ARRAY['admin', 'user', 'moderator']::TEXT[])
);

-- Unique constraint with partial index
CREATE UNIQUE INDEX users_email_unique ON users (LOWER(email));

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();


-- ==========================================
-- COMPLETE TABLE EXAMPLE
-- ==========================================

CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Foreign key with ON DELETE behavior
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    title TEXT NOT NULL,
    slug TEXT NOT NULL,
    content TEXT NOT NULL,
    excerpt TEXT,
    
    -- Enum-like with CHECK constraint
    status TEXT NOT NULL DEFAULT 'draft' 
        CHECK (status IN ('draft', 'published', 'archived')),
    
    -- Full-text search vector (auto-generated)
    search_vector TSVECTOR GENERATED ALWAYS AS (
        setweight(to_tsvector('english', COALESCE(title, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(content, '')), 'B')
    ) STORED,
    
    -- JSONB for flexible metadata
    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,
    
    -- Tags as array
    tags TEXT[] NOT NULL DEFAULT '{}',
    
    view_count INTEGER NOT NULL DEFAULT 0,
    published_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Soft delete
    deleted_at TIMESTAMPTZ
);

-- Unique slug per author
CREATE UNIQUE INDEX posts_author_slug_unique 
    ON posts (author_id, slug) 
    WHERE deleted_at IS NULL;

-- Trigger for updated_at
CREATE TRIGGER posts_updated_at
    BEFORE UPDATE ON posts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();
```

### Table Partitioning
```sql
-- ==========================================
-- RANGE PARTITIONING (Time-based)
-- ==========================================

CREATE TABLE events (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    event_type TEXT NOT NULL,
    payload JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
) PARTITION BY RANGE (created_at);

-- Create partitions
CREATE TABLE events_2024_01 PARTITION OF events
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
    
CREATE TABLE events_2024_02 PARTITION OF events
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- Default partition for overflow
CREATE TABLE events_default PARTITION OF events DEFAULT;

-- Auto-create partitions function
CREATE OR REPLACE FUNCTION create_monthly_partition()
RETURNS VOID AS $$
DECLARE
    partition_date DATE := DATE_TRUNC('month', NOW()) + INTERVAL '1 month';
    partition_name TEXT;
    start_date TEXT;
    end_date TEXT;
BEGIN
    partition_name := 'events_' || TO_CHAR(partition_date, 'YYYY_MM');
    start_date := TO_CHAR(partition_date, 'YYYY-MM-DD');
    end_date := TO_CHAR(partition_date + INTERVAL '1 month', 'YYYY-MM-DD');
    
    IF NOT EXISTS (
        SELECT 1 FROM pg_class WHERE relname = partition_name
    ) THEN
        EXECUTE format(
            'CREATE TABLE %I PARTITION OF events FOR VALUES FROM (%L) TO (%L)',
            partition_name, start_date, end_date
        );
        RAISE NOTICE 'Created partition: %', partition_name;
    END IF;
END;
$$ LANGUAGE plpgsql;


-- ==========================================
-- LIST PARTITIONING (Category-based)
-- ==========================================

CREATE TABLE orders (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    region TEXT NOT NULL,
    total NUMERIC(15, 2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
) PARTITION BY LIST (region);

CREATE TABLE orders_us PARTITION OF orders FOR VALUES IN ('US', 'CA');
CREATE TABLE orders_eu PARTITION OF orders FOR VALUES IN ('UK', 'DE', 'FR');
CREATE TABLE orders_asia PARTITION OF orders FOR VALUES IN ('JP', 'CN', 'KR');
CREATE TABLE orders_other PARTITION OF orders DEFAULT;
```

---

## 2) Indexing Strategies

### Index Types
```sql
-- ==========================================
-- B-TREE (Default - Most Common)
-- ==========================================

-- Single column
CREATE INDEX idx_users_email ON users (email);

-- Multi-column (order matters!)
-- Good for: WHERE status = 'x' AND created_at > 'y'
CREATE INDEX idx_posts_status_created ON posts (status, created_at DESC);

-- Partial index (only index relevant rows)
CREATE INDEX idx_posts_published ON posts (published_at)
    WHERE status = 'published' AND deleted_at IS NULL;

-- Include columns (covering index)
CREATE INDEX idx_users_email_covering ON users (email) 
    INCLUDE (name, created_at);


-- ==========================================
-- GIN (Generalized Inverted Index)
-- For: JSONB, Arrays, Full-Text Search
-- ==========================================

-- JSONB containment queries
CREATE INDEX idx_posts_metadata ON posts USING GIN (metadata);
-- Supports: WHERE metadata @> '{"featured": true}'

-- JSONB path operations (jsonb_path_ops is faster but limited)
CREATE INDEX idx_posts_metadata_path ON posts USING GIN (metadata jsonb_path_ops);
-- Supports: WHERE metadata @> '{"category": "tech"}'

-- Array contains
CREATE INDEX idx_posts_tags ON posts USING GIN (tags);
-- Supports: WHERE tags @> ARRAY['postgresql']

-- Full-text search
CREATE INDEX idx_posts_search ON posts USING GIN (search_vector);
-- Supports: WHERE search_vector @@ to_tsquery('postgresql & performance')


-- ==========================================
-- GiST (Generalized Search Tree)
-- For: Geometric, Range, Network types
-- ==========================================

-- IP range queries
CREATE INDEX idx_sessions_ip ON sessions USING GIST (ip_address inet_ops);

-- Geometric queries
CREATE TABLE locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    coordinates POINT NOT NULL
);

CREATE INDEX idx_locations_coords ON locations USING GIST (coordinates);
-- Supports: WHERE coordinates <@ box '((0,0),(100,100))'


-- ==========================================
-- BRIN (Block Range Index)
-- For: Large tables with naturally ordered data
-- ==========================================

-- Very efficient for time-series data
CREATE INDEX idx_events_created_brin ON events USING BRIN (created_at)
    WITH (pages_per_range = 32);
-- Much smaller than B-tree, good for append-only tables


-- ==========================================
-- HASH (Equality only)
-- ==========================================

-- Only for exact equality (=) operations
CREATE INDEX idx_sessions_token ON sessions USING HASH (session_token);
```

### Index Analysis
```sql
-- ==========================================
-- INDEX USAGE ANALYSIS
-- ==========================================

-- Check index usage
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan AS times_used,
    idx_tup_read AS tuples_read,
    idx_tup_fetch AS tuples_fetched,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

-- Find unused indexes
SELECT 
    schemaname || '.' || relname AS table,
    indexrelname AS index,
    pg_size_pretty(pg_relation_size(i.indexrelid)) AS index_size,
    idx_scan AS times_used
FROM pg_stat_user_indexes ui
JOIN pg_index i ON ui.indexrelid = i.indexrelid
WHERE NOT indisunique  -- Exclude unique constraints
AND idx_scan < 50      -- Used less than 50 times
ORDER BY pg_relation_size(i.indexrelid) DESC;

-- Check for missing indexes (sequential scans on large tables)
SELECT 
    schemaname,
    relname,
    seq_scan,
    seq_tup_read,
    idx_scan,
    n_live_tup AS row_count,
    ROUND(seq_tup_read::numeric / NULLIF(seq_scan, 0)) AS avg_seq_read
FROM pg_stat_user_tables
WHERE seq_scan > 1000
AND n_live_tup > 10000
ORDER BY seq_tup_read DESC;
```

---

## 3) Advanced Queries

### Common Table Expressions (CTEs)
```sql
-- ==========================================
-- RECURSIVE CTE (Hierarchical Data)
-- ==========================================

-- Category tree
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    parent_id UUID REFERENCES categories(id),
    sort_order INTEGER NOT NULL DEFAULT 0
);

-- Get full category path
WITH RECURSIVE category_tree AS (
    -- Base case: root categories
    SELECT 
        id, 
        name, 
        parent_id, 
        name AS path,
        1 AS depth,
        ARRAY[id] AS ancestors
    FROM categories
    WHERE parent_id IS NULL
    
    UNION ALL
    
    -- Recursive case: children
    SELECT 
        c.id, 
        c.name, 
        c.parent_id,
        ct.path || ' > ' || c.name,
        ct.depth + 1,
        ct.ancestors || c.id
    FROM categories c
    JOIN category_tree ct ON c.parent_id = ct.id
)
SELECT * FROM category_tree ORDER BY path;


-- ==========================================
-- MATERIALIZED CTE (Data Modification)
-- ==========================================

WITH deactivated AS (
    UPDATE users 
    SET is_active = FALSE, updated_at = NOW()
    WHERE last_login < NOW() - INTERVAL '1 year'
    RETURNING id, email, last_login
),
notification_sent AS (
    INSERT INTO notifications (user_id, type, message)
    SELECT id, 'deactivation', 'Your account has been deactivated'
    FROM deactivated
    RETURNING user_id
)
SELECT COUNT(*) AS users_deactivated FROM deactivated;
```

### Window Functions
```sql
-- ==========================================
-- WINDOW FUNCTIONS
-- ==========================================

-- Running total and ranking
SELECT 
    date,
    amount,
    SUM(amount) OVER (ORDER BY date) AS running_total,
    ROW_NUMBER() OVER (ORDER BY amount DESC) AS rank,
    RANK() OVER (ORDER BY amount DESC) AS rank_with_gaps,
    DENSE_RANK() OVER (ORDER BY amount DESC) AS dense_rank,
    NTILE(4) OVER (ORDER BY amount) AS quartile
FROM orders;

-- Partitioned windows
SELECT 
    customer_id,
    order_date,
    amount,
    -- Per-customer running total
    SUM(amount) OVER (
        PARTITION BY customer_id 
        ORDER BY order_date
    ) AS customer_running_total,
    -- Per-customer rank
    RANK() OVER (
        PARTITION BY customer_id 
        ORDER BY amount DESC
    ) AS customer_rank,
    -- Difference from previous order
    amount - LAG(amount) OVER (
        PARTITION BY customer_id 
        ORDER BY order_date
    ) AS diff_from_previous,
    -- Moving average (last 3 orders)
    AVG(amount) OVER (
        PARTITION BY customer_id 
        ORDER BY order_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3
FROM orders;

-- Percentage of total
SELECT 
    category,
    SUM(amount) AS category_total,
    ROUND(
        SUM(amount) * 100.0 / SUM(SUM(amount)) OVER (), 
        2
    ) AS percentage_of_total
FROM sales
GROUP BY category;
```

### Full-Text Search
```sql
-- ==========================================
-- FULL-TEXT SEARCH
-- ==========================================

-- Search with ranking
SELECT 
    id,
    title,
    ts_rank(search_vector, query) AS rank,
    ts_headline('english', content, query, 
        'MaxWords=35, MinWords=15, MaxFragments=3'
    ) AS snippet
FROM posts, plainto_tsquery('english', 'postgresql performance') AS query
WHERE search_vector @@ query
ORDER BY rank DESC
LIMIT 20;

-- Advanced search with phrase matching
SELECT id, title
FROM posts
WHERE search_vector @@ to_tsquery('english', 
    'postgresql & (performance | optimization) & !deprecated'
);

-- Search with prefix matching
SELECT id, title
FROM posts
WHERE search_vector @@ to_tsquery('english', 'postg:*');

-- Weighted search
SELECT 
    id,
    title,
    ts_rank_cd(
        setweight(to_tsvector('english', title), 'A') ||
        setweight(to_tsvector('english', COALESCE(excerpt, '')), 'B') ||
        setweight(to_tsvector('english', content), 'C'),
        plainto_tsquery('english', 'postgresql')
    ) AS rank
FROM posts
ORDER BY rank DESC;
```

### JSONB Operations
```sql
-- ==========================================
-- JSONB QUERIES
-- ==========================================

-- Containment (uses GIN index)
SELECT * FROM posts
WHERE metadata @> '{"featured": true, "category": "tech"}';

-- Path existence
SELECT * FROM posts
WHERE metadata ? 'author';  -- Has 'author' key

-- Path extraction
SELECT 
    id,
    metadata->>'title' AS title,           -- Text extraction
    metadata->'stats'->>'views' AS views,  -- Nested extraction
    (metadata->'stats'->>'views')::int AS views_int,
    metadata #>> '{author,name}' AS author_name  -- Path extraction
FROM posts;

-- JSONB array operations
SELECT * FROM posts
WHERE metadata->'tags' ? 'postgresql';  -- Array contains

-- Update JSONB
UPDATE posts
SET metadata = metadata || '{"updated": true}'::jsonb
WHERE id = '...';

-- Remove key
UPDATE posts
SET metadata = metadata - 'deprecated_field'
WHERE id = '...';

-- Deep merge
UPDATE posts
SET metadata = jsonb_set(
    metadata,
    '{stats,views}',
    to_jsonb((metadata->'stats'->>'views')::int + 1)
)
WHERE id = '...';


-- ==========================================
-- JSONB AGGREGATION
-- ==========================================

-- Build JSON object from rows
SELECT jsonb_object_agg(key, value) AS config
FROM (
    SELECT 'theme' AS key, 'dark' AS value
    UNION SELECT 'language', 'en'
) AS settings;

-- Array aggregation
SELECT 
    author_id,
    jsonb_agg(
        jsonb_build_object(
            'id', id,
            'title', title,
            'status', status
        ) ORDER BY created_at DESC
    ) AS posts
FROM posts
GROUP BY author_id;
```

---

## 4) Performance Tuning

### Query Analysis
```sql
-- ==========================================
-- EXPLAIN ANALYZE
-- ==========================================

-- Full analysis with timing and buffers
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT p.*, u.name AS author_name
FROM posts p
JOIN users u ON p.author_id = u.id
WHERE p.status = 'published'
ORDER BY p.created_at DESC
LIMIT 20;

-- Look for:
-- - Seq Scan on large tables (need index?)
-- - High actual rows vs estimated rows (need ANALYZE?)
-- - Nested loops with high row counts (consider hash join)
-- - Sort with high cost (need index for ORDER BY?)


-- ==========================================
-- SLOW QUERY ANALYSIS
-- ==========================================

-- Enable pg_stat_statements (in postgresql.conf)
-- shared_preload_libraries = 'pg_stat_statements'

-- Top 10 slowest queries by total time
SELECT 
    ROUND(total_exec_time::numeric, 2) AS total_time_ms,
    calls,
    ROUND(mean_exec_time::numeric, 2) AS mean_time_ms,
    ROUND((100 * total_exec_time / SUM(total_exec_time) OVER ())::numeric, 2) AS percentage,
    query
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;

-- Queries with most I/O
SELECT 
    query,
    calls,
    shared_blks_hit + shared_blks_read AS total_blocks,
    ROUND(
        100.0 * shared_blks_hit / 
        NULLIF(shared_blks_hit + shared_blks_read, 0), 
        2
    ) AS cache_hit_ratio
FROM pg_stat_statements
ORDER BY (shared_blks_hit + shared_blks_read) DESC
LIMIT 10;
```

### Configuration Tuning
```sql
-- ==========================================
-- KEY SETTINGS
-- ==========================================

-- Memory settings (adjust based on available RAM)
-- shared_buffers = 25% of RAM (max ~8GB typically)
-- effective_cache_size = 75% of RAM
-- work_mem = RAM / max_connections / 4 (for sorts, hashes)
-- maintenance_work_mem = 512MB-1GB (for VACUUM, CREATE INDEX)

-- Example for 32GB RAM server:
ALTER SYSTEM SET shared_buffers = '8GB';
ALTER SYSTEM SET effective_cache_size = '24GB';
ALTER SYSTEM SET work_mem = '256MB';
ALTER SYSTEM SET maintenance_work_mem = '1GB';

-- WAL settings
ALTER SYSTEM SET wal_buffers = '64MB';
ALTER SYSTEM SET checkpoint_completion_target = 0.9;

-- Autovacuum tuning for high-write tables
ALTER TABLE high_write_table SET (
    autovacuum_vacuum_scale_factor = 0.05,  -- Vacuum when 5% dead (vs 20% default)
    autovacuum_analyze_scale_factor = 0.025,
    autovacuum_vacuum_cost_limit = 1000
);


-- ==========================================
-- MONITORING QUERIES
-- ==========================================

-- Cache hit ratio (should be >99%)
SELECT 
    SUM(heap_blks_hit) / 
    (SUM(heap_blks_hit) + SUM(heap_blks_read)) * 100 AS cache_hit_ratio
FROM pg_statio_user_tables;

-- Table bloat estimation
SELECT 
    schemaname,
    relname,
    n_live_tup,
    n_dead_tup,
    ROUND(100.0 * n_dead_tup / NULLIF(n_live_tup, 0), 2) AS dead_ratio,
    last_vacuum,
    last_autovacuum
FROM pg_stat_user_tables
WHERE n_dead_tup > 10000
ORDER BY n_dead_tup DESC;

-- Connection usage
SELECT 
    COUNT(*) AS total_connections,
    SUM(CASE WHEN state = 'active' THEN 1 ELSE 0 END) AS active,
    SUM(CASE WHEN state = 'idle' THEN 1 ELSE 0 END) AS idle,
    SUM(CASE WHEN state = 'idle in transaction' THEN 1 ELSE 0 END) AS idle_in_tx
FROM pg_stat_activity
WHERE backend_type = 'client backend';

-- Long-running queries
SELECT 
    pid,
    NOW() - pg_stat_activity.query_start AS duration,
    query,
    state
FROM pg_stat_activity
WHERE state != 'idle'
AND query NOT ILIKE '%pg_stat_activity%'
ORDER BY duration DESC;
```

---

## 5) Security

### Row-Level Security (RLS)
```sql
-- ==========================================
-- ROW-LEVEL SECURITY
-- ==========================================

-- Enable RLS
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Policy: Users can see their own posts + published posts
CREATE POLICY posts_select_policy ON posts
    FOR SELECT
    USING (
        author_id = current_setting('app.user_id')::UUID
        OR status = 'published'
    );

-- Policy: Users can only modify their own posts
CREATE POLICY posts_modify_policy ON posts
    FOR ALL
    USING (author_id = current_setting('app.user_id')::UUID)
    WITH CHECK (author_id = current_setting('app.user_id')::UUID);

-- Policy: Admins can do everything
CREATE POLICY posts_admin_policy ON posts
    FOR ALL
    USING (current_setting('app.user_role') = 'admin');

-- Set context before queries
SET app.user_id = 'user-uuid-here';
SET app.user_role = 'user';


-- ==========================================
-- ROLE-BASED ACCESS CONTROL
-- ==========================================

-- Create roles
CREATE ROLE app_readonly;
CREATE ROLE app_readwrite;
CREATE ROLE app_admin;

-- Grant permissions
GRANT CONNECT ON DATABASE myapp TO app_readonly, app_readwrite, app_admin;
GRANT USAGE ON SCHEMA public TO app_readonly, app_readwrite, app_admin;

-- Readonly: SELECT only
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO app_readonly;

-- Readwrite: SELECT, INSERT, UPDATE, DELETE
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_readwrite;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO app_readwrite;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_readwrite;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE ON SEQUENCES TO app_readwrite;

-- Admin: All privileges
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO app_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO app_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO app_admin;

-- Create application users
CREATE USER app_api WITH PASSWORD 'secure_password';
GRANT app_readwrite TO app_api;

CREATE USER app_reporting WITH PASSWORD 'secure_password';
GRANT app_readonly TO app_reporting;
```

### Data Encryption
```sql
-- ==========================================
-- ENCRYPTION WITH pgcrypto
-- ==========================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Hash passwords (use bcrypt)
INSERT INTO users (name, email, password_hash)
VALUES (
    'John',
    'john@example.com',
    crypt('user_password', gen_salt('bf', 12))  -- bcrypt with cost 12
);

-- Verify password
SELECT id, name FROM users
WHERE email = 'john@example.com'
AND password_hash = crypt('user_password', password_hash);

-- Encrypt sensitive data
CREATE TABLE sensitive_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    encrypted_ssn BYTEA NOT NULL
);

-- Encrypt on insert
INSERT INTO sensitive_data (encrypted_ssn)
VALUES (pgp_sym_encrypt('123-45-6789', 'encryption_key'));

-- Decrypt on select
SELECT pgp_sym_decrypt(encrypted_ssn, 'encryption_key') AS ssn
FROM sensitive_data;
```

---

## 6) Stored Procedures & Triggers

### PL/pgSQL Functions
```sql
-- ==========================================
-- STORED PROCEDURES
-- ==========================================

-- Transaction procedure
CREATE OR REPLACE PROCEDURE transfer_funds(
    p_from_account UUID,
    p_to_account UUID,
    p_amount NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_from_balance NUMERIC;
BEGIN
    -- Check balance
    SELECT balance INTO v_from_balance
    FROM accounts WHERE id = p_from_account FOR UPDATE;
    
    IF v_from_balance < p_amount THEN
        RAISE EXCEPTION 'Insufficient funds';
    END IF;
    
    -- Debit
    UPDATE accounts 
    SET balance = balance - p_amount 
    WHERE id = p_from_account;
    
    -- Credit
    UPDATE accounts 
    SET balance = balance + p_amount 
    WHERE id = p_to_account;
    
    -- Log transaction
    INSERT INTO transactions (from_account, to_account, amount)
    VALUES (p_from_account, p_to_account, p_amount);
    
    COMMIT;
END;
$$;

-- Call procedure
CALL transfer_funds('uuid1', 'uuid2', 100.00);


-- ==========================================
-- AUDIT TRIGGER
-- ==========================================

CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name TEXT NOT NULL,
    record_id UUID NOT NULL,
    action TEXT NOT NULL,
    old_data JSONB,
    new_data JSONB,
    changed_by TEXT,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION audit_trigger_func()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, old_data, new_data, changed_by)
    VALUES (
        TG_TABLE_NAME,
        COALESCE(NEW.id, OLD.id),
        TG_OP,
        CASE WHEN TG_OP IN ('UPDATE', 'DELETE') THEN to_jsonb(OLD) ELSE NULL END,
        CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN to_jsonb(NEW) ELSE NULL END,
        current_setting('app.user_id', TRUE)
    );
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Apply to table
CREATE TRIGGER users_audit
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();
```

---

## 7) Pub/Sub with LISTEN/NOTIFY

```sql
-- ==========================================
-- REAL-TIME NOTIFICATIONS
-- ==========================================

-- Notify trigger
CREATE OR REPLACE FUNCTION notify_changes()
RETURNS TRIGGER AS $$
DECLARE
    payload JSONB;
BEGIN
    payload := jsonb_build_object(
        'table', TG_TABLE_NAME,
        'action', TG_OP,
        'record_id', COALESCE(NEW.id, OLD.id),
        'timestamp', NOW()
    );
    
    PERFORM pg_notify('data_changes', payload::text);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER posts_notify
    AFTER INSERT OR UPDATE OR DELETE ON posts
    FOR EACH ROW EXECUTE FUNCTION notify_changes();

-- In application:
-- LISTEN data_changes;
-- Then handle notifications in your code
```

---

## Best Practices Checklist

### Schema Design
- [ ] Use appropriate data types
- [ ] Add constraints (CHECK, UNIQUE)
- [ ] Use JSONB for flexible data
- [ ] Partition large tables

### Indexing
- [ ] Index foreign keys
- [ ] Use partial indexes
- [ ] GIN for JSONB/arrays
- [ ] Monitor unused indexes

### Performance
- [ ] Analyze slow queries
- [ ] Tune memory settings
- [ ] Monitor bloat
- [ ] Use connection pooling

### Security
- [ ] Row-Level Security
- [ ] Role-based access
- [ ] Encrypt sensitive data
- [ ] Regular backups

---

**References:**
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [PostgreSQL Wiki](https://wiki.postgresql.org/)
- [Use The Index, Luke](https://use-the-index-luke.com/)
- [pgMustard](https://www.pgmustard.com/)

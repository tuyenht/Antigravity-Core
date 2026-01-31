# SQL Query Optimization Expert

> **Version:** 2.0.0 | **Updated:** 2026-02-01  
> **Applies to:** PostgreSQL, MySQL, SQL Server  
> **Priority:** P0 - Load for query optimization

---

You are an expert in optimizing SQL queries and database performance.

## Core Principles

- Fetch only what you need
- Index effectively
- Understand the execution plan
- Avoid N+1 query problems

---

## 1) Query Tuning Basics

### Select Only What You Need
```sql
-- ==========================================
-- SELECT SPECIFIC COLUMNS
-- ==========================================

-- ❌ BAD: Selecting all columns
SELECT * FROM users WHERE status = 'active';

-- ✅ GOOD: Select only needed columns
SELECT id, name, email, created_at 
FROM users 
WHERE status = 'active';

-- Benefits:
-- ✓ Less data transferred
-- ✓ Can use covering indexes
-- ✓ Better cache utilization
-- ✓ Clearer intent


-- ==========================================
-- FILTER EARLY
-- ==========================================

-- ❌ BAD: Filter after aggregation
SELECT user_id, COUNT(*) as order_count
FROM orders
GROUP BY user_id
HAVING COUNT(*) > 10;  -- Filters after computing ALL groups

-- ✅ BETTER: Pre-filter when possible
SELECT user_id, COUNT(*) as order_count
FROM orders
WHERE status = 'completed'  -- Filter early
  AND created_at > '2024-01-01'
GROUP BY user_id
HAVING COUNT(*) > 10;


-- ==========================================
-- LIMIT RESULTS
-- ==========================================

-- ❌ BAD: Fetch all rows to application
SELECT * FROM products ORDER BY created_at DESC;

-- ✅ GOOD: Use LIMIT
SELECT id, name, price 
FROM products 
ORDER BY created_at DESC 
LIMIT 20;

-- ✅ GOOD: With offset pagination (simple but slow for large offsets)
SELECT id, name, price 
FROM products 
ORDER BY created_at DESC 
LIMIT 20 OFFSET 100;

-- ✅ BEST: Keyset pagination (fast for any page)
SELECT id, name, price 
FROM products 
WHERE (created_at, id) < ('2024-01-15 10:30:00', 12345)
ORDER BY created_at DESC, id DESC
LIMIT 20;
```

### JOIN Optimization
```sql
-- ==========================================
-- JOIN TYPES
-- ==========================================

-- INNER JOIN: Only matching rows (most common, usually fastest)
SELECT o.id, o.total, u.name
FROM orders o
INNER JOIN users u ON u.id = o.user_id
WHERE o.status = 'completed';

-- LEFT JOIN: All left rows + matching right (NULL if no match)
SELECT u.id, u.name, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
GROUP BY u.id, u.name;

-- ⚠️ Avoid unnecessary LEFT JOINs
-- If you always expect a match, use INNER JOIN


-- ==========================================
-- JOIN ORDER MATTERS
-- ==========================================

-- ❌ BAD: Joining large table first
SELECT p.name, c.name as category
FROM products p  -- 1M rows
JOIN categories c ON c.id = p.category_id  -- 50 rows
WHERE c.type = 'electronics';

-- ✅ GOOD: Filter small table first (optimizer usually handles this)
SELECT p.name, c.name as category
FROM categories c  -- 50 rows
JOIN products p ON p.category_id = c.id  -- Only matching products
WHERE c.type = 'electronics';

-- Modern optimizers usually reorder, but explicit CTEs help:
WITH electronics_categories AS (
    SELECT id, name FROM categories WHERE type = 'electronics'
)
SELECT p.name, ec.name as category
FROM electronics_categories ec
JOIN products p ON p.category_id = ec.id;


-- ==========================================
-- EXISTS vs IN
-- ==========================================

-- ❌ BAD: IN with large subquery (builds full list)
SELECT * FROM users
WHERE id IN (SELECT user_id FROM orders WHERE total > 1000);

-- ✅ GOOD: EXISTS (stops at first match)
SELECT * FROM users u
WHERE EXISTS (
    SELECT 1 FROM orders o 
    WHERE o.user_id = u.id AND o.total > 1000
);

-- ✅ GOOD: JOIN (often fastest)
SELECT DISTINCT u.*
FROM users u
JOIN orders o ON o.user_id = u.id
WHERE o.total > 1000;


-- ==========================================
-- NOT IN vs NOT EXISTS
-- ==========================================

-- ⚠️ DANGER: NOT IN with NULLs returns no rows!
SELECT * FROM users
WHERE id NOT IN (SELECT user_id FROM orders);  -- If any user_id is NULL, returns nothing!

-- ✅ SAFE: NOT EXISTS (handles NULLs correctly)
SELECT * FROM users u
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.user_id = u.id
);

-- ✅ SAFE: LEFT JOIN with NULL check
SELECT u.*
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE o.id IS NULL;
```

---

## 2) Indexing Strategies

### Index Selection
```sql
-- ==========================================
-- INDEX FOR WHERE CLAUSES
-- ==========================================

-- Query:
SELECT * FROM orders WHERE user_id = 123 AND status = 'pending';

-- Create composite index (order matters!)
CREATE INDEX idx_orders_user_status ON orders (user_id, status);

-- This index supports:
-- ✓ WHERE user_id = ?
-- ✓ WHERE user_id = ? AND status = ?
-- ✗ WHERE status = ?  (index not used - wrong leftmost column)


-- ==========================================
-- INDEX FOR ORDER BY
-- ==========================================

-- Query:
SELECT * FROM posts 
WHERE status = 'published' 
ORDER BY created_at DESC 
LIMIT 20;

-- Index that covers both filter and sort:
CREATE INDEX idx_posts_status_created ON posts (status, created_at DESC);

-- Without index: Sort operation required (expensive)
-- With index: Sorted order from index (fast)


-- ==========================================
-- INDEX FOR JOIN
-- ==========================================

-- Query:
SELECT o.*, u.name 
FROM orders o 
JOIN users u ON u.id = o.user_id;

-- Ensure FK column is indexed:
CREATE INDEX idx_orders_user_id ON orders (user_id);

-- PK on users.id is automatically indexed


-- ==========================================
-- COVERING INDEX (Index-Only Scan)
-- ==========================================

-- Query:
SELECT id, email, name FROM users WHERE email = 'john@example.com';

-- ❌ Regular index (requires table lookup):
CREATE INDEX idx_users_email ON users (email);

-- ✅ Covering index (all columns in index):
CREATE INDEX idx_users_email_covering ON users (email) INCLUDE (name);
-- PostgreSQL: INCLUDE clause
-- MySQL: Include columns at end of index

-- Result: Index-only scan, no table access needed


-- ==========================================
-- PARTIAL INDEX (PostgreSQL)
-- ==========================================

-- Only index rows matching condition:
CREATE INDEX idx_orders_pending ON orders (created_at)
WHERE status = 'pending';

-- Much smaller index, faster for specific queries:
SELECT * FROM orders WHERE status = 'pending' ORDER BY created_at;

-- MySQL alternative: Generated column + index
ALTER TABLE orders ADD COLUMN is_pending TINYINT 
    GENERATED ALWAYS AS (IF(status = 'pending', 1, NULL)) STORED;
CREATE INDEX idx_orders_is_pending ON orders (is_pending, created_at);
```

### Index Analysis
```sql
-- ==========================================
-- FIND MISSING INDEXES
-- ==========================================

-- PostgreSQL: Find sequential scans on large tables
SELECT 
    schemaname, relname,
    seq_scan, seq_tup_read,
    idx_scan, idx_tup_fetch,
    n_live_tup
FROM pg_stat_user_tables
WHERE seq_scan > idx_scan
  AND n_live_tup > 10000
ORDER BY seq_tup_read DESC;

-- MySQL: Enable performance_schema and query
SELECT 
    object_schema, object_name,
    COUNT_STAR as accesses,
    SUM_TIMER_WAIT/1000000000 as total_time_ms
FROM performance_schema.table_io_waits_summary_by_table
ORDER BY COUNT_STAR DESC;


-- ==========================================
-- FIND UNUSED INDEXES
-- ==========================================

-- PostgreSQL
SELECT 
    schemaname, relname, indexrelname,
    idx_scan, idx_tup_read, idx_tup_fetch,
    pg_size_pretty(pg_relation_size(indexrelid)) as size
FROM pg_stat_user_indexes
WHERE idx_scan < 100  -- Rarely used
ORDER BY pg_relation_size(indexrelid) DESC;

-- Consider dropping if:
-- - idx_scan is very low
-- - Index is large
-- - Not a unique constraint
-- - Not required for FK


-- ==========================================
-- INDEX BLOAT (PostgreSQL)
-- ==========================================

-- Reindex if bloated
REINDEX INDEX CONCURRENTLY idx_orders_user_status;

-- Or rebuild entire table
VACUUM FULL orders;  -- Locks table!
-- Better: pg_repack extension
```

---

## 3) Execution Plan Analysis

### Reading EXPLAIN Output
```sql
-- ==========================================
-- POSTGRESQL EXPLAIN
-- ==========================================

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT o.id, o.total, u.name
FROM orders o
JOIN users u ON u.id = o.user_id
WHERE o.status = 'completed'
  AND o.created_at > '2024-01-01'
ORDER BY o.created_at DESC
LIMIT 20;

-- Output interpretation:
/*
Limit  (cost=0.86..123.45 rows=20 width=48) (actual time=0.123..0.456 rows=20 loops=1)
  ->  Nested Loop  (cost=0.86..12345.67 rows=5000 width=48) (actual time=0.120..0.450 rows=20 loops=1)
        ->  Index Scan using idx_orders_status_created on orders o  ← GOOD: Using index
              (cost=0.43..1234.56 rows=5000 width=40) (actual time=0.050..0.200 rows=20 loops=1)
              Index Cond: ((status = 'completed'::text) AND (created_at > '2024-01-01'))
              Buffers: shared hit=15  ← All from cache, good!
        ->  Index Scan using users_pkey on users u  ← GOOD: PK lookup
              (cost=0.43..0.50 rows=1 width=12) (actual time=0.010..0.010 rows=1 loops=20)
              Index Cond: (id = o.user_id)
              Buffers: shared hit=60
Planning Time: 0.234 ms
Execution Time: 0.567 ms
*/

-- Key things to check:
-- ✓ cost: Lower is better
-- ✓ rows: Estimated vs actual (should be close)
-- ✓ Buffers: shared hit (cache) vs read (disk)
-- ✓ Scan type: Index Scan > Seq Scan (usually)


-- ==========================================
-- MYSQL EXPLAIN
-- ==========================================

EXPLAIN ANALYZE
SELECT o.id, o.total, u.name
FROM orders o
JOIN users u ON u.id = o.user_id
WHERE o.status = 'completed';

-- Key columns:
-- type: 
--   ALL = Full table scan (bad)
--   index = Full index scan
--   range = Index range scan (good)
--   ref = Index lookup (good)
--   eq_ref = Unique index lookup (best)
--   const = Single row (best)

-- rows: Estimated rows examined
-- filtered: Percentage after WHERE
-- Extra: 
--   Using index = Covering index (good)
--   Using filesort = Sort needed (consider index)
--   Using temporary = Temp table (expensive)


-- ==========================================
-- IDENTIFY PROBLEMS
-- ==========================================

-- ❌ PROBLEM: Sequential Scan on large table
/*
Seq Scan on orders  (cost=0.00..123456.00 rows=1000000)
  Filter: (status = 'completed')
*/
-- FIX: Add index on status column
CREATE INDEX idx_orders_status ON orders (status);


-- ❌ PROBLEM: Sort operation (no index for ORDER BY)
/*
Sort  (cost=12345.67..12456.78 rows=50000)
  Sort Key: created_at DESC
*/
-- FIX: Add index that supports the sort
CREATE INDEX idx_orders_created ON orders (created_at DESC);


-- ❌ PROBLEM: High actual rows vs estimated
/*
Index Scan (estimated rows=100) (actual rows=50000)
*/
-- FIX: Update statistics
ANALYZE orders;  -- PostgreSQL
ANALYZE TABLE orders;  -- MySQL


-- ❌ PROBLEM: Nested Loop with high loops
/*
Nested Loop (loops=10000)
  -> Index Scan (loops=10000)  ← Called 10000 times!
*/
-- FIX: Consider Hash Join or optimize the outer query
```

---

## 4) Common Anti-Patterns & Fixes

### N+1 Query Problem
```sql
-- ==========================================
-- N+1 PROBLEM
-- ==========================================

-- ❌ BAD: Application code doing N+1
/*
users = SELECT * FROM users LIMIT 100;  -- 1 query
for each user:
    orders = SELECT * FROM orders WHERE user_id = user.id;  -- 100 queries!
*/
-- Total: 101 queries!

-- ✅ GOOD: Single query with JOIN
SELECT u.id, u.name, o.id as order_id, o.total
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
ORDER BY u.id, o.created_at DESC;

-- ✅ GOOD: Two queries (batch loading)
SELECT * FROM users WHERE id IN (1, 2, 3, ..., 100);
SELECT * FROM orders WHERE user_id IN (1, 2, 3, ..., 100);

-- ✅ ORM: Use eager loading
-- Laravel: User::with('orders')->get()
-- Rails: User.includes(:orders).all
-- Django: User.objects.prefetch_related('orders')


-- ==========================================
-- BATCH OPERATIONS
-- ==========================================

-- ❌ BAD: Individual inserts
INSERT INTO logs (user_id, action) VALUES (1, 'login');
INSERT INTO logs (user_id, action) VALUES (2, 'login');
INSERT INTO logs (user_id, action) VALUES (3, 'login');
-- 3 round trips, 3 transactions

-- ✅ GOOD: Batch insert
INSERT INTO logs (user_id, action) VALUES 
    (1, 'login'),
    (2, 'login'),
    (3, 'login');
-- 1 round trip, 1 transaction

-- ✅ GOOD: Batch update
UPDATE products 
SET price = price * 1.1
WHERE category_id = 5;
-- Instead of updating one by one

-- ✅ GOOD: Bulk upsert (PostgreSQL)
INSERT INTO inventory (product_id, quantity)
VALUES (1, 10), (2, 20), (3, 30)
ON CONFLICT (product_id) 
DO UPDATE SET quantity = inventory.quantity + EXCLUDED.quantity;
```

### Function on Indexed Column
```sql
-- ==========================================
-- AVOID FUNCTIONS ON WHERE COLUMNS
-- ==========================================

-- ❌ BAD: Function prevents index use
SELECT * FROM users WHERE YEAR(created_at) = 2024;
SELECT * FROM users WHERE LOWER(email) = 'john@example.com';
SELECT * FROM users WHERE created_at + INTERVAL '7 days' > NOW();

-- ✅ GOOD: Rewrite to use index
SELECT * FROM users 
WHERE created_at >= '2024-01-01' AND created_at < '2025-01-01';

-- ✅ GOOD: Use functional index (if needed)
CREATE INDEX idx_users_email_lower ON users (LOWER(email));
SELECT * FROM users WHERE LOWER(email) = 'john@example.com';

-- ✅ GOOD: Move function to right side
SELECT * FROM users WHERE created_at > NOW() - INTERVAL '7 days';


-- ==========================================
-- AVOID IMPLICIT TYPE CONVERSION
-- ==========================================

-- ❌ BAD: String compared to integer (implicit conversion)
-- Column: order_id VARCHAR(20)
SELECT * FROM orders WHERE order_id = 12345;  -- Converts every row!

-- ✅ GOOD: Match types
SELECT * FROM orders WHERE order_id = '12345';


-- ==========================================
-- AVOID LEADING WILDCARD
-- ==========================================

-- ❌ BAD: Leading wildcard (full scan)
SELECT * FROM products WHERE name LIKE '%phone%';

-- ✅ BETTER: Trailing wildcard only (uses index)
SELECT * FROM products WHERE name LIKE 'phone%';

-- ✅ BEST: Full-text search for substring matching
-- PostgreSQL:
SELECT * FROM products 
WHERE to_tsvector('english', name) @@ to_tsquery('phone');

-- MySQL:
SELECT * FROM products 
WHERE MATCH(name) AGAINST('phone' IN NATURAL LANGUAGE MODE);
```

### OR Conditions
```sql
-- ==========================================
-- OR CAN DEFEAT INDEXES
-- ==========================================

-- ❌ BAD: OR on different columns (often full scan)
SELECT * FROM orders 
WHERE user_id = 123 OR status = 'pending';

-- ✅ GOOD: Use UNION for different index paths
SELECT * FROM orders WHERE user_id = 123
UNION
SELECT * FROM orders WHERE status = 'pending';

-- ✅ GOOD: If same column, rewrite as IN
-- ❌ BAD:
SELECT * FROM orders WHERE status = 'pending' OR status = 'processing';
-- ✅ GOOD:
SELECT * FROM orders WHERE status IN ('pending', 'processing');


-- ==========================================
-- NULL HANDLING
-- ==========================================

-- ❌ BAD: = NULL doesn't work
SELECT * FROM orders WHERE shipped_at = NULL;  -- Returns nothing!

-- ✅ GOOD: Use IS NULL
SELECT * FROM orders WHERE shipped_at IS NULL;

-- ❌ BAD: NOT IN with potential NULLs
SELECT * FROM users WHERE id NOT IN (SELECT manager_id FROM departments);
-- If any manager_id is NULL, returns no rows!

-- ✅ GOOD: Exclude NULLs or use NOT EXISTS
SELECT * FROM users 
WHERE id NOT IN (
    SELECT manager_id FROM departments WHERE manager_id IS NOT NULL
);
```

---

## 5) Pagination Optimization

### Keyset Pagination
```sql
-- ==========================================
-- OFFSET PAGINATION (Slow for large offsets)
-- ==========================================

-- Page 1 (fast)
SELECT * FROM posts ORDER BY created_at DESC LIMIT 20;

-- Page 1000 (slow - must scan 20000 rows!)
SELECT * FROM posts ORDER BY created_at DESC LIMIT 20 OFFSET 19980;


-- ==========================================
-- KEYSET PAGINATION (Fast for any page)
-- ==========================================

-- First page
SELECT id, title, created_at
FROM posts
WHERE status = 'published'
ORDER BY created_at DESC, id DESC
LIMIT 20;

-- Next page: Use last row's values as cursor
SELECT id, title, created_at
FROM posts
WHERE status = 'published'
  AND (created_at, id) < ('2024-01-15 10:30:00', 12345)  -- Last row values
ORDER BY created_at DESC, id DESC
LIMIT 20;

-- Supporting index
CREATE INDEX idx_posts_published_cursor ON posts (status, created_at DESC, id DESC)
WHERE status = 'published';  -- Partial index

-- Benefits:
-- ✓ Consistent performance regardless of page
-- ✓ Works with real-time data (no missing/duplicate rows)
-- ✓ Uses index efficiently


-- ==========================================
-- DEFERRED JOIN (For large offsets when keyset not possible)
-- ==========================================

-- ❌ SLOW: Regular offset pagination
SELECT p.*, u.name as author_name
FROM posts p
JOIN users u ON u.id = p.author_id
WHERE p.status = 'published'
ORDER BY p.created_at DESC
LIMIT 20 OFFSET 10000;

-- ✅ FASTER: Deferred join
SELECT p.*, u.name as author_name
FROM posts p
JOIN users u ON u.id = p.author_id
WHERE p.id IN (
    -- Subquery only fetches IDs (faster)
    SELECT id FROM posts 
    WHERE status = 'published'
    ORDER BY created_at DESC
    LIMIT 20 OFFSET 10000
)
ORDER BY p.created_at DESC;
```

---

## 6) Aggregation & Grouping

### Efficient Aggregation
```sql
-- ==========================================
-- COUNT OPTIMIZATION
-- ==========================================

-- ❌ SLOW: COUNT(*) on large table (full scan)
SELECT COUNT(*) FROM orders;

-- ✅ FASTER: Approximate count (PostgreSQL)
SELECT reltuples::bigint as estimate
FROM pg_class WHERE relname = 'orders';

-- ✅ FASTER: Use covering index for filtered count
CREATE INDEX idx_orders_status ON orders (status);
SELECT COUNT(*) FROM orders WHERE status = 'pending';

-- ✅ BEST: Maintain count in separate table/cache
CREATE TABLE order_stats (
    id INT PRIMARY KEY DEFAULT 1,
    pending_count INT NOT NULL DEFAULT 0,
    completed_count INT NOT NULL DEFAULT 0
);


-- ==========================================
-- DISTINCT OPTIMIZATION
-- ==========================================

-- ❌ SLOW: Large DISTINCT
SELECT DISTINCT category_id FROM products;

-- ✅ FASTER: GROUP BY (same result, often faster)
SELECT category_id FROM products GROUP BY category_id;

-- ✅ FASTER: Loose index scan (if supported)
-- PostgreSQL: Recursive CTE trick
WITH RECURSIVE categories AS (
    SELECT MIN(category_id) as category_id FROM products
    UNION ALL
    SELECT (SELECT MIN(category_id) FROM products WHERE category_id > c.category_id)
    FROM categories c WHERE c.category_id IS NOT NULL
)
SELECT category_id FROM categories WHERE category_id IS NOT NULL;


-- ==========================================
-- AGGREGATE WITH FILTER
-- ==========================================

-- ✅ Conditional aggregation (single scan)
SELECT 
    COUNT(*) as total_orders,
    COUNT(*) FILTER (WHERE status = 'completed') as completed_orders,
    COUNT(*) FILTER (WHERE status = 'pending') as pending_orders,
    SUM(total) FILTER (WHERE status = 'completed') as completed_revenue
FROM orders
WHERE created_at > '2024-01-01';

-- MySQL equivalent
SELECT 
    COUNT(*) as total_orders,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_orders,
    SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_orders,
    SUM(CASE WHEN status = 'completed' THEN total ELSE 0 END) as completed_revenue
FROM orders
WHERE created_at > '2024-01-01';
```

---

## 7) Query Caching & Materialization

### Materialized Views
```sql
-- ==========================================
-- MATERIALIZED VIEW FOR EXPENSIVE QUERIES
-- ==========================================

-- Create materialized view
CREATE MATERIALIZED VIEW mv_product_stats AS
SELECT 
    p.id as product_id,
    p.name,
    p.category_id,
    COUNT(oi.id) as order_count,
    SUM(oi.quantity) as units_sold,
    SUM(oi.line_total) as total_revenue,
    AVG(oi.unit_price) as avg_price
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.id
LEFT JOIN orders o ON o.id = oi.order_id AND o.status = 'completed'
GROUP BY p.id, p.name, p.category_id;

-- Create indexes on materialized view
CREATE UNIQUE INDEX idx_mv_product_stats_id ON mv_product_stats (product_id);
CREATE INDEX idx_mv_product_stats_category ON mv_product_stats (category_id);

-- Query the view (fast!)
SELECT * FROM mv_product_stats WHERE category_id = 5 ORDER BY total_revenue DESC;

-- Refresh (run periodically)
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_product_stats;

-- Automatic refresh with pg_cron
SELECT cron.schedule('refresh-product-stats', '0 */1 * * *',  -- Every hour
    'REFRESH MATERIALIZED VIEW CONCURRENTLY mv_product_stats');


-- ==========================================
-- QUERY RESULT CACHING (Application Layer)
-- ==========================================

-- Cache expensive queries in Redis/Memcached
-- Key: query_hash or semantic key
-- Value: JSON result
-- TTL: Based on data freshness requirements

-- Example cache key patterns:
-- "dashboard:stats:2024-01-15"
-- "product:123:reviews:page:1"
-- "search:electronics:price_asc:page:1"
```

---

## Best Practices Checklist

### Query Writing
- [ ] Select only needed columns
- [ ] Filter early with WHERE
- [ ] Use appropriate JOIN types
- [ ] Avoid functions on indexed columns
- [ ] Use EXISTS over IN for subqueries

### Indexing
- [ ] Index WHERE, JOIN, ORDER BY columns
- [ ] Use composite indexes (leftmost rule)
- [ ] Consider covering indexes
- [ ] Remove unused indexes
- [ ] Update statistics regularly

### Execution Plans
- [ ] Run EXPLAIN on slow queries
- [ ] Check for sequential scans
- [ ] Compare estimated vs actual rows
- [ ] Look for expensive sort/hash operations

### Anti-Patterns
- [ ] Avoid N+1 queries
- [ ] Batch inserts/updates
- [ ] No leading wildcards in LIKE
- [ ] Handle NULLs correctly
- [ ] Avoid OR across different columns

### Pagination
- [ ] Use keyset pagination
- [ ] Deferred join for large offsets
- [ ] Cache count results

---

**References:**
- [Use The Index, Luke](https://use-the-index-luke.com/)
- [PostgreSQL EXPLAIN](https://www.postgresql.org/docs/current/using-explain.html)
- [MySQL Query Optimization](https://dev.mysql.com/doc/refman/8.0/en/optimization.html)

# MySQL/MariaDB Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **MySQL:** 8.0+  
> **MariaDB:** 10.6+  
> **Priority:** P0 - Load for MySQL/MariaDB projects

---

You are an expert in MySQL and MariaDB database management.

## Core Principles

- Choose the right storage engine (InnoDB)
- Optimize for read-heavy workloads
- Manage replication effectively
- Use strict SQL mode

---

## 1) Schema Design

### Data Types Best Practices
```sql
-- ==========================================
-- DATA TYPES SELECTION
-- ==========================================

-- ✅ GOOD: Optimal data types
CREATE TABLE users (
    -- BIGINT UNSIGNED for auto-increment PKs
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    
    -- Use UUID as BINARY(16) for better performance
    uuid BINARY(16) NOT NULL UNIQUE,
    
    -- VARCHAR for variable-length strings
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    
    -- ENUM for limited options (stored as integers)
    status ENUM('active', 'inactive', 'pending') NOT NULL DEFAULT 'pending',
    role ENUM('admin', 'user', 'moderator') NOT NULL DEFAULT 'user',
    
    -- TINYINT for small numbers/booleans
    is_verified TINYINT(1) NOT NULL DEFAULT 0,
    login_attempts TINYINT UNSIGNED NOT NULL DEFAULT 0,
    
    -- DECIMAL for exact precision (money)
    account_balance DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    
    -- DATETIME vs TIMESTAMP
    -- TIMESTAMP: auto-converts to UTC, limited to 2038
    -- DATETIME: no conversion, full range
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- For future dates beyond 2038
    subscription_ends_at DATETIME NULL,
    
    -- JSON for semi-structured data (MySQL 8.0+)
    metadata JSON NOT NULL DEFAULT (JSON_OBJECT()),
    
    -- TEXT for long content (stored separately)
    bio TEXT,
    
    -- IP address as VARBINARY or INT
    last_login_ip VARBINARY(16),
    
    -- Constraints
    CONSTRAINT chk_positive_balance CHECK (account_balance >= 0),
    CONSTRAINT chk_login_attempts CHECK (login_attempts <= 10)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- Unique constraint (case-insensitive with collation)
CREATE UNIQUE INDEX idx_users_email ON users (email);

-- UUID helper functions
DELIMITER //

CREATE FUNCTION uuid_to_bin(uuid CHAR(36))
RETURNS BINARY(16) DETERMINISTIC
BEGIN
    RETURN UNHEX(REPLACE(uuid, '-', ''));
END //

CREATE FUNCTION bin_to_uuid(b BINARY(16))
RETURNS CHAR(36) DETERMINISTIC
BEGIN
    RETURN LOWER(CONCAT(
        HEX(SUBSTR(b, 1, 4)), '-',
        HEX(SUBSTR(b, 5, 2)), '-',
        HEX(SUBSTR(b, 7, 2)), '-',
        HEX(SUBSTR(b, 9, 2)), '-',
        HEX(SUBSTR(b, 11, 6))
    ));
END //

DELIMITER ;

-- Insert with UUID
INSERT INTO users (uuid, name, email)
VALUES (uuid_to_bin(UUID()), 'John Doe', 'john@example.com');


-- ==========================================
-- COMPLETE TABLE WITH RELATIONSHIPS
-- ==========================================

CREATE TABLE posts (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    uuid BINARY(16) NOT NULL UNIQUE,
    
    -- Foreign key
    author_id BIGINT UNSIGNED NOT NULL,
    
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    content LONGTEXT NOT NULL,
    excerpt TEXT,
    
    status ENUM('draft', 'published', 'archived') NOT NULL DEFAULT 'draft',
    
    -- Full-text search columns
    -- (InnoDB supports FULLTEXT in MySQL 5.6+)
    
    -- JSON for flexible metadata
    metadata JSON NOT NULL DEFAULT (JSON_OBJECT()),
    
    view_count INT UNSIGNED NOT NULL DEFAULT 0,
    published_at DATETIME NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Soft delete
    deleted_at DATETIME NULL,
    
    -- Foreign key constraint
    CONSTRAINT fk_posts_author 
        FOREIGN KEY (author_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    -- Unique slug per author (when not deleted)
    CONSTRAINT uq_posts_author_slug UNIQUE (author_id, slug)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- Full-text index
CREATE FULLTEXT INDEX idx_posts_fulltext ON posts (title, content);
```

### Table Partitioning
```sql
-- ==========================================
-- RANGE PARTITIONING (Time-based)
-- ==========================================

CREATE TABLE events (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    event_type VARCHAR(50) NOT NULL,
    payload JSON NOT NULL,
    created_at DATETIME NOT NULL,
    PRIMARY KEY (id, created_at)  -- Include partition key
) ENGINE=InnoDB
PARTITION BY RANGE (YEAR(created_at) * 100 + MONTH(created_at)) (
    PARTITION p202401 VALUES LESS THAN (202402),
    PARTITION p202402 VALUES LESS THAN (202403),
    PARTITION p202403 VALUES LESS THAN (202404),
    PARTITION p202404 VALUES LESS THAN (202405),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Add new partition
ALTER TABLE events REORGANIZE PARTITION p_future INTO (
    PARTITION p202405 VALUES LESS THAN (202406),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Drop old partition (fast deletion)
ALTER TABLE events DROP PARTITION p202401;


-- ==========================================
-- LIST PARTITIONING
-- ==========================================

CREATE TABLE orders (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    customer_id BIGINT UNSIGNED NOT NULL,
    region VARCHAR(20) NOT NULL,
    total DECIMAL(15, 2) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id, region)
) ENGINE=InnoDB
PARTITION BY LIST COLUMNS (region) (
    PARTITION p_americas VALUES IN ('US', 'CA', 'MX', 'BR'),
    PARTITION p_europe VALUES IN ('UK', 'DE', 'FR', 'ES', 'IT'),
    PARTITION p_asia VALUES IN ('JP', 'CN', 'KR', 'IN', 'SG'),
    PARTITION p_other VALUES IN ('AU', 'NZ', 'OTHER')
);


-- ==========================================
-- HASH PARTITIONING (Even distribution)
-- ==========================================

CREATE TABLE sessions (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    session_token CHAR(64) NOT NULL,
    expires_at DATETIME NOT NULL,
    PRIMARY KEY (id, user_id)
) ENGINE=InnoDB
PARTITION BY HASH(user_id)
PARTITIONS 8;
```

---

## 2) Indexing Strategies

### Index Types
```sql
-- ==========================================
-- B-TREE INDEXES (Default)
-- ==========================================

-- Single column index
CREATE INDEX idx_users_email ON users (email);

-- Composite index (order matters!)
-- Good for: WHERE status = 'x' AND created_at > 'y'
-- Also covers: WHERE status = 'x' (leftmost prefix)
CREATE INDEX idx_posts_status_created ON posts (status, created_at DESC);

-- Covering index (includes all needed columns)
-- Avoids table lookups for covered queries
CREATE INDEX idx_posts_listing ON posts (
    status, 
    published_at DESC
) INCLUDE (title, excerpt, author_id);  -- MySQL 8.0.13+

-- Partial index simulation with generated column
ALTER TABLE posts ADD COLUMN is_published TINYINT(1) 
    GENERATED ALWAYS AS (IF(status = 'published' AND deleted_at IS NULL, 1, NULL)) STORED;
CREATE INDEX idx_posts_published ON posts (is_published, published_at DESC);


-- ==========================================
-- FULLTEXT INDEXES
-- ==========================================

-- Create fulltext index
CREATE FULLTEXT INDEX idx_posts_search ON posts (title, content);

-- Natural language search
SELECT id, title, 
    MATCH(title, content) AGAINST('mysql performance' IN NATURAL LANGUAGE MODE) AS relevance
FROM posts
WHERE MATCH(title, content) AGAINST('mysql performance' IN NATURAL LANGUAGE MODE)
ORDER BY relevance DESC
LIMIT 20;

-- Boolean mode search
SELECT id, title
FROM posts
WHERE MATCH(title, content) AGAINST('+mysql +performance -deprecated' IN BOOLEAN MODE);

-- Query expansion
SELECT id, title
FROM posts
WHERE MATCH(title, content) AGAINST('database' WITH QUERY EXPANSION)
LIMIT 20;


-- ==========================================
-- SPATIAL INDEXES (For geographic data)
-- ==========================================

CREATE TABLE locations (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    coordinates POINT NOT NULL SRID 4326,
    SPATIAL INDEX idx_locations_coords (coordinates)
) ENGINE=InnoDB;

-- Insert with coordinates
INSERT INTO locations (name, coordinates)
VALUES ('Office', ST_GeomFromText('POINT(-73.935242 40.730610)', 4326));

-- Find nearby locations
SELECT id, name, 
    ST_Distance_Sphere(coordinates, ST_GeomFromText('POINT(-73.935242 40.730610)', 4326)) AS distance_meters
FROM locations
WHERE ST_Distance_Sphere(coordinates, ST_GeomFromText('POINT(-73.935242 40.730610)', 4326)) < 5000
ORDER BY distance_meters;


-- ==========================================
-- INVISIBLE INDEXES (MySQL 8.0+)
-- ==========================================

-- Make index invisible (for testing removal impact)
ALTER TABLE posts ALTER INDEX idx_posts_status_created INVISIBLE;

-- Check query still works without index
EXPLAIN SELECT * FROM posts WHERE status = 'published';

-- Make visible again or drop
ALTER TABLE posts ALTER INDEX idx_posts_status_created VISIBLE;
-- Or: DROP INDEX idx_posts_status_created ON posts;
```

### Index Analysis
```sql
-- ==========================================
-- INDEX USAGE ANALYSIS
-- ==========================================

-- Check index usage (MySQL 8.0+)
SELECT 
    object_schema AS `schema`,
    object_name AS `table`,
    index_name,
    count_star AS accesses,
    count_read,
    count_write
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE object_schema = 'your_database'
AND index_name IS NOT NULL
ORDER BY count_star DESC;

-- Find unused indexes
SELECT 
    s.table_schema,
    s.table_name,
    s.index_name,
    s.column_name,
    t.table_rows
FROM information_schema.statistics s
LEFT JOIN performance_schema.table_io_waits_summary_by_index_usage io
    ON s.table_schema = io.object_schema
    AND s.table_name = io.object_name
    AND s.index_name = io.index_name
JOIN information_schema.tables t
    ON s.table_schema = t.table_schema
    AND s.table_name = t.table_name
WHERE s.table_schema = 'your_database'
AND s.index_name != 'PRIMARY'
AND (io.count_star IS NULL OR io.count_star = 0)
AND t.table_rows > 1000;

-- Index cardinality
SHOW INDEX FROM posts;

-- Analyze table to update statistics
ANALYZE TABLE posts;
```

---

## 3) Query Optimization

### EXPLAIN Analysis
```sql
-- ==========================================
-- EXPLAIN FORMAT
-- ==========================================

-- Basic explain
EXPLAIN SELECT p.*, u.name AS author_name
FROM posts p
JOIN users u ON p.author_id = u.id
WHERE p.status = 'published'
ORDER BY p.created_at DESC
LIMIT 20;

-- Detailed explain (MySQL 8.0+)
EXPLAIN ANALYZE
SELECT p.*, u.name AS author_name
FROM posts p
JOIN users u ON p.author_id = u.id
WHERE p.status = 'published'
ORDER BY p.created_at DESC
LIMIT 20;

-- JSON format for detailed info
EXPLAIN FORMAT=JSON
SELECT * FROM posts WHERE status = 'published';

-- Tree format (MySQL 8.0.18+)
EXPLAIN FORMAT=TREE
SELECT * FROM posts WHERE status = 'published';


-- ==========================================
-- COMMON OPTIMIZATION PATTERNS
-- ==========================================

-- ❌ BAD: Using function on indexed column
SELECT * FROM users WHERE YEAR(created_at) = 2024;

-- ✅ GOOD: Range query (uses index)
SELECT * FROM users 
WHERE created_at >= '2024-01-01' 
AND created_at < '2025-01-01';


-- ❌ BAD: LIKE with leading wildcard
SELECT * FROM users WHERE email LIKE '%@gmail.com';

-- ✅ GOOD: Use generated column or fulltext
ALTER TABLE users ADD COLUMN email_domain VARCHAR(100) 
    GENERATED ALWAYS AS (SUBSTRING_INDEX(email, '@', -1)) STORED;
CREATE INDEX idx_users_email_domain ON users (email_domain);
SELECT * FROM users WHERE email_domain = 'gmail.com';


-- ❌ BAD: ORDER BY with different direction
SELECT * FROM posts 
WHERE author_id = 1 
ORDER BY status ASC, created_at DESC;  -- Can't use single index efficiently

-- ✅ GOOD: Match index direction
CREATE INDEX idx_posts_author_sort ON posts (author_id, status ASC, created_at DESC);


-- ❌ BAD: SELECT * when you don't need all columns
SELECT * FROM posts WHERE author_id = 1;

-- ✅ GOOD: Select only needed columns (enables covering index)
SELECT id, title, status, created_at 
FROM posts 
WHERE author_id = 1;


-- ==========================================
-- PAGINATION OPTIMIZATION
-- ==========================================

-- ❌ BAD: Large OFFSET (scans all skipped rows)
SELECT * FROM posts 
WHERE status = 'published' 
ORDER BY created_at DESC 
LIMIT 20 OFFSET 10000;

-- ✅ GOOD: Keyset pagination (seek method)
SELECT * FROM posts 
WHERE status = 'published' 
AND (created_at, id) < ('2024-01-15 10:30:00', 12345)
ORDER BY created_at DESC, id DESC
LIMIT 20;

-- ✅ GOOD: Deferred join for large offsets
SELECT p.* 
FROM posts p
JOIN (
    SELECT id FROM posts 
    WHERE status = 'published' 
    ORDER BY created_at DESC 
    LIMIT 20 OFFSET 10000
) AS t ON p.id = t.id
ORDER BY p.created_at DESC;
```

### JSON Operations
```sql
-- ==========================================
-- JSON QUERIES (MySQL 8.0+)
-- ==========================================

-- Extract JSON values
SELECT 
    id,
    JSON_EXTRACT(metadata, '$.author') AS author,
    metadata->>'$.category' AS category,  -- Unquoted extraction
    JSON_EXTRACT(metadata, '$.tags[0]') AS first_tag
FROM posts;

-- JSON containment search
SELECT * FROM posts
WHERE JSON_CONTAINS(metadata, '"tech"', '$.tags');

-- JSON search (returns path)
SELECT * FROM posts
WHERE JSON_SEARCH(metadata, 'one', 'tech', NULL, '$.tags[*]') IS NOT NULL;

-- Update JSON
UPDATE posts
SET metadata = JSON_SET(
    metadata,
    '$.views', COALESCE(metadata->>'$.views', 0) + 1,
    '$.last_viewed', NOW()
)
WHERE id = 1;

-- JSON aggregation
SELECT 
    author_id,
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'id', id,
            'title', title,
            'status', status
        )
    ) AS posts
FROM posts
GROUP BY author_id;

-- Create generated column for JSON value (indexable)
ALTER TABLE posts ADD COLUMN category VARCHAR(50) 
    GENERATED ALWAYS AS (metadata->>'$.category') STORED;
CREATE INDEX idx_posts_category ON posts (category);
```

---

## 4) Performance Tuning

### Server Configuration
```sql
-- ==========================================
-- KEY CONFIGURATION SETTINGS
-- ==========================================

-- Check current values
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';
SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool%';

-- InnoDB Buffer Pool (50-70% of RAM for dedicated server)
SET GLOBAL innodb_buffer_pool_size = 8589934592;  -- 8GB

-- Buffer pool instances (1 per GB, max 64)
-- innodb_buffer_pool_instances = 8  -- Set in my.cnf

-- Log settings
-- innodb_log_file_size = 1G
-- innodb_log_buffer_size = 64M

-- Thread settings
-- innodb_read_io_threads = 8
-- innodb_write_io_threads = 8

-- Flush settings
-- innodb_flush_log_at_trx_commit = 1  -- Safest (ACID)
-- innodb_flush_log_at_trx_commit = 2  -- Better performance, less safe
-- innodb_flush_method = O_DIRECT      -- Linux recommended

-- Query optimization
-- join_buffer_size = 256K
-- sort_buffer_size = 256K
-- read_buffer_size = 128K
-- read_rnd_buffer_size = 256K


-- ==========================================
-- MONITORING QUERIES
-- ==========================================

-- Buffer pool hit ratio (should be >99%)
SELECT 
    (1 - (Innodb_buffer_pool_reads / Innodb_buffer_pool_read_requests)) * 100 
    AS buffer_pool_hit_ratio
FROM (
    SELECT 
        VARIABLE_VALUE AS Innodb_buffer_pool_reads 
    FROM performance_schema.global_status 
    WHERE VARIABLE_NAME = 'Innodb_buffer_pool_reads'
) AS reads,
(
    SELECT 
        VARIABLE_VALUE AS Innodb_buffer_pool_read_requests 
    FROM performance_schema.global_status 
    WHERE VARIABLE_NAME = 'Innodb_buffer_pool_read_requests'
) AS requests;

-- Table size and row count
SELECT 
    table_name,
    table_rows,
    ROUND(data_length / 1024 / 1024, 2) AS data_mb,
    ROUND(index_length / 1024 / 1024, 2) AS index_mb,
    ROUND((data_length + index_length) / 1024 / 1024, 2) AS total_mb
FROM information_schema.tables
WHERE table_schema = 'your_database'
ORDER BY (data_length + index_length) DESC;

-- Connection status
SHOW STATUS LIKE 'Threads%';
SHOW STATUS LIKE 'Connections';
SHOW PROCESSLIST;

-- InnoDB status
SHOW ENGINE INNODB STATUS\G
```

### Slow Query Log
```sql
-- ==========================================
-- SLOW QUERY ANALYSIS
-- ==========================================

-- Enable slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 1;  -- Queries > 1 second
SET GLOBAL log_queries_not_using_indexes = 'ON';

-- View slow query log location
SHOW VARIABLES LIKE 'slow_query_log_file';

-- Performance Schema queries (MySQL 8.0+)
-- Top 10 slowest queries
SELECT 
    DIGEST_TEXT,
    COUNT_STAR AS exec_count,
    ROUND(SUM_TIMER_WAIT/1000000000000, 4) AS total_time_sec,
    ROUND(AVG_TIMER_WAIT/1000000000000, 4) AS avg_time_sec,
    ROUND(MAX_TIMER_WAIT/1000000000000, 4) AS max_time_sec,
    SUM_ROWS_EXAMINED AS rows_examined,
    SUM_ROWS_SENT AS rows_sent
FROM performance_schema.events_statements_summary_by_digest
ORDER BY SUM_TIMER_WAIT DESC
LIMIT 10;

-- Queries with full table scans
SELECT 
    DIGEST_TEXT,
    COUNT_STAR,
    SUM_NO_INDEX_USED,
    SUM_NO_GOOD_INDEX_USED
FROM performance_schema.events_statements_summary_by_digest
WHERE SUM_NO_INDEX_USED > 0 OR SUM_NO_GOOD_INDEX_USED > 0
ORDER BY SUM_NO_INDEX_USED DESC
LIMIT 20;
```

---

## 5) Replication

### Master-Slave Replication
```sql
-- ==========================================
-- MASTER CONFIGURATION
-- ==========================================

-- my.cnf on master
-- [mysqld]
-- server-id = 1
-- log_bin = mysql-bin
-- binlog_format = ROW
-- gtid_mode = ON
-- enforce_gtid_consistency = ON
-- binlog_expire_logs_seconds = 604800  -- 7 days

-- Create replication user
CREATE USER 'repl_user'@'%' IDENTIFIED BY 'secure_password';
GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%';
FLUSH PRIVILEGES;

-- Check master status
SHOW MASTER STATUS;


-- ==========================================
-- SLAVE CONFIGURATION
-- ==========================================

-- my.cnf on slave
-- [mysqld]
-- server-id = 2
-- relay_log = relay-bin
-- read_only = ON
-- gtid_mode = ON
-- enforce_gtid_consistency = ON

-- Configure slave (MySQL 8.0+)
CHANGE REPLICATION SOURCE TO
    SOURCE_HOST = 'master-host',
    SOURCE_USER = 'repl_user',
    SOURCE_PASSWORD = 'secure_password',
    SOURCE_AUTO_POSITION = 1;  -- Use GTID

-- Start replication
START REPLICA;

-- Check slave status
SHOW REPLICA STATUS\G


-- ==========================================
-- MONITORING REPLICATION
-- ==========================================

-- Check replication lag
SELECT 
    CHANNEL_NAME,
    LAST_QUEUED_TRANSACTION,
    LAST_APPLIED_TRANSACTION,
    APPLYING_TRANSACTION,
    LAST_APPLIED_TRANSACTION_START_APPLY_TIMESTAMP,
    LAST_APPLIED_TRANSACTION_END_APPLY_TIMESTAMP
FROM performance_schema.replication_applier_status_by_worker;

-- Simple lag check
SHOW REPLICA STATUS\G
-- Look for: Seconds_Behind_Source

-- Skip problematic transaction (use carefully!)
-- SET GLOBAL SQL_SLAVE_SKIP_COUNTER = 1;
-- START REPLICA;
```

### ProxySQL Load Balancing
```sql
-- ==========================================
-- PROXYSQL CONFIGURATION
-- ==========================================

-- Add MySQL servers
INSERT INTO mysql_servers (hostgroup_id, hostname, port, weight)
VALUES 
    (10, 'master-host', 3306, 1),    -- Write group
    (20, 'slave1-host', 3306, 1),    -- Read group
    (20, 'slave2-host', 3306, 1);    -- Read group

-- Add replication hostgroup
INSERT INTO mysql_replication_hostgroups (writer_hostgroup, reader_hostgroup)
VALUES (10, 20);

-- Add query rules (read/write split)
INSERT INTO mysql_query_rules (rule_id, active, match_pattern, destination_hostgroup)
VALUES
    (1, 1, '^SELECT .* FOR UPDATE', 10),   -- Writes
    (2, 1, '^SELECT', 20),                  -- Reads
    (3, 1, '.*', 10);                       -- Default to master

-- Load configuration
LOAD MYSQL SERVERS TO RUNTIME;
LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;
SAVE MYSQL QUERY RULES TO DISK;
```

---

## 6) Security

### User Management
```sql
-- ==========================================
-- ROLE-BASED ACCESS CONTROL (MySQL 8.0+)
-- ==========================================

-- Create roles
CREATE ROLE 'app_readonly', 'app_readwrite', 'app_admin';

-- Grant privileges to roles
GRANT SELECT ON your_database.* TO 'app_readonly';
GRANT SELECT, INSERT, UPDATE, DELETE ON your_database.* TO 'app_readwrite';
GRANT ALL PRIVILEGES ON your_database.* TO 'app_admin';

-- Create users and assign roles
CREATE USER 'api_user'@'%' IDENTIFIED BY 'secure_password';
GRANT 'app_readwrite' TO 'api_user'@'%';
SET DEFAULT ROLE 'app_readwrite' TO 'api_user'@'%';

CREATE USER 'reporting_user'@'%' IDENTIFIED BY 'secure_password';
GRANT 'app_readonly' TO 'reporting_user'@'%';
SET DEFAULT ROLE 'app_readonly' TO 'reporting_user'@'%';

-- Column-level permissions
GRANT SELECT (id, name, email) ON your_database.users TO 'limited_user'@'%';

-- Row-level security simulation with views
CREATE VIEW public_posts AS
SELECT * FROM posts WHERE status = 'published' AND deleted_at IS NULL;
GRANT SELECT ON your_database.public_posts TO 'public_user'@'%';


-- ==========================================
-- AUTHENTICATION & ENCRYPTION
-- ==========================================

-- Password policy (MySQL 8.0+)
SET GLOBAL validate_password.policy = 'STRONG';
SET GLOBAL validate_password.length = 12;

-- SSL connections
-- my.cnf:
-- [mysqld]
-- require_secure_transport = ON
-- ssl_ca = /path/to/ca.pem
-- ssl_cert = /path/to/server-cert.pem
-- ssl_key = /path/to/server-key.pem

-- Create user requiring SSL
CREATE USER 'secure_user'@'%' 
    IDENTIFIED BY 'secure_password'
    REQUIRE SSL;

-- Verify SSL
SHOW STATUS LIKE 'Ssl_cipher';
```

---

## 7) Stored Procedures & Triggers

### Stored Procedures
```sql
-- ==========================================
-- STORED PROCEDURES
-- ==========================================

DELIMITER //

-- Procedure with transaction
CREATE PROCEDURE transfer_funds(
    IN p_from_account BIGINT,
    IN p_to_account BIGINT,
    IN p_amount DECIMAL(15,2),
    OUT p_success TINYINT
)
BEGIN
    DECLARE v_from_balance DECIMAL(15,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_success = 0;
    END;
    
    START TRANSACTION;
    
    -- Lock and check balance
    SELECT balance INTO v_from_balance
    FROM accounts 
    WHERE id = p_from_account 
    FOR UPDATE;
    
    IF v_from_balance < p_amount THEN
        ROLLBACK;
        SET p_success = 0;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient funds';
    END IF;
    
    -- Debit
    UPDATE accounts SET balance = balance - p_amount WHERE id = p_from_account;
    
    -- Credit
    UPDATE accounts SET balance = balance + p_amount WHERE id = p_to_account;
    
    -- Log transaction
    INSERT INTO transactions (from_account, to_account, amount, created_at)
    VALUES (p_from_account, p_to_account, p_amount, NOW());
    
    COMMIT;
    SET p_success = 1;
END //

DELIMITER ;

-- Call procedure
CALL transfer_funds(1, 2, 100.00, @success);
SELECT @success;


-- ==========================================
-- AUDIT TRIGGER
-- ==========================================

DELIMITER //

CREATE TRIGGER users_audit_insert
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, new_data, created_at)
    VALUES ('users', NEW.id, 'INSERT', JSON_OBJECT(
        'name', NEW.name,
        'email', NEW.email,
        'status', NEW.status
    ), NOW());
END //

CREATE TRIGGER users_audit_update
AFTER UPDATE ON users
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, old_data, new_data, created_at)
    VALUES ('users', NEW.id, 'UPDATE',
        JSON_OBJECT('name', OLD.name, 'email', OLD.email, 'status', OLD.status),
        JSON_OBJECT('name', NEW.name, 'email', NEW.email, 'status', NEW.status),
        NOW()
    );
END //

CREATE TRIGGER users_audit_delete
AFTER DELETE ON users
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, old_data, created_at)
    VALUES ('users', OLD.id, 'DELETE', JSON_OBJECT(
        'name', OLD.name,
        'email', OLD.email,
        'status', OLD.status
    ), NOW());
END //

DELIMITER ;
```

---

## 8) Backup & Recovery

```sql
-- ==========================================
-- BACKUP STRATEGIES
-- ==========================================

-- Logical backup (mysqldump)
-- mysqldump -u root -p --single-transaction --routines --triggers \
--     --databases your_database > backup.sql

-- With compression
-- mysqldump -u root -p --single-transaction your_database | gzip > backup.sql.gz

-- Specific tables
-- mysqldump -u root -p your_database users posts > tables_backup.sql

-- Physical backup with Percona XtraBackup
-- xtrabackup --backup --target-dir=/backups/full

-- Point-in-time recovery setup
-- Enable binary logging in my.cnf:
-- log_bin = mysql-bin
-- binlog_format = ROW
-- expire_logs_days = 7


-- ==========================================
-- RESTORE
-- ==========================================

-- Restore from mysqldump
-- mysql -u root -p your_database < backup.sql

-- Restore from compressed
-- gunzip < backup.sql.gz | mysql -u root -p your_database

-- Point-in-time recovery
-- mysqlbinlog --start-datetime="2024-01-15 10:00:00" \
--     --stop-datetime="2024-01-15 12:00:00" \
--     mysql-bin.000001 | mysql -u root -p
```

---

## Best Practices Checklist

### Schema Design
- [ ] Use appropriate data types
- [ ] InnoDB engine for all tables
- [ ] utf8mb4 character set
- [ ] Proper foreign keys

### Indexing
- [ ] Index foreign keys
- [ ] Composite indexes (left-to-right)
- [ ] Covering indexes when possible
- [ ] Regular index analysis

### Performance
- [ ] Appropriate buffer pool size
- [ ] Enable slow query log
- [ ] Use EXPLAIN ANALYZE
- [ ] Keyset pagination

### Security
- [ ] Role-based access control
- [ ] SSL connections
- [ ] Regular password rotation
- [ ] Minimal privileges

### Operations
- [ ] Regular backups
- [ ] Monitor replication lag
- [ ] Test restoration
- [ ] Update statistics

---

**References:**
- [MySQL Documentation](https://dev.mysql.com/doc/)
- [MariaDB Documentation](https://mariadb.com/kb/en/)
- [Percona Blog](https://www.percona.com/blog/)
- [High Performance MySQL](https://www.oreilly.com/library/view/high-performance-mysql/9781492080503/)

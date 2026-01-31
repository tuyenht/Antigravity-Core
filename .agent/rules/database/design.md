# Database Design & Normalization Expert

> **Version:** 2.0.0 | **Updated:** 2026-02-01  
> **Applies to:** All relational databases  
> **Priority:** P0 - Load for database design

---

You are an expert in database design, data modeling, and normalization.

## Core Principles

- Design for data integrity first
- Normalize to reduce redundancy
- Denormalize for performance (consciously)
- Document the schema

---

## 1) Normalization Forms

### First Normal Form (1NF)
```sql
-- ==========================================
-- 1NF: Atomic values, unique rows
-- ==========================================

-- ❌ VIOLATES 1NF: Non-atomic values
CREATE TABLE orders_bad (
    id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    products VARCHAR(500),        -- "Laptop, Mouse, Keyboard" (not atomic!)
    phone_numbers VARCHAR(200)    -- "555-1234, 555-5678" (not atomic!)
);

-- ✅ 1NF COMPLIANT: Atomic values, separate tables
CREATE TABLE customers (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE customer_phones (
    id INT PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(id),
    phone_number VARCHAR(20) NOT NULL,
    phone_type VARCHAR(20) NOT NULL  -- 'home', 'work', 'mobile'
);

CREATE TABLE orders (
    id INT PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(id),
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    id INT PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(id),
    product_id INT NOT NULL REFERENCES products(id),
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL
);

-- 1NF Rules:
-- ✓ Each column contains atomic (indivisible) values
-- ✓ Each row is unique (has a primary key)
-- ✓ No repeating groups (arrays stored as separate rows)
```

### Second Normal Form (2NF)
```sql
-- ==========================================
-- 2NF: No partial dependencies
-- ==========================================

-- ❌ VIOLATES 2NF: Partial dependency on composite key
CREATE TABLE order_items_bad (
    order_id INT,
    product_id INT,
    quantity INT,
    product_name VARCHAR(100),     -- Depends only on product_id!
    product_price DECIMAL(10,2),   -- Depends only on product_id!
    PRIMARY KEY (order_id, product_id)
);

-- ✅ 2NF COMPLIANT: Remove partial dependencies
CREATE TABLE products (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category_id INT REFERENCES categories(id)
);

CREATE TABLE order_items (
    id INT PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(id),
    product_id INT NOT NULL REFERENCES products(id),
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL  -- Price at time of order (intentional denorm)
);

-- 2NF Rules:
-- ✓ Must be in 1NF
-- ✓ No partial dependencies (non-key attributes depend on ENTIRE primary key)
-- ✓ Only applies to composite keys
```

### Third Normal Form (3NF)
```sql
-- ==========================================
-- 3NF: No transitive dependencies
-- ==========================================

-- ❌ VIOLATES 3NF: Transitive dependency
CREATE TABLE employees_bad (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    department_id INT,
    department_name VARCHAR(100),  -- Depends on department_id, not id!
    manager_name VARCHAR(100)      -- Depends on department_id, not id!
);

-- ✅ 3NF COMPLIANT: Remove transitive dependencies
CREATE TABLE departments (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    manager_id INT REFERENCES employees(id)
);

CREATE TABLE employees (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    department_id INT REFERENCES departments(id),
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2) NOT NULL
);

-- 3NF Rules:
-- ✓ Must be in 2NF
-- ✓ No transitive dependencies (non-key → non-key)
-- ✓ Every non-key attribute depends ONLY on the primary key
```

### Boyce-Codd Normal Form (BCNF)
```sql
-- ==========================================
-- BCNF: Every determinant is a candidate key
-- ==========================================

-- ❌ VIOLATES BCNF: Non-key determinant
-- Scenario: Students take courses, each course has one teacher per student group
CREATE TABLE enrollments_bad (
    student_id INT,
    course_id INT,
    teacher_id INT,
    PRIMARY KEY (student_id, course_id)
    -- Problem: teacher_id → course_id (teacher teaches only one course)
    -- But teacher_id is not a candidate key
);

-- ✅ BCNF COMPLIANT: Decompose the relation
CREATE TABLE courses (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE teachers (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    course_id INT NOT NULL REFERENCES courses(id)  -- Teacher teaches one course
);

CREATE TABLE student_teachers (
    student_id INT REFERENCES students(id),
    teacher_id INT REFERENCES teachers(id),
    PRIMARY KEY (student_id, teacher_id)
);

-- BCNF Rules:
-- ✓ Must be in 3NF
-- ✓ For every functional dependency X → Y, X must be a superkey
```

### Fourth Normal Form (4NF)
```sql
-- ==========================================
-- 4NF: No multi-valued dependencies
-- ==========================================

-- ❌ VIOLATES 4NF: Multi-valued dependencies
-- An employee can have multiple skills AND multiple languages (independent)
CREATE TABLE employee_attributes_bad (
    employee_id INT,
    skill VARCHAR(50),
    language VARCHAR(50),
    PRIMARY KEY (employee_id, skill, language)
    -- Problem: skill and language are independent multi-valued facts
);

-- For employee with 3 skills and 2 languages = 6 rows (cartesian product)
-- This creates redundancy and update anomalies

-- ✅ 4NF COMPLIANT: Separate independent multi-valued facts
CREATE TABLE employee_skills (
    employee_id INT REFERENCES employees(id),
    skill VARCHAR(50),
    PRIMARY KEY (employee_id, skill)
);

CREATE TABLE employee_languages (
    employee_id INT REFERENCES employees(id),
    language VARCHAR(50),
    proficiency VARCHAR(20),  -- 'basic', 'intermediate', 'fluent'
    PRIMARY KEY (employee_id, language)
);

-- 4NF Rules:
-- ✓ Must be in BCNF
-- ✓ No multi-valued dependencies (independent facts in separate tables)
```

---

## 2) Entity-Relationship Modeling

### Identifying Entities and Relationships
```sql
-- ==========================================
-- CORE ENTITIES
-- ==========================================

-- Entity: A distinguishable thing in the domain
-- Examples: User, Product, Order, Category

CREATE TABLE users (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    
    -- Natural attributes
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    
    -- Status attributes
    status VARCHAR(20) NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'inactive', 'suspended')),
    email_verified_at TIMESTAMP,
    
    -- Audit attributes
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP  -- Soft delete
);

CREATE TABLE products (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    sku VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(12, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'draft'
        CHECK (status IN ('draft', 'active', 'archived')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ==========================================
-- RELATIONSHIP TYPES
-- ==========================================

-- 1:1 Relationship (User has one Profile)
CREATE TABLE user_profiles (
    user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    avatar_url VARCHAR(500),
    bio TEXT,
    location VARCHAR(100),
    website VARCHAR(255),
    date_of_birth DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 1:N Relationship (User has many Orders)
CREATE TABLE orders (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    order_number VARCHAR(50) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
    subtotal DECIMAL(12, 2) NOT NULL,
    tax DECIMAL(12, 2) NOT NULL DEFAULT 0,
    shipping DECIMAL(12, 2) NOT NULL DEFAULT 0,
    total DECIMAL(12, 2) NOT NULL,
    
    -- Denormalized shipping address (snapshot at order time)
    shipping_name VARCHAR(100) NOT NULL,
    shipping_address TEXT NOT NULL,
    shipping_city VARCHAR(100) NOT NULL,
    shipping_postal_code VARCHAR(20) NOT NULL,
    shipping_country VARCHAR(50) NOT NULL,
    
    ordered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    shipped_at TIMESTAMP,
    delivered_at TIMESTAMP,
    
    INDEX idx_orders_user (user_id),
    INDEX idx_orders_status (status, ordered_at)
);

-- M:N Relationship (Orders have many Products, Products in many Orders)
CREATE TABLE order_items (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES products(id),
    
    -- Snapshot at order time (intentional denormalization)
    product_name VARCHAR(255) NOT NULL,
    product_sku VARCHAR(50) NOT NULL,
    unit_price DECIMAL(12, 2) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    line_total DECIMAL(12, 2) NOT NULL,
    
    UNIQUE (order_id, product_id)
);

-- M:N with junction table (Products have many Tags)
CREATE TABLE tags (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(50) NOT NULL UNIQUE,
    slug VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE product_tags (
    product_id BIGINT REFERENCES products(id) ON DELETE CASCADE,
    tag_id BIGINT REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, tag_id)
);
```

### Inheritance Patterns
```sql
-- ==========================================
-- SINGLE TABLE INHERITANCE (STI)
-- ==========================================

-- All types in one table with discriminator column
CREATE TABLE notifications (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    type VARCHAR(50) NOT NULL,  -- Discriminator
    
    -- Common attributes
    read_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Type-specific data in JSON
    data JSONB NOT NULL DEFAULT '{}',
    
    -- Or: type-specific nullable columns
    -- email_subject VARCHAR(255),      -- EmailNotification
    -- push_title VARCHAR(100),         -- PushNotification
    -- sms_message VARCHAR(160),        -- SMSNotification
    
    INDEX idx_notifications_user_unread (user_id, read_at)
);

-- Pros: Simple queries, no JOINs needed
-- Cons: Many NULL columns, less strict typing


-- ==========================================
-- CLASS TABLE INHERITANCE (CTI)
-- ==========================================

-- Base table with common attributes
CREATE TABLE vehicles (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    type VARCHAR(20) NOT NULL,
    brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INT NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Subtype tables with specific attributes
CREATE TABLE cars (
    vehicle_id BIGINT PRIMARY KEY REFERENCES vehicles(id) ON DELETE CASCADE,
    doors INT NOT NULL,
    fuel_type VARCHAR(20) NOT NULL,
    transmission VARCHAR(20) NOT NULL
);

CREATE TABLE motorcycles (
    vehicle_id BIGINT PRIMARY KEY REFERENCES vehicles(id) ON DELETE CASCADE,
    engine_cc INT NOT NULL,
    type VARCHAR(20) NOT NULL  -- 'sport', 'cruiser', 'touring'
);

CREATE TABLE trucks (
    vehicle_id BIGINT PRIMARY KEY REFERENCES vehicles(id) ON DELETE CASCADE,
    payload_capacity INT NOT NULL,
    bed_length DECIMAL(4, 2) NOT NULL
);

-- Pros: Clean separation, proper typing
-- Cons: Requires JOINs for full data


-- ==========================================
-- CONCRETE TABLE INHERITANCE
-- ==========================================

-- Each type has its own complete table (no shared base)
CREATE TABLE credit_card_payments (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    order_id BIGINT NOT NULL REFERENCES orders(id),
    amount DECIMAL(12, 2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    
    -- Credit card specific
    card_last_four VARCHAR(4) NOT NULL,
    card_brand VARCHAR(20) NOT NULL,
    authorization_code VARCHAR(50),
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE paypal_payments (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    order_id BIGINT NOT NULL REFERENCES orders(id),
    amount DECIMAL(12, 2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    
    -- PayPal specific
    paypal_transaction_id VARCHAR(100) NOT NULL,
    payer_email VARCHAR(255),
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Pros: No NULLs, simple per-type queries
-- Cons: Duplicate columns, hard to query across types
```

---

## 3) Keys and Constraints

### Key Types
```sql
-- ==========================================
-- PRIMARY KEYS
-- ==========================================

-- Auto-increment (traditional)
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT  -- MySQL
    -- id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY  -- PostgreSQL
);

-- UUID (distributed-friendly)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid()  -- PostgreSQL
    -- id BINARY(16) PRIMARY KEY  -- MySQL (use uuid_to_bin())
);

-- Composite key
CREATE TABLE order_items (
    order_id BIGINT,
    product_id BIGINT,
    quantity INT NOT NULL,
    PRIMARY KEY (order_id, product_id)
);

-- Natural key (use with caution)
CREATE TABLE countries (
    code CHAR(2) PRIMARY KEY,  -- ISO 3166-1 alpha-2
    name VARCHAR(100) NOT NULL
);


-- ==========================================
-- FOREIGN KEYS
-- ==========================================

-- Basic foreign key
ALTER TABLE orders
ADD CONSTRAINT fk_orders_user
FOREIGN KEY (user_id) REFERENCES users(id);

-- With referential actions
ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_order
FOREIGN KEY (order_id) REFERENCES orders(id)
ON DELETE CASCADE      -- Delete items when order deleted
ON UPDATE CASCADE;     -- Update if order_id changes

-- Self-referencing (hierarchies)
CREATE TABLE categories (
    id BIGINT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    parent_id BIGINT REFERENCES categories(id) ON DELETE SET NULL
);

-- ON DELETE options:
-- CASCADE: Delete child rows
-- SET NULL: Set FK to NULL (column must be nullable)
-- SET DEFAULT: Set to default value
-- RESTRICT: Prevent parent deletion if children exist
-- NO ACTION: Same as RESTRICT but checked at transaction end


-- ==========================================
-- OTHER CONSTRAINTS
-- ==========================================

-- Unique constraint
ALTER TABLE users
ADD CONSTRAINT uq_users_email UNIQUE (email);

-- Composite unique
ALTER TABLE subscriptions
ADD CONSTRAINT uq_subscriptions_user_plan 
UNIQUE (user_id, plan_id, status)
WHERE status = 'active';  -- Partial unique (PostgreSQL)

-- Check constraint
ALTER TABLE products
ADD CONSTRAINT chk_products_price CHECK (price >= 0);

ALTER TABLE orders
ADD CONSTRAINT chk_orders_dates 
CHECK (shipped_at IS NULL OR shipped_at >= ordered_at);

-- Not null (column constraint)
ALTER TABLE products
ALTER COLUMN name SET NOT NULL;

-- Default value
ALTER TABLE users
ALTER COLUMN status SET DEFAULT 'active';
```

---

## 4) Denormalization Strategies

### Intentional Denormalization
```sql
-- ==========================================
-- REDUNDANT COLUMNS (Read optimization)
-- ==========================================

-- Store computed/aggregated values
CREATE TABLE posts (
    id BIGINT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    author_id BIGINT NOT NULL REFERENCES users(id),
    
    -- Denormalized for fast display
    author_name VARCHAR(100) NOT NULL,
    author_avatar_url VARCHAR(500),
    
    -- Aggregated counts (updated via triggers/application)
    comment_count INT NOT NULL DEFAULT 0,
    like_count INT NOT NULL DEFAULT 0,
    view_count INT NOT NULL DEFAULT 0,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Trigger to maintain counts
CREATE OR REPLACE FUNCTION update_post_comment_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE posts SET comment_count = comment_count + 1 
        WHERE id = NEW.post_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE posts SET comment_count = comment_count - 1 
        WHERE id = OLD.post_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_comments_count
AFTER INSERT OR DELETE ON comments
FOR EACH ROW EXECUTE FUNCTION update_post_comment_count();


-- ==========================================
-- MATERIALIZED VIEWS
-- ==========================================

-- Pre-computed analytics
CREATE MATERIALIZED VIEW product_sales_summary AS
SELECT 
    p.id AS product_id,
    p.name AS product_name,
    p.category_id,
    c.name AS category_name,
    COUNT(DISTINCT oi.order_id) AS order_count,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.line_total) AS total_revenue,
    AVG(oi.unit_price) AS avg_price,
    MAX(o.ordered_at) AS last_order_date
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.id
LEFT JOIN orders o ON o.id = oi.order_id AND o.status = 'delivered'
LEFT JOIN categories c ON c.id = p.category_id
GROUP BY p.id, p.name, p.category_id, c.name;

-- Refresh periodically
REFRESH MATERIALIZED VIEW CONCURRENTLY product_sales_summary;

-- Index for fast queries
CREATE UNIQUE INDEX idx_product_sales_summary_product 
ON product_sales_summary (product_id);


-- ==========================================
-- JSON COLUMNS (Flexibility)
-- ==========================================

-- Flexible attributes without schema changes
CREATE TABLE products (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    base_price DECIMAL(12, 2) NOT NULL,
    
    -- Flexible attributes in JSON
    attributes JSONB NOT NULL DEFAULT '{}',
    -- { "color": "red", "size": "XL", "weight_kg": 2.5 }
    
    -- Variant information
    variants JSONB NOT NULL DEFAULT '[]',
    -- [{ "sku": "...", "color": "red", "price": 29.99, "stock": 10 }]
    
    -- SEO metadata
    seo_metadata JSONB NOT NULL DEFAULT '{}'
    -- { "title": "...", "description": "...", "keywords": [...] }
);

-- Index JSON fields
CREATE INDEX idx_products_attributes ON products USING GIN (attributes);

-- Query JSON
SELECT * FROM products 
WHERE attributes @> '{"color": "red"}';

SELECT * FROM products
WHERE (attributes->>'weight_kg')::numeric > 1.0;
```

### Caching Tables
```sql
-- ==========================================
-- SUMMARY/CACHE TABLES
-- ==========================================

-- Daily sales summary (updated periodically)
CREATE TABLE daily_sales_summary (
    date DATE NOT NULL,
    product_id BIGINT NOT NULL REFERENCES products(id),
    category_id BIGINT REFERENCES categories(id),
    
    order_count INT NOT NULL DEFAULT 0,
    units_sold INT NOT NULL DEFAULT 0,
    gross_revenue DECIMAL(12, 2) NOT NULL DEFAULT 0,
    net_revenue DECIMAL(12, 2) NOT NULL DEFAULT 0,
    avg_order_value DECIMAL(12, 2),
    
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (date, product_id)
);

-- Populate/update job
INSERT INTO daily_sales_summary (date, product_id, category_id, order_count, units_sold, gross_revenue)
SELECT 
    DATE(o.ordered_at) AS date,
    oi.product_id,
    p.category_id,
    COUNT(DISTINCT o.id),
    SUM(oi.quantity),
    SUM(oi.line_total)
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE o.ordered_at >= CURRENT_DATE - INTERVAL '1 day'
AND o.status = 'delivered'
GROUP BY DATE(o.ordered_at), oi.product_id, p.category_id
ON CONFLICT (date, product_id) 
DO UPDATE SET
    order_count = EXCLUDED.order_count,
    units_sold = EXCLUDED.units_sold,
    gross_revenue = EXCLUDED.gross_revenue,
    updated_at = CURRENT_TIMESTAMP;
```

---

## 5) Naming Conventions

### Consistent Naming
```sql
-- ==========================================
-- TABLE NAMING
-- ==========================================

-- Option 1: Plural (recommended)
users, products, orders, categories

-- Option 2: Singular
user, product, order, category

-- Junction tables: entity1_entity2 (alphabetical or logical)
product_tags, user_roles, order_items

-- Audit/log tables
audit_logs, user_activity_logs


-- ==========================================
-- COLUMN NAMING
-- ==========================================

-- snake_case (recommended for SQL)
user_id, created_at, first_name, is_active

-- ID columns
id              -- Primary key
user_id         -- Foreign key
external_id     -- External system reference

-- Boolean columns
is_active, is_verified, has_permission, can_edit

-- Date/time columns
created_at, updated_at, deleted_at    -- Timestamps
birth_date, start_date, end_date      -- Dates only
expires_at, verified_at               -- Event timestamps

-- Count/aggregate columns
view_count, comment_count, total_amount

-- Status columns
status, order_status, payment_status


-- ==========================================
-- INDEX NAMING
-- ==========================================

-- idx_table_column(s)
CREATE INDEX idx_users_email ON users (email);
CREATE INDEX idx_orders_user_status ON orders (user_id, status);

-- Unique indexes
CREATE UNIQUE INDEX uq_users_email ON users (email);

-- Partial indexes
CREATE INDEX idx_orders_pending ON orders (created_at) WHERE status = 'pending';


-- ==========================================
-- CONSTRAINT NAMING
-- ==========================================

-- Primary key: pk_table
CONSTRAINT pk_users PRIMARY KEY (id)

-- Foreign key: fk_table_referenced
CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(id)

-- Unique: uq_table_column(s)
CONSTRAINT uq_users_email UNIQUE (email)

-- Check: chk_table_description
CONSTRAINT chk_products_positive_price CHECK (price >= 0)
CONSTRAINT chk_orders_valid_dates CHECK (shipped_at >= ordered_at)
```

---

## 6) Schema Evolution

### Migration Patterns
```sql
-- ==========================================
-- ADDING COLUMNS
-- ==========================================

-- Add nullable column (safe)
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- Add with default (locks table briefly)
ALTER TABLE users ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'active';

-- Add column, backfill, then add constraint
ALTER TABLE users ADD COLUMN verified_at TIMESTAMP;
UPDATE users SET verified_at = created_at WHERE email_verified = true;
ALTER TABLE users DROP COLUMN email_verified;


-- ==========================================
-- RENAMING (Backward compatible)
-- ==========================================

-- 1. Add new column
ALTER TABLE users ADD COLUMN full_name VARCHAR(100);

-- 2. Backfill data
UPDATE users SET full_name = name;

-- 3. Update application to write both, read from new
-- 4. Deploy application changes

-- 5. Make new column not null (if needed)
ALTER TABLE users ALTER COLUMN full_name SET NOT NULL;

-- 6. Drop old column (after verification)
ALTER TABLE users DROP COLUMN name;


-- ==========================================
-- CHANGING DATA TYPES
-- ==========================================

-- Safe: Widening (INT to BIGINT)
ALTER TABLE orders ALTER COLUMN total TYPE DECIMAL(15, 2);

-- Risky: Narrowing (needs validation)
-- First validate data fits
SELECT * FROM products WHERE LENGTH(sku) > 20;

-- Then alter
ALTER TABLE products ALTER COLUMN sku TYPE VARCHAR(20);


-- ==========================================
-- SPLITTING TABLES
-- ==========================================

-- 1. Create new table
CREATE TABLE user_preferences (
    user_id BIGINT PRIMARY KEY REFERENCES users(id),
    theme VARCHAR(20) DEFAULT 'light',
    language VARCHAR(10) DEFAULT 'en',
    notifications_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Migrate data
INSERT INTO user_preferences (user_id, theme, language, notifications_enabled)
SELECT id, theme, language, notifications_enabled FROM users;

-- 3. Update application to use new table
-- 4. Drop old columns
ALTER TABLE users 
    DROP COLUMN theme,
    DROP COLUMN language,
    DROP COLUMN notifications_enabled;
```

---

## 7) Privacy & GDPR Considerations

```sql
-- ==========================================
-- DATA CLASSIFICATION
-- ==========================================

-- Mark PII columns with comments
COMMENT ON COLUMN users.email IS 'PII: Email address - requires encryption';
COMMENT ON COLUMN users.phone IS 'PII: Phone number - requires consent';
COMMENT ON COLUMN user_profiles.date_of_birth IS 'PII: Birth date - age calculation only';


-- ==========================================
-- DATA RETENTION
-- ==========================================

-- Soft delete for audit trail
CREATE TABLE users (
    id BIGINT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    
    -- Soft delete
    deleted_at TIMESTAMP,
    deletion_requested_at TIMESTAMP,
    deletion_reason VARCHAR(255)
);

-- Hard delete after retention period
DELETE FROM users 
WHERE deleted_at < CURRENT_DATE - INTERVAL '30 days';

-- Anonymization instead of deletion
UPDATE users SET
    email = CONCAT('deleted_', id, '@anonymized.local'),
    name = 'Deleted User',
    phone = NULL,
    address = NULL
WHERE id = 123;


-- ==========================================
-- ACCESS CONTROL
-- ==========================================

-- Row-level security (PostgreSQL)
ALTER TABLE customer_data ENABLE ROW LEVEL SECURITY;

CREATE POLICY customer_isolation ON customer_data
    USING (tenant_id = current_setting('app.tenant_id')::BIGINT);

-- Audit logging
CREATE TABLE data_access_log (
    id BIGINT PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    record_id BIGINT NOT NULL,
    action VARCHAR(20) NOT NULL,
    user_id BIGINT NOT NULL,
    accessed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_address INET,
    user_agent TEXT
);


-- ==========================================
-- ENCRYPTION
-- ==========================================

-- Column-level encryption (application-side recommended)
CREATE TABLE sensitive_data (
    id BIGINT PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    
    -- Encrypted at application layer
    encrypted_ssn BYTEA,
    encrypted_credit_card BYTEA,
    
    -- Encryption metadata
    encryption_key_id VARCHAR(50),
    encrypted_at TIMESTAMP
);
```

---

## Best Practices Checklist

### Design
- [ ] Identify all entities
- [ ] Define relationships (1:1, 1:N, M:N)
- [ ] Normalize to 3NF minimum
- [ ] Document denormalization reasons

### Keys
- [ ] Every table has primary key
- [ ] Foreign keys with proper actions
- [ ] Unique constraints for business keys
- [ ] Check constraints for validation

### Naming
- [ ] Consistent case (snake_case)
- [ ] Consistent plural/singular
- [ ] Descriptive index names
- [ ] Constraint naming convention

### Evolution
- [ ] Plan for migrations
- [ ] Backward compatible changes
- [ ] Document schema versions
- [ ] Test migrations on copy

### Privacy
- [ ] Classify PII columns
- [ ] Implement soft delete
- [ ] Plan data retention
- [ ] Audit access to PII

---

**References:**
- [Database Design (Wikipedia)](https://en.wikipedia.org/wiki/Database_design)
- [Normalization Forms](https://en.wikipedia.org/wiki/Database_normalization)
- [GDPR for Developers](https://gdpr.eu/developers/)

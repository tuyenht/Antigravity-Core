# Redis & Caching Strategies Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **Redis:** 7.0+  
> **ioredis:** 5.x+  
> **Priority:** P0 - Load for Redis/caching projects

---

You are an expert in Redis and application caching strategies.

## Core Principles

- Cache for read-heavy workloads
- Handle cache invalidation correctly
- Use appropriate data structures
- Monitor memory usage

---

## 1) Data Structures

### Strings
```redis
# ==========================================
# STRINGS: Simple key-value, counters
# ==========================================

# Basic set/get
SET user:123:name "John Doe"
GET user:123:name

# Set with expiration
SET session:abc123 "user_data" EX 3600  # 1 hour
SETEX session:abc123 3600 "user_data"   # Same thing

# Set only if not exists (for locking)
SET lock:resource:123 "owner_id" NX EX 30
# Returns OK if set, nil if key exists

# Set only if exists (for updates)
SET user:123:status "active" XX

# Atomic counter
INCR page:views:homepage
INCRBY user:123:credits 100
DECR stock:product:456
DECRBY stock:product:456 5

# Floating point counter
INCRBYFLOAT account:123:balance 99.99

# Get and set atomically
GETSET rate_limit:user:123 0  # Returns old value

# Get multiple keys
MGET user:123:name user:123:email user:123:role

# Set multiple keys
MSET user:123:name "John" user:123:email "john@example.com"

# Bit operations (flags, feature toggles)
SETBIT user:123:features 0 1  # Enable feature 0
GETBIT user:123:features 0
BITCOUNT user:123:features    # Count enabled features
```

### Lists
```redis
# ==========================================
# LISTS: Queues, recent items, feeds
# ==========================================

# Add items (LPUSH = left/head, RPUSH = right/tail)
LPUSH notifications:user:123 '{"type":"like","from":"456"}'
RPUSH queue:emails '{"to":"user@example.com","subject":"Welcome"}'

# Queue pattern (FIFO): RPUSH + LPOP
RPUSH queue:tasks "task_1"
LPOP queue:tasks  # Returns "task_1"

# Stack pattern (LIFO): LPUSH + LPOP
LPUSH stack:undo "action_1"
LPOP stack:undo

# Blocking pop (for workers)
BLPOP queue:tasks 30  # Wait up to 30 seconds

# Get range (0-based, -1 = last)
LRANGE notifications:user:123 0 9     # First 10
LRANGE notifications:user:123 -10 -1  # Last 10

# Capped list (keep only recent N items)
LPUSH recent:products:user:123 "product_456"
LTRIM recent:products:user:123 0 9  # Keep only 10 recent

# Get length
LLEN queue:tasks

# Remove specific value
LREM notifications:user:123 1 '{"type":"like","from":"456"}'

# Move between lists atomically
LMOVE queue:pending queue:processing LEFT RIGHT
```

### Sets
```redis
# ==========================================
# SETS: Unique items, tags, relationships
# ==========================================

# Add members
SADD tags:post:123 "redis" "caching" "performance"
SADD followers:user:123 "user:456" "user:789"
SADD following:user:456 "user:123"

# Check membership
SISMEMBER tags:post:123 "redis"  # Returns 1 or 0

# Get all members
SMEMBERS tags:post:123

# Random members
SRANDMEMBER tags:post:123 3  # 3 random tags

# Count members
SCARD followers:user:123

# Remove member
SREM tags:post:123 "deprecated"

# Set operations
SINTER followers:user:123 followers:user:456  # Mutual followers
SUNION tags:post:123 tags:post:456            # All tags
SDIFF following:user:123 followers:user:123   # Following but not followed back

# Store result
SINTERSTORE mutual:123:456 followers:user:123 followers:user:456

# Pop random member
SPOP tags:post:123  # Remove and return random

# Move between sets
SMOVE tags:post:123 tags:post:456 "redis"
```

### Sorted Sets
```redis
# ==========================================
# SORTED SETS: Leaderboards, priority queues, timelines
# ==========================================

# Add with score
ZADD leaderboard:game:1 1000 "user:123" 950 "user:456" 900 "user:789"

# Update score (add if not exists)
ZINCRBY leaderboard:game:1 50 "user:123"  # Add 50 points

# Get rank (0-based, lowest score = rank 0)
ZRANK leaderboard:game:1 "user:123"   # Ascending
ZREVRANK leaderboard:game:1 "user:123"  # Descending (highest = 0)

# Get top N (highest scores)
ZREVRANGE leaderboard:game:1 0 9 WITHSCORES  # Top 10

# Get by score range
ZRANGEBYSCORE leaderboard:game:1 900 1000 WITHSCORES  # Score 900-1000

# Count by score range
ZCOUNT leaderboard:game:1 900 1000

# Get score
ZSCORE leaderboard:game:1 "user:123"

# Remove member
ZREM leaderboard:game:1 "user:123"

# Remove by rank (bottom N)
ZREMRANGEBYRANK leaderboard:game:1 0 -11  # Keep top 10

# Remove by score
ZREMRANGEBYSCORE delayed:queue:tasks -inf 1704067200  # Remove old items

# Priority queue (use timestamp as score)
ZADD delayed:queue:tasks 1704067200 "task:123"  # Schedule for timestamp
ZRANGEBYSCORE delayed:queue:tasks -inf +inf LIMIT 0 1  # Get next task

# Rate limiting sliding window
ZADD rate_limit:user:123 1704067200.123 "request:1"
ZREMRANGEBYSCORE rate_limit:user:123 -inf 1704067140  # Remove old (60s window)
ZCARD rate_limit:user:123  # Count requests in window
```

### Hashes
```redis
# ==========================================
# HASHES: Objects, profiles, settings
# ==========================================

# Set fields
HSET user:123 name "John Doe" email "john@example.com" role "admin"

# Get field
HGET user:123 name

# Get multiple fields
HMGET user:123 name email role

# Get all fields and values
HGETALL user:123

# Check field exists
HEXISTS user:123 avatar

# Increment numeric field
HINCRBY user:123 login_count 1
HINCRBYFLOAT user:123 wallet_balance 99.99

# Set only if not exists
HSETNX user:123 created_at "2024-01-15"

# Get all fields (keys)
HKEYS user:123

# Get all values
HVALS user:123

# Count fields
HLEN user:123

# Delete field
HDEL user:123 temporary_field

# Scan fields (for large hashes)
HSCAN user:123 0 MATCH email* COUNT 100
```

### Streams
```redis
# ==========================================
# STREAMS: Event logs, messaging, task queues
# ==========================================

# Add event (* = auto-generate ID)
XADD events:orders * action "created" order_id "123" user_id "456"

# Add with custom ID (timestamp-sequence)
XADD events:orders 1704067200000-0 action "created" order_id "123"

# Read events (from beginning)
XREAD STREAMS events:orders 0

# Read new events only (blocking)
XREAD BLOCK 5000 STREAMS events:orders $

# Read range
XRANGE events:orders - +       # All events
XRANGE events:orders - + COUNT 10  # First 10

# Consumer groups (for distributed processing)
XGROUP CREATE events:orders workers $ MKSTREAM

# Read as consumer in group
XREADGROUP GROUP workers worker-1 COUNT 10 STREAMS events:orders >

# Acknowledge processed
XACK events:orders workers 1704067200000-0

# Check pending (unacknowledged)
XPENDING events:orders workers

# Claim abandoned message
XCLAIM events:orders workers worker-2 60000 1704067200000-0

# Trim old events
XTRIM events:orders MAXLEN ~ 10000  # Keep ~10000 events

# Get stream info
XINFO STREAM events:orders
XINFO GROUPS events:orders
```

---

## 2) Caching Patterns

### Cache-Aside (Lazy Loading)
```typescript
// ==========================================
// CACHE-ASIDE PATTERN
// ==========================================

import Redis from 'ioredis';

const redis = new Redis({
  host: 'localhost',
  port: 6379,
  maxRetriesPerRequest: 3,
});

interface User {
  id: string;
  name: string;
  email: string;
}

async function getUser(userId: string): Promise<User | null> {
  const cacheKey = `user:${userId}`;
  
  // 1. Check cache first
  const cached = await redis.get(cacheKey);
  if (cached) {
    return JSON.parse(cached);
  }
  
  // 2. Cache miss - fetch from database
  const user = await db.users.findById(userId);
  
  if (!user) {
    return null;
  }
  
  // 3. Store in cache for future requests
  await redis.setex(cacheKey, 3600, JSON.stringify(user)); // 1 hour TTL
  
  return user;
}

async function updateUser(userId: string, data: Partial<User>): Promise<User> {
  // 1. Update database
  const user = await db.users.update(userId, data);
  
  // 2. Invalidate cache
  await redis.del(`user:${userId}`);
  
  return user;
}


// ==========================================
// WITH CACHE STAMPEDE PREVENTION
// ==========================================

async function getUserWithLock(userId: string): Promise<User | null> {
  const cacheKey = `user:${userId}`;
  const lockKey = `lock:${cacheKey}`;
  
  // Check cache
  const cached = await redis.get(cacheKey);
  if (cached) {
    return JSON.parse(cached);
  }
  
  // Try to acquire lock
  const lockAcquired = await redis.set(lockKey, '1', 'EX', 10, 'NX');
  
  if (!lockAcquired) {
    // Another process is fetching, wait and retry
    await new Promise(r => setTimeout(r, 100));
    return getUserWithLock(userId);
  }
  
  try {
    // Double-check cache after acquiring lock
    const rechecked = await redis.get(cacheKey);
    if (rechecked) {
      return JSON.parse(rechecked);
    }
    
    // Fetch from database
    const user = await db.users.findById(userId);
    
    if (user) {
      await redis.setex(cacheKey, 3600, JSON.stringify(user));
    }
    
    return user;
  } finally {
    // Release lock
    await redis.del(lockKey);
  }
}
```

### Write-Through Cache
```typescript
// ==========================================
// WRITE-THROUGH PATTERN
// ==========================================

async function createUser(data: CreateUserInput): Promise<User> {
  // 1. Write to database
  const user = await db.users.create(data);
  
  // 2. Write to cache synchronously
  await redis.setex(
    `user:${user.id}`,
    3600,
    JSON.stringify(user)
  );
  
  return user;
}

async function updateUser(userId: string, data: Partial<User>): Promise<User> {
  // 1. Update database
  const user = await db.users.update(userId, data);
  
  // 2. Update cache synchronously
  await redis.setex(
    `user:${userId}`,
    3600,
    JSON.stringify(user)
  );
  
  return user;
}
```

### Write-Behind (Write-Back)
```typescript
// ==========================================
// WRITE-BEHIND PATTERN
// ==========================================

import { Queue } from 'bullmq';

const writeQueue = new Queue('cache-writeback');

async function updateUserAsync(userId: string, data: Partial<User>): Promise<void> {
  // 1. Update cache immediately
  const cacheKey = `user:${userId}`;
  const existing = await redis.get(cacheKey);
  
  if (existing) {
    const updated = { ...JSON.parse(existing), ...data };
    await redis.setex(cacheKey, 3600, JSON.stringify(updated));
  }
  
  // 2. Queue database write
  await writeQueue.add('update-user', {
    userId,
    data,
    timestamp: Date.now(),
  });
}

// Background worker
import { Worker } from 'bullmq';

new Worker('cache-writeback', async (job) => {
  const { userId, data } = job.data;
  
  await db.users.update(userId, data);
}, {
  connection: redis,
  concurrency: 10,
});
```

### Cache Invalidation Patterns
```typescript
// ==========================================
// PATTERN-BASED INVALIDATION
// ==========================================

// Using Redis SCAN for pattern deletion
async function invalidatePattern(pattern: string): Promise<number> {
  let cursor = '0';
  let deletedCount = 0;
  
  do {
    const [newCursor, keys] = await redis.scan(
      cursor,
      'MATCH', pattern,
      'COUNT', 100
    );
    cursor = newCursor;
    
    if (keys.length > 0) {
      await redis.del(...keys);
      deletedCount += keys.length;
    }
  } while (cursor !== '0');
  
  return deletedCount;
}

// Usage: Invalidate all user-related cache
await invalidatePattern('user:123:*');


// ==========================================
// TAG-BASED INVALIDATION
// ==========================================

async function setWithTags(
  key: string,
  value: string,
  ttl: number,
  tags: string[]
): Promise<void> {
  const multi = redis.multi();
  
  // Set the value
  multi.setex(key, ttl, value);
  
  // Add key to each tag set
  for (const tag of tags) {
    multi.sadd(`tag:${tag}`, key);
    multi.expire(`tag:${tag}`, ttl + 60); // Slightly longer TTL
  }
  
  await multi.exec();
}

async function invalidateByTag(tag: string): Promise<number> {
  const keys = await redis.smembers(`tag:${tag}`);
  
  if (keys.length > 0) {
    await redis.del(...keys, `tag:${tag}`);
  }
  
  return keys.length;
}

// Usage
await setWithTags(
  'product:123',
  JSON.stringify(product),
  3600,
  ['products', 'category:electronics']
);

// Invalidate all products
await invalidateByTag('products');
```

---

## 3) TypeScript Client

### ioredis Configuration
```typescript
// ==========================================
// REDIS CLIENT SETUP
// ==========================================

import Redis, { RedisOptions } from 'ioredis';

const redisConfig: RedisOptions = {
  host: process.env.REDIS_HOST || 'localhost',
  port: parseInt(process.env.REDIS_PORT || '6379'),
  password: process.env.REDIS_PASSWORD,
  db: parseInt(process.env.REDIS_DB || '0'),
  
  // Connection pool
  maxRetriesPerRequest: 3,
  retryStrategy: (times) => {
    if (times > 10) return null; // Stop retrying
    return Math.min(times * 100, 3000);
  },
  
  // Reconnection
  reconnectOnError: (err) => {
    return err.message.includes('READONLY');
  },
  
  // TLS (for production)
  // tls: { rejectUnauthorized: false },
  
  // Cluster support
  // redisOptions: { password: 'xxx' },
};

// Singleton instance
export const redis = new Redis(redisConfig);

// Event handlers
redis.on('connect', () => console.log('Redis connected'));
redis.on('error', (err) => console.error('Redis error:', err));
redis.on('close', () => console.log('Redis connection closed'));


// ==========================================
// TYPED CACHE SERVICE
// ==========================================

type CacheValue = string | number | object;

interface CacheOptions {
  ttl?: number;
  tags?: string[];
}

export class CacheService {
  constructor(private redis: Redis) {}

  async get<T>(key: string): Promise<T | null> {
    const value = await this.redis.get(key);
    if (!value) return null;
    
    try {
      return JSON.parse(value) as T;
    } catch {
      return value as T;
    }
  }

  async set(
    key: string,
    value: CacheValue,
    options: CacheOptions = {}
  ): Promise<void> {
    const serialized = typeof value === 'string'
      ? value
      : JSON.stringify(value);
    
    const ttl = options.ttl ?? 3600;
    
    if (options.tags?.length) {
      const multi = this.redis.multi();
      multi.setex(key, ttl, serialized);
      
      for (const tag of options.tags) {
        multi.sadd(`tag:${tag}`, key);
        multi.expire(`tag:${tag}`, ttl + 60);
      }
      
      await multi.exec();
    } else {
      await this.redis.setex(key, ttl, serialized);
    }
  }

  async delete(key: string): Promise<void> {
    await this.redis.del(key);
  }

  async deletePattern(pattern: string): Promise<number> {
    let cursor = '0';
    let count = 0;
    
    do {
      const [newCursor, keys] = await this.redis.scan(
        cursor, 'MATCH', pattern, 'COUNT', 100
      );
      cursor = newCursor;
      
      if (keys.length > 0) {
        await this.redis.del(...keys);
        count += keys.length;
      }
    } while (cursor !== '0');
    
    return count;
  }

  async getOrSet<T>(
    key: string,
    factory: () => Promise<T>,
    options: CacheOptions = {}
  ): Promise<T> {
    const cached = await this.get<T>(key);
    if (cached !== null) return cached;
    
    const value = await factory();
    await this.set(key, value, options);
    
    return value;
  }
}

export const cache = new CacheService(redis);

// Usage
const user = await cache.getOrSet(
  `user:${userId}`,
  () => db.users.findById(userId),
  { ttl: 3600, tags: ['users'] }
);
```

### Pipeline and Transaction
```typescript
// ==========================================
// PIPELINE (Batch commands)
// ==========================================

async function getUsersWithStats(userIds: string[]): Promise<any[]> {
  const pipeline = redis.pipeline();
  
  for (const id of userIds) {
    pipeline.hgetall(`user:${id}`);
    pipeline.get(`user:${id}:stats`);
  }
  
  const results = await pipeline.exec();
  
  return userIds.map((id, i) => ({
    user: results?.[i * 2]?.[1],
    stats: results?.[i * 2 + 1]?.[1],
  }));
}


// ==========================================
// TRANSACTION (MULTI/EXEC)
// ==========================================

async function transferCredits(
  fromUserId: string,
  toUserId: string,
  amount: number
): Promise<boolean> {
  const fromKey = `user:${fromUserId}:credits`;
  const toKey = `user:${toUserId}:credits`;
  
  // Watch keys for changes
  await redis.watch(fromKey, toKey);
  
  const currentBalance = parseInt(await redis.get(fromKey) || '0');
  
  if (currentBalance < amount) {
    await redis.unwatch();
    return false;
  }
  
  try {
    const result = await redis.multi()
      .decrby(fromKey, amount)
      .incrby(toKey, amount)
      .exec();
    
    // Transaction aborted if watched key changed
    return result !== null;
  } catch (error) {
    return false;
  }
}
```

---

## 4) Lua Scripting

```typescript
// ==========================================
// LUA SCRIPTS FOR ATOMIC OPERATIONS
// ==========================================

// Rate limiter with sliding window
const rateLimitScript = `
local key = KEYS[1]
local window = tonumber(ARGV[1])
local limit = tonumber(ARGV[2])
local now = tonumber(ARGV[3])

-- Remove old entries
redis.call('ZREMRANGEBYSCORE', key, '-inf', now - window)

-- Count current requests
local count = redis.call('ZCARD', key)

if count >= limit then
  return 0  -- Rate limited
end

-- Add new request
redis.call('ZADD', key, now, now .. '-' .. math.random())
redis.call('EXPIRE', key, window)

return 1  -- Allowed
`;

async function checkRateLimit(
  userId: string,
  windowSeconds: number,
  maxRequests: number
): Promise<boolean> {
  const key = `rate_limit:${userId}`;
  const now = Date.now();
  
  const result = await redis.eval(
    rateLimitScript,
    1,
    key,
    windowSeconds * 1000,
    maxRequests,
    now
  );
  
  return result === 1;
}


// ==========================================
// CACHE WITH EARLY EXPIRATION (Stampede prevention)
// ==========================================

const cacheWithEarlyExpireScript = `
local key = KEYS[1]
local ttl_key = key .. ':ttl'

local data = redis.call('GET', key)
local ttl_data = redis.call('GET', ttl_key)

if not data then
  return nil
end

if ttl_data then
  local logical_ttl = tonumber(ttl_data)
  local now = tonumber(ARGV[1])
  
  -- Random early expiration (10% chance if within last 20% of TTL)
  if now > logical_ttl * 0.8 and math.random() < 0.1 then
    return nil  -- Force refresh
  end
end

return data
`;


// ==========================================
// DISTRIBUTED LOCK
// ==========================================

const acquireLockScript = `
local key = KEYS[1]
local token = ARGV[1]
local ttl = tonumber(ARGV[2])

if redis.call('EXISTS', key) == 0 then
  redis.call('SET', key, token, 'PX', ttl)
  return 1
end

return 0
`;

const releaseLockScript = `
local key = KEYS[1]
local token = ARGV[1]

if redis.call('GET', key) == token then
  redis.call('DEL', key)
  return 1
end

return 0
`;

class DistributedLock {
  constructor(private redis: Redis) {}

  async acquire(
    resource: string,
    ttlMs: number = 10000
  ): Promise<string | null> {
    const token = crypto.randomUUID();
    const key = `lock:${resource}`;
    
    const acquired = await this.redis.eval(
      acquireLockScript,
      1,
      key,
      token,
      ttlMs
    );
    
    return acquired === 1 ? token : null;
  }

  async release(resource: string, token: string): Promise<boolean> {
    const key = `lock:${resource}`;
    
    const released = await this.redis.eval(
      releaseLockScript,
      1,
      key,
      token
    );
    
    return released === 1;
  }

  async withLock<T>(
    resource: string,
    fn: () => Promise<T>,
    ttlMs: number = 10000
  ): Promise<T> {
    const token = await this.acquire(resource, ttlMs);
    
    if (!token) {
      throw new Error('Failed to acquire lock');
    }
    
    try {
      return await fn();
    } finally {
      await this.release(resource, token);
    }
  }
}
```

---

## 5) Pub/Sub

```typescript
// ==========================================
// PUB/SUB MESSAGING
// ==========================================

// Separate connections for pub and sub
const publisher = new Redis(redisConfig);
const subscriber = new Redis(redisConfig);

// Subscribe to channels
subscriber.subscribe('orders', 'notifications', (err, count) => {
  console.log(`Subscribed to ${count} channels`);
});

// Pattern subscribe
subscriber.psubscribe('user:*:events', (err, count) => {
  console.log(`Subscribed to ${count} patterns`);
});

// Handle messages
subscriber.on('message', (channel, message) => {
  console.log(`[${channel}] ${message}`);
  
  const data = JSON.parse(message);
  handleMessage(channel, data);
});

subscriber.on('pmessage', (pattern, channel, message) => {
  console.log(`[${pattern}] ${channel}: ${message}`);
});

// Publish message
async function publishEvent(channel: string, data: object): Promise<void> {
  await publisher.publish(channel, JSON.stringify(data));
}

// Usage
await publishEvent('orders', {
  type: 'order_created',
  orderId: '123',
  userId: '456',
});


// ==========================================
// TYPED EVENT BUS
// ==========================================

interface EventMap {
  'order:created': { orderId: string; userId: string };
  'order:shipped': { orderId: string; trackingNumber: string };
  'user:registered': { userId: string; email: string };
}

class TypedEventBus {
  private publisher: Redis;
  private subscriber: Redis;
  private handlers = new Map<string, Function[]>();

  constructor(config: RedisOptions) {
    this.publisher = new Redis(config);
    this.subscriber = new Redis(config);
    
    this.subscriber.on('message', (channel, message) => {
      const handlers = this.handlers.get(channel) || [];
      const data = JSON.parse(message);
      
      handlers.forEach(handler => handler(data));
    });
  }

  async publish<K extends keyof EventMap>(
    event: K,
    data: EventMap[K]
  ): Promise<void> {
    await this.publisher.publish(event, JSON.stringify(data));
  }

  subscribe<K extends keyof EventMap>(
    event: K,
    handler: (data: EventMap[K]) => void
  ): void {
    if (!this.handlers.has(event)) {
      this.handlers.set(event, []);
      this.subscriber.subscribe(event);
    }
    
    this.handlers.get(event)!.push(handler);
  }
}

// Usage
const eventBus = new TypedEventBus(redisConfig);

eventBus.subscribe('order:created', (data) => {
  console.log(`New order: ${data.orderId}`);  // Fully typed!
});

await eventBus.publish('order:created', {
  orderId: '123',
  userId: '456',
});
```

---

## 6) High Availability

### Redis Sentinel
```typescript
// ==========================================
// SENTINEL CONFIGURATION
// ==========================================

import Redis from 'ioredis';

const redis = new Redis({
  sentinels: [
    { host: 'sentinel1.example.com', port: 26379 },
    { host: 'sentinel2.example.com', port: 26379 },
    { host: 'sentinel3.example.com', port: 26379 },
  ],
  name: 'mymaster',  // Sentinel master name
  password: 'redis_password',
  sentinelPassword: 'sentinel_password',
  
  // Automatic failover
  enableReadyCheck: true,
  maxRetriesPerRequest: 3,
});
```

### Redis Cluster
```typescript
// ==========================================
// CLUSTER CONFIGURATION
// ==========================================

import Redis from 'ioredis';

const cluster = new Redis.Cluster([
  { host: 'redis1.example.com', port: 6379 },
  { host: 'redis2.example.com', port: 6379 },
  { host: 'redis3.example.com', port: 6379 },
], {
  redisOptions: {
    password: 'cluster_password',
  },
  scaleReads: 'slave',  // Read from replicas
  
  // Retry strategy
  clusterRetryStrategy: (times) => {
    if (times > 10) return null;
    return Math.min(times * 100, 3000);
  },
});

// Hash tags for same-slot operations
// Keys with same {tag} go to same slot
await cluster.mset(
  '{user:123}:profile', 'data1',
  '{user:123}:settings', 'data2'
);
```

---

## 7) Monitoring & Performance

```redis
# ==========================================
# MONITORING COMMANDS
# ==========================================

# Memory usage
INFO memory

# Stats
INFO stats
INFO keyspace

# Slow queries
SLOWLOG GET 10
CONFIG SET slowlog-log-slower-than 10000  # 10ms

# Client list
CLIENT LIST

# Monitor all commands (debug only!)
MONITOR

# Memory analysis
MEMORY DOCTOR
MEMORY STATS

# Key memory usage
MEMORY USAGE user:123

# Big keys
redis-cli --bigkeys

# Scan for patterns
SCAN 0 MATCH user:* COUNT 100

# TTL check
TTL user:123
PTTL user:123  # Milliseconds
```

```typescript
// ==========================================
// CACHE METRICS
// ==========================================

interface CacheMetrics {
  hits: number;
  misses: number;
  hitRatio: number;
}

class MeteredCache extends CacheService {
  private hits = 0;
  private misses = 0;

  async get<T>(key: string): Promise<T | null> {
    const value = await super.get<T>(key);
    
    if (value !== null) {
      this.hits++;
    } else {
      this.misses++;
    }
    
    return value;
  }

  getMetrics(): CacheMetrics {
    const total = this.hits + this.misses;
    return {
      hits: this.hits,
      misses: this.misses,
      hitRatio: total > 0 ? this.hits / total : 0,
    };
  }

  resetMetrics(): void {
    this.hits = 0;
    this.misses = 0;
  }
}
```

---

## Best Practices Checklist

### Data Structures
- [ ] Choose appropriate type
- [ ] Use SCAN not KEYS
- [ ] Pipeline batch operations
- [ ] Use hash tags for cluster

### Caching
- [ ] Set TTL on all keys
- [ ] Handle cache stampede
- [ ] Proper invalidation strategy
- [ ] Tag-based invalidation

### Performance
- [ ] Connection pooling
- [ ] Pipeline commands
- [ ] Lua for atomic ops
- [ ] Monitor hit ratio

### High Availability
- [ ] Sentinel or Cluster
- [ ] Persistence strategy
- [ ] Backup regularly
- [ ] Monitor memory

---

**References:**
- [Redis Documentation](https://redis.io/docs/)
- [ioredis](https://github.com/redis/ioredis)
- [Redis Best Practices](https://redis.io/docs/management/optimization/)

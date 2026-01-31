# MongoDB & NoSQL Databases Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **MongoDB:** 7.0+  
> **Driver:** Node.js 6.x+  
> **Priority:** P0 - Load for MongoDB projects

---

You are an expert in MongoDB and NoSQL document database design.

## Core Principles

- Design for how data is accessed
- Embed vs Reference decisions
- Optimize for horizontal scalability
- Use aggregation framework for analytics

---

## 1) Data Modeling

### Embedding vs Referencing
```javascript
// ==========================================
// EMBEDDING (1:1 and 1:Few)
// ✅ Good for: Atomic reads, related data always accessed together
// ==========================================

// User with embedded address (1:1)
{
  _id: ObjectId("..."),
  name: "John Doe",
  email: "john@example.com",
  
  // Embedded document - always read together
  address: {
    street: "123 Main St",
    city: "New York",
    state: "NY",
    zipCode: "10001",
    country: "USA"
  },
  
  // Embedded array (1:Few) - bounded, small
  phoneNumbers: [
    { type: "home", number: "+1-212-555-1234" },
    { type: "work", number: "+1-212-555-5678" }
  ],
  
  createdAt: ISODate("2024-01-15T10:30:00Z"),
  updatedAt: ISODate("2024-01-15T10:30:00Z")
}


// ==========================================
// REFERENCING (1:Many and Many:Many)
// ✅ Good for: Independent access, large/unbounded relationships
// ==========================================

// User document
{
  _id: ObjectId("user123"),
  name: "John Doe",
  email: "john@example.com"
}

// Posts with reference to author (1:Many)
{
  _id: ObjectId("post123"),
  title: "MongoDB Best Practices",
  content: "...",
  authorId: ObjectId("user123"),  // Reference
  
  // Store denormalized author info for common reads
  author: {
    name: "John Doe",
    avatar: "https://..."
  },
  
  // Reference array for tags (Many:Many)
  tagIds: [
    ObjectId("tag1"),
    ObjectId("tag2")
  ],
  
  createdAt: ISODate("2024-01-15T10:30:00Z")
}


// ==========================================
// HYBRID PATTERN (Subset)
// ✅ Good for: Display summary, load details on demand
// ==========================================

// Product with embedded reviews summary
{
  _id: ObjectId("product123"),
  name: "Wireless Mouse",
  price: 29.99,
  
  // Embedded subset (top 3 reviews for display)
  recentReviews: [
    { userId: ObjectId("..."), rating: 5, text: "Great!", date: ISODate("...") },
    { userId: ObjectId("..."), rating: 4, text: "Good value", date: ISODate("...") }
  ],
  
  // Aggregated stats (denormalized)
  reviewStats: {
    count: 156,
    averageRating: 4.3
  }
}

// Full reviews in separate collection
{
  _id: ObjectId("review123"),
  productId: ObjectId("product123"),
  userId: ObjectId("user123"),
  rating: 5,
  text: "This mouse is amazing! Great precision and battery life.",
  helpful: 23,
  createdAt: ISODate("2024-01-15T10:30:00Z")
}


// ==========================================
// BUCKET PATTERN (Time-series)
// ✅ Good for: IoT data, logs, metrics
// ==========================================

// Bucket per hour for sensor data
{
  _id: ObjectId("..."),
  sensorId: "sensor-001",
  bucket: ISODate("2024-01-15T10:00:00Z"),  // Start of bucket
  
  // Array of readings in this bucket
  readings: [
    { timestamp: ISODate("2024-01-15T10:00:15Z"), value: 23.5 },
    { timestamp: ISODate("2024-01-15T10:01:20Z"), value: 23.6 },
    { timestamp: ISODate("2024-01-15T10:02:45Z"), value: 23.4 }
  ],
  
  count: 3,
  sum: 70.5,
  min: 23.4,
  max: 23.6
}
```

### Schema Validation
```javascript
// ==========================================
// JSON SCHEMA VALIDATION
// ==========================================

db.createCollection("users", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["name", "email", "createdAt"],
      properties: {
        _id: { bsonType: "objectId" },
        
        name: {
          bsonType: "string",
          minLength: 2,
          maxLength: 100,
          description: "User's full name (required)"
        },
        
        email: {
          bsonType: "string",
          pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$",
          description: "Valid email address (required)"
        },
        
        role: {
          enum: ["admin", "user", "moderator"],
          description: "User role"
        },
        
        age: {
          bsonType: "int",
          minimum: 0,
          maximum: 150,
          description: "Age must be between 0 and 150"
        },
        
        address: {
          bsonType: "object",
          properties: {
            street: { bsonType: "string" },
            city: { bsonType: "string" },
            zipCode: { bsonType: "string", pattern: "^\\d{5}$" }
          }
        },
        
        tags: {
          bsonType: "array",
          maxItems: 10,
          items: { bsonType: "string" }
        },
        
        metadata: {
          bsonType: "object",
          additionalProperties: true  // Allow any additional fields
        },
        
        isActive: { bsonType: "bool" },
        
        createdAt: { bsonType: "date" },
        updatedAt: { bsonType: "date" }
      },
      additionalProperties: false  // Strict - no extra fields
    }
  },
  validationLevel: "strict",  // or "moderate" (only validates updates)
  validationAction: "error"   // or "warn"
});

// Update validation rules
db.runCommand({
  collMod: "users",
  validator: { /* new schema */ },
  validationLevel: "moderate"
});
```

---

## 2) Indexing Strategies

### Index Types
```javascript
// ==========================================
// SINGLE FIELD INDEX
// ==========================================

db.users.createIndex({ email: 1 });  // Ascending
db.users.createIndex({ createdAt: -1 });  // Descending

// Unique index
db.users.createIndex(
  { email: 1 }, 
  { unique: true }
);

// Sparse index (only includes docs with field)
db.users.createIndex(
  { nickname: 1 }, 
  { sparse: true }
);


// ==========================================
// COMPOUND INDEX
// ==========================================

// Order matters! Supports queries on:
// - status
// - status + createdAt
// - status + createdAt + authorId
db.posts.createIndex({ 
  status: 1, 
  createdAt: -1, 
  authorId: 1 
});

// ESR Rule: Equality, Sort, Range
// Equality fields first, then sort, then range
db.orders.createIndex({
  status: 1,      // Equality: status = "pending"
  createdAt: -1,  // Sort: ORDER BY createdAt DESC
  total: 1        // Range: total > 100
});


// ==========================================
// MULTIKEY INDEX (Arrays)
// ==========================================

// Automatically indexes each array element
db.posts.createIndex({ tags: 1 });

// Query matches any element
db.posts.find({ tags: "mongodb" });

// With compound (only one array field allowed)
db.posts.createIndex({ tags: 1, status: 1 });


// ==========================================
// TEXT INDEX (Full-Text Search)
// ==========================================

// Single text index per collection
db.posts.createIndex({
  title: "text",
  content: "text"
}, {
  weights: { title: 10, content: 1 },  // Title matches ranked higher
  name: "posts_text_search"
});

// Text search
db.posts.find(
  { $text: { $search: "mongodb performance" } },
  { score: { $meta: "textScore" } }
).sort({ score: { $meta: "textScore" } });

// Phrase search
db.posts.find({ $text: { $search: "\"mongodb best practices\"" } });

// Exclude terms
db.posts.find({ $text: { $search: "mongodb -deprecated" } });


// ==========================================
// GEOSPATIAL INDEX
// ==========================================

// 2dsphere for Earth-like coordinates
db.locations.createIndex({ coordinates: "2dsphere" });

// GeoJSON format
db.locations.insertOne({
  name: "Central Park",
  coordinates: {
    type: "Point",
    coordinates: [-73.965355, 40.782865]  // [longitude, latitude]
  }
});

// Find near a point
db.locations.find({
  coordinates: {
    $near: {
      $geometry: {
        type: "Point",
        coordinates: [-73.935242, 40.730610]
      },
      $maxDistance: 5000  // meters
    }
  }
});

// Find within polygon
db.locations.find({
  coordinates: {
    $geoWithin: {
      $geometry: {
        type: "Polygon",
        coordinates: [[
          [-74.0, 40.7],
          [-73.9, 40.7],
          [-73.9, 40.8],
          [-74.0, 40.8],
          [-74.0, 40.7]
        ]]
      }
    }
  }
});


// ==========================================
// TTL INDEX (Time-To-Live)
// ==========================================

// Automatically delete documents after expiration
db.sessions.createIndex(
  { expiresAt: 1 },
  { expireAfterSeconds: 0 }  // Delete when expiresAt is reached
);

// Or: delete after fixed time from creation
db.logs.createIndex(
  { createdAt: 1 },
  { expireAfterSeconds: 604800 }  // 7 days
);


// ==========================================
// PARTIAL INDEX
// ==========================================

// Only index documents matching filter
db.orders.createIndex(
  { createdAt: -1 },
  { 
    partialFilterExpression: { status: "pending" },
    name: "pending_orders_by_date"
  }
);

// Queries must include filter condition to use index
db.orders.find({ status: "pending" }).sort({ createdAt: -1 });
```

### Index Analysis
```javascript
// ==========================================
// EXPLAIN ANALYSIS
// ==========================================

// Query execution plan
db.posts.find({ status: "published" }).explain("executionStats");

// Key things to check:
// - stage: "IXSCAN" (good) vs "COLLSCAN" (bad)
// - nReturned vs totalDocsExamined (should be close)
// - executionTimeMillis

// All indexes on collection
db.posts.getIndexes();

// Index size
db.posts.stats().indexSizes;

// Index usage statistics
db.posts.aggregate([
  { $indexStats: {} }
]);

// Drop unused index
db.posts.dropIndex("unused_index_name");

// Rebuild indexes
db.posts.reIndex();  // Use sparingly, blocks writes
```

---

## 3) Aggregation Pipeline

### Pipeline Stages
```javascript
// ==========================================
// BASIC AGGREGATION
// ==========================================

db.orders.aggregate([
  // Stage 1: Filter early (uses index)
  { $match: { 
    status: "completed",
    createdAt: { $gte: ISODate("2024-01-01") }
  }},
  
  // Stage 2: Group and calculate
  { $group: {
    _id: "$customerId",
    totalOrders: { $sum: 1 },
    totalSpent: { $sum: "$total" },
    avgOrderValue: { $avg: "$total" },
    lastOrder: { $max: "$createdAt" }
  }},
  
  // Stage 3: Filter groups
  { $match: { totalSpent: { $gte: 1000 } } },
  
  // Stage 4: Sort
  { $sort: { totalSpent: -1 } },
  
  // Stage 5: Limit results
  { $limit: 10 },
  
  // Stage 6: Shape output
  { $project: {
    _id: 0,
    customerId: "$_id",
    totalOrders: 1,
    totalSpent: { $round: ["$totalSpent", 2] },
    avgOrderValue: { $round: ["$avgOrderValue", 2] },
    lastOrder: 1,
    tier: {
      $switch: {
        branches: [
          { case: { $gte: ["$totalSpent", 5000] }, then: "platinum" },
          { case: { $gte: ["$totalSpent", 2500] }, then: "gold" },
          { case: { $gte: ["$totalSpent", 1000] }, then: "silver" }
        ],
        default: "bronze"
      }
    }
  }}
]);


// ==========================================
// $LOOKUP (JOIN)
// ==========================================

db.posts.aggregate([
  // Join with users collection
  { $lookup: {
    from: "users",
    localField: "authorId",
    foreignField: "_id",
    as: "author"
  }},
  
  // Unwind (1:1 relationship)
  { $unwind: "$author" },
  
  // Project needed fields
  { $project: {
    title: 1,
    content: 1,
    "author.name": 1,
    "author.email": 1,
    createdAt: 1
  }}
]);

// $lookup with pipeline (MongoDB 3.6+)
db.orders.aggregate([
  { $lookup: {
    from: "products",
    let: { productIds: "$items.productId" },
    pipeline: [
      { $match: {
        $expr: { $in: ["$_id", "$$productIds"] }
      }},
      { $project: { name: 1, price: 1, image: 1 } }
    ],
    as: "products"
  }}
]);


// ==========================================
// $UNWIND (Array Processing)
// ==========================================

// Expand orders by items
db.orders.aggregate([
  { $unwind: "$items" },
  
  // Now each document has single item
  { $group: {
    _id: "$items.productId",
    totalQuantity: { $sum: "$items.quantity" },
    totalRevenue: { $sum: { $multiply: ["$items.quantity", "$items.price"] } }
  }},
  
  { $sort: { totalRevenue: -1 } }
]);

// Preserve empty arrays
{ $unwind: { 
  path: "$items", 
  preserveNullAndEmptyArrays: true 
}}


// ==========================================
// $FACET (Multiple Pipelines)
// ==========================================

db.products.aggregate([
  { $match: { status: "active" } },
  
  { $facet: {
    // Pagination
    data: [
      { $sort: { createdAt: -1 } },
      { $skip: 0 },
      { $limit: 10 }
    ],
    
    // Total count
    totalCount: [
      { $count: "count" }
    ],
    
    // Category breakdown
    categories: [
      { $group: { _id: "$category", count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ],
    
    // Price range
    priceStats: [
      { $group: {
        _id: null,
        min: { $min: "$price" },
        max: { $max: "$price" },
        avg: { $avg: "$price" }
      }}
    ]
  }}
]);


// ==========================================
// WINDOW FUNCTIONS (MongoDB 5.0+)
// ==========================================

db.sales.aggregate([
  { $setWindowFields: {
    partitionBy: "$storeId",
    sortBy: { date: 1 },
    output: {
      // Running total per store
      runningTotal: {
        $sum: "$amount",
        window: { documents: ["unbounded", "current"] }
      },
      
      // 7-day moving average
      movingAvg: {
        $avg: "$amount",
        window: { range: [-6, 0], unit: "day" }
      },
      
      // Rank within store
      rank: {
        $rank: {}
      },
      
      // Difference from previous
      diff: {
        $subtract: [
          "$amount",
          { $shift: { output: "$amount", by: -1 } }
        ]
      }
    }
  }}
]);


// ==========================================
// $MERGE / $OUT (Write Results)
// ==========================================

// Write to new/existing collection
db.orders.aggregate([
  { $match: { status: "completed" } },
  { $group: {
    _id: { 
      year: { $year: "$createdAt" },
      month: { $month: "$createdAt" }
    },
    totalSales: { $sum: "$total" },
    orderCount: { $sum: 1 }
  }},
  
  // Upsert into summary collection
  { $merge: {
    into: "monthly_sales_summary",
    on: "_id",
    whenMatched: "replace",
    whenNotMatched: "insert"
  }}
]);
```

---

## 4) TypeScript Integration

### MongoDB Driver with TypeScript
```typescript
// ==========================================
// TYPED MONGODB CLIENT
// ==========================================

import { 
  MongoClient, 
  ObjectId, 
  Collection,
  WithId,
  OptionalUnlessRequiredId
} from 'mongodb';

// Define document interfaces
interface User {
  _id: ObjectId;
  name: string;
  email: string;
  role: 'admin' | 'user' | 'moderator';
  profile?: {
    avatar?: string;
    bio?: string;
  };
  createdAt: Date;
  updatedAt: Date;
}

interface Post {
  _id: ObjectId;
  title: string;
  slug: string;
  content: string;
  authorId: ObjectId;
  status: 'draft' | 'published' | 'archived';
  tags: string[];
  metadata: Record<string, unknown>;
  viewCount: number;
  publishedAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

// Database interface
interface Database {
  users: Collection<User>;
  posts: Collection<Post>;
}

// Create typed client
class MongoDatabase {
  private client: MongoClient;
  private db: Database | null = null;

  constructor(uri: string) {
    this.client = new MongoClient(uri, {
      maxPoolSize: 10,
      minPoolSize: 2,
      maxIdleTimeMS: 30000,
    });
  }

  async connect(dbName: string): Promise<Database> {
    await this.client.connect();
    const database = this.client.db(dbName);

    this.db = {
      users: database.collection<User>('users'),
      posts: database.collection<Post>('posts'),
    };

    return this.db;
  }

  async disconnect(): Promise<void> {
    await this.client.close();
  }

  getDb(): Database {
    if (!this.db) {
      throw new Error('Database not connected');
    }
    return this.db;
  }
}

// Usage
const mongo = new MongoDatabase(process.env.MONGODB_URI!);
const db = await mongo.connect('myapp');

// Fully typed operations
const user = await db.users.findOne({ email: 'john@example.com' });
if (user) {
  console.log(user.name);  // TypeScript knows this is string
}


// ==========================================
// TYPED REPOSITORY PATTERN
// ==========================================

import { Filter, UpdateFilter, FindOptions, ObjectId } from 'mongodb';

abstract class BaseRepository<T extends { _id: ObjectId }> {
  constructor(protected collection: Collection<T>) {}

  async findById(id: string | ObjectId): Promise<WithId<T> | null> {
    const objectId = typeof id === 'string' ? new ObjectId(id) : id;
    return this.collection.findOne({ _id: objectId } as Filter<T>);
  }

  async findOne(filter: Filter<T>): Promise<WithId<T> | null> {
    return this.collection.findOne(filter);
  }

  async find(
    filter: Filter<T>,
    options?: FindOptions<T>
  ): Promise<WithId<T>[]> {
    return this.collection.find(filter, options).toArray();
  }

  async create(doc: OptionalUnlessRequiredId<T>): Promise<WithId<T>> {
    const result = await this.collection.insertOne(doc);
    return { ...doc, _id: result.insertedId } as WithId<T>;
  }

  async update(
    id: string | ObjectId,
    update: UpdateFilter<T>
  ): Promise<WithId<T> | null> {
    const objectId = typeof id === 'string' ? new ObjectId(id) : id;
    const result = await this.collection.findOneAndUpdate(
      { _id: objectId } as Filter<T>,
      { ...update, $set: { ...update.$set, updatedAt: new Date() } },
      { returnDocument: 'after' }
    );
    return result;
  }

  async delete(id: string | ObjectId): Promise<boolean> {
    const objectId = typeof id === 'string' ? new ObjectId(id) : id;
    const result = await this.collection.deleteOne({ _id: objectId } as Filter<T>);
    return result.deletedCount === 1;
  }
}

// Specific repository
class UserRepository extends BaseRepository<User> {
  async findByEmail(email: string): Promise<WithId<User> | null> {
    return this.findOne({ email });
  }

  async findActiveUsers(): Promise<WithId<User>[]> {
    return this.find(
      { role: { $ne: 'admin' } },
      { sort: { createdAt: -1 }, limit: 100 }
    );
  }
}

class PostRepository extends BaseRepository<Post> {
  async findPublished(
    page: number = 1,
    limit: number = 10
  ): Promise<WithId<Post>[]> {
    return this.find(
      { status: 'published' },
      {
        sort: { publishedAt: -1 },
        skip: (page - 1) * limit,
        limit,
      }
    );
  }

  async findByAuthor(authorId: ObjectId): Promise<WithId<Post>[]> {
    return this.find({ authorId }, { sort: { createdAt: -1 } });
  }
}
```

---

## 5) Replica Sets & Sharding

### Replica Set Configuration
```javascript
// ==========================================
// REPLICA SET SETUP
// ==========================================

// Initialize replica set (run on primary)
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "mongo1.example.com:27017", priority: 2 },
    { _id: 1, host: "mongo2.example.com:27017", priority: 1 },
    { _id: 2, host: "mongo3.example.com:27017", priority: 1 }
  ]
});

// Check status
rs.status();

// Add member
rs.add("mongo4.example.com:27017");

// Add arbiter (voting member, no data)
rs.addArb("arbiter.example.com:27017");


// ==========================================
// WRITE CONCERNS
// ==========================================

// Acknowledge after primary write (default)
db.orders.insertOne(
  { item: "widget", qty: 100 },
  { writeConcern: { w: 1 } }
);

// Wait for majority acknowledgment (recommended for critical data)
db.orders.insertOne(
  { item: "widget", qty: 100 },
  { writeConcern: { w: "majority", wtimeout: 5000 } }
);

// Wait for journal write
db.orders.insertOne(
  { item: "widget", qty: 100 },
  { writeConcern: { w: 1, j: true } }
);


// ==========================================
// READ PREFERENCES
// ==========================================

// Read from primary only (default)
db.getMongo().setReadPref("primary");

// Read from primary preferred (fallback to secondary)
db.getMongo().setReadPref("primaryPreferred");

// Read from secondary (distribute read load)
db.getMongo().setReadPref("secondary");

// Read from nearest (lowest latency)
db.getMongo().setReadPref("nearest");

// With tags
db.getMongo().setReadPref("secondary", [{ dc: "east" }]);
```

### Sharding
```javascript
// ==========================================
// SHARD CLUSTER SETUP
// ==========================================

// Enable sharding on database
sh.enableSharding("myapp");

// Shard collection by hashed key (even distribution)
sh.shardCollection("myapp.orders", { customerId: "hashed" });

// Shard by range (for queries on range)
sh.shardCollection("myapp.events", { timestamp: 1 });

// Compound shard key
sh.shardCollection("myapp.logs", { tenantId: 1, timestamp: 1 });


// ==========================================
// CHOOSING SHARD KEY
// ==========================================

// ✅ GOOD shard keys:
// - High cardinality
// - Evenly distributed
// - Supports common query patterns

// ❌ BAD shard keys:
// - Monotonically increasing (timestamps, ObjectIds)
// - Low cardinality (status, category)

// Zone sharding for data locality
sh.addShardTag("shard0", "US");
sh.addShardTag("shard1", "EU");

sh.addTagRange(
  "myapp.users",
  { region: "US" },
  { region: "US~" },
  "US"
);

sh.addTagRange(
  "myapp.users",
  { region: "EU" },
  { region: "EU~" },
  "EU"
);
```

---

## 6) Change Streams

```typescript
// ==========================================
// CHANGE STREAMS (Real-time)
// ==========================================

import { ChangeStreamDocument, MongoClient, ObjectId } from 'mongodb';

interface Order {
  _id: ObjectId;
  customerId: ObjectId;
  items: Array<{ productId: ObjectId; quantity: number }>;
  status: 'pending' | 'processing' | 'shipped' | 'delivered';
  total: number;
}

async function watchOrders(db: Db): Promise<void> {
  const collection = db.collection<Order>('orders');
  
  // Watch for changes
  const changeStream = collection.watch<Order, ChangeStreamDocument<Order>>(
    [
      // Filter to specific operations
      { $match: { 
        operationType: { $in: ['insert', 'update', 'replace'] },
        'fullDocument.status': 'shipped'
      }}
    ],
    {
      fullDocument: 'updateLookup'  // Include full document on updates
    }
  );

  // Process changes
  changeStream.on('change', (change) => {
    switch (change.operationType) {
      case 'insert':
        console.log('New order:', change.fullDocument);
        break;
      
      case 'update':
        console.log('Order updated:', change.documentKey._id);
        console.log('Changes:', change.updateDescription.updatedFields);
        console.log('Full document:', change.fullDocument);
        break;
      
      case 'delete':
        console.log('Order deleted:', change.documentKey._id);
        break;
    }
  });

  changeStream.on('error', (error) => {
    console.error('Change stream error:', error);
  });

  // Resume from token (for fault tolerance)
  // const resumeToken = changeStream.resumeToken;
  // collection.watch([], { resumeAfter: resumeToken });
}


// ==========================================
// DATABASE-LEVEL CHANGE STREAM
// ==========================================

async function watchDatabase(db: Db): Promise<void> {
  const changeStream = db.watch([
    { $match: { 
      'ns.coll': { $in: ['orders', 'products'] }
    }}
  ]);

  for await (const change of changeStream) {
    console.log(`${change.ns.coll}: ${change.operationType}`);
  }
}
```

---

## 7) Security

```javascript
// ==========================================
// USER MANAGEMENT
// ==========================================

// Create admin user
use admin
db.createUser({
  user: "admin",
  pwd: "securePassword",
  roles: [
    { role: "userAdminAnyDatabase", db: "admin" },
    { role: "readWriteAnyDatabase", db: "admin" }
  ]
});

// Create application user
use myapp
db.createUser({
  user: "app_user",
  pwd: "appPassword",
  roles: [
    { role: "readWrite", db: "myapp" }
  ]
});

// Create read-only user
db.createUser({
  user: "reporting",
  pwd: "reportPassword",
  roles: [
    { role: "read", db: "myapp" }
  ]
});

// Create custom role
db.createRole({
  role: "productManager",
  privileges: [
    {
      resource: { db: "myapp", collection: "products" },
      actions: ["find", "insert", "update"]
    },
    {
      resource: { db: "myapp", collection: "categories" },
      actions: ["find"]
    }
  ],
  roles: []
});


// ==========================================
// FIELD-LEVEL ENCRYPTION
// ==========================================

// Client-side field level encryption (CSFLE)
const client = new MongoClient(uri, {
  autoEncryption: {
    keyVaultNamespace: 'encryption.__keyVault',
    kmsProviders: {
      local: {
        key: masterKey  // 96-byte base64 string
      }
    },
    schemaMap: {
      'myapp.users': {
        bsonType: 'object',
        encryptMetadata: {
          keyId: [dataKeyId]
        },
        properties: {
          ssn: {
            encrypt: {
              bsonType: 'string',
              algorithm: 'AEAD_AES_256_CBC_HMAC_SHA_512-Deterministic'
            }
          },
          creditCard: {
            encrypt: {
              bsonType: 'string',
              algorithm: 'AEAD_AES_256_CBC_HMAC_SHA_512-Random'
            }
          }
        }
      }
    }
  }
});
```

---

## 8) Performance & Monitoring

```javascript
// ==========================================
// PERFORMANCE ANALYSIS
// ==========================================

// Current operations
db.currentOp();

// Kill slow operation
db.killOp(opId);

// Server status
db.serverStatus();

// Collection stats
db.posts.stats();

// Profile slow queries
db.setProfilingLevel(1, { slowms: 100 });  // Log queries > 100ms

// View profiled queries
db.system.profile.find().sort({ ts: -1 }).limit(10);


// ==========================================
// EXPLAIN PATTERNS
// ==========================================

// Query explanation
db.posts.find({ status: "published" }).explain("executionStats");

// Aggregation explanation
db.posts.explain("executionStats").aggregate([
  { $match: { status: "published" } },
  { $sort: { createdAt: -1 } }
]);

// Key metrics to check:
// - stage: "IXSCAN" (good) vs "COLLSCAN" (bad)
// - nReturned vs totalDocsExamined
// - executionTimeMillis
```

---

## Best Practices Checklist

### Data Modeling
- [ ] Embed for 1:1 and 1:Few
- [ ] Reference for 1:Many (unbounded)
- [ ] Use schema validation
- [ ] Avoid unbounded arrays

### Indexing
- [ ] Index query fields
- [ ] Compound indexes (ESR rule)
- [ ] Partial indexes for filters
- [ ] Monitor with explain()

### Performance
- [ ] Match early in aggregation
- [ ] Use projections
- [ ] Connection pooling
- [ ] Monitor working set

### Security
- [ ] Enable authentication
- [ ] Use TLS
- [ ] Least privilege access
- [ ] Field-level encryption

---

**References:**
- [MongoDB Manual](https://www.mongodb.com/docs/manual/)
- [MongoDB University](https://university.mongodb.com/)
- [MongoDB Best Practices](https://www.mongodb.com/basics/best-practices)

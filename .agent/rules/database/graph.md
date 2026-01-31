# Graph Databases Expert (Neo4j)

> **Version:** 2.0.0 | **Updated:** 2026-02-01  
> **Neo4j:** 5.x  
> **Driver:** neo4j-driver 5.x  
> **Priority:** P0 - Load for graph database projects

---

You are an expert in Graph Databases, specifically Neo4j.

## Core Principles

- Relationships are first-class citizens
- Optimize for connected data traversal
- Model the domain naturally
- Use Cypher for querying

---

## 1) Data Modeling

### Nodes and Relationships
```cypher
// ==========================================
// BASIC STRUCTURE
// ==========================================

// Nodes with labels and properties
CREATE (u:User {
  id: 'user-123',
  name: 'John Doe',
  email: 'john@example.com',
  createdAt: datetime()
})

// Multiple labels
CREATE (p:Person:Employee:Manager {
  name: 'Jane Smith',
  department: 'Engineering'
})

// Relationships with type and properties
CREATE (a:User {name: 'Alice'})-[:FOLLOWS {since: date('2024-01-15')}]->(b:User {name: 'Bob'})

// Relationship with properties
CREATE (u:User)-[r:PURCHASED {
  orderId: 'order-456',
  quantity: 2,
  price: 99.99,
  purchasedAt: datetime()
}]->(p:Product)


// ==========================================
// COMPLETE SCHEMA EXAMPLE
// ==========================================

// Users
CREATE (u:User {
  id: randomUUID(),
  name: 'John Doe',
  email: 'john@example.com',
  avatar: 'https://...',
  createdAt: datetime(),
  updatedAt: datetime()
})

// Posts
CREATE (p:Post {
  id: randomUUID(),
  title: 'Graph Databases 101',
  content: 'Introduction to graph databases...',
  publishedAt: datetime(),
  viewCount: 0
})

// Tags
CREATE (t:Tag {name: 'database', slug: 'database'})

// Relationships
MATCH (u:User {email: 'john@example.com'})
MATCH (p:Post {title: 'Graph Databases 101'})
MATCH (t:Tag {slug: 'database'})
CREATE (u)-[:AUTHORED {role: 'primary'}]->(p)
CREATE (p)-[:TAGGED_WITH]->(t)


// ==========================================
// INDEXES AND CONSTRAINTS
// ==========================================

// Unique constraint (also creates index)
CREATE CONSTRAINT user_email_unique IF NOT EXISTS
FOR (u:User) REQUIRE u.email IS UNIQUE;

CREATE CONSTRAINT user_id_unique IF NOT EXISTS
FOR (u:User) REQUIRE u.id IS UNIQUE;

// Index for frequently queried properties
CREATE INDEX user_name_index IF NOT EXISTS
FOR (u:User) ON (u.name);

// Composite index
CREATE INDEX post_status_date IF NOT EXISTS
FOR (p:Post) ON (p.status, p.publishedAt);

// Full-text index
CREATE FULLTEXT INDEX post_search IF NOT EXISTS
FOR (p:Post) ON EACH [p.title, p.content];

// Range index (Neo4j 5+)
CREATE RANGE INDEX user_created IF NOT EXISTS
FOR (u:User) ON (u.createdAt);

// Relationship property index
CREATE INDEX follows_since IF NOT EXISTS
FOR ()-[f:FOLLOWS]-() ON (f.since);
```

### Common Graph Patterns
```cypher
// ==========================================
// SOCIAL NETWORK MODEL
// ==========================================

// User follows User
(:User)-[:FOLLOWS]->(:User)

// User likes Post
(:User)-[:LIKES {likedAt: datetime()}]->(:Post)

// User comments on Post
(:User)-[:COMMENTED {text: '...', commentedAt: datetime()}]->(:Post)

// Post belongs to Category
(:Post)-[:IN_CATEGORY]->(:Category)

// Category hierarchy
(:Category)-[:PARENT_OF]->(:Category)


// ==========================================
// E-COMMERCE MODEL
// ==========================================

// Customer purchases Product
(:Customer)-[:PURCHASED {
  orderId: 'string',
  quantity: 1,
  price: 0.00,
  purchasedAt: datetime()
}]->(:Product)

// Product in Category
(:Product)-[:IN_CATEGORY]->(:Category)

// Product has Reviews
(:Customer)-[:REVIEWED {
  rating: 5,
  text: '...',
  reviewedAt: datetime()
}]->(:Product)

// Similar Products (computed)
(:Product)-[:SIMILAR_TO {score: 0.85}]->(:Product)


// ==========================================
// KNOWLEDGE GRAPH MODEL
// ==========================================

// Entity relationships
(:Person)-[:WORKS_AT]->(:Company)
(:Person)-[:BORN_IN]->(:Location)
(:Company)-[:HEADQUARTERED_IN]->(:Location)
(:Person)-[:KNOWS]->(:Person)

// With temporal properties
(:Person)-[:WORKS_AT {
  role: 'Engineer',
  startDate: date('2020-01-01'),
  endDate: null
}]->(:Company)
```

---

## 2) Cypher Queries

### Basic Queries
```cypher
// ==========================================
// READ QUERIES
// ==========================================

// Find all users
MATCH (u:User)
RETURN u.name, u.email
ORDER BY u.name
LIMIT 10;

// Find by property
MATCH (u:User {email: 'john@example.com'})
RETURN u;

// Find with WHERE clause
MATCH (u:User)
WHERE u.name STARTS WITH 'John'
  AND u.createdAt > datetime('2024-01-01')
RETURN u;

// Find by relationship
MATCH (u:User)-[:FOLLOWS]->(following:User)
WHERE u.email = 'john@example.com'
RETURN following.name, following.email;

// Find with multiple hops
MATCH (u:User {email: 'john@example.com'})-[:FOLLOWS*1..3]->(distant:User)
RETURN DISTINCT distant.name;


// ==========================================
// PATTERN MATCHING
// ==========================================

// Bidirectional relationship
MATCH (a:User)-[:FOLLOWS]-(b:User)
WHERE a.email = 'john@example.com'
RETURN b.name;

// Multiple patterns
MATCH (u:User)-[:AUTHORED]->(p:Post)
MATCH (p)-[:TAGGED_WITH]->(t:Tag)
WHERE t.name = 'database'
RETURN u.name, p.title;

// Optional match (LEFT JOIN equivalent)
MATCH (u:User)
OPTIONAL MATCH (u)-[:AUTHORED]->(p:Post)
RETURN u.name, count(p) AS postCount;

// Negative pattern (NOT EXISTS)
MATCH (u:User)
WHERE NOT EXISTS {
  MATCH (u)-[:FOLLOWS]->(:User)
}
RETURN u.name AS usersWithNoFollowing;


// ==========================================
// AGGREGATIONS
// ==========================================

// Count
MATCH (u:User)-[:FOLLOWS]->(f:User)
RETURN u.name, count(f) AS followingCount
ORDER BY followingCount DESC
LIMIT 10;

// Collect into list
MATCH (u:User)-[:AUTHORED]->(p:Post)
RETURN u.name, collect(p.title) AS posts;

// Multiple aggregations
MATCH (p:Post)
OPTIONAL MATCH (p)<-[l:LIKES]-(:User)
OPTIONAL MATCH (p)<-[c:COMMENTED]-(:User)
RETURN 
  p.title,
  count(DISTINCT l) AS likes,
  count(DISTINCT c) AS comments
ORDER BY likes DESC;
```

### Graph Traversals
```cypher
// ==========================================
// FRIEND RECOMMENDATIONS
// ==========================================

// Friends of friends (not already following)
MATCH (me:User {email: 'john@example.com'})-[:FOLLOWS]->(friend:User)-[:FOLLOWS]->(fof:User)
WHERE NOT (me)-[:FOLLOWS]->(fof)
  AND me <> fof
RETURN fof.name, count(friend) AS mutualFriends
ORDER BY mutualFriends DESC
LIMIT 10;


// ==========================================
// SHORTEST PATH
// ==========================================

// Find shortest connection between two users
MATCH path = shortestPath(
  (a:User {email: 'alice@example.com'})-[:FOLLOWS*..6]->(b:User {email: 'bob@example.com'})
)
RETURN path, length(path) AS hops;

// All shortest paths
MATCH path = allShortestPaths(
  (a:User {email: 'alice@example.com'})-[:FOLLOWS|KNOWS*..6]->(b:User {email: 'bob@example.com'})
)
RETURN path;


// ==========================================
// RECOMMENDATION ENGINE
// ==========================================

// Collaborative filtering: Users who bought X also bought Y
MATCH (u:User)-[:PURCHASED]->(p:Product {name: 'MacBook Pro'})
MATCH (u)-[:PURCHASED]->(other:Product)
WHERE other.name <> 'MacBook Pro'
RETURN other.name, count(u) AS purchaseCount
ORDER BY purchaseCount DESC
LIMIT 5;

// Content-based: Products with similar tags
MATCH (p:Product {id: 'product-123'})-[:HAS_TAG]->(t:Tag)<-[:HAS_TAG]-(similar:Product)
WHERE p <> similar
RETURN similar.name, count(t) AS sharedTags
ORDER BY sharedTags DESC
LIMIT 5;

// Hybrid recommendation
MATCH (me:User {id: 'user-123'})
// Products I've purchased
MATCH (me)-[:PURCHASED]->(myProducts:Product)
// Find similar users (purchased same products)
MATCH (similar:User)-[:PURCHASED]->(myProducts)
WHERE similar <> me
// Find what they purchased that I haven't
MATCH (similar)-[:PURCHASED]->(rec:Product)
WHERE NOT (me)-[:PURCHASED]->(rec)
RETURN rec.name, count(DISTINCT similar) AS score
ORDER BY score DESC
LIMIT 10;


// ==========================================
// FRAUD DETECTION
// ==========================================

// Find circular transaction patterns
MATCH path = (a:Account)-[:TRANSFERRED*3..6]->(a)
WHERE all(r IN relationships(path) WHERE r.amount > 10000)
RETURN path, reduce(total = 0, r IN relationships(path) | total + r.amount) AS totalAmount;

// Find accounts with unusual connection patterns
MATCH (a:Account)-[t:TRANSFERRED]->(b:Account)
WHERE t.timestamp > datetime() - duration('P7D')
WITH a, count(DISTINCT b) AS recipients
WHERE recipients > 50
RETURN a.accountNumber, recipients
ORDER BY recipients DESC;
```

### Write Operations
```cypher
// ==========================================
// CREATE / MERGE
// ==========================================

// Create node
CREATE (u:User {
  id: randomUUID(),
  name: 'New User',
  email: 'new@example.com',
  createdAt: datetime()
})
RETURN u;

// Create with relationship
CREATE (u:User {name: 'Alice'})-[:FOLLOWS {since: date()}]->(f:User {name: 'Bob'})
RETURN u, f;

// MERGE (create if not exists)
MERGE (u:User {email: 'john@example.com'})
ON CREATE SET 
  u.id = randomUUID(),
  u.createdAt = datetime()
ON MATCH SET 
  u.lastLoginAt = datetime()
RETURN u;

// MERGE relationship
MATCH (a:User {email: 'alice@example.com'})
MATCH (b:User {email: 'bob@example.com'})
MERGE (a)-[r:FOLLOWS]->(b)
ON CREATE SET r.since = date()
RETURN r;


// ==========================================
// UPDATE / DELETE
// ==========================================

// Update properties
MATCH (u:User {email: 'john@example.com'})
SET u.name = 'John Updated',
    u.updatedAt = datetime()
RETURN u;

// Add label
MATCH (u:User {email: 'john@example.com'})
SET u:PremiumUser
RETURN u;

// Remove property
MATCH (u:User {email: 'john@example.com'})
REMOVE u.temporaryField
RETURN u;

// Delete relationship
MATCH (a:User {email: 'alice@example.com'})-[r:FOLLOWS]->(b:User {email: 'bob@example.com'})
DELETE r;

// Delete node (must delete relationships first)
MATCH (u:User {email: 'delete@example.com'})
DETACH DELETE u;

// Batch delete
MATCH (u:User)
WHERE u.lastLoginAt < datetime() - duration('P365D')
DETACH DELETE u;


// ==========================================
// UNWIND (List processing)
// ==========================================

// Create multiple nodes from list
UNWIND ['tech', 'science', 'art'] AS tagName
MERGE (t:Tag {name: tagName})
RETURN t;

// Batch create relationships
WITH [
  {from: 'alice@example.com', to: 'bob@example.com'},
  {from: 'alice@example.com', to: 'charlie@example.com'}
] AS follows
UNWIND follows AS f
MATCH (a:User {email: f.from})
MATCH (b:User {email: f.to})
MERGE (a)-[:FOLLOWS]->(b);

// Import from JSON-like structure
WITH {
  users: [
    {name: 'User1', email: 'user1@example.com'},
    {name: 'User2', email: 'user2@example.com'}
  ]
} AS data
UNWIND data.users AS userData
CREATE (u:User)
SET u += userData,
    u.id = randomUUID(),
    u.createdAt = datetime();
```

---

## 3) TypeScript Integration

### Neo4j Driver
```typescript
// ==========================================
// NEO4J DRIVER SETUP
// ==========================================

import neo4j, { Driver, Session, Result } from 'neo4j-driver';

const driver: Driver = neo4j.driver(
  process.env.NEO4J_URI!,
  neo4j.auth.basic(
    process.env.NEO4J_USER!,
    process.env.NEO4J_PASSWORD!
  ),
  {
    maxConnectionPoolSize: 50,
    connectionAcquisitionTimeout: 10000,
    maxTransactionRetryTime: 30000,
  }
);

// Verify connectivity
await driver.verifyConnectivity();

// Cleanup on shutdown
process.on('exit', async () => {
  await driver.close();
});


// ==========================================
// TYPED QUERIES
// ==========================================

interface User {
  id: string;
  name: string;
  email: string;
  createdAt: Date;
}

interface UserWithFollowers extends User {
  followerCount: number;
  followingCount: number;
}

async function getUserByEmail(email: string): Promise<User | null> {
  const session = driver.session();
  
  try {
    const result = await session.run<{ u: User }>(
      `MATCH (u:User {email: $email})
       RETURN u`,
      { email }
    );
    
    if (result.records.length === 0) {
      return null;
    }
    
    const record = result.records[0];
    const node = record.get('u');
    
    return {
      id: node.properties.id,
      name: node.properties.name,
      email: node.properties.email,
      createdAt: node.properties.createdAt.toStandardDate(),
    };
  } finally {
    await session.close();
  }
}

async function createUser(data: Omit<User, 'id' | 'createdAt'>): Promise<User> {
  const session = driver.session();
  
  try {
    const result = await session.run(
      `CREATE (u:User {
        id: randomUUID(),
        name: $name,
        email: $email,
        createdAt: datetime()
      })
      RETURN u`,
      data
    );
    
    const node = result.records[0].get('u');
    
    return {
      id: node.properties.id,
      name: node.properties.name,
      email: node.properties.email,
      createdAt: node.properties.createdAt.toStandardDate(),
    };
  } finally {
    await session.close();
  }
}


// ==========================================
// TRANSACTION HANDLING
// ==========================================

async function followUser(followerEmail: string, followingEmail: string): Promise<boolean> {
  const session = driver.session();
  
  try {
    const result = await session.executeWrite(async (tx) => {
      // Check if relationship already exists
      const existsResult = await tx.run(
        `MATCH (a:User {email: $follower})-[r:FOLLOWS]->(b:User {email: $following})
         RETURN r`,
        { follower: followerEmail, following: followingEmail }
      );
      
      if (existsResult.records.length > 0) {
        return false; // Already following
      }
      
      // Create relationship
      await tx.run(
        `MATCH (a:User {email: $follower})
         MATCH (b:User {email: $following})
         CREATE (a)-[:FOLLOWS {since: date()}]->(b)`,
        { follower: followerEmail, following: followingEmail }
      );
      
      // Update follower counts (denormalized)
      await tx.run(
        `MATCH (a:User {email: $follower})
         MATCH (b:User {email: $following})
         SET a.followingCount = coalesce(a.followingCount, 0) + 1,
             b.followerCount = coalesce(b.followerCount, 0) + 1`,
        { follower: followerEmail, following: followingEmail }
      );
      
      return true;
    });
    
    return result;
  } finally {
    await session.close();
  }
}


// ==========================================
// REPOSITORY PATTERN
// ==========================================

class UserRepository {
  constructor(private driver: Driver) {}

  async findById(id: string): Promise<User | null> {
    const session = this.driver.session();
    
    try {
      const result = await session.run(
        `MATCH (u:User {id: $id}) RETURN u`,
        { id }
      );
      
      return result.records.length > 0
        ? this.mapUser(result.records[0].get('u'))
        : null;
    } finally {
      await session.close();
    }
  }

  async findFollowers(userId: string, limit: number = 20): Promise<User[]> {
    const session = this.driver.session();
    
    try {
      const result = await session.run(
        `MATCH (u:User {id: $userId})<-[:FOLLOWS]-(follower:User)
         RETURN follower
         ORDER BY follower.name
         LIMIT $limit`,
        { userId, limit: neo4j.int(limit) }
      );
      
      return result.records.map(r => this.mapUser(r.get('follower')));
    } finally {
      await session.close();
    }
  }

  async findRecommendations(userId: string, limit: number = 10): Promise<User[]> {
    const session = this.driver.session();
    
    try {
      const result = await session.run(
        `MATCH (me:User {id: $userId})-[:FOLLOWS]->(friend:User)-[:FOLLOWS]->(fof:User)
         WHERE NOT (me)-[:FOLLOWS]->(fof)
           AND me <> fof
         RETURN fof, count(friend) AS mutual
         ORDER BY mutual DESC
         LIMIT $limit`,
        { userId, limit: neo4j.int(limit) }
      );
      
      return result.records.map(r => this.mapUser(r.get('fof')));
    } finally {
      await session.close();
    }
  }

  private mapUser(node: any): User {
    return {
      id: node.properties.id,
      name: node.properties.name,
      email: node.properties.email,
      createdAt: node.properties.createdAt?.toStandardDate() ?? new Date(),
    };
  }
}
```

---

## 4) Graph Algorithms

### Built-in Algorithms (GDS Library)
```cypher
// ==========================================
// PAGERANK
// ==========================================

// Create graph projection
CALL gds.graph.project(
  'social-network',
  'User',
  'FOLLOWS'
);

// Run PageRank
CALL gds.pageRank.stream('social-network')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC
LIMIT 10;

// Write results back to nodes
CALL gds.pageRank.write('social-network', {
  writeProperty: 'pageRank'
});


// ==========================================
// COMMUNITY DETECTION (Louvain)
// ==========================================

CALL gds.louvain.stream('social-network')
YIELD nodeId, communityId
RETURN communityId, collect(gds.util.asNode(nodeId).name) AS members
ORDER BY size(members) DESC;


// ==========================================
// SIMILARITY (Node Similarity)
// ==========================================

CALL gds.graph.project(
  'user-products',
  ['User', 'Product'],
  {PURCHASED: {orientation: 'UNDIRECTED'}}
);

CALL gds.nodeSimilarity.stream('user-products')
YIELD node1, node2, similarity
WHERE gds.util.asNode(node1):User AND gds.util.asNode(node2):User
RETURN 
  gds.util.asNode(node1).name AS user1,
  gds.util.asNode(node2).name AS user2,
  similarity
ORDER BY similarity DESC
LIMIT 10;


// ==========================================
// CENTRALITY (Betweenness)
// ==========================================

// Find influential nodes (bridges between communities)
CALL gds.betweenness.stream('social-network')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC
LIMIT 10;
```

---

## 5) Performance Optimization

### Query Profiling
```cypher
// ==========================================
// PROFILE AND EXPLAIN
// ==========================================

// EXPLAIN: Show query plan without executing
EXPLAIN
MATCH (u:User)-[:FOLLOWS]->(f:User)
WHERE u.email = 'john@example.com'
RETURN f.name;

// PROFILE: Execute and show actual metrics
PROFILE
MATCH (u:User)-[:FOLLOWS]->(f:User)
WHERE u.email = 'john@example.com'
RETURN f.name;

// Look for:
// - Db Hits (lower is better)
// - Rows (check for cartesian products)
// - NodeByLabelScan vs NodeIndexSeek


// ==========================================
// OPTIMIZATION PATTERNS
// ==========================================

// ❌ BAD: No index usage
MATCH (u:User)
WHERE u.name = 'John'
RETURN u;

// ✅ GOOD: Use indexed property for lookup
MATCH (u:User {email: 'john@example.com'})
RETURN u;

// ❌ BAD: Unbounded variable-length path
MATCH (a:User)-[:FOLLOWS*]->(b:User)
RETURN a, b;

// ✅ GOOD: Bounded path length
MATCH (a:User)-[:FOLLOWS*1..3]->(b:User)
RETURN a, b;

// ❌ BAD: Cartesian product
MATCH (u:User), (p:Product)
RETURN u, p;

// ✅ GOOD: Connected patterns
MATCH (u:User)-[:PURCHASED]->(p:Product)
RETURN u, p;

// ❌ BAD: Filtering after match
MATCH (u:User)-[:FOLLOWS]->(f:User)
WITH u, f
WHERE u.email = 'john@example.com'
RETURN f;

// ✅ GOOD: Filter early
MATCH (u:User {email: 'john@example.com'})-[:FOLLOWS]->(f:User)
RETURN f;

// Use parameters (enables query caching)
MATCH (u:User {email: $email})
RETURN u;
```

### Avoiding Super Nodes
```cypher
// ==========================================
// SUPER NODE PROBLEM
// ==========================================

// Super nodes: Nodes with millions of relationships
// Example: A celebrity with 10M followers

// ❌ BAD: Direct query on super node
MATCH (celebrity:User {name: 'Celebrity'})<-[:FOLLOWS]-(follower:User)
RETURN count(follower);  // Slow!

// ✅ GOOD: Use intermediate fanout layer
// Instead of: (Celebrity)<-[:FOLLOWS]-(Millions of users)
// Model as: (Celebrity)<-[:FAN_OF]-(Fan Page)<-[:MEMBER_OF]-(Users)

// ✅ GOOD: Store aggregated counts
MATCH (u:User {name: 'Celebrity'})
RETURN u.followerCount;  // Pre-computed

// ✅ GOOD: Limit results
MATCH (u:User {name: 'Celebrity'})<-[:FOLLOWS]-(follower:User)
RETURN follower
LIMIT 100;


// ==========================================
// BATCH OPERATIONS
// ==========================================

// Process in batches using CALL {} IN TRANSACTIONS
CALL {
  MATCH (u:User)
  WHERE u.lastActive < datetime() - duration('P365D')
  RETURN u
} IN TRANSACTIONS OF 1000 ROWS
  DETACH DELETE u;

// Bulk property update
CALL {
  MATCH (u:User)
  WHERE u.score IS NULL
  RETURN u
} IN TRANSACTIONS OF 5000 ROWS
  SET u.score = 0;
```

---

## 6) Use Case Examples

### Social Network
```cypher
// Complete social network queries

// Mutual friends
MATCH (me:User {email: $email})-[:FOLLOWS]->(mutual:User)<-[:FOLLOWS]-(other:User)
WHERE NOT (me)-[:FOLLOWS]->(other)
  AND me <> other
RETURN other.name, count(mutual) AS mutualFriends
ORDER BY mutualFriends DESC
LIMIT 10;

// Activity feed
MATCH (me:User {email: $email})-[:FOLLOWS]->(friend:User)
MATCH (friend)-[:AUTHORED]->(post:Post)
WHERE post.publishedAt > datetime() - duration('P7D')
OPTIONAL MATCH (post)<-[l:LIKES]-(:User)
OPTIONAL MATCH (post)<-[c:COMMENTED]-(:User)
RETURN 
  post.title,
  post.publishedAt,
  friend.name AS author,
  count(DISTINCT l) AS likes,
  count(DISTINCT c) AS comments
ORDER BY post.publishedAt DESC
LIMIT 20;

// Trending posts
MATCH (p:Post)
WHERE p.publishedAt > datetime() - duration('P24H')
OPTIONAL MATCH (p)<-[l:LIKES]-(:User)
WITH p, count(l) AS likeCount
ORDER BY likeCount DESC
LIMIT 10
MATCH (p)<-[:AUTHORED]-(author:User)
RETURN p.title, author.name, likeCount;
```

---

## Best Practices Checklist

### Data Modeling
- [ ] Identify core entities (nodes)
- [ ] Define relationships with meaning
- [ ] Avoid high-degree super nodes
- [ ] Use labels for categorization

### Querying
- [ ] Use indexes for lookups
- [ ] Bound variable-length paths
- [ ] Filter early in queries
- [ ] Use parameters

### Performance
- [ ] Profile slow queries
- [ ] Create appropriate indexes
- [ ] Batch large operations
- [ ] Monitor heap and cache

### Operations
- [ ] Regular backups
- [ ] Monitor disk usage
- [ ] Use bulk import for large data
- [ ] Test query performance

---

**References:**
- [Neo4j Documentation](https://neo4j.com/docs/)
- [Cypher Manual](https://neo4j.com/docs/cypher-manual/)
- [Neo4j Graph Data Science](https://neo4j.com/docs/graph-data-science/)

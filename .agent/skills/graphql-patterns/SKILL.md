---
name: GraphQL Patterns
description: "Các mẫu thiết kế GraphQL API toàn diện, cấu trúc schema và best practices."
category: API Development
difficulty: Intermediate
last_updated: 2026-01-16
---

# GraphQL Patterns

Expert patterns for building efficient, scalable GraphQL APIs.

---

## When to Use This Skill

- Building GraphQL APIs
- Designing GraphQL schemas
- Implementing resolvers
- Optimizing query performance
- Federation and microservices

---

## Content Map

### Core Concepts
- GraphQL vs REST
- Schema definition language
- Type system
- Queries, Mutations, Subscriptions

### Schema Design
- **schema-design.md** - Best practices for schema organization
- Object types and interfaces
- Input types
- Enums and scalars
- Directives

### Resolvers
- **resolvers.md** - Resolver implementation patterns
- Data fetching strategies
- Error handling
- Context and authentication

### Performance
- **performance.md** - Query optimization
- N+1 problem solutions (DataLoader)
- Caching strategies
- Complexity analysis
- Query depth limiting

### Security
- **security.md** - Authentication patterns
- Authorization (field-level)
- Rate limiting
- Query complexity limits
- Preventing malicious queries

### Testing
- **testing.md** - Testing strategies
- Unit testing resolvers
- Integration testing
- Schema validation

---

## Quick Reference

### Schema Example
```graphql
type User {
  id: ID!
  name: String!
  email: String!
  posts: [Post!]!
}

type Post {
  id: ID!
  title: String!
  content: String
  author: User!
}

type Query {
  user(id: ID!): User
  users(limit: Int, offset: Int): [User!]!
  post(id: ID!): Post
}

type Mutation {
  createPost(input: CreatePostInput!): Post!
  updatePost(id: ID!, input: UpdatePostInput!): Post!
}

input CreatePostInput {
  title: String!
  content: String
}
```

### Resolver Pattern
```javascript
const resolvers = {
  Query: {
    user: async (parent, { id }, context) => {
      return context.dataSources.userAPI.getUser(id);
    },
  },
  User: {
    posts: async (user, args, { dataSources }) => {
      return dataSources.postAPI.getPostsByUser(user.id);
    },
  },
  Mutation: {
    createPost: async (parent, { input }, { user, dataSources }) => {
      if (!user) throw new Error('Unauthorized');
      return dataSources.postAPI.createPost(input);
    },
  },
};
```

### DataLoader (N+1 Solution)
```javascript
const DataLoader = require('dataloader');

const userLoader = new DataLoader(async (userIds) => {
  const users = await User.findAll({
    where: { id: userIds }
  });
  return userIds.map(id => users.find(u => u.id === id));
});

// Usage in resolver
posts: async (user) => {
  const author = await userLoader.load(user.authorId);
  return author.posts;
}
```

---

## Anti-Patterns

❌ **Exposing entire database schema** → Design for clients  
❌ **No pagination** → Always paginate lists  
❌ **Ignoring N+1 problem** → Use DataLoader  
❌ **Deep nesting without limits** → Set max depth  
❌ **No error handling** → Proper error responses

---

## Best Practices

✅ **Schema-first design** - Define schema before implementation  
✅ **DataLoader** for batching and caching  
✅ **Pagination** (cursor-based preferred)  
✅ **Field-level authorization**  
✅ **Query complexity analysis**  
✅ **Comprehensive error handling**

---

## Related Skills

- `api-patterns` - General API design
- `nodejs-best-practices` - Node.js implementation
- `database-design` - Data modeling

---

## Official Resources

- [GraphQL.org](https://graphql.org/)
- [Apollo Server Docs](https://www.apollographql.com/docs/apollo-server/)
- [GraphQL Best Practices](https://graphql.org/learn/best-practices/)

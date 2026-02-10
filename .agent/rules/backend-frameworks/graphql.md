# GraphQL Server Development Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Standards:** GraphQL Spec 2021, Relay Cursor Connections
> **Priority:** P1 - Load for GraphQL projects

---

You are an expert in GraphQL server development with TypeScript.

## Key Principles

- Ask for what you need, get exactly that
- Single endpoint for all operations
- Strongly typed schema
- Self-documenting with introspection
- Versioning through schema evolution
- Demand-driven schema design

---

## Project Structure

```
src/
├── graphql/
│   ├── schema.ts           # Combined schema
│   ├── context.ts          # Context setup
│   ├── types/
│   │   ├── user.ts         # User type + resolvers
│   │   ├── post.ts         # Post type + resolvers
│   │   └── index.ts
│   ├── scalars/            # Custom scalars
│   ├── directives/         # Custom directives
│   └── loaders/            # DataLoaders
├── services/
├── db/
└── server.ts
```

---

## GraphQL Yoga Setup

### Basic Server
```typescript
// server.ts
import { createServer } from 'node:http';
import { createYoga } from 'graphql-yoga';
import { schema } from './graphql/schema';
import { createContext, Context } from './graphql/context';

const yoga = createYoga<Context>({
  schema,
  context: createContext,
  graphiql: process.env.NODE_ENV !== 'production',
  maskedErrors: process.env.NODE_ENV === 'production',
  cors: {
    origin: process.env.CORS_ORIGIN?.split(',') || '*',
    credentials: true,
  },
  // Security
  plugins: [
    // Disable introspection in production
    process.env.NODE_ENV === 'production' && useDisableIntrospection(),
  ].filter(Boolean),
});

const server = createServer(yoga);

server.listen(4000, () => {
  console.log('GraphQL server running at http://localhost:4000/graphql');
});
```

### Context Setup
```typescript
// graphql/context.ts
import { YogaInitialContext } from 'graphql-yoga';
import { PrismaClient, User } from '@prisma/client';
import { createLoaders, Loaders } from './loaders';
import { verifyToken } from '../utils/auth';

const prisma = new PrismaClient();

export interface Context {
  prisma: PrismaClient;
  currentUser: User | null;
  loaders: Loaders;
}

export async function createContext(
  initialContext: YogaInitialContext
): Promise<Context> {
  const { request } = initialContext;
  
  // Get auth token
  const authHeader = request.headers.get('authorization');
  let currentUser: User | null = null;
  
  if (authHeader?.startsWith('Bearer ')) {
    const token = authHeader.slice(7);
    try {
      const payload = verifyToken(token);
      currentUser = await prisma.user.findUnique({
        where: { id: payload.userId },
      });
    } catch {
      // Invalid token - user remains null
    }
  }
  
  return {
    prisma,
    currentUser,
    loaders: createLoaders(prisma),
  };
}
```

---

## Schema-First Approach

### Schema Definition (SDL)
```graphql
# schema.graphql
scalar DateTime
scalar JSON

type Query {
  me: User
  user(id: ID!): User
  users(
    first: Int
    after: String
    filter: UserFilter
  ): UserConnection!
  
  post(id: ID!): Post
  posts(
    first: Int = 10
    after: String
    filter: PostFilter
    orderBy: PostOrderBy
  ): PostConnection!
}

type Mutation {
  # Auth
  signUp(input: SignUpInput!): AuthPayload!
  signIn(input: SignInInput!): AuthPayload!
  
  # User
  updateProfile(input: UpdateProfileInput!): User!
  
  # Post
  createPost(input: CreatePostInput!): Post!
  updatePost(id: ID!, input: UpdatePostInput!): Post!
  deletePost(id: ID!): Boolean!
  
  # Like
  likePost(postId: ID!): Post!
  unlikePost(postId: ID!): Post!
}

type Subscription {
  postCreated: Post!
  commentAdded(postId: ID!): Comment!
}

# Types
type User {
  id: ID!
  name: String!
  email: String!
  avatar: String
  role: UserRole!
  posts(first: Int, after: String): PostConnection!
  createdAt: DateTime!
  updatedAt: DateTime!
}

type Post {
  id: ID!
  title: String!
  content: String!
  published: Boolean!
  author: User!
  comments(first: Int, after: String): CommentConnection!
  likeCount: Int!
  isLikedByMe: Boolean!
  createdAt: DateTime!
  updatedAt: DateTime!
}

type Comment {
  id: ID!
  text: String!
  author: User!
  post: Post!
  createdAt: DateTime!
}

# Connections (Relay Cursor Pagination)
type UserConnection {
  edges: [UserEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type UserEdge {
  cursor: String!
  node: User!
}

type PostConnection {
  edges: [PostEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type PostEdge {
  cursor: String!
  node: Post!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}

# Inputs
input SignUpInput {
  name: String!
  email: String!
  password: String!
}

input SignInInput {
  email: String!
  password: String!
}

input CreatePostInput {
  title: String!
  content: String!
  published: Boolean = false
}

input UpdatePostInput {
  title: String
  content: String
  published: Boolean
}

input UserFilter {
  search: String
  role: UserRole
}

input PostFilter {
  authorId: ID
  published: Boolean
  search: String
}

input PostOrderBy {
  field: PostOrderField!
  direction: OrderDirection!
}

# Enums
enum UserRole {
  USER
  ADMIN
  MODERATOR
}

enum PostOrderField {
  CREATED_AT
  UPDATED_AT
  TITLE
  LIKE_COUNT
}

enum OrderDirection {
  ASC
  DESC
}

# Payloads
type AuthPayload {
  token: String!
  user: User!
}
```

---

## Code-First with Pothos

### Setup
```typescript
// graphql/builder.ts
import SchemaBuilder from '@pothos/core';
import PrismaPlugin from '@pothos/plugin-prisma';
import RelayPlugin from '@pothos/plugin-relay';
import ValidationPlugin from '@pothos/plugin-validation';
import type PrismaTypes from '@pothos/plugin-prisma/generated';
import { prisma } from '../db';
import { Context } from './context';

export const builder = new SchemaBuilder<{
  Context: Context;
  PrismaTypes: PrismaTypes;
  Scalars: {
    DateTime: {
      Input: Date;
      Output: Date;
    };
  };
}>({
  plugins: [PrismaPlugin, RelayPlugin, ValidationPlugin],
  prisma: {
    client: prisma,
  },
  relay: {
    cursorType: 'String',
    clientMutationId: 'omit',
    edgesFieldOptions: {
      nullable: false,
    },
  },
});

// Base types
builder.queryType({});
builder.mutationType({});
builder.subscriptionType({});
```

### User Type with Pothos
```typescript
// graphql/types/user.ts
import { builder } from '../builder';

// Define User object type from Prisma
builder.prismaObject('User', {
  fields: (t) => ({
    id: t.exposeID('id'),
    name: t.exposeString('name'),
    email: t.exposeString('email', {
      // Only expose email to self or admin
      authScopes: (user, _args, ctx) => 
        ctx.currentUser?.id === user.id || 
        ctx.currentUser?.role === 'ADMIN',
    }),
    avatar: t.exposeString('avatar', { nullable: true }),
    role: t.expose('role', { type: UserRole }),
    createdAt: t.expose('createdAt', { type: 'DateTime' }),
    
    // Relations
    posts: t.relatedConnection('posts', {
      cursor: 'id',
      totalCount: true,
      query: () => ({
        where: { published: true },
        orderBy: { createdAt: 'desc' },
      }),
    }),
    
    // Computed field
    postCount: t.int({
      resolve: async (user, _args, ctx) => {
        return ctx.loaders.userPostCount.load(user.id);
      },
    }),
  }),
});

// Enum
const UserRole = builder.enumType('UserRole', {
  values: ['USER', 'ADMIN', 'MODERATOR'] as const,
});

// Queries
builder.queryField('me', (t) =>
  t.prismaField({
    type: 'User',
    nullable: true,
    resolve: (query, _root, _args, ctx) => {
      if (!ctx.currentUser) return null;
      return ctx.prisma.user.findUnique({
        ...query,
        where: { id: ctx.currentUser.id },
      });
    },
  })
);

builder.queryField('user', (t) =>
  t.prismaField({
    type: 'User',
    nullable: true,
    args: {
      id: t.arg.id({ required: true }),
    },
    resolve: (query, _root, args, ctx) => {
      return ctx.prisma.user.findUnique({
        ...query,
        where: { id: String(args.id) },
      });
    },
  })
);

builder.queryField('users', (t) =>
  t.prismaConnection({
    type: 'User',
    cursor: 'id',
    totalCount: true,
    args: {
      search: t.arg.string(),
      role: t.arg({ type: UserRole }),
    },
    resolve: (query, _root, args, ctx) => {
      return ctx.prisma.user.findMany({
        ...query,
        where: {
          ...(args.search && {
            OR: [
              { name: { contains: args.search, mode: 'insensitive' } },
              { email: { contains: args.search, mode: 'insensitive' } },
            ],
          }),
          ...(args.role && { role: args.role }),
        },
        orderBy: { createdAt: 'desc' },
      });
    },
  })
);
```

### Post Type with Mutations
```typescript
// graphql/types/post.ts
import { builder } from '../builder';
import { GraphQLError } from 'graphql';

builder.prismaObject('Post', {
  fields: (t) => ({
    id: t.exposeID('id'),
    title: t.exposeString('title'),
    content: t.exposeString('content'),
    published: t.exposeBoolean('published'),
    createdAt: t.expose('createdAt', { type: 'DateTime' }),
    updatedAt: t.expose('updatedAt', { type: 'DateTime' }),
    
    // Relations
    author: t.relation('author'),
    comments: t.relatedConnection('comments', {
      cursor: 'id',
      totalCount: true,
    }),
    
    // Computed fields
    likeCount: t.int({
      resolve: (post, _args, ctx) => ctx.loaders.postLikeCount.load(post.id),
    }),
    
    isLikedByMe: t.boolean({
      resolve: async (post, _args, ctx) => {
        if (!ctx.currentUser) return false;
        return ctx.loaders.isPostLikedByUser.load({
          postId: post.id,
          userId: ctx.currentUser.id,
        });
      },
    }),
  }),
});

// Input types
const CreatePostInput = builder.inputType('CreatePostInput', {
  fields: (t) => ({
    title: t.string({ required: true, validate: { minLength: 3, maxLength: 200 } }),
    content: t.string({ required: true, validate: { minLength: 10 } }),
    published: t.boolean({ defaultValue: false }),
  }),
});

const UpdatePostInput = builder.inputType('UpdatePostInput', {
  fields: (t) => ({
    title: t.string({ validate: { minLength: 3, maxLength: 200 } }),
    content: t.string({ validate: { minLength: 10 } }),
    published: t.boolean(),
  }),
});

// Mutations
builder.mutationField('createPost', (t) =>
  t.prismaField({
    type: 'Post',
    args: {
      input: t.arg({ type: CreatePostInput, required: true }),
    },
    authScopes: { isAuthenticated: true },
    resolve: async (query, _root, args, ctx) => {
      return ctx.prisma.post.create({
        ...query,
        data: {
          title: args.input.title,
          content: args.input.content,
          published: args.input.published ?? false,
          authorId: ctx.currentUser!.id,
        },
      });
    },
  })
);

builder.mutationField('updatePost', (t) =>
  t.prismaField({
    type: 'Post',
    args: {
      id: t.arg.id({ required: true }),
      input: t.arg({ type: UpdatePostInput, required: true }),
    },
    authScopes: { isAuthenticated: true },
    resolve: async (query, _root, args, ctx) => {
      const post = await ctx.prisma.post.findUnique({
        where: { id: String(args.id) },
      });
      
      if (!post) {
        throw new GraphQLError('Post not found', {
          extensions: { code: 'NOT_FOUND' },
        });
      }
      
      if (post.authorId !== ctx.currentUser!.id && ctx.currentUser!.role !== 'ADMIN') {
        throw new GraphQLError('Not authorized', {
          extensions: { code: 'FORBIDDEN' },
        });
      }
      
      return ctx.prisma.post.update({
        ...query,
        where: { id: String(args.id) },
        data: {
          ...(args.input.title && { title: args.input.title }),
          ...(args.input.content && { content: args.input.content }),
          ...(args.input.published !== null && { published: args.input.published }),
        },
      });
    },
  })
);

builder.mutationField('deletePost', (t) =>
  t.boolean({
    args: {
      id: t.arg.id({ required: true }),
    },
    authScopes: { isAuthenticated: true },
    resolve: async (_root, args, ctx) => {
      const post = await ctx.prisma.post.findUnique({
        where: { id: String(args.id) },
      });
      
      if (!post) {
        throw new GraphQLError('Post not found', {
          extensions: { code: 'NOT_FOUND' },
        });
      }
      
      if (post.authorId !== ctx.currentUser!.id && ctx.currentUser!.role !== 'ADMIN') {
        throw new GraphQLError('Not authorized', {
          extensions: { code: 'FORBIDDEN' },
        });
      }
      
      await ctx.prisma.post.delete({
        where: { id: String(args.id) },
      });
      
      return true;
    },
  })
);
```

---

## DataLoader (N+1 Prevention)

```typescript
// graphql/loaders/index.ts
import DataLoader from 'dataloader';
import { PrismaClient, User, Post } from '@prisma/client';

export interface Loaders {
  userById: DataLoader<string, User | null>;
  postsByAuthor: DataLoader<string, Post[]>;
  postLikeCount: DataLoader<string, number>;
  userPostCount: DataLoader<string, number>;
  isPostLikedByUser: DataLoader<{ postId: string; userId: string }, boolean>;
}

export function createLoaders(prisma: PrismaClient): Loaders {
  return {
    // Load users by ID
    userById: new DataLoader(async (ids) => {
      const users = await prisma.user.findMany({
        where: { id: { in: [...ids] } },
      });
      
      const userMap = new Map(users.map(u => [u.id, u]));
      return ids.map(id => userMap.get(id) ?? null);
    }),
    
    // Load posts for multiple authors
    postsByAuthor: new DataLoader(async (authorIds) => {
      const posts = await prisma.post.findMany({
        where: { authorId: { in: [...authorIds] } },
        orderBy: { createdAt: 'desc' },
      });
      
      const postMap = new Map<string, Post[]>();
      posts.forEach(post => {
        const existing = postMap.get(post.authorId) || [];
        postMap.set(post.authorId, [...existing, post]);
      });
      
      return authorIds.map(id => postMap.get(id) || []);
    }),
    
    // Load like counts for posts
    postLikeCount: new DataLoader(async (postIds) => {
      const counts = await prisma.like.groupBy({
        by: ['postId'],
        where: { postId: { in: [...postIds] } },
        _count: { id: true },
      });
      
      const countMap = new Map(counts.map(c => [c.postId, c._count.id]));
      return postIds.map(id => countMap.get(id) ?? 0);
    }),
    
    // Load post counts for users
    userPostCount: new DataLoader(async (userIds) => {
      const counts = await prisma.post.groupBy({
        by: ['authorId'],
        where: { 
          authorId: { in: [...userIds] },
          published: true,
        },
        _count: { id: true },
      });
      
      const countMap = new Map(counts.map(c => [c.authorId, c._count.id]));
      return userIds.map(id => countMap.get(id) ?? 0);
    }),
    
    // Check if user liked posts (batch)
    isPostLikedByUser: new DataLoader(
      async (keys) => {
        const likes = await prisma.like.findMany({
          where: {
            OR: keys.map(({ postId, userId }) => ({
              postId,
              userId,
            })),
          },
        });
        
        const likeSet = new Set(
          likes.map(l => `${l.postId}:${l.userId}`)
        );
        
        return keys.map(({ postId, userId }) => 
          likeSet.has(`${postId}:${userId}`)
        );
      },
      {
        cacheKeyFn: (key) => `${key.postId}:${key.userId}`,
      }
    ),
  };
}
```

---

## Subscriptions

```typescript
// graphql/types/subscriptions.ts
import { builder } from '../builder';
import { pubSub } from '../pubsub';

// PubSub setup (use Redis for production)
import { createPubSub } from 'graphql-yoga';

export const pubSub = createPubSub<{
  'POST_CREATED': [post: Post];
  'COMMENT_ADDED': [postId: string, comment: Comment];
}>();

// Subscription fields
builder.subscriptionField('postCreated', (t) =>
  t.prismaField({
    type: 'Post',
    subscribe: () => pubSub.subscribe('POST_CREATED'),
    resolve: (query, post) => post,
  })
);

builder.subscriptionField('commentAdded', (t) =>
  t.prismaField({
    type: 'Comment',
    args: {
      postId: t.arg.id({ required: true }),
    },
    subscribe: (_root, args) => 
      pubSub.subscribe('COMMENT_ADDED', String(args.postId)),
    resolve: (_query, [_postId, comment]) => comment,
  })
);

// Publish in mutations
builder.mutationField('createComment', (t) =>
  t.prismaField({
    type: 'Comment',
    args: {
      postId: t.arg.id({ required: true }),
      text: t.arg.string({ required: true }),
    },
    authScopes: { isAuthenticated: true },
    resolve: async (query, _root, args, ctx) => {
      const comment = await ctx.prisma.comment.create({
        ...query,
        data: {
          text: args.text,
          postId: String(args.postId),
          authorId: ctx.currentUser!.id,
        },
      });
      
      // Publish event
      pubSub.publish('COMMENT_ADDED', String(args.postId), comment);
      
      return comment;
    },
  })
);
```

---

## Error Handling

```typescript
// utils/errors.ts
import { GraphQLError, GraphQLErrorExtensions } from 'graphql';

type ErrorCode = 
  | 'BAD_REQUEST'
  | 'UNAUTHORIZED'
  | 'FORBIDDEN'
  | 'NOT_FOUND'
  | 'CONFLICT'
  | 'VALIDATION_ERROR'
  | 'INTERNAL_ERROR';

export function createGraphQLError(
  message: string,
  code: ErrorCode,
  extensions?: Record<string, unknown>
): GraphQLError {
  return new GraphQLError(message, {
    extensions: {
      code,
      ...extensions,
    },
  });
}

// Predefined errors
export const errors = {
  unauthorized: (message = 'You must be logged in') =>
    createGraphQLError(message, 'UNAUTHORIZED'),
  
  forbidden: (message = 'You do not have permission') =>
    createGraphQLError(message, 'FORBIDDEN'),
  
  notFound: (resource: string) =>
    createGraphQLError(`${resource} not found`, 'NOT_FOUND'),
  
  conflict: (message: string) =>
    createGraphQLError(message, 'CONFLICT'),
  
  validation: (field: string, message: string) =>
    createGraphQLError(message, 'VALIDATION_ERROR', { field }),
};

// Usage in resolvers
if (!post) {
  throw errors.notFound('Post');
}

if (post.authorId !== ctx.currentUser?.id) {
  throw errors.forbidden('You can only edit your own posts');
}
```

---

## Security

### Query Complexity & Depth Limiting
```typescript
import { createYoga } from 'graphql-yoga';
import { useDepthLimit } from '@graphql-yoga/plugin-depth-limit';
import { useQueryComplexity } from '@graphql-yoga/plugin-query-complexity';

const yoga = createYoga({
  schema,
  plugins: [
    // Limit query depth
    useDepthLimit({
      maxDepth: 10,
      ignore: ['__schema', '__type'],
    }),
    
    // Limit query complexity
    useQueryComplexity({
      maximumComplexity: 1000,
      estimators: [
        // Connection fields are more expensive
        (args) => {
          if (args.field.name.endsWith('Connection')) {
            return (args.args.first ?? 10) * 10;
          }
          return 1;
        },
      ],
    }),
  ],
});
```

### Auth Scopes (Pothos)
```typescript
// graphql/builder.ts
import ScopeAuthPlugin from '@pothos/plugin-scope-auth';

export const builder = new SchemaBuilder<{
  Context: Context;
  AuthScopes: {
    isAuthenticated: boolean;
    isAdmin: boolean;
  };
}>({
  plugins: [ScopeAuthPlugin],
  authScopes: async (ctx) => ({
    isAuthenticated: !!ctx.currentUser,
    isAdmin: ctx.currentUser?.role === 'ADMIN',
  }),
});

// Usage
builder.mutationField('deleteUser', (t) =>
  t.boolean({
    args: { id: t.arg.id({ required: true }) },
    authScopes: { isAdmin: true }, // Only admins
    resolve: async (_root, args, ctx) => {
      // ...
    },
  })
);
```

---

## Testing

```typescript
// tests/graphql/user.test.ts
import { describe, it, expect, beforeAll } from 'vitest';
import { createYoga } from 'graphql-yoga';
import { schema } from '../../src/graphql/schema';
import { createTestContext } from '../utils';

describe('User Queries', () => {
  const yoga = createYoga({
    schema,
    context: createTestContext,
  });
  
  it('should return current user for authenticated request', async () => {
    const response = await yoga.fetch('http://localhost/graphql', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer valid-test-token',
      },
      body: JSON.stringify({
        query: `
          query {
            me {
              id
              name
              email
            }
          }
        `,
      }),
    });
    
    const result = await response.json();
    
    expect(result.errors).toBeUndefined();
    expect(result.data.me).toMatchObject({
      name: 'Test User',
      email: 'test@example.com',
    });
  });
  
  it('should return null for unauthenticated request', async () => {
    const response = await yoga.fetch('http://localhost/graphql', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        query: `query { me { id } }`,
      }),
    });
    
    const result = await response.json();
    
    expect(result.errors).toBeUndefined();
    expect(result.data.me).toBeNull();
  });
});
```

---

## Best Practices Checklist

- [ ] Use Relay Cursor Connections for pagination
- [ ] Implement DataLoader for N+1 prevention
- [ ] Use Pothos for type-safe code-first schemas
- [ ] Limit query depth and complexity
- [ ] Disable introspection in production
- [ ] Use custom error codes consistently
- [ ] Generate TypeScript types with codegen
- [ ] Implement proper auth scopes
- [ ] Use persisted queries in production
- [ ] Monitor query performance

---

## See Also

- [websocket.md](websocket.md) — Real-time transport for GraphQL Subscriptions
- [connect-rpc.md](connect-rpc.md) — Type-safe RPC alternative with Protocol Buffers

---

**References:**
- [GraphQL Specification](https://spec.graphql.org/)
- [GraphQL Yoga](https://the-guild.dev/graphql/yoga-server)
- [Pothos GraphQL](https://pothos-graphql.dev/)
- [Relay Cursor Connections](https://relay.dev/graphql/connections.htm)
- [DataLoader](https://github.com/graphql/dataloader)

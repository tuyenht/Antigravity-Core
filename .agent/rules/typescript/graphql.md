# GraphQL with TypeScript Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **GraphQL Codegen:** 5.x  
> **Apollo:** 4.x  
> **TypeScript:** 5.x  
> **Priority:** P0 - Load for GraphQL projects

---

You are an expert in GraphQL development with TypeScript.

## Core Principles

- Use GraphQL Code Generator for type safety
- Type all resolvers and queries
- Implement schema-first or code-first approach
- Use typed GraphQL clients

---

## 1) Project Structure

### Recommended Structure
```
src/
├── graphql/
│   ├── schema/                  # Schema files
│   │   ├── user.graphql
│   │   ├── post.graphql
│   │   └── index.graphql
│   ├── resolvers/               # Resolvers
│   │   ├── user.resolver.ts
│   │   ├── post.resolver.ts
│   │   └── index.ts
│   ├── dataloaders/             # DataLoaders
│   │   ├── user.loader.ts
│   │   └── index.ts
│   ├── directives/              # Custom directives
│   ├── scalars/                 # Custom scalars
│   └── context.ts               # Context type
├── generated/                   # Generated types
│   └── graphql.ts
├── services/                    # Business logic
├── models/                      # Data models
└── server.ts
```

---

## 2) GraphQL Code Generator

### Configuration
```typescript
// ==========================================
// codegen.ts
// ==========================================

import type { CodegenConfig } from '@graphql-codegen/cli';

const config: CodegenConfig = {
  schema: './src/graphql/schema/**/*.graphql',
  documents: './src/**/*.{ts,tsx}',
  generates: {
    // Server types (resolvers)
    './src/generated/graphql.ts': {
      plugins: [
        'typescript',
        'typescript-resolvers',
      ],
      config: {
        useIndexSignature: true,
        contextType: '../graphql/context#Context',
        mappers: {
          User: '../models/user#UserModel',
          Post: '../models/post#PostModel',
        },
        enumsAsTypes: true,
        scalars: {
          DateTime: 'Date',
          JSON: 'Record<string, unknown>',
        },
      },
    },
    // Client types (React hooks)
    './src/generated/client.ts': {
      documents: './src/client/**/*.graphql',
      plugins: [
        'typescript',
        'typescript-operations',
        'typescript-react-apollo',
      ],
      config: {
        withHooks: true,
        withHOC: false,
        withComponent: false,
        dedupeFragments: true,
      },
    },
    // Introspection for Apollo Client
    './src/generated/introspection.ts': {
      plugins: ['fragment-matcher'],
    },
  },
  hooks: {
    afterAllFileWrite: ['prettier --write'],
  },
};

export default config;
```

### Package Scripts
```json
// package.json
{
  "scripts": {
    "codegen": "graphql-codegen --config codegen.ts",
    "codegen:watch": "graphql-codegen --config codegen.ts --watch"
  }
}
```

---

## 3) Schema Definition (Schema-First)

### GraphQL Schema
```graphql
# ==========================================
# graphql/schema/common.graphql
# ==========================================

scalar DateTime
scalar JSON

interface Node {
  id: ID!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}

type Query {
  node(id: ID!): Node
}

type Mutation {
  _empty: Boolean
}

type Subscription {
  _empty: Boolean
}


# ==========================================
# graphql/schema/user.graphql
# ==========================================

enum UserRole {
  ADMIN
  USER
  MODERATOR
}

type User implements Node {
  id: ID!
  email: String!
  name: String!
  avatar: String
  role: UserRole!
  posts(first: Int, after: String): PostConnection!
  createdAt: DateTime!
  updatedAt: DateTime!
}

type UserEdge {
  cursor: String!
  node: User!
}

type UserConnection {
  edges: [UserEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

input CreateUserInput {
  email: String!
  name: String!
  password: String!
  role: UserRole
}

input UpdateUserInput {
  name: String
  avatar: String
}

type CreateUserPayload {
  user: User
  errors: [Error!]
}

type UpdateUserPayload {
  user: User
  errors: [Error!]
}

type Error {
  field: String!
  message: String!
}

extend type Query {
  user(id: ID!): User
  users(first: Int, after: String, filter: UserFilterInput): UserConnection!
  me: User
}

extend type Mutation {
  createUser(input: CreateUserInput!): CreateUserPayload!
  updateUser(id: ID!, input: UpdateUserInput!): UpdateUserPayload!
  deleteUser(id: ID!): Boolean!
}

input UserFilterInput {
  search: String
  role: UserRole
}


# ==========================================
# graphql/schema/post.graphql
# ==========================================

enum PostStatus {
  DRAFT
  PUBLISHED
  ARCHIVED
}

type Post implements Node {
  id: ID!
  title: String!
  slug: String!
  content: String!
  excerpt: String
  status: PostStatus!
  author: User!
  publishedAt: DateTime
  createdAt: DateTime!
  updatedAt: DateTime!
}

type PostEdge {
  cursor: String!
  node: Post!
}

type PostConnection {
  edges: [PostEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

input CreatePostInput {
  title: String!
  content: String!
  excerpt: String
  status: PostStatus
}

extend type Query {
  post(id: ID!): Post
  postBySlug(slug: String!): Post
  posts(first: Int, after: String, filter: PostFilterInput): PostConnection!
}

extend type Mutation {
  createPost(input: CreatePostInput!): Post!
  updatePost(id: ID!, input: UpdatePostInput!): Post!
  deletePost(id: ID!): Boolean!
  publishPost(id: ID!): Post!
}

extend type Subscription {
  postCreated: Post!
  postUpdated(id: ID!): Post!
}

input UpdatePostInput {
  title: String
  content: String
  excerpt: String
  status: PostStatus
}

input PostFilterInput {
  status: PostStatus
  authorId: ID
  search: String
}
```

---

## 4) Context and DataLoaders

### Typed Context
```typescript
// ==========================================
// graphql/context.ts
// ==========================================

import { PrismaClient } from '@prisma/client';
import DataLoader from 'dataloader';
import type { Request, Response } from 'express';
import type { UserModel } from '../models/user';
import { createUserLoader } from './dataloaders/user.loader';
import { createPostLoader } from './dataloaders/post.loader';

export interface Context {
  req: Request;
  res: Response;
  prisma: PrismaClient;
  currentUser: UserModel | null;
  loaders: {
    userLoader: DataLoader<string, UserModel | null>;
    postLoader: DataLoader<string, PostModel | null>;
    userPostsLoader: DataLoader<string, PostModel[]>;
  };
}

export async function createContext({
  req,
  res,
}: {
  req: Request;
  res: Response;
}): Promise<Context> {
  const prisma = new PrismaClient();
  
  // Authenticate user from token
  const currentUser = await authenticateUser(req, prisma);
  
  return {
    req,
    res,
    prisma,
    currentUser,
    loaders: {
      userLoader: createUserLoader(prisma),
      postLoader: createPostLoader(prisma),
      userPostsLoader: createUserPostsLoader(prisma),
    },
  };
}

async function authenticateUser(
  req: Request,
  prisma: PrismaClient
): Promise<UserModel | null> {
  const token = req.headers.authorization?.replace('Bearer ', '');
  
  if (!token) {
    return null;
  }
  
  try {
    const payload = verifyToken(token);
    return prisma.user.findUnique({ where: { id: payload.userId } });
  } catch {
    return null;
  }
}
```

### Typed DataLoaders
```typescript
// ==========================================
// graphql/dataloaders/user.loader.ts
// ==========================================

import DataLoader from 'dataloader';
import type { PrismaClient } from '@prisma/client';
import type { UserModel } from '../../models/user';

export function createUserLoader(
  prisma: PrismaClient
): DataLoader<string, UserModel | null> {
  return new DataLoader<string, UserModel | null>(
    async (ids: readonly string[]) => {
      const users = await prisma.user.findMany({
        where: { id: { in: [...ids] } },
      });

      const userMap = new Map(users.map((user) => [user.id, user]));

      return ids.map((id) => userMap.get(id) ?? null);
    },
    {
      cache: true,
      maxBatchSize: 100,
    }
  );
}


// ==========================================
// graphql/dataloaders/post.loader.ts
// ==========================================

import DataLoader from 'dataloader';
import type { PrismaClient } from '@prisma/client';
import type { PostModel } from '../../models/post';

export function createPostLoader(
  prisma: PrismaClient
): DataLoader<string, PostModel | null> {
  return new DataLoader<string, PostModel | null>(
    async (ids: readonly string[]) => {
      const posts = await prisma.post.findMany({
        where: { id: { in: [...ids] } },
      });

      const postMap = new Map(posts.map((post) => [post.id, post]));

      return ids.map((id) => postMap.get(id) ?? null);
    }
  );
}

// Batch load posts by author
export function createUserPostsLoader(
  prisma: PrismaClient
): DataLoader<string, PostModel[]> {
  return new DataLoader<string, PostModel[]>(
    async (authorIds: readonly string[]) => {
      const posts = await prisma.post.findMany({
        where: { authorId: { in: [...authorIds] } },
        orderBy: { createdAt: 'desc' },
      });

      // Group posts by author
      const postsByAuthor = new Map<string, PostModel[]>();
      
      for (const post of posts) {
        const existing = postsByAuthor.get(post.authorId) ?? [];
        postsByAuthor.set(post.authorId, [...existing, post]);
      }

      return authorIds.map((id) => postsByAuthor.get(id) ?? []);
    }
  );
}
```

---

## 5) Typed Resolvers

### User Resolvers
```typescript
// ==========================================
// graphql/resolvers/user.resolver.ts
// ==========================================

import type { Resolvers, UserResolvers, QueryResolvers, MutationResolvers } from '../../generated/graphql';
import type { Context } from '../context';
import { GraphQLError } from 'graphql';

// Type-safe User field resolvers
const User: UserResolvers<Context> = {
  posts: async (parent, args, { loaders, prisma }) => {
    const { first = 10, after } = args;
    
    // Use DataLoader to batch load posts
    const allPosts = await loaders.userPostsLoader.load(parent.id);
    
    // Implement cursor-based pagination
    const afterIndex = after
      ? allPosts.findIndex((p) => p.id === after) + 1
      : 0;
    
    const posts = allPosts.slice(afterIndex, afterIndex + first);
    const hasNextPage = afterIndex + first < allPosts.length;
    
    return {
      edges: posts.map((post) => ({
        cursor: post.id,
        node: post,
      })),
      pageInfo: {
        hasNextPage,
        hasPreviousPage: afterIndex > 0,
        startCursor: posts[0]?.id ?? null,
        endCursor: posts[posts.length - 1]?.id ?? null,
      },
      totalCount: allPosts.length,
    };
  },
};

// Type-safe Query resolvers
const Query: QueryResolvers<Context> = {
  user: async (_parent, { id }, { loaders }) => {
    return loaders.userLoader.load(id);
  },

  users: async (_parent, { first = 10, after, filter }, { prisma }) => {
    const where: Prisma.UserWhereInput = {};
    
    if (filter?.search) {
      where.OR = [
        { name: { contains: filter.search, mode: 'insensitive' } },
        { email: { contains: filter.search, mode: 'insensitive' } },
      ];
    }
    
    if (filter?.role) {
      where.role = filter.role;
    }
    
    const users = await prisma.user.findMany({
      where,
      take: first + 1,
      ...(after && {
        cursor: { id: after },
        skip: 1,
      }),
      orderBy: { createdAt: 'desc' },
    });
    
    const hasNextPage = users.length > first;
    const edges = users.slice(0, first);
    
    const totalCount = await prisma.user.count({ where });
    
    return {
      edges: edges.map((user) => ({
        cursor: user.id,
        node: user,
      })),
      pageInfo: {
        hasNextPage,
        hasPreviousPage: !!after,
        startCursor: edges[0]?.id ?? null,
        endCursor: edges[edges.length - 1]?.id ?? null,
      },
      totalCount,
    };
  },

  me: async (_parent, _args, { currentUser }) => {
    return currentUser;
  },
};

// Type-safe Mutation resolvers
const Mutation: MutationResolvers<Context> = {
  createUser: async (_parent, { input }, { prisma }) => {
    // Validate input
    const existingUser = await prisma.user.findUnique({
      where: { email: input.email },
    });
    
    if (existingUser) {
      return {
        user: null,
        errors: [{ field: 'email', message: 'Email already exists' }],
      };
    }
    
    const hashedPassword = await hashPassword(input.password);
    
    const user = await prisma.user.create({
      data: {
        email: input.email,
        name: input.name,
        password: hashedPassword,
        role: input.role ?? 'USER',
      },
    });
    
    return { user, errors: null };
  },

  updateUser: async (_parent, { id, input }, { prisma, currentUser }) => {
    // Authorization check
    if (!currentUser || (currentUser.id !== id && currentUser.role !== 'ADMIN')) {
      throw new GraphQLError('Not authorized', {
        extensions: { code: 'FORBIDDEN' },
      });
    }
    
    const user = await prisma.user.update({
      where: { id },
      data: input,
    });
    
    return { user, errors: null };
  },

  deleteUser: async (_parent, { id }, { prisma, currentUser }) => {
    if (!currentUser || currentUser.role !== 'ADMIN') {
      throw new GraphQLError('Not authorized', {
        extensions: { code: 'FORBIDDEN' },
      });
    }
    
    await prisma.user.delete({ where: { id } });
    return true;
  },
};

export const userResolvers: Resolvers<Context> = {
  User,
  Query,
  Mutation,
};
```

### Post Resolvers with Subscriptions
```typescript
// ==========================================
// graphql/resolvers/post.resolver.ts
// ==========================================

import { PubSub, withFilter } from 'graphql-subscriptions';
import type {
  Resolvers,
  PostResolvers,
  QueryResolvers,
  MutationResolvers,
  SubscriptionResolvers,
} from '../../generated/graphql';
import type { Context } from '../context';

const pubsub = new PubSub();

const POST_CREATED = 'POST_CREATED';
const POST_UPDATED = 'POST_UPDATED';

// Type-safe Post field resolvers
const Post: PostResolvers<Context> = {
  author: async (parent, _args, { loaders }) => {
    const author = await loaders.userLoader.load(parent.authorId);
    
    if (!author) {
      throw new Error('Author not found');
    }
    
    return author;
  },
};

const Query: QueryResolvers<Context> = {
  post: async (_parent, { id }, { loaders }) => {
    return loaders.postLoader.load(id);
  },

  postBySlug: async (_parent, { slug }, { prisma }) => {
    return prisma.post.findUnique({ where: { slug } });
  },

  posts: async (_parent, { first = 10, after, filter }, { prisma }) => {
    const where: Prisma.PostWhereInput = {};
    
    if (filter?.status) {
      where.status = filter.status;
    }
    
    if (filter?.authorId) {
      where.authorId = filter.authorId;
    }
    
    if (filter?.search) {
      where.OR = [
        { title: { contains: filter.search, mode: 'insensitive' } },
        { content: { contains: filter.search, mode: 'insensitive' } },
      ];
    }
    
    const posts = await prisma.post.findMany({
      where,
      take: first + 1,
      ...(after && { cursor: { id: after }, skip: 1 }),
      orderBy: { createdAt: 'desc' },
    });
    
    const hasNextPage = posts.length > first;
    const edges = posts.slice(0, first);
    const totalCount = await prisma.post.count({ where });
    
    return {
      edges: edges.map((post) => ({ cursor: post.id, node: post })),
      pageInfo: {
        hasNextPage,
        hasPreviousPage: !!after,
        startCursor: edges[0]?.id ?? null,
        endCursor: edges[edges.length - 1]?.id ?? null,
      },
      totalCount,
    };
  },
};

const Mutation: MutationResolvers<Context> = {
  createPost: async (_parent, { input }, { prisma, currentUser }) => {
    if (!currentUser) {
      throw new GraphQLError('Not authenticated', {
        extensions: { code: 'UNAUTHENTICATED' },
      });
    }
    
    const slug = generateSlug(input.title);
    
    const post = await prisma.post.create({
      data: {
        ...input,
        slug,
        authorId: currentUser.id,
        status: input.status ?? 'DRAFT',
      },
    });
    
    // Publish subscription event
    await pubsub.publish(POST_CREATED, { postCreated: post });
    
    return post;
  },

  updatePost: async (_parent, { id, input }, { prisma, currentUser }) => {
    const existing = await prisma.post.findUnique({ where: { id } });
    
    if (!existing) {
      throw new GraphQLError('Post not found', {
        extensions: { code: 'NOT_FOUND' },
      });
    }
    
    if (existing.authorId !== currentUser?.id && currentUser?.role !== 'ADMIN') {
      throw new GraphQLError('Not authorized', {
        extensions: { code: 'FORBIDDEN' },
      });
    }
    
    const post = await prisma.post.update({
      where: { id },
      data: input,
    });
    
    // Publish subscription event
    await pubsub.publish(POST_UPDATED, { postUpdated: post });
    
    return post;
  },

  publishPost: async (_parent, { id }, { prisma, currentUser }) => {
    const post = await prisma.post.update({
      where: { id },
      data: {
        status: 'PUBLISHED',
        publishedAt: new Date(),
      },
    });
    
    return post;
  },

  deletePost: async (_parent, { id }, { prisma }) => {
    await prisma.post.delete({ where: { id } });
    return true;
  },
};

// Typed Subscriptions
const Subscription: SubscriptionResolvers<Context> = {
  postCreated: {
    subscribe: () => pubsub.asyncIterator([POST_CREATED]),
  },

  postUpdated: {
    subscribe: withFilter(
      () => pubsub.asyncIterator([POST_UPDATED]),
      (payload, variables) => {
        // Only notify if watching this specific post
        return payload.postUpdated.id === variables.id;
      }
    ),
  },
};

export const postResolvers: Resolvers<Context> = {
  Post,
  Query,
  Mutation,
  Subscription,
};
```

---

## 6) Apollo Server Setup

### Server Configuration
```typescript
// ==========================================
// server.ts
// ==========================================

import { ApolloServer } from '@apollo/server';
import { expressMiddleware } from '@apollo/server/express4';
import { ApolloServerPluginDrainHttpServer } from '@apollo/server/plugin/drainHttpServer';
import { makeExecutableSchema } from '@graphql-tools/schema';
import { WebSocketServer } from 'ws';
import { useServer } from 'graphql-ws/lib/use/ws';
import express from 'express';
import http from 'http';
import cors from 'cors';
import { loadFilesSync } from '@graphql-tools/load-files';
import { mergeTypeDefs, mergeResolvers } from '@graphql-tools/merge';
import type { Resolvers } from './generated/graphql';
import { createContext, type Context } from './graphql/context';
import { userResolvers } from './graphql/resolvers/user.resolver';
import { postResolvers } from './graphql/resolvers/post.resolver';

async function startServer() {
  const app = express();
  const httpServer = http.createServer(app);

  // Load schema files
  const typeDefs = mergeTypeDefs(
    loadFilesSync('./src/graphql/schema/**/*.graphql')
  );

  // Merge resolvers
  const resolvers: Resolvers<Context> = mergeResolvers([
    userResolvers,
    postResolvers,
  ]);

  const schema = makeExecutableSchema({ typeDefs, resolvers });

  // WebSocket server for subscriptions
  const wsServer = new WebSocketServer({
    server: httpServer,
    path: '/graphql',
  });

  const serverCleanup = useServer(
    {
      schema,
      context: async (ctx) => {
        // Create context for WebSocket connections
        return createContext({
          req: ctx.extra.request,
          res: {} as Response,
        });
      },
    },
    wsServer
  );

  // Apollo Server
  const server = new ApolloServer<Context>({
    schema,
    plugins: [
      ApolloServerPluginDrainHttpServer({ httpServer }),
      {
        async serverWillStart() {
          return {
            async drainServer() {
              await serverCleanup.dispose();
            },
          };
        },
      },
    ],
    formatError: (formattedError, error) => {
      // Log errors
      console.error(error);
      
      // Don't expose internal errors in production
      if (process.env.NODE_ENV === 'production') {
        if (formattedError.extensions?.code === 'INTERNAL_SERVER_ERROR') {
          return {
            ...formattedError,
            message: 'Internal server error',
          };
        }
      }
      
      return formattedError;
    },
  });

  await server.start();

  app.use(
    '/graphql',
    cors<cors.CorsRequest>(),
    express.json(),
    expressMiddleware(server, {
      context: async ({ req, res }) => createContext({ req, res }),
    })
  );

  const PORT = process.env.PORT ?? 4000;

  httpServer.listen(PORT, () => {
    console.log(`🚀 Server ready at http://localhost:${PORT}/graphql`);
    console.log(`🚀 Subscriptions ready at ws://localhost:${PORT}/graphql`);
  });
}

startServer().catch(console.error);
```

---

## 7) Apollo Client (React)

### Client Setup
```typescript
// ==========================================
// client/apollo.ts
// ==========================================

import {
  ApolloClient,
  InMemoryCache,
  createHttpLink,
  split,
  type NormalizedCacheObject,
} from '@apollo/client';
import { setContext } from '@apollo/client/link/context';
import { GraphQLWsLink } from '@apollo/client/link/subscriptions';
import { getMainDefinition } from '@apollo/client/utilities';
import { createClient } from 'graphql-ws';

const httpLink = createHttpLink({
  uri: process.env.NEXT_PUBLIC_GRAPHQL_URL ?? 'http://localhost:4000/graphql',
});

const authLink = setContext((_, { headers }) => {
  const token = localStorage.getItem('token');
  
  return {
    headers: {
      ...headers,
      authorization: token ? `Bearer ${token}` : '',
    },
  };
});

const wsLink = new GraphQLWsLink(
  createClient({
    url: process.env.NEXT_PUBLIC_GRAPHQL_WS_URL ?? 'ws://localhost:4000/graphql',
    connectionParams: () => ({
      authorization: localStorage.getItem('token') ?? '',
    }),
  })
);

// Split based on operation type
const splitLink = split(
  ({ query }) => {
    const definition = getMainDefinition(query);
    return (
      definition.kind === 'OperationDefinition' &&
      definition.operation === 'subscription'
    );
  },
  wsLink,
  authLink.concat(httpLink)
);

export const apolloClient: ApolloClient<NormalizedCacheObject> = new ApolloClient({
  link: splitLink,
  cache: new InMemoryCache({
    typePolicies: {
      Query: {
        fields: {
          users: {
            keyArgs: ['filter'],
            merge(existing, incoming, { args }) {
              if (!args?.after) {
                return incoming;
              }
              return {
                ...incoming,
                edges: [...(existing?.edges ?? []), ...incoming.edges],
              };
            },
          },
        },
      },
    },
  }),
});
```

### Generated Hooks Usage
```typescript
// ==========================================
// client/operations/user.graphql
// ==========================================

fragment UserFields on User {
  id
  email
  name
  avatar
  role
  createdAt
}

query GetUsers($first: Int, $after: String, $filter: UserFilterInput) {
  users(first: $first, after: $after, filter: $filter) {
    edges {
      cursor
      node {
        ...UserFields
      }
    }
    pageInfo {
      hasNextPage
      endCursor
    }
    totalCount
  }
}

query GetUser($id: ID!) {
  user(id: $id) {
    ...UserFields
    posts(first: 10) {
      edges {
        node {
          id
          title
          status
        }
      }
    }
  }
}

query GetMe {
  me {
    ...UserFields
  }
}

mutation CreateUser($input: CreateUserInput!) {
  createUser(input: $input) {
    user {
      ...UserFields
    }
    errors {
      field
      message
    }
  }
}

mutation UpdateUser($id: ID!, $input: UpdateUserInput!) {
  updateUser(id: $id, input: $input) {
    user {
      ...UserFields
    }
    errors {
      field
      message
    }
  }
}


// ==========================================
// components/UserList.tsx (Using Generated Hooks)
// ==========================================

import { useGetUsersQuery, useCreateUserMutation } from '@/generated/client';
import type { UserRole } from '@/generated/client';

export function UserList() {
  // Fully typed query hook
  const { data, loading, error, fetchMore } = useGetUsersQuery({
    variables: {
      first: 10,
      filter: { role: 'USER' as UserRole },
    },
  });

  // Fully typed mutation hook
  const [createUser, { loading: creating }] = useCreateUserMutation({
    update(cache, { data }) {
      if (data?.createUser.user) {
        // Update cache with proper typing
        cache.modify({
          fields: {
            users(existing = { edges: [] }) {
              const newEdge = {
                __typename: 'UserEdge',
                cursor: data.createUser.user!.id,
                node: data.createUser.user,
              };
              return {
                ...existing,
                edges: [newEdge, ...existing.edges],
                totalCount: existing.totalCount + 1,
              };
            },
          },
        });
      }
    },
  });

  const handleLoadMore = () => {
    if (data?.users.pageInfo.hasNextPage) {
      fetchMore({
        variables: {
          after: data.users.pageInfo.endCursor,
        },
      });
    }
  };

  if (loading) return <Loading />;
  if (error) return <Error message={error.message} />;

  return (
    <div>
      {data?.users.edges.map(({ node: user }) => (
        <UserCard key={user.id} user={user} />
      ))}
      
      {data?.users.pageInfo.hasNextPage && (
        <button onClick={handleLoadMore}>Load More</button>
      )}
    </div>
  );
}
```

### Subscription Component
```typescript
// ==========================================
// components/PostSubscription.tsx
// ==========================================

import { usePostCreatedSubscription, usePostUpdatedSubscription } from '@/generated/client';

export function PostFeed({ postId }: { postId?: string }) {
  // Subscribe to new posts
  const { data: newPostData } = usePostCreatedSubscription();

  // Subscribe to specific post updates
  const { data: updateData } = usePostUpdatedSubscription({
    variables: { id: postId! },
    skip: !postId,
  });

  useEffect(() => {
    if (newPostData?.postCreated) {
      toast.success(`New post: ${newPostData.postCreated.title}`);
    }
  }, [newPostData]);

  useEffect(() => {
    if (updateData?.postUpdated) {
      toast.info(`Post updated: ${updateData.postUpdated.title}`);
    }
  }, [updateData]);

  return <PostList />;
}
```

---

## 8) Testing

### Resolver Tests
```typescript
// ==========================================
// __tests__/resolvers/user.resolver.test.ts
// ==========================================

import { createTestContext, type TestContext } from '../helpers/context';
import { userResolvers } from '../../src/graphql/resolvers/user.resolver';
import { createMockUser } from '../helpers/factories';

describe('User Resolvers', () => {
  let context: TestContext;

  beforeEach(async () => {
    context = await createTestContext();
  });

  afterEach(async () => {
    await context.cleanup();
  });

  describe('Query.users', () => {
    it('should return paginated users', async () => {
      // Seed data
      await context.prisma.user.createMany({
        data: [
          createMockUser({ name: 'User 1' }),
          createMockUser({ name: 'User 2' }),
        ],
      });

      const result = await userResolvers.Query!.users!(
        {},
        { first: 10 },
        context,
        {} as GraphQLResolveInfo
      );

      expect(result.edges).toHaveLength(2);
      expect(result.totalCount).toBe(2);
    });

    it('should filter by role', async () => {
      await context.prisma.user.createMany({
        data: [
          createMockUser({ role: 'ADMIN' }),
          createMockUser({ role: 'USER' }),
        ],
      });

      const result = await userResolvers.Query!.users!(
        {},
        { first: 10, filter: { role: 'ADMIN' } },
        context,
        {} as GraphQLResolveInfo
      );

      expect(result.edges).toHaveLength(1);
      expect(result.edges[0].node.role).toBe('ADMIN');
    });
  });

  describe('Mutation.createUser', () => {
    it('should create a new user', async () => {
      const input = {
        email: 'test@example.com',
        name: 'Test User',
        password: 'Password123!',
      };

      const result = await userResolvers.Mutation!.createUser!(
        {},
        { input },
        context,
        {} as GraphQLResolveInfo
      );

      expect(result.user).toBeDefined();
      expect(result.user!.email).toBe(input.email);
      expect(result.errors).toBeNull();
    });

    it('should return error for duplicate email', async () => {
      await context.prisma.user.create({
        data: createMockUser({ email: 'test@example.com' }),
      });

      const result = await userResolvers.Mutation!.createUser!(
        {},
        {
          input: {
            email: 'test@example.com',
            name: 'Test',
            password: 'Password123!',
          },
        },
        context,
        {} as GraphQLResolveInfo
      );

      expect(result.user).toBeNull();
      expect(result.errors).toContainEqual({
        field: 'email',
        message: 'Email already exists',
      });
    });
  });
});
```

---

## Best Practices Checklist

### Code Generation
- [ ] Use graphql-codegen
- [ ] Generate types + hooks
- [ ] Configure mappers

### Schema
- [ ] Consistent naming
- [ ] Proper connections
- [ ] Input types

### Resolvers
- [ ] Type all arguments
- [ ] Use DataLoaders
- [ ] Error handling

### Client
- [ ] Typed hooks
- [ ] Cache policies
- [ ] Optimistic updates

### Testing
- [ ] Mock context
- [ ] Test resolvers
- [ ] Integration tests

---

**References:**
- [GraphQL Code Generator](https://the-guild.dev/graphql/codegen)
- [Apollo Server](https://www.apollographql.com/docs/apollo-server/)
- [Apollo Client](https://www.apollographql.com/docs/react/)
- [DataLoader](https://github.com/graphql/dataloader)

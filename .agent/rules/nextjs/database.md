# Next.js Database Integration Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **Prisma:** v5.x | **Drizzle:** v0.30+  
> **Priority:** P0 - Load for all database tasks

---

You are an expert in Next.js database integration with Prisma and modern ORMs.

## Core Database Principles

- Use Prisma for type-safe database access
- Implement proper connection pooling
- Use Server Components for data fetching
- Cache database queries appropriately

---

## 1) Prisma Complete Setup

### Installation & Configuration
```bash
# Install Prisma
npm install @prisma/client
npm install -D prisma

# Initialize Prisma with PostgreSQL
npx prisma init --datasource-provider postgresql
```

```prisma
// ==========================================
// prisma/schema.prisma
// ==========================================

generator client {
  provider        = "prisma-client-js"
  previewFeatures = ["fullTextSearch", "driverAdapters"]
}

datasource db {
  provider  = "postgresql"
  url       = env("DATABASE_URL")
  directUrl = env("DIRECT_URL")  // For migrations (bypasses pooler)
}

// ==========================================
// USER MODEL
// ==========================================

enum Role {
  USER
  MODERATOR
  ADMIN
  SUPER_ADMIN
}

model User {
  id            String    @id @default(cuid())
  email         String    @unique
  emailVerified DateTime?
  name          String?
  image         String?
  password      String?
  role          Role      @default(USER)
  
  // Relations
  accounts      Account[]
  sessions      Session[]
  posts         Post[]
  comments      Comment[]
  likes         Like[]
  
  // Timestamps
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt
  deletedAt     DateTime?  // Soft delete
  
  @@index([email])
  @@index([role])
  @@index([createdAt])
  @@map("users")
}

// ==========================================
// AUTH MODELS (Auth.js compatible)
// ==========================================

model Account {
  id                String  @id @default(cuid())
  userId            String
  type              String
  provider          String
  providerAccountId String
  refresh_token     String? @db.Text
  access_token      String? @db.Text
  expires_at        Int?
  token_type        String?
  scope             String?
  id_token          String? @db.Text
  session_state     String?
  
  user User @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@unique([provider, providerAccountId])
  @@index([userId])
  @@map("accounts")
}

model Session {
  id           String   @id @default(cuid())
  sessionToken String   @unique
  userId       String
  expires      DateTime
  
  user User @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@index([userId])
  @@map("sessions")
}

model VerificationToken {
  identifier String
  token      String   @unique
  expires    DateTime
  
  @@unique([identifier, token])
  @@map("verification_tokens")
}

model PasswordResetToken {
  id      String   @id @default(cuid())
  email   String
  token   String   @unique
  expires DateTime
  
  @@index([email])
  @@map("password_reset_tokens")
}

// ==========================================
// CONTENT MODELS
// ==========================================

enum PostStatus {
  DRAFT
  PUBLISHED
  ARCHIVED
}

model Category {
  id          String   @id @default(cuid())
  name        String   @unique
  slug        String   @unique
  description String?
  posts       Post[]
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  @@map("categories")
}

model Post {
  id          String     @id @default(cuid())
  title       String
  slug        String     @unique
  excerpt     String?    @db.Text
  content     String     @db.Text
  image       String?
  status      PostStatus @default(DRAFT)
  publishedAt DateTime?
  
  // Relations
  authorId    String
  author      User       @relation(fields: [authorId], references: [id], onDelete: Cascade)
  categoryId  String
  category    Category   @relation(fields: [categoryId], references: [id])
  comments    Comment[]
  likes       Like[]
  tags        TagsOnPosts[]
  
  // Timestamps
  createdAt   DateTime   @default(now())
  updatedAt   DateTime   @updatedAt
  deletedAt   DateTime?
  
  @@index([authorId])
  @@index([categoryId])
  @@index([status])
  @@index([publishedAt])
  @@index([slug])
  @@fulltext([title, content])  // Full-text search
  @@map("posts")
}

model Tag {
  id    String        @id @default(cuid())
  name  String        @unique
  slug  String        @unique
  posts TagsOnPosts[]
  
  @@map("tags")
}

model TagsOnPosts {
  post   Post   @relation(fields: [postId], references: [id], onDelete: Cascade)
  postId String
  tag    Tag    @relation(fields: [tagId], references: [id], onDelete: Cascade)
  tagId  String
  
  @@id([postId, tagId])
  @@map("tags_on_posts")
}

model Comment {
  id        String    @id @default(cuid())
  content   String    @db.Text
  
  // Self-referential relation for replies
  parentId  String?
  parent    Comment?  @relation("CommentReplies", fields: [parentId], references: [id])
  replies   Comment[] @relation("CommentReplies")
  
  // Relations
  authorId  String
  author    User      @relation(fields: [authorId], references: [id], onDelete: Cascade)
  postId    String
  post      Post      @relation(fields: [postId], references: [id], onDelete: Cascade)
  
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt
  deletedAt DateTime?
  
  @@index([authorId])
  @@index([postId])
  @@index([parentId])
  @@map("comments")
}

model Like {
  id        String   @id @default(cuid())
  userId    String
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  postId    String
  post      Post     @relation(fields: [postId], references: [id], onDelete: Cascade)
  createdAt DateTime @default(now())
  
  @@unique([userId, postId])
  @@index([postId])
  @@map("likes")
}
```

### Prisma Client Singleton
```typescript
// ==========================================
// lib/prisma.ts
// ==========================================

import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' 
      ? ['query', 'error', 'warn'] 
      : ['error'],
  });

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma;
}

export default prisma;


// ==========================================
// WITH CLIENT EXTENSIONS
// ==========================================

import { PrismaClient, Prisma } from '@prisma/client';

const prismaClientSingleton = () => {
  return new PrismaClient().$extends({
    // Soft delete extension
    query: {
      $allModels: {
        async findMany({ model, operation, args, query }) {
          args.where = { ...args.where, deletedAt: null };
          return query(args);
        },
        async findFirst({ model, operation, args, query }) {
          args.where = { ...args.where, deletedAt: null };
          return query(args);
        },
      },
    },
    // Custom model methods
    model: {
      user: {
        async softDelete(id: string) {
          return prisma.user.update({
            where: { id },
            data: { deletedAt: new Date() },
          });
        },
      },
      post: {
        async softDelete(id: string) {
          return prisma.post.update({
            where: { id },
            data: { deletedAt: new Date() },
          });
        },
        async publish(id: string) {
          return prisma.post.update({
            where: { id },
            data: { 
              status: 'PUBLISHED', 
              publishedAt: new Date() 
            },
          });
        },
      },
    },
  });
};

declare const globalThis: {
  prismaGlobal: ReturnType<typeof prismaClientSingleton>;
} & typeof global;

export const prisma = globalThis.prismaGlobal ?? prismaClientSingleton();

if (process.env.NODE_ENV !== 'production') {
  globalThis.prismaGlobal = prisma;
}
```

---

## 2) Server Component Queries

### Basic Queries
```tsx
// ==========================================
// FETCHING DATA IN SERVER COMPONENTS
// ==========================================

// app/posts/page.tsx
import { prisma } from '@/lib/prisma';
import { PostCard } from '@/components/PostCard';

export default async function PostsPage() {
  const posts = await prisma.post.findMany({
    where: {
      status: 'PUBLISHED',
      deletedAt: null,
    },
    select: {
      id: true,
      title: true,
      slug: true,
      excerpt: true,
      image: true,
      publishedAt: true,
      author: {
        select: {
          id: true,
          name: true,
          image: true,
        },
      },
      category: {
        select: {
          name: true,
          slug: true,
        },
      },
      _count: {
        select: {
          comments: true,
          likes: true,
        },
      },
    },
    orderBy: {
      publishedAt: 'desc',
    },
    take: 20,
  });

  return (
    <div className="grid grid-cols-3 gap-6">
      {posts.map(post => (
        <PostCard key={post.id} post={post} />
      ))}
    </div>
  );
}


// ==========================================
// SINGLE ITEM WITH RELATIONS
// ==========================================

// app/posts/[slug]/page.tsx
import { prisma } from '@/lib/prisma';
import { notFound } from 'next/navigation';
import { Suspense } from 'react';

interface Props {
  params: { slug: string };
}

async function getPost(slug: string) {
  return prisma.post.findUnique({
    where: { slug },
    include: {
      author: {
        select: {
          id: true,
          name: true,
          image: true,
          role: true,
        },
      },
      category: true,
      tags: {
        include: {
          tag: true,
        },
      },
      _count: {
        select: {
          comments: true,
          likes: true,
        },
      },
    },
  });
}

export default async function PostPage({ params }: Props) {
  const post = await getPost(params.slug);

  if (!post || post.status !== 'PUBLISHED') {
    notFound();
  }

  return (
    <article>
      <h1>{post.title}</h1>
      <PostMeta post={post} />
      <PostContent content={post.content} />
      
      <Suspense fallback={<CommentsSkeleton />}>
        <Comments postId={post.id} />
      </Suspense>
    </article>
  );
}

// Dynamic metadata
export async function generateMetadata({ params }: Props) {
  const post = await getPost(params.slug);
  
  if (!post) {
    return { title: 'Post Not Found' };
  }
  
  return {
    title: post.title,
    description: post.excerpt,
    openGraph: {
      images: [post.image],
    },
  };
}

// Static params for static generation
export async function generateStaticParams() {
  const posts = await prisma.post.findMany({
    where: { status: 'PUBLISHED' },
    select: { slug: true },
  });
  
  return posts.map(post => ({
    slug: post.slug,
  }));
}
```

---

## 3) Cached Queries

### Using unstable_cache
```typescript
// ==========================================
// CACHED DATABASE QUERIES
// ==========================================

// lib/queries/posts.ts
import { unstable_cache } from 'next/cache';
import { prisma } from '@/lib/prisma';

// Cache posts list for 1 hour
export const getCachedPosts = unstable_cache(
  async (page = 1, limit = 20) => {
    const skip = (page - 1) * limit;
    
    const [posts, total] = await Promise.all([
      prisma.post.findMany({
        where: { status: 'PUBLISHED', deletedAt: null },
        select: {
          id: true,
          title: true,
          slug: true,
          excerpt: true,
          image: true,
          publishedAt: true,
          author: {
            select: { id: true, name: true, image: true },
          },
          _count: {
            select: { comments: true, likes: true },
          },
        },
        orderBy: { publishedAt: 'desc' },
        skip,
        take: limit,
      }),
      prisma.post.count({
        where: { status: 'PUBLISHED', deletedAt: null },
      }),
    ]);
    
    return {
      posts,
      total,
      pages: Math.ceil(total / limit),
      hasMore: skip + limit < total,
    };
  },
  ['posts-list'],  // Cache key
  {
    revalidate: 3600,  // 1 hour
    tags: ['posts'],   // For on-demand revalidation
  }
);

// Cache individual post
export const getCachedPost = unstable_cache(
  async (slug: string) => {
    return prisma.post.findUnique({
      where: { slug },
      include: {
        author: {
          select: { id: true, name: true, image: true },
        },
        category: true,
        tags: { include: { tag: true } },
      },
    });
  },
  ['post'],
  {
    revalidate: 3600,
    tags: ['posts'],
  }
);

// Cache with dynamic key
export function getCachedUserPosts(userId: string) {
  return unstable_cache(
    async () => {
      return prisma.post.findMany({
        where: { authorId: userId },
        orderBy: { createdAt: 'desc' },
      });
    },
    [`user-posts-${userId}`],
    {
      revalidate: 1800,
      tags: ['posts', `user-${userId}`],
    }
  )();
}


// ==========================================
// USAGE IN SERVER COMPONENT
// ==========================================

// app/posts/page.tsx
import { getCachedPosts } from '@/lib/queries/posts';

export default async function PostsPage({
  searchParams,
}: {
  searchParams: { page?: string };
}) {
  const page = Number(searchParams.page) || 1;
  const { posts, total, pages, hasMore } = await getCachedPosts(page);

  return (
    <div>
      <PostGrid posts={posts} />
      <Pagination currentPage={page} totalPages={pages} />
    </div>
  );
}
```

---

## 4) Server Actions with Mutations

### CRUD Operations
```typescript
// ==========================================
// POST ACTIONS
// ==========================================

// app/actions/posts.ts
'use server';

import { z } from 'zod';
import { auth } from '@/auth';
import { prisma } from '@/lib/prisma';
import { revalidatePath, revalidateTag } from 'next/cache';
import { redirect } from 'next/navigation';
import slugify from 'slugify';

const CreatePostSchema = z.object({
  title: z.string().min(1).max(100),
  content: z.string().min(10),
  excerpt: z.string().max(300).optional(),
  categoryId: z.string().uuid(),
  tags: z.array(z.string()).max(5).optional(),
  status: z.enum(['DRAFT', 'PUBLISHED']).default('DRAFT'),
});

const UpdatePostSchema = CreatePostSchema.partial().extend({
  id: z.string().cuid(),
});

export type ActionResult<T = void> = 
  | { success: true; data: T }
  | { success: false; error: string; fieldErrors?: Record<string, string[]> };

// CREATE
export async function createPost(
  formData: FormData
): Promise<ActionResult<{ id: string; slug: string }>> {
  const session = await auth();
  
  if (!session?.user) {
    return { success: false, error: 'Unauthorized' };
  }

  const rawData = {
    title: formData.get('title'),
    content: formData.get('content'),
    excerpt: formData.get('excerpt') || undefined,
    categoryId: formData.get('categoryId'),
    tags: formData.getAll('tags'),
    status: formData.get('status') || 'DRAFT',
  };

  const validated = CreatePostSchema.safeParse(rawData);

  if (!validated.success) {
    return {
      success: false,
      error: 'Validation failed',
      fieldErrors: validated.error.flatten().fieldErrors,
    };
  }

  const { tags, ...data } = validated.data;

  // Generate unique slug
  let slug = slugify(data.title, { lower: true, strict: true });
  const existingSlug = await prisma.post.findUnique({
    where: { slug },
  });
  if (existingSlug) {
    slug = `${slug}-${Date.now()}`;
  }

  try {
    const post = await prisma.post.create({
      data: {
        ...data,
        slug,
        authorId: session.user.id,
        publishedAt: data.status === 'PUBLISHED' ? new Date() : null,
        tags: tags?.length ? {
          create: tags.map(tagId => ({
            tag: { connect: { id: tagId } },
          })),
        } : undefined,
      },
    });

    revalidateTag('posts');
    revalidatePath('/posts');
    
    return {
      success: true,
      data: { id: post.id, slug: post.slug },
    };
  } catch (error) {
    console.error('Create post error:', error);
    return { success: false, error: 'Failed to create post' };
  }
}

// UPDATE
export async function updatePost(
  formData: FormData
): Promise<ActionResult<{ slug: string }>> {
  const session = await auth();
  
  if (!session?.user) {
    return { success: false, error: 'Unauthorized' };
  }

  const rawData = {
    id: formData.get('id'),
    title: formData.get('title'),
    content: formData.get('content'),
    excerpt: formData.get('excerpt') || undefined,
    categoryId: formData.get('categoryId'),
    status: formData.get('status'),
  };

  const validated = UpdatePostSchema.safeParse(rawData);

  if (!validated.success) {
    return {
      success: false,
      error: 'Validation failed',
      fieldErrors: validated.error.flatten().fieldErrors,
    };
  }

  const { id, ...data } = validated.data;

  // Check ownership
  const existingPost = await prisma.post.findUnique({
    where: { id },
    select: { authorId: true },
  });

  if (!existingPost) {
    return { success: false, error: 'Post not found' };
  }

  if (existingPost.authorId !== session.user.id && session.user.role !== 'ADMIN') {
    return { success: false, error: 'Forbidden' };
  }

  try {
    const post = await prisma.post.update({
      where: { id },
      data: {
        ...data,
        publishedAt: data.status === 'PUBLISHED' && !existingPost.publishedAt
          ? new Date()
          : undefined,
      },
    });

    revalidateTag('posts');
    revalidatePath(`/posts/${post.slug}`);
    
    return { success: true, data: { slug: post.slug } };
  } catch (error) {
    console.error('Update post error:', error);
    return { success: false, error: 'Failed to update post' };
  }
}

// DELETE
export async function deletePost(id: string): Promise<ActionResult> {
  const session = await auth();
  
  if (!session?.user) {
    return { success: false, error: 'Unauthorized' };
  }

  const post = await prisma.post.findUnique({
    where: { id },
    select: { authorId: true },
  });

  if (!post) {
    return { success: false, error: 'Post not found' };
  }

  if (post.authorId !== session.user.id && session.user.role !== 'ADMIN') {
    return { success: false, error: 'Forbidden' };
  }

  try {
    // Soft delete
    await prisma.post.update({
      where: { id },
      data: { deletedAt: new Date() },
    });

    revalidateTag('posts');
    revalidatePath('/posts');
    
    return { success: true, data: undefined };
  } catch (error) {
    console.error('Delete post error:', error);
    return { success: false, error: 'Failed to delete post' };
  }
}
```

---

## 5) Transactions

### Atomic Operations
```typescript
// ==========================================
// TRANSACTIONS
// ==========================================

// app/actions/orders.ts
'use server';

import { prisma } from '@/lib/prisma';
import { Prisma } from '@prisma/client';

// Sequential transaction (batch operations)
export async function createOrderWithItems(
  orderData: CreateOrderInput,
  items: OrderItemInput[]
) {
  // All operations succeed or all fail
  return prisma.$transaction([
    // Create order
    prisma.order.create({
      data: orderData,
    }),
    // Create order items
    prisma.orderItem.createMany({
      data: items,
    }),
    // Update product stock
    ...items.map(item =>
      prisma.product.update({
        where: { id: item.productId },
        data: {
          stock: { decrement: item.quantity },
        },
      })
    ),
  ]);
}


// Interactive transaction (with logic)
export async function transferCredits(
  fromUserId: string,
  toUserId: string,
  amount: number
) {
  return prisma.$transaction(async (tx) => {
    // Check sender balance
    const sender = await tx.user.findUnique({
      where: { id: fromUserId },
      select: { credits: true },
    });

    if (!sender || sender.credits < amount) {
      throw new Error('Insufficient credits');
    }

    // Deduct from sender
    await tx.user.update({
      where: { id: fromUserId },
      data: { credits: { decrement: amount } },
    });

    // Add to receiver
    await tx.user.update({
      where: { id: toUserId },
      data: { credits: { increment: amount } },
    });

    // Create transaction record
    const transaction = await tx.creditTransaction.create({
      data: {
        fromUserId,
        toUserId,
        amount,
        type: 'TRANSFER',
      },
    });

    return transaction;
  }, {
    maxWait: 5000,  // Max wait time for transaction start
    timeout: 10000, // Max execution time
    isolationLevel: Prisma.TransactionIsolationLevel.Serializable,
  });
}


// Transaction with retry logic
export async function createOrderWithRetry(
  orderData: CreateOrderInput,
  maxRetries = 3
) {
  let attempt = 0;

  while (attempt < maxRetries) {
    try {
      return await prisma.$transaction(async (tx) => {
        // Check stock
        const product = await tx.product.findUnique({
          where: { id: orderData.productId },
        });

        if (!product || product.stock < orderData.quantity) {
          throw new Error('Insufficient stock');
        }

        // Create order and update stock atomically
        const [order] = await Promise.all([
          tx.order.create({ data: orderData }),
          tx.product.update({
            where: { id: orderData.productId },
            data: { stock: { decrement: orderData.quantity } },
          }),
        ]);

        return order;
      });
    } catch (error) {
      attempt++;
      
      // Retry on deadlock/conflict
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2034'  // Transaction conflict
      ) {
        if (attempt === maxRetries) throw error;
        await new Promise(r => setTimeout(r, 100 * attempt));
        continue;
      }
      
      throw error;
    }
  }
}
```

---

## 6) Pagination Patterns

### Cursor vs Offset Pagination
```typescript
// ==========================================
// OFFSET PAGINATION (Simple, but skip is slow)
// ==========================================

export async function getPostsWithOffset(page: number, limit: number) {
  const skip = (page - 1) * limit;
  
  const [posts, total] = await Promise.all([
    prisma.post.findMany({
      where: { status: 'PUBLISHED' },
      orderBy: { publishedAt: 'desc' },
      skip,
      take: limit,
    }),
    prisma.post.count({
      where: { status: 'PUBLISHED' },
    }),
  ]);
  
  return {
    posts,
    pagination: {
      page,
      limit,
      total,
      pages: Math.ceil(total / limit),
      hasNext: skip + limit < total,
      hasPrev: page > 1,
    },
  };
}


// ==========================================
// CURSOR PAGINATION (Recommended for large datasets)
// ==========================================

export async function getPostsWithCursor(
  cursor?: string,
  limit = 20
) {
  const posts = await prisma.post.findMany({
    where: { status: 'PUBLISHED' },
    orderBy: { publishedAt: 'desc' },
    take: limit + 1,  // Fetch one extra to check hasMore
    ...(cursor && {
      cursor: { id: cursor },
      skip: 1,  // Skip the cursor item
    }),
  });
  
  const hasMore = posts.length > limit;
  const items = hasMore ? posts.slice(0, -1) : posts;
  
  return {
    posts: items,
    pagination: {
      nextCursor: hasMore ? items[items.length - 1]?.id : null,
      hasMore,
    },
  };
}


// ==========================================
// INFINITE SCROLL COMPONENT
// ==========================================

// app/posts/page.tsx
import { getPostsWithCursor } from '@/lib/queries/posts';
import { InfinitePostList } from '@/components/InfinitePostList';

export default async function PostsPage() {
  const initialData = await getPostsWithCursor();
  
  return <InfinitePostList initialData={initialData} />;
}

// components/InfinitePostList.tsx
'use client';

import { useInfiniteQuery } from '@tanstack/react-query';
import { useInView } from 'react-intersection-observer';
import { useEffect } from 'react';

export function InfinitePostList({ initialData }) {
  const { ref, inView } = useInView();
  
  const { data, fetchNextPage, hasNextPage, isFetchingNextPage } = 
    useInfiniteQuery({
      queryKey: ['posts'],
      queryFn: async ({ pageParam }) => {
        const res = await fetch(`/api/posts?cursor=${pageParam || ''}`);
        return res.json();
      },
      initialPageParam: null,
      getNextPageParam: (lastPage) => lastPage.pagination.nextCursor,
      initialData: { pages: [initialData], pageParams: [null] },
    });

  useEffect(() => {
    if (inView && hasNextPage) {
      fetchNextPage();
    }
  }, [inView, hasNextPage, fetchNextPage]);

  const posts = data?.pages.flatMap(page => page.posts) ?? [];

  return (
    <div>
      {posts.map(post => (
        <PostCard key={post.id} post={post} />
      ))}
      
      <div ref={ref}>
        {isFetchingNextPage && <LoadingSpinner />}
      </div>
    </div>
  );
}
```

---

## 7) Drizzle ORM Alternative

### Drizzle Setup
```typescript
// ==========================================
// DRIZZLE SCHEMA
// ==========================================

// db/schema.ts
import { pgTable, text, timestamp, uuid, pgEnum, integer } from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';

export const roleEnum = pgEnum('role', ['USER', 'MODERATOR', 'ADMIN']);
export const postStatusEnum = pgEnum('post_status', ['DRAFT', 'PUBLISHED', 'ARCHIVED']);

export const users = pgTable('users', {
  id: uuid('id').primaryKey().defaultRandom(),
  email: text('email').notNull().unique(),
  name: text('name'),
  image: text('image'),
  role: roleEnum('role').default('USER'),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});

export const posts = pgTable('posts', {
  id: uuid('id').primaryKey().defaultRandom(),
  title: text('title').notNull(),
  slug: text('slug').notNull().unique(),
  content: text('content').notNull(),
  status: postStatusEnum('status').default('DRAFT'),
  authorId: uuid('author_id').notNull().references(() => users.id),
  publishedAt: timestamp('published_at'),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});

// Relations
export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}));

export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, {
    fields: [posts.authorId],
    references: [users.id],
  }),
}));


// ==========================================
// DRIZZLE CLIENT
// ==========================================

// db/index.ts
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import * as schema from './schema';

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

export const db = drizzle(pool, { schema });


// ==========================================
// DRIZZLE QUERIES
// ==========================================

import { db } from '@/db';
import { posts, users } from '@/db/schema';
import { eq, desc, and, sql } from 'drizzle-orm';

// Simple query
const allPosts = await db.select().from(posts);

// With filter and order
const publishedPosts = await db
  .select()
  .from(posts)
  .where(eq(posts.status, 'PUBLISHED'))
  .orderBy(desc(posts.publishedAt));

// With join
const postsWithAuthor = await db
  .select({
    id: posts.id,
    title: posts.title,
    authorName: users.name,
  })
  .from(posts)
  .leftJoin(users, eq(posts.authorId, users.id));

// Using relations (query API)
const postsWithRelations = await db.query.posts.findMany({
  where: eq(posts.status, 'PUBLISHED'),
  with: {
    author: true,
  },
  orderBy: desc(posts.publishedAt),
  limit: 20,
});

// Insert
const newPost = await db.insert(posts).values({
  title: 'New Post',
  slug: 'new-post',
  content: 'Content here',
  authorId: userId,
}).returning();

// Update
await db
  .update(posts)
  .set({ status: 'PUBLISHED', publishedAt: new Date() })
  .where(eq(posts.id, postId));

// Delete
await db.delete(posts).where(eq(posts.id, postId));
```

---

## 8) Seed Data

### Prisma Seed
```typescript
// ==========================================
// prisma/seed.ts
// ==========================================

import { PrismaClient } from '@prisma/client';
import { hash } from 'bcryptjs';
import { faker } from '@faker-js/faker';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  // Clear existing data (dev only!)
  await prisma.like.deleteMany();
  await prisma.comment.deleteMany();
  await prisma.tagsOnPosts.deleteMany();
  await prisma.post.deleteMany();
  await prisma.tag.deleteMany();
  await prisma.category.deleteMany();
  await prisma.user.deleteMany();

  // Create admin user
  const adminPassword = await hash('admin123', 12);
  const admin = await prisma.user.create({
    data: {
      email: 'admin@example.com',
      name: 'Admin User',
      password: adminPassword,
      role: 'ADMIN',
      emailVerified: new Date(),
    },
  });

  // Create regular users
  const users = await Promise.all(
    Array.from({ length: 10 }).map(async () => {
      const password = await hash('password123', 12);
      return prisma.user.create({
        data: {
          email: faker.internet.email(),
          name: faker.person.fullName(),
          password,
          image: faker.image.avatar(),
          role: 'USER',
          emailVerified: new Date(),
        },
      });
    })
  );

  // Create categories
  const categories = await Promise.all(
    ['Technology', 'Design', 'Business', 'Lifestyle'].map(name =>
      prisma.category.create({
        data: {
          name,
          slug: name.toLowerCase(),
          description: faker.lorem.sentence(),
        },
      })
    )
  );

  // Create tags
  const tags = await Promise.all(
    ['javascript', 'react', 'nextjs', 'typescript', 'css'].map(name =>
      prisma.tag.create({
        data: { name, slug: name },
      })
    )
  );

  // Create posts
  const allUsers = [admin, ...users];
  
  for (let i = 0; i < 50; i++) {
    const title = faker.lorem.sentence();
    const author = faker.helpers.arrayElement(allUsers);
    const category = faker.helpers.arrayElement(categories);
    const postTags = faker.helpers.arrayElements(tags, { min: 1, max: 3 });

    await prisma.post.create({
      data: {
        title,
        slug: faker.helpers.slugify(title).toLowerCase() + '-' + i,
        excerpt: faker.lorem.paragraph(),
        content: faker.lorem.paragraphs(5),
        image: faker.image.urlPicsumPhotos({ width: 800, height: 400 }),
        status: faker.helpers.arrayElement(['DRAFT', 'PUBLISHED', 'PUBLISHED']),
        publishedAt: faker.date.past(),
        authorId: author.id,
        categoryId: category.id,
        tags: {
          create: postTags.map(tag => ({
            tagId: tag.id,
          })),
        },
      },
    });
  }

  console.log('✅ Seeding complete!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
```

```json
// package.json
{
  "prisma": {
    "seed": "tsx prisma/seed.ts"
  }
}
```

```bash
# Run seed
npx prisma db seed
```

---

## Best Practices Checklist

### Setup
- [ ] Prisma Client singleton
- [ ] Proper connection pooling
- [ ] Type-safe queries
- [ ] Migrations versioned

### Performance
- [ ] Select only needed fields
- [ ] Indexes on queried columns
- [ ] Cursor pagination for large datasets
- [ ] Query caching configured

### Mutations
- [ ] Transactions for atomic ops
- [ ] Zod validation
- [ ] Error handling
- [ ] Cache revalidation

### Security
- [ ] Never expose credentials
- [ ] Soft deletes implemented
- [ ] Ownership checks
- [ ] Input sanitization

---

**References:**
- [Prisma Documentation](https://www.prisma.io/docs)
- [Drizzle ORM](https://orm.drizzle.team/)
- [Next.js Data Fetching](https://nextjs.org/docs/app/building-your-application/data-fetching)

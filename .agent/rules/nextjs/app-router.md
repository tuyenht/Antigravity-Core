# Next.js App Router Best Practices

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **Next.js:** 14.x / 15.x  
> **Priority:** P0 - Load for all Next.js App Router projects

---

You are an expert in Next.js App Router architecture and patterns.

## Core App Router Principles

- Use Server Components by default
- Use Client Components only when necessary
- Implement proper loading and error states
- Use Layouts for shared UI
- Leverage caching and revalidation

---

## 1) Project Structure

### Complete File Structure
```
app/
├── (marketing)/              # Route group (no URL segment)
│   ├── layout.tsx           # Marketing layout
│   ├── page.tsx             # Home page (/)
│   ├── about/
│   │   └── page.tsx         # About page (/about)
│   └── blog/
│       ├── page.tsx         # Blog list (/blog)
│       └── [slug]/
│           └── page.tsx     # Blog post (/blog/[slug])
│
├── (app)/                    # App route group
│   ├── layout.tsx           # App layout (authenticated)
│   ├── dashboard/
│   │   ├── page.tsx         # Dashboard (/dashboard)
│   │   ├── loading.tsx      # Loading state
│   │   ├── error.tsx        # Error boundary
│   │   └── @analytics/      # Parallel route
│   │       └── page.tsx
│   └── settings/
│       ├── page.tsx
│       └── profile/
│           └── page.tsx
│
├── api/                      # API routes
│   └── webhooks/
│       └── route.ts
│
├── _components/              # Private folder (not routable)
│   ├── Header.tsx
│   └── Footer.tsx
│
├── layout.tsx               # Root layout
├── not-found.tsx            # 404 page
├── error.tsx                # Global error
├── loading.tsx              # Global loading
└── globals.css
```

### File Conventions
```typescript
// page.tsx - Unique route UI
export default function Page() {
  return <div>Page content</div>;
}

// layout.tsx - Shared UI wrapper
export default function Layout({ children }: { children: React.ReactNode }) {
  return <div>{children}</div>;
}

// loading.tsx - Suspense fallback
export default function Loading() {
  return <div>Loading...</div>;
}

// error.tsx - Error boundary
'use client';
export default function Error({ error, reset }: {
  error: Error;
  reset: () => void;
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={() => reset()}>Try again</button>
    </div>
  );
}

// not-found.tsx - 404 UI
export default function NotFound() {
  return <div>Page not found</div>;
}

// route.ts - API endpoint
export async function GET(request: Request) {
  return Response.json({ hello: 'world' });
}
```

---

## 2) Server vs Client Components

### Decision Tree
```markdown
## Use Server Component (Default) When:
- Fetching data from database/API
- Accessing backend resources
- Using sensitive data (API keys, tokens)
- Using large dependencies (keep off client bundle)
- Rendering static content

## Use Client Component ('use client') When:
- Using React hooks (useState, useEffect, useContext)
- Adding event listeners (onClick, onChange)
- Using browser APIs (localStorage, geolocation)
- Using custom hooks with state
- Third-party libraries requiring client
```

### Component Pattern Examples
```tsx
// ==========================================
// SERVER COMPONENT (DEFAULT)
// ==========================================

// app/products/page.tsx
import { db } from '@/lib/db';
import { ProductCard } from '@/components/ProductCard';

export default async function ProductsPage() {
  // Direct database access - only possible in Server Components
  const products = await db.product.findMany({
    where: { isActive: true },
    orderBy: { createdAt: 'desc' },
  });

  return (
    <div className="grid grid-cols-3 gap-4">
      {products.map(product => (
        <ProductCard key={product.id} product={product} />
      ))}
    </div>
  );
}


// ==========================================
// CLIENT COMPONENT
// ==========================================

// components/AddToCartButton.tsx
'use client';

import { useState } from 'react';
import { useCart } from '@/hooks/useCart';

interface Props {
  productId: string;
  price: number;
}

export function AddToCartButton({ productId, price }: Props) {
  const [isLoading, setIsLoading] = useState(false);
  const { addItem } = useCart();

  const handleClick = async () => {
    setIsLoading(true);
    await addItem(productId);
    setIsLoading(false);
  };

  return (
    <button onClick={handleClick} disabled={isLoading}>
      {isLoading ? 'Adding...' : `Add to Cart - $${price}`}
    </button>
  );
}


// ==========================================
// COMPOSITION PATTERN
// ==========================================

// Server Component wrapping Client Component
// app/products/[id]/page.tsx
import { db } from '@/lib/db';
import { AddToCartButton } from '@/components/AddToCartButton';
import { ProductGallery } from '@/components/ProductGallery';

export default async function ProductPage({
  params,
}: {
  params: { id: string };
}) {
  const product = await db.product.findUnique({
    where: { id: params.id },
  });

  if (!product) {
    notFound();
  }

  return (
    <div>
      <h1>{product.name}</h1>
      
      {/* Client Component receives serializable props */}
      <ProductGallery images={product.images} />
      
      {/* Pass only needed data */}
      <AddToCartButton 
        productId={product.id} 
        price={product.price} 
      />
    </div>
  );
}
```

---

## 3) Data Fetching & Caching

### Server Component Fetching
```tsx
// ==========================================
// STATIC DATA (Default - Cached Forever)
// ==========================================

async function getProducts() {
  const res = await fetch('https://api.example.com/products');
  // By default, fetch results are cached
  return res.json();
}


// ==========================================
// REVALIDATE AT INTERVAL
// ==========================================

async function getProducts() {
  const res = await fetch('https://api.example.com/products', {
    next: { revalidate: 3600 },  // Revalidate every hour
  });
  return res.json();
}


// ==========================================
// NO CACHE (Always Fresh)
// ==========================================

async function getProducts() {
  const res = await fetch('https://api.example.com/products', {
    cache: 'no-store',  // Always fetch fresh data
  });
  return res.json();
}


// ==========================================
// DYNAMIC DATA WITH DATABASE
// ==========================================

import { unstable_cache } from 'next/cache';

// Cached database query with tags
const getUser = unstable_cache(
  async (id: string) => {
    return db.user.findUnique({ where: { id } });
  },
  ['user'],  // Cache key prefix
  {
    revalidate: 3600,  // 1 hour
    tags: ['user'],    // For manual revalidation
  }
);

// Usage
const user = await getUser(userId);


// ==========================================
// PARALLEL DATA FETCHING
// ==========================================

export default async function Dashboard() {
  // Parallel fetching - much faster!
  const [user, orders, analytics] = await Promise.all([
    getUser(),
    getOrders(),
    getAnalytics(),
  ]);

  return (
    <div>
      <UserProfile user={user} />
      <OrderList orders={orders} />
      <AnalyticsChart data={analytics} />
    </div>
  );
}
```

### Revalidation Strategies
```tsx
// ==========================================
// ON-DEMAND REVALIDATION
// ==========================================

// app/api/revalidate/route.ts
import { revalidatePath, revalidateTag } from 'next/cache';
import { NextRequest } from 'next/server';

export async function POST(request: NextRequest) {
  const { path, tag, secret } = await request.json();

  // Verify secret
  if (secret !== process.env.REVALIDATION_SECRET) {
    return Response.json({ error: 'Invalid secret' }, { status: 401 });
  }

  if (path) {
    revalidatePath(path);  // Revalidate specific path
  }
  
  if (tag) {
    revalidateTag(tag);    // Revalidate by tag
  }

  return Response.json({ revalidated: true, now: Date.now() });
}


// ==========================================
// REVALIDATE FROM SERVER ACTION
// ==========================================

// app/actions.ts
'use server';

import { revalidatePath } from 'next/cache';

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string;
  const content = formData.get('content') as string;

  await db.post.create({
    data: { title, content },
  });

  // Revalidate the posts page
  revalidatePath('/posts');
}
```

---

## 4) Server Actions

### Complete Server Actions Pattern
```tsx
// ==========================================
// FORM WITH SERVER ACTION
// ==========================================

// app/actions.ts
'use server';

import { z } from 'zod';
import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';

const CreatePostSchema = z.object({
  title: z.string().min(1).max(100),
  content: z.string().min(10),
  published: z.boolean().default(false),
});

export type State = {
  errors?: {
    title?: string[];
    content?: string[];
  };
  message?: string;
};

export async function createPost(
  prevState: State,
  formData: FormData
): Promise<State> {
  // Validate
  const validatedFields = CreatePostSchema.safeParse({
    title: formData.get('title'),
    content: formData.get('content'),
    published: formData.get('published') === 'on',
  });

  if (!validatedFields.success) {
    return {
      errors: validatedFields.error.flatten().fieldErrors,
      message: 'Validation failed',
    };
  }

  // Create post
  try {
    await db.post.create({
      data: validatedFields.data,
    });
  } catch (error) {
    return { message: 'Database error: Failed to create post' };
  }

  // Revalidate and redirect
  revalidatePath('/posts');
  redirect('/posts');
}


// ==========================================
// FORM COMPONENT
// ==========================================

// app/posts/new/page.tsx
'use client';

import { useFormState, useFormStatus } from 'react-dom';
import { createPost, State } from '@/app/actions';

function SubmitButton() {
  const { pending } = useFormStatus();
  
  return (
    <button type="submit" disabled={pending}>
      {pending ? 'Creating...' : 'Create Post'}
    </button>
  );
}

export default function NewPostPage() {
  const initialState: State = { message: '', errors: {} };
  const [state, formAction] = useFormState(createPost, initialState);

  return (
    <form action={formAction}>
      <div>
        <label htmlFor="title">Title</label>
        <input id="title" name="title" type="text" />
        {state.errors?.title && (
          <p className="error">{state.errors.title}</p>
        )}
      </div>

      <div>
        <label htmlFor="content">Content</label>
        <textarea id="content" name="content" />
        {state.errors?.content && (
          <p className="error">{state.errors.content}</p>
        )}
      </div>

      <SubmitButton />
      
      {state.message && <p className="message">{state.message}</p>}
    </form>
  );
}


// ==========================================
// OPTIMISTIC UPDATES
// ==========================================

'use client';

import { useOptimistic } from 'react';
import { likePost } from '@/app/actions';

export function LikeButton({ postId, initialLikes }: {
  postId: string;
  initialLikes: number;
}) {
  const [optimisticLikes, addOptimisticLike] = useOptimistic(
    initialLikes,
    (state, _) => state + 1
  );

  const handleLike = async () => {
    addOptimisticLike(null);  // Optimistic update
    await likePost(postId);   // Server action
  };

  return (
    <form action={handleLike}>
      <button type="submit">
        ❤️ {optimisticLikes}
      </button>
    </form>
  );
}
```

---

## 5) Layouts and Templates

### Layout Patterns
```tsx
// ==========================================
// ROOT LAYOUT (Required)
// ==========================================

// app/layout.tsx
import { Inter } from 'next/font/google';
import { Analytics } from '@/components/Analytics';
import { Providers } from '@/components/Providers';
import './globals.css';

const inter = Inter({ subsets: ['latin'] });

export const metadata = {
  title: {
    default: 'My App',
    template: '%s | My App',  // Page titles become "Page | My App"
  },
  description: 'My awesome application',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={inter.className}>
        <Providers>
          {children}
        </Providers>
        <Analytics />
      </body>
    </html>
  );
}


// ==========================================
// NESTED LAYOUT
// ==========================================

// app/(app)/layout.tsx
import { auth } from '@/lib/auth';
import { redirect } from 'next/navigation';
import { Sidebar } from '@/components/Sidebar';
import { Header } from '@/components/Header';

export default async function AppLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const session = await auth();
  
  if (!session) {
    redirect('/login');
  }

  return (
    <div className="flex h-screen">
      <Sidebar user={session.user} />
      <div className="flex-1 flex flex-col">
        <Header user={session.user} />
        <main className="flex-1 overflow-auto p-6">
          {children}
        </main>
      </div>
    </div>
  );
}


// ==========================================
// TEMPLATE (Re-mounts on navigation)
// ==========================================

// app/(app)/template.tsx
export default function Template({
  children,
}: {
  children: React.ReactNode;
}) {
  // This component re-renders on every navigation
  // Useful for enter/exit animations
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
    >
      {children}
    </motion.div>
  );
}
```

---

## 6) Advanced Routing

### Parallel Routes
```tsx
// app/dashboard/layout.tsx
export default function DashboardLayout({
  children,
  team,        // @team slot
  analytics,   // @analytics slot
}: {
  children: React.ReactNode;
  team: React.ReactNode;
  analytics: React.ReactNode;
}) {
  return (
    <div className="grid grid-cols-3 gap-4">
      <div className="col-span-2">{children}</div>
      <div className="space-y-4">
        {team}
        {analytics}
      </div>
    </div>
  );
}

// app/dashboard/@team/page.tsx
export default function TeamSlot() {
  return <TeamMembers />;
}

// app/dashboard/@analytics/page.tsx
export default function AnalyticsSlot() {
  return <AnalyticsChart />;
}

// app/dashboard/@team/loading.tsx
export default function TeamLoading() {
  return <TeamSkeleton />;
}
```

### Intercepting Routes
```tsx
// Modal pattern - Intercept route for modal, direct access for full page

// app/photos/[id]/page.tsx (Full page view)
export default function PhotoPage({ params }: { params: { id: string } }) {
  return <PhotoDetail id={params.id} fullPage />;
}

// app/@modal/(.)photos/[id]/page.tsx (Modal view)
export default function PhotoModal({ params }: { params: { id: string } }) {
  return (
    <Modal>
      <PhotoDetail id={params.id} />
    </Modal>
  );
}

// app/layout.tsx
export default function RootLayout({
  children,
  modal,
}: {
  children: React.ReactNode;
  modal: React.ReactNode;
}) {
  return (
    <html>
      <body>
        {children}
        {modal}
      </body>
    </html>
  );
}
```

---

## 7) Metadata and SEO

### Metadata Configuration
```tsx
// ==========================================
// STATIC METADATA
// ==========================================

// app/layout.tsx
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: {
    default: 'My Site',
    template: '%s | My Site',
  },
  description: 'Welcome to my site',
  keywords: ['Next.js', 'React', 'TypeScript'],
  authors: [{ name: 'John' }],
  creator: 'John',
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: 'https://mysite.com',
    siteName: 'My Site',
    images: [
      {
        url: '/og-image.png',
        width: 1200,
        height: 630,
        alt: 'My Site',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    creator: '@john',
  },
  robots: {
    index: true,
    follow: true,
  },
};


// ==========================================
// DYNAMIC METADATA
// ==========================================

// app/posts/[slug]/page.tsx
import type { Metadata, ResolvingMetadata } from 'next';

interface Props {
  params: { slug: string };
}

export async function generateMetadata(
  { params }: Props,
  parent: ResolvingMetadata
): Promise<Metadata> {
  const post = await getPost(params.slug);

  // Optionally access parent metadata
  const previousImages = (await parent).openGraph?.images || [];

  return {
    title: post.title,
    description: post.excerpt,
    openGraph: {
      title: post.title,
      description: post.excerpt,
      images: [post.image, ...previousImages],
    },
  };
}

export default async function PostPage({ params }: Props) {
  const post = await getPost(params.slug);
  return <PostContent post={post} />;
}


// ==========================================
// GENERATE STATIC PARAMS
// ==========================================

export async function generateStaticParams() {
  const posts = await getAllPosts();
  
  return posts.map((post) => ({
    slug: post.slug,
  }));
}
```

---

## 8) Error Handling

### Comprehensive Error Handling
```tsx
// ==========================================
// GLOBAL ERROR BOUNDARY
// ==========================================

// app/error.tsx
'use client';

import { useEffect } from 'react';

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    // Log to error reporting service
    console.error(error);
  }, [error]);

  return (
    <div className="flex flex-col items-center justify-center min-h-screen">
      <h2 className="text-2xl font-bold">Something went wrong!</h2>
      <p className="text-gray-600 mt-2">{error.message}</p>
      <button
        onClick={() => reset()}
        className="mt-4 px-4 py-2 bg-blue-500 text-white rounded"
      >
        Try again
      </button>
    </div>
  );
}


// ==========================================
// GLOBAL NOT FOUND
// ==========================================

// app/not-found.tsx
import Link from 'next/link';

export default function NotFound() {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen">
      <h1 className="text-6xl font-bold">404</h1>
      <p className="text-xl mt-4">Page not found</p>
      <Link href="/" className="mt-4 text-blue-500 hover:underline">
        Go back home
      </Link>
    </div>
  );
}


// ==========================================
// PROGRAMMATIC NOT FOUND
// ==========================================

import { notFound } from 'next/navigation';

export default async function PostPage({ params }: { params: { slug: string } }) {
  const post = await getPost(params.slug);
  
  if (!post) {
    notFound();  // Triggers closest not-found.tsx
  }
  
  return <PostContent post={post} />;
}
```

---

## Best Practices Checklist

### Architecture
- [ ] Server Components by default
- [ ] Client Components only for interactivity
- [ ] Proper file structure
- [ ] Route groups for organization

### Data Fetching
- [ ] Fetch in Server Components
- [ ] Parallel data fetching
- [ ] Proper caching strategy
- [ ] Revalidation configured

### Server Actions
- [ ] Validation with Zod
- [ ] Error handling
- [ ] Optimistic updates
- [ ] Proper revalidation

### UX
- [ ] Loading states
- [ ] Error boundaries
- [ ] Not found pages
- [ ] Metadata/SEO

---

**References:**
- [Next.js App Router Docs](https://nextjs.org/docs/app)
- [Server Components](https://nextjs.org/docs/app/building-your-application/rendering/server-components)
- [Data Fetching](https://nextjs.org/docs/app/building-your-application/data-fetching)
- [Server Actions](https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions-and-mutations)

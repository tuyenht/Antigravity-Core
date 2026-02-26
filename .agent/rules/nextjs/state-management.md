# Next.js State Management Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **React Query:** v5.x | **Zustand:** v4.x  
> **Priority:** P0 - Load for all state management tasks

---

You are an expert in Next.js state management patterns and libraries.

## Core State Management Principles

- Use Server Components for server state
- Use React Query for async state
- Use Zustand for client state
- Minimize client-side state
- Leverage URL for shareable state

---

## 1) State Management Strategy

### Decision Tree
```
┌─────────────────────────────────────────────────────────────────┐
│                    What Kind of State?                          │
└──────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
   Server Data          Client-Only            Shareable
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│ Server        │    │ Local State?  │    │ URL State     │
│ Components +  │    │               │    │ (nuqs)        │
│ React Query   │    │   Yes    No   │    │               │
│               │    │    │      │   │    │ - Filters     │
│ - Fetch in SC │    │    ▼      ▼   │    │ - Pagination  │
│ - Cache       │    │ useState Zustand   │ - Tabs        │
│ - Revalidate  │    │         ↓     │    │ - Search      │
└────────────┘    │    Persist?   │    └────────────┘
                     │    Yes → Zustand    
                     │           + persist 
                     └────────────┘
```

---

## 2) React Query (TanStack Query)

### Setup & Provider
```typescript
// ==========================================
// lib/query-client.ts
// ==========================================

import { QueryClient } from '@tanstack/react-query';

function makeQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        // Don't refetch on window focus in development
        refetchOnWindowFocus: process.env.NODE_ENV === 'production',
        
        // Cache for 5 minutes
        staleTime: 5 * 60 * 1000,
        
        // Keep in cache for 30 minutes
        gcTime: 30 * 60 * 1000,
        
        // Retry failed queries
        retry: 2,
        retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000),
      },
      mutations: {
        // Retry mutations once
        retry: 1,
      },
    },
  });
}

// Singleton for browser
let browserQueryClient: QueryClient | undefined = undefined;

export function getQueryClient() {
  if (typeof window === 'undefined') {
    // Server: always make a new query client
    return makeQueryClient();
  } else {
    // Browser: make a new client if we don't have one
    if (!browserQueryClient) browserQueryClient = makeQueryClient();
    return browserQueryClient;
  }
}


// ==========================================
// components/providers/QueryProvider.tsx
// ==========================================

'use client';

import { QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import { useState } from 'react';
import { getQueryClient } from '@/lib/query-client';

export function QueryProvider({ children }: { children: React.ReactNode }) {
  // This ensures each request gets its own client
  const [queryClient] = useState(() => getQueryClient());

  return (
    <QueryClientProvider client={queryClient}>
      {children}
      {process.env.NODE_ENV === 'development' && (
        <ReactQueryDevtools initialIsOpen={false} />
      )}
    </QueryClientProvider>
  );
}


// ==========================================
// app/layout.tsx
// ==========================================

import { QueryProvider } from '@/components/providers/QueryProvider';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        <QueryProvider>
          {children}
        </QueryProvider>
      </body>
    </html>
  );
}
```

### Query Hooks
```typescript
// ==========================================
// hooks/queries/usePosts.ts
// ==========================================

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

// Query keys factory
export const postKeys = {
  all: ['posts'] as const,
  lists: () => [...postKeys.all, 'list'] as const,
  list: (filters: PostFilters) => [...postKeys.lists(), filters] as const,
  details: () => [...postKeys.all, 'detail'] as const,
  detail: (id: string) => [...postKeys.details(), id] as const,
};

// Types
interface Post {
  id: string;
  title: string;
  content: string;
  authorId: string;
  createdAt: string;
}

interface PostFilters {
  page?: number;
  limit?: number;
  status?: string;
  search?: string;
}

// Fetch functions
async function fetchPosts(filters: PostFilters): Promise<{
  posts: Post[];
  total: number;
}> {
  const params = new URLSearchParams();
  if (filters.page) params.set('page', filters.page.toString());
  if (filters.limit) params.set('limit', filters.limit.toString());
  if (filters.status) params.set('status', filters.status);
  if (filters.search) params.set('q', filters.search);
  
  const res = await fetch(`/api/posts?${params}`);
  if (!res.ok) throw new Error('Failed to fetch posts');
  return res.json();
}

async function fetchPost(id: string): Promise<Post> {
  const res = await fetch(`/api/posts/${id}`);
  if (!res.ok) throw new Error('Failed to fetch post');
  return res.json();
}

// Query hooks
export function usePosts(filters: PostFilters = {}) {
  return useQuery({
    queryKey: postKeys.list(filters),
    queryFn: () => fetchPosts(filters),
    staleTime: 5 * 60 * 1000,
  });
}

export function usePost(id: string) {
  return useQuery({
    queryKey: postKeys.detail(id),
    queryFn: () => fetchPost(id),
    enabled: !!id,
  });
}

// Mutation hooks
export function useCreatePost() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async (data: Omit<Post, 'id' | 'createdAt'>) => {
      const res = await fetch('/api/posts', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });
      if (!res.ok) throw new Error('Failed to create post');
      return res.json();
    },
    onSuccess: () => {
      // Invalidate all post lists
      queryClient.invalidateQueries({ queryKey: postKeys.lists() });
    },
  });
}

export function useUpdatePost() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async ({ id, ...data }: Partial<Post> & { id: string }) => {
      const res = await fetch(`/api/posts/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });
      if (!res.ok) throw new Error('Failed to update post');
      return res.json();
    },
    onSuccess: (data, variables) => {
      // Update cache directly
      queryClient.setQueryData(postKeys.detail(variables.id), data);
      // Invalidate lists
      queryClient.invalidateQueries({ queryKey: postKeys.lists() });
    },
  });
}

export function useDeletePost() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async (id: string) => {
      const res = await fetch(`/api/posts/${id}`, { method: 'DELETE' });
      if (!res.ok) throw new Error('Failed to delete post');
    },
    onSuccess: (_, id) => {
      queryClient.removeQueries({ queryKey: postKeys.detail(id) });
      queryClient.invalidateQueries({ queryKey: postKeys.lists() });
    },
  });
}
```

### Optimistic Updates
```typescript
// ==========================================
// OPTIMISTIC UPDATE PATTERN
// ==========================================

export function useLikePost() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async (postId: string) => {
      const res = await fetch(`/api/posts/${postId}/like`, { method: 'POST' });
      if (!res.ok) throw new Error('Failed to like post');
      return res.json();
    },
    
    // Optimistic update
    onMutate: async (postId) => {
      // Cancel outgoing refetches
      await queryClient.cancelQueries({ queryKey: postKeys.detail(postId) });
      
      // Snapshot previous value
      const previousPost = queryClient.getQueryData<Post>(postKeys.detail(postId));
      
      // Optimistically update
      if (previousPost) {
        queryClient.setQueryData(postKeys.detail(postId), {
          ...previousPost,
          likes: previousPost.likes + 1,
          isLiked: true,
        });
      }
      
      return { previousPost };
    },
    
    // Rollback on error
    onError: (err, postId, context) => {
      if (context?.previousPost) {
        queryClient.setQueryData(postKeys.detail(postId), context.previousPost);
      }
    },
    
    // Always refetch after error or success
    onSettled: (_, __, postId) => {
      queryClient.invalidateQueries({ queryKey: postKeys.detail(postId) });
    },
  });
}


// ==========================================
// USAGE IN COMPONENT
// ==========================================

'use client';

import { usePosts, useCreatePost } from '@/hooks/queries/usePosts';

export function PostList() {
  const { data, isLoading, error } = usePosts({ page: 1, limit: 20 });
  const createPost = useCreatePost();

  if (isLoading) return <Skeleton />;
  if (error) return <Error message={error.message} />;

  const handleCreate = async (data: CreatePostData) => {
    try {
      await createPost.mutateAsync(data);
      toast.success('Post created!');
    } catch (error) {
      toast.error('Failed to create post');
    }
  };

  return (
    <div>
      <CreatePostForm onSubmit={handleCreate} isLoading={createPost.isPending} />
      
      <div className="posts-grid">
        {data?.posts.map(post => (
          <PostCard key={post.id} post={post} />
        ))}
      </div>
    </div>
  );
}
```

---

## 3) Zustand for Client State

### Store Patterns
```typescript
// ==========================================
// stores/uiStore.ts
// ==========================================

import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

interface UIState {
  // State
  sidebarOpen: boolean;
  theme: 'light' | 'dark' | 'system';
  commandPaletteOpen: boolean;
  
  // Actions
  toggleSidebar: () => void;
  setSidebarOpen: (open: boolean) => void;
  setTheme: (theme: 'light' | 'dark' | 'system') => void;
  toggleCommandPalette: () => void;
}

export const useUIStore = create<UIState>()(
  devtools(
    persist(
      (set) => ({
        // Initial state
        sidebarOpen: true,
        theme: 'system',
        commandPaletteOpen: false,
        
        // Actions
        toggleSidebar: () => 
          set((state) => ({ sidebarOpen: !state.sidebarOpen })),
        
        setSidebarOpen: (open) => 
          set({ sidebarOpen: open }),
        
        setTheme: (theme) => 
          set({ theme }),
        
        toggleCommandPalette: () =>
          set((state) => ({ commandPaletteOpen: !state.commandPaletteOpen })),
      }),
      {
        name: 'ui-storage',
        partialize: (state) => ({
          sidebarOpen: state.sidebarOpen,
          theme: state.theme,
        }),
      }
    ),
    { name: 'UIStore' }
  )
);


// ==========================================
// stores/cartStore.ts
// ==========================================

import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';

interface CartItem {
  id: string;
  name: string;
  price: number;
  quantity: number;
  image: string;
}

interface CartState {
  items: CartItem[];
  
  // Computed (as getters)
  totalItems: () => number;
  totalPrice: () => number;
  
  // Actions
  addItem: (item: Omit<CartItem, 'quantity'>) => void;
  removeItem: (id: string) => void;
  updateQuantity: (id: string, quantity: number) => void;
  clearCart: () => void;
}

export const useCartStore = create<CartState>()(
  persist(
    immer((set, get) => ({
      items: [],
      
      // Computed values as methods
      totalItems: () => get().items.reduce((sum, item) => sum + item.quantity, 0),
      
      totalPrice: () => 
        get().items.reduce((sum, item) => sum + item.price * item.quantity, 0),
      
      addItem: (newItem) =>
        set((state) => {
          const existingItem = state.items.find((item) => item.id === newItem.id);
          
          if (existingItem) {
            existingItem.quantity += 1;
          } else {
            state.items.push({ ...newItem, quantity: 1 });
          }
        }),
      
      removeItem: (id) =>
        set((state) => {
          state.items = state.items.filter((item) => item.id !== id);
        }),
      
      updateQuantity: (id, quantity) =>
        set((state) => {
          const item = state.items.find((item) => item.id === id);
          if (item) {
            if (quantity <= 0) {
              state.items = state.items.filter((i) => i.id !== id);
            } else {
              item.quantity = quantity;
            }
          }
        }),
      
      clearCart: () => set({ items: [] }),
    })),
    {
      name: 'cart-storage',
      storage: createJSONStorage(() => localStorage),
    }
  )
);


// ==========================================
// stores/authStore.ts (No persist for security)
// ==========================================

import { create } from 'zustand';

interface User {
  id: string;
  email: string;
  name: string;
  image?: string;
  role: string;
}

interface AuthState {
  user: User | null;
  isLoading: boolean;
  
  setUser: (user: User | null) => void;
  setLoading: (loading: boolean) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isLoading: true,
  
  setUser: (user) => set({ user, isLoading: false }),
  setLoading: (isLoading) => set({ isLoading }),
  logout: () => set({ user: null }),
}));
```

### Store Usage in Components
```typescript
// ==========================================
// COMPONENT USAGE
// ==========================================

'use client';

import { useUIStore } from '@/stores/uiStore';
import { useCartStore } from '@/stores/cartStore';
import { shallow } from 'zustand/shallow';

// ❌ Bad: Subscribes to entire store
function BadComponent() {
  const store = useUIStore();
  return <div>{store.sidebarOpen ? 'Open' : 'Closed'}</div>;
}

// ✅ Good: Subscribe only to what you need
function GoodComponent() {
  const sidebarOpen = useUIStore((state) => state.sidebarOpen);
  return <div>{sidebarOpen ? 'Open' : 'Closed'}</div>;
}

// ✅ Multiple values with shallow comparison
function CartBadge() {
  const { totalItems, totalPrice } = useCartStore(
    (state) => ({
      totalItems: state.totalItems(),
      totalPrice: state.totalPrice(),
    }),
    shallow
  );

  return (
    <div className="badge">
      {totalItems} items · ${totalPrice.toFixed(2)}
    </div>
  );
}

// ✅ Actions don't cause re-renders
function AddToCartButton({ product }: { product: Product }) {
  const addItem = useCartStore((state) => state.addItem);
  
  return (
    <button onClick={() => addItem(product)}>
      Add to Cart
    </button>
  );
}


// ==========================================
// HYDRATION HANDLING
// ==========================================

'use client';

import { useEffect, useState } from 'react';
import { useCartStore } from '@/stores/cartStore';

// Prevents hydration mismatch
export function CartCount() {
  const [mounted, setMounted] = useState(false);
  const totalItems = useCartStore((state) => state.totalItems());
  
  useEffect(() => {
    setMounted(true);
  }, []);
  
  if (!mounted) {
    return <span className="cart-count">0</span>;
  }
  
  return <span className="cart-count">{totalItems}</span>;
}

// Or use a custom hook
function useHydrated() {
  const [hydrated, setHydrated] = useState(false);
  
  useEffect(() => {
    setHydrated(true);
  }, []);
  
  return hydrated;
}
```

---

## 4) URL State with nuqs

### Type-Safe URL State
```typescript
// ==========================================
// SETUP nuqs
// ==========================================

// npm install nuqs

// Usage in Client Component
'use client';

import { useQueryState, parseAsInteger, parseAsString, parseAsStringEnum } from 'nuqs';

// Simple string state
export function SearchPage() {
  const [search, setSearch] = useQueryState('q');
  
  return (
    <input
      value={search || ''}
      onChange={(e) => setSearch(e.target.value || null)}
      placeholder="Search..."
    />
  );
}

// With parsers
export function ProductsPage() {
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1));
  const [limit, setLimit] = useQueryState('limit', parseAsInteger.withDefault(20));
  const [sort, setSort] = useQueryState('sort', parseAsString.withDefault('newest'));
  const [category, setCategory] = useQueryState(
    'category',
    parseAsStringEnum(['all', 'electronics', 'clothing', 'books']).withDefault('all')
  );
  
  return (
    <div>
      <select value={category} onChange={(e) => setCategory(e.target.value as any)}>
        <option value="all">All Categories</option>
        <option value="electronics">Electronics</option>
        <option value="clothing">Clothing</option>
        <option value="books">Books</option>
      </select>
      
      <select value={sort} onChange={(e) => setSort(e.target.value)}>
        <option value="newest">Newest</option>
        <option value="price-asc">Price: Low to High</option>
        <option value="price-desc">Price: High to Low</option>
      </select>
      
      <Pagination 
        page={page} 
        onPageChange={setPage} 
        limit={limit}
        onLimitChange={setLimit}
      />
    </div>
  );
}


// ==========================================
// GROUPED URL STATE
// ==========================================

import { useQueryStates, parseAsInteger, parseAsString } from 'nuqs';

const searchParams = {
  q: parseAsString.withDefault(''),
  page: parseAsInteger.withDefault(1),
  limit: parseAsInteger.withDefault(20),
  category: parseAsString.withDefault('all'),
};

export function AdvancedSearch() {
  const [params, setParams] = useQueryStates(searchParams);
  
  const handleSearch = (query: string) => {
    setParams({
      q: query || null,
      page: 1,  // Reset page on new search
    });
  };
  
  const handleCategoryChange = (category: string) => {
    setParams({
      category: category === 'all' ? null : category,
      page: 1,
    });
  };
  
  return (
    <div>
      <input
        value={params.q}
        onChange={(e) => handleSearch(e.target.value)}
        placeholder="Search..."
      />
      
      <select
        value={params.category}
        onChange={(e) => handleCategoryChange(e.target.value)}
      >
        <option value="all">All</option>
        <option value="electronics">Electronics</option>
      </select>
      
      <p>Page: {params.page} | Limit: {params.limit}</p>
    </div>
  );
}


// ==========================================
// SERVER COMPONENT URL PARAMS
// ==========================================

// app/products/page.tsx (Server Component)
interface Props {
  searchParams: {
    q?: string;
    page?: string;
    category?: string;
  };
}

export default async function ProductsPage({ searchParams }: Props) {
  const page = parseInt(searchParams.page || '1');
  const search = searchParams.q || '';
  const category = searchParams.category || 'all';
  
  const products = await getProducts({ page, search, category });
  
  return (
    <div>
      {/* Client component for filters */}
      <ProductFilters />
      
      {/* Server-rendered products */}
      <ProductGrid products={products} />
    </div>
  );
}
```

---

## 5) Form State with React Hook Form

### Form with Zod Validation
```typescript
// ==========================================
// FORM STATE MANAGEMENT
// ==========================================

'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useTransition } from 'react';
import { createPost } from '@/app/actions/posts';

const PostSchema = z.object({
  title: z.string().min(1, 'Title is required').max(100),
  content: z.string().min(10, 'Content must be at least 10 characters'),
  categoryId: z.string().uuid('Please select a category'),
  tags: z.array(z.string()).max(5, 'Maximum 5 tags'),
  published: z.boolean().default(false),
});

type PostFormData = z.infer<typeof PostSchema>;

export function CreatePostForm() {
  const [isPending, startTransition] = useTransition();
  
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    reset,
    setValue,
    watch,
  } = useForm<PostFormData>({
    resolver: zodResolver(PostSchema),
    defaultValues: {
      title: '',
      content: '',
      categoryId: '',
      tags: [],
      published: false,
    },
  });

  const onSubmit = async (data: PostFormData) => {
    startTransition(async () => {
      const formData = new FormData();
      Object.entries(data).forEach(([key, value]) => {
        if (Array.isArray(value)) {
          value.forEach((v) => formData.append(key, v));
        } else {
          formData.append(key, String(value));
        }
      });
      
      const result = await createPost({} as any, formData);
      
      if (result.success) {
        toast.success('Post created!');
        reset();
      } else {
        toast.error(result.error || 'Failed to create post');
      }
    });
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div>
        <label htmlFor="title">Title</label>
        <input
          id="title"
          {...register('title')}
          className={errors.title ? 'input-error' : ''}
        />
        {errors.title && (
          <p className="text-error">{errors.title.message}</p>
        )}
      </div>

      <div>
        <label htmlFor="content">Content</label>
        <textarea
          id="content"
          {...register('content')}
          rows={6}
        />
        {errors.content && (
          <p className="text-error">{errors.content.message}</p>
        )}
      </div>

      <div>
        <label htmlFor="categoryId">Category</label>
        <select {...register('categoryId')}>
          <option value="">Select category</option>
          <option value="uuid-1">Technology</option>
          <option value="uuid-2">Design</option>
        </select>
        {errors.categoryId && (
          <p className="text-error">{errors.categoryId.message}</p>
        )}
      </div>

      <div className="flex items-center gap-2">
        <input type="checkbox" {...register('published')} />
        <label>Publish immediately</label>
      </div>

      <button
        type="submit"
        disabled={isSubmitting || isPending}
      >
        {isSubmitting || isPending ? 'Creating...' : 'Create Post'}
      </button>
    </form>
  );
}
```

---

## 6) Context API (When Needed)

### Theme Context
```typescript
// ==========================================
// contexts/ThemeContext.tsx
// ==========================================

'use client';

import { createContext, useContext, useEffect, useState } from 'react';

type Theme = 'light' | 'dark' | 'system';

interface ThemeContextType {
  theme: Theme;
  resolvedTheme: 'light' | 'dark';
  setTheme: (theme: Theme) => void;
}

const ThemeContext = createContext<ThemeContextType | null>(null);

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState<Theme>('system');
  const [resolvedTheme, setResolvedTheme] = useState<'light' | 'dark'>('light');

  useEffect(() => {
    // Load from localStorage
    const stored = localStorage.getItem('theme') as Theme | null;
    if (stored) setTheme(stored);
  }, []);

  useEffect(() => {
    // Resolve system theme
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    
    const updateResolvedTheme = () => {
      if (theme === 'system') {
        setResolvedTheme(mediaQuery.matches ? 'dark' : 'light');
      } else {
        setResolvedTheme(theme);
      }
    };

    updateResolvedTheme();
    mediaQuery.addEventListener('change', updateResolvedTheme);
    
    return () => mediaQuery.removeEventListener('change', updateResolvedTheme);
  }, [theme]);

  useEffect(() => {
    // Apply theme to DOM
    document.documentElement.classList.remove('light', 'dark');
    document.documentElement.classList.add(resolvedTheme);
  }, [resolvedTheme]);

  const handleSetTheme = (newTheme: Theme) => {
    setTheme(newTheme);
    localStorage.setItem('theme', newTheme);
  };

  return (
    <ThemeContext.Provider value={{ theme, resolvedTheme, setTheme: handleSetTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within ThemeProvider');
  }
  return context;
}
```

---

## 7) State Synchronization Patterns

### Server + Client State Sync
```typescript
// ==========================================
// SYNC SERVER STATE TO CLIENT
// ==========================================

// Prefetch on server, hydrate on client
// app/posts/page.tsx
import { dehydrate, HydrationBoundary, QueryClient } from '@tanstack/react-query';
import { postKeys, getPosts } from '@/hooks/queries/usePosts';

export default async function PostsPage() {
  const queryClient = new QueryClient();
  
  // Prefetch on server
  await queryClient.prefetchQuery({
    queryKey: postKeys.list({ page: 1 }),
    queryFn: () => getPosts({ page: 1 }),
  });
  
  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <PostList />
    </HydrationBoundary>
  );
}


// ==========================================
// REAL-TIME UPDATES WITH SSE
// ==========================================

'use client';

import { useEffect } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { postKeys } from '@/hooks/queries/usePosts';

export function useRealtimeUpdates() {
  const queryClient = useQueryClient();

  useEffect(() => {
    const eventSource = new EventSource('/api/events');

    eventSource.onmessage = (event) => {
      const data = JSON.parse(event.data);
      
      switch (data.type) {
        case 'post.created':
        case 'post.updated':
        case 'post.deleted':
          // Invalidate relevant queries
          queryClient.invalidateQueries({ queryKey: postKeys.all });
          break;
      }
    };

    return () => eventSource.close();
  }, [queryClient]);
}
```

---

## Best Practices Checklist

### Strategy
- [ ] Server Components for server data
- [ ] React Query for async state
- [ ] Zustand for client state
- [ ] URL state for shareable state

### React Query
- [ ] Query keys factory
- [ ] Optimistic updates
- [ ] Error handling
- [ ] Loading states

### Zustand
- [ ] Small focused stores
- [ ] Persist only necessary state
- [ ] Shallow selectors
- [ ] Hydration handled

### Performance
- [ ] Minimal re-renders
- [ ] Proper selectors
- [ ] Cache configured
- [ ] DevTools enabled

---

**References:**
- [TanStack Query](https://tanstack.com/query/latest)
- [Zustand](https://zustand-demo.pmnd.rs/)
- [nuqs](https://nuqs.47ng.com/)
- [React Hook Form](https://react-hook-form.com/)

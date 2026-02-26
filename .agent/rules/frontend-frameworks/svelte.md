# Svelte & SvelteKit Development Expert

> **Version:** 2.0.0 | **Updated:** 2026-02-01  
> **Svelte:** 5.x (Runes) | **SvelteKit:** 2.x  
> **Priority:** P0 - Load for Svelte projects

---

You are an expert in Svelte and SvelteKit development.

## Core Principles

- Compiler-first: Work is done at build time
- No Virtual DOM: Direct DOM manipulation
- Reactivity by Runes (Svelte 5)
- Less boilerplate, more productivity

---

## 1) Svelte 5 Runes

### Core Runes
```svelte
<!-- ==========================================
     SVELTE 5 RUNES - MODERN REACTIVITY
     ========================================== -->

<script lang="ts">
  // ==========================================
  // $state - Reactive state
  // ==========================================
  
  // Primitive state
  let count = $state(0);
  let message = $state('Hello');
  let isOpen = $state(false);
  
  // Object state (deeply reactive)
  let user = $state({
    name: 'John',
    email: 'john@example.com',
    settings: {
      theme: 'dark',
      notifications: true
    }
  });
  
  // Array state
  let items = $state<string[]>([]);
  
  // Update state (direct mutation works!)
  function addItem(item: string) {
    items.push(item);  // This triggers reactivity!
  }
  
  function updateUser() {
    user.name = 'Jane';  // Deeply reactive
    user.settings.theme = 'light';
  }
  
  
  // ==========================================
  // $derived - Computed values
  // ==========================================
  
  let doubled = $derived(count * 2);
  let fullName = $derived(`${user.name} (${user.email})`);
  
  // Complex derived
  let filteredItems = $derived(
    items.filter(item => item.toLowerCase().includes(searchQuery))
  );
  
  // Derived with side-effect (use $derived.by for complex logic)
  let expensiveComputation = $derived.by(() => {
    // Can have multiple statements
    const filtered = items.filter(x => x.active);
    const sorted = filtered.sort((a, b) => a.name.localeCompare(b.name));
    return sorted;
  });
  
  
  // ==========================================
  // $effect - Side effects
  // ==========================================
  
  // Runs when dependencies change
  $effect(() => {
    console.log(`Count is now: ${count}`);
  });
  
  // Effect with cleanup
  $effect(() => {
    const interval = setInterval(() => {
      count++;
    }, 1000);
    
    // Cleanup function
    return () => clearInterval(interval);
  });
  
  // Pre-effect (runs before DOM updates)
  $effect.pre(() => {
    console.log('Before DOM update');
  });
  
  // Effect that tracks specific dependencies
  $effect(() => {
    // Only runs when user.name changes
    document.title = user.name;
  });
  
  
  // ==========================================
  // $props - Component props
  // ==========================================
  
  interface Props {
    name: string;
    count?: number;
    onUpdate?: (value: number) => void;
  }
  
  let { name, count = 0, onUpdate }: Props = $props();
  
  // With rest props
  let { name, ...rest }: Props & Record<string, unknown> = $props();
  
  
  // ==========================================
  // $bindable - Two-way binding props
  // ==========================================
  
  let { value = $bindable() }: { value: string } = $props();
  
  // Parent can now use: <Child bind:value />
  
  
  // ==========================================
  // $inspect - Debugging (dev only)
  // ==========================================
  
  $inspect(count);  // Logs when count changes
  $inspect(user).with(console.trace);  // With custom logger
</script>

<div>
  <p>Count: {count}</p>
  <p>Doubled: {doubled}</p>
  <button onclick={() => count++}>Increment</button>
  
  <p>User: {fullName}</p>
</div>
```

### Component Patterns
```svelte
<!-- ==========================================
     MODERN SVELTE 5 COMPONENT
     ========================================== -->

<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import type { User } from '$lib/types';
  
  // ==========================================
  // PROPS
  // ==========================================
  interface Props {
    userId: string;
    showAvatar?: boolean;
    size?: 'sm' | 'md' | 'lg';
    onSelect?: (user: User) => void;
    onDelete?: (id: string) => void;
  }
  
  let { 
    userId, 
    showAvatar = true, 
    size = 'md',
    onSelect,
    onDelete
  }: Props = $props();
  
  // ==========================================
  // LOCAL STATE
  // ==========================================
  let user = $state<User | null>(null);
  let isLoading = $state(false);
  let error = $state<string | null>(null);
  
  // ==========================================
  // DERIVED
  // ==========================================
  let fullName = $derived(
    user ? `${user.firstName} ${user.lastName}` : ''
  );
  
  let avatarSize = $derived({
    sm: 32,
    md: 48,
    lg: 64
  }[size]);
  
  // ==========================================
  // EFFECTS
  // ==========================================
  $effect(() => {
    // Fetch when userId changes
    fetchUser();
  });
  
  // ==========================================
  // METHODS
  // ==========================================
  async function fetchUser() {
    isLoading = true;
    error = null;
    
    try {
      const response = await fetch(`/api/users/${userId}`);
      if (!response.ok) throw new Error('Failed to fetch');
      user = await response.json();
    } catch (e) {
      error = e instanceof Error ? e.message : 'Unknown error';
    } finally {
      isLoading = false;
    }
  }
  
  function handleSelect() {
    if (user) onSelect?.(user);
  }
  
  function handleDelete() {
    onDelete?.(userId);
  }
  
  // ==========================================
  // LIFECYCLE
  // ==========================================
  onMount(() => {
    console.log('Component mounted');
  });
  
  onDestroy(() => {
    console.log('Component destroyed');
  });
</script>

<!-- ==========================================
     TEMPLATE
     ========================================== -->

<div class="user-card size-{size}">
  {#if isLoading}
    <div class="loading">
      <span class="spinner"></span>
      Loading...
    </div>
  {:else if error}
    <div class="error">
      {error}
      <button onclick={fetchUser}>Retry</button>
    </div>
  {:else if user}
    {#if showAvatar}
      <img 
        src={user.avatarUrl} 
        alt={fullName}
        width={avatarSize}
        height={avatarSize}
        class="avatar"
      />
    {/if}
    
    <div class="info">
      <h3>{fullName}</h3>
      <p>{user.email}</p>
    </div>
    
    <div class="actions">
      <button onclick={handleSelect}>Select</button>
      <button onclick={handleDelete} class="danger">Delete</button>
    </div>
  {/if}
</div>

<!-- ==========================================
     STYLES (Scoped by default)
     ========================================== -->

<style>
  .user-card {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 1rem;
    border-radius: 8px;
    background: var(--surface);
  }
  
  .size-sm { padding: 0.5rem; }
  .size-md { padding: 1rem; }
  .size-lg { padding: 1.5rem; }
  
  .avatar {
    border-radius: 50%;
    object-fit: cover;
  }
  
  .danger {
    color: var(--error);
  }
</style>
```

---

## 2) Logic Blocks

### Conditionals and Loops
```svelte
<script lang="ts">
  interface Item {
    id: string;
    name: string;
    status: 'pending' | 'active' | 'completed';
  }
  
  let items = $state<Item[]>([]);
  let selectedId = $state<string | null>(null);
  let promise = $state<Promise<Item[]>>();
</script>

<!-- ==========================================
     {#if} - Conditionals
     ========================================== -->

{#if isLoggedIn}
  <nav>Welcome, {user.name}</nav>
{:else if isLoading}
  <div class="loading">Loading...</div>
{:else}
  <a href="/login">Login</a>
{/if}


<!-- ==========================================
     {#each} - Loops
     ========================================== -->

<ul>
  {#each items as item (item.id)}
    <li class:selected={item.id === selectedId}>
      {item.name}
    </li>
  {:else}
    <li class="empty">No items found</li>
  {/each}
</ul>

<!-- With index -->
{#each items as item, index (item.id)}
  <div>
    {index + 1}. {item.name}
  </div>
{/each}

<!-- Destructuring -->
{#each items as { id, name, status } (id)}
  <div class={status}>{name}</div>
{/each}


<!-- ==========================================
     {#await} - Async handling
     ========================================== -->

{#await promise}
  <p class="loading">Loading...</p>
{:then items}
  <ul>
    {#each items as item (item.id)}
      <li>{item.name}</li>
    {/each}
  </ul>
{:catch error}
  <p class="error">{error.message}</p>
{/await}

<!-- Short form (no loading state) -->
{#await promise then items}
  <ul>
    {#each items as item}
      <li>{item.name}</li>
    {/each}
  </ul>
{/await}


<!-- ==========================================
     {#key} - Force re-render
     ========================================== -->

{#key selectedId}
  <!-- Component recreated when selectedId changes -->
  <UserDetail userId={selectedId} />
{/key}


<!-- ==========================================
     {@html} - Raw HTML (use carefully!)
     ========================================== -->

{@html sanitizedHtml}


<!-- ==========================================
     {@const} - Local constants
     ========================================== -->

{#each items as item}
  {@const isSelected = item.id === selectedId}
  {@const statusClass = `status-${item.status}`}
  
  <div class={statusClass} class:selected={isSelected}>
    {item.name}
  </div>
{/each}
```

---

## 3) Stores

### Store Patterns
```typescript
// ==========================================
// stores/user.ts
// ==========================================

import { writable, readable, derived, get } from 'svelte/store';
import type { User } from '$lib/types';

// ==========================================
// WRITABLE STORE
// ==========================================

function createUserStore() {
  const { subscribe, set, update } = writable<User | null>(null);
  
  return {
    subscribe,
    
    login: async (email: string, password: string) => {
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        body: JSON.stringify({ email, password }),
        headers: { 'Content-Type': 'application/json' }
      });
      
      if (!response.ok) {
        throw new Error('Login failed');
      }
      
      const user = await response.json();
      set(user);
      return user;
    },
    
    logout: () => {
      set(null);
    },
    
    updateProfile: (updates: Partial<User>) => {
      update(user => user ? { ...user, ...updates } : null);
    }
  };
}

export const userStore = createUserStore();


// ==========================================
// READABLE STORE
// ==========================================

export const time = readable(new Date(), (set) => {
  const interval = setInterval(() => {
    set(new Date());
  }, 1000);
  
  // Cleanup
  return () => clearInterval(interval);
});


// ==========================================
// DERIVED STORE
// ==========================================

export const isAuthenticated = derived(
  userStore,
  $user => $user !== null
);

export const userDisplayName = derived(
  userStore,
  $user => $user ? `${$user.firstName} ${$user.lastName}` : 'Guest'
);

// Derived from multiple stores
export const greeting = derived(
  [userStore, time],
  ([$user, $time]) => {
    const hour = $time.getHours();
    const timeOfDay = hour < 12 ? 'morning' : hour < 18 ? 'afternoon' : 'evening';
    return `Good ${timeOfDay}, ${$user?.firstName || 'Guest'}!`;
  }
);


// ==========================================
// COMPLEX STATE STORE
// ==========================================

interface CartItem {
  productId: string;
  name: string;
  price: number;
  quantity: number;
}

interface CartState {
  items: CartItem[];
  couponCode: string | null;
  discount: number;
}

function createCartStore() {
  const { subscribe, set, update } = writable<CartState>({
    items: [],
    couponCode: null,
    discount: 0
  });
  
  return {
    subscribe,
    
    addItem: (product: { id: string; name: string; price: number }) => {
      update(state => {
        const existing = state.items.find(i => i.productId === product.id);
        
        if (existing) {
          return {
            ...state,
            items: state.items.map(i =>
              i.productId === product.id
                ? { ...i, quantity: i.quantity + 1 }
                : i
            )
          };
        }
        
        return {
          ...state,
          items: [...state.items, {
            productId: product.id,
            name: product.name,
            price: product.price,
            quantity: 1
          }]
        };
      });
    },
    
    removeItem: (productId: string) => {
      update(state => ({
        ...state,
        items: state.items.filter(i => i.productId !== productId)
      }));
    },
    
    updateQuantity: (productId: string, quantity: number) => {
      update(state => ({
        ...state,
        items: state.items.map(i =>
          i.productId === productId
            ? { ...i, quantity: Math.max(0, quantity) }
            : i
        ).filter(i => i.quantity > 0)
      }));
    },
    
    applyCoupon: async (code: string) => {
      const response = await fetch(`/api/coupons/${code}`);
      if (!response.ok) throw new Error('Invalid coupon');
      
      const coupon = await response.json();
      update(state => ({
        ...state,
        couponCode: code,
        discount: coupon.percentage
      }));
    },
    
    clear: () => {
      set({ items: [], couponCode: null, discount: 0 });
    }
  };
}

export const cartStore = createCartStore();

// Derived values
export const cartTotal = derived(
  cartStore,
  $cart => $cart.items.reduce((sum, i) => sum + i.price * i.quantity, 0)
);

export const cartFinalTotal = derived(
  [cartStore, cartTotal],
  ([$cart, $total]) => $total * (1 - $cart.discount / 100)
);

export const cartItemCount = derived(
  cartStore,
  $cart => $cart.items.reduce((sum, i) => sum + i.quantity, 0)
);
```

### Using Stores
```svelte
<script lang="ts">
  import { userStore, isAuthenticated, cartStore, cartTotal } from '$lib/stores';
  
  // Auto-subscription with $ prefix
  // $userStore automatically subscribes/unsubscribes
</script>

<nav>
  {#if $isAuthenticated}
    <span>Welcome, {$userStore?.firstName}</span>
    <button onclick={() => userStore.logout()}>Logout</button>
  {:else}
    <a href="/login">Login</a>
  {/if}
  
  <div class="cart">
    <span>Cart ({$cartStore.items.length})</span>
    <span>Total: ${$cartTotal.toFixed(2)}</span>
  </div>
</nav>
```

---

## 4) SvelteKit Routing

### File Structure
```
src/
├── routes/
│   ├── +page.svelte              # / (home)
│   ├── +page.ts                  # Client load
│   ├── +page.server.ts           # Server load + actions
│   ├── +layout.svelte            # Root layout
│   ├── +layout.ts                # Layout load
│   ├── +error.svelte             # Error page
│   │
│   ├── about/
│   │   └── +page.svelte          # /about
│   │
│   ├── users/
│   │   ├── +page.svelte          # /users
│   │   ├── +page.server.ts       # Server load for list
│   │   ├── [id]/
│   │   │   ├── +page.svelte      # /users/123
│   │   │   ├── +page.server.ts   # Server load for detail
│   │   │   └── edit/
│   │   │       └── +page.svelte  # /users/123/edit
│   │   └── +layout.svelte        # Layout for /users/*
│   │
│   ├── api/
│   │   └── users/
│   │       ├── +server.ts        # GET, POST /api/users
│   │       └── [id]/
│   │           └── +server.ts    # GET, PUT, DELETE /api/users/123
│   │
│   └── (auth)/                   # Route group (no URL segment)
│       ├── login/
│       │   └── +page.svelte      # /login
│       └── register/
│           └── +page.svelte      # /register
│
├── lib/
│   ├── components/
│   ├── stores/
│   ├── types/
│   └── utils/
│
├── app.html
├── app.css
└── hooks.server.ts               # Server hooks
```

### Load Functions
```typescript
// ==========================================
// +page.server.ts - Server Load
// ==========================================

import type { PageServerLoad, Actions } from './$types';
import { error, fail, redirect } from '@sveltejs/kit';
import { db } from '$lib/server/db';

export const load: PageServerLoad = async ({ params, locals, url, fetch }) => {
  // Check authentication
  if (!locals.user) {
    throw redirect(303, '/login');
  }
  
  // Get query params
  const page = Number(url.searchParams.get('page')) || 1;
  const limit = 20;
  
  // Fetch data
  const users = await db.user.findMany({
    skip: (page - 1) * limit,
    take: limit,
    orderBy: { createdAt: 'desc' }
  });
  
  const total = await db.user.count();
  
  // Return data (serializable)
  return {
    users,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit)
    }
  };
};


// ==========================================
// +page.ts - Universal/Client Load
// ==========================================

import type { PageLoad } from './$types';

export const load: PageLoad = async ({ params, data, fetch }) => {
  // `data` comes from +page.server.ts
  
  // Additional client-side data fetching
  const categories = await fetch('/api/categories').then(r => r.json());
  
  return {
    ...data,
    categories
  };
};


// ==========================================
// +layout.server.ts - Layout Load
// ==========================================

import type { LayoutServerLoad } from './$types';

export const load: LayoutServerLoad = async ({ locals }) => {
  return {
    user: locals.user
  };
};


// ==========================================
// [id]/+page.server.ts - Dynamic Route
// ==========================================

import type { PageServerLoad } from './$types';
import { error } from '@sveltejs/kit';

export const load: PageServerLoad = async ({ params }) => {
  const user = await db.user.findUnique({
    where: { id: params.id }
  });
  
  if (!user) {
    throw error(404, {
      message: 'User not found'
    });
  }
  
  return { user };
};
```

### Form Actions
```typescript
// ==========================================
// +page.server.ts - Form Actions
// ==========================================

import type { Actions, PageServerLoad } from './$types';
import { fail, redirect } from '@sveltejs/kit';
import { z } from 'zod';

const userSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Password must be at least 8 characters')
});

export const actions: Actions = {
  // Default action (form without action attribute)
  default: async ({ request }) => {
    const formData = await request.formData();
    
    const data = {
      name: formData.get('name') as string,
      email: formData.get('email') as string,
      password: formData.get('password') as string
    };
    
    // Validate
    const result = userSchema.safeParse(data);
    
    if (!result.success) {
      return fail(400, {
        data: { name: data.name, email: data.email },
        errors: result.error.flatten().fieldErrors
      });
    }
    
    // Check if email exists
    const existing = await db.user.findUnique({
      where: { email: data.email }
    });
    
    if (existing) {
      return fail(400, {
        data: { name: data.name, email: data.email },
        errors: { email: ['Email already exists'] }
      });
    }
    
    // Create user
    const user = await db.user.create({
      data: result.data
    });
    
    // Redirect on success
    throw redirect(303, `/users/${user.id}`);
  },
  
  // Named action (?/delete)
  delete: async ({ params, locals }) => {
    if (!locals.user?.isAdmin) {
      return fail(403, { message: 'Unauthorized' });
    }
    
    await db.user.delete({
      where: { id: params.id }
    });
    
    throw redirect(303, '/users');
  },
  
  // Another named action (?/update)
  update: async ({ params, request }) => {
    const formData = await request.formData();
    
    await db.user.update({
      where: { id: params.id },
      data: {
        name: formData.get('name') as string
      }
    });
    
    return { success: true };
  }
};
```

### Using Form Actions
```svelte
<!-- ==========================================
     +page.svelte - Form with Actions
     ========================================== -->

<script lang="ts">
  import { enhance } from '$app/forms';
  import type { ActionData, PageData } from './$types';
  
  export let data: PageData;
  export let form: ActionData;
  
  let isSubmitting = $state(false);
</script>

<!-- Default action -->
<form 
  method="POST" 
  use:enhance={() => {
    isSubmitting = true;
    
    return async ({ update, result }) => {
      isSubmitting = false;
      
      if (result.type === 'success') {
        // Handle success
      }
      
      await update(); // Apply returned data
    };
  }}
>
  <div class="field">
    <label for="name">Name</label>
    <input 
      id="name" 
      name="name" 
      value={form?.data?.name ?? ''} 
      required 
    />
    {#if form?.errors?.name}
      <span class="error">{form.errors.name[0]}</span>
    {/if}
  </div>
  
  <div class="field">
    <label for="email">Email</label>
    <input 
      id="email" 
      name="email" 
      type="email"
      value={form?.data?.email ?? ''} 
      required 
    />
    {#if form?.errors?.email}
      <span class="error">{form.errors.email[0]}</span>
    {/if}
  </div>
  
  <div class="field">
    <label for="password">Password</label>
    <input 
      id="password" 
      name="password" 
      type="password"
      required 
    />
    {#if form?.errors?.password}
      <span class="error">{form.errors.password[0]}</span>
    {/if}
  </div>
  
  <button type="submit" disabled={isSubmitting}>
    {#if isSubmitting}
      Submitting...
    {:else}
      Create User
    {/if}
  </button>
</form>


<!-- Named action -->
<form method="POST" action="?/delete" use:enhance>
  <button type="submit" class="danger">Delete</button>
</form>

<!-- Inline update -->
<form method="POST" action="?/update" use:enhance>
  <input name="name" value={data.user.name} />
  <button type="submit">Update</button>
</form>
```

---

## 5) API Routes

### REST Endpoints
```typescript
// ==========================================
// routes/api/users/+server.ts
// ==========================================

import { json, error } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { db } from '$lib/server/db';

// GET /api/users
export const GET: RequestHandler = async ({ url, locals }) => {
  const page = Number(url.searchParams.get('page')) || 1;
  const limit = Number(url.searchParams.get('limit')) || 20;
  const search = url.searchParams.get('search') || '';
  
  const users = await db.user.findMany({
    where: search ? {
      OR: [
        { name: { contains: search, mode: 'insensitive' } },
        { email: { contains: search, mode: 'insensitive' } }
      ]
    } : undefined,
    skip: (page - 1) * limit,
    take: limit,
    select: {
      id: true,
      name: true,
      email: true,
      createdAt: true
    }
  });
  
  return json({ users, page, limit });
};

// POST /api/users
export const POST: RequestHandler = async ({ request, locals }) => {
  if (!locals.user?.isAdmin) {
    throw error(403, 'Unauthorized');
  }
  
  const data = await request.json();
  
  const user = await db.user.create({
    data
  });
  
  return json(user, { status: 201 });
};


// ==========================================
// routes/api/users/[id]/+server.ts
// ==========================================

import { json, error } from '@sveltejs/kit';
import type { RequestHandler } from './$types';

// GET /api/users/123
export const GET: RequestHandler = async ({ params }) => {
  const user = await db.user.findUnique({
    where: { id: params.id }
  });
  
  if (!user) {
    throw error(404, 'User not found');
  }
  
  return json(user);
};

// PUT /api/users/123
export const PUT: RequestHandler = async ({ params, request }) => {
  const data = await request.json();
  
  const user = await db.user.update({
    where: { id: params.id },
    data
  });
  
  return json(user);
};

// PATCH /api/users/123
export const PATCH: RequestHandler = async ({ params, request }) => {
  const data = await request.json();
  
  const user = await db.user.update({
    where: { id: params.id },
    data
  });
  
  return json(user);
};

// DELETE /api/users/123
export const DELETE: RequestHandler = async ({ params }) => {
  await db.user.delete({
    where: { id: params.id }
  });
  
  return new Response(null, { status: 204 });
};
```

---

## 6) Transitions & Animations

### Transition Directives
```svelte
<script lang="ts">
  import { 
    fade, 
    fly, 
    slide, 
    scale, 
    blur,
    draw,
    crossfade
  } from 'svelte/transition';
  import { flip } from 'svelte/animate';
  import { quintOut, elasticOut } from 'svelte/easing';
  
  let isVisible = $state(false);
  let items = $state<string[]>([]);
  
  const [send, receive] = crossfade({
    duration: 300,
    fallback: scale
  });
</script>

<!-- Basic transitions -->
{#if isVisible}
  <div transition:fade>Fades in/out</div>
  
  <div transition:fly={{ y: -20, duration: 300 }}>
    Flies from top
  </div>
  
  <div transition:slide={{ duration: 300, easing: quintOut }}>
    Slides in/out
  </div>
  
  <div transition:scale={{ start: 0.8 }}>
    Scales in/out
  </div>
  
  <div transition:blur={{ amount: 5 }}>
    Blurs in/out
  </div>
{/if}


<!-- Separate in/out transitions -->
{#if isVisible}
  <div 
    in:fly={{ y: 50, duration: 300 }}
    out:fade={{ duration: 200 }}
  >
    Different in and out
  </div>
{/if}


<!-- List animations with flip -->
<ul>
  {#each items as item (item.id)}
    <li
      animate:flip={{ duration: 300 }}
      in:fly={{ x: -100, duration: 300 }}
      out:fade={{ duration: 200 }}
    >
      {item.name}
    </li>
  {/each}
</ul>


<!-- Crossfade between lists -->
<div class="columns">
  <div class="left">
    {#each leftItems as item (item.id)}
      <div 
        in:receive={{ key: item.id }} 
        out:send={{ key: item.id }}
        animate:flip
      >
        {item.name}
      </div>
    {/each}
  </div>
  
  <div class="right">
    {#each rightItems as item (item.id)}
      <div 
        in:receive={{ key: item.id }} 
        out:send={{ key: item.id }}
        animate:flip
      >
        {item.name}
      </div>
    {/each}
  </div>
</div>


<!-- Custom transition -->
<script context="module" lang="ts">
  function typewriter(node: HTMLElement, { speed = 50 }: { speed?: number } = {}) {
    const text = node.textContent || '';
    const duration = text.length * speed;
    
    return {
      duration,
      tick: (t: number) => {
        const i = Math.floor(text.length * t);
        node.textContent = text.slice(0, i);
      }
    };
  }
</script>

{#if isVisible}
  <p transition:typewriter={{ speed: 30 }}>
    This text types out character by character...
  </p>
{/if}
```

---

## 7) Actions (use: Directive)

### Custom Actions
```svelte
<script lang="ts">
  import type { Action } from 'svelte/action';
  
  // ==========================================
  // CLICK OUTSIDE ACTION
  // ==========================================
  const clickOutside: Action<HTMLElement, () => void> = (node, callback) => {
    function handleClick(event: MouseEvent) {
      if (!node.contains(event.target as Node)) {
        callback?.();
      }
    }
    
    document.addEventListener('click', handleClick, true);
    
    return {
      update(newCallback) {
        callback = newCallback;
      },
      destroy() {
        document.removeEventListener('click', handleClick, true);
      }
    };
  };
  
  
  // ==========================================
  // INTERSECTION OBSERVER ACTION
  // ==========================================
  interface InViewParams {
    onEnter?: () => void;
    onLeave?: () => void;
    threshold?: number;
  }
  
  const inView: Action<HTMLElement, InViewParams> = (node, params = {}) => {
    let observer: IntersectionObserver;
    
    function init(params: InViewParams) {
      observer?.disconnect();
      
      observer = new IntersectionObserver(
        (entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              params.onEnter?.();
            } else {
              params.onLeave?.();
            }
          });
        },
        { threshold: params.threshold || 0 }
      );
      
      observer.observe(node);
    }
    
    init(params);
    
    return {
      update: init,
      destroy() {
        observer?.disconnect();
      }
    };
  };
  
  
  // ==========================================
  // TOOLTIP ACTION
  // ==========================================
  interface TooltipParams {
    content: string;
    position?: 'top' | 'bottom' | 'left' | 'right';
  }
  
  const tooltip: Action<HTMLElement, TooltipParams> = (node, params) => {
    let tooltipEl: HTMLDivElement | null = null;
    
    function show() {
      tooltipEl = document.createElement('div');
      tooltipEl.className = `tooltip tooltip-${params.position || 'top'}`;
      tooltipEl.textContent = params.content;
      document.body.appendChild(tooltipEl);
      
      const rect = node.getBoundingClientRect();
      const tooltipRect = tooltipEl.getBoundingClientRect();
      
      // Position tooltip
      tooltipEl.style.left = `${rect.left + rect.width / 2 - tooltipRect.width / 2}px`;
      tooltipEl.style.top = `${rect.top - tooltipRect.height - 8}px`;
    }
    
    function hide() {
      tooltipEl?.remove();
      tooltipEl = null;
    }
    
    node.addEventListener('mouseenter', show);
    node.addEventListener('mouseleave', hide);
    
    return {
      update(newParams) {
        params = newParams;
      },
      destroy() {
        hide();
        node.removeEventListener('mouseenter', show);
        node.removeEventListener('mouseleave', hide);
      }
    };
  };
  
  
  let isOpen = $state(false);
  let isInView = $state(false);
</script>

<!-- Using actions -->
<div 
  class="dropdown" 
  use:clickOutside={() => isOpen = false}
>
  <button onclick={() => isOpen = !isOpen}>Toggle</button>
  {#if isOpen}
    <div class="menu">Menu content</div>
  {/if}
</div>

<div 
  use:inView={{
    onEnter: () => isInView = true,
    onLeave: () => isInView = false,
    threshold: 0.5
  }}
  class:visible={isInView}
>
  Lazy loaded content
</div>

<button use:tooltip={{ content: 'Click me!', position: 'top' }}>
  Hover for tooltip
</button>
```

---

## 8) Best Practices Checklist

```
┌─────────────────────────────────────────┐
│    SVELTE/SVELTEKIT BEST PRACTICES      │
├─────────────────────────────────────────┤
│                                         │
│  SVELTE 5:                              │
│  □ Use $state for reactive state       │
│  □ Use $derived for computed           │
│  □ Use $effect for side effects        │
│  □ Use $props for typed props          │
│                                         │
│  SVELTEKIT:                             │
│  □ Use +page.server.ts for data        │
│  □ Use Form Actions with use:enhance   │
│  □ Type load functions (PageServerLoad)│
│  □ Use hooks for auth/middleware       │
│                                         │
│  STATE:                                 │
│  □ Use stores for global state         │
│  □ Prefer derived for computed         │
│  □ Keep stores in $lib/stores          │
│                                         │
│  PERFORMANCE:                           │
│  □ Use {#key} for animations           │
│  □ Use {#await} for async              │
│  □ Lazy load heavy components          │
│  □ Use enhanced-img for images         │
│                                         │
│  FORMS:                                 │
│  □ Progressive enhancement             │
│  □ Return validation errors            │
│  □ Use use:enhance for UX              │
│                                         │
└──────────────────────────────────────┘
```

---

## Best Practices Summary

### Svelte 5
- [ ] Use Runes ($state, $derived, $effect)
- [ ] Use $props with TypeScript
- [ ] Use $bindable for two-way binding
- [ ] Use $inspect for debugging

### SvelteKit
- [ ] Server load for sensitive data
- [ ] Form Actions for mutations
- [ ] Type all load functions
- [ ] Use hooks for middleware

### State
- [ ] Stores for global state
- [ ] Derived for computed values
- [ ] Keep stores modular
- [ ] Use get() for one-time reads

---

**References:**
- [Svelte Documentation](https://svelte.dev/docs)
- [SvelteKit Documentation](https://kit.svelte.dev/docs)
- [Svelte 5 Runes](https://svelte-5-preview.vercel.app/)
- [Svelte Tutorial](https://learn.svelte.dev/)

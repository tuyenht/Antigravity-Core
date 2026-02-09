# Solid.js Reactive Development Expert

> **Version:** 2.0.0 | **Updated:** 2026-02-01  
> **Solid.js:** 1.8+ | **SolidStart:** 1.0+  
> **Priority:** P0 - Load for Solid.js projects

---

You are an expert in Solid.js and fine-grained reactivity.

## Core Principles

- Fine-grained reactivity (Signals)
- No Virtual DOM overhead
- Components run once (setup phase)
- JSX for templating

---

## 1) Signals & Reactivity

### Signal Fundamentals
```tsx
// ==========================================
// SIGNALS - CORE REACTIVE PRIMITIVE
// ==========================================

import { createSignal, createEffect, createMemo, batch } from 'solid-js';

// ==========================================
// CREATE SIGNAL
// ==========================================

// Basic signal
const [count, setCount] = createSignal(0);

// Read signal value (as function!)
console.log(count());  // 0

// Set new value
setCount(5);

// Update based on previous value
setCount(prev => prev + 1);


// ==========================================
// TYPED SIGNALS
// ==========================================

interface User {
  id: string;
  name: string;
  email: string;
}

const [user, setUser] = createSignal<User | null>(null);

// Update object (creates new reference)
setUser({
  id: '1',
  name: 'John',
  email: 'john@example.com'
});

// Update specific properties
setUser(prev => prev ? { ...prev, name: 'Jane' } : null);


// ==========================================
// ARRAY SIGNALS
// ==========================================

const [items, setItems] = createSignal<string[]>([]);

// Add item
setItems(prev => [...prev, 'new item']);

// Remove item
setItems(prev => prev.filter(item => item !== 'remove'));

// Update specific index
setItems(prev => prev.map((item, i) => i === 0 ? 'updated' : item));


// ==========================================
// CREATE EFFECT
// ==========================================

// Runs when any signal inside changes
createEffect(() => {
  console.log(`Count is now: ${count()}`);
});

// Effect with explicit dependencies
createEffect((prev) => {
  const current = count();
  console.log(`Count changed from ${prev} to ${current}`);
  return current;  // Return for next iteration
}, count());  // Initial value


// ==========================================
// CREATE MEMO (Cached Derived Value)
// ==========================================

const doubled = createMemo(() => count() * 2);
console.log(doubled());  // 0

setCount(5);
console.log(doubled());  // 10

// Complex memo
const [items, setItems] = createSignal<Item[]>([]);
const [searchQuery, setSearchQuery] = createSignal('');

const filteredItems = createMemo(() => {
  const query = searchQuery().toLowerCase();
  if (!query) return items();
  
  return items().filter(item =>
    item.name.toLowerCase().includes(query) ||
    item.description.toLowerCase().includes(query)
  );
});


// ==========================================
// BATCH UPDATES
// ==========================================

const [firstName, setFirstName] = createSignal('John');
const [lastName, setLastName] = createSignal('Doe');

// Without batch: 2 re-computations
// With batch: 1 re-computation
batch(() => {
  setFirstName('Jane');
  setLastName('Smith');
});


// ==========================================
// UNTRACK (Read without subscribing)
// ==========================================

import { untrack } from 'solid-js';

createEffect(() => {
  // This will re-run when firstName changes
  console.log(firstName());
  
  // This will NOT cause re-runs when lastName changes
  console.log(untrack(() => lastName()));
});
```

### Component Patterns
```tsx
// ==========================================
// SOLID COMPONENT PATTERN
// ==========================================

import { Component, createSignal, createEffect, onMount, onCleanup } from 'solid-js';
import type { JSX } from 'solid-js';

// ==========================================
// COMPONENT PROPS (Don't destructure!)
// ==========================================

interface UserCardProps {
  userId: string;
  showAvatar?: boolean;
  size?: 'sm' | 'md' | 'lg';
  onSelect?: (user: User) => void;
  onDelete?: (id: string) => void;
  children?: JSX.Element;
}

// ❌ WRONG: Destructuring loses reactivity
// const UserCard = ({ userId, showAvatar }: Props) => { ... }

// ✅ CORRECT: Access props directly
const UserCard: Component<UserCardProps> = (props) => {
  // Local state
  const [user, setUser] = createSignal<User | null>(null);
  const [isLoading, setIsLoading] = createSignal(false);
  const [error, setError] = createSignal<string | null>(null);
  
  // Derived values
  const fullName = createMemo(() => {
    const u = user();
    return u ? `${u.firstName} ${u.lastName}` : '';
  });
  
  const avatarSize = createMemo(() => {
    const sizes = { sm: 32, md: 48, lg: 64 };
    return sizes[props.size ?? 'md'];
  });
  
  // Effect: Fetch when userId changes
  createEffect(() => {
    const id = props.userId;  // Track userId
    fetchUser(id);
  });
  
  async function fetchUser(id: string) {
    setIsLoading(true);
    setError(null);
    
    try {
      const response = await fetch(`/api/users/${id}`);
      if (!response.ok) throw new Error('Failed to fetch');
      setUser(await response.json());
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Unknown error');
    } finally {
      setIsLoading(false);
    }
  }
  
  function handleSelect() {
    const u = user();
    if (u) props.onSelect?.(u);
  }
  
  function handleDelete() {
    props.onDelete?.(props.userId);
  }
  
  // Lifecycle
  onMount(() => {
    console.log('Component mounted');
  });
  
  onCleanup(() => {
    console.log('Component destroyed');
  });
  
  return (
    <div class={`user-card size-${props.size ?? 'md'}`}>
      <Show when={isLoading()}>
        <div class="loading">
          <span class="spinner" />
          Loading...
        </div>
      </Show>
      
      <Show when={error()}>
        <div class="error">
          {error()}
          <button onClick={() => fetchUser(props.userId)}>Retry</button>
        </div>
      </Show>
      
      <Show when={user()}>
        {(u) => (
          <>
            <Show when={props.showAvatar !== false}>
              <img
                src={u().avatarUrl}
                alt={fullName()}
                width={avatarSize()}
                height={avatarSize()}
                class="avatar"
              />
            </Show>
            
            <div class="info">
              <h3>{fullName()}</h3>
              <p>{u().email}</p>
            </div>
            
            <div class="actions">
              <button onClick={handleSelect}>Select</button>
              <button onClick={handleDelete} class="danger">Delete</button>
            </div>
          </>
        )}
      </Show>
      
      {props.children}
    </div>
  );
};

export default UserCard;
```

---

## 2) Control Flow Components

### Show, For, Index, Switch
```tsx
import { Show, For, Index, Switch, Match } from 'solid-js';

// ==========================================
// <SHOW> - Conditional Rendering
// ==========================================

const [isLoggedIn, setIsLoggedIn] = createSignal(false);
const [user, setUser] = createSignal<User | null>(null);

// Basic Show
<Show when={isLoggedIn()}>
  <Dashboard />
</Show>

// Show with fallback
<Show when={isLoggedIn()} fallback={<LoginPage />}>
  <Dashboard />
</Show>

// Show with keyed (gets unwrapped value)
<Show when={user()} keyed>
  {(u) => <UserProfile user={u} />}
</Show>

// Non-keyed (gets accessor)
<Show when={user()}>
  {(u) => <UserProfile user={u()} />}
</Show>


// ==========================================
// <FOR> - Keyed List (items have identity)
// ==========================================

const [items, setItems] = createSignal<Item[]>([]);

// Each item tracked by reference
<ul>
  <For each={items()}>
    {(item, index) => (
      <li>
        {index()}: {item.name}
        <button onClick={() => removeItem(item.id)}>Remove</button>
      </li>
    )}
  </For>
</ul>

// With fallback
<For each={items()} fallback={<div>No items found</div>}>
  {(item) => <ItemCard item={item} />}
</For>


// ==========================================
// <INDEX> - Non-keyed List (items by position)
// ==========================================

// Use when items don't have identity (primitives, indices matter)
const [values, setValues] = createSignal([1, 2, 3, 4, 5]);

<ul>
  <Index each={values()}>
    {(value, index) => (
      <li>
        Index {index}: Value {value()}
        {/* value is a signal here! */}
      </li>
    )}
  </Index>
</ul>


// ==========================================
// <SWITCH> / <MATCH> - Pattern Matching
// ==========================================

const [status, setStatus] = createSignal<'pending' | 'success' | 'error'>('pending');

<Switch fallback={<div>Unknown status</div>}>
  <Match when={status() === 'pending'}>
    <div class="pending">Loading...</div>
  </Match>
  <Match when={status() === 'success'}>
    <div class="success">Success!</div>
  </Match>
  <Match when={status() === 'error'}>
    <div class="error">Error occurred</div>
  </Match>
</Switch>

// With extracted value
const [result, setResult] = createSignal<Result | null>(null);

<Switch>
  <Match when={result()?.type === 'user'}>
    {/* Type narrowing within match */}
    <UserView user={result() as UserResult} />
  </Match>
  <Match when={result()?.type === 'product'}>
    <ProductView product={result() as ProductResult} />
  </Match>
</Switch>


// ==========================================
// <PORTAL> - Render Outside DOM Hierarchy
// ==========================================

import { Portal } from 'solid-js/web';

<Portal mount={document.body}>
  <div class="modal-overlay">
    <div class="modal">
      Modal content...
    </div>
  </div>
</Portal>


// ==========================================
// <SUSPENSE> - Async Boundaries
// ==========================================

import { Suspense } from 'solid-js';

<Suspense fallback={<Loading />}>
  <AsyncComponent />
</Suspense>


// ==========================================
// <ERRORBOUNDARY> - Error Handling
// ==========================================

import { ErrorBoundary } from 'solid-js';

<ErrorBoundary fallback={(err, reset) => (
  <div class="error">
    <p>Error: {err.message}</p>
    <button onClick={reset}>Try Again</button>
  </div>
)}>
  <MayThrowComponent />
</ErrorBoundary>


// ==========================================
// <DYNAMIC> - Dynamic Components
// ==========================================

import { Dynamic } from 'solid-js/web';

const [component, setComponent] = createSignal<'user' | 'product'>('user');

const components = {
  user: UserComponent,
  product: ProductComponent,
};

<Dynamic component={components[component()]} />
```

---

## 3) Stores (Nested Reactivity)

### Store Patterns
```tsx
// ==========================================
// STORES - DEEP NESTED REACTIVITY
// ==========================================

import { createStore, produce, reconcile } from 'solid-js/store';

// ==========================================
// BASIC STORE
// ==========================================

interface AppState {
  user: User | null;
  settings: {
    theme: 'light' | 'dark';
    notifications: boolean;
    language: string;
  };
  items: Item[];
}

const [state, setState] = createStore<AppState>({
  user: null,
  settings: {
    theme: 'light',
    notifications: true,
    language: 'en',
  },
  items: [],
});

// Read (direct access, no function call)
console.log(state.user);
console.log(state.settings.theme);

// Update specific path
setState('user', { id: '1', name: 'John', email: 'john@example.com' });

// Update nested path
setState('settings', 'theme', 'dark');
setState('settings', 'notifications', false);

// Update with function
setState('settings', 'language', prev => prev === 'en' ? 'vi' : 'en');


// ==========================================
// ARRAY OPERATIONS
// ==========================================

// Add item
setState('items', items => [...items, newItem]);

// Or use produce for mutable-style updates
setState(produce((s) => {
  s.items.push(newItem);
}));

// Update specific item by index
setState('items', 0, 'name', 'Updated Name');

// Update item by predicate
setState('items', item => item.id === targetId, 'status', 'completed');

// Remove item
setState('items', items => items.filter(i => i.id !== targetId));


// ==========================================
// PRODUCE (Immer-like Mutations)
// ==========================================

import { produce } from 'solid-js/store';

setState(produce((state) => {
  state.user = { id: '1', name: 'John' };
  state.settings.theme = 'dark';
  state.items.push({ id: '1', name: 'New Item' });
  state.items[0].status = 'active';
}));


// ==========================================
// RECONCILE (Diffing for API data)
// ==========================================

import { reconcile } from 'solid-js/store';

// Efficiently update store with new data from API
const fetchUsers = async () => {
  const data = await fetch('/api/users').then(r => r.json());
  setState('items', reconcile(data));
};


// ==========================================
// STORE CONTEXT PATTERN
// ==========================================

import { createContext, useContext, ParentComponent } from 'solid-js';
import { createStore } from 'solid-js/store';

interface UserState {
  user: User | null;
  isLoading: boolean;
  error: string | null;
}

interface UserActions {
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  updateProfile: (updates: Partial<User>) => void;
}

type UserStore = [UserState, UserActions];

const UserContext = createContext<UserStore>();

export const UserProvider: ParentComponent = (props) => {
  const [state, setState] = createStore<UserState>({
    user: null,
    isLoading: false,
    error: null,
  });
  
  const actions: UserActions = {
    login: async (email, password) => {
      setState('isLoading', true);
      setState('error', null);
      
      try {
        const response = await fetch('/api/auth/login', {
          method: 'POST',
          body: JSON.stringify({ email, password }),
          headers: { 'Content-Type': 'application/json' },
        });
        
        if (!response.ok) throw new Error('Login failed');
        
        const user = await response.json();
        setState('user', user);
      } catch (e) {
        setState('error', e instanceof Error ? e.message : 'Unknown error');
      } finally {
        setState('isLoading', false);
      }
    },
    
    logout: () => {
      setState('user', null);
    },
    
    updateProfile: (updates) => {
      setState('user', prev => prev ? { ...prev, ...updates } : null);
    },
  };
  
  return (
    <UserContext.Provider value={[state, actions]}>
      {props.children}
    </UserContext.Provider>
  );
};

export function useUser(): UserStore {
  const context = useContext(UserContext);
  if (!context) {
    throw new Error('useUser must be used within UserProvider');
  }
  return context;
}


// ==========================================
// USING THE STORE
// ==========================================

const UserProfile: Component = () => {
  const [user, { updateProfile, logout }] = useUser();
  
  return (
    <Show when={user.user} fallback={<LoginForm />}>
      {(u) => (
        <div>
          <h2>Welcome, {u().name}</h2>
          <button onClick={() => updateProfile({ name: 'New Name' })}>
            Update
          </button>
          <button onClick={logout}>Logout</button>
        </div>
      )}
    </Show>
  );
};
```

---

## 4) Resources (Async Data)

### Resource Patterns
```tsx
// ==========================================
// RESOURCES - ASYNC DATA FETCHING
// ==========================================

import { createResource, createSignal, Suspense } from 'solid-js';

// ==========================================
// BASIC RESOURCE
// ==========================================

const fetchUser = async (id: string): Promise<User> => {
  const response = await fetch(`/api/users/${id}`);
  if (!response.ok) throw new Error('Failed to fetch');
  return response.json();
};

const [userId, setUserId] = createSignal('1');

// Resource with source signal
const [user, { refetch, mutate }] = createResource(userId, fetchUser);

// Access resource
user();           // User | undefined
user.loading;     // boolean
user.error;       // Error | undefined
user.latest;      // Last successful value (doesn't clear on refetch)


// ==========================================
// USING RESOURCES IN COMPONENTS
// ==========================================

const UserProfile: Component = () => {
  const [userId, setUserId] = createSignal('1');
  const [user] = createResource(userId, fetchUser);
  
  return (
    <div>
      <select onChange={(e) => setUserId(e.target.value)}>
        <option value="1">User 1</option>
        <option value="2">User 2</option>
      </select>
      
      <Show when={user.loading}>
        <div class="loading">Loading...</div>
      </Show>
      
      <Show when={user.error}>
        <div class="error">{user.error.message}</div>
      </Show>
      
      <Show when={user()}>
        {(u) => (
          <div>
            <h2>{u().name}</h2>
            <p>{u().email}</p>
          </div>
        )}
      </Show>
    </div>
  );
};


// ==========================================
// RESOURCE WITH SUSPENSE
// ==========================================

// Suspense boundary catches resource loading
<Suspense fallback={<Loading />}>
  <UserProfile />
</Suspense>


// ==========================================
// RESOURCE ACTIONS
// ==========================================

const [users, { refetch, mutate }] = createResource(fetchUsers);

// Refetch data
<button onClick={() => refetch()}>Refresh</button>

// Optimistic update
const addUser = async (userData: CreateUser) => {
  // Optimistically add to list
  mutate(prev => [...(prev || []), { ...userData, id: 'temp' }]);
  
  try {
    const newUser = await createUser(userData);
    // Replace temp with real user
    mutate(prev => prev?.map(u => u.id === 'temp' ? newUser : u));
  } catch (e) {
    // Rollback on error
    mutate(prev => prev?.filter(u => u.id !== 'temp'));
    throw e;
  }
};


// ==========================================
// RESOURCE WITH INITIAL VALUE
// ==========================================

const [data] = createResource(fetcher, {
  initialValue: [],
  ssrLoadFrom: 'initial',  // Use initial value during SSR
});


// ==========================================
// MULTIPLE RESOURCES
// ==========================================

const [userId] = createSignal('1');

const [user] = createResource(userId, fetchUser);
const [posts] = createResource(userId, fetchUserPosts);
const [followers] = createResource(userId, fetchUserFollowers);

// All resources track userId and refetch when it changes
<Suspense fallback={<Loading />}>
  <Show when={user() && posts() && followers()}>
    <UserDashboard 
      user={user()!} 
      posts={posts()!} 
      followers={followers()!} 
    />
  </Show>
</Suspense>
```

---

## 5) Solid Router

### Router Configuration
```tsx
// ==========================================
// SOLID ROUTER SETUP
// ==========================================

import { Router, Route, Routes, A, Navigate, useParams, useNavigate } from '@solidjs/router';
import { lazy } from 'solid-js';

// Lazy load routes
const Home = lazy(() => import('./pages/Home'));
const Users = lazy(() => import('./pages/Users'));
const UserDetail = lazy(() => import('./pages/UserDetail'));
const NotFound = lazy(() => import('./pages/NotFound'));

// ==========================================
// ROUTE CONFIGURATION
// ==========================================

const App = () => {
  return (
    <Router>
      <Layout>
        <Routes>
          <Route path="/" component={Home} />
          
          <Route path="/users" component={Users} />
          <Route path="/users/:id" component={UserDetail} />
          <Route path="/users/:id/edit" component={UserEdit} />
          
          {/* Nested routes */}
          <Route path="/dashboard" component={DashboardLayout}>
            <Route path="/" component={DashboardHome} />
            <Route path="/analytics" component={Analytics} />
            <Route path="/settings" component={Settings} />
          </Route>
          
          {/* Redirect */}
          <Route path="/old-path" element={<Navigate href="/new-path" />} />
          
          {/* Catch-all */}
          <Route path="*" component={NotFound} />
        </Routes>
      </Layout>
    </Router>
  );
};


// ==========================================
// NAVIGATION
// ==========================================

const Navigation = () => {
  return (
    <nav>
      {/* Link component */}
      <A href="/" activeClass="active">Home</A>
      <A href="/users" activeClass="active">Users</A>
      <A href="/dashboard" activeClass="active">Dashboard</A>
      
      {/* With end prop for exact matching */}
      <A href="/dashboard" end activeClass="active">Dashboard Home</A>
    </nav>
  );
};


// ==========================================
// ROUTE PARAMS & NAVIGATION
// ==========================================

const UserDetail = () => {
  const params = useParams<{ id: string }>();
  const navigate = useNavigate();
  
  const [user] = createResource(() => params.id, fetchUser);
  
  function goToEdit() {
    navigate(`/users/${params.id}/edit`);
  }
  
  function goBack() {
    navigate(-1);  // Go back in history
  }
  
  function goToUsers() {
    navigate('/users', { replace: true });  // Replace history entry
  }
  
  return (
    <div>
      <button onClick={goBack}>Back</button>
      
      <Suspense fallback={<Loading />}>
        <Show when={user()}>
          {(u) => (
            <div>
              <h1>{u().name}</h1>
              <button onClick={goToEdit}>Edit</button>
            </div>
          )}
        </Show>
      </Suspense>
    </div>
  );
};


// ==========================================
// QUERY PARAMS
// ==========================================

import { useSearchParams } from '@solidjs/router';

const UserList = () => {
  const [searchParams, setSearchParams] = useSearchParams();
  
  // Read params
  const page = () => Number(searchParams.page) || 1;
  const search = () => searchParams.search || '';
  
  // Update params
  function nextPage() {
    setSearchParams({ page: page() + 1 });
  }
  
  function setSearch(query: string) {
    setSearchParams({ search: query, page: 1 });
  }
  
  return (
    <div>
      <input
        value={search()}
        onInput={(e) => setSearch(e.target.value)}
        placeholder="Search..."
      />
      
      <UserListContent page={page()} search={search()} />
      
      <button onClick={nextPage}>Next Page</button>
    </div>
  );
};
```

### Route Data Loading
```tsx
// ==========================================
// ROUTE DATA FUNCTIONS
// ==========================================

import { RouteDataArgs, useRouteData } from '@solidjs/router';
import { createResource } from 'solid-js';

// Define data function
function userRouteData({ params }: RouteDataArgs) {
  const [user] = createResource(() => params.id, fetchUser);
  const [posts] = createResource(() => params.id, fetchUserPosts);
  
  return { user, posts };
}

// Route with data
<Route 
  path="/users/:id" 
  component={UserDetail}
  data={userRouteData}
/>

// Access data in component
const UserDetail = () => {
  const { user, posts } = useRouteData<typeof userRouteData>();
  
  return (
    <Suspense fallback={<Loading />}>
      <Show when={user()}>
        {(u) => <UserProfile user={u()} />}
      </Show>
      
      <Show when={posts()}>
        {(p) => <PostList posts={p()} />}
      </Show>
    </Suspense>
  );
};
```

---

## 6) SolidStart (Fullstack)

### SolidStart Patterns
```tsx
// ==========================================
// SOLIDSTART - FILE-BASED ROUTING
// ==========================================

// routes/index.tsx - Home page
export default function Home() {
  return <h1>Home</h1>;
}

// routes/users/[id].tsx - Dynamic route
export default function UserPage() {
  const params = useParams();
  return <UserDetail id={params.id} />;
}


// ==========================================
// SERVER FUNCTIONS
// ==========================================

import { action, redirect, json } from '@solidjs/router';
import { getRequestEvent } from 'solid-js/web';

// Server action
const createUser = action(async (formData: FormData) => {
  'use server';
  
  const name = formData.get('name') as string;
  const email = formData.get('email') as string;
  
  // Validate
  if (!name || !email) {
    return json({ error: 'Name and email required' }, { status: 400 });
  }
  
  // Create user
  const user = await db.user.create({ data: { name, email } });
  
  // Redirect on success
  throw redirect(`/users/${user.id}`);
});

// Use in form
<form action={createUser} method="post">
  <input name="name" required />
  <input name="email" type="email" required />
  <button type="submit">Create</button>
</form>


// ==========================================
// ROUTE PRELOAD (Data Loading)
// ==========================================

import { cache, createAsync } from '@solidjs/router';

// Define cached fetcher
const getUser = cache(async (id: string) => {
  'use server';
  return db.user.findUnique({ where: { id } });
}, 'user');

// Preload function
export const route = {
  preload: ({ params }) => getUser(params.id),
};

// Use in component
export default function UserPage() {
  const params = useParams();
  const user = createAsync(() => getUser(params.id));
  
  return (
    <Suspense fallback={<Loading />}>
      <Show when={user()}>
        {(u) => <UserDetail user={u()} />}
      </Show>
    </Suspense>
  );
}


// ==========================================
// API ROUTES
// ==========================================

// routes/api/users/[id].ts
import { json } from '@solidjs/router';
import type { APIEvent } from '@solidjs/start/server';

export async function GET({ params }: APIEvent) {
  const user = await db.user.findUnique({
    where: { id: params.id }
  });
  
  if (!user) {
    return json({ error: 'Not found' }, { status: 404 });
  }
  
  return json(user);
}

export async function PUT({ params, request }: APIEvent) {
  const data = await request.json();
  
  const user = await db.user.update({
    where: { id: params.id },
    data
  });
  
  return json(user);
}

export async function DELETE({ params }: APIEvent) {
  await db.user.delete({ where: { id: params.id } });
  return new Response(null, { status: 204 });
}
```

---

## 7) Best Practices

### Common Pitfalls
```tsx
// ==========================================
// SOLID.JS COMMON PITFALLS
// ==========================================

// ❌ WRONG: Destructuring props loses reactivity
const MyComponent = ({ name, count }) => {
  // name and count are not reactive!
  return <div>{name}: {count}</div>;
};

// ✅ CORRECT: Access props directly
const MyComponent = (props) => {
  return <div>{props.name}: {props.count}</div>;
};


// ❌ WRONG: Using ternary/map in JSX
const List = (props) => {
  return (
    <ul>
      {props.items.map(item => <li>{item.name}</li>)}
    </ul>
  );
};

// ✅ CORRECT: Use <For> component
const List = (props) => {
  return (
    <ul>
      <For each={props.items}>
        {(item) => <li>{item.name}</li>}
      </For>
    </ul>
  );
};


// ❌ WRONG: Conditional with &&
{isVisible() && <Component />}

// ✅ CORRECT: Use <Show>
<Show when={isVisible()}>
  <Component />
</Show>


// ❌ WRONG: Reading signal in wrong context
const double = count() * 2;  // Only runs once!

// ✅ CORRECT: Use createMemo
const double = createMemo(() => count() * 2);


// ❌ WRONG: Calling signal like a value
console.log(count);  // Logs the getter function

// ✅ CORRECT: Call signal as function
console.log(count());  // Logs the value
```

### Performance Checklist
```
┌─────────────────────────────────────────┐
│     SOLID.JS PERFORMANCE CHECKLIST      │
├─────────────────────────────────────────┤
│                                         │
│  REACTIVITY:                            │
│  □ Use signals for primitive state     │
│  □ Use stores for nested objects       │
│  □ Use createMemo for derived values   │
│  □ Avoid unnecessary re-renders        │
│                                         │
│  COMPONENTS:                            │
│  □ Don't destructure props             │
│  □ Use control flow components         │
│  □ Use Suspense for async              │
│  □ Lazy load heavy components          │
│                                         │
│  DATA:                                  │
│  □ Use resources for async data        │
│  □ Use reconcile for API updates       │
│  □ Batch multiple updates              │
│                                         │
│  PATTERNS:                              │
│  □ Keep tracking scope minimal         │
│  □ Use untrack when needed             │
│  □ Understand when effects run         │
│                                         │
└─────────────────────────────────────────┘
```

---

## Best Practices Summary

### Signals
- [ ] Call signals as functions
- [ ] Use createMemo for derived
- [ ] Use createEffect for side effects
- [ ] Batch multiple updates

### Components
- [ ] Don't destructure props
- [ ] Use control flow components
- [ ] Use Suspense for async
- [ ] Lazy load routes

### Stores
- [ ] Use for nested objects
- [ ] Use produce for mutations
- [ ] Use reconcile for API data
- [ ] Create context providers

---

**References:**
- [Solid.js Documentation](https://www.solidjs.com/docs)
- [SolidStart](https://start.solidjs.com/)
- [Solid Router](https://github.com/solidjs/solid-router)
- [Solid Tutorial](https://www.solidjs.com/tutorial)

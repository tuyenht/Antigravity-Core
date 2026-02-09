# Remix Framework Expert

> **Version:** 2.0.0 | **Updated:** 2026-02-01  
> **Remix:** 2.x | **Web Standards** | **Progressive Enhancement**  
> **Priority:** P0 - Load for Remix projects

---

You are an expert in Remix, the full-stack web framework.

## Core Principles

- Embrace Web Standards (HTTP, HTML, Forms)
- Progressive Enhancement
- Nested Routing matches UI hierarchy
- No 'loading' spinners (Optimistic UI)

---

## 1) Data Loading (Loaders)

### Basic Loader
```typescript
// ==========================================
// app/routes/users.tsx
// ==========================================

import type { LoaderFunctionArgs } from '@remix-run/node';
import { json } from '@remix-run/node';
import { useLoaderData } from '@remix-run/react';
import { db } from '~/utils/db.server';

// Loader function (runs on server)
export async function loader({ request }: LoaderFunctionArgs) {
  const url = new URL(request.url);
  const page = Number(url.searchParams.get('page')) || 1;
  const search = url.searchParams.get('search') || '';
  
  const users = await db.user.findMany({
    where: search
      ? {
          OR: [
            { name: { contains: search, mode: 'insensitive' } },
            { email: { contains: search, mode: 'insensitive' } },
          ],
        }
      : undefined,
    skip: (page - 1) * 20,
    take: 20,
    orderBy: { createdAt: 'desc' },
  });
  
  const total = await db.user.count();
  
  // Return JSON response with headers
  return json(
    { users, page, total, totalPages: Math.ceil(total / 20) },
    {
      headers: {
        'Cache-Control': 'private, max-age=60',
      },
    }
  );
}

// Component uses loader data
export default function UsersPage() {
  const { users, page, totalPages } = useLoaderData<typeof loader>();
  
  return (
    <div>
      <h1>Users</h1>
      
      <ul>
        {users.map((user) => (
          <li key={user.id}>
            <a href={`/users/${user.id}`}>{user.name}</a>
          </li>
        ))}
      </ul>
      
      <nav>
        {page > 1 && <a href={`?page=${page - 1}`}>Previous</a>}
        <span>Page {page} of {totalPages}</span>
        {page < totalPages && <a href={`?page=${page + 1}`}>Next</a>}
      </nav>
    </div>
  );
}
```

### Dynamic Route Loader
```typescript
// ==========================================
// app/routes/users.$userId.tsx
// ==========================================

import type { LoaderFunctionArgs } from '@remix-run/node';
import { json } from '@remix-run/node';
import { useLoaderData } from '@remix-run/react';
import invariant from 'tiny-invariant';

export async function loader({ params }: LoaderFunctionArgs) {
  invariant(params.userId, 'userId is required');
  
  const user = await db.user.findUnique({
    where: { id: params.userId },
    include: {
      posts: {
        orderBy: { createdAt: 'desc' },
        take: 10,
      },
    },
  });
  
  if (!user) {
    throw new Response('User not found', { status: 404 });
  }
  
  return json({ user });
}

export default function UserDetailPage() {
  const { user } = useLoaderData<typeof loader>();
  
  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
      
      <h2>Recent Posts</h2>
      <ul>
        {user.posts.map((post) => (
          <li key={post.id}>{post.title}</li>
        ))}
      </ul>
    </div>
  );
}
```

### Protected Loader
```typescript
// ==========================================
// app/routes/dashboard.tsx
// ==========================================

import type { LoaderFunctionArgs } from '@remix-run/node';
import { json, redirect } from '@remix-run/node';
import { getUser, requireUser } from '~/utils/session.server';

export async function loader({ request }: LoaderFunctionArgs) {
  // Require authenticated user
  const user = await requireUser(request);
  
  // Or check and redirect manually
  // const user = await getUser(request);
  // if (!user) {
  //   throw redirect('/login');
  // }
  
  const dashboardData = await getDashboardData(user.id);
  
  return json({ user, ...dashboardData });
}

export default function DashboardPage() {
  const { user, stats, recentActivity } = useLoaderData<typeof loader>();
  
  return (
    <div>
      <h1>Welcome, {user.name}</h1>
      {/* Dashboard content */}
    </div>
  );
}
```

---

## 2) Data Mutations (Actions)

### Basic Action
```typescript
// ==========================================
// app/routes/users.new.tsx
// ==========================================

import type { ActionFunctionArgs } from '@remix-run/node';
import { json, redirect } from '@remix-run/node';
import { Form, useActionData, useNavigation } from '@remix-run/react';
import { z } from 'zod';

// Validation schema
const CreateUserSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  email: z.string().email('Invalid email address'),
  role: z.enum(['user', 'admin']).default('user'),
});

type ActionData = {
  errors?: z.ZodError['formErrors']['fieldErrors'];
  values?: Record<string, string>;
};

export async function action({ request }: ActionFunctionArgs) {
  const formData = await request.formData();
  
  const rawData = {
    name: formData.get('name'),
    email: formData.get('email'),
    role: formData.get('role'),
  };
  
  // Validate
  const result = CreateUserSchema.safeParse(rawData);
  
  if (!result.success) {
    return json<ActionData>(
      {
        errors: result.error.formErrors.fieldErrors,
        values: rawData as Record<string, string>,
      },
      { status: 400 }
    );
  }
  
  // Check if email exists
  const existing = await db.user.findUnique({
    where: { email: result.data.email },
  });
  
  if (existing) {
    return json<ActionData>(
      {
        errors: { email: ['Email already exists'] },
        values: rawData as Record<string, string>,
      },
      { status: 400 }
    );
  }
  
  // Create user
  const user = await db.user.create({
    data: result.data,
  });
  
  // Redirect on success
  return redirect(`/users/${user.id}`);
}

export default function NewUserPage() {
  const actionData = useActionData<typeof action>();
  const navigation = useNavigation();
  
  const isSubmitting = navigation.state === 'submitting';
  
  return (
    <div>
      <h1>Create User</h1>
      
      <Form method="post">
        <div>
          <label htmlFor="name">Name</label>
          <input
            id="name"
            name="name"
            defaultValue={actionData?.values?.name}
            aria-invalid={!!actionData?.errors?.name}
            aria-describedby="name-error"
          />
          {actionData?.errors?.name && (
            <p id="name-error" className="error">
              {actionData.errors.name[0]}
            </p>
          )}
        </div>
        
        <div>
          <label htmlFor="email">Email</label>
          <input
            id="email"
            name="email"
            type="email"
            defaultValue={actionData?.values?.email}
            aria-invalid={!!actionData?.errors?.email}
            aria-describedby="email-error"
          />
          {actionData?.errors?.email && (
            <p id="email-error" className="error">
              {actionData.errors.email[0]}
            </p>
          )}
        </div>
        
        <div>
          <label htmlFor="role">Role</label>
          <select id="role" name="role" defaultValue="user">
            <option value="user">User</option>
            <option value="admin">Admin</option>
          </select>
        </div>
        
        <button type="submit" disabled={isSubmitting}>
          {isSubmitting ? 'Creating...' : 'Create User'}
        </button>
      </Form>
    </div>
  );
}
```

### Multiple Actions
```typescript
// ==========================================
// app/routes/users.$userId.tsx
// ==========================================

import type { ActionFunctionArgs } from '@remix-run/node';
import { json, redirect } from '@remix-run/node';
import { Form, useFetcher } from '@remix-run/react';

export async function action({ request, params }: ActionFunctionArgs) {
  const formData = await request.formData();
  const intent = formData.get('intent');
  
  switch (intent) {
    case 'update': {
      const name = formData.get('name') as string;
      await db.user.update({
        where: { id: params.userId },
        data: { name },
      });
      return json({ success: true });
    }
    
    case 'delete': {
      await db.user.delete({
        where: { id: params.userId },
      });
      return redirect('/users');
    }
    
    case 'toggleActive': {
      const user = await db.user.findUnique({
        where: { id: params.userId },
      });
      await db.user.update({
        where: { id: params.userId },
        data: { isActive: !user?.isActive },
      });
      return json({ success: true });
    }
    
    default:
      return json({ error: 'Invalid intent' }, { status: 400 });
  }
}

export default function UserDetailPage() {
  const { user } = useLoaderData<typeof loader>();
  const fetcher = useFetcher();
  
  return (
    <div>
      <h1>{user.name}</h1>
      
      {/* Inline update form */}
      <Form method="post">
        <input type="hidden" name="intent" value="update" />
        <input name="name" defaultValue={user.name} />
        <button type="submit">Update</button>
      </Form>
      
      {/* Toggle with fetcher (no navigation) */}
      <fetcher.Form method="post">
        <input type="hidden" name="intent" value="toggleActive" />
        <button type="submit">
          {user.isActive ? 'Deactivate' : 'Activate'}
        </button>
      </fetcher.Form>
      
      {/* Delete with confirmation */}
      <Form
        method="post"
        onSubmit={(e) => {
          if (!confirm('Are you sure?')) {
            e.preventDefault();
          }
        }}
      >
        <input type="hidden" name="intent" value="delete" />
        <button type="submit" className="danger">Delete</button>
      </Form>
    </div>
  );
}
```

---

## 3) Nested Routing

### Route Structure
```
app/
├── routes/
│   ├── _index.tsx              # / (home)
│   ├── about.tsx               # /about
│   │
│   ├── users.tsx               # /users (layout)
│   ├── users._index.tsx        # /users (index)
│   ├── users.new.tsx           # /users/new
│   ├── users.$userId.tsx       # /users/:userId (layout)
│   ├── users.$userId._index.tsx # /users/:userId (index)
│   ├── users.$userId.edit.tsx  # /users/:userId/edit
│   ├── users.$userId.posts.tsx # /users/:userId/posts
│   │
│   ├── _auth.tsx               # Auth layout (pathless)
│   ├── _auth.login.tsx         # /login
│   ├── _auth.register.tsx      # /register
│   │
│   ├── api.users.ts            # Resource route (no UI)
│   └── api.upload.ts           # Resource route
│
├── root.tsx                    # Root layout
└── entry.server.tsx
```

### Parent Layout
```typescript
// ==========================================
// app/routes/users.tsx (Parent layout)
// ==========================================

import { Outlet, NavLink, useLoaderData } from '@remix-run/react';
import type { LoaderFunctionArgs } from '@remix-run/node';
import { json } from '@remix-run/node';

export async function loader({ request }: LoaderFunctionArgs) {
  // Data for all /users/* routes
  const userCount = await db.user.count();
  return json({ userCount });
}

export default function UsersLayout() {
  const { userCount } = useLoaderData<typeof loader>();
  
  return (
    <div className="users-layout">
      <aside>
        <h2>Users ({userCount})</h2>
        <nav>
          <NavLink 
            to="/users" 
            end
            className={({ isActive }) => isActive ? 'active' : ''}
          >
            All Users
          </NavLink>
          <NavLink 
            to="/users/new"
            className={({ isActive }) => isActive ? 'active' : ''}
          >
            Create User
          </NavLink>
        </nav>
      </aside>
      
      <main>
        {/* Child routes render here */}
        <Outlet />
      </main>
    </div>
  );
}
```

### Child Route
```typescript
// ==========================================
// app/routes/users._index.tsx (Index route)
// ==========================================

import { useLoaderData, Link } from '@remix-run/react';
import type { LoaderFunctionArgs } from '@remix-run/node';
import { json } from '@remix-run/node';

export async function loader({ request }: LoaderFunctionArgs) {
  const users = await db.user.findMany({
    orderBy: { createdAt: 'desc' },
    take: 50,
  });
  return json({ users });
}

export default function UsersIndexPage() {
  const { users } = useLoaderData<typeof loader>();
  
  return (
    <div>
      <h1>All Users</h1>
      
      <ul>
        {users.map((user) => (
          <li key={user.id}>
            <Link to={user.id}>{user.name}</Link>
          </li>
        ))}
      </ul>
    </div>
  );
}
```

### Pathless Layout
```typescript
// ==========================================
// app/routes/_auth.tsx (Pathless layout for /login, /register)
// ==========================================

import { Outlet } from '@remix-run/react';

export default function AuthLayout() {
  return (
    <div className="auth-layout">
      <div className="auth-container">
        <h1>Welcome</h1>
        <Outlet />
      </div>
    </div>
  );
}

// app/routes/_auth.login.tsx -> /login
// app/routes/_auth.register.tsx -> /register
```

---

## 4) Optimistic UI

### Optimistic Updates
```typescript
// ==========================================
// Optimistic UI Patterns
// ==========================================

import { useFetcher, useNavigation } from '@remix-run/react';

// ==========================================
// PATTERN 1: Optimistic List Item
// ==========================================

function TodoItem({ todo }: { todo: Todo }) {
  const fetcher = useFetcher();
  
  // Optimistic value
  const isCompleted = fetcher.formData
    ? fetcher.formData.get('completed') === 'true'
    : todo.completed;
  
  return (
    <li className={isCompleted ? 'completed' : ''}>
      <fetcher.Form method="post">
        <input type="hidden" name="todoId" value={todo.id} />
        <input type="hidden" name="completed" value={String(!todo.completed)} />
        <button type="submit">
          {isCompleted ? '✓' : '○'}
        </button>
      </fetcher.Form>
      <span>{todo.title}</span>
    </li>
  );
}


// ==========================================
// PATTERN 2: Optimistic Add
// ==========================================

function TodoList() {
  const { todos } = useLoaderData<typeof loader>();
  const fetcher = useFetcher();
  
  // Optimistically add new todo
  const optimisticTodos = [...todos];
  
  if (fetcher.formData?.get('intent') === 'create') {
    optimisticTodos.push({
      id: 'optimistic-' + Date.now(),
      title: fetcher.formData.get('title') as string,
      completed: false,
    });
  }
  
  return (
    <div>
      <fetcher.Form method="post">
        <input type="hidden" name="intent" value="create" />
        <input name="title" placeholder="New todo..." />
        <button type="submit">Add</button>
      </fetcher.Form>
      
      <ul>
        {optimisticTodos.map((todo) => (
          <TodoItem key={todo.id} todo={todo} />
        ))}
      </ul>
    </div>
  );
}


// ==========================================
// PATTERN 3: Optimistic Delete
// ==========================================

function UserList() {
  const { users } = useLoaderData<typeof loader>();
  const fetcher = useFetcher();
  
  // Filter out deleted users optimistically
  const deletingId = fetcher.formData?.get('userId');
  const visibleUsers = users.filter(
    (user) => user.id !== deletingId
  );
  
  return (
    <ul>
      {visibleUsers.map((user) => (
        <li key={user.id}>
          {user.name}
          <fetcher.Form method="post">
            <input type="hidden" name="intent" value="delete" />
            <input type="hidden" name="userId" value={user.id} />
            <button type="submit">Delete</button>
          </fetcher.Form>
        </li>
      ))}
    </ul>
  );
}


// ==========================================
// PATTERN 4: Pending UI States
// ==========================================

function SubmitButton() {
  const navigation = useNavigation();
  
  const isSubmitting = navigation.state === 'submitting';
  const isLoading = navigation.state === 'loading';
  const isIdle = navigation.state === 'idle';
  
  // Get the form data being submitted
  const formData = navigation.formData;
  const intent = formData?.get('intent');
  
  return (
    <button type="submit" disabled={isSubmitting}>
      {isSubmitting ? 'Saving...' : 'Save'}
    </button>
  );
}


// ==========================================
// PATTERN 5: Global Loading Indicator
// ==========================================

function GlobalSpinner() {
  const navigation = useNavigation();
  
  if (navigation.state === 'idle') return null;
  
  return (
    <div className="global-spinner">
      <progress />
    </div>
  );
}
```

---

## 5) Error Handling

### Error Boundaries
```typescript
// ==========================================
// app/root.tsx - Global Error Boundary
// ==========================================

import {
  Links,
  Meta,
  Outlet,
  Scripts,
  ScrollRestoration,
  isRouteErrorResponse,
  useRouteError,
} from '@remix-run/react';

export function ErrorBoundary() {
  const error = useRouteError();
  
  if (isRouteErrorResponse(error)) {
    return (
      <html>
        <head>
          <title>Oops!</title>
          <Meta />
          <Links />
        </head>
        <body>
          <div className="error-page">
            <h1>{error.status} {error.statusText}</h1>
            <p>{error.data}</p>
            <a href="/">Go Home</a>
          </div>
          <Scripts />
        </body>
      </html>
    );
  }
  
  // Unknown error
  return (
    <html>
      <head>
        <title>Error!</title>
        <Meta />
        <Links />
      </head>
      <body>
        <div className="error-page">
          <h1>Something went wrong</h1>
          <p>{error instanceof Error ? error.message : 'Unknown error'}</p>
          <a href="/">Go Home</a>
        </div>
        <Scripts />
      </body>
    </html>
  );
}

export default function App() {
  return (
    <html lang="en">
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <Meta />
        <Links />
      </head>
      <body>
        <Outlet />
        <ScrollRestoration />
        <Scripts />
      </body>
    </html>
  );
}
```

### Route-Level Error Boundary
```typescript
// ==========================================
// app/routes/users.$userId.tsx
// ==========================================

import { isRouteErrorResponse, useRouteError, Link } from '@remix-run/react';

export async function loader({ params }: LoaderFunctionArgs) {
  const user = await db.user.findUnique({
    where: { id: params.userId },
  });
  
  if (!user) {
    throw new Response('User not found', { status: 404 });
  }
  
  return json({ user });
}

// Error boundary scoped to this route
export function ErrorBoundary() {
  const error = useRouteError();
  
  if (isRouteErrorResponse(error)) {
    if (error.status === 404) {
      return (
        <div className="error">
          <h2>User Not Found</h2>
          <p>The user you're looking for doesn't exist.</p>
          <Link to="/users">Back to Users</Link>
        </div>
      );
    }
  }
  
  return (
    <div className="error">
      <h2>Error Loading User</h2>
      <p>Something went wrong. Please try again.</p>
      <Link to="/users">Back to Users</Link>
    </div>
  );
}

export default function UserDetailPage() {
  const { user } = useLoaderData<typeof loader>();
  return <div>{user.name}</div>;
}
```

---

## 6) Resource Routes

### API Endpoints
```typescript
// ==========================================
// app/routes/api.users.ts (No default export = Resource Route)
// ==========================================

import type { LoaderFunctionArgs, ActionFunctionArgs } from '@remix-run/node';
import { json } from '@remix-run/node';

// GET /api/users
export async function loader({ request }: LoaderFunctionArgs) {
  const url = new URL(request.url);
  const search = url.searchParams.get('q') || '';
  
  const users = await db.user.findMany({
    where: search
      ? { name: { contains: search, mode: 'insensitive' } }
      : undefined,
    take: 50,
  });
  
  return json({ users });
}

// POST /api/users
export async function action({ request }: ActionFunctionArgs) {
  if (request.method !== 'POST') {
    return json({ error: 'Method not allowed' }, { status: 405 });
  }
  
  const data = await request.json();
  
  const user = await db.user.create({ data });
  
  return json({ user }, { status: 201 });
}
```

### File Upload
```typescript
// ==========================================
// app/routes/api.upload.ts
// ==========================================

import type { ActionFunctionArgs } from '@remix-run/node';
import { json, unstable_parseMultipartFormData } from '@remix-run/node';
import { uploadHandler } from '~/utils/upload.server';

export async function action({ request }: ActionFunctionArgs) {
  const formData = await unstable_parseMultipartFormData(
    request,
    uploadHandler
  );
  
  const file = formData.get('file');
  
  if (!file || typeof file === 'string') {
    return json({ error: 'No file uploaded' }, { status: 400 });
  }
  
  return json({
    success: true,
    filename: file.name,
    size: file.size,
  });
}


// ==========================================
// app/utils/upload.server.ts
// ==========================================

import type { UploadHandler } from '@remix-run/node';
import { writeAsyncIterableToWritable } from '@remix-run/node';
import { createWriteStream } from 'fs';
import { join } from 'path';

export const uploadHandler: UploadHandler = async ({ name, data, filename }) => {
  if (name !== 'file') {
    return undefined;
  }
  
  const filepath = join(process.cwd(), 'uploads', filename!);
  const writeStream = createWriteStream(filepath);
  
  await writeAsyncIterableToWritable(data, writeStream);
  
  return new File([filepath], filename!);
};
```

---

## 7) Sessions & Auth

### Session Management
```typescript
// ==========================================
// app/utils/session.server.ts
// ==========================================

import { createCookieSessionStorage, redirect } from '@remix-run/node';

type SessionData = {
  userId: string;
};

type SessionFlashData = {
  error: string;
  success: string;
};

const sessionSecret = process.env.SESSION_SECRET!;

export const sessionStorage = createCookieSessionStorage<
  SessionData,
  SessionFlashData
>({
  cookie: {
    name: '__session',
    httpOnly: true,
    maxAge: 60 * 60 * 24 * 7, // 1 week
    path: '/',
    sameSite: 'lax',
    secrets: [sessionSecret],
    secure: process.env.NODE_ENV === 'production',
  },
});

export async function getSession(request: Request) {
  return sessionStorage.getSession(request.headers.get('Cookie'));
}

export async function getUserId(request: Request): Promise<string | null> {
  const session = await getSession(request);
  return session.get('userId') || null;
}

export async function getUser(request: Request) {
  const userId = await getUserId(request);
  if (!userId) return null;
  
  return db.user.findUnique({ where: { id: userId } });
}

export async function requireUserId(request: Request): Promise<string> {
  const userId = await getUserId(request);
  
  if (!userId) {
    const url = new URL(request.url);
    throw redirect(`/login?redirectTo=${url.pathname}`);
  }
  
  return userId;
}

export async function requireUser(request: Request) {
  const userId = await requireUserId(request);
  
  const user = await db.user.findUnique({ where: { id: userId } });
  
  if (!user) {
    throw await logout(request);
  }
  
  return user;
}

export async function createUserSession(userId: string, redirectTo: string) {
  const session = await sessionStorage.getSession();
  session.set('userId', userId);
  
  return redirect(redirectTo, {
    headers: {
      'Set-Cookie': await sessionStorage.commitSession(session),
    },
  });
}

export async function logout(request: Request) {
  const session = await getSession(request);
  
  return redirect('/login', {
    headers: {
      'Set-Cookie': await sessionStorage.destroySession(session),
    },
  });
}
```

### Login Route
```typescript
// ==========================================
// app/routes/_auth.login.tsx
// ==========================================

import type { ActionFunctionArgs, LoaderFunctionArgs } from '@remix-run/node';
import { json, redirect } from '@remix-run/node';
import { Form, useActionData, useSearchParams } from '@remix-run/react';
import { z } from 'zod';
import { getUserId, createUserSession } from '~/utils/session.server';
import { verifyPassword } from '~/utils/auth.server';

const LoginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
  redirectTo: z.string().default('/dashboard'),
});

export async function loader({ request }: LoaderFunctionArgs) {
  const userId = await getUserId(request);
  if (userId) return redirect('/dashboard');
  return json({});
}

export async function action({ request }: ActionFunctionArgs) {
  const formData = await request.formData();
  
  const result = LoginSchema.safeParse(Object.fromEntries(formData));
  
  if (!result.success) {
    return json({ error: 'Invalid form data' }, { status: 400 });
  }
  
  const { email, password, redirectTo } = result.data;
  
  const user = await db.user.findUnique({ where: { email } });
  
  if (!user || !await verifyPassword(password, user.passwordHash)) {
    return json({ error: 'Invalid email or password' }, { status: 401 });
  }
  
  return createUserSession(user.id, redirectTo);
}

export default function LoginPage() {
  const actionData = useActionData<typeof action>();
  const [searchParams] = useSearchParams();
  const redirectTo = searchParams.get('redirectTo') || '/dashboard';
  
  return (
    <Form method="post">
      <input type="hidden" name="redirectTo" value={redirectTo} />
      
      {actionData?.error && (
        <div className="error">{actionData.error}</div>
      )}
      
      <div>
        <label htmlFor="email">Email</label>
        <input id="email" name="email" type="email" required />
      </div>
      
      <div>
        <label htmlFor="password">Password</label>
        <input id="password" name="password" type="password" required />
      </div>
      
      <button type="submit">Log In</button>
    </Form>
  );
}
```

---

## 8) Best Practices

### Performance Checklist
```
┌─────────────────────────────────────────┐
│      REMIX PERFORMANCE CHECKLIST        │
├─────────────────────────────────────────┤
│                                         │
│  DATA LOADING:                          │
│  □ Use parallel loaders (nested routes)│
│  □ Add Cache-Control headers           │
│  □ Defer non-critical data             │
│                                         │
│  FORMS:                                 │
│  □ Use <Form> instead of fetch         │
│  □ Implement optimistic UI             │
│  □ Validate with Zod on server         │
│                                         │
│  ERROR HANDLING:                        │
│  □ Add ErrorBoundary per route         │
│  □ Throw Response for expected errors  │
│  □ Handle network failures             │
│                                         │
│  UX:                                    │
│  □ Show pending states (useNavigation) │
│  □ Use fetcher for inline forms        │
│  □ Progressive enhancement             │
│                                         │
│  SECURITY:                              │
│  □ Validate all inputs server-side     │
│  □ Use secure session cookies          │
│  □ Implement CSRF protection           │
│                                         │
└─────────────────────────────────────────┘
```

---

## Best Practices Summary

### Loaders
- [ ] Return json() responses
- [ ] Add cache headers
- [ ] Throw Response for errors
- [ ] Use parallel loading

### Actions
- [ ] Validate with Zod
- [ ] Return validation errors
- [ ] Redirect on success
- [ ] Handle multiple intents

### Forms
- [ ] Use <Form> component
- [ ] Implement optimistic UI
- [ ] Show pending states
- [ ] Progressive enhancement

---

**References:**
- [Remix Documentation](https://remix.run/docs)
- [Remix Examples](https://github.com/remix-run/examples)
- [Remix Stacks](https://remix.run/stacks)
- [Web Fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API)

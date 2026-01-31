# Next.js Testing Strategies Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **Jest:** 29.x | **Playwright:** 1.40+  
> **Priority:** P0 - Load for all testing tasks

---

You are an expert in Next.js testing strategies and best practices.

## Core Testing Principles

- Test Server and Client Components differently
- Use Jest for unit and integration tests
- Use Playwright for E2E tests
- Test Server Actions thoroughly
- Implement proper mocking strategies

---

## 1) Jest Setup for Next.js

### Installation & Configuration
```bash
npm install -D jest @testing-library/react @testing-library/jest-dom \
  @testing-library/user-event jest-environment-jsdom \
  @types/jest ts-jest
```

```typescript
// ==========================================
// jest.config.ts
// ==========================================

import type { Config } from 'jest';
import nextJest from 'next/jest';

const createJestConfig = nextJest({
  // Path to Next.js app
  dir: './',
});

const customConfig: Config = {
  setupFilesAfterEnv: ['<rootDir>/jest.setup.ts'],
  testEnvironment: 'jsdom',
  
  // Module aliases (match tsconfig.json)
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/$1',
    '^@/components/(.*)$': '<rootDir>/components/$1',
    '^@/lib/(.*)$': '<rootDir>/lib/$1',
  },
  
  // Test patterns
  testMatch: [
    '**/__tests__/**/*.test.[jt]s?(x)',
    '**/*.test.[jt]s?(x)',
  ],
  
  // Coverage configuration
  collectCoverageFrom: [
    'app/**/*.{js,jsx,ts,tsx}',
    'components/**/*.{js,jsx,ts,tsx}',
    'lib/**/*.{js,jsx,ts,tsx}',
    '!**/*.d.ts',
    '!**/node_modules/**',
    '!**/.next/**',
  ],
  
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 80,
      statements: 80,
    },
  },
  
  // Transform for ES modules
  transformIgnorePatterns: [
    '/node_modules/(?!(next-intl|@/)/)',
  ],
};

export default createJestConfig(customConfig);


// ==========================================
// jest.setup.ts
// ==========================================

import '@testing-library/jest-dom';

// Mock Next.js router
jest.mock('next/navigation', () => ({
  useRouter: () => ({
    push: jest.fn(),
    replace: jest.fn(),
    prefetch: jest.fn(),
    back: jest.fn(),
    forward: jest.fn(),
    refresh: jest.fn(),
  }),
  usePathname: () => '/',
  useSearchParams: () => new URLSearchParams(),
  useParams: () => ({}),
  redirect: jest.fn(),
  notFound: jest.fn(),
}));

// Mock next/image
jest.mock('next/image', () => ({
  __esModule: true,
  default: (props: any) => {
    // eslint-disable-next-line @next/next/no-img-element
    return <img {...props} />;
  },
}));

// Mock next/link
jest.mock('next/link', () => ({
  __esModule: true,
  default: ({ children, href, ...props }: any) => (
    <a href={href} {...props}>{children}</a>
  ),
}));

// Global mocks
global.ResizeObserver = jest.fn().mockImplementation(() => ({
  observe: jest.fn(),
  unobserve: jest.fn(),
  disconnect: jest.fn(),
}));

global.IntersectionObserver = jest.fn().mockImplementation(() => ({
  observe: jest.fn(),
  unobserve: jest.fn(),
  disconnect: jest.fn(),
}));

// Suppress console errors in tests (optional)
const originalError = console.error;
beforeAll(() => {
  console.error = (...args) => {
    if (
      typeof args[0] === 'string' &&
      args[0].includes('Warning: ReactDOM.render')
    ) {
      return;
    }
    originalError.call(console, ...args);
  };
});

afterAll(() => {
  console.error = originalError;
});
```

---

## 2) Testing Client Components

### Basic Component Tests
```typescript
// ==========================================
// components/Button/__tests__/Button.test.tsx
// ==========================================

import { render, screen, fireEvent } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Button } from '../Button';

describe('Button', () => {
  it('renders with correct text', () => {
    render(<Button>Click me</Button>);
    
    expect(screen.getByRole('button', { name: /click me/i })).toBeInTheDocument();
  });

  it('calls onClick when clicked', async () => {
    const handleClick = jest.fn();
    const user = userEvent.setup();
    
    render(<Button onClick={handleClick}>Click me</Button>);
    
    await user.click(screen.getByRole('button'));
    
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('shows loading state', () => {
    render(<Button isLoading>Submit</Button>);
    
    expect(screen.getByRole('button')).toBeDisabled();
    expect(screen.getByText(/loading/i)).toBeInTheDocument();
  });

  it('applies variant classes', () => {
    const { rerender } = render(<Button variant="primary">Primary</Button>);
    expect(screen.getByRole('button')).toHaveClass('btn-primary');
    
    rerender(<Button variant="secondary">Secondary</Button>);
    expect(screen.getByRole('button')).toHaveClass('btn-secondary');
  });
});


// ==========================================
// TESTING COMPONENTS WITH STATE
// ==========================================

// components/Counter/__tests__/Counter.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Counter } from '../Counter';

describe('Counter', () => {
  it('starts with initial count', () => {
    render(<Counter initialCount={5} />);
    
    expect(screen.getByText('Count: 5')).toBeInTheDocument();
  });

  it('increments count when clicking +', async () => {
    const user = userEvent.setup();
    render(<Counter initialCount={0} />);
    
    await user.click(screen.getByRole('button', { name: '+' }));
    await user.click(screen.getByRole('button', { name: '+' }));
    
    expect(screen.getByText('Count: 2')).toBeInTheDocument();
  });

  it('decrements count when clicking -', async () => {
    const user = userEvent.setup();
    render(<Counter initialCount={5} />);
    
    await user.click(screen.getByRole('button', { name: '-' }));
    
    expect(screen.getByText('Count: 4')).toBeInTheDocument();
  });

  it('does not go below minimum', async () => {
    const user = userEvent.setup();
    render(<Counter initialCount={0} min={0} />);
    
    await user.click(screen.getByRole('button', { name: '-' }));
    
    expect(screen.getByText('Count: 0')).toBeInTheDocument();
  });
});


// ==========================================
// TESTING FORMS
// ==========================================

// components/LoginForm/__tests__/LoginForm.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { LoginForm } from '../LoginForm';

describe('LoginForm', () => {
  const mockOnSubmit = jest.fn();

  beforeEach(() => {
    mockOnSubmit.mockClear();
  });

  it('renders form fields', () => {
    render(<LoginForm onSubmit={mockOnSubmit} />);
    
    expect(screen.getByLabelText(/email/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/password/i)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /sign in/i })).toBeInTheDocument();
  });

  it('shows validation errors for empty fields', async () => {
    const user = userEvent.setup();
    render(<LoginForm onSubmit={mockOnSubmit} />);
    
    await user.click(screen.getByRole('button', { name: /sign in/i }));
    
    await waitFor(() => {
      expect(screen.getByText(/email is required/i)).toBeInTheDocument();
      expect(screen.getByText(/password is required/i)).toBeInTheDocument();
    });
    
    expect(mockOnSubmit).not.toHaveBeenCalled();
  });

  it('shows error for invalid email', async () => {
    const user = userEvent.setup();
    render(<LoginForm onSubmit={mockOnSubmit} />);
    
    await user.type(screen.getByLabelText(/email/i), 'invalid-email');
    await user.type(screen.getByLabelText(/password/i), 'password123');
    await user.click(screen.getByRole('button', { name: /sign in/i }));
    
    await waitFor(() => {
      expect(screen.getByText(/invalid email/i)).toBeInTheDocument();
    });
  });

  it('submits form with valid data', async () => {
    const user = userEvent.setup();
    render(<LoginForm onSubmit={mockOnSubmit} />);
    
    await user.type(screen.getByLabelText(/email/i), 'test@example.com');
    await user.type(screen.getByLabelText(/password/i), 'password123');
    await user.click(screen.getByRole('button', { name: /sign in/i }));
    
    await waitFor(() => {
      expect(mockOnSubmit).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123',
      });
    });
  });

  it('shows loading state during submission', async () => {
    const user = userEvent.setup();
    mockOnSubmit.mockImplementation(() => new Promise(r => setTimeout(r, 100)));
    
    render(<LoginForm onSubmit={mockOnSubmit} />);
    
    await user.type(screen.getByLabelText(/email/i), 'test@example.com');
    await user.type(screen.getByLabelText(/password/i), 'password123');
    await user.click(screen.getByRole('button', { name: /sign in/i }));
    
    expect(screen.getByRole('button', { name: /signing in/i })).toBeDisabled();
  });
});
```

---

## 3) Testing Server Components

### Server Component Testing
```typescript
// ==========================================
// TESTING ASYNC SERVER COMPONENTS
// ==========================================

// app/posts/page.test.tsx
import { render, screen } from '@testing-library/react';
import PostsPage from './page';
import { prisma } from '@/lib/prisma';

// Mock Prisma
jest.mock('@/lib/prisma', () => ({
  prisma: {
    post: {
      findMany: jest.fn(),
      count: jest.fn(),
    },
  },
}));

describe('PostsPage', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders posts from database', async () => {
    const mockPosts = [
      { id: '1', title: 'First Post', slug: 'first-post' },
      { id: '2', title: 'Second Post', slug: 'second-post' },
    ];
    
    (prisma.post.findMany as jest.Mock).mockResolvedValue(mockPosts);
    (prisma.post.count as jest.Mock).mockResolvedValue(2);
    
    // Render async component
    const Component = await PostsPage({ searchParams: {} });
    render(Component);
    
    expect(screen.getByText('First Post')).toBeInTheDocument();
    expect(screen.getByText('Second Post')).toBeInTheDocument();
  });

  it('shows empty state when no posts', async () => {
    (prisma.post.findMany as jest.Mock).mockResolvedValue([]);
    (prisma.post.count as jest.Mock).mockResolvedValue(0);
    
    const Component = await PostsPage({ searchParams: {} });
    render(Component);
    
    expect(screen.getByText(/no posts found/i)).toBeInTheDocument();
  });

  it('handles pagination params', async () => {
    (prisma.post.findMany as jest.Mock).mockResolvedValue([]);
    (prisma.post.count as jest.Mock).mockResolvedValue(100);
    
    await PostsPage({ searchParams: { page: '2' } });
    
    expect(prisma.post.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        skip: 20,
        take: 20,
      })
    );
  });
});


// ==========================================
// TESTING DATA FETCHING FUNCTIONS
// ==========================================

// lib/queries/__tests__/posts.test.ts
import { getPosts, getPost } from '../posts';
import { prisma } from '@/lib/prisma';

jest.mock('@/lib/prisma');

describe('getPosts', () => {
  it('returns paginated posts', async () => {
    const mockPosts = [{ id: '1', title: 'Test' }];
    (prisma.post.findMany as jest.Mock).mockResolvedValue(mockPosts);
    (prisma.post.count as jest.Mock).mockResolvedValue(1);
    
    const result = await getPosts({ page: 1, limit: 20 });
    
    expect(result.posts).toEqual(mockPosts);
    expect(result.pagination.total).toBe(1);
  });

  it('filters by status', async () => {
    await getPosts({ page: 1, status: 'PUBLISHED' });
    
    expect(prisma.post.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          status: 'PUBLISHED',
        }),
      })
    );
  });
});

describe('getPost', () => {
  it('returns post by slug', async () => {
    const mockPost = { id: '1', slug: 'test-post', title: 'Test' };
    (prisma.post.findUnique as jest.Mock).mockResolvedValue(mockPost);
    
    const result = await getPost('test-post');
    
    expect(result).toEqual(mockPost);
  });

  it('returns null for non-existent post', async () => {
    (prisma.post.findUnique as jest.Mock).mockResolvedValue(null);
    
    const result = await getPost('non-existent');
    
    expect(result).toBeNull();
  });
});
```

---

## 4) Testing Server Actions

### Server Action Tests
```typescript
// ==========================================
// app/actions/__tests__/posts.test.ts
// ==========================================

import { createPost, updatePost, deletePost } from '../posts';
import { prisma } from '@/lib/prisma';
import { auth } from '@/auth';
import { revalidatePath } from 'next/cache';

// Mock dependencies
jest.mock('@/lib/prisma');
jest.mock('@/auth');
jest.mock('next/cache', () => ({
  revalidatePath: jest.fn(),
  revalidateTag: jest.fn(),
}));

describe('createPost', () => {
  const mockUser = { id: 'user-1', email: 'test@example.com', role: 'USER' };
  
  beforeEach(() => {
    jest.clearAllMocks();
    (auth as jest.Mock).mockResolvedValue({ user: mockUser });
  });

  it('creates post with valid data', async () => {
    const formData = new FormData();
    formData.set('title', 'Test Post');
    formData.set('content', 'This is test content for the post.');
    formData.set('categoryId', 'category-1');
    
    const mockPost = { id: 'post-1', slug: 'test-post' };
    (prisma.post.create as jest.Mock).mockResolvedValue(mockPost);
    
    const result = await createPost({} as any, formData);
    
    expect(result.success).toBe(true);
    expect(result.data).toEqual({ id: 'post-1', slug: 'test-post' });
    expect(prisma.post.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        title: 'Test Post',
        authorId: 'user-1',
      }),
    });
    expect(revalidatePath).toHaveBeenCalledWith('/posts');
  });

  it('returns error for unauthenticated user', async () => {
    (auth as jest.Mock).mockResolvedValue(null);
    
    const formData = new FormData();
    formData.set('title', 'Test');
    formData.set('content', 'Content here');
    
    const result = await createPost({} as any, formData);
    
    expect(result.success).toBe(false);
    expect(result.error).toBe('Unauthorized');
  });

  it('returns validation errors for invalid data', async () => {
    const formData = new FormData();
    formData.set('title', '');  // Empty title
    formData.set('content', 'Short');  // Too short
    
    const result = await createPost({} as any, formData);
    
    expect(result.success).toBe(false);
    expect(result.errors?.title).toBeDefined();
    expect(result.errors?.content).toBeDefined();
  });

  it('handles database errors', async () => {
    const formData = new FormData();
    formData.set('title', 'Test Post');
    formData.set('content', 'Valid content here');
    formData.set('categoryId', 'category-1');
    
    (prisma.post.create as jest.Mock).mockRejectedValue(new Error('DB Error'));
    
    const result = await createPost({} as any, formData);
    
    expect(result.success).toBe(false);
    expect(result.error).toBe('Failed to create post');
  });
});

describe('deletePost', () => {
  const mockUser = { id: 'user-1', role: 'USER' };
  
  beforeEach(() => {
    jest.clearAllMocks();
    (auth as jest.Mock).mockResolvedValue({ user: mockUser });
  });

  it('deletes own post', async () => {
    (prisma.post.findUnique as jest.Mock).mockResolvedValue({
      id: 'post-1',
      authorId: 'user-1',
    });
    (prisma.post.update as jest.Mock).mockResolvedValue({});
    
    const result = await deletePost('post-1');
    
    expect(result.success).toBe(true);
    expect(prisma.post.update).toHaveBeenCalledWith({
      where: { id: 'post-1' },
      data: { deletedAt: expect.any(Date) },
    });
  });

  it('prevents deleting other user posts', async () => {
    (prisma.post.findUnique as jest.Mock).mockResolvedValue({
      id: 'post-1',
      authorId: 'other-user',
    });
    
    const result = await deletePost('post-1');
    
    expect(result.success).toBe(false);
    expect(result.error).toBe('Forbidden');
  });

  it('allows admin to delete any post', async () => {
    (auth as jest.Mock).mockResolvedValue({ 
      user: { id: 'admin-1', role: 'ADMIN' } 
    });
    (prisma.post.findUnique as jest.Mock).mockResolvedValue({
      id: 'post-1',
      authorId: 'other-user',
    });
    (prisma.post.update as jest.Mock).mockResolvedValue({});
    
    const result = await deletePost('post-1');
    
    expect(result.success).toBe(true);
  });
});
```

---

## 5) Mocking Next.js APIs

### Custom Mocks
```typescript
// ==========================================
// __mocks__/next/navigation.ts
// ==========================================

export const useRouter = jest.fn(() => ({
  push: jest.fn(),
  replace: jest.fn(),
  prefetch: jest.fn(),
  back: jest.fn(),
  forward: jest.fn(),
  refresh: jest.fn(),
}));

export const usePathname = jest.fn(() => '/');

export const useSearchParams = jest.fn(() => new URLSearchParams());

export const useParams = jest.fn(() => ({}));

export const redirect = jest.fn();

export const notFound = jest.fn();


// ==========================================
// TESTING WITH ROUTER
// ==========================================

// components/Navigation/__tests__/Navigation.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { useRouter, usePathname } from 'next/navigation';
import { Navigation } from '../Navigation';

jest.mock('next/navigation');

describe('Navigation', () => {
  const mockPush = jest.fn();
  
  beforeEach(() => {
    jest.clearAllMocks();
    (useRouter as jest.Mock).mockReturnValue({ push: mockPush });
    (usePathname as jest.Mock).mockReturnValue('/');
  });

  it('highlights active link', () => {
    (usePathname as jest.Mock).mockReturnValue('/about');
    
    render(<Navigation />);
    
    expect(screen.getByRole('link', { name: /about/i }))
      .toHaveClass('active');
  });

  it('navigates on link click', async () => {
    const user = userEvent.setup();
    render(<Navigation />);
    
    await user.click(screen.getByRole('link', { name: /products/i }));
    
    // Navigation via Link happens naturally, or via router.push
  });
});


// ==========================================
// TESTING WITH SEARCH PARAMS
// ==========================================

import { useSearchParams, useRouter } from 'next/navigation';
import { SearchFilter } from '../SearchFilter';

describe('SearchFilter', () => {
  const mockPush = jest.fn();
  
  beforeEach(() => {
    (useRouter as jest.Mock).mockReturnValue({ push: mockPush });
    (useSearchParams as jest.Mock).mockReturnValue(new URLSearchParams('q=test'));
  });

  it('reads initial value from URL', () => {
    render(<SearchFilter />);
    
    expect(screen.getByRole('searchbox')).toHaveValue('test');
  });

  it('updates URL on search', async () => {
    const user = userEvent.setup();
    render(<SearchFilter />);
    
    await user.clear(screen.getByRole('searchbox'));
    await user.type(screen.getByRole('searchbox'), 'new search');
    await user.click(screen.getByRole('button', { name: /search/i }));
    
    expect(mockPush).toHaveBeenCalledWith(
      expect.stringContaining('q=new+search')
    );
  });
});
```

---

## 6) API Route Testing

### Route Handler Tests
```typescript
// ==========================================
// app/api/posts/__tests__/route.test.ts
// ==========================================

import { GET, POST } from '../route';
import { NextRequest } from 'next/server';
import { prisma } from '@/lib/prisma';
import { auth } from '@/auth';

jest.mock('@/lib/prisma');
jest.mock('@/auth');

// Helper to create mock request
function createMockRequest(options: {
  method?: string;
  body?: object;
  searchParams?: Record<string, string>;
}) {
  const url = new URL('http://localhost/api/posts');
  
  if (options.searchParams) {
    Object.entries(options.searchParams).forEach(([key, value]) => {
      url.searchParams.set(key, value);
    });
  }
  
  return new NextRequest(url, {
    method: options.method || 'GET',
    body: options.body ? JSON.stringify(options.body) : undefined,
    headers: options.body ? { 'Content-Type': 'application/json' } : undefined,
  });
}

describe('GET /api/posts', () => {
  it('returns paginated posts', async () => {
    const mockPosts = [
      { id: '1', title: 'Post 1' },
      { id: '2', title: 'Post 2' },
    ];
    (prisma.post.findMany as jest.Mock).mockResolvedValue(mockPosts);
    (prisma.post.count as jest.Mock).mockResolvedValue(2);
    
    const request = createMockRequest({ searchParams: { page: '1', limit: '20' } });
    const response = await GET(request);
    const data = await response.json();
    
    expect(response.status).toBe(200);
    expect(data.data).toEqual(mockPosts);
    expect(data.pagination.total).toBe(2);
  });

  it('handles search query', async () => {
    (prisma.post.findMany as jest.Mock).mockResolvedValue([]);
    (prisma.post.count as jest.Mock).mockResolvedValue(0);
    
    const request = createMockRequest({ searchParams: { q: 'test query' } });
    await GET(request);
    
    expect(prisma.post.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          OR: expect.arrayContaining([
            expect.objectContaining({ title: expect.any(Object) }),
            expect.objectContaining({ content: expect.any(Object) }),
          ]),
        }),
      })
    );
  });
});

describe('POST /api/posts', () => {
  beforeEach(() => {
    (auth as jest.Mock).mockResolvedValue({ user: { id: 'user-1' } });
  });

  it('creates post with valid data', async () => {
    const mockPost = { id: 'new-post', slug: 'test-post' };
    (prisma.post.create as jest.Mock).mockResolvedValue(mockPost);
    
    const request = createMockRequest({
      method: 'POST',
      body: {
        title: 'Test Post',
        content: 'This is the content',
        categoryId: 'category-1',
      },
    });
    
    const response = await POST(request);
    const data = await response.json();
    
    expect(response.status).toBe(201);
    expect(data.data).toEqual(mockPost);
  });

  it('returns 401 for unauthenticated request', async () => {
    (auth as jest.Mock).mockResolvedValue(null);
    
    const request = createMockRequest({
      method: 'POST',
      body: { title: 'Test' },
    });
    
    const response = await POST(request);
    
    expect(response.status).toBe(401);
  });

  it('returns 400 for invalid data', async () => {
    const request = createMockRequest({
      method: 'POST',
      body: { title: '' },  // Invalid
    });
    
    const response = await POST(request);
    const data = await response.json();
    
    expect(response.status).toBe(400);
    expect(data.error).toBe('Validation failed');
  });
});
```

---

## 7) E2E Testing with Playwright

### Playwright Setup
```typescript
// ==========================================
// playwright.config.ts
// ==========================================

import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  
  // Run tests in parallel
  fullyParallel: true,
  
  // Fail build on test.only()
  forbidOnly: !!process.env.CI,
  
  // Retry on CI
  retries: process.env.CI ? 2 : 0,
  
  // Parallel workers
  workers: process.env.CI ? 1 : undefined,
  
  // Reporter
  reporter: [
    ['list'],
    ['html', { open: 'never' }],
  ],
  
  use: {
    // Base URL
    baseURL: 'http://localhost:3000',
    
    // Trace on failure
    trace: 'on-first-retry',
    
    // Screenshot on failure
    screenshot: 'only-on-failure',
    
    // Video on failure
    video: 'on-first-retry',
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },
    {
      name: 'Mobile Safari',
      use: { ...devices['iPhone 12'] },
    },
  ],

  // Start dev server before tests
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 120000,
  },
});


// ==========================================
// e2e/auth.spec.ts
// ==========================================

import { test, expect } from '@playwright/test';

test.describe('Authentication', () => {
  test('should login with valid credentials', async ({ page }) => {
    await page.goto('/login');
    
    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="password"]', 'password123');
    await page.click('button[type="submit"]');
    
    // Wait for redirect
    await expect(page).toHaveURL('/dashboard');
    
    // Verify user is logged in
    await expect(page.locator('[data-testid="user-menu"]')).toBeVisible();
  });

  test('should show error for invalid credentials', async ({ page }) => {
    await page.goto('/login');
    
    await page.fill('[name="email"]', 'wrong@example.com');
    await page.fill('[name="password"]', 'wrongpassword');
    await page.click('button[type="submit"]');
    
    await expect(page.locator('[role="alert"]')).toContainText('Invalid email or password');
    await expect(page).toHaveURL('/login');
  });

  test('should redirect to login for protected routes', async ({ page }) => {
    await page.goto('/dashboard');
    
    await expect(page).toHaveURL(/\/login\?callbackUrl=/);
  });

  test('should logout successfully', async ({ page }) => {
    // Login first
    await page.goto('/login');
    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="password"]', 'password123');
    await page.click('button[type="submit"]');
    
    await expect(page).toHaveURL('/dashboard');
    
    // Logout
    await page.click('[data-testid="user-menu"]');
    await page.click('[data-testid="logout-button"]');
    
    await expect(page).toHaveURL('/');
  });
});


// ==========================================
// e2e/posts.spec.ts
// ==========================================

import { test, expect } from '@playwright/test';

test.describe('Posts', () => {
  test.beforeEach(async ({ page }) => {
    // Login before each test
    await page.goto('/login');
    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="password"]', 'password123');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL('/dashboard');
  });

  test('should create a new post', async ({ page }) => {
    await page.goto('/dashboard/posts/new');
    
    await page.fill('[name="title"]', 'E2E Test Post');
    await page.fill('[name="content"]', 'This is content created by E2E test.');
    await page.selectOption('[name="categoryId"]', { label: 'Technology' });
    
    await page.click('button[type="submit"]');
    
    // Wait for success message or redirect
    await expect(page.locator('[role="alert"]')).toContainText('created');
  });

  test('should edit existing post', async ({ page }) => {
    // Go to posts list
    await page.goto('/dashboard/posts');
    
    // Click edit on first post
    await page.click('[data-testid="edit-post"]:first-child');
    
    // Update title
    await page.fill('[name="title"]', 'Updated Title');
    await page.click('button[type="submit"]');
    
    await expect(page.locator('[role="alert"]')).toContainText('updated');
  });

  test('should delete post with confirmation', async ({ page }) => {
    await page.goto('/dashboard/posts');
    
    // Click delete on first post
    await page.click('[data-testid="delete-post"]:first-child');
    
    // Confirm deletion
    await page.click('button:has-text("Confirm")');
    
    await expect(page.locator('[role="alert"]')).toContainText('deleted');
  });
});
```

---

## 8) Accessibility Testing

### Jest-Axe Integration
```typescript
// ==========================================
// ACCESSIBILITY TESTS
// ==========================================

import { render } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

describe('Accessibility', () => {
  it('LoginForm has no a11y violations', async () => {
    const { container } = render(<LoginForm onSubmit={jest.fn()} />);
    
    const results = await axe(container);
    
    expect(results).toHaveNoViolations();
  });

  it('Navigation has no a11y violations', async () => {
    const { container } = render(<Navigation />);
    
    const results = await axe(container);
    
    expect(results).toHaveNoViolations();
  });

  it('ProductCard has no a11y violations', async () => {
    const product = {
      id: '1',
      name: 'Test Product',
      price: 99.99,
      image: '/test.jpg',
    };
    
    const { container } = render(<ProductCard product={product} />);
    
    const results = await axe(container);
    
    expect(results).toHaveNoViolations();
  });
});


// ==========================================
// PLAYWRIGHT A11Y TESTS
// ==========================================

// e2e/accessibility.spec.ts
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test.describe('Accessibility', () => {
  test('homepage should have no a11y violations', async ({ page }) => {
    await page.goto('/');
    
    const accessibilityScanResults = await new AxeBuilder({ page }).analyze();
    
    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test('login page should have no a11y violations', async ({ page }) => {
    await page.goto('/login');
    
    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa', 'wcag21aa'])
      .analyze();
    
    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test('should be keyboard navigable', async ({ page }) => {
    await page.goto('/');
    
    // Tab through navigation
    await page.keyboard.press('Tab');
    await expect(page.locator(':focus')).toHaveAttribute('href', '/');
    
    await page.keyboard.press('Tab');
    await expect(page.locator(':focus')).toHaveAttribute('href', '/products');
    
    // Enter should activate link
    await page.keyboard.press('Enter');
    await expect(page).toHaveURL('/products');
  });
});
```

---

## 9) Test Utilities & Factories

### Test Helpers
```typescript
// ==========================================
// test/utils.tsx
// ==========================================

import { render, RenderOptions } from '@testing-library/react';
import { ReactElement } from 'react';
import { SessionProvider } from 'next-auth/react';

// Custom render with providers
interface CustomRenderOptions extends Omit<RenderOptions, 'wrapper'> {
  session?: any;
}

function AllProviders({ children, session }: { children: React.ReactNode; session?: any }) {
  return (
    <SessionProvider session={session}>
      {children}
    </SessionProvider>
  );
}

export function renderWithProviders(
  ui: ReactElement,
  options: CustomRenderOptions = {}
) {
  const { session, ...renderOptions } = options;
  
  return render(ui, {
    wrapper: ({ children }) => (
      <AllProviders session={session}>{children}</AllProviders>
    ),
    ...renderOptions,
  });
}

export * from '@testing-library/react';
export { renderWithProviders as render };


// ==========================================
// test/factories.ts
// ==========================================

import { faker } from '@faker-js/faker';

export function createUser(overrides = {}) {
  return {
    id: faker.string.uuid(),
    email: faker.internet.email(),
    name: faker.person.fullName(),
    image: faker.image.avatar(),
    role: 'USER',
    createdAt: faker.date.past(),
    ...overrides,
  };
}

export function createPost(overrides = {}) {
  return {
    id: faker.string.uuid(),
    title: faker.lorem.sentence(),
    slug: faker.helpers.slugify(faker.lorem.words(3)).toLowerCase(),
    content: faker.lorem.paragraphs(3),
    excerpt: faker.lorem.paragraph(),
    status: 'PUBLISHED',
    authorId: faker.string.uuid(),
    categoryId: faker.string.uuid(),
    publishedAt: faker.date.past(),
    createdAt: faker.date.past(),
    ...overrides,
  };
}

export function createSession(overrides = {}) {
  const user = createUser();
  return {
    user: {
      id: user.id,
      email: user.email,
      name: user.name,
      image: user.image,
      role: user.role,
    },
    expires: faker.date.future().toISOString(),
    ...overrides,
  };
}
```

---

## Best Practices Checklist

### Setup
- [ ] Jest configured for Next.js
- [ ] Playwright installed
- [ ] Mocks in place
- [ ] Test utilities ready

### Coverage
- [ ] Components tested
- [ ] Server Actions tested
- [ ] API routes tested
- [ ] 80%+ coverage

### Quality
- [ ] Accessible (jest-axe)
- [ ] E2E critical paths
- [ ] Edge cases covered
- [ ] CI/CD integration

### Performance
- [ ] Tests run fast
- [ ] Parallelization enabled
- [ ] Mocking external APIs
- [ ] Selective test runs

---

**References:**
- [Next.js Testing](https://nextjs.org/docs/app/building-your-application/testing)
- [Testing Library](https://testing-library.com/docs/react-testing-library/intro/)
- [Playwright](https://playwright.dev/docs/intro)
- [Jest-Axe](https://github.com/nickcolley/jest-axe)

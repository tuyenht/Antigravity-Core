# TypeScript Testing with Vitest/Jest Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **Vitest:** 2.x  
> **Jest:** 29.x  
> **TypeScript:** 5.x  
> **Priority:** P0 - Load for testing

---

You are an expert in TypeScript testing with Vitest and Jest.

## Core Principles

- Write type-safe tests
- Use proper test typing
- Mock with TypeScript support
- Follow testing best practices

---

## 1) Test Setup

### Vitest Configuration
```typescript
// ==========================================
// vitest.config.ts
// ==========================================

import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import tsconfigPaths from 'vite-tsconfig-paths';

export default defineConfig({
  plugins: [react(), tsconfigPaths()],
  test: {
    globals: true,
    environment: 'jsdom',
    include: ['**/*.{test,spec}.{ts,tsx}'],
    exclude: ['**/node_modules/**', '**/e2e/**'],
    setupFiles: ['./test/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'test/',
        '**/*.d.ts',
        '**/*.config.*',
        '**/types/**',
      ],
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 80,
        statements: 80,
      },
    },
    typecheck: {
      enabled: true,
      tsconfig: './tsconfig.json',
    },
  },
});
```

### Jest Configuration
```typescript
// ==========================================
// jest.config.ts
// ==========================================

import type { Config } from 'jest';

const config: Config = {
  preset: 'ts-jest',
  testEnvironment: 'jsdom',
  roots: ['<rootDir>/src'],
  modulePaths: ['<rootDir>/src'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@components/(.*)$': '<rootDir>/src/components/$1',
    '^@utils/(.*)$': '<rootDir>/src/utils/$1',
    '\\.(css|less|scss|sass)$': 'identity-obj-proxy',
  },
  setupFilesAfterEnv: ['<rootDir>/test/setup.ts'],
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.stories.tsx',
    '!src/**/index.ts',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
  transform: {
    '^.+\\.tsx?$': [
      'ts-jest',
      {
        tsconfig: 'tsconfig.json',
        diagnostics: {
          warnOnly: true,
        },
      },
    ],
  },
  testMatch: ['**/*.test.ts', '**/*.test.tsx', '**/*.spec.ts', '**/*.spec.tsx'],
};

export default config;
```

### Test Setup File
```typescript
// ==========================================
// test/setup.ts
// ==========================================

import '@testing-library/jest-dom/vitest';  // or '/jest' for Jest
import { cleanup } from '@testing-library/react';
import { afterEach, beforeAll, afterAll, vi } from 'vitest';
import { server } from './mocks/server';

// Extend Vitest matchers
declare module 'vitest' {
  interface Assertion<T = unknown> {
    toBeWithinRange(floor: number, ceiling: number): T;
    toHaveBeenCalledWithTyped<A extends unknown[]>(...args: A): T;
  }
}

// Setup MSW
beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => {
  cleanup();
  server.resetHandlers();
});
afterAll(() => server.close());

// Mock window.matchMedia
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: vi.fn().mockImplementation((query: string) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: vi.fn(),
    removeListener: vi.fn(),
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(),
  })),
});

// Mock IntersectionObserver
class MockIntersectionObserver implements IntersectionObserver {
  readonly root: Element | null = null;
  readonly rootMargin: string = '';
  readonly thresholds: ReadonlyArray<number> = [];

  observe = vi.fn();
  unobserve = vi.fn();
  disconnect = vi.fn();
  takeRecords = vi.fn().mockReturnValue([]);
}

Object.defineProperty(window, 'IntersectionObserver', {
  writable: true,
  value: MockIntersectionObserver,
});
```

---

## 2) Typed Mocking

### Mock Functions
```typescript
// ==========================================
// TYPED MOCK FUNCTIONS
// ==========================================

import { vi, type Mock, type MockedFunction } from 'vitest';
// For Jest: import { jest, type MockedFunction } from '@jest/globals';

// Basic typed mock
const mockFn = vi.fn<[string, number], boolean>();
mockFn.mockReturnValue(true);
mockFn('test', 42);  // OK
// mockFn(42, 'test');  // ❌ Compile error

// Mock with implementation
interface User {
  id: string;
  name: string;
  email: string;
}

const fetchUser = vi.fn<[string], Promise<User>>();
fetchUser.mockResolvedValue({
  id: '1',
  name: 'John',
  email: 'john@example.com',
});

// Mock function type inference
type FetchUserFn = (id: string) => Promise<User>;
const typedFetchUser: MockedFunction<FetchUserFn> = vi.fn();

typedFetchUser.mockImplementation(async (id) => ({
  id,
  name: 'Mock User',
  email: 'mock@example.com',
}));


// ==========================================
// MOCK IMPLEMENTATION PATTERNS
// ==========================================

// Conditional mock
const saveUser = vi.fn<[User], Promise<User>>();

saveUser.mockImplementation(async (user) => {
  if (user.email.includes('invalid')) {
    throw new Error('Invalid email');
  }
  return { ...user, id: 'generated-id' };
});

// Mock returning different values
const getItem = vi.fn<[string], string | null>();
getItem
  .mockReturnValueOnce('first')
  .mockReturnValueOnce('second')
  .mockReturnValue('default');

// Spy on existing function
const service = {
  process: (data: string): number => data.length,
};

const spy = vi.spyOn(service, 'process');
spy.mockReturnValue(100);

service.process('test');  // Returns 100
expect(spy).toHaveBeenCalledWith('test');
```

### Module Mocking
```typescript
// ==========================================
// TYPED MODULE MOCKING
// ==========================================

import { vi, describe, it, expect, beforeEach } from 'vitest';

// Mock entire module
vi.mock('@/services/api', () => ({
  fetchUsers: vi.fn(),
  createUser: vi.fn(),
  updateUser: vi.fn(),
}));

// Import after mock declaration
import { fetchUsers, createUser, updateUser } from '@/services/api';
import type { User } from '@/types';

// Type the mocked functions
const mockedFetchUsers = vi.mocked(fetchUsers);
const mockedCreateUser = vi.mocked(createUser);

describe('UserComponent', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should fetch users', async () => {
    const mockUsers: User[] = [
      { id: '1', name: 'John', email: 'john@example.com' },
      { id: '2', name: 'Jane', email: 'jane@example.com' },
    ];

    mockedFetchUsers.mockResolvedValue(mockUsers);

    const result = await fetchUsers();

    expect(result).toEqual(mockUsers);
    expect(mockedFetchUsers).toHaveBeenCalledTimes(1);
  });

  it('should create user with proper types', async () => {
    const newUser: Omit<User, 'id'> = {
      name: 'New User',
      email: 'new@example.com',
    };

    const createdUser: User = { ...newUser, id: 'new-id' };
    mockedCreateUser.mockResolvedValue(createdUser);

    const result = await createUser(newUser);

    expect(result).toHaveProperty('id');
    expect(mockedCreateUser).toHaveBeenCalledWith(newUser);
  });
});


// ==========================================
// PARTIAL MODULE MOCKING
// ==========================================

import { vi } from 'vitest';

// Mock only specific exports
vi.mock('@/utils/helpers', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@/utils/helpers')>();
  
  return {
    ...actual,  // Keep all original exports
    formatDate: vi.fn().mockReturnValue('2024-01-01'),  // Override specific function
  };
});

import { formatDate, parseDate } from '@/utils/helpers';

// formatDate is mocked, parseDate is real
```

### Class Mocking
```typescript
// ==========================================
// TYPED CLASS MOCKING
// ==========================================

import { vi, describe, it, expect, beforeEach } from 'vitest';

// Original class
class UserRepository {
  async findById(id: string): Promise<User | null> {
    // Database call
    return null;
  }

  async save(user: User): Promise<User> {
    // Database call
    return user;
  }

  async delete(id: string): Promise<void> {
    // Database call
  }
}

// Mock class
vi.mock('@/repositories/UserRepository');

import { UserRepository } from '@/repositories/UserRepository';

// Type helper for mocked class
type MockedUserRepository = {
  [K in keyof UserRepository]: UserRepository[K] extends (...args: infer A) => infer R
    ? Mock<A, R>
    : UserRepository[K];
};

describe('UserService', () => {
  let mockRepository: MockedUserRepository;

  beforeEach(() => {
    mockRepository = new UserRepository() as unknown as MockedUserRepository;
    vi.clearAllMocks();
  });

  it('should find user by id', async () => {
    const mockUser: User = { id: '1', name: 'John', email: 'john@example.com' };
    
    mockRepository.findById.mockResolvedValue(mockUser);

    const user = await mockRepository.findById('1');

    expect(user).toEqual(mockUser);
    expect(mockRepository.findById).toHaveBeenCalledWith('1');
  });
});


// ==========================================
// MANUAL CLASS MOCK
// ==========================================

// Create typed mock class
function createMockRepository(): MockedUserRepository {
  return {
    findById: vi.fn(),
    save: vi.fn(),
    delete: vi.fn(),
  } as unknown as MockedUserRepository;
}

describe('UserService with manual mock', () => {
  const mockRepo = createMockRepository();
  const service = new UserService(mockRepo as UserRepository);

  it('should process user', async () => {
    mockRepo.findById.mockResolvedValue({ id: '1', name: 'Test' });

    await service.processUser('1');

    expect(mockRepo.findById).toHaveBeenCalledWith('1');
  });
});
```

---

## 3) Component Testing

### React Testing Library with TypeScript
```typescript
// ==========================================
// TYPED COMPONENT TESTING
// ==========================================

import { describe, it, expect, vi } from 'vitest';
import { render, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import type { UserEvent } from '@testing-library/user-event';

import { UserProfile } from '@/components/UserProfile';
import type { User } from '@/types';

// Typed render helper
interface RenderOptions {
  user?: User;
  onUpdate?: (user: User) => void;
  onDelete?: () => void;
}

function renderUserProfile(options: RenderOptions = {}) {
  const defaultUser: User = {
    id: '1',
    name: 'John Doe',
    email: 'john@example.com',
  };

  const props = {
    user: options.user ?? defaultUser,
    onUpdate: options.onUpdate ?? vi.fn(),
    onDelete: options.onDelete ?? vi.fn(),
  };

  const utils = render(<UserProfile {...props} />);

  return {
    ...utils,
    props,
    user: userEvent.setup(),
  };
}

describe('UserProfile', () => {
  it('should display user information', () => {
    const mockUser: User = {
      id: '1',
      name: 'Jane Doe',
      email: 'jane@example.com',
    };

    renderUserProfile({ user: mockUser });

    expect(screen.getByText('Jane Doe')).toBeInTheDocument();
    expect(screen.getByText('jane@example.com')).toBeInTheDocument();
  });

  it('should call onUpdate with new data', async () => {
    const onUpdate = vi.fn<[User], void>();
    const { user } = renderUserProfile({ onUpdate });

    // Click edit button
    await user.click(screen.getByRole('button', { name: /edit/i }));

    // Change name
    const nameInput = screen.getByLabelText(/name/i);
    await user.clear(nameInput);
    await user.type(nameInput, 'Updated Name');

    // Save
    await user.click(screen.getByRole('button', { name: /save/i }));

    expect(onUpdate).toHaveBeenCalledWith(
      expect.objectContaining({
        name: 'Updated Name',
      })
    );
  });

  it('should show confirmation dialog on delete', async () => {
    const onDelete = vi.fn();
    const { user } = renderUserProfile({ onDelete });

    await user.click(screen.getByRole('button', { name: /delete/i }));

    // Check dialog appears
    const dialog = screen.getByRole('dialog');
    expect(dialog).toBeInTheDocument();

    // Confirm deletion
    const confirmButton = within(dialog).getByRole('button', { name: /confirm/i });
    await user.click(confirmButton);

    expect(onDelete).toHaveBeenCalledTimes(1);
  });
});


// ==========================================
// TYPED ASYNC TESTING
// ==========================================

import { waitFor, screen } from '@testing-library/react';

describe('AsyncComponent', () => {
  it('should load and display data', async () => {
    render(<DataFetcher url="/api/users" />);

    // Loading state
    expect(screen.getByRole('progressbar')).toBeInTheDocument();

    // Wait for data
    await waitFor(() => {
      expect(screen.queryByRole('progressbar')).not.toBeInTheDocument();
    });

    // Verify data displayed
    expect(screen.getByText('User 1')).toBeInTheDocument();
  });

  it('should handle errors', async () => {
    // Setup mock to fail
    server.use(
      http.get('/api/users', () => {
        return HttpResponse.json({ error: 'Server Error' }, { status: 500 });
      })
    );

    render(<DataFetcher url="/api/users" />);

    await waitFor(() => {
      expect(screen.getByRole('alert')).toHaveTextContent('Server Error');
    });
  });
});
```

### Custom Render with Providers
```typescript
// ==========================================
// TYPED CUSTOM RENDER
// ==========================================

import { render, type RenderOptions } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { BrowserRouter } from 'react-router-dom';
import type { ReactNode } from 'react';

interface CustomRenderOptions extends Omit<RenderOptions, 'wrapper'> {
  initialRoute?: string;
  queryClient?: QueryClient;
}

function createTestQueryClient(): QueryClient {
  return new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
        gcTime: Infinity,
      },
      mutations: {
        retry: false,
      },
    },
  });
}

function AllProviders({
  children,
  queryClient,
}: {
  children: ReactNode;
  queryClient: QueryClient;
}) {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>{children}</BrowserRouter>
    </QueryClientProvider>
  );
}

function customRender(
  ui: React.ReactElement,
  options: CustomRenderOptions = {}
) {
  const {
    initialRoute = '/',
    queryClient = createTestQueryClient(),
    ...renderOptions
  } = options;

  window.history.pushState({}, 'Test page', initialRoute);

  return {
    ...render(ui, {
      wrapper: ({ children }) => (
        <AllProviders queryClient={queryClient}>{children}</AllProviders>
      ),
      ...renderOptions,
    }),
    queryClient,
  };
}

export * from '@testing-library/react';
export { customRender as render };
```

---

## 4) Test Utilities

### Typed Test Factories
```typescript
// ==========================================
// TEST DATA FACTORIES
// ==========================================

import { vi } from 'vitest';

// Factory pattern for test data
function createUser(overrides: Partial<User> = {}): User {
  return {
    id: crypto.randomUUID(),
    name: 'Test User',
    email: 'test@example.com',
    role: 'user',
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  };
}

function createPost(overrides: Partial<Post> = {}): Post {
  return {
    id: crypto.randomUUID(),
    title: 'Test Post',
    content: 'Test content',
    authorId: crypto.randomUUID(),
    status: 'draft',
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  };
}

// Factory with relationships
function createUserWithPosts(
  userOverrides: Partial<User> = {},
  postCount: number = 3
): User & { posts: Post[] } {
  const user = createUser(userOverrides);
  const posts = Array.from({ length: postCount }, () =>
    createPost({ authorId: user.id })
  );

  return { ...user, posts };
}

// Builder pattern for complex objects
class UserBuilder {
  private user: User;

  constructor() {
    this.user = createUser();
  }

  withId(id: string): this {
    this.user.id = id;
    return this;
  }

  withName(name: string): this {
    this.user.name = name;
    return this;
  }

  withEmail(email: string): this {
    this.user.email = email;
    return this;
  }

  asAdmin(): this {
    this.user.role = 'admin';
    return this;
  }

  build(): User {
    return { ...this.user };
  }
}

// Usage
const adminUser = new UserBuilder()
  .withName('Admin')
  .withEmail('admin@example.com')
  .asAdmin()
  .build();


// ==========================================
// TYPED MOCK SERVICE
// ==========================================

interface MockUserService {
  getUser: Mock<[string], Promise<User>>;
  getUsers: Mock<[], Promise<User[]>>;
  createUser: Mock<[Omit<User, 'id'>], Promise<User>>;
  updateUser: Mock<[string, Partial<User>], Promise<User>>;
  deleteUser: Mock<[string], Promise<void>>;
}

function createMockUserService(
  overrides: Partial<MockUserService> = {}
): MockUserService {
  return {
    getUser: vi.fn().mockResolvedValue(createUser()),
    getUsers: vi.fn().mockResolvedValue([createUser()]),
    createUser: vi.fn().mockImplementation(async (data) => 
      createUser({ ...data, id: crypto.randomUUID() })
    ),
    updateUser: vi.fn().mockImplementation(async (id, data) =>
      createUser({ id, ...data })
    ),
    deleteUser: vi.fn().mockResolvedValue(undefined),
    ...overrides,
  };
}
```

### Custom Matchers
```typescript
// ==========================================
// TYPED CUSTOM MATCHERS
// ==========================================

import { expect } from 'vitest';
import type { ExpectationResult } from 'vitest';

// Extend matchers
expect.extend({
  toBeWithinRange(
    received: number,
    floor: number,
    ceiling: number
  ): ExpectationResult {
    const pass = received >= floor && received <= ceiling;

    return {
      pass,
      message: () =>
        pass
          ? `expected ${received} not to be within range ${floor} - ${ceiling}`
          : `expected ${received} to be within range ${floor} - ${ceiling}`,
    };
  },

  toBeValidEmail(received: string): ExpectationResult {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const pass = emailRegex.test(received);

    return {
      pass,
      message: () =>
        pass
          ? `expected ${received} not to be a valid email`
          : `expected ${received} to be a valid email`,
    };
  },

  toHaveBeenCalledWithUser(
    received: Mock,
    expectedUser: Partial<User>
  ): ExpectationResult {
    const calls = received.mock.calls;
    const pass = calls.some((call) => {
      const user = call[0] as User;
      return Object.entries(expectedUser).every(
        ([key, value]) => user[key as keyof User] === value
      );
    });

    return {
      pass,
      message: () =>
        pass
          ? `expected not to be called with user matching ${JSON.stringify(expectedUser)}`
          : `expected to be called with user matching ${JSON.stringify(expectedUser)}`,
    };
  },
});

// Augment types
declare module 'vitest' {
  interface Assertion<T = unknown> {
    toBeWithinRange(floor: number, ceiling: number): T;
    toBeValidEmail(): T;
    toHaveBeenCalledWithUser(user: Partial<User>): T;
  }
  interface AsymmetricMatchersContaining {
    toBeWithinRange(floor: number, ceiling: number): unknown;
    toBeValidEmail(): unknown;
  }
}

// Usage
describe('Custom Matchers', () => {
  it('should validate range', () => {
    expect(5).toBeWithinRange(1, 10);
    expect(100).not.toBeWithinRange(1, 10);
  });

  it('should validate email', () => {
    expect('test@example.com').toBeValidEmail();
    expect('invalid-email').not.toBeValidEmail();
  });

  it('should check user call', () => {
    const mockFn = vi.fn();
    mockFn({ id: '1', name: 'John', email: 'john@example.com' });

    expect(mockFn).toHaveBeenCalledWithUser({ name: 'John' });
  });
});
```

---

## 5) API Testing

### MSW (Mock Service Worker)
```typescript
// ==========================================
// TYPED MSW HANDLERS
// ==========================================

import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';
import type { User, CreateUserInput } from '@/types';

// Typed handlers
const handlers = [
  http.get<never, never, User[]>('/api/users', () => {
    return HttpResponse.json([
      { id: '1', name: 'John', email: 'john@example.com' },
      { id: '2', name: 'Jane', email: 'jane@example.com' },
    ]);
  }),

  http.get<{ id: string }, never, User>('/api/users/:id', ({ params }) => {
    const { id } = params;
    return HttpResponse.json({
      id,
      name: `User ${id}`,
      email: `user${id}@example.com`,
    });
  }),

  http.post<never, CreateUserInput, User>('/api/users', async ({ request }) => {
    const body = await request.json();
    
    const newUser: User = {
      id: crypto.randomUUID(),
      ...body,
    };

    return HttpResponse.json(newUser, { status: 201 });
  }),

  http.put<{ id: string }, Partial<User>, User>(
    '/api/users/:id',
    async ({ params, request }) => {
      const { id } = params;
      const updates = await request.json();

      return HttpResponse.json({
        id,
        name: updates.name ?? 'Original',
        email: updates.email ?? 'original@example.com',
      });
    }
  ),

  http.delete<{ id: string }>('/api/users/:id', () => {
    return new HttpResponse(null, { status: 204 });
  }),
];

export const server = setupServer(...handlers);


// ==========================================
// TESTING WITH MSW
// ==========================================

import { describe, it, expect, beforeEach } from 'vitest';
import { http, HttpResponse } from 'msw';
import { server } from '@/test/mocks/server';

describe('UserAPI', () => {
  it('should fetch users', async () => {
    const response = await fetch('/api/users');
    const users: User[] = await response.json();

    expect(users).toHaveLength(2);
    expect(users[0]).toHaveProperty('id');
    expect(users[0]).toHaveProperty('name');
  });

  it('should handle server error', async () => {
    // Override handler for this test
    server.use(
      http.get('/api/users', () => {
        return HttpResponse.json(
          { message: 'Internal Server Error' },
          { status: 500 }
        );
      })
    );

    const response = await fetch('/api/users');

    expect(response.status).toBe(500);
  });

  it('should create user with typed body', async () => {
    const newUser: CreateUserInput = {
      name: 'New User',
      email: 'new@example.com',
    };

    const response = await fetch('/api/users', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(newUser),
    });

    const created: User = await response.json();

    expect(response.status).toBe(201);
    expect(created).toHaveProperty('id');
    expect(created.name).toBe(newUser.name);
    expect(created.email).toBe(newUser.email);
  });
});
```

---

## 6) Async Testing

### Async Test Patterns
```typescript
// ==========================================
// TYPED ASYNC TESTING
// ==========================================

import { describe, it, expect, vi } from 'vitest';

describe('Async Operations', () => {
  // Promise resolution
  it('should resolve with typed value', async () => {
    const fetchData = async (): Promise<User> => ({
      id: '1',
      name: 'John',
      email: 'john@example.com',
    });

    const user = await fetchData();

    expect(user).toEqual({
      id: '1',
      name: 'John',
      email: 'john@example.com',
    });
  });

  // Promise rejection
  it('should handle rejection with typed error', async () => {
    interface ApiError {
      code: string;
      message: string;
    }

    const failingFetch = async (): Promise<User> => {
      throw { code: 'NOT_FOUND', message: 'User not found' } as ApiError;
    };

    await expect(failingFetch()).rejects.toMatchObject({
      code: 'NOT_FOUND',
    });
  });

  // waitFor patterns
  it('should wait for condition', async () => {
    let value: number = 0;

    setTimeout(() => {
      value = 42;
    }, 100);

    await vi.waitFor(() => {
      expect(value).toBe(42);
    });
  });

  // Fake timers
  it('should handle debounced function', async () => {
    vi.useFakeTimers();

    const callback = vi.fn();
    const debouncedFn = debounce(callback, 1000);

    debouncedFn('test');
    debouncedFn('test');
    debouncedFn('final');

    expect(callback).not.toHaveBeenCalled();

    await vi.advanceTimersByTimeAsync(1000);

    expect(callback).toHaveBeenCalledTimes(1);
    expect(callback).toHaveBeenCalledWith('final');

    vi.useRealTimers();
  });

  // Retry pattern
  it('should retry failing operation', async () => {
    let attempts = 0;

    const flakyOperation = vi.fn<[], Promise<string>>().mockImplementation(async () => {
      attempts++;
      if (attempts < 3) {
        throw new Error('Flaky');
      }
      return 'success';
    });

    // Retry helper
    async function retry<T>(
      fn: () => Promise<T>,
      maxAttempts: number = 3
    ): Promise<T> {
      let lastError: Error | undefined;

      for (let i = 0; i < maxAttempts; i++) {
        try {
          return await fn();
        } catch (e) {
          lastError = e as Error;
        }
      }

      throw lastError;
    }

    const result = await retry(flakyOperation);

    expect(result).toBe('success');
    expect(flakyOperation).toHaveBeenCalledTimes(3);
  });
});
```

---

## 7) Snapshot Testing

### Typed Snapshots
```typescript
// ==========================================
// TYPED SNAPSHOT TESTING
// ==========================================

import { describe, it, expect } from 'vitest';
import { render } from '@testing-library/react';

describe('Snapshot Testing', () => {
  it('should match component snapshot', () => {
    const { container } = render(
      <UserCard user={createUser({ name: 'John' })} />
    );

    expect(container).toMatchSnapshot();
  });

  it('should match inline snapshot', () => {
    const user = createUser({ name: 'Jane', email: 'jane@example.com' });

    expect(user).toMatchInlineSnapshot(`
      {
        "createdAt": Any<Date>,
        "email": "jane@example.com",
        "id": Any<String>,
        "name": "Jane",
        "role": "user",
        "updatedAt": Any<Date>,
      }
    `);
  });

  // Custom serializer
  it('should use custom serializer', () => {
    expect.addSnapshotSerializer({
      serialize(val: User): string {
        return `User(${val.name}, ${val.email})`;
      },
      test(val): val is User {
        return val && typeof val === 'object' && 'email' in val;
      },
    });

    const user = createUser({ name: 'Test', email: 'test@example.com' });

    expect(user).toMatchSnapshot();
    // Outputs: User(Test, test@example.com)
  });
});
```

---

## 8) E2E Testing (Playwright)

### Typed Playwright Tests
```typescript
// ==========================================
// TYPED PLAYWRIGHT TESTS
// ==========================================

import { test, expect, type Page, type Locator } from '@playwright/test';

// Page Object Pattern
class LoginPage {
  readonly page: Page;
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;
  readonly errorMessage: Locator;

  constructor(page: Page) {
    this.page = page;
    this.emailInput = page.getByLabel('Email');
    this.passwordInput = page.getByLabel('Password');
    this.submitButton = page.getByRole('button', { name: 'Sign In' });
    this.errorMessage = page.getByRole('alert');
  }

  async goto(): Promise<void> {
    await this.page.goto('/login');
  }

  async login(email: string, password: string): Promise<void> {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }

  async expectError(message: string): Promise<void> {
    await expect(this.errorMessage).toContainText(message);
  }
}

// Typed fixtures
interface TestFixtures {
  loginPage: LoginPage;
  authenticatedPage: Page;
}

const authTest = test.extend<TestFixtures>({
  loginPage: async ({ page }, use) => {
    const loginPage = new LoginPage(page);
    await use(loginPage);
  },

  authenticatedPage: async ({ page }, use) => {
    await page.goto('/login');
    await page.getByLabel('Email').fill('test@example.com');
    await page.getByLabel('Password').fill('password123');
    await page.getByRole('button', { name: 'Sign In' }).click();
    await page.waitForURL('/dashboard');
    await use(page);
  },
});

// Tests using fixtures
authTest.describe('Authentication', () => {
  authTest('should login with valid credentials', async ({ loginPage, page }) => {
    await loginPage.goto();
    await loginPage.login('user@example.com', 'password123');

    await expect(page).toHaveURL('/dashboard');
  });

  authTest('should show error for invalid credentials', async ({ loginPage }) => {
    await loginPage.goto();
    await loginPage.login('wrong@example.com', 'wrongpassword');

    await loginPage.expectError('Invalid credentials');
  });

  authTest('should access protected route when authenticated', async ({
    authenticatedPage,
  }) => {
    await authenticatedPage.goto('/settings');

    await expect(authenticatedPage.getByRole('heading')).toContainText('Settings');
  });
});
```

---

## Best Practices Checklist

### Test Structure
- [ ] Use typed factories
- [ ] Create custom renderers
- [ ] Implement test utilities

### Mocking
- [ ] Type all mocks
- [ ] Use vi.mocked()
- [ ] Clear mocks between tests

### Assertions
- [ ] Use typed matchers
- [ ] Create custom matchers
- [ ] Type assertion helpers

### Async
- [ ] Handle promises properly
- [ ] Use waitFor patterns
- [ ] Test error states

### Coverage
- [ ] Set thresholds
- [ ] Exclude irrelevant files
- [ ] Track trends

---

**References:**
- [Vitest](https://vitest.dev/)
- [Jest](https://jestjs.io/)
- [Testing Library](https://testing-library.com/)
- [Playwright](https://playwright.dev/)

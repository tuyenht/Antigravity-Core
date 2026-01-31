# TypeScript Strict Mode & Safety Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **TypeScript:** 5.x  
> **Priority:** P0 - Load for all TypeScript projects

---

You are an expert in TypeScript configuration and type safety.

## Core Type Safety Principles

- Enable 'strict': true in tsconfig.json
- Avoid 'any' type at all costs
- Use 'unknown' for uncertain types
- Handle null and undefined explicitly

---

## 1) TypeScript Configuration

### Complete tsconfig.json
```json
// ==========================================
// tsconfig.json - Strict Configuration
// ==========================================

{
  "$schema": "https://json.schemastore.org/tsconfig",
  "compilerOptions": {
    // ==========================================
    // STRICT MODE (All enabled by strict: true)
    // ==========================================
    "strict": true,
    
    // Individual strict flags (for reference)
    // "noImplicitAny": true,
    // "strictNullChecks": true,
    // "strictFunctionTypes": true,
    // "strictBindCallApply": true,
    // "strictPropertyInitialization": true,
    // "noImplicitThis": true,
    // "useUnknownInCatchVariables": true,
    // "alwaysStrict": true,
    
    // ==========================================
    // ADDITIONAL STRICTNESS
    // ==========================================
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitOverride": true,
    "noPropertyAccessFromIndexSignature": true,
    
    // ==========================================
    // MODULE RESOLUTION
    // ==========================================
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "verbatimModuleSyntax": true,
    
    // ==========================================
    // EMIT
    // ==========================================
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "noEmit": true,
    
    // ==========================================
    // INTEROP
    // ==========================================
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": true,
    
    // ==========================================
    // TYPE CHECKING
    // ==========================================
    "skipLibCheck": true,
    
    // ==========================================
    // PATHS
    // ==========================================
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src/**/*", "tests/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

### Project-Specific Configs
```json
// ==========================================
// Next.js tsconfig.json
// ==========================================

{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    
    // Next.js specific
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "noEmit": true,
    
    // Plugins
    "plugins": [{ "name": "next" }],
    
    // Paths
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}


// ==========================================
// Node.js/Backend tsconfig.json
// ==========================================

{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    
    // Node.js specific
    "target": "ES2022",
    "lib": ["ES2022"],
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "outDir": "./dist",
    "rootDir": "./src",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    
    // Interop
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

---

## 2) Avoiding 'any'

### Replace 'any' with Safe Alternatives
```typescript
// ==========================================
// ❌ BAD: Using 'any'
// ==========================================

function processData(data: any): any {
  return data.value;  // No type checking!
}

const result: any = fetchData();
result.unknownMethod();  // No error, but crashes at runtime!


// ==========================================
// ✅ GOOD: Using 'unknown'
// ==========================================

function processData(data: unknown): string {
  // Must narrow type before use
  if (typeof data === 'object' && data !== null && 'value' in data) {
    return String((data as { value: unknown }).value);
  }
  throw new Error('Invalid data format');
}


// ==========================================
// ✅ GOOD: Using generics
// ==========================================

function processData<T extends { value: string }>(data: T): string {
  return data.value;  // Type-safe!
}


// ==========================================
// ✅ GOOD: Using specific types
// ==========================================

interface ApiResponse<T> {
  data: T;
  status: number;
  message: string;
}

async function fetchUser(): Promise<ApiResponse<User>> {
  const response = await fetch('/api/user');
  return response.json() as Promise<ApiResponse<User>>;
}


// ==========================================
// WHEN 'any' IS (RARELY) ACCEPTABLE
// ==========================================

// 1. Third-party library without types (use @ts-expect-error with comment)
// @ts-expect-error - Legacy library without types, migration planned
const legacyResult = legacyLibrary.doSomething();

// 2. Migrating JavaScript gradually (use unknown instead)
// eslint-disable-next-line @typescript-eslint/no-explicit-any
type LegacyData = any;  // Mark for migration

// 3. Never in new code!
```

---

## 3) Type Guards

### Built-in Type Guards
```typescript
// ==========================================
// TYPEOF GUARD
// ==========================================

function processValue(value: string | number | null) {
  if (typeof value === 'string') {
    // value is string
    return value.toUpperCase();
  }
  
  if (typeof value === 'number') {
    // value is number
    return value.toFixed(2);
  }
  
  // value is null
  return 'N/A';
}


// ==========================================
// INSTANCEOF GUARD
// ==========================================

class Dog {
  bark() { return 'woof!'; }
}

class Cat {
  meow() { return 'meow!'; }
}

function makeSound(animal: Dog | Cat) {
  if (animal instanceof Dog) {
    return animal.bark();  // TypeScript knows it's Dog
  }
  return animal.meow();    // TypeScript knows it's Cat
}


// ==========================================
// 'IN' OPERATOR GUARD
// ==========================================

interface Fish {
  swim: () => void;
}

interface Bird {
  fly: () => void;
}

function move(animal: Fish | Bird) {
  if ('swim' in animal) {
    animal.swim();  // TypeScript knows it's Fish
  } else {
    animal.fly();   // TypeScript knows it's Bird
  }
}


// ==========================================
// TRUTHINESS GUARD
// ==========================================

function printName(name: string | null | undefined) {
  if (name) {
    console.log(name.toUpperCase());  // name is string
  } else {
    console.log('No name provided');
  }
}


// ==========================================
// EQUALITY GUARD
// ==========================================

function processInput(input: string | number | null) {
  if (input === null) {
    return 'null value';
  }
  
  if (input === '') {
    return 'empty string';
  }
  
  // input is string | number (not null, not '')
  return input;
}
```

### Custom Type Guards
```typescript
// ==========================================
// TYPE PREDICATE FUNCTIONS
// ==========================================

interface User {
  id: string;
  name: string;
  email: string;
}

interface Admin extends User {
  role: 'admin';
  permissions: string[];
}

// Custom type guard
function isAdmin(user: User): user is Admin {
  return 'role' in user && (user as Admin).role === 'admin';
}

function handleUser(user: User) {
  if (isAdmin(user)) {
    console.log(user.permissions);  // TypeScript knows it's Admin
  } else {
    console.log(user.name);         // Just a regular User
  }
}


// ==========================================
// VALIDATION TYPE GUARDS
// ==========================================

interface ApiError {
  code: string;
  message: string;
}

function isApiError(value: unknown): value is ApiError {
  return (
    typeof value === 'object' &&
    value !== null &&
    'code' in value &&
    'message' in value &&
    typeof (value as ApiError).code === 'string' &&
    typeof (value as ApiError).message === 'string'
  );
}

async function fetchData() {
  try {
    const response = await fetch('/api/data');
    const data: unknown = await response.json();
    
    if (isApiError(data)) {
      throw new Error(`API Error: ${data.code} - ${data.message}`);
    }
    
    return data;
  } catch (error) {
    // Handle error
  }
}


// ==========================================
// GENERIC TYPE GUARDS
// ==========================================

function isNotNull<T>(value: T | null | undefined): value is T {
  return value !== null && value !== undefined;
}

function isArray<T>(value: T | T[]): value is T[] {
  return Array.isArray(value);
}

function hasProperty<T extends object, K extends string>(
  obj: T,
  key: K
): obj is T & Record<K, unknown> {
  return key in obj;
}

// Usage
const items = [1, null, 2, undefined, 3].filter(isNotNull);
// items: number[]

const value: string | string[] = getInput();
if (isArray(value)) {
  value.map(v => v.toUpperCase());  // value is string[]
}
```

---

## 4) Discriminated Unions

### State Management
```typescript
// ==========================================
// ASYNC STATE DISCRIMINATED UNION
// ==========================================

interface IdleState {
  status: 'idle';
}

interface LoadingState {
  status: 'loading';
}

interface SuccessState<T> {
  status: 'success';
  data: T;
}

interface ErrorState {
  status: 'error';
  error: Error;
}

type AsyncState<T> = 
  | IdleState 
  | LoadingState 
  | SuccessState<T> 
  | ErrorState;

function handleState<T>(state: AsyncState<T>) {
  switch (state.status) {
    case 'idle':
      return 'Ready to start';
    
    case 'loading':
      return 'Loading...';
    
    case 'success':
      return `Data: ${JSON.stringify(state.data)}`;
    
    case 'error':
      return `Error: ${state.error.message}`;
  }
}


// ==========================================
// ACTION DISCRIMINATED UNIONS (Redux-style)
// ==========================================

interface AddTodoAction {
  type: 'ADD_TODO';
  payload: { text: string };
}

interface RemoveTodoAction {
  type: 'REMOVE_TODO';
  payload: { id: string };
}

interface ToggleTodoAction {
  type: 'TOGGLE_TODO';
  payload: { id: string };
}

type TodoAction = AddTodoAction | RemoveTodoAction | ToggleTodoAction;

function todoReducer(state: Todo[], action: TodoAction): Todo[] {
  switch (action.type) {
    case 'ADD_TODO':
      return [...state, { id: crypto.randomUUID(), text: action.payload.text, done: false }];
    
    case 'REMOVE_TODO':
      return state.filter(todo => todo.id !== action.payload.id);
    
    case 'TOGGLE_TODO':
      return state.map(todo =>
        todo.id === action.payload.id
          ? { ...todo, done: !todo.done }
          : todo
      );
  }
}


// ==========================================
// API RESPONSE DISCRIMINATED UNIONS
// ==========================================

interface SuccessResponse<T> {
  ok: true;
  data: T;
}

interface ErrorResponse {
  ok: false;
  error: {
    code: string;
    message: string;
  };
}

type ApiResponse<T> = SuccessResponse<T> | ErrorResponse;

async function fetchUser(id: string): Promise<ApiResponse<User>> {
  try {
    const res = await fetch(`/api/users/${id}`);
    
    if (!res.ok) {
      return {
        ok: false,
        error: { code: 'FETCH_ERROR', message: 'Failed to fetch user' },
      };
    }
    
    const data = await res.json();
    return { ok: true, data };
  } catch {
    return {
      ok: false,
      error: { code: 'NETWORK_ERROR', message: 'Network error' },
    };
  }
}

// Usage with type narrowing
async function displayUser(id: string) {
  const response = await fetchUser(id);
  
  if (response.ok) {
    console.log(response.data.name);  // TypeScript knows data exists
  } else {
    console.error(response.error.message);  // TypeScript knows error exists
  }
}
```

---

## 5) Result & Option Types

### Result Type (Rust-inspired)
```typescript
// ==========================================
// RESULT TYPE IMPLEMENTATION
// ==========================================

class Ok<T> {
  readonly ok = true as const;
  constructor(public readonly value: T) {}
  
  isOk(): this is Ok<T> { return true; }
  isErr(): this is Err<never> { return false; }
  
  map<U>(fn: (value: T) => U): Result<U, never> {
    return new Ok(fn(this.value));
  }
  
  mapErr<F>(_fn: (error: never) => F): Result<T, F> {
    return this as unknown as Result<T, F>;
  }
  
  unwrap(): T {
    return this.value;
  }
  
  unwrapOr(_defaultValue: T): T {
    return this.value;
  }
}

class Err<E> {
  readonly ok = false as const;
  constructor(public readonly error: E) {}
  
  isOk(): this is Ok<never> { return false; }
  isErr(): this is Err<E> { return true; }
  
  map<U>(_fn: (value: never) => U): Result<U, E> {
    return this as unknown as Result<U, E>;
  }
  
  mapErr<F>(fn: (error: E) => F): Result<never, F> {
    return new Err(fn(this.error));
  }
  
  unwrap(): never {
    throw new Error(`Called unwrap on Err: ${this.error}`);
  }
  
  unwrapOr<T>(defaultValue: T): T {
    return defaultValue;
  }
}

type Result<T, E> = Ok<T> | Err<E>;

// Factory functions
function ok<T>(value: T): Ok<T> {
  return new Ok(value);
}

function err<E>(error: E): Err<E> {
  return new Err(error);
}


// ==========================================
// USAGE
// ==========================================

interface ValidationError {
  field: string;
  message: string;
}

function validateEmail(email: string): Result<string, ValidationError> {
  if (!email.includes('@')) {
    return err({ field: 'email', message: 'Invalid email format' });
  }
  return ok(email.toLowerCase());
}

function validateAge(age: number): Result<number, ValidationError> {
  if (age < 0 || age > 150) {
    return err({ field: 'age', message: 'Age must be between 0 and 150' });
  }
  return ok(age);
}

// Chain operations
const emailResult = validateEmail('user@example.com')
  .map(email => email.trim())
  .map(email => email.toLowerCase());

if (emailResult.isOk()) {
  console.log('Valid email:', emailResult.value);
} else {
  console.error('Invalid:', emailResult.error.message);
}
```

### Option Type
```typescript
// ==========================================
// OPTION TYPE IMPLEMENTATION
// ==========================================

class Some<T> {
  readonly isSome = true as const;
  readonly isNone = false as const;
  
  constructor(public readonly value: T) {}
  
  map<U>(fn: (value: T) => U): Option<U> {
    return new Some(fn(this.value));
  }
  
  flatMap<U>(fn: (value: T) => Option<U>): Option<U> {
    return fn(this.value);
  }
  
  unwrap(): T {
    return this.value;
  }
  
  unwrapOr(_defaultValue: T): T {
    return this.value;
  }
  
  match<U>(handlers: { some: (value: T) => U; none: () => U }): U {
    return handlers.some(this.value);
  }
}

class None {
  readonly isSome = false as const;
  readonly isNone = true as const;
  
  map<U>(_fn: (value: never) => U): Option<U> {
    return none;
  }
  
  flatMap<U>(_fn: (value: never) => Option<U>): Option<U> {
    return none;
  }
  
  unwrap(): never {
    throw new Error('Called unwrap on None');
  }
  
  unwrapOr<T>(defaultValue: T): T {
    return defaultValue;
  }
  
  match<U>(handlers: { some: (value: never) => U; none: () => U }): U {
    return handlers.none();
  }
}

type Option<T> = Some<T> | None;

const none = new None();

function some<T>(value: T): Some<T> {
  return new Some(value);
}

function fromNullable<T>(value: T | null | undefined): Option<T> {
  return value === null || value === undefined ? none : some(value);
}


// ==========================================
// USAGE
// ==========================================

function findUser(id: string): Option<User> {
  const user = users.find(u => u.id === id);
  return fromNullable(user);
}

const userName = findUser('123')
  .map(user => user.name)
  .map(name => name.toUpperCase())
  .unwrapOr('Anonymous');

// Pattern matching
const greeting = findUser('123').match({
  some: (user) => `Hello, ${user.name}!`,
  none: () => 'Hello, stranger!',
});
```

---

## 6) Exhaustiveness Checking

### Never Type for Exhaustiveness
```typescript
// ==========================================
// EXHAUSTIVE SWITCH
// ==========================================

type Status = 'pending' | 'approved' | 'rejected';

function getStatusMessage(status: Status): string {
  switch (status) {
    case 'pending':
      return 'Awaiting review';
    case 'approved':
      return 'Request approved';
    case 'rejected':
      return 'Request rejected';
    default:
      // This ensures all cases are handled
      const _exhaustive: never = status;
      return _exhaustive;
  }
}


// ==========================================
// EXHAUSTIVE WITH HELPER FUNCTION
// ==========================================

function assertNever(value: never, message?: string): never {
  throw new Error(message || `Unexpected value: ${value}`);
}

type PaymentMethod = 'card' | 'bank' | 'crypto' | 'paypal';

function processPayment(method: PaymentMethod): void {
  switch (method) {
    case 'card':
      processCardPayment();
      break;
    case 'bank':
      processBankPayment();
      break;
    case 'crypto':
      processCryptoPayment();
      break;
    case 'paypal':
      processPayPalPayment();
      break;
    default:
      assertNever(method, `Unknown payment method: ${method}`);
  }
}


// ==========================================
// EXHAUSTIVE OBJECT MAPPING
// ==========================================

type UserRole = 'admin' | 'moderator' | 'user' | 'guest';

const rolePermissions: Record<UserRole, string[]> = {
  admin: ['read', 'write', 'delete', 'manage-users'],
  moderator: ['read', 'write', 'delete'],
  user: ['read', 'write'],
  guest: ['read'],
};

// TypeScript will error if you miss a role or add an unknown one
function getPermissions(role: UserRole): string[] {
  return rolePermissions[role];
}


// ==========================================
// EXHAUSTIVE DISCRIMINATED UNION
// ==========================================

type Shape = 
  | { kind: 'circle'; radius: number }
  | { kind: 'square'; side: number }
  | { kind: 'rectangle'; width: number; height: number };

function getArea(shape: Shape): number {
  switch (shape.kind) {
    case 'circle':
      return Math.PI * shape.radius ** 2;
    case 'square':
      return shape.side ** 2;
    case 'rectangle':
      return shape.width * shape.height;
    default:
      return assertNever(shape);
  }
}
```

---

## 7) Readonly & Immutability

### Readonly Patterns
```typescript
// ==========================================
// READONLY MODIFIERS
// ==========================================

interface User {
  readonly id: string;
  readonly email: string;
  name: string;  // Mutable
}

const user: User = {
  id: '123',
  email: 'user@example.com',
  name: 'John',
};

user.name = 'Jane';  // ✅ OK
// user.id = '456';  // ❌ Error: Cannot assign to 'id' because it is read-only


// ==========================================
// READONLY UTILITY TYPES
// ==========================================

// Make all properties readonly
type ReadonlyUser = Readonly<User>;

// Deep readonly
type DeepReadonly<T> = {
  readonly [P in keyof T]: T[P] extends object
    ? DeepReadonly<T[P]>
    : T[P];
};

interface Config {
  api: {
    url: string;
    timeout: number;
  };
  features: string[];
}

const config: DeepReadonly<Config> = {
  api: {
    url: 'https://api.example.com',
    timeout: 5000,
  },
  features: ['feature1', 'feature2'],
};

// config.api.url = 'new-url';  // ❌ Error


// ==========================================
// AS CONST
// ==========================================

// Without as const
const colors = ['red', 'green', 'blue'];
// Type: string[]

// With as const
const colorsConst = ['red', 'green', 'blue'] as const;
// Type: readonly ['red', 'green', 'blue']

const config = {
  endpoint: '/api',
  timeout: 5000,
} as const;
// Type: { readonly endpoint: '/api'; readonly timeout: 5000 }

// Create literal union from const array
type Color = typeof colorsConst[number];
// Type: 'red' | 'green' | 'blue'


// ==========================================
// READONLY ARRAYS AND TUPLES
// ==========================================

// Readonly array
function processItems(items: readonly string[]): void {
  // items.push('new');  // ❌ Error
  items.forEach(item => console.log(item));  // ✅ OK
}

// Readonly tuple
function getCoordinates(): readonly [number, number] {
  return [10, 20] as const;
}

const coords = getCoordinates();
// coords[0] = 5;  // ❌ Error
```

---

## 8) Null Safety

### Handling Null and Undefined
```typescript
// ==========================================
// OPTIONAL CHAINING
// ==========================================

interface User {
  name: string;
  address?: {
    street?: string;
    city?: string;
  };
}

function getCity(user: User): string | undefined {
  return user.address?.city;
}


// ==========================================
// NULLISH COALESCING
// ==========================================

function getDisplayName(name: string | null | undefined): string {
  return name ?? 'Anonymous';
}

// Different from || which treats '' and 0 as falsy
const count = 0;
const displayCount = count ?? 10;  // 0 (preserves 0)
const wrongCount = count || 10;    // 10 (treats 0 as falsy)


// ==========================================
// NON-NULL ASSERTION (USE SPARINGLY)
// ==========================================

// Only use when you're 100% certain
function processElement(element: HTMLElement | null) {
  // Bad: might crash
  // element!.click();
  
  // Good: guard first
  if (element) {
    element.click();
  }
  
  // Or throw explicit error
  if (!element) {
    throw new Error('Element is required');
  }
  element.click();
}


// ==========================================
// STRICT NULL CHECKS PATTERNS
// ==========================================

// 1. Default values
function greet(name: string | undefined = 'World'): string {
  return `Hello, ${name}!`;
}

// 2. Early return
function processUser(user: User | null): string {
  if (!user) {
    return 'No user';
  }
  return user.name.toUpperCase();
}

// 3. Type assertion after check
function assertDefined<T>(value: T | null | undefined, name: string): T {
  if (value === null || value === undefined) {
    throw new Error(`${name} is required`);
  }
  return value;
}

const user = assertDefined(getUser(), 'User');
console.log(user.name);  // TypeScript knows user is not null
```

---

## Best Practices Checklist

### Configuration
- [ ] `strict: true` enabled
- [ ] `noUncheckedIndexedAccess: true`
- [ ] `exactOptionalPropertyTypes: true`
- [ ] `noImplicitReturns: true`

### Type Safety
- [ ] No `any` types
- [ ] Type guards for unknown
- [ ] Discriminated unions for state
- [ ] Exhaustiveness checking

### Immutability
- [ ] `readonly` for immutable props
- [ ] `as const` for literals
- [ ] `Readonly<T>` for objects
- [ ] `readonly[]` for arrays

### Error Handling
- [ ] Result types for errors
- [ ] Option types for nullable
- [ ] Proper null checks
- [ ] No non-null assertions

---

**References:**
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/)
- [TypeScript Strict Mode](https://www.typescriptlang.org/tsconfig#strict)
- [Type Guards](https://www.typescriptlang.org/docs/handbook/2/narrowing.html)
- [Matt Pocock](https://www.totaltypescript.com/)

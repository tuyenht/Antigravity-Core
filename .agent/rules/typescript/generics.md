# Mastering TypeScript Generics

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **TypeScript:** 5.x  
> **Priority:** P0 - Essential TypeScript knowledge

---

You are an expert in TypeScript Generics.

## Core Generic Principles

- Use generics to create reusable components
- Constrain generics to ensure type safety
- Use default type parameters for better DX
- Avoid excessive generic nesting

---

## 1) Generic Basics

### Generic Functions
```typescript
// ==========================================
// BASIC GENERIC FUNCTION
// ==========================================

function identity<T>(value: T): T {
  return value;
}

// Type is inferred
const num = identity(42);         // number
const str = identity('hello');    // string

// Explicit type argument
const explicit = identity<string>('hello');


// ==========================================
// MULTIPLE TYPE PARAMETERS
// ==========================================

function pair<TFirst, TSecond>(first: TFirst, second: TSecond): [TFirst, TSecond] {
  return [first, second];
}

const result = pair('name', 42);  // [string, number]


// ==========================================
// GENERIC ARROW FUNCTIONS
// ==========================================

// Standard
const identity2 = <T>(value: T): T => value;

// In JSX files (need comma to distinguish from JSX)
const identity3 = <T,>(value: T): T => value;

// With constraint
const toString = <T extends { toString(): string }>(value: T): string => {
  return value.toString();
};


// ==========================================
// MEANINGFUL PARAMETER NAMES
// ==========================================

// ❌ Bad: Single letters are unclear
function fetchData<T, U>(url: T, options: U): void {}

// ✅ Good: Descriptive names
function fetchData<TResponse, TOptions>(
  url: string,
  options: TOptions
): Promise<TResponse> {
  // ...
}

// Common conventions:
// TData, TResult, TResponse - for data types
// TProps, TState - for React components
// TKey, TValue - for key-value structures
// TElement, TItem - for collections
// TInput, TOutput - for transformations
```

### Generic Interfaces & Types
```typescript
// ==========================================
// GENERIC INTERFACES
// ==========================================

interface Box<TValue> {
  value: TValue;
  getValue(): TValue;
  setValue(value: TValue): void;
}

interface ApiResponse<TData> {
  data: TData;
  status: number;
  message: string;
  timestamp: Date;
}

interface Repository<TEntity, TId = string> {
  findById(id: TId): Promise<TEntity | null>;
  findAll(): Promise<TEntity[]>;
  create(entity: TEntity): Promise<TEntity>;
  update(id: TId, entity: Partial<TEntity>): Promise<TEntity>;
  delete(id: TId): Promise<void>;
}


// ==========================================
// GENERIC TYPES
// ==========================================

type Nullable<T> = T | null;
type Optional<T> = T | undefined;
type Maybe<T> = T | null | undefined;

type AsyncResult<T, E = Error> = Promise<
  { ok: true; data: T } | { ok: false; error: E }
>;

type Callback<T> = (data: T) => void;
type Predicate<T> = (item: T) => boolean;
type Mapper<TInput, TOutput> = (input: TInput) => TOutput;


// ==========================================
// GENERIC CLASSES
// ==========================================

class Stack<TElement> {
  private items: TElement[] = [];
  
  push(item: TElement): void {
    this.items.push(item);
  }
  
  pop(): TElement | undefined {
    return this.items.pop();
  }
  
  peek(): TElement | undefined {
    return this.items[this.items.length - 1];
  }
  
  isEmpty(): boolean {
    return this.items.length === 0;
  }
  
  get size(): number {
    return this.items.length;
  }
}

const numberStack = new Stack<number>();
numberStack.push(1);
numberStack.push(2);
const top = numberStack.pop();  // number | undefined
```

---

## 2) Generic Constraints

### Basic Constraints
```typescript
// ==========================================
// EXTENDS CONSTRAINT
// ==========================================

// Must have length property
function logLength<T extends { length: number }>(item: T): T {
  console.log(item.length);
  return item;
}

logLength('hello');       // ✅ string has length
logLength([1, 2, 3]);     // ✅ array has length
// logLength(123);        // ❌ number doesn't have length


// ==========================================
// INTERFACE CONSTRAINT
// ==========================================

interface HasId {
  id: string;
}

function findById<T extends HasId>(items: T[], id: string): T | undefined {
  return items.find(item => item.id === id);
}

interface User extends HasId {
  name: string;
  email: string;
}

const users: User[] = [
  { id: '1', name: 'John', email: 'john@example.com' },
];

const user = findById(users, '1');  // User | undefined


// ==========================================
// MULTIPLE CONSTRAINTS
// ==========================================

interface HasName {
  name: string;
}

interface HasAge {
  age: number;
}

// Combine with intersection
function greet<T extends HasName & HasAge>(entity: T): string {
  return `Hello ${entity.name}, you are ${entity.age} years old`;
}


// ==========================================
// CONSTRUCTOR CONSTRAINT
// ==========================================

interface Constructor<T> {
  new (...args: any[]): T;
}

function createInstance<T>(ctor: Constructor<T>, ...args: any[]): T {
  return new ctor(...args);
}

class Person {
  constructor(public name: string) {}
}

const person = createInstance(Person, 'John');  // Person
```

### keyof Constraint
```typescript
// ==========================================
// KEYOF OPERATOR
// ==========================================

function getProperty<TObj, TKey extends keyof TObj>(
  obj: TObj,
  key: TKey
): TObj[TKey] {
  return obj[key];
}

const user = {
  name: 'John',
  age: 30,
  email: 'john@example.com',
};

const name = getProperty(user, 'name');   // string
const age = getProperty(user, 'age');     // number
// getProperty(user, 'invalid');          // ❌ Error


// ==========================================
// PICK MULTIPLE KEYS
// ==========================================

function pick<TObj, TKeys extends keyof TObj>(
  obj: TObj,
  keys: TKeys[]
): Pick<TObj, TKeys> {
  const result = {} as Pick<TObj, TKeys>;
  
  for (const key of keys) {
    result[key] = obj[key];
  }
  
  return result;
}

const picked = pick(user, ['name', 'email']);
// { name: string; email: string }


// ==========================================
// SET PROPERTY
// ==========================================

function setProperty<TObj, TKey extends keyof TObj>(
  obj: TObj,
  key: TKey,
  value: TObj[TKey]
): TObj {
  return { ...obj, [key]: value };
}

const updated = setProperty(user, 'age', 31);
// setProperty(user, 'age', 'thirty');  // ❌ Error: must be number
```

---

## 3) Default Type Parameters

### Defaults for Better DX
```typescript
// ==========================================
// DEFAULT TYPE PARAMETERS
// ==========================================

interface ApiResponse<TData = unknown, TError = Error> {
  data?: TData;
  error?: TError;
  status: number;
}

// No type args needed
const response1: ApiResponse = { status: 200 };

// Partial type args
const response2: ApiResponse<User> = { 
  data: { id: '1', name: 'John' },
  status: 200,
};

// Full type args
const response3: ApiResponse<User, ValidationError> = {
  error: { field: 'email', message: 'Invalid' },
  status: 400,
};


// ==========================================
// DEFAULT WITH CONSTRAINTS
// ==========================================

interface EventEmitter<TEvents extends Record<string, unknown> = Record<string, unknown>> {
  on<K extends keyof TEvents>(event: K, handler: (data: TEvents[K]) => void): void;
  emit<K extends keyof TEvents>(event: K, data: TEvents[K]): void;
}

interface MyEvents {
  login: { userId: string };
  logout: { userId: string };
  error: { message: string };
}

const emitter: EventEmitter<MyEvents> = createEmitter();
emitter.on('login', (data) => console.log(data.userId));


// ==========================================
// FACTORY WITH DEFAULTS
// ==========================================

function createStore<
  TState extends Record<string, unknown>,
  TActions extends Record<string, (...args: any[]) => void> = Record<string, never>
>(initialState: TState, actions?: TActions) {
  let state = initialState;
  
  return {
    getState: () => state,
    setState: (newState: Partial<TState>) => {
      state = { ...state, ...newState };
    },
    ...actions,
  };
}

const store = createStore({ count: 0 });
store.setState({ count: 1 });
```

---

## 4) Mapped Types

### Built-in Mapped Types
```typescript
// ==========================================
// BUILT-IN UTILITY TYPES
// ==========================================

interface User {
  id: string;
  name: string;
  email: string;
  age: number;
}

// Make all properties optional
type PartialUser = Partial<User>;
// { id?: string; name?: string; email?: string; age?: number }

// Make all properties required
type RequiredUser = Required<PartialUser>;

// Make all properties readonly
type ReadonlyUser = Readonly<User>;

// Pick specific properties
type UserPreview = Pick<User, 'id' | 'name'>;
// { id: string; name: string }

// Omit specific properties
type UserWithoutEmail = Omit<User, 'email'>;
// { id: string; name: string; age: number }

// Record type
type UserScores = Record<string, number>;
// { [key: string]: number }

// Extract/Exclude from unions
type Status = 'pending' | 'approved' | 'rejected';
type ActiveStatus = Extract<Status, 'pending' | 'approved'>;  // 'pending' | 'approved'
type InactiveStatus = Exclude<Status, 'pending'>;             // 'approved' | 'rejected'

// NonNullable
type MaybeString = string | null | undefined;
type DefiniteString = NonNullable<MaybeString>;  // string
```

### Custom Mapped Types
```typescript
// ==========================================
// CUSTOM MAPPED TYPES
// ==========================================

// Make all properties nullable
type Nullable<T> = {
  [K in keyof T]: T[K] | null;
};

// Make specific properties optional
type PartialBy<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>;

// Make specific properties required
type RequiredBy<T, K extends keyof T> = Omit<T, K> & Required<Pick<T, K>>;

// Deep partial
type DeepPartial<T> = {
  [K in keyof T]?: T[K] extends object ? DeepPartial<T[K]> : T[K];
};

// Deep readonly
type DeepReadonly<T> = {
  readonly [K in keyof T]: T[K] extends object ? DeepReadonly<T[K]> : T[K];
};

// Mutable (remove readonly)
type Mutable<T> = {
  -readonly [K in keyof T]: T[K];
};

// Required (remove optional)
type StrictRequired<T> = {
  [K in keyof T]-?: T[K];
};


// ==========================================
// KEY REMAPPING
// ==========================================

// Getters
type Getters<T> = {
  [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K];
};

interface Person {
  name: string;
  age: number;
}

type PersonGetters = Getters<Person>;
// { getName: () => string; getAge: () => number }

// Setters
type Setters<T> = {
  [K in keyof T as `set${Capitalize<string & K>}`]: (value: T[K]) => void;
};

// Event handlers
type EventHandlers<T> = {
  [K in keyof T as `on${Capitalize<string & K>}Change`]: (newValue: T[K]) => void;
};

// Filter by type
type StringProperties<T> = {
  [K in keyof T as T[K] extends string ? K : never]: T[K];
};

interface Mixed {
  id: number;
  name: string;
  email: string;
  age: number;
}

type StringProps = StringProperties<Mixed>;
// { name: string; email: string }
```

---

## 5) Conditional Types

### Basic Conditional Types
```typescript
// ==========================================
// BASIC CONDITIONAL
// ==========================================

type IsString<T> = T extends string ? true : false;

type A = IsString<string>;   // true
type B = IsString<number>;   // false


// ==========================================
// EXTRACT TYPES
// ==========================================

type ExtractArrayType<T> = T extends (infer U)[] ? U : never;

type Numbers = ExtractArrayType<number[]>;  // number
type Strings = ExtractArrayType<string[]>;  // string


// ==========================================
// FUNCTION TYPE EXTRACTION
// ==========================================

type ReturnType<T> = T extends (...args: any[]) => infer R ? R : never;

type Fn = () => { name: string };
type FnReturn = ReturnType<Fn>;  // { name: string }

type Parameters<T> = T extends (...args: infer P) => any ? P : never;

type Fn2 = (a: string, b: number) => void;
type Fn2Params = Parameters<Fn2>;  // [string, number]


// ==========================================
// PROMISE UNWRAPPING
// ==========================================

type Awaited<T> = T extends Promise<infer U> ? Awaited<U> : T;

type A = Awaited<Promise<string>>;              // string
type B = Awaited<Promise<Promise<number>>>;     // number


// ==========================================
// DISTRIBUTIVE CONDITIONAL TYPES
// ==========================================

type ToArray<T> = T extends any ? T[] : never;

type StrOrNum = string | number;
type StrOrNumArrays = ToArray<StrOrNum>;  // string[] | number[]

// Prevent distribution with tuple
type ToArrayNonDist<T> = [T] extends [any] ? T[] : never;
type SingleArray = ToArrayNonDist<StrOrNum>;  // (string | number)[]
```

### Advanced Conditional Types
```typescript
// ==========================================
// INFER KEYWORD PATTERNS
// ==========================================

// Extract first element of tuple
type First<T> = T extends [infer F, ...any[]] ? F : never;
type FirstEl = First<[1, 2, 3]>;  // 1

// Extract last element
type Last<T> = T extends [...any[], infer L] ? L : never;
type LastEl = Last<[1, 2, 3]>;  // 3

// Extract array element type
type ElementOf<T> = T extends readonly (infer E)[] ? E : never;

// Extract promise value
type UnwrapPromise<T> = T extends Promise<infer V> ? V : T;

// Extract object value types
type ValueOf<T> = T[keyof T];


// ==========================================
// RECURSIVE CONDITIONAL
// ==========================================

// Deep unwrap promises
type DeepAwaited<T> = T extends Promise<infer U>
  ? DeepAwaited<U>
  : T extends object
    ? { [K in keyof T]: DeepAwaited<T[K]> }
    : T;

// Flatten nested arrays
type Flatten<T> = T extends (infer U)[]
  ? Flatten<U>
  : T;

type Nested = number[][][];
type Flat = Flatten<Nested>;  // number


// ==========================================
// PATTERN MATCHING
// ==========================================

type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE';

type RouteHandler<T extends HttpMethod> =
  T extends 'GET' ? { query: unknown } :
  T extends 'POST' | 'PUT' ? { body: unknown } :
  T extends 'DELETE' ? { params: { id: string } } :
  never;

type GetHandler = RouteHandler<'GET'>;     // { query: unknown }
type PostHandler = RouteHandler<'POST'>;   // { body: unknown }
```

---

## 6) Utility Type Patterns

### Real-World Utilities
```typescript
// ==========================================
// API & DATA UTILITIES
// ==========================================

// Form state from entity
type FormState<T> = {
  values: T;
  errors: Partial<Record<keyof T, string>>;
  touched: Partial<Record<keyof T, boolean>>;
  isValid: boolean;
  isSubmitting: boolean;
};

// Create input type (omit auto-generated fields)
type CreateInput<T> = Omit<T, 'id' | 'createdAt' | 'updatedAt'>;

// Update input type (all optional except id)
type UpdateInput<T extends { id: string }> = 
  Pick<T, 'id'> & Partial<Omit<T, 'id'>>;

// API response wrapper
type ApiResponse<T> = 
  | { success: true; data: T }
  | { success: false; error: { code: string; message: string } };


// ==========================================
// REACT UTILITIES
// ==========================================

// Extract props from component
type PropsOf<TComponent> = TComponent extends React.ComponentType<infer P> 
  ? P 
  : never;

// Make specific props required
type WithRequired<T, K extends keyof T> = T & Required<Pick<T, K>>;

// Omit children
type PropsWithoutChildren<T> = Omit<T, 'children'>;

// Polymorphic component props
type PolymorphicProps<TElement extends React.ElementType, TProps = object> = 
  TProps & 
  Omit<React.ComponentPropsWithoutRef<TElement>, keyof TProps> & {
    as?: TElement;
  };


// ==========================================
// STATE MANAGEMENT
// ==========================================

// Action creator type
type ActionCreator<TPayload = void> = TPayload extends void
  ? () => { type: string }
  : (payload: TPayload) => { type: string; payload: TPayload };

// Reducer state type
type ReducerState<TReducer> = TReducer extends (
  state: infer S,
  action: any
) => any
  ? S
  : never;

// Action types from action creators
type ActionsOf<T extends Record<string, (...args: any[]) => any>> = ReturnType<T[keyof T]>;


// ==========================================
// OBJECT UTILITIES
// ==========================================

// Get optional keys
type OptionalKeys<T> = {
  [K in keyof T]-?: undefined extends T[K] ? K : never;
}[keyof T];

// Get required keys
type RequiredKeys<T> = {
  [K in keyof T]-?: undefined extends T[K] ? never : K;
}[keyof T];

// Pick by value type
type PickByType<T, TValue> = {
  [K in keyof T as T[K] extends TValue ? K : never]: T[K];
};

// Omit by value type
type OmitByType<T, TValue> = {
  [K in keyof T as T[K] extends TValue ? never : K]: T[K];
};

interface User {
  id: string;
  name: string;
  age: number;
  isActive: boolean;
}

type StringFields = PickByType<User, string>;
// { id: string; name: string }

type NonStringFields = OmitByType<User, string>;
// { age: number; isActive: boolean }
```

---

## 7) Generic Patterns

### Repository Pattern
```typescript
// ==========================================
// GENERIC REPOSITORY
// ==========================================

interface Entity {
  id: string;
  createdAt: Date;
  updatedAt: Date;
}

interface Repository<TEntity extends Entity> {
  findById(id: string): Promise<TEntity | null>;
  findMany(options?: FindManyOptions<TEntity>): Promise<TEntity[]>;
  create(data: CreateInput<TEntity>): Promise<TEntity>;
  update(id: string, data: UpdateInput<TEntity>): Promise<TEntity>;
  delete(id: string): Promise<void>;
}

interface FindManyOptions<T> {
  where?: Partial<T>;
  orderBy?: { [K in keyof T]?: 'asc' | 'desc' };
  take?: number;
  skip?: number;
}

type CreateInput<T extends Entity> = Omit<T, 'id' | 'createdAt' | 'updatedAt'>;
type UpdateInput<T extends Entity> = Partial<CreateInput<T>>;

// Implementation
class BaseRepository<TEntity extends Entity> implements Repository<TEntity> {
  constructor(private readonly model: any) {}
  
  async findById(id: string): Promise<TEntity | null> {
    return this.model.findUnique({ where: { id } });
  }
  
  async findMany(options?: FindManyOptions<TEntity>): Promise<TEntity[]> {
    return this.model.findMany(options);
  }
  
  async create(data: CreateInput<TEntity>): Promise<TEntity> {
    return this.model.create({ data });
  }
  
  async update(id: string, data: UpdateInput<TEntity>): Promise<TEntity> {
    return this.model.update({ where: { id }, data });
  }
  
  async delete(id: string): Promise<void> {
    await this.model.delete({ where: { id } });
  }
}
```

### Builder Pattern
```typescript
// ==========================================
// GENERIC BUILDER
// ==========================================

class QueryBuilder<TEntity, TSelected = TEntity> {
  private query: any = {};
  
  where<K extends keyof TEntity>(
    field: K,
    value: TEntity[K]
  ): QueryBuilder<TEntity, TSelected> {
    this.query.where = { ...this.query.where, [field]: value };
    return this;
  }
  
  select<K extends keyof TEntity>(
    ...fields: K[]
  ): QueryBuilder<TEntity, Pick<TEntity, K>> {
    this.query.select = fields.reduce(
      (acc, field) => ({ ...acc, [field]: true }),
      {}
    );
    return this as unknown as QueryBuilder<TEntity, Pick<TEntity, K>>;
  }
  
  orderBy<K extends keyof TEntity>(
    field: K,
    direction: 'asc' | 'desc' = 'asc'
  ): QueryBuilder<TEntity, TSelected> {
    this.query.orderBy = { [field]: direction };
    return this;
  }
  
  take(limit: number): QueryBuilder<TEntity, TSelected> {
    this.query.take = limit;
    return this;
  }
  
  build(): any {
    return this.query;
  }
}

// Usage
interface User {
  id: string;
  name: string;
  email: string;
  age: number;
}

const query = new QueryBuilder<User>()
  .where('age', 25)
  .select('id', 'name')
  .orderBy('name', 'asc')
  .take(10)
  .build();
```

---

## 8) Generic React Patterns

### Generic Components
```typescript
// ==========================================
// GENERIC LIST COMPONENT
// ==========================================

interface ListProps<TItem> {
  items: TItem[];
  renderItem: (item: TItem, index: number) => React.ReactNode;
  keyExtractor: (item: TItem) => string;
  emptyMessage?: string;
}

function List<TItem>({
  items,
  renderItem,
  keyExtractor,
  emptyMessage = 'No items',
}: ListProps<TItem>) {
  if (items.length === 0) {
    return <div>{emptyMessage}</div>;
  }
  
  return (
    <ul>
      {items.map((item, index) => (
        <li key={keyExtractor(item)}>
          {renderItem(item, index)}
        </li>
      ))}
    </ul>
  );
}

// Usage
<List
  items={users}
  keyExtractor={(user) => user.id}
  renderItem={(user) => <span>{user.name}</span>}
/>


// ==========================================
// GENERIC SELECT COMPONENT
// ==========================================

interface SelectProps<TValue> {
  value: TValue;
  onChange: (value: TValue) => void;
  options: { value: TValue; label: string }[];
  placeholder?: string;
}

function Select<TValue extends string | number>({
  value,
  onChange,
  options,
  placeholder,
}: SelectProps<TValue>) {
  return (
    <select
      value={value}
      onChange={(e) => onChange(e.target.value as TValue)}
    >
      {placeholder && <option value="">{placeholder}</option>}
      {options.map((option) => (
        <option key={String(option.value)} value={option.value}>
          {option.label}
        </option>
      ))}
    </select>
  );
}


// ==========================================
// GENERIC FORM HOOK
// ==========================================

function useForm<TValues extends Record<string, unknown>>(
  initialValues: TValues
) {
  const [values, setValues] = useState(initialValues);
  const [errors, setErrors] = useState<Partial<Record<keyof TValues, string>>>({});
  
  const setValue = <K extends keyof TValues>(
    field: K,
    value: TValues[K]
  ) => {
    setValues(prev => ({ ...prev, [field]: value }));
  };
  
  const setError = <K extends keyof TValues>(
    field: K,
    error: string
  ) => {
    setErrors(prev => ({ ...prev, [field]: error }));
  };
  
  const reset = () => {
    setValues(initialValues);
    setErrors({});
  };
  
  return { values, errors, setValue, setError, reset };
}

// Usage
const form = useForm({ name: '', email: '', age: 0 });
form.setValue('name', 'John');
form.setValue('age', 30);
```

---

## Best Practices Checklist

### Naming
- [ ] Meaningful names (TData, TProps)
- [ ] Consistent conventions
- [ ] Clear intent

### Constraints
- [ ] Minimal constraints
- [ ] Appropriate extends
- [ ] Default parameters

### Patterns
- [ ] Mapped types for transforms
- [ ] Conditional types for logic
- [ ] Utility types for common ops

### Avoid
- [ ] No excessive nesting
- [ ] No unnecessary generics
- [ ] No over-engineering

---

**References:**
- [TypeScript Generics](https://www.typescriptlang.org/docs/handbook/2/generics.html)
- [Utility Types](https://www.typescriptlang.org/docs/handbook/utility-types.html)
- [Conditional Types](https://www.typescriptlang.org/docs/handbook/2/conditional-types.html)
- [Total TypeScript](https://www.totaltypescript.com/)

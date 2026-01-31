# JavaScript ES2024+ Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Standards:** ECMAScript 2024, TC39 Stage 4 Proposals
> **Priority:** P0 - Always load for web projects

---

You are an expert in modern JavaScript ES2024+ features and best practices.

## Key Principles

- Use modern JavaScript syntax and features
- Leverage ES2024+ features for cleaner, more expressive code
- Master asynchronous JavaScript patterns
- Follow functional programming principles
- Write maintainable, performant, and type-safe code
- Stay updated with TC39 proposals

## Variables and Scope

### Declaration
- Use `const` by default for immutability
- Use `let` only when reassignment is needed
- Never use `var` - avoid hoisting issues
- Understand block scoping vs function scoping

### Destructuring
```javascript
// Object destructuring with defaults and renaming
const { name, age = 18, email: userEmail } = user;

// Array destructuring
const [first, second, ...rest] = items;

// Nested destructuring
const { address: { city, zip } } = user;

// Function parameter destructuring
function createUser({ name, email, role = 'user' }) {
  return { name, email, role };
}
```

## Arrow Functions

```javascript
// Implicit return for single expression
const double = x => x * 2;
const add = (a, b) => a + b;

// With object literal return
const createPoint = (x, y) => ({ x, y });

// Array methods with arrow functions
const evens = numbers.filter(n => n % 2 === 0);
const doubled = numbers.map(n => n * 2);
const sum = numbers.reduce((acc, n) => acc + n, 0);

// Know when to use regular functions
// - When you need `this` binding
// - When you need `arguments` object
// - For object methods
// - For constructors
```

## Template Literals

```javascript
// String interpolation
const greeting = `Hello, ${name}!`;

// Multi-line strings
const html = `
  <div class="card">
    <h2>${title}</h2>
    <p>${description}</p>
  </div>
`;

// Tagged templates
function highlight(strings, ...values) {
  return strings.reduce((result, str, i) => {
    const value = values[i] ? `<mark>${values[i]}</mark>` : '';
    return result + str + value;
  }, '');
}
const message = highlight`Search for ${term} in ${category}`;
```

## Spread and Rest

```javascript
// Spread for arrays
const combined = [...arr1, ...arr2];
const copy = [...original];

// Spread for objects (shallow clone)
const updated = { ...user, name: 'New Name' };
const merged = { ...defaults, ...options };

// Rest parameters
function sum(...numbers) {
  return numbers.reduce((a, b) => a + b, 0);
}

// Rest in destructuring
const { id, ...rest } = data;
const [first, ...others] = items;
```

## Async/Await

### Basic Usage
```javascript
// Async function
async function fetchUser(id) {
  try {
    const response = await fetch(`/api/users/${id}`);
    if (!response.ok) throw new Error('User not found');
    return await response.json();
  } catch (error) {
    console.error('Failed to fetch user:', error);
    throw error;
  }
}
```

### Parallel Execution
```javascript
// Promise.all - all must succeed
const [users, posts, comments] = await Promise.all([
  fetchUsers(),
  fetchPosts(),
  fetchComments()
]);

// Promise.allSettled - get all results regardless of success/failure
const results = await Promise.allSettled([
  fetchUser(1),
  fetchUser(2),
  fetchUser(999) // might fail
]);

results.forEach(result => {
  if (result.status === 'fulfilled') {
    console.log('Success:', result.value);
  } else {
    console.log('Failed:', result.reason);
  }
});

// Promise.any - first to succeed
const fastest = await Promise.any([
  fetchFromServer1(),
  fetchFromServer2(),
  fetchFromServer3()
]);

// Promise.race - first to settle (succeed or fail)
const result = await Promise.race([
  fetchData(),
  timeout(5000) // reject after 5 seconds
]);
```

### Promise.withResolvers (ES2024)
```javascript
// Cleaner deferred promise pattern
const { promise, resolve, reject } = Promise.withResolvers();

// Use in event-based code
button.addEventListener('click', () => resolve('clicked'));
setTimeout(() => reject(new Error('Timeout')), 5000);

const result = await promise;
```

### Top-level Await (ES2022)
```javascript
// In ES modules (no async wrapper needed)
const config = await fetch('/config.json').then(r => r.json());
const db = await connectDatabase();

export { config, db };
```

## Modules

```javascript
// Named exports
export const API_URL = '/api';
export function fetchData(url) { /* ... */ }
export class UserService { /* ... */ }

// Default export
export default class App { /* ... */ }

// Named imports
import { fetchData, API_URL } from './api.js';

// Default import
import App from './App.js';

// Namespace import
import * as utils from './utils.js';

// Dynamic imports (code splitting)
const module = await import('./heavy-module.js');
const { Component } = await import('./Component.js');

// Barrel exports (index.js)
export { UserService } from './UserService.js';
export { ProductService } from './ProductService.js';
export * from './utils.js';
```

## Classes

```javascript
class User {
  // Public field
  name = '';
  
  // Private field (ES2022)
  #password = '';
  
  // Static field
  static count = 0;
  
  // Static private field
  static #instances = new Map();
  
  // Static initialization block (ES2022)
  static {
    console.log('User class initialized');
  }
  
  constructor(name, password) {
    this.name = name;
    this.#password = password;
    User.count++;
    User.#instances.set(this.name, this);
  }
  
  // Getter
  get displayName() {
    return `@${this.name}`;
  }
  
  // Setter
  set displayName(value) {
    this.name = value.replace('@', '');
  }
  
  // Private method
  #hashPassword(password) {
    return `hashed_${password}`;
  }
  
  // Public method
  validatePassword(input) {
    return this.#hashPassword(input) === this.#password;
  }
  
  // Static method
  static getCount() {
    return User.count;
  }
}
```

## Array Methods

### Transformation
```javascript
// map - transform each element
const names = users.map(user => user.name);

// filter - keep matching elements
const adults = users.filter(user => user.age >= 18);

// reduce - accumulate to single value
const total = items.reduce((sum, item) => sum + item.price, 0);

// flatMap - map + flatten (ES2019)
const allTags = posts.flatMap(post => post.tags);
```

### Searching
```javascript
// find - first matching element
const admin = users.find(user => user.role === 'admin');

// findIndex - index of first match
const index = users.findIndex(user => user.id === 5);

// findLast / findLastIndex (ES2023)
const lastAdmin = users.findLast(user => user.role === 'admin');
const lastIndex = users.findLastIndex(user => user.active);
```

### Validation
```javascript
// some - at least one matches
const hasAdmin = users.some(user => user.role === 'admin');

// every - all match
const allActive = users.every(user => user.active);

// includes - contains value
const hasItem = items.includes('apple');
```

### Array.at() (ES2022)
```javascript
const arr = [1, 2, 3, 4, 5];

arr.at(0);   // 1 (first)
arr.at(-1);  // 5 (last)
arr.at(-2);  // 4 (second to last)

// Works on strings too
'hello'.at(-1); // 'o'
```

### Immutable Array Methods (ES2023)
```javascript
const original = [3, 1, 4, 1, 5];

// toSorted - returns new sorted array
const sorted = original.toSorted((a, b) => a - b);
// original is unchanged

// toReversed - returns new reversed array
const reversed = original.toReversed();

// toSpliced - returns new array with splice applied
const spliced = original.toSpliced(1, 2, 'a', 'b');

// with - returns new array with element replaced
const updated = original.with(0, 100);
// [100, 1, 4, 1, 5]
```

### Array Grouping (ES2024)
```javascript
const people = [
  { name: 'Alice', age: 25, city: 'NYC' },
  { name: 'Bob', age: 30, city: 'LA' },
  { name: 'Charlie', age: 25, city: 'NYC' }
];

// Object.groupBy - returns plain object
const byAge = Object.groupBy(people, person => person.age);
// { 25: [...], 30: [...] }

// Map.groupBy - returns Map
const byCity = Map.groupBy(people, person => person.city);
```

## Object Methods

```javascript
// Object.keys, values, entries
const keys = Object.keys(user);
const values = Object.values(user);
const entries = Object.entries(user);

// Object.fromEntries (ES2019)
const obj = Object.fromEntries([['a', 1], ['b', 2]]);

// Object.hasOwn (ES2022) - replaces hasOwnProperty
if (Object.hasOwn(obj, 'key')) {
  console.log(obj.key);
}

// Shorthand property syntax
const name = 'John';
const age = 30;
const user = { name, age }; // { name: 'John', age: 30 }

// Computed property names
const key = 'dynamicKey';
const obj = { [key]: 'value' };

// Object.freeze for immutability
const frozen = Object.freeze({ a: 1 });
```

## Optional Chaining and Nullish Coalescing

```javascript
// Optional chaining (?.)
const city = user?.address?.city;
const firstItem = arr?.[0];
const result = obj.method?.();

// Nullish coalescing (??)
const name = user.name ?? 'Anonymous';
const count = data.count ?? 0;

// Difference from ||
const value1 = 0 || 'default'; // 'default' (0 is falsy)
const value2 = 0 ?? 'default'; // 0 (only null/undefined trigger ??)

// Logical assignment operators (ES2021)
options.timeout ??= 3000;     // assign if null/undefined
user.name ||= 'Anonymous';    // assign if falsy
config.debug &&= validate();  // assign if truthy
```

## Error Handling

```javascript
// Error with cause (ES2022)
try {
  await fetchData();
} catch (error) {
  throw new Error('Failed to fetch data', { cause: error });
}

// Access the cause
catch (error) {
  console.error('Error:', error.message);
  console.error('Cause:', error.cause);
}

// Custom error classes
class ValidationError extends Error {
  constructor(message, field) {
    super(message);
    this.name = 'ValidationError';
    this.field = field;
  }
}
```

## Utility Functions

### structuredClone (ES2022)
```javascript
// Deep clone - handles circular refs, Date, Map, Set, etc.
const original = {
  date: new Date(),
  nested: { deep: { value: 1 } },
  set: new Set([1, 2, 3])
};

const clone = structuredClone(original);
// Deep copy - all nested objects are cloned
```

### Iterators and Generators
```javascript
// Generator function
function* range(start, end) {
  for (let i = start; i <= end; i++) {
    yield i;
  }
}

for (const num of range(1, 5)) {
  console.log(num); // 1, 2, 3, 4, 5
}

// Async generator
async function* fetchPages(urls) {
  for (const url of urls) {
    yield await fetch(url).then(r => r.json());
  }
}
```

## Best Practices

### Code Quality
- Use strict mode (`'use strict'` or ES modules)
- Avoid global variables
- Use meaningful, descriptive variable names
- Implement pure functions when possible
- Avoid mutating data - prefer immutable patterns
- Use const for values that won't be reassigned

### Error Handling
- Always handle promise rejections
- Use try/catch with async/await
- Preserve error causes with Error { cause }
- Create custom error classes for domain errors

### Performance
- Use appropriate data structures (Map, Set)
- Avoid unnecessary array iterations
- Use lazy evaluation with generators
- Profile before optimizing

### Tooling
- Use ESLint for code quality
- Use Prettier for formatting
- Write unit tests with Jest/Vitest
- Use TypeScript for type safety
- Document complex logic with JSDoc

---

**References:**
- [ECMAScript Specification](https://tc39.es/ecma262/)
- [TC39 Proposals](https://github.com/tc39/proposals)
- [MDN JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
- [JavaScript.info](https://javascript.info/)

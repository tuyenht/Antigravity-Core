# TypeScript Design Patterns Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **TypeScript:** 5.x  
> **Priority:** P0 - Load for architecture decisions

---

You are an expert in TypeScript design patterns and advanced programming techniques.

## Core Principles

- Use design patterns appropriately
- Leverage TypeScript's type system
- Follow SOLID principles
- Use patterns to solve common problems

---

## 1) Creational Patterns

### Singleton Pattern
```typescript
// ==========================================
// SINGLETON PATTERN
// Thread-safe, lazy initialization
// ==========================================

class DatabaseConnection {
  private static instance: DatabaseConnection | null = null;
  private readonly connectionString: string;
  private isConnected = false;

  private constructor(connectionString: string) {
    this.connectionString = connectionString;
  }

  static getInstance(connectionString?: string): DatabaseConnection {
    if (!DatabaseConnection.instance) {
      if (!connectionString) {
        throw new Error('Connection string required for first initialization');
      }
      DatabaseConnection.instance = new DatabaseConnection(connectionString);
    }
    return DatabaseConnection.instance;
  }

  async connect(): Promise<void> {
    if (this.isConnected) return;
    // Connection logic
    this.isConnected = true;
    console.log(`Connected to ${this.connectionString}`);
  }

  async disconnect(): Promise<void> {
    if (!this.isConnected) return;
    this.isConnected = false;
    console.log('Disconnected');
  }

  // For testing - reset singleton
  static resetInstance(): void {
    DatabaseConnection.instance = null;
  }
}

// Usage
const db1 = DatabaseConnection.getInstance('postgresql://localhost/db');
const db2 = DatabaseConnection.getInstance();
console.log(db1 === db2);  // true


// ==========================================
// MODERN SINGLETON (Module-based)
// ==========================================

// config.ts - Module singleton
interface AppConfig {
  apiUrl: string;
  debug: boolean;
  version: string;
}

const config: AppConfig = Object.freeze({
  apiUrl: process.env.API_URL ?? 'http://localhost:3000',
  debug: process.env.NODE_ENV !== 'production',
  version: '1.0.0',
});

export default config;
```

### Factory Pattern
```typescript
// ==========================================
// FACTORY PATTERN
// With discriminated unions and type guards
// ==========================================

// Product types with discriminant
type NotificationType = 'email' | 'sms' | 'push';

interface BaseNotification {
  type: NotificationType;
  message: string;
  recipient: string;
}

interface EmailNotification extends BaseNotification {
  type: 'email';
  subject: string;
  attachments?: string[];
}

interface SmsNotification extends BaseNotification {
  type: 'sms';
  phoneNumber: string;
}

interface PushNotification extends BaseNotification {
  type: 'push';
  deviceToken: string;
  title: string;
}

type Notification = EmailNotification | SmsNotification | PushNotification;

// Notification sender interface
interface NotificationSender<T extends Notification = Notification> {
  send(notification: T): Promise<void>;
}

// Concrete senders
class EmailSender implements NotificationSender<EmailNotification> {
  async send(notification: EmailNotification): Promise<void> {
    console.log(`Sending email to ${notification.recipient}: ${notification.subject}`);
  }
}

class SmsSender implements NotificationSender<SmsNotification> {
  async send(notification: SmsNotification): Promise<void> {
    console.log(`Sending SMS to ${notification.phoneNumber}: ${notification.message}`);
  }
}

class PushSender implements NotificationSender<PushNotification> {
  async send(notification: PushNotification): Promise<void> {
    console.log(`Sending push to ${notification.deviceToken}: ${notification.title}`);
  }
}

// Factory
class NotificationFactory {
  private readonly senders: Map<NotificationType, NotificationSender> = new Map([
    ['email', new EmailSender()],
    ['sms', new SmsSender()],
    ['push', new PushSender()],
  ]);

  getSender<T extends NotificationType>(type: T): NotificationSender {
    const sender = this.senders.get(type);
    if (!sender) {
      throw new Error(`Unknown notification type: ${type}`);
    }
    return sender;
  }

  async send(notification: Notification): Promise<void> {
    const sender = this.getSender(notification.type);
    await sender.send(notification);
  }
}

// Usage
const factory = new NotificationFactory();

const emailNotification: EmailNotification = {
  type: 'email',
  message: 'Hello',
  recipient: 'user@example.com',
  subject: 'Welcome!',
};

await factory.send(emailNotification);
```

### Builder Pattern
```typescript
// ==========================================
// BUILDER PATTERN
// Fluent API with type safety
// ==========================================

interface HttpRequest {
  url: string;
  method: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';
  headers: Record<string, string>;
  body?: unknown;
  timeout: number;
  retries: number;
}

// Builder with method chaining
class HttpRequestBuilder {
  private request: Partial<HttpRequest> = {
    method: 'GET',
    headers: {},
    timeout: 5000,
    retries: 0,
  };

  url(url: string): this {
    this.request.url = url;
    return this;
  }

  method(method: HttpRequest['method']): this {
    this.request.method = method;
    return this;
  }

  header(key: string, value: string): this {
    this.request.headers = {
      ...this.request.headers,
      [key]: value,
    };
    return this;
  }

  auth(token: string): this {
    return this.header('Authorization', `Bearer ${token}`);
  }

  contentType(type: string): this {
    return this.header('Content-Type', type);
  }

  json(): this {
    return this.contentType('application/json');
  }

  body(data: unknown): this {
    this.request.body = data;
    return this;
  }

  timeout(ms: number): this {
    this.request.timeout = ms;
    return this;
  }

  retries(count: number): this {
    this.request.retries = count;
    return this;
  }

  build(): HttpRequest {
    if (!this.request.url) {
      throw new Error('URL is required');
    }

    return {
      url: this.request.url,
      method: this.request.method ?? 'GET',
      headers: this.request.headers ?? {},
      body: this.request.body,
      timeout: this.request.timeout ?? 5000,
      retries: this.request.retries ?? 0,
    };
  }
}

// Usage
const request = new HttpRequestBuilder()
  .url('https://api.example.com/users')
  .method('POST')
  .json()
  .auth('my-token')
  .body({ name: 'John', email: 'john@example.com' })
  .timeout(10000)
  .retries(3)
  .build();


// ==========================================
// TYPE-SAFE BUILDER (Compile-time validation)
// ==========================================

type BuilderState = {
  hasUrl: boolean;
  hasMethod: boolean;
};

class TypeSafeBuilder<S extends BuilderState = { hasUrl: false; hasMethod: false }> {
  private config: Partial<HttpRequest> = {};

  url(url: string): TypeSafeBuilder<S & { hasUrl: true }> {
    this.config.url = url;
    return this as TypeSafeBuilder<S & { hasUrl: true }>;
  }

  method(method: HttpRequest['method']): TypeSafeBuilder<S & { hasMethod: true }> {
    this.config.method = method;
    return this as TypeSafeBuilder<S & { hasMethod: true }>;
  }

  // Only available when both url and method are set
  build(
    this: TypeSafeBuilder<{ hasUrl: true; hasMethod: true }>
  ): HttpRequest {
    return this.config as HttpRequest;
  }
}

// Compile-time error if url or method not set
const req = new TypeSafeBuilder()
  .url('https://api.example.com')
  .method('GET')
  .build();  // ✅ Works

// const invalid = new TypeSafeBuilder().build();  // ❌ Compile error
```

---

## 2) Structural Patterns

### Adapter Pattern
```typescript
// ==========================================
// ADAPTER PATTERN
// Integrate incompatible interfaces
// ==========================================

// Legacy payment system
interface LegacyPayment {
  processPayment(amount: number, currency: string): boolean;
  getTransactionId(): string;
}

class LegacyPaymentProcessor implements LegacyPayment {
  private transactionId = '';

  processPayment(amount: number, currency: string): boolean {
    this.transactionId = `TXN-${Date.now()}`;
    console.log(`Legacy: Processing ${currency} ${amount}`);
    return true;
  }

  getTransactionId(): string {
    return this.transactionId;
  }
}

// Modern payment interface
interface PaymentProvider {
  charge(params: {
    amount: number;
    currency: string;
    description?: string;
  }): Promise<PaymentResult>;
}

interface PaymentResult {
  success: boolean;
  transactionId: string;
  amount: number;
  currency: string;
}

// Adapter
class LegacyPaymentAdapter implements PaymentProvider {
  constructor(private readonly legacyProcessor: LegacyPayment) {}

  async charge(params: {
    amount: number;
    currency: string;
    description?: string;
  }): Promise<PaymentResult> {
    const success = this.legacyProcessor.processPayment(
      params.amount,
      params.currency
    );

    return {
      success,
      transactionId: this.legacyProcessor.getTransactionId(),
      amount: params.amount,
      currency: params.currency,
    };
  }
}

// Usage
const legacyProcessor = new LegacyPaymentProcessor();
const modernPayment: PaymentProvider = new LegacyPaymentAdapter(legacyProcessor);

const result = await modernPayment.charge({
  amount: 100,
  currency: 'USD',
  description: 'Order #123',
});
```

### Decorator Pattern
```typescript
// ==========================================
// DECORATOR PATTERN
// Add behavior without modifying original
// ==========================================

// Base interface
interface DataSource {
  read(): string;
  write(data: string): void;
}

// Concrete implementation
class FileDataSource implements DataSource {
  constructor(private filename: string) {}

  read(): string {
    return `Content of ${this.filename}`;
  }

  write(data: string): void {
    console.log(`Writing to ${this.filename}: ${data}`);
  }
}

// Base decorator
abstract class DataSourceDecorator implements DataSource {
  constructor(protected wrappee: DataSource) {}

  read(): string {
    return this.wrappee.read();
  }

  write(data: string): void {
    this.wrappee.write(data);
  }
}

// Encryption decorator
class EncryptionDecorator extends DataSourceDecorator {
  read(): string {
    const data = this.wrappee.read();
    return this.decrypt(data);
  }

  write(data: string): void {
    this.wrappee.write(this.encrypt(data));
  }

  private encrypt(data: string): string {
    return Buffer.from(data).toString('base64');
  }

  private decrypt(data: string): string {
    return Buffer.from(data, 'base64').toString('utf8');
  }
}

// Compression decorator
class CompressionDecorator extends DataSourceDecorator {
  read(): string {
    const data = this.wrappee.read();
    return this.decompress(data);
  }

  write(data: string): void {
    this.wrappee.write(this.compress(data));
  }

  private compress(data: string): string {
    return `compressed(${data})`;
  }

  private decompress(data: string): string {
    return data.replace('compressed(', '').replace(')', '');
  }
}

// Usage - Stack decorators
let source: DataSource = new FileDataSource('data.txt');
source = new EncryptionDecorator(source);
source = new CompressionDecorator(source);

source.write('Hello World');  // Compressed, then encrypted


// ==========================================
// METHOD DECORATORS (TypeScript 5.0+)
// ==========================================

function log<This, Args extends unknown[], Return>(
  target: (this: This, ...args: Args) => Return,
  context: ClassMethodDecoratorContext<This, (this: This, ...args: Args) => Return>
): (this: This, ...args: Args) => Return {
  const methodName = String(context.name);

  return function (this: This, ...args: Args): Return {
    console.log(`Calling ${methodName} with:`, args);
    const result = target.call(this, ...args);
    console.log(`${methodName} returned:`, result);
    return result;
  };
}

function memoize<This, Args extends unknown[], Return>(
  target: (this: This, ...args: Args) => Return,
  context: ClassMethodDecoratorContext<This, (this: This, ...args: Args) => Return>
): (this: This, ...args: Args) => Return {
  const cache = new Map<string, Return>();

  return function (this: This, ...args: Args): Return {
    const key = JSON.stringify(args);

    if (cache.has(key)) {
      return cache.get(key)!;
    }

    const result = target.call(this, ...args);
    cache.set(key, result);
    return result;
  };
}

class Calculator {
  @log
  @memoize
  fibonacci(n: number): number {
    if (n <= 1) return n;
    return this.fibonacci(n - 1) + this.fibonacci(n - 2);
  }
}
```

### Proxy Pattern
```typescript
// ==========================================
// PROXY PATTERN
// Control access to objects
// ==========================================

interface Image {
  display(): void;
  getInfo(): { width: number; height: number; size: number };
}

// Real subject
class RealImage implements Image {
  private data: Buffer | null = null;

  constructor(private readonly filename: string) {
    this.loadFromDisk();
  }

  private loadFromDisk(): void {
    console.log(`Loading image: ${this.filename}`);
    // Simulate expensive operation
    this.data = Buffer.from('image data');
  }

  display(): void {
    console.log(`Displaying: ${this.filename}`);
  }

  getInfo(): { width: number; height: number; size: number } {
    return { width: 1920, height: 1080, size: this.data?.length ?? 0 };
  }
}

// Virtual Proxy (lazy loading)
class ImageProxy implements Image {
  private realImage: RealImage | null = null;

  constructor(private readonly filename: string) {}

  private loadImage(): RealImage {
    if (!this.realImage) {
      this.realImage = new RealImage(this.filename);
    }
    return this.realImage;
  }

  display(): void {
    this.loadImage().display();
  }

  getInfo(): { width: number; height: number; size: number } {
    return this.loadImage().getInfo();
  }
}

// Protection Proxy (access control)
interface User {
  id: string;
  role: 'admin' | 'user';
}

class ProtectedImageProxy implements Image {
  constructor(
    private readonly realImage: Image,
    private readonly currentUser: User
  ) {}

  display(): void {
    this.realImage.display();
  }

  getInfo(): { width: number; height: number; size: number } {
    if (this.currentUser.role !== 'admin') {
      throw new Error('Access denied');
    }
    return this.realImage.getInfo();
  }
}


// ==========================================
// JAVASCRIPT PROXY
// ==========================================

interface ApiResponse<T> {
  data: T;
  loading: boolean;
  error: Error | null;
}

function createReactiveState<T extends object>(
  initial: T,
  onChange: (key: keyof T, value: T[keyof T]) => void
): T {
  return new Proxy(initial, {
    set(target, property: string, value): boolean {
      const key = property as keyof T;
      if (target[key] !== value) {
        target[key] = value;
        onChange(key, value);
      }
      return true;
    },
    get(target, property: string) {
      return target[property as keyof T];
    },
  });
}

// Usage
const state = createReactiveState(
  { count: 0, name: 'test' },
  (key, value) => console.log(`State changed: ${String(key)} = ${value}`)
);

state.count = 5;  // Logs: State changed: count = 5
```

---

## 3) Behavioral Patterns

### Observer Pattern
```typescript
// ==========================================
// OBSERVER PATTERN
// Pub/Sub with type safety
// ==========================================

type EventMap = {
  userCreated: { id: string; email: string };
  userUpdated: { id: string; changes: Partial<User> };
  userDeleted: { id: string };
  orderPlaced: { orderId: string; userId: string; total: number };
};

type EventHandler<T> = (data: T) => void;

class TypedEventEmitter<Events extends Record<string, unknown>> {
  private listeners = new Map<keyof Events, Set<EventHandler<unknown>>>();

  on<K extends keyof Events>(
    event: K,
    handler: EventHandler<Events[K]>
  ): () => void {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, new Set());
    }

    this.listeners.get(event)!.add(handler as EventHandler<unknown>);

    // Return unsubscribe function
    return () => {
      this.listeners.get(event)?.delete(handler as EventHandler<unknown>);
    };
  }

  once<K extends keyof Events>(
    event: K,
    handler: EventHandler<Events[K]>
  ): void {
    const wrapper = (data: Events[K]) => {
      handler(data);
      this.off(event, wrapper);
    };
    this.on(event, wrapper);
  }

  off<K extends keyof Events>(
    event: K,
    handler: EventHandler<Events[K]>
  ): void {
    this.listeners.get(event)?.delete(handler as EventHandler<unknown>);
  }

  emit<K extends keyof Events>(event: K, data: Events[K]): void {
    const handlers = this.listeners.get(event);
    if (handlers) {
      handlers.forEach((handler) => handler(data));
    }
  }

  removeAllListeners(event?: keyof Events): void {
    if (event) {
      this.listeners.delete(event);
    } else {
      this.listeners.clear();
    }
  }
}

// Usage
const events = new TypedEventEmitter<EventMap>();

const unsubscribe = events.on('userCreated', (data) => {
  console.log(`User created: ${data.email}`);  // Fully typed
});

events.emit('userCreated', { id: '1', email: 'test@example.com' });

unsubscribe();  // Clean up
```

### Strategy Pattern
```typescript
// ==========================================
// STRATEGY PATTERN
// Interchangeable algorithms
// ==========================================

// Strategy interface
interface PricingStrategy {
  calculatePrice(basePrice: number, quantity: number): number;
  getName(): string;
}

// Concrete strategies
class RegularPricing implements PricingStrategy {
  calculatePrice(basePrice: number, quantity: number): number {
    return basePrice * quantity;
  }

  getName(): string {
    return 'Regular';
  }
}

class PremiumPricing implements PricingStrategy {
  constructor(private readonly discountPercent: number = 10) {}

  calculatePrice(basePrice: number, quantity: number): number {
    const subtotal = basePrice * quantity;
    return subtotal * (1 - this.discountPercent / 100);
  }

  getName(): string {
    return `Premium (${this.discountPercent}% off)`;
  }
}

class BulkPricing implements PricingStrategy {
  constructor(
    private readonly bulkThreshold: number = 10,
    private readonly bulkDiscount: number = 20
  ) {}

  calculatePrice(basePrice: number, quantity: number): number {
    const subtotal = basePrice * quantity;

    if (quantity >= this.bulkThreshold) {
      return subtotal * (1 - this.bulkDiscount / 100);
    }

    return subtotal;
  }

  getName(): string {
    return `Bulk (${this.bulkDiscount}% off for ${this.bulkThreshold}+ items)`;
  }
}

// Context
class ShoppingCart {
  private items: Array<{ name: string; price: number; quantity: number }> = [];
  private pricingStrategy: PricingStrategy;

  constructor(strategy: PricingStrategy = new RegularPricing()) {
    this.pricingStrategy = strategy;
  }

  setStrategy(strategy: PricingStrategy): void {
    this.pricingStrategy = strategy;
  }

  addItem(name: string, price: number, quantity: number): void {
    this.items.push({ name, price, quantity });
  }

  calculateTotal(): number {
    return this.items.reduce((total, item) => {
      return total + this.pricingStrategy.calculatePrice(item.price, item.quantity);
    }, 0);
  }

  getBreakdown(): string {
    return `Strategy: ${this.pricingStrategy.getName()}\nTotal: $${this.calculateTotal().toFixed(2)}`;
  }
}

// Usage
const cart = new ShoppingCart();
cart.addItem('Widget', 10, 5);
cart.addItem('Gadget', 25, 3);

console.log(cart.getBreakdown());  // Regular pricing

cart.setStrategy(new PremiumPricing(15));
console.log(cart.getBreakdown());  // 15% discount

cart.setStrategy(new BulkPricing(5, 25));
console.log(cart.getBreakdown());  // 25% bulk discount
```

### Command Pattern
```typescript
// ==========================================
// COMMAND PATTERN
// Encapsulate actions with undo/redo
// ==========================================

interface Command<T = void> {
  execute(): T;
  undo(): void;
  describe(): string;
}

// Text editor example
class TextEditor {
  private content = '';

  getContent(): string {
    return this.content;
  }

  setContent(content: string): void {
    this.content = content;
  }

  insertAt(position: number, text: string): void {
    this.content =
      this.content.slice(0, position) +
      text +
      this.content.slice(position);
  }

  deleteRange(start: number, end: number): string {
    const deleted = this.content.slice(start, end);
    this.content = this.content.slice(0, start) + this.content.slice(end);
    return deleted;
  }
}

// Concrete commands
class InsertCommand implements Command {
  private previousContent = '';

  constructor(
    private readonly editor: TextEditor,
    private readonly position: number,
    private readonly text: string
  ) {}

  execute(): void {
    this.previousContent = this.editor.getContent();
    this.editor.insertAt(this.position, this.text);
  }

  undo(): void {
    this.editor.setContent(this.previousContent);
  }

  describe(): string {
    return `Insert "${this.text}" at position ${this.position}`;
  }
}

class DeleteCommand implements Command {
  private deletedText = '';

  constructor(
    private readonly editor: TextEditor,
    private readonly start: number,
    private readonly end: number
  ) {}

  execute(): void {
    this.deletedText = this.editor.deleteRange(this.start, this.end);
  }

  undo(): void {
    this.editor.insertAt(this.start, this.deletedText);
  }

  describe(): string {
    return `Delete from ${this.start} to ${this.end}`;
  }
}

// Command invoker with history
class CommandHistory {
  private undoStack: Command[] = [];
  private redoStack: Command[] = [];

  execute(command: Command): void {
    command.execute();
    this.undoStack.push(command);
    this.redoStack = [];  // Clear redo stack on new command
  }

  undo(): void {
    const command = this.undoStack.pop();
    if (command) {
      command.undo();
      this.redoStack.push(command);
    }
  }

  redo(): void {
    const command = this.redoStack.pop();
    if (command) {
      command.execute();
      this.undoStack.push(command);
    }
  }

  canUndo(): boolean {
    return this.undoStack.length > 0;
  }

  canRedo(): boolean {
    return this.redoStack.length > 0;
  }
}

// Usage
const editor = new TextEditor();
const history = new CommandHistory();

history.execute(new InsertCommand(editor, 0, 'Hello'));
history.execute(new InsertCommand(editor, 5, ' World'));
console.log(editor.getContent());  // "Hello World"

history.undo();
console.log(editor.getContent());  // "Hello"

history.redo();
console.log(editor.getContent());  // "Hello World"
```

---

## 4) Functional Patterns

### Result/Either Pattern
```typescript
// ==========================================
// RESULT PATTERN
// Type-safe error handling
// ==========================================

type Result<T, E = Error> =
  | { success: true; value: T }
  | { success: false; error: E };

// Helper functions
const Ok = <T>(value: T): Result<T, never> => ({
  success: true,
  value,
});

const Err = <E>(error: E): Result<never, E> => ({
  success: false,
  error,
});

// Result utilities
function map<T, U, E>(
  result: Result<T, E>,
  fn: (value: T) => U
): Result<U, E> {
  if (result.success) {
    return Ok(fn(result.value));
  }
  return result;
}

function flatMap<T, U, E>(
  result: Result<T, E>,
  fn: (value: T) => Result<U, E>
): Result<U, E> {
  if (result.success) {
    return fn(result.value);
  }
  return result;
}

function unwrapOr<T, E>(result: Result<T, E>, defaultValue: T): T {
  if (result.success) {
    return result.value;
  }
  return defaultValue;
}

// Usage
interface ValidationError {
  field: string;
  message: string;
}

function validateEmail(email: string): Result<string, ValidationError> {
  if (!email.includes('@')) {
    return Err({ field: 'email', message: 'Invalid email format' });
  }
  return Ok(email.toLowerCase());
}

function validatePassword(password: string): Result<string, ValidationError> {
  if (password.length < 8) {
    return Err({ field: 'password', message: 'Password too short' });
  }
  return Ok(password);
}

function createUser(
  email: string,
  password: string
): Result<{ email: string; password: string }, ValidationError> {
  const emailResult = validateEmail(email);
  if (!emailResult.success) {
    return emailResult;
  }

  const passwordResult = validatePassword(password);
  if (!passwordResult.success) {
    return passwordResult;
  }

  return Ok({
    email: emailResult.value,
    password: passwordResult.value,
  });
}


// ==========================================
// OPTION/MAYBE PATTERN
// ==========================================

type Option<T> = { type: 'some'; value: T } | { type: 'none' };

const Some = <T>(value: T): Option<T> => ({ type: 'some', value });
const None = <T>(): Option<T> => ({ type: 'none' });

function fromNullable<T>(value: T | null | undefined): Option<T> {
  return value != null ? Some(value) : None();
}

function mapOption<T, U>(option: Option<T>, fn: (value: T) => U): Option<U> {
  if (option.type === 'some') {
    return Some(fn(option.value));
  }
  return None();
}

function getOrElse<T>(option: Option<T>, defaultValue: T): T {
  if (option.type === 'some') {
    return option.value;
  }
  return defaultValue;
}

// Usage
function findUser(id: string): Option<User> {
  const user = users.find((u) => u.id === id);
  return fromNullable(user);
}

const userName = getOrElse(
  mapOption(findUser('123'), (u) => u.name),
  'Unknown'
);
```

### Pipe Pattern
```typescript
// ==========================================
// PIPE PATTERN
// Function composition
// ==========================================

// Type-safe pipe
function pipe<A>(value: A): A;
function pipe<A, B>(value: A, fn1: (a: A) => B): B;
function pipe<A, B, C>(value: A, fn1: (a: A) => B, fn2: (b: B) => C): C;
function pipe<A, B, C, D>(
  value: A,
  fn1: (a: A) => B,
  fn2: (b: B) => C,
  fn3: (c: C) => D
): D;
function pipe<A, B, C, D, E>(
  value: A,
  fn1: (a: A) => B,
  fn2: (b: B) => C,
  fn3: (c: C) => D,
  fn4: (d: D) => E
): E;
function pipe(value: unknown, ...fns: Array<(arg: unknown) => unknown>): unknown {
  return fns.reduce((acc, fn) => fn(acc), value);
}

// Async pipe
async function pipeAsync<A>(value: A): Promise<A>;
async function pipeAsync<A, B>(
  value: A,
  fn1: (a: A) => B | Promise<B>
): Promise<B>;
async function pipeAsync<A, B, C>(
  value: A,
  fn1: (a: A) => B | Promise<B>,
  fn2: (b: B) => C | Promise<C>
): Promise<C>;
async function pipeAsync(
  value: unknown,
  ...fns: Array<(arg: unknown) => unknown | Promise<unknown>>
): Promise<unknown> {
  let result = value;
  for (const fn of fns) {
    result = await fn(result);
  }
  return result;
}

// Usage
const processUser = (user: { name: string; age: number }) =>
  pipe(
    user,
    (u) => ({ ...u, name: u.name.trim() }),
    (u) => ({ ...u, name: u.name.toLowerCase() }),
    (u) => ({ ...u, isAdult: u.age >= 18 })
  );

const result = processUser({ name: '  John Doe  ', age: 25 });
// { name: 'john doe', age: 25, isAdult: true }
```

---

## 5) Advanced Type Patterns

### Branded Types
```typescript
// ==========================================
// BRANDED TYPES
// Nominal typing for type safety
// ==========================================

declare const __brand: unique symbol;

type Brand<T, B> = T & { [__brand]: B };

// User ID
type UserId = Brand<string, 'UserId'>;
type PostId = Brand<string, 'PostId'>;
type OrderId = Brand<string, 'OrderId'>;

// Constructors with validation
function createUserId(id: string): UserId {
  if (!id.startsWith('user_')) {
    throw new Error('Invalid user ID format');
  }
  return id as UserId;
}

function createPostId(id: string): PostId {
  if (!id.startsWith('post_')) {
    throw new Error('Invalid post ID format');
  }
  return id as PostId;
}

// Type-safe functions
function getUser(id: UserId): User {
  // ...
}

function getPost(id: PostId): Post {
  // ...
}

// Usage
const userId = createUserId('user_123');
const postId = createPostId('post_456');

getUser(userId);  // ✅ OK
// getUser(postId);  // ❌ Compile error: PostId is not assignable to UserId


// ==========================================
// VALIDATED TYPES
// ==========================================

type Email = Brand<string, 'Email'>;
type PositiveNumber = Brand<number, 'PositiveNumber'>;
type NonEmptyString = Brand<string, 'NonEmptyString'>;

function validateEmail(value: string): Email {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(value)) {
    throw new Error('Invalid email format');
  }
  return value as Email;
}

function validatePositive(value: number): PositiveNumber {
  if (value <= 0) {
    throw new Error('Number must be positive');
  }
  return value as PositiveNumber;
}

// Now functions can require validated types
function sendEmail(to: Email, subject: string): void {
  // We know `to` is a valid email
}

function createPrice(amount: PositiveNumber, currency: string): Price {
  // We know `amount` is positive
}
```

### State Machine Pattern
```typescript
// ==========================================
// TYPE-SAFE STATE MACHINE
// ==========================================

type OrderState = 'pending' | 'paid' | 'shipped' | 'delivered' | 'cancelled';

type OrderTransition = {
  pending: 'paid' | 'cancelled';
  paid: 'shipped' | 'cancelled';
  shipped: 'delivered';
  delivered: never;
  cancelled: never;
};

class Order<S extends OrderState = 'pending'> {
  constructor(
    public readonly id: string,
    public readonly state: S
  ) {}

  transition<T extends OrderTransition[S]>(
    newState: T
  ): Order<T> {
    console.log(`Transitioning from ${this.state} to ${newState}`);
    return new Order(this.id, newState);
  }
}

// Usage
const order = new Order('order-1', 'pending');

const paidOrder = order.transition('paid');      // Order<'paid'>
const shippedOrder = paidOrder.transition('shipped');  // Order<'shipped'>
const deliveredOrder = shippedOrder.transition('delivered');  // Order<'delivered'>

// deliveredOrder.transition('pending');  // ❌ Compile error: 'pending' not in never
```

---

## Best Practices Checklist

### Pattern Selection
- [ ] Match pattern to problem
- [ ] Don't over-engineer
- [ ] Consider maintenance

### Type Safety
- [ ] Use discriminated unions
- [ ] Brand primitive types
- [ ] Avoid `any`

### Implementation
- [ ] Follow SOLID
- [ ] Write tests
- [ ] Document patterns

---

**References:**
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/)
- [Refactoring Guru - Design Patterns](https://refactoring.guru/design-patterns)
- [Functional TypeScript](https://gcanti.github.io/fp-ts/)

# gRPC Development Expert

> **Version:** 1.0.0 | **Updated:** 2026-02-09
> **Standards:** gRPC v1.60+, Protocol Buffers v3, HTTP/2
> **Priority:** P1 - Load for gRPC/microservices projects

---

You are an expert in gRPC service development with TypeScript/Node.js and Protocol Buffers.

## Key Principles

- Contract-first API design with Protocol Buffers
- HTTP/2 multiplexing for high-performance transport
- Strongly typed service definitions
- Bidirectional streaming for real-time communication
- Deadline propagation and cancellation
- Language-agnostic service interoperability

---

## Project Structure

```
src/
├── proto/
│   ├── common/
│   │   ├── pagination.proto
│   │   ├── error.proto
│   │   └── timestamp.proto
│   ├── user/
│   │   └── v1/
│   │       └── user_service.proto
│   ├── order/
│   │   └── v1/
│   │       └── order_service.proto
│   └── buf.yaml                # Buf configuration
├── generated/                  # Auto-generated code
│   ├── user/v1/
│   └── order/v1/
├── server/
│   ├── index.ts               # Server bootstrap
│   ├── interceptors/          # Server interceptors
│   │   ├── auth.ts
│   │   ├── logging.ts
│   │   └── error-handler.ts
│   └── services/
│       ├── user-service.ts
│       └── order-service.ts
├── client/
│   ├── index.ts               # Client factory
│   └── interceptors/
│       ├── auth.ts
│       └── retry.ts
└── tests/
    ├── user-service.test.ts
    └── helpers/
        └── grpc-test-server.ts
```

---

## Protocol Buffer Schema Design

### Naming Conventions
```protobuf
// proto/user/v1/user_service.proto
syntax = "proto3";

package user.v1;

option go_package = "github.com/example/api/user/v1;userv1";

// Service naming: <Entity>Service
service UserService {
  // Method naming: <Verb><Entity>
  rpc GetUser(GetUserRequest) returns (GetUserResponse);
  rpc ListUsers(ListUsersRequest) returns (ListUsersResponse);
  rpc CreateUser(CreateUserRequest) returns (CreateUserResponse);
  rpc UpdateUser(UpdateUserRequest) returns (UpdateUserResponse);
  rpc DeleteUser(DeleteUserRequest) returns (DeleteUserResponse);
  
  // Streaming
  rpc WatchUsers(WatchUsersRequest) returns (stream WatchUsersResponse);
  rpc BatchCreateUsers(stream CreateUserRequest) returns (BatchCreateUsersResponse);
  rpc Chat(stream ChatMessage) returns (stream ChatMessage);
}

// Message naming: <MethodName>Request / <MethodName>Response
message GetUserRequest {
  string user_id = 1;  // snake_case field names
}

message GetUserResponse {
  User user = 1;
}

// Entity messages
message User {
  string id = 1;
  string name = 2;
  string email = 3;
  UserRole role = 4;
  google.protobuf.Timestamp created_at = 5;
  google.protobuf.Timestamp updated_at = 6;
}

// Enum naming: <Type>_<VALUE> with UNSPECIFIED as 0
enum UserRole {
  USER_ROLE_UNSPECIFIED = 0;
  USER_ROLE_USER = 1;
  USER_ROLE_ADMIN = 2;
  USER_ROLE_MODERATOR = 3;
}
```

### Pagination Pattern
```protobuf
// proto/common/pagination.proto
syntax = "proto3";

package common;

message PaginationRequest {
  int32 page_size = 1;       // Max items per page
  string page_token = 2;     // Cursor for next page
}

message PaginationResponse {
  string next_page_token = 1; // Empty if no more pages
  int32 total_count = 2;
}
```

```protobuf
// Usage in service
message ListUsersRequest {
  common.PaginationRequest pagination = 1;
  UserFilter filter = 2;
}

message ListUsersResponse {
  repeated User users = 1;
  common.PaginationResponse pagination = 2;
}

message UserFilter {
  optional string search = 1;
  optional UserRole role = 2;
  optional bool is_active = 3;
}
```

### Field Numbering Rules
```protobuf
message ExampleMessage {
  // 1-15: Single byte encoding (use for frequent fields)
  string id = 1;
  string name = 2;
  string email = 3;
  
  // 16-2047: Two byte encoding (less frequent fields)
  optional string avatar_url = 16;
  optional string bio = 17;
  
  // Reserved: prevent reuse of removed fields
  reserved 4, 5;
  reserved "old_field", "deprecated_field";
  
  // Oneof: mutually exclusive fields
  oneof notification_preference {
    EmailNotification email_notification = 20;
    SmsNotification sms_notification = 21;
    PushNotification push_notification = 22;
  }
}
```

### Schema Versioning
```protobuf
// ✅ Good: Version in package path
package user.v1;  // user/v1/user_service.proto
package user.v2;  // user/v2/user_service.proto

// ✅ Good: Backward-compatible changes
// - Add new fields (with new field numbers)
// - Add new enum values
// - Add new methods to services
// - Add new services

// ❌ Bad: Breaking changes
// - Remove or rename fields
// - Change field numbers
// - Change field types
// - Reorder enum values
// - Remove enum values
```

---

## Server Implementation

### Server Bootstrap
```typescript
// server/index.ts
import { createServer, ServerCredentials } from 'nice-grpc';
import { UserServiceDefinition } from '../generated/user/v1/user_service';
import { userServiceImpl } from './services/user-service';
import { authInterceptor } from './interceptors/auth';
import { loggingInterceptor } from './interceptors/logging';
import { errorHandlerInterceptor } from './interceptors/error-handler';

async function startServer() {
  const server = createServer()
    .use(loggingInterceptor)
    .use(errorHandlerInterceptor)
    .use(authInterceptor);

  server.add(UserServiceDefinition, userServiceImpl);

  const port = process.env.GRPC_PORT || '50051';
  await server.listen(`0.0.0.0:${port}`, ServerCredentials.createInsecure());
  
  console.log(`gRPC server listening on port ${port}`);
  
  // Graceful shutdown
  const shutdown = async () => {
    console.log('Shutting down gRPC server...');
    await server.shutdown();
    process.exit(0);
  };
  
  process.on('SIGINT', shutdown);
  process.on('SIGTERM', shutdown);
}

startServer().catch(console.error);
```

### Service Implementation
```typescript
// server/services/user-service.ts
import { ServiceImplementation, ServerError } from 'nice-grpc';
import {
  UserServiceDefinition,
  GetUserRequest,
  GetUserResponse,
  ListUsersRequest,
  ListUsersResponse,
  CreateUserRequest,
  CreateUserResponse,
} from '../../generated/user/v1/user_service';
import { Status } from 'nice-grpc-common';
import { prisma } from '../../db';

export const userServiceImpl: ServiceImplementation<
  typeof UserServiceDefinition
> = {
  async getUser(
    request: GetUserRequest,
    context
  ): Promise<GetUserResponse> {
    const user = await prisma.user.findUnique({
      where: { id: request.userId },
    });

    if (!user) {
      throw new ServerError(Status.NOT_FOUND, `User ${request.userId} not found`);
    }

    return {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: mapRole(user.role),
        createdAt: toTimestamp(user.createdAt),
        updatedAt: toTimestamp(user.updatedAt),
      },
    };
  },

  async listUsers(
    request: ListUsersRequest
  ): Promise<ListUsersResponse> {
    const pageSize = Math.min(request.pagination?.pageSize || 20, 100);
    const cursor = request.pagination?.pageToken
      ? decodeCursor(request.pagination.pageToken)
      : undefined;

    const [users, total] = await Promise.all([
      prisma.user.findMany({
        take: pageSize + 1,
        ...(cursor && { cursor: { id: cursor }, skip: 1 }),
        where: buildFilter(request.filter),
        orderBy: { createdAt: 'desc' },
      }),
      prisma.user.count({ where: buildFilter(request.filter) }),
    ]);

    const hasMore = users.length > pageSize;
    const items = hasMore ? users.slice(0, pageSize) : users;

    return {
      users: items.map(mapUser),
      pagination: {
        nextPageToken: hasMore
          ? encodeCursor(items[items.length - 1].id)
          : '',
        totalCount: total,
      },
    };
  },

  async createUser(
    request: CreateUserRequest,
    context
  ): Promise<CreateUserResponse> {
    // Validate input
    if (!request.name?.trim()) {
      throw new ServerError(
        Status.INVALID_ARGUMENT,
        'Name is required'
      );
    }

    if (!request.email?.trim()) {
      throw new ServerError(
        Status.INVALID_ARGUMENT,
        'Email is required'
      );
    }

    // Check uniqueness
    const existing = await prisma.user.findUnique({
      where: { email: request.email },
    });

    if (existing) {
      throw new ServerError(
        Status.ALREADY_EXISTS,
        `User with email ${request.email} already exists`
      );
    }

    const user = await prisma.user.create({
      data: {
        name: request.name,
        email: request.email,
        role: 'USER',
      },
    });

    return { user: mapUser(user) };
  },

  // Server streaming
  async *watchUsers(request, context) {
    // Yield initial state
    const users = await prisma.user.findMany({ take: 50 });
    for (const user of users) {
      yield { user: mapUser(user), eventType: 'INITIAL' };
    }

    // Watch for changes (simplified — use DB triggers or pub/sub)
    const interval = setInterval(async () => {
      // Poll for changes (in production, use change streams)
    }, 1000);

    // Cleanup on client disconnect
    context.signal.addEventListener('abort', () => {
      clearInterval(interval);
    });
  },
};
```

---

## Error Handling

### gRPC Status Codes
```typescript
// server/interceptors/error-handler.ts
import { ServerError, Status, ServerMiddleware } from 'nice-grpc';

// gRPC Status Code Reference
// ─────────────────────────────────────────────────
// OK (0)              - Success
// CANCELLED (1)       - Client cancelled
// UNKNOWN (2)         - Unknown error
// INVALID_ARGUMENT (3)- Bad request / validation error
// DEADLINE_EXCEEDED (4)- Timeout
// NOT_FOUND (5)       - Resource not found
// ALREADY_EXISTS (6)  - Duplicate / conflict
// PERMISSION_DENIED (7)- Authorization failure
// RESOURCE_EXHAUSTED (8)- Rate limit / quota
// FAILED_PRECONDITION (9)- State conflict
// ABORTED (10)        - Transaction conflict
// OUT_OF_RANGE (11)   - Pagination out of range
// UNIMPLEMENTED (12)  - Method not implemented
// INTERNAL (13)       - Internal server error
// UNAVAILABLE (14)    - Transient error, retry
// DATA_LOSS (15)      - Unrecoverable data loss
// UNAUTHENTICATED (16)- Missing/invalid credentials

// HTTP → gRPC status mapping (useful for gateway/proxy layers)
// 400 → INVALID_ARGUMENT    | 401 → UNAUTHENTICATED
// 403 → PERMISSION_DENIED   | 404 → NOT_FOUND
// 409 → ALREADY_EXISTS      | 429 → RESOURCE_EXHAUSTED
// 500 → INTERNAL            | 503 → UNAVAILABLE

export const errorHandlerInterceptor: ServerMiddleware = async function* (
  call,
  context
) {
  try {
    return yield* call.next(call.request, context);
  } catch (error) {
    if (error instanceof ServerError) {
      throw error; // Already a gRPC error
    }

    console.error('Unhandled error:', error);
    throw new ServerError(
      Status.INTERNAL,
      process.env.NODE_ENV === 'production'
        ? 'Internal server error'
        : (error as Error).message
    );
  }
};
```

### Rich Error Details
```protobuf
// proto/common/error.proto
syntax = "proto3";

package common;

import "google/protobuf/any.proto";

message ErrorInfo {
  string reason = 1;          // Machine-readable error reason
  string domain = 2;          // Service domain
  map<string, string> metadata = 3;
}

message BadRequest {
  repeated FieldViolation field_violations = 1;
  
  message FieldViolation {
    string field = 1;
    string description = 2;
  }
}

message RetryInfo {
  google.protobuf.Duration retry_delay = 1;
}
```

```typescript
// Usage: Validation error with field details
import { Metadata } from 'nice-grpc';

function throwValidationError(violations: FieldViolation[]) {
  const metadata = new Metadata();
  metadata.set('error-details', JSON.stringify({
    '@type': 'type.googleapis.com/common.BadRequest',
    fieldViolations: violations,
  }));

  throw new ServerError(
    Status.INVALID_ARGUMENT,
    'Validation failed',
    metadata
  );
}

// Example
throwValidationError([
  { field: 'email', description: 'Must be a valid email' },
  { field: 'name', description: 'Must be between 2 and 100 characters' },
]);
```

---

## Interceptors (Middleware)

### Authentication
```typescript
// server/interceptors/auth.ts
import { ServerMiddleware, ServerError, Status, Metadata } from 'nice-grpc';
import { verifyToken } from '../../utils/auth';

// Methods that don't require authentication
const PUBLIC_METHODS = new Set([
  '/user.v1.UserService/GetUser',
  '/auth.v1.AuthService/Login',
  '/auth.v1.AuthService/Register',
]);

export const authInterceptor: ServerMiddleware = async function* (
  call,
  context
) {
  const methodPath = context.path;

  if (PUBLIC_METHODS.has(methodPath)) {
    return yield* call.next(call.request, context);
  }

  const token = context.metadata.get('authorization');
  if (!token) {
    throw new ServerError(
      Status.UNAUTHENTICATED,
      'Missing authorization token'
    );
  }

  try {
    const bearerToken = token.replace('Bearer ', '');
    const payload = await verifyToken(bearerToken);
    
    // Pass user info via metadata
    const enrichedMetadata = new Metadata(context.metadata);
    enrichedMetadata.set('x-user-id', payload.userId);
    enrichedMetadata.set('x-user-role', payload.role);

    return yield* call.next(call.request, {
      ...context,
      metadata: enrichedMetadata,
    });
  } catch {
    throw new ServerError(
      Status.UNAUTHENTICATED,
      'Invalid or expired token'
    );
  }
};
```

### Logging
```typescript
// server/interceptors/logging.ts
import { ServerMiddleware } from 'nice-grpc';

export const loggingInterceptor: ServerMiddleware = async function* (
  call,
  context
) {
  const startTime = Date.now();
  const method = context.path;

  try {
    const result = yield* call.next(call.request, context);
    const duration = Date.now() - startTime;

    console.log(JSON.stringify({
      level: 'info',
      method,
      duration_ms: duration,
      status: 'OK',
    }));

    return result;
  } catch (error) {
    const duration = Date.now() - startTime;

    console.error(JSON.stringify({
      level: 'error',
      method,
      duration_ms: duration,
      status: (error as any).code || 'UNKNOWN',
      message: (error as any).message,
    }));

    throw error;
  }
};
```

### Deadline Propagation
```typescript
// server/interceptors/deadline.ts
import { ServerMiddleware, ServerError, Status } from 'nice-grpc';

export const deadlineInterceptor: ServerMiddleware = async function* (
  call,
  context
) {
  // Check if deadline already exceeded
  if (context.signal.aborted) {
    throw new ServerError(
      Status.DEADLINE_EXCEEDED,
      'Request deadline exceeded before processing'
    );
  }

  // Pass abort signal to downstream calls
  return yield* call.next(call.request, context);
};
```

---

## Client Implementation

### Client Factory
```typescript
// client/index.ts
import { createChannel, createClient, Metadata } from 'nice-grpc';
import { UserServiceDefinition } from '../generated/user/v1/user_service';
import { retryInterceptor } from './interceptors/retry';

export function createUserClient(address?: string) {
  const channel = createChannel(
    address || process.env.USER_SERVICE_URL || 'localhost:50051'
  );

  return createClient(UserServiceDefinition, channel, {
    '*': {
      // Default deadline: 5 seconds
      deadline: Date.now() + 5000,
    },
  });
}

// Usage
const userClient = createUserClient();

// Simple call
const { user } = await userClient.getUser({ userId: '123' });

// Call with metadata (auth token)
const metadata = new Metadata();
metadata.set('authorization', `Bearer ${token}`);

const { user: authedUser } = await userClient.getUser(
  { userId: '123' },
  { metadata }
);

// Call with custom deadline
const { users } = await userClient.listUsers(
  { pagination: { pageSize: 20, pageToken: '' } },
  { deadline: Date.now() + 10000 }
);
```

### Retry Interceptor
```typescript
// client/interceptors/retry.ts
import { ClientMiddleware, Status } from 'nice-grpc';

const RETRYABLE_CODES = new Set([
  Status.UNAVAILABLE,
  Status.DEADLINE_EXCEEDED,
  Status.RESOURCE_EXHAUSTED,
]);

const MAX_RETRIES = 3;
const BASE_DELAY_MS = 100;

export const retryInterceptor: ClientMiddleware = async function* (
  call,
  options
) {
  let lastError: Error | undefined;

  for (let attempt = 0; attempt <= MAX_RETRIES; attempt++) {
    try {
      return yield* call.next(call.request, options);
    } catch (error: any) {
      lastError = error;

      if (!RETRYABLE_CODES.has(error.code) || attempt === MAX_RETRIES) {
        throw error;
      }

      // Exponential backoff with jitter
      const delay = BASE_DELAY_MS * Math.pow(2, attempt) * (0.5 + Math.random());
      await new Promise((resolve) => setTimeout(resolve, delay));
    }
  }

  throw lastError;
};
```

---

## Streaming Patterns

### Server Streaming (Server → Client)
```typescript
// Server: Stream real-time updates
async *watchOrders(request, context) {
  const { userId } = request;

  // Send initial snapshot
  const orders = await prisma.order.findMany({
    where: { userId },
    orderBy: { createdAt: 'desc' },
    take: 50,
  });

  for (const order of orders) {
    yield { order: mapOrder(order), eventType: 'SNAPSHOT' };
  }

  // Watch for changes using pub/sub
  const subscription = pubsub.subscribe(`orders:${userId}`);

  try {
    for await (const event of subscription) {
      // Check if client disconnected
      if (context.signal.aborted) break;

      yield {
        order: mapOrder(event.data),
        eventType: event.type,
      };
    }
  } finally {
    subscription.unsubscribe();
  }
}

// Client: Consume stream
const stream = orderClient.watchOrders({ userId: '123' });

for await (const response of stream) {
  console.log(`${response.eventType}: Order ${response.order.id}`);
}
```

### Client Streaming (Client → Server)
```typescript
// Server: Receive batch of items
async batchCreateUsers(request, context) {
  const users = [];

  for await (const req of request) {
    // Validate each item
    if (!req.name || !req.email) {
      throw new ServerError(
        Status.INVALID_ARGUMENT,
        'Name and email are required for each user'
      );
    }
    users.push({ name: req.name, email: req.email });
  }

  // Bulk insert
  const created = await prisma.user.createMany({ data: users });

  return {
    createdCount: created.count,
    users: users.map(mapUser),
  };
}

// Client: Stream batch
async function batchCreate(users: CreateUserRequest[]) {
  async function* generateRequests() {
    for (const user of users) {
      yield user;
    }
  }

  const result = await userClient.batchCreateUsers(generateRequests());
  console.log(`Created ${result.createdCount} users`);
}
```

### Bidirectional Streaming
```typescript
// Server: Chat service
async *chat(request, context) {
  for await (const message of request) {
    // Process each message
    const response = await processMessage(message);

    // Echo enriched response
    yield {
      id: generateId(),
      text: response.text,
      senderId: message.senderId,
      timestamp: toTimestamp(new Date()),
    };
  }
}

// Client: Interactive chat
async function startChat() {
  const messages = new Subject<ChatMessage>();

  const responses = chatClient.chat(messages);

  // Send messages
  messages.next({ text: 'Hello!', senderId: 'user1' });
  messages.next({ text: 'How are you?', senderId: 'user1' });

  // Receive responses
  for await (const response of responses) {
    console.log(`Received: ${response.text}`);
  }

  messages.complete();
}
```

---

## Health Checking

```protobuf
// Standard health check protocol
// https://github.com/grpc/grpc/blob/master/doc/health-checking.md
syntax = "proto3";

package grpc.health.v1;

service Health {
  rpc Check(HealthCheckRequest) returns (HealthCheckResponse);
  rpc Watch(HealthCheckRequest) returns (stream HealthCheckResponse);
}

message HealthCheckRequest {
  string service = 1;
}

message HealthCheckResponse {
  ServingStatus status = 1;
  
  enum ServingStatus {
    UNKNOWN = 0;
    SERVING = 1;
    NOT_SERVING = 2;
    SERVICE_UNKNOWN = 3;
  }
}
```

```typescript
// Implementation
import { HealthDefinition } from '../generated/grpc/health/v1/health';

const healthImpl: ServiceImplementation<typeof HealthDefinition> = {
  async check(request) {
    const service = request.service;

    // Check specific service health
    if (service === 'user.v1.UserService') {
      const dbHealthy = await checkDatabase();
      return {
        status: dbHealthy ? 'SERVING' : 'NOT_SERVING',
      };
    }

    // Overall health
    return { status: 'SERVING' };
  },

  async *watch(request) {
    while (true) {
      // Call check directly (avoid `this` in object literals)
      const result = await healthImpl.check(request);
      yield { status: result.status };
      await new Promise((r) => setTimeout(r, 5000));
    }
  },
};

server.add(HealthDefinition, healthImpl);
```

---

## Load Balancing

```typescript
// Client-side load balancing
import { createChannel } from 'nice-grpc';

// Round-robin across multiple backends
const channel = createChannel(
  'dns:///user-service.default.svc.cluster.local:50051',
  undefined,
  {
    // Enable round-robin load balancing
    'grpc.service_config': JSON.stringify({
      loadBalancingConfig: [{ round_robin: {} }],
    }),
    // Connection pool
    'grpc.max_concurrent_streams': 100,
    // Keepalive
    'grpc.keepalive_time_ms': 30000,
    'grpc.keepalive_timeout_ms': 5000,
    'grpc.keepalive_permit_without_calls': 1,
  }
);
```

---

## Buf Configuration

```yaml
# buf.yaml - Lint and breaking change detection
version: v2
lint:
  use:
    - DEFAULT
  except:
    - PACKAGE_VERSION_SUFFIX
  disallow_comment_ignores: true
breaking:
  use:
    - FILE
```

```yaml
# buf.gen.yaml - Code generation
version: v2
plugins:
  - remote: buf.build/connectrpc/es
    out: src/generated
    opt:
      - target=ts
  - remote: buf.build/grpc/node
    out: src/generated
    opt:
      - target=ts
```

```bash
# Commands
buf lint                    # Lint proto files
buf breaking --against .git # Check breaking changes
buf generate                # Generate code
```

---

## Testing

### Unit Tests
```typescript
// tests/user-service.test.ts
import { createServer, createChannel, createClient } from 'nice-grpc';
import { UserServiceDefinition } from '../generated/user/v1/user_service';
import { userServiceImpl } from '../server/services/user-service';

describe('UserService', () => {
  let server: ReturnType<typeof createServer>;
  let client: ReturnType<typeof createClient>;

  beforeAll(async () => {
    server = createServer();
    server.add(UserServiceDefinition, userServiceImpl);
    const port = await server.listen('localhost:0');

    const channel = createChannel(`localhost:${port}`);
    client = createClient(UserServiceDefinition, channel);
  });

  afterAll(async () => {
    await server.shutdown();
  });

  test('GetUser returns user by ID', async () => {
    const response = await client.getUser({ userId: 'test-id-1' });
    
    expect(response.user).toBeDefined();
    expect(response.user?.id).toBe('test-id-1');
    expect(response.user?.name).toBeTruthy();
  });

  test('GetUser throws NOT_FOUND for missing user', async () => {
    await expect(
      client.getUser({ userId: 'nonexistent' })
    ).rejects.toMatchObject({
      code: Status.NOT_FOUND,
    });
  });

  test('CreateUser validates required fields', async () => {
    await expect(
      client.createUser({ name: '', email: '' })
    ).rejects.toMatchObject({
      code: Status.INVALID_ARGUMENT,
    });
  });

  test('ListUsers paginates correctly', async () => {
    const page1 = await client.listUsers({
      pagination: { pageSize: 2, pageToken: '' },
    });

    expect(page1.users.length).toBeLessThanOrEqual(2);
    
    if (page1.pagination?.nextPageToken) {
      const page2 = await client.listUsers({
        pagination: { pageSize: 2, pageToken: page1.pagination.nextPageToken },
      });
      expect(page2.users.length).toBeGreaterThan(0);
    }
  });
});
```

### Testing with grpcurl
```bash
# List services
grpcurl -plaintext localhost:50051 list

# Describe service
grpcurl -plaintext localhost:50051 describe user.v1.UserService

# Call method
grpcurl -plaintext \
  -d '{"user_id": "123"}' \
  localhost:50051 user.v1.UserService/GetUser

# Call with auth
grpcurl -plaintext \
  -H 'authorization: Bearer <token>' \
  -d '{"name": "John", "email": "john@example.com"}' \
  localhost:50051 user.v1.UserService/CreateUser

# Health check
grpcurl -plaintext localhost:50051 grpc.health.v1.Health/Check
```

---

## Security

### TLS Configuration
```typescript
// Production: Always use TLS
import { ServerCredentials, ChannelCredentials } from 'nice-grpc';
import { readFileSync } from 'fs';

// Server
const serverCredentials = ServerCredentials.createSsl(
  readFileSync('certs/ca.pem'),
  [
    {
      cert_chain: readFileSync('certs/server.pem'),
      private_key: readFileSync('certs/server-key.pem'),
    },
  ],
  true // Require client certificates (mTLS)
);

await server.listen('0.0.0.0:50051', serverCredentials);

// Client
const channelCredentials = ChannelCredentials.createSsl(
  readFileSync('certs/ca.pem'),
  readFileSync('certs/client-key.pem'),
  readFileSync('certs/client.pem')
);

const channel = createChannel('server:50051', channelCredentials);
```

### Rate Limiting
```typescript
// server/interceptors/rate-limit.ts
import { ServerMiddleware, ServerError, Status } from 'nice-grpc';

const rateLimits = new Map<string, { count: number; resetAt: number }>();

export const rateLimitInterceptor: ServerMiddleware = async function* (
  call,
  context
) {
  const clientId = context.metadata.get('x-client-id') || context.peer;
  const now = Date.now();
  const windowMs = 60_000; // 1 minute
  const maxRequests = 100;

  let entry = rateLimits.get(clientId);
  if (!entry || entry.resetAt < now) {
    entry = { count: 0, resetAt: now + windowMs };
    rateLimits.set(clientId, entry);
  }

  entry.count++;

  if (entry.count > maxRequests) {
    const retryAfter = Math.ceil((entry.resetAt - now) / 1000);
    throw new ServerError(
      Status.RESOURCE_EXHAUSTED,
      `Rate limit exceeded. Retry after ${retryAfter}s`
    );
  }

  return yield* call.next(call.request, context);
};
```

---

## Performance Best Practices

```yaml
Server:
  - Use connection pooling for database
  - Set appropriate max_concurrent_streams (default 100)
  - Enable keepalive (30s interval)
  - Use server reflection in development only
  - Compress large payloads (gzip)

Client:
  - Set deadlines on every call (never infinite)
  - Use client-side load balancing
  - Implement retry with exponential backoff
  - Reuse channels (don't create per-call)
  - Use streaming for bulk operations

Proto:
  - Use optional for nullable fields (proto3)
  - Avoid large messages (> 4MB default limit)
  - Use repeated + pagination for lists
  - Reserve removed field numbers
  - Run buf lint on CI
```

---

## gRPC Gateway (REST Transcoding)

```protobuf
// Expose gRPC as REST API
import "google/api/annotations.proto";

service UserService {
  rpc GetUser(GetUserRequest) returns (GetUserResponse) {
    option (google.api.http) = {
      get: "/v1/users/{user_id}"
    };
  }
  
  rpc CreateUser(CreateUserRequest) returns (CreateUserResponse) {
    option (google.api.http) = {
      post: "/v1/users"
      body: "*"
    };
  }
  
  rpc ListUsers(ListUsersRequest) returns (ListUsersResponse) {
    option (google.api.http) = {
      get: "/v1/users"
    };
  }
}
```

---

## Anti-Patterns

```yaml
❌ DON'T:
  - Use gRPC for browser-to-server (use gRPC-Web or Connect)
  - Send messages > 4MB (chunk or stream instead)
  - Use unary for real-time data (use streaming)
  - Ignore deadlines (always set them)
  - Mix business logic in interceptors
  - Return Status.OK with error in response body
  - Create channels per request (reuse them)
  - Skip health checking in production

✅ DO:
  - Use proto3 syntax (not proto2)
  - Version packages (user.v1, user.v2)
  - Run buf lint in CI/CD
  - Set deadlines on every RPC call
  - Implement server reflection for debugging
  - Use DataLoader pattern for N+1 prevention
  - Enable gzip compression for large payloads
  - Test with grpcurl for manual verification
```

---

**Version:** 1.0.0  
**Standards:** gRPC v1.60+, Protocol Buffers v3, HTTP/2  
**Created:** 2026-02-09

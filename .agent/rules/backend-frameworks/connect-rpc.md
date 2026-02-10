# Connect-RPC Development Expert

> **Version:** 1.0.0 | **Updated:** 2026-02-10
> **Standards:** Connect Protocol, gRPC, gRPC-Web, Buf v2
> **Priority:** P1 - Load for Connect/browser-gRPC projects

---

You are an expert in Connect-RPC, the browser-native RPC framework built on Protocol Buffers.

## Key Principles

- Protocol Buffers as the single source of truth
- Three wire protocols: Connect, gRPC, gRPC-Web (same server)
- Browser-native — works with fetch, no proxies needed
- Type-safe clients generated from proto schemas
- First-class streaming over HTTP/1.1 and HTTP/2
- Interceptor chain for cross-cutting concerns
- Seamless integration with TanStack Query

---

## Project Structure

```
src/
├── proto/
│   ├── user/v1/
│   │   └── user.proto
│   ├── order/v1/
│   │   └── order.proto
│   └── buf.yaml
├── gen/                          # Generated code (buf generate)
│   ├── user/v1/
│   │   ├── user_pb.ts           # Message types
│   │   └── user_connect.ts      # Service definitions
│   └── order/v1/
├── server/
│   ├── index.ts                 # Server bootstrap
│   ├── routes/
│   │   ├── user-service.ts
│   │   └── order-service.ts
│   └── interceptors/
│       ├── auth.ts
│       └── logging.ts
├── client/
│   ├── transport.ts             # Client transport config
│   └── hooks/                   # React hooks
│       ├── use-user.ts
│       └── use-order.ts
└── tests/
    └── user-service.test.ts
```

---

## Proto Schema & Code Generation

### Buf Configuration
```yaml
# buf.yaml
version: v2
modules:
  - path: proto
lint:
  use:
    - DEFAULT
breaking:
  use:
    - FILE
```

```yaml
# buf.gen.yaml
version: v2
plugins:
  # Generate TypeScript message types
  - remote: buf.build/bufbuild/es
    out: src/gen
    opt:
      - target=ts

  # Generate Connect service definitions
  - remote: buf.build/connectrpc/es
    out: src/gen
    opt:
      - target=ts
```

```bash
# Generate code from proto files
buf generate

# Lint proto files
buf lint

# Check for breaking changes
buf breaking --against .git#branch=main
```

### Proto Definition
```protobuf
// proto/user/v1/user.proto
syntax = "proto3";

package user.v1;

import "google/protobuf/timestamp.proto";

service UserService {
  rpc GetUser(GetUserRequest) returns (GetUserResponse);
  rpc ListUsers(ListUsersRequest) returns (ListUsersResponse);
  rpc CreateUser(CreateUserRequest) returns (CreateUserResponse);
  rpc UpdateUser(UpdateUserRequest) returns (UpdateUserResponse);
  rpc DeleteUser(DeleteUserRequest) returns (DeleteUserResponse);

  // Server streaming
  rpc WatchUsers(WatchUsersRequest) returns (stream UserEvent);
}

message GetUserRequest {
  string id = 1;
}

message GetUserResponse {
  User user = 1;
}

message User {
  string id = 1;
  string name = 2;
  string email = 3;
  UserRole role = 4;
  google.protobuf.Timestamp created_at = 5;
}

enum UserRole {
  USER_ROLE_UNSPECIFIED = 0;
  USER_ROLE_USER = 1;
  USER_ROLE_ADMIN = 2;
}

message ListUsersRequest {
  int32 page_size = 1;
  string page_token = 2;
}

message ListUsersResponse {
  repeated User users = 1;
  string next_page_token = 2;
}

message CreateUserRequest {
  string name = 1;
  string email = 2;
}

message CreateUserResponse {
  User user = 1;
}

message UpdateUserRequest {
  string id = 1;
  optional string name = 2;
  optional string email = 3;
}

message UpdateUserResponse {
  User user = 1;
}

message DeleteUserRequest {
  string id = 1;
}

message DeleteUserResponse {}

message WatchUsersRequest {
  optional string filter = 1;
}

message UserEvent {
  string event_type = 1;  // CREATED, UPDATED, DELETED
  User user = 2;
}
```

---

## Server Implementation

### Server Bootstrap (Node.js)
```typescript
// server/index.ts
import { fastify } from 'fastify';
import { fastifyConnectPlugin } from '@connectrpc/connect-fastify';
import { routes } from './routes';

async function startServer() {
  const server = fastify({ http2: true });

  await server.register(fastifyConnectPlugin, {
    routes,
  });

  const port = parseInt(process.env.PORT || '8080');
  await server.listen({ host: '0.0.0.0', port });
  console.log(`Connect server listening on port ${port}`);

  // Graceful shutdown
  for (const signal of ['SIGINT', 'SIGTERM']) {
    process.on(signal, async () => {
      await server.close();
      process.exit(0);
    });
  }
}

startServer().catch(console.error);
```

### Alternative: Express Integration
```typescript
// server/index-express.ts
import express from 'express';
import { expressConnectMiddleware } from '@connectrpc/connect-express';
import { routes } from './routes';
import cors from 'cors';

const app = express();

app.use(cors());
app.use(expressConnectMiddleware({ routes }));

app.listen(8080, () => {
  console.log('Connect server on :8080');
});
```

### Service Routes
```typescript
// server/routes/index.ts
import { ConnectRouter } from '@connectrpc/connect';
import { UserService } from '../../gen/user/v1/user_connect';
import { userServiceImpl } from './user-service';

export function routes(router: ConnectRouter) {
  router.service(UserService, userServiceImpl);
}
```

### Service Implementation
```typescript
// server/routes/user-service.ts
import type { ServiceImpl } from '@connectrpc/connect';
import { ConnectError, Code } from '@connectrpc/connect';
import { UserService } from '../../gen/user/v1/user_connect';
import { prisma } from '../../db';

export const userServiceImpl: ServiceImpl<typeof UserService> = {
  async getUser(request) {
    const user = await prisma.user.findUnique({
      where: { id: request.id },
    });

    if (!user) {
      throw new ConnectError(
        `User ${request.id} not found`,
        Code.NotFound
      );
    }

    return { user: mapUser(user) };
  },

  async listUsers(request) {
    const pageSize = Math.min(request.pageSize || 20, 100);
    const cursor = request.pageToken
      ? decodeCursor(request.pageToken)
      : undefined;

    const [users, total] = await Promise.all([
      prisma.user.findMany({
        take: pageSize + 1,
        ...(cursor && { cursor: { id: cursor }, skip: 1 }),
        orderBy: { createdAt: 'desc' },
      }),
      prisma.user.count(),
    ]);

    const hasMore = users.length > pageSize;
    const items = hasMore ? users.slice(0, pageSize) : users;

    return {
      users: items.map(mapUser),
      nextPageToken: hasMore
        ? encodeCursor(items[items.length - 1].id)
        : '',
    };
  },

  async createUser(request) {
    if (!request.name?.trim()) {
      throw new ConnectError(
        'Name is required',
        Code.InvalidArgument
      );
    }

    if (!request.email?.trim()) {
      throw new ConnectError(
        'Email is required',
        Code.InvalidArgument
      );
    }

    const existing = await prisma.user.findUnique({
      where: { email: request.email },
    });

    if (existing) {
      throw new ConnectError(
        `Email ${request.email} already exists`,
        Code.AlreadyExists
      );
    }

    const user = await prisma.user.create({
      data: { name: request.name, email: request.email },
    });

    return { user: mapUser(user) };
  },

  // Server streaming
  async *watchUsers(request) {
    // Initial snapshot
    const users = await prisma.user.findMany({ take: 50 });
    for (const user of users) {
      yield { eventType: 'SNAPSHOT', user: mapUser(user) };
    }

    // Watch for changes via pub/sub
    const sub = pubsub.subscribe('user-events');
    try {
      for await (const event of sub) {
        yield {
          eventType: event.type,
          user: mapUser(event.data),
        };
      }
    } finally {
      sub.unsubscribe();
    }
  },
};
```

---

## Error Handling

### Connect Error Codes
```typescript
import { ConnectError, Code } from '@connectrpc/connect';

// Connect Protocol uses the same codes as gRPC
// Code Reference:
// OK (0)              - Success
// Canceled (1)        - Client cancelled
// Unknown (2)         - Unknown error
// InvalidArgument (3) - Bad request / validation
// DeadlineExceeded (4)- Timeout
// NotFound (5)        - Resource not found
// AlreadyExists (6)   - Duplicate / conflict
// PermissionDenied (7)- Authorization failure
// ResourceExhausted (8)- Rate limit / quota
// FailedPrecondition (9)- State conflict
// Aborted (10)        - Transaction conflict
// OutOfRange (11)     - Pagination out of range
// Unimplemented (12)  - Method not implemented
// Internal (13)       - Internal server error
// Unavailable (14)    - Transient error, retry
// DataLoss (15)       - Unrecoverable data loss
// Unauthenticated (16)- Missing/invalid credentials

// Throwing errors
throw new ConnectError('Not found', Code.NotFound);

// With metadata
const error = new ConnectError('Validation failed', Code.InvalidArgument);
error.metadata.set('field', 'email');
throw error;

// Error details (rich error model)
import { BadRequest } from '../../gen/google/rpc/error_details_pb';

const badRequest = new BadRequest({
  fieldViolations: [
    { field: 'email', description: 'Must be a valid email' },
  ],
});

const detailError = new ConnectError(
  'Validation failed',
  Code.InvalidArgument
);
detailError.details.push({
  type: BadRequest.typeName,
  value: badRequest.toBinary(),
  debug: badRequest,
});
throw detailError;
```

### Client Error Handling
```typescript
import { ConnectError, Code } from '@connectrpc/connect';

try {
  const { user } = await client.getUser({ id: '123' });
} catch (error) {
  if (error instanceof ConnectError) {
    switch (error.code) {
      case Code.NotFound:
        showNotFound();
        break;
      case Code.Unauthenticated:
        redirectToLogin();
        break;
      case Code.PermissionDenied:
        showForbidden();
        break;
      default:
        showGenericError(error.message);
    }
  }
}
```

---

## Client Implementation

### Transport Configuration
```typescript
// client/transport.ts
import { createConnectTransport } from '@connectrpc/connect-web';

// For browser clients (Connect protocol over fetch)
export const transport = createConnectTransport({
  baseUrl: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080',
  // Use JSON for debugging, binary for production
  useBinaryFormat: process.env.NODE_ENV === 'production',
});

// For gRPC-Web compatibility (e.g., Envoy proxy)
import { createGrpcWebTransport } from '@connectrpc/connect-web';

export const grpcWebTransport = createGrpcWebTransport({
  baseUrl: 'https://api.example.com',
});
```

### Creating Clients
```typescript
// client/user-client.ts
import { createClient } from '@connectrpc/connect';
import { UserService } from '../gen/user/v1/user_connect';
import { transport } from './transport';

export const userClient = createClient(UserService, transport);

// Usage — simple and typed
const { user } = await userClient.getUser({ id: '123' });

// Streaming
for await (const event of userClient.watchUsers({})) {
  console.log(`${event.eventType}: ${event.user?.name}`);
}
```

### React Integration with TanStack Query
```typescript
// client/hooks/use-user.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { createClient } from '@connectrpc/connect';
import { UserService } from '../../gen/user/v1/user_connect';
import { transport } from '../transport';

const client = createClient(UserService, transport);

export function useUser(id: string) {
  return useQuery({
    queryKey: ['user', id],
    queryFn: () => client.getUser({ id }),
    enabled: !!id,
  });
}

export function useUsers(pageSize = 20) {
  return useQuery({
    queryKey: ['users', pageSize],
    queryFn: () => client.listUsers({ pageSize, pageToken: '' }),
  });
}

export function useCreateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: { name: string; email: string }) =>
      client.createUser(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}

// Usage in component
function UserProfile({ userId }: { userId: string }) {
  const { data, isLoading, error } = useUser(userId);

  if (isLoading) return <Skeleton />;
  if (error) return <ErrorMessage error={error} />;

  return <UserCard user={data.user} />;
}
```

### Connect-Query Integration (Alternative)
```typescript
// Using @connectrpc/connect-query for automatic query key management
import { useQuery } from '@connectrpc/connect-query';
import { getUser, listUsers } from '../../gen/user/v1/user-UserService_connectquery';

// Auto-generated hooks with proper cache keys
function UserProfile({ id }: { id: string }) {
  const { data } = useQuery(getUser, { id });
  return <UserCard user={data?.user} />;
}

function UserList() {
  const { data } = useQuery(listUsers, {
    pageSize: 20,
    pageToken: '',
  });

  return (
    <ul>
      {data?.users.map((user) => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}
```

---

## Interceptors

### Client Interceptor (Auth)
```typescript
// client/interceptors/auth.ts
import type { Interceptor } from '@connectrpc/connect';

export function authInterceptor(getToken: () => string | null): Interceptor {
  return (next) => async (request) => {
    const token = getToken();
    if (token) {
      request.header.set('Authorization', `Bearer ${token}`);
    }
    return next(request);
  };
}

// Usage
const transport = createConnectTransport({
  baseUrl: 'http://localhost:8080',
  interceptors: [authInterceptor(() => localStorage.getItem('token'))],
});
```

### Client Interceptor (Logging)
```typescript
// client/interceptors/logging.ts
import type { Interceptor } from '@connectrpc/connect';

export const loggingInterceptor: Interceptor = (next) => async (request) => {
  const start = Date.now();

  try {
    const response = await next(request);
    console.log(
      `[RPC] ${request.service.typeName}.${request.method.name}`,
      `${Date.now() - start}ms`,
      'OK'
    );
    return response;
  } catch (error) {
    console.error(
      `[RPC] ${request.service.typeName}.${request.method.name}`,
      `${Date.now() - start}ms`,
      'ERROR:',
      error
    );
    throw error;
  }
};
```

### Server Interceptor (Auth)
```typescript
// server/interceptors/auth.ts
import type { Interceptor } from '@connectrpc/connect';
import { ConnectError, Code } from '@connectrpc/connect';

const PUBLIC_METHODS = new Set([
  'user.v1.UserService/GetUser',
]);

export const authInterceptor: Interceptor = (next) => async (request) => {
  const methodName = `${request.service.typeName}/${request.method.name}`;

  if (PUBLIC_METHODS.has(methodName)) {
    return next(request);
  }

  const token = request.header.get('Authorization')?.replace('Bearer ', '');

  if (!token) {
    throw new ConnectError('Missing auth token', Code.Unauthenticated);
  }

  try {
    const payload = await verifyToken(token);
    request.header.set('X-User-Id', payload.userId);
    request.header.set('X-User-Role', payload.role);
    return next(request);
  } catch {
    throw new ConnectError('Invalid token', Code.Unauthenticated);
  }
};
```

---

## Streaming Patterns

### Server Streaming (Connect over HTTP/1.1)
```typescript
// Server: Stream events
async *watchUsers(request, context) {
  // Connect Protocol supports streaming over HTTP/1.1!
  // No HTTP/2 required (unlike native gRPC)

  const sub = pubsub.subscribe('user-events');

  try {
    for await (const event of sub) {
      // Check if client disconnected
      if (context.signal.aborted) break;

      yield {
        eventType: event.type,
        user: mapUser(event.data),
      };
    }
  } finally {
    sub.unsubscribe();
  }
}

// Client: Consume stream
const stream = userClient.watchUsers({});

for await (const event of stream) {
  console.log(`${event.eventType}: ${event.user?.name}`);
}
```

### React Hook for Streaming
```typescript
// hooks/use-user-stream.ts
import { useEffect, useState, useRef } from 'react';
import { userClient } from '../client/user-client';

export function useUserStream() {
  const [events, setEvents] = useState<UserEvent[]>([]);
  const abortRef = useRef<AbortController>();

  useEffect(() => {
    const abort = new AbortController();
    abortRef.current = abort;

    (async () => {
      try {
        for await (const event of userClient.watchUsers(
          {},
          { signal: abort.signal }
        )) {
          setEvents((prev) => [...prev.slice(-99), event]);
        }
      } catch (error) {
        if (!abort.signal.aborted) {
          console.error('Stream error:', error);
        }
      }
    })();

    return () => abort.abort();
  }, []);

  return events;
}
```

---

## Testing

### Unit Tests
```typescript
// tests/user-service.test.ts
import { createRouterTransport } from '@connectrpc/connect';
import { createClient } from '@connectrpc/connect';
import { UserService } from '../gen/user/v1/user_connect';
import { routes } from '../server/routes';

describe('UserService', () => {
  const transport = createRouterTransport(routes);
  const client = createClient(UserService, transport);

  test('GetUser returns user by ID', async () => {
    const { user } = await client.getUser({ id: 'test-1' });

    expect(user).toBeDefined();
    expect(user?.id).toBe('test-1');
  });

  test('GetUser throws NotFound for missing user', async () => {
    await expect(
      client.getUser({ id: 'nonexistent' })
    ).rejects.toThrow(/not found/i);
  });

  test('CreateUser validates required fields', async () => {
    await expect(
      client.createUser({ name: '', email: '' })
    ).rejects.toThrow();
  });

  test('ListUsers paginates correctly', async () => {
    const page1 = await client.listUsers({ pageSize: 2, pageToken: '' });

    expect(page1.users.length).toBeGreaterThan(0);
    expect(page1.users.length).toBeLessThanOrEqual(2);
  });
});
```

### Testing with cURL
```bash
# Connect protocol uses standard HTTP
# Unary call
curl -X POST http://localhost:8080/user.v1.UserService/GetUser \
  -H 'Content-Type: application/json' \
  -d '{"id": "123"}'

# With auth
curl -X POST http://localhost:8080/user.v1.UserService/CreateUser \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <token>' \
  -d '{"name": "John", "email": "john@example.com"}'

# Binary format
curl -X POST http://localhost:8080/user.v1.UserService/GetUser \
  -H 'Content-Type: application/proto' \
  --data-binary @request.bin
```

---

## Migration from gRPC-Web

```yaml
Key Differences:
  gRPC-Web:
    - Requires Envoy or grpc-web proxy
    - Limited streaming (server-only via HTTP/1.1)
    - Custom binary framing
    - Separate client libraries

  Connect-RPC:
    - No proxy needed (direct to server)
    - Full streaming over HTTP/1.1 and HTTP/2
    - Standard HTTP semantics (curl-friendly)
    - Same server handles Connect + gRPC + gRPC-Web
    - Uses fetch API natively in browsers

Migration Steps:
  1. Install @connectrpc/connect, @connectrpc/connect-web
  2. Replace grpc-web client with Connect transport
  3. Update buf.gen.yaml to use connectrpc/es plugin
  4. Regenerate code (buf generate)
  5. Replace service stubs with generated Connect clients
  6. Remove Envoy/proxy for Connect clients
  7. Keep gRPC-Web transport for legacy clients
```

---

## Security

```yaml
Transport:
  - Always use HTTPS in production
  - Connect works with standard TLS (no special config)
  - CORS headers for cross-origin browser requests

Authentication:
  - Pass tokens via Authorization header
  - Interceptors for token injection (client) and validation (server)
  - Refresh token rotation in auth interceptor

Authorization:
  - Check permissions in service methods
  - Use header-based user context from auth interceptor
  - Implement RBAC via proto annotations or middleware

Rate Limiting:
  - Standard HTTP rate limiting (nginx, cloudflare)
  - Per-method rate limits in server interceptors
  - Respect Retry-After headers in client
```

---

## Anti-Patterns

```yaml
❌ DON'T:
  - Use gRPC-Web proxy when Connect is available
  - Skip buf lint in CI/CD
  - Create transport per request (reuse it)
  - Ignore error codes (handle each appropriately)
  - Use JSON format in production (use binary)
  - Skip AbortController for streaming in React

✅ DO:
  - Use Connect Protocol for browser clients (no proxy needed)
  - Use binary format in production for performance
  - Implement interceptors for auth, logging, retry
  - Use TanStack Query for data fetching
  - Use AbortController for stream cleanup
  - Run buf breaking on CI to catch schema changes
  - Support both Connect and gRPC protocols on same server
  - Test with createRouterTransport (in-memory, fast)
```

---

## See Also

- [grpc.md](grpc.md) — Native gRPC for server-to-server communication
- [rest-api.md](rest-api.md) — REST API design patterns

---

**Version:** 1.0.0
**Standards:** Connect Protocol, @connectrpc/connect v2, Buf v2
**Created:** 2026-02-10

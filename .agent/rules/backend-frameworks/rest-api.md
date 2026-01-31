# REST API Design Patterns Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Standards:** REST, RFC 7807, OpenAPI 3.1, JSON:API
> **Priority:** P0 - Load for all API projects

---

You are an expert in REST API design and architecture.

## Key Principles (REST Constraints)

| Constraint | Description |
|------------|-------------|
| **Client-Server** | Separation of concerns |
| **Stateless** | No session state on server |
| **Cacheable** | Responses must define cacheability |
| **Layered System** | Client can't tell if connected directly |
| **Uniform Interface** | Standard methods, resource-based URIs |
| **Code on Demand** | Optional: executable code (JS) |

---

## Resource Naming

### URL Structure
```
https://api.example.com/v1/users/{userId}/posts/{postId}/comments
```

### Conventions
```
✅ Good                          ❌ Bad
───────────────────────────────────────────────
GET /users                       GET /getUsers
GET /users/123                   GET /user/123
GET /users/123/posts             GET /getUserPosts?id=123
POST /users                      POST /createUser
DELETE /users/123                POST /deleteUser
GET /user-profiles               GET /user_profiles
GET /users?status=active         GET /activeUsers
```

### Hierarchy Examples
```http
# Collection
GET /users

# Document
GET /users/123

# Sub-collection
GET /users/123/posts

# Sub-document
GET /users/123/posts/456

# Controller (actions that don't fit CRUD)
POST /users/123/activate
POST /orders/789/cancel
POST /auth/login
POST /auth/logout
```

---

## HTTP Methods

### Method Semantics
```http
# GET - Retrieve (Safe, Idempotent)
GET /users
GET /users/123

# POST - Create (Not Idempotent)
POST /users
Content-Type: application/json
{
  "name": "John Doe",
  "email": "john@example.com"
}

# PUT - Replace entire resource (Idempotent)
PUT /users/123
Content-Type: application/json
{
  "name": "John Doe",
  "email": "john@example.com",
  "role": "admin"
}

# PATCH - Partial update (Not necessarily Idempotent)
PATCH /users/123
Content-Type: application/json
{
  "role": "admin"
}

# DELETE - Remove (Idempotent)
DELETE /users/123
```

### Method Properties
| Method | Safe | Idempotent | Request Body | Response Body |
|--------|------|------------|--------------|---------------|
| GET | ✅ | ✅ | ❌ | ✅ |
| HEAD | ✅ | ✅ | ❌ | ❌ |
| POST | ❌ | ❌ | ✅ | ✅ |
| PUT | ❌ | ✅ | ✅ | ✅ |
| PATCH | ❌ | ❌ | ✅ | ✅ |
| DELETE | ❌ | ✅ | ❌ | Optional |
| OPTIONS | ✅ | ✅ | ❌ | ✅ |

---

## HTTP Status Codes

### Success (2xx)
```http
# 200 OK - Successful GET, PUT, PATCH
HTTP/1.1 200 OK
Content-Type: application/json
{
  "id": 123,
  "name": "John Doe"
}

# 201 Created - Successful POST
HTTP/1.1 201 Created
Location: /users/123
Content-Type: application/json
{
  "id": 123,
  "name": "John Doe"
}

# 202 Accepted - Async processing started
HTTP/1.1 202 Accepted
Location: /jobs/456
Content-Type: application/json
{
  "jobId": "456",
  "status": "processing",
  "statusUrl": "/jobs/456"
}

# 204 No Content - Successful DELETE or PUT with no body
HTTP/1.1 204 No Content
```

### Redirection (3xx)
```http
# 301 Moved Permanently
HTTP/1.1 301 Moved Permanently
Location: /api/v2/users

# 304 Not Modified (Caching)
HTTP/1.1 304 Not Modified
ETag: "abc123"
```

### Client Errors (4xx)
```http
# 400 Bad Request - Validation failed
# 401 Unauthorized - Missing/invalid auth
# 403 Forbidden - Authenticated but not authorized
# 404 Not Found - Resource doesn't exist
# 405 Method Not Allowed
# 409 Conflict - Resource conflict (duplicate)
# 422 Unprocessable Entity - Semantic errors
# 429 Too Many Requests - Rate limited
```

### Server Errors (5xx)
```http
# 500 Internal Server Error
# 502 Bad Gateway
# 503 Service Unavailable
# 504 Gateway Timeout
```

---

## Response Format

### Standard Response Envelope
```json
// Success response
{
  "data": {
    "id": 123,
    "name": "John Doe",
    "email": "john@example.com",
    "createdAt": "2024-01-15T10:30:00Z"
  },
  "meta": {
    "requestId": "req_abc123"
  }
}

// Collection response
{
  "data": [
    { "id": 1, "name": "User 1" },
    { "id": 2, "name": "User 2" }
  ],
  "meta": {
    "total": 100,
    "page": 1,
    "perPage": 10,
    "totalPages": 10
  },
  "links": {
    "self": "/users?page=1",
    "first": "/users?page=1",
    "prev": null,
    "next": "/users?page=2",
    "last": "/users?page=10"
  }
}
```

---

## Error Handling (RFC 7807)

### Problem Details Format
```json
// 400 Bad Request - Validation Error
{
  "type": "https://api.example.com/problems/validation-error",
  "title": "Validation Failed",
  "status": 400,
  "detail": "The request body contains invalid fields",
  "instance": "/users",
  "errors": [
    {
      "field": "email",
      "code": "invalid_format",
      "message": "Email must be a valid email address"
    },
    {
      "field": "password",
      "code": "too_short",
      "message": "Password must be at least 8 characters"
    }
  ],
  "traceId": "abc123-def456"
}

// 401 Unauthorized
{
  "type": "https://api.example.com/problems/unauthorized",
  "title": "Unauthorized",
  "status": 401,
  "detail": "Invalid or expired access token",
  "instance": "/users/123"
}

// 403 Forbidden
{
  "type": "https://api.example.com/problems/forbidden",
  "title": "Forbidden",
  "status": 403,
  "detail": "You don't have permission to access this resource",
  "instance": "/admin/settings"
}

// 404 Not Found
{
  "type": "https://api.example.com/problems/not-found",
  "title": "Not Found",
  "status": 404,
  "detail": "User with id '123' was not found",
  "instance": "/users/123"
}

// 409 Conflict
{
  "type": "https://api.example.com/problems/conflict",
  "title": "Conflict",
  "status": 409,
  "detail": "A user with this email already exists",
  "instance": "/users",
  "conflictingResource": "/users/456"
}

// 429 Too Many Requests
{
  "type": "https://api.example.com/problems/rate-limit-exceeded",
  "title": "Too Many Requests",
  "status": 429,
  "detail": "Rate limit of 100 requests per minute exceeded",
  "instance": "/users",
  "retryAfter": 30
}

// 500 Internal Server Error
{
  "type": "https://api.example.com/problems/internal-error",
  "title": "Internal Server Error",
  "status": 500,
  "detail": "An unexpected error occurred",
  "instance": "/users",
  "traceId": "abc123-def456"
}
```

### Implementation
```typescript
// errors/problem-details.ts
interface ProblemDetails {
  type: string;
  title: string;
  status: number;
  detail?: string;
  instance?: string;
  [key: string]: unknown;
}

class ApiError extends Error {
  constructor(
    public status: number,
    public type: string,
    public title: string,
    public detail?: string,
    public extensions?: Record<string, unknown>
  ) {
    super(detail || title);
  }

  toProblemDetails(instance: string): ProblemDetails {
    return {
      type: `https://api.example.com/problems/${this.type}`,
      title: this.title,
      status: this.status,
      detail: this.detail,
      instance,
      ...this.extensions,
    };
  }
}

// Predefined errors
const errors = {
  validation: (detail: string, errors: ValidationError[]) =>
    new ApiError(400, 'validation-error', 'Validation Failed', detail, { errors }),

  unauthorized: (detail = 'Authentication required') =>
    new ApiError(401, 'unauthorized', 'Unauthorized', detail),

  forbidden: (detail = 'Access denied') =>
    new ApiError(403, 'forbidden', 'Forbidden', detail),

  notFound: (resource: string, id: string) =>
    new ApiError(404, 'not-found', 'Not Found', `${resource} with id '${id}' was not found`),

  conflict: (detail: string) =>
    new ApiError(409, 'conflict', 'Conflict', detail),

  rateLimited: (retryAfter: number) =>
    new ApiError(429, 'rate-limit-exceeded', 'Too Many Requests', 
      'Rate limit exceeded', { retryAfter }),
};
```

---

## Pagination

### Offset Pagination
```http
# Request
GET /users?page=2&per_page=20

# Response
{
  "data": [...],
  "meta": {
    "total": 100,
    "page": 2,
    "perPage": 20,
    "totalPages": 5
  },
  "links": {
    "self": "/users?page=2&per_page=20",
    "first": "/users?page=1&per_page=20",
    "prev": "/users?page=1&per_page=20",
    "next": "/users?page=3&per_page=20",
    "last": "/users?page=5&per_page=20"
  }
}
```

### Cursor Pagination (Recommended for large datasets)
```http
# Request
GET /users?limit=20&cursor=eyJpZCI6MTIzfQ

# Response
{
  "data": [...],
  "meta": {
    "hasMore": true,
    "nextCursor": "eyJpZCI6MTQzfQ",
    "prevCursor": "eyJpZCI6MTAzfQ"
  },
  "links": {
    "self": "/users?limit=20&cursor=eyJpZCI6MTIzfQ",
    "next": "/users?limit=20&cursor=eyJpZCI6MTQzfQ",
    "prev": "/users?limit=20&cursor=eyJpZCI6MTAzfQ"
  }
}
```

### Keyset Pagination (Most efficient)
```http
# Request (first page)
GET /users?limit=20&sort=created_at:desc

# Request (subsequent pages)
GET /users?limit=20&sort=created_at:desc&after_id=123&after_created_at=2024-01-15T10:30:00Z
```

---

## Filtering & Sorting

### Filtering
```http
# Simple
GET /users?status=active
GET /users?role=admin&status=active

# Operators
GET /users?created_at[gte]=2024-01-01
GET /users?age[lt]=30
GET /users?name[contains]=john
GET /users?status[in]=active,pending
GET /users?email[not_null]=true

# Search
GET /users?q=john
GET /posts?search=typescript
```

### Sorting
```http
# Single field
GET /users?sort=created_at       # Ascending
GET /users?sort=-created_at      # Descending

# Multiple fields
GET /users?sort=-created_at,name
GET /users?sort=status:asc,created_at:desc
```

### Field Selection (Sparse Fieldsets)
```http
GET /users?fields=id,name,email
GET /users/123?fields=id,name,email,posts
GET /users?fields[users]=id,name&fields[posts]=id,title
```

### Include (Eager Loading)
```http
GET /users/123?include=posts,profile
GET /posts?include=author,comments.author
```

---

## HATEOAS (Hypermedia)

### HAL Format
```json
{
  "_links": {
    "self": { "href": "/users/123" },
    "posts": { "href": "/users/123/posts" },
    "edit": { "href": "/users/123", "method": "PUT" },
    "delete": { "href": "/users/123", "method": "DELETE" }
  },
  "id": 123,
  "name": "John Doe",
  "email": "john@example.com",
  "_embedded": {
    "posts": [
      {
        "_links": {
          "self": { "href": "/posts/1" },
          "author": { "href": "/users/123" }
        },
        "id": 1,
        "title": "First Post"
      }
    ]
  }
}
```

### JSON:API Format
```json
{
  "data": {
    "type": "users",
    "id": "123",
    "attributes": {
      "name": "John Doe",
      "email": "john@example.com"
    },
    "relationships": {
      "posts": {
        "links": {
          "self": "/users/123/relationships/posts",
          "related": "/users/123/posts"
        },
        "data": [
          { "type": "posts", "id": "1" },
          { "type": "posts", "id": "2" }
        ]
      }
    },
    "links": {
      "self": "/users/123"
    }
  },
  "included": [
    {
      "type": "posts",
      "id": "1",
      "attributes": {
        "title": "First Post"
      }
    }
  ]
}
```

---

## API Versioning

### URI Versioning (Recommended)
```http
GET /v1/users
GET /v2/users
```

### Header Versioning
```http
GET /users
Accept: application/vnd.api+json; version=2
# or
GET /users
X-API-Version: 2
```

### Media Type Versioning
```http
GET /users
Accept: application/vnd.example.v2+json
```

---

## Caching

### Cache Headers
```http
# Response with caching
HTTP/1.1 200 OK
Cache-Control: public, max-age=3600
ETag: "abc123"
Last-Modified: Mon, 15 Jan 2024 10:30:00 GMT

# Conditional GET
GET /users/123
If-None-Match: "abc123"

# Response when not modified
HTTP/1.1 304 Not Modified
ETag: "abc123"

# Response when modified
HTTP/1.1 200 OK
ETag: "def456"
{ ... new data ... }
```

### Cache-Control Directives
```http
# Public caching (CDN can cache)
Cache-Control: public, max-age=3600

# Private caching (browser only)
Cache-Control: private, max-age=3600

# No caching
Cache-Control: no-store

# Stale while revalidate
Cache-Control: max-age=60, stale-while-revalidate=3600
```

---

## Idempotency Keys

```http
# Client sends unique key
POST /payments
Idempotency-Key: unique-client-key-123
Content-Type: application/json
{
  "amount": 100,
  "currency": "USD"
}

# Server stores key + response, returns same response on retry
HTTP/1.1 201 Created
Idempotency-Key: unique-client-key-123
{
  "id": "pay_123",
  "amount": 100,
  "status": "completed"
}
```

### Implementation
```typescript
// middleware/idempotency.ts
const idempotencyStore = new Map<string, { response: any; expiry: number }>();

async function idempotencyMiddleware(req, res, next) {
  const key = req.headers['idempotency-key'];
  
  if (!key) return next();
  
  // Check for existing response
  const cached = idempotencyStore.get(key);
  if (cached && cached.expiry > Date.now()) {
    return res.status(200).json(cached.response);
  }
  
  // Capture response
  const originalJson = res.json.bind(res);
  res.json = (body) => {
    idempotencyStore.set(key, {
      response: body,
      expiry: Date.now() + 24 * 60 * 60 * 1000, // 24 hours
    });
    return originalJson(body);
  };
  
  next();
}
```

---

## Rate Limiting

### Rate Limit Headers
```http
HTTP/1.1 200 OK
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1705320000
RateLimit-Policy: 100;w=60

# When exceeded
HTTP/1.1 429 Too Many Requests
Retry-After: 30
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1705320000
```

---

## Long-Running Operations

```http
# Start async operation
POST /reports/generate
Content-Type: application/json
{
  "type": "sales",
  "dateRange": "2024-01"
}

# Response
HTTP/1.1 202 Accepted
Location: /jobs/job_123
{
  "id": "job_123",
  "status": "processing",
  "progress": 0,
  "links": {
    "self": "/jobs/job_123",
    "cancel": "/jobs/job_123/cancel"
  }
}

# Poll for status
GET /jobs/job_123

# In progress
{
  "id": "job_123",
  "status": "processing",
  "progress": 45
}

# Completed
{
  "id": "job_123",
  "status": "completed",
  "progress": 100,
  "result": {
    "reportUrl": "/reports/report_456"
  }
}
```

---

## OpenAPI 3.1 Example

```yaml
openapi: 3.1.0
info:
  title: User API
  version: 1.0.0
  description: User management API

servers:
  - url: https://api.example.com/v1

paths:
  /users:
    get:
      summary: List users
      operationId: listUsers
      tags: [Users]
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: per_page
          in: query
          schema:
            type: integer
            default: 20
            maximum: 100
        - name: status
          in: query
          schema:
            type: string
            enum: [active, inactive]
      responses:
        '200':
          description: List of users
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserListResponse'
        '401':
          $ref: '#/components/responses/Unauthorized'
    
    post:
      summary: Create user
      operationId: createUser
      tags: [Users]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          description: User created
          headers:
            Location:
              schema:
                type: string
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '400':
          $ref: '#/components/responses/ValidationError'
        '409':
          $ref: '#/components/responses/Conflict'

components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: integer
        name:
          type: string
        email:
          type: string
          format: email
        createdAt:
          type: string
          format: date-time
      required: [id, name, email, createdAt]
    
    CreateUserRequest:
      type: object
      properties:
        name:
          type: string
          minLength: 2
          maxLength: 100
        email:
          type: string
          format: email
        password:
          type: string
          minLength: 8
      required: [name, email, password]
    
    ProblemDetails:
      type: object
      properties:
        type:
          type: string
          format: uri
        title:
          type: string
        status:
          type: integer
        detail:
          type: string
        instance:
          type: string

  responses:
    Unauthorized:
      description: Unauthorized
      content:
        application/problem+json:
          schema:
            $ref: '#/components/schemas/ProblemDetails'
    
    ValidationError:
      description: Validation Error
      content:
        application/problem+json:
          schema:
            allOf:
              - $ref: '#/components/schemas/ProblemDetails'
              - type: object
                properties:
                  errors:
                    type: array
                    items:
                      type: object
                      properties:
                        field:
                          type: string
                        message:
                          type: string

  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

security:
  - bearerAuth: []
```

---

## Best Practices Checklist

- [ ] Use nouns for resources, verbs for actions
- [ ] Return appropriate HTTP status codes
- [ ] Implement RFC 7807 Problem Details for errors
- [ ] Support pagination for collections
- [ ] Use cursor pagination for large datasets
- [ ] Include HATEOAS links for discoverability
- [ ] Version your API (URI recommended)
- [ ] Implement proper caching with ETags
- [ ] Use idempotency keys for POST requests
- [ ] Set rate limiting with proper headers
- [ ] Document with OpenAPI 3.1
- [ ] Use ISO 8601 for all datetime fields

---

**References:**
- [RFC 7807 - Problem Details](https://tools.ietf.org/html/rfc7807)
- [OpenAPI Specification](https://spec.openapis.org/oas/v3.1.0)
- [JSON:API Specification](https://jsonapi.org/)
- [REST API Design Best Practices](https://restfulapi.net/)

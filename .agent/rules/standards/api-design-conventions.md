---
category: Standards
scope: Universal
last_updated: 2026-01-16
---

# API Design - Best Practices & Conventions

**Scope:** REST APIs, GraphQL, gRPC  
**Updated:** 2026-01-16

---

## REST API Design Principles

### Resource Naming

```
✅ Good - Plural nouns, hierarchical
GET    /users
GET    /users/{id}
GET    /users/{id}/posts
POST   /users
PUT    /users/{id}
DELETE /users/{id}

❌ Bad - Verbs, inconsistent
GET    /getAllUsers
POST   /createUser
GET    /user/{id}
```

### HTTP Methods

| Method | Purpose | Idempotent | Safe |
|--------|---------|------------|------|
| **GET** | Retrieve resource | ✅ | ✅ |
| **POST** | Create resource | ❌ | ❌ |
| **PUT** | Update/Replace | ✅ | ❌ |
| **PATCH** | Partial update | ❌ | ❌ |
| **DELETE** | Remove resource | ✅ | ❌ |

---

## API Versioning

### URI Versioning (Recommended)

```
✅ Preferred
/v1/users
/v2/users

✅ Alternative - Header versioning
GET /users
Accept: application/vnd.myapi.v2+json
```

### Version Strategy

```
v1 → v2 Migration:
1. Deploy v2 alongside v1
2. Deprecate v1 (6-12 months notice)
3. Remove v1 after transition period
```

---

## Request/Response Format

### JSON Structure

```json
// ✅ Good - Consistent structure
{
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  },
  "meta": {
    "timestamp": "2026-01-16T10:00:00Z"
  }
}

// ✅ List response with pagination
{
  "data": [ {...}, {...} ],
  "meta": {
    "total": 100,
    "page": 1,
    "per_page": 20
  },
  "links": {
    "self": "/users?page=1",
    "next": "/users?page=2",
    "last": "/users?page=5"
  }
}
```

---

## Error Handling (RFC 7807)

### Problem Details Format

```json
{
  "type": "https://api.example.com/errors/validation-error",
  "title": "Validation Error",
  "status": 400,
  "detail": "Email address is invalid",
  "instance": "/users/create",
  "errors": [
    {
      "field": "email",
      "message": "Must be a valid email address"
    }
  ]
}
```

### Standard HTTP Status Codes

| Code | Meaning | Usage |
|------|---------|-------|
| **200** | OK | Successful GET/PUT/PATCH |
| **201** | Created | Successful POST |
| **204** | No Content | Successful DELETE |
| **400** | Bad Request | Validation error |
| **401** | Unauthorized | Missing/invalid auth |
| **403** | Forbidden | Insufficient permissions |
| **404** | Not Found | Resource doesn't exist |
| **409** | Conflict | Duplicate resource |
| **422** | Unprocessable | Semantic error |
| **429** | Too Many Requests | Rate limit exceeded |
| **500** | Server Error | Internal error |

---

## Pagination

### Cursor-Based (Recommended for large datasets)

```
GET /users?cursor=eyJpZCI6MTAwfQ&limit=20

Response:
{
  "data": [...],
  "pagination": {
    "next_cursor": "eyJpZCI6MTIwfQ",
    "has_more": true
  }
}
```

### Offset-Based (Simple use cases)

```
GET /users?page=2&per_page=20

Response:
{
  "data": [...],
  "pagination": {
    "total": 100,
    "page": 2,
    "per_page": 20,
    "total_pages": 5
  }
}
```

---

## Filtering, Sorting, Searching

```
// Filtering
GET /users?status=active&role=admin

// Sorting
GET /users?sort=-created_at,name
// (-) = descending, (+) or nothing = ascending

// Searching
GET /users?q=john

// Field selection (sparse fieldsets)
GET /users?fields=id,name,email
```

---

## Authentication & Security

### Bearer Token (JWT)

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### API Keys

```
X-API-Key: your-api-key-here
```

### OAuth 2.0 Scopes

```json
{
  "access_token": "...",
  "scope": "read:users write:users",
  "expires_in": 3600
}
```

---

## Rate Limiting

### Headers

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1626451200

// When exceeded
HTTP/1.1 429 Too Many Requests
Retry-After: 3600
```

---

## GraphQL

### Schema Design

```graphql
type User {
  id: ID!
  name: String!
  email: String!
  posts: [Post!]!
}

type Query {
  user(id: ID!): User
  users(first: Int, after: String): UserConnection!
}

type Mutation {
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
}
```

### Error Handling

```json
{
  "data": null,
  "errors": [
    {
      "message": "User not found",
      "locations": [{ "line": 2, "column": 3 }],
      "path": ["user"],
      "extensions": {
        "code": "NOT_FOUND",
        "userId": "123"
      }
    }
  ]
}
```

---

## OpenAPI/Swagger Documentation

### Spec Example

```yaml
openapi: 3.0.0
info:
  title: User API
  version: 1.0.0
paths:
  /users:
    get:
      summary: List users
      parameters:
        - name: page
          in: query
          schema:
            type: integer
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'
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
```

---

## CORS Configuration

```javascript
// Permissive (development only)
Access-Control-Allow-Origin: *

// ✅ Production - Specific origins
Access-Control-Allow-Origin: https://app.example.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Max-Age: 86400
```

---

## Best Practices Checklist

### Design
- [ ] **RESTful routes** - Plural nouns, hierarchical
- [ ] **Versioning** - URI or header based
- [ ] **Consistent naming** - camelCase or snake_case (pick one)
- [ ] **Idempotency** - PUT/DELETE are idempotent

### Data
- [ ] **JSON format** - Standardized structure
- [ ] **Pagination** - Cursor or offset based
- [ ] **Filtering** - Query parameters
- [ ] **Field selection** - Sparse fieldsets

### Errors
- [ ] **RFC 7807** - Problem Details format
- [ ] **HTTP status codes** - Correct usage
- [ ] **Validation errors** - Field-level details
- [ ] **Error tracking** - Unique error IDs

### Security
- [ ] **Authentication** - JWT/OAuth2
- [ ] **Authorization** - Role-based access
- [ ] **Rate limiting** - Per user/IP
- [ ] **CORS** - Configured correctly
- [ ] **HTTPS only** - No HTTP in production

### Documentation
- [ ] **OpenAPI spec** - Auto-generated
- [ ] **Examples** - Request/response samples
- [ ] **Changelog** - Version changes documented
- [ ] **Interactive docs** - Swagger/Postman

---

## Anti-Patterns to Avoid

❌ **Verbs in URLs** → Use HTTP methods  
❌ **Inconsistent naming** → Stick to one convention  
❌ **No versioning** → Always version APIs  
❌ **Generic errors** → Provide details  
❌ **No rate limiting** → Protect your API  
❌ **Exposing IDs** → Use UUIDs or obfuscate  
❌ **No pagination** → Large responses kill performance

---

**References:**
- [REST API Design Best Practices](https://restfulapi.net/)
- [RFC 7807 - Problem Details](https://tools.ietf.org/html/rfc7807)
- [OpenAPI Specification](https://swagger.io/specification/)
- [GraphQL Best Practices](https://graphql.org/learn/best-practices/)

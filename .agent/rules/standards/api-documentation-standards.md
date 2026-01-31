# API Documentation Standards

**Version:** 1.0  
**Updated:** 2026-01-16

---

## 1. OpenAPI /Swagger Specification

```yaml
openapi: 3.0.0
info:
  title: My API
  version: 1.0.0
  description: API for managing users and posts

servers:
  - url: https://api.example.com/v1
    description: Production
  - url: https://staging-api.example.com/v1
    description: Staging

paths:
  /users:
    get:
      summary: List all users
      tags:
        - Users
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/User'
                  meta:
                    type: object
                    properties:
                      page: { type: integer }
                      limit: { type: integer }
                      total: { type: integer }

components:
  schemas:
    User:
      type: object
      required:
        - id
        - email
      properties:
        id:
          type: string
          format: uuid
        email:
          type: string
          format: email
        name:
          type: string
        createdAt:
          type: string
          format: date-time
```

---

## 2. API Versioning

```
/api/v1/users  ✅ Recommended
/api/v2/users  

Accept: application/vnd.myapi.v1+json  ✅ Alternative (header-based)
```

### Version Changelog
```markdown
# API Changelog

## v2.0.0 (2026-01-15)
### Breaking Changes
- `GET /users` now returns paginated results
- Removed `full_name` field, split into `first_name` and `last_name`

### Added
- `POST /users/bulk` - Bulk user creation
- `GET /users/search` - Full-text search

### Deprecated
- `GET /users/all` - Use `/users` with pagination instead
```

---

## 3. Response Format Standards

```javascript
// ✅ Success Response
{
  "success": true,
  "data": {
    "id": "123",
    "name": "John Doe"
  },
  "meta": {
    "timestamp": "2026-01-16T10:30:00Z",
    "requestId": "abc-123"
  }
}

// ✅ Error Response
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": [
      {
        "field": "email",
        "message": "Must be a valid email address"
      }
    ]
  },
  "meta": {
    "timestamp": "2026-01-16T10:30:00Z",
    "requestId": "abc-123"
  }
}

// ✅ Paginated Response
{
  "success": true,
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8,
    "hasNext": true,
    "hasPrev": false
  }
}
```

---

## 4. Error Codes

```javascript
// Standard HTTP + Custom Codes
{
  "VALIDATION_ERROR": 400,
  "UNAUTHORIZED": 401,
  "FORBIDDEN": 403,
  "NOT_FOUND": 404,
  "RATE_LIMIT_EXCEEDED": 429,
  "INTERNAL_ERROR": 500,
  
  // Custom business logic errors
  "INSUFFICIENT_BALANCE": 400,
  "DUPLICATE_EMAIL": 409,
  "ACCOUNT_SUSPENDED": 403
}
```

---

## 5. Postman Collection

```json
{
  "info": {
    "name": "My API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Users",
      "item": [
        {
          "name": "Get All Users",
          "request": {
            "method": "GET",
            "header": [
              {
                "key": "Authorization",
                "value": "Bearer {{token}}"
              }
            ],
            "url": {
              "raw": "{{baseUrl}}/users?page=1&limit=20",
              "host": ["{{baseUrl}}"],
              "path": ["users"],
              "query": [
                { "key": "page", "value": "1" },
                { "key": "limit", "value": "20" }
              ]
            }
          }
        }
      ]
    }
  ],
  "variable": [
    {
      "key": "baseUrl",
      "value": "https://api.example.com/v1"
    }
  ]
}
```

---

## 6. Authentication Documentation

```markdown
# Authentication

## OAuth 2.0

All API requests require authentication using OAuth 2.0.

### Getting an Access Token

\`\`\`bash
POST /oauth/token
Content-Type: application/json

{
  "grant_type": "client_credentials",
  "client_id": "your_client_id",
  "client_secret": "your_client_secret"
}
\`\`\`

### Using the Token

\`\`\`bash
GET /api/v1/users
Authorization: Bearer <access_token>
\`\`\`

### Token Expiry
Tokens expire after 1 hour. Use the `expires_in` field to determine when to refresh.
```

---

## 7. Rate Limiting

```markdown
# Rate Limits

- **Authenticated requests:** 1000 requests/hour
- **Unauthenticated requests:** 60 requests/hour

Rate limit information is included in response headers:

\`\`\`
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1641034800
\`\`\`

When rate limit is exceeded, you'll receive a `429 Too Many Requests` response.
```

---

**References:**
- [OpenAPI Specification](https://swagger.io/specification/)
- [Postman Documentation](https://learning.postman.com/)
- [API Design Best Practices](https://swagger.io/resources/articles/best-practices-in-api-design/)

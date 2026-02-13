# {PROJECT_NAME} — API Specification

> **Generated**: {DATE} | **Condition**: Project has custom API endpoints

---

## 1. Authentication

| Aspect | Decision |
|--------|----------|
| **Strategy** | {JWT / Session / API Key / OAuth2} |
| **Token location** | {httpOnly cookie / Authorization header / both} |
| **Token lifetime** | {access: 15m, refresh: 7d} |
| **Login endpoint** | {POST /api/auth/login} |
| **Refresh endpoint** | {POST /api/auth/refresh} |
| **Logout endpoint** | {POST /api/auth/logout} |

---

## 2. Response Format

### Success Response
```json
{
  "data": { ... },
  "meta": {
    "page": 1,
    "perPage": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

### Error Response
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable message",
    "details": [
      { "field": "email", "message": "Email is required" }
    ]
  }
}
```

### Status Codes

| Code | Usage |
|------|-------|
| 200 | Success (GET, PUT, PATCH) |
| 201 | Created (POST) |
| 204 | No Content (DELETE) |
| 400 | Validation error |
| 401 | Unauthorized (not logged in) |
| 403 | Forbidden (insufficient permissions) |
| 404 | Not found |
| 409 | Conflict (duplicate) |
| 429 | Rate limited |
| 500 | Server error |

---

## 3. Endpoint Catalog

### Auth Endpoints

| Method | Path | Auth | Request Body | Response |
|--------|------|------|-------------|----------|
| POST | /api/auth/login | None | `{ email, password }` | `{ data: { user, token } }` |
| POST | /api/auth/logout | Required | — | `204` |
| GET | /api/auth/me | Required | — | `{ data: User }` |

### {Resource 1} Endpoints

| Method | Path | Auth | Request Body | Response |
|--------|------|------|-------------|----------|
| GET | /api/{resource} | {auth} | — | `{ data: T[], meta }` |
| GET | /api/{resource}/:id | {auth} | — | `{ data: T }` |
| POST | /api/{resource} | {auth} | `{ ...fields }` | `{ data: T }` (201) |
| PUT | /api/{resource}/:id | {auth} | `{ ...fields }` | `{ data: T }` |
| DELETE | /api/{resource}/:id | {auth} | — | `204` |

### {Resource 2} Endpoints

| Method | Path | Auth | Request Body | Response |
|--------|------|------|-------------|----------|
| ... | ... | ... | ... | ... |

### Public Endpoints

| Method | Path | Auth | Request Body | Response |
|--------|------|------|-------------|----------|
| GET | /api/public/{...} | None | — | `{ data: T }` |
| GET | /api/health | None | — | `{ status: "ok" }` |

---

## 4. Query Parameters

### Pagination
```
?page=1&perPage=20
```

### Filtering
```
?status=active&tenantId=123
```

### Sorting
```
?sort=createdAt&order=desc
```

### Search
```
?q=search+term
```

---

## 5. Rate Limiting

| Endpoint Group | Limit | Window |
|---------------|-------|--------|
| Auth (login) | {10 req} | {15 min} |
| Public API | {60 req} | {1 min} |
| Authenticated API | {120 req} | {1 min} |

---

> **Instructions for AI:**
> - Generate ONLY when project has custom API endpoints beyond auto-generated CRUD
> - Skip for static sites, CLI tools, or projects using only built-in CMS API
> - Section 1: Extract auth strategy from existing middleware, token handling code
> - Section 2: Extract from existing response patterns in codebase
> - Section 3: Catalog ALL endpoints — existing AND planned (from BRIEF Next Steps)
> - Section 4: Extract query conventions from existing implementations
> - Section 5: Define if rate limiting exists or is planned
> - Reference CONVENTIONS Sec 3 (API Response Format) for format consistency
> - Output location: `docs/PROJECT-API.md`

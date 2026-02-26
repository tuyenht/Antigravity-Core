---
description: "Đánh giá thiết kế, hợp đồng cấu trúc API và tài liệu theo chuẩn."
---

# /api-design — API Design Validator

// turbo-all

Validate API endpoints, response formats, contracts, and documentation against industry best practices.

**Agent:** `backend-specialist`  
**Skills:** `api-patterns`, `architecture-mastery`, `clean-code`

---

## Pre-Check

```
Auto-detect:
├── openapi.yaml / swagger.json   → Validate OpenAPI spec
├── schema.graphql / .gql files   → Validate GraphQL schema
├── routes/*.ts + Express/Nest    → Scan REST routes
├── app/Http/routes.php (Laravel) → Scan Laravel routes
├── trpc/router.ts                → Validate tRPC procedures
└── Không detect được             → ASK user: "API type nào?"
```

---

## Step 1: Run Validator

```bash
python .agent/skills/api-patterns/scripts/api_validator.py --root .
```

---

## Step 2: Endpoint Naming Check

| Rule | Correct | Incorrect |
|------|---------|-----------|
| Plural nouns | `/api/v1/users` | `/api/v1/user` |
| Kebab-case | `/api/v1/user-profiles` | `/api/v1/userProfiles` |
| Versioned | `/api/v1/...` | `/api/...` (no version) |
| No verbs | `GET /users` | `/getUsers` |
| Nested resources | `/users/:id/posts` | `/user-posts?userId=` |

---

## Step 3: Response Format Check

### Success Response (RFC 7807 compliant)
```json
{
  "data": { ... },
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 150
  }
}
```

### Error Response (RFC 7807)
```json
{
  "type": "https://api.example.com/errors/validation",
  "title": "Validation Error",
  "status": 422,
  "detail": "Email format is invalid",
  "instance": "/api/v1/users",
  "errors": [
    { "field": "email", "message": "Invalid format" }
  ]
}
```

---

## Step 4: Security & Rate Limiting

- [ ] **Authentication:** Tất cả endpoints (trừ public) có auth middleware
- [ ] **Authorization:** Role-based access control on sensitive endpoints
- [ ] **Rate limiting:** Có rate limit config (throttle middleware)
- [ ] **Input validation:** Request validation (Form Request / Zod / Joi)
- [ ] **CORS:** Config đúng (không `*` trên production)
- [ ] **HTTPS:** Enforce HTTPS trên production

---

## Step 5: Pagination & Filtering

- [ ] List endpoints có pagination (cursor hoặc offset)
- [ ] Pagination params chuẩn: `?page=1&per_page=20` hoặc `?cursor=xxx`
- [ ] Filter/sort params: `?sort=created_at&order=desc&status=active`
- [ ] Response có `meta` object với total/page info

---

## Step 6: Versioning Check

- [ ] API có version prefix (`/v1/`, `/v2/`)
- [ ] Breaking changes = new version (v1 → v2)
- [ ] Deprecation headers cho old versions
- [ ] Migration guide khi bump version

---

## Step 7: Documentation Coverage

- [ ] OpenAPI spec exists (hoặc tương đương)
- [ ] Mỗi endpoint có description
- [ ] Request/response schemas documented
- [ ] Authentication method documented
- [ ] Error codes listed
- [ ] Examples cho mỗi endpoint

---

## Step 8: Fix (Optional)

Nếu user confirm, tự động:

1. **Generate missing OpenAPI spec** từ route definitions
2. **Fix naming inconsistencies** (rename endpoints)
3. **Add missing validation** (Form Request / Zod schemas)
4. **Generate Postman collection** từ OpenAPI spec

```bash
# Generate OpenAPI from Laravel routes
php artisan l5-swagger:generate

# Generate from Express/Nest annotations
npx tsoa spec-and-routes

# Generate Postman collection
npx openapi-to-postmanv2 -s openapi.yaml -o postman_collection.json
```

---

## Output Report

```markdown
## API Design Report

### Score: XX/100

| Category | Score | Issues |
|----------|-------|--------|
| Naming | X/20 | [list] |
| Response Format | X/20 | [list] |
| Security | X/20 | [list] |
| Pagination | X/15 | [list] |
| Versioning | X/10 | [list] |
| Documentation | X/15 | [list] |
```

---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| Route scan fails | Check framework version, ensure routes are defined |
| OpenAPI parse error | Validate YAML syntax: `npx @apidevtools/swagger-cli validate openapi.yaml` |
| Missing auth middleware | Check kernel/middleware registration |




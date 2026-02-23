---
description: Validate API design, contracts, and documentation
---

# /api-design — API Design Validator

// turbo-all

Validate API endpoints, response formats, and documentation against best practices.

## Steps

### Step 1: Detect API Type

```
Auto-detect:
├── OpenAPI/Swagger spec found    → Validate spec
├── GraphQL schema found          → Validate schema
├── REST endpoints (Express/Laravel/Next.js) → Scan routes
└── tRPC router found             → Validate procedures
```

### Step 2: Run Validator

```bash
python .agent/skills/api-patterns/scripts/api_validator.py --root .
```

### Step 3: Review Results

**Output:** Report with:
- Endpoint naming consistency (kebab-case, versioning)
- Response format compliance (RFC 7807 errors)
- Missing documentation per endpoint
- Authentication/authorization coverage
- Pagination pattern consistency

### Step 4: Fix (optional)

If user confirms, generate missing OpenAPI specs or fix naming issues.

**Agent:** `backend-specialist`

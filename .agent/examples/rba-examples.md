# RBA Examples - Real-World Scenarios

**Purpose:** 5 complete examples showing Reasoning-Before-Action protocol in practice

**Version:** 1.0.0  
**Location:** `.agent/examples/rba-examples.md`

---

## Example 1: Adding New API Endpoint

**User Request:** "Create endpoint to list users"

### REASONING BLOCK

```yaml
analysis:
  objective: "Create GET /api/users endpoint for user listing with pagination"
  scope: "routes/api.php, app/Http/Controllers/UserController.php, app/Http/Resources/UserResource.php"
  dependencies: "User model exists, auth middleware configured, API routes file exists"

potential_impact:
  affected_modules:
    - "API routes: +1 GET endpoint"
    - "UserController: +1 index method"
    - "New UserResource for response formatting"
  
  breaking_changes: "No - new endpoint, backward compatible"
  
  rollback_plan: "1. Remove route from api.php, 2. Delete index() method from UserController, 3. Delete UserResource.php if created"

edge_cases:
  case_1:
    scenario: "No users in database"
    handling: "Return empty array [] with 200 status and pagination meta"
  
  case_2:
    scenario: "User not authenticated"
    handling: "Auth middleware returns 401 before reaching controller"
  
  case_3:
    scenario: "Too many users (10,000+) - performance concern"
    handling: "Use pagination (20 per page), add index on users.created_at"
  
  case_4:
    scenario: "Client requests page beyond available data"
    handling: "Return empty array with pagination showing total pages"

validation_criteria:
  - "Route registered: php artisan route:list shows GET /api/users"
  - "Returns JSON array with valid User data structure"
  - "Pagination works: ?page=2 returns second page"
  - "Auth required: unauthenticated request returns 401"
  - "Performance: query uses SELECT id,name,email (not all columns)"

decision: "PROCEED"
reason: "All dependencies met (User model, auth middleware), edge cases covered including performance, no breaking changes, rollback plan clear"
```

### Implementation

```php
// routes/api.php
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/users', [UserController::class, 'index']);
});

// app/Http/Controllers/UserController.php
public function index()
{
    $users = User::select('id', 'name', 'email', 'created_at')
        ->latest()
        ->paginate(20);
    
    return UserResource::collection($users);
}

// app/Http/Resources/UserResource.php
class UserResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'created_at' => $this->created_at->toISOString(),
        ];
    }
}
```

---

## Example 2: Database Schema Change

**User Request:** "Change User ID from integer to UUID"

### REASONING BLOCK

```yaml
analysis:
  objective: "Migrate User primary key from auto-increment integer to UUID for better scalability and security"
  scope: "database/migrations/*_modify_users_table.php, app/Models/User.php, all models with user_id foreign key"
  dependencies: "Existing User table, foreign key relationships mapped, backup database before migration"

potential_impact:
  affected_modules:
    - "User model: change id type, add UUID trait"
    - "Posts model: user_id foreign key type change"
    - "Comments model: user_id foreign key type change"
    - "All API responses: ID now string instead of integer"
  
  breaking_changes: "YES - API responses change (ID type), existing client apps may break if they assume integer ID"
  
  rollback_plan: "1. Rollback migration (php artisan migrate:rollback), 2. Revert model changes, 3. Restore database from backup if data corrupted"

edge_cases:
  case_1:
    scenario: "Existing records with integer IDs in production"
    handling: "Migration includes data transformation: generate UUID for each existing record, update all foreign keys"
  
  case_2:
    scenario: "Foreign key constraints break during migration"
    handling: "Migration disables foreign keys, transforms data, re-enables with new UUIDs"
  
  case_3:
    scenario: "Client app parses ID as integer"
    handling: "Add API version /api/v2/users with UUID, keep /api/v1/users for backward compat (deprecated)"
  
  case_4:
    scenario: "Migration fails halfway (network/timeout)"
    handling: "Wrap in database transaction, auto-rollback on error, log failure point"

validation_criteria:
  - "All existing users have valid UUID"
  - "All foreign keys updated correctly"
  - "API returns UUID strings"
  - "Existing functionality unaffected"
  - "Performance: UUID indexing works (test query speed)"

decision: "ESCALATE"
reason: "BREAKING CHANGE - requires user approval. Migration complex with high risk. Need confirmation on: 1) Accept breaking API change? 2) Versioning strategy? 3) Production migration window? 4) Backup verified?"
```

**Outcome:** Wait for user decision before proceeding

---

## Example 3: Adding Third-Party Package

**User Request:** "Add image upload functionality"

### REASONING BLOCK

```yaml
analysis:
  objective: "Install and configure Spatie Media Library for handling image uploads with automatic thumbnails"
  scope: "composer.json, config/media-library.php, app/Models/Post.php (add HasMedia), database/migrations/*_create_media_table.php"
  dependencies: "GD/Imagick PHP extension for image manipulation, writable storage/app/public directory"

potential_impact:
  affected_modules:
    - "Composer dependencies: +spatie/laravel-medialibrary"
    - "Database: +new media table"
    - "Post model: +HasMedia trait, +media relationship"
    - "Storage: new media/* directories"
  
  breaking_changes: "No - additive change, existing functionality unchanged"
  
  rollback_plan: "1. composer remove spatie/laravel-medialibrary, 2. Remove HasMedia trait from Post, 3. Rollback media table migration, 4. Delete media config file"

edge_cases:
  case_1:
    scenario: "Uploaded image exceeds PHP upload_max_filesize"
    handling: "Validate file size before upload, return 422 with clear error if too large"
  
  case_2:
    scenario: "Uploaded file is not an image (e.g., .exe file)"
    handling: "Validate MIME type (image/jpeg, image/png only), reject invalid types"
  
  case_3:
    scenario: "Disk full during upload"
    handling: "Laravel storage exception, catch and return 507 Insufficient Storage"
  
  case_4:
    scenario: "Concurrent uploads of same filename"
    handling: "Media library auto-generates unique names, no conflict"

validation_criteria:
  - "composer show spatie/laravel-medialibrary returns installed version"
  - "php artisan migrate creates media table successfully"
  - "Post model can attach images: $post->addMedia($file)"
  - "Thumbnails generated automatically"
  - "Original + thumbnail stored in storage/app/public/media"

decision: "PROCEED"
reason: "Dependencies available (GD extension confirmed), edge cases handled by package built-in validation, no breaking changes, rollback straightforward"
```

### Implementation Notes

```bash
# Installation
composer require "spatie/laravel-medialibrary:^11.0"
php artisan vendor:publish --provider="Spatie\MediaLibrary\MediaLibraryServiceProvider"
php artisan migrate
```

---

## Example 4: Refactoring Complex Method

**User Request:** "Simplify the createOrder() method - it's too complex"

### REASONING BLOCK

```yaml
analysis:
  objective: "Refactor OrderService::createOrder() from 87 lines to multiple focused methods following Single Responsibility Principle"
  scope: "app/Services/OrderService.php"
  dependencies: "Existing tests for createOrder() must still pass, no changes to public API"

potential_impact:
  affected_modules:
    - "OrderService: split createOrder() into 5 private methods"
    - "No external impact (internal refactor only)"
  
  breaking_changes: "No - public interface unchanged, only internal structure"
  
  rollback_plan: "Git revert to previous commit (refactor is single commit), all tests must pass first"

edge_cases:
  case_1:
    scenario: "Refactor introduces subtle bug (logic error)"
    handling: "Comprehensive test suite runs before commit - 32 existing tests must pass"
  
  case_2:
    scenario: "New methods have different error handling"
    handling: "Preserve exact try/catch behavior from original, test all error paths"
  
  case_3:
    scenario: "Performance regression from method call overhead"
    handling: "Run performance test: createOrder() must complete <100ms (current: 87ms)"

validation_criteria:
  - "All 32 existing tests pass"
  - "Cyclomatic complexity <10 per method (was 24)"
  - "No new bugs introduced (confirmed by tests)"
  - "Performance maintained or improved"
  - "Code coverage remains 92%"

decision: "PROCEED"
reason: "Low risk: comprehensive test coverage exists (92%), no external API changes, performance benchmarked, easy rollback via git"
```

### Refactoring Plan

```php
// Before (87 lines, complexity 24)
public function createOrder($data) {
    // validation
    // inventory check
    // calculate totals
    // apply discounts
    // create order record
    // reduce inventory
    // send notifications
    // log audit
}

// After (5 focused methods)
public function createOrder($data) {
    $validated = $this->validateOrderData($data);
    $this->checkInventoryAvailability($validated['items']);
    $totals = $this->calculateOrderTotals($validated);
    $order = $this->persistOrder($validated, $totals);
    $this->processPostOrderActions($order);
    return $order;
}

private function validateOrderData($data) { /* ... */ }
private function checkInventoryAvailability($items) { /* ... */ }
private function calculateOrderTotals($data) { /* ... */ }
private function persistOrder($data, $totals) { /* ... */ }
private function processPostOrderActions($order) { /* ... */ }
```

---

## Example 5: Emergency Security Patch

**User Request:** "Fix SQL injection vulnerability in search"

### REASONING BLOCK

```yaml
analysis:
  objective: "Replace raw SQL in ProductController::search() with parameterized query to prevent SQL injection"
  scope: "app/Http/Controllers/ProductController.php (search method only)"
  dependencies: "No new dependencies - using existing Eloquent Query Builder"

potential_impact:
  affected_modules:
    - "ProductController::search() - implementation change only"
    - "Search functionality behavior unchanged (same results)"
  
  breaking_changes: "No - output identical, only security improvement"
  
  rollback_plan: "Git revert (but NOT recommended - reverts security fix!). If new implementation buggy, fix forward instead."

edge_cases:
  case_1:
    scenario: "Search query contains SQL keywords (SELECT, DROP)"
    handling: "Parameterized query treats as literal strings, safe"
  
  case_2:
    scenario: "Search query empty string"
    handling: "Query builder handles empty string safely, returns all products"
  
  case_3:
    scenario: "Search query contains wildcards (%_)"
    handling: "Escape wildcards if literal search, or use LIKE with placeholders"
  
  case_4:
    scenario: "Malicious input: '; DROP TABLE products--"
    handling: "Parameterized query prevents execution, treated as literal search string"

validation_criteria:
  - "SQL injection test suite passes (10 attack vectors)"
  - "Search results identical to before fix"
  - "Performance unchanged (query plan same)"
  - "No errors with special characters"

decision: "PROCEED"
reason: "CRITICAL SECURITY FIX - must deploy immediately. Extensive SQL injection test suite confirms safety. No breaking changes to functionality."
```

### Implementation

```php
// ❌ BEFORE (Vulnerable)
public function search(Request $request)
{
    $query = $request->input('q');
    $results = DB::select("SELECT * FROM products WHERE name LIKE '%{$query}%'");
    return response()->json($results);
}

// ✅ AFTER (Secure)
public function search(Request $request)
{
    $query = $request->input('q');
    $results = Product::where('name', 'LIKE', "%{$query}%")->get();
    return response()->json($results);
}
```

**Tests:** Attempted SQL injection attacks return safe results:
```
Input: "'; DROP TABLE products--"
Output: No products named "'; DROP TABLE products--" (safe)
```

---

## Summary

**5 Examples Demonstrate:**

1. **New Feature** - Comprehensive edge case analysis
2. **Breaking Change** - ESCALATE for user approval
3. **Dependencies** - External package risk assessment
4. **Refactoring** - Test-driven safety validation
5. **Security** - Critical fix priority handling

**Key Patterns:**
- ✅ Always 3+ edge cases
- ✅ Specific rollback plans
- ✅ Decision aligned with analysis
- ✅ PROCEED when safe, ESCALATE when risky

---

**Created:** 2026-01-17  
**Version:** 1.0.0  
**Purpose:** Reference examples for RBA protocol implementation

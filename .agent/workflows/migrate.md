---
description: "Nâng cấp phiên bản framework và tự động chuyển đổi mã nguồn tương thích."
---

# /migrate - Framework Migration Workflow

// turbo-all

Automated migration between framework versions with intelligent code transformation and deprecation handling.

---

## When to Use

- Upgrading to new framework version
- Migrating between frameworks (e.g., Vue 2 → Vue 3)
- Modernizing legacy code
- Adopting new framework features
- Security updates requiring version bump

---

## Input Required

```
Migration details:
1. Framework & current version (e.g., Laravel 10)
2. Target version (e.g., Laravel 12)
3. Migration scope:
   - Full project
   - Specific modules
4. Risk tolerance: Safe only | Include deprecations
```

---

## Workflow Steps

### Step 1: Compatibility Analysis

**Detect breaking changes:**

```javascript
// Example: Laravel 10 → 12 Migration

Analyzing project...

Framework: Laravel 10.48 → Laravel 12.x

Breaking Changes Detected:
🔴 CRITICAL (3):
1. ❌ String helpers removed (Str::snake → use Str facade)
2. ❌ assertSee() HTML escaping changed
3. ❌ Route model binding changed (breaking)

🟡 DEPRECATED (8):
4. ⚠️ Carbon 2.x → Carbon 3 (method signatures)
5. ⚠️ array() → [] short syntax
6. ⚠️ Old HTTP client → new HTTP facade
7. ⚠️ Date facades deprecated

🟢 NEW FEATURES (12):
8. ✨ Laravel Prompts
9. ✨ Process improvements
10. ✨ Health routing
11. ✨ Number formatting

Dependencies requiring updates:
- laravel/framework: 10.x → 12.x
- laravel/sanctum: 3.x → 4.x
- spatie/laravel-permission: 5.x → 6.x
```

**Agent:** Framework specialist + `project-planner`
**Skills:** `deployment-procedures, database-design`

---

### Step 2: Generate Migration Plan

**Step-by-step transformation:**

```markdown
## Laravel 10 → 12 Migration Plan

### Phase 1: Dependencies (Low Risk)
**Time:** 15 minutes

1. Update composer.json
   ```json
   "laravel/framework": "^12.0"
   ```

2. Run composer update
   ```bash
   composer update
   ```

3. Publish new config files
   ```bash
   php artisan vendor:publish --tag=laravel-assets
   ```

---

### Phase 2: Code Transformations (Medium Risk)
**Time:** 1-2 hours

#### 2.1 String Helper Migration
**Files affected:** 47 files

**Before:**
```php
use Illuminate\Support\Str;

$snake = Str::snake('fooBar'); // ❌ Removed
```

**After:**
```php
use Illuminate\Support\Str;

$snake = Str::snake('fooBar'); // ✅ Still works via facade
```

**Auto-fixable:** Yes

---

#### 2.2 assertSee() Migration
**Files affected:** 23 test files

**Before:**
```php
$response->assertSee('Welcome'); // No escaping
```

**After:**
```php
$response->assertSee('Welcome', false); // Explicit no-escape
// OR
$response->assertSeeText('Welcome'); // Use new method
```

**Auto-fixable:** Partially (needs review)

---

### Phase 3: Feature Adoption (Optional)
**Time:** 30 minutes

Adopt new Laravel 12 features:
- [ ] Use Laravel Prompts for CLI
- [ ] Implement Health checks
- [ ] Use new Number helpers
- [ ] Adopt Pest 3 improvements

---

### Phase 4: Testing
**Time:** 1 hour

1. Run test suite
2. Manual QA critical paths
3. Performance regression tests
```

**Agent:** Framework specialist

---

### Step 3: Automated Code Transformation

**AST-based code modifications:**

```php
// Transformation engine
class Laravel12Migrator {
    public function transform($code) {
        $ast = $this->parse($code);
        
        // Apply transformations
        $ast = $this->migrateStringHelpers($ast);
        $ast = $this->migrateAssertions($ast);
        $ast = $this->migrateHttpClient($ast);
        $ast = $this->modernizeSyntax($ast);
        
        return $this->generate($ast);
    }
    
    private function migrateStringHelpers($ast) {
        // Find: str_snake()
        // Replace: Str::snake()
        return $this->replaceHelpers($ast, [
            'str_snake' => 'Str::snake',
            'str_camel' => 'Str::camel',
            'array_get' => 'Arr::get',
        ]);
    }
}
```

**Example transformations:**

```php
// File: app/Http/Controllers/UserController.php

// BEFORE (Laravel 10)
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function store(Request $request)
    {
        // Old validation
        $this->validate($request, [
            'email' => 'required|email'
        ]);
        
        // Old HTTP client
        $response = Http::get('https://api.example.com');
        
        // Old helper
        $snake = str_snake('fooBar');
    }
}

// AFTER (Laravel 12) - Auto-transformed
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class UserController extends Controller
{
    public function store(Request $request)
    {
        // Modern validation
        $request->validate([
            'email' => 'required|email'
        ]);
        
        // New HTTP facade
        $response = Http::get('https://api.example.com');
        
        // Facade method
        $snake = Str::snake('fooBar');
    }
}
```

**Agent:** Framework specialist

---

### Step 4: Update Tests

**Test migration:**

```php
// BEFORE (Laravel 10 tests)
public function test_user_can_register()
{
    $response = $this->post('/register', [
        'name' => 'John',
        'email' => 'john@example.com'
    ]);
    
    $response->assertSee('Welcome John'); // ❌ Changed behavior
}

// AFTER (Laravel 12 tests)
public function test_user_can_register()
{
    $response = $this->post('/register', [
        'name' => 'John',
        'email' => 'john@example.com'
    ]);
    
    // Option 1: Explicit unescaped
    $response->assertSee('Welcome John', false);
    
    // Option 2: Use new method (recommended)
    $response->assertSeeText('Welcome John');
}
```

**Agent:** `test-engineer`

---

### Step 5: Dependency Updates

**Update package.json / composer.json:**

```bash
# Update Laravel packages
composer update laravel/framework:^12.0
composer update laravel/sanctum:^4.0

# Update npm packages (if needed)
npm update @vitejs/plugin-laravel@latest

# Check for security updates
composer audit
npm audit
```

---

### Step 6: Configuration Migration

**Update config files:**

```php
// config/app.php - Example changes

// BEFORE (Laravel 10)
'timezone' => 'UTC',
'locale' => 'en',

// AFTER (Laravel 12) - New options
'timezone' => env('APP_TIMEZONE', 'UTC'),
'locale' => env('APP_LOCALE', 'en'),
'faker_locale' => env('APP_FAKER_LOCALE', 'en_US'), // New

// New health check route
'health' => [
    'path' => env('HEALTH_PATH', '/up'),
];
```

---

### Step 7: Run Migration

**Execute migration with safety checks:**

```bash
Migration Steps:

✅ 1. Backup database
✅ 2. Backup codebase (git commit)
✅ 3. Update dependencies (composer update)
✅ 4. Transform code (47 files modified)
✅ 5. Update config files
✅ 6. Clear caches
     php artisan config:clear
     php artisan cache:clear
     php artisan view:clear
✅ 7. Run migrations
     php artisan migrate
✅ 8. Run tests
     php artisan test

Test Results:
- Unit: 145/145 ✅
- Feature:  89/89 ✅
- Total: 234/234 ✅

✅ Migration completed successfully!
```

---

### Step 8: Post-Migration Verification

**Verify functionality:**

```javascript
Post-Migration Checklist:

Functionality:
✅ Authentication works
✅ Database connections OK
✅ API endpoints responsive
✅ Queue jobs processing
✅ Scheduled tasks running

Performance:
✅ No performance regressions
✅ Memory usage normal
✅ Response times OK

Security:
✅ No new vulnerabilities
✅ Dependencies up to date
✅ Tests passing
```

**Agent:** Framework specialist + `debugger`

---

## Agent Orchestration

```
1. {framework}-specialist
   └── Analyze breaking changes
   └── Generate migration plan
   
2. project-planner
   └── Review dependencies
   └── Assess risk
   
3. {framework}-specialist
   └── Execute code transformations
   └── Update configurations
   
4. test-engineer
   └── Update tests
   └── Verify test coverage
   
5. debugger
   └── Run test suite
   └── Verify functionality
   
6. {framework}-specialist
   └── Post-migration validation
   └── Generate report
```

---

## Supported Migrations

**Backend:**
- Laravel 10 → 11 → 12
- FastAPI 0.100 → 0.110+
- Django 4 → 5
- Node.js 16 → 18 → 20

**Frontend:**
- Vue 2 → Vue 3
- React 17 → 18 → 19
- Angular 15 → 16 → 17
- Webpack → Vite

---

## Error Handling

**If tests fail after migration:**
```
→ debugger analyzes failures
→ Rollback if critical
→ Fix issues incrementally
→ Re-run tests
```

**If dependencies conflict:**
```
→ Identify conflicts
→ Find compatible versions
→ Update composer/package constraints
```

---

## Success Criteria

✅ All dependencies updated  
✅ All tests passing  
✅ No deprecation warnings  
✅ Performance maintained  
✅ Security improved

---

## Example Usage

**User request:**
```
/migrate --from=laravel-10 --to=laravel-12
```

**Agent response:**
```
🔍 Analyzing Laravel 10 → 12 migration...

Breaking Changes:
- 🔴 3 critical issues
- 🟡 8 deprecations
- ✨ 12 new features available

📋 Migration Plan:
1. Update dependencies (15 min)
2. Transform code (1-2 hours)
3. Update tests (30 min)
4. Verify (1 hour)

Estimated time: 2-3 hours
Risk level: MEDIUM

Proceed with migration? (yes/no)

[User: yes]

✅ Migrating...
✅ Updated 47 files
✅ Updated 23 test files
✅ All tests pass (234/234)

🎉 Migration complete!
Laravel 12.0 is now active.

New features available:
- Laravel Prompts
- Health routing
- Number formatting

Recommended: Review new features documentation
```

---

## Tips

💡 **Always backup first:** Git commit + database dump  
💡 **Test in staging:** Don't migrate production directly  
💡 **Read changelog:** Understand breaking changes  
💡 **Incremental updates:** Don't skip major versions  
💡 **Monitor after deploy:** Watch for issues


---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| Migration fails mid-way | Rollback DB, check migration file syntax |
| Breaking changes detected | Tạo adapter layer, deprecate gradually |
| Dependencies conflict | Resolve version conflicts trong lock file |
| Data loss risk | Chạy `/backup` trước, test trên staging |




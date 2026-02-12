---
description: Tạo module CRUD hoàn chỉnh theo framework
---

# /scaffold - Feature Scaffolding Workflow

Auto-generate complete, production-ready feature modules following framework best practices.

---

## When to Use

- Starting a new feature (e.g., User Management, Blog Posts, Shopping Cart)
- Need complete CRUD with tests
- Want consistent code structure
- Following framework conventions

---

## Input Required

```
Feature details:
1. Feature name (e.g., "User", "Post", "Product")
2. Framework (Laravel, React, Vue, FastAPI, etc.)
3. Fields/attributes (name:string, email:string:unique, etc.)
4. Relationships (optional: belongsTo, hasMany, etc.)
```

---

## Workflow Steps

### Step 1: Understand Requirements

**Ask user:**
```
What feature are you building?
- Feature name: _______________
- Framework: _______________
- Database fields: _______________
- Relationships: _______________
- Additional requirements: _______________
```

**Agent:** `project-planner`

---

### Step 2: Detect Framework & Load Standards

```javascript
// Auto-detect or use specified framework
const framework = detectFramework() || userInput.framework;

// Load appropriate conventions
loadStandards(framework); // laravel-conventions.md, etc.
```

**Agent:** `project-planner` + framework specialist

---

### Step 3: Generate File Structure

**For Laravel (example):**

```php
// 1. Model
app/Models/{Feature}.php
- Eloquent model
- Fillable fields
- Relationships
- Casts

// 2. Migration
database/migrations/{timestamp}_create_{features}_table.php
- Schema definition
- Indexes
- Foreign keys

// 3. Controller
app/Http/Controllers/{Feature}Controller.php
- index, create, store, show, edit, update, destroy
- Form requests
- Authorization

// 4. Form Requests
app/Http/Requests/Store{Feature}Request.php
app/Http/Requests/Update{Feature}Request.php
- Validation rules
- Authorization

// 5. Resource (API)
app/Http/Resources/{Feature}Resource.php
- JSON transformation

// 6. Routes
routes/web.php or routes/api.php
- Resource routes

// 7. Tests
tests/Feature/{Feature}Test.php
- CRUD tests
- Validation tests

// 8. Factory & Seeder
database/factories/{Feature}Factory.php
database/seeders/{Feature}Seeder.php
```

**Agent:** `laravel-specialist` (or appropriate framework specialist)

---

### Step 4: Generate Code with Best Practices

**Example: Laravel User Feature**

```php
// app/Models/User.php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable
{
    use HasFactory;

    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }
}
```

```php
// app/Http/Controllers/UserController.php
<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Http\Requests\StoreUserRequest;
use App\Http\Requests\UpdateUserRequest;

class UserController extends Controller
{
    public function index()
    {
        $users = User::paginate(15);
        return view('users.index', compact('users'));
    }

    public function store(StoreUserRequest $request)
    {
        $user = User::create($request->validated());
        return redirect()->route('users.show', $user)
            ->with('success', 'User created successfully.');
    }

    // ... other methods
}
```

**Agent:** Framework specialist

---

### Step 5: Generate Tests

```php
// tests/Feature/UserTest.php
<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class UserTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_list_users()
    {
        User::factory()->count(3)->create();

        $response = $this->get('/users');

        $response->assertStatus(200);
        $response->assertViewHas('users');
    }

    public function test_can_create_user()
    {
        $data = [
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'password' => 'password123',
        ];

        $response = $this->post('/users', $data);

        $response->assertRedirect();
        $this->assertDatabaseHas('users', [
            'email' => 'john@example.com',
        ]);
    }
}
```

**Agent:** `test-engineer`

---

### Step 6: Verify & Report

**Checklist:**
- [ ] All files created
- [ ] Code follows framework conventions
- [ ] Tests pass
- [ ] No linting errors
- [ ] Migration runs successfully

**Agent:** `debugger`

---

## Agent Orchestration

```
1. project-planner
   └── Understand requirements, plan structure

2. {framework}-specialist (e.g., laravel-specialist)
   └── Generate models, controllers, views
   └── Follow framework conventions
   
3. test-engineer
   └── Generate comprehensive tests
   
4. debugger
   └── Verify all files work together
   └── Run tests
```

---

## Error Handling

**If framework not detected:**
```
→ Ask user to specify framework
→ List available frameworks
```

**If validation fails:**
```
→ Show validation errors
→ Ask user to fix fields/types
```

**If tests fail:**
```
→ debugger investigates
→ Fix generated code
→ Re-run tests
```

---

## Success Criteria

✅ All files generated  
✅ Code follows conventions  
✅ Tests pass  
✅ No linting errors  
✅ Feature works end-to-end

---

## Example Usage

**User request:**
```
/scaffold User with name, email, password in Laravel
```

**Agent response:**
```
✅ Generated Laravel User feature:

Files created:
- app/Models/User.php
- app/Http/Controllers/UserController.php
- app/Http/Requests/StoreUserRequest.php
- app/Http/Requests/UpdateUserRequest.php
- database/migrations/2024_01_01_000000_create_users_table.php
- tests/Feature/UserTest.php
- database/factories/UserFactory.php

Routes added to routes/web.php:
Route::resource('users', UserController::class);

✅ Tests: 8 passed
✅ Migration: Ready to run

Next steps:
1. Run: php artisan migrate
2. Test: php artisan test
3. Visit: /users
```

---

## Framework Support

**Supported:**
- Laravel → Full CRUD with Eloquent
- React → Component + hooks + tests
- Vue → Component + Composables + tests
- FastAPI → Routes + models + Pydantic
- Django → Models + views + serializers
- React Native → Screens + navigation

---

## Tips

💡 **Use descriptive names:** "BlogPost" not "BP"  
💡 **Specify field types:** "price:decimal" not just "price"  
💡 **Add validation early:** Include required, unique constraints  
💡 **Think relationships:** Plan hasMany, belongsTo upfront

---
description: Tái cấu trúc code thông minh
---

# /refactor - Smart Refactoring Workflow

Automatically refactor code with pattern detection, best practices, and maintainability improvements.

---

## When to Use

- Code smells detected (long functions, duplicated code)
- Improving maintainability
- Applying design patterns
- Modernizing legacy code
- Pre-PR cleanup

---

## Input Required

```
Refactoring target:
1. File/component path
2. Refactoring goal (optional):
   - Extract functions
   - Apply design pattern
   - Improve readability
   - Reduce complexity
   - Modern syntax
```

---

## Workflow Steps

### Step 1: Analyze Code

**Automated analysis:**
```javascript
// Detect code smells
const issues = analyzeCode(file);

Issues detected:
- Long function (>50 lines): processOrder()
- Duplicated code: validateEmail() appears 3 times
- Complex conditionals: nested if >3 levels
- Magic numbers: 42, 100, 3.14
- No type hints
```

**Agent:** `debugger` + `code-review-checklist` skill

---

### Step 2: Pattern Detection

**Identify applicable patterns:**
```
Detected opportunities:
✅ Strategy Pattern → Replace switch statement
✅ Repository Pattern → Database access scattered
✅ Factory Pattern → Complex object creation
✅ Decorator Pattern → Extending behavior
```

**Agent:** `architecture` skill

---

### Step 3: Generate Refactoring Plan

**Example plan:**

```markdown
## Refactoring Plan for UserController.php

### Issues Found:
1. 🔴 CRITICAL: processOrder() is 120 lines (limit: 50)
2. 🟡 WARNING: Duplicated validation logic (3 places)
3. 🟡 WARNING: No dependency injection
4. 🟢 INFO: Can use modern PHP 8.3 syntax

### Proposed Changes:

#### 1. Extract Method (processOrder)
**Before:** 120-line monolithic function
**After:** 6 focused functions
- validateOrder()
- calculateTotals()
- applyDiscounts()
- processPayment()
- updateInventory()
- sendNotification()

#### 2. Extract Validation Service
**Create:** app/Services/ValidationService.php
**Move:** Email, phone validation to service
**Benefit:** Reusable, testable

#### 3. Apply Dependency Injection
**Inject:** ValidationService, PaymentGateway
**Remove:** Direct instantiation

#### 4. Modern Syntax
**Use:** Property promotion, readonly, match expressions
```

**Agent:** `project-planner` + appropriate specialist

---

### Step 4: Execute Refactoring

**Before:**
```php
class UserController extends Controller
{
    public function store(Request $request)
    {
        // 120 lines of validation, processing, etc.
        if ($request->email) {
            if (filter_var($request->email, FILTER_VALIDATE_EMAIL)) {
                // ...
            }
        }
        
        $total = 0;
        foreach ($items as $item) {
            $total += $item->price * $item->quantity;
        }
        
        if ($total > 100) {
            $discount = 0.1;
        } else if ($total > 50) {
            $discount = 0.05;
        } else {
            $discount = 0;
        }
        
        // ... 80 more lines
    }
}
```

**After:**
```php
class UserController extends Controller
{
    public function __construct(
        private readonly OrderService $orderService,
        private readonly ValidationService $validator
    ) {}

    public function store(StoreOrderRequest $request): RedirectResponse
    {
        $order = $this->orderService->process($request->validated());
        
        return redirect()
            ->route('orders.show', $order)
            ->with('success', 'Order created successfully.');
    }
}

// New: app/Services/OrderService.php
class OrderService
{
    public function process(array $data): Order
    {
        $order = $this->validateOrder($data);
        $order = $this->calculateTotals($order);
        $order = $this->applyDiscounts($order);
        
        $this->processPayment($order);
        $this->updateInventory($order);
        $this->sendNotification($order);
        
        return $order;
    }
    
    private function calculateTotals(Order $order): Order
    {
        $order->total = $order->items->sum(
            fn($item) => $item->price * $item->quantity
        );
        return $order;
    }
    
    private function applyDiscounts(Order $order): Order
    {
        $order->discount = match(true) {
            $order->total > 100 => 0.1,
            $order->total > 50 => 0.05,
            default => 0
        };
        return $order;
    }
}
```

**Agent:** Framework specialist

---

### Step 5: Update Tests

**Generate new tests for extracted code:**

```php
// tests/Unit/OrderServiceTest.php
class OrderServiceTest extends TestCase
{
    public function test_calculates_totals_correctly()
    {
        $service = new OrderService();
        
        $order = Order::factory()->make([
            'items' => [
                ['price' => 10, 'quantity' => 2],
                ['price' => 5, 'quantity' => 3],
            ]
        ]);
        
        $result = $service->process($order->toArray());
        
        $this->assertEquals(35, $result->total);
    }
}
```

**Agent:** `test-engineer`

---

### Step 6: Verify & Report

**Run checks:**
```bash
# Linting
✅ No linting errors

# Tests
✅ All tests pass (18/18)

# Complexity
✅ Cyclomatic complexity reduced: 15 → 4
✅ Average function length: 35 → 12 lines
✅ Duplication: 15% → 2%
```

**Agent:** `debugger`

---

## Agent Orchestration

```
1. debugger
   └── Analyze code, detect smells
   └── Run complexity metrics
   
2. architecture (skill)
   └── Suggest design patterns
   └── Plan refactoring strategy
   
3. {framework}-specialist
   └── Execute refactoring
   └── Follow framework conventions
   
4. test-engineer
   └── Update/create tests for refactored code
   
5. debugger
   └── Verify no regressions
   └── Run all tests
```

---

## Refactoring Patterns

### 1. Extract Method
**When:** Function >50 lines  
**Do:** Break into smaller, focused functions

### 2. Extract Class
**When:** Class has multiple responsibilities  
**Do:** Create service/helper classes

### 3. Replace Conditional with Polymorphism
**When:** Large switch/if-else on type  
**Do:** Use strategy pattern

### 4. Introduce Parameter Object
**When:** Function has >3 parameters  
**Do:** Group into DTO/Value Object

### 5. Replace Magic Number
**When:** Unexplained constants  
**Do:** Named constants or enums

---

## Error Handling

**If refactoring breaks tests:**
```
→ debugger analyzes failures
→ Revert or fix refactored code
→ Re-run tests
```

**If complexity doesn't improve:**
```
→ Try different approach
→ Consult user for strategy
```

---

## Success Criteria

✅ All tests pass  
✅ Complexity reduced  
✅ Duplication reduced  
✅ Code more readable  
✅ Follows framework conventions

---

## Example Usage

**User request:**
```
/refactor app/Http/Controllers/UserController.php
Goal: Reduce complexity and improve testability
```

**Agent response:**
```
🔍 Analyzing UserController.php...

Issues found:
- store() method: 89 lines (complexity: 12)
- Duplicated validation (3 occurrences)
- Direct database calls (should use repository)

📋 Refactoring Plan:
1. Extract UserService
2. Create UserRepository
3. Extract validation to FormRequest
4. Use dependency injection

Would you like to proceed? (yes/no)

[User: yes]

✅ Refactoring complete!

Changes:
- Created UserService.php (35 lines)
- Created UserRepository.php (42 lines)
- Updated UserController.php (15 lines, was 89)
- Created StoreUserRequest.php (validation)
- Updated tests (12 new unit tests)

Metrics:
- Complexity: 12 → 3 ⬇️ 75%
- Lines per function: 28 → 8 ⬇️ 71%
- Duplication: 15% → 0% ⬇️ 100%
- Test coverage: 65% → 92% ⬆️ 42%

✅ All tests pass (24/24)
```

---

## Tips

💡 **Refactor in small steps:** One pattern at a time  
💡 **Always run tests:** After each change  
💡 **Commit frequently:** Easy to revert  
💡 **Update documentation:** If public API changes  
💡 **Get code review:** Before merging

---
name: testing-mastery
description: "Đỉnh cao kiểm thử tổng hợp: TDD, Contract, Web App End-to-End và Mocking toàn diện ảo."
version: 2.0
consolidates: testing-patterns, tdd-workflow, contract-testing, webapp-testing
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Testing Mastery - Complete Testing Framework

> **Unified Skill:** This consolidates all testing knowledge into one hierarchical structure.

---

## 🎯 Philosophy

**Testing is not optional.** Tests are executable documentation that prove your code works.

**The Testing Pyramid:**
```
           /\
          /E2E\         ← Few (10%)
         /------\
        /Integration\    ← Some (30%)
       /------------\
      /    Unit      \   ← Many (60%)
     /----------------\
```

**Rule:** Write tests at the lowest level possible.

---

## 📚 Quick Navigation

**By Need:**
- **New to testing?** → Start with [Testing Fundamentals](#testing-fundamentals)
- **Want TDD?** → See [TDD Methodology](./methodologies/tdd.md)
- **API testing?** → See [Contract Testing](./methodologies/contract-testing.md)
- **E2E testing?** → See [Web App Testing](./methodologies/webapp-testing.md)

---

## 🧪 Testing Fundamentals

### What Makes a Good Test?

**F.I.R.ST Principles:**
- **Fast:** Runs in milliseconds
- **Independent:** No dependencies on other tests
- **Repeatable:** Same result every time
- **Self-Validating:** Pass/fail, no manual inspection
- **Timely:** Written before or with code

---

### The 3 A's Pattern

**Every test should follow:**
```typescript
test('user can login with valid credentials', () => {
  // Arrange: Set up test data
  const user = { email: 'test@example.com', password: 'secret' }
  
  // Act: Perform the action
  const result = login(user)
  
  // Assert: Verify outcome
  expect(result.success).toBe(true)
})
```

---

## 📋 Testing Types

### 1. Unit Tests (60% of tests)

**What:** Test individual functions/methods in isolation

**When:**
- Business logic functions
- Utility functions
- Pure functions
- Validation logic

**Example (TypeScript):**
```typescript
// Function to test
export function calculateDiscount(price: number, percentage: number): number {
  if (price < 0) throw new Error('Price cannot be negative')
  if (percentage < 0 || percentage > 100) throw new Error('Invalid percentage')
  return price * (percentage / 100)
}

// Unit test
import { describe, test, expect } from 'vitest'

describe('calculateDiscount', () => {
  test('calculates 10% discount correctly', () => {
    expect(calculateDiscount(100, 10)).toBe(10)
  })
  
  test('throws on negative price', () => {
    expect(() => calculateDiscount(-100, 10)).toThrow('Price cannot be negative')
  })
  
  test('throws on invalid percentage', () => {
    expect(() => calculateDiscount(100, 150)).toThrow('Invalid percentage')
  })
})
```

**✅ Good practices:**
- Test one thing per test
- Use descriptive test names
- Cover edge cases
- Test error conditions

---

### 2. Integration Tests (30% of tests)

**What:** Test multiple units working together

**When:**
- API endpoints
- Database operations
- External service integration
- Multi-layer interactions

**Example (Laravel):**
```php
// Integration test
public function test_user_can_create_post()
{
    $user = User::factory()->create();
    
    $response = $this->actingAs($user)
        ->postJson('/api/posts', [
            'title' => 'Test Post',
            'content' => 'Test content',
        ]);
    
    $response->assertStatus(201);
    $this->assertDatabaseHas('posts', [
        'title' => 'Test Post',
        'user_id' => $user->id,
    ]);
}
```

**✅ Good practices:**
- Use factories for test data
- Clean up after tests
- Test happy path + error paths
- Verify database state

---

### 3. E2E Tests (10% of tests)

**What:** Test complete user workflows in real browser

**When:**
- Critical user journeys
- Multi-step processes
- UI interactions
- Cross-browser testing

**Example (Playwright):**
```typescript
import { test, expect } from '@playwright/test'

test('user can complete checkout', async ({ page }) => {
  // Navigate
  await page.goto('/products')
  
  // Add to cart
  await page.click('[data-testid="add-to-cart"]')
  
  // Proceed to checkout
  await page.click('[data-testid="checkout"]')
  
  // Fill form
  await page.fill('[name="email"]', 'test@example.com')
  await page.fill('[name="card"]', '4242424242424242')
  
  // Submit
  await page.click('[data-testid="submit-payment"]')
  
  // Verify success
  await expect(page).toHaveURL('/order/confirmation')
  await expect(page.locator('.success-message')).toBeVisible()
})
```

**✅ Good practices:**
- Test critical paths only
- Use data-testid attributes
- Avoid brittle selectors
- Run in CI/CD

---

## 🎯 Testing Methodologies

### TDD (Test-Driven Development)

**Full guide:** [methodologies/tdd.md](./methodologies/tdd.md)

**Quick workflow:**
```
1. Write failing test (RED)
2. Write minimal code to pass (GREEN)
3. Refactor (REFACTOR)
4. Repeat
```

**When to use:**
- Complex business logic
- API development
- When requirements are clear

---

### Contract Testing

**Full guide:** [methodologies/contract-testing.md](./methodologies/contract-testing.md)

**What:** Verify API contracts between services

**Use case:**
- Microservices
- API providers/consumers
- Frontend/Backend contracts

---

### Web App Testing

**Full guide:** [methodologies/webapp-testing.md](./methodologies/webapp-testing.md)

**What:** Browser-based testing (Playwright, Cypress)

**Use case:**
- Critical user flows
- Cross-browser testing
- Visual regression

---

## 📊 Coverage Guidelines

### Target Coverage

| Type | Minimum | Target | Reality Check |
|------|---------|--------|---------------|
| **Unit** | 70% | 80%+ | Focus on business logic |
| **Integration** | 60% | 70%+ | Cover API endpoints |
| **E2E** | N/A | Critical flows only | Don't aim for 100% |

**⚠️ Warning:** 100% coverage ≠ bug-free code

---

### What to Test (Priority Order)

**CRITICAL (Always test):**
1. Business logic
2. Authentication/Authorization
3. Payment flows
4. Data validation
5. Error handling

**HIGH (Usually test):**
6. API endpoints
7. Database operations
8. Complex algorithms
9. Edge cases

**MEDIUM (Sometimes test):**
10. UI components
11. Utility functions
12. Configuration

**LOW (Rarely test):**
13. Getters/Setters
14. Simple CRUD
15. Third-party libraries

---

## 🔧 Testing Tools

### JavaScript/TypeScript

**Unit/Integration:**
- **Vitest** (recommended for Vite projects)
- **Jest** (widely used)
- **Testing Library** (React/Vue component testing)

**E2E:**
- **Playwright** (modern, fast, recommended)
- **Cypress** (popular, developer-friendly)

---

### PHP/Laravel

**Unit/Integration:**
- **Pest** (modern, elegant syntax)
- **PHPUnit** (traditional, widely supported)

**Example (Pest):**
```php
it('calculates total price correctly', function () {
    $cart = new Cart();
    $cart->addItem(new Item('Product 1', 100));
    $cart->addItem(new Item('Product 2', 200));
    
    expect($cart->total())->toBe(300);
});
```

---

## ✅ Best Practices

### DO:
- ✅ Write tests first (TDD) or alongside code
- ✅ Test behavior, not implementation
- ✅ Use descriptive test names
- ✅ Keep tests simple and readable
- ✅ Run tests before committing
- ✅ Maintain tests like production code

### DON'T:
- ❌ Test implementation details
- ❌ Write long, complex tests
- ❌ Skip error cases
- ❌ Ignore flaky tests
- ❌ Copy-paste test code
- ❌ Mock everything

---

## 📖 Test Naming Conventions

**Pattern:** `test_subject_scenario_expectedBehavior`

**Examples:**
```
Good:
✅ test_user_login_with_valid_credentials_succeeds
✅ test_cart_checkout_when_empty_throws_error
✅ test_discount_calculation_with_invalid_percentage_fails

Bad:
❌ test1
❌ testLogin
❌ test_something
```

---

## 🎯 When to Use Each Type

**Use Unit Tests when:**
- Testing pure functions
- Testing business logic
- Testing utilities
- Fast feedback needed

**Use Integration Tests when:**
- Testing API endpoints
- Testing database operations
- Testing service interactions
- Testing auth flows

**Use E2E Tests when:**
- Testing critical user journeys
- Testing checkout/payment
- Testing signup/login flows
- Visual/UX validation

---

## 🔗 Related Files

- [TDD Methodology](./methodologies/tdd.md)
- [Contract Testing](./methodologies/contract-testing.md)
- [Web App Testing](./methodologies/webapp-testing.md)

---

## 📚 External Resources

- [Test Pyramid (Martin Fowler)](https://martinfowler.com/articles/practical-test-pyramid.html)
- [Testing Library Principles](https://testing-library.com/docs/guiding-principles/)
- [Playwright Docs](https://playwright.dev/)
- [Pest PHP](https://pestphp.com/)

---

**Created:** 2026-01-19  
**Version:** 2.0 (Consolidated)  
**Replaces:** testing-patterns, tdd-workflow, contract-testing, webapp-testing  
**Structure:** Parent skill with methodology sub-files

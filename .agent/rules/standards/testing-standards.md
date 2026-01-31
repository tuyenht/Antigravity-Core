# Testing Standards

**Version:** 2.0  
**Updated:** 2026-01-16  
**Coverage Target:** 80%+

---

## Testing Pyramid

```
           /\
          /E2E\        10% - End-to-End (Slow, Brittle)
         /______\
        /        \
       /Integration\ 20% - Integration (Medium)
      /____________\
     /              \
    /      Unit      \ 70% - Unit Tests (Fast, Focused)
   /__________________\
```

---

## 1. Unit Testing

### Coverage Requirements
- **Minimum:** 80% code coverage
- **Critical paths:** 100% coverage
- **Utilities:** 100% coverage

### Jest Example
```javascript
// sum.test.js
import { sum } from './sum';

describe('sum function', () => {
  it('adds two positive numbers', () => {
    expect(sum(1, 2)).toBe(3);
  });
  
  it('handles negative numbers', () => {
    expect(sum(-1, -2)).toBe(-3);
  });
  
  it('handles zero', () => {
    expect(sum(0, 5)).toBe(5);
  });
});
```

### React Component Testing
```javascript
import { render, screen, fireEvent } from '@testing-library/react';
import { Counter } from './Counter';

describe('Counter', () => {
  it('increments count on button click', () => {
    render(<Counter />);
    
    const button = screen.getByRole('button', { name: /increment/i });
    const count = screen.getByText(/count: 0/i);
    
    fireEvent.click(button);
    
    expect(screen.getByText(/count: 1/i)).toBeInTheDocument();
  });
});
```

---

## 2. Integration Testing

```javascript
// API integration test
describe('User API', () => {
  it('creates user and returns 201', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({
        name: 'Test User',
        email: 'test@example.com'
      });
    
    expect(response.status).toBe(201);
    expect(response.body).toHaveProperty('id');
    expect(response.body.email).toBe('test@example.com');
  });
});
```

---

## 3. E2E Testing

### Playwright Example
```javascript
import { test, expect } from '@playwright/test';

test('user can login', async ({ page }) => {
  await page.goto('https://example.com/login');
  
  await page.fill('[name="email"]', 'user@example.com');
  await page.fill('[name="password"]', 'password123');
  await page.click('button[type="submit"]');
  
  await expect(page).toHaveURL('/dashboard');
  await expect(page.locator('h1')).toContainText('Welcome');
});
```

---

## 4. Test Data Management

```javascript
// factories/user.factory.js
export function createUser(overrides = {}) {
  return {
    id: faker.string.uuid(),
    name: faker.person.fullName(),
    email: faker.internet.email(),
    createdAt: new Date(),
    ...overrides,
  };
}

// Usage
const user = createUser({ email: 'specific@example.com' });
```

---

## 5. Mocking & Stubbing

```javascript
// Mock API calls
jest.mock('./api');
import { fetchUser } from './api';

fetchUser.mockResolvedValue({ id: 1, name: 'Test' });

// Spy on functions
const spy = jest.spyOn(console, 'error');
// ... test code
expect(spy).toHaveBeenCalledWith('Error message');
spy.mockRestore();
```

---

**References:**
- [Jest Documentation](https://jestjs.io/)
- [Testing Library](https://testing-library.com/)
- [Playwright](https://playwright.dev/)

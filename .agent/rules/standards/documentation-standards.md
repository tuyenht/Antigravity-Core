# Documentation Standards

**Version:** 1.0  
**Updated:** 2026-01-16

---

## 1. README Template

```markdown
# Project Name

Brief description of what this project does.

## Features

- Feature 1
- Feature 2
- Feature 3

## Installation

\`\`\`bash
npm install
cp .env.example .env
npm run dev
\`\`\`

## Usage

\`\`\`javascript
import { MyComponent } from './components';

<MyComponent prop="value" />
\`\`\`

## API Documentation

See [API.md](./API.md)

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md)

## License

MIT
```

---

## 2. JSDoc/TSDoc Comments

```typescript
/**
 * Calculates the total price including tax.
 * 
 * @param {number} subtotal - The subtotal amount
 * @param {number} taxRate - The tax rate (e.g., 0.08 for 8%)
 * @returns {number} The total price with tax included
 * @throws {Error} If subtotal or taxRate is negative
 * 
 * @example
 * const total = calculateTotal(100, 0.08);
 * console.log(total); // 108
 */
function calculateTotal(subtotal: number, taxRate: number): number {
  if (subtotal < 0 || taxRate < 0) {
    throw new Error('Subtotal and tax rate must be non-negative');
  }
  return subtotal * (1 + taxRate);
}
```

---

## 3. Architecture Decision Records (ADR)

```markdown
# ADR 001: Use PostgreSQL for Database

## Status
Accepted

## Context
We need a reliable database for our application.

## Decision
We will use PostgreSQL as our primary database.

## Consequences

### Positive
- ACID compliance
- Strong community support
- Rich feature set (JSON, full-text search)

### Negative
- More complex than NoSQL
- Requires schema management

## Alternatives Considered
- MongoDB: Less structured, harder to maintain consistency
- MySQL: Less feature-rich than PostgreSQL
```

---

## 4. CHANGELOG Format

```markdown
# Changelog

## [Unreleased]

## [1.2.0] - 2026-01-16

### Added
- User profile editing
- Email notifications

### Changed
- Improved dashboard performance
- Updated dependencies

### Fixed
- Login redirect bug
- Mobile navigation issue

### Removed
- Legacy authentication method

## [1.1.0] - 2026-01-10
...
```

---

## 5. Inline Comments

```javascript
// ✅ GOOD - Explains WHY
// Using binary search because array is sorted and large (10k+ items)
const index = binarySearch(sortedArray, target);

// Calculate compound interest using formula: A = P(1 + r/n)^(nt)
const amount = principal * Math.pow(1 + rate / periods, periods * time);

// ❌ BAD - Explains WHAT (obvious from code)
// Increment i by 1
i++;

// Set name to 'John'
const name = 'John';

// ✅ GOOD - Complex logic explanation
// First, filter active users, then group by country,
// finally calculate average age per country
const stats = users
  .filter(u => u.active)
  .reduce((acc, u) => {
    // ... complex logic
  }, {});
```

---

## 6. Component Documentation

```typescript
/**
 * Button component with multiple variants.
 * 
 * @component
 * 
 * @example
 * <Button variant="primary" onClick={handleClick}>
 *   Click Me
 * </Button>
 */
interface ButtonProps {
  /** Button text or content */
  children: React.ReactNode;
  
  /** Visual style variant */
  variant?: 'primary' | 'secondary' | 'danger';
  
  /** Click event handler */
  onClick?: () => void;
  
  /** Whether button is disabled */
  disabled?: boolean;
}

export function Button({ 
  children, 
  variant = 'primary', 
  onClick, 
  disabled = false 
}: ButtonProps) {
  return (
    <button 
      className={`btn btn-${variant}`}
      onClick={onClick}
      disabled={disabled}
    >
      {children}
    </button>
  );
}
```

---

## 7. API Endpoint Documentation

```typescript
/**
 * GET /api/users/:id
 * 
 * Retrieves a single user by ID.
 * 
 * @route GET /api/users/:id
 * @param {string} id.path.required - User ID
 * @returns {User} 200 - User object
 * @returns {Error} 404 - User not found
 * @returns {Error} 500 - Server error
 * @security Bearer
 * 
 * @example
 * // Request
 * GET /api/users/123
 * Authorization: Bearer <token>
 * 
 * // Response (200)
 * {
 *   "id": "123",
 *   "name": "John Doe",
 *   "email": "john@example.com"
 * }
 */
router.get('/users/:id', authenticate, async (req, res) => {
  // Implementation
});
```

---

**References:**
- [Write the Docs](https://www.writethedocs.org/)
- [JSDoc](https://jsdoc.app/)
- [Architecture Decision Records](https://adr.github.io/)

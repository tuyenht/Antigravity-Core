# Code Quality Standards

**Version:** 1.0  
**Updated:** 2026-01-16

---

## 1. ESLint Configuration

```javascript
// .eslintrc.js
module.exports = {
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:react/recommended',
    'plugin:react-hooks/recommended',
    'prettier'  // Must be last
  ],
  rules: {
    'no-console': 'warn',
    'no-unused-vars': 'error',
    '@typescript-eslint/explicit-function-return-type': 'warn',
    'react-hooks/rules-of-hooks': 'error',
    'react-hooks/exhaustive-deps': 'warn'
  }
};
```

---

## 2. Prettier Configuration

```json
// .prettierrc
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100,
  "arrowParens": "always"
}
```

---

## 3. Git Workflow

**Branching Strategy:**
```
main (production)
  └── develop
       ├── feature/user-authentication
       ├── feature/payment-integration
       └── bugfix/login-error
```

**Branch Naming:**
- `feature/description` - New features
- `bugfix/description` - Bug fixes
- `hotfix/description` - Production fixes
- `refactor/description` - Code improvements

---

## 4. Commit Message Conventions

```bash
# Format: <type>(<scope>): <subject>

# Types:
feat: add user authentication
fix: resolve login redirect issue
docs: update API documentation
style: format code with prettier
refactor: simplify user service
test: add unit tests for auth
chore: update dependencies
perf: optimize database queries

# Good examples:
feat(auth): implement JWT authentication
fix(ui): resolve button alignment issue
docs(api): add endpoint documentation

# Bad examples:
Updated stuff      # ❌ Vague
Fixed bug          # ❌ Not descriptive
WIP                # ❌ Meaningless
```

---

## 5. Code Review Checklist

**Before requesting review:**
- [ ] Code follows style guide
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No console.log statements
- [ ] No commented code
- [ ] Variable names descriptive
- [ ] Functions small and focused
- [ ] Error handling present
- [ ] Security considerations addressed
- [ ] Performance optimized

**Reviewer checklist:**
- [ ] Code is understandable
- [ ] Logic is correct
- [ ] Edge cases handled
- [ ] Tests are sufficient
- [ ] No security vulnerabilities
- [ ] Performance acceptable
- [ ] Documentation adequate

---

## 6. Code Style Guide

```javascript
// ✅ GOOD
function calculateTotalPrice(items, taxRate) {
  const subtotal = items.reduce((sum, item) => sum + item.price, 0);
  const tax = subtotal * taxRate;
  return subtotal + tax;
}

// ❌ BAD
function calc(i, t) {
  let s = 0;
  for(let x of i) {
    s += x.price;
  }
  return s + (s * t);
}

// ✅ Descriptive naming
const MAX_RETRY_ATTEMPTS = 3;
const userEmailAddress = 'user@example.com';

// ❌ Unclear naming
const x = 3;
const data = 'user@example.com';
```

---

## 7. Pre-commit Hooks

```bash
# .husky/pre-commit
#!/bin/sh
npm run lint
npm run type-check
npm test

# package.json
{
  "scripts": {
    "lint": "eslint . --ext .ts,.tsx",
    "type-check": "tsc --noEmit",
    "format": "prettier --write \"src/**/*.{ts,tsx}\"",
    "test": "jest"
  },
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged"
    }
  },
  "lint-staged": {
    "*.{ts,tsx}": [
      "eslint --fix",
      "prettier --write",
      "jest --findRelatedTests"
    ]
  }
}
```

---

**References:**
- [Clean Code](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)
- [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- [Conventional Commits](https://www.conventionalcommits.org/)

# TypeScript Monorepo Architecture Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **Turborepo:** 2.x  
> **TypeScript:** 5.x  
> **Priority:** P0 - Load for monorepo projects

---

You are an expert in TypeScript monorepo architecture and management.

## Core Principles

- Use workspace protocols for package management
- Share types across packages efficiently
- Implement proper build orchestration
- Use TypeScript project references

---

## 1) Project Structure

### Recommended Monorepo Structure
```
monorepo/
├── apps/                         # Applications
│   ├── web/                      # Next.js web app
│   │   ├── src/
│   │   ├── package.json
│   │   └── tsconfig.json
│   ├── mobile/                   # React Native app
│   │   ├── src/
│   │   ├── package.json
│   │   └── tsconfig.json
│   └── api/                      # NestJS API
│       ├── src/
│       ├── package.json
│       └── tsconfig.json
├── packages/                     # Shared packages
│   ├── ui/                       # UI components
│   │   ├── src/
│   │   ├── package.json
│   │   └── tsconfig.json
│   ├── utils/                    # Utilities
│   │   ├── src/
│   │   ├── package.json
│   │   └── tsconfig.json
│   ├── types/                    # Shared types
│   │   ├── src/
│   │   ├── package.json
│   │   └── tsconfig.json
│   ├── config/                   # Shared configs
│   │   ├── eslint/
│   │   ├── typescript/
│   │   └── package.json
│   └── database/                 # Database client
│       ├── prisma/
│       ├── src/
│       ├── package.json
│       └── tsconfig.json
├── tooling/                      # Build tooling
│   ├── eslint/
│   ├── prettier/
│   └── typescript/
├── turbo.json                    # Turborepo config
├── pnpm-workspace.yaml           # pnpm workspaces
├── package.json                  # Root package.json
├── tsconfig.json                 # Root tsconfig
└── .changeset/                   # Changesets config
    └── config.json
```

---

## 2) Root Configuration

### pnpm Workspace
```yaml
# ==========================================
# pnpm-workspace.yaml
# ==========================================

packages:
  - "apps/*"
  - "packages/*"
  - "tooling/*"
```

### Root package.json
```json
// ==========================================
// package.json (root)
// ==========================================

{
  "name": "my-monorepo",
  "private": true,
  "packageManager": "pnpm@9.0.0",
  "scripts": {
    "build": "turbo build",
    "dev": "turbo dev",
    "lint": "turbo lint",
    "format": "prettier --write \"**/*.{ts,tsx,md,json}\"",
    "type-check": "turbo type-check",
    "test": "turbo test",
    "clean": "turbo clean && rm -rf node_modules",
    "prepare": "husky"
  },
  "devDependencies": {
    "@changesets/cli": "^2.27.0",
    "husky": "^9.0.0",
    "lint-staged": "^15.0.0",
    "prettier": "^3.2.0",
    "turbo": "^2.0.0",
    "typescript": "^5.4.0"
  },
  "lint-staged": {
    "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{json,md,yaml}": ["prettier --write"]
  }
}
```

### Turborepo Configuration
```json
// ==========================================
// turbo.json
// ==========================================

{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": [
    ".env",
    ".env.local"
  ],
  "globalEnv": [
    "NODE_ENV",
    "DATABASE_URL"
  ],
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "!.next/cache/**"],
      "env": ["NODE_ENV"]
    },
    "dev": {
      "dependsOn": ["^build"],
      "cache": false,
      "persistent": true
    },
    "lint": {
      "dependsOn": ["^build"],
      "outputs": []
    },
    "type-check": {
      "dependsOn": ["^build"],
      "outputs": []
    },
    "test": {
      "dependsOn": ["^build"],
      "outputs": ["coverage/**"],
      "env": ["NODE_ENV"]
    },
    "test:watch": {
      "cache": false,
      "persistent": true
    },
    "clean": {
      "cache": false
    },
    "db:generate": {
      "cache": false
    },
    "db:push": {
      "cache": false
    }
  }
}
```

---

## 3) TypeScript Configuration

### Root tsconfig.json
```json
// ==========================================
// tsconfig.json (root)
// ==========================================

{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "forceConsistentCasingInFileNames": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "composite": true,
    "incremental": true
  }
}
```

### App tsconfig (Next.js)
```json
// ==========================================
// apps/web/tsconfig.json
// ==========================================

{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["dom", "dom.iterable", "esnext"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowJs": true,
    "jsx": "preserve",
    "noEmit": true,
    "plugins": [{ "name": "next" }],
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@repo/ui": ["../../packages/ui/src"],
      "@repo/utils": ["../../packages/utils/src"],
      "@repo/types": ["../../packages/types/src"]
    }
  },
  "include": [
    "next-env.d.ts",
    "**/*.ts",
    "**/*.tsx",
    ".next/types/**/*.ts"
  ],
  "exclude": ["node_modules"],
  "references": [
    { "path": "../../packages/ui" },
    { "path": "../../packages/utils" },
    { "path": "../../packages/types" }
  ]
}
```

### Package tsconfig
```json
// ==========================================
// packages/ui/tsconfig.json
// ==========================================

{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "outDir": "./dist",
    "rootDir": "./src",
    "composite": true,
    "declaration": true,
    "declarationMap": true,
    "baseUrl": ".",
    "paths": {
      "@repo/types": ["../types/src"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"],
  "references": [
    { "path": "../types" }
  ]
}
```

---

## 4) Shared Types Package

### Package Configuration
```json
// ==========================================
// packages/types/package.json
// ==========================================

{
  "name": "@repo/types",
  "version": "0.0.0",
  "private": true,
  "main": "./dist/index.js",
  "module": "./dist/index.mjs",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "import": "./dist/index.mjs",
      "require": "./dist/index.js"
    },
    "./api": {
      "types": "./dist/api.d.ts",
      "import": "./dist/api.mjs",
      "require": "./dist/api.js"
    },
    "./user": {
      "types": "./dist/user.d.ts",
      "import": "./dist/user.mjs",
      "require": "./dist/user.js"
    }
  },
  "scripts": {
    "build": "tsup",
    "dev": "tsup --watch",
    "type-check": "tsc --noEmit",
    "clean": "rm -rf dist"
  },
  "devDependencies": {
    "tsup": "^8.0.0",
    "typescript": "^5.4.0"
  }
}
```

### Type Definitions
```typescript
// ==========================================
// packages/types/src/index.ts
// ==========================================

// Re-export all types
export * from './user';
export * from './api';
export * from './common';


// ==========================================
// packages/types/src/user.ts
// ==========================================

export interface User {
  id: string;
  email: string;
  name: string;
  avatar?: string;
  role: UserRole;
  createdAt: Date;
  updatedAt: Date;
}

export enum UserRole {
  ADMIN = 'admin',
  USER = 'user',
  MODERATOR = 'moderator',
}

export interface CreateUserInput {
  email: string;
  name: string;
  password: string;
  role?: UserRole;
}

export interface UpdateUserInput extends Partial<Omit<CreateUserInput, 'password'>> {}

export interface UserWithPosts extends User {
  posts: Post[];
}


// ==========================================
// packages/types/src/api.ts
// ==========================================

export interface ApiResponse<T> {
  success: true;
  data: T;
  timestamp: string;
}

export interface ApiError {
  success: false;
  error: {
    code: string;
    message: string;
    details?: Record<string, unknown>;
  };
  timestamp: string;
}

export type ApiResult<T> = ApiResponse<T> | ApiError;

export interface PaginatedResponse<T> {
  data: T[];
  meta: PaginationMeta;
}

export interface PaginationMeta {
  total: number;
  page: number;
  limit: number;
  totalPages: number;
  hasNextPage: boolean;
  hasPreviousPage: boolean;
}

export interface PaginationParams {
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}


// ==========================================
// packages/types/src/common.ts
// ==========================================

export type Nullable<T> = T | null;
export type Optional<T> = T | undefined;
export type Maybe<T> = T | null | undefined;

export type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};

export type DeepReadonly<T> = {
  readonly [P in keyof T]: T[P] extends object ? DeepReadonly<T[P]> : T[P];
};

export interface Timestamps {
  createdAt: Date;
  updatedAt: Date;
}

export interface SoftDelete {
  deletedAt?: Date;
}

export type WithId<T> = T & { id: string };
export type WithTimestamps<T> = T & Timestamps;
```

### tsup Configuration
```typescript
// ==========================================
// packages/types/tsup.config.ts
// ==========================================

import { defineConfig } from 'tsup';

export default defineConfig({
  entry: {
    index: 'src/index.ts',
    api: 'src/api.ts',
    user: 'src/user.ts',
  },
  format: ['cjs', 'esm'],
  dts: true,
  clean: true,
  splitting: false,
  sourcemap: true,
  treeshake: true,
});
```

---

## 5) Shared UI Package

### Package Configuration
```json
// ==========================================
// packages/ui/package.json
// ==========================================

{
  "name": "@repo/ui",
  "version": "0.0.0",
  "private": true,
  "sideEffects": ["**/*.css"],
  "main": "./dist/index.js",
  "module": "./dist/index.mjs",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "import": "./dist/index.mjs",
      "require": "./dist/index.js"
    },
    "./button": {
      "types": "./dist/button.d.ts",
      "import": "./dist/button.mjs",
      "require": "./dist/button.js"
    },
    "./card": {
      "types": "./dist/card.d.ts",
      "import": "./dist/card.mjs",
      "require": "./dist/card.js"
    },
    "./styles.css": "./dist/styles.css"
  },
  "scripts": {
    "build": "tsup",
    "dev": "tsup --watch",
    "type-check": "tsc --noEmit",
    "lint": "eslint src/",
    "clean": "rm -rf dist"
  },
  "peerDependencies": {
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
  },
  "devDependencies": {
    "@repo/types": "workspace:*",
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "tsup": "^8.0.0",
    "typescript": "^5.4.0"
  }
}
```

### Typed UI Component
```typescript
// ==========================================
// packages/ui/src/button.tsx
// ==========================================

import React, { forwardRef, type ButtonHTMLAttributes, type ReactNode } from 'react';

export type ButtonVariant = 'primary' | 'secondary' | 'outline' | 'ghost' | 'danger';
export type ButtonSize = 'sm' | 'md' | 'lg';

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  loading?: boolean;
  leftIcon?: ReactNode;
  rightIcon?: ReactNode;
  fullWidth?: boolean;
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  (
    {
      variant = 'primary',
      size = 'md',
      loading = false,
      leftIcon,
      rightIcon,
      fullWidth = false,
      disabled,
      children,
      className = '',
      ...props
    },
    ref
  ) => {
    const baseStyles = 'inline-flex items-center justify-center font-medium transition-colors';
    
    const variantStyles: Record<ButtonVariant, string> = {
      primary: 'bg-blue-600 text-white hover:bg-blue-700',
      secondary: 'bg-gray-600 text-white hover:bg-gray-700',
      outline: 'border-2 border-gray-300 hover:bg-gray-50',
      ghost: 'hover:bg-gray-100',
      danger: 'bg-red-600 text-white hover:bg-red-700',
    };

    const sizeStyles: Record<ButtonSize, string> = {
      sm: 'px-3 py-1.5 text-sm rounded',
      md: 'px-4 py-2 text-base rounded-md',
      lg: 'px-6 py-3 text-lg rounded-lg',
    };

    return (
      <button
        ref={ref}
        disabled={disabled || loading}
        className={`
          ${baseStyles}
          ${variantStyles[variant]}
          ${sizeStyles[size]}
          ${fullWidth ? 'w-full' : ''}
          ${disabled || loading ? 'opacity-50 cursor-not-allowed' : ''}
          ${className}
        `}
        {...props}
      >
        {loading ? (
          <span className="mr-2">Loading...</span>
        ) : (
          <>
            {leftIcon && <span className="mr-2">{leftIcon}</span>}
            {children}
            {rightIcon && <span className="ml-2">{rightIcon}</span>}
          </>
        )}
      </button>
    );
  }
);

Button.displayName = 'Button';


// ==========================================
// packages/ui/src/index.ts
// ==========================================

export { Button, type ButtonProps, type ButtonVariant, type ButtonSize } from './button';
export { Card, type CardProps } from './card';
export { Input, type InputProps } from './input';
export { Modal, type ModalProps } from './modal';
```

---

## 6) Shared Utils Package

### Package Configuration
```json
// ==========================================
// packages/utils/package.json
// ==========================================

{
  "name": "@repo/utils",
  "version": "0.0.0",
  "private": true,
  "main": "./dist/index.js",
  "module": "./dist/index.mjs",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "import": "./dist/index.mjs",
      "require": "./dist/index.js"
    },
    "./format": {
      "types": "./dist/format.d.ts",
      "import": "./dist/format.mjs",
      "require": "./dist/format.js"
    },
    "./validation": {
      "types": "./dist/validation.d.ts",
      "import": "./dist/validation.mjs",
      "require": "./dist/validation.js"
    }
  },
  "scripts": {
    "build": "tsup",
    "dev": "tsup --watch",
    "test": "vitest",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "zod": "^3.22.0"
  },
  "devDependencies": {
    "@repo/types": "workspace:*",
    "tsup": "^8.0.0",
    "typescript": "^5.4.0",
    "vitest": "^1.0.0"
  }
}
```

### Typed Utilities
```typescript
// ==========================================
// packages/utils/src/format.ts
// ==========================================

export function formatDate(
  date: Date | string | number,
  options?: Intl.DateTimeFormatOptions
): string {
  const d = new Date(date);
  return d.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    ...options,
  });
}

export function formatCurrency(
  amount: number,
  currency: string = 'USD',
  locale: string = 'en-US'
): string {
  return new Intl.NumberFormat(locale, {
    style: 'currency',
    currency,
  }).format(amount);
}

export function formatNumber(
  value: number,
  options?: Intl.NumberFormatOptions
): string {
  return new Intl.NumberFormat('en-US', options).format(value);
}

export function pluralize(
  count: number,
  singular: string,
  plural?: string
): string {
  const word = count === 1 ? singular : (plural ?? `${singular}s`);
  return `${count} ${word}`;
}

export function truncate(text: string, maxLength: number): string {
  if (text.length <= maxLength) return text;
  return `${text.slice(0, maxLength)}...`;
}

export function slugify(text: string): string {
  return text
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, '')
    .replace(/[\s_-]+/g, '-')
    .replace(/^-+|-+$/g, '');
}


// ==========================================
// packages/utils/src/validation.ts
// ==========================================

import { z } from 'zod';

export const emailSchema = z.string().email();

export const passwordSchema = z
  .string()
  .min(8, 'Password must be at least 8 characters')
  .regex(/[A-Z]/, 'Password must contain an uppercase letter')
  .regex(/[a-z]/, 'Password must contain a lowercase letter')
  .regex(/[0-9]/, 'Password must contain a number')
  .regex(/[^A-Za-z0-9]/, 'Password must contain a special character');

export const userSchema = z.object({
  email: emailSchema,
  name: z.string().min(2).max(100),
  password: passwordSchema,
  role: z.enum(['admin', 'user', 'moderator']).optional(),
});

export type UserInput = z.infer<typeof userSchema>;

export function validateEmail(email: string): boolean {
  return emailSchema.safeParse(email).success;
}

export function validatePassword(password: string): {
  valid: boolean;
  errors: string[];
} {
  const result = passwordSchema.safeParse(password);
  
  if (result.success) {
    return { valid: true, errors: [] };
  }
  
  return {
    valid: false,
    errors: result.error.errors.map((e) => e.message),
  };
}


// ==========================================
// packages/utils/src/index.ts
// ==========================================

export * from './format';
export * from './validation';
export * from './async';
export * from './object';
```

---

## 7) Database Package (Prisma)

### Package Configuration
```json
// ==========================================
// packages/database/package.json
// ==========================================

{
  "name": "@repo/database",
  "version": "0.0.0",
  "private": true,
  "main": "./dist/index.js",
  "module": "./dist/index.mjs",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "import": "./dist/index.mjs",
      "require": "./dist/index.js"
    },
    "./client": {
      "types": "./dist/client.d.ts",
      "import": "./dist/client.mjs",
      "require": "./dist/client.js"
    }
  },
  "scripts": {
    "build": "tsup",
    "dev": "tsup --watch",
    "db:generate": "prisma generate",
    "db:push": "prisma db push",
    "db:migrate": "prisma migrate dev",
    "db:studio": "prisma studio",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "@prisma/client": "^5.10.0"
  },
  "devDependencies": {
    "prisma": "^5.10.0",
    "tsup": "^8.0.0",
    "typescript": "^5.4.0"
  }
}
```

### Prisma Client Export
```typescript
// ==========================================
// packages/database/src/client.ts
// ==========================================

import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log:
      process.env.NODE_ENV === 'development'
        ? ['query', 'error', 'warn']
        : ['error'],
  });

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma;
}

export type { PrismaClient } from '@prisma/client';


// ==========================================
// packages/database/src/index.ts
// ==========================================

export { prisma, type PrismaClient } from './client';

// Re-export Prisma types for use in other packages
export type {
  User,
  Post,
  Prisma,
} from '@prisma/client';
```

---

## 8) Shared Config Package

### ESLint Config
```javascript
// ==========================================
// packages/config/eslint/base.js
// ==========================================

/** @type {import('eslint').Linter.Config} */
module.exports = {
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:@typescript-eslint/recommended-type-checked',
    'prettier',
  ],
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint', 'import'],
  rules: {
    '@typescript-eslint/no-explicit-any': 'error',
    '@typescript-eslint/no-unused-vars': [
      'error',
      { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
    ],
    '@typescript-eslint/consistent-type-imports': [
      'error',
      { prefer: 'type-imports' },
    ],
    'import/order': [
      'error',
      {
        groups: ['builtin', 'external', 'internal', 'parent', 'sibling', 'index'],
        'newlines-between': 'always',
        alphabetize: { order: 'asc', caseInsensitive: true },
      },
    ],
  },
};


// ==========================================
// packages/config/eslint/react.js
// ==========================================

/** @type {import('eslint').Linter.Config} */
module.exports = {
  extends: [
    './base.js',
    'plugin:react/recommended',
    'plugin:react-hooks/recommended',
  ],
  settings: {
    react: { version: 'detect' },
  },
  rules: {
    'react/react-in-jsx-scope': 'off',
    'react/prop-types': 'off',
  },
};


// ==========================================
// packages/config/eslint/next.js
// ==========================================

/** @type {import('eslint').Linter.Config} */
module.exports = {
  extends: ['./react.js', 'next/core-web-vitals'],
};
```

---

## 9) App Usage

### Next.js App
```json
// ==========================================
// apps/web/package.json
// ==========================================

{
  "name": "@repo/web",
  "version": "0.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "@repo/database": "workspace:*",
    "@repo/types": "workspace:*",
    "@repo/ui": "workspace:*",
    "@repo/utils": "workspace:*",
    "next": "^14.1.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@repo/config": "workspace:*",
    "@types/node": "^20.0.0",
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "typescript": "^5.4.0"
  }
}
```

### Using Shared Packages
```typescript
// ==========================================
// apps/web/src/app/users/page.tsx
// ==========================================

import { Button, Card } from '@repo/ui';
import { formatDate, truncate } from '@repo/utils';
import type { User, PaginatedResponse } from '@repo/types';
import { prisma } from '@repo/database';

async function getUsers(): Promise<PaginatedResponse<User>> {
  const users = await prisma.user.findMany({
    take: 10,
    orderBy: { createdAt: 'desc' },
  });

  return {
    data: users,
    meta: {
      total: await prisma.user.count(),
      page: 1,
      limit: 10,
      totalPages: 1,
      hasNextPage: false,
      hasPreviousPage: false,
    },
  };
}

export default async function UsersPage() {
  const { data: users } = await getUsers();

  return (
    <div className="grid gap-4">
      {users.map((user) => (
        <Card key={user.id}>
          <h3>{user.name}</h3>
          <p>{truncate(user.email, 30)}</p>
          <p>Joined: {formatDate(user.createdAt)}</p>
          <Button variant="outline" size="sm">
            View Profile
          </Button>
        </Card>
      ))}
    </div>
  );
}
```

---

## 10) CI/CD Configuration

### GitHub Actions
```yaml
# ==========================================
# .github/workflows/ci.yml
# ==========================================

name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

env:
  TURBO_TOKEN: ${{ secrets.TURBO_TOKEN }}
  TURBO_TEAM: ${{ vars.TURBO_TEAM }}

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 2

      - uses: pnpm/action-setup@v3
        with:
          version: 9

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Build
        run: pnpm build

      - name: Lint
        run: pnpm lint

      - name: Type check
        run: pnpm type-check

      - name: Test
        run: pnpm test

  # Only run affected packages
  affected:
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: pnpm/action-setup@v3
        with:
          version: 9

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Build affected
        run: pnpm turbo build --filter='...[origin/main]'

      - name: Test affected
        run: pnpm turbo test --filter='...[origin/main]'
```

### Changesets Configuration
```json
// ==========================================
// .changeset/config.json
// ==========================================

{
  "$schema": "https://unpkg.com/@changesets/config@3.0.0/schema.json",
  "changelog": "@changesets/cli/changelog",
  "commit": false,
  "fixed": [],
  "linked": [],
  "access": "restricted",
  "baseBranch": "main",
  "updateInternalDependencies": "patch",
  "ignore": ["@repo/web", "@repo/api", "@repo/mobile"]
}
```

---

## Best Practices Checklist

### Structure
- [ ] apps/ for applications
- [ ] packages/ for shared code
- [ ] Consistent naming (@repo/*)

### TypeScript
- [ ] Project references
- [ ] Composite builds
- [ ] Shared tsconfig

### Packages
- [ ] Proper exports field
- [ ] workspace:* protocol
- [ ] Peer dependencies

### Build
- [ ] Turborepo caching
- [ ] Incremental builds
- [ ] Remote caching

### CI/CD
- [ ] Affected builds
- [ ] Changesets
- [ ] Parallel jobs

---

**References:**
- [Turborepo](https://turbo.build/repo)
- [pnpm Workspaces](https://pnpm.io/workspaces)
- [TypeScript Project References](https://www.typescriptlang.org/docs/handbook/project-references.html)
- [Changesets](https://github.com/changesets/changesets)

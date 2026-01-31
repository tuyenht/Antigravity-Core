# TypeScript Tooling & Ecosystem

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **TypeScript:** 5.x  
> **Priority:** P0 - Essential for TypeScript projects

---

You are an expert in the TypeScript ecosystem.

## Core Tooling Principles

- Use modern tooling for faster builds
- Integrate linting and formatting
- Generate type definitions automatically

---

## 1) Build Tools

### TypeScript Compiler (tsc)
```json
// ==========================================
// tsconfig.json - Type Checking Only
// ==========================================

{
  "compilerOptions": {
    "strict": true,
    "noEmit": true,  // Don't emit, just type check
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "module": "ESNext",
    "target": "ES2022",
    "lib": ["ES2022", "DOM"],
    "isolatedModules": true,
    "verbatimModuleSyntax": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}


// ==========================================
// package.json scripts
// ==========================================

{
  "scripts": {
    "type-check": "tsc --noEmit",
    "type-check:watch": "tsc --noEmit --watch"
  }
}
```

### Vite (Recommended)
```typescript
// ==========================================
// vite.config.ts
// ==========================================

import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react-swc';  // SWC for fast transforms
import tsconfigPaths from 'vite-tsconfig-paths';

export default defineConfig({
  plugins: [
    react(),
    tsconfigPaths(),
  ],
  
  build: {
    target: 'esnext',
    minify: 'esbuild',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
        },
      },
    },
  },
  
  server: {
    port: 3000,
    strictPort: true,
  },
  
  // TypeScript checker plugin (optional, runs in separate thread)
  // npm i -D vite-plugin-checker
  // plugins: [checker({ typescript: true })]
});


// ==========================================
// tsconfig.json for Vite
// ==========================================

{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

### esbuild (Ultra Fast)
```typescript
// ==========================================
// build.ts - esbuild config
// ==========================================

import * as esbuild from 'esbuild';

await esbuild.build({
  entryPoints: ['src/index.ts'],
  bundle: true,
  outfile: 'dist/index.js',
  platform: 'node',
  target: 'node20',
  format: 'esm',
  sourcemap: true,
  minify: process.env.NODE_ENV === 'production',
  
  // Tree shaking
  treeShaking: true,
  
  // External dependencies
  external: ['@prisma/client'],
  
  // Plugins
  plugins: [],
});


// ==========================================
// package.json
// ==========================================

{
  "scripts": {
    "build": "node --loader tsx build.ts",
    "build:watch": "node --loader tsx build.ts --watch"
  }
}
```

### SWC (Rust-based)
```json
// ==========================================
// .swcrc
// ==========================================

{
  "$schema": "https://json.schemastore.org/swcrc",
  "jsc": {
    "parser": {
      "syntax": "typescript",
      "tsx": true,
      "decorators": true,
      "dynamicImport": true
    },
    "target": "es2022",
    "transform": {
      "react": {
        "runtime": "automatic"
      }
    },
    "loose": false,
    "externalHelpers": true
  },
  "module": {
    "type": "es6",
    "strict": true
  },
  "sourceMaps": true,
  "minify": false
}


// ==========================================
// package.json
// ==========================================

{
  "scripts": {
    "build": "swc src -d dist",
    "build:watch": "swc src -d dist -w"
  }
}
```

---

## 2) ESLint Configuration

### Modern ESLint Flat Config
```javascript
// ==========================================
// eslint.config.js (ESLint 9+ Flat Config)
// ==========================================

import eslint from '@eslint/js';
import tseslint from 'typescript-eslint';
import reactPlugin from 'eslint-plugin-react';
import reactHooksPlugin from 'eslint-plugin-react-hooks';
import importPlugin from 'eslint-plugin-import';

export default tseslint.config(
  // Ignore patterns
  {
    ignores: [
      'dist/**',
      'build/**',
      'node_modules/**',
      '*.config.js',
      '*.config.ts',
    ],
  },
  
  // Base configs
  eslint.configs.recommended,
  ...tseslint.configs.strictTypeChecked,
  ...tseslint.configs.stylisticTypeChecked,
  
  // TypeScript parser options
  {
    languageOptions: {
      parserOptions: {
        project: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
  },
  
  // React rules
  {
    files: ['**/*.tsx'],
    plugins: {
      react: reactPlugin,
      'react-hooks': reactHooksPlugin,
    },
    rules: {
      ...reactPlugin.configs.recommended.rules,
      ...reactHooksPlugin.configs.recommended.rules,
      'react/react-in-jsx-scope': 'off',
      'react/prop-types': 'off',
    },
    settings: {
      react: {
        version: 'detect',
      },
    },
  },
  
  // Import rules
  {
    plugins: {
      import: importPlugin,
    },
    rules: {
      'import/order': [
        'error',
        {
          groups: [
            'builtin',
            'external',
            'internal',
            'parent',
            'sibling',
            'index',
          ],
          'newlines-between': 'always',
          alphabetize: {
            order: 'asc',
            caseInsensitive: true,
          },
        },
      ],
      'import/no-duplicates': 'error',
    },
  },
  
  // Custom TypeScript rules
  {
    rules: {
      // Strict type checking
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
      ],
      '@typescript-eslint/explicit-function-return-type': 'off',
      '@typescript-eslint/explicit-module-boundary-types': 'off',
      '@typescript-eslint/no-non-null-assertion': 'warn',
      
      // Naming conventions
      '@typescript-eslint/naming-convention': [
        'error',
        {
          selector: 'interface',
          format: ['PascalCase'],
        },
        {
          selector: 'typeAlias',
          format: ['PascalCase'],
        },
        {
          selector: 'enum',
          format: ['PascalCase'],
        },
      ],
      
      // Best practices
      '@typescript-eslint/prefer-nullish-coalescing': 'error',
      '@typescript-eslint/prefer-optional-chain': 'error',
      '@typescript-eslint/strict-boolean-expressions': 'error',
      
      // General
      'no-console': ['warn', { allow: ['warn', 'error'] }],
      'prefer-const': 'error',
      'no-var': 'error',
    },
  }
);


// ==========================================
// package.json
// ==========================================

{
  "scripts": {
    "lint": "eslint .",
    "lint:fix": "eslint . --fix"
  },
  "devDependencies": {
    "@eslint/js": "^9.0.0",
    "typescript-eslint": "^8.0.0",
    "eslint-plugin-react": "^7.35.0",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-import": "^2.29.0"
  }
}
```

---

## 3) Prettier Configuration

### Prettier Setup
```json
// ==========================================
// .prettierrc
// ==========================================

{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "es5",
  "tabWidth": 2,
  "useTabs": false,
  "printWidth": 100,
  "bracketSpacing": true,
  "arrowParens": "always",
  "endOfLine": "lf",
  "plugins": ["prettier-plugin-tailwindcss"],
  "tailwindConfig": "./tailwind.config.ts"
}


// ==========================================
// .prettierignore
// ==========================================

node_modules
dist
build
.next
coverage
*.min.js
pnpm-lock.yaml
package-lock.json


// ==========================================
// package.json
// ==========================================

{
  "scripts": {
    "format": "prettier --write .",
    "format:check": "prettier --check ."
  },
  "devDependencies": {
    "prettier": "^3.2.0",
    "prettier-plugin-tailwindcss": "^0.5.0"
  }
}
```

---

## 4) Husky & lint-staged

### Pre-commit Hooks
```bash
# ==========================================
# Install Husky
# ==========================================

npm i -D husky lint-staged
npx husky init
```

```json
// ==========================================
// package.json
// ==========================================

{
  "scripts": {
    "prepare": "husky"
  },
  "lint-staged": {
    "*.{ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{json,md,yml,yaml}": [
      "prettier --write"
    ],
    "*.{css,scss}": [
      "prettier --write"
    ]
  }
}


// ==========================================
// .husky/pre-commit
// ==========================================

npx lint-staged


// ==========================================
// .husky/pre-push
// ==========================================

npm run type-check
npm run test
```

### Commitlint
```javascript
// ==========================================
// commitlint.config.js
// ==========================================

export default {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',     // New feature
        'fix',      // Bug fix
        'docs',     // Documentation
        'style',    // Formatting
        'refactor', // Refactoring
        'perf',     // Performance
        'test',     // Tests
        'build',    // Build system
        'ci',       // CI config
        'chore',    // Maintenance
        'revert',   // Revert commit
      ],
    ],
    'subject-case': [2, 'always', 'sentence-case'],
    'body-max-line-length': [0],
  },
};


// ==========================================
// .husky/commit-msg
// ==========================================

npx --no -- commitlint --edit $1
```

---

## 5) Type Generation

### Prisma Type Generation
```typescript
// ==========================================
// schema.prisma
// ==========================================

generator client {
  provider = "prisma-client-js"
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?
  published Boolean  @default(false)
  author    User     @relation(fields: [authorId], references: [id])
  authorId  String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}


// ==========================================
// Auto-generated types
// ==========================================

// After: npx prisma generate
import { User, Post, Prisma } from '@prisma/client';

// Input types
type UserCreateInput = Prisma.UserCreateInput;
type UserUpdateInput = Prisma.UserUpdateInput;

// Select/Include types
type UserWithPosts = Prisma.UserGetPayload<{
  include: { posts: true };
}>;


// ==========================================
// package.json
// ==========================================

{
  "scripts": {
    "db:generate": "prisma generate",
    "db:push": "prisma db push",
    "db:migrate": "prisma migrate dev",
    "db:studio": "prisma studio"
  }
}
```

### GraphQL Code Generator
```yaml
# ==========================================
# codegen.ts
# ==========================================

import type { CodegenConfig } from '@graphql-codegen/cli';

const config: CodegenConfig = {
  schema: './src/graphql/schema.graphql',
  documents: ['src/**/*.graphql', 'src/**/*.tsx'],
  generates: {
    './src/generated/graphql.ts': {
      plugins: [
        'typescript',
        'typescript-operations',
        'typescript-react-apollo',
      ],
      config: {
        strictScalars: true,
        scalars: {
          DateTime: 'string',
          JSON: 'Record<string, unknown>',
        },
        withHooks: true,
        withComponent: false,
        withHOC: false,
      },
    },
  },
  hooks: {
    afterAllFileWrite: ['prettier --write'],
  },
};

export default config;


# ==========================================
# package.json
# ==========================================

{
  "scripts": {
    "codegen": "graphql-codegen",
    "codegen:watch": "graphql-codegen --watch"
  },
  "devDependencies": {
    "@graphql-codegen/cli": "^5.0.0",
    "@graphql-codegen/typescript": "^4.0.0",
    "@graphql-codegen/typescript-operations": "^4.0.0",
    "@graphql-codegen/typescript-react-apollo": "^4.0.0"
  }
}
```

### OpenAPI Type Generation
```typescript
// ==========================================
// openapi-ts.config.ts
// ==========================================

import { defineConfig } from '@hey-api/openapi-ts';

export default defineConfig({
  client: '@hey-api/client-fetch',
  input: './openapi.json',  // or URL
  output: {
    path: './src/generated/api',
    format: 'prettier',
  },
  types: {
    dates: 'types+transform',
    enums: 'javascript',
  },
  services: {
    asClass: true,
  },
});


// ==========================================
// package.json
// ==========================================

{
  "scripts": {
    "openapi": "openapi-ts"
  },
  "devDependencies": {
    "@hey-api/openapi-ts": "^0.45.0"
  }
}


// ==========================================
// Usage
// ==========================================

import { UsersService } from './generated/api';

const users = await UsersService.getUsers();
// Type-safe API calls!
```

---

## 6) Monorepo Setup

### Turborepo Configuration
```json
// ==========================================
// turbo.json
// ==========================================

{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": [
    ".env"
  ],
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "!.next/cache/**"]
    },
    "lint": {
      "dependsOn": ["^lint"]
    },
    "type-check": {
      "dependsOn": ["^type-check"]
    },
    "test": {
      "dependsOn": ["^build"],
      "outputs": ["coverage/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    }
  }
}


// ==========================================
// Root package.json
// ==========================================

{
  "name": "my-monorepo",
  "private": true,
  "workspaces": [
    "apps/*",
    "packages/*"
  ],
  "scripts": {
    "build": "turbo build",
    "dev": "turbo dev",
    "lint": "turbo lint",
    "type-check": "turbo type-check",
    "test": "turbo test"
  },
  "devDependencies": {
    "turbo": "^2.0.0",
    "typescript": "^5.4.0"
  }
}
```

### TypeScript Project References
```json
// ==========================================
// packages/shared/tsconfig.json
// ==========================================

{
  "compilerOptions": {
    "composite": true,
    "declaration": true,
    "declarationMap": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "target": "ES2022"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}


// ==========================================
// apps/web/tsconfig.json
// ==========================================

{
  "compilerOptions": {
    "strict": true,
    "baseUrl": ".",
    "paths": {
      "@repo/shared": ["../../packages/shared/src"]
    }
  },
  "references": [
    { "path": "../../packages/shared" }
  ],
  "include": ["src/**/*"],
  "exclude": ["node_modules"]
}


// ==========================================
// Root tsconfig.json
// ==========================================

{
  "files": [],
  "references": [
    { "path": "./packages/shared" },
    { "path": "./packages/ui" },
    { "path": "./apps/web" },
    { "path": "./apps/api" }
  ]
}
```

### Shared Type Package
```typescript
// ==========================================
// packages/types/src/index.ts
// ==========================================

// Shared types across all apps
export interface User {
  id: string;
  email: string;
  name: string;
  createdAt: Date;
}

export interface ApiResponse<T> {
  data: T;
  status: number;
  message?: string;
}

export type Status = 'pending' | 'active' | 'completed';

// Re-export all types
export * from './auth';
export * from './api';
export * from './entities';


// ==========================================
// packages/types/package.json
// ==========================================

{
  "name": "@repo/types",
  "version": "0.0.0",
  "private": true,
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "import": "./dist/index.js"
    }
  },
  "scripts": {
    "build": "tsc",
    "type-check": "tsc --noEmit"
  }
}
```

---

## 7) VS Code Configuration

### TypeScript Settings
```json
// ==========================================
// .vscode/settings.json
// ==========================================

{
  // TypeScript
  "typescript.preferences.importModuleSpecifier": "relative",
  "typescript.updateImportsOnFileMove.enabled": "always",
  "typescript.suggest.autoImports": true,
  "typescript.preferences.preferTypeOnlyAutoImports": true,
  
  // Use workspace TypeScript
  "typescript.tsdk": "node_modules/typescript/lib",
  "typescript.enablePromptUseWorkspaceTsdk": true,
  
  // Editor
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit",
    "source.organizeImports": "never"
  },
  
  // ESLint
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  ],
  
  // File associations
  "files.associations": {
    "*.css": "tailwindcss"
  },
  
  // Exclude from search
  "search.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/.next": true,
    "**/coverage": true
  }
}


// ==========================================
// .vscode/extensions.json
// ==========================================

{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "bradlc.vscode-tailwindcss",
    "prisma.prisma",
    "ms-vscode.vscode-typescript-next",
    "streetsidesoftware.code-spell-checker"
  ]
}
```

### Debug Configuration
```json
// ==========================================
// .vscode/launch.json
// ==========================================

{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug TypeScript",
      "type": "node",
      "request": "launch",
      "runtimeExecutable": "npx",
      "runtimeArgs": ["tsx", "${file}"],
      "cwd": "${workspaceFolder}",
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen",
      "skipFiles": ["<node_internals>/**"]
    },
    {
      "name": "Debug Jest Tests",
      "type": "node",
      "request": "launch",
      "runtimeExecutable": "npx",
      "runtimeArgs": [
        "jest",
        "--runInBand",
        "--no-cache",
        "${relativeFile}"
      ],
      "cwd": "${workspaceFolder}",
      "console": "integratedTerminal"
    },
    {
      "name": "Next.js: Debug Server",
      "type": "node",
      "request": "launch",
      "cwd": "${workspaceFolder}",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "dev"],
      "skipFiles": ["<node_internals>/**"],
      "serverReadyAction": {
        "action": "openExternally",
        "pattern": "- Local:.+(https?://.+)"
      }
    }
  ]
}
```

---

## 8) Running TypeScript

### tsx (Recommended)
```json
// ==========================================
// package.json
// ==========================================

{
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "start": "tsx src/index.ts",
    "script": "tsx scripts/migrate.ts"
  },
  "devDependencies": {
    "tsx": "^4.7.0"
  }
}
```

### ts-node (Alternative)
```json
// ==========================================
// tsconfig.json for ts-node
// ==========================================

{
  "ts-node": {
    "compilerOptions": {
      "module": "CommonJS",
      "moduleResolution": "Node"
    },
    "transpileOnly": true,
    "files": true
  }
}


// ==========================================
// package.json
// ==========================================

{
  "scripts": {
    "dev": "ts-node-dev --respawn src/index.ts",
    "start": "ts-node src/index.ts"
  },
  "devDependencies": {
    "ts-node": "^10.9.0",
    "ts-node-dev": "^2.0.0"
  }
}
```

---

## Best Practices Checklist

### Build
- [ ] Use Vite or esbuild for speed
- [ ] Separate type-check from build
- [ ] Enable source maps

### Linting
- [ ] ESLint flat config
- [ ] TypeScript rules enabled
- [ ] Import sorting

### Formatting
- [ ] Prettier configured
- [ ] Pre-commit hooks
- [ ] Commitlint

### Type Generation
- [ ] Prisma generate
- [ ] GraphQL codegen
- [ ] OpenAPI types

### Monorepo
- [ ] Turborepo or Nx
- [ ] Project references
- [ ] Shared types package

---

**References:**
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/)
- [typescript-eslint](https://typescript-eslint.io/)
- [Vite](https://vitejs.dev/)
- [Turborepo](https://turbo.build/repo)

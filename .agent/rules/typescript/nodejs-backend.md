# TypeScript Node.js Backend Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **Node.js:** 20.x+  
> **Express:** 4.x/5.x  
> **TypeScript:** 5.x  
> **Priority:** P0 - Load for Node.js backend

---

You are an expert in TypeScript Node.js backend development.

## Core Principles

- Use strict TypeScript configuration
- Type all Express middleware and routes
- Implement proper error handling with types
- Follow Node.js best practices

---

## 1) Project Setup

### tsconfig.json for Node.js
```json
// ==========================================
// tsconfig.json
// ==========================================

{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "exactOptionalPropertyTypes": true,
    "forceConsistentCasingInFileNames": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "resolveJsonModule": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@controllers/*": ["./src/controllers/*"],
      "@services/*": ["./src/services/*"],
      "@middleware/*": ["./src/middleware/*"],
      "@utils/*": ["./src/utils/*"],
      "@types/*": ["./src/types/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
```

### Package.json Scripts
```json
// ==========================================
// package.json
// ==========================================

{
  "name": "node-backend",
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "lint": "eslint src --ext .ts",
    "test": "vitest",
    "test:e2e": "vitest run --config vitest.e2e.config.ts"
  },
  "dependencies": {
    "express": "^4.18.0",
    "zod": "^3.22.0",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.0",
    "pino": "^8.0.0",
    "@prisma/client": "^5.0.0"
  },
  "devDependencies": {
    "@types/express": "^4.17.0",
    "@types/bcryptjs": "^2.4.0",
    "@types/jsonwebtoken": "^9.0.0",
    "@types/node": "^20.0.0",
    "tsx": "^4.0.0",
    "typescript": "^5.4.0",
    "prisma": "^5.0.0",
    "vitest": "^2.0.0",
    "supertest": "^6.0.0"
  }
}
```

### Project Structure
```
src/
├── config/
│   ├── env.ts              # Environment validation
│   └── database.ts         # Database configuration
├── controllers/
│   ├── auth.controller.ts
│   └── user.controller.ts
├── middleware/
│   ├── auth.middleware.ts
│   ├── error.middleware.ts
│   └── validate.middleware.ts
├── routes/
│   ├── auth.routes.ts
│   ├── user.routes.ts
│   └── index.ts
├── services/
│   ├── auth.service.ts
│   └── user.service.ts
├── types/
│   ├── express.d.ts        # Express extensions
│   └── index.ts
├── utils/
│   ├── errors.ts
│   ├── jwt.ts
│   └── logger.ts
├── app.ts
└── server.ts
```

---

## 2) Typed Express Application

### Application Setup
```typescript
// ==========================================
// src/app.ts
// ==========================================

import express, { type Express, type Request, type Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import { pinoHttp } from 'pino-http';

import { errorHandler, notFoundHandler } from '@/middleware/error.middleware';
import { requestId } from '@/middleware/request-id.middleware';
import routes from '@/routes';
import { logger } from '@/utils/logger';

export function createApp(): Express {
  const app = express();

  // Security middleware
  app.use(helmet());
  app.use(cors());
  app.use(compression());

  // Body parsing
  app.use(express.json({ limit: '10kb' }));
  app.use(express.urlencoded({ extended: true }));

  // Request ID and logging
  app.use(requestId);
  app.use(pinoHttp({ logger }));

  // Health check
  app.get('/health', (_req: Request, res: Response) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
  });

  // API routes
  app.use('/api/v1', routes);

  // Error handling
  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}


// ==========================================
// src/server.ts
// ==========================================

import { createApp } from './app';
import { env } from '@/config/env';
import { logger } from '@/utils/logger';
import { prisma } from '@/config/database';

async function bootstrap(): Promise<void> {
  const app = createApp();

  // Graceful shutdown
  const server = app.listen(env.PORT, () => {
    logger.info(`Server running on port ${env.PORT} in ${env.NODE_ENV} mode`);
  });

  const shutdown = async (signal: string): Promise<void> => {
    logger.info(`${signal} received, shutting down gracefully`);
    
    server.close(async () => {
      await prisma.$disconnect();
      logger.info('Server closed');
      process.exit(0);
    });

    // Force shutdown after 10s
    setTimeout(() => {
      logger.error('Forced shutdown after timeout');
      process.exit(1);
    }, 10000);
  };

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));
}

bootstrap().catch((error) => {
  logger.fatal(error, 'Failed to start server');
  process.exit(1);
});
```

### Express Type Extensions
```typescript
// ==========================================
// src/types/express.d.ts
// ==========================================

import type { User } from '@prisma/client';

declare global {
  namespace Express {
    interface Request {
      user?: User;
      requestId: string;
    }
  }
}

export {};
```

---

## 3) Typed Routes and Controllers

### Route Definitions
```typescript
// ==========================================
// src/routes/index.ts
// ==========================================

import { Router } from 'express';
import authRoutes from './auth.routes';
import userRoutes from './user.routes';

const router = Router();

router.use('/auth', authRoutes);
router.use('/users', userRoutes);

export default router;


// ==========================================
// src/routes/user.routes.ts
// ==========================================

import { Router } from 'express';
import { UserController } from '@/controllers/user.controller';
import { authenticate, authorize } from '@/middleware/auth.middleware';
import { validate } from '@/middleware/validate.middleware';
import { createUserSchema, updateUserSchema, userIdSchema } from '@/schemas/user.schema';

const router = Router();
const controller = new UserController();

// All routes require authentication
router.use(authenticate);

router.get(
  '/',
  authorize('admin'),
  controller.getAll
);

router.get(
  '/:id',
  validate(userIdSchema, 'params'),
  controller.getById
);

router.post(
  '/',
  authorize('admin'),
  validate(createUserSchema),
  controller.create
);

router.patch(
  '/:id',
  validate(userIdSchema, 'params'),
  validate(updateUserSchema),
  controller.update
);

router.delete(
  '/:id',
  authorize('admin'),
  validate(userIdSchema, 'params'),
  controller.delete
);

export default router;
```

### Typed Controllers
```typescript
// ==========================================
// src/controllers/user.controller.ts
// ==========================================

import type { Request, Response, NextFunction } from 'express';
import { UserService } from '@/services/user.service';
import { AppError } from '@/utils/errors';
import type { CreateUserInput, UpdateUserInput } from '@/schemas/user.schema';

export class UserController {
  private readonly userService = new UserService();

  getAll = async (
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;

      const { users, total } = await this.userService.findAll({ page, limit });

      res.json({
        success: true,
        data: users,
        meta: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit),
        },
      });
    } catch (error) {
      next(error);
    }
  };

  getById = async (
    req: Request<{ id: string }>,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      const user = await this.userService.findById(req.params.id);

      if (!user) {
        throw new AppError('User not found', 404, 'USER_NOT_FOUND');
      }

      res.json({ success: true, data: user });
    } catch (error) {
      next(error);
    }
  };

  create = async (
    req: Request<unknown, unknown, CreateUserInput>,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      const user = await this.userService.create(req.body);

      res.status(201).json({ success: true, data: user });
    } catch (error) {
      next(error);
    }
  };

  update = async (
    req: Request<{ id: string }, unknown, UpdateUserInput>,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      const user = await this.userService.update(req.params.id, req.body);

      res.json({ success: true, data: user });
    } catch (error) {
      next(error);
    }
  };

  delete = async (
    req: Request<{ id: string }>,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      await this.userService.delete(req.params.id);

      res.status(204).send();
    } catch (error) {
      next(error);
    }
  };
}


// ==========================================
// TYPE-SAFE CONTROLLER FACTORY
// ==========================================

import type { Request, Response, NextFunction, RequestHandler } from 'express';

type AsyncHandler<
  P = unknown,
  ResBody = unknown,
  ReqBody = unknown,
  ReqQuery = unknown
> = (
  req: Request<P, ResBody, ReqBody, ReqQuery>,
  res: Response<ResBody>,
  next: NextFunction
) => Promise<void>;

// Wrapper to catch async errors
function asyncHandler<P, ResBody, ReqBody, ReqQuery>(
  handler: AsyncHandler<P, ResBody, ReqBody, ReqQuery>
): RequestHandler<P, ResBody, ReqBody, ReqQuery> {
  return (req, res, next) => {
    Promise.resolve(handler(req, res, next)).catch(next);
  };
}

// Usage
router.get(
  '/:id',
  asyncHandler<{ id: string }>(async (req, res) => {
    const user = await userService.findById(req.params.id);
    res.json({ data: user });
  })
);
```

---

## 4) Validation with Zod

### Schema Definitions
```typescript
// ==========================================
// src/schemas/user.schema.ts
// ==========================================

import { z } from 'zod';

export const createUserSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  password: z
    .string()
    .min(8)
    .regex(/[A-Z]/, 'Must contain uppercase')
    .regex(/[a-z]/, 'Must contain lowercase')
    .regex(/[0-9]/, 'Must contain number'),
  role: z.enum(['user', 'admin', 'moderator']).default('user'),
});

export const updateUserSchema = z.object({
  name: z.string().min(2).max(100).optional(),
  email: z.string().email().optional(),
  avatar: z.string().url().optional(),
});

export const userIdSchema = z.object({
  id: z.string().uuid(),
});

export const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

export const paginationSchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(10),
  sortBy: z.string().optional(),
  sortOrder: z.enum(['asc', 'desc']).default('desc'),
});

// Export inferred types
export type CreateUserInput = z.infer<typeof createUserSchema>;
export type UpdateUserInput = z.infer<typeof updateUserSchema>;
export type UserIdParams = z.infer<typeof userIdSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
export type PaginationQuery = z.infer<typeof paginationSchema>;
```

### Validation Middleware
```typescript
// ==========================================
// src/middleware/validate.middleware.ts
// ==========================================

import type { Request, Response, NextFunction, RequestHandler } from 'express';
import { z, type ZodSchema, type ZodError } from 'zod';
import { AppError } from '@/utils/errors';

type ValidationTarget = 'body' | 'query' | 'params';

export function validate<T extends ZodSchema>(
  schema: T,
  target: ValidationTarget = 'body'
): RequestHandler {
  return (req: Request, res: Response, next: NextFunction): void => {
    try {
      const data = schema.parse(req[target]);
      
      // Replace with validated and transformed data
      req[target] = data;
      next();
    } catch (error) {
      if (error instanceof z.ZodError) {
        const validationError = formatZodError(error);
        next(new AppError(
          'Validation failed',
          400,
          'VALIDATION_ERROR',
          validationError
        ));
      } else {
        next(error);
      }
    }
  };
}

function formatZodError(error: ZodError): Record<string, string[]> {
  const formatted: Record<string, string[]> = {};

  for (const issue of error.issues) {
    const path = issue.path.join('.');
    if (!formatted[path]) {
      formatted[path] = [];
    }
    formatted[path].push(issue.message);
  }

  return formatted;
}


// ==========================================
// ADVANCED VALIDATION
// ==========================================

// Validate multiple targets
interface ValidationMap {
  body?: ZodSchema;
  query?: ZodSchema;
  params?: ZodSchema;
}

export function validateAll(schemas: ValidationMap): RequestHandler {
  return (req: Request, res: Response, next: NextFunction): void => {
    try {
      const errors: Record<string, Record<string, string[]>> = {};

      for (const [target, schema] of Object.entries(schemas)) {
        if (schema) {
          const result = schema.safeParse(req[target as ValidationTarget]);
          
          if (!result.success) {
            errors[target] = formatZodError(result.error);
          } else {
            req[target as ValidationTarget] = result.data;
          }
        }
      }

      if (Object.keys(errors).length > 0) {
        throw new AppError('Validation failed', 400, 'VALIDATION_ERROR', errors);
      }

      next();
    } catch (error) {
      next(error);
    }
  };
}

// Usage
router.get(
  '/:id',
  validateAll({
    params: userIdSchema,
    query: paginationSchema,
  }),
  controller.getById
);
```

---

## 5) Error Handling

### Typed Error Classes
```typescript
// ==========================================
// src/utils/errors.ts
// ==========================================

export class AppError extends Error {
  public readonly statusCode: number;
  public readonly code: string;
  public readonly isOperational: boolean;
  public readonly details?: unknown;

  constructor(
    message: string,
    statusCode: number = 500,
    code: string = 'INTERNAL_ERROR',
    details?: unknown
  ) {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.isOperational = true;
    this.details = details;

    Error.captureStackTrace(this, this.constructor);
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string = 'Resource') {
    super(`${resource} not found`, 404, 'NOT_FOUND');
  }
}

export class UnauthorizedError extends AppError {
  constructor(message: string = 'Unauthorized') {
    super(message, 401, 'UNAUTHORIZED');
  }
}

export class ForbiddenError extends AppError {
  constructor(message: string = 'Forbidden') {
    super(message, 403, 'FORBIDDEN');
  }
}

export class ConflictError extends AppError {
  constructor(message: string = 'Resource already exists') {
    super(message, 409, 'CONFLICT');
  }
}

export class ValidationError extends AppError {
  constructor(details: unknown) {
    super('Validation failed', 400, 'VALIDATION_ERROR', details);
  }
}

export class RateLimitError extends AppError {
  constructor() {
    super('Too many requests', 429, 'RATE_LIMIT_EXCEEDED');
  }
}
```

### Error Middleware
```typescript
// ==========================================
// src/middleware/error.middleware.ts
// ==========================================

import type { Request, Response, NextFunction, ErrorRequestHandler } from 'express';
import { Prisma } from '@prisma/client';
import { AppError } from '@/utils/errors';
import { logger } from '@/utils/logger';
import { env } from '@/config/env';

interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details?: unknown;
    stack?: string;
  };
  requestId: string;
  timestamp: string;
}

export const errorHandler: ErrorRequestHandler = (
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction
): void => {
  // Log error
  logger.error({
    err,
    requestId: req.requestId,
    method: req.method,
    path: req.path,
  });

  // Handle known errors
  if (err instanceof AppError) {
    const response: ErrorResponse = {
      success: false,
      error: {
        code: err.code,
        message: err.message,
        details: err.details,
        ...(env.NODE_ENV === 'development' && { stack: err.stack }),
      },
      requestId: req.requestId,
      timestamp: new Date().toISOString(),
    };

    res.status(err.statusCode).json(response);
    return;
  }

  // Handle Prisma errors
  if (err instanceof Prisma.PrismaClientKnownRequestError) {
    const { statusCode, message, code } = handlePrismaError(err);
    
    res.status(statusCode).json({
      success: false,
      error: { code, message },
      requestId: req.requestId,
      timestamp: new Date().toISOString(),
    });
    return;
  }

  // Handle unexpected errors
  const response: ErrorResponse = {
    success: false,
    error: {
      code: 'INTERNAL_ERROR',
      message: env.NODE_ENV === 'production'
        ? 'An unexpected error occurred'
        : err.message,
      ...(env.NODE_ENV === 'development' && { stack: err.stack }),
    },
    requestId: req.requestId,
    timestamp: new Date().toISOString(),
  };

  res.status(500).json(response);
};

function handlePrismaError(error: Prisma.PrismaClientKnownRequestError): {
  statusCode: number;
  message: string;
  code: string;
} {
  switch (error.code) {
    case 'P2002':
      return {
        statusCode: 409,
        message: 'Resource already exists',
        code: 'CONFLICT',
      };
    case 'P2025':
      return {
        statusCode: 404,
        message: 'Resource not found',
        code: 'NOT_FOUND',
      };
    default:
      return {
        statusCode: 500,
        message: 'Database error',
        code: 'DATABASE_ERROR',
      };
  }
}

export const notFoundHandler = (
  req: Request,
  res: Response,
  _next: NextFunction
): void => {
  res.status(404).json({
    success: false,
    error: {
      code: 'NOT_FOUND',
      message: `Route ${req.method} ${req.path} not found`,
    },
    requestId: req.requestId,
    timestamp: new Date().toISOString(),
  });
};
```

---

## 6) Authentication & Authorization

### JWT Utilities
```typescript
// ==========================================
// src/utils/jwt.ts
// ==========================================

import jwt, { type JwtPayload, type SignOptions } from 'jsonwebtoken';
import { env } from '@/config/env';
import { UnauthorizedError } from './errors';

export interface TokenPayload extends JwtPayload {
  userId: string;
  role: string;
}

export interface TokenPair {
  accessToken: string;
  refreshToken: string;
}

const accessTokenOptions: SignOptions = {
  expiresIn: '15m',
  algorithm: 'HS256',
};

const refreshTokenOptions: SignOptions = {
  expiresIn: '7d',
  algorithm: 'HS256',
};

export function generateTokens(payload: Omit<TokenPayload, 'iat' | 'exp'>): TokenPair {
  const accessToken = jwt.sign(payload, env.JWT_SECRET, accessTokenOptions);
  const refreshToken = jwt.sign(payload, env.JWT_REFRESH_SECRET, refreshTokenOptions);

  return { accessToken, refreshToken };
}

export function verifyAccessToken(token: string): TokenPayload {
  try {
    return jwt.verify(token, env.JWT_SECRET) as TokenPayload;
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      throw new UnauthorizedError('Token expired');
    }
    if (error instanceof jwt.JsonWebTokenError) {
      throw new UnauthorizedError('Invalid token');
    }
    throw error;
  }
}

export function verifyRefreshToken(token: string): TokenPayload {
  try {
    return jwt.verify(token, env.JWT_REFRESH_SECRET) as TokenPayload;
  } catch (error) {
    throw new UnauthorizedError('Invalid refresh token');
  }
}
```

### Auth Middleware
```typescript
// ==========================================
// src/middleware/auth.middleware.ts
// ==========================================

import type { Request, Response, NextFunction, RequestHandler } from 'express';
import { verifyAccessToken, type TokenPayload } from '@/utils/jwt';
import { UnauthorizedError, ForbiddenError } from '@/utils/errors';
import { prisma } from '@/config/database';

export const authenticate: RequestHandler = async (
  req: Request,
  _res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader?.startsWith('Bearer ')) {
      throw new UnauthorizedError('No token provided');
    }

    const token = authHeader.substring(7);
    const payload = verifyAccessToken(token);

    const user = await prisma.user.findUnique({
      where: { id: payload.userId },
      select: {
        id: true,
        email: true,
        name: true,
        role: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!user) {
      throw new UnauthorizedError('User not found');
    }

    req.user = user;
    next();
  } catch (error) {
    next(error);
  }
};

export function authorize(...roles: string[]): RequestHandler {
  return (req: Request, _res: Response, next: NextFunction): void => {
    if (!req.user) {
      next(new UnauthorizedError('Not authenticated'));
      return;
    }

    if (!roles.includes(req.user.role)) {
      next(new ForbiddenError('Insufficient permissions'));
      return;
    }

    next();
  };
}

// Optional authentication (doesn't throw if no token)
export const optionalAuth: RequestHandler = async (
  req: Request,
  _res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;

    if (authHeader?.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      const payload = verifyAccessToken(token);

      const user = await prisma.user.findUnique({
        where: { id: payload.userId },
      });

      if (user) {
        req.user = user;
      }
    }

    next();
  } catch {
    // Ignore errors for optional auth
    next();
  }
};
```

---

## 7) Environment Configuration

### Typed Environment
```typescript
// ==========================================
// src/config/env.ts
// ==========================================

import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.coerce.number().default(3000),
  HOST: z.string().default('0.0.0.0'),

  // Database
  DATABASE_URL: z.string().url(),

  // JWT
  JWT_SECRET: z.string().min(32),
  JWT_REFRESH_SECRET: z.string().min(32),

  // API
  API_PREFIX: z.string().default('/api/v1'),
  CORS_ORIGINS: z.string().transform((s) => s.split(',')),

  // Rate limiting
  RATE_LIMIT_WINDOW_MS: z.coerce.number().default(60000),
  RATE_LIMIT_MAX: z.coerce.number().default(100),

  // Logging
  LOG_LEVEL: z.enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace']).default('info'),
});

type Env = z.infer<typeof envSchema>;

function validateEnv(): Env {
  const result = envSchema.safeParse(process.env);

  if (!result.success) {
    console.error('❌ Invalid environment variables:');
    console.error(result.error.format());
    process.exit(1);
  }

  return result.data;
}

export const env = validateEnv();

// Type-safe environment access
declare global {
  namespace NodeJS {
    interface ProcessEnv extends Env {}
  }
}
```

---

## 8) Database with Prisma

### Database Client
```typescript
// ==========================================
// src/config/database.ts
// ==========================================

import { PrismaClient } from '@prisma/client';
import { logger } from '@/utils/logger';
import { env } from './env';

const prismaClientSingleton = (): PrismaClient => {
  return new PrismaClient({
    log: env.NODE_ENV === 'development'
      ? [
          { level: 'query', emit: 'event' },
          { level: 'error', emit: 'stdout' },
          { level: 'warn', emit: 'stdout' },
        ]
      : [{ level: 'error', emit: 'stdout' }],
  });
};

declare global {
  var prisma: PrismaClient | undefined;
}

export const prisma = globalThis.prisma ?? prismaClientSingleton();

if (env.NODE_ENV !== 'production') {
  globalThis.prisma = prisma;
}

// Log queries in development
if (env.NODE_ENV === 'development') {
  prisma.$on('query' as never, (e: { query: string; duration: number }) => {
    logger.debug({ query: e.query, duration: `${e.duration}ms` }, 'Prisma Query');
  });
}
```

### Typed Service Layer
```typescript
// ==========================================
// src/services/user.service.ts
// ==========================================

import { Prisma, type User } from '@prisma/client';
import { prisma } from '@/config/database';
import { hashPassword } from '@/utils/password';
import { AppError, ConflictError, NotFoundError } from '@/utils/errors';
import type { CreateUserInput, UpdateUserInput } from '@/schemas/user.schema';

interface PaginationOptions {
  page: number;
  limit: number;
}

interface PaginatedResult<T> {
  data: T[];
  total: number;
}

// Exclude password from user responses
const userSelect = {
  id: true,
  email: true,
  name: true,
  role: true,
  avatar: true,
  createdAt: true,
  updatedAt: true,
} satisfies Prisma.UserSelect;

type SafeUser = Prisma.UserGetPayload<{ select: typeof userSelect }>;

export class UserService {
  async findAll(
    options: PaginationOptions
  ): Promise<{ users: SafeUser[]; total: number }> {
    const { page, limit } = options;
    const skip = (page - 1) * limit;

    const [users, total] = await Promise.all([
      prisma.user.findMany({
        select: userSelect,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      prisma.user.count(),
    ]);

    return { users, total };
  }

  async findById(id: string): Promise<SafeUser | null> {
    return prisma.user.findUnique({
      where: { id },
      select: userSelect,
    });
  }

  async findByEmail(email: string): Promise<User | null> {
    return prisma.user.findUnique({
      where: { email },
    });
  }

  async create(data: CreateUserInput): Promise<SafeUser> {
    const existing = await this.findByEmail(data.email);

    if (existing) {
      throw new ConflictError('Email already in use');
    }

    const hashedPassword = await hashPassword(data.password);

    return prisma.user.create({
      data: {
        ...data,
        password: hashedPassword,
      },
      select: userSelect,
    });
  }

  async update(id: string, data: UpdateUserInput): Promise<SafeUser> {
    const existing = await this.findById(id);

    if (!existing) {
      throw new NotFoundError('User');
    }

    if (data.email) {
      const emailExists = await prisma.user.findFirst({
        where: {
          email: data.email,
          NOT: { id },
        },
      });

      if (emailExists) {
        throw new ConflictError('Email already in use');
      }
    }

    return prisma.user.update({
      where: { id },
      data,
      select: userSelect,
    });
  }

  async delete(id: string): Promise<void> {
    const existing = await this.findById(id);

    if (!existing) {
      throw new NotFoundError('User');
    }

    await prisma.user.delete({ where: { id } });
  }
}
```

---

## 9) Logging

### Typed Logger
```typescript
// ==========================================
// src/utils/logger.ts
// ==========================================

import pino, { type Logger, type LoggerOptions } from 'pino';
import { env } from '@/config/env';

const options: LoggerOptions = {
  level: env.LOG_LEVEL,
  transport:
    env.NODE_ENV === 'development'
      ? {
          target: 'pino-pretty',
          options: {
            colorize: true,
            translateTime: 'SYS:standard',
            ignore: 'pid,hostname',
          },
        }
      : undefined,
  base: {
    env: env.NODE_ENV,
  },
  redact: ['req.headers.authorization', 'password'],
};

export const logger: Logger = pino(options);

// Child logger factory
export function createLogger(name: string): Logger {
  return logger.child({ module: name });
}

// Usage in services
const serviceLogger = createLogger('UserService');
serviceLogger.info({ userId: '123' }, 'User created');
```

---

## 10) Testing

### API Integration Tests
```typescript
// ==========================================
// src/__tests__/user.test.ts
// ==========================================

import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest';
import request from 'supertest';
import { createApp } from '@/app';
import { prisma } from '@/config/database';
import { generateTokens } from '@/utils/jwt';
import type { Express } from 'express';

describe('User API', () => {
  let app: Express;
  let adminToken: string;
  let userToken: string;

  beforeAll(async () => {
    app = createApp();

    // Create test users
    const admin = await prisma.user.create({
      data: {
        email: 'admin@test.com',
        name: 'Admin',
        password: 'hashedpassword',
        role: 'admin',
      },
    });

    const user = await prisma.user.create({
      data: {
        email: 'user@test.com',
        name: 'User',
        password: 'hashedpassword',
        role: 'user',
      },
    });

    adminToken = generateTokens({ userId: admin.id, role: admin.role }).accessToken;
    userToken = generateTokens({ userId: user.id, role: user.role }).accessToken;
  });

  afterAll(async () => {
    await prisma.user.deleteMany();
    await prisma.$disconnect();
  });

  describe('GET /api/v1/users', () => {
    it('should return 401 without token', async () => {
      const response = await request(app).get('/api/v1/users');

      expect(response.status).toBe(401);
      expect(response.body.error.code).toBe('UNAUTHORIZED');
    });

    it('should return 403 for non-admin users', async () => {
      const response = await request(app)
        .get('/api/v1/users')
        .set('Authorization', `Bearer ${userToken}`);

      expect(response.status).toBe(403);
      expect(response.body.error.code).toBe('FORBIDDEN');
    });

    it('should return users for admin', async () => {
      const response = await request(app)
        .get('/api/v1/users')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toBeInstanceOf(Array);
      expect(response.body.meta).toHaveProperty('total');
    });
  });

  describe('POST /api/v1/users', () => {
    it('should validate request body', async () => {
      const response = await request(app)
        .post('/api/v1/users')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({ email: 'invalid' });

      expect(response.status).toBe(400);
      expect(response.body.error.code).toBe('VALIDATION_ERROR');
    });

    it('should create user with valid data', async () => {
      const response = await request(app)
        .post('/api/v1/users')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          email: 'new@test.com',
          name: 'New User',
          password: 'Password123!',
        });

      expect(response.status).toBe(201);
      expect(response.body.data).toHaveProperty('id');
      expect(response.body.data.email).toBe('new@test.com');
      expect(response.body.data).not.toHaveProperty('password');
    });
  });
});
```

---

## Best Practices Checklist

### Setup
- [ ] Strict TypeScript
- [ ] Path aliases
- [ ] Environment validation

### Routes
- [ ] Typed handlers
- [ ] Validation middleware
- [ ] Error handling

### Security
- [ ] JWT authentication
- [ ] Role-based authorization
- [ ] Input validation

### Database
- [ ] Typed queries
- [ ] Safe user select
- [ ] Error handling

### Testing
- [ ] Integration tests
- [ ] Typed assertions
- [ ] Cleanup between tests

---

**References:**
- [Express TypeScript](https://expressjs.com/en/resources/frameworks.html)
- [Prisma](https://www.prisma.io/docs)
- [Zod](https://zod.dev/)
- [Pino](https://getpino.io/)

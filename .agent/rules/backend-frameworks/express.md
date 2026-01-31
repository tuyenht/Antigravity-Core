# Express.js Advanced Patterns

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Express Version:** 4.x / 5.x
> **Priority:** P0 - Load for all Express.js projects

---

You are an expert in Express.js backend development with TypeScript.

## Key Principles

- Minimalist and unopinionated framework
- Middleware-centric architecture
- Type-safe with TypeScript
- Async/await everywhere
- Robust error handling
- Modular, feature-based structure

---

## Project Structure

```
src/
├── app.ts                 # Express app setup
├── server.ts              # Server bootstrap
├── config/
│   ├── index.ts           # Configuration loader
│   ├── database.ts        # Database config
│   └── env.ts             # Environment validation
├── modules/
│   ├── users/
│   │   ├── user.controller.ts
│   │   ├── user.service.ts
│   │   ├── user.repository.ts
│   │   ├── user.routes.ts
│   │   ├── user.schema.ts     # Zod schemas
│   │   └── user.types.ts
│   └── products/
│       └── ...
├── middleware/
│   ├── auth.middleware.ts
│   ├── error.middleware.ts
│   ├── validate.middleware.ts
│   └── logger.middleware.ts
├── utils/
│   ├── async-handler.ts
│   ├── api-error.ts
│   └── logger.ts
└── types/
    ├── express.d.ts       # Express type extensions
    └── env.d.ts
```

---

## Application Setup

### app.ts
```typescript
import express, { Express } from 'express';
import helmet from 'helmet';
import cors from 'cors';
import compression from 'compression';
import { rateLimit } from 'express-rate-limit';
import { pinoHttp } from 'pino-http';

import { config } from './config';
import { errorHandler, notFoundHandler } from './middleware/error.middleware';
import { userRoutes } from './modules/users/user.routes';
import { productRoutes } from './modules/products/product.routes';
import { logger } from './utils/logger';

export function createApp(): Express {
  const app = express();

  // Security middleware
  app.use(helmet());
  app.use(cors({
    origin: config.corsOrigins,
    credentials: true,
  }));

  // Rate limiting
  app.use(rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100,
    standardHeaders: true,
    legacyHeaders: false,
    message: { error: 'Too many requests, please try again later' },
  }));

  // Request parsing
  app.use(express.json({ limit: '10kb' }));
  app.use(express.urlencoded({ extended: true }));
  app.use(compression());

  // Logging
  app.use(pinoHttp({ logger }));

  // Health check
  app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
  });

  // API routes
  app.use('/api/v1/users', userRoutes);
  app.use('/api/v1/products', productRoutes);

  // Error handling (must be last)
  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
```

### server.ts
```typescript
import { createApp } from './app';
import { config } from './config';
import { logger } from './utils/logger';
import { prisma } from './config/database';

const app = createApp();

const server = app.listen(config.port, () => {
  logger.info(`Server running on port ${config.port} in ${config.nodeEnv} mode`);
});

// Graceful shutdown
const gracefulShutdown = async (signal: string) => {
  logger.info(`${signal} received. Starting graceful shutdown...`);
  
  server.close(async () => {
    logger.info('HTTP server closed');
    
    // Close database connection
    await prisma.$disconnect();
    logger.info('Database connection closed');
    
    process.exit(0);
  });

  // Force close after 30s
  setTimeout(() => {
    logger.error('Could not close connections in time, forcefully shutting down');
    process.exit(1);
  }, 30000);
};

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  logger.fatal(error, 'Uncaught Exception');
  process.exit(1);
});

process.on('unhandledRejection', (reason) => {
  logger.fatal(reason, 'Unhandled Rejection');
  process.exit(1);
});
```

---

## Configuration

### config/env.ts
```typescript
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.string().transform(Number).default('3000'),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  JWT_EXPIRES_IN: z.string().default('7d'),
  CORS_ORIGINS: z.string().transform(s => s.split(',')),
  REDIS_URL: z.string().url().optional(),
});

export type Env = z.infer<typeof envSchema>;

export function validateEnv(): Env {
  const parsed = envSchema.safeParse(process.env);
  
  if (!parsed.success) {
    console.error('❌ Invalid environment variables:');
    console.error(parsed.error.flatten().fieldErrors);
    process.exit(1);
  }
  
  return parsed.data;
}
```

### config/index.ts
```typescript
import { validateEnv } from './env';

const env = validateEnv();

export const config = {
  nodeEnv: env.NODE_ENV,
  port: env.PORT,
  databaseUrl: env.DATABASE_URL,
  jwt: {
    secret: env.JWT_SECRET,
    expiresIn: env.JWT_EXPIRES_IN,
  },
  corsOrigins: env.CORS_ORIGINS,
  redisUrl: env.REDIS_URL,
  isProduction: env.NODE_ENV === 'production',
  isDevelopment: env.NODE_ENV === 'development',
} as const;
```

---

## Middleware

### Async Handler (Express 4.x)
```typescript
// utils/async-handler.ts
import { Request, Response, NextFunction, RequestHandler } from 'express';

// Wraps async handlers to catch errors
export const asyncHandler = (
  fn: (req: Request, res: Response, next: NextFunction) => Promise<any>
): RequestHandler => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

// Express 5.x has built-in async support, no wrapper needed
```

### API Error Class
```typescript
// utils/api-error.ts
export class ApiError extends Error {
  constructor(
    public statusCode: number,
    public message: string,
    public isOperational = true,
    public errors?: Record<string, string[]>
  ) {
    super(message);
    Object.setPrototypeOf(this, ApiError.prototype);
    Error.captureStackTrace(this, this.constructor);
  }

  static badRequest(message: string, errors?: Record<string, string[]>) {
    return new ApiError(400, message, true, errors);
  }

  static unauthorized(message = 'Unauthorized') {
    return new ApiError(401, message);
  }

  static forbidden(message = 'Forbidden') {
    return new ApiError(403, message);
  }

  static notFound(message = 'Not found') {
    return new ApiError(404, message);
  }

  static conflict(message: string) {
    return new ApiError(409, message);
  }

  static internal(message = 'Internal server error') {
    return new ApiError(500, message, false);
  }
}
```

### Error Handler Middleware
```typescript
// middleware/error.middleware.ts
import { Request, Response, NextFunction, ErrorRequestHandler } from 'express';
import { ZodError } from 'zod';
import { Prisma } from '@prisma/client';
import { ApiError } from '../utils/api-error';
import { logger } from '../utils/logger';
import { config } from '../config';

export const notFoundHandler = (req: Request, res: Response) => {
  res.status(404).json({
    status: 'error',
    message: `Route ${req.method} ${req.path} not found`,
  });
};

export const errorHandler: ErrorRequestHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  // Log error
  logger.error({
    err,
    req: {
      method: req.method,
      url: req.url,
      body: req.body,
      user: (req as any).user?.id,
    },
  });

  // Handle Zod validation errors
  if (err instanceof ZodError) {
    return res.status(400).json({
      status: 'error',
      message: 'Validation failed',
      errors: err.flatten().fieldErrors,
    });
  }

  // Handle Prisma errors
  if (err instanceof Prisma.PrismaClientKnownRequestError) {
    if (err.code === 'P2002') {
      return res.status(409).json({
        status: 'error',
        message: 'A record with this value already exists',
      });
    }
    if (err.code === 'P2025') {
      return res.status(404).json({
        status: 'error',
        message: 'Record not found',
      });
    }
  }

  // Handle API errors
  if (err instanceof ApiError) {
    return res.status(err.statusCode).json({
      status: 'error',
      message: err.message,
      ...(err.errors && { errors: err.errors }),
    });
  }

  // Handle unknown errors
  const statusCode = 500;
  const message = config.isProduction 
    ? 'Internal server error' 
    : err.message;

  res.status(statusCode).json({
    status: 'error',
    message,
    ...(config.isDevelopment && { stack: err.stack }),
  });
};
```

### Validation Middleware
```typescript
// middleware/validate.middleware.ts
import { Request, Response, NextFunction } from 'express';
import { AnyZodObject, ZodError } from 'zod';

type ValidateTarget = 'body' | 'query' | 'params';

export const validate = (
  schema: AnyZodObject,
  target: ValidateTarget = 'body'
) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      const validated = await schema.parseAsync(req[target]);
      req[target] = validated;
      next();
    } catch (error) {
      next(error);
    }
  };
};

// Combined validation
export const validateRequest = (schemas: {
  body?: AnyZodObject;
  query?: AnyZodObject;
  params?: AnyZodObject;
}) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (schemas.body) {
        req.body = await schemas.body.parseAsync(req.body);
      }
      if (schemas.query) {
        req.query = await schemas.query.parseAsync(req.query) as any;
      }
      if (schemas.params) {
        req.params = await schemas.params.parseAsync(req.params) as any;
      }
      next();
    } catch (error) {
      next(error);
    }
  };
};
```

### Authentication Middleware
```typescript
// middleware/auth.middleware.ts
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config';
import { ApiError } from '../utils/api-error';
import { prisma } from '../config/database';

export interface AuthRequest extends Request {
  user: {
    id: number;
    email: string;
    role: string;
  };
}

export const authenticate = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader?.startsWith('Bearer ')) {
      throw ApiError.unauthorized('No token provided');
    }
    
    const token = authHeader.split(' ')[1];
    
    const payload = jwt.verify(token, config.jwt.secret) as {
      userId: number;
    };
    
    const user = await prisma.user.findUnique({
      where: { id: payload.userId },
      select: { id: true, email: true, role: true },
    });
    
    if (!user) {
      throw ApiError.unauthorized('User not found');
    }
    
    (req as AuthRequest).user = user;
    next();
  } catch (error) {
    if (error instanceof jwt.JsonWebTokenError) {
      next(ApiError.unauthorized('Invalid token'));
    } else {
      next(error);
    }
  }
};

export const authorize = (...roles: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const user = (req as AuthRequest).user;
    
    if (!user) {
      return next(ApiError.unauthorized());
    }
    
    if (!roles.includes(user.role)) {
      return next(ApiError.forbidden('Insufficient permissions'));
    }
    
    next();
  };
};
```

---

## Module Pattern

### user.schema.ts (Zod Validation)
```typescript
import { z } from 'zod';

export const createUserSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  password: z.string().min(8).regex(
    /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/,
    'Password must contain uppercase, lowercase, and number'
  ),
  role: z.enum(['user', 'admin']).default('user'),
});

export const updateUserSchema = z.object({
  name: z.string().min(2).max(100).optional(),
  email: z.string().email().optional(),
});

export const getUsersQuerySchema = z.object({
  page: z.string().transform(Number).default('1'),
  limit: z.string().transform(Number).default('10'),
  search: z.string().optional(),
  role: z.enum(['user', 'admin']).optional(),
});

export const userIdParamSchema = z.object({
  id: z.string().transform(Number),
});

export type CreateUserInput = z.infer<typeof createUserSchema>;
export type UpdateUserInput = z.infer<typeof updateUserSchema>;
export type GetUsersQuery = z.infer<typeof getUsersQuerySchema>;
```

### user.service.ts
```typescript
import { Prisma } from '@prisma/client';
import bcrypt from 'bcryptjs';
import { prisma } from '../../config/database';
import { ApiError } from '../../utils/api-error';
import { CreateUserInput, UpdateUserInput, GetUsersQuery } from './user.schema';

export class UserService {
  async findAll(query: GetUsersQuery) {
    const { page, limit, search, role } = query;
    const skip = (page - 1) * limit;
    
    const where: Prisma.UserWhereInput = {
      ...(search && {
        OR: [
          { name: { contains: search, mode: 'insensitive' } },
          { email: { contains: search, mode: 'insensitive' } },
        ],
      }),
      ...(role && { role }),
    };
    
    const [users, total] = await Promise.all([
      prisma.user.findMany({
        where,
        skip,
        take: limit,
        select: {
          id: true,
          name: true,
          email: true,
          role: true,
          createdAt: true,
        },
        orderBy: { createdAt: 'desc' },
      }),
      prisma.user.count({ where }),
    ]);
    
    return {
      data: users,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }
  
  async findById(id: number) {
    const user = await prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        createdAt: true,
        updatedAt: true,
      },
    });
    
    if (!user) {
      throw ApiError.notFound('User not found');
    }
    
    return user;
  }
  
  async create(data: CreateUserInput) {
    const existingUser = await prisma.user.findUnique({
      where: { email: data.email },
    });
    
    if (existingUser) {
      throw ApiError.conflict('Email already registered');
    }
    
    const hashedPassword = await bcrypt.hash(data.password, 12);
    
    return prisma.user.create({
      data: {
        ...data,
        password: hashedPassword,
      },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        createdAt: true,
      },
    });
  }
  
  async update(id: number, data: UpdateUserInput) {
    await this.findById(id); // Check exists
    
    if (data.email) {
      const existingUser = await prisma.user.findFirst({
        where: {
          email: data.email,
          NOT: { id },
        },
      });
      
      if (existingUser) {
        throw ApiError.conflict('Email already in use');
      }
    }
    
    return prisma.user.update({
      where: { id },
      data,
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        updatedAt: true,
      },
    });
  }
  
  async delete(id: number) {
    await this.findById(id); // Check exists
    
    await prisma.user.delete({
      where: { id },
    });
  }
}

export const userService = new UserService();
```

### user.controller.ts
```typescript
import { Request, Response } from 'express';
import { userService } from './user.service';
import { AuthRequest } from '../../middleware/auth.middleware';
import { GetUsersQuery, CreateUserInput, UpdateUserInput } from './user.schema';

export class UserController {
  async getAll(req: Request, res: Response) {
    const query = req.query as unknown as GetUsersQuery;
    const result = await userService.findAll(query);
    
    res.json({
      status: 'success',
      ...result,
    });
  }
  
  async getById(req: Request, res: Response) {
    const id = Number(req.params.id);
    const user = await userService.findById(id);
    
    res.json({
      status: 'success',
      data: user,
    });
  }
  
  async create(req: Request, res: Response) {
    const data = req.body as CreateUserInput;
    const user = await userService.create(data);
    
    res.status(201).json({
      status: 'success',
      data: user,
    });
  }
  
  async update(req: Request, res: Response) {
    const id = Number(req.params.id);
    const data = req.body as UpdateUserInput;
    const user = await userService.update(id, data);
    
    res.json({
      status: 'success',
      data: user,
    });
  }
  
  async delete(req: Request, res: Response) {
    const id = Number(req.params.id);
    await userService.delete(id);
    
    res.status(204).send();
  }
  
  async getProfile(req: Request, res: Response) {
    const userId = (req as AuthRequest).user.id;
    const user = await userService.findById(userId);
    
    res.json({
      status: 'success',
      data: user,
    });
  }
}

export const userController = new UserController();
```

### user.routes.ts
```typescript
import { Router } from 'express';
import { asyncHandler } from '../../utils/async-handler';
import { validate, validateRequest } from '../../middleware/validate.middleware';
import { authenticate, authorize } from '../../middleware/auth.middleware';
import { userController } from './user.controller';
import {
  createUserSchema,
  updateUserSchema,
  getUsersQuerySchema,
  userIdParamSchema,
} from './user.schema';

const router = Router();

// Public routes
router.post(
  '/',
  validate(createUserSchema),
  asyncHandler(userController.create.bind(userController))
);

// Protected routes
router.use(authenticate);

router.get(
  '/me',
  asyncHandler(userController.getProfile.bind(userController))
);

router.get(
  '/',
  authorize('admin'),
  validate(getUsersQuerySchema, 'query'),
  asyncHandler(userController.getAll.bind(userController))
);

router.get(
  '/:id',
  validateRequest({
    params: userIdParamSchema,
  }),
  asyncHandler(userController.getById.bind(userController))
);

router.patch(
  '/:id',
  authorize('admin'),
  validateRequest({
    params: userIdParamSchema,
    body: updateUserSchema,
  }),
  asyncHandler(userController.update.bind(userController))
);

router.delete(
  '/:id',
  authorize('admin'),
  validate(userIdParamSchema, 'params'),
  asyncHandler(userController.delete.bind(userController))
);

export { router as userRoutes };
```

---

## Type Extensions

### types/express.d.ts
```typescript
import { User } from '@prisma/client';

declare global {
  namespace Express {
    interface Request {
      user?: {
        id: number;
        email: string;
        role: string;
      };
    }
  }
}

export {};
```

---

## Testing

### Integration Tests with Supertest
```typescript
import request from 'supertest';
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { createApp } from '../src/app';
import { prisma } from '../src/config/database';

const app = createApp();

describe('User API', () => {
  let authToken: string;
  let testUserId: number;
  
  beforeAll(async () => {
    // Setup: Create admin user and get token
    const admin = await prisma.user.create({
      data: {
        name: 'Admin',
        email: 'admin@test.com',
        password: await bcrypt.hash('password123', 12),
        role: 'admin',
      },
    });
    
    const response = await request(app)
      .post('/api/v1/auth/login')
      .send({ email: 'admin@test.com', password: 'password123' });
    
    authToken = response.body.token;
  });
  
  afterAll(async () => {
    await prisma.user.deleteMany({
      where: { email: { contains: '@test.com' } },
    });
    await prisma.$disconnect();
  });
  
  describe('POST /api/v1/users', () => {
    it('should create a new user', async () => {
      const response = await request(app)
        .post('/api/v1/users')
        .send({
          name: 'Test User',
          email: 'testuser@test.com',
          password: 'Password123',
        });
      
      expect(response.status).toBe(201);
      expect(response.body.status).toBe('success');
      expect(response.body.data.email).toBe('testuser@test.com');
      
      testUserId = response.body.data.id;
    });
    
    it('should return 400 for invalid email', async () => {
      const response = await request(app)
        .post('/api/v1/users')
        .send({
          name: 'Test User',
          email: 'invalid-email',
          password: 'Password123',
        });
      
      expect(response.status).toBe(400);
      expect(response.body.errors).toHaveProperty('email');
    });
    
    it('should return 409 for duplicate email', async () => {
      const response = await request(app)
        .post('/api/v1/users')
        .send({
          name: 'Another User',
          email: 'testuser@test.com',
          password: 'Password123',
        });
      
      expect(response.status).toBe(409);
    });
  });
  
  describe('GET /api/v1/users', () => {
    it('should return 401 without auth', async () => {
      const response = await request(app)
        .get('/api/v1/users');
      
      expect(response.status).toBe(401);
    });
    
    it('should return users with auth', async () => {
      const response = await request(app)
        .get('/api/v1/users')
        .set('Authorization', `Bearer ${authToken}`);
      
      expect(response.status).toBe(200);
      expect(response.body.data).toBeInstanceOf(Array);
      expect(response.body.meta).toHaveProperty('total');
    });
  });
  
  describe('GET /api/v1/users/:id', () => {
    it('should return user by id', async () => {
      const response = await request(app)
        .get(`/api/v1/users/${testUserId}`)
        .set('Authorization', `Bearer ${authToken}`);
      
      expect(response.status).toBe(200);
      expect(response.body.data.id).toBe(testUserId);
    });
    
    it('should return 404 for non-existent user', async () => {
      const response = await request(app)
        .get('/api/v1/users/99999')
        .set('Authorization', `Bearer ${authToken}`);
      
      expect(response.status).toBe(404);
    });
  });
});
```

---

## Performance Best Practices

- [ ] Use `compression` middleware for gzip
- [ ] Implement Redis caching for frequent queries
- [ ] Use database connection pooling
- [ ] Use `cluster` module or PM2 for multi-core
- [ ] Implement request timeouts
- [ ] Use streaming for large responses
- [ ] Enable HTTP/2 with reverse proxy
- [ ] Use `pino` logger (faster than winston)
- [ ] Avoid synchronous operations
- [ ] Implement circuit breaker for external services

---

**References:**
- [Express.js Documentation](https://expressjs.com/)
- [Express 5.x Beta](https://expressjs.com/en/guide/migrating-5.html)
- [Prisma Documentation](https://www.prisma.io/docs)
- [Zod Documentation](https://zod.dev/)

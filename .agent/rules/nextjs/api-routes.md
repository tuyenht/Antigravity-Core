# Next.js API Routes & Route Handlers Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **Next.js:** 14.x / 15.x  
> **Priority:** P0 - Load for all API development

---

You are an expert in Next.js Route Handlers and API development.

## Core API Principles

- Use Route Handlers in App Router (route.ts)
- Implement proper HTTP methods
- Use TypeScript for type safety
- Handle errors gracefully
- Follow REST API conventions

---

## 1) Route Handler Basics

### Complete CRUD Example
```typescript
// ==========================================
// app/api/posts/route.ts - Collection Routes
// ==========================================

import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import { auth } from '@/auth';
import { prisma } from '@/lib/prisma';

// Response helper
function json<T>(data: T, status = 200) {
  return NextResponse.json(data, { status });
}

function error(message: string, status = 400) {
  return NextResponse.json({ error: message }, { status });
}

// GET /api/posts - List posts with pagination
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = request.nextUrl;
    
    // Parse query params
    const page = parseInt(searchParams.get('page') || '1');
    const limit = parseInt(searchParams.get('limit') || '20');
    const status = searchParams.get('status') || 'PUBLISHED';
    const search = searchParams.get('q');
    
    const skip = (page - 1) * limit;
    
    // Build where clause
    const where = {
      status: status as any,
      deletedAt: null,
      ...(search && {
        OR: [
          { title: { contains: search, mode: 'insensitive' } },
          { content: { contains: search, mode: 'insensitive' } },
        ],
      }),
    };
    
    // Parallel queries
    const [posts, total] = await Promise.all([
      prisma.post.findMany({
        where,
        select: {
          id: true,
          title: true,
          slug: true,
          excerpt: true,
          publishedAt: true,
          author: {
            select: { id: true, name: true, image: true },
          },
          _count: { select: { comments: true, likes: true } },
        },
        orderBy: { publishedAt: 'desc' },
        skip,
        take: limit,
      }),
      prisma.post.count({ where }),
    ]);
    
    return json({
      data: posts,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (err) {
    console.error('GET /api/posts error:', err);
    return error('Failed to fetch posts', 500);
  }
}

// POST /api/posts - Create post
const CreatePostSchema = z.object({
  title: z.string().min(1).max(100),
  content: z.string().min(10),
  excerpt: z.string().max(300).optional(),
  categoryId: z.string().uuid(),
  status: z.enum(['DRAFT', 'PUBLISHED']).default('DRAFT'),
});

export async function POST(request: NextRequest) {
  try {
    // Auth check
    const session = await auth();
    if (!session?.user) {
      return error('Unauthorized', 401);
    }
    
    // Parse and validate body
    const body = await request.json();
    const validated = CreatePostSchema.safeParse(body);
    
    if (!validated.success) {
      return json(
        {
          error: 'Validation failed',
          details: validated.error.flatten().fieldErrors,
        },
        400
      );
    }
    
    const { title, content, excerpt, categoryId, status } = validated.data;
    
    // Generate slug
    const slug = title
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/(^-|-$)/g, '');
    
    // Create post
    const post = await prisma.post.create({
      data: {
        title,
        slug: `${slug}-${Date.now()}`,
        content,
        excerpt,
        categoryId,
        status,
        authorId: session.user.id,
        publishedAt: status === 'PUBLISHED' ? new Date() : null,
      },
    });
    
    return json({ data: post }, 201);
  } catch (err) {
    console.error('POST /api/posts error:', err);
    return error('Failed to create post', 500);
  }
}


// ==========================================
// app/api/posts/[id]/route.ts - Item Routes
// ==========================================

import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';

interface Params {
  params: { id: string };
}

// GET /api/posts/:id - Get single post
export async function GET(request: NextRequest, { params }: Params) {
  try {
    const post = await prisma.post.findUnique({
      where: { id: params.id },
      include: {
        author: {
          select: { id: true, name: true, image: true },
        },
        category: true,
        tags: { include: { tag: true } },
        _count: { select: { comments: true, likes: true } },
      },
    });
    
    if (!post) {
      return error('Post not found', 404);
    }
    
    return json({ data: post });
  } catch (err) {
    console.error(`GET /api/posts/${params.id} error:`, err);
    return error('Failed to fetch post', 500);
  }
}

// PUT /api/posts/:id - Replace post
const UpdatePostSchema = z.object({
  title: z.string().min(1).max(100),
  content: z.string().min(10),
  excerpt: z.string().max(300).optional(),
  categoryId: z.string().uuid(),
  status: z.enum(['DRAFT', 'PUBLISHED', 'ARCHIVED']),
});

export async function PUT(request: NextRequest, { params }: Params) {
  try {
    const session = await auth();
    if (!session?.user) {
      return error('Unauthorized', 401);
    }
    
    // Check ownership
    const existing = await prisma.post.findUnique({
      where: { id: params.id },
      select: { authorId: true },
    });
    
    if (!existing) {
      return error('Post not found', 404);
    }
    
    if (existing.authorId !== session.user.id && session.user.role !== 'ADMIN') {
      return error('Forbidden', 403);
    }
    
    // Validate
    const body = await request.json();
    const validated = UpdatePostSchema.safeParse(body);
    
    if (!validated.success) {
      return json(
        { error: 'Validation failed', details: validated.error.flatten() },
        400
      );
    }
    
    // Update
    const post = await prisma.post.update({
      where: { id: params.id },
      data: validated.data,
    });
    
    return json({ data: post });
  } catch (err) {
    console.error(`PUT /api/posts/${params.id} error:`, err);
    return error('Failed to update post', 500);
  }
}

// PATCH /api/posts/:id - Partial update
const PatchPostSchema = UpdatePostSchema.partial();

export async function PATCH(request: NextRequest, { params }: Params) {
  try {
    const session = await auth();
    if (!session?.user) {
      return error('Unauthorized', 401);
    }
    
    const existing = await prisma.post.findUnique({
      where: { id: params.id },
      select: { authorId: true },
    });
    
    if (!existing) {
      return error('Post not found', 404);
    }
    
    if (existing.authorId !== session.user.id && session.user.role !== 'ADMIN') {
      return error('Forbidden', 403);
    }
    
    const body = await request.json();
    const validated = PatchPostSchema.safeParse(body);
    
    if (!validated.success) {
      return json(
        { error: 'Validation failed', details: validated.error.flatten() },
        400
      );
    }
    
    const post = await prisma.post.update({
      where: { id: params.id },
      data: validated.data,
    });
    
    return json({ data: post });
  } catch (err) {
    console.error(`PATCH /api/posts/${params.id} error:`, err);
    return error('Failed to update post', 500);
  }
}

// DELETE /api/posts/:id - Delete post
export async function DELETE(request: NextRequest, { params }: Params) {
  try {
    const session = await auth();
    if (!session?.user) {
      return error('Unauthorized', 401);
    }
    
    const existing = await prisma.post.findUnique({
      where: { id: params.id },
      select: { authorId: true },
    });
    
    if (!existing) {
      return error('Post not found', 404);
    }
    
    if (existing.authorId !== session.user.id && session.user.role !== 'ADMIN') {
      return error('Forbidden', 403);
    }
    
    // Soft delete
    await prisma.post.update({
      where: { id: params.id },
      data: { deletedAt: new Date() },
    });
    
    return new Response(null, { status: 204 });
  } catch (err) {
    console.error(`DELETE /api/posts/${params.id} error:`, err);
    return error('Failed to delete post', 500);
  }
}
```

---

## 2) Validation Patterns

### Zod Request Validation
```typescript
// ==========================================
// lib/api/validation.ts
// ==========================================

import { z } from 'zod';
import { NextRequest, NextResponse } from 'next/server';

// Reusable validation wrapper
export async function validateRequest<T>(
  request: NextRequest,
  schema: z.Schema<T>
): Promise<{ success: true; data: T } | { success: false; error: NextResponse }> {
  try {
    const body = await request.json();
    const validated = schema.safeParse(body);
    
    if (!validated.success) {
      return {
        success: false,
        error: NextResponse.json(
          {
            error: 'Validation failed',
            details: validated.error.flatten().fieldErrors,
          },
          { status: 400 }
        ),
      };
    }
    
    return { success: true, data: validated.data };
  } catch {
    return {
      success: false,
      error: NextResponse.json(
        { error: 'Invalid JSON body' },
        { status: 400 }
      ),
    };
  }
}

// Common schemas
export const PaginationSchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

export const IdParamSchema = z.object({
  id: z.string().cuid(),
});

export const EmailSchema = z.string().email().toLowerCase();

// Usage example
export async function POST(request: NextRequest) {
  const result = await validateRequest(request, CreatePostSchema);
  
  if (!result.success) {
    return result.error;
  }
  
  const { data } = result;
  // data is fully typed!
}


// ==========================================
// VALIDATE QUERY PARAMS
// ==========================================

export function validateQueryParams<T>(
  searchParams: URLSearchParams,
  schema: z.Schema<T>
): { success: true; data: T } | { success: false; error: NextResponse } {
  const params: Record<string, string | string[]> = {};
  
  searchParams.forEach((value, key) => {
    if (params[key]) {
      // Multiple values
      if (Array.isArray(params[key])) {
        (params[key] as string[]).push(value);
      } else {
        params[key] = [params[key] as string, value];
      }
    } else {
      params[key] = value;
    }
  });
  
  const validated = schema.safeParse(params);
  
  if (!validated.success) {
    return {
      success: false,
      error: NextResponse.json(
        {
          error: 'Invalid query parameters',
          details: validated.error.flatten().fieldErrors,
        },
        { status: 400 }
      ),
    };
  }
  
  return { success: true, data: validated.data };
}
```

---

## 3) Error Handling

### Centralized Error Handling
```typescript
// ==========================================
// lib/api/errors.ts
// ==========================================

export class ApiError extends Error {
  constructor(
    public message: string,
    public statusCode: number = 400,
    public code?: string,
    public details?: unknown
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

export class NotFoundError extends ApiError {
  constructor(resource = 'Resource') {
    super(`${resource} not found`, 404, 'NOT_FOUND');
  }
}

export class UnauthorizedError extends ApiError {
  constructor(message = 'Unauthorized') {
    super(message, 401, 'UNAUTHORIZED');
  }
}

export class ForbiddenError extends ApiError {
  constructor(message = 'Forbidden') {
    super(message, 403, 'FORBIDDEN');
  }
}

export class ValidationError extends ApiError {
  constructor(details: unknown) {
    super('Validation failed', 400, 'VALIDATION_ERROR', details);
  }
}

export class RateLimitError extends ApiError {
  constructor(retryAfter: number) {
    super('Too many requests', 429, 'RATE_LIMITED', { retryAfter });
  }
}


// ==========================================
// lib/api/handler.ts - Route Handler Wrapper
// ==========================================

import { NextRequest, NextResponse } from 'next/server';
import { ApiError } from './errors';
import { ZodError } from 'zod';

type RouteHandler = (
  request: NextRequest,
  context: { params: Record<string, string> }
) => Promise<Response>;

export function withErrorHandler(handler: RouteHandler): RouteHandler {
  return async (request, context) => {
    try {
      return await handler(request, context);
    } catch (error) {
      console.error(`API Error: ${request.method} ${request.nextUrl.pathname}`, error);
      
      if (error instanceof ApiError) {
        return NextResponse.json(
          {
            error: error.message,
            code: error.code,
            details: error.details,
          },
          { status: error.statusCode }
        );
      }
      
      if (error instanceof ZodError) {
        return NextResponse.json(
          {
            error: 'Validation failed',
            code: 'VALIDATION_ERROR',
            details: error.flatten().fieldErrors,
          },
          { status: 400 }
        );
      }
      
      // Don't expose internal errors
      return NextResponse.json(
        { error: 'Internal server error', code: 'INTERNAL_ERROR' },
        { status: 500 }
      );
    }
  };
}


// ==========================================
// USAGE
// ==========================================

// app/api/posts/[id]/route.ts
import { withErrorHandler } from '@/lib/api/handler';
import { NotFoundError, ForbiddenError } from '@/lib/api/errors';

export const GET = withErrorHandler(async (request, { params }) => {
  const post = await prisma.post.findUnique({
    where: { id: params.id },
  });
  
  if (!post) {
    throw new NotFoundError('Post');
  }
  
  return NextResponse.json({ data: post });
});

export const DELETE = withErrorHandler(async (request, { params }) => {
  const session = await auth();
  
  if (!session?.user) {
    throw new UnauthorizedError();
  }
  
  const post = await prisma.post.findUnique({
    where: { id: params.id },
    select: { authorId: true },
  });
  
  if (!post) {
    throw new NotFoundError('Post');
  }
  
  if (post.authorId !== session.user.id) {
    throw new ForbiddenError('You can only delete your own posts');
  }
  
  await prisma.post.delete({ where: { id: params.id } });
  
  return new Response(null, { status: 204 });
});
```

---

## 4) Rate Limiting

### Upstash Rate Limiting
```typescript
// ==========================================
// lib/api/rate-limit.ts
// ==========================================

import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';
import { NextRequest, NextResponse } from 'next/server';

// Create rate limiter
const redis = new Redis({
  url: process.env.UPSTASH_REDIS_REST_URL!,
  token: process.env.UPSTASH_REDIS_REST_TOKEN!,
});

// Different rate limits for different purposes
export const rateLimiters = {
  // General API: 100 requests per minute
  api: new Ratelimit({
    redis,
    limiter: Ratelimit.slidingWindow(100, '1 m'),
    analytics: true,
    prefix: 'ratelimit:api',
  }),
  
  // Auth endpoints: 10 per minute
  auth: new Ratelimit({
    redis,
    limiter: Ratelimit.slidingWindow(10, '1 m'),
    analytics: true,
    prefix: 'ratelimit:auth',
  }),
  
  // Upload: 20 per hour
  upload: new Ratelimit({
    redis,
    limiter: Ratelimit.slidingWindow(20, '1 h'),
    analytics: true,
    prefix: 'ratelimit:upload',
  }),
  
  // AI/Expensive: 10 per hour
  expensive: new Ratelimit({
    redis,
    limiter: Ratelimit.slidingWindow(10, '1 h'),
    analytics: true,
    prefix: 'ratelimit:expensive',
  }),
};

// Get client identifier
export function getClientId(request: NextRequest): string {
  // Try to get user ID from session
  const sessionToken = request.cookies.get('next-auth.session-token')?.value;
  if (sessionToken) {
    return `user:${sessionToken.slice(0, 16)}`;
  }
  
  // Fallback to IP
  const forwarded = request.headers.get('x-forwarded-for');
  const ip = forwarded?.split(',')[0] ?? request.ip ?? 'unknown';
  return `ip:${ip}`;
}

// Rate limit middleware
export async function rateLimit(
  request: NextRequest,
  limiter: Ratelimit = rateLimiters.api
): Promise<NextResponse | null> {
  const clientId = getClientId(request);
  const { success, limit, remaining, reset } = await limiter.limit(clientId);
  
  if (!success) {
    return NextResponse.json(
      {
        error: 'Too many requests',
        retryAfter: Math.ceil((reset - Date.now()) / 1000),
      },
      {
        status: 429,
        headers: {
          'X-RateLimit-Limit': limit.toString(),
          'X-RateLimit-Remaining': '0',
          'X-RateLimit-Reset': reset.toString(),
          'Retry-After': Math.ceil((reset - Date.now()) / 1000).toString(),
        },
      }
    );
  }
  
  return null;  // No rate limit hit
}


// ==========================================
// USAGE IN ROUTE HANDLER
// ==========================================

// app/api/posts/route.ts
import { rateLimit, rateLimiters } from '@/lib/api/rate-limit';

export async function POST(request: NextRequest) {
  // Check rate limit
  const rateLimitResponse = await rateLimit(request, rateLimiters.api);
  if (rateLimitResponse) {
    return rateLimitResponse;
  }
  
  // Continue with handler
  // ...
}


// ==========================================
// RATE LIMIT AS MIDDLEWARE
// ==========================================

// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(100, '1 m'),
});

export async function middleware(request: NextRequest) {
  // Only rate limit API routes
  if (request.nextUrl.pathname.startsWith('/api')) {
    const ip = request.ip ?? '127.0.0.1';
    const { success, limit, remaining } = await ratelimit.limit(ip);
    
    if (!success) {
      return NextResponse.json(
        { error: 'Too many requests' },
        { status: 429 }
      );
    }
    
    // Add headers to response
    const response = NextResponse.next();
    response.headers.set('X-RateLimit-Limit', limit.toString());
    response.headers.set('X-RateLimit-Remaining', remaining.toString());
    return response;
  }
  
  return NextResponse.next();
}
```

---

## 5) CORS Configuration

### CORS Helper
```typescript
// ==========================================
// lib/api/cors.ts
// ==========================================

import { NextRequest, NextResponse } from 'next/server';

const ALLOWED_ORIGINS = [
  'http://localhost:3000',
  'https://myapp.com',
  'https://www.myapp.com',
];

const CORS_HEADERS = {
  'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
  'Access-Control-Max-Age': '86400',  // 24 hours
};

export function getCorsHeaders(request: NextRequest): HeadersInit {
  const origin = request.headers.get('origin');
  
  if (origin && ALLOWED_ORIGINS.includes(origin)) {
    return {
      ...CORS_HEADERS,
      'Access-Control-Allow-Origin': origin,
      'Access-Control-Allow-Credentials': 'true',
    };
  }
  
  return CORS_HEADERS;
}

export function corsResponse(request: NextRequest): NextResponse {
  return new NextResponse(null, {
    status: 204,
    headers: getCorsHeaders(request),
  });
}

export function withCors(response: NextResponse, request: NextRequest): NextResponse {
  const corsHeaders = getCorsHeaders(request);
  
  Object.entries(corsHeaders).forEach(([key, value]) => {
    response.headers.set(key, value);
  });
  
  return response;
}


// ==========================================
// USAGE
// ==========================================

// app/api/data/route.ts
import { getCorsHeaders, corsResponse, withCors } from '@/lib/api/cors';

// Handle OPTIONS preflight
export async function OPTIONS(request: NextRequest) {
  return corsResponse(request);
}

export async function GET(request: NextRequest) {
  const data = await fetchData();
  
  const response = NextResponse.json({ data });
  return withCors(response, request);
}
```

---

## 6) Streaming Responses

### Server-Sent Events (SSE)
```typescript
// ==========================================
// app/api/events/route.ts - SSE Endpoint
// ==========================================

import { NextRequest } from 'next/server';

export async function GET(request: NextRequest) {
  const encoder = new TextEncoder();
  
  const stream = new ReadableStream({
    async start(controller) {
      let counter = 0;
      
      const sendEvent = (data: object) => {
        const message = `data: ${JSON.stringify(data)}\n\n`;
        controller.enqueue(encoder.encode(message));
      };
      
      // Send initial connection event
      sendEvent({ type: 'connected', timestamp: Date.now() });
      
      // Send periodic updates
      const interval = setInterval(() => {
        counter++;
        sendEvent({
          type: 'update',
          count: counter,
          timestamp: Date.now(),
        });
        
        // Close after 10 events for demo
        if (counter >= 10) {
          clearInterval(interval);
          controller.close();
        }
      }, 1000);
      
      // Handle client disconnect
      request.signal.addEventListener('abort', () => {
        clearInterval(interval);
        controller.close();
      });
    },
  });
  
  return new Response(stream, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    },
  });
}


// ==========================================
// AI STREAMING RESPONSE
// ==========================================

// app/api/chat/route.ts
import { OpenAI } from 'openai';

const openai = new OpenAI();

export async function POST(request: NextRequest) {
  const { messages } = await request.json();
  
  const stream = await openai.chat.completions.create({
    model: 'gpt-4-turbo-preview',
    messages,
    stream: true,
  });
  
  const encoder = new TextEncoder();
  
  const readable = new ReadableStream({
    async start(controller) {
      for await (const chunk of stream) {
        const content = chunk.choices[0]?.delta?.content || '';
        if (content) {
          controller.enqueue(encoder.encode(`data: ${JSON.stringify({ content })}\n\n`));
        }
      }
      
      controller.enqueue(encoder.encode('data: [DONE]\n\n'));
      controller.close();
    },
  });
  
  return new Response(readable, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
    },
  });
}


// ==========================================
// CLIENT-SIDE SSE CONSUMER
// ==========================================

// hooks/useSSE.ts
'use client';

import { useEffect, useState, useCallback } from 'react';

export function useSSE<T>(url: string) {
  const [data, setData] = useState<T[]>([]);
  const [error, setError] = useState<Error | null>(null);
  const [isConnected, setIsConnected] = useState(false);
  
  useEffect(() => {
    const eventSource = new EventSource(url);
    
    eventSource.onopen = () => {
      setIsConnected(true);
      setError(null);
    };
    
    eventSource.onmessage = (event) => {
      try {
        const parsed = JSON.parse(event.data);
        setData((prev) => [...prev, parsed]);
      } catch (e) {
        console.error('Failed to parse SSE data:', e);
      }
    };
    
    eventSource.onerror = (e) => {
      setIsConnected(false);
      setError(new Error('SSE connection failed'));
      eventSource.close();
    };
    
    return () => {
      eventSource.close();
    };
  }, [url]);
  
  return { data, error, isConnected };
}
```

---

## 7) File Uploads

### File Upload Handler
```typescript
// ==========================================
// app/api/upload/route.ts
// ==========================================

import { NextRequest, NextResponse } from 'next/server';
import { writeFile, mkdir } from 'fs/promises';
import { join } from 'path';
import { v4 as uuid } from 'uuid';
import { z } from 'zod';

const MAX_FILE_SIZE = 10 * 1024 * 1024;  // 10MB
const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'application/pdf'];

export async function POST(request: NextRequest) {
  try {
    const session = await auth();
    if (!session?.user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const formData = await request.formData();
    const file = formData.get('file') as File | null;
    
    if (!file) {
      return NextResponse.json({ error: 'No file provided' }, { status: 400 });
    }
    
    // Validate file type
    if (!ALLOWED_TYPES.includes(file.type)) {
      return NextResponse.json(
        { error: 'Invalid file type', allowed: ALLOWED_TYPES },
        { status: 400 }
      );
    }
    
    // Validate file size
    if (file.size > MAX_FILE_SIZE) {
      return NextResponse.json(
        { error: 'File too large', maxSize: `${MAX_FILE_SIZE / 1024 / 1024}MB` },
        { status: 400 }
      );
    }
    
    // Generate unique filename
    const ext = file.name.split('.').pop() || 'bin';
    const filename = `${uuid()}.${ext}`;
    
    // Save to disk (or upload to cloud storage)
    const uploadDir = join(process.cwd(), 'public', 'uploads');
    await mkdir(uploadDir, { recursive: true });
    
    const filepath = join(uploadDir, filename);
    const bytes = await file.arrayBuffer();
    await writeFile(filepath, Buffer.from(bytes));
    
    // Return URL
    const url = `/uploads/${filename}`;
    
    return NextResponse.json({
      success: true,
      url,
      filename: file.name,
      size: file.size,
      type: file.type,
    });
  } catch (error) {
    console.error('Upload error:', error);
    return NextResponse.json({ error: 'Upload failed' }, { status: 500 });
  }
}


// ==========================================
// MULTIPLE FILE UPLOADS
// ==========================================

export async function POST(request: NextRequest) {
  const formData = await request.formData();
  const files = formData.getAll('files') as File[];
  
  const results = await Promise.all(
    files.map(async (file) => {
      // Process each file
      const filename = `${uuid()}.${file.name.split('.').pop()}`;
      // Upload to S3/GCS/etc...
      return { filename, url: `/uploads/${filename}` };
    })
  );
  
  return NextResponse.json({ files: results });
}
```

---

## 8) Webhooks

### Webhook Handler
```typescript
// ==========================================
// app/api/webhooks/stripe/route.ts
// ==========================================

import { NextRequest, NextResponse } from 'next/server';
import Stripe from 'stripe';
import { headers } from 'next/headers';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);
const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET!;

export async function POST(request: NextRequest) {
  const body = await request.text();
  const signature = headers().get('stripe-signature');
  
  if (!signature) {
    return NextResponse.json({ error: 'Missing signature' }, { status: 400 });
  }
  
  let event: Stripe.Event;
  
  try {
    event = stripe.webhooks.constructEvent(body, signature, webhookSecret);
  } catch (err) {
    console.error('Webhook signature verification failed:', err);
    return NextResponse.json({ error: 'Invalid signature' }, { status: 400 });
  }
  
  // Process webhook (idempotent)
  try {
    switch (event.type) {
      case 'checkout.session.completed': {
        const session = event.data.object as Stripe.Checkout.Session;
        await handleCheckoutComplete(session);
        break;
      }
      
      case 'invoice.paid': {
        const invoice = event.data.object as Stripe.Invoice;
        await handleInvoicePaid(invoice);
        break;
      }
      
      case 'customer.subscription.deleted': {
        const subscription = event.data.object as Stripe.Subscription;
        await handleSubscriptionCanceled(subscription);
        break;
      }
      
      default:
        console.log(`Unhandled event type: ${event.type}`);
    }
    
    return NextResponse.json({ received: true });
  } catch (error) {
    console.error('Webhook processing error:', error);
    // Return 200 to prevent retries for business logic errors
    return NextResponse.json({ received: true, error: 'Processing failed' });
  }
}

// Idempotent handlers
async function handleCheckoutComplete(session: Stripe.Checkout.Session) {
  const orderId = session.metadata?.orderId;
  if (!orderId) return;
  
  // Check if already processed
  const order = await prisma.order.findUnique({
    where: { id: orderId },
  });
  
  if (order?.status === 'PAID') {
    console.log(`Order ${orderId} already processed`);
    return;
  }
  
  // Process order
  await prisma.order.update({
    where: { id: orderId },
    data: {
      status: 'PAID',
      stripeSessionId: session.id,
      paidAt: new Date(),
    },
  });
}
```

---

## 9) Health Check & Monitoring

### Health Endpoint
```typescript
// ==========================================
// app/api/health/route.ts
// ==========================================

import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

interface HealthCheck {
  status: 'healthy' | 'unhealthy';
  timestamp: string;
  version: string;
  checks: {
    database: 'ok' | 'error';
    redis?: 'ok' | 'error';
  };
  uptime: number;
}

export async function GET() {
  const startTime = Date.now();
  const checks: HealthCheck['checks'] = {
    database: 'error',
  };
  
  // Check database
  try {
    await prisma.$queryRaw`SELECT 1`;
    checks.database = 'ok';
  } catch (error) {
    console.error('Database health check failed:', error);
  }
  
  // Check Redis (if used)
  // try {
  //   await redis.ping();
  //   checks.redis = 'ok';
  // } catch (error) {
  //   checks.redis = 'error';
  // }
  
  const isHealthy = Object.values(checks).every(v => v === 'ok');
  
  const response: HealthCheck = {
    status: isHealthy ? 'healthy' : 'unhealthy',
    timestamp: new Date().toISOString(),
    version: process.env.APP_VERSION || '1.0.0',
    checks,
    uptime: process.uptime(),
  };
  
  return NextResponse.json(response, {
    status: isHealthy ? 200 : 503,
  });
}
```

---

## Best Practices Checklist

### Structure
- [ ] Use route.ts in App Router
- [ ] Export named HTTP method handlers
- [ ] Consistent response format
- [ ] Proper status codes

### Validation
- [ ] Validate all inputs with Zod
- [ ] Return detailed errors
- [ ] Sanitize user input
- [ ] Type-safe handlers

### Security
- [ ] Auth check in handlers
- [ ] Rate limiting
- [ ] CORS configuration
- [ ] Webhook signature verification

### Performance
- [ ] Cache where appropriate
- [ ] Stream large responses
- [ ] Connection pooling
- [ ] Request logging

---

**References:**
- [Route Handlers](https://nextjs.org/docs/app/building-your-application/routing/route-handlers)
- [Upstash Rate Limiting](https://upstash.com/docs/ratelimit)
- [Stripe Webhooks](https://stripe.com/docs/webhooks)

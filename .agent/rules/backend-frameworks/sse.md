# Server-Sent Events (SSE) Development Expert

> **Version:** 1.0.0 | **Updated:** 2026-02-10
> **Standards:** HTML Living Standard (EventSource), HTTP/1.1
> **Priority:** P1 - Load for SSE/streaming projects

---

You are an expert in Server-Sent Events for real-time one-way streaming with TypeScript/Node.js.

## Key Principles

- Server-to-client only (one-way push)
- Built on standard HTTP — no special protocols
- Automatic reconnection with `Last-Event-ID`
- Text-based protocol (`text/event-stream`)
- Native browser API (`EventSource`) — no dependencies
- Ideal for notifications, live feeds, progress updates

---

## When to Use SSE vs WebSocket

```yaml
Use SSE when:
  - Server pushes data to client (one-way)
  - Live feeds, notifications, dashboards
  - Real-time progress updates
  - Stock tickers, news feeds
  - AI/LLM token streaming
  - Simple deployment (standard HTTP)

Use WebSocket when:
  - Bidirectional communication needed
  - Chat, collaborative editing
  - Gaming, real-time multiplayer
  - Client sends frequent data to server
  - Binary data transfer

Use gRPC/Connect when:
  - Service-to-service communication
  - Strong typing with Protocol Buffers
  - Bidirectional streaming
  - High-performance microservices
```

---

## Project Structure

```
src/
├── sse/
│   ├── server.ts               # SSE endpoint setup
│   ├── channels/               # Event channels
│   │   ├── notifications.ts
│   │   ├── activity-feed.ts
│   │   └── progress.ts
│   ├── middleware/
│   │   ├── auth.ts
│   │   └── rate-limit.ts
│   └── types/
│       └── events.ts
├── services/
└── server.ts                   # HTTP server
```

---

## Event Stream Protocol

### Format Specification
```
# SSE Message Format (text/event-stream)
# Each message is a block of key: value lines, separated by \n\n

# Basic data message
data: Hello World\n\n

# Named event
event: notification\n
data: {"title": "New message"}\n\n

# With ID (for reconnection)
id: 12345\n
event: message\n
data: {"text": "Hello"}\n\n

# Multi-line data
data: line 1\n
data: line 2\n\n

# Retry interval (milliseconds)
retry: 5000\n\n

# Comment (keepalive)
: keepalive\n\n
```

### Typed Events
```typescript
// sse/types/events.ts

interface SSEEvent<T = unknown> {
  id?: string;
  event: string;
  data: T;
  retry?: number;
}

// Server → Client event types
interface SSEEventMap {
  'notification': {
    id: string;
    type: 'info' | 'warning' | 'error';
    title: string;
    body: string;
    timestamp: number;
  };
  'activity': {
    userId: string;
    action: string;
    resource: string;
    timestamp: number;
  };
  'progress': {
    taskId: string;
    percent: number;
    status: 'pending' | 'running' | 'complete' | 'failed';
    message?: string;
  };
  'ai:token': {
    token: string;
    done: boolean;
    messageId: string;
  };
}
```

---

## Server Implementation

### Express SSE Endpoint
```typescript
// sse/server.ts
import { Router, Request, Response } from 'express';
import { verifyToken } from '../utils/auth';

const router = Router();

// Active connections
interface SSEClient {
  id: string;
  userId: string;
  res: Response;
  channels: Set<string>;
}

const clients = new Map<string, SSEClient>();

// SSE endpoint
router.get('/events', async (req: Request, res: Response) => {
  // Authentication
  const token = req.query.token as string
    || req.headers.authorization?.replace('Bearer ', '');

  if (!token) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  let user;
  try {
    user = await verifyToken(token);
  } catch {
    return res.status(401).json({ error: 'Invalid token' });
  }

  // SSE headers
  res.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive',
    'X-Accel-Buffering': 'no',  // Disable nginx buffering
  });

  // Flush headers immediately
  res.flushHeaders();

  const clientId = generateId();
  const client: SSEClient = {
    id: clientId,
    userId: user.id,
    res,
    channels: new Set(['global', `user:${user.id}`]),
  };

  clients.set(clientId, client);

  // Handle Last-Event-ID (reconnection)
  const lastEventId = req.headers['last-event-id'];
  if (lastEventId) {
    await replayEvents(client, lastEventId);
  }

  // Send initial connection event
  sendEvent(res, {
    event: 'connected',
    data: { clientId, serverTime: Date.now() },
  });

  // Keepalive (every 30 seconds)
  const keepalive = setInterval(() => {
    res.write(': keepalive\n\n');
  }, 30_000);

  // Cleanup on disconnect
  req.on('close', () => {
    clearInterval(keepalive);
    clients.delete(clientId);
    console.log(`SSE client disconnected: ${user.id}`);
  });
});

// Helper: Send event (accepts any event name for flexibility)
function sendEvent(
  res: Response,
  event: {
    id?: string;
    event: string;
    data: unknown;
    retry?: number;
  }
) {
  if (event.id) res.write(`id: ${event.id}\n`);
  if (event.retry) res.write(`retry: ${event.retry}\n`);
  res.write(`event: ${event.event}\n`);
  res.write(`data: ${JSON.stringify(event.data)}\n\n`);
}

// Helper: Broadcast to channel
function broadcast<E extends keyof SSEEventMap>(
  channel: string,
  event: E,
  data: SSEEventMap[E],
  eventId?: string
) {
  for (const client of clients.values()) {
    if (client.channels.has(channel)) {
      sendEvent(client.res, {
        id: eventId || generateId(),
        event,
        data,
      });
    }
  }
}

// Helper: Send to specific user
function sendToUser<E extends keyof SSEEventMap>(
  userId: string,
  event: E,
  data: SSEEventMap[E]
) {
  broadcast(`user:${userId}`, event, data);
}

export { router as sseRouter, broadcast, sendToUser };
```

### Fastify SSE Plugin
```typescript
// sse/server-fastify.ts
import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';

export async function ssePlugin(fastify: FastifyInstance) {
  fastify.get('/events', async (request: FastifyRequest, reply: FastifyReply) => {
    const token = (request.query as any).token;

    if (!token) {
      return reply.code(401).send({ error: 'Unauthorized' });
    }

    const user = await verifyToken(token);

    reply.raw.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    });

    // Use reply.raw for SSE streaming
    const send = (event: string, data: unknown, id?: string) => {
      if (id) reply.raw.write(`id: ${id}\n`);
      reply.raw.write(`event: ${event}\n`);
      reply.raw.write(`data: ${JSON.stringify(data)}\n\n`);
    };

    send('connected', { userId: user.id, serverTime: Date.now() });

    // Keepalive
    const keepalive = setInterval(() => {
      reply.raw.write(': keepalive\n\n');
    }, 30_000);

    request.raw.on('close', () => {
      clearInterval(keepalive);
    });
  });
}
```

### Event Replay (Last-Event-ID)
```typescript
// sse/channels/replay.ts

// Store recent events for replay (ring buffer in Redis)
async function storeEvent(channel: string, event: SSEEvent) {
  const id = event.id || generateId();
  await redis.xadd(
    `sse:${channel}`,
    id,
    'event', event.event,
    'data', JSON.stringify(event.data)
  );
  // Trim to last 1000 events
  await redis.xtrim(`sse:${channel}`, 'MAXLEN', '~', 1000);
}

// Replay missed events after reconnection
async function replayEvents(client: SSEClient, lastEventId: string) {
  for (const channel of client.channels) {
    const events = await redis.xrange(
      `sse:${channel}`,
      `(${lastEventId}`,  // Exclusive start
      '+'                  // Until latest
    );

    for (const [id, fields] of events) {
      client.res.write(`id: ${id}\n`);
      client.res.write(`event: ${fields[1]}\n`);
      client.res.write(`data: ${fields[3]}\n\n`);
    }
  }
}
```

---

## Scaling with Redis Pub/Sub

```typescript
// sse/adapters/redis-broadcast.ts
import { createClient } from 'redis';

const pubClient = createClient({ url: process.env.REDIS_URL });
const subClient = pubClient.duplicate();

await Promise.all([pubClient.connect(), subClient.connect()]);

// Subscribe to channels
await subClient.subscribe('sse:global', (message) => {
  const event = JSON.parse(message);
  // Broadcast to local SSE clients
  for (const client of clients.values()) {
    if (client.channels.has('global')) {
      sendEvent(client.res, event);
    }
  }
});

// Publish from any server instance
async function publishEvent<E extends keyof SSEEventMap>(
  channel: string,
  event: E,
  data: SSEEventMap[E]
) {
  await pubClient.publish(
    `sse:${channel}`,
    JSON.stringify({ event, data, id: generateId() })
  );
}
```

---

## Client Implementation

### Native EventSource
```typescript
// client/sse-client.ts

interface SSEClientOptions {
  url: string;
  token: string;
  onOpen?: () => void;
  onError?: (error: Event) => void;
}

export function createSSEClient(options: SSEClientOptions) {
  // EventSource doesn't support custom headers
  // Pass token via query parameter
  const url = new URL(options.url);
  url.searchParams.set('token', options.token);

  const eventSource = new EventSource(url.toString());

  eventSource.onopen = () => {
    console.log('SSE connected');
    options.onOpen?.();
  };

  eventSource.onerror = (error) => {
    console.error('SSE error:', error);
    options.onError?.(error);
    // EventSource auto-reconnects with Last-Event-ID
  };

  return eventSource;
}

// Usage
const sse = createSSEClient({
  url: 'https://api.example.com/events',
  token: authToken,
});

// Listen for typed events
sse.addEventListener('notification', (event) => {
  const data = JSON.parse(event.data);
  showNotification(data);
});

sse.addEventListener('progress', (event) => {
  const data = JSON.parse(event.data);
  updateProgressBar(data.percent);
});

// Cleanup
sse.close();
```

### Fetch-Based SSE (Custom Headers Support)
```typescript
// client/fetch-sse.ts
// Use fetch for SSE when you need custom headers

export async function fetchSSE(
  url: string,
  options: {
    token: string;
    onEvent: (event: string, data: unknown) => void;
    onError?: (error: Error) => void;
    signal?: AbortSignal;
    method?: string;
    body?: string;
  }
) {
  const response = await fetch(url, {
    method: options.method || 'GET',
    headers: {
      'Authorization': `Bearer ${options.token}`,
      'Accept': 'text/event-stream',
      ...(options.body && { 'Content-Type': 'application/json' }),
    },
    body: options.body,
    signal: options.signal,
  });

  if (!response.ok) {
    throw new Error(`SSE connection failed: ${response.status}`);
  }

  const reader = response.body!.getReader();
  const decoder = new TextDecoder();
  let buffer = '';

  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      buffer += decoder.decode(value, { stream: true });

      // Parse SSE messages
      const messages = buffer.split('\n\n');
      buffer = messages.pop() || ''; // Keep incomplete message

      for (const msg of messages) {
        if (!msg.trim()) continue;

        let event = 'message';
        let data = '';

        for (const line of msg.split('\n')) {
          if (line.startsWith('event: ')) {
            event = line.slice(7);
          } else if (line.startsWith('data: ')) {
            data += line.slice(6);
          }
        }

        if (data) {
          try {
            options.onEvent(event, JSON.parse(data));
          } catch {
            options.onEvent(event, data);
          }
        }
      }
    }
  } catch (error) {
    if (!(error instanceof DOMException && error.name === 'AbortError')) {
      options.onError?.(error as Error);
    }
  }
}
```

### React Hook
```typescript
// hooks/useSSE.ts
import { useEffect, useRef, useCallback, useState } from 'react';

interface UseSSEOptions {
  url: string;
  token: string;
  enabled?: boolean;
}

export function useSSE({ url, token, enabled = true }: UseSSEOptions) {
  const sourceRef = useRef<EventSource | null>(null);
  const [isConnected, setIsConnected] = useState(false);

  useEffect(() => {
    if (!enabled || !token) return;

    const eventUrl = new URL(url);
    eventUrl.searchParams.set('token', token);

    const source = new EventSource(eventUrl.toString());
    sourceRef.current = source;

    source.onopen = () => setIsConnected(true);
    source.onerror = () => setIsConnected(false);

    return () => {
      source.close();
      sourceRef.current = null;
      setIsConnected(false);
    };
  }, [url, token, enabled]);

  const on = useCallback(
    <E extends keyof SSEEventMap>(
      event: E,
      handler: (data: SSEEventMap[E]) => void
    ) => {
      const listener = (e: MessageEvent) => {
        handler(JSON.parse(e.data));
      };

      sourceRef.current?.addEventListener(event, listener);

      return () => {
        sourceRef.current?.removeEventListener(event, listener);
      };
    },
    []
  );

  return { isConnected, on };
}

// Usage
function NotificationBell() {
  const { isConnected, on } = useSSE({
    url: '/api/events',
    token: useAuth().token,
  });
  const [notifications, setNotifications] = useState<Notification[]>([]);

  useEffect(() => {
    return on('notification', (data) => {
      setNotifications((prev) => [data, ...prev.slice(0, 49)]);
    });
  }, [on]);

  return (
    <div>
      <StatusDot connected={isConnected} />
      <NotificationList items={notifications} />
    </div>
  );
}
```

### AI/LLM Token Streaming
```typescript
// Common pattern: Stream AI responses via SSE

// Server
router.post('/ai/chat', async (req, res) => {
  res.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
  });

  const messageId = generateId();

  try {
    const stream = await openai.chat.completions.create({
      model: 'gpt-4',
      messages: req.body.messages,
      stream: true,
    });

    for await (const chunk of stream) {
      const token = chunk.choices[0]?.delta?.content || '';
      res.write(`event: ai:token\n`);
      res.write(`data: ${JSON.stringify({
        token,
        done: false,
        messageId,
      })}\n\n`);
    }

    // Signal completion
    res.write(`event: ai:token\n`);
    res.write(`data: ${JSON.stringify({
      token: '',
      done: true,
      messageId,
    })}\n\n`);
  } catch (error) {
    res.write(`event: error\n`);
    res.write(`data: ${JSON.stringify({
      code: 'AI_ERROR',
      message: 'Failed to generate response',
    })}\n\n`);
  }

  res.end();
});

// Client (React)
function useAIStream(messages: Message[]) {
  const [tokens, setTokens] = useState('');
  const [isStreaming, setIsStreaming] = useState(false);

  const stream = useCallback(async () => {
    setIsStreaming(true);
    setTokens('');

    await fetchSSE('/api/ai/chat', {
      token: getToken(),
      body: JSON.stringify({ messages }),
      onEvent: (event, data: any) => {
        if (event === 'ai:token') {
          if (data.done) {
            setIsStreaming(false);
          } else {
            setTokens((prev) => prev + data.token);
          }
        }
      },
    });
  }, [messages]);

  return { tokens, isStreaming, stream };
}
```

---

## Testing

```typescript
// tests/sse.test.ts
import request from 'supertest';
import { app } from '../server';

describe('SSE Endpoint', () => {
  test('establishes SSE connection', async () => {
    const res = await request(app)
      .get('/events?token=test-token')
      .set('Accept', 'text/event-stream')
      .buffer(false);

    expect(res.status).toBe(200);
    expect(res.headers['content-type']).toContain('text/event-stream');
  });

  test('sends initial connected event', (done) => {
    const res = request(app)
      .get('/events?token=test-token')
      .set('Accept', 'text/event-stream');

    let data = '';
    res.on('data', (chunk: Buffer) => {
      data += chunk.toString();
      if (data.includes('event: connected')) {
        res.abort();
        done();
      }
    });
  });

  test('rejects unauthenticated requests', async () => {
    const res = await request(app).get('/events');
    expect(res.status).toBe(401);
  });
});
```

---

## Security

```yaml
Authentication:
  - Pass token via query param (EventSource limitation)
  - OR use fetch-based SSE for Authorization header
  - Validate token before establishing stream
  - Close connection on token expiry

Transport:
  - Always use HTTPS in production
  - Set Cache-Control: no-cache
  - Disable proxy buffering (X-Accel-Buffering: no)
  - Set appropriate CORS headers

Rate Limiting:
  - Limit SSE connections per user (e.g., max 5)
  - Rate limit event publishing
  - Set retry interval to prevent reconnection storms

Data:
  - Sanitize all event data before sending
  - Don't expose internal errors in stream
  - Use event IDs for deduplication
  - Limit event payload size
```

---

## Anti-Patterns

```yaml
❌ DON'T:
  - Use SSE for bidirectional communication (use WebSocket)
  - Send auth tokens in event data (use query param or headers)
  - Skip keepalive comments (connections may timeout)
  - Ignore Last-Event-ID (breaks reconnection replay)
  - Buffer responses (disable nginx/proxy buffering)
  - Create unlimited SSE connections per user
  - Use SSE for binary data (it's text-only)
  - Skip event IDs (needed for reliable delivery)

✅ DO:
  - Use SSE for server-to-client push (notifications, feeds)
  - Implement Last-Event-ID replay for reliability
  - Send keepalive comments every 30s
  - Use Redis pub/sub for horizontal scaling
  - Set retry interval in initial response
  - Close connections on auth expiry
  - Use fetch-based SSE when custom headers needed
  - Consider SSE for AI/LLM token streaming
```

---

## See Also

- [websocket.md](websocket.md) — Bidirectional real-time communication
- [message-queue.md](message-queue.md) — Async event-driven patterns

---

**Version:** 1.0.0
**Standards:** HTML Living Standard (EventSource), HTTP/1.1
**Created:** 2026-02-10

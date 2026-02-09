# WebSocket Development Expert

> **Version:** 1.0.0 | **Updated:** 2026-02-09
> **Standards:** RFC 6455, WebSocket Protocol, Socket.IO v4
> **Priority:** P1 - Load for real-time/WebSocket projects

---

You are an expert in WebSocket-based real-time application development with TypeScript/Node.js.

## Key Principles

- Event-driven bidirectional communication
- Persistent connections with lifecycle management
- Structured message protocols (typed events)
- Graceful reconnection with exponential backoff
- Room/channel-based pub/sub for broadcasting
- Authentication on handshake, authorization per event

---

## Project Structure

```
src/
├── ws/
│   ├── server.ts              # WebSocket server bootstrap
│   ├── events/                # Event handlers
│   │   ├── chat.ts
│   │   ├── notifications.ts
│   │   └── presence.ts
│   ├── middleware/            # Connection middleware
│   │   ├── auth.ts
│   │   ├── rate-limit.ts
│   │   └── validation.ts
│   ├── rooms/                 # Room management
│   │   └── room-manager.ts
│   ├── adapters/              # Scaling adapters
│   │   └── redis-adapter.ts
│   └── types/                 # Event type definitions
│       ├── events.ts
│       └── payloads.ts
├── services/
├── db/
└── server.ts                  # HTTP + WS server
```

---

## Message Protocol Design

### Event Structure
```typescript
// ws/types/events.ts

// ✅ Standard event envelope
interface WebSocketEvent<T = unknown> {
  event: string;        // Namespaced event name
  data: T;              // Typed payload
  id?: string;          // Message ID for acknowledgment
  timestamp?: number;   // Unix timestamp
}

// ✅ Server → Client events
interface ServerEvents {
  'chat:message': {
    id: string;
    text: string;
    senderId: string;
    senderName: string;
    roomId: string;
    timestamp: number;
  };
  'chat:typing': {
    userId: string;
    roomId: string;
    isTyping: boolean;
  };
  'user:online': {
    userId: string;
    name: string;
    onlineAt: number;
  };
  'user:offline': {
    userId: string;
    lastSeen: number;
  };
  'notification': {
    id: string;
    type: 'info' | 'warning' | 'error';
    title: string;
    body: string;
  };
  'error': {
    code: string;
    message: string;
    details?: Record<string, unknown>;
  };
}

// ✅ Client → Server events
interface ClientEvents {
  'chat:send': {
    text: string;
    roomId: string;
  };
  'chat:typing': {
    roomId: string;
    isTyping: boolean;
  };
  'room:join': {
    roomId: string;
  };
  'room:leave': {
    roomId: string;
  };
  'presence:heartbeat': Record<string, never>;
}

// Acknowledgment callback
type AckCallback<T = unknown> = (response: {
  success: boolean;
  data?: T;
  error?: { code: string; message: string };
}) => void;
```

### Event Naming Conventions
```yaml
✅ Good:
  - "chat:message"          # namespace:action
  - "user:online"           # namespace:state
  - "notification:new"      # namespace:event
  - "room:join"             # namespace:verb
  - "order:status:updated"  # namespace:subject:action

❌ Bad:
  - "chatMessage"           # No namespace separator
  - "SEND_CHAT"             # SCREAMING_CASE
  - "on-message"            # Kebab-case
  - "msg"                   # Abbreviation
```

---

## Native WebSocket Server (ws library)

### Server Setup
```typescript
// ws/server.ts
import { WebSocketServer, WebSocket } from 'ws';
import { createServer } from 'http';
import { parse } from 'url';
import { verifyToken } from '../utils/auth';

const httpServer = createServer();
const wss = new WebSocketServer({ noServer: true });

// Connection state
interface ClientState {
  userId: string;
  name: string;
  rooms: Set<string>;
  isAlive: boolean;
  lastActivity: number;
}

const clients = new Map<WebSocket, ClientState>();

// Authentication on upgrade
httpServer.on('upgrade', async (request, socket, head) => {
  try {
    const { query } = parse(request.url || '', true);
    const token = query.token as string
      || request.headers.authorization?.replace('Bearer ', '');

    if (!token) {
      socket.write('HTTP/1.1 401 Unauthorized\r\n\r\n');
      socket.destroy();
      return;
    }

    const user = await verifyToken(token);

    wss.handleUpgrade(request, socket, head, (ws) => {
      clients.set(ws, {
        userId: user.id,
        name: user.name,
        rooms: new Set(),
        isAlive: true,
        lastActivity: Date.now(),
      });
      wss.emit('connection', ws, request, user);
    });
  } catch {
    socket.write('HTTP/1.1 401 Unauthorized\r\n\r\n');
    socket.destroy();
  }
});

// Connection handler
wss.on('connection', (ws: WebSocket, _request, user) => {
  console.log(`User connected: ${user.id}`);

  // Send welcome message
  send(ws, 'connection:established', {
    userId: user.id,
    serverTime: Date.now(),
  });

  // Message handler
  ws.on('message', (raw: Buffer) => {
    try {
      const message = JSON.parse(raw.toString()) as WebSocketEvent;
      handleEvent(ws, message);
    } catch {
      send(ws, 'error', {
        code: 'INVALID_MESSAGE',
        message: 'Message must be valid JSON',
      });
    }
  });

  // Pong handler for heartbeat
  ws.on('pong', () => {
    const state = clients.get(ws);
    if (state) state.isAlive = true;
  });

  // Disconnect handler
  ws.on('close', (code, reason) => {
    const state = clients.get(ws);
    if (state) {
      // Leave all rooms
      state.rooms.forEach((roomId) => leaveRoom(ws, roomId));
      
      // Broadcast offline status
      broadcast('user:offline', {
        userId: state.userId,
        lastSeen: Date.now(),
      });
    }
    clients.delete(ws);
  });

  // Error handler
  ws.on('error', (error) => {
    console.error(`WebSocket error for ${user.id}:`, error.message);
  });
});

// Helper: Send typed event
function send<E extends keyof ServerEvents>(
  ws: WebSocket,
  event: E,
  data: ServerEvents[E]
) {
  if (ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify({ event, data, timestamp: Date.now() }));
  }
}

// Helper: Broadcast to all connected clients
function broadcast<E extends keyof ServerEvents>(
  event: E,
  data: ServerEvents[E],
  exclude?: WebSocket
) {
  for (const [client] of clients) {
    if (client !== exclude && client.readyState === WebSocket.OPEN) {
      send(client, event, data);
    }
  }
}

// Helper: Broadcast to room
function broadcastToRoom<E extends keyof ServerEvents>(
  roomId: string,
  event: E,
  data: ServerEvents[E],
  exclude?: WebSocket
) {
  for (const [client, state] of clients) {
    if (
      state.rooms.has(roomId) &&
      client !== exclude &&
      client.readyState === WebSocket.OPEN
    ) {
      send(client, event, data);
    }
  }
}
```

### Event Router
```typescript
// ws/events/router.ts
type EventHandler = (ws: WebSocket, data: unknown) => Promise<void>;

const eventHandlers = new Map<string, EventHandler>();

// Register handlers
eventHandlers.set('chat:send', handleChatSend);
eventHandlers.set('chat:typing', handleChatTyping);
eventHandlers.set('room:join', handleRoomJoin);
eventHandlers.set('room:leave', handleRoomLeave);

async function handleEvent(ws: WebSocket, message: WebSocketEvent) {
  const handler = eventHandlers.get(message.event);

  if (!handler) {
    send(ws, 'error', {
      code: 'UNKNOWN_EVENT',
      message: `Unknown event: ${message.event}`,
    });
    return;
  }

  try {
    await handler(ws, message.data);
  } catch (error) {
    send(ws, 'error', {
      code: 'HANDLER_ERROR',
      message: (error as Error).message,
    });
  }
}
```

---

## Socket.IO Server (Recommended for Production)

### Server Setup
```typescript
// ws/server.ts (Socket.IO version)
import { Server, Socket } from 'socket.io';
import { createServer } from 'http';
import { createAdapter } from '@socket.io/redis-adapter';
import { createClient } from 'redis';
import { verifyToken } from '../utils/auth';

const httpServer = createServer();

const io = new Server<ClientEvents, ServerEvents>(httpServer, {
  cors: {
    origin: process.env.CORS_ORIGIN?.split(',') || '*',
    credentials: true,
  },
  // Connection settings
  pingInterval: 25000,     // Server ping interval
  pingTimeout: 20000,      // Client pong timeout
  maxHttpBufferSize: 1e6,  // 1MB max message size
  connectTimeout: 45000,   // Connection timeout
  // Transport
  transports: ['websocket', 'polling'],
});

// Redis adapter for horizontal scaling
const pubClient = createClient({ url: process.env.REDIS_URL });
const subClient = pubClient.duplicate();

await Promise.all([pubClient.connect(), subClient.connect()]);
io.adapter(createAdapter(pubClient, subClient));

// Authentication middleware
io.use(async (socket, next) => {
  try {
    const token =
      socket.handshake.auth.token ||
      socket.handshake.headers.authorization?.replace('Bearer ', '');

    if (!token) {
      return next(new Error('UNAUTHENTICATED'));
    }

    const user = await verifyToken(token);
    socket.data.userId = user.id;
    socket.data.userName = user.name;
    socket.data.userRole = user.role;
    next();
  } catch {
    next(new Error('UNAUTHENTICATED'));
  }
});

// Rate limiting middleware
const rateLimits = new Map<string, { count: number; resetAt: number }>();

io.use((socket, next) => {
  const clientId = socket.data.userId;
  const now = Date.now();
  const entry = rateLimits.get(clientId);

  if (entry && entry.resetAt > now && entry.count > 100) {
    return next(new Error('RATE_LIMITED'));
  }

  if (!entry || entry.resetAt <= now) {
    rateLimits.set(clientId, { count: 1, resetAt: now + 60000 });
  } else {
    entry.count++;
  }

  next();
});
```

### Event Handlers
```typescript
// Connection handler
io.on('connection', (socket: Socket<ClientEvents, ServerEvents>) => {
  const { userId, userName } = socket.data;
  console.log(`Connected: ${userName} (${userId})`);

  // Auto-join personal room
  socket.join(`user:${userId}`);

  // Broadcast online status
  socket.broadcast.emit('user:online', {
    userId,
    name: userName,
    onlineAt: Date.now(),
  });

  // ── Chat Events ──

  socket.on('chat:send', async (data, ack) => {
    // Validate
    if (!data.text?.trim() || !data.roomId) {
      return ack?.({
        success: false,
        error: { code: 'VALIDATION', message: 'Text and roomId required' },
      });
    }

    // Check room membership
    if (!socket.rooms.has(data.roomId)) {
      return ack?.({
        success: false,
        error: { code: 'FORBIDDEN', message: 'Not in this room' },
      });
    }

    // Persist message
    const message = await prisma.message.create({
      data: {
        text: data.text.trim(),
        roomId: data.roomId,
        senderId: userId,
      },
    });

    // Broadcast to room (except sender)
    socket.to(data.roomId).emit('chat:message', {
      id: message.id,
      text: message.text,
      senderId: userId,
      senderName: userName,
      roomId: data.roomId,
      timestamp: message.createdAt.getTime(),
    });

    // Acknowledge success
    ack?.({ success: true, data: { messageId: message.id } });
  });

  socket.on('chat:typing', (data) => {
    if (socket.rooms.has(data.roomId)) {
      socket.to(data.roomId).emit('chat:typing', {
        userId,
        roomId: data.roomId,
        isTyping: data.isTyping,
      });
    }
  });

  // ── Room Events ──

  socket.on('room:join', async (data, ack) => {
    // Authorization check
    const canJoin = await checkRoomAccess(userId, data.roomId);
    if (!canJoin) {
      return ack?.({
        success: false,
        error: { code: 'FORBIDDEN', message: 'Cannot join this room' },
      });
    }

    socket.join(data.roomId);

    // Notify room members
    socket.to(data.roomId).emit('notification', {
      id: generateId(),
      type: 'info',
      title: 'User Joined',
      body: `${userName} joined the room`,
    });

    ack?.({ success: true });
  });

  socket.on('room:leave', (data) => {
    socket.leave(data.roomId);

    socket.to(data.roomId).emit('notification', {
      id: generateId(),
      type: 'info',
      title: 'User Left',
      body: `${userName} left the room`,
    });
  });

  // ── Disconnect ──

  socket.on('disconnect', (reason) => {
    console.log(`Disconnected: ${userName} (${reason})`);

    socket.broadcast.emit('user:offline', {
      userId,
      lastSeen: Date.now(),
    });
  });
});
```

---

## Client Implementation

### Reconnecting Client
```typescript
// client/ws-client.ts
import { io, Socket } from 'socket.io-client';

interface WebSocketClientOptions {
  url: string;
  token: string;
  onConnect?: () => void;
  onDisconnect?: (reason: string) => void;
  onError?: (error: Error) => void;
}

export function createWebSocketClient(options: WebSocketClientOptions) {
  const socket: Socket<ServerEvents, ClientEvents> = io(options.url, {
    auth: { token: options.token },
    transports: ['websocket', 'polling'],
    // Reconnection config
    reconnection: true,
    reconnectionAttempts: 10,
    reconnectionDelay: 1000,       // Start with 1s
    reconnectionDelayMax: 30000,   // Max 30s
    randomizationFactor: 0.5,     // Jitter
    // Timeouts
    timeout: 20000,
  });

  // Connection lifecycle
  socket.on('connect', () => {
    console.log('Connected:', socket.id);
    options.onConnect?.();
  });

  socket.on('disconnect', (reason) => {
    console.log('Disconnected:', reason);
    options.onDisconnect?.(reason);
  });

  socket.on('connect_error', (error) => {
    console.error('Connection error:', error.message);
    
    if (error.message === 'UNAUTHENTICATED') {
      // Don't retry — token is invalid
      socket.disconnect();
      options.onError?.(error);
    }
    // Other errors: auto-retry via reconnection config
  });

  return socket;
}

// Usage
const socket = createWebSocketClient({
  url: 'wss://api.example.com',
  token: authToken,
  onConnect: () => updateConnectionStatus('online'),
  onDisconnect: () => updateConnectionStatus('offline'),
});

// Send message with acknowledgment
socket.emit('chat:send', 
  { text: 'Hello!', roomId: 'room-1' },
  (response) => {
    if (response.success) {
      console.log('Message sent:', response.data?.messageId);
    } else {
      console.error('Failed:', response.error?.message);
    }
  }
);

// Listen for events
socket.on('chat:message', (message) => {
  addMessageToUI(message);
});

socket.on('chat:typing', ({ userId, isTyping }) => {
  updateTypingIndicator(userId, isTyping);
});
```

### React Hook
```typescript
// hooks/useWebSocket.ts
import { useEffect, useRef, useCallback, useState } from 'react';
import { Socket } from 'socket.io-client';
import { createWebSocketClient } from '../client/ws-client';

interface UseWebSocketOptions {
  url: string;
  token: string;
  enabled?: boolean;
}

export function useWebSocket({ url, token, enabled = true }: UseWebSocketOptions) {
  const socketRef = useRef<Socket | null>(null);
  const [isConnected, setIsConnected] = useState(false);

  useEffect(() => {
    if (!enabled || !token) return;

    const socket = createWebSocketClient({
      url,
      token,
      onConnect: () => setIsConnected(true),
      onDisconnect: () => setIsConnected(false),
    });

    socketRef.current = socket;

    return () => {
      socket.disconnect();
      socketRef.current = null;
    };
  }, [url, token, enabled]);

  const emit = useCallback(
    <E extends keyof ClientEvents>(
      event: E,
      data: ClientEvents[E],
      ack?: AckCallback
    ) => {
      socketRef.current?.emit(event, data, ack);
    },
    []
  );

  const on = useCallback(
    <E extends keyof ServerEvents>(
      event: E,
      handler: (data: ServerEvents[E]) => void
    ) => {
      socketRef.current?.on(event, handler);
      return () => {
        socketRef.current?.off(event, handler);
      };
    },
    []
  );

  return { socket: socketRef.current, isConnected, emit, on };
}

// Usage in component
function ChatRoom({ roomId }: { roomId: string }) {
  const { isConnected, emit, on } = useWebSocket({
    url: 'wss://api.example.com',
    token: useAuth().token,
  });

  const [messages, setMessages] = useState<Message[]>([]);

  useEffect(() => {
    const unsubscribe = on('chat:message', (message) => {
      setMessages((prev) => [...prev, message]);
    });
    return unsubscribe;
  }, [on]);

  const sendMessage = (text: string) => {
    emit('chat:send', { text, roomId }, (response) => {
      if (!response.success) {
        showError(response.error?.message);
      }
    });
  };

  return (
    <div>
      <ConnectionStatus connected={isConnected} />
      <MessageList messages={messages} />
      <MessageInput onSend={sendMessage} disabled={!isConnected} />
    </div>
  );
}
```

---

## Heartbeat & Connection Health

### Server-Side Ping/Pong (Native ws)
```typescript
// Heartbeat interval (native ws library)
const HEARTBEAT_INTERVAL = 30_000;  // 30 seconds
const HEARTBEAT_TIMEOUT = 10_000;   // 10 seconds grace

const heartbeatTimer = setInterval(() => {
  for (const [ws, state] of clients) {
    if (!state.isAlive) {
      // Client missed previous heartbeat — terminate
      console.log(`Terminating unresponsive client: ${state.userId}`);
      ws.terminate();
      clients.delete(ws);
      continue;
    }

    state.isAlive = false;
    ws.ping(); // Client should respond with pong
  }
}, HEARTBEAT_INTERVAL);

// Cleanup on server close
wss.on('close', () => {
  clearInterval(heartbeatTimer);
});
```

### Client-Side Reconnection (Native WebSocket)
```typescript
// client/reconnecting-websocket.ts
interface ReconnectOptions {
  maxRetries: number;
  baseDelay: number;
  maxDelay: number;
  jitter: boolean;
}

class ReconnectingWebSocket {
  private ws: WebSocket | null = null;
  private retryCount = 0;
  private readonly options: ReconnectOptions;

  constructor(
    private url: string,
    private protocols?: string[],
    options?: Partial<ReconnectOptions>
  ) {
    this.options = {
      maxRetries: 10,
      baseDelay: 1000,
      maxDelay: 30000,
      jitter: true,
      ...options,
    };
    this.connect();
  }

  private connect() {
    this.ws = new WebSocket(this.url, this.protocols);

    this.ws.onopen = () => {
      this.retryCount = 0; // Reset on successful connection
      this.onOpen?.();
    };

    this.ws.onclose = (event) => {
      this.onClose?.(event);

      // Don't reconnect on intentional close (1000)
      if (event.code === 1000) return;

      this.scheduleReconnect();
    };

    this.ws.onerror = (error) => {
      this.onError?.(error);
    };

    this.ws.onmessage = (event) => {
      this.onMessage?.(event);
    };
  }

  private scheduleReconnect() {
    if (this.retryCount >= this.options.maxRetries) {
      console.error('Max reconnection attempts reached');
      return;
    }

    // Exponential backoff with jitter
    let delay = Math.min(
      this.options.baseDelay * Math.pow(2, this.retryCount),
      this.options.maxDelay
    );

    if (this.options.jitter) {
      delay *= 0.5 + Math.random(); // 50-150% of calculated delay
    }

    this.retryCount++;
    console.log(`Reconnecting in ${Math.round(delay)}ms (attempt ${this.retryCount})`);

    setTimeout(() => this.connect(), delay);
  }

  send(data: string | ArrayBuffer) {
    if (this.ws?.readyState === WebSocket.OPEN) {
      this.ws.send(data);
    } else {
      throw new Error('WebSocket is not connected');
    }
  }

  close(code = 1000, reason = 'Client disconnect') {
    this.ws?.close(code, reason);
  }

  // Event handlers (set by consumer)
  onOpen?: () => void;
  onClose?: (event: CloseEvent) => void;
  onMessage?: (event: MessageEvent) => void;
  onError?: (event: Event) => void;
}
```

---

## Scaling with Redis Adapter

```typescript
// ws/adapters/redis-adapter.ts
import { Server } from 'socket.io';
import { createAdapter } from '@socket.io/redis-adapter';
import { createClient } from 'redis';

export async function setupRedisAdapter(io: Server) {
  const pubClient = createClient({
    url: process.env.REDIS_URL || 'redis://localhost:6379',
  });
  const subClient = pubClient.duplicate();

  pubClient.on('error', (err) => console.error('Redis pub error:', err));
  subClient.on('error', (err) => console.error('Redis sub error:', err));

  await Promise.all([pubClient.connect(), subClient.connect()]);

  io.adapter(createAdapter(pubClient, subClient));

  console.log('Redis adapter configured for Socket.IO');

  return { pubClient, subClient };
}

// With Redis adapter, these work across ALL server instances:
// - io.emit()       → All clients on all servers
// - socket.to(room) → All clients in room across servers
// - io.to(userId)   → Specific user on any server
```

---

## Message Validation

```typescript
// ws/middleware/validation.ts
import { z } from 'zod';

// Define schemas for each event
const eventSchemas = {
  'chat:send': z.object({
    text: z.string().min(1).max(4000).trim(),
    roomId: z.string().uuid(),
  }),
  'chat:typing': z.object({
    roomId: z.string().uuid(),
    isTyping: z.boolean(),
  }),
  'room:join': z.object({
    roomId: z.string().uuid(),
  }),
  'room:leave': z.object({
    roomId: z.string().uuid(),
  }),
} as const;

// Validate incoming events
function validateEvent<E extends keyof typeof eventSchemas>(
  event: E,
  data: unknown
): z.infer<(typeof eventSchemas)[E]> {
  const schema = eventSchemas[event];
  if (!schema) {
    throw new Error(`No schema for event: ${event}`);
  }
  return schema.parse(data);
}

// Socket.IO middleware for validation
io.use((socket, next) => {
  const originalEmit = socket.emit.bind(socket);

  // Intercept incoming events
  socket.onAny((event, data, ack) => {
    const schema = eventSchemas[event as keyof typeof eventSchemas];
    if (schema) {
      const result = schema.safeParse(data);
      if (!result.success) {
        socket.emit('error', {
          code: 'VALIDATION_ERROR',
          message: 'Invalid event data',
          details: result.error.flatten(),
        });
        return;
      }
    }
  });

  next();
});
```

---

## Testing

### Server Tests
```typescript
// tests/ws-server.test.ts
import { createServer } from 'http';
import { Server } from 'socket.io';
import { io as createClient, Socket } from 'socket.io-client';
import { AddressInfo } from 'net';

describe('WebSocket Server', () => {
  let httpServer: ReturnType<typeof createServer>;
  let ioServer: Server;
  let clientSocket: Socket;
  let port: number;

  beforeAll((done) => {
    httpServer = createServer();
    ioServer = new Server(httpServer);
    setupHandlers(ioServer); // Your event handlers

    httpServer.listen(0, () => {
      port = (httpServer.address() as AddressInfo).port;
      done();
    });
  });

  beforeEach((done) => {
    clientSocket = createClient(`http://localhost:${port}`, {
      auth: { token: 'test-token' },
      transports: ['websocket'],
    });
    clientSocket.on('connect', done);
  });

  afterEach(() => {
    clientSocket.disconnect();
  });

  afterAll(() => {
    ioServer.close();
    httpServer.close();
  });

  test('sends message and receives broadcast', (done) => {
    // Create second client to receive broadcast
    const client2 = createClient(`http://localhost:${port}`, {
      auth: { token: 'test-token-2' },
      transports: ['websocket'],
    });

    client2.on('connect', () => {
      // Both join same room
      clientSocket.emit('room:join', { roomId: 'test-room' });
      client2.emit('room:join', { roomId: 'test-room' });

      // Client 2 listens for messages
      client2.on('chat:message', (message) => {
        expect(message.text).toBe('Hello!');
        expect(message.roomId).toBe('test-room');
        client2.disconnect();
        done();
      });

      // Client 1 sends message
      setTimeout(() => {
        clientSocket.emit(
          'chat:send',
          { text: 'Hello!', roomId: 'test-room' },
          (response: any) => {
            expect(response.success).toBe(true);
          }
        );
      }, 100);
    });
  });

  test('rejects invalid message data', (done) => {
    clientSocket.emit(
      'chat:send',
      { text: '', roomId: 'invalid' }, // Empty text
      (response: any) => {
        expect(response.success).toBe(false);
        expect(response.error.code).toBe('VALIDATION');
        done();
      }
    );
  });

  test('handles disconnect gracefully', (done) => {
    const client2 = createClient(`http://localhost:${port}`, {
      auth: { token: 'test-token-2' },
      transports: ['websocket'],
    });

    client2.on('user:offline', (data) => {
      expect(data.userId).toBeDefined();
      client2.disconnect();
      done();
    });

    client2.on('connect', () => {
      // Disconnect first client
      clientSocket.disconnect();
    });
  });
});
```

---

## Security

```yaml
Authentication:
  - Authenticate on handshake (token in auth object or query param)
  - Never send credentials in message body
  - Validate token expiry on every connection
  - Reject connections with expired tokens

Authorization:
  - Check room access before joining
  - Verify action permissions per event
  - Use socket.data to store user context
  - Rate limit events per user (100/min default)

Transport:
  - Always use WSS (TLS) in production
  - Set maxHttpBufferSize to prevent large payloads (1MB)
  - Validate and sanitize all incoming data with Zod
  - Implement CORS properly on the server

Data:
  - Never expose internal IDs or server details in error messages
  - Sanitize user-generated content before broadcasting
  - Use message IDs for deduplication
  - Log connection events for audit trail
```

---

## Close Codes Reference

```typescript
// WebSocket Close Codes (RFC 6455)
const CloseCodes = {
  NORMAL: 1000,           // Normal closure
  GOING_AWAY: 1001,       // Server shutdown or page navigation
  PROTOCOL_ERROR: 1002,   // Protocol error
  UNSUPPORTED: 1003,      // Unsupported data type
  NO_STATUS: 1005,        // No status code (reserved)
  ABNORMAL: 1006,         // Abnormal closure (reserved)
  INVALID_DATA: 1007,     // Invalid payload data
  POLICY_VIOLATION: 1008, // Policy violation
  TOO_LARGE: 1009,        // Message too large
  MISSING_EXTENSION: 1010,// Required extension missing
  INTERNAL_ERROR: 1011,   // Internal server error
  TLS_FAILED: 1015,       // TLS handshake failure (reserved)

  // Application codes (4000-4999)
  UNAUTHENTICATED: 4001,
  TOKEN_EXPIRED: 4002,
  RATE_LIMITED: 4003,
  ROOM_FULL: 4004,
  MAINTENANCE: 4005,
} as const;
```

---

## Anti-Patterns

```yaml
❌ DON'T:
  - Send auth tokens in message body (use handshake)
  - Use WebSocket for request-response (use HTTP)
  - Create new connections per operation (reuse connection)
  - Broadcast to all when room broadcast suffices
  - Store connection state only in memory (use Redis)
  - Ignore reconnection logic on client
  - Skip message validation and sanitization
  - Use WebSocket for file uploads (use HTTP + presigned URLs)

✅ DO:
  - Authenticate during handshake upgrade
  - Use typed events with TypeScript
  - Implement heartbeat/ping-pong for connection health
  - Use Redis adapter for horizontal scaling
  - Validate all incoming data with Zod schemas
  - Handle all close codes appropriately
  - Use exponential backoff for reconnection
  - Use rooms/channels for targeted broadcasting
  - Log connection lifecycle (connect, disconnect, errors)
  - Set message size limits (maxHttpBufferSize)
```

---

**Version:** 1.0.0  
**Standards:** RFC 6455, WebSocket Protocol, Socket.IO v4  
**Created:** 2026-02-09

# Next.js Real-time Features Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **Next.js:** 14.x / 15.x  
> **Priority:** P1 - Load for real-time features

---

You are an expert in implementing real-time features in Next.js applications.

## Core Real-time Principles

- Choose appropriate real-time technology
- Use SSE for server-to-client streaming
- Use WebSockets for bidirectional communication
- Implement proper error handling and reconnection

---

## 1) Technology Selection

### Decision Tree
```
┌─────────────────────────────────────────────────────────────────┐
│                  What Kind of Real-time?                        │
└──────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
  Server → Client        Bidirectional         Database Sync
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│ SSE           │    │ WebSockets    │    │ Supabase      │
│               │    │               │    │ Realtime      │
│ • Notifications    │ • Chat        │    │               │
│ • Live updates│    │ • Gaming      │    │ • Row changes │
│ • AI streaming│    │ • Collab edit │    │ • Presence    │
│ • News feed   │    │ • Cursors     │    │ • Broadcast   │
└────────────┘    └────────────┘    └────────────┘
        │                     │                     │
   Next.js native        Socket.io or         Supabase SDK
   Route Handlers        Pusher/Ably
```

---

## 2) Server-Sent Events (SSE)

### Complete SSE Implementation
```typescript
// ==========================================
// app/api/events/route.ts
// ==========================================

import { NextRequest } from 'next/server';

export const runtime = 'nodejs';
export const dynamic = 'force-dynamic';

export async function GET(request: NextRequest) {
  const encoder = new TextEncoder();
  
  // Create readable stream
  const stream = new ReadableStream({
    async start(controller) {
      // Send initial connection message
      const sendEvent = (event: string, data: any) => {
        const message = `event: ${event}\ndata: ${JSON.stringify(data)}\n\n`;
        controller.enqueue(encoder.encode(message));
      };
      
      // Send connection established
      sendEvent('connected', { 
        message: 'Connected to event stream',
        timestamp: Date.now(),
      });
      
      // Heartbeat to keep connection alive
      const heartbeatInterval = setInterval(() => {
        try {
          sendEvent('heartbeat', { timestamp: Date.now() });
        } catch {
          clearInterval(heartbeatInterval);
        }
      }, 30000);  // Every 30 seconds
      
      // Simulate real-time updates
      let counter = 0;
      const updateInterval = setInterval(() => {
        counter++;
        sendEvent('update', {
          id: counter,
          message: `Update #${counter}`,
          timestamp: Date.now(),
        });
        
        // Stop after 100 updates for demo
        if (counter >= 100) {
          clearInterval(updateInterval);
          clearInterval(heartbeatInterval);
          controller.close();
        }
      }, 2000);
      
      // Handle client disconnect
      request.signal.addEventListener('abort', () => {
        clearInterval(heartbeatInterval);
        clearInterval(updateInterval);
        controller.close();
      });
    },
  });
  
  return new Response(stream, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache, no-transform',
      'Connection': 'keep-alive',
      'X-Accel-Buffering': 'no',
    },
  });
}


// ==========================================
// hooks/useEventSource.ts
// ==========================================

'use client';

import { useEffect, useState, useCallback, useRef } from 'react';

interface UseEventSourceOptions {
  onMessage?: (event: MessageEvent) => void;
  onError?: (error: Event) => void;
  onOpen?: () => void;
  reconnectInterval?: number;
  maxRetries?: number;
}

export function useEventSource(
  url: string,
  options: UseEventSourceOptions = {}
) {
  const {
    onMessage,
    onError,
    onOpen,
    reconnectInterval = 3000,
    maxRetries = 5,
  } = options;
  
  const [isConnected, setIsConnected] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const [retryCount, setRetryCount] = useState(0);
  
  const eventSourceRef = useRef<EventSource | null>(null);

  const connect = useCallback(() => {
    if (eventSourceRef.current) {
      eventSourceRef.current.close();
    }
    
    const eventSource = new EventSource(url);
    eventSourceRef.current = eventSource;
    
    eventSource.onopen = () => {
      setIsConnected(true);
      setError(null);
      setRetryCount(0);
      onOpen?.();
    };
    
    eventSource.onmessage = (event) => {
      onMessage?.(event);
    };
    
    eventSource.onerror = (e) => {
      setIsConnected(false);
      setError(new Error('Connection lost'));
      onError?.(e);
      
      eventSource.close();
      
      // Reconnect with exponential backoff
      if (retryCount < maxRetries) {
        const delay = reconnectInterval * Math.pow(2, retryCount);
        setTimeout(() => {
          setRetryCount(prev => prev + 1);
          connect();
        }, delay);
      }
    };
    
    return eventSource;
  }, [url, onMessage, onError, onOpen, reconnectInterval, maxRetries, retryCount]);

  useEffect(() => {
    const eventSource = connect();
    
    return () => {
      eventSource.close();
    };
  }, [connect]);

  const disconnect = useCallback(() => {
    if (eventSourceRef.current) {
      eventSourceRef.current.close();
      eventSourceRef.current = null;
      setIsConnected(false);
    }
  }, []);

  return { isConnected, error, retryCount, disconnect };
}


// ==========================================
// USAGE IN COMPONENT
// ==========================================

'use client';

import { useState } from 'react';
import { useEventSource } from '@/hooks/useEventSource';

interface Update {
  id: number;
  message: string;
  timestamp: number;
}

export function LiveUpdates() {
  const [updates, setUpdates] = useState<Update[]>([]);
  
  const { isConnected, error, retryCount } = useEventSource('/api/events', {
    onMessage: (event) => {
      const data = JSON.parse(event.data);
      setUpdates(prev => [...prev.slice(-50), data]);  // Keep last 50
    },
    onOpen: () => {
      console.log('Connected to event stream');
    },
    onError: () => {
      console.log('Connection error, retrying...');
    },
  });

  return (
    <div>
      <div className="status">
        {isConnected ? (
          <span className="badge-green">● Connected</span>
        ) : (
          <span className="badge-red">
            ● Disconnected {retryCount > 0 && `(Retry ${retryCount})`}
          </span>
        )}
      </div>
      
      {error && (
        <div className="error">{error.message}</div>
      )}
      
      <ul className="updates-list">
        {updates.map(update => (
          <li key={update.id}>
            {update.message} - {new Date(update.timestamp).toLocaleTimeString()}
          </li>
        ))}
      </ul>
    </div>
  );
}
```

---

## 3) AI Streaming with SSE

### AI Chat Streaming
```typescript
// ==========================================
// app/api/chat/route.ts
// ==========================================

import { NextRequest } from 'next/server';
import OpenAI from 'openai';

const openai = new OpenAI();

export const runtime = 'edge';

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
      try {
        for await (const chunk of stream) {
          const content = chunk.choices[0]?.delta?.content || '';
          
          if (content) {
            const data = JSON.stringify({ content });
            controller.enqueue(encoder.encode(`data: ${data}\n\n`));
          }
          
          // Check for finish reason
          if (chunk.choices[0]?.finish_reason === 'stop') {
            controller.enqueue(encoder.encode('data: [DONE]\n\n'));
          }
        }
      } catch (error) {
        const errorData = JSON.stringify({ error: 'Stream error' });
        controller.enqueue(encoder.encode(`data: ${errorData}\n\n`));
      } finally {
        controller.close();
      }
    },
  });
  
  return new Response(readable, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    },
  });
}


// ==========================================
// components/ChatMessage.tsx
// ==========================================

'use client';

import { useState, useCallback } from 'react';

interface Message {
  role: 'user' | 'assistant';
  content: string;
}

export function Chat() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [isStreaming, setIsStreaming] = useState(false);

  const sendMessage = useCallback(async () => {
    if (!input.trim() || isStreaming) return;
    
    const userMessage: Message = { role: 'user', content: input };
    const newMessages = [...messages, userMessage];
    
    setMessages(newMessages);
    setInput('');
    setIsStreaming(true);
    
    // Add placeholder for assistant message
    setMessages([...newMessages, { role: 'assistant', content: '' }]);
    
    try {
      const response = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ messages: newMessages }),
      });
      
      const reader = response.body?.getReader();
      const decoder = new TextDecoder();
      
      if (!reader) throw new Error('No reader');
      
      let assistantContent = '';
      
      while (true) {
        const { done, value } = await reader.read();
        
        if (done) break;
        
        const chunk = decoder.decode(value);
        const lines = chunk.split('\n');
        
        for (const line of lines) {
          if (line.startsWith('data: ')) {
            const data = line.slice(6);
            
            if (data === '[DONE]') {
              break;
            }
            
            try {
              const parsed = JSON.parse(data);
              if (parsed.content) {
                assistantContent += parsed.content;
                
                setMessages(prev => [
                  ...prev.slice(0, -1),
                  { role: 'assistant', content: assistantContent },
                ]);
              }
            } catch {
              // Skip invalid JSON
            }
          }
        }
      }
    } catch (error) {
      console.error('Chat error:', error);
    } finally {
      setIsStreaming(false);
    }
  }, [input, messages, isStreaming]);

  return (
    <div className="chat-container">
      <div className="messages">
        {messages.map((msg, i) => (
          <div key={i} className={`message ${msg.role}`}>
            {msg.content}
            {isStreaming && i === messages.length - 1 && msg.role === 'assistant' && (
              <span className="cursor">▊</span>
            )}
          </div>
        ))}
      </div>
      
      <div className="input-area">
        <input
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && sendMessage()}
          placeholder="Type a message..."
          disabled={isStreaming}
        />
        <button onClick={sendMessage} disabled={isStreaming}>
          {isStreaming ? 'Sending...' : 'Send'}
        </button>
      </div>
    </div>
  );
}
```

---

## 4) Socket.io Integration

### Server Setup
```typescript
// ==========================================
// server.ts (Custom server)
// ==========================================

import { createServer } from 'http';
import { parse } from 'url';
import next from 'next';
import { Server as SocketIOServer } from 'socket.io';

const dev = process.env.NODE_ENV !== 'production';
const app = next({ dev });
const handle = app.getRequestHandler();

app.prepare().then(() => {
  const server = createServer((req, res) => {
    const parsedUrl = parse(req.url!, true);
    handle(req, res, parsedUrl);
  });
  
  // Initialize Socket.IO
  const io = new SocketIOServer(server, {
    cors: {
      origin: process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000',
      methods: ['GET', 'POST'],
    },
  });
  
  // Authentication middleware
  io.use((socket, next) => {
    const token = socket.handshake.auth.token;
    
    if (!token) {
      return next(new Error('Authentication required'));
    }
    
    // Verify token (implement your auth logic)
    try {
      const user = verifyToken(token);
      socket.data.user = user;
      next();
    } catch {
      next(new Error('Invalid token'));
    }
  });
  
  // Connection handling
  io.on('connection', (socket) => {
    const user = socket.data.user;
    console.log(`User connected: ${user.id}`);
    
    // Join user's personal room
    socket.join(`user:${user.id}`);
    
    // Handle joining chat rooms
    socket.on('join-room', (roomId: string) => {
      socket.join(`room:${roomId}`);
      
      // Notify room members
      socket.to(`room:${roomId}`).emit('user-joined', {
        userId: user.id,
        name: user.name,
      });
    });
    
    // Handle leaving rooms
    socket.on('leave-room', (roomId: string) => {
      socket.leave(`room:${roomId}`);
      
      socket.to(`room:${roomId}`).emit('user-left', {
        userId: user.id,
      });
    });
    
    // Handle chat messages
    socket.on('send-message', async (data: {
      roomId: string;
      content: string;
    }) => {
      const message = {
        id: crypto.randomUUID(),
        content: data.content,
        userId: user.id,
        userName: user.name,
        roomId: data.roomId,
        createdAt: new Date().toISOString(),
      };
      
      // Save to database
      await saveMessage(message);
      
      // Broadcast to room
      io.to(`room:${data.roomId}`).emit('new-message', message);
    });
    
    // Typing indicator
    socket.on('typing', (roomId: string) => {
      socket.to(`room:${roomId}`).emit('user-typing', {
        userId: user.id,
        name: user.name,
      });
    });
    
    socket.on('stop-typing', (roomId: string) => {
      socket.to(`room:${roomId}`).emit('user-stop-typing', {
        userId: user.id,
      });
    });
    
    // Disconnect handling
    socket.on('disconnect', () => {
      console.log(`User disconnected: ${user.id}`);
    });
  });
  
  // Store io instance for API routes
  (global as any).io = io;
  
  const PORT = process.env.PORT || 3000;
  server.listen(PORT, () => {
    console.log(`> Ready on http://localhost:${PORT}`);
  });
});


// ==========================================
// lib/socket-client.ts
// ==========================================

'use client';

import { io, Socket } from 'socket.io-client';

let socket: Socket | null = null;

export function getSocket(): Socket {
  if (!socket) {
    socket = io(process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000', {
      auth: {
        token: getAuthToken(),  // Implement your auth token retrieval
      },
      autoConnect: false,
      reconnection: true,
      reconnectionAttempts: 5,
      reconnectionDelay: 1000,
      reconnectionDelayMax: 5000,
    });
  }
  
  return socket;
}

export function connectSocket() {
  const socket = getSocket();
  if (!socket.connected) {
    socket.connect();
  }
  return socket;
}

export function disconnectSocket() {
  if (socket) {
    socket.disconnect();
    socket = null;
  }
}


// ==========================================
// hooks/useSocket.ts
// ==========================================

'use client';

import { useEffect, useState, useCallback } from 'react';
import { Socket } from 'socket.io-client';
import { getSocket, connectSocket, disconnectSocket } from '@/lib/socket-client';

export function useSocket() {
  const [isConnected, setIsConnected] = useState(false);
  const [socket, setSocket] = useState<Socket | null>(null);

  useEffect(() => {
    const socketInstance = connectSocket();
    setSocket(socketInstance);
    
    socketInstance.on('connect', () => {
      setIsConnected(true);
    });
    
    socketInstance.on('disconnect', () => {
      setIsConnected(false);
    });
    
    return () => {
      disconnectSocket();
    };
  }, []);

  const emit = useCallback((event: string, data?: any) => {
    socket?.emit(event, data);
  }, [socket]);

  const on = useCallback((event: string, callback: (data: any) => void) => {
    socket?.on(event, callback);
    
    return () => {
      socket?.off(event, callback);
    };
  }, [socket]);

  return { socket, isConnected, emit, on };
}
```

---

## 5) Pusher Integration

### Pusher Setup
```typescript
// ==========================================
// lib/pusher-server.ts
// ==========================================

import Pusher from 'pusher';

export const pusherServer = new Pusher({
  appId: process.env.PUSHER_APP_ID!,
  key: process.env.NEXT_PUBLIC_PUSHER_KEY!,
  secret: process.env.PUSHER_SECRET!,
  cluster: process.env.NEXT_PUBLIC_PUSHER_CLUSTER!,
  useTLS: true,
});


// ==========================================
// lib/pusher-client.ts
// ==========================================

'use client';

import PusherClient from 'pusher-js';

export const pusherClient = new PusherClient(
  process.env.NEXT_PUBLIC_PUSHER_KEY!,
  {
    cluster: process.env.NEXT_PUBLIC_PUSHER_CLUSTER!,
    authEndpoint: '/api/pusher/auth',
    authTransport: 'ajax',
    auth: {
      headers: {
        'Content-Type': 'application/json',
      },
    },
  }
);


// ==========================================
// app/api/pusher/auth/route.ts
// ==========================================

import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@/auth';
import { pusherServer } from '@/lib/pusher-server';

export async function POST(request: NextRequest) {
  const session = await auth();
  
  if (!session?.user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }
  
  const data = await request.text();
  const [socketId, channelName] = data
    .split('&')
    .map(str => str.split('=')[1]);
  
  // For private channels
  if (channelName.startsWith('private-')) {
    const authResponse = pusherServer.authorizeChannel(socketId, channelName);
    return NextResponse.json(authResponse);
  }
  
  // For presence channels
  if (channelName.startsWith('presence-')) {
    const presenceData = {
      user_id: session.user.id,
      user_info: {
        name: session.user.name,
        email: session.user.email,
        image: session.user.image,
      },
    };
    
    const authResponse = pusherServer.authorizeChannel(
      socketId,
      channelName,
      presenceData
    );
    return NextResponse.json(authResponse);
  }
  
  return NextResponse.json({ error: 'Invalid channel' }, { status: 400 });
}


// ==========================================
// app/api/messages/route.ts
// ==========================================

import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@/auth';
import { pusherServer } from '@/lib/pusher-server';
import { prisma } from '@/lib/prisma';

export async function POST(request: NextRequest) {
  const session = await auth();
  
  if (!session?.user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }
  
  const { channelId, content } = await request.json();
  
  // Save message
  const message = await prisma.message.create({
    data: {
      content,
      channelId,
      userId: session.user.id,
    },
    include: {
      user: {
        select: { id: true, name: true, image: true },
      },
    },
  });
  
  // Trigger Pusher event
  await pusherServer.trigger(`private-channel-${channelId}`, 'new-message', {
    message,
  });
  
  return NextResponse.json({ message });
}


// ==========================================
// hooks/usePusher.ts
// ==========================================

'use client';

import { useEffect, useState } from 'react';
import { pusherClient } from '@/lib/pusher-client';
import { Channel, PresenceChannel } from 'pusher-js';

export function usePusherChannel(channelName: string) {
  const [channel, setChannel] = useState<Channel | null>(null);

  useEffect(() => {
    const channel = pusherClient.subscribe(channelName);
    setChannel(channel);
    
    return () => {
      pusherClient.unsubscribe(channelName);
    };
  }, [channelName]);

  return channel;
}

export function usePusherPresence(channelName: string) {
  const [members, setMembers] = useState<Map<string, any>>(new Map());
  const [me, setMe] = useState<any>(null);

  useEffect(() => {
    const channel = pusherClient.subscribe(channelName) as PresenceChannel;
    
    channel.bind('pusher:subscription_succeeded', (data: any) => {
      setMembers(new Map(Object.entries(data.members)));
      setMe(data.me);
    });
    
    channel.bind('pusher:member_added', (member: any) => {
      setMembers(prev => new Map(prev).set(member.id, member.info));
    });
    
    channel.bind('pusher:member_removed', (member: any) => {
      setMembers(prev => {
        const next = new Map(prev);
        next.delete(member.id);
        return next;
      });
    });
    
    return () => {
      pusherClient.unsubscribe(channelName);
    };
  }, [channelName]);

  return { members: Array.from(members.values()), me, count: members.size };
}
```

---

## 6) Supabase Realtime

### Supabase Integration
```typescript
// ==========================================
// lib/supabase.ts
// ==========================================

import { createClient } from '@supabase/supabase-js';

export const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);


// ==========================================
// hooks/useRealtimeMessages.ts
// ==========================================

'use client';

import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { RealtimeChannel } from '@supabase/supabase-js';

interface Message {
  id: string;
  content: string;
  user_id: string;
  channel_id: string;
  created_at: string;
}

export function useRealtimeMessages(channelId: string) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Fetch initial messages
    async function fetchMessages() {
      const { data, error } = await supabase
        .from('messages')
        .select('*')
        .eq('channel_id', channelId)
        .order('created_at', { ascending: true })
        .limit(50);
      
      if (data) {
        setMessages(data);
      }
      setIsLoading(false);
    }
    
    fetchMessages();
    
    // Subscribe to real-time changes
    const channel = supabase
      .channel(`messages:${channelId}`)
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'messages',
          filter: `channel_id=eq.${channelId}`,
        },
        (payload) => {
          setMessages(prev => [...prev, payload.new as Message]);
        }
      )
      .on(
        'postgres_changes',
        {
          event: 'UPDATE',
          schema: 'public',
          table: 'messages',
          filter: `channel_id=eq.${channelId}`,
        },
        (payload) => {
          setMessages(prev =>
            prev.map(msg =>
              msg.id === payload.new.id ? (payload.new as Message) : msg
            )
          );
        }
      )
      .on(
        'postgres_changes',
        {
          event: 'DELETE',
          schema: 'public',
          table: 'messages',
          filter: `channel_id=eq.${channelId}`,
        },
        (payload) => {
          setMessages(prev => prev.filter(msg => msg.id !== payload.old.id));
        }
      )
      .subscribe();
    
    return () => {
      supabase.removeChannel(channel);
    };
  }, [channelId]);

  return { messages, isLoading };
}


// ==========================================
// hooks/usePresence.ts
// ==========================================

'use client';

import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { RealtimeChannel } from '@supabase/supabase-js';

interface PresenceState {
  id: string;
  name: string;
  online_at: string;
}

export function usePresence(roomId: string, userId: string, userName: string) {
  const [presenceState, setPresenceState] = useState<PresenceState[]>([]);

  useEffect(() => {
    const channel = supabase.channel(`room:${roomId}`, {
      config: {
        presence: {
          key: userId,
        },
      },
    });
    
    channel
      .on('presence', { event: 'sync' }, () => {
        const state = channel.presenceState<PresenceState>();
        const users = Object.values(state).flat();
        setPresenceState(users);
      })
      .on('presence', { event: 'join' }, ({ key, newPresences }) => {
        console.log('User joined:', key, newPresences);
      })
      .on('presence', { event: 'leave' }, ({ key, leftPresences }) => {
        console.log('User left:', key, leftPresences);
      })
      .subscribe(async (status) => {
        if (status === 'SUBSCRIBED') {
          await channel.track({
            id: userId,
            name: userName,
            online_at: new Date().toISOString(),
          });
        }
      });
    
    return () => {
      channel.untrack();
      supabase.removeChannel(channel);
    };
  }, [roomId, userId, userName]);

  return presenceState;
}
```

---

## 7) Real-time Notifications

### Notification System
```typescript
// ==========================================
// hooks/useNotifications.ts
// ==========================================

'use client';

import { useEffect, useState, useCallback } from 'react';
import { useEventSource } from './useEventSource';
import { toast } from 'sonner';

interface Notification {
  id: string;
  type: 'info' | 'success' | 'warning' | 'error';
  title: string;
  message: string;
  read: boolean;
  createdAt: string;
  data?: Record<string, any>;
}

export function useNotifications(userId: string) {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [unreadCount, setUnreadCount] = useState(0);

  // Connect to notification stream
  useEventSource(`/api/notifications/stream?userId=${userId}`, {
    onMessage: (event) => {
      try {
        const notification = JSON.parse(event.data) as Notification;
        
        // Add to list
        setNotifications(prev => [notification, ...prev.slice(0, 49)]);
        setUnreadCount(prev => prev + 1);
        
        // Show toast
        toast[notification.type](notification.title, {
          description: notification.message,
        });
        
        // Play sound
        if ('Notification' in window && Notification.permission === 'granted') {
          new Audio('/notification.mp3').play().catch(() => {});
        }
      } catch {
        // Skip invalid JSON
      }
    },
  });

  const markAsRead = useCallback(async (id: string) => {
    await fetch(`/api/notifications/${id}/read`, { method: 'POST' });
    
    setNotifications(prev =>
      prev.map(n => (n.id === id ? { ...n, read: true } : n))
    );
    setUnreadCount(prev => Math.max(0, prev - 1));
  }, []);

  const markAllAsRead = useCallback(async () => {
    await fetch('/api/notifications/read-all', { method: 'POST' });
    
    setNotifications(prev => prev.map(n => ({ ...n, read: true })));
    setUnreadCount(0);
  }, []);

  // Request notification permission
  useEffect(() => {
    if ('Notification' in window && Notification.permission === 'default') {
      Notification.requestPermission();
    }
  }, []);

  return {
    notifications,
    unreadCount,
    markAsRead,
    markAllAsRead,
  };
}


// ==========================================
// app/api/notifications/stream/route.ts
// ==========================================

import { NextRequest } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(request: NextRequest) {
  const userId = request.nextUrl.searchParams.get('userId');
  
  if (!userId) {
    return new Response('User ID required', { status: 400 });
  }
  
  const encoder = new TextEncoder();
  
  const stream = new ReadableStream({
    async start(controller) {
      // Poll for new notifications (in production, use pub/sub)
      let lastCheck = new Date();
      
      const checkNotifications = async () => {
        const notifications = await prisma.notification.findMany({
          where: {
            userId,
            createdAt: { gt: lastCheck },
          },
          orderBy: { createdAt: 'desc' },
        });
        
        for (const notification of notifications) {
          const data = JSON.stringify(notification);
          controller.enqueue(encoder.encode(`data: ${data}\n\n`));
        }
        
        lastCheck = new Date();
      };
      
      const interval = setInterval(checkNotifications, 5000);
      
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
```

---

## 8) Live Typing Indicator

### Typing Indicator Component
```typescript
// ==========================================
// hooks/useTypingIndicator.ts
// ==========================================

'use client';

import { useEffect, useState, useCallback, useRef } from 'react';

interface TypingUser {
  id: string;
  name: string;
}

export function useTypingIndicator(
  roomId: string,
  currentUserId: string,
  emit: (event: string, data: any) => void,
  on: (event: string, callback: (data: any) => void) => () => void
) {
  const [typingUsers, setTypingUsers] = useState<TypingUser[]>([]);
  const typingTimeoutRef = useRef<NodeJS.Timeout>();

  // Listen for typing events
  useEffect(() => {
    const unsubscribeTyping = on('user-typing', (user: TypingUser) => {
      if (user.id !== currentUserId) {
        setTypingUsers(prev => {
          if (prev.find(u => u.id === user.id)) return prev;
          return [...prev, user];
        });
      }
    });
    
    const unsubscribeStopTyping = on('user-stop-typing', (user: { id: string }) => {
      setTypingUsers(prev => prev.filter(u => u.id !== user.id));
    });
    
    return () => {
      unsubscribeTyping();
      unsubscribeStopTyping();
    };
  }, [on, currentUserId]);

  // Send typing indicator
  const startTyping = useCallback(() => {
    emit('typing', roomId);
    
    // Auto stop after 3 seconds
    if (typingTimeoutRef.current) {
      clearTimeout(typingTimeoutRef.current);
    }
    
    typingTimeoutRef.current = setTimeout(() => {
      emit('stop-typing', roomId);
    }, 3000);
  }, [emit, roomId]);

  const stopTyping = useCallback(() => {
    if (typingTimeoutRef.current) {
      clearTimeout(typingTimeoutRef.current);
    }
    emit('stop-typing', roomId);
  }, [emit, roomId]);

  return { typingUsers, startTyping, stopTyping };
}


// ==========================================
// components/TypingIndicator.tsx
// ==========================================

interface TypingIndicatorProps {
  users: { id: string; name: string }[];
}

export function TypingIndicator({ users }: TypingIndicatorProps) {
  if (users.length === 0) return null;
  
  const text = users.length === 1
    ? `${users[0].name} is typing...`
    : users.length === 2
      ? `${users[0].name} and ${users[1].name} are typing...`
      : `${users.length} people are typing...`;
  
  return (
    <div className="flex items-center gap-2 text-sm text-gray-500">
      <div className="flex gap-1">
        <span className="animate-bounce">.</span>
        <span className="animate-bounce delay-100">.</span>
        <span className="animate-bounce delay-200">.</span>
      </div>
      <span>{text}</span>
    </div>
  );
}
```

---

## Best Practices Checklist

### Technology
- [ ] Right tech for use case
- [ ] SSE for server → client
- [ ] WebSocket for bidirectional
- [ ] Managed service for scale

### Implementation
- [ ] Reconnection logic
- [ ] Error handling
- [ ] Connection status UI
- [ ] Graceful degradation

### Performance
- [ ] Message batching
- [ ] Payload optimization
- [ ] Connection pooling
- [ ] Heartbeat implemented

### Security
- [ ] Auth on connections
- [ ] Message validation
- [ ] Rate limiting
- [ ] Private channels

---

**References:**
- [Next.js Streaming](https://nextjs.org/docs/app/building-your-application/routing/loading-ui-and-streaming)
- [Socket.io](https://socket.io/docs/v4/)
- [Pusher](https://pusher.com/docs/)
- [Supabase Realtime](https://supabase.com/docs/guides/realtime)

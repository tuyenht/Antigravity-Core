# Message Queue & Async Messaging Expert

> **Version:** 1.0.0 | **Updated:** 2026-02-10
> **Standards:** BullMQ v5, RabbitMQ (AMQP 0-9-1), Redis Streams
> **Priority:** P1 - Load for message queue/event-driven projects

---

You are an expert in asynchronous messaging patterns, job queues, and event-driven architecture with TypeScript/Node.js.

## Key Principles

- Asynchronous by default — decouple producers from consumers
- At-least-once delivery with idempotent consumers
- Dead-letter queues for failed message handling
- Schema validation on message boundaries
- Observability: every message traceable end-to-end
- Horizontal scaling with consumer groups

---

## Technology Selection

```yaml
BullMQ (Redis-based):
  Best for:
    - Job queues, background processing
    - Delayed/scheduled jobs
    - Rate limiting, priority queues
    - Existing Redis infrastructure
  Limitations:
    - Redis is the bottleneck
    - No complex routing (exchanges)
    - Not ideal for cross-service pub/sub

RabbitMQ (AMQP):
  Best for:
    - Complex message routing (topic, fanout, headers)
    - Cross-service event distribution
    - Publish/subscribe patterns
    - Message acknowledgment and redelivery
  Limitations:
    - Operational complexity
    - Separate infrastructure to manage
    - Higher latency than Redis

Redis Streams:
  Best for:
    - Lightweight event streaming
    - Consumer groups without dedicated broker
    - Existing Redis infrastructure
    - Event sourcing with trimming
  Limitations:
    - Limited routing capabilities
    - No built-in dead-letter queue
    - Manual consumer group management
```

---

## Project Structure

```
src/
├── queues/
│   ├── registry.ts              # Queue registry & initialization
│   ├── definitions/             # Queue definitions
│   │   ├── email.queue.ts
│   │   ├── notification.queue.ts
│   │   └── report.queue.ts
│   ├── workers/                 # Job processors
│   │   ├── email.worker.ts
│   │   ├── notification.worker.ts
│   │   └── report.worker.ts
│   └── types/
│       └── jobs.ts              # Job payload types
├── events/
│   ├── bus.ts                   # Event bus abstraction
│   ├── handlers/                # Event handlers
│   │   ├── user-created.ts
│   │   └── order-completed.ts
│   └── types/
│       └── events.ts            # Event type definitions
├── middleware/
│   └── idempotency.ts
└── monitoring/
    └── bull-board.ts
```

---

## BullMQ Implementation

### Queue Setup
```typescript
// queues/registry.ts
import { Queue, QueueEvents } from 'bullmq';

const connection = {
  host: process.env.REDIS_HOST || 'localhost',
  port: parseInt(process.env.REDIS_PORT || '6379'),
  password: process.env.REDIS_PASSWORD,
  maxRetriesPerRequest: null,
};

// Queue registry — central place for all queues
export const queues = {
  email: new Queue('email', {
    connection,
    defaultJobOptions: {
      attempts: 3,
      backoff: { type: 'exponential', delay: 1000 },
      removeOnComplete: { count: 1000 },
      removeOnFail: { count: 5000 },
    },
  }),

  notification: new Queue('notification', {
    connection,
    defaultJobOptions: {
      attempts: 2,
      backoff: { type: 'fixed', delay: 5000 },
      removeOnComplete: { age: 3600 },
    },
  }),

  report: new Queue('report', {
    connection,
    defaultJobOptions: {
      attempts: 1,
      timeout: 300_000, // 5 min for heavy reports
      removeOnComplete: true,
    },
  }),
} as const;

// Queue events for monitoring
export const queueEvents = {
  email: new QueueEvents('email', { connection }),
  notification: new QueueEvents('notification', { connection }),
  report: new QueueEvents('report', { connection }),
};
```

### Typed Job Definitions
```typescript
// queues/types/jobs.ts
import { z } from 'zod';

// Email job schema
export const EmailJobSchema = z.discriminatedUnion('type', [
  z.object({
    type: z.literal('welcome'),
    to: z.string().email(),
    name: z.string(),
  }),
  z.object({
    type: z.literal('password-reset'),
    to: z.string().email(),
    resetToken: z.string(),
    expiresAt: z.number(),
  }),
  z.object({
    type: z.literal('order-confirmation'),
    to: z.string().email(),
    orderId: z.string(),
    items: z.array(z.object({
      name: z.string(),
      quantity: z.number(),
      price: z.number(),
    })),
  }),
]);

export type EmailJob = z.infer<typeof EmailJobSchema>;

// Notification job schema
export const NotificationJobSchema = z.object({
  userId: z.string(),
  title: z.string(),
  body: z.string(),
  channel: z.enum(['push', 'in-app', 'sms']),
  data: z.record(z.unknown()).optional(),
});

export type NotificationJob = z.infer<typeof NotificationJobSchema>;

// Report job schema
export const ReportJobSchema = z.object({
  userId: z.string(),
  reportType: z.enum(['sales', 'inventory', 'analytics']),
  dateRange: z.object({
    from: z.string(),
    to: z.string(),
  }),
  format: z.enum(['pdf', 'csv', 'xlsx']).default('pdf'),
});

export type ReportJob = z.infer<typeof ReportJobSchema>;
```

### Adding Jobs
```typescript
// Adding jobs to queues
import { queues } from './registry';
import { EmailJobSchema, type EmailJob } from './types/jobs';

// Type-safe job creation
async function sendEmail(data: EmailJob) {
  // Validate payload
  const validated = EmailJobSchema.parse(data);

  await queues.email.add(validated.type, validated, {
    // Per-job options override defaults
    priority: validated.type === 'password-reset' ? 1 : 5,
  });
}

// Delayed job (send in 5 minutes)
await queues.email.add('welcome', payload, {
  delay: 5 * 60 * 1000,
});

// Scheduled/recurring jobs
await queues.report.add(
  'daily-sales',
  { reportType: 'sales', dateRange: todayRange(), format: 'pdf', userId: 'system' },
  {
    repeat: {
      pattern: '0 9 * * *', // Every day at 9 AM
      tz: 'Asia/Ho_Chi_Minh',
    },
    jobId: 'daily-sales-report', // Prevent duplicates
  }
);

// Bulk add
await queues.notification.addBulk(
  userIds.map((userId) => ({
    name: 'broadcast',
    data: { userId, title: 'Update', body: 'New feature', channel: 'push' as const },
  }))
);
```

### Workers (Job Processors)
```typescript
// queues/workers/email.worker.ts
import { Worker, Job } from 'bullmq';
import { EmailJobSchema, type EmailJob } from '../types/jobs';

const emailWorker = new Worker<EmailJob>(
  'email',
  async (job: Job<EmailJob>) => {
    // Validate incoming data
    const data = EmailJobSchema.parse(job.data);

    // Update progress
    await job.updateProgress(10);

    switch (data.type) {
      case 'welcome':
        await sendWelcomeEmail(data.to, data.name);
        break;
      case 'password-reset':
        await sendPasswordResetEmail(data.to, data.resetToken);
        break;
      case 'order-confirmation':
        await sendOrderConfirmation(data.to, data.orderId, data.items);
        break;
    }

    await job.updateProgress(100);
    return { sent: true, to: data.to };
  },
  {
    connection,
    concurrency: 5, // Process 5 emails concurrently
    limiter: {
      max: 100,      // Max 100 jobs
      duration: 60_000, // Per minute (rate limiting)
    },
  }
);

// Event handlers
emailWorker.on('completed', (job) => {
  console.log(`Email sent: ${job.id} → ${job.returnvalue?.to}`);
});

emailWorker.on('failed', (job, error) => {
  console.error(`Email failed: ${job?.id}`, error.message);

  // Alert on final failure (all retries exhausted)
  if (job && job.attemptsMade >= (job.opts.attempts || 1)) {
    alertOps(`Email permanently failed: ${job.id}`, error);
  }
});

emailWorker.on('error', (error) => {
  console.error('Worker error:', error);
});

export { emailWorker };
```

### Flow (Job Dependencies)
```typescript
// BullMQ Flows — chain dependent jobs
import { FlowProducer } from 'bullmq';

const flow = new FlowProducer({ connection });

// Parent job waits for all children to complete
await flow.add({
  name: 'generate-report',
  queueName: 'report',
  data: { reportType: 'sales', userId: 'admin', dateRange: range, format: 'pdf' },
  children: [
    {
      name: 'fetch-sales-data',
      queueName: 'report',
      data: { source: 'sales', dateRange: range },
    },
    {
      name: 'fetch-inventory-data',
      queueName: 'report',
      data: { source: 'inventory', dateRange: range },
    },
  ],
});
```

---

## RabbitMQ Implementation

### Connection Setup
```typescript
// events/rabbitmq/connection.ts
import amqplib, { Connection, Channel } from 'amqplib';

let connection: Connection;
let channel: Channel;

export async function connectRabbitMQ() {
  connection = await amqplib.connect(
    process.env.RABBITMQ_URL || 'amqp://localhost:5672'
  );

  connection.on('error', (err) => {
    console.error('RabbitMQ connection error:', err);
  });

  connection.on('close', () => {
    console.warn('RabbitMQ connection closed, reconnecting...');
    setTimeout(connectRabbitMQ, 5000);
  });

  channel = await connection.createChannel();

  // Prefetch: process 10 messages at a time
  await channel.prefetch(10);

  return { connection, channel };
}

export function getChannel() {
  if (!channel) throw new Error('RabbitMQ not connected');
  return channel;
}
```

### Exchange & Queue Setup
```typescript
// events/rabbitmq/setup.ts
import { getChannel } from './connection';

export async function setupExchangesAndQueues() {
  const ch = getChannel();

  // Topic exchange for domain events
  await ch.assertExchange('domain.events', 'topic', { durable: true });

  // Dead-letter exchange
  await ch.assertExchange('domain.dlx', 'topic', { durable: true });

  // Queues with dead-letter routing
  await ch.assertQueue('user.notifications', {
    durable: true,
    arguments: {
      'x-dead-letter-exchange': 'domain.dlx',
      'x-dead-letter-routing-key': 'user.notifications.dlq',
      'x-message-ttl': 86_400_000, // 24h
    },
  });

  await ch.assertQueue('order.processing', {
    durable: true,
    arguments: {
      'x-dead-letter-exchange': 'domain.dlx',
      'x-dead-letter-routing-key': 'order.processing.dlq',
    },
  });

  // Dead-letter queues
  await ch.assertQueue('user.notifications.dlq', { durable: true });
  await ch.assertQueue('order.processing.dlq', { durable: true });

  // Bindings
  await ch.bindQueue('user.notifications', 'domain.events', 'user.*');
  await ch.bindQueue('order.processing', 'domain.events', 'order.*');

  // DLQ bindings
  await ch.bindQueue('user.notifications.dlq', 'domain.dlx', 'user.notifications.dlq');
  await ch.bindQueue('order.processing.dlq', 'domain.dlx', 'order.processing.dlq');
}
```

### Publishing Events
```typescript
// events/rabbitmq/publisher.ts
import { getChannel } from './connection';
import { z } from 'zod';

// Event schemas
const DomainEventSchema = z.object({
  id: z.string().uuid(),
  type: z.string(),
  timestamp: z.number(),
  source: z.string(),
  data: z.unknown(),
  metadata: z.object({
    correlationId: z.string().optional(),
    causationId: z.string().optional(),
  }).optional(),
});

type DomainEvent = z.infer<typeof DomainEventSchema>;

export async function publishEvent(
  routingKey: string,
  event: Omit<DomainEvent, 'id' | 'timestamp'>
) {
  const ch = getChannel();

  const fullEvent: DomainEvent = {
    ...event,
    id: crypto.randomUUID(),
    timestamp: Date.now(),
  };

  // Validate before publishing
  DomainEventSchema.parse(fullEvent);

  ch.publish(
    'domain.events',
    routingKey,
    Buffer.from(JSON.stringify(fullEvent)),
    {
      persistent: true,             // Survive broker restart
      contentType: 'application/json',
      messageId: fullEvent.id,
      timestamp: fullEvent.timestamp,
      headers: {
        'x-correlation-id': event.metadata?.correlationId,
      },
    }
  );
}

// Usage
await publishEvent('user.created', {
  type: 'UserCreated',
  source: 'user-service',
  data: { userId: '123', email: 'user@example.com' },
  metadata: { correlationId: requestId },
});

await publishEvent('order.completed', {
  type: 'OrderCompleted',
  source: 'order-service',
  data: { orderId: '456', total: 99.99 },
});
```

### Consuming Events
```typescript
// events/rabbitmq/consumer.ts
import { getChannel } from './connection';

export async function consumeQueue(
  queue: string,
  handler: (event: DomainEvent) => Promise<void>,
  options: { maxRetries?: number } = {}
) {
  const ch = getChannel();
  const { maxRetries = 3 } = options;

  await ch.consume(queue, async (msg) => {
    if (!msg) return;

    const retryCount = (msg.properties.headers?.['x-retry-count'] as number) || 0;

    try {
      const event = JSON.parse(msg.content.toString()) as DomainEvent;

      // Idempotency check
      const processed = await isEventProcessed(event.id);
      if (processed) {
        ch.ack(msg);
        return;
      }

      await handler(event);

      // Mark as processed
      await markEventProcessed(event.id);

      ch.ack(msg);
    } catch (error) {
      console.error(`Error processing message from ${queue}:`, error);

      if (retryCount >= maxRetries) {
        // Send to DLQ (reject without requeue)
        ch.reject(msg, false);
      } else {
        // Retry with delay using DLX + TTL trick
        ch.reject(msg, false);
        // Or: nack with requeue for simple retry
        // ch.nack(msg, false, true);
      }
    }
  });
}

// Usage
await consumeQueue('user.notifications', async (event) => {
  switch (event.type) {
    case 'UserCreated':
      await sendWelcomeNotification(event.data);
      break;
    case 'UserUpdated':
      await syncUserProfile(event.data);
      break;
  }
});
```

---

## Event-Driven Patterns

### Event Bus Abstraction
```typescript
// events/bus.ts
// Technology-agnostic event bus

interface EventBus {
  publish(routingKey: string, event: Omit<DomainEvent, 'id' | 'timestamp'>): Promise<void>;
  subscribe(pattern: string, handler: (event: DomainEvent) => Promise<void>): Promise<void>;
}

// BullMQ implementation
class BullMQEventBus implements EventBus {
  async publish(routingKey: string, event: any) {
    await queues.events.add(routingKey, {
      ...event,
      id: crypto.randomUUID(),
      timestamp: Date.now(),
    });
  }

  async subscribe(pattern: string, handler: (event: DomainEvent) => Promise<void>) {
    new Worker('events', async (job) => {
      if (matchPattern(pattern, job.name)) {
        await handler(job.data);
      }
    }, { connection });
  }
}

// RabbitMQ implementation
class RabbitMQEventBus implements EventBus {
  async publish(routingKey: string, event: any) {
    await publishEvent(routingKey, event);
  }

  async subscribe(pattern: string, handler: (event: DomainEvent) => Promise<void>) {
    const ch = getChannel();
    const q = await ch.assertQueue('', { exclusive: true });
    await ch.bindQueue(q.queue, 'domain.events', pattern);
    await consumeQueue(q.queue, handler);
  }
}

// Factory
export function createEventBus(): EventBus {
  if (process.env.MESSAGE_BROKER === 'rabbitmq') {
    return new RabbitMQEventBus();
  }
  return new BullMQEventBus();
}
```

### Saga Pattern
```typescript
// patterns/saga.ts
// Coordinate multi-step processes across services

interface SagaStep<T> {
  name: string;
  execute: (context: T) => Promise<T>;
  compensate: (context: T) => Promise<void>;
}

class Saga<T extends Record<string, unknown>> {
  private steps: SagaStep<T>[] = [];

  addStep(step: SagaStep<T>) {
    this.steps.push(step);
    return this;
  }

  async execute(initialContext: T): Promise<T> {
    let context = { ...initialContext };
    const completedSteps: SagaStep<T>[] = [];

    for (const step of this.steps) {
      try {
        context = await step.execute(context);
        completedSteps.push(step);
      } catch (error) {
        console.error(`Saga step "${step.name}" failed:`, error);

        // Compensate in reverse order
        for (const completed of completedSteps.reverse()) {
          try {
            await completed.compensate(context);
          } catch (compError) {
            console.error(
              `Compensation failed for "${completed.name}":`,
              compError
            );
          }
        }

        throw new SagaError(step.name, error as Error, completedSteps);
      }
    }

    return context;
  }
}

// Usage: Order processing saga
const orderSaga = new Saga<OrderContext>()
  .addStep({
    name: 'reserve-inventory',
    execute: async (ctx) => {
      const reservation = await inventoryService.reserve(ctx.items);
      return { ...ctx, reservationId: reservation.id };
    },
    compensate: async (ctx) => {
      if (ctx.reservationId) {
        await inventoryService.release(ctx.reservationId);
      }
    },
  })
  .addStep({
    name: 'charge-payment',
    execute: async (ctx) => {
      const payment = await paymentService.charge(ctx.amount, ctx.paymentMethod);
      return { ...ctx, paymentId: payment.id };
    },
    compensate: async (ctx) => {
      if (ctx.paymentId) {
        await paymentService.refund(ctx.paymentId);
      }
    },
  })
  .addStep({
    name: 'create-order',
    execute: async (ctx) => {
      const order = await orderService.create(ctx);
      return { ...ctx, orderId: order.id };
    },
    compensate: async (ctx) => {
      if (ctx.orderId) {
        await orderService.cancel(ctx.orderId);
      }
    },
  });

// Execute
await orderSaga.execute({
  userId: 'user-123',
  items: [{ productId: 'prod-1', quantity: 2 }],
  amount: 49.99,
  paymentMethod: 'card_xxx',
});
```

---

## Idempotency

```typescript
// middleware/idempotency.ts
import { Redis } from 'ioredis';

const redis = new Redis(process.env.REDIS_URL);

/**
 * Ensure a job/event is processed exactly once.
 * Uses Redis SET NX with TTL for distributed locking.
 */
export async function isEventProcessed(eventId: string): Promise<boolean> {
  const key = `idempotency:${eventId}`;
  const exists = await redis.exists(key);
  return exists === 1;
}

export async function markEventProcessed(
  eventId: string,
  ttlSeconds = 86_400 // 24 hours
): Promise<void> {
  const key = `idempotency:${eventId}`;
  await redis.set(key, Date.now().toString(), 'EX', ttlSeconds);
}

// Idempotency wrapper for handlers
export function idempotent(
  handler: (event: DomainEvent) => Promise<void>
): (event: DomainEvent) => Promise<void> {
  return async (event) => {
    if (await isEventProcessed(event.id)) {
      console.log(`Skipping duplicate event: ${event.id}`);
      return;
    }

    await handler(event);
    await markEventProcessed(event.id);
  };
}

// Usage
await consumeQueue('order.processing', idempotent(async (event) => {
  await processOrder(event.data);
}));
```

---

## Monitoring

### Bull Board (Dashboard)
```typescript
// monitoring/bull-board.ts
import { createBullBoard } from '@bull-board/api';
import { BullMQAdapter } from '@bull-board/api/bullMQAdapter';
import { ExpressAdapter } from '@bull-board/express';
import { queues } from '../queues/registry';

export function setupBullBoard(app: express.Application) {
  const serverAdapter = new ExpressAdapter();
  serverAdapter.setBasePath('/admin/queues');

  createBullBoard({
    queues: Object.values(queues).map((q) => new BullMQAdapter(q)),
    serverAdapter,
  });

  // Protect with auth middleware
  app.use('/admin/queues', requireAdmin, serverAdapter.getRouter());
}
```

### Metrics
```typescript
// monitoring/metrics.ts
import { queues, queueEvents } from '../queues/registry';

// Collect queue metrics
async function getQueueMetrics() {
  const metrics: Record<string, unknown> = {};

  for (const [name, queue] of Object.entries(queues)) {
    const counts = await queue.getJobCounts(
      'waiting', 'active', 'completed', 'failed', 'delayed'
    );

    metrics[name] = {
      ...counts,
      isPaused: await queue.isPaused(),
    };
  }

  return metrics;
}

// Health check endpoint
app.get('/health/queues', async (req, res) => {
  const metrics = await getQueueMetrics();

  const unhealthy = Object.entries(metrics).filter(
    ([, m]: [string, any]) => m.failed > 100 || m.waiting > 10_000
  );

  res.status(unhealthy.length > 0 ? 503 : 200).json({
    status: unhealthy.length > 0 ? 'degraded' : 'healthy',
    queues: metrics,
  });
});
```

---

## Testing

### BullMQ Testing
```typescript
// tests/email.worker.test.ts
import { Queue, Worker, Job } from 'bullmq';
import IORedis from 'ioredis';

describe('Email Worker', () => {
  const connection = new IORedis({ maxRetriesPerRequest: null });
  let queue: Queue;

  beforeAll(async () => {
    queue = new Queue('test-email', { connection });
  });

  afterAll(async () => {
    await queue.close();
    await connection.quit();
  });

  afterEach(async () => {
    await queue.drain();
  });

  test('processes welcome email', async () => {
    const sendSpy = jest.spyOn(emailService, 'send');

    const job = await queue.add('welcome', {
      type: 'welcome',
      to: 'user@test.com',
      name: 'Test User',
    });

    // Wait for job completion
    await job.waitUntilFinished(queueEvents);

    expect(sendSpy).toHaveBeenCalledWith(
      expect.objectContaining({ to: 'user@test.com' })
    );
  });

  test('retries on transient failure', async () => {
    const sendSpy = jest.spyOn(emailService, 'send')
      .mockRejectedValueOnce(new Error('Transient'))
      .mockResolvedValueOnce(undefined);

    const job = await queue.add('welcome', {
      type: 'welcome',
      to: 'user@test.com',
      name: 'Test User',
    });

    await job.waitUntilFinished(queueEvents);
    expect(sendSpy).toHaveBeenCalledTimes(2);
  });
});
```

### RabbitMQ Testing
```typescript
// tests/events.test.ts
// Use testcontainers for integration tests

import { GenericContainer, StartedTestContainer } from 'testcontainers';

describe('RabbitMQ Events', () => {
  let container: StartedTestContainer;

  beforeAll(async () => {
    container = await new GenericContainer('rabbitmq:3-management')
      .withExposedPorts(5672)
      .start();

    process.env.RABBITMQ_URL =
      `amqp://localhost:${container.getMappedPort(5672)}`;

    await connectRabbitMQ();
    await setupExchangesAndQueues();
  }, 30_000);

  afterAll(async () => {
    await container.stop();
  });

  test('publishes and consumes event', async () => {
    const received: DomainEvent[] = [];

    await consumeQueue('user.notifications', async (event) => {
      received.push(event);
    });

    await publishEvent('user.created', {
      type: 'UserCreated',
      source: 'test',
      data: { userId: 'test-1' },
    });

    // Wait for message processing
    await new Promise((r) => setTimeout(r, 1000));

    expect(received).toHaveLength(1);
    expect(received[0].type).toBe('UserCreated');
  });
});
```

---

## Security

```yaml
Transport:
  - Use TLS for Redis/RabbitMQ connections in production
  - Authenticate all broker connections (password/certificate)
  - Network isolation: broker in private subnet

Messages:
  - Validate all message payloads with Zod schemas
  - Don't put sensitive data in messages (use references)
  - Encrypt sensitive payloads if needed (AES-256-GCM)

Access:
  - Use separate credentials per service/consumer
  - RabbitMQ vhosts for tenant isolation
  - Restrict queue/exchange permissions per user

Operational:
  - Set message TTL to prevent queue overflow
  - Monitor queue depth and set alerts
  - Implement circuit breakers for consumers
  - Test DLQ handling regularly
```

---

## Anti-Patterns

```yaml
❌ DON'T:
  - Process messages without idempotency checks
  - Skip dead-letter queues (failed messages vanish)
  - Put large payloads in messages (use references/URLs)
  - Create unlimited retry loops (set max attempts)
  - Share connections across workers (use per-worker pools)
  - Ignore backpressure (set prefetch/concurrency limits)
  - Use message queues for synchronous request/response
  - Skip schema validation on message boundaries

✅ DO:
  - Use idempotency keys for at-least-once delivery
  - Implement dead-letter queues for error handling
  - Validate message schemas at producer AND consumer
  - Set appropriate TTL and retention policies
  - Monitor queue depth, failure rate, processing time
  - Use consumer groups for horizontal scaling
  - Implement saga pattern for distributed transactions
  - Test failure scenarios (broker down, consumer crash)
```

---

## See Also

- [grpc.md](grpc.md) — Synchronous service-to-service communication
- [websocket.md](websocket.md) — Real-time bidirectional streaming
- [sse.md](sse.md) — Server-to-client push notifications

---

**Version:** 1.0.0
**Standards:** BullMQ v5, AMQP 0-9-1, Redis Streams
**Created:** 2026-02-10

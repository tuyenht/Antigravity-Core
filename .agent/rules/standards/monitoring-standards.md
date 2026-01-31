# Monitoring & Observability Standards

**Version:** 1.0  
**Updated:** 2026-01-16

---

## Three Pillars of Observability

1. **Logs** - What happened
2. **Metrics** - How much/how many
3. **Traces** - Where time was spent

---

## 1. Structured Logging

```javascript
// ✅ Structured JSON logs
logger.info('User logged in', {
  userId: user.id,
  email: user.email,
  ip: request.ip,
  timestamp: new Date().toISOString(),
  sessionId: session.id
});

// ❌ Unstructured logs
console.log(`User ${user.id} logged in from ${request.ip}`);
```

### Log Levels
- **ERROR:** Application errors (500s)
- **WARN:** Degraded state (429s, deprecated API)
- **INFO:** Business events (login, purchase)
- **DEBUG:** Development debugging

---

## 2. Metrics Collection

### Prometheus Format
```javascript
// Counter - monotonically increasing
httpRequestsTotal.inc({ method: 'GET', path: '/api/users', status: 200 });

// Gauge - can go up/down
activeUsers.set(150);

// Histogram - distribution
responseTime.observe(0.234); // seconds
```

### Key Metrics (RED Method)
- **Rate:** Requests per second
- **Errors:** Error rate
- **Duration:** Response time (p50, p95, p99)

---

## 3. Distributed Tracing

### OpenTelemetry Example
```javascript
import { trace } from '@opentelemetry/api';

const tracer = trace.getTracer('my-app');

async function processOrder(orderId) {
  const span = tracer.startSpan('processOrder');
  
  try {
    span.setAttribute('order.id', orderId);
    
    // Child span
    await tracer.startActiveSpan('validateOrder', async (childSpan) => {
      await validateOrder(orderId);
      childSpan.end();
    });
    
    span.setStatus({ code: SpanStatusCode.OK });
  } catch (error) {
    span.recordException(error);
    span.setStatus({ code: SpanStatusCode.ERROR });
    throw error;
  } finally {
    span.end();
  }
}
```

---

## 4. Health Checks

```javascript
// /health endpoint
app.get('/health', async (req, res) => {
  const health = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    checks: {
      database: await checkDatabase(),
      redis: await checkRedis(),
      externalAPI: await checkExternalAPI()
    }
  };
  
  const allHealthy = Object.values(health.checks).every(c => c.status === 'ok');
  
  res.status(allHealthy ? 200 : 503).json(health);
});
```

---

## 5. Error Tracking (Sentry)

```javascript
import * as Sentry from '@sentry/node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 0.1, // 10% of transactions
});

// Capture exception with context
try {
  await processPayment(payment);
} catch (error) {
  Sentry.captureException(error, {
    tags: { payment_method: payment.method },
    user: { id: user.id, email: user.email },
    extra: { paymentAmount: payment.amount }
  });
  throw error;
}
```

---

## 6. SLA/SLO Definitions

```yaml
# Service Level Objectives
slos:
  - name: API Availability
    target: 99.9%
    window: 30d
    
  - name: API Latency (p95)
    target: < 200ms
    window: 30d
    
  - name: Error Rate
    target: < 0.1%
    window: 7d
```

---

**References:**
- [OpenTelemetry](https://opentelemetry.io/)
- [Prometheus](https://prometheus.io/)
- [Sentry](https://sentry.io/)

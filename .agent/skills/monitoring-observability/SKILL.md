---
name: Monitoring & Observability
description: "Thiết kế hệ thống giám sát production, logging, metrics và quan sát (Observability)."
category: DevOps & Operations
difficulty: Advanced
last_updated: 2026-01-16
---

# Monitoring & Observability

Expert patterns for production observability: logs, metrics, traces, và SLO/SLI/SLA.

---

## When to Use This Skill

- Production system monitoring
- Performance troubleshooting
- Incident response
- SLO/SLI definition
- Distributed tracing
- Alert management

---

## Content Map

### Three Pillars
- **logging.md** - Structured logs, ELK, Loki
- **metrics.md** - Prometheus, Grafana, InfluxDB
- **tracing.md** - Jaeger, Zipkin, OpenTelemetry

### Tools
- **prometheus.md** - Metrics collection, PromQL
- **grafana.md** - Dashboards, visualization
- **elk-stack.md** - Elasticsearch, Logstash, Kibana
- **opentelemetry.md** - Unified observability

### Best Practices
- **slo-sli-sla.md** - Service level objectives
- **alerting.md** - Alert strategies, on-call
- **incident-response.md** - Runbooks, post-mortems

---

## Quick Reference

### Three Pillars of Observability

```
1. LOGS (Events)
   → What happened? When? Context?
   → Use: Debugging, audit trails
   
2. METRICS (Numbers)
   → How much? How fast? How many?
   → Use: Dashboards, alerts, trends
   
3. TRACES (Requests)
   → Where did request go? How long?
   → Use: Distributed systems, latency
```

---

### Prometheus Metrics

```yaml
# Prometheus config
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'web-app'
    static_configs:
      - targets: ['localhost:8080']
```

```javascript
// Node.js instrumentation
const client = require('prom-client');

// Create metrics
const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code']
});

const activeConnections = new client.Gauge({
  name: 'active_connections',
  help: 'Number of active connections'
});

// Instrument
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration
      .labels(req.method, req.route.path, res.statusCode)
      .observe(duration);
  });
  
  next();
});

// Expose metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});
```

---

### Structured Logging

```javascript
// ✅ Good - Structured
const winston = require('winston');

const logger = winston.createLogger({
  format: winston.format.json(),
  transports: [
    new winston.transports.Console()
  ]
});

logger.info('User login', {
  userId: '123',
  email: 'user@example.com',
  ip: '192.168.1.1',
  timestamp: new Date().toISOString()
});

// Output: {"level":"info","message":"User login","userId":"123",...}
```

```javascript
// ❌ Bad - Unstructured
console.log('User 123 logged in from 192.168.1.1');
```

---

### Distributed Tracing (OpenTelemetry)

```javascript
const { NodeTracerProvider } = require('@opentelemetry/sdk-trace-node');
const { registerInstrumentations } = require('@opentelemetry/instrumentation');
const { HttpInstrumentation } = require('@opentelemetry/instrumentation-http');
const { JaegerExporter } = require('@opentelemetry/exporter-jaeger');

// Setup tracer
const provider = new NodeTracerProvider();
const exporter = new JaegerExporter({
  endpoint: 'http://localhost:14268/api/traces'
});

provider.addSpanProcessor(new BatchSpanProcessor(exporter));
provider.register();

// Auto-instrument HTTP
registerInstrumentations({
  instrumentations: [
    new HttpInstrumentation()
  ]
});

// Manual span
const tracer = provider.getTracer('my-app');

async function processOrder(orderId) {
  const span = tracer.startSpan('process-order');
  span.setAttribute('order.id', orderId);
  
  try {
    await validateOrder(orderId);
    await chargePayment(orderId);
    span.setStatus({ code: SpanStatusCode.OK });
  } catch (error) {
    span.recordException(error);
    span.setStatus({ code: SpanStatusCode.ERROR });
  } finally {
    span.end();
  }
}
```

---

### SLO/SLI/SLA Definitions

```yaml
# Service Level Indicators (SLI) - What to measure
sli:
  availability:
    query: |
      sum(rate(http_requests_total{status=~"2.."}[5m]))
      /
      sum(rate(http_requests_total[5m]))
  
  latency_p99:
    query: |
      histogram_quantile(0.99, 
        rate(http_request_duration_seconds_bucket[5m])
      )

# Service Level Objectives (SLO) - Target
slo:
  availability: 99.9%    # 43.2 minutes downtime/month
  latency_p99: 500ms     # 99% of requests < 500ms

# Service Level Agreement (SLA) - Contract with users
sla:
  availability: 99.5%
  penalty: "10% refund if violated"
```

---

### Grafana Dashboard (JSON)

```json
{
  "dashboard": {
    "title": "Application Metrics",
    "panels": [
      {
        "title": "Request Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])"
          }
        ],
        "type": "graph"
      },
      {
        "title": "Error Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total{status=~\"5..\"}[5m])"
          }
        ],
        "type": "graph"
      },
      {
        "title": "P99 Latency",
        "targets": [
          {
            "expr": "histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))"
          }
        ],
        "type": "graph"
      }
    ]
  }
}
```

---

### Alerting Rules (Prometheus)

```yaml
# alerting_rules.yml
groups:
  - name: app_alerts
    interval: 30s
    rules:
      # High error rate
      - alert: HighErrorRate
        expr: |
          rate(http_requests_total{status=~"5.."}[5m])
          /
          rate(http_requests_total[5m])
          > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }}%"
      
      # High latency
      - alert: HighLatency
        expr: |
          histogram_quantile(0.99,
            rate(http_request_duration_seconds_bucket[5m])
          ) > 1
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High latency detected"
          description: "P99 latency is {{ $value }}s"
      
      # Low availability
      - alert: ServiceDown
        expr: up{job="web-app"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service is down"
```

---

### Error Budget

```
Error Budget Calculation:

SLO: 99.9% availability
Error Budget: 100% - 99.9% = 0.1%

Monthly:
- Total time: 30 days = 43,200 minutes
- Error budget: 43,200 × 0.1% = 43.2 minutes

If errors exceed 43.2 minutes/month:
→ STOP feature development
→ Focus on reliability
→ Review incidents
```

---

### ELK Stack (Elasticsearch, Logstash, Kibana)

```yaml
# Logstash pipeline config
input {
  beats {
    port => 5044
  }
}

filter {
  json {
    source => "message"
  }
  
  date {
    match => ["timestamp", "ISO8601"]
  }
}

output {
  elasticsearch {
    hosts => ["localhost:9200"]
    index => "app-logs-%{+YYYY.MM.dd}"
  }
}
```

```javascript
// Application logging to ELK
const winston = require('winston');
const { ElasticsearchTransport } = require('winston-elasticsearch');

const logger = winston.createLogger({
  transports: [
    new ElasticsearchTransport({
      level: 'info',
      clientOpts: { node: 'http://localhost:9200' },
      index: 'app-logs'
    })
  ]
});

logger.info('Order processed', {
  orderId: '123',
  amount: 99.99,
  userId: 'user-456'
});
```

---

## Anti-Patterns

❌ **Logging everything** → Too much noise, high cost  
❌ **No structured logs** → Can't query efficiently  
❌ **Alert on everything** → Alert fatigue  
❌ **No SLOs defined** → Can't measure success  
❌ **Metrics without labels** → Can't slice data  
❌ **No distributed tracing** → Can't debug microservices

---

## Best Practices

✅ **Structured logging** (JSON format)  
✅ **Four golden signals** (Latency, Traffic, Errors, Saturation)  
✅ **SLO-based alerting** - Alert on error budget burn  
✅ **Distributed tracing** - For microservices  
✅ **Correlation IDs** - Track requests across services  
✅ **Dashboards for humans** - Clear, actionable  
✅ **Runbooks for alerts** - What to do when it fires

---

### Four Golden Signals

```
1. LATENCY
   → How long does it take?
   → Metric: P50, P95, P99 response time

2. TRAFFIC
   → How much demand?
   → Metric: Requests per second

3. ERRORS
   → What's failing?
   → Metric: Error rate (%)

4. SATURATION
   → How full is it?
   → Metric: CPU, memory, disk usage
```

---

## Related Skills

- `performance-profiling` - Application profiling
- `kubernetes-patterns` - Container metrics
- `microservices-communication` - Distributed tracing

---

## Official Resources

- [Prometheus](https://prometheus.io/)
- [Grafana](https://grafana.com/)
- [OpenTelemetry](https://opentelemetry.io/)
- [ELK Stack](https://www.elastic.co/elastic-stack)
- [Google SRE Book](https://sre.google/books/)

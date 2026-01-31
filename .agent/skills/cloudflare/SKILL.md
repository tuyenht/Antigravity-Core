---
name: cloudflare
description: Comprehensive Cloudflare platform skill covering Workers, Pages, storage (KV, D1, R2), AI (Workers AI, Vectorize, Agents SDK), networking (Tunnel, Spectrum), security (WAF, DDoS), and infrastructure-as-code (Terraform, Pulumi). Use for any Cloudflare development task.
category: Cloud Platform & Edge Computing
difficulty: Advanced
last_updated: 2026-01-16
---

# Cloudflare Platform Skill

Comprehensive skill for building on the Cloudflare edge platform. Covers 60+ products including serverless compute, storage, AI/ML, networking, and security.

---

## When to Use This Skill

- Building edge/serverless applications
- Implementing Cloudflare Workers or Pages
- Using Cloudflare storage (KV, D1, R2)
- Integrating Workers AI or Vectorize
- Setting up Cloudflare Tunnel or networking
- Implementing WAF, DDoS protection
- Managing infrastructure with Terraform/Pulumi

---

## Quick Decision Trees

### "I need to run code"

```
Need to run code?
├─ Serverless functions at the edge → Cloudflare Workers
├─ Full-stack web app with Git deploys → Cloudflare Pages
├─ Stateful coordination/real-time → Durable Objects
├─ Long-running multi-step jobs → Workflows
├─ Run containers → Cloudflare Containers
├─ Multi-tenant (customers deploy code) → Workers for Platforms
└─ Scheduled tasks (cron) → Cron Triggers
```

### "I need to store data"

```
Need storage?
├─ Key-value (config, sessions, cache) → KV
├─ Relational SQL → D1 (SQLite) or Hyperdrive (Postgres/MySQL)
├─ Object/file storage (S3-compatible) → R2
├─ Message queue (async processing) → Queues
├─ Vector embeddings (AI/semantic search) → Vectorize
├─ Strongly-consistent per-entity state → Durable Objects Storage
├─ Secrets management → Secrets Store
└─ Streaming ETL to R2 → Pipelines
```

### "I need AI/ML"

```
Need AI?
├─ Run inference (LLMs, embeddings, images) → Workers AI
├─ Vector database for RAG/search → Vectorize
├─ Build stateful AI agents → Agents SDK
├─ Gateway for any AI provider (caching, routing) → AI Gateway
└─ AI-powered search widget → AI Search
```

### "I need security"

```
Need security?
├─ Web Application Firewall → WAF
├─ DDoS protection → DDoS Protection
├─ Bot detection/management → Bot Management
├─ API protection → API Shield
├─ CAPTCHA alternative → Turnstile
└─ Credential leak detection → WAF (managed ruleset)
```

---

## Core Products

### Cloudflare Workers

**Serverless functions at the edge**

```javascript
// Basic Worker
export default {
  async fetch(request, env, ctx) {
    return new Response('Hello from Cloudflare Workers!');
  }
};

// With KV storage
export default {
  async fetch(request, env, ctx) {
    const value = await env.MY_KV.get('key');
    return new Response(value);
  }
};

// With D1 database
export default {
  async fetch(request, env, ctx) {
    const { results } = await env.DB.prepare(
      'SELECT * FROM users WHERE id = ?'
    ).bind(1).all();
    
    return Response.json(results);
  }
};
```

**wrangler.toml:**
```toml
name = "my-worker"
main = "src/index.js"
compatibility_date = "2024-01-01"

[[kv_namespaces]]
binding = "MY_KV"
id = "your-kv-id"

[[d1_databases]]
binding = "DB"
database_name = "my-database"
database_id = "your-db-id"
```

---

### Cloudflare Pages

**Full-stack web apps với Git integration**

```javascript
// pages/functions/api/users.js
export async function onRequest(context) {
  const { env, request } = context;
  
  // Access D1
  const users = await env.DB.prepare('SELECT * FROM users').all();
  
  return Response.json(users.results);
}
```

---

### D1 (SQL Database)

**SQLite at the edge**

```javascript
// Query
const results = await env.DB.prepare(
  'SELECT * FROM users WHERE email = ?'
).bind('user@example.com').all();

// Transaction
const info = await env.DB.batch([
  env.DB.prepare('INSERT INTO users (name) VALUES (?)').bind('Alice'),
  env.DB.prepare('INSERT INTO users (name) VALUES (?)').bind('Bob')
]);

// Migration
await env.DB.exec(`
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE
  )
`);
```

---

### KV (Key-Value Storage)

**Global, low-latency key-value store**

```javascript
// Write
await env.MY_KV.put('key', 'value', {
  expirationTtl: 3600, // 1 hour
  metadata: { userId: '123' }
});

// Read
const value = await env.MY_KV.get('key');
const valueWithMetadata = await env.MY_KV.getWithMetadata('key');

// List
const list = await env.MY_KV.list({ prefix: 'user:' });

// Delete
await env.MY_KV.delete('key');
```

---

### R2 (Object Storage)

**S3-compatible object storage, zero egress fees**

```javascript
// Upload
await env.MY_BUCKET.put('file.txt', 'Hello World', {
  httpMetadata: {
    contentType: 'text/plain'
  }
});

// Download
const object = await env.MY_BUCKET.get('file.txt');
const text = await object.text();

// List
const list = await env.MY_BUCKET.list({ prefix: 'images/' });

// Delete
await env.MY_BUCKET.delete('file.txt');
```

---

### Durable Objects

**Stateful, strongly-consistent coordination**

```javascript
// Durable Object class
export class Counter {
  constructor(state, env) {
    this.state = state;
  }

  async fetch(request) {
    let count = (await this.state.storage.get('count')) || 0;
    count++;
    await this.state.storage.put('count', count);
    
    return new Response(count.toString());
  }
}

// Worker using DO
export default {
  async fetch(request, env) {
    const id = env.COUNTER.idFromName('global');
    const stub = env.COUNTER.get(id);
    return stub.fetch(request);
  }
};
```

---

### Workers AI

**Run AI models at the edge**

```javascript
// Text generation
const response = await env.AI.run(
  '@cf/meta/llama-2-7b-chat-int8',
  {
    messages: [
      { role: 'user', content: 'What is Cloudflare?' }
    ]
  }
);

// Text embeddings
const embeddings = await env.AI.run(
  '@cf/baai/bge-base-en-v1.5',
  { text: 'Hello world' }
);

// Image classification
const result = await env.AI.run(
  '@cf/microsoft/resnet-50',
  { image: imageData }
);
```

---

### Vectorize

**Vector database for AI/ML**

```javascript
// Insert vectors
const vectors = [
  { id: '1', values: [0.1, 0.2, 0.3], metadata: { text: 'doc 1' } },
  { id: '2', values: [0.4, 0.5, 0.6], metadata: { text: 'doc 2' } }
];

await env.VECTORIZE.upsert(vectors);

// Query
const matches = await env.VECTORIZE.query([0.1, 0.2, 0.3], {
  topK: 5,
  returnMetadata: true
});
```

---

### Queues

**Message queue for async processing**

```javascript
// Send message
await env.MY_QUEUE.send({
  userId: '123',
  action: 'process'
});

// Batch send
await env.MY_QUEUE.sendBatch([
  { body: { action: 'email' } },
  { body: { action: 'notify' } }
]);

// Consumer
export default {
  async queue(batch, env) {
    for (const message of batch.messages) {
      console.log('Processing:', message.body);
      message.ack();
    }
  }
};
```

---

## Infrastructure as Code

### Terraform

```hcl
# Worker
resource "cloudflare_worker_script" "my_worker" {
  account_id = var.account_id
  name       = "my-worker"
  content    = file("worker.js")
}

# KV Namespace
resource "cloudflare_workers_kv_namespace" "my_kv" {
  account_id = var.account_id
  title      = "My KV"
}

# D1 Database
resource "cloudflare_d1_database" "my_db" {
  account_id = var.account_id
  name       = "my-database"
}

# R2 Bucket
resource "cloudflare_r2_bucket" "my_bucket" {
  account_id = var.account_id
  name       = "my-bucket"
}
```

---

## Security Products

### WAF (Web Application Firewall)

```javascript
// Custom WAF rule
if (request.headers.get('User-Agent').includes('bot')) {
  return new Response('Blocked', { status: 403 });
}
```

### Turnstile (CAPTCHA Alternative)

```html
<!-- Frontend -->
<div class="cf-turnstile" data-sitekey="your-site-key"></div>
<script src="https://challenges.cloudflare.com/turnstile/v0/api.js"></script>
```

```javascript
// Backend verification
const response = await fetch(
  'https://challenges.cloudflare.com/turnstile/v0/siteverify',
  {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      secret: env.TURNSTILE_SECRET,
      response: token
    })
  }
);

const outcome = await response.json();
if (outcome.success) {
  // Verified
}
```

---

## Best Practices

✅ **Use bindings** - KV, D1, R2, Queues via env, not fetch  
✅ **Cache strategically** - KV for cache, CF cache API  
✅ **Minimize cold starts** - Keep Workers small  
✅ **Use Durable Objects wisely** - For coordination, not general storage  
✅ **Leverage edge** - Compute close to users  
✅ **Monitor costs** - Watch KV reads, R2 operations  
✅ **Use wrangler** - Local development, deployment

---

## Anti-Patterns

❌ **Long-running Workers** → Use Workflows or Queues  
❌ **KV as primary database** → Use D1 for relational data  
❌ **Large Worker bundles** → Increases cold start time  
❌ **Storing secrets in code** → Use env vars or Secrets Store  
❌ **Not using bindings** → Fetch to KV/D1 slower  
❌ **Blocking on I/O** → Use async/await, Promise.all

---

## Product Coverage (60+ Products)

**Compute:** Workers, Pages, Durable Objects, Workflows, Containers  
**Storage:** KV, D1, R2, Queues, Hyperdrive, Pipelines  
**AI/ML:** Workers AI, Vectorize, Agents SDK, AI Gateway  
**Networking:** Tunnel, Spectrum, TURN, VPC  
**Security:** WAF, DDoS, Bot Management, API Shield, Turnstile  
**Media:** Images, Stream, Browser Rendering  
**Developer Tools:** Wrangler, Miniflare, C3, Analytics  
**IaC:** Terraform, Pulumi, API

---

## Related Skills

- `microservices-communication` - Service architecture
- `vector-databases` - AI/ML patterns
- `terraform-iac` - Infrastructure management
- `monitoring-observability` - Production monitoring

---

## Official Resources

- [Cloudflare Docs](https://developers.cloudflare.com/)
- [Workers Docs](https://developers.cloudflare.com/workers/)
- [D1 Docs](https://developers.cloudflare.com/d1/)
- [R2 Docs](https://developers.cloudflare.com/r2/)
- [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/)

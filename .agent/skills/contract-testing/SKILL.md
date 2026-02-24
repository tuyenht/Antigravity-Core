---
name: Contract Testing
description: Expert patterns for API contract testing, consumer-driven contracts, Pact framework, and contract validation in microservices
category: Testing & Quality
difficulty: Advanced
last_updated: 2026-01-16
---

# Contract Testing

> [!NOTE]
> **Consolidated:** This skill is part of `testing-mastery`. For the full unified skill, see `@[skills/testing-mastery]`.

Expert patterns for API contract testing và consumer-driven contracts.

---

## When to Use This Skill

- Microservices architectures
- API versioning
- Consumer-provider contracts
- CI/CD integration
- Breaking change prevention
- Team collaboration

---

## Quick Reference

### Contract Testing Flow

```
1. Consumer defines contract (expected API behavior)
2. Consumer tests against mock (Pact generates contract file)
3. Contract published to Pact Broker
4. Provider verifies against contract
5. Both sides pass → Safe to deploy
```

---

### Pact Example (Consumer Side)

```javascript
// consumer.test.js
const { Pact } = require('@pact-foundation/pact');
const { UserService } = require('./user-service');

const provider = new Pact({
  consumer: 'WebApp',
  provider: 'UserAPI',
  port: 8080,
});

describe('User API Contract', () => {
  beforeAll(() => provider.setup());
  afterAll(() => provider.finalize());
  afterEach(() => provider.verify());

  test('get user by ID', async () => {
    // Define expected interaction
    await provider.addInteraction({
      state: 'user 123 exists',
      uponReceiving: 'a request for user 123',
      withRequest: {
        method: 'GET',
        path: '/users/123',
        headers: {
          Accept: 'application/json',
        },
      },
      willRespondWith: {
        status: 200,
        headers: {
          'Content-Type': 'application/json',
        },
        body: {
          id: 123,
          name: 'John Doe',
          email: 'john@example.com',
        },
      },
    });

    // Test consumer code
    const userService = new UserService('http://localhost:8080');
    const user = await userService.getUser(123);

    expect(user.id).toBe(123);
    expect(user.name).toBe('John Doe');
  });
});
```

---

### Pact Example (Provider Side)

```javascript
// provider.test.js
const { Verifier } = require('@pact-foundation/pact');
const app = require('./app'); // Your Express app

describe('Pact Verification', () => {
  test('validates the expectations of UserAPI', () => {
    return new Verifier({
      provider: 'UserAPI',
      providerBaseUrl: 'http://localhost:3000',
      
      // Fetch contracts from Pact Broker
      pactBrokerUrl: 'https://pact-broker.example.com',
      pactBrokerToken: process.env.PACT_BROKER_TOKEN,
      
      // Or use local pacts
      // pactUrls: ['./pacts/webapp-userapi.json'],
      
      // Provider states
      stateHandlers: {
        'user 123 exists': async () => {
          // Setup: Create user 123 in test DB
          await db.users.create({
            id: 123,
            name: 'John Doe',
            email: 'john@example.com',
          });
        },
      },
      
      publishVerificationResult: true,
      providerVersion: process.env.GIT_COMMIT,
    }).verifyProvider();
  });
});
```

---

### OpenAPI Contract Testing

```yaml
# openapi.yaml
openapi: 3.0.0
info:
  title: User API
  version: 1.0.0

paths:
  /users/{userId}:
    get:
      parameters:
        - name: userId
          in: path
          required: true
          schema:
            type: integer
      responses:
        '200':
          description: User found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'

components:
  schemas:
    User:
      type: object
      required:
        - id
        - name
        - email
      properties:
        id:
          type: integer
        name:
          type: string
        email:
          type: string
          format: email
```

```javascript
// Validate against OpenAPI spec
const OpenAPIBackend = require('openapi-backend').default;

const api = new OpenAPIBackend({
  definition: './openapi.yaml',
});

api.register({
  validationFail: (c, req, res) => {
    res.status(400).json({ error: c.validation.errors });
  },
});

await api.init();

// Test requests
const request = {
  method: 'GET',
  path: '/users/123',
};

const validation = await api.validateRequest(request);
expect(validation.valid).toBe(true);
```

---

### Spring Cloud Contract (Java)

```groovy
// Contract DSL
package contracts

import org.springframework.cloud.contract.spec.Contract

Contract.make {
    request {
        method 'GET'
        url '/users/123'
        headers {
            accept(applicationJson())
        }
    }
    response {
        status OK()
        body([
            id: 123,
            name: 'John Doe',
            email: 'john@example.com'
        ])
        headers {
            contentType(applicationJson())
        }
    }
}
```

---

### Pact Broker Integration

```yaml
# .github/workflows/pact.yml
name: Contract Testing

on: [push, pull_request]

jobs:
  consumer:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - run: npm test
      
      # Publish pacts
      - run: |
          npx pact-broker publish \
            ./pacts \
            --consumer-app-version=${{ github.sha }} \
            --broker-base-url=${{ secrets.PACT_BROKER_URL }} \
            --broker-token=${{ secrets.PACT_BROKER_TOKEN }}
  
  provider:
    runs-on: ubuntu-latest
    needs: consumer
    steps:
      - uses: actions/checkout@v2
      - run: npm test  # Runs provider verification
      
      # Can-i-deploy check
      - run: |
          npx pact-broker can-i-deploy \
            --pacticipant=UserAPI \
            --version=${{ github.sha }} \
            --to-environment=production \
            --broker-base-url=${{ secrets.PACT_BROKER_URL }} \
            --broker-token=${{ secrets.PACT_BROKER_TOKEN }}
```

---

### Can-i-Deploy

```bash
# Check if safe to deploy
pact-broker can-i-deploy \
  --pacticipant=UserAPI \
  --version=1.2.3 \
  --to-environment=production

# Output:
# Computer says yes \o/
# 
# CONSUMER       | C.VERSION | PROVIDER | P.VERSION | SUCCESS?
# ---------------|-----------|----------|-----------|----------
# WebApp         | abc123    | UserAPI  | 1.2.3     | true
```

---

### GraphQL Contract Testing

```javascript
// GraphQL contract
const { buildSchema } = require('graphql');

const schema = buildSchema(`
  type User {
    id: ID!
    name: String!
    email: String!
  }
  
  type Query {
    user(id: ID!): User
  }
`);

// Test against schema
const { validate } = require('graphql');

const query = `
  query {
    user(id: "123") {
      id
      name
      email
    }
  }
`;

const errors = validate(schema, parse(query));
expect(errors).toHaveLength(0);
```

---

### Versioning Strategy

```javascript
// Provider states for multiple versions
stateHandlers: {
  // v1 contract
  'user 123 exists (v1)': async () => {
    await db.users.create({
      id: 123,
      name: 'John Doe',
    });
  },
  
  // v2 contract (with email)
  'user 123 exists (v2)': async () => {
    await db.users.create({
      id: 123,
      name: 'John Doe',
      email: 'john@example.com',
    });
  },
}
```

---

## Best Practices

✅ **Consumer-driven** - Consumers define needs  
✅ **Pact Broker** - Centralized contract storage  
✅ **Can-i-deploy** - Safe deployment checks  
✅ **Provider states** - Reproducible test data  
✅ **Version contracts** - Track changes  
✅ **CI/CD integration** - Automated validation  
✅ **Minimal contracts** - Test behavior, not data

---

## Anti-Patterns

❌ **Testing implementation** → Test behavior  
❌ **Brittle contracts** → Too specific, break often  
❌ **No Pact Broker** → Manual contract sharing  
❌ **Skip provider verification** → One-sided testing  
❌ **Large payload contracts** → Focus on structure  
❌ **No versioning** → Breaking changes undetected

---

## Pact vs Traditional Integration Tests

| Aspect | Pact | Integration Tests |
|--------|------|-------------------|
| Speed | Fast (mock) | Slow (real services) |
| Isolation | Yes | No |
| Consumer-driven | Yes | No |
| Both sides tested | Yes | Provider only |
| CI-friendly | Very | Moderately |

---

## Related Skills

- `api-patterns` - API design
- `testing-patterns` - Testing strategies
- `microservices-communication` - Service contracts

---

## Official Resources

- [Pact Documentation](https://docs.pact.io/)
- [Pact Broker](https://github.com/pact-foundation/pact_broker)
- [Spring Cloud Contract](https://spring.io/projects/spring-cloud-contract)

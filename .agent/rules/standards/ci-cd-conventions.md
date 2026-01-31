---
category: Standards
scope: DevOps
last_updated: 2026-01-16
---

# CI/CD - Best Practices & Conventions

**Scope:** GitHub Actions, GitLab CI, Docker, Deployment  
**Updated:** 2026-01-16

---

## GitHub Actions Workflows

### Basic CI Pipeline

```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run linter
        run: npm run lint
      
      - name: Run tests
        run: npm test -- --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

### Multi-Stage Pipeline

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm run build
      - uses: actions/upload-artifact@v3
        with:
          name: dist
          path: dist/
  
  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/download-artifact@v3
      - run: npm test
  
  deploy:
    needs: [build, test]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - run: echo "Deploy to production"
```

---

## Docker Multi-Stage Builds

### Node.js Example

```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./

USER node
EXPOSE 3000
CMD ["node", "dist/main.js"]
```

### Python FastAPI Example

```dockerfile
# Build stage
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Production stage
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .

ENV PATH=/root/.local/bin:$PATH
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0"]
```

---

## Security Scanning

### Dependency Scanning

```yaml
- name: Run Snyk security scan
  uses: snyk/actions/node@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

- name: SAST with SonarCloud
  uses: SonarSource/sonarcloud-github-action@master
  env:
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

### Container Scanning

```yaml
- name: Build Docker image
  run: docker build -t myapp:${{ github.sha }} .

- name: Scan image with Trivy
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: myapp:${{ github.sha }}
    severity: 'CRITICAL,HIGH'
```

---

## Environment Management

### Secrets Management

```yaml
# ✅ Use GitHub Secrets
env:
  DATABASE_URL: ${{ secrets.DATABASE_URL }}
  API_KEY: ${{ secrets.API_KEY }}

# ❌ Never commit secrets
env:
  API_KEY: "hardcoded-key-123"  # WRONG!
```

### Environment-Specific Deploy

```yaml
deploy-staging:
  environment:
    name: staging
    url: https://staging.example.com
  steps:
    - run: deploy-to-staging.sh

deploy-production:
  environment:
    name: production
    url: https://app.example.com
  needs: deploy-staging
  if: github.ref == 'refs/heads/main'
  steps:
    - run: deploy-to-production.sh
```

---

## Deployment Strategies

### Blue-Green Deployment

```yaml
deploy:
  steps:
    # Deploy to green environment
    - run: kubectl apply -f k8s/green/
    
    # Health check
    - run: ./health-check.sh green
    
    # Switch traffic
    - run: kubectl patch service app -p '{"spec":{"selector":{"version":"green"}}}'
    
    # Keep blue for rollback
```

### Canary Deployment

```yaml
# Deploy to 10% of traffic
- run: kubectl apply -f k8s/canary/deployment.yaml
- run: kubectl set resources deployment/canary --limits=cpu=100m --requests=cpu=50m

# Monitor metrics
- run: ./monitor-canary.sh --duration=10m

# If successful, roll out to 100%
- run: kubectl scale deployment/canary --replicas=10
```

### Rolling Update

```yaml
apiVersion: apps/v1
kind: Deployment
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # Add 1 new pod
      maxUnavailable: 0  # No downtime
```

---

## Testing in CI

### Unit + Integration Tests

```yaml
test:
  services:
    postgres:
      image: postgres:15
      env:
        POSTGRES_PASSWORD: test
    redis:
      image: redis:7
  
  steps:
    - run: npm run test:unit
    - run: npm run test:integration
```

### E2E Tests

```yaml
e2e:
  steps:
    - name: Start app
      run: npm start &
    
    - name: Wait for app
      run: npx wait-on http://localhost:3000
    
    - name: Run E2E tests
      run: npx playwright test
    
    - name: Upload test results
      if: always()
      uses: actions/upload-artifact@v3
      with:
        name: playwright-report
        path: playwright-report/
```

---

## Build Optimization

### Caching

```yaml
- name: Cache node modules
  uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}

- name: Cache Docker layers
  uses: actions/cache@v3
  with:
    path: /tmp/.buildx-cache
    key: ${{ runner.os }}-buildx-${{ hashFiles('Dockerfile') }}
```

### Parallel Jobs

```yaml
test:
  strategy:
    matrix:
      node: [18, 20, 22]
      os: [ubuntu-latest, windows-latest]
  runs-on: ${{ matrix.os }}
  steps:
    - uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node }}
```

---

## Monitoring & Notifications

### Slack Notifications

```yaml
- name: Notify deployment
  if: always()
  uses: slackapi/slack-github-action@v1
  with:
    payload: |
      {
        "text": "Deployment ${{ job.status }}: ${{ github.repository }}"
      }
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

### Status Badges

```markdown
![CI](https://github.com/user/repo/workflows/CI/badge.svg)
![Coverage](https://codecov.io/gh/user/repo/branch/main/graph/badge.svg)
```

---

## Best Practices Checklist

### CI Pipeline
- [ ] **Runs on every PR** - Catch issues early
- [ ] **Fast feedback** - Under 10 minutes ideal
- [ ] **Fail fast** - Stop on first failure
- [ ] **Parallel execution** - Run tests concurrently
- [ ] **Caching** - Dependencies, build artifacts

### Security
- [ ] **Secrets in vault** - Never in code
- [ ] **Dependency scanning** - Snyk, Dependabot
- [ ] **SAST** - SonarCloud, CodeQL
- [ ] **Container scanning** - Trivy, Snyk
- [ ] **Signed commits** - Git signing required

### Testing
- [ ] **Unit tests** - Fast, isolated
- [ ] **Integration tests** - With real services
- [ ] **E2E tests** - Critical user paths
- [ ] **Coverage threshold** - Minimum 80%

### Deployment
- [ ] **Zero-downtime** - Rolling or blue-green
- [ ] **Health checks** - Before traffic switch
- [ ] **Rollback plan** - One-command rollback
- [ ] **Monitoring** - Logs, metrics, alerts

### Docker
- [ ] **Multi-stage builds** - Smaller images
- [ ] **Non-root user** - Security best practice
- [ ] **.dockerignore** - Exclude unnecessary files
- [ ] **Image scanning** - Before deployment

---

## Anti-Patterns to Avoid

❌ **Manual deployments** → Automate everything  
❌ **No testing** → Test before merge  
❌ **Secrets in code** → Use secret management  
❌ **Large Docker images** → Multi-stage builds  
❌ **No rollback** → Always have rollback plan  
❌ **Deploy to production directly** → Use staging  
❌ **No monitoring** → Track deployments

---

**References:**
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [12-Factor App](https://12factor.net/)

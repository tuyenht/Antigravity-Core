# DevOps Best Practices

**Version:** 1.0  
**Updated:** 2026-01-16

---

## 1. Dockerfile Optimization

```dockerfile
# ✅ Multi-stage build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
USER node
EXPOSE 3000
CMD ["node", "server.js"]

# ❌ Single stage (larger image)
FROM node:20
WORKDIR /app
COPY . .
RUN npm install
CMD ["node", "server.js"]
```

### Best Practices:
- Use specific tags (not `latest`)
- Multi-stage builds
- Minimal base images (alpine)
- Run as non-root user
- .dockerignore file

---

## 2. Environment Configuration

```bash
# ✅ .env.example (committed)
DATABASE_URL=postgresql://user:password@localhost:5432/db
REDIS_URL=redis://localhost:6379
API_KEY=your_api_key_here

# ✅ .env (NOT committed, gitignored)
DATABASE_URL=postgresql://prod_user:prod_pass@db.example.com:5432/prod_db
REDIS_URL=redis://redis.example.com:6379
API_KEY=actual_secret_key_123

# Environment-specific configs
.env.development
.env.staging
.env.production
```

---

## 3. Kubernetes Deployment

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:v1.2.3
        resources:
          limits:
            cpu: "500m"
            memory: "512Mi"
          requests:
            cpu: "250m"
            memory: "256Mi"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
```

---

## 4. Secret Management

```bash
# ✅ Use secret managers
# Kubernetes Secrets
kubectl create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password=secret123

# ✅ AWS Secrets Manager
aws secretsmanager create-secret \
  --name prod/db/password \
  --secret-string "super-secret-password"

# ❌ Never commit secrets
git add .env  # ❌ DON'T DO THIS
```

---

## 5. Blue-Green Deployment

```yaml
# Blue deployment (current)
service:
  selector:
    app: myapp
    version: blue

# Green deployment (new)
deployment-green:
  labels:
    app: myapp
    version: green

# Switch traffic
kubectl patch service myapp -p '{"spec":{"selector":{"version":"green"}}}'

# Rollback if needed
kubectl patch service myapp -p '{"spec":{"selector":{"version":"blue"}}}'
```

---

## 6. Canary Releases

```yaml
# 90% traffic to stable
apiVersion: v1
kind: Service
metadata:
  name: myapp-stable
spec:
  selector:
    app: myapp
    version: stable
  ports:
  - port: 80

# 10% traffic to canary
---
apiVersion: v1
kind: Service
metadata:
  name: myapp-canary
spec:
  selector:
    app: myapp
    version: canary
```

---

## 7. CI/CD Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm ci
      - run: npm test
      - run: npm run lint

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: docker/build-push-action@v4
        with:
          push: true
          tags: myapp:${{ github.sha }}

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - run: kubectl set image deployment/myapp myapp=myapp:${{ github.sha }}
      - run: kubectl rollout status deployment/myapp
```

---

**References:**
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Kubernetes Documentation](https://kubernetes.io/)
- [12-Factor App](https://12factor.net/)

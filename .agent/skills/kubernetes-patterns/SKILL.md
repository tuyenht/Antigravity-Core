---
name: Kubernetes Patterns
description: Production-ready Kubernetes patterns for deployment, scaling, service discovery, configuration management, and container orchestration best practices
category: DevOps & Infrastructure
difficulty: Advanced
last_updated: 2026-01-16
---

# Kubernetes Patterns

Expert patterns for container orchestration and cloud-native deployments với Kubernetes.

---

## When to Use This Skill

- Deploying containerized applications
- Container orchestration
- Auto-scaling workloads
- Service discovery and load balancing
- Configuration management
- Production infrastructure

---

## Content Map

### Core Concepts
- **pods.md** - Pod design, multi-container patterns
- **services.md** - Service types, discovery, load balancing
- **deployments.md** - Rolling updates, strategies, rollbacks

### Configuration
- **configmaps.md** - Configuration management
- **secrets.md** - Sensitive data handling
- **volumes.md** - Persistent storage patterns

### Scaling
- **hpa.md** - Horizontal Pod Autoscaler
- **vpa.md** - Vertical Pod Autoscaler
- **cluster-autoscaler.md** - Node scaling

### Networking
- **ingress.md** - Ingress controllers (Nginx, Traefik)
- **network-policies.md** - Security policies
- **service-mesh.md** - Istio integration

### Deployment Strategies
- **rolling-update.md** - Zero-downtime deployments
- **blue-green.md** - Blue-green deployments
- **canary.md** - Canary releases

### Advanced
- **helm.md** - Package management
- **operators.md** - Custom controllers
- **statefulsets.md** - Stateful applications

---

## Quick Reference

### Deployment Strategies Decision Tree

```
Choose Deployment Strategy:

Zero downtime required?
├── YES → Rolling Update (default)
│   ├── Need instant rollback? → Blue-Green
│   └── Test with subset? → Canary
│
└── NO → Recreate (downtime acceptable)
```

---

### Basic Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: myapp:v1.0.0
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
```

---

### Service & Ingress

```yaml
# Service (LoadBalancer)
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080

---
# Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

---

### ConfigMap & Secrets

```yaml
# ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database.url: "postgres://db.example.com:5432"
  log.level: "info"
  
---
# Secret
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  db-password: cGFzc3dvcmQxMjM=  # base64 encoded

---
# Usage in Pod
spec:
  containers:
  - name: app
    env:
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database.url
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: app-secrets
          key: db-password
```

---

### Horizontal Pod Autoscaler (HPA)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

---

### Helm Chart Structure

```
my-app/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default values
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── _helpers.tpl    # Template helpers
└── charts/             # Dependencies
```

```yaml
# values.yaml
replicaCount: 3

image:
  repository: myapp
  tag: v1.0.0
  pullPolicy: IfNotPresent

service:
  type: LoadBalancer
  port: 80

ingress:
  enabled: true
  host: app.example.com

resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"
    cpu: "500m"
```

---

### Blue-Green Deployment

```yaml
# Blue (current production)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-blue
  labels:
    version: blue
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: blue
  template:
    metadata:
      labels:
        app: myapp
        version: blue
    spec:
      containers:
      - name: app
        image: myapp:v1.0.0

---
# Green (new version)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-green
  labels:
    version: green
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: green
  template:
    metadata:
      labels:
        app: myapp
        version: green
    spec:
      containers:
      - name: app
        image: myapp:v2.0.0

---
# Service (switch by updating selector)
apiVersion: v1
kind: Service
metadata:
  name: app-service
spec:
  selector:
    app: myapp
    version: blue  # Change to 'green' to switch
  ports:
  - port: 80
    targetPort: 8080
```

---

### StatefulSet (for databases)

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

---

## Production Best Practices

### Resource Management

```yaml
# ✅ Always set requests and limits
resources:
  requests:      # Guaranteed resources
    memory: "64Mi"
    cpu: "250m"
  limits:        # Maximum allowed
    memory: "128Mi"
    cpu: "500m"
```

### Health Checks

```yaml
# ✅ Always define probes
livenessProbe:   # Restart if unhealthy
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
  
readinessProbe:  # Remove from load balancer if not ready
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

### Security

```yaml
# ✅ Run as non-root
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 2000
  capabilities:
    drop:
    - ALL
```

---

## Anti-Patterns

❌ **No resource limits** → OOMKilled, noisy neighbors  
❌ **No health probes** → Can't detect failures  
❌ **Using :latest tag** → Unpredictable deployments  
❌ **Storing state in pods** → Use StatefulSet or external storage  
❌ **No namespace isolation** → Security risk  
❌ **Manual kubectl apply** → Use Helm or GitOps

---

## Best Practices

✅ **Namespace per environment** (dev, staging, prod)  
✅ **Resource quotas** - Prevent resource exhaustion  
✅ **Network policies** - Restrict pod communication  
✅ **RBAC** - Least privilege access  
✅ **Helm for packaging** - Version, rollback, share  
✅ **GitOps (ArgoCD/Flux)** - Declarative deployments  
✅ **Monitoring** - Prometheus + Grafana

---

## Common Commands

```bash
# Deployments
kubectl apply -f deployment.yaml
kubectl rollout status deployment/web-app
kubectl rollout undo deployment/web-app

# Scaling
kubectl scale deployment web-app --replicas=5
kubectl autoscale deployment web-app --min=2 --max=10 --cpu-percent=70

# Debugging
kubectl get pods
kubectl describe pod web-app-xxx
kubectl logs web-app-xxx
kubectl exec -it web-app-xxx -- /bin/bash

# Helm
helm install myapp ./chart
helm upgrade myapp ./chart
helm rollback myapp 1
```

---

## Related Skills

- `docker-expert` - Container fundamentals
- `monitoring-observability` - Cluster monitoring
- `microservices-communication` - Service mesh

---

## Official Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Patterns Book](https://www.oreilly.com/library/view/kubernetes-patterns/9781492050278/)

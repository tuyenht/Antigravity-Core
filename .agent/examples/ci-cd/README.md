# CI/CD Integration Examples

This directory contains example configurations for integrating the `.agent` system with popular CI/CD platforms.

---

## GitHub Actions

### Basic Integration

```yaml
# .github/workflows/agent-checks.yml
name: Agent Quality Checks

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  agent-quality:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'
          tools: composer:v2
      
      - name: Install Dependencies
        run: |
          npm ci
          composer install --no-interaction
      
      # Secret Scanning
      - name: Secret Scan
        run: pwsh .agent/scripts/secret-scan.ps1 -All
        continue-on-error: false
      
      # Performance Check
      - name: Build & Performance Check
        run: |
          npm run build
          pwsh .agent/scripts/performance-check.ps1 -Frontend
      
      # Lint & Type Check
      - name: Lint Check
        run: |
          npm run lint
          ./vendor/bin/pint --test
      
      # Tests
      - name: Run Tests
        run: |
          npm test
          php artisan test --coverage --min=80
      
      # Health Check
      - name: Agent Health Check
        run: pwsh .agent/scripts/health-check.ps1
```

---

### With Lighthouse CI

```yaml
# .github/workflows/lighthouse.yml
name: Lighthouse CI

on:
  pull_request:

jobs:
  lighthouse:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      
      - name: Install & Build
        run: |
          npm ci
          npm run build
      
      - name: Run Lighthouse CI
        uses: treosh/lighthouse-ci-action@v11
        with:
          configPath: '.agent/benchmarks/lighthouserc.json'
          uploadArtifacts: true
```

---

## GitLab CI

```yaml
# .gitlab-ci.yml
stages:
  - security
  - build
  - test
  - quality

variables:
  NODE_VERSION: "20"
  PHP_VERSION: "8.3"

# Secret Scanning
secret-scan:
  stage: security
  image: mcr.microsoft.com/powershell:latest
  script:
    - pwsh .agent/scripts/secret-scan.ps1 -All
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"

# Build
build:
  stage: build
  image: node:${NODE_VERSION}
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 hour

# Tests
test-frontend:
  stage: test
  image: node:${NODE_VERSION}
  script:
    - npm ci
    - npm run test:coverage
  coverage: '/All files.*\|.*(\d+\.\d+)/'

test-backend:
  stage: test
  image: php:${PHP_VERSION}
  script:
    - composer install
    - php artisan test --coverage
  coverage: '/Coverage:.*(\d+\.\d+)%/'

# Quality Checks
quality:
  stage: quality
  image: mcr.microsoft.com/powershell:latest
  script:
    - pwsh .agent/scripts/health-check.ps1
    - pwsh .agent/scripts/validate-compliance.ps1
```

---

## Azure DevOps

```yaml
# azure-pipelines.yml
trigger:
  - main

pr:
  - main

pool:
  vmImage: 'ubuntu-latest'

stages:
  - stage: Security
    jobs:
      - job: SecretScan
        steps:
          - task: PowerShell@2
            inputs:
              filePath: '.agent/scripts/secret-scan.ps1'
              arguments: '-All'

  - stage: Build
    jobs:
      - job: BuildFrontend
        steps:
          - task: NodeTool@0
            inputs:
              versionSpec: '20.x'
          - script: |
              npm ci
              npm run build
            displayName: 'Build'

  - stage: Test
    jobs:
      - job: Test
        steps:
          - script: |
              npm test
              php artisan test
            displayName: 'Run Tests'

  - stage: Quality
    jobs:
      - job: QualityCheck
        steps:
          - task: PowerShell@2
            inputs:
              filePath: '.agent/scripts/health-check.ps1'
```

---

## Recommended Pipeline Flow

```
┌─────────────┐
│ Code Push   │
└──────┬──────┘
       ▼
┌─────────────┐
│ Secret Scan │ ← Blocks if secrets found
└──────┬──────┘
       ▼
┌─────────────┐
│ Build       │
└──────┬──────┘
       ▼
┌─────────────┐
│ Lint/Types  │ ← Auto-fix with auto-heal
└──────┬──────┘
       ▼
┌─────────────┐
│ Tests       │ ← 80% coverage required
└──────┬──────┘
       ▼
┌─────────────┐
│ Perf Check  │ ← Against budgets
└──────┬──────┘
       ▼
┌─────────────┐
│ AI Review   │ ← CRITICAL blocks merge
└──────┬──────┘
       ▼
┌─────────────┐
│ Deploy      │
└─────────────┘
```

---

## Environment Variables

Set these in your CI/CD secrets:

```
# Required
DATABASE_URL=...
APP_KEY=...

# Optional (for enhanced checks)
LIGHTHOUSE_TOKEN=...
SENTRY_DSN=...
```

---

## Related Files

- [secret-scan.ps1](../scripts/secret-scan.ps1)
- [performance-check.ps1](../scripts/performance-check.ps1)
- [health-check.ps1](../scripts/health-check.ps1)
- [performance-budgets.yml](../performance-budgets.yml)

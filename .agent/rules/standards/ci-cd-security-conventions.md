# CI/CD Security Conventions

**Version:** 1.0  
**Updated:** 2026-01-16  
**Scope:** Continuous Integration & Deployment Security

---

## 1. Dependency Scanning

### npm/Node.js Projects

```yaml
# .github/workflows/security.yml
name: Security Scan

on: [push, pull_request]

jobs:
  dependency-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run npm audit
        run: |
          npm ci
          npm audit --audit-level=high
          
      - name: Check for outdated packages
        run: npm outdated || true
```

### Python Projects

```yaml
- name: pip-audit
  run: |
    pip install pip-audit
    pip-audit --require-hashes --desc
```

### Automated Dependency Updates

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    labels:
      - "dependencies"
      - "security"
```

---

## 2. SAST (Static Application Security Testing)

### CodeQL (GitHub Actions)

```yaml
- name: Initialize CodeQL
  uses: github/codeql-action/init@v2
  with:
    languages: javascript, python
    
- name: Autobuild
  uses: github/codeql-action/autobuild@v2
  
- name: Perform CodeQL Analysis
  uses: github/codeql-action/analyze@v2
```

### SonarQube Integration

```yaml
- name: SonarQube Scan
  uses: sonarsource/sonarqube-scan-action@master
  env:
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
    SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
```

---

## 3. Container Security

### Trivy Scanning

```yaml
- name: Build Docker image
  run: docker build -t myapp:${{ github.sha }} .
  
- name: Run Trivy vulnerability scanner
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: 'myapp:${{ github.sha }}'
    format: 'sarif'
    severity: 'CRITICAL,HIGH'
    exit-code: '1'  # Fail on vulnerabilities
```

### Base Image Security

```dockerfile
# ✅ GOOD - Official, minimal, specific version
FROM node:20.10-alpine3.19

# ❌ BAD - Latest tag, bloated
FROM node:latest
```

---

## 4. Secrets Management

### GitHub Actions Secrets

```yaml
# ✅ Use GitHub Secrets
- name: Deploy
  env:
    API_KEY: ${{ secrets.API_KEY }}
    DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
  run: npm run deploy
```

### Secret Scanning (pre-commit)

```bash
# Install git-secrets
brew install git-secrets  # macOS
apt-get install git-secrets  # Linux

# Setup
git secrets --install
git secrets --register-aws
git secrets --add 'API_KEY.*'
git secrets --add 'sk_live_[a-zA-Z0-9]+'
```

### Prevent Secrets in Code

```yaml
# .github/workflows/secret-scan.yml
- name: TruffleHog Secret Scan
  uses: trufflesecurity/trufflehog@main
  with:
    path: ./
    base: main
    head: HEAD
```

---

## 5. SBOM Generation

### CycloneDX (Node.js)

```yaml
- name: Generate SBOM
  run: |
    npx @cyclonedx/cyclonedx-npm --output-file sbom.json
    
- name: Upload SBOM
  uses: actions/upload-artifact@v3
  with:
    name: sbom
    path: sbom.json
```

### Syft (Multi-language)

```yaml
- name: Generate SBOM with Syft
  uses: anchore/sbom-action@v0
  with:
    format: spdx-json
    artifact-name: sbom.spdx.json
```

---

## 6. Code Signing

### Sign Commits

```bash
# GPG signing
git config --global commit.gpgsign true
git config --global user.signingkey <YOUR_GPG_KEY>
```

### Sign Container Images

```yaml
- name: Install Cosign
  uses: sigstore/cosign-installer@main
  
- name: Sign image
  run: |
    cosign sign --key cosign.key myimage:tag
```

---

## 7. Environment Separation

### Branch Protection

```yaml
# Required for main/production
- Require pull request reviews (2+)
- Require status checks to pass
- Require signed commits
- Include administrators
```

### Environment-Specific Secrets

```yaml
jobs:
  deploy-staging:
    environment: staging
    env:
      API_URL: ${{ secrets.STAGING_API_URL }}
      
  deploy-production:
    environment: production
    needs: deploy-staging
    env:
      API_URL: ${{ secrets.PRODUCTION_API_URL }}
```

---

## 8. Security Gates

### Quality Gates

```yaml
- name: Security Quality Gate
  run: |
    # Fail if critical vulnerabilities
    CRITICAL=$(npm audit --json | jq '.metadata.vulnerabilities.critical')
    if [ "$CRITICAL" -gt 0 ]; then
      echo "❌ Critical vulnerabilities found!"
      exit 1
    fi
```

### License Compliance

```yaml
- name: Check Licenses
  run: |
    npx license-checker --onlyAllow 'MIT;Apache-2.0;BSD-3-Clause'
```

---

## 9. Audit Logging

### Track Deployments

```yaml
- name: Log Deployment
  run: |
    curl -X POST ${{ secrets.AUDIT_WEBHOOK }} \
      -H "Content-Type: application/json" \
      -d '{
        "event": "deployment",
        "commit": "${{ github.sha }}",
        "user": "${{ github.actor }}",
        "environment": "production"
      }'
```

---

## 10. Best Practices Checklist

**Pre-Commit:**
- [ ] Secret scanning (git-secrets)
- [ ] Linting passes
- [ ] Unit tests pass

**CI Pipeline:**
- [ ] Dependency vulnerability scan (npm audit)
- [ ] SAST (CodeQL/SonarQube)
- [ ] Container scanning (Trivy)
- [ ] License compliance check
- [ ] SBOM generation

**CD Pipeline:**
- [ ] Deployment approval required (production)
- [ ] Environment-specific secrets
- [ ] Signed commits/images
- [ ] Audit logging
- [ ] Rollback plan

---

**References:**
- [OWASP CI/CD Security](https://owasp.org/www-project-top-10-ci-cd-security-risks/)
- [GitHub Security Best Practices](https://docs.github.com/en/actions/security-guides)

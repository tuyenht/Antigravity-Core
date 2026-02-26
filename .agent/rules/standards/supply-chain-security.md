# Supply Chain Security Guidelines

**Version:** 1.0  
**Updated:** 2026-01-16  
**Scope:** Software Supply Chain Security

---

## 1. Dependency Management

### Lock Files (CRITICAL)

**Always commit lock files:**

```bash
# ✅ Required files
package-lock.json  # npm
yarn.lock          # Yarn
pnpm-lock.yaml     # pnpm
requirements.txt   # Python (with hashes)
Gemfile.lock       # Ruby
composer.lock      # PHP
```

### Dependency Pinning

```json
// ✅ GOOD - Exact versions
{
  "dependencies": {
    "express": "4.18.2",
    "react": "18.2.0"
  }
}

// ❌ BAD - Unpinned
{
  "dependencies": {
    "express": "^4.18.2",  // Can update to 4.x
    "react": "latest"       // Dangerous!
  }
}
```

### Hash Verification (Python)

```bash
# Generate hashes
pip freeze --all > requirements.txt
pip-compile --generate-hashes requirements.in

# requirements.txt
django==4.2.0 \
    --hash=sha256:abc123... \
    --hash=sha256:def456...
```

---

## 2. Vulnerability Monitoring

### Automated Scanning

```yaml
# .github/workflows/dependency-check.yml
name: Dependency Check

on:
  schedule:
    - cron: '0 0 * * 1'  # Weekly

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Dependency Review
        uses: actions/dependency-review-action@v3
        with:
          fail-on-severity: moderate
```

### CVE Alerts

```bash
# Enable GitHub Dependabot alerts
Settings → Security → Dependabot alerts → Enable

# npm audit
npm audit --audit-level=moderate

# Snyk monitoring
snyk monitor
```

---

## 3. Package Registry Security

### Private Registry

```bash
# .npmrc
registry=https://npm.pkg.github.com/@your-org
//npm.pkg.github.com/:_authToken=${NPM_TOKEN}
```

### Package Verification

```bash
# Verify package integrity
npm install --package-lock-only
npm audit signatures

# Check package provenance
npm view package@version dist.integrity
```

### Typosquatting Prevention

```javascript
// Check for suspicious packages
const suspiciousPatterns = [
  /react-/, /node-/, /npm-/,  // Common prefixes
  /\d{6,}/,  // Random numbers
];

// Use package allow-list
{
  "dependencies": {
    // Only approved packages
  }
}
```

---

## 4. SBOM (Software Bill of Materials)

### Generate SBOM

```bash
# CycloneDX (npm)
npx @cyclonedx/cyclonedx-npm --output-file sbom.json

# Syft (multi-language)
syft packages dir:. -o spdx-json > sbom.spdx.json

# SPDX format
syft packages docker:myimage:tag -o spdx
```

### SBOM Verification

```bash
# Verify SBOM against actual dependencies
sbom verify --sbom sbom.json --path .

# Check for known vulnerabilities in SBOM
grype sbom:sbom.json
```

---

## 5. Code Provenance

### Signed Commits

```bash
# GPG setup
gpg --gen-key
git config --global user.signingkey <KEY_ID>
git config --global commit.gpgsign true

# Verify
git log --show-signature
```

### SLSA Framework

```yaml
# SLSA Level 3 requirements
✅ Source integrity
✅ Build integrity  
✅ Provenance
✅ Hermetic builds
```

---

## 6. Build Security

### Reproducible Builds

```dockerfile
# ✅ GOOD - Pinned versions, reproducible
FROM node:20.10-alpine3.19
COPY package-lock.json .
RUN npm ci --only=production

# ❌ BAD - Latest, non-reproducible
FROM node:latest
RUN npm install
```

### Build Isolation

```yaml
# Use ephemeral build environments
- name: Build
  run: |
    docker run --rm \
      -v $(pwd):/app \
      -w /app \
      node:20-alpine \
      npm ci && npm run build
```

---

## 7. Dependency Review

### Manual Review Checklist

Before adding new dependency:

- [ ] Is it maintained? (last commit < 6 months)
- [ ] Does it have many stars/downloads?
- [ ] Are there known vulnerabilities?
- [ ] Is the license compatible?
- [ ] Is it really needed? (avoid bloat)
- [ ] Any suspicious code?

### Automated Review

```yaml
- name: Check new dependencies
  run: |
    npx can-i-ignore-scripts
    npx install-peerdeps --dry-run
```

---

## 8. Update Strategy

### Semantic Versioning

```
MAJOR.MINOR.PATCH
  ^     ^     ^
  |     |     └─ Bug fixes (safe)
  |     └──── New features (review)
  └────────── Breaking changes (test thoroughly)
```

### Automated Updates (Controlled)

```yaml
# Dependabot - only patch/minor
version: 2
updates:
  - package-ecosystem: "npm"
    versioning-strategy: increase-if-necessary
    ignore:
      - dependency-name: "*"
        update-types: ["version-update:semver-major"]
```

---

## 9. Incident Response

### Vulnerability Response Plan

```
1. DETECT (automated alerts)
   ↓
2. ASSESS (severity, exploitability)
   ↓
3. PATCH (update dependency)
   ↓
4. TEST (regression testing)
   ↓
5. DEPLOY (emergency deployment if critical)
   ↓
6. VERIFY (confirm fix)
   ↓
7. DOCUMENT (postmortem)
```

### Emergency Patching

```bash
# Critical vulnerability detected
npm audit fix --force  # Caution: may break things

# Manual patch
npm install package@safe-version
npm test  # Critical: test before deploy
git commit -m "security: patch CVE-2024-12345"
```

---

## 10. Security Checklist

**Daily:**
- [ ] Monitor Dependabot/Snyk alerts

**Weekly:**
- [ ] Review outdated packages
- [ ] Check for new CVEs

**Monthly:**
- [ ] Update dependencies (patch)
- [ ] Review dependency tree
- [ ] Generate fresh SBOM

**Quarterly:**
- [ ] Major dependency updates
- [ ] Remove unused dependencies
- [ ] Security audit

---

**Tools:**
- npm audit / yarn audit
- Snyk / Dependabot
- Trivy / Grype
- CycloneDX / Syft (SBOM)
- OWASP Dependency-Check

**References:**
- [OWASP Dependency Check](https://owasp.org/www-project-dependency-check/)
- [SLSA Framework](https://slsa.dev/)
- [npm Security Best Practices](https://docs.npmjs.com/security-best-practices)

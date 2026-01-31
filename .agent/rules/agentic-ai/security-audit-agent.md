# Security Audit Agent - Vulnerability Detection

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **Standard:** OWASP Top 10 2025, CWE/SANS Top 25  
> **Priority:** P0 - Load for all security reviews

---

You are an expert security audit agent specialized in identifying vulnerabilities and security risks.

## Core Security Principles

Apply systematic reasoning following OWASP guidelines and security best practices.

---

## 1) Attack Surface Analysis

### Entry Point Mapping
```markdown
## Attack Surface Template

### API Endpoints
| Endpoint | Method | Auth | Input | Risk |
|----------|--------|------|-------|------|
| /api/users | GET | JWT | query params | Low |
| /api/users | POST | JWT | JSON body | Medium |
| /api/upload | POST | JWT | multipart | High |
| /api/admin | * | Admin JWT | varies | Critical |

### Data Flows
```
User Input → Validation → Processing → Storage → Output
     ↓           ↓            ↓           ↓         ↓
  [Attack]   [Bypass?]    [Inject?]   [Leak?]   [XSS?]
```

### Trust Boundaries
1. Client ↔ Server (untrusted → trusted)
2. Server ↔ Database (trusted → trusted)
3. Server ↔ External API (trusted → semi-trusted)

### External Dependencies
| Dependency | Version | CVEs | Risk |
|------------|---------|------|------|
| express | 4.18.2 | 0 | Low |
| lodash | 4.17.21 | 0 | Low |
| log4j | 2.17.1 | 1 (fixed) | Low |
```

---

## 2) OWASP Top 10 (2025)

### A01: Broken Access Control

#### Vulnerable Code
```python
# ❌ VULNERABLE: IDOR - No ownership check
@app.get("/api/orders/{order_id}")
def get_order(order_id: int, current_user: User = Depends(get_current_user)):
    # Anyone can access any order!
    return db.query(Order).filter(Order.id == order_id).first()


# ❌ VULNERABLE: Missing authorization
@app.delete("/api/users/{user_id}")
def delete_user(user_id: int):
    # No auth check at all!
    db.query(User).filter(User.id == user_id).delete()
```

#### Secure Code
```python
# ✅ SECURE: Ownership verification
@app.get("/api/orders/{order_id}")
def get_order(
    order_id: int,
    current_user: User = Depends(get_current_user)
):
    order = db.query(Order).filter(
        Order.id == order_id,
        Order.user_id == current_user.id  # Ownership check
    ).first()
    
    if not order:
        raise HTTPException(status_code=404)
    
    return order


# ✅ SECURE: Role-based access control
@app.delete("/api/users/{user_id}")
def delete_user(
    user_id: int,
    current_user: User = Depends(get_current_user)
):
    # Only admins or self can delete
    if not current_user.is_admin and current_user.id != user_id:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    db.query(User).filter(User.id == user_id).delete()
```

#### Audit Checklist
```markdown
- [ ] All endpoints have authentication
- [ ] All endpoints have authorization checks
- [ ] IDOR protection (ownership verification)
- [ ] Role-based access control implemented
- [ ] Admin functions properly restricted
- [ ] CORS properly configured
- [ ] JWT tokens validated correctly
```

---

### A02: Cryptographic Failures

#### Vulnerable Code
```python
# ❌ VULNERABLE: Weak password hashing
import hashlib
password_hash = hashlib.md5(password.encode()).hexdigest()

# ❌ VULNERABLE: Hardcoded secrets
JWT_SECRET = "super-secret-key-12345"
API_KEY = "AIzaSyD..."

# ❌ VULNERABLE: Sensitive data in logs
logger.info(f"User {email} logged in with password {password}")

# ❌ VULNERABLE: No encryption at rest
user.ssn = "123-45-6789"  # Stored in plaintext
```

#### Secure Code
```python
# ✅ SECURE: Strong password hashing (Argon2)
from argon2 import PasswordHasher

ph = PasswordHasher(
    time_cost=3,
    memory_cost=65536,
    parallelism=4
)

password_hash = ph.hash(password)

# Verify
try:
    ph.verify(password_hash, password)
except VerifyMismatchError:
    raise InvalidCredentials()


# ✅ SECURE: Environment variables for secrets
import os
JWT_SECRET = os.environ["JWT_SECRET"]
API_KEY = os.environ["API_KEY"]


# ✅ SECURE: No sensitive data in logs
logger.info(f"User {email} logged in")  # No password!


# ✅ SECURE: Encrypt PII at rest
from cryptography.fernet import Fernet

cipher = Fernet(os.environ["ENCRYPTION_KEY"])
user.ssn_encrypted = cipher.encrypt(ssn.encode())
```

---

### A03: Injection

#### SQL Injection
```python
# ❌ VULNERABLE: String concatenation
def get_user(username):
    query = f"SELECT * FROM users WHERE username = '{username}'"
    return db.execute(query)  # SQL Injection!


# ✅ SECURE: Parameterized query
def get_user(username):
    query = "SELECT * FROM users WHERE username = %s"
    return db.execute(query, (username,))


# ✅ SECURE: ORM with safe queries
def get_user(username):
    return User.query.filter(User.username == username).first()
```

#### Command Injection
```python
# ❌ VULNERABLE: Shell command with user input
import os
def convert_file(filename):
    os.system(f"convert {filename} output.pdf")  # Injection!


# ✅ SECURE: Use subprocess with list args
import subprocess
def convert_file(filename):
    # Validate filename first
    if not filename.isalnum():
        raise ValueError("Invalid filename")
    
    subprocess.run(
        ["convert", filename, "output.pdf"],
        check=True,
        capture_output=True
    )
```

#### NoSQL Injection
```javascript
// ❌ VULNERABLE: User input in query
app.get('/users', (req, res) => {
    const query = { username: req.query.username };
    // Attacker: ?username[$ne]=anything
    db.users.find(query);
});


// ✅ SECURE: Sanitize input
import mongoSanitize from 'express-mongo-sanitize';
app.use(mongoSanitize());

app.get('/users', (req, res) => {
    const username = String(req.query.username);  // Force string
    db.users.find({ username });
});
```

---

### A04-A05: Insecure Design & Misconfiguration

#### Security Headers (Express.js)
```javascript
// ❌ VULNERABLE: No security headers
app.listen(3000);


// ✅ SECURE: Complete security headers
import helmet from 'helmet';

app.use(helmet({
    contentSecurityPolicy: {
        directives: {
            defaultSrc: ["'self'"],
            scriptSrc: ["'self'", "'strict-dynamic'"],
            styleSrc: ["'self'", "'unsafe-inline'"],
            imgSrc: ["'self'", "data:", "https:"],
            connectSrc: ["'self'"],
            fontSrc: ["'self'"],
            objectSrc: ["'none'"],
            frameAncestors: ["'none'"],
            upgradeInsecureRequests: [],
        },
    },
    hsts: {
        maxAge: 31536000,
        includeSubDomains: true,
        preload: true,
    },
    referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
    crossOriginEmbedderPolicy: true,
    crossOriginOpenerPolicy: true,
}));
```

#### Security Headers (Python/FastAPI)
```python
from fastapi import FastAPI
from starlette.middleware.trustedhost import TrustedHostMiddleware

app = FastAPI()

# Trusted hosts
app.add_middleware(
    TrustedHostMiddleware,
    allowed_hosts=["example.com", "*.example.com"]
)

# Security headers middleware
@app.middleware("http")
async def add_security_headers(request, call_next):
    response = await call_next(request)
    
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
    response.headers["Content-Security-Policy"] = "default-src 'self'"
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    response.headers["Permissions-Policy"] = "geolocation=(), microphone=()"
    
    return response
```

---

### A06-A07: Vulnerable Components & Authentication

#### Dependency Scanning
```yaml
# .github/workflows/security.yml
name: Security Scan

on: [push, pull_request]

jobs:
  dependency-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      # Python dependencies
      - name: Run Safety check
        run: |
          pip install safety
          safety check -r requirements.txt
      
      # Node dependencies
      - name: Run npm audit
        run: npm audit --audit-level=high
      
      # SAST scanning
      - name: Run Semgrep
        uses: semgrep/semgrep-action@v1
        with:
          config: p/security-audit
      
      # Container scanning
      - name: Run Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'myapp:latest'
          severity: 'HIGH,CRITICAL'
```

#### Secure Authentication
```python
# ✅ SECURE: Complete auth system
from datetime import datetime, timedelta
from jose import jwt, JWTError
from argon2 import PasswordHasher
from fastapi import HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer

# Configuration
SECRET_KEY = os.environ["JWT_SECRET"]
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE = 15  # minutes
REFRESH_TOKEN_EXPIRE = 7  # days
MAX_LOGIN_ATTEMPTS = 5
LOCKOUT_DURATION = 900  # 15 minutes

ph = PasswordHasher()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")


class AuthService:
    def __init__(self, db):
        self.db = db
        self.redis = get_redis()
    
    async def authenticate(self, email: str, password: str) -> dict:
        # Check lockout
        attempts_key = f"login_attempts:{email}"
        attempts = int(self.redis.get(attempts_key) or 0)
        
        if attempts >= MAX_LOGIN_ATTEMPTS:
            ttl = self.redis.ttl(attempts_key)
            raise HTTPException(
                status_code=429,
                detail=f"Account locked. Try again in {ttl} seconds"
            )
        
        # Find user
        user = await self.db.get_user_by_email(email)
        
        if not user:
            # Prevent enumeration - same timing
            ph.hash("dummy_password")
            self._increment_attempts(email)
            raise HTTPException(status_code=401, detail="Invalid credentials")
        
        # Verify password
        try:
            ph.verify(user.password_hash, password)
        except Exception:
            self._increment_attempts(email)
            raise HTTPException(status_code=401, detail="Invalid credentials")
        
        # Clear attempts on success
        self.redis.delete(attempts_key)
        
        # Generate tokens
        access_token = self._create_token(
            {"sub": str(user.id), "type": "access"},
            expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE)
        )
        refresh_token = self._create_token(
            {"sub": str(user.id), "type": "refresh"},
            expires_delta=timedelta(days=REFRESH_TOKEN_EXPIRE)
        )
        
        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer"
        }
    
    def _increment_attempts(self, email: str):
        key = f"login_attempts:{email}"
        pipe = self.redis.pipeline()
        pipe.incr(key)
        pipe.expire(key, LOCKOUT_DURATION)
        pipe.execute()
    
    def _create_token(self, data: dict, expires_delta: timedelta) -> str:
        to_encode = data.copy()
        expire = datetime.utcnow() + expires_delta
        to_encode.update({"exp": expire, "iat": datetime.utcnow()})
        return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
```

---

### A08-A10: Integrity, Logging, SSRF

#### XSS Prevention
```javascript
// ❌ VULNERABLE: innerHTML with user content
element.innerHTML = userInput;

// ❌ VULNERABLE: dangerouslySetInnerHTML
<div dangerouslySetInnerHTML={{ __html: userContent }} />


// ✅ SECURE: Text content only
element.textContent = userInput;

// ✅ SECURE: React auto-escaping
<div>{userContent}</div>

// ✅ SECURE: Sanitize if HTML needed
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userContent) }} />
```

#### Security Logging
```python
import structlog
from datetime import datetime

logger = structlog.get_logger()


class SecurityLogger:
    """Centralized security event logging."""
    
    @staticmethod
    def log_auth_success(user_id: str, ip: str, user_agent: str):
        logger.info(
            "auth.login.success",
            user_id=user_id,
            ip=ip,
            user_agent=user_agent,
            timestamp=datetime.utcnow().isoformat()
        )
    
    @staticmethod
    def log_auth_failure(email: str, ip: str, reason: str):
        logger.warning(
            "auth.login.failure",
            email_hash=hash_email(email),  # Don't log raw email
            ip=ip,
            reason=reason,
            timestamp=datetime.utcnow().isoformat()
        )
    
    @staticmethod
    def log_suspicious_activity(
        event_type: str,
        user_id: str | None,
        ip: str,
        details: dict
    ):
        logger.warning(
            "security.suspicious",
            event_type=event_type,
            user_id=user_id,
            ip=ip,
            details=details,
            timestamp=datetime.utcnow().isoformat()
        )
    
    @staticmethod
    def log_access_denied(
        user_id: str,
        resource: str,
        action: str,
        ip: str
    ):
        logger.warning(
            "security.access_denied",
            user_id=user_id,
            resource=resource,
            action=action,
            ip=ip,
            timestamp=datetime.utcnow().isoformat()
        )


# Usage
SecurityLogger.log_auth_failure(
    email=request.email,
    ip=request.client.host,
    reason="invalid_password"
)
```

#### SSRF Prevention
```python
# ❌ VULNERABLE: Fetch arbitrary URLs
import requests

@app.post("/fetch-url")
def fetch_url(url: str):
    response = requests.get(url)  # SSRF vulnerability!
    return response.text


# ✅ SECURE: URL validation
from urllib.parse import urlparse
import ipaddress

ALLOWED_HOSTS = ["api.example.com", "cdn.example.com"]
BLOCKED_NETWORKS = [
    ipaddress.ip_network("10.0.0.0/8"),
    ipaddress.ip_network("172.16.0.0/12"),
    ipaddress.ip_network("192.168.0.0/16"),
    ipaddress.ip_network("127.0.0.0/8"),
]


def is_safe_url(url: str) -> bool:
    """Validate URL is safe to fetch."""
    try:
        parsed = urlparse(url)
        
        # Must be HTTPS
        if parsed.scheme != "https":
            return False
        
        # Check allowed hosts
        if parsed.hostname not in ALLOWED_HOSTS:
            return False
        
        # Resolve and check IP
        ip = socket.gethostbyname(parsed.hostname)
        ip_obj = ipaddress.ip_address(ip)
        
        for network in BLOCKED_NETWORKS:
            if ip_obj in network:
                return False
        
        return True
        
    except Exception:
        return False


@app.post("/fetch-url")
def fetch_url(url: str):
    if not is_safe_url(url):
        raise HTTPException(400, "URL not allowed")
    
    response = requests.get(url, timeout=5)
    return response.text
```

---

## 3) Automated Security Scanning

### CI/CD Security Pipeline
```yaml
# .github/workflows/security.yml
name: Security Pipeline

on:
  push:
    branches: [main]
  pull_request:
  schedule:
    - cron: '0 0 * * *'  # Daily

jobs:
  # SAST - Static Analysis
  sast:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Semgrep SAST
        uses: semgrep/semgrep-action@v1
        with:
          config: >-
            p/security-audit
            p/owasp-top-ten
            p/python
            p/javascript
      
      - name: CodeQL Analysis
        uses: github/codeql-action/analyze@v2

  # Dependency Scanning
  dependencies:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Python - pip-audit
        run: |
          pip install pip-audit
          pip-audit -r requirements.txt
      
      - name: Node - npm audit
        run: npm audit --audit-level=high
      
      - name: Snyk Scan
        uses: snyk/actions/python@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

  # Secret Scanning
  secrets:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: TruffleHog Secret Scan
        uses: trufflesecurity/trufflehog@main
        with:
          extra_args: --only-verified

  # Container Scanning
  container:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build image
        run: docker build -t myapp:test .
      
      - name: Trivy Container Scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'myapp:test'
          severity: 'HIGH,CRITICAL'
          exit-code: '1'
```

---

## 4) Vulnerability Report Template

```markdown
## Security Vulnerability Report

### Executive Summary
[Brief overview of findings]

### Risk Summary
| Severity | Count | Status |
|----------|-------|--------|
| Critical | X | Action Required |
| High | X | Action Required |
| Medium | X | Review Needed |
| Low | X | Consider Fixing |

---

## Findings

### [CRITICAL] SQL Injection in User Search

**CWE:** CWE-89
**CVSS:** 9.8 (Critical)
**Location:** `src/api/users.py:45`

**Description:**
User input is concatenated directly into SQL query without sanitization.

**Impact:**
- Full database read access
- Data modification/deletion
- Potential RCE via SQL features

**Proof of Concept:**
```
GET /api/users?search=admin' OR '1'='1
```

**Remediation:**
Use parameterized queries:
```python
# Before
query = f"SELECT * FROM users WHERE name = '{search}'"

# After
query = "SELECT * FROM users WHERE name = %s"
cursor.execute(query, (search,))
```

**References:**
- [OWASP SQL Injection](https://owasp.org/www-community/attacks/SQL_Injection)
- [CWE-89](https://cwe.mitre.org/data/definitions/89.html)

---

### [HIGH] Missing Rate Limiting

**CWE:** CWE-307
...

[Continue for each vulnerability]
```

---

## 5) Security Audit Checklist

```markdown
## Pre-Deployment Security Checklist

### Authentication & Authorization
- [ ] Passwords hashed with Argon2 or bcrypt
- [ ] JWT tokens properly validated
- [ ] Session tokens are HttpOnly, Secure, SameSite
- [ ] Account lockout after failed attempts
- [ ] MFA available for sensitive operations
- [ ] All endpoints require authentication
- [ ] RBAC/ABAC properly implemented
- [ ] IDOR protection in place

### Input Validation
- [ ] All inputs validated server-side
- [ ] SQL injection prevented (parameterized queries)
- [ ] XSS prevented (output encoding)
- [ ] Command injection prevented
- [ ] File upload validation
- [ ] API rate limiting

### Cryptography
- [ ] TLS 1.3 enforced
- [ ] Strong cipher suites only
- [ ] Secrets in environment variables
- [ ] Sensitive data encrypted at rest
- [ ] No hardcoded credentials

### Security Headers
- [ ] Strict-Transport-Security
- [ ] Content-Security-Policy
- [ ] X-Content-Type-Options
- [ ] X-Frame-Options
- [ ] Referrer-Policy

### Logging & Monitoring
- [ ] Security events logged
- [ ] Logs don't contain sensitive data
- [ ] Alerting configured
- [ ] Log integrity protected

### Dependencies
- [ ] All dependencies up to date
- [ ] No known vulnerabilities
- [ ] Automated vulnerability scanning
```

---

## Best Practices Summary

- [ ] Follow OWASP Top 10 guidelines
- [ ] Implement defense in depth
- [ ] Use parameterized queries (no string concat)
- [ ] Hash passwords with Argon2/bcrypt
- [ ] Validate all input server-side
- [ ] Escape all output for context
- [ ] Use security headers
- [ ] Log security events
- [ ] Scan dependencies regularly
- [ ] Conduct regular security reviews

---

**References:**
- [OWASP Top 10](https://owasp.org/Top10/)
- [CWE/SANS Top 25](https://cwe.mitre.org/top25/)
- [OWASP Cheat Sheets](https://cheatsheetseries.owasp.org/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

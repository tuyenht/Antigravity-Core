# Python Security Best Practices

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Python:** 3.11+ | **OWASP:** 2024
> **Priority:** P0 - Load for ALL Python projects

---

You are an expert in Python security and secure coding practices.

## Key Principles

- Never trust user input
- Use principle of least privilege
- Keep dependencies updated
- Implement defense in depth
- Follow OWASP guidelines
- Use type hints for safety

---

## Password Hashing

### Argon2 (Recommended)
```python
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError


class PasswordService:
    """Secure password hashing with Argon2."""
    
    def __init__(self):
        # Use recommended parameters
        self.hasher = PasswordHasher(
            time_cost=3,        # iterations
            memory_cost=65536,  # 64 MB
            parallelism=4,      # threads
            hash_len=32,        # output length
            salt_len=16,        # salt length
        )
    
    def hash_password(self, password: str) -> str:
        """Hash a password."""
        return self.hasher.hash(password)
    
    def verify_password(self, password: str, hash: str) -> bool:
        """Verify password against hash."""
        try:
            self.hasher.verify(hash, password)
            return True
        except VerifyMismatchError:
            return False
    
    def needs_rehash(self, hash: str) -> bool:
        """Check if hash needs updating."""
        return self.hasher.check_needs_rehash(hash)


# Usage
password_service = PasswordService()

# Hash password
hashed = password_service.hash_password("user_password")

# Verify
is_valid = password_service.verify_password("user_password", hashed)

# Rehash if needed (e.g., after updating parameters)
if password_service.needs_rehash(hashed):
    new_hash = password_service.hash_password("user_password")
```

### bcrypt (Alternative)
```python
import bcrypt


def hash_password(password: str) -> bytes:
    """Hash password with bcrypt."""
    salt = bcrypt.gensalt(rounds=12)
    return bcrypt.hashpw(password.encode(), salt)


def verify_password(password: str, hashed: bytes) -> bool:
    """Verify password."""
    return bcrypt.checkpw(password.encode(), hashed)
```

---

## JWT Authentication

### Secure JWT Implementation
```python
from datetime import datetime, timedelta, timezone
from typing import Any
from jose import jwt, JWTError
from pydantic import BaseModel, Field
from secrets import token_urlsafe


class JWTConfig(BaseModel):
    """JWT configuration."""
    secret_key: str = Field(min_length=32)
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 15
    refresh_token_expire_days: int = 7


class TokenPayload(BaseModel):
    """Token payload model."""
    sub: str  # Subject (user ID)
    exp: datetime
    iat: datetime
    jti: str  # Unique token ID
    type: str  # "access" or "refresh"
    roles: list[str] = []


class JWTService:
    """Secure JWT service."""
    
    def __init__(self, config: JWTConfig):
        self.config = config
        self._revoked_tokens: set[str] = set()  # Use Redis in production
    
    def create_access_token(
        self,
        subject: str,
        roles: list[str] = [],
        extra_claims: dict[str, Any] = {},
    ) -> str:
        """Create access token."""
        now = datetime.now(timezone.utc)
        expire = now + timedelta(minutes=self.config.access_token_expire_minutes)
        
        payload = {
            "sub": subject,
            "exp": expire,
            "iat": now,
            "jti": token_urlsafe(16),
            "type": "access",
            "roles": roles,
            **extra_claims,
        }
        
        return jwt.encode(
            payload,
            self.config.secret_key,
            algorithm=self.config.algorithm,
        )
    
    def create_refresh_token(self, subject: str) -> str:
        """Create refresh token."""
        now = datetime.now(timezone.utc)
        expire = now + timedelta(days=self.config.refresh_token_expire_days)
        
        payload = {
            "sub": subject,
            "exp": expire,
            "iat": now,
            "jti": token_urlsafe(16),
            "type": "refresh",
        }
        
        return jwt.encode(
            payload,
            self.config.secret_key,
            algorithm=self.config.algorithm,
        )
    
    def verify_token(self, token: str, token_type: str = "access") -> TokenPayload:
        """Verify and decode token."""
        try:
            payload = jwt.decode(
                token,
                self.config.secret_key,
                algorithms=[self.config.algorithm],
            )
            
            token_payload = TokenPayload(**payload)
            
            # Check token type
            if token_payload.type != token_type:
                raise ValueError(f"Invalid token type: expected {token_type}")
            
            # Check if revoked
            if token_payload.jti in self._revoked_tokens:
                raise ValueError("Token has been revoked")
            
            return token_payload
            
        except JWTError as e:
            raise ValueError(f"Invalid token: {e}")
    
    def revoke_token(self, token: str) -> None:
        """Revoke a token."""
        try:
            payload = jwt.decode(
                token,
                self.config.secret_key,
                algorithms=[self.config.algorithm],
            )
            self._revoked_tokens.add(payload["jti"])
        except JWTError:
            pass  # Already invalid


# Usage
jwt_service = JWTService(JWTConfig(
    secret_key="your-256-bit-secret-key-minimum-32-chars",
))

# Create tokens
access_token = jwt_service.create_access_token(
    subject="user_123",
    roles=["admin", "user"],
)
refresh_token = jwt_service.create_refresh_token(subject="user_123")

# Verify
payload = jwt_service.verify_token(access_token, token_type="access")
print(f"User: {payload.sub}, Roles: {payload.roles}")
```

---

## FastAPI Security

### OAuth2 with JWT
```python
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel, EmailStr


app = FastAPI()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")


class User(BaseModel):
    id: str
    email: EmailStr
    roles: list[str] = []
    is_active: bool = True


class UserService:
    """User service with authentication."""
    
    def __init__(
        self,
        password_service: PasswordService,
        jwt_service: JWTService,
    ):
        self.password_service = password_service
        self.jwt_service = jwt_service
    
    async def authenticate(self, email: str, password: str) -> User | None:
        """Authenticate user."""
        user = await self.get_user_by_email(email)
        
        if not user:
            # Prevent timing attacks
            self.password_service.hash_password("dummy")
            return None
        
        if not self.password_service.verify_password(password, user.password_hash):
            return None
        
        return user
    
    async def get_user_by_email(self, email: str) -> User | None:
        """Get user by email (implement with your database)."""
        # ... database query
        pass


async def get_current_user(
    token: str = Depends(oauth2_scheme),
) -> User:
    """Dependency to get current user from token."""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        payload = jwt_service.verify_token(token)
        user_id = payload.sub
        
        if user_id is None:
            raise credentials_exception
            
    except ValueError:
        raise credentials_exception
    
    user = await user_service.get_user_by_id(user_id)
    
    if user is None:
        raise credentials_exception
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Inactive user",
        )
    
    return user


def require_roles(required_roles: list[str]):
    """Dependency factory for role-based access control."""
    
    async def role_checker(user: User = Depends(get_current_user)) -> User:
        if not any(role in user.roles for role in required_roles):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions",
            )
        return user
    
    return role_checker


# Routes
@app.post("/token")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    """Login endpoint."""
    user = await user_service.authenticate(form_data.username, form_data.password)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token = jwt_service.create_access_token(
        subject=user.id,
        roles=user.roles,
    )
    refresh_token = jwt_service.create_refresh_token(subject=user.id)
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
    }


@app.get("/users/me")
async def read_users_me(current_user: User = Depends(get_current_user)):
    """Get current user."""
    return current_user


@app.get("/admin/dashboard")
async def admin_dashboard(
    current_user: User = Depends(require_roles(["admin"])),
):
    """Admin only endpoint."""
    return {"message": "Welcome, admin!"}
```

---

## Input Validation

### Pydantic Validation
```python
from pydantic import (
    BaseModel,
    Field,
    EmailStr,
    SecretStr,
    field_validator,
    model_validator,
)
import re
from typing import Annotated


class UserCreate(BaseModel):
    """Secure user creation model."""
    
    email: EmailStr
    password: SecretStr = Field(min_length=12)
    username: str = Field(min_length=3, max_length=30, pattern=r"^[a-zA-Z0-9_]+$")
    
    @field_validator("password")
    @classmethod
    def validate_password(cls, v: SecretStr) -> SecretStr:
        password = v.get_secret_value()
        
        if not re.search(r"[A-Z]", password):
            raise ValueError("Password must contain uppercase letter")
        if not re.search(r"[a-z]", password):
            raise ValueError("Password must contain lowercase letter")
        if not re.search(r"\d", password):
            raise ValueError("Password must contain digit")
        if not re.search(r"[!@#$%^&*(),.?\":{}|<>]", password):
            raise ValueError("Password must contain special character")
        
        return v
    
    @field_validator("username")
    @classmethod
    def validate_username(cls, v: str) -> str:
        # Prevent reserved names
        reserved = {"admin", "root", "system", "api", "www"}
        if v.lower() in reserved:
            raise ValueError("Username is reserved")
        return v


class SearchQuery(BaseModel):
    """Safe search query model."""
    
    query: str = Field(max_length=100)
    page: int = Field(ge=1, le=1000, default=1)
    limit: int = Field(ge=1, le=100, default=20)
    
    @field_validator("query")
    @classmethod
    def sanitize_query(cls, v: str) -> str:
        # Remove potential SQL injection patterns
        dangerous_patterns = [
            r"['\";]",
            r"--",
            r"/\*.*\*/",
            r"\b(union|select|insert|update|delete|drop|exec)\b",
        ]
        
        for pattern in dangerous_patterns:
            if re.search(pattern, v, re.IGNORECASE):
                raise ValueError("Invalid characters in query")
        
        return v.strip()


class FileUpload(BaseModel):
    """Secure file upload validation."""
    
    filename: str
    content_type: str
    size: int = Field(le=10 * 1024 * 1024)  # 10 MB max
    
    ALLOWED_TYPES = {
        "image/jpeg": [".jpg", ".jpeg"],
        "image/png": [".png"],
        "image/gif": [".gif"],
        "application/pdf": [".pdf"],
    }
    
    @model_validator(mode="after")
    def validate_file(self) -> "FileUpload":
        # Check content type
        if self.content_type not in self.ALLOWED_TYPES:
            raise ValueError(f"File type not allowed: {self.content_type}")
        
        # Check extension matches content type
        import os
        ext = os.path.splitext(self.filename)[1].lower()
        
        if ext not in self.ALLOWED_TYPES[self.content_type]:
            raise ValueError("File extension doesn't match content type")
        
        return self
```

---

## SQL Injection Prevention

### SQLAlchemy Safe Patterns
```python
from sqlalchemy import select, text
from sqlalchemy.orm import Session
from sqlalchemy.ext.asyncio import AsyncSession


# ❌ WRONG - SQL Injection vulnerable
def get_user_unsafe(db: Session, username: str):
    query = f"SELECT * FROM users WHERE username = '{username}'"
    return db.execute(text(query)).fetchone()


# ✅ CORRECT - Parameterized query
def get_user_safe(db: Session, username: str):
    # Using ORM
    stmt = select(User).where(User.username == username)
    return db.execute(stmt).scalar_one_or_none()


# ✅ CORRECT - Parameterized raw query
def get_user_raw_safe(db: Session, username: str):
    query = text("SELECT * FROM users WHERE username = :username")
    return db.execute(query, {"username": username}).fetchone()


# ✅ CORRECT - Dynamic queries safely
def search_users(
    db: Session,
    name: str | None = None,
    email: str | None = None,
    role: str | None = None,
) -> list[User]:
    stmt = select(User)
    
    if name:
        stmt = stmt.where(User.name.ilike(f"%{name}%"))
    if email:
        stmt = stmt.where(User.email == email)
    if role:
        stmt = stmt.where(User.role == role)
    
    return db.execute(stmt).scalars().all()


# ✅ CORRECT - Async pattern
async def get_user_async(db: AsyncSession, user_id: str) -> User | None:
    stmt = select(User).where(User.id == user_id)
    result = await db.execute(stmt)
    return result.scalar_one_or_none()
```

---

## XSS Prevention

### HTML Sanitization
```python
import bleach
from markupsafe import escape, Markup


class HTMLSanitizer:
    """HTML sanitization for user content."""
    
    # Safe tags and attributes
    ALLOWED_TAGS = [
        "p", "br", "strong", "em", "u", "s",
        "h1", "h2", "h3", "h4", "h5", "h6",
        "ul", "ol", "li",
        "a", "blockquote", "code", "pre",
    ]
    
    ALLOWED_ATTRIBUTES = {
        "a": ["href", "title"],
        "img": ["src", "alt", "title"],
    }
    
    ALLOWED_PROTOCOLS = ["http", "https", "mailto"]
    
    @classmethod
    def sanitize(cls, html: str) -> str:
        """Sanitize HTML content."""
        return bleach.clean(
            html,
            tags=cls.ALLOWED_TAGS,
            attributes=cls.ALLOWED_ATTRIBUTES,
            protocols=cls.ALLOWED_PROTOCOLS,
            strip=True,
        )
    
    @classmethod
    def escape(cls, text: str) -> str:
        """Escape HTML characters."""
        return str(escape(text))
    
    @classmethod
    def linkify(cls, text: str) -> str:
        """Convert URLs to safe links."""
        return bleach.linkify(
            bleach.clean(text),
            callbacks=[cls._add_nofollow],
        )
    
    @staticmethod
    def _add_nofollow(attrs, new=False):
        """Add nofollow to external links."""
        attrs[(None, "rel")] = "nofollow noopener noreferrer"
        attrs[(None, "target")] = "_blank"
        return attrs


# Usage
user_input = '<script>alert("xss")</script><p>Hello</p>'
safe_html = HTMLSanitizer.sanitize(user_input)
# Result: '<p>Hello</p>'

# In templates (Jinja2)
# {{ user_content | e }}  # Auto-escape
# {{ safe_content | safe }}  # Mark as safe (only for sanitized content)
```

---

## Rate Limiting

### FastAPI Rate Limiting
```python
from fastapi import FastAPI, Request, HTTPException
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware


# Create limiter
limiter = Limiter(
    key_func=get_remote_address,
    default_limits=["100/minute"],
)

app = FastAPI()
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.add_middleware(SlowAPIMiddleware)


# Per-endpoint limits
@app.get("/api/data")
@limiter.limit("30/minute")
async def get_data(request: Request):
    return {"data": "example"}


@app.post("/auth/login")
@limiter.limit("5/minute")  # Stricter for auth
async def login(request: Request):
    return {"token": "..."}


@app.post("/api/expensive-operation")
@limiter.limit("3/hour")  # Very strict
async def expensive_operation(request: Request):
    return {"result": "..."}


# Custom key function (e.g., by user ID)
def get_user_id(request: Request) -> str:
    """Get user ID from JWT token."""
    auth = request.headers.get("Authorization", "")
    if auth.startswith("Bearer "):
        # Parse JWT and extract user ID
        pass
    return get_remote_address(request)


@app.get("/api/user-limited")
@limiter.limit("100/hour", key_func=get_user_id)
async def user_limited(request: Request):
    return {"data": "..."}
```

---

## Security Headers

### Security Headers Middleware
```python
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import Response


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """Add security headers to all responses."""
    
    async def dispatch(self, request: Request, call_next) -> Response:
        response = await call_next(request)
        
        # Content Security Policy
        response.headers["Content-Security-Policy"] = (
            "default-src 'self'; "
            "script-src 'self' 'unsafe-inline'; "
            "style-src 'self' 'unsafe-inline'; "
            "img-src 'self' data: https:; "
            "font-src 'self'; "
            "frame-ancestors 'none'; "
            "form-action 'self';"
        )
        
        # Prevent MIME sniffing
        response.headers["X-Content-Type-Options"] = "nosniff"
        
        # Prevent clickjacking
        response.headers["X-Frame-Options"] = "DENY"
        
        # Enable XSS filter
        response.headers["X-XSS-Protection"] = "1; mode=block"
        
        # HSTS (HTTPS only)
        response.headers["Strict-Transport-Security"] = (
            "max-age=31536000; includeSubDomains; preload"
        )
        
        # Referrer policy
        response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
        
        # Permissions policy
        response.headers["Permissions-Policy"] = (
            "camera=(), microphone=(), geolocation=(), "
            "payment=(), usb=()"
        )
        
        return response


# Apply middleware
app = FastAPI()
app.add_middleware(SecurityHeadersMiddleware)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://myapp.com"],  # Never use ["*"] in production
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["Authorization", "Content-Type"],
    max_age=600,  # Cache preflight for 10 minutes
)
```

---

## Secrets Management

### Environment Variables
```python
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import SecretStr, Field
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings with secrets."""
    
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )
    
    # Database
    database_url: SecretStr
    
    # JWT
    jwt_secret_key: SecretStr = Field(min_length=32)
    jwt_algorithm: str = "HS256"
    
    # API Keys
    stripe_api_key: SecretStr
    sendgrid_api_key: SecretStr
    
    # AWS
    aws_access_key_id: SecretStr
    aws_secret_access_key: SecretStr


@lru_cache
def get_settings() -> Settings:
    """Get cached settings."""
    return Settings()


# Usage
settings = get_settings()
database_url = settings.database_url.get_secret_value()

# Never log secrets!
# ❌ WRONG: print(f"DB URL: {settings.database_url}")
# ✅ CORRECT: print("DB URL: ***")
```

---

## Security Scanning

### Bandit Configuration
```toml
# pyproject.toml
[tool.bandit]
exclude_dirs = ["tests", ".venv"]
skips = []
tests = [
    "B101",  # assert_used
    "B102",  # exec_used
    "B103",  # set_bad_file_permissions
    "B104",  # hardcoded_bind_all_interfaces
    "B105",  # hardcoded_password_string
    "B106",  # hardcoded_password_funcarg
    "B107",  # hardcoded_password_default
    "B108",  # hardcoded_tmp_directory
    "B110",  # try_except_pass
    "B112",  # try_except_continue
    "B201",  # flask_debug_true
    "B301",  # pickle
    "B302",  # marshal
    "B303",  # md5
    "B304",  # des
    "B305",  # cipher
    "B306",  # mktemp_q
    "B307",  # eval
    "B308",  # mark_safe
    "B310",  # urllib_urlopen
    "B311",  # random
    "B312",  # telnetlib
    "B313",  # xml_bad_cElementTree
    "B314",  # xml_bad_ElementTree
    "B315",  # xml_bad_expatreader
    "B316",  # xml_bad_expatbuilder
    "B317",  # xml_bad_sax
    "B318",  # xml_bad_minidom
    "B319",  # xml_bad_pulldom
    "B320",  # xml_bad_etree
    "B321",  # ftplib
    "B323",  # unverified_context
    "B324",  # hashlib_insecure_functions
    "B501",  # request_with_no_cert_validation
    "B502",  # ssl_with_bad_version
    "B503",  # ssl_with_bad_defaults
    "B504",  # ssl_with_no_version
    "B505",  # weak_cryptographic_key
    "B506",  # yaml_load
    "B507",  # ssh_no_host_key_verification
    "B508",  # snmp_insecure_version
    "B509",  # snmp_weak_cryptography
    "B601",  # paramiko_calls
    "B602",  # subprocess_popen_with_shell_equals_true
    "B603",  # subprocess_without_shell_equals_true
    "B604",  # any_other_function_with_shell_equals_true
    "B605",  # start_process_with_a_shell
    "B606",  # start_process_with_no_shell
    "B607",  # start_process_with_partial_path
    "B608",  # hardcoded_sql_expressions
    "B609",  # linux_commands_wildcard_injection
    "B610",  # django_extra_used
    "B611",  # django_rawsql_used
    "B701",  # jinja2_autoescape_false
    "B702",  # use_of_mako_templates
    "B703",  # django_mark_safe
]
```

### pip-audit Integration
```bash
# Run security audit
pip-audit

# With JSON output
pip-audit --format=json --output=audit-report.json

# Fix vulnerabilities
pip-audit --fix

# Ignore specific vulnerabilities
pip-audit --ignore-vuln GHSA-xxxx-xxxx-xxxx
```

### CI/CD Security Pipeline
```yaml
# .github/workflows/security.yml
name: Security Scan

on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      
      - name: Install dependencies
        run: pip install bandit pip-audit safety
      
      - name: Run Bandit
        run: bandit -r src -f json -o bandit-report.json
        continue-on-error: true
      
      - name: Run pip-audit
        run: pip-audit --format=json --output=pip-audit-report.json
        continue-on-error: true
      
      - name: Run Safety
        run: safety check --json > safety-report.json
        continue-on-error: true
      
      - name: Upload reports
        uses: actions/upload-artifact@v4
        with:
          name: security-reports
          path: "*-report.json"
```

---

## Cryptography

### Secure Encryption
```python
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.backends import default_backend
import base64
import secrets


class Encryption:
    """Secure encryption utilities."""
    
    @staticmethod
    def generate_key() -> bytes:
        """Generate a new Fernet key."""
        return Fernet.generate_key()
    
    @staticmethod
    def derive_key(password: str, salt: bytes) -> bytes:
        """Derive key from password."""
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=600_000,  # OWASP recommendation
            backend=default_backend(),
        )
        key = base64.urlsafe_b64encode(kdf.derive(password.encode()))
        return key
    
    @staticmethod
    def encrypt(data: bytes, key: bytes) -> bytes:
        """Encrypt data with Fernet."""
        f = Fernet(key)
        return f.encrypt(data)
    
    @staticmethod
    def decrypt(encrypted: bytes, key: bytes) -> bytes:
        """Decrypt data with Fernet."""
        f = Fernet(key)
        return f.decrypt(encrypted)
    
    @staticmethod
    def generate_token(length: int = 32) -> str:
        """Generate secure random token."""
        return secrets.token_urlsafe(length)
    
    @staticmethod
    def generate_salt(length: int = 16) -> bytes:
        """Generate random salt."""
        return secrets.token_bytes(length)


# Usage
key = Encryption.generate_key()
encrypted = Encryption.encrypt(b"sensitive data", key)
decrypted = Encryption.decrypt(encrypted, key)
```

---

## Best Practices Checklist

- [ ] Use Argon2 for password hashing
- [ ] Implement JWT with short expiration
- [ ] Validate all inputs with Pydantic
- [ ] Use parameterized SQL queries
- [ ] Sanitize HTML output
- [ ] Implement rate limiting
- [ ] Add security headers middleware
- [ ] Use environment variables for secrets
- [ ] Run Bandit and pip-audit in CI/CD
- [ ] Keep dependencies updated

---

**References:**
- [OWASP Python Security](https://cheatsheetseries.owasp.org/cheatsheets/Python_Security_Cheat_Sheet.html)
- [Argon2 Documentation](https://argon2-cffi.readthedocs.io/)
- [FastAPI Security](https://fastapi.tiangolo.com/tutorial/security/)
- [Bandit Documentation](https://bandit.readthedocs.io/)

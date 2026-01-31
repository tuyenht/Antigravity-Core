# FastAPI Python Framework Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **FastAPI Version:** 0.100+ | **Pydantic:** v2
> **Priority:** P0 - Load for all FastAPI projects

---

You are an expert in FastAPI for building high-performance Python APIs.

## Key Principles

- High performance (Starlette + Pydantic)
- Type hints as first-class citizens
- Automatic OpenAPI documentation
- Async-first with sync fallback
- Dependency injection built-in
- Standards-based (OpenAPI 3.1, JSON Schema)

---

## Project Structure

```
src/
├── main.py                 # Application entry point
├── config.py               # Settings management
├── database.py             # Database setup
├── dependencies.py         # Shared dependencies
├── routers/
│   ├── __init__.py
│   ├── users.py
│   ├── posts.py
│   └── auth.py
├── models/                 # SQLAlchemy models
│   ├── __init__.py
│   ├── user.py
│   └── post.py
├── schemas/                # Pydantic schemas
│   ├── __init__.py
│   ├── user.py
│   └── post.py
├── services/               # Business logic
│   ├── __init__.py
│   └── user_service.py
├── utils/
│   ├── security.py
│   └── exceptions.py
└── tests/
    ├── conftest.py
    ├── test_users.py
    └── test_auth.py
```

---

## Application Setup

### main.py
```python
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware

from .config import settings
from .database import engine, Base
from .routers import users, posts, auth
from .utils.exceptions import register_exception_handlers


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifespan context manager for startup and shutdown."""
    # Startup
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    print("Database tables created")
    
    yield  # Application runs here
    
    # Shutdown
    await engine.dispose()
    print("Database connection closed")


app = FastAPI(
    title="My API",
    description="High-performance API built with FastAPI",
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs" if settings.debug else None,
    redoc_url="/redoc" if settings.debug else None,
)

# Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

if not settings.debug:
    app.add_middleware(
        TrustedHostMiddleware,
        allowed_hosts=settings.allowed_hosts,
    )

# Exception handlers
register_exception_handlers(app)

# Routers
app.include_router(auth.router, prefix="/api/v1/auth", tags=["Auth"])
app.include_router(users.router, prefix="/api/v1/users", tags=["Users"])
app.include_router(posts.router, prefix="/api/v1/posts", tags=["Posts"])


@app.get("/health")
async def health_check():
    return {"status": "healthy"}
```

---

## Configuration (pydantic-settings)

### config.py
```python
from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )
    
    # App
    debug: bool = False
    app_name: str = "My API"
    
    # Database
    database_url: str
    database_echo: bool = False
    
    # Security
    secret_key: str
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 7
    
    # CORS
    cors_origins: list[str] = ["http://localhost:3000"]
    allowed_hosts: list[str] = ["localhost", "example.com"]
    
    # Redis (optional)
    redis_url: str | None = None


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
```

---

## Pydantic v2 Schemas

### schemas/user.py
```python
from datetime import datetime
from pydantic import BaseModel, EmailStr, Field, ConfigDict, field_validator
from typing import Annotated


# Base schema with common fields
class UserBase(BaseModel):
    email: EmailStr
    name: Annotated[str, Field(min_length=2, max_length=100)]


# Input schema for creation
class UserCreate(UserBase):
    password: Annotated[str, Field(min_length=8, max_length=100)]
    
    @field_validator("password")
    @classmethod
    def validate_password(cls, v: str) -> str:
        if not any(c.isupper() for c in v):
            raise ValueError("Password must contain uppercase letter")
        if not any(c.isdigit() for c in v):
            raise ValueError("Password must contain digit")
        return v


# Input schema for update (all optional)
class UserUpdate(BaseModel):
    email: EmailStr | None = None
    name: Annotated[str, Field(min_length=2, max_length=100)] | None = None
    

# Output schema (what API returns)
class UserResponse(UserBase):
    model_config = ConfigDict(from_attributes=True)
    
    id: int
    role: str
    is_active: bool
    created_at: datetime
    updated_at: datetime | None = None


# Schema with relationships
class UserWithPosts(UserResponse):
    posts: list["PostResponse"] = []


# Pagination response
class PaginatedUsers(BaseModel):
    items: list[UserResponse]
    total: int
    page: int
    per_page: int
    pages: int
```

### schemas/common.py
```python
from pydantic import BaseModel, Field
from typing import Generic, TypeVar

T = TypeVar("T")


class PaginatedResponse(BaseModel, Generic[T]):
    items: list[T]
    total: int
    page: int
    per_page: int
    pages: int


class MessageResponse(BaseModel):
    message: str


class ErrorDetail(BaseModel):
    loc: list[str | int]
    msg: str
    type: str


class ErrorResponse(BaseModel):
    detail: str | list[ErrorDetail]
```

---

## SQLAlchemy 2.0 Async

### database.py
```python
from sqlalchemy.ext.asyncio import (
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy.orm import DeclarativeBase

from .config import settings


# Create async engine
engine = create_async_engine(
    settings.database_url,
    echo=settings.database_echo,
    pool_pre_ping=True,
    pool_size=5,
    max_overflow=10,
)

# Session factory
async_session_maker = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autoflush=False,
)


class Base(DeclarativeBase):
    pass


# Dependency for getting database session
async def get_db() -> AsyncSession:
    async with async_session_maker() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
```

### models/user.py
```python
from datetime import datetime
from sqlalchemy import String, Boolean, DateTime, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ..database import Base


class User(Base):
    __tablename__ = "users"
    
    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    name: Mapped[str] = mapped_column(String(100))
    hashed_password: Mapped[str] = mapped_column(String(255))
    role: Mapped[str] = mapped_column(String(20), default="user")
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
    )
    updated_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        onupdate=func.now(),
    )
    
    # Relationships
    posts: Mapped[list["Post"]] = relationship(
        back_populates="author",
        lazy="selectin",
    )
    
    def __repr__(self) -> str:
        return f"User(id={self.id}, email={self.email})"
```

---

## Routers

### routers/users.py
```python
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from ..database import get_db
from ..models.user import User
from ..schemas.user import (
    UserCreate,
    UserUpdate,
    UserResponse,
    PaginatedUsers,
)
from ..dependencies import get_current_user, get_current_admin
from ..services.user_service import UserService

router = APIRouter()


@router.get("", response_model=PaginatedUsers)
async def list_users(
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    search: str | None = None,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_admin),
):
    """List all users with pagination (admin only)."""
    service = UserService(db)
    return await service.get_paginated(page, per_page, search)


@router.get("/me", response_model=UserResponse)
async def get_current_user_profile(
    current_user: User = Depends(get_current_user),
):
    """Get current user's profile."""
    return current_user


@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get user by ID."""
    service = UserService(db)
    user = await service.get_by_id(user_id)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
    
    return user


@router.post("", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    user_data: UserCreate,
    db: AsyncSession = Depends(get_db),
):
    """Create a new user."""
    service = UserService(db)
    
    # Check if email exists
    existing = await service.get_by_email(user_data.email)
    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already registered",
        )
    
    return await service.create(user_data)


@router.patch("/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: int,
    user_data: UserUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Update user (own profile or admin)."""
    if current_user.id != user_id and current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to update this user",
        )
    
    service = UserService(db)
    user = await service.update(user_id, user_data)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
    
    return user


@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_admin),
):
    """Delete user (admin only)."""
    service = UserService(db)
    deleted = await service.delete(user_id)
    
    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
```

---

## Dependency Injection

### dependencies.py
```python
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from sqlalchemy.ext.asyncio import AsyncSession

from .config import settings
from .database import get_db
from .models.user import User
from .services.user_service import UserService

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db),
) -> User:
    """Dependency to get current authenticated user."""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        payload = jwt.decode(
            token,
            settings.secret_key,
            algorithms=[settings.algorithm],
        )
        user_id: int = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    service = UserService(db)
    user = await service.get_by_id(user_id)
    
    if user is None:
        raise credentials_exception
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Inactive user",
        )
    
    return user


async def get_current_admin(
    current_user: User = Depends(get_current_user),
) -> User:
    """Dependency to require admin role."""
    if current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required",
        )
    return current_user


def get_pagination(
    page: int = 1,
    per_page: int = 20,
) -> dict:
    """Reusable pagination dependency."""
    return {
        "skip": (page - 1) * per_page,
        "limit": per_page,
        "page": page,
        "per_page": per_page,
    }
```

---

## Services

### services/user_service.py
```python
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from ..models.user import User
from ..schemas.user import UserCreate, UserUpdate, PaginatedUsers
from ..utils.security import get_password_hash


class UserService:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def get_by_id(self, user_id: int) -> User | None:
        result = await self.db.execute(
            select(User).where(User.id == user_id)
        )
        return result.scalar_one_or_none()
    
    async def get_by_email(self, email: str) -> User | None:
        result = await self.db.execute(
            select(User).where(User.email == email)
        )
        return result.scalar_one_or_none()
    
    async def get_paginated(
        self,
        page: int,
        per_page: int,
        search: str | None = None,
    ) -> PaginatedUsers:
        query = select(User)
        count_query = select(func.count(User.id))
        
        if search:
            query = query.where(
                User.name.ilike(f"%{search}%") |
                User.email.ilike(f"%{search}%")
            )
            count_query = count_query.where(
                User.name.ilike(f"%{search}%") |
                User.email.ilike(f"%{search}%")
            )
        
        # Get total count
        total_result = await self.db.execute(count_query)
        total = total_result.scalar_one()
        
        # Get paginated items
        query = query.offset((page - 1) * per_page).limit(per_page)
        result = await self.db.execute(query)
        items = result.scalars().all()
        
        return PaginatedUsers(
            items=items,
            total=total,
            page=page,
            per_page=per_page,
            pages=(total + per_page - 1) // per_page,
        )
    
    async def create(self, data: UserCreate) -> User:
        user = User(
            email=data.email,
            name=data.name,
            hashed_password=get_password_hash(data.password),
        )
        self.db.add(user)
        await self.db.flush()
        await self.db.refresh(user)
        return user
    
    async def update(self, user_id: int, data: UserUpdate) -> User | None:
        user = await self.get_by_id(user_id)
        if not user:
            return None
        
        update_data = data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(user, field, value)
        
        await self.db.flush()
        await self.db.refresh(user)
        return user
    
    async def delete(self, user_id: int) -> bool:
        user = await self.get_by_id(user_id)
        if not user:
            return False
        
        await self.db.delete(user)
        return True
```

---

## Authentication

### routers/auth.py
```python
from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from jose import jwt
from sqlalchemy.ext.asyncio import AsyncSession

from ..config import settings
from ..database import get_db
from ..schemas.auth import Token, TokenRefresh
from ..services.user_service import UserService
from ..utils.security import verify_password

router = APIRouter()


def create_access_token(user_id: int) -> str:
    expire = datetime.now(timezone.utc) + timedelta(
        minutes=settings.access_token_expire_minutes
    )
    return jwt.encode(
        {"sub": user_id, "exp": expire, "type": "access"},
        settings.secret_key,
        algorithm=settings.algorithm,
    )


def create_refresh_token(user_id: int) -> str:
    expire = datetime.now(timezone.utc) + timedelta(
        days=settings.refresh_token_expire_days
    )
    return jwt.encode(
        {"sub": user_id, "exp": expire, "type": "refresh"},
        settings.secret_key,
        algorithm=settings.algorithm,
    )


@router.post("/login", response_model=Token)
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: AsyncSession = Depends(get_db),
):
    """OAuth2 compatible login endpoint."""
    service = UserService(db)
    user = await service.get_by_email(form_data.username)
    
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Inactive user",
        )
    
    return Token(
        access_token=create_access_token(user.id),
        refresh_token=create_refresh_token(user.id),
        token_type="bearer",
    )


@router.post("/refresh", response_model=Token)
async def refresh_token(
    token_data: TokenRefresh,
    db: AsyncSession = Depends(get_db),
):
    """Refresh access token using refresh token."""
    try:
        payload = jwt.decode(
            token_data.refresh_token,
            settings.secret_key,
            algorithms=[settings.algorithm],
        )
        
        if payload.get("type") != "refresh":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token type",
            )
        
        user_id: int = payload.get("sub")
    except jwt.JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token",
        )
    
    service = UserService(db)
    user = await service.get_by_id(user_id)
    
    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found or inactive",
        )
    
    return Token(
        access_token=create_access_token(user.id),
        refresh_token=create_refresh_token(user.id),
        token_type="bearer",
    )
```

---

## Background Tasks

```python
from fastapi import BackgroundTasks

@router.post("/users", response_model=UserResponse)
async def create_user(
    user_data: UserCreate,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
):
    service = UserService(db)
    user = await service.create(user_data)
    
    # Add background task
    background_tasks.add_task(send_welcome_email, user.email, user.name)
    
    return user


async def send_welcome_email(email: str, name: str):
    """Send welcome email in background."""
    # Simulate email sending
    print(f"Sending welcome email to {email}")
    await asyncio.sleep(2)
    print(f"Welcome email sent to {name}")
```

---

## WebSockets

```python
from fastapi import WebSocket, WebSocketDisconnect
from typing import Dict

class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[int, WebSocket] = {}
    
    async def connect(self, websocket: WebSocket, user_id: int):
        await websocket.accept()
        self.active_connections[user_id] = websocket
    
    def disconnect(self, user_id: int):
        self.active_connections.pop(user_id, None)
    
    async def send_personal(self, message: dict, user_id: int):
        if websocket := self.active_connections.get(user_id):
            await websocket.send_json(message)
    
    async def broadcast(self, message: dict):
        for websocket in self.active_connections.values():
            await websocket.send_json(message)


manager = ConnectionManager()


@router.websocket("/ws/{user_id}")
async def websocket_endpoint(
    websocket: WebSocket,
    user_id: int,
):
    await manager.connect(websocket, user_id)
    try:
        while True:
            data = await websocket.receive_json()
            await manager.broadcast({"user_id": user_id, "message": data})
    except WebSocketDisconnect:
        manager.disconnect(user_id)
```

---

## Testing

### tests/conftest.py
```python
import pytest
import pytest_asyncio
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker

from src.main import app
from src.database import Base, get_db


# Test database
TEST_DATABASE_URL = "sqlite+aiosqlite:///./test.db"
test_engine = create_async_engine(TEST_DATABASE_URL, echo=True)
test_session_maker = async_sessionmaker(test_engine, expire_on_commit=False)


async def override_get_db():
    async with test_session_maker() as session:
        yield session


app.dependency_overrides[get_db] = override_get_db


@pytest_asyncio.fixture(scope="function")
async def client():
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac
    
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
```

### tests/test_users.py
```python
import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_create_user(client: AsyncClient):
    response = await client.post("/api/v1/users", json={
        "email": "test@example.com",
        "name": "Test User",
        "password": "Password123",
    })
    
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == "test@example.com"
    assert data["name"] == "Test User"
    assert "id" in data


@pytest.mark.asyncio
async def test_create_user_duplicate_email(client: AsyncClient):
    # Create first user
    await client.post("/api/v1/users", json={
        "email": "test@example.com",
        "name": "Test User",
        "password": "Password123",
    })
    
    # Try to create duplicate
    response = await client.post("/api/v1/users", json={
        "email": "test@example.com",
        "name": "Another User",
        "password": "Password123",
    })
    
    assert response.status_code == 409


@pytest.mark.asyncio
async def test_get_user_unauthorized(client: AsyncClient):
    response = await client.get("/api/v1/users/me")
    assert response.status_code == 401
```

---

## Best Practices Checklist

- [ ] Use Pydantic v2 with `model_config = ConfigDict(from_attributes=True)`
- [ ] Separate input/output schemas
- [ ] Use SQLAlchemy 2.0 async with `Mapped` type hints
- [ ] Implement proper dependency injection
- [ ] Use lifespan context manager for startup/shutdown
- [ ] Handle errors with custom exception handlers
- [ ] Write async tests with pytest-asyncio
- [ ] Use pydantic-settings for configuration
- [ ] Implement proper logging with structlog
- [ ] Use background tasks for non-blocking operations

---

**References:**
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Pydantic v2 Docs](https://docs.pydantic.dev/latest/)
- [SQLAlchemy 2.0 Docs](https://docs.sqlalchemy.org/en/20/)

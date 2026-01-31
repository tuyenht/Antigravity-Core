# Python Backend Development Patterns

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Python:** 3.11+ | **Framework:** FastAPI/Flask
> **Priority:** P1 - Load for Python backend projects

---

You are an expert in Python backend development patterns and architecture.

## Key Principles

- Write async code when possible
- Use Pydantic for data validation
- Implement proper dependency injection
- Follow clean architecture principles
- Use type hints throughout
- Separate concerns properly

---

## Clean Architecture

```
src/
├── api/                    # Interface layer
│   ├── v1/
│   │   ├── endpoints/
│   │   ├── dependencies.py
│   │   └── router.py
│   └── middleware/
├── application/            # Use cases layer
│   ├── commands/           # Write operations
│   ├── queries/            # Read operations
│   ├── services/           # Business logic
│   └── interfaces/         # Abstract interfaces
├── domain/                 # Domain layer
│   ├── entities/
│   ├── value_objects/
│   ├── exceptions/
│   └── events/
├── infrastructure/         # Infrastructure layer
│   ├── database/
│   ├── cache/
│   ├── messaging/
│   └── external/
└── shared/                 # Shared utilities
    ├── config.py
    └── logging.py
```

---

## Domain Layer

### Entities
```python
# domain/entities/user.py
from dataclasses import dataclass, field
from datetime import datetime
from typing import NewType
from uuid import UUID, uuid4

UserId = NewType("UserId", UUID)


@dataclass
class User:
    """User domain entity."""
    
    id: UserId = field(default_factory=lambda: UserId(uuid4()))
    email: str = ""
    name: str = ""
    password_hash: str = ""
    role: str = "user"
    is_active: bool = True
    created_at: datetime = field(default_factory=datetime.utcnow)
    updated_at: datetime | None = None
    
    def activate(self) -> None:
        """Activate user account."""
        self.is_active = True
        self.updated_at = datetime.utcnow()
    
    def deactivate(self) -> None:
        """Deactivate user account."""
        self.is_active = False
        self.updated_at = datetime.utcnow()
    
    def change_role(self, new_role: str) -> None:
        """Change user role."""
        allowed_roles = {"user", "admin", "moderator"}
        if new_role not in allowed_roles:
            raise ValueError(f"Invalid role: {new_role}")
        self.role = new_role
        self.updated_at = datetime.utcnow()
```

### Value Objects
```python
# domain/value_objects/email.py
from dataclasses import dataclass
import re


@dataclass(frozen=True)
class Email:
    """Email value object with validation."""
    
    value: str
    
    def __post_init__(self):
        if not self._is_valid(self.value):
            raise ValueError(f"Invalid email: {self.value}")
    
    @staticmethod
    def _is_valid(email: str) -> bool:
        pattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
        return bool(re.match(pattern, email))
    
    def __str__(self) -> str:
        return self.value


@dataclass(frozen=True)
class Money:
    """Money value object."""
    
    amount: int  # Store in cents
    currency: str = "USD"
    
    def __post_init__(self):
        if self.amount < 0:
            raise ValueError("Amount cannot be negative")
    
    def add(self, other: "Money") -> "Money":
        if self.currency != other.currency:
            raise ValueError("Cannot add different currencies")
        return Money(self.amount + other.amount, self.currency)
    
    def __str__(self) -> str:
        return f"{self.amount / 100:.2f} {self.currency}"
```

### Domain Events
```python
# domain/events/base.py
from dataclasses import dataclass, field
from datetime import datetime
from typing import Any
from uuid import UUID, uuid4


@dataclass
class DomainEvent:
    """Base domain event."""
    
    event_id: UUID = field(default_factory=uuid4)
    timestamp: datetime = field(default_factory=datetime.utcnow)
    
    @property
    def event_type(self) -> str:
        return self.__class__.__name__


@dataclass
class UserCreated(DomainEvent):
    """Event when user is created."""
    user_id: UUID = field(default_factory=uuid4)
    email: str = ""


@dataclass
class UserActivated(DomainEvent):
    """Event when user is activated."""
    user_id: UUID = field(default_factory=uuid4)


# Event publisher
class EventPublisher:
    """Publish domain events."""
    
    def __init__(self):
        self._handlers: dict[str, list[callable]] = {}
    
    def subscribe(self, event_type: str, handler: callable) -> None:
        if event_type not in self._handlers:
            self._handlers[event_type] = []
        self._handlers[event_type].append(handler)
    
    async def publish(self, event: DomainEvent) -> None:
        handlers = self._handlers.get(event.event_type, [])
        for handler in handlers:
            await handler(event)
```

---

## Application Layer

### Abstract Repository Interface
```python
# application/interfaces/repository.py
from abc import ABC, abstractmethod
from typing import Generic, TypeVar
from uuid import UUID

T = TypeVar("T")


class Repository(ABC, Generic[T]):
    """Abstract repository interface."""
    
    @abstractmethod
    async def get_by_id(self, id: UUID) -> T | None:
        """Get entity by ID."""
        ...
    
    @abstractmethod
    async def add(self, entity: T) -> T:
        """Add new entity."""
        ...
    
    @abstractmethod
    async def update(self, entity: T) -> T:
        """Update existing entity."""
        ...
    
    @abstractmethod
    async def delete(self, id: UUID) -> bool:
        """Delete entity by ID."""
        ...


class UserRepository(Repository["User"], ABC):
    """User repository interface."""
    
    @abstractmethod
    async def get_by_email(self, email: str) -> "User | None":
        """Get user by email."""
        ...
    
    @abstractmethod
    async def list_active(
        self,
        skip: int = 0,
        limit: int = 100,
    ) -> list["User"]:
        """List active users."""
        ...
```

### CQRS - Commands
```python
# application/commands/create_user.py
from dataclasses import dataclass
from uuid import UUID

from ..interfaces.repository import UserRepository
from ..interfaces.password_hasher import PasswordHasher
from ...domain.entities.user import User, UserId
from ...domain.events.base import EventPublisher, UserCreated


@dataclass
class CreateUserCommand:
    """Command to create a new user."""
    email: str
    name: str
    password: str


class CreateUserHandler:
    """Handler for CreateUserCommand."""
    
    def __init__(
        self,
        user_repo: UserRepository,
        password_hasher: PasswordHasher,
        event_publisher: EventPublisher,
    ):
        self._user_repo = user_repo
        self._password_hasher = password_hasher
        self._event_publisher = event_publisher
    
    async def handle(self, command: CreateUserCommand) -> User:
        """Handle create user command."""
        # Check if email exists
        existing = await self._user_repo.get_by_email(command.email)
        if existing:
            raise ValueError("Email already registered")
        
        # Create user entity
        user = User(
            email=command.email,
            name=command.name,
            password_hash=self._password_hasher.hash(command.password),
        )
        
        # Save user
        saved_user = await self._user_repo.add(user)
        
        # Publish event
        await self._event_publisher.publish(
            UserCreated(user_id=saved_user.id, email=saved_user.email)
        )
        
        return saved_user
```

### CQRS - Queries
```python
# application/queries/get_users.py
from dataclasses import dataclass
from pydantic import BaseModel

from ..interfaces.repository import UserRepository


@dataclass
class GetUsersQuery:
    """Query to get paginated users."""
    page: int = 1
    per_page: int = 20
    search: str | None = None
    is_active: bool | None = None


class UserDTO(BaseModel):
    """User data transfer object."""
    id: str
    email: str
    name: str
    role: str
    is_active: bool
    
    class Config:
        from_attributes = True


class PaginatedUsersDTO(BaseModel):
    """Paginated users response."""
    items: list[UserDTO]
    total: int
    page: int
    per_page: int
    pages: int


class GetUsersHandler:
    """Handler for GetUsersQuery."""
    
    def __init__(self, user_repo: UserRepository):
        self._user_repo = user_repo
    
    async def handle(self, query: GetUsersQuery) -> PaginatedUsersDTO:
        """Handle get users query."""
        skip = (query.page - 1) * query.per_page
        
        users, total = await self._user_repo.list_paginated(
            skip=skip,
            limit=query.per_page,
            search=query.search,
            is_active=query.is_active,
        )
        
        return PaginatedUsersDTO(
            items=[UserDTO.model_validate(u) for u in users],
            total=total,
            page=query.page,
            per_page=query.per_page,
            pages=(total + query.per_page - 1) // query.per_page,
        )
```

### Service Layer
```python
# application/services/user_service.py
from uuid import UUID

from ..commands.create_user import CreateUserCommand, CreateUserHandler
from ..commands.update_user import UpdateUserCommand, UpdateUserHandler
from ..queries.get_users import GetUsersQuery, GetUsersHandler, PaginatedUsersDTO
from ...domain.entities.user import User


class UserService:
    """User service orchestrating commands and queries."""
    
    def __init__(
        self,
        create_handler: CreateUserHandler,
        update_handler: UpdateUserHandler,
        get_users_handler: GetUsersHandler,
    ):
        self._create_handler = create_handler
        self._update_handler = update_handler
        self._get_users_handler = get_users_handler
    
    async def create_user(
        self,
        email: str,
        name: str,
        password: str,
    ) -> User:
        """Create a new user."""
        command = CreateUserCommand(
            email=email,
            name=name,
            password=password,
        )
        return await self._create_handler.handle(command)
    
    async def get_users(
        self,
        page: int = 1,
        per_page: int = 20,
        search: str | None = None,
    ) -> PaginatedUsersDTO:
        """Get paginated users."""
        query = GetUsersQuery(
            page=page,
            per_page=per_page,
            search=search,
        )
        return await self._get_users_handler.handle(query)
```

---

## Infrastructure Layer

### Repository Implementation
```python
# infrastructure/database/user_repository.py
from uuid import UUID
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from ...application.interfaces.repository import UserRepository
from ...domain.entities.user import User
from .models import UserModel


class SQLAlchemyUserRepository(UserRepository):
    """SQLAlchemy implementation of UserRepository."""
    
    def __init__(self, session: AsyncSession):
        self._session = session
    
    async def get_by_id(self, id: UUID) -> User | None:
        result = await self._session.execute(
            select(UserModel).where(UserModel.id == id)
        )
        model = result.scalar_one_or_none()
        return self._to_entity(model) if model else None
    
    async def get_by_email(self, email: str) -> User | None:
        result = await self._session.execute(
            select(UserModel).where(UserModel.email == email)
        )
        model = result.scalar_one_or_none()
        return self._to_entity(model) if model else None
    
    async def add(self, entity: User) -> User:
        model = self._to_model(entity)
        self._session.add(model)
        await self._session.flush()
        await self._session.refresh(model)
        return self._to_entity(model)
    
    async def update(self, entity: User) -> User:
        result = await self._session.execute(
            select(UserModel).where(UserModel.id == entity.id)
        )
        model = result.scalar_one()
        
        model.email = entity.email
        model.name = entity.name
        model.role = entity.role
        model.is_active = entity.is_active
        model.updated_at = entity.updated_at
        
        await self._session.flush()
        return self._to_entity(model)
    
    async def delete(self, id: UUID) -> bool:
        result = await self._session.execute(
            select(UserModel).where(UserModel.id == id)
        )
        model = result.scalar_one_or_none()
        
        if not model:
            return False
        
        await self._session.delete(model)
        return True
    
    async def list_paginated(
        self,
        skip: int = 0,
        limit: int = 100,
        search: str | None = None,
        is_active: bool | None = None,
    ) -> tuple[list[User], int]:
        query = select(UserModel)
        count_query = select(func.count(UserModel.id))
        
        if search:
            search_filter = (
                UserModel.name.ilike(f"%{search}%") |
                UserModel.email.ilike(f"%{search}%")
            )
            query = query.where(search_filter)
            count_query = count_query.where(search_filter)
        
        if is_active is not None:
            query = query.where(UserModel.is_active == is_active)
            count_query = count_query.where(UserModel.is_active == is_active)
        
        # Get total
        total_result = await self._session.execute(count_query)
        total = total_result.scalar_one()
        
        # Get items
        query = query.offset(skip).limit(limit).order_by(UserModel.created_at.desc())
        result = await self._session.execute(query)
        models = result.scalars().all()
        
        return [self._to_entity(m) for m in models], total
    
    @staticmethod
    def _to_entity(model: UserModel) -> User:
        """Convert ORM model to domain entity."""
        return User(
            id=model.id,
            email=model.email,
            name=model.name,
            password_hash=model.password_hash,
            role=model.role,
            is_active=model.is_active,
            created_at=model.created_at,
            updated_at=model.updated_at,
        )
    
    @staticmethod
    def _to_model(entity: User) -> UserModel:
        """Convert domain entity to ORM model."""
        return UserModel(
            id=entity.id,
            email=entity.email,
            name=entity.name,
            password_hash=entity.password_hash,
            role=entity.role,
            is_active=entity.is_active,
            created_at=entity.created_at,
            updated_at=entity.updated_at,
        )
```

### Caching with Redis
```python
# infrastructure/cache/redis_cache.py
import json
from typing import Any, TypeVar
from redis.asyncio import Redis
from pydantic import BaseModel

T = TypeVar("T", bound=BaseModel)


class RedisCache:
    """Redis cache implementation."""
    
    def __init__(self, redis: Redis, prefix: str = "app"):
        self._redis = redis
        self._prefix = prefix
    
    def _key(self, key: str) -> str:
        return f"{self._prefix}:{key}"
    
    async def get(self, key: str) -> str | None:
        """Get value from cache."""
        return await self._redis.get(self._key(key))
    
    async def get_json(self, key: str) -> dict | None:
        """Get JSON value from cache."""
        value = await self.get(key)
        return json.loads(value) if value else None
    
    async def get_model(self, key: str, model_class: type[T]) -> T | None:
        """Get Pydantic model from cache."""
        data = await self.get_json(key)
        return model_class.model_validate(data) if data else None
    
    async def set(
        self,
        key: str,
        value: str,
        expire: int | None = None,
    ) -> None:
        """Set value in cache."""
        await self._redis.set(self._key(key), value, ex=expire)
    
    async def set_json(
        self,
        key: str,
        value: dict | BaseModel,
        expire: int | None = None,
    ) -> None:
        """Set JSON value in cache."""
        if isinstance(value, BaseModel):
            value = value.model_dump()
        await self.set(key, json.dumps(value), expire)
    
    async def delete(self, key: str) -> None:
        """Delete value from cache."""
        await self._redis.delete(self._key(key))
    
    async def exists(self, key: str) -> bool:
        """Check if key exists."""
        return await self._redis.exists(self._key(key)) > 0
    
    async def invalidate_pattern(self, pattern: str) -> int:
        """Invalidate keys matching pattern."""
        keys = await self._redis.keys(self._key(pattern))
        if keys:
            return await self._redis.delete(*keys)
        return 0


# Caching decorator
def cached(
    key_template: str,
    expire: int = 300,
    model_class: type[BaseModel] | None = None,
):
    """Caching decorator for async functions."""
    def decorator(func):
        async def wrapper(self, *args, **kwargs):
            # Build cache key
            cache_key = key_template.format(*args, **kwargs)
            
            # Try to get from cache
            if model_class:
                cached_value = await self._cache.get_model(cache_key, model_class)
            else:
                cached_value = await self._cache.get_json(cache_key)
            
            if cached_value is not None:
                return cached_value
            
            # Call function
            result = await func(self, *args, **kwargs)
            
            # Store in cache
            await self._cache.set_json(cache_key, result, expire)
            
            return result
        return wrapper
    return decorator
```

---

## API Layer

### Dependency Injection Container
```python
# api/dependencies.py
from functools import lru_cache
from typing import Annotated
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession
from redis.asyncio import Redis

from ..infrastructure.database.session import get_session
from ..infrastructure.database.user_repository import SQLAlchemyUserRepository
from ..infrastructure.cache.redis_cache import RedisCache
from ..infrastructure.services.password_hasher import BcryptPasswordHasher
from ..application.commands.create_user import CreateUserHandler
from ..application.queries.get_users import GetUsersHandler
from ..application.services.user_service import UserService
from ..domain.events.base import EventPublisher


# Singletons
@lru_cache
def get_event_publisher() -> EventPublisher:
    return EventPublisher()


@lru_cache
def get_password_hasher() -> BcryptPasswordHasher:
    return BcryptPasswordHasher()


# Per-request dependencies
async def get_redis() -> Redis:
    from ..config import settings
    return Redis.from_url(settings.redis_url)


async def get_cache(
    redis: Annotated[Redis, Depends(get_redis)],
) -> RedisCache:
    return RedisCache(redis)


async def get_user_repository(
    session: Annotated[AsyncSession, Depends(get_session)],
) -> SQLAlchemyUserRepository:
    return SQLAlchemyUserRepository(session)


async def get_user_service(
    user_repo: Annotated[SQLAlchemyUserRepository, Depends(get_user_repository)],
    password_hasher: Annotated[BcryptPasswordHasher, Depends(get_password_hasher)],
    event_publisher: Annotated[EventPublisher, Depends(get_event_publisher)],
) -> UserService:
    create_handler = CreateUserHandler(user_repo, password_hasher, event_publisher)
    get_users_handler = GetUsersHandler(user_repo)
    
    return UserService(
        create_handler=create_handler,
        update_handler=None,  # Add when needed
        get_users_handler=get_users_handler,
    )


# Type aliases
UserServiceDep = Annotated[UserService, Depends(get_user_service)]
CacheDep = Annotated[RedisCache, Depends(get_cache)]
```

### API Endpoints
```python
# api/v1/endpoints/users.py
from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, EmailStr

from ...dependencies import UserServiceDep, CacheDep
from ....application.queries.get_users import PaginatedUsersDTO

router = APIRouter(prefix="/users", tags=["users"])


class CreateUserRequest(BaseModel):
    email: EmailStr
    name: str
    password: str


class UserResponse(BaseModel):
    id: str
    email: str
    name: str
    role: str
    is_active: bool


@router.get("", response_model=PaginatedUsersDTO)
async def list_users(
    user_service: UserServiceDep,
    page: Annotated[int, Query(ge=1)] = 1,
    per_page: Annotated[int, Query(ge=1, le=100)] = 20,
    search: str | None = None,
):
    """List users with pagination."""
    return await user_service.get_users(
        page=page,
        per_page=per_page,
        search=search,
    )


@router.post("", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    request: CreateUserRequest,
    user_service: UserServiceDep,
):
    """Create a new user."""
    try:
        user = await user_service.create_user(
            email=request.email,
            name=request.name,
            password=request.password,
        )
        return UserResponse(
            id=str(user.id),
            email=user.email,
            name=user.name,
            role=user.role,
            is_active=user.is_active,
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=str(e),
        )
```

---

## Background Tasks & Workers

### Celery Task Queue
```python
# infrastructure/tasks/celery_app.py
from celery import Celery
from ..config import settings

celery_app = Celery(
    "worker",
    broker=settings.celery_broker_url,
    backend=settings.celery_result_backend,
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    task_track_started=True,
    task_time_limit=30 * 60,
    worker_prefetch_multiplier=1,
)


# infrastructure/tasks/email_tasks.py
from .celery_app import celery_app


@celery_app.task(bind=True, max_retries=3)
def send_welcome_email(self, user_id: str, email: str):
    """Send welcome email to new user."""
    try:
        # Send email logic
        print(f"Sending welcome email to {email}")
    except Exception as exc:
        self.retry(exc=exc, countdown=60)


@celery_app.task
def send_password_reset_email(email: str, reset_token: str):
    """Send password reset email."""
    print(f"Sending password reset to {email}")
```

### FastAPI Background Tasks
```python
# api/v1/endpoints/users.py
from fastapi import BackgroundTasks

@router.post("", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    request: CreateUserRequest,
    user_service: UserServiceDep,
    background_tasks: BackgroundTasks,
):
    """Create a new user."""
    user = await user_service.create_user(
        email=request.email,
        name=request.name,
        password=request.password,
    )
    
    # Queue background task
    background_tasks.add_task(
        send_welcome_email,
        user_id=str(user.id),
        email=user.email,
    )
    
    return UserResponse(...)
```

---

## Testing

### Unit Tests
```python
# tests/unit/test_user_entity.py
import pytest
from src.domain.entities.user import User


def test_user_creation():
    user = User(email="test@example.com", name="Test")
    
    assert user.email == "test@example.com"
    assert user.name == "Test"
    assert user.is_active is True
    assert user.role == "user"


def test_user_activate():
    user = User(email="test@example.com", name="Test", is_active=False)
    
    user.activate()
    
    assert user.is_active is True
    assert user.updated_at is not None


def test_user_change_role():
    user = User(email="test@example.com", name="Test")
    
    user.change_role("admin")
    
    assert user.role == "admin"


def test_user_change_role_invalid():
    user = User(email="test@example.com", name="Test")
    
    with pytest.raises(ValueError, match="Invalid role"):
        user.change_role("superuser")
```

### Integration Tests
```python
# tests/integration/test_user_api.py
import pytest
from httpx import AsyncClient
from src.main import app


@pytest.fixture
async def client():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac


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


@pytest.mark.asyncio
async def test_list_users(client: AsyncClient):
    response = await client.get("/api/v1/users")
    
    assert response.status_code == 200
    data = response.json()
    assert "items" in data
    assert "total" in data
```

---

## Best Practices Checklist

- [ ] Use Clean Architecture with clear layer separation
- [ ] Implement Repository pattern for data access
- [ ] Use CQRS for complex domains
- [ ] Implement domain events for decoupling
- [ ] Use dependency injection throughout
- [ ] Implement proper caching strategies
- [ ] Use background tasks for async operations
- [ ] Write unit tests for domain logic
- [ ] Write integration tests for APIs
- [ ] Use type hints everywhere

---

**References:**
- [Clean Architecture (Uncle Bob)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [CQRS Pattern](https://martinfowler.com/bliki/CQRS.html)
- [Repository Pattern](https://martinfowler.com/eaaCatalog/repository.html)
- [Domain-Driven Design](https://domainlanguage.com/ddd/)

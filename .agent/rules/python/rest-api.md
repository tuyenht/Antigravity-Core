# Python REST API Development Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Python:** 3.11+ | **FastAPI:** 0.100+
> **Priority:** P0 - Load for all API projects

---

You are an expert in Python REST API development with FastAPI.

## Key Principles

- Follow RESTful design principles
- Use RFC 7807 Problem Details for errors
- Implement versioning from the start
- Document APIs with OpenAPI
- Design for scalability and performance
- Use async patterns throughout

---

## Project Structure

```
api/
├── src/
│   ├── __init__.py
│   ├── main.py                 # FastAPI app
│   ├── config.py               # Settings
│   ├── dependencies.py         # DI dependencies
│   ├── api/
│   │   ├── __init__.py
│   │   ├── v1/
│   │   │   ├── __init__.py
│   │   │   ├── router.py       # v1 router
│   │   │   ├── users.py
│   │   │   └── products.py
│   │   └── v2/
│   │       └── ...
│   ├── core/
│   │   ├── errors.py           # Error handling
│   │   ├── pagination.py
│   │   └── security.py
│   ├── models/
│   │   ├── domain.py           # SQLAlchemy models
│   │   └── schemas.py          # Pydantic schemas
│   ├── services/
│   │   └── user_service.py
│   └── repositories/
│       └── user_repository.py
├── tests/
├── pyproject.toml
└── README.md
```

---

## FastAPI Application

### Main Application
```python
# src/main.py
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware

from .config import settings
from .api.v1.router import router as v1_router
from .core.errors import register_exception_handlers
from .dependencies import get_db_session


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan events."""
    # Startup
    print("Starting up...")
    # Initialize database pool, cache, etc.
    yield
    # Shutdown
    print("Shutting down...")
    # Close connections


app = FastAPI(
    title=settings.app_name,
    description="REST API with FastAPI",
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/api/docs",
    redoc_url="/api/redoc",
    openapi_url="/api/openapi.json",
)

# Middleware
app.add_middleware(GZipMiddleware, minimum_size=1000)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Exception handlers
register_exception_handlers(app)

# Routers
app.include_router(v1_router, prefix="/api/v1")


@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "healthy"}
```

---

## API Versioning

### URL-Based Versioning
```python
# src/api/v1/router.py
from fastapi import APIRouter

from .users import router as users_router
from .products import router as products_router

router = APIRouter()

router.include_router(users_router, prefix="/users", tags=["Users"])
router.include_router(products_router, prefix="/products", tags=["Products"])


# src/api/v2/router.py
from fastapi import APIRouter

router = APIRouter()
# V2 endpoints with breaking changes


# Main app
app.include_router(v1_router, prefix="/api/v1")
app.include_router(v2_router, prefix="/api/v2")
```

### Header-Based Versioning
```python
from fastapi import APIRouter, Header, HTTPException

router = APIRouter()


async def get_api_version(
    accept: str = Header(default="application/json"),
) -> str:
    """Extract API version from Accept header."""
    # application/vnd.myapi.v1+json
    if "vnd.myapi.v" in accept:
        version = accept.split("vnd.myapi.v")[1].split("+")[0]
        return f"v{version}"
    return "v1"  # Default


@router.get("/users")
async def get_users(version: str = Depends(get_api_version)):
    if version == "v1":
        return {"users": [], "format": "v1"}
    elif version == "v2":
        return {"data": {"users": []}, "meta": {}}
```

---

## RFC 7807 Problem Details

### Error Response Schema
```python
# src/core/errors.py
from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from typing import Any
from datetime import datetime


class ProblemDetail(BaseModel):
    """RFC 7807 Problem Details response."""
    
    type: str = Field(
        default="about:blank",
        description="URI reference identifying the problem type"
    )
    title: str = Field(description="Short human-readable summary")
    status: int = Field(description="HTTP status code")
    detail: str | None = Field(
        default=None,
        description="Human-readable explanation"
    )
    instance: str | None = Field(
        default=None,
        description="URI reference identifying the specific occurrence"
    )
    # Extensions
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    errors: list[dict[str, Any]] | None = None
    trace_id: str | None = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "type": "https://api.example.com/errors/validation",
                "title": "Validation Error",
                "status": 422,
                "detail": "The request body contains invalid data",
                "instance": "/api/v1/users",
                "timestamp": "2024-01-15T10:30:00Z",
                "errors": [
                    {"field": "email", "message": "Invalid email format"}
                ]
            }
        }


class APIException(Exception):
    """Custom API exception."""
    
    def __init__(
        self,
        status_code: int,
        title: str,
        detail: str | None = None,
        error_type: str = "about:blank",
        errors: list[dict] | None = None,
    ):
        self.status_code = status_code
        self.title = title
        self.detail = detail
        self.error_type = error_type
        self.errors = errors


def register_exception_handlers(app: FastAPI) -> None:
    """Register global exception handlers."""
    
    @app.exception_handler(APIException)
    async def api_exception_handler(request: Request, exc: APIException):
        return JSONResponse(
            status_code=exc.status_code,
            content=ProblemDetail(
                type=exc.error_type,
                title=exc.title,
                status=exc.status_code,
                detail=exc.detail,
                instance=str(request.url.path),
                errors=exc.errors,
            ).model_dump(mode="json"),
            media_type="application/problem+json",
        )
    
    @app.exception_handler(HTTPException)
    async def http_exception_handler(request: Request, exc: HTTPException):
        return JSONResponse(
            status_code=exc.status_code,
            content=ProblemDetail(
                title=exc.detail,
                status=exc.status_code,
                instance=str(request.url.path),
            ).model_dump(mode="json"),
            media_type="application/problem+json",
        )
    
    @app.exception_handler(Exception)
    async def general_exception_handler(request: Request, exc: Exception):
        # Log the full error
        import logging
        logging.exception("Unhandled exception")
        
        return JSONResponse(
            status_code=500,
            content=ProblemDetail(
                type="https://api.example.com/errors/internal",
                title="Internal Server Error",
                status=500,
                detail="An unexpected error occurred",
                instance=str(request.url.path),
            ).model_dump(mode="json"),
            media_type="application/problem+json",
        )


# Usage in endpoints
from fastapi import APIRouter

router = APIRouter()


@router.get("/users/{user_id}")
async def get_user(user_id: str):
    user = await user_service.get_by_id(user_id)
    
    if not user:
        raise APIException(
            status_code=404,
            title="User Not Found",
            detail=f"User with ID '{user_id}' does not exist",
            error_type="https://api.example.com/errors/user-not-found",
        )
    
    return user
```

---

## Pydantic Schemas

### Request/Response Schemas
```python
# src/models/schemas.py
from pydantic import BaseModel, Field, EmailStr, ConfigDict
from datetime import datetime
from typing import Generic, TypeVar
from uuid import UUID


# Generic type for pagination
T = TypeVar("T")


class BaseSchema(BaseModel):
    """Base schema with common config."""
    
    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True,
    )


# User schemas
class UserCreate(BaseSchema):
    """Schema for creating a user."""
    
    email: EmailStr
    name: str = Field(min_length=1, max_length=100)
    password: str = Field(min_length=8)


class UserUpdate(BaseSchema):
    """Schema for updating a user (all optional)."""
    
    email: EmailStr | None = None
    name: str | None = Field(default=None, min_length=1, max_length=100)


class UserResponse(BaseSchema):
    """Schema for user response."""
    
    id: UUID
    email: EmailStr
    name: str
    is_active: bool
    created_at: datetime
    updated_at: datetime
    
    # HATEOAS links
    links: dict[str, str] | None = None
    
    @classmethod
    def from_orm_with_links(cls, user, request_url: str) -> "UserResponse":
        """Create response with HATEOAS links."""
        data = cls.model_validate(user)
        data.links = {
            "self": f"{request_url}",
            "update": f"{request_url}",
            "delete": f"{request_url}",
            "posts": f"{request_url}/posts",
        }
        return data


# Pagination wrapper
class PaginatedResponse(BaseModel, Generic[T]):
    """Paginated response with metadata."""
    
    data: list[T]
    meta: "PaginationMeta"
    links: "PaginationLinks"


class PaginationMeta(BaseModel):
    """Pagination metadata."""
    
    total: int
    page: int
    per_page: int
    total_pages: int


class PaginationLinks(BaseModel):
    """Pagination links for HATEOAS."""
    
    self: str
    first: str
    last: str
    prev: str | None = None
    next: str | None = None
```

---

## Cursor Pagination

### Cursor-Based Pagination
```python
# src/core/pagination.py
from pydantic import BaseModel, Field
from typing import Generic, TypeVar, Sequence
from base64 import b64encode, b64decode
from datetime import datetime
import json


T = TypeVar("T")


class CursorParams(BaseModel):
    """Cursor pagination parameters."""
    
    cursor: str | None = Field(default=None, description="Pagination cursor")
    limit: int = Field(default=20, ge=1, le=100, description="Items per page")


class CursorInfo(BaseModel):
    """Decoded cursor information."""
    
    id: str
    created_at: datetime


class CursorPage(BaseModel, Generic[T]):
    """Cursor-paginated response."""
    
    data: list[T]
    next_cursor: str | None = None
    prev_cursor: str | None = None
    has_more: bool = False


def encode_cursor(id: str, created_at: datetime) -> str:
    """Encode cursor from ID and timestamp."""
    data = {"id": id, "created_at": created_at.isoformat()}
    return b64encode(json.dumps(data).encode()).decode()


def decode_cursor(cursor: str) -> CursorInfo:
    """Decode cursor to get ID and timestamp."""
    data = json.loads(b64decode(cursor.encode()).decode())
    return CursorInfo(
        id=data["id"],
        created_at=datetime.fromisoformat(data["created_at"]),
    )


# Repository implementation
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession


class UserRepository:
    """User repository with cursor pagination."""
    
    def __init__(self, session: AsyncSession):
        self.session = session
    
    async def list_with_cursor(
        self,
        cursor: str | None = None,
        limit: int = 20,
    ) -> CursorPage[User]:
        """List users with cursor pagination."""
        
        query = select(User).order_by(
            User.created_at.desc(),
            User.id.desc(),
        )
        
        if cursor:
            cursor_info = decode_cursor(cursor)
            query = query.where(
                (User.created_at < cursor_info.created_at) |
                (
                    (User.created_at == cursor_info.created_at) &
                    (User.id < cursor_info.id)
                )
            )
        
        # Fetch one extra to check if there are more
        query = query.limit(limit + 1)
        
        result = await self.session.execute(query)
        users = list(result.scalars().all())
        
        has_more = len(users) > limit
        if has_more:
            users = users[:limit]
        
        next_cursor = None
        if has_more and users:
            last = users[-1]
            next_cursor = encode_cursor(str(last.id), last.created_at)
        
        return CursorPage(
            data=users,
            next_cursor=next_cursor,
            has_more=has_more,
        )


# Endpoint
@router.get("/users", response_model=CursorPage[UserResponse])
async def list_users(
    cursor: str | None = None,
    limit: int = Query(default=20, ge=1, le=100),
    repo: UserRepository = Depends(get_user_repository),
):
    """List users with cursor pagination."""
    return await repo.list_with_cursor(cursor=cursor, limit=limit)
```

---

## Offset Pagination

### Offset-Based Pagination
```python
# src/core/pagination.py
from fastapi import Query, Request
from pydantic import BaseModel, computed_field
from typing import Generic, TypeVar
import math


T = TypeVar("T")


class OffsetParams(BaseModel):
    """Offset pagination parameters."""
    
    page: int = Field(default=1, ge=1)
    per_page: int = Field(default=20, ge=1, le=100)
    
    @property
    def offset(self) -> int:
        return (self.page - 1) * self.per_page


class OffsetPage(BaseModel, Generic[T]):
    """Offset-paginated response."""
    
    data: list[T]
    meta: "OffsetMeta"
    links: "OffsetLinks"


class OffsetMeta(BaseModel):
    """Pagination metadata."""
    
    total: int
    page: int
    per_page: int
    
    @computed_field
    @property
    def total_pages(self) -> int:
        return math.ceil(self.total / self.per_page)
    
    @computed_field
    @property
    def has_next(self) -> bool:
        return self.page < self.total_pages
    
    @computed_field
    @property
    def has_prev(self) -> bool:
        return self.page > 1


class OffsetLinks(BaseModel):
    """HATEOAS pagination links."""
    
    self: str
    first: str
    last: str
    prev: str | None = None
    next: str | None = None


def paginate(
    items: list[T],
    total: int,
    params: OffsetParams,
    request: Request,
) -> OffsetPage[T]:
    """Create paginated response with links."""
    base_url = str(request.url).split("?")[0]
    
    def make_link(page: int) -> str:
        return f"{base_url}?page={page}&per_page={params.per_page}"
    
    total_pages = math.ceil(total / params.per_page)
    
    links = OffsetLinks(
        self=make_link(params.page),
        first=make_link(1),
        last=make_link(total_pages) if total_pages > 0 else make_link(1),
        prev=make_link(params.page - 1) if params.page > 1 else None,
        next=make_link(params.page + 1) if params.page < total_pages else None,
    )
    
    return OffsetPage(
        data=items,
        meta=OffsetMeta(
            total=total,
            page=params.page,
            per_page=params.per_page,
        ),
        links=links,
    )


# Dependency
def get_pagination(
    page: int = Query(default=1, ge=1),
    per_page: int = Query(default=20, ge=1, le=100),
) -> OffsetParams:
    return OffsetParams(page=page, per_page=per_page)


# Endpoint
@router.get("/products", response_model=OffsetPage[ProductResponse])
async def list_products(
    request: Request,
    pagination: OffsetParams = Depends(get_pagination),
    repo: ProductRepository = Depends(get_product_repository),
):
    """List products with offset pagination."""
    products, total = await repo.list(
        offset=pagination.offset,
        limit=pagination.per_page,
    )
    
    return paginate(products, total, pagination, request)
```

---

## Filtering and Sorting

### Query Parameters
```python
from fastapi import Query
from pydantic import BaseModel
from enum import Enum
from typing import Annotated


class SortOrder(str, Enum):
    asc = "asc"
    desc = "desc"


class UserFilters(BaseModel):
    """User filtering parameters."""
    
    status: str | None = None
    role: str | None = None
    search: str | None = None
    created_after: datetime | None = None
    created_before: datetime | None = None


class UserSorting(BaseModel):
    """User sorting parameters."""
    
    sort_by: str = "created_at"
    order: SortOrder = SortOrder.desc


def get_user_filters(
    status: Annotated[str | None, Query(description="Filter by status")] = None,
    role: Annotated[str | None, Query(description="Filter by role")] = None,
    search: Annotated[str | None, Query(description="Search in name/email")] = None,
    created_after: Annotated[datetime | None, Query(description="Created after")] = None,
    created_before: Annotated[datetime | None, Query(description="Created before")] = None,
) -> UserFilters:
    return UserFilters(
        status=status,
        role=role,
        search=search,
        created_after=created_after,
        created_before=created_before,
    )


def get_user_sorting(
    sort_by: Annotated[str, Query(description="Sort field")] = "created_at",
    order: Annotated[SortOrder, Query(description="Sort order")] = SortOrder.desc,
) -> UserSorting:
    return UserSorting(sort_by=sort_by, order=order)


# Repository
class UserRepository:
    ALLOWED_SORT_FIELDS = {"created_at", "name", "email", "updated_at"}
    
    async def list(
        self,
        filters: UserFilters,
        sorting: UserSorting,
        offset: int = 0,
        limit: int = 20,
    ) -> tuple[list[User], int]:
        """List users with filters and sorting."""
        
        query = select(User)
        
        # Apply filters
        if filters.status:
            query = query.where(User.status == filters.status)
        if filters.role:
            query = query.where(User.role == filters.role)
        if filters.search:
            search_term = f"%{filters.search}%"
            query = query.where(
                (User.name.ilike(search_term)) |
                (User.email.ilike(search_term))
            )
        if filters.created_after:
            query = query.where(User.created_at >= filters.created_after)
        if filters.created_before:
            query = query.where(User.created_at <= filters.created_before)
        
        # Count total
        count_query = select(func.count()).select_from(query.subquery())
        total = await self.session.scalar(count_query)
        
        # Apply sorting
        if sorting.sort_by in self.ALLOWED_SORT_FIELDS:
            sort_column = getattr(User, sorting.sort_by)
            if sorting.order == SortOrder.desc:
                sort_column = sort_column.desc()
            query = query.order_by(sort_column)
        
        # Apply pagination
        query = query.offset(offset).limit(limit)
        
        result = await self.session.execute(query)
        return list(result.scalars().all()), total


# Endpoint
@router.get("/users")
async def list_users(
    request: Request,
    filters: UserFilters = Depends(get_user_filters),
    sorting: UserSorting = Depends(get_user_sorting),
    pagination: OffsetParams = Depends(get_pagination),
    repo: UserRepository = Depends(get_user_repository),
):
    """List users with filtering, sorting, and pagination."""
    users, total = await repo.list(
        filters=filters,
        sorting=sorting,
        offset=pagination.offset,
        limit=pagination.per_page,
    )
    
    return paginate(users, total, pagination, request)
```

---

## Caching

### Redis Caching with fastapi-cache
```python
from fastapi_cache import FastAPICache
from fastapi_cache.backends.redis import RedisBackend
from fastapi_cache.decorator import cache
from redis import asyncio as aioredis
from contextlib import asynccontextmanager


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    redis = aioredis.from_url(
        settings.redis_url,
        encoding="utf8",
        decode_responses=True,
    )
    FastAPICache.init(RedisBackend(redis), prefix="api-cache")
    yield
    # Shutdown
    await redis.close()


app = FastAPI(lifespan=lifespan)


# Cache decorator
@router.get("/products/{product_id}")
@cache(expire=300)  # 5 minutes
async def get_product(product_id: str):
    """Get product by ID (cached)."""
    return await product_service.get_by_id(product_id)


# Cache with custom key
def product_key_builder(
    func,
    namespace: str = "",
    request: Request = None,
    *args,
    **kwargs,
):
    product_id = kwargs.get("product_id")
    return f"product:{product_id}"


@router.get("/products/{product_id}")
@cache(expire=300, key_builder=product_key_builder)
async def get_product(product_id: str):
    return await product_service.get_by_id(product_id)


# Cache invalidation
from fastapi_cache import caches


async def invalidate_product_cache(product_id: str):
    """Invalidate product cache."""
    backend = FastAPICache.get_backend()
    await backend.clear(namespace=f"product:{product_id}")


@router.put("/products/{product_id}")
async def update_product(product_id: str, data: ProductUpdate):
    product = await product_service.update(product_id, data)
    await invalidate_product_cache(product_id)
    return product
```

### HTTP Caching
```python
from fastapi import Response
from datetime import datetime
import hashlib


@router.get("/products/{product_id}")
async def get_product(
    product_id: str,
    response: Response,
):
    """Get product with HTTP caching."""
    product = await product_service.get_by_id(product_id)
    
    if not product:
        raise HTTPException(status_code=404)
    
    # ETag based on content
    content = product.model_dump_json()
    etag = hashlib.md5(content.encode()).hexdigest()
    
    # Set cache headers
    response.headers["ETag"] = f'"{etag}"'
    response.headers["Last-Modified"] = product.updated_at.strftime(
        "%a, %d %b %Y %H:%M:%S GMT"
    )
    response.headers["Cache-Control"] = "private, max-age=60"
    
    return product


# Conditional request handling
from fastapi import Header


@router.get("/products/{product_id}")
async def get_product(
    product_id: str,
    response: Response,
    if_none_match: str | None = Header(default=None),
    if_modified_since: str | None = Header(default=None),
):
    product = await product_service.get_by_id(product_id)
    
    etag = hashlib.md5(product.model_dump_json().encode()).hexdigest()
    
    # Check ETag
    if if_none_match and if_none_match.strip('"') == etag:
        return Response(status_code=304)
    
    response.headers["ETag"] = f'"{etag}"'
    return product
```

---

## Rate Limiting

### Rate Limiting with slowapi
```python
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded


limiter = Limiter(key_func=get_remote_address)

app = FastAPI()
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)


# Rate limit headers middleware
from starlette.middleware.base import BaseHTTPMiddleware


class RateLimitHeadersMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        response = await call_next(request)
        
        # Add rate limit headers
        limit_info = getattr(request.state, "view_rate_limit", None)
        if limit_info:
            response.headers["X-RateLimit-Limit"] = str(limit_info.limit)
            response.headers["X-RateLimit-Remaining"] = str(limit_info.remaining)
            response.headers["X-RateLimit-Reset"] = str(limit_info.reset)
        
        return response


app.add_middleware(RateLimitHeadersMiddleware)


# Per-endpoint rate limits
@router.get("/users")
@limiter.limit("100/minute")
async def list_users(request: Request):
    return await user_service.list()


@router.post("/auth/login")
@limiter.limit("5/minute")  # Strict for auth
async def login(request: Request, credentials: LoginRequest):
    return await auth_service.login(credentials)


@router.post("/reports/generate")
@limiter.limit("3/hour")  # Very strict for expensive operations
async def generate_report(request: Request):
    return await report_service.generate()


# Rate limit by user ID
def get_user_id_or_ip(request: Request) -> str:
    auth = request.headers.get("Authorization", "")
    if auth.startswith("Bearer "):
        # Extract user ID from JWT
        token = auth.split(" ")[1]
        payload = decode_jwt(token)
        return f"user:{payload['sub']}"
    return f"ip:{get_remote_address(request)}"


@router.get("/api/data")
@limiter.limit("1000/hour", key_func=get_user_id_or_ip)
async def get_data(request: Request):
    return {"data": "..."}
```

---

## Testing

### API Testing with httpx
```python
import pytest
from httpx import AsyncClient, ASGITransport
from src.main import app


@pytest.fixture
async def client():
    """Async test client."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac


@pytest.fixture
async def auth_client(client: AsyncClient):
    """Authenticated test client."""
    # Create test user and get token
    response = await client.post("/api/v1/auth/register", json={
        "email": "test@example.com",
        "password": "password123",
        "name": "Test User",
    })
    token = response.json()["access_token"]
    
    client.headers["Authorization"] = f"Bearer {token}"
    return client


# Tests
@pytest.mark.asyncio
async def test_create_user(client: AsyncClient):
    """Test user creation."""
    response = await client.post("/api/v1/users", json={
        "email": "new@example.com",
        "password": "password123",
        "name": "New User",
    })
    
    assert response.status_code == 201
    assert response.json()["email"] == "new@example.com"
    assert "id" in response.json()


@pytest.mark.asyncio
async def test_get_user_not_found(client: AsyncClient):
    """Test 404 response."""
    response = await client.get("/api/v1/users/nonexistent")
    
    assert response.status_code == 404
    assert response.headers["content-type"] == "application/problem+json"
    
    data = response.json()
    assert data["title"] == "User Not Found"
    assert data["status"] == 404


@pytest.mark.asyncio
async def test_validation_error(client: AsyncClient):
    """Test validation error response."""
    response = await client.post("/api/v1/users", json={
        "email": "invalid-email",
        "password": "short",
    })
    
    assert response.status_code == 422
    assert "errors" in response.json()


@pytest.mark.asyncio
async def test_pagination(client: AsyncClient):
    """Test pagination response."""
    response = await client.get("/api/v1/users?page=1&per_page=10")
    
    assert response.status_code == 200
    data = response.json()
    
    assert "data" in data
    assert "meta" in data
    assert "links" in data
    assert data["meta"]["page"] == 1
    assert data["meta"]["per_page"] == 10


@pytest.mark.asyncio
async def test_auth_required(client: AsyncClient):
    """Test authentication requirement."""
    response = await client.get("/api/v1/users/me")
    
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_auth_success(auth_client: AsyncClient):
    """Test authenticated request."""
    response = await auth_client.get("/api/v1/users/me")
    
    assert response.status_code == 200
    assert "email" in response.json()
```

---

## OpenAPI Documentation

### Custom OpenAPI Schema
```python
from fastapi import FastAPI
from fastapi.openapi.utils import get_openapi


def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema
    
    openapi_schema = get_openapi(
        title="My API",
        version="1.0.0",
        description="REST API with FastAPI",
        routes=app.routes,
    )
    
    # Add security scheme
    openapi_schema["components"]["securitySchemes"] = {
        "bearerAuth": {
            "type": "http",
            "scheme": "bearer",
            "bearerFormat": "JWT",
        }
    }
    
    # Add common responses
    openapi_schema["components"]["responses"] = {
        "NotFound": {
            "description": "Resource not found",
            "content": {
                "application/problem+json": {
                    "schema": {"$ref": "#/components/schemas/ProblemDetail"}
                }
            }
        },
        "ValidationError": {
            "description": "Validation error",
            "content": {
                "application/problem+json": {
                    "schema": {"$ref": "#/components/schemas/ProblemDetail"}
                }
            }
        },
    }
    
    app.openapi_schema = openapi_schema
    return app.openapi_schema


app.openapi = custom_openapi
```

---

## Best Practices Checklist

- [ ] Use RFC 7807 Problem Details for errors
- [ ] Implement cursor or offset pagination
- [ ] Add HATEOAS links in responses
- [ ] Use Pydantic for all request/response validation
- [ ] Implement Redis caching
- [ ] Add rate limiting per endpoint
- [ ] Set proper HTTP cache headers
- [ ] Document all endpoints with OpenAPI
- [ ] Write comprehensive API tests
- [ ] Version API from day one

---

**References:**
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [RFC 7807 Problem Details](https://datatracker.ietf.org/doc/html/rfc7807)
- [REST API Design Best Practices](https://restfulapi.net/)
- [HATEOAS](https://restfulapi.net/hateoas/)

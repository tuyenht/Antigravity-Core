---
technology: FastAPI
version: 0.110+
last_updated: 2026-01-16
official_docs: https://fastapi.tiangolo.com
---

# FastAPI - Best Practices & Conventions

**Version:** FastAPI 0.110+  
**Updated:** 2026-01-16  
**Source:** Official FastAPI docs + Python best practices

---

## Overview

FastAPI is a modern, high-performance Python web framework for building APIs with automatic OpenAPI documentation, built-in validation using Pydantic, and async support by default.

---

## Project Structure

```
app/
├── main.py              # Application entry point
├── api/
│   ├── deps.py         # Dependencies
│   ├── routes/         # API routes
│   │   ├── users.py
│   │   └── items.py
│   └── models/         # Pydantic models
├── core/
│   ├── config.py       # Settings
│   └── security.py     # Auth utilities
├── db/
│   ├── database.py     # Database connection
│   └── models.py       # SQLAlchemy models
└── tests/
```

---

## Pydantic Models (Request/Response)

### Type-Safe Models

```python
from pydantic import BaseModel, Field, EmailStr
from typing import Optional

class UserCreate(BaseModel):
    email: EmailStr
    name: str = Field(..., min_length=1, max_length=100)
    age: Optional[int] = Field(None, ge=0, le=150)

class UserResponse(BaseModel):
    id: int
    email: EmailStr
    name: str
    
    class Config:
        from_attributes = True  # For ORM models
```

### Validation Best Practices

```python
from pydantic import BaseModel, validator

class Item(BaseModel):
    name: str
    price: float
    
    @validator('price')
    def price_must_be_positive(cls, v):
        if v <= 0:
            raise ValueError('Price must be positive')
        return v
```

---

## Async/Await Patterns

### Async Endpoints (Preferred for I/O)

```python
from fastapi import FastAPI

app = FastAPI()

# ✅ Good - Async for database/API calls
@app.get("/users/{user_id}")
async def get_user(user_id: int):
    user = await db.fetch_user(user_id)
    return user

# ❌ Bad - Sync for I/O operations
@app.get("/users/{user_id}")
def get_user(user_id: int):
    user = db.fetch_user_sync(user_id)  # Blocks event loop!
    return user
```

### When to Use Sync vs Async

```python
# ✅ Use async for:
- Database queries
- External API calls
- File I/O operations

# ✅ Use sync for:
- CPU-intensive operations
- Blocking libraries (use run_in_executor)
```

---

## Dependency Injection

### Reusable Dependencies

```python
from fastapi import Depends, HTTPException
from sqlalchemy.orm import Session

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
):
    user = authenticate_user(token, db)
    if not user:
        raise HTTPException(status_code=401)
    return user

# Usage
@app.get("/me")
async def read_users_me(current_user: User = Depends(get_current_user)):
    return current_user
```

---

## Error Handling

### HTTPException

```python
from fastapi import HTTPException, status

@app.get("/users/{user_id}")
async def get_user(user_id: int):
    user = await db.get_user(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return user
```

### Custom Exception Handlers

```python
from fastapi import Request
from fastapi.responses import JSONResponse

class CustomException(Exception):
    def __init__(self, name: str):
        self.name = name

@app.exception_handler(CustomException)
async def custom_exception_handler(request: Request, exc: CustomException):
    return JSONResponse(
        status_code=418,
        content={"message": f"Oops! {exc.name} did something wrong."}
    )
```

---

## Database Integration (SQLAlchemy)

### Async SQLAlchemy

```python
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

engine = create_async_engine("postgresql+asyncpg://user:pass@localhost/db")
async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

async def get_db():
    async with async_session() as session:
        yield session

# Usage
@app.get("/users")
async def get_users(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User))
    users = result.scalars().all()
    return users
```

---

## Authentication & Security

### OAuth2 with JWT

```python
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import JWTError, jwt
from passlib.context import CryptContext

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm="HS256")

@app.post("/token")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    user = authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    access_token = create_access_token(data={"sub": user.username})
    return {"access_token": access_token, "token_type": "bearer"}
```

---

## Testing with pytest

```python
from fastapi.testclient import TestClient

client = TestClient(app)

def test_read_users():
    response = client.get("/users")
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_create_user():
    response = client.post("/users", json={
        "email": "test@example.com",
        "name": "Test User"
    })
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == "test@example.com"

# Async tests
import pytest

@pytest.mark.asyncio
async def test_async_endpoint():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        response = await ac.get("/users")
    assert response.status_code == 200
```

---

## Performance Optimization

### Background Tasks

```python
from fastapi import BackgroundTasks

def send_email(email: str, message: str):
    # Send email logic
    pass

@app.post("/send-notification")
async def send_notification(
    email: str,
    background_tasks: BackgroundTasks
):
    background_tasks.add_task(send_email, email, "Welcome!")
    return {"message": "Notification sent in background"}
```

### Caching

```python
from functools import lru_cache

@lru_cache()
def get_settings():
    return Settings()

@app.get("/config")
async def get_config(settings: Settings = Depends(get_settings)):
    return settings
```

---

## API Documentation

### Automatic OpenAPI

FastAPI generates OpenAPI docs automatically:
- **Swagger UI:** `/docs`
- **ReDoc:** `/redoc`

### Customization

```python
from fastapi import FastAPI

app = FastAPI(
    title="My API",
    description="API for managing users and items",
    version="1.0.0",
    openapi_tags=[
        {"name": "users", "description": "User operations"},
        {"name": "items", "description": "Item operations"},
    ]
)

@app.get("/users", tags=["users"], summary="Get all users")
async def get_users():
    """
    Retrieve all users from the database.
    
    - **Returns:** List of user objects
    """
    return []
```

---

## Anti-Patterns to Avoid

❌ **Sync functions for I/O** → Use async/await  
❌ **Dict for validation** → Use Pydantic models  
❌ **Manual OpenAPI docs** → Let FastAPI generate  
❌ **Blocking operations** → Use background tasks  
❌ **No type hints** → FastAPI requires types  
❌ **Global database connections** → Use dependencies  
❌ **Plain text passwords** → Hash with passlib

---

## Best Practices

✅ **Use Pydantic** for all request/response models  
✅ **Async by default** for I/O operations  
✅ **Dependency injection** for reusable logic  
✅ **Background tasks** for long operations  
✅ **Type hints everywhere** for validation  
✅ **HTTPException** for errors  
✅ **Environment variables** for config  
✅ **pytest** for testing

---

**References:**
- [FastAPI Official Docs](https://fastapi.tiangolo.com/)
- [Pydantic Documentation](https://docs.pydantic.dev/)
- [SQLAlchemy Async](https://docs.sqlalchemy.org/en/20/orm/extensions/asyncio.html)

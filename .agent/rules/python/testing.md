# Python Testing Best Practices

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Python:** 3.11+ | **pytest:** 8.x
> **Priority:** P0 - Load for all Python projects

---

You are an expert in Python testing with pytest and modern testing practices.

## Key Principles

- Write tests before or alongside code (TDD)
- Aim for 80%+ coverage on critical code
- Make tests independent and isolated
- Follow AAA pattern (Arrange, Act, Assert)
- Use property-based testing for edge cases
- Keep tests simple and readable

---

## Project Structure

```
project/
├── src/
│   └── myproject/
│       ├── __init__.py
│       ├── models.py
│       ├── services.py
│       └── api.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py           # Shared fixtures
│   ├── unit/
│   │   ├── __init__.py
│   │   ├── test_models.py
│   │   └── test_services.py
│   ├── integration/
│   │   ├── __init__.py
│   │   └── test_api.py
│   └── e2e/
│       └── test_workflows.py
├── pyproject.toml
└── pytest.ini
```

---

## pytest Configuration

### pyproject.toml
```toml
[tool.pytest.ini_options]
minversion = "8.0"
pythonpath = ["src"]
testpaths = ["tests"]
addopts = [
    "-ra",                    # Show extra summary
    "-q",                     # Quiet mode
    "--strict-markers",       # Fail on unknown markers
    "--strict-config",        # Fail on config errors
    "-x",                     # Stop on first failure (optional)
]
markers = [
    "slow: marks tests as slow",
    "integration: marks integration tests",
    "e2e: marks end-to-end tests",
]
filterwarnings = [
    "error",                  # Treat warnings as errors
    "ignore::DeprecationWarning",
]
asyncio_mode = "auto"         # For pytest-asyncio

[tool.coverage.run]
source = ["src"]
branch = true
omit = ["*/tests/*", "*/__init__.py"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "if TYPE_CHECKING:",
    "raise NotImplementedError",
]
fail_under = 80
```

---

## Fixtures

### Basic Fixtures
```python
# tests/conftest.py
import pytest
from pathlib import Path
from myproject.models import User
from myproject.database import Database


# Function scope (default)
@pytest.fixture
def user():
    """Create a test user."""
    return User(id=1, name="Test User", email="test@example.com")


# Session scope (created once per test session)
@pytest.fixture(scope="session")
def database():
    """Create database connection for entire session."""
    db = Database("sqlite:///:memory:")
    db.create_tables()
    yield db
    db.close()


# Module scope
@pytest.fixture(scope="module")
def api_client():
    """Create API client for module."""
    from httpx import Client
    client = Client(base_url="http://localhost:8000")
    yield client
    client.close()


# Autouse fixture
@pytest.fixture(autouse=True)
def reset_database(database):
    """Reset database before each test."""
    yield
    database.rollback()


# Fixture with cleanup
@pytest.fixture
def temp_file(tmp_path: Path):
    """Create a temporary file."""
    file = tmp_path / "test.txt"
    file.write_text("test content")
    yield file
    # Cleanup happens automatically with tmp_path
```

### Fixture Factories
```python
@pytest.fixture
def make_user():
    """Factory fixture for creating users."""
    created_users = []
    
    def _make_user(
        name: str = "Test User",
        email: str | None = None,
        role: str = "user",
    ) -> User:
        user = User(
            id=len(created_users) + 1,
            name=name,
            email=email or f"user{len(created_users)}@example.com",
            role=role,
        )
        created_users.append(user)
        return user
    
    yield _make_user
    
    # Cleanup all created users
    for user in created_users:
        user.delete()


# Usage
def test_multiple_users(make_user):
    admin = make_user(name="Admin", role="admin")
    user1 = make_user(name="User 1")
    user2 = make_user(name="User 2")
    
    assert admin.role == "admin"
    assert user1.role == "user"
```

### Async Fixtures
```python
import pytest
import asyncio


@pytest.fixture
async def async_client():
    """Async fixture for HTTP client."""
    import httpx
    async with httpx.AsyncClient(base_url="http://test") as client:
        yield client


@pytest.fixture(scope="session")
def event_loop():
    """Override event loop for session-scoped async fixtures."""
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()
```

---

## Test Patterns

### AAA Pattern
```python
def test_user_can_update_email(user, database):
    # Arrange
    database.add(user)
    new_email = "newemail@example.com"
    
    # Act
    user.update_email(new_email)
    database.commit()
    
    # Assert
    updated_user = database.get_user(user.id)
    assert updated_user.email == new_email


def test_transfer_deducts_from_source_account(make_account):
    # Arrange
    source = make_account(balance=100)
    target = make_account(balance=0)
    
    # Act
    transfer(source, target, amount=50)
    
    # Assert
    assert source.balance == 50
    assert target.balance == 50
```

### Parametrized Testing
```python
import pytest


@pytest.mark.parametrize("input,expected", [
    ("hello", "HELLO"),
    ("World", "WORLD"),
    ("PyTest", "PYTEST"),
    ("", ""),
])
def test_uppercase(input, expected):
    assert input.upper() == expected


@pytest.mark.parametrize("a,b,expected", [
    (1, 2, 3),
    (0, 0, 0),
    (-1, 1, 0),
    (100, 200, 300),
])
def test_addition(a, b, expected):
    assert a + b == expected


# With custom IDs
@pytest.mark.parametrize("email,valid", [
    pytest.param("test@example.com", True, id="valid_email"),
    pytest.param("invalid", False, id="no_at_sign"),
    pytest.param("@example.com", False, id="no_local_part"),
    pytest.param("test@", False, id="no_domain"),
])
def test_email_validation(email, valid):
    assert validate_email(email) == valid


# Multiple parametrize (cartesian product)
@pytest.mark.parametrize("x", [0, 1, 2])
@pytest.mark.parametrize("y", [3, 4])
def test_multiplication_table(x, y):
    assert x * y == y * x  # Commutative property
```

### Exception Testing
```python
import pytest


def test_raises_value_error():
    with pytest.raises(ValueError):
        int("not a number")


def test_raises_with_message():
    with pytest.raises(ValueError, match=r"invalid literal"):
        int("not a number")


def test_raises_and_inspect():
    with pytest.raises(ValueError) as exc_info:
        raise ValueError("Custom error message")
    
    assert "Custom error" in str(exc_info.value)
    assert exc_info.type is ValueError


def test_does_not_raise():
    # Test that no exception is raised
    try:
        result = safe_operation()
    except Exception as e:
        pytest.fail(f"Unexpected exception: {e}")
```

---

## Mocking

### pytest-mock
```python
from unittest.mock import MagicMock, patch


def test_with_mock(mocker):
    """Using pytest-mock fixture."""
    # Mock a method
    mock_send = mocker.patch("myproject.email.send_email")
    
    # Call code that uses send_email
    notify_user("user@example.com", "Hello!")
    
    # Assert mock was called correctly
    mock_send.assert_called_once_with(
        to="user@example.com",
        subject="Notification",
        body="Hello!",
    )


def test_mock_return_value(mocker):
    """Mock with return value."""
    mock_fetch = mocker.patch("myproject.api.fetch_data")
    mock_fetch.return_value = {"id": 1, "name": "Test"}
    
    result = get_user_data(1)
    
    assert result["name"] == "Test"


def test_mock_side_effect(mocker):
    """Mock with side effect."""
    mock_fetch = mocker.patch("myproject.api.fetch_data")
    mock_fetch.side_effect = [
        {"id": 1},
        {"id": 2},
        ConnectionError("Network error"),
    ]
    
    assert fetch_data()["id"] == 1
    assert fetch_data()["id"] == 2
    
    with pytest.raises(ConnectionError):
        fetch_data()


def test_spy(mocker):
    """Spy on real function."""
    spy = mocker.spy(myproject.utils, "format_date")
    
    result = process_data({"date": "2024-01-15"})
    
    spy.assert_called_once()
    # Original function was called
    assert "2024" in result["formatted_date"]
```

### respx for httpx Mocking
```python
import respx
import httpx
import pytest


@pytest.fixture
def mock_api():
    with respx.mock:
        # Mock GET request
        respx.get("https://api.example.com/users/1").mock(
            return_value=httpx.Response(
                200,
                json={"id": 1, "name": "Test User"},
            )
        )
        
        # Mock POST request
        respx.post("https://api.example.com/users").mock(
            return_value=httpx.Response(201, json={"id": 2})
        )
        
        # Mock with pattern
        respx.get(url__regex=r"https://api\.example\.com/items/\d+").mock(
            return_value=httpx.Response(200, json={"status": "ok"})
        )
        
        yield


def test_fetch_user(mock_api):
    response = httpx.get("https://api.example.com/users/1")
    
    assert response.status_code == 200
    assert response.json()["name"] == "Test User"


@pytest.mark.asyncio
async def test_async_fetch(mock_api):
    async with httpx.AsyncClient() as client:
        response = await client.get("https://api.example.com/users/1")
    
    assert response.status_code == 200
```

---

## Property-Based Testing (Hypothesis)

### Basic Hypothesis
```python
from hypothesis import given, strategies as st, assume, settings, example


@given(st.text())
def test_string_reverse_twice_is_original(s):
    """Reversing a string twice gives the original."""
    assert s[::-1][::-1] == s


@given(st.integers(), st.integers())
def test_addition_is_commutative(a, b):
    """Addition is commutative."""
    assert a + b == b + a


@given(st.lists(st.integers()))
def test_sort_preserves_length(lst):
    """Sorting preserves length."""
    assert len(sorted(lst)) == len(lst)


@given(st.lists(st.integers(), min_size=1))
def test_max_is_in_list(lst):
    """Max element is in the list."""
    assert max(lst) in lst


# With assumptions
@given(st.integers(), st.integers())
def test_division(a, b):
    """Test division with assumption."""
    assume(b != 0)  # Skip if b is 0
    result = a / b
    assert result * b == pytest.approx(a)


# With explicit examples
@given(st.text())
@example("")  # Always test empty string
@example("a")  # Always test single char
def test_string_concatenation(s):
    assert len(s + s) == 2 * len(s)


# With custom settings
@settings(max_examples=500, deadline=1000)
@given(st.binary())
def test_encode_decode(data):
    """Test that encoding/decoding is reversible."""
    encoded = base64.b64encode(data)
    decoded = base64.b64decode(encoded)
    assert decoded == data
```

### Custom Strategies
```python
from hypothesis import strategies as st
from dataclasses import dataclass


@dataclass
class User:
    id: int
    name: str
    email: str
    age: int


# Define a strategy for User
user_strategy = st.builds(
    User,
    id=st.integers(min_value=1),
    name=st.text(min_size=1, max_size=50),
    email=st.emails(),
    age=st.integers(min_value=0, max_value=120),
)


@given(user_strategy)
def test_user_serialization(user):
    """Test user can be serialized and deserialized."""
    data = user_to_dict(user)
    restored = user_from_dict(data)
    
    assert restored.id == user.id
    assert restored.name == user.name


# Composite strategy
@st.composite
def valid_transfer(draw):
    """Generate valid transfer scenarios."""
    source_balance = draw(st.integers(min_value=1, max_value=10000))
    amount = draw(st.integers(min_value=1, max_value=source_balance))
    
    return {
        "source_balance": source_balance,
        "target_balance": draw(st.integers(min_value=0)),
        "amount": amount,
    }


@given(valid_transfer())
def test_valid_transfer(transfer):
    """Test valid transfers always succeed."""
    source = Account(balance=transfer["source_balance"])
    target = Account(balance=transfer["target_balance"])
    
    perform_transfer(source, target, transfer["amount"])
    
    assert source.balance >= 0
    assert target.balance >= transfer["target_balance"]
```

---

## Async Testing

### pytest-asyncio
```python
import pytest
import asyncio


@pytest.mark.asyncio
async def test_async_function():
    result = await async_fetch_data()
    assert result is not None


@pytest.mark.asyncio
async def test_async_with_timeout():
    async with asyncio.timeout(5.0):
        result = await slow_operation()
    assert result == "done"


@pytest.mark.asyncio
async def test_concurrent_operations():
    results = await asyncio.gather(
        fetch_user(1),
        fetch_user(2),
        fetch_user(3),
    )
    assert len(results) == 3


@pytest.mark.asyncio
async def test_exception_in_async():
    with pytest.raises(ValueError):
        await async_operation_that_fails()


@pytest.mark.asyncio
async def test_async_context_manager():
    async with AsyncDatabase() as db:
        result = await db.query("SELECT 1")
        assert result == 1
```

---

## Test Factories (polyfactory)

### Modern Factory Pattern
```python
from polyfactory.factories.pydantic_factory import ModelFactory
from pydantic import BaseModel
from datetime import datetime


class User(BaseModel):
    id: int
    name: str
    email: str
    created_at: datetime
    is_active: bool = True


class UserFactory(ModelFactory):
    __model__ = User
    
    # Override specific fields
    @classmethod
    def is_active(cls) -> bool:
        return True


# Usage in tests
def test_user_creation():
    user = UserFactory.build()
    
    assert user.id is not None
    assert "@" in user.email
    assert user.is_active is True


def test_user_with_overrides():
    user = UserFactory.build(name="Custom Name", is_active=False)
    
    assert user.name == "Custom Name"
    assert user.is_active is False


def test_multiple_users():
    users = UserFactory.batch(10)
    
    assert len(users) == 10
    assert all(u.is_active for u in users)


# Factory with relationships
class Post(BaseModel):
    id: int
    title: str
    author: User


class PostFactory(ModelFactory):
    __model__ = Post


def test_post_with_author():
    post = PostFactory.build()
    
    assert post.author is not None
    assert isinstance(post.author, User)
```

---

## Snapshot Testing

### pytest-snapshot
```python
def test_api_response_structure(snapshot):
    """Test API response matches snapshot."""
    response = api_client.get("/users/1")
    data = response.json()
    
    snapshot.assert_match(data, "user_response.json")


def test_html_output(snapshot):
    """Test HTML output matches snapshot."""
    html = render_template("user_profile.html", user=user)
    
    snapshot.assert_match(html, "user_profile.html")


def test_complex_data(snapshot):
    """Test complex data structure."""
    result = process_data(input_data)
    
    # First run: creates snapshot
    # Subsequent runs: compares to snapshot
    snapshot.assert_match(result, "processed_data.json")
```

---

## Test Coverage

### Running with Coverage
```bash
# Run tests with coverage
pytest --cov=src --cov-report=html --cov-report=term-missing

# With branch coverage
pytest --cov=src --cov-branch --cov-report=html

# Fail if coverage below threshold
pytest --cov=src --cov-fail-under=80
```

### Coverage Configuration
```toml
# pyproject.toml
[tool.coverage.run]
source = ["src"]
branch = true
parallel = true
omit = [
    "*/tests/*",
    "*/__init__.py",
    "*/migrations/*",
]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "if TYPE_CHECKING:",
    "raise NotImplementedError",
    "if __name__ == .__main__.:",
    "@abstractmethod",
]
show_missing = true
skip_covered = true
fail_under = 80

[tool.coverage.html]
directory = "htmlcov"
```

---

## Integration Testing

### Database Testing
```python
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker


@pytest.fixture(scope="session")
def engine():
    """Create test database engine."""
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    yield engine
    engine.dispose()


@pytest.fixture(scope="function")
def db_session(engine):
    """Create test database session with rollback."""
    connection = engine.connect()
    transaction = connection.begin()
    Session = sessionmaker(bind=connection)
    session = Session()
    
    yield session
    
    session.close()
    transaction.rollback()
    connection.close()


def test_create_user(db_session):
    user = User(name="Test", email="test@example.com")
    db_session.add(user)
    db_session.commit()
    
    assert user.id is not None
    
    # Changes are rolled back after test
```

### API Testing
```python
import pytest
from httpx import AsyncClient
from myproject.main import app


@pytest.fixture
async def client():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac


@pytest.mark.asyncio
async def test_create_user(client):
    response = await client.post("/users", json={
        "name": "Test User",
        "email": "test@example.com",
    })
    
    assert response.status_code == 201
    assert response.json()["name"] == "Test User"


@pytest.mark.asyncio
async def test_get_user(client, db_session):
    # Create user in database first
    user = User(name="Test", email="test@example.com")
    db_session.add(user)
    db_session.commit()
    
    response = await client.get(f"/users/{user.id}")
    
    assert response.status_code == 200
    assert response.json()["email"] == "test@example.com"
```

---

## Performance Testing

### pytest-benchmark
```python
import pytest


def test_function_performance(benchmark):
    """Benchmark a function."""
    result = benchmark(my_function, arg1, arg2)
    assert result is not None


def test_with_setup(benchmark):
    """Benchmark with setup."""
    data = list(range(10000))
    
    result = benchmark(sorted, data)
    
    assert result == list(range(10000))


def test_compare_algorithms(benchmark):
    """Compare algorithm performance."""
    data = list(range(1000))
    
    # Set minimum rounds
    benchmark.pedantic(
        quicksort,
        args=(data.copy(),),
        rounds=100,
        iterations=10,
    )
```

---

## CI Configuration

### GitHub Actions
```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.11", "3.12"]
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
      
      - name: Install dependencies
        run: |
          pip install -e ".[dev]"
      
      - name: Run tests
        run: |
          pytest --cov=src --cov-report=xml
      
      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          file: ./coverage.xml
```

---

## Best Practices Checklist

- [ ] Use pytest 8.x with modern configuration
- [ ] Follow AAA pattern (Arrange, Act, Assert)
- [ ] Use fixtures for setup/teardown
- [ ] Use parametrize for multiple test cases
- [ ] Use Hypothesis for property-based testing
- [ ] Use pytest-asyncio for async testing
- [ ] Use respx for httpx mocking
- [ ] Use polyfactory for test data
- [ ] Maintain 80%+ coverage on critical code
- [ ] Run tests in CI/CD pipeline

---

**References:**
- [pytest Documentation](https://docs.pytest.org/)
- [Hypothesis Documentation](https://hypothesis.readthedocs.io/)
- [pytest-asyncio](https://pytest-asyncio.readthedocs.io/)
- [polyfactory](https://polyfactory.litestar.dev/)

# Flask Python Framework Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Flask Version:** 3.x | **SQLAlchemy:** 2.0
> **Priority:** P1 - Load for Flask projects

---

You are an expert in Flask, the Python microframework.

## Key Principles

- Micro: Simple core, extensible via extensions
- Explicit over implicit
- Flexible project structure
- Context locals (request, g, current_app)
- Supports async views (Flask 2.0+)
- Type hints for better DX

---

## Project Structure

```
project/
├── app/
│   ├── __init__.py          # Application factory
│   ├── config.py             # Configuration classes
│   ├── extensions.py         # Extension instances
│   ├── models/
│   │   ├── __init__.py
│   │   ├── user.py
│   │   └── post.py
│   ├── api/
│   │   ├── __init__.py       # API Blueprint
│   │   ├── users.py
│   │   ├── posts.py
│   │   └── auth.py
│   ├── schemas/              # Pydantic/Marshmallow schemas
│   │   ├── __init__.py
│   │   ├── user.py
│   │   └── post.py
│   ├── services/
│   │   └── user_service.py
│   ├── utils/
│   │   ├── security.py
│   │   └── decorators.py
│   ├── templates/
│   └── static/
├── migrations/               # Flask-Migrate
├── tests/
│   ├── conftest.py
│   ├── test_users.py
│   └── test_auth.py
├── .env
├── requirements.txt
└── run.py
```

---

## Application Factory Pattern

### app/__init__.py
```python
from flask import Flask
from flask_cors import CORS

from .config import config
from .extensions import db, migrate, jwt
from .api import api_bp
from .utils.error_handlers import register_error_handlers


def create_app(config_name: str = "default") -> Flask:
    """Application factory pattern."""
    app = Flask(__name__)
    
    # Load configuration
    app.config.from_object(config[config_name])
    
    # Initialize extensions
    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)
    CORS(app, resources={r"/api/*": {"origins": app.config["CORS_ORIGINS"]}})
    
    # Register blueprints
    app.register_blueprint(api_bp, url_prefix="/api/v1")
    
    # Register error handlers
    register_error_handlers(app)
    
    # Register CLI commands
    register_commands(app)
    
    # Shell context
    @app.shell_context_processor
    def make_shell_context():
        from .models import User, Post
        return {"db": db, "User": User, "Post": Post}
    
    return app


def register_commands(app: Flask) -> None:
    """Register CLI commands."""
    
    @app.cli.command("seed")
    def seed_db():
        """Seed database with sample data."""
        from .models import User
        
        user = User(
            email="admin@example.com",
            name="Admin",
            role="admin",
        )
        user.set_password("password123")
        db.session.add(user)
        db.session.commit()
        print("Database seeded!")
    
    @app.cli.command("create-admin")
    def create_admin():
        """Create admin user."""
        import click
        
        email = click.prompt("Email")
        password = click.prompt("Password", hide_input=True)
        
        from .models import User
        user = User(email=email, name="Admin", role="admin")
        user.set_password(password)
        db.session.add(user)
        db.session.commit()
        print(f"Admin user {email} created!")
```

---

## Configuration

### app/config.py
```python
import os
from datetime import timedelta


class Config:
    """Base configuration."""
    SECRET_KEY = os.environ.get("SECRET_KEY", "dev-secret-key")
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # JWT
    JWT_SECRET_KEY = os.environ.get("JWT_SECRET_KEY", SECRET_KEY)
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=1)
    JWT_REFRESH_TOKEN_EXPIRES = timedelta(days=30)
    
    # CORS
    CORS_ORIGINS = os.environ.get("CORS_ORIGINS", "*").split(",")


class DevelopmentConfig(Config):
    """Development configuration."""
    DEBUG = True
    SQLALCHEMY_DATABASE_URI = os.environ.get(
        "DATABASE_URL",
        "sqlite:///dev.db"
    )
    SQLALCHEMY_ECHO = True


class TestingConfig(Config):
    """Testing configuration."""
    TESTING = True
    SQLALCHEMY_DATABASE_URI = "sqlite:///:memory:"
    WTF_CSRF_ENABLED = False


class ProductionConfig(Config):
    """Production configuration."""
    DEBUG = False
    SQLALCHEMY_DATABASE_URI = os.environ.get("DATABASE_URL")
    
    @classmethod
    def init_app(cls, app):
        # Production-specific initialization
        import logging
        from logging.handlers import RotatingFileHandler
        
        handler = RotatingFileHandler(
            "logs/app.log",
            maxBytes=10240,
            backupCount=10
        )
        handler.setFormatter(logging.Formatter(
            "%(asctime)s %(levelname)s: %(message)s"
        ))
        handler.setLevel(logging.INFO)
        app.logger.addHandler(handler)


config = {
    "development": DevelopmentConfig,
    "testing": TestingConfig,
    "production": ProductionConfig,
    "default": DevelopmentConfig,
}
```

---

## Extensions

### app/extensions.py
```python
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_jwt_extended import JWTManager

# Initialize extensions without app
db = SQLAlchemy()
migrate = Migrate()
jwt = JWTManager()


# JWT callbacks
@jwt.user_identity_loader
def user_identity_lookup(user):
    """Return user ID as identity."""
    return user.id


@jwt.user_lookup_loader
def user_lookup_callback(_jwt_header, jwt_data):
    """Load user from JWT identity."""
    from .models import User
    identity = jwt_data["sub"]
    return db.session.get(User, identity)


@jwt.expired_token_loader
def expired_token_callback(jwt_header, jwt_data):
    return {"message": "Token has expired"}, 401


@jwt.invalid_token_loader
def invalid_token_callback(error):
    return {"message": "Invalid token"}, 401


@jwt.unauthorized_loader
def unauthorized_callback(error):
    return {"message": "Missing authorization header"}, 401
```

---

## Models (SQLAlchemy 2.0)

### app/models/user.py
```python
from datetime import datetime
from typing import TYPE_CHECKING
from werkzeug.security import generate_password_hash, check_password_hash
from sqlalchemy import String, Boolean, DateTime
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ..extensions import db

if TYPE_CHECKING:
    from .post import Post


class User(db.Model):
    __tablename__ = "users"
    
    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    name: Mapped[str] = mapped_column(String(100))
    password_hash: Mapped[str] = mapped_column(String(255))
    role: Mapped[str] = mapped_column(String(20), default="user")
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow
    )
    updated_at: Mapped[datetime | None] = mapped_column(
        DateTime,
        default=None,
        onupdate=datetime.utcnow
    )
    
    # Relationships
    posts: Mapped[list["Post"]] = relationship(
        back_populates="author",
        lazy="dynamic"
    )
    
    def set_password(self, password: str) -> None:
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password: str) -> bool:
        return check_password_hash(self.password_hash, password)
    
    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "email": self.email,
            "name": self.name,
            "role": self.role,
            "is_active": self.is_active,
            "created_at": self.created_at.isoformat(),
        }
    
    def __repr__(self) -> str:
        return f"<User {self.email}>"
```

### app/models/post.py
```python
from datetime import datetime
from typing import TYPE_CHECKING
from sqlalchemy import String, Text, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ..extensions import db

if TYPE_CHECKING:
    from .user import User


class Post(db.Model):
    __tablename__ = "posts"
    
    id: Mapped[int] = mapped_column(primary_key=True)
    title: Mapped[str] = mapped_column(String(200))
    content: Mapped[str] = mapped_column(Text)
    published: Mapped[bool] = mapped_column(Boolean, default=False)
    author_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow
    )
    
    # Relationships
    author: Mapped["User"] = relationship(back_populates="posts")
    
    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "title": self.title,
            "content": self.content,
            "published": self.published,
            "author_id": self.author_id,
            "created_at": self.created_at.isoformat(),
        }
```

---

## Blueprints

### app/api/__init__.py
```python
from flask import Blueprint

api_bp = Blueprint("api", __name__)

# Import routes after blueprint creation to avoid circular imports
from . import users, posts, auth  # noqa
```

### app/api/users.py
```python
from flask import request, jsonify
from flask_jwt_extended import jwt_required, current_user

from . import api_bp
from ..extensions import db
from ..models import User
from ..schemas.user import UserCreateSchema, UserUpdateSchema
from ..utils.decorators import admin_required


@api_bp.route("/users", methods=["GET"])
@jwt_required()
@admin_required
def list_users():
    """List all users (admin only)."""
    page = request.args.get("page", 1, type=int)
    per_page = request.args.get("per_page", 20, type=int)
    search = request.args.get("search", "")
    
    query = User.query
    
    if search:
        query = query.filter(
            db.or_(
                User.name.ilike(f"%{search}%"),
                User.email.ilike(f"%{search}%")
            )
        )
    
    pagination = query.order_by(User.created_at.desc()).paginate(
        page=page,
        per_page=per_page,
        error_out=False
    )
    
    return jsonify({
        "items": [user.to_dict() for user in pagination.items],
        "total": pagination.total,
        "page": page,
        "per_page": per_page,
        "pages": pagination.pages,
    })


@api_bp.route("/users/me", methods=["GET"])
@jwt_required()
def get_current_user():
    """Get current user profile."""
    return jsonify(current_user.to_dict())


@api_bp.route("/users/<int:user_id>", methods=["GET"])
@jwt_required()
def get_user(user_id: int):
    """Get user by ID."""
    user = db.session.get(User, user_id)
    
    if not user:
        return jsonify({"message": "User not found"}), 404
    
    return jsonify(user.to_dict())


@api_bp.route("/users", methods=["POST"])
def create_user():
    """Create new user (public registration)."""
    schema = UserCreateSchema()
    data = schema.load(request.json)
    
    # Check if email exists
    if User.query.filter_by(email=data["email"]).first():
        return jsonify({"message": "Email already registered"}), 409
    
    user = User(
        email=data["email"],
        name=data["name"],
    )
    user.set_password(data["password"])
    
    db.session.add(user)
    db.session.commit()
    
    return jsonify(user.to_dict()), 201


@api_bp.route("/users/<int:user_id>", methods=["PATCH"])
@jwt_required()
def update_user(user_id: int):
    """Update user."""
    # Check authorization
    if current_user.id != user_id and current_user.role != "admin":
        return jsonify({"message": "Not authorized"}), 403
    
    user = db.session.get(User, user_id)
    if not user:
        return jsonify({"message": "User not found"}), 404
    
    schema = UserUpdateSchema()
    data = schema.load(request.json)
    
    for key, value in data.items():
        setattr(user, key, value)
    
    db.session.commit()
    
    return jsonify(user.to_dict())


@api_bp.route("/users/<int:user_id>", methods=["DELETE"])
@jwt_required()
@admin_required
def delete_user(user_id: int):
    """Delete user (admin only)."""
    user = db.session.get(User, user_id)
    
    if not user:
        return jsonify({"message": "User not found"}), 404
    
    db.session.delete(user)
    db.session.commit()
    
    return "", 204
```

### app/api/auth.py
```python
from flask import request, jsonify
from flask_jwt_extended import (
    create_access_token,
    create_refresh_token,
    jwt_required,
    get_jwt_identity,
)

from . import api_bp
from ..models import User


@api_bp.route("/auth/login", methods=["POST"])
def login():
    """Login and get tokens."""
    data = request.json
    email = data.get("email")
    password = data.get("password")
    
    if not email or not password:
        return jsonify({"message": "Email and password required"}), 400
    
    user = User.query.filter_by(email=email).first()
    
    if not user or not user.check_password(password):
        return jsonify({"message": "Invalid credentials"}), 401
    
    if not user.is_active:
        return jsonify({"message": "Account is inactive"}), 403
    
    return jsonify({
        "access_token": create_access_token(identity=user),
        "refresh_token": create_refresh_token(identity=user),
        "user": user.to_dict(),
    })


@api_bp.route("/auth/refresh", methods=["POST"])
@jwt_required(refresh=True)
def refresh():
    """Refresh access token."""
    identity = get_jwt_identity()
    user = User.query.get(identity)
    
    if not user or not user.is_active:
        return jsonify({"message": "Invalid user"}), 401
    
    return jsonify({
        "access_token": create_access_token(identity=user),
    })


@api_bp.route("/auth/logout", methods=["POST"])
@jwt_required()
def logout():
    """Logout (client should discard tokens)."""
    # For stateless JWT, client just discards the token
    # For token blacklisting, you would add token to blacklist here
    return jsonify({"message": "Successfully logged out"})
```

---

## Schemas (Marshmallow)

### app/schemas/user.py
```python
from marshmallow import Schema, fields, validate, validates, ValidationError


class UserCreateSchema(Schema):
    email = fields.Email(required=True)
    name = fields.Str(required=True, validate=validate.Length(min=2, max=100))
    password = fields.Str(
        required=True,
        validate=validate.Length(min=8),
        load_only=True
    )
    
    @validates("password")
    def validate_password(self, value):
        if not any(c.isupper() for c in value):
            raise ValidationError("Password must contain uppercase letter")
        if not any(c.isdigit() for c in value):
            raise ValidationError("Password must contain a digit")


class UserUpdateSchema(Schema):
    email = fields.Email()
    name = fields.Str(validate=validate.Length(min=2, max=100))


class UserResponseSchema(Schema):
    id = fields.Int(dump_only=True)
    email = fields.Email()
    name = fields.Str()
    role = fields.Str()
    is_active = fields.Bool()
    created_at = fields.DateTime()
```

---

## Decorators

### app/utils/decorators.py
```python
from functools import wraps
from flask import jsonify
from flask_jwt_extended import current_user


def admin_required(fn):
    """Decorator to require admin role."""
    @wraps(fn)
    def wrapper(*args, **kwargs):
        if not current_user or current_user.role != "admin":
            return jsonify({"message": "Admin access required"}), 403
        return fn(*args, **kwargs)
    return wrapper


def roles_required(*roles):
    """Decorator to require specific roles."""
    def decorator(fn):
        @wraps(fn)
        def wrapper(*args, **kwargs):
            if not current_user or current_user.role not in roles:
                return jsonify({"message": "Access denied"}), 403
            return fn(*args, **kwargs)
        return wrapper
    return decorator
```

---

## Error Handlers

### app/utils/error_handlers.py
```python
from flask import Flask, jsonify
from marshmallow import ValidationError
from sqlalchemy.exc import IntegrityError
from werkzeug.exceptions import HTTPException


def register_error_handlers(app: Flask) -> None:
    """Register error handlers."""
    
    @app.errorhandler(ValidationError)
    def handle_validation_error(e):
        return jsonify({
            "message": "Validation error",
            "errors": e.messages,
        }), 400
    
    @app.errorhandler(IntegrityError)
    def handle_integrity_error(e):
        return jsonify({
            "message": "Database integrity error",
        }), 409
    
    @app.errorhandler(404)
    def handle_not_found(e):
        return jsonify({
            "message": "Resource not found",
        }), 404
    
    @app.errorhandler(405)
    def handle_method_not_allowed(e):
        return jsonify({
            "message": "Method not allowed",
        }), 405
    
    @app.errorhandler(500)
    def handle_internal_error(e):
        app.logger.error(f"Internal error: {e}")
        return jsonify({
            "message": "Internal server error",
        }), 500
    
    @app.errorhandler(HTTPException)
    def handle_http_exception(e):
        return jsonify({
            "message": e.description,
        }), e.code
```

---

## Async Views (Flask 2.0+)

```python
import asyncio
import httpx

@api_bp.route("/fetch-data", methods=["GET"])
async def fetch_external_data():
    """Async view example."""
    async with httpx.AsyncClient() as client:
        responses = await asyncio.gather(
            client.get("https://api.example.com/users"),
            client.get("https://api.example.com/posts"),
        )
    
    return jsonify({
        "users": responses[0].json(),
        "posts": responses[1].json(),
    })
```

---

## Class-Based Views

### app/api/views.py
```python
from flask import request, jsonify
from flask.views import MethodView
from flask_jwt_extended import jwt_required

from ..extensions import db
from ..models import Post


class PostAPI(MethodView):
    """Class-based view for posts."""
    
    decorators = [jwt_required()]
    
    def get(self, post_id: int | None = None):
        """Get post(s)."""
        if post_id is None:
            # List all posts
            posts = Post.query.filter_by(published=True).all()
            return jsonify([post.to_dict() for post in posts])
        else:
            # Get single post
            post = db.session.get(Post, post_id)
            if not post:
                return jsonify({"message": "Not found"}), 404
            return jsonify(post.to_dict())
    
    def post(self):
        """Create post."""
        data = request.json
        post = Post(
            title=data["title"],
            content=data["content"],
            author_id=1,  # Get from current_user
        )
        db.session.add(post)
        db.session.commit()
        return jsonify(post.to_dict()), 201
    
    def put(self, post_id: int):
        """Update post."""
        post = db.session.get(Post, post_id)
        if not post:
            return jsonify({"message": "Not found"}), 404
        
        data = request.json
        post.title = data.get("title", post.title)
        post.content = data.get("content", post.content)
        db.session.commit()
        
        return jsonify(post.to_dict())
    
    def delete(self, post_id: int):
        """Delete post."""
        post = db.session.get(Post, post_id)
        if not post:
            return jsonify({"message": "Not found"}), 404
        
        db.session.delete(post)
        db.session.commit()
        
        return "", 204


# Register the view
post_view = PostAPI.as_view("post_api")
api_bp.add_url_rule(
    "/posts",
    defaults={"post_id": None},
    view_func=post_view,
    methods=["GET"]
)
api_bp.add_url_rule(
    "/posts",
    view_func=post_view,
    methods=["POST"]
)
api_bp.add_url_rule(
    "/posts/<int:post_id>",
    view_func=post_view,
    methods=["GET", "PUT", "DELETE"]
)
```

---

## Testing

### tests/conftest.py
```python
import pytest
from app import create_app
from app.extensions import db
from app.models import User


@pytest.fixture(scope="function")
def app():
    """Create test application."""
    app = create_app("testing")
    
    with app.app_context():
        db.create_all()
        yield app
        db.drop_all()


@pytest.fixture
def client(app):
    """Create test client."""
    return app.test_client()


@pytest.fixture
def runner(app):
    """Create CLI runner."""
    return app.test_cli_runner()


@pytest.fixture
def auth_headers(client):
    """Create authenticated headers."""
    # Create user
    user = User(email="test@example.com", name="Test")
    user.set_password("Password123")
    db.session.add(user)
    db.session.commit()
    
    # Login
    response = client.post("/api/v1/auth/login", json={
        "email": "test@example.com",
        "password": "Password123",
    })
    
    token = response.json["access_token"]
    return {"Authorization": f"Bearer {token}"}
```

### tests/test_users.py
```python
import pytest
from app.models import User
from app.extensions import db


def test_create_user(client):
    """Test user creation."""
    response = client.post("/api/v1/users", json={
        "email": "new@example.com",
        "name": "New User",
        "password": "Password123",
    })
    
    assert response.status_code == 201
    assert response.json["email"] == "new@example.com"


def test_create_user_duplicate_email(client):
    """Test duplicate email rejection."""
    # Create first user
    client.post("/api/v1/users", json={
        "email": "test@example.com",
        "name": "Test User",
        "password": "Password123",
    })
    
    # Try duplicate
    response = client.post("/api/v1/users", json={
        "email": "test@example.com",
        "name": "Another User",
        "password": "Password123",
    })
    
    assert response.status_code == 409


def test_get_current_user(client, auth_headers):
    """Test getting current user."""
    response = client.get("/api/v1/users/me", headers=auth_headers)
    
    assert response.status_code == 200
    assert response.json["email"] == "test@example.com"


def test_unauthorized_access(client):
    """Test unauthorized access."""
    response = client.get("/api/v1/users/me")
    assert response.status_code == 401
```

---

## Production Deployment

### run.py
```python
from app import create_app

app = create_app("production")

if __name__ == "__main__":
    app.run()
```

### Gunicorn
```bash
# gunicorn.conf.py
workers = 4
bind = "0.0.0.0:8000"
accesslog = "-"
errorlog = "-"
capture_output = True

# Run
gunicorn -c gunicorn.conf.py "run:app"
```

---

## Best Practices Checklist

- [ ] Use application factory pattern
- [ ] Use blueprints for modularity
- [ ] Use Flask-Migrate for database migrations
- [ ] Use SQLAlchemy 2.0 with Mapped type hints
- [ ] Handle errors with error handlers
- [ ] Use Flask-JWT-Extended for authentication
- [ ] Write tests with pytest
- [ ] Use environment variables for configuration
- [ ] Use Gunicorn/uWSGI in production
- [ ] Set up proper logging

---

**References:**
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Flask-SQLAlchemy](https://flask-sqlalchemy.palletsprojects.com/)
- [Flask-JWT-Extended](https://flask-jwt-extended.readthedocs.io/)

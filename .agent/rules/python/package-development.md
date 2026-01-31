# Python Package Development Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Python:** 3.11+ | **Tools:** Hatch, Ruff, pytest
> **Priority:** P1 - Load for package development

---

You are an expert in Python package development and publishing.

## Key Principles

- Follow semantic versioning (SemVer)
- Use Hatch for modern packaging
- Use Ruff for linting and formatting
- Use Trusted Publisher for PyPI
- Write comprehensive documentation
- Implement thorough testing

---

## Project Structure

```
my-package/
├── src/
│   └── mypackage/
│       ├── __init__.py
│       ├── core.py
│       ├── utils.py
│       └── py.typed           # PEP 561
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   ├── test_core.py
│   └── test_utils.py
├── docs/
│   ├── index.md
│   ├── getting-started.md
│   ├── api-reference.md
│   └── changelog.md
├── .github/
│   ├── workflows/
│   │   ├── ci.yml
│   │   └── release.yml
│   ├── dependabot.yml
│   └── ISSUE_TEMPLATE/
├── pyproject.toml
├── README.md
├── LICENSE
├── CHANGELOG.md
├── CONTRIBUTING.md
└── .gitignore
```

---

## pyproject.toml

### Complete Configuration
```toml
[build-system]
requires = ["hatchling", "hatch-vcs"]
build-backend = "hatchling.build"

[project]
name = "mypackage"
dynamic = ["version"]
description = "A modern Python package"
readme = "README.md"
license = "MIT"
requires-python = ">=3.11"
authors = [
    { name = "Your Name", email = "you@example.com" },
]
maintainers = [
    { name = "Your Name", email = "you@example.com" },
]
keywords = [
    "python",
    "package",
    "example",
]
classifiers = [
    "Development Status :: 4 - Beta",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Operating System :: OS Independent",
    "Programming Language :: Python",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
    "Programming Language :: Python :: 3.13",
    "Programming Language :: Python :: 3 :: Only",
    "Typing :: Typed",
]
dependencies = [
    "pydantic>=2.0.0",
    "httpx>=0.25.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "pytest-cov>=4.0.0",
    "pytest-asyncio>=0.23.0",
    "ruff>=0.1.0",
    "mypy>=1.8.0",
    "pre-commit>=3.0.0",
]
docs = [
    "mkdocs>=1.5.0",
    "mkdocs-material>=9.0.0",
    "mkdocstrings[python]>=0.24.0",
]
all = [
    "mypackage[dev,docs]",
]

[project.urls]
Homepage = "https://github.com/user/mypackage"
Documentation = "https://mypackage.readthedocs.io"
Repository = "https://github.com/user/mypackage"
Changelog = "https://github.com/user/mypackage/blob/main/CHANGELOG.md"
Issues = "https://github.com/user/mypackage/issues"

[project.scripts]
mypackage = "mypackage.cli:main"

[project.entry-points."mypackage.plugins"]
example = "mypackage.plugins.example:ExamplePlugin"

# Hatch configuration
[tool.hatch.version]
source = "vcs"

[tool.hatch.build.hooks.vcs]
version-file = "src/mypackage/_version.py"

[tool.hatch.build.targets.sdist]
include = [
    "/src",
    "/tests",
]

[tool.hatch.build.targets.wheel]
packages = ["src/mypackage"]

[tool.hatch.envs.default]
dependencies = [
    "pytest",
    "pytest-cov",
    "ruff",
    "mypy",
]

[tool.hatch.envs.default.scripts]
test = "pytest {args:tests}"
test-cov = "pytest --cov=mypackage --cov-report=term-missing {args:tests}"
lint = "ruff check ."
format = "ruff format ."
typecheck = "mypy src/mypackage"
all = ["format", "lint", "typecheck", "test"]

[tool.hatch.envs.docs]
dependencies = [
    "mkdocs",
    "mkdocs-material",
    "mkdocstrings[python]",
]

[tool.hatch.envs.docs.scripts]
build = "mkdocs build"
serve = "mkdocs serve"
deploy = "mkdocs gh-deploy"

# Ruff configuration
[tool.ruff]
line-length = 88
target-version = "py311"
src = ["src", "tests"]

[tool.ruff.lint]
select = [
    "E",      # pycodestyle errors
    "W",      # pycodestyle warnings
    "F",      # Pyflakes
    "I",      # isort
    "B",      # flake8-bugbear
    "C4",     # flake8-comprehensions
    "UP",     # pyupgrade
    "ARG",    # flake8-unused-arguments
    "SIM",    # flake8-simplify
    "TCH",    # flake8-type-checking
    "PTH",    # flake8-use-pathlib
    "ERA",    # eradicate (commented code)
    "RUF",    # Ruff-specific rules
]
ignore = [
    "E501",   # line too long (handled by formatter)
]

[tool.ruff.lint.isort]
known-first-party = ["mypackage"]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"

# Pytest configuration
[tool.pytest.ini_options]
testpaths = ["tests"]
pythonpath = ["src"]
addopts = [
    "-v",
    "-ra",
    "--strict-markers",
    "--strict-config",
]
markers = [
    "slow: marks tests as slow",
    "integration: marks tests as integration tests",
]
filterwarnings = [
    "error",
]

# Coverage configuration
[tool.coverage.run]
source = ["mypackage"]
branch = true
parallel = true

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "if TYPE_CHECKING:",
    "if __name__ == .__main__.:",
    "raise NotImplementedError",
]
show_missing = true
fail_under = 80

# Mypy configuration
[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_configs = true
show_error_codes = true
enable_error_code = [
    "ignore-without-code",
    "truthy-bool",
]
exclude = [
    "tests",
]

[[tool.mypy.overrides]]
module = "tests.*"
disallow_untyped_defs = false
```

---

## Package Code

### Package Init
```python
# src/mypackage/__init__.py
"""
MyPackage - A modern Python package.

This package provides awesome functionality.
"""

from mypackage.core import MyClass, my_function
from mypackage._version import __version__

__all__ = [
    "__version__",
    "MyClass",
    "my_function",
]
```

### Core Module
```python
# src/mypackage/core.py
"""Core functionality."""

from __future__ import annotations

from typing import Any, TypeVar
from pydantic import BaseModel, Field

T = TypeVar("T")


class Config(BaseModel):
    """Configuration model."""
    
    name: str = Field(description="Configuration name")
    value: int = Field(default=0, ge=0)
    enabled: bool = Field(default=True)


class MyClass:
    """
    Main class for the package.
    
    This class provides the primary interface for the package.
    
    Attributes:
        name: The name of the instance.
        config: Configuration options.
    
    Example:
        >>> obj = MyClass("example")
        >>> obj.greet()
        'Hello, example!'
    """
    
    def __init__(self, name: str, *, config: Config | None = None) -> None:
        """
        Initialize MyClass.
        
        Args:
            name: The name for this instance.
            config: Optional configuration.
        """
        self.name = name
        self.config = config or Config(name=name)
    
    def greet(self) -> str:
        """
        Generate a greeting.
        
        Returns:
            A greeting string.
        """
        return f"Hello, {self.name}!"
    
    def process(self, data: list[T]) -> list[T]:
        """
        Process a list of items.
        
        Args:
            data: List of items to process.
        
        Returns:
            Processed list.
        
        Raises:
            ValueError: If data is empty.
        """
        if not data:
            raise ValueError("Data cannot be empty")
        
        return [item for item in data if item is not None]


def my_function(value: int) -> int:
    """
    Perform a calculation.
    
    Args:
        value: Input value.
    
    Returns:
        The calculated result.
    
    Example:
        >>> my_function(5)
        10
    """
    return value * 2
```

### Type Stub Marker
```python
# src/mypackage/py.typed
# Marker file for PEP 561
# This file should be empty
```

---

## Deprecation Handling

### Deprecation Utilities
```python
# src/mypackage/deprecation.py
"""Deprecation utilities."""

from __future__ import annotations

import functools
import warnings
from typing import Callable, TypeVar

F = TypeVar("F", bound=Callable[..., object])


def deprecated(
    reason: str,
    version: str,
    removal_version: str | None = None,
) -> Callable[[F], F]:
    """
    Mark a function or class as deprecated.
    
    Args:
        reason: Why it's deprecated and what to use instead.
        version: Version when deprecation was introduced.
        removal_version: Version when it will be removed.
    
    Example:
        @deprecated(
            reason="Use new_function() instead",
            version="2.0.0",
            removal_version="3.0.0",
        )
        def old_function():
            pass
    """
    def decorator(func: F) -> F:
        message = f"{func.__name__} is deprecated since version {version}. {reason}"
        if removal_version:
            message += f" It will be removed in version {removal_version}."
        
        @functools.wraps(func)
        def wrapper(*args: object, **kwargs: object) -> object:
            warnings.warn(
                message,
                DeprecationWarning,
                stacklevel=2,
            )
            return func(*args, **kwargs)
        
        # Add deprecation notice to docstring
        if wrapper.__doc__:
            wrapper.__doc__ = f".. deprecated:: {version}\n   {reason}\n\n{wrapper.__doc__}"
        
        return wrapper  # type: ignore[return-value]
    
    return decorator


def warn_renamed_argument(
    old_name: str,
    new_name: str,
    version: str,
) -> None:
    """Warn about a renamed argument."""
    warnings.warn(
        f"Argument '{old_name}' is deprecated, use '{new_name}' instead. "
        f"Deprecated since version {version}.",
        DeprecationWarning,
        stacklevel=3,
    )


# Usage
@deprecated(
    reason="Use MyClass instead",
    version="1.5.0",
    removal_version="2.0.0",
)
def old_function() -> None:
    """Old function that is deprecated."""
    pass
```

---

## Testing

### Conftest
```python
# tests/conftest.py
"""Pytest configuration and fixtures."""

import pytest
from mypackage import MyClass, Config


@pytest.fixture
def sample_config() -> Config:
    """Provide a sample configuration."""
    return Config(name="test", value=42, enabled=True)


@pytest.fixture
def my_class(sample_config: Config) -> MyClass:
    """Provide a MyClass instance."""
    return MyClass("test", config=sample_config)


@pytest.fixture
def temp_file(tmp_path):
    """Provide a temporary file."""
    file = tmp_path / "test.txt"
    file.write_text("test content")
    return file
```

### Test Module
```python
# tests/test_core.py
"""Tests for core module."""

import pytest
from mypackage import MyClass, my_function
from mypackage.core import Config


class TestConfig:
    """Tests for Config class."""
    
    def test_config_defaults(self):
        """Test default configuration values."""
        config = Config(name="test")
        
        assert config.name == "test"
        assert config.value == 0
        assert config.enabled is True
    
    def test_config_validation(self):
        """Test configuration validation."""
        with pytest.raises(ValueError):
            Config(name="test", value=-1)


class TestMyClass:
    """Tests for MyClass."""
    
    def test_init(self):
        """Test initialization."""
        obj = MyClass("example")
        
        assert obj.name == "example"
        assert obj.config is not None
    
    def test_init_with_config(self, sample_config: Config):
        """Test initialization with custom config."""
        obj = MyClass("example", config=sample_config)
        
        assert obj.config == sample_config
    
    def test_greet(self, my_class: MyClass):
        """Test greeting generation."""
        result = my_class.greet()
        
        assert result == "Hello, test!"
    
    def test_process(self, my_class: MyClass):
        """Test data processing."""
        data = [1, None, 2, None, 3]
        result = my_class.process(data)
        
        assert result == [1, 2, 3]
    
    def test_process_empty_raises(self, my_class: MyClass):
        """Test that empty data raises ValueError."""
        with pytest.raises(ValueError, match="cannot be empty"):
            my_class.process([])


class TestMyFunction:
    """Tests for my_function."""
    
    @pytest.mark.parametrize(
        "input_value,expected",
        [
            (0, 0),
            (1, 2),
            (5, 10),
            (-3, -6),
        ],
    )
    def test_my_function(self, input_value: int, expected: int):
        """Test my_function with various inputs."""
        assert my_function(input_value) == expected


class TestDeprecation:
    """Tests for deprecation warnings."""
    
    def test_deprecated_function_warns(self):
        """Test that deprecated function emits warning."""
        from mypackage.deprecation import old_function
        
        with pytest.warns(DeprecationWarning, match="old_function is deprecated"):
            old_function()
```

---

## GitHub Actions

### CI Workflow
```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      
      - name: Install uv
        uses: astral-sh/setup-uv@v4
      
      - name: Install dependencies
        run: uv sync --all-extras
      
      - name: Run Ruff
        run: |
          uv run ruff check .
          uv run ruff format --check .
      
      - name: Run mypy
        run: uv run mypy src/mypackage

  test:
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        python-version: ["3.11", "3.12", "3.13"]
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
      
      - name: Install uv
        uses: astral-sh/setup-uv@v4
      
      - name: Install dependencies
        run: uv sync --all-extras
      
      - name: Run tests
        run: uv run pytest --cov=mypackage --cov-report=xml
      
      - name: Upload coverage
        if: matrix.os == 'ubuntu-latest' && matrix.python-version == '3.12'
        uses: codecov/codecov-action@v4
        with:
          files: ./coverage.xml
          fail_ci_if_error: true
          token: ${{ secrets.CODECOV_TOKEN }}

  docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      
      - name: Install uv
        uses: astral-sh/setup-uv@v4
      
      - name: Install dependencies
        run: uv sync --group docs
      
      - name: Build docs
        run: uv run mkdocs build --strict
```

### Release Workflow (Trusted Publisher)
```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - "v*"

permissions:
  contents: write
  id-token: write  # Required for Trusted Publisher

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # For hatch-vcs
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      
      - name: Install build tools
        run: pip install build
      
      - name: Build package
        run: python -m build
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist/

  publish-testpypi:
    needs: build
    runs-on: ubuntu-latest
    environment: testpypi
    
    steps:
      - name: Download artifacts
        uses: actions/download-artifact@v4
        with:
          name: dist
          path: dist/
      
      - name: Publish to TestPyPI
        uses: pypa/gh-action-pypi-publish@release/v1
        with:
          repository-url: https://test.pypi.org/legacy/

  publish-pypi:
    needs: [build, publish-testpypi]
    runs-on: ubuntu-latest
    environment: pypi
    
    steps:
      - name: Download artifacts
        uses: actions/download-artifact@v4
        with:
          name: dist
          path: dist/
      
      - name: Publish to PyPI
        uses: pypa/gh-action-pypi-publish@release/v1

  github-release:
    needs: publish-pypi
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Download artifacts
        uses: actions/download-artifact@v4
        with:
          name: dist
          path: dist/
      
      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          files: dist/*
          generate_release_notes: true
```

### Dependabot
```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
    groups:
      dev-dependencies:
        patterns:
          - "pytest*"
          - "ruff"
          - "mypy"
    open-pull-requests-limit: 10
  
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

---

## Documentation

### MkDocs Configuration
```yaml
# mkdocs.yml
site_name: MyPackage
site_description: A modern Python package
site_url: https://mypackage.readthedocs.io
repo_url: https://github.com/user/mypackage
repo_name: user/mypackage

theme:
  name: material
  palette:
    - scheme: default
      primary: indigo
      accent: indigo
      toggle:
        icon: material/brightness-7
        name: Switch to dark mode
    - scheme: slate
      primary: indigo
      accent: indigo
      toggle:
        icon: material/brightness-4
        name: Switch to light mode
  features:
    - navigation.instant
    - navigation.tracking
    - navigation.sections
    - navigation.expand
    - search.suggest
    - search.highlight
    - content.code.copy
    - content.code.annotate

plugins:
  - search
  - mkdocstrings:
      handlers:
        python:
          options:
            docstring_style: google
            show_source: true
            show_root_heading: true

nav:
  - Home: index.md
  - Getting Started: getting-started.md
  - User Guide:
      - Installation: guide/installation.md
      - Configuration: guide/configuration.md
      - Usage: guide/usage.md
  - API Reference: api-reference.md
  - Changelog: changelog.md
  - Contributing: contributing.md

markdown_extensions:
  - pymdownx.highlight:
      anchor_linenums: true
  - pymdownx.superfences
  - pymdownx.tabbed:
      alternate_style: true
  - admonition
  - pymdownx.details
```

### Documentation Pages
```markdown
<!-- docs/index.md -->
# MyPackage

[![PyPI version](https://img.shields.io/pypi/v/mypackage.svg)](https://pypi.org/project/mypackage/)
[![Python versions](https://img.shields.io/pypi/pyversions/mypackage.svg)](https://pypi.org/project/mypackage/)
[![License](https://img.shields.io/pypi/l/mypackage.svg)](https://github.com/user/mypackage/blob/main/LICENSE)
[![CI](https://github.com/user/mypackage/workflows/CI/badge.svg)](https://github.com/user/mypackage/actions)
[![Coverage](https://codecov.io/gh/user/mypackage/branch/main/graph/badge.svg)](https://codecov.io/gh/user/mypackage)

A modern Python package for doing awesome things.

## Installation

```bash
pip install mypackage
```

## Quick Start

```python
from mypackage import MyClass

obj = MyClass("world")
print(obj.greet())  # Hello, world!
```

## Features

- ✨ Modern Python 3.11+ support
- 🔒 Type-safe with full type hints
- 📦 Easy installation from PyPI
- 📚 Comprehensive documentation

## License

MIT License
```

---

## Pre-commit Hooks

### Pre-commit Configuration
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.9
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-toml
      - id: check-added-large-files
      - id: check-merge-conflict
      - id: debug-statements

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.8.0
    hooks:
      - id: mypy
        additional_dependencies:
          - pydantic>=2.0.0
        args: [--strict]
```

---

## CHANGELOG

### CHANGELOG Format
```markdown
<!-- CHANGELOG.md -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New feature X

### Changed
- Updated dependency Y

### Deprecated
- Old function Z (use new_function instead)

### Removed
- Removed deprecated module

### Fixed
- Fixed bug in processing

### Security
- Fixed vulnerability CVE-XXXX

## [1.0.0] - 2024-01-15

### Added
- Initial release
- Core functionality
- Documentation
- CI/CD pipeline

[Unreleased]: https://github.com/user/mypackage/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/user/mypackage/releases/tag/v1.0.0
```

---

## Best Practices Checklist

- [ ] Use src layout for packages
- [ ] Use Hatch or uv for build/dev
- [ ] Use Ruff for linting and formatting
- [ ] Configure mypy with strict mode
- [ ] Write tests with pytest (80%+ coverage)
- [ ] Use Trusted Publisher for PyPI
- [ ] Set up GitHub Actions CI/CD
- [ ] Write MkDocs documentation
- [ ] Include py.typed marker
- [ ] Maintain CHANGELOG.md

---

**References:**
- [Python Packaging Guide](https://packaging.python.org/)
- [Hatch Documentation](https://hatch.pypa.io/)
- [Ruff Documentation](https://docs.astral.sh/ruff/)
- [MkDocs Material](https://squidfunk.github.io/mkdocs-material/)
- [Trusted Publishers](https://docs.pypi.org/trusted-publishers/)

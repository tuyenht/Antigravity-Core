---
name: "rust-patterns"
description: "Các mẫu thiết kế Rust: ownership, lifetimes, async, error handling và performance optimization."
---

# Rust Patterns

> **Status:** Active | **Version:** 1.0.0

## When to Use

- Building systems programming applications (CLI tools, servers, WebAssembly)
- Performance-critical backends or data processing pipelines
- Projects requiring memory safety without garbage collection
- Embedded systems or IoT applications

## Core Patterns

### 1. Ownership & Borrowing
```rust
// Prefer borrowing over cloning
fn process(data: &[u8]) -> Result<(), Error> {
    // Borrow, don't own
    Ok(())
}

// Use Cow for conditional ownership
use std::borrow::Cow;
fn normalize(input: &str) -> Cow<'_, str> {
    if input.contains(' ') {
        Cow::Owned(input.replace(' ', "_"))
    } else {
        Cow::Borrowed(input)
    }
}
```

### 2. Error Handling
```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
    #[error("Database error: {0}")]
    Database(#[from] sqlx::Error),
    #[error("Not found: {entity} with id {id}")]
    NotFound { entity: String, id: String },
    #[error("Validation failed: {0}")]
    Validation(String),
}

// Use anyhow for application code, thiserror for libraries
```

### 3. Async Patterns (Tokio)
```rust
use tokio::task::JoinSet;

async fn parallel_fetch(urls: Vec<String>) -> Vec<Result<String, reqwest::Error>> {
    let mut set = JoinSet::new();
    for url in urls {
        set.spawn(async move {
            reqwest::get(&url).await?.text().await
        });
    }
    let mut results = Vec::new();
    while let Some(result) = set.join_next().await {
        results.push(result.unwrap());
    }
    results
}
```

### 4. Builder Pattern
```rust
#[derive(Default)]
pub struct ServerConfig {
    host: String,
    port: u16,
    max_connections: usize,
}

impl ServerConfig {
    pub fn builder() -> ServerConfigBuilder {
        ServerConfigBuilder::default()
    }
}

#[derive(Default)]
pub struct ServerConfigBuilder {
    host: Option<String>,
    port: Option<u16>,
    max_connections: Option<usize>,
}

impl ServerConfigBuilder {
    pub fn host(mut self, host: impl Into<String>) -> Self {
        self.host = Some(host.into());
        self
    }
    pub fn port(mut self, port: u16) -> Self {
        self.port = Some(port);
        self
    }
    pub fn build(self) -> ServerConfig {
        ServerConfig {
            host: self.host.unwrap_or_else(|| "0.0.0.0".into()),
            port: self.port.unwrap_or(8080),
            max_connections: self.max_connections.unwrap_or(1000),
        }
    }
}
```

### 5. Type State Pattern
```rust
pub struct Request<State> {
    url: String,
    _state: std::marker::PhantomData<State>,
}

pub struct Pending;
pub struct Authenticated;

impl Request<Pending> {
    pub fn new(url: &str) -> Self {
        Request { url: url.to_string(), _state: std::marker::PhantomData }
    }
    pub fn authenticate(self, token: &str) -> Request<Authenticated> {
        Request { url: self.url, _state: std::marker::PhantomData }
    }
}

impl Request<Authenticated> {
    pub async fn send(self) -> Result<Response, Error> {
        // Only authenticated requests can be sent
        todo!()
    }
}
```

## Project Structure
```
src/
├── main.rs           # Entry point
├── lib.rs            # Library root
├── config.rs         # Configuration
├── errors.rs         # Error types (thiserror)
├── models/           # Domain models
├── handlers/         # Request handlers
├── services/         # Business logic
└── db/               # Database layer
```

## Key Dependencies (2026)
| Crate | Purpose | Version |
|-------|---------|---------|
| `tokio` | Async runtime | 1.x |
| `axum` | Web framework | 0.8+ |
| `sqlx` | Async SQL | 0.8+ |
| `serde` | Serialization | 1.x |
| `thiserror` | Error types | 2.x |
| `anyhow` | App errors | 1.x |
| `tracing` | Observability | 0.1.x |
| `clap` | CLI parsing | 4.x |

## Quality Checklist
```bash
cargo fmt -- --check      # Format
cargo clippy -- -D warnings  # Lint
cargo test                # Unit tests
cargo audit               # Security
cargo build --release     # Optimized build
```

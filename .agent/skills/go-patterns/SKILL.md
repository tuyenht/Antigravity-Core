---
name: "go-patterns"
description: "Các mẫu thiết kế Go: concurrency, interfaces, error handling và clean architecture."
---

# Go Patterns

> **Status:** Active | **Version:** 1.0.0

## When to Use

- Building microservices and distributed systems
- High-concurrency servers (APIs, gRPC, WebSocket)
- DevOps tooling and CLI applications
- Cloud-native infrastructure (Kubernetes operators, controllers)

## Core Patterns

### 1. Interface-Driven Design
```go
// Small interfaces — Go proverb: "The bigger the interface, the weaker the abstraction"
type Reader interface {
    Read(p []byte) (n int, err error)
}

type UserRepository interface {
    FindByID(ctx context.Context, id string) (*User, error)
    Create(ctx context.Context, user *User) error
}

// Accept interfaces, return structs
func NewUserService(repo UserRepository, logger *slog.Logger) *UserService {
    return &UserService{repo: repo, logger: logger}
}
```

### 2. Error Handling
```go
import "fmt"

// Sentinel errors for comparison
var (
    ErrNotFound     = fmt.Errorf("not found")
    ErrUnauthorized = fmt.Errorf("unauthorized")
)

// Wrap errors with context
func (s *UserService) GetUser(ctx context.Context, id string) (*User, error) {
    user, err := s.repo.FindByID(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("get user %s: %w", id, err)
    }
    return user, nil
}

// Custom error types
type ValidationError struct {
    Field   string
    Message string
}
func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation: %s - %s", e.Field, e.Message)
}
```

### 3. Concurrency Patterns
```go
// Worker pool
func processItems(ctx context.Context, items []Item, workers int) []Result {
    in := make(chan Item, len(items))
    out := make(chan Result, len(items))

    var wg sync.WaitGroup
    for i := 0; i < workers; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for item := range in {
                out <- process(item)
            }
        }()
    }

    for _, item := range items {
        in <- item
    }
    close(in)

    go func() {
        wg.Wait()
        close(out)
    }()

    var results []Result
    for r := range out {
        results = append(results, r)
    }
    return results
}

// Context with cancellation
func longRunningTask(ctx context.Context) error {
    select {
    case <-ctx.Done():
        return ctx.Err()
    case result := <-doWork():
        return handleResult(result)
    }
}
```

### 4. Functional Options
```go
type Server struct {
    host    string
    port    int
    timeout time.Duration
}

type Option func(*Server)

func WithHost(host string) Option {
    return func(s *Server) { s.host = host }
}
func WithPort(port int) Option {
    return func(s *Server) { s.port = port }
}
func WithTimeout(t time.Duration) Option {
    return func(s *Server) { s.timeout = t }
}

func NewServer(opts ...Option) *Server {
    s := &Server{host: "0.0.0.0", port: 8080, timeout: 30 * time.Second}
    for _, opt := range opts {
        opt(s)
    }
    return s
}
```

### 5. Middleware Pattern
```go
type Middleware func(http.Handler) http.Handler

func Logging(logger *slog.Logger) Middleware {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            start := time.Now()
            next.ServeHTTP(w, r)
            logger.Info("request", "method", r.Method, "path", r.URL.Path, "duration", time.Since(start))
        })
    }
}

func Chain(h http.Handler, middlewares ...Middleware) http.Handler {
    for i := len(middlewares) - 1; i >= 0; i-- {
        h = middlewares[i](h)
    }
    return h
}
```

## Project Structure
```
cmd/
├── api/main.go           # API server entry
├── worker/main.go         # Background worker
internal/
├── config/config.go       # Configuration
├── domain/                # Domain models
├── handler/               # HTTP handlers
├── service/               # Business logic
├── repository/            # Data access
├── middleware/             # HTTP middleware
pkg/
├── logger/                # Shared logger
├── validator/             # Input validation
```

## Key Dependencies (2026)
| Package | Purpose | Note |
|---------|---------|------|
| `net/http` | HTTP server | stdlib |
| `log/slog` | Structured logging | stdlib (Go 1.21+) |
| `database/sql` | Database | stdlib |
| `github.com/gin-gonic/gin` | Web framework | Popular |
| `github.com/go-chi/chi` | Lightweight router | Idiomatic |
| `google.golang.org/grpc` | gRPC | Google |
| `github.com/jackc/pgx` | PostgreSQL driver | Fast |
| `github.com/stretchr/testify` | Testing | Assert + Mock |

## Quality Checklist
```bash
go fmt ./...           # Format
go vet ./...           # Static analysis
golangci-lint run      # Comprehensive lint
go test ./... -race    # Tests with race detector
go build ./...         # Build check
```

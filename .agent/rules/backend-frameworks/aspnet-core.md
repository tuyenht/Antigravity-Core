# ASP.NET Core C# Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **.NET Version:** 8.x / 9.x
> **Priority:** P0 - Load for all ASP.NET Core projects

---

You are an expert in ASP.NET Core and modern C# backend development.

## Key Principles

- High performance and cross-platform
- Modular middleware pipeline
- Built-in Dependency Injection
- Unified programming model (Controllers + Minimal APIs)
- Cloud-native configuration
- Async/await everywhere
- Nullable reference types enabled

---

## .NET 8/9 Project Structure

```
src/
├── Api/
│   ├── Controllers/
│   ├── Endpoints/          # Minimal API endpoints
│   ├── Filters/
│   ├── Middleware/
│   └── Program.cs
├── Application/
│   ├── Commands/           # CQRS commands
│   ├── Queries/            # CQRS queries
│   ├── Services/
│   ├── DTOs/
│   └── Validators/
├── Domain/
│   ├── Entities/
│   ├── ValueObjects/
│   ├── Enums/
│   └── Exceptions/
├── Infrastructure/
│   ├── Data/
│   │   ├── AppDbContext.cs
│   │   ├── Configurations/
│   │   └── Migrations/
│   ├── Services/
│   └── Repositories/
└── Tests/
    ├── UnitTests/
    └── IntegrationTests/
```

---

## Program.cs (.NET 8+)

### Modern Minimal Bootstrap
```csharp
using Microsoft.AspNetCore.RateLimiting;
using System.Threading.RateLimiting;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add DbContext
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("Default")));

// Add custom services
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddSingleton<ICacheService, RedisCacheService>();

// Add authentication
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!))
        };
    });

// Add authorization
builder.Services.AddAuthorizationBuilder()
    .AddPolicy("AdminOnly", policy => policy.RequireRole("Admin"))
    .AddPolicy("Premium", policy => policy.RequireClaim("subscription", "premium"));

// Add rate limiting (.NET 7+)
builder.Services.AddRateLimiter(options =>
{
    options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(context =>
        RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: context.User.Identity?.Name ?? context.Request.Headers.Host.ToString(),
            factory: _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 100,
                Window = TimeSpan.FromMinutes(1)
            }));
    
    options.AddPolicy("api", context =>
        RateLimitPartition.GetTokenBucketLimiter(
            partitionKey: context.User.Identity?.Name ?? "anonymous",
            factory: _ => new TokenBucketRateLimiterOptions
            {
                TokenLimit = 10,
                ReplenishmentPeriod = TimeSpan.FromSeconds(1),
                TokensPerPeriod = 2
            }));
});

// Add output caching (.NET 7+)
builder.Services.AddOutputCache(options =>
{
    options.AddBasePolicy(builder => builder.Cache());
    options.AddPolicy("Expire30s", builder => 
        builder.Expire(TimeSpan.FromSeconds(30)));
    options.AddPolicy("VaryByQuery", builder => 
        builder.SetVaryByQuery("page", "pageSize"));
});

// Add health checks
builder.Services.AddHealthChecks()
    .AddDbContextCheck<AppDbContext>()
    .AddRedis(builder.Configuration.GetConnectionString("Redis")!);

var app = builder.Build();

// Configure pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseRateLimiter();
app.UseOutputCache();
app.UseAuthentication();
app.UseAuthorization();

// Map endpoints
app.MapControllers();
app.MapHealthChecks("/health");

// Minimal API endpoints
app.MapUserEndpoints();
app.MapProductEndpoints();

app.Run();
```

---

## Minimal APIs (.NET 8+)

### Endpoint Organization
```csharp
// Endpoints/UserEndpoints.cs
public static class UserEndpoints
{
    public static void MapUserEndpoints(this IEndpointRouteBuilder routes)
    {
        var group = routes.MapGroup("/api/users")
            .WithTags("Users")
            .RequireAuthorization();
        
        group.MapGet("/", GetUsers)
            .WithName("GetUsers")
            .WithOpenApi()
            .CacheOutput("Expire30s");
        
        group.MapGet("/{id:int}", GetUserById)
            .WithName("GetUserById");
        
        group.MapPost("/", CreateUser)
            .AddEndpointFilter<ValidationFilter<CreateUserRequest>>()
            .RequireAuthorization("AdminOnly");
        
        group.MapPut("/{id:int}", UpdateUser);
        
        group.MapDelete("/{id:int}", DeleteUser)
            .RequireAuthorization("AdminOnly");
    }
    
    private static async Task<Results<Ok<IEnumerable<UserDto>>, NotFound>> GetUsers(
        IUserService userService,
        [AsParameters] PaginationParams pagination,
        CancellationToken ct)
    {
        var users = await userService.GetAllAsync(pagination, ct);
        return TypedResults.Ok(users);
    }
    
    private static async Task<Results<Ok<UserDto>, NotFound>> GetUserById(
        int id,
        IUserService userService,
        CancellationToken ct)
    {
        var user = await userService.GetByIdAsync(id, ct);
        
        return user is null
            ? TypedResults.NotFound()
            : TypedResults.Ok(user);
    }
    
    private static async Task<Results<Created<UserDto>, ValidationProblem>> CreateUser(
        CreateUserRequest request,
        IUserService userService,
        CancellationToken ct)
    {
        var user = await userService.CreateAsync(request, ct);
        return TypedResults.Created($"/api/users/{user.Id}", user);
    }
    
    private static async Task<Results<NoContent, NotFound>> UpdateUser(
        int id,
        UpdateUserRequest request,
        IUserService userService,
        CancellationToken ct)
    {
        var success = await userService.UpdateAsync(id, request, ct);
        return success ? TypedResults.NoContent() : TypedResults.NotFound();
    }
    
    private static async Task<Results<NoContent, NotFound>> DeleteUser(
        int id,
        IUserService userService,
        CancellationToken ct)
    {
        var success = await userService.DeleteAsync(id, ct);
        return success ? TypedResults.NoContent() : TypedResults.NotFound();
    }
}

// Parameter binding
public record PaginationParams(
    [FromQuery] int Page = 1,
    [FromQuery] int PageSize = 10);
```

### Endpoint Filters
```csharp
public class ValidationFilter<T> : IEndpointFilter where T : class
{
    public async ValueTask<object?> InvokeAsync(
        EndpointFilterInvocationContext context,
        EndpointFilterDelegate next)
    {
        var model = context.Arguments.OfType<T>().FirstOrDefault();
        
        if (model is null)
        {
            return TypedResults.BadRequest("Request body is required");
        }
        
        var validator = context.HttpContext.RequestServices
            .GetService<IValidator<T>>();
        
        if (validator is not null)
        {
            var result = await validator.ValidateAsync(model);
            
            if (!result.IsValid)
            {
                return TypedResults.ValidationProblem(
                    result.Errors.ToDictionary(
                        e => e.PropertyName,
                        e => new[] { e.ErrorMessage }));
            }
        }
        
        return await next(context);
    }
}
```

---

## Controllers

### Modern Controller Pattern
```csharp
[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
public class ProductsController(
    IProductService productService,
    ILogger<ProductsController> logger) : ControllerBase
{
    [HttpGet]
    [OutputCache(PolicyName = "VaryByQuery")]
    [ProducesResponseType<IEnumerable<ProductDto>>(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll(
        [FromQuery] ProductFilter filter,
        CancellationToken ct)
    {
        var products = await productService.GetAllAsync(filter, ct);
        return Ok(products);
    }
    
    [HttpGet("{id:int}")]
    [ProducesResponseType<ProductDto>(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(int id, CancellationToken ct)
    {
        var product = await productService.GetByIdAsync(id, ct);
        
        if (product is null)
        {
            return NotFound();
        }
        
        return Ok(product);
    }
    
    [HttpPost]
    [Authorize(Policy = "AdminOnly")]
    [ProducesResponseType<ProductDto>(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Create(
        [FromBody] CreateProductRequest request,
        CancellationToken ct)
    {
        var product = await productService.CreateAsync(request, ct);
        
        logger.LogInformation("Product created: {ProductId}", product.Id);
        
        return CreatedAtAction(
            nameof(GetById),
            new { id = product.Id },
            product);
    }
    
    [HttpPut("{id:int}")]
    [Authorize(Policy = "AdminOnly")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Update(
        int id,
        [FromBody] UpdateProductRequest request,
        CancellationToken ct)
    {
        var success = await productService.UpdateAsync(id, request, ct);
        
        return success ? NoContent() : NotFound();
    }
    
    [HttpDelete("{id:int}")]
    [Authorize(Policy = "AdminOnly")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(int id, CancellationToken ct)
    {
        var success = await productService.DeleteAsync(id, ct);
        
        return success ? NoContent() : NotFound();
    }
}
```

---

## Entity Framework Core

### DbContext Configuration
```csharp
public class AppDbContext(DbContextOptions<AppDbContext> options) 
    : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<Product> Products => Set<Product>();
    public DbSet<Order> Orders => Set<Order>();
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(
            Assembly.GetExecutingAssembly());
    }
    
    public override async Task<int> SaveChangesAsync(
        CancellationToken cancellationToken = default)
    {
        // Audit timestamps
        foreach (var entry in ChangeTracker.Entries<BaseEntity>())
        {
            switch (entry.State)
            {
                case EntityState.Added:
                    entry.Entity.CreatedAt = DateTime.UtcNow;
                    break;
                case EntityState.Modified:
                    entry.Entity.UpdatedAt = DateTime.UtcNow;
                    break;
            }
        }
        
        return await base.SaveChangesAsync(cancellationToken);
    }
}
```

### Entity Configuration
```csharp
public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.ToTable("users");
        
        builder.HasKey(u => u.Id);
        
        builder.Property(u => u.Email)
            .IsRequired()
            .HasMaxLength(256);
        
        builder.HasIndex(u => u.Email)
            .IsUnique();
        
        builder.Property(u => u.Status)
            .HasConversion<string>()
            .HasMaxLength(50);
        
        // Relationships
        builder.HasMany(u => u.Orders)
            .WithOne(o => o.User)
            .HasForeignKey(o => o.UserId)
            .OnDelete(DeleteBehavior.Cascade);
        
        // Owned types (Value Objects)
        builder.OwnsOne(u => u.Address, address =>
        {
            address.Property(a => a.Street).HasMaxLength(200);
            address.Property(a => a.City).HasMaxLength(100);
            address.Property(a => a.PostalCode).HasMaxLength(20);
        });
    }
}
```

### Repository Pattern
```csharp
public interface IRepository<T> where T : class
{
    Task<T?> GetByIdAsync(int id, CancellationToken ct = default);
    Task<IEnumerable<T>> GetAllAsync(CancellationToken ct = default);
    Task<T> AddAsync(T entity, CancellationToken ct = default);
    Task UpdateAsync(T entity, CancellationToken ct = default);
    Task DeleteAsync(T entity, CancellationToken ct = default);
}

public class Repository<T>(AppDbContext context) : IRepository<T> 
    where T : class
{
    protected readonly DbSet<T> _dbSet = context.Set<T>();
    
    public virtual async Task<T?> GetByIdAsync(int id, CancellationToken ct = default)
    {
        return await _dbSet.FindAsync([id], ct);
    }
    
    public virtual async Task<IEnumerable<T>> GetAllAsync(CancellationToken ct = default)
    {
        return await _dbSet.AsNoTracking().ToListAsync(ct);
    }
    
    public virtual async Task<T> AddAsync(T entity, CancellationToken ct = default)
    {
        await _dbSet.AddAsync(entity, ct);
        await context.SaveChangesAsync(ct);
        return entity;
    }
    
    public virtual async Task UpdateAsync(T entity, CancellationToken ct = default)
    {
        _dbSet.Update(entity);
        await context.SaveChangesAsync(ct);
    }
    
    public virtual async Task DeleteAsync(T entity, CancellationToken ct = default)
    {
        _dbSet.Remove(entity);
        await context.SaveChangesAsync(ct);
    }
}
```

### Query Optimization
```csharp
// ✅ Use AsNoTracking for read-only queries
var users = await context.Users
    .AsNoTracking()
    .Where(u => u.IsActive)
    .ToListAsync(ct);

// ✅ Use projection to select only needed columns
var userDtos = await context.Users
    .AsNoTracking()
    .Where(u => u.IsActive)
    .Select(u => new UserDto
    {
        Id = u.Id,
        Name = u.Name,
        Email = u.Email
    })
    .ToListAsync(ct);

// ✅ Use Split Queries for large includes
var orders = await context.Orders
    .Include(o => o.Items)
    .Include(o => o.User)
    .AsSplitQuery()
    .ToListAsync(ct);

// ✅ Use compiled queries for hot paths
private static readonly Func<AppDbContext, int, Task<User?>> GetUserById =
    EF.CompileAsyncQuery((AppDbContext context, int id) =>
        context.Users.FirstOrDefault(u => u.Id == id));

// Usage
var user = await GetUserById(context, 1);

// ✅ Pagination
var pagedUsers = await context.Users
    .AsNoTracking()
    .OrderBy(u => u.Id)
    .Skip((page - 1) * pageSize)
    .Take(pageSize)
    .ToListAsync(ct);
```

---

## Dependency Injection

### Service Lifetimes
```csharp
// Transient: New instance every time
builder.Services.AddTransient<IEmailSender, SmtpEmailSender>();

// Scoped: One instance per request
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();

// Singleton: One instance for app lifetime
builder.Services.AddSingleton<ICacheService, RedisCacheService>();
builder.Services.AddSingleton(TimeProvider.System);

// Register with factory
builder.Services.AddScoped<IPaymentService>(provider =>
{
    var config = provider.GetRequiredService<IConfiguration>();
    var env = provider.GetRequiredService<IWebHostEnvironment>();
    
    return env.IsDevelopment()
        ? new MockPaymentService()
        : new StripePaymentService(config["Stripe:ApiKey"]!);
});

// Keyed services (.NET 8+)
builder.Services.AddKeyedScoped<INotificationService, EmailService>("email");
builder.Services.AddKeyedScoped<INotificationService, SmsService>("sms");

// Usage
public class OrderService(
    [FromKeyedServices("email")] INotificationService emailService,
    [FromKeyedServices("sms")] INotificationService smsService)
{
    // ...
}
```

### Primary Constructors (C# 12)
```csharp
// Before C# 12
public class UserService : IUserService
{
    private readonly IRepository<User> _repository;
    private readonly ILogger<UserService> _logger;
    
    public UserService(IRepository<User> repository, ILogger<UserService> logger)
    {
        _repository = repository;
        _logger = logger;
    }
}

// C# 12 with primary constructor
public class UserService(
    IRepository<User> repository,
    ILogger<UserService> logger) : IUserService
{
    public async Task<UserDto?> GetByIdAsync(int id, CancellationToken ct)
    {
        logger.LogInformation("Getting user {UserId}", id);
        
        var user = await repository.GetByIdAsync(id, ct);
        return user?.ToDto();
    }
}
```

---

## DTOs and Records

```csharp
// Records for immutable DTOs
public record UserDto(
    int Id,
    string Name,
    string Email,
    DateTime CreatedAt);

public record CreateUserRequest(
    [Required] string Name,
    [Required, EmailAddress] string Email,
    [Required, MinLength(8)] string Password);

public record UpdateUserRequest(
    string? Name,
    string? Email);

public record PaginatedResult<T>(
    IEnumerable<T> Items,
    int TotalCount,
    int Page,
    int PageSize)
{
    public int TotalPages => (int)Math.Ceiling(TotalCount / (double)PageSize);
    public bool HasPreviousPage => Page > 1;
    public bool HasNextPage => Page < TotalPages;
}

// Extension for mapping
public static class UserMappingExtensions
{
    public static UserDto ToDto(this User user) => new(
        user.Id,
        user.Name,
        user.Email,
        user.CreatedAt);
    
    public static User ToEntity(this CreateUserRequest request) => new()
    {
        Name = request.Name,
        Email = request.Email,
        PasswordHash = HashPassword(request.Password)
    };
}
```

---

## Error Handling

### Global Exception Handler
```csharp
public class GlobalExceptionHandler(
    ILogger<GlobalExceptionHandler> logger) : IExceptionHandler
{
    public async ValueTask<bool> TryHandleAsync(
        HttpContext httpContext,
        Exception exception,
        CancellationToken cancellationToken)
    {
        logger.LogError(exception, "Unhandled exception occurred");
        
        var (statusCode, title, detail) = exception switch
        {
            ValidationException validationEx => (
                StatusCodes.Status400BadRequest,
                "Validation Error",
                validationEx.Message),
            NotFoundException notFoundEx => (
                StatusCodes.Status404NotFound,
                "Not Found",
                notFoundEx.Message),
            UnauthorizedAccessException => (
                StatusCodes.Status401Unauthorized,
                "Unauthorized",
                "You are not authorized to access this resource"),
            _ => (
                StatusCodes.Status500InternalServerError,
                "Server Error",
                "An unexpected error occurred")
        };
        
        httpContext.Response.StatusCode = statusCode;
        
        await httpContext.Response.WriteAsJsonAsync(new ProblemDetails
        {
            Status = statusCode,
            Title = title,
            Detail = detail,
            Instance = httpContext.Request.Path
        }, cancellationToken);
        
        return true;
    }
}

// Register in Program.cs
builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
builder.Services.AddProblemDetails();

// Use in pipeline
app.UseExceptionHandler();
```

---

## Testing

### Integration Tests
```csharp
public class UserEndpointsTests(WebApplicationFactory<Program> factory)
    : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client = factory.CreateClient();
    
    [Fact]
    public async Task GetUsers_ReturnsOk()
    {
        // Arrange & Act
        var response = await _client.GetAsync("/api/users");
        
        // Assert
        response.EnsureSuccessStatusCode();
        var users = await response.Content
            .ReadFromJsonAsync<IEnumerable<UserDto>>();
        users.Should().NotBeNull();
    }
    
    [Fact]
    public async Task CreateUser_WithValidData_ReturnsCreated()
    {
        // Arrange
        var request = new CreateUserRequest(
            "John Doe",
            "john@example.com",
            "SecurePassword123!");
        
        // Act
        var response = await _client.PostAsJsonAsync("/api/users", request);
        
        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        
        var user = await response.Content.ReadFromJsonAsync<UserDto>();
        user.Should().NotBeNull();
        user!.Email.Should().Be("john@example.com");
    }
    
    [Fact]
    public async Task CreateUser_WithInvalidEmail_ReturnsBadRequest()
    {
        // Arrange
        var request = new CreateUserRequest(
            "John Doe",
            "invalid-email",
            "password");
        
        // Act
        var response = await _client.PostAsJsonAsync("/api/users", request);
        
        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }
}
```

### Custom WebApplicationFactory
```csharp
public class CustomWebApplicationFactory : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureServices(services =>
        {
            // Replace DbContext with in-memory database
            var descriptor = services.SingleOrDefault(
                d => d.ServiceType == typeof(DbContextOptions<AppDbContext>));
            
            if (descriptor is not null)
            {
                services.Remove(descriptor);
            }
            
            services.AddDbContext<AppDbContext>(options =>
                options.UseInMemoryDatabase("TestDb"));
            
            // Seed test data
            var sp = services.BuildServiceProvider();
            using var scope = sp.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            db.Database.EnsureCreated();
            SeedTestData(db);
        });
    }
    
    private static void SeedTestData(AppDbContext context)
    {
        context.Users.AddRange(
            new User { Name = "Test User", Email = "test@example.com" }
        );
        context.SaveChanges();
    }
}
```

---

## Performance Best Practices

- [ ] Use `async/await` throughout - never block with `.Result` or `.Wait()`
- [ ] Use `CancellationToken` in all async methods
- [ ] Use `AsNoTracking()` for read-only queries
- [ ] Use projection (`Select`) instead of loading full entities
- [ ] Enable response compression
- [ ] Use output caching for frequently accessed data
- [ ] Use rate limiting to prevent abuse
- [ ] Pool DbContext with `AddDbContextPool`
- [ ] Use compiled queries for hot paths
- [ ] Enable HTTP/2 and HTTP/3
- [ ] Consider Native AOT for startup performance

---

**References:**
- [ASP.NET Core Documentation](https://docs.microsoft.com/aspnet/core)
- [Entity Framework Core](https://docs.microsoft.com/ef/core)
- [.NET 8 What's New](https://learn.microsoft.com/dotnet/core/whats-new/dotnet-8)

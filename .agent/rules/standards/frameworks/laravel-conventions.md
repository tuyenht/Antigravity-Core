# Laravel 12 - Best Practices & Conventions

**Version:** Laravel 12.x  
**Updated:** 2026-01-16  
**Source:** Official Laravel docs + industry best practices

---

## Project Structure

### MVC Architecture
- **Fat Models, Skinny Controllers** - Business logic in models, controllers handle HTTP only
- Use Service classes for complex business logic
- Use Action classes for single-purpose operations
- Repository pattern for data access layer (optional, for complex apps)

### Directory Organization
```
app/
├── Actions/          # Single-purpose business actions
├── Services/         # Complex business logic services
├── Http/
│   ├── Controllers/  # Thin HTTP handlers
│   ├── Requests/     # Form request validation
│   └── Middleware/   # HTTP middleware
├── Models/           # Eloquent models
└── Providers/        # Service providers
```

---

## Eloquent ORM Best Practices

###

 N+1 Query Prevention **CRITICAL**

```php
// ❌ Bad - N+1 problem
$users = User::all();
foreach ($users as $user) {
    echo $user->posts->count(); // Queries posts foreach user!
}

// ✅ Good - Eager loading
$users = User::with('posts')->get();
foreach ($users as $user) {
    echo $user->posts->count(); // Already loaded
}

// ✅ Better - Count with WithCount
$users = User::withCount('posts')->get();
foreach ($users as $user) {
    echo $user->posts_count; // Single optimized query
}
```

### Select Only Needed Columns

```php
// ❌ Bad - Loads all columns
$users = User::all();

// ✅ Good - Select specific columns
$users = User::select(['id', 'name', 'email'])->get();
```

### Chunking for Large Datasets

```php
// ✅ Process large datasets in chunks
User::chunk(200, function ($users) {
    foreach ($users as $user) {
        // Process user
    }
});
```

### Query Scopes for Reusability

```php
// Model
class Post extends Model
{
    public function scopePublished($query)
    {
        return $query->where('status', 'published');
    }
    
    public function scopeRecent($query)
    {
        return $query->orderBy('created_at', 'desc');
    }
}

// Usage
$posts = Post::published()->recent()->get();
```

### Soft Deletes

```php
use Illuminate\Database\Eloquent\SoftDeletes;

class Post extends Model
{
    use SoftDeletes;
    
    protected $dates = ['deleted_at'];
}
```

---

## Routing Conventions

### RESTful Routes

```php
// Use resource controllers
Route::resource('posts', PostController::class);

// API versioning
Route::prefix('v1')->group(function () {
    Route::apiResource('posts', PostController::class);
});

// Route model binding
Route::get('/posts/{post}', [PostController::class, 'show']);
// Automatically injects Post model
```

---

## Validation

### Form Requests (Preferred)

```php
// app/Http/Requests/StorePostRequest.php
class StorePostRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'title' => 'required|max:255',
            'content' => 'required',
            'category_id' => 'required|exists:categories,id',
        ];
    }
}

// Controller
public function store(StorePostRequest $request)
{
    // Already validated
    $post = Post::create($request->validated());
}
```

### Custom Validation Rules

```php
// app/Rules/Uppercase.php
use Illuminate\Contracts\Validation\Rule;

class Uppercase implements Rule
{
    public function passes($attribute, $value): bool
    {
        return strtoupper($value) === $value;
    }
}
```

---

## Security Best Practices

### CSRF Protection (Auto-enabled)
```php
// Ensure CSRF middleware in web routes
protected $middlewareGroups = [
    'web' => [
        \App\Http\Middleware\VerifyCsrfToken::class,
    ],
];
```

### SQL Injection Prevention
```php
// ✅ Always use query builder or Eloquent
User::where('email', $email)->first();

// ❌ Never raw SQL with user input
DB::select("SELECT * FROM users WHERE email = '$email'"); // Vulnerable!

// ✅ If raw needed, use bindings
DB::select('SELECT * FROM users WHERE email = ?', [$email]);
```

### XSS Prevention

```blade
{{-- Good: Auto-escaped --}}
{{ $userInput }}

{{-- Dangerous: Unescaped HTML --}}
{!! $trustedHtml !!}
```

---

### Security Headers (REQUIRED)

**Create middleware for security headers:**

```php
// app/Http/Middleware/SecurityHeaders.php
<?php

namespace App\Http\Middleware;

use Closure;

class SecurityHeaders
{
    public function handle($request, Closure $next)
    {
        $response = $next($request);
        
        // Prevent clickjacking
        $response->headers->set('X-Frame-Options', 'DENY');
        
        // Prevent MIME sniffing
        $response->headers->set('X-Content-Type-Options', 'nosniff');
        
        // XSS Protection (legacy browsers)
        $response->headers->set('X-XSS-Protection', '1; mode=block');
        
        // Force HTTPS
        $response->headers->set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains; preload');
        
        // Referrer Policy
        $response->headers->set('Referrer-Policy', 'strict-origin-when-cross-origin');
        
        // Permissions Policy
        $response->headers->set('Permissions-Policy', 'geolocation=(), microphone=(), camera=()');
        
        // Content Security Policy
        $csp = [
            "default-src 'self'",
            "script-src 'self' 'unsafe-inline' 'unsafe-eval'", // Adjust for production
            "style-src 'self' 'unsafe-inline'",
            "img-src 'self' data: https:",
            "font-src 'self' data:",
            "connect-src 'self'",
            "frame-ancestors 'none'",
        ];
        $response->headers->set('Content-Security-Policy', implode('; ', $csp));
        
        return $response;
    }
}
```

**Register in `app/Http/Kernel.php`:**

```php
protected $middlewareGroups = [
    'web' => [
        \App\Http\Middleware\SecurityHeaders::class,
        // ... other middleware
    ],
];
```

**Test headers:**
```bash
# Check headers
curl -I https://yourapp.test

# Or use: https://securityheaders.com
```

---

### Rate Limiting (Throttling)

**Built-in throttle middleware:**

```php
// routes/api.php
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Cache\RateLimiting\Limit;

// Global API rate limit
RateLimiter::for('api', function (Request $request) {
    return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
});

// Login rate limit (stricter)
RateLimiter::for('login', function (Request $request) {
    return Limit::perMinute(5)->by($request->ip())
        ->response(function () {
            return response()->json([
                'message' => 'Too many login attempts. Please try again in 1 minute.'
            ], 429);
        });
});

// Apply to routes
Route::middleware('throttle:api')->group(function () {
    Route::get('/users', [UserController::class, 'index']);
});

Route::post('/login', [AuthController::class, 'login'])
    ->middleware('throttle:login');
```

**Custom rate limiting:**

```php
// In a controller
use Illuminate\Support\Facades\RateLimiter;

public function store(Request $request)
{
    $key = 'create-post:' . $request->user()->id;
    
    if (RateLimiter::tooManyAttempts($key, 10)) {
        $seconds = RateLimiter::availableIn($key);
        return response()->json([
            'message' => "Too many posts. Try again in {$seconds} seconds."
        ], 429);
    }
    
    RateLimiter::hit($key, 60); // 10 attempts per 60 seconds
    
    // Create post...
}
```

### Authentication
```php
// Use Laravel Sanctum for API auth
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens;
}
```

---

## Performance Optimization

### Caching

```php
// Cache expensive queries
$posts = Cache::remember('posts.all', 3600, function () {
    return Post::with('author')->published()->get();
});

// Cache tags for granular invalidation
Cache::tags(['posts'])->put('latest', $posts, 3600);
Cache::tags(['posts'])->flush(); // Clear all posts cache
```

### Database Indexing

```php
// Migration - Add indexes
Schema::table('posts', function (Blueprint $table) {
    $table->index('user_id');
    $table->index(['status', 'published_at']); // Composite
});
```

### Queue Long-Running Tasks

```php
// Dispatch to queue
use App\Jobs\ProcessPodcast;

ProcessPodcast::dispatch($podcast);

// With delay
ProcessPodcast::dispatch($podcast)->delay(now()->addMinutes(10));
```

---

## Testing with Pest (Recommended)

```php
// tests/Feature/PostTest.php
use App\Models\Post;

test('user can create post', function () {
    $user = User::factory()->create();
    
    $response = $this->actingAs($user)
        ->post('/posts', [
            'title' => 'Test Post',
            'content' => 'Content here',
        ]);
    
    $response->assertRedirect('/posts');
    expect(Post::count())->toBe(1);
});
```

---

## Laravel 12 New Features

### Enhanced Authentication
- Multi-factor authentication (MFA)
- Passkey support
- Improved token handling

### Performance Improvements
- Optimized lazy eager loading
- Better query performance
- Reduced memory footprint

---

## Common Patterns

### Service Pattern
```php
// app/Services/PostService.php
class PostService
{
    public function createPost(array $data): Post
    {
        return DB::transaction(function () use ($data) {
            $post = Post::create($data);
            $post->tags()->attach($data['tags']);
            return $post;
        });
    }
}
```

### Observer Pattern
```php
// app/Observers/PostObserver.php
class PostObserver
{
    public function creating(Post $post): void
    {
        $post->slug = Str::slug($post->title);
    }
}

// Register in AppServiceProvider
Post::observe(PostObserver::class);
```

---

## Performance Optimization

### Laravel Octane (2x Faster!)

**Installation:**
```bash
composer require laravel/octane
php artisan octane:install  # Choose Swoole or RoadRunner
```

**Configuration:**
```php
// config/octane.php
return [
    'server' => 'swoole',  // or 'roadrunner'
    'https' => false,
    'workers' => 4,        // CPU cores
    'task_workers' => 6,
    'max_requests' => 500, // Prevent memory leaks
];
```

**Usage:**
```bash
# Start Octane server
php artisan octane:start --workers=4 --max-requests=500

# Production with supervisor
php artisan octane:start --server=swoole --host=0.0.0.0 --port=8000
```

**Best Practices:**
- Reset state between requests (avoid memory leaks)
- Use dependency injection
- Clear resolved instances

---

### Laravel Horizon (Queue Dashboard)

**For queue monitoring and management:**

```bash
composer require laravel/horizon
php artisan horizon:install
```

**Configuration:**
```php
// config/horizon.php
'environments' => [
    'production' => [
        'supervisor-1' => [
            'connection' => 'redis',
            'queue' => ['high', 'default', 'low'],
            'balance' => 'auto',
            'processes' => 10,
            'tries' => 3,
        ],
    ],
],
```

**Access Dashboard:**
```
/horizon  // Real-time queue monitoring
```

---

### Redis Optimization

```php
// Use Redis for cache, sessions, queues
// .env
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

// Pipeline multiple Redis commands
Redis::pipeline(function ($pipe) {
    for ($i = 0; $i < 1000; $i++) {
        $pipe->set("key:$i", $i);
    }
});

// Use Redis tags for cache groups
Cache::tags(['users', 'posts'])->put('key', $value);
Cache::tags(['users'])->flush();  // Clear specific tag
```

---

### Database Indexing

```php
// Create indexes in migrations
Schema::table('posts', function (Blueprint $table) {
    // Single column index
    $table->index('user_id');
    
    // Composite index (order matters!)
    $table->index(['user_id', 'created_at']);
    
    // Unique index
    $table->unique('email');
    
    // Full-text search
    $table->fullText('title');
});

// Check slow queries
DB::listen(function ($query) {
    if ($query->time > 100) {  // > 100ms
        Log::warning('Slow query', [
            'sql' => $query->sql,
            'bindings' => $query->bindings,
            'time' => $query->time
        ]);
    }
});
```

---

### Query Profiling

```php
// Enable query log
DB::enableQueryLog();

// Your queries here
User::with('posts')->get();

// Get executed queries
dd(DB::getQueryLog());

// Use Laravel Telescope for production
composer require laravel/telescope
php artisan telescope:install
// Access /telescope
```

---

## Anti-Patterns to Avoid

❌ **Logic in templates** → Move to views/services  
❌ **Fat views** → Use services/managers  
❌ **No indexes** → Index foreign keys and frequent queries  
❌ **N+1 queries** → Use select_related/prefetch_related  
❌ **Raw SQL everywhere** → Use ORM  
❌ **No migrations** → Always create migrations  
❌ **Hardcoded settings** → Use environment variables

---

## Best Practices

✅ **Custom User model** from the start  
✅ **Use ORM** for database queries  
✅ **select_related/prefetch_related** for relationships  
✅ **Django REST Framework** for APIs  
✅ **Environment variables** for config  
✅ **Migrations** for schema changes  
✅ **pytest-django** for testing  
✅ **Celery** for async tasks
✅ **Laravel Octane** for production performance
✅ **Laravel Horizon** for queue monitoring
✅ **Redis** for caching and sessions
✅ **Database indexes** for frequent queries

---

**References:**
- [Laravel Official Docs](https://laravel.com/docs)
- [Laravel Octane](https://laravel.com/docs/octane)
- [Laravel Horizon](https://laravel.com/docs/horizon)
- [Laravel Telescope](https://laravel.com/docs/telescope)

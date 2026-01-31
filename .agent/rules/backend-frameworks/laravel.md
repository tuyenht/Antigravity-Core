# Laravel PHP Framework Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Laravel Version:** 11.x / 12.x
> **Priority:** P0 - Load for all Laravel projects

---

You are an expert in Laravel, the PHP framework for web artisans.

## Key Principles

- Convention over configuration
- Elegant, expressive syntax
- MVC architecture with modern patterns
- Powerful dependency injection container
- Rich ecosystem (Forge, Vapor, Nova, Octane)
- Modern PHP 8.2+ features

---

## Laravel 11+ Project Structure

### Slimmed Application Structure
```
app/
├── Http/
│   ├── Controllers/
│   ├── Middleware/        # Custom middleware only
│   └── Requests/
├── Models/
├── Providers/
│   └── AppServiceProvider.php  # Single provider by default
├── Actions/               # Single-purpose action classes
├── Services/              # Business logic services
├── Enums/                 # PHP 8.1+ Enums
└── DTOs/                  # Data Transfer Objects

bootstrap/
├── app.php               # Application bootstrap
└── providers.php         # Provider registration

routes/
├── web.php
├── api.php              # Optional, create with artisan
└── console.php          # Artisan commands
```

### Bootstrap Configuration (Laravel 11+)
```php
// bootstrap/app.php
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->web(append: [
            \App\Http\Middleware\HandleInertiaRequests::class,
        ]);
        
        $middleware->api(prepend: [
            \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
        ]);
        
        $middleware->alias([
            'admin' => \App\Http\Middleware\EnsureUserIsAdmin::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        $exceptions->reportable(function (Throwable $e) {
            // Report to error tracking service
        });
    })
    ->create();
```

---

## Eloquent ORM

### Model Definition
```php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Casts\Attribute;
use App\Enums\UserStatus;

class User extends Model
{
    use HasFactory, SoftDeletes;
    
    protected $fillable = [
        'name',
        'email',
        'password',
        'status',
    ];
    
    protected $hidden = [
        'password',
        'remember_token',
    ];
    
    // Laravel 11+ casts as method
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'status' => UserStatus::class,
            'settings' => 'array',
            'is_admin' => 'boolean',
        ];
    }
    
    // Modern accessor (Laravel 9+)
    protected function fullName(): Attribute
    {
        return Attribute::make(
            get: fn () => "{$this->first_name} {$this->last_name}",
            set: fn (string $value) => [
                'first_name' => explode(' ', $value)[0] ?? '',
                'last_name' => explode(' ', $value)[1] ?? '',
            ],
        );
    }
    
    // Relationships
    public function posts(): HasMany
    {
        return $this->hasMany(Post::class);
    }
    
    public function profile(): HasOne
    {
        return $this->hasOne(Profile::class);
    }
    
    public function roles(): BelongsToMany
    {
        return $this->belongsToMany(Role::class)
            ->withTimestamps()
            ->withPivot('assigned_at');
    }
    
    // Scopes
    public function scopeActive(Builder $query): Builder
    {
        return $query->where('status', UserStatus::Active);
    }
    
    public function scopeCreatedAfter(Builder $query, Carbon $date): Builder
    {
        return $query->where('created_at', '>=', $date);
    }
}
```

### Enums (PHP 8.1+)
```php
namespace App\Enums;

enum UserStatus: string
{
    case Active = 'active';
    case Inactive = 'inactive';
    case Suspended = 'suspended';
    
    public function label(): string
    {
        return match($this) {
            self::Active => 'Active User',
            self::Inactive => 'Inactive User',
            self::Suspended => 'Suspended User',
        };
    }
    
    public function color(): string
    {
        return match($this) {
            self::Active => 'green',
            self::Inactive => 'gray',
            self::Suspended => 'red',
        };
    }
}
```

### Query Optimization
```php
// ❌ N+1 Problem
$posts = Post::all();
foreach ($posts as $post) {
    echo $post->author->name; // Query per post!
}

// ✅ Eager Loading
$posts = Post::with('author')->get();
$posts = Post::with(['author', 'comments.user'])->get();

// ✅ Lazy Eager Loading
$posts = Post::all();
$posts->load('author');

// ✅ Conditional Eager Loading
$posts = Post::with(['author' => function ($query) {
    $query->select('id', 'name');
}])->get();

// ✅ Count without loading
$posts = Post::withCount('comments')->get();
// Access: $post->comments_count

// ✅ Chunking for large datasets
Post::chunk(200, function ($posts) {
    foreach ($posts as $post) {
        // Process
    }
});

// ✅ Lazy collections for memory efficiency
Post::lazy()->each(function ($post) {
    // Process one at a time
});

// ✅ Cursor for streaming
foreach (Post::cursor() as $post) {
    // Memory efficient iteration
}
```

---

## Controllers

### Resource Controller
```php
namespace App\Http\Controllers;

use App\Models\Post;
use App\Http\Requests\StorePostRequest;
use App\Http\Requests\UpdatePostRequest;
use App\Http\Resources\PostResource;
use Illuminate\Http\Request;

class PostController extends Controller
{
    public function index(Request $request)
    {
        $posts = Post::query()
            ->with('author')
            ->when($request->search, fn ($q, $search) => 
                $q->where('title', 'like', "%{$search}%")
            )
            ->when($request->status, fn ($q, $status) => 
                $q->where('status', $status)
            )
            ->latest()
            ->paginate(15);
        
        return PostResource::collection($posts);
    }
    
    public function store(StorePostRequest $request)
    {
        $post = $request->user()->posts()->create(
            $request->validated()
        );
        
        return new PostResource($post);
    }
    
    public function show(Post $post)
    {
        $post->load(['author', 'comments.user']);
        
        return new PostResource($post);
    }
    
    public function update(UpdatePostRequest $request, Post $post)
    {
        $post->update($request->validated());
        
        return new PostResource($post);
    }
    
    public function destroy(Post $post)
    {
        $post->delete();
        
        return response()->noContent();
    }
}
```

### Invokable Controller (Single Action)
```php
namespace App\Http\Controllers;

use App\Models\Post;
use App\Actions\PublishPost;

class PublishPostController extends Controller
{
    public function __invoke(Post $post, PublishPost $action)
    {
        $action->execute($post);
        
        return back()->with('success', 'Post published!');
    }
}
```

---

## Form Requests

```php
namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class StoreUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('create', User::class);
    }
    
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users,email'],
            'password' => [
                'required',
                'confirmed',
                Password::min(12)
                    ->letters()
                    ->mixedCase()
                    ->numbers()
                    ->symbols()
                    ->uncompromised(),
            ],
            'role' => ['required', 'exists:roles,id'],
            'avatar' => ['nullable', 'image', 'max:2048'],
        ];
    }
    
    public function messages(): array
    {
        return [
            'email.unique' => 'This email is already registered.',
            'password.uncompromised' => 'This password has been leaked in a data breach.',
        ];
    }
    
    protected function prepareForValidation(): void
    {
        $this->merge([
            'email' => strtolower($this->email),
        ]);
    }
}
```

---

## Actions Pattern

```php
namespace App\Actions;

use App\Models\User;
use App\Models\Team;
use Illuminate\Support\Facades\DB;

class CreateTeamAction
{
    public function execute(User $owner, array $data): Team
    {
        return DB::transaction(function () use ($owner, $data) {
            $team = Team::create([
                'name' => $data['name'],
                'owner_id' => $owner->id,
            ]);
            
            $team->members()->attach($owner, [
                'role' => 'owner',
            ]);
            
            event(new TeamCreated($team));
            
            return $team;
        });
    }
}

// Usage in controller
public function store(Request $request, CreateTeamAction $action)
{
    $team = $action->execute(
        $request->user(),
        $request->validated()
    );
    
    return new TeamResource($team);
}
```

---

## API Resources

```php
namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PostResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'slug' => $this->slug,
            'excerpt' => $this->excerpt,
            'content' => $this->when(
                $request->routeIs('posts.show'),
                $this->content
            ),
            'status' => $this->status,
            'published_at' => $this->published_at?->toISOString(),
            'author' => new UserResource($this->whenLoaded('author')),
            'comments' => CommentResource::collection(
                $this->whenLoaded('comments')
            ),
            'comments_count' => $this->whenCounted('comments'),
            'created_at' => $this->created_at->toISOString(),
            'links' => [
                'self' => route('posts.show', $this->id),
            ],
        ];
    }
}
```

---

## Inertia.js Integration

### Controller with Inertia
```php
namespace App\Http\Controllers;

use Inertia\Inertia;
use App\Models\Post;

class PostController extends Controller
{
    public function index()
    {
        return Inertia::render('Posts/Index', [
            'posts' => Post::query()
                ->with('author:id,name')
                ->latest()
                ->paginate(10)
                ->through(fn ($post) => [
                    'id' => $post->id,
                    'title' => $post->title,
                    'author' => $post->author->name,
                ]),
            'filters' => request()->only(['search', 'status']),
        ]);
    }
    
    public function create()
    {
        return Inertia::render('Posts/Create', [
            'categories' => Category::pluck('name', 'id'),
        ]);
    }
    
    public function store(StorePostRequest $request)
    {
        $post = Post::create($request->validated());
        
        return redirect()
            ->route('posts.show', $post)
            ->with('success', 'Post created!');
    }
}
```

### Inertia Middleware
```php
namespace App\Http\Middleware;

use Illuminate\Http\Request;
use Inertia\Middleware;
use Tighten\Ziggy\Ziggy;

class HandleInertiaRequests extends Middleware
{
    protected $rootView = 'app';
    
    public function share(Request $request): array
    {
        return array_merge(parent::share($request), [
            'auth' => [
                'user' => $request->user() ? [
                    'id' => $request->user()->id,
                    'name' => $request->user()->name,
                    'email' => $request->user()->email,
                    'avatar' => $request->user()->avatar_url,
                ] : null,
            ],
            'flash' => [
                'success' => fn () => $request->session()->get('success'),
                'error' => fn () => $request->session()->get('error'),
            ],
            'ziggy' => fn () => [
                ...(new Ziggy)->toArray(),
                'location' => $request->url(),
            ],
        ]);
    }
}
```

---

## Laravel Octane (High Performance)

### Configuration
```php
// config/octane.php
return [
    'server' => env('OCTANE_SERVER', 'swoole'), // or 'roadrunner'
    
    'https' => env('OCTANE_HTTPS', false),
    
    'listeners' => [
        RequestReceived::class => [
            // Listeners
        ],
    ],
    
    'warm' => [
        // Classes to warm on worker boot
        App\Services\HeavyService::class,
    ],
    
    'flush' => [
        // Services to flush between requests
    ],
    
    'cache' => [
        'rows' => 1000,
        'bytes' => 10000,
    ],
];
```

### Octane-Safe Code
```php
// ❌ Bad - Static state persists between requests
class BadService
{
    private static array $cache = [];
    
    public function getValue()
    {
        return self::$cache; // Leaks between requests!
    }
}

// ✅ Good - Use container or cache
class GoodService
{
    public function __construct(
        private Cache $cache
    ) {}
    
    public function getValue(string $key)
    {
        return $this->cache->get($key);
    }
}

// ✅ Concurrent tasks with Octane
use Laravel\Octane\Facades\Octane;

$results = Octane::concurrently([
    'users' => fn () => User::count(),
    'posts' => fn () => Post::count(),
    'comments' => fn () => Comment::count(),
]);
// $results['users'], $results['posts'], $results['comments']
```

---

## Laravel Precognition (Live Validation)

```php
// Controller
use Illuminate\Foundation\Http\FormRequest;

class StoreUserRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'email' => ['required', 'email', 'unique:users'],
            'password' => ['required', 'min:8'],
        ];
    }
}

// Route
Route::post('/users', [UserController::class, 'store'])
    ->middleware('precognitive');
```

```tsx
// React component with Precognition
import { useForm } from '@inertiajs/react';
import { usePrecognition } from 'laravel-precognition-react';

function CreateUser() {
    const form = usePrecognition('post', '/users', {
        email: '',
        password: '',
    });
    
    return (
        <form onSubmit={e => form.submit(e)}>
            <input
                value={form.data.email}
                onChange={e => form.setData('email', e.target.value)}
                onBlur={() => form.validate('email')}
            />
            {form.invalid('email') && (
                <span>{form.errors.email}</span>
            )}
            
            <input
                type="password"
                value={form.data.password}
                onChange={e => form.setData('password', e.target.value)}
                onBlur={() => form.validate('password')}
            />
            
            <button disabled={form.processing}>Create</button>
        </form>
    );
}
```

---

## Laravel Pennant (Feature Flags)

```php
use Laravel\Pennant\Feature;

// Define features
Feature::define('new-dashboard', function (User $user) {
    return $user->isAdmin() || $user->isBetaTester();
});

// Gradual rollout
Feature::define('new-checkout', function (User $user) {
    return $user->id % 10 < 3; // 30% of users
});

// Usage in code
if (Feature::active('new-dashboard')) {
    return view('dashboard.new');
}

return view('dashboard.old');

// Usage in Blade
@feature('new-dashboard')
    <x-new-dashboard />
@else
    <x-old-dashboard />
@endfeature

// Usage with Inertia
return Inertia::render('Dashboard', [
    'features' => [
        'newDashboard' => Feature::active('new-dashboard'),
    ],
]);
```

---

## Queues & Jobs

```php
namespace App\Jobs;

use App\Models\User;
use App\Notifications\WelcomeNotification;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Queue\Middleware\WithoutOverlapping;

class SendWelcomeEmail implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;
    
    public int $tries = 3;
    public int $backoff = 60;
    public int $timeout = 120;
    
    public function __construct(
        public User $user
    ) {}
    
    public function middleware(): array
    {
        return [
            new WithoutOverlapping($this->user->id),
        ];
    }
    
    public function handle(): void
    {
        $this->user->notify(new WelcomeNotification());
    }
    
    public function failed(Throwable $exception): void
    {
        // Handle failure
        Log::error('Welcome email failed', [
            'user_id' => $this->user->id,
            'error' => $exception->getMessage(),
        ]);
    }
}

// Dispatch
SendWelcomeEmail::dispatch($user);
SendWelcomeEmail::dispatch($user)->onQueue('emails');
SendWelcomeEmail::dispatch($user)->delay(now()->addMinutes(5));

// Job batching
Bus::batch([
    new ProcessPodcast($podcast1),
    new ProcessPodcast($podcast2),
    new ProcessPodcast($podcast3),
])->then(function (Batch $batch) {
    // All jobs completed successfully
})->catch(function (Batch $batch, Throwable $e) {
    // First batch job failure
})->finally(function (Batch $batch) {
    // Batch finished executing
})->dispatch();
```

---

## Testing with Pest

```php
// tests/Feature/PostTest.php
use App\Models\User;
use App\Models\Post;

beforeEach(function () {
    $this->user = User::factory()->create();
});

it('can create a post', function () {
    $response = $this->actingAs($this->user)
        ->post('/posts', [
            'title' => 'My Post',
            'content' => 'Post content',
        ]);
    
    $response->assertRedirect();
    
    expect(Post::count())->toBe(1)
        ->and(Post::first())
        ->title->toBe('My Post')
        ->author_id->toBe($this->user->id);
});

it('requires authentication to create posts', function () {
    $response = $this->post('/posts', [
        'title' => 'My Post',
    ]);
    
    $response->assertRedirect('/login');
});

it('validates required fields', function () {
    $this->actingAs($this->user)
        ->post('/posts', [])
        ->assertSessionHasErrors(['title', 'content']);
});

// Dataset testing
it('filters posts by status', function (string $status, int $expectedCount) {
    Post::factory()->count(3)->create(['status' => 'published']);
    Post::factory()->count(2)->create(['status' => 'draft']);
    
    $response = $this->get("/posts?status={$status}");
    
    expect($response->json('data'))->toHaveCount($expectedCount);
})->with([
    ['published', 3],
    ['draft', 2],
]);

// Snapshot testing
it('returns post resource', function () {
    $post = Post::factory()->create();
    
    $this->get("/api/posts/{$post->id}")
        ->assertJson(fn ($json) => 
            $json->where('data.id', $post->id)
                 ->where('data.title', $post->title)
                 ->etc()
        );
});
```

---

## Security Best Practices

```php
// Mass Assignment Protection
protected $fillable = ['name', 'email']; // Whitelist
protected $guarded = ['id', 'is_admin']; // Blacklist

// SQL Injection Prevention - Always use bindings
User::where('email', $email)->first(); // ✅ Safe
DB::select('SELECT * FROM users WHERE email = ?', [$email]); // ✅ Safe

// XSS Prevention - Blade escapes by default
{{ $userInput }}  // ✅ Escaped
{!! $userInput !!} // ❌ Raw - avoid unless sanitized

// CSRF Protection - Automatic in web routes
<form method="POST">
    @csrf
    ...
</form>

// Rate Limiting
RateLimiter::for('api', function (Request $request) {
    return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
});

// Encryption
$encrypted = Crypt::encryptString($secret);
$decrypted = Crypt::decryptString($encrypted);
```

---

## Performance Checklist

- [ ] Use `with()` for eager loading relationships
- [ ] Use `select()` to limit columns
- [ ] Use `chunking` or `cursor` for large datasets
- [ ] Cache expensive queries with `remember()`
- [ ] Use database indexes on frequently queried columns
- [ ] Use Redis for sessions, cache, and queues
- [ ] Enable OPcache in production
- [ ] Use Laravel Octane for high-traffic apps
- [ ] Optimize autoloader: `composer dump-autoload -o`
- [ ] Cache configuration: `php artisan config:cache`
- [ ] Cache routes: `php artisan route:cache`
- [ ] Cache views: `php artisan view:cache`

---

**References:**
- [Laravel Documentation](https://laravel.com/docs)
- [Laravel News](https://laravel-news.com/)
- [Laracasts](https://laracasts.com/)

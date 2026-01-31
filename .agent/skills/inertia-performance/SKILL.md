---
name: inertia-performance
description: Inertia.js performance optimization patterns for Laravel + React bridge
version: 1.0
impact-driven: true
priority-order: CRITICAL → HIGH → MEDIUM → LOW
stack: Inertia.js, Laravel, React
bridge: Laravel (Backend) ↔ Inertia.js ↔ React (Frontend)
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Inertia.js Performance Optimization

> Optimize the bridge between Laravel and React with impact-driven patterns.

---

## 🎯 WHY THIS MATTERS

**Inertia.js is the bridge:**
```
Laravel Backend
    ↓ (Inertia Response)
Inertia.js Router
    ↓ (Props)
React Frontend
```

**Common Performance Issues:**
1. **Full-page reloads** when partial would suffice
2. **Over-serialization** - sending too much data
3. **No prefetching** - sequential navigation waterfalls
4. **Combined waterfalls** - Backend + Frontend delays stack

---

## 📚 OPTIMIZATION CATEGORIES

### 1. Partial Reloads (CRITICAL)

**Impact:** 70-90% faster navigation

#### Rule 1.1: Use `only` for Targeted Updates

**❌ Bad: Full Page Reload**
```typescript
// React Component
import { router } from '@inertiajs/react'

function FilterPosts() {
  const applyFilter = (status: string) => {
    // Reloads ENTIRE page (all props)
    router.visit(`/posts?status=${status}`)
  }
  
  return <button onClick={() => applyFilter('published')}>
    Published Only
  </button>
}
```

```php
// Laravel Controller
public function index(Request $request)
{
    return Inertia::render('Posts/Index', [
        'posts' => Post::where('status', $request->status ?? 'all')->paginate(),
        'categories' => Category::all(), // Reloaded unnecessarily
        'user' => auth()->user(), // Reloaded unnecessarily
        'stats' => $this->getStats(), // Expensive re-calculation
    ]);
}
```

**Performance:** Reloads everything (500ms)

---

**✅ Good: Partial Reload**
```typescript
// React Component
import { router } from '@inertiajs/react'

function FilterPosts() {
  const applyFilter = (status: string) => {
    // Only reload 'posts' prop
    router.reload({
      only: ['posts'],
      data: { status }
    })
  }
  
  return <button onClick={() => applyFilter('published')}>
    Published Only
  </button>
}
```

```php
// Laravel Controller (same code - Inertia handles lazy loading)
public function index(Request $request)
{
    return Inertia::render('Posts/Index', [
        'posts' => Post::where('status', $request->status ?? 'all')->paginate(),
        'categories' => Category::all(), // NOT reloaded (cached in client')
        'user' => auth()->user(), // NOT reloaded
        'stats' => $this->getStats(), // NOT re-calculated
    ]);
}
```

**Performance:** Only reloads posts (150ms)  
**Impact:** 500ms → 150ms (70% faster)

---

#### Rule 1.2: Use Lazy Props for Optional Data

**❌ Bad: Always Load Everything**
```php
public function show(Post $post)
{
    return Inertia::render('Posts/Show', [
        'post' => $post,
        // Always loaded, even if tab not opened
        'comments' => $post->comments()->with('user')->get(),
        'relatedPosts' => Post::where('category_id', $post->category_id)
            ->limit(5)
            ->get(),
    ]);
}
```

**Performance:** 800ms (loads comments + related even if not viewed)

---

**✅ Good: Lazy Load Optional Data**
```php
public function show(Post $post)
{
    return Inertia::render('Posts/Show', [
        'post' => $post,
        
        // Lazy: only loaded when requested
        'comments' => Inertia::lazy(fn () => 
            $post->comments()->with('user')->get()
        ),
        
        'relatedPosts' => Inertia::lazy(fn () =>
            Post::where('category_id', $post->category_id)
                ->limit(5)
                ->get()
        ),
    ]);
}
```

```typescript
// React - Load on demand
import { router } from '@inertiajs/react'

function PostShow({ post, comments, relatedPosts }: Props) {
  const [tab, setTab] = useState('content')
  
  const switchToComments = () => {
    setTab('comments')
    
    // Load comments only when tab opened
    if (!comments) {
      router.reload({ only: ['comments'] })
    }
  }
  
  return (
    <div>
      <button onClick={switchToComments}>Comments</button>
      {tab === 'comments' && <CommentsList comments={comments} />}
    </div>
  )
}
```

**Performance:** 200ms initial + 300ms when tab opened  
**Impact:** 800ms → 200-500ms (60-75% faster perceived)

---

### 2. Prop Minimization (CRITICAL)

**Impact:** 40-60% smaller payloads

#### Rule 2.1: Select Only Required Columns

**❌ Bad: Send Entire Models**
```php
public function index()
{
    return Inertia::render('Users/Index', [
        // Sends ALL columns (including password hash, remember_token, etc.)
        'users' => User::all()
    ]);
}
```

**Serialized payload:** 500KB (100 users × ~5KB each)

---

**✅ Good: Select Specific Columns**
```php
public function index()
{
    return Inertia::render('Users/Index', [
        'users' => User::select('id', 'name', 'email', 'avatar_url')
            ->get()
    ]);
}
```

**Serialized payload:** 150KB (100 users × ~1.5KB each)  
**Impact:** 500KB → 150KB (70% smaller, 60% faster)

---

#### Rule 2.2: Use API Resources for Consistent Shaping

**✅ Better: API Resources**
```php
// app/Http/Resources/UserResource.php
class UserResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'avatar' => $this->avatar_url,
            // Conditional fields
            'phone' => $this->when($request->user()->isAdmin(), $this->phone),
        ];
    }
}

// Controller
public function index()
{
    return Inertia::render('Users/Index', [
        'users' => UserResource::collection(User::all())
    ]);
}
```

**Benefits:**
- Consistent data shape
- Type-safe on frontend
- Conditional fields
- Easier testing

---

### 3. Prefetching (HIGH)

**Impact:** 50-70% faster navigation

#### Rule 3.1: Prefetch on Hover

** Good: Prefetch Linked Pages**
```typescript
import { Link } from '@inertiajs/react'

// Automatically prefetches on hover
<Link href="/posts/123" prefetch>
  View Post
</Link>

// Or manual prefetch
import { router } from '@inertiajs/react'

<button
  onMouseEnter={() => router.prefetch('/posts/123')}
  onClick={() => router.visit('/posts/123')}
>
  View Post
</button>
```

**Impact:**
- Without prefetch: Click → 500ms load
- With prefetch: Click → instant (already cached)

---

### 4. Combined Waterfall Elimination (CRITICAL)

**Impact:** 2-5× faster page loads

#### Rule 4.1: Parallel Backend Operations

**❌ Bad: Sequential Laravel Queries**
```php
public function dashboard()
{
    // Sequential: 100ms + 150ms + 200ms = 450ms
    $user = auth()->user(); // 100ms
    $stats = $this->getStats(); // 150ms (depends on user)
    $notifications = Notification::where('user_id', $user->id)->get(); // 200ms
    
    return Inertia::render('Dashboard', [
        'user' => $user,
        'stats' => $stats,
        'notifications' => $notifications,
    ]);
}
```

**✅ Good: Parallel Queries** (if independent)
```php
use Illuminate\Support\Facades\DB;

public function dashboard()
{
    $user = auth()->user();
    
    // Parallel: max(150ms, 200ms) = 200ms
    [$stats, $notifications] = [
        function () { return $this->getStats(); },
        function () use ($user) { 
            return Notification::where('user_id', $user->id)->get();
        },
    ];
    
    // Execute in parallel using async (requires swoole/octane)
    // Or at minimum, ensure queries are independent
    
    return Inertia::render('Dashboard', [
        'user' => $user,
        'stats' => $stats(),
        'notifications' => $notifications(),
    ]);
}
```

---

#### Rule 4.2: Eliminate Frontend  Waterfalls Too

**❌ Bad: Sequential Frontend + Backend**
```typescript
// Page component
function Dashboard({ user }: Props) {
  const [notifications, setNotifications] = useState([])
  
  useEffect(() => {
    // Waterfall: Only starts AFTER page loaded!
    fetch('/api/notifications')
      .then(r => r.json())
      .then(setNotifications)
  }, [])
  
  return <div>{/* UI */}</div>
}
```

**✅ Good: Load Everything from Inertia**
```php
// Controller - Load all data upfront
public function dashboard()
{
    return Inertia::render('Dashboard', [
        'user' => auth()->user(),
        'notifications' => Notification::where('user_id', auth()->id())->get(),
    ]);
}
```

```typescript
// Component - No additional fetching
function Dashboard({ user, notifications }: Props) {
  return <div>{/* All data available */}</div>
}
```

**Impact:** Sequential (Laravel + React fetch) → Parallel (single Inertia load)

---

## 🎯 USAGE GUIDELINES

### When to Apply

✅ **DO optimize when:**
- Navigating between pages feels slow
- Initial page load > 500ms
- Payloads > 100KB
- Complex dashboards with tabs

❌ **DON'T optimize when:**
- Prototyping/MVP
- Pages already load < 200ms
- Simple CRUD forms

---

### Priority Checklist

**CRITICAL (Fix First):**
- [ ] Use `only` for partial reloads
- [ ] Lazy load optional/tabbed data
- [ ] Select only required columns
- [ ] Eliminate Laravel backend waterfalls

**HIGH (Fix Second):**
- [ ] Implement prefetching
- [ ] Use API Resources for shaping
- [ ] Cache Inertia responses

**MEDIUM (Fix Later):**
- [ ] Optimize serialization format
- [ ] Implement pagination
- [ ] Use WebSockets for realtime (if needed)

---

## 📊 METRICS TO TRACK

- [ ] Initial page load time (target: < 500ms)
- [ ] Navigation time (target: < 200ms)
- [ ] Payload size (target: < 100KB)
- [ ] Prefetch hit rate (target: > 70%)

---

## 🔗 INTEGRATION

**Stack:**
```
Laravel (laravel-performance skill)
    ↓
Inertia.js (THIS SKILL)
    ↓
React (react-performance skill)
```

**Use all three together for maximum impact!**

---

## 📖 REFERENCES

- [Inertia.js Docs](https://inertiajs.com)
- [Partial Reloads](https://inertiajs.com/partial-reloads)
- [Lazy Props](https://inertiajs.com/shared-data#lazy-data-evaluation)
- [Prefetching](https://inertiajs.com/links#prefetching)

---

**Created:** 2026-01-19  
**Version:** 1.0  
**Bridge:** Laravel ↔ Inertia.js ↔ React  
**Impact:** CRITICAL for Laravel + React stacks

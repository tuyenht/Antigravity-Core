<?php

namespace App\Http\Controllers;

use App\Models\Post;
use Inertia\Inertia;

// ❌ BAD: Full Page Reload on Filter Change
class PostControllerBad extends Controller
{
    public function index(Request $request)
    {
        return Inertia::render('Posts/Index', [
            // All props reloaded on EVERY filter change
            'posts' => Post::where('status', $request->status ?? 'all')
                ->paginate(20),
            'categories' => Category::all(), // Unchanging - why reload?
            'user' => auth()->user(), // Unchanging
            'stats' => $this->calculateStats(), // Expensive - recomputed!
        ]);
    }
}

// React Component - triggers full reload
import { router } from '@inertiajs/react'

export default function PostsIndex({ posts, categories, user, stats }) {
    const filterByStatus = (status) => {
        // Full page reload - slow!
        router.visit(`/posts?status=${status}`)
    }
    
    return (
        <div>
            <button onClick={() => filterByStatus('published')}>
                Published
            </button>
            {/* Renders posts */}
        </div>
    )
}

// Performance: 500ms (reloads everything)


// ✅ GOOD: Partial Reload - Only Update What Changed
class PostControllerGood extends Controller
{
    public function index(Request $request)
    {
        return Inertia::render('Posts/Index', [
            'posts' => Post::where('status', $request->status ?? 'all')
                ->paginate(20),
            // These won't be reloaded when using 'only'
            'categories' => Category::all(),
            'user' => auth()->user(),
            'stats' => $this->calculateStats(),
        ]);
    }
}

// React Component - partial reload
import { router } from '@inertiajs/react'

export default function PostsIndex({ posts, categories, user, stats }) {
    const filterByStatus = (status) => {
        // Only reload 'posts' prop - fast!
        router.reload({
            only: ['posts'],
            data: { status }
        })
    }
    
    return (
        <div>
            <button onClick={() => filterByStatus('published')}>
                Published
            </button>
            {/* Renders posts */}
        </div>
    )
}

// Performance: 150ms (only reloads posts)
// Impact: 500ms → 150ms (70% faster)

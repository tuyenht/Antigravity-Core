<?php

namespace App\Http\Controllers;

use App\Models\User;

// ❌ BAD: N+1 Query Problem
class DashboardControllerBad extends Controller
{
    public function index()
    {
        // Query 1: SELECT * FROM users
        $users = User::all();
        
        // For EACH user: SELECT * FROM posts WHERE user_id = ?
        // If 100 users → 100 additional queries!
        // Total: 101 queries
        
        return view('dashboard', compact('users'));
    }
}

// Blade template causes N+1:
// @foreach ($users as $user)
//     {{ $user->name }}: {{ $user->posts->count() }} posts
// @endforeach


// ✅ GOOD: Eager Loading Eliminates N+1
class DashboardControllerGood extends Controller
{
    public function index()
    {
        // Single query with JOIN
        // SELECT users.*, COUNT(posts.id) as posts_count
        // FROM users  
        // LEFT JOIN posts ON users.id = posts.user_id
        // GROUP BY users.id
        
        $users = User::withCount('posts')->get();
        
        // Total: 1-2 queries (regardless of user count)
        
        return view('dashboard', compact('users'));
    }
}

// Blade template - no additional queries:
// @foreach ($users as $user)
//     {{ $user->name }}: {{ $user->posts_count }} posts
// @endforeach


// Impact: 600ms (101 queries) → 100ms (2 queries)
// Result: 6× faster

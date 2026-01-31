// Example: React component with async waterfall issue

import { useEffect, useState } from 'react'

// ❌ BAD: Waterfall pattern (fetch sequentially)
export function DashboardBad() {
    const [user, setUser] = useState(null)
    const [posts, setPosts] = useState([])
    const [comments, setComments] = useState([])

    useEffect(() => {
        async function loadData() {
            // These run sequentially - WATERFALL!
            const userData = await fetch('/api/user').then(r => r.json())
            setUser(userData)

            const postsData = await fetch('/api/posts').then(r => r.json())
            setPosts(postsData)

            const commentsData = await fetch('/api/comments').then(r => r.json())
            setComments(commentsData)
        }

        loadData()
    }, [])

    if (!user) return <div>Loading...</div>

    return (
        <div>
            <h1>{user.name}</h1>
            <PostsList posts={posts} />
            <CommentsList comments={comments} />
        </div>
    )
}

// ✅ GOOD: Parallel fetching with Promise.all()
export function DashboardGood() {
    const [user, setUser] = useState(null)
    const [posts, setPosts] = useState([])
    const [comments, setComments] = useState([])

    useEffect(() => {
        async function loadData() {
            // All fetch in parallel - 3x FASTER!
            const [userData, postsData, commentsData] = await Promise.all([
                fetch('/api/user').then(r => r.json()),
                fetch('/api/posts').then(r => r.json()),
                fetch('/api/comments').then(r => r.json())
            ])

            setUser(userData)
            setPosts(postsData)
            setComments(commentsData)
        }

        loadData()
    }, [])

    if (!user) return <div>Loading...</div>

    return (
        <div>
            <h1>{user.name}</h1>
            <PostsList posts={posts} />
            <CommentsList comments={comments} />
        </div>
    )
}

// Impact: 600ms (200+200+200) → 200ms (max of parallel)
// Result: 3x faster initial load

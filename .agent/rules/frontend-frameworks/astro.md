# Astro Static Site Generation Expert

> **Version:** 2.0.0 | **Updated:** 2026-02-01  
> **Astro:** 4.x | **Content Collections** | **Islands Architecture**  
> **Priority:** P0 - Load for Astro projects

---

You are an expert in Astro for building content-driven websites.

## Core Principles

- Content-focused (MPA architecture)
- Zero JavaScript by default
- Islands Architecture (Partial Hydration)
- Server-first rendering

---

## 1) Astro Components

### Component Structure
```astro
---
// ==========================================
// ASTRO COMPONENT - .astro file
// ==========================================

// Frontmatter: Server-side JS/TS (runs at build time)
import Layout from '../layouts/Layout.astro';
import Card from '../components/Card.astro';
import { getCollection } from 'astro:content';
import type { CollectionEntry } from 'astro:content';

// Props interface
interface Props {
  title: string;
  description?: string;
  posts?: CollectionEntry<'blog'>[];
}

// Access props
const { title, description = 'Default description', posts = [] } = Astro.props;

// Access URL params (for dynamic routes)
const { slug } = Astro.params;

// Access request info
const url = Astro.url;
const pathname = Astro.url.pathname;
const searchParams = Astro.url.searchParams;

// Server-side data fetching
const response = await fetch('https://api.example.com/data');
const data = await response.json();

// Computed values
const formattedDate = new Date().toLocaleDateString();
const isProduction = import.meta.env.PROD;
---

<!-- Template: HTML-like syntax -->
<Layout title={title}>
  <main>
    <h1>{title}</h1>
    <p>{description}</p>
    
    <!-- Conditional rendering -->
    {isProduction && <Analytics />}
    
    <!-- List rendering -->
    <ul>
      {posts.map((post) => (
        <li>
          <Card
            title={post.data.title}
            href={`/blog/${post.slug}`}
            description={post.data.description}
          />
        </li>
      ))}
    </ul>
    
    <!-- Slots for content injection -->
    <slot />
    <slot name="sidebar" />
  </main>
</Layout>

<!-- Scoped CSS (default) -->
<style>
  main {
    max-width: 1200px;
    margin: 0 auto;
    padding: 2rem;
  }
  
  h1 {
    font-size: 2.5rem;
    color: var(--color-heading);
  }
  
  /* Use :global() for global styles */
  :global(body) {
    font-family: system-ui, sans-serif;
  }
</style>

<!-- Client-side script (bundled) -->
<script>
  // Runs in the browser
  document.addEventListener('DOMContentLoaded', () => {
    console.log('Page loaded');
  });
</script>

<!-- Inline script (not bundled) -->
<script is:inline>
  // Executes exactly as written
  console.log('Inline script');
</script>
```

### Layout Component
```astro
---
// layouts/Layout.astro
import Header from '../components/Header.astro';
import Footer from '../components/Footer.astro';
import { ViewTransitions } from 'astro:transitions';
import '../styles/global.css';

interface Props {
  title: string;
  description?: string;
  image?: string;
}

const { 
  title, 
  description = 'My Astro Site', 
  image = '/og-image.png' 
} = Astro.props;

const canonicalURL = new URL(Astro.url.pathname, Astro.site);
---

<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content={description} />
    
    <!-- Canonical URL -->
    <link rel="canonical" href={canonicalURL} />
    
    <!-- Open Graph -->
    <meta property="og:title" content={title} />
    <meta property="og:description" content={description} />
    <meta property="og:image" content={new URL(image, Astro.url)} />
    <meta property="og:url" content={canonicalURL} />
    <meta property="og:type" content="website" />
    
    <!-- Twitter -->
    <meta name="twitter:card" content="summary_large_image" />
    <meta name="twitter:title" content={title} />
    <meta name="twitter:description" content={description} />
    <meta name="twitter:image" content={new URL(image, Astro.url)} />
    
    <!-- Favicon -->
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
    
    <title>{title}</title>
    
    <!-- View Transitions -->
    <ViewTransitions />
  </head>
  <body>
    <Header />
    
    <main>
      <slot />
    </main>
    
    <Footer />
  </body>
</html>

<style is:global>
  :root {
    --color-bg: #ffffff;
    --color-text: #1a1a1a;
    --color-primary: #4f46e5;
    --color-heading: #111827;
  }
  
  @media (prefers-color-scheme: dark) {
    :root {
      --color-bg: #0f172a;
      --color-text: #e2e8f0;
      --color-primary: #818cf8;
      --color-heading: #f1f5f9;
    }
  }
  
  html {
    background: var(--color-bg);
    color: var(--color-text);
  }
  
  body {
    margin: 0;
    min-height: 100vh;
    display: flex;
    flex-direction: column;
  }
  
  main {
    flex: 1;
  }
</style>
```

---

## 2) Islands Architecture

### Hydration Directives
```astro
---
// Islands: Only hydrate interactive components
import StaticCard from '../components/Card.astro';
import InteractiveCounter from '../components/Counter.tsx';
import ImageCarousel from '../components/Carousel.vue';
import Newsletter from '../components/Newsletter.svelte';
import VideoPlayer from '../components/VideoPlayer.tsx';
import MobileMenu from '../components/MobileMenu.tsx';
import Comments from '../components/Comments.tsx';
---

<main>
  <!-- ==========================================
       STATIC COMPONENT (No JS)
       ========================================== -->
  <StaticCard title="Static" />
  
  
  <!-- ==========================================
       client:load - Hydrate immediately
       Use for: Above-the-fold interactive elements
       ========================================== -->
  <InteractiveCounter client:load initialCount={0} />
  
  
  <!-- ==========================================
       client:idle - Hydrate when main thread is free
       Use for: Lower-priority interactive elements
       ========================================== -->
  <Newsletter client:idle />
  
  
  <!-- ==========================================
       client:visible - Hydrate when in viewport
       Use for: Below-the-fold content
       ========================================== -->
  <ImageCarousel client:visible images={carouselImages} />
  <Comments client:visible postId={post.id} />
  
  
  <!-- ==========================================
       client:media - Hydrate on media query match
       Use for: Mobile-only or desktop-only components
       ========================================== -->
  <MobileMenu client:media="(max-width: 768px)" />
  
  
  <!-- ==========================================
       client:only - Skip SSR, client-only
       Use for: Components that can't render on server
       Specify the framework!
       ========================================== -->
  <VideoPlayer client:only="react" videoId="abc123" />
  
  
  <!-- ==========================================
       MULTIPLE FRAMEWORKS
       ========================================== -->
  <!-- React component -->
  <InteractiveCounter client:load />
  
  <!-- Vue component -->
  <ImageCarousel client:visible images={images} />
  
  <!-- Svelte component -->
  <Newsletter client:idle />
</main>
```

### Framework Components
```tsx
// ==========================================
// React Island - components/Counter.tsx
// ==========================================

import { useState } from 'react';

interface CounterProps {
  initialCount?: number;
  step?: number;
}

export default function Counter({ initialCount = 0, step = 1 }: CounterProps) {
  const [count, setCount] = useState(initialCount);
  
  return (
    <div className="counter">
      <button onClick={() => setCount(c => c - step)}>-</button>
      <span>{count}</span>
      <button onClick={() => setCount(c => c + step)}>+</button>
    </div>
  );
}


// ==========================================
// Vue Island - components/Carousel.vue
// ==========================================
/*
<script setup lang="ts">
import { ref } from 'vue';

interface Props {
  images: string[];
  autoplay?: boolean;
}

const props = withDefaults(defineProps<Props>(), {
  autoplay: false
});

const currentIndex = ref(0);

function next() {
  currentIndex.value = (currentIndex.value + 1) % props.images.length;
}

function prev() {
  currentIndex.value = currentIndex.value === 0 
    ? props.images.length - 1 
    : currentIndex.value - 1;
}
</script>

<template>
  <div class="carousel">
    <button @click="prev">←</button>
    <img :src="images[currentIndex]" alt="" />
    <button @click="next">→</button>
  </div>
</template>
*/


// ==========================================
// Svelte Island - components/Newsletter.svelte
// ==========================================
/*
<script lang="ts">
  let email = '';
  let status: 'idle' | 'loading' | 'success' | 'error' = 'idle';
  
  async function submit() {
    status = 'loading';
    try {
      await fetch('/api/newsletter', {
        method: 'POST',
        body: JSON.stringify({ email })
      });
      status = 'success';
    } catch {
      status = 'error';
    }
  }
</script>

<form on:submit|preventDefault={submit}>
  <input 
    type="email" 
    bind:value={email} 
    placeholder="Enter your email"
    disabled={status === 'loading'}
  />
  <button type="submit" disabled={status === 'loading'}>
    {status === 'loading' ? 'Subscribing...' : 'Subscribe'}
  </button>
  
  {#if status === 'success'}
    <p class="success">Thanks for subscribing!</p>
  {/if}
</form>
*/
```

---

## 3) Content Collections

### Collection Configuration
```typescript
// ==========================================
// src/content/config.ts
// ==========================================

import { z, defineCollection } from 'astro:content';

// Blog collection schema
const blogCollection = defineCollection({
  type: 'content',  // Markdown/MDX
  schema: ({ image }) => z.object({
    title: z.string(),
    description: z.string(),
    pubDate: z.coerce.date(),
    updatedDate: z.coerce.date().optional(),
    heroImage: image().optional(),
    author: z.string().default('Anonymous'),
    tags: z.array(z.string()).default([]),
    draft: z.boolean().default(false),
  }),
});

// Authors collection
const authorsCollection = defineCollection({
  type: 'data',  // JSON/YAML
  schema: ({ image }) => z.object({
    name: z.string(),
    email: z.string().email(),
    avatar: image(),
    bio: z.string(),
    social: z.object({
      twitter: z.string().url().optional(),
      github: z.string().url().optional(),
      linkedin: z.string().url().optional(),
    }).optional(),
  }),
});

// Docs collection with relations
const docsCollection = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    sidebar: z.object({
      order: z.number(),
      label: z.string().optional(),
      badge: z.enum(['new', 'updated', 'deprecated']).optional(),
    }),
    next: z.string().optional(),
    prev: z.string().optional(),
  }),
});

// Products collection (data)
const productsCollection = defineCollection({
  type: 'data',
  schema: ({ image }) => z.object({
    name: z.string(),
    price: z.number(),
    description: z.string(),
    image: image(),
    category: z.enum(['electronics', 'clothing', 'books']),
    inStock: z.boolean(),
    rating: z.number().min(0).max(5),
  }),
});

export const collections = {
  blog: blogCollection,
  authors: authorsCollection,
  docs: docsCollection,
  products: productsCollection,
};
```

### Content Structure
```
src/content/
├── config.ts
├── blog/
│   ├── first-post.md
│   ├── second-post.mdx
│   └── images/
│       └── hero.png
├── authors/
│   ├── john-doe.json
│   └── jane-smith.yaml
├── docs/
│   ├── getting-started/
│   │   ├── installation.md
│   │   └── configuration.md
│   └── guides/
│       ├── deployment.md
│       └── integrations.md
└── products/
    ├── product-1.json
    └── product-2.json
```

### Query Collections
```astro
---
// ==========================================
// pages/blog/index.astro - Blog list
// ==========================================

import { getCollection } from 'astro:content';
import Layout from '../../layouts/Layout.astro';
import BlogCard from '../../components/BlogCard.astro';

// Get all published posts, sorted by date
const posts = (await getCollection('blog', ({ data }) => {
  // Filter out drafts in production
  return import.meta.env.PROD ? !data.draft : true;
})).sort((a, b) => b.data.pubDate.valueOf() - a.data.pubDate.valueOf());

// Get posts by tag
const tag = Astro.url.searchParams.get('tag');
const filteredPosts = tag
  ? posts.filter(post => post.data.tags.includes(tag))
  : posts;

// Get unique tags
const allTags = [...new Set(posts.flatMap(post => post.data.tags))];
---

<Layout title="Blog">
  <h1>Blog</h1>
  
  <!-- Tag filter -->
  <nav class="tags">
    <a href="/blog" class:list={[{ active: !tag }]}>All</a>
    {allTags.map(t => (
      <a href={`/blog?tag=${t}`} class:list={[{ active: tag === t }]}>
        {t}
      </a>
    ))}
  </nav>
  
  <!-- Post list -->
  <div class="posts">
    {filteredPosts.map(post => (
      <BlogCard
        title={post.data.title}
        description={post.data.description}
        pubDate={post.data.pubDate}
        heroImage={post.data.heroImage}
        href={`/blog/${post.slug}`}
        tags={post.data.tags}
      />
    ))}
  </div>
</Layout>
```

### Dynamic Routes
```astro
---
// ==========================================
// pages/blog/[...slug].astro - Blog post
// ==========================================

import { getCollection, getEntry } from 'astro:content';
import Layout from '../../layouts/Layout.astro';
import { Image } from 'astro:assets';

// Generate static paths
export async function getStaticPaths() {
  const posts = await getCollection('blog');
  
  return posts.map(post => ({
    params: { slug: post.slug },
    props: { post },
  }));
}

type Props = {
  post: CollectionEntry<'blog'>;
};

const { post } = Astro.props;

// Get author data
const author = await getEntry('authors', post.data.author);

// Render content
const { Content, headings, remarkPluginFrontmatter } = await post.render();

// Calculate reading time (from remark plugin)
const readingTime = remarkPluginFrontmatter.readingTime;

// Get related posts
const allPosts = await getCollection('blog');
const relatedPosts = allPosts
  .filter(p => 
    p.slug !== post.slug &&
    p.data.tags.some(tag => post.data.tags.includes(tag))
  )
  .slice(0, 3);
---

<Layout 
  title={post.data.title}
  description={post.data.description}
  image={post.data.heroImage?.src}
>
  <article>
    {post.data.heroImage && (
      <Image 
        src={post.data.heroImage} 
        alt=""
        width={1200}
        height={630}
        class="hero-image"
      />
    )}
    
    <header>
      <h1>{post.data.title}</h1>
      
      <div class="meta">
        <time datetime={post.data.pubDate.toISOString()}>
          {post.data.pubDate.toLocaleDateString()}
        </time>
        
        {author && (
          <span class="author">
            by {author.data.name}
          </span>
        )}
        
        <span class="reading-time">{readingTime} min read</span>
      </div>
      
      <div class="tags">
        {post.data.tags.map(tag => (
          <a href={`/blog?tag=${tag}`}>{tag}</a>
        ))}
      </div>
    </header>
    
    <!-- Table of Contents -->
    <nav class="toc">
      <h2>Contents</h2>
      <ul>
        {headings.map(heading => (
          <li class={`depth-${heading.depth}`}>
            <a href={`#${heading.slug}`}>{heading.text}</a>
          </li>
        ))}
      </ul>
    </nav>
    
    <!-- Rendered Markdown/MDX content -->
    <div class="content">
      <Content />
    </div>
    
    <!-- Related posts -->
    {relatedPosts.length > 0 && (
      <aside class="related">
        <h2>Related Posts</h2>
        <ul>
          {relatedPosts.map(related => (
            <li>
              <a href={`/blog/${related.slug}`}>{related.data.title}</a>
            </li>
          ))}
        </ul>
      </aside>
    )}
  </article>
</Layout>
```

---

## 4) View Transitions

### Page Transitions
```astro
---
// layouts/Layout.astro
import { ViewTransitions } from 'astro:transitions';
---

<html>
  <head>
    <!-- Enable view transitions -->
    <ViewTransitions />
  </head>
  <body>
    <slot />
  </body>
</html>
```

```astro
---
// components/Header.astro
---

<!-- Persist across page navigations -->
<header transition:persist>
  <nav>
    <a href="/">Home</a>
    <a href="/blog">Blog</a>
    <a href="/about">About</a>
  </nav>
</header>


<!-- Named transitions -->
<article transition:name="post-card">
  <h2>{title}</h2>
</article>


<!-- Transition animations -->
<div transition:animate="slide">Slides in</div>
<div transition:animate="fade">Fades in</div>
<div transition:animate="initial">No animation</div>
<div transition:animate="none">Disabled</div>


<!-- Custom animation -->
<div transition:animate={{
  old: {
    name: 'fadeOut',
    duration: '0.2s',
    easing: 'ease-out',
    fillMode: 'forwards',
  },
  new: {
    name: 'fadeIn',
    duration: '0.3s',
    easing: 'ease-in',
    delay: '0.1s',
    fillMode: 'backwards',
  },
}}>
  Custom transition
</div>

<style>
  @keyframes fadeOut {
    from { opacity: 1; }
    to { opacity: 0; }
  }
  
  @keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
  }
</style>
```

### View Transitions Events
```astro
<script>
  // Listen for transition events
  document.addEventListener('astro:before-preparation', (e) => {
    console.log('Preparing to navigate to:', e.to);
  });
  
  document.addEventListener('astro:after-preparation', () => {
    console.log('New page ready');
  });
  
  document.addEventListener('astro:before-swap', (e) => {
    console.log('About to swap DOM');
  });
  
  document.addEventListener('astro:after-swap', () => {
    console.log('DOM swapped, re-initialize scripts');
    // Re-initialize any scripts that need to run on new page
  });
  
  document.addEventListener('astro:page-load', () => {
    console.log('Page fully loaded');
    // Works on initial load and after transitions
  });
</script>
```

---

## 5) Image Optimization

### Image Component
```astro
---
import { Image, Picture, getImage } from 'astro:assets';

// Import local images
import heroImage from '../assets/hero.png';
import authorAvatar from '../assets/author.jpg';

// Remote images (must configure in astro.config)
const remoteImage = 'https://example.com/image.jpg';

// Get optimized image programmatically
const optimizedBg = await getImage({
  src: heroImage,
  width: 1920,
  format: 'webp',
});
---

<!-- Local image with automatic optimization -->
<Image 
  src={heroImage} 
  alt="Hero image"
  width={1200}
  height={630}
  quality={80}
  format="webp"
/>


<!-- Responsive image with Picture -->
<Picture
  src={heroImage}
  widths={[400, 800, 1200]}
  sizes="(max-width: 800px) 100vw, 800px"
  formats={['avif', 'webp', 'jpeg']}
  alt="Responsive hero"
/>


<!-- Avatar with specific dimensions -->
<Image
  src={authorAvatar}
  alt="Author"
  width={64}
  height={64}
  class="avatar"
/>


<!-- Background image -->
<div 
  class="hero"
  style={`background-image: url(${optimizedBg.src})`}
>
  <h1>Welcome</h1>
</div>


<!-- Remote image (needs config) -->
<Image
  src={remoteImage}
  alt="Remote image"
  width={800}
  height={600}
  inferSize
/>


<!-- From Content Collection -->
{post.data.heroImage && (
  <Image
    src={post.data.heroImage}
    alt=""
    width={1200}
    height={630}
  />
)}
```

### Image Configuration
```javascript
// astro.config.mjs
import { defineConfig } from 'astro/config';

export default defineConfig({
  image: {
    // Service configuration
    service: {
      entrypoint: 'astro/assets/services/sharp',
      config: {
        limitInputPixels: false,
      },
    },
    
    // Remote image domains
    domains: ['example.com', 'cdn.example.com'],
    
    // Remote patterns
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '**.example.com',
      },
    ],
  },
});
```

---

## 6) SSR & Middleware

### SSR Configuration
```javascript
// astro.config.mjs
import { defineConfig } from 'astro/config';
import vercel from '@astrojs/vercel/serverless';
import netlify from '@astrojs/netlify';
import node from '@astrojs/node';

export default defineConfig({
  output: 'hybrid',  // 'static' | 'server' | 'hybrid'
  
  // Choose adapter based on deployment target
  adapter: vercel({
    webAnalytics: { enabled: true },
    imageService: true,
  }),
  // OR
  // adapter: netlify(),
  // OR
  // adapter: node({ mode: 'standalone' }),
});
```

### Server Endpoints
```typescript
// ==========================================
// src/pages/api/newsletter.ts
// ==========================================

import type { APIRoute } from 'astro';

export const POST: APIRoute = async ({ request }) => {
  try {
    const body = await request.json();
    const { email } = body;
    
    if (!email || !email.includes('@')) {
      return new Response(
        JSON.stringify({ error: 'Invalid email' }),
        { status: 400 }
      );
    }
    
    // Add to newsletter service
    await addToNewsletter(email);
    
    return new Response(
      JSON.stringify({ success: true }),
      { status: 200 }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: 'Server error' }),
      { status: 500 }
    );
  }
};

export const GET: APIRoute = async () => {
  return new Response(
    JSON.stringify({ message: 'Newsletter API' }),
    { status: 200 }
  );
};
```

### Middleware
```typescript
// ==========================================
// src/middleware.ts
// ==========================================

import { defineMiddleware, sequence } from 'astro:middleware';

// Auth middleware
const auth = defineMiddleware(async ({ locals, request, redirect }, next) => {
  const token = request.headers.get('authorization')?.split(' ')[1];
  
  if (token) {
    try {
      const user = await verifyToken(token);
      locals.user = user;
    } catch {
      locals.user = null;
    }
  }
  
  return next();
});

// Protected routes
const protectedRoutes = defineMiddleware(async ({ locals, url, redirect }, next) => {
  const protectedPaths = ['/dashboard', '/admin', '/settings'];
  
  if (protectedPaths.some(path => url.pathname.startsWith(path))) {
    if (!locals.user) {
      return redirect('/login');
    }
  }
  
  return next();
});

// Logging middleware
const logging = defineMiddleware(async ({ request }, next) => {
  const start = Date.now();
  const response = await next();
  const duration = Date.now() - start;
  
  console.log(`${request.method} ${request.url} - ${duration}ms`);
  
  return response;
});

// Compose middlewares
export const onRequest = sequence(logging, auth, protectedRoutes);
```

---

## 7) Integrations & Config

### Full Configuration
```javascript
// ==========================================
// astro.config.mjs
// ==========================================

import { defineConfig } from 'astro/config';

// Framework integrations
import react from '@astrojs/react';
import vue from '@astrojs/vue';
import svelte from '@astrojs/svelte';

// Styling
import tailwind from '@astrojs/tailwind';

// SEO & Performance
import sitemap from '@astrojs/sitemap';
import partytown from '@astrojs/partytown';

// Deployment
import vercel from '@astrojs/vercel/serverless';

// MDX
import mdx from '@astrojs/mdx';

export default defineConfig({
  site: 'https://example.com',
  base: '/',
  
  output: 'hybrid',
  adapter: vercel(),
  
  integrations: [
    // Frameworks (order matters for CSS)
    react(),
    vue(),
    svelte(),
    
    // MDX support
    mdx({
      syntaxHighlight: 'shiki',
      shikiConfig: { theme: 'github-dark' },
      remarkPlugins: [],
      rehypePlugins: [],
    }),
    
    // Tailwind
    tailwind({
      applyBaseStyles: false,
    }),
    
    // Sitemap
    sitemap({
      filter: (page) => !page.includes('/admin'),
      changefreq: 'weekly',
      priority: 0.7,
    }),
    
    // Third-party scripts
    partytown({
      config: {
        forward: ['dataLayer.push'],
      },
    }),
  ],
  
  // Vite config
  vite: {
    ssr: {
      noExternal: ['some-package'],
    },
    build: {
      cssCodeSplit: true,
    },
  },
  
  // Markdown config
  markdown: {
    syntaxHighlight: 'prism',
    remarkPlugins: [],
    rehypePlugins: [],
    gfm: true,
  },
  
  // Prefetch config
  prefetch: {
    prefetchAll: true,
    defaultStrategy: 'viewport',
  },
  
  // Experimental features
  experimental: {
    contentCollectionCache: true,
  },
});
```

---

## 8) Best Practices

### Performance Checklist
```
┌─────────────────────────────────────────┐
│      ASTRO PERFORMANCE CHECKLIST        │
├─────────────────────────────────────────┤
│                                         │
│  ISLANDS:                               │
│  □ Minimize client: directives         │
│  □ Use client:visible for below fold  │
│  □ Use client:idle for low priority   │
│  □ Avoid client:load when possible    │
│                                         │
│  CONTENT:                               │
│  □ Use Content Collections             │
│  □ Define schemas with Zod             │
│  □ Cache collections in production     │
│                                         │
│  IMAGES:                                │
│  □ Use <Image> component               │
│  □ Use <Picture> for responsive        │
│  □ Specify width/height                │
│  □ Use modern formats (webp/avif)      │
│                                         │
│  BUILD:                                 │
│  □ Enable prefetch                     │
│  □ Use View Transitions                │
│  □ Generate sitemap                    │
│  □ Optimize fonts                      │
│                                         │
│  SSR:                                   │
│  □ Use hybrid mode when needed         │
│  □ Choose appropriate adapter          │
│  □ Implement caching                   │
│                                         │
└──────────────────────────────────────┘
```

---

## Best Practices Summary

### Components
- [ ] Use .astro for static content
- [ ] Use framework components for interactivity
- [ ] Minimize client: directives
- [ ] Use scoped styles

### Content
- [ ] Use Content Collections
- [ ] Define Zod schemas
- [ ] Use dynamic routes for content
- [ ] Implement search/filtering

### Performance
- [ ] Optimize images with <Image>
- [ ] Enable View Transitions
- [ ] Use appropriate hydration
- [ ] Enable prefetch

---

**References:**
- [Astro Documentation](https://docs.astro.build/)
- [Content Collections](https://docs.astro.build/en/guides/content-collections/)
- [View Transitions](https://docs.astro.build/en/guides/view-transitions/)
- [Islands Architecture](https://docs.astro.build/en/concepts/islands/)

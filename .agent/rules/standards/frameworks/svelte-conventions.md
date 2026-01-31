---
technology: Svelte
version: 5.x
last_updated: 2026-01-16
official_docs: https://svelte.dev
---

# Svelte 5 - Best Practices & Conventions

**Version:** Svelte 5.x + SvelteKit  
**Updated:** 2026-01-16  
**Source:** Official Svelte docs + community best practices

---

## Overview

Svelte is a radical new approach to building user interfaces. Instead of using techniques like virtual DOM diffing, Svelte writes code that surgically updates the DOM when your app's state changes.

---

## Project Structure

```
my-app/
├── src/
│   ├── lib/
│   │   ├── components/
│   │   ├── stores/
│   │   └── utils/
│   ├── routes/
│   │   ├── +page.svelte
│   │   ├── +layout.svelte
│   │   └── api/
│   └── app.html
├── static/
└── svelte.config.js
```

---

## Component Patterns

### Basic Component

```svelte
<script>
  let count = $state(0);
  
  function increment() {
    count++;
  }
</script>

<button onclick={increment}>
  Clicks: {count}
</button>

<style>
  button {
    background: blue;
    color: white;
    padding: 1rem;
  }
</style>
```

### Props & TypeScript

```svelte
<script lang="ts">
  interface Props {
    title: string;
    count?: number;
  }
  
  let { title, count = 0 }: Props = $props();
</script>

<h1>{title}</h1>
<p>Count: {count}</p>
```

---

## Reactivity (Svelte 5 Runes)

### $state - Reactive State

```svelte
<script>
  let count = $state(0);
  let user = $state({ name: 'John', age: 30 });
  
  // Nested reactivity works automatically
  user.name = 'Jane'; // Triggers update
</script>
```

### $derived - Computed Values

```svelte
<script>
  let count = $state(0);
  let doubled = $derived(count * 2);
  let message = $derived(count > 10 ? 'High' : 'Low');
</script>

<p>{doubled}</p>
<p>{message}</p>
```

### $effect - Side Effects

```svelte
<script>
  let count = $state(0);
  
  $effect(() => {
    console.log(`Count changed to: ${count}`);
    document.title = `Count: ${count}`;
  });
</script>
```

---

## Stores (Global State)

### Writable Store

```typescript
// stores.ts
import { writable } from 'svelte/store';

export const count = writable(0);
export const user = writable({ name: 'John' });
```

```svelte
<!-- Usage -->
<script>
  import { count } from './stores';
</script>

<button onclick={() => $count++}>
  Count: {$count}
</button>
```

### Readable & Derived Stores

```typescript
import { readable, derived } from 'svelte/store';

export const time = readable(new Date(), (set) => {
  const interval = setInterval(() => {
    set(new Date());
  }, 1000);
  
  return () => clearInterval(interval);
});

export const doubled = derived(count, $count => $count * 2);
```

---

## SvelteKit Routing

### File-Based Routing

```
routes/
├── +page.svelte           # /
├── about/
│   └── +page.svelte       # /about
├── blog/
│   ├── +page.svelte       # /blog
│   └── [slug]/
│       └── +page.svelte   # /blog/:slug
```

### Loading Data

```svelte
<!-- +page.ts -->
<script lang="ts">
  export async function load({ params, fetch }) {
    const res = await fetch(`/api/posts/${params.slug}`);
    const post = await res.json();
    
    return {
      post
    };
  }
</script>
```

```svelte
<!-- +page.svelte -->
<script lang="ts">
  let { data } = $props();
</script>

<h1>{data.post.title}</h1>
<p>{data.post.content}</p>
```

---

## Forms & Actions

### Form Actions

```typescript
// +page.server.ts
import type { Actions } from './$types';

export const actions = {
  default: async ({ request }) => {
    const data = await request.formData();
    const email = data.get('email');
    
    // Process form
    return { success: true };
  }
} satisfies Actions;
```

```svelte
<!-- +page.svelte -->
<script>
  import { enhance } from '$app/forms';
</script>

<form method="POST" use:enhance>
  <input name="email" type="email" required />
  <button>Submit</button>
</form>
```

---

## Component Directives

### Conditional Rendering

```svelte
{#if condition}
  <p>Condition is true</p>
{:else if otherCondition}
  <p>Other condition</p>
{:else}
  <p>All false</p>
{/if}
```

### Loops

```svelte
<script>
  let items = $state(['Apple', 'Banana', 'Orange']);
</script>

{#each items as item, index (item)}
  <p>{index}: {item}</p>
{/each}
```

### Await Blocks

```svelte
{#await promise}
  <p>Loading...</p>
{:then value}
  <p>Result: {value}</p>
{:catch error}
  <p>Error: {error.message}</p>
{/await}
```

---

## Events

### Event Handling

```svelte
<button onclick={() => count++}>Click</button>
<button onclick={handleClick}>Click</button>

<input oninput={(e) => name = e.target.value} />
```

### Custom Events

```svelte
<!-- Child.svelte -->
<script>
  let { onmessage } = $props();
  
  function send() {
    onmessage?.('Hello from child');
  }
</script>

<button onclick={send}>Send</button>
```

```svelte
<!-- Parent.svelte -->
<Child onmessage={(msg) => console.log(msg)} />
```

---

## Snippets (Svelte 5)

```svelte
<script>
  let items = $state(['A', 'B', 'C']);
</script>

{#snippet card(title, content)}
  <div class="card">
    <h2>{title}</h2>
    <p>{content}</p>
  </div>
{/snippet}

{#each items as item}
  {@render card(item, `Content for ${item}`)}
{/each}
```

---

## Performance Optimization

### Lazy Loading

```svelte
<script>
  import { onMount } from 'svelte';
  
  let Component;
  
  onMount(async () => {
    const module = await import('./HeavyComponent.svelte');
    Component = module.default;
  });
</script>

{#if Component}
  <svelte:component this={Component} />
{/if}
```

### Keyed Each Blocks

```svelte
<!-- ✅ Good - with key -->
{#each items as item (item.id)}
  <Item {item} />
{/each}

<!-- ❌ Bad - no key -->
{#each items as item}
  <Item {item} />
{/each}
```

---

## Testing

```typescript
import { render } from '@testing-library/svelte';
import Counter from './Counter.svelte';

test('increments counter', async () => {
  const { getByRole } = render(Counter);
  const button = getByRole('button');
  
  await button.click();
  
  expect(button.textContent).toBe('Count: 1');
});
```

---

## Anti-Patterns to Avoid

❌ **Mutating arrays without reassignment** (Svelte 4)  
❌ **Using stores for local state** → Use $state  
❌ **Not using keys in each blocks**  
❌ **Overusing $effect** → Prefer $derived  
❌ **Inline event handlers for complex logic**

---

## Best Practices

✅ **Use Svelte 5 runes** ($state, $derived, $effect)  
✅ **TypeScript** for type safety  
✅ **SvelteKit** for full-stack apps  
✅ **Stores** for global state only  
✅ **File-based routing** in SvelteKit  
✅ **Form actions** for server mutations  
✅ **Snippets** for reusable templates

---

**References:**
- [Svelte Documentation](https://svelte.dev/)
- [SvelteKit Documentation](https://kit.svelte.dev/)
- [Svelte 5 Migration Guide](https://svelte.dev/docs/v5-migration-guide)

---

## ⚠️ CRITICAL SECURITY WARNINGS

### NEVER Store Secrets in Frontend Code

❌ **WRONG - Secrets Exposed Publicly:**
```javascript
// .env or .env.local
VITE_API_KEY=sk_live_abc123...  // ❌ Will be in bundle! PUBLIC!
PUBLIC_SECRET_KEY=secret123      // ❌ ANYONE can see this!

// Component
const apiKey = import.meta.env.VITE_API_KEY;  // ❌ Bundled into JavaScript
```

✅ **CORRECT - Backend Proxy Pattern:**
```javascript
// ✅ Frontend - NO secrets
async function fetchData() {
  const response = await fetch('/api/proxy/external');
  return response.json();
}

// ✅ Backend (+page.server.ts) - Secrets stay server-side
export const load = async () => {
  const apiKey = process.env.EXTERNAL_API_KEY;  // ✅ Server-only
  const data = await fetch('https://api.example.com/data', {
    headers: { 'Authorization': `Bearer ${apiKey}` }
  });
  return { data: await data.json() };
};
```

---

### NEVER Rely on Frontend Authorization

❌ **WRONG:**
```svelte
<script>
  let { user } = $props();
</script>

{#if user.role === 'admin'}
  <button onclick={deleteUser}>Delete</button>
{/if}
<!-- ❌ Attacker can still call API directly! -->
```

✅ **CORRECT - Backend Validation:**
```typescript
// +page.server.ts
export const actions = {
  delete: async ({ locals, request }) => {
    // ✅ ALWAYS validate on backend
    if (!locals.user?.isAdmin) {
      throw error(403, 'Unauthorized');
    }
    
    const data = await request.formData();
    await deleteUser(data.get('userId'));
    return { success: true };
  }
};
```

---

### XSS Prevention

❌ **WRONG:**
```svelte
{@html userComment}  <!-- ❌ Dangerous! -->
```

✅ **CORRECT:**
```svelte
{userComment}  <!-- ✅ Auto-escaped -->

<!-- Or sanitize -->
<script>
  import DOMPurify from 'isomorphic-dompurify';
  const clean = DOMPurify.sanitize(userComment);
</script>
{@html clean}
```

---

**Security Checklist:**
- [ ] No secrets in VITE_* or PUBLIC_* env vars
- [ ] Backend validates ALL permissions
- [ ] Use {@html} only with sanitized content
- [ ] CSRF protection in form actions
- [ ] HTTPS enforced in production


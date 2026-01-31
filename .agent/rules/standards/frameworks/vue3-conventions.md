---
technology: Vue 3
version: 3.x
last_updated: 2026-01-16
official_docs: https://vuejs.org/guide/introduction.html
---

# Vue 3 - Best Practices & Conventions

**Version:** Vue 3.x  
**Updated:** 2026-01-16  
**Source:** Official Vue docs + industry best practices

---

## Overview

Vue 3 is a progressive JavaScript framework for building user interfaces. It features the Composition API, improved performance, better TypeScript support, and a more maintainable codebase.

---

## Project Structure

### Recommended Structure

```
src/
├── assets/          # Static assets
├── components/      # Reusable components
│   ├── common/     # Shared components
│   └── features/   # Feature-specific components
├── composables/     # Composition functions
├── layouts/         # Layout components
├── pages/          # Page components (with router)
├── stores/         # Pinia stores
├── types/          # TypeScript types
├── utils/          # Utility functions
└── App.vue         # Root component
```

---

## Composition API (Preferred)

### `<script setup>` Syntax (Recommended)

```vue
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'

interface User {
  id: number
  name: string
}

// Reactive state
const count = ref(0)
const user = ref<User | null>(null)

// Computed properties
const doubleCount = computed(() => count.value * 2)

// Methods
function increment() {
  count.value++
}

// Lifecycle
onMounted(() => {
  console.log('Component mounted')
})
</script>

<template>
  <div>
    <p>Count: {{ count }}</p>
    <p>Double: {{ doubleCount }}</p>
    <button @click="increment">Increment</button>
  </div>
</template>
```

### Composables (Reusable Logic)

```typescript
// composables/useCounter.ts
import { ref, computed } from 'vue'

export function useCounter(initialValue = 0) {
  const count = ref(initialValue)
  const double = computed(() => count.value * 2)
  
  function increment() {
    count.value++
  }
  
  function decrement() {
    count.value--
  }
  
  return {
    count,
    double,
    increment,
    decrement
  }
}

// Usage in component
<script setup>
import { useCounter } from '@/composables/useCounter'

const { count, double, increment } = useCounter(10)
</script>
```

---

## State Management with Pinia

### Store Definition

```typescript
// stores/user.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useUserStore = defineStore('user', () => {
  // State
  const user = ref<User | null>(null)
  const isLoggedIn = ref(false)
  
  // Getters
  const userName = computed(() => user.value?.name ?? 'Guest')
  
  // Actions
  async function login(email: string, password: string) {
    try {
      const response = await api.login(email, password)
      user.value = response.user
      isLoggedIn.value = true
    } catch (error) {
      console.error('Login failed', error)
    }
  }
  
  function logout() {
    user.value = null
    isLoggedIn.value = false
  }
  
  return {
    user,
    isLoggedIn,
    userName,
    login,
    logout
  }
})
```

### Using Store in Components

```vue
<script setup>
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

// Access state
console.log(userStore.user)

// Access getters
console.log(userStore.userName)

// Call actions
userStore.login('user@example.com', 'password')
</script>
```

---

## TypeScript Integration

### Typed Component Props

```vue
<script setup lang="ts">
interface Props {
  title: string
  count?: number
  items: string[]
}

// With defaults
const props = withDefaults(defineProps<Props>(), {
  count: 0
})

// Emits
interface Emits {
  (e: 'update', value: number): void
  (e: 'delete'): void
}

const emit = defineEmits<Emits>()
</script>
```

### Generic Components

```vue
<script setup lang="ts" generic="T">
interface Props<T> {
  items: T[]
  selected?: T
}

const props = defineProps<Props<T>>()

const emit = defineEmits<{
  select: [item: T]
}>()
</script>
```

---

## Component Patterns

### Reusable Button Component

```vue
<script setup lang="ts">
interface Props {
  variant?: 'primary' | 'secondary' | 'danger'
  size?: 'sm' | 'md' | 'lg'
  disabled?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  size: 'md',
  disabled: false
})
</script>

<template>
  <button 
    :class="[`btn-${variant}`, `btn-${size}`]"
    :disabled="disabled"
  >
    <slot />
  </button>
</template>

<style scoped>
.btn-primary { background: blue; color: white; }
.btn-secondary { background: gray; color: white; }
.btn-danger { background: red; color: white; }

.btn-sm { padding: 0.25rem 0.5rem; }
.btn-md { padding: 0.5rem 1rem; }
.btn-lg { padding: 0.75rem 1.5rem; }
</style>
```

### Form Handling

```vue
<script setup lang="ts">
import { ref, reactive } from 'vue'

interface FormData {
  email: string
  password: string
}

const formData = reactive<FormData>({
  email: '',
  password: ''
})

const errors = ref<Partial<FormData>>({})

async function handleSubmit() {
  errors.value = {}
  
  // Validation
  if (!formData.email) {
    errors.value.email = 'Email is required'
  }
  if (!formData.password) {
    errors.value.password = 'Password is required'
  }
  
  if (Object.keys(errors.value).length === 0) {
    // Submit
    await api.login(formData)
  }
}
</script>

<template>
  <form @submit.prevent="handleSubmit">
    <div>
      <input v-model="formData.email" type="email" />
      <span v-if="errors.email" class="error">{{ errors.email }}</span>
    </div>
    
    <div>
      <input v-model="formData.password" type="password" />
      <span v-if="errors.password" class="error">{{ errors.password }}</span>
    </div>
    
    <button type="submit">Login</button>
  </form>
</template>
```

---

## Vue Router (Vue 3)

### Router Setup

```typescript
// router/index.ts
import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: () => import('@/pages/Home.vue')
    },
    {
      path: '/users/:id',
      name: 'user',
      component: () => import('@/pages/User.vue'),
      props: true
    }
  ]
})

export default router
```

### Using Router in Components

```vue
<script setup>
import { useRouter, useRoute } from 'vue-router'

const router = useRouter()
const route = useRoute()

// Access params
const userId = route.params.id

// Navigate
function goHome() {
  router.push({ name: 'home' })
}
</script>
```

---

## Performance Optimization

### Lazy Loading Components

```vue
<script setup>
import { defineAsyncComponent } from 'vue'

const HeavyComponent = defineAsyncComponent(() =>
  import('./HeavyComponent.vue')
)
</script>

<template>
  <Suspense>
    <HeavyComponent />
    <template #fallback>
      <div>Loading...</div>
    </template>
  </Suspense>
</template>
```

### Computed Caching

```typescript
// ✅ Good - Cached
const filteredItems = computed(() => {
  return items.value.filter(item => item.active)
})

// ❌ Bad - Re-runs on every render
function getFilteredItems() {
  return items.value.filter(item => item.active)
}
```

### v-memo for List Optimization

```vue
<template>
  <div 
    v-for="item in items" 
    :key="item.id"
    v-memo="[item.id, item.selected]"
  >
    {{ item.name }}
  </div>
</template>
```

---

## Testing with Vitest

```typescript
import { mount } from '@vue/test-utils'
import { describe, it, expect } from 'vitest'
import Counter from './Counter.vue'

describe('Counter', () => {
  it('increments count when button clicked', async () => {
    const wrapper = mount(Counter)
    
    await wrapper.find('button').trigger('click')
    
    expect(wrapper.text()).toContain('Count: 1')
  })
  
  it('displays initial count prop', () => {
    const wrapper = mount(Counter, {
      props: { initialCount: 5 }
    })
    
    expect(wrapper.text()).toContain('Count: 5')
  })
})
```

---

## Anti-Patterns to Avoid

❌ **Mutating props directly** → Use events/emits  
❌ **Using Options API for new projects** → Use Composition API  
❌ **Not typing components** → Use TypeScript  
❌ **Deep component nesting** → Use composables  
❌ **Inline styles** → Use scoped styles or CSS modules  
❌ **Not using `v-memo`** → For large lists  
❌ **Reactive() on primitives** → Use ref() instead

---

## Best Practices

✅ **Use `<script setup>`** for cleaner code  
✅ **Type everything** with TypeScript  
✅ **Pinia over Vuex** for state management  
✅ **Composables** for reusable logic  
✅ **Lazy load** routes and heavy components  
✅ **Scoped styles** to avoid CSS conflicts  
✅ **v-model** for two-way binding  
✅ **Computed** for derived state

---

## Nuxt 3 Integration

If using Nuxt 3, leverage:
- Auto-imports for components/composables
- Server-side rendering (SSR)
- File-based routing
- Built-in state management

```vue
<!-- pages/index.vue (Nuxt 3) -->
<script setup>
// Auto-imported
const count = ref(0)

// Server-side fetch
const { data: users } = await useFetch('/api/users')
</script>
```

---

**References:**
- [Vue 3 Official Docs](https://vuejs.org/)
- [Pinia Documentation](https://pinia.vuejs.org/)
- [Vue Router](https://router.vuejs.org/)
- [Vite](https://vitejs.dev/)

---

---

## ⚠ CRITICAL SECURITY WARNINGS

### NEVER Store Secrets in Frontend Code

❌ **WRONG - Secrets Exposed Publicly:**
```javascript
// .env or .env.local
VITE_API_KEY=sk_live_abc123...  // ❌ Will be in bundle.js! PUBLIC!
VITE_SECRET_TOKEN=secret123      // ❌ ANYONE can see this!

// Component
const apiKey = import.meta.env.VITE_API_KEY;  // ❌ Bundled into JavaScript
fetch(`https://api.example.com?key=${apiKey}`); // ❌ Key exposed!
```

**Why this is CRITICAL:**
- All `VITE_*` environment variables are bundled into your JavaScript
- **Anyone** can view source, see bundle.js, and extract your keys
- This leads to unauthorized API usage, data theft, billing fraud

✅ **CORRECT - Backend Proxy Pattern:**
```javascript
// ✅ Frontend - NO secrets, NO API keys
async function fetchExternalData() {
  // Call YOUR backend, which has the secret
  const response = await fetch('/api/proxy/external-service');
  return response.json();
}

// ✅ Backend (Laravel example) - Secrets stay server-side
Route::get('/api/proxy/external-service', function () {
    $apiKey = env('EXTERNAL_API_KEY');  // ✅ Server-only, never exposed
    
    return Http::withToken($apiKey)
        ->get('https://api.example.com/data');
});
```

**Correct Pattern:**
1. **Frontend**: Call your own backend API (no secrets)
2. **Backend**: Backend calls external API (with secret)
3. **Backend**: Returns sanitized data to frontend

**Only use in frontend:**
- Public API keys (Google Maps with domain restrictions)
- Configuration values (feature flags, non-sensitive settings)

---

### NEVER Rely on Frontend Authorization

❌ **WRONG - UI-Only Authorization (INSECURE!):**
```vue
<template>
  <!-- ❌ This is just UI, NOT security! -->
  <button v-if="user.role === 'admin'" @click="deleteUser">
    Delete User
  </button>
</template>

<script setup>
// ❌ Attacker can still call the API directly!
async function deleteUser() {
  await fetch('/api/users/123', { method: 'DELETE' });
  // ^ This will work even if button is hidden!
}
</script>
```

**Why this is CRITICAL:**
- Hiding UI does NOT prevent API calls
- Attackers use browser dev tools, Postman, curl
- They can bypass ALL frontend checks

✅ **CORRECT - Backend Validation (REQUIRED!):**
```vue
<template>
  <!-- ✅ Frontend: UI convenience only -->
  <button v-if="user.role === 'admin'" @click="deleteUser">
    Delete User
  </button>
</template>

<script setup>
async function deleteUser() {
  // Call API - backend MUST validate
  await fetch('/api/users/123', { method: 'DELETE' });
}
</script>
```

```php
// ✅ Backend (Laravel) - REAL security checkpoint
public function destroy(User $user)
{
    // ✅ ALWAYS check authorization on backend
    $this->authorize('delete', $user);
    
    if (!auth()->user()->isAdmin()) {
        abort(403, 'Unauthorized');
    }
    
    $user->delete();
    return response()->json(['message' => 'User deleted']);
}
```

**Golden Rule:**
> **Frontend controls = UX (User Experience)**  
> **Backend validation = Security**  
> **ALWAYS validate permissions on backend!**

---

### XSS Prevention

❌ **WRONG - Unescaped HTML:**
```vue
<template>
  <!-- ❌ Dangerous: User input as HTML -->
  <div v-html="userComment"></div>
</template>
```

✅ **CORRECT - Use text rendering:**
```vue
<template>
  <!-- ✅ Safe: Auto-escaped -->
  <div>{{ userComment }}</div>
  
  <!-- ✅ Or explicitly escape -->
  <div v-text="userComment"></div>
</template>
```

**Only use `v-html` for:**
- Trusted content (your own CMS)
- Sanitized HTML (use DOMPurify)

```javascript
import DOMPurify from 'dompurify';

const cleanHtml = DOMPurify.sanitize(userInput);
```

---

### CSRF Protection

```vue
<script setup>
// ✅ Include CSRF token in requests
import { useCsrfToken } from '@/composables/useCsrf';

const csrfToken = useCsrfToken();

async function submitForm() {
  await fetch('/api/posts', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-TOKEN': csrfToken.value, // ✅ Required for Laravel
    },
    body: JSON.stringify(formData),
  });
}
</script>
```

---

### Secure Token Storage

❌ **WRONG - localStorage for sensitive tokens:**
```javascript
// ❌ localStorage is accessible to any JavaScript (XSS risk)
localStorage.setItem('auth_token', token);
```

✅ **CORRECT - HttpOnly cookies (backend sets):**
```php
// Backend (Laravel) - Set secure cookie
return response()->json(['user' => $user])
    ->cookie('auth_token', $token, 60, null, null, true, true);
    //                                secure ^    ^ httpOnly
```

Or use secure session storage:
```javascript
// ✅ Better: Short-lived tokens in memory
const authToken = ref(null); // Lost on page refresh (more secure)

// ✅ Or sessionStorage for single tab
sessionStorage.setItem('auth_token', token);
```

---

## 🔒 Security Checklist

Before deploying Vue app:

- [ ] No `VITE_*` secrets (API keys, tokens) in .env
- [ ] All API calls go through YOUR backend
- [ ] Backend validates ALL permissions
- [ ] No `v-html` with user input (or use DOMPurify)
- [ ] CSRF tokens included in state-changing requests
- [ ] Sensitive tokens in HttpOnly cookies (not localStorage)
- [ ] HTTPS enforced in production
- [ ] Security headers configured (backend)

---

**References:**
- [Vue Security](https://vuejs.org/guide/best-practices/security.html)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)

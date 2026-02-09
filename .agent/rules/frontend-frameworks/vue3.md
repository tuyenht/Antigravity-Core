# Vue.js 3 Composition API Expert

> **Version:** 2.0.0 | **Updated:** 2026-02-01  
> **Vue:** 3.4+ | **Pinia:** 2.1+ | **Vue Router:** 4.2+  
> **Priority:** P0 - Load for Vue.js projects

---

You are an expert in Vue.js 3 development using the Composition API.

## Core Principles

- Use Composition API with `<script setup>`
- Reactivity is the core engine
- Components should be focused and reusable
- Prefer Composables over Mixins

---

## 1) Script Setup Fundamentals

### Basic Component Structure
```vue
<!-- ==========================================
     MODERN VUE 3 COMPONENT
     ========================================== -->

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import type { User } from '@/types'

// ==========================================
// PROPS
// ==========================================
interface Props {
  userId: string
  showAvatar?: boolean
  size?: 'sm' | 'md' | 'lg'
}

const props = withDefaults(defineProps<Props>(), {
  showAvatar: true,
  size: 'md',
})

// ==========================================
// EMITS
// ==========================================
interface Emits {
  (e: 'update', user: User): void
  (e: 'delete', id: string): void
  (e: 'click'): void
}

const emit = defineEmits<Emits>()

// ==========================================
// COMPOSABLES
// ==========================================
const router = useRouter()
const userStore = useUserStore()

// ==========================================
// LOCAL STATE
// ==========================================
const isLoading = ref(false)
const error = ref<string | null>(null)
const user = ref<User | null>(null)

// ==========================================
// COMPUTED
// ==========================================
const fullName = computed(() => {
  if (!user.value) return ''
  return `${user.value.firstName} ${user.value.lastName}`
})

const avatarSize = computed(() => {
  const sizes = { sm: 32, md: 48, lg: 64 }
  return sizes[props.size]
})

// ==========================================
// METHODS
// ==========================================
async function fetchUser() {
  isLoading.value = true
  error.value = null
  
  try {
    user.value = await userStore.fetchUser(props.userId)
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to fetch user'
  } finally {
    isLoading.value = false
  }
}

function handleUpdate() {
  if (user.value) {
    emit('update', user.value)
  }
}

function handleDelete() {
  emit('delete', props.userId)
}

// ==========================================
// WATCHERS
// ==========================================
watch(
  () => props.userId,
  (newId) => {
    if (newId) {
      fetchUser()
    }
  },
  { immediate: true }
)

// ==========================================
// LIFECYCLE
// ==========================================
onMounted(() => {
  console.log('Component mounted')
})

// ==========================================
// EXPOSE (for parent refs)
// ==========================================
defineExpose({
  refresh: fetchUser,
})
</script>

<template>
  <div class="user-card" :class="[`size-${size}`]">
    <!-- Loading State -->
    <div v-if="isLoading" class="loading">
      <span class="spinner" />
      Loading...
    </div>
    
    <!-- Error State -->
    <div v-else-if="error" class="error">
      {{ error }}
      <button @click="fetchUser">Retry</button>
    </div>
    
    <!-- Content -->
    <template v-else-if="user">
      <img
        v-if="showAvatar"
        :src="user.avatarUrl"
        :alt="fullName"
        :width="avatarSize"
        :height="avatarSize"
        class="avatar"
      />
      
      <div class="info">
        <h3>{{ fullName }}</h3>
        <p>{{ user.email }}</p>
      </div>
      
      <div class="actions">
        <button @click="handleUpdate">Edit</button>
        <button @click="handleDelete" class="danger">Delete</button>
      </div>
    </template>
  </div>
</template>

<style scoped>
.user-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  border-radius: 8px;
  background: var(--color-surface);
}

.size-sm { padding: 0.5rem; }
.size-md { padding: 1rem; }
.size-lg { padding: 1.5rem; }

.avatar {
  border-radius: 50%;
  object-fit: cover;
}

.danger {
  color: var(--color-error);
}
</style>
```

---

## 2) Reactivity System

### ref vs reactive
```vue
<script setup lang="ts">
import { ref, reactive, toRef, toRefs, unref } from 'vue'

// ==========================================
// REF - For primitives and single values
// ==========================================

// ✅ Use ref for primitives
const count = ref(0)
const message = ref('Hello')
const isVisible = ref(true)

// Access with .value in script
count.value++
console.log(message.value)

// ✅ ref can also hold objects (auto-unwrapped in template)
const user = ref<User | null>(null)
user.value = { id: '1', name: 'John' }


// ==========================================
// REACTIVE - For objects and arrays
// ==========================================

// ✅ Use reactive for objects
const state = reactive({
  count: 0,
  items: [] as string[],
  nested: {
    deep: {
      value: 'hello',
    },
  },
})

// Access directly (no .value)
state.count++
state.items.push('item')
state.nested.deep.value = 'world'

// ⚠️ Don't destructure reactive - loses reactivity!
// ❌ BAD
const { count } = state  // Not reactive!

// ✅ GOOD - Use toRefs
const { count: countRef } = toRefs(state)  // Reactive!


// ==========================================
// TOREF / TOREFS
// ==========================================

// Single property
const countRef = toRef(state, 'count')

// All properties
const { count, items } = toRefs(state)


// ==========================================
// SHALLOW REF/REACTIVE
// ==========================================
import { shallowRef, shallowReactive, triggerRef } from 'vue'

// Only track top-level changes
const shallowState = shallowReactive({
  nested: { value: 1 },  // Changes to nested.value won't trigger updates
})

const shallowList = shallowRef([1, 2, 3])
// Must replace entire array to trigger update
shallowList.value = [...shallowList.value, 4]
// Or manually trigger
triggerRef(shallowList)
</script>
```

### Computed Properties
```vue
<script setup lang="ts">
import { ref, computed } from 'vue'

const firstName = ref('John')
const lastName = ref('Doe')

// ==========================================
// READONLY COMPUTED
// ==========================================
const fullName = computed(() => {
  return `${firstName.value} ${lastName.value}`
})

// ==========================================
// WRITABLE COMPUTED
// ==========================================
const fullNameWritable = computed({
  get() {
    return `${firstName.value} ${lastName.value}`
  },
  set(newValue: string) {
    const [first, ...rest] = newValue.split(' ')
    firstName.value = first
    lastName.value = rest.join(' ')
  },
})

// Usage
fullNameWritable.value = 'Jane Smith'
// firstName.value === 'Jane'
// lastName.value === 'Smith'


// ==========================================
// COMPUTED WITH GETTER OPTIONS
// ==========================================
const expensiveComputed = computed(() => {
  // Heavy computation
  return items.value.filter(x => x.active).map(x => x.value).reduce((a, b) => a + b, 0)
}, {
  // Debug options (development only)
  onTrack(e) {
    console.log('Tracked:', e)
  },
  onTrigger(e) {
    console.log('Triggered:', e)
  },
})
</script>
```

### Watchers
```vue
<script setup lang="ts">
import { ref, watch, watchEffect, watchPostEffect } from 'vue'

const count = ref(0)
const message = ref('hello')
const user = ref<User | null>(null)

// ==========================================
// WATCH - Explicit dependencies
// ==========================================

// Watch single ref
watch(count, (newValue, oldValue) => {
  console.log(`Count changed from ${oldValue} to ${newValue}`)
})

// Watch with options
watch(
  count,
  (newValue) => {
    console.log('Count:', newValue)
  },
  {
    immediate: true,  // Run immediately
    deep: false,      // Deep watch for objects
    flush: 'post',    // 'pre' | 'post' | 'sync'
  }
)

// Watch multiple sources
watch(
  [count, message],
  ([newCount, newMessage], [oldCount, oldMessage]) => {
    console.log('Either changed')
  }
)

// Watch getter
watch(
  () => user.value?.name,
  (newName) => {
    console.log('Name changed:', newName)
  }
)

// Watch deep object
watch(
  () => user.value,
  (newUser) => {
    console.log('User changed:', newUser)
  },
  { deep: true }
)


// ==========================================
// WATCHEFFECT - Auto-track dependencies
// ==========================================

// Automatically tracks all reactive dependencies used inside
watchEffect(() => {
  console.log(`Count is ${count.value}, message is ${message.value}`)
  // Both count and message are tracked automatically
})

// With cleanup
watchEffect((onCleanup) => {
  const controller = new AbortController()
  
  fetchData(user.value?.id, { signal: controller.signal })
  
  onCleanup(() => {
    controller.abort()
  })
})


// ==========================================
// WATCHPOSTEFFECT - After DOM update
// ==========================================

// Same as watchEffect with flush: 'post'
watchPostEffect(() => {
  // DOM is already updated here
  const element = document.getElementById('my-element')
  console.log('Element height:', element?.offsetHeight)
})


// ==========================================
// STOP WATCHER
// ==========================================

const stop = watch(count, (val) => {
  console.log(val)
})

// Later, stop watching
stop()
</script>
```

---

## 3) Composables (Custom Hooks)

### Creating Composables
```typescript
// ==========================================
// composables/useFetch.ts
// ==========================================

import { ref, shallowRef, watchEffect, type Ref } from 'vue'

interface UseFetchOptions<T> {
  immediate?: boolean
  initialData?: T
  refetch?: Ref<unknown>
}

interface UseFetchReturn<T> {
  data: Ref<T | null>
  error: Ref<string | null>
  isLoading: Ref<boolean>
  execute: () => Promise<void>
}

export function useFetch<T>(
  url: string | Ref<string>,
  options: UseFetchOptions<T> = {}
): UseFetchReturn<T> {
  const { immediate = true, initialData = null, refetch } = options
  
  const data = shallowRef<T | null>(initialData)
  const error = ref<string | null>(null)
  const isLoading = ref(false)
  
  async function execute() {
    isLoading.value = true
    error.value = null
    
    try {
      const targetUrl = typeof url === 'string' ? url : url.value
      const response = await fetch(targetUrl)
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`)
      }
      
      data.value = await response.json()
    } catch (e) {
      error.value = e instanceof Error ? e.message : 'Fetch failed'
      data.value = null
    } finally {
      isLoading.value = false
    }
  }
  
  if (immediate) {
    execute()
  }
  
  // Refetch when url changes
  if (typeof url !== 'string') {
    watchEffect(() => {
      void url.value // Track
      execute()
    })
  }
  
  // Refetch when trigger changes
  if (refetch) {
    watchEffect(() => {
      void refetch.value // Track
      execute()
    })
  }
  
  return { data, error, isLoading, execute }
}


// ==========================================
// composables/useLocalStorage.ts
// ==========================================

import { ref, watch, type Ref } from 'vue'

export function useLocalStorage<T>(
  key: string,
  defaultValue: T
): Ref<T> {
  // Get initial value
  const stored = localStorage.getItem(key)
  const initial = stored ? JSON.parse(stored) : defaultValue
  
  const data = ref<T>(initial) as Ref<T>
  
  // Sync to localStorage
  watch(
    data,
    (newValue) => {
      if (newValue === null || newValue === undefined) {
        localStorage.removeItem(key)
      } else {
        localStorage.setItem(key, JSON.stringify(newValue))
      }
    },
    { deep: true }
  )
  
  // Listen for changes in other tabs
  window.addEventListener('storage', (e) => {
    if (e.key === key && e.newValue) {
      data.value = JSON.parse(e.newValue)
    }
  })
  
  return data
}


// ==========================================
// composables/useDebounce.ts
// ==========================================

import { ref, watch, type Ref } from 'vue'

export function useDebounce<T>(value: Ref<T>, delay: number): Ref<T> {
  const debouncedValue = ref(value.value) as Ref<T>
  
  let timeout: ReturnType<typeof setTimeout>
  
  watch(value, (newValue) => {
    clearTimeout(timeout)
    timeout = setTimeout(() => {
      debouncedValue.value = newValue
    }, delay)
  })
  
  return debouncedValue
}


// ==========================================
// composables/useEventListener.ts
// ==========================================

import { onMounted, onUnmounted, type Ref } from 'vue'

export function useEventListener<K extends keyof WindowEventMap>(
  target: Window | Ref<HTMLElement | null>,
  event: K,
  handler: (e: WindowEventMap[K]) => void
): void {
  onMounted(() => {
    const el = 'value' in target ? target.value : target
    el?.addEventListener(event, handler as EventListener)
  })
  
  onUnmounted(() => {
    const el = 'value' in target ? target.value : target
    el?.removeEventListener(event, handler as EventListener)
  })
}


// ==========================================
// composables/useMouse.ts
// ==========================================

import { ref, onMounted, onUnmounted } from 'vue'

export function useMouse() {
  const x = ref(0)
  const y = ref(0)
  
  function update(e: MouseEvent) {
    x.value = e.clientX
    y.value = e.clientY
  }
  
  onMounted(() => window.addEventListener('mousemove', update))
  onUnmounted(() => window.removeEventListener('mousemove', update))
  
  return { x, y }
}
```

### Using Composables
```vue
<script setup lang="ts">
import { ref, computed } from 'vue'
import { useFetch } from '@/composables/useFetch'
import { useLocalStorage } from '@/composables/useLocalStorage'
import { useDebounce } from '@/composables/useDebounce'
import { useMouse } from '@/composables/useMouse'

// ==========================================
// USE FETCH
// ==========================================
const userId = ref('123')
const url = computed(() => `/api/users/${userId.value}`)

const { data: user, isLoading, error, execute: refetch } = useFetch<User>(url)

// ==========================================
// USE LOCAL STORAGE
// ==========================================
const theme = useLocalStorage('theme', 'light')
const savedFilters = useLocalStorage('filters', { search: '', category: 'all' })

// ==========================================
// USE DEBOUNCE
// ==========================================
const searchQuery = ref('')
const debouncedSearch = useDebounce(searchQuery, 300)

// ==========================================
// USE MOUSE
// ==========================================
const { x, y } = useMouse()
</script>

<template>
  <div>
    <!-- Fetch data -->
    <div v-if="isLoading">Loading...</div>
    <div v-else-if="error">{{ error }}</div>
    <div v-else-if="user">{{ user.name }}</div>
    
    <!-- Theme toggle -->
    <button @click="theme = theme === 'light' ? 'dark' : 'light'">
      Current: {{ theme }}
    </button>
    
    <!-- Search with debounce -->
    <input v-model="searchQuery" placeholder="Search..." />
    <p>Searching: {{ debouncedSearch }}</p>
    
    <!-- Mouse position -->
    <p>Mouse: {{ x }}, {{ y }}</p>
  </div>
</template>
```

---

## 4) Pinia State Management

### Store Definition
```typescript
// ==========================================
// stores/user.ts
// ==========================================

import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { User } from '@/types'
import { apiClient } from '@/api'

// ==========================================
// SETUP STORE (Composition API style)
// ==========================================

export const useUserStore = defineStore('user', () => {
  // ==========================================
  // STATE
  // ==========================================
  const currentUser = ref<User | null>(null)
  const users = ref<User[]>([])
  const isLoading = ref(false)
  const error = ref<string | null>(null)
  
  // ==========================================
  // GETTERS
  // ==========================================
  const isAuthenticated = computed(() => currentUser.value !== null)
  
  const userById = computed(() => {
    return (id: string) => users.value.find(user => user.id === id)
  })
  
  const activeUsers = computed(() => {
    return users.value.filter(user => user.isActive)
  })
  
  // ==========================================
  // ACTIONS
  // ==========================================
  async function login(email: string, password: string) {
    isLoading.value = true
    error.value = null
    
    try {
      const response = await apiClient.post<{ user: User; token: string }>(
        '/auth/login',
        { email, password }
      )
      
      currentUser.value = response.user
      localStorage.setItem('token', response.token)
      
      return true
    } catch (e) {
      error.value = e instanceof Error ? e.message : 'Login failed'
      return false
    } finally {
      isLoading.value = false
    }
  }
  
  function logout() {
    currentUser.value = null
    localStorage.removeItem('token')
  }
  
  async function fetchUsers() {
    isLoading.value = true
    error.value = null
    
    try {
      users.value = await apiClient.get<User[]>('/users')
    } catch (e) {
      error.value = e instanceof Error ? e.message : 'Failed to fetch users'
    } finally {
      isLoading.value = false
    }
  }
  
  async function fetchUser(id: string): Promise<User | null> {
    try {
      return await apiClient.get<User>(`/users/${id}`)
    } catch {
      return null
    }
  }
  
  async function updateUser(id: string, data: Partial<User>) {
    const updatedUser = await apiClient.patch<User>(`/users/${id}`, data)
    
    // Update in list
    const index = users.value.findIndex(u => u.id === id)
    if (index !== -1) {
      users.value[index] = updatedUser
    }
    
    // Update current user if same
    if (currentUser.value?.id === id) {
      currentUser.value = updatedUser
    }
    
    return updatedUser
  }
  
  async function deleteUser(id: string) {
    await apiClient.delete(`/users/${id}`)
    users.value = users.value.filter(u => u.id !== id)
  }
  
  // ==========================================
  // HYDRATION (SSR/Persistence)
  // ==========================================
  function $hydrate(state: { currentUser: User | null }) {
    if (state.currentUser) {
      currentUser.value = state.currentUser
    }
  }
  
  // Return all state, getters, and actions
  return {
    // State
    currentUser,
    users,
    isLoading,
    error,
    
    // Getters
    isAuthenticated,
    userById,
    activeUsers,
    
    // Actions
    login,
    logout,
    fetchUsers,
    fetchUser,
    updateUser,
    deleteUser,
    $hydrate,
  }
})


// ==========================================
// stores/cart.ts - Options API style
// ==========================================

import { defineStore } from 'pinia'
import type { Product, CartItem } from '@/types'

export const useCartStore = defineStore('cart', {
  state: () => ({
    items: [] as CartItem[],
    couponCode: null as string | null,
    discount: 0,
  }),
  
  getters: {
    itemCount: (state) => state.items.reduce((sum, item) => sum + item.quantity, 0),
    
    subtotal: (state) => {
      return state.items.reduce((sum, item) => sum + item.price * item.quantity, 0)
    },
    
    total(): number {
      return this.subtotal - this.discount
    },
    
    itemById: (state) => {
      return (productId: string) => state.items.find(item => item.productId === productId)
    },
  },
  
  actions: {
    addItem(product: Product, quantity = 1) {
      const existing = this.items.find(item => item.productId === product.id)
      
      if (existing) {
        existing.quantity += quantity
      } else {
        this.items.push({
          productId: product.id,
          name: product.name,
          price: product.price,
          quantity,
        })
      }
    },
    
    removeItem(productId: string) {
      this.items = this.items.filter(item => item.productId !== productId)
    },
    
    updateQuantity(productId: string, quantity: number) {
      const item = this.items.find(item => item.productId === productId)
      if (item) {
        item.quantity = Math.max(0, quantity)
        if (item.quantity === 0) {
          this.removeItem(productId)
        }
      }
    },
    
    async applyCoupon(code: string) {
      const response = await fetch(`/api/coupons/${code}`)
      if (response.ok) {
        const coupon = await response.json()
        this.couponCode = code
        this.discount = this.subtotal * (coupon.percentage / 100)
      }
    },
    
    clearCart() {
      this.items = []
      this.couponCode = null
      this.discount = 0
    },
  },
  
  // Persistence plugin
  persist: {
    storage: localStorage,
    paths: ['items', 'couponCode'],
  },
})
```

### Using Stores
```vue
<script setup lang="ts">
import { storeToRefs } from 'pinia'
import { useUserStore } from '@/stores/user'
import { useCartStore } from '@/stores/cart'

// ==========================================
// ACCESSING STORES
// ==========================================

const userStore = useUserStore()
const cartStore = useCartStore()

// ==========================================
// EXTRACTING STATE (maintain reactivity)
// ==========================================

// ✅ Use storeToRefs for state and getters
const { currentUser, isAuthenticated, isLoading } = storeToRefs(userStore)
const { items, total, itemCount } = storeToRefs(cartStore)

// ✅ Actions can be destructured directly
const { login, logout } = userStore
const { addItem, removeItem } = cartStore

// ❌ BAD: Don't destructure state directly
// const { currentUser } = userStore // Not reactive!


// ==========================================
// METHODS
// ==========================================

async function handleLogin(email: string, password: string) {
  const success = await login(email, password)
  if (success) {
    router.push('/dashboard')
  }
}

function handleAddToCart(product: Product) {
  addItem(product)
}
</script>

<template>
  <div>
    <!-- User state -->
    <div v-if="isAuthenticated">
      Welcome, {{ currentUser?.name }}
      <button @click="logout">Logout</button>
    </div>
    
    <!-- Cart -->
    <div class="cart">
      <span>Cart ({{ itemCount }})</span>
      <span>Total: ${{ total.toFixed(2) }}</span>
    </div>
  </div>
</template>
```

---

## 5) Vue Router

### Router Configuration
```typescript
// ==========================================
// router/index.ts
// ==========================================

import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import { useUserStore } from '@/stores/user'

// ==========================================
// ROUTE DEFINITIONS
// ==========================================

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'home',
    component: () => import('@/views/HomeView.vue'),
    meta: { title: 'Home' },
  },
  
  // Lazy-loaded route
  {
    path: '/about',
    name: 'about',
    component: () => import('@/views/AboutView.vue'),
    meta: { title: 'About' },
  },
  
  // Auth routes (redirect if logged in)
  {
    path: '/login',
    name: 'login',
    component: () => import('@/views/auth/LoginView.vue'),
    meta: { guest: true, title: 'Login' },
  },
  
  // Protected routes
  {
    path: '/dashboard',
    name: 'dashboard',
    component: () => import('@/views/DashboardView.vue'),
    meta: { requiresAuth: true, title: 'Dashboard' },
  },
  
  // Nested routes
  {
    path: '/users',
    component: () => import('@/views/users/UsersLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'users',
        component: () => import('@/views/users/UserListView.vue'),
        meta: { title: 'Users' },
      },
      {
        path: ':id',
        name: 'user-detail',
        component: () => import('@/views/users/UserDetailView.vue'),
        props: true,
        meta: { title: 'User Details' },
      },
      {
        path: ':id/edit',
        name: 'user-edit',
        component: () => import('@/views/users/UserEditView.vue'),
        props: true,
        meta: { title: 'Edit User', requiresAuth: true },
      },
    ],
  },
  
  // Dynamic route
  {
    path: '/products/:category/:id?',
    name: 'products',
    component: () => import('@/views/ProductsView.vue'),
    props: (route) => ({
      category: route.params.category,
      productId: route.params.id || null,
      page: Number(route.query.page) || 1,
    }),
  },
  
  // Catch-all 404
  {
    path: '/:pathMatch(.*)*',
    name: 'not-found',
    component: () => import('@/views/NotFoundView.vue'),
  },
]

// ==========================================
// ROUTER INSTANCE
// ==========================================

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition
    }
    if (to.hash) {
      return { el: to.hash, behavior: 'smooth' }
    }
    return { top: 0 }
  },
})

// ==========================================
// NAVIGATION GUARDS
// ==========================================

// Global before guard
router.beforeEach(async (to, from) => {
  const userStore = useUserStore()
  
  // Update document title
  document.title = `${to.meta.title || 'App'} | My App`
  
  // Check auth requirements
  if (to.meta.requiresAuth && !userStore.isAuthenticated) {
    return {
      name: 'login',
      query: { redirect: to.fullPath },
    }
  }
  
  // Redirect logged-in users from guest pages
  if (to.meta.guest && userStore.isAuthenticated) {
    return { name: 'dashboard' }
  }
})

// Global after guard
router.afterEach((to, from) => {
  // Analytics, logging, etc.
  console.log(`Navigated from ${from.path} to ${to.path}`)
})

export default router
```

### Using Router in Components
```vue
<script setup lang="ts">
import { useRouter, useRoute, onBeforeRouteLeave } from 'vue-router'

const router = useRouter()
const route = useRoute()

// ==========================================
// ACCESS ROUTE INFO
// ==========================================

// Current route params
const userId = route.params.id as string

// Query params
const page = Number(route.query.page) || 1

// Route meta
const pageTitle = route.meta.title as string

// ==========================================
// PROGRAMMATIC NAVIGATION
// ==========================================

function goToUser(id: string) {
  router.push({ name: 'user-detail', params: { id } })
}

function goToProducts(category: string, page = 1) {
  router.push({
    name: 'products',
    params: { category },
    query: { page: page.toString() },
  })
}

function goBack() {
  router.back()
}

async function submitAndRedirect() {
  await saveData()
  router.replace({ name: 'dashboard' })
}

// ==========================================
// ROUTE GUARD (Component-level)
// ==========================================

const hasUnsavedChanges = ref(false)

onBeforeRouteLeave((to, from) => {
  if (hasUnsavedChanges.value) {
    const confirm = window.confirm('You have unsaved changes. Leave anyway?')
    if (!confirm) {
      return false
    }
  }
})
</script>

<template>
  <div>
    <h1>{{ pageTitle }}</h1>
    <p>User ID: {{ userId }}</p>
    <p>Page: {{ page }}</p>
    
    <!-- Navigation -->
    <router-link :to="{ name: 'home' }">Home</router-link>
    <router-link :to="{ name: 'user-detail', params: { id: '123' } }">
      User 123
    </router-link>
    
    <!-- Active class -->
    <router-link
      :to="{ name: 'dashboard' }"
      active-class="active"
      exact-active-class="exact-active"
    >
      Dashboard
    </router-link>
    
    <!-- Router view with transitions -->
    <router-view v-slot="{ Component, route }">
      <Transition name="fade" mode="out-in">
        <component :is="Component" :key="route.path" />
      </Transition>
    </router-view>
  </div>
</template>
```

---

## 6) Advanced Patterns

### Provide/Inject
```vue
<!-- ==========================================
     PARENT COMPONENT - PROVIDE
     ========================================== -->

<script setup lang="ts">
import { provide, ref, readonly } from 'vue'
import type { InjectionKey } from 'vue'

// Type-safe injection key
interface ThemeContext {
  theme: Ref<'light' | 'dark'>
  toggleTheme: () => void
}

export const ThemeKey: InjectionKey<ThemeContext> = Symbol('theme')

// State
const theme = ref<'light' | 'dark'>('light')

function toggleTheme() {
  theme.value = theme.value === 'light' ? 'dark' : 'light'
}

// Provide to descendants
provide(ThemeKey, {
  theme: readonly(theme),  // Readonly for safety
  toggleTheme,
})
</script>


<!-- ==========================================
     CHILD COMPONENT - INJECT
     ========================================== -->

<script setup lang="ts">
import { inject } from 'vue'
import { ThemeKey } from '@/components/ThemeProvider.vue'

// Inject with type safety
const themeContext = inject(ThemeKey)

if (!themeContext) {
  throw new Error('ThemeProvider not found')
}

const { theme, toggleTheme } = themeContext
</script>

<template>
  <div :class="theme">
    <button @click="toggleTheme">
      Toggle ({{ theme }})
    </button>
  </div>
</template>
```

### Teleport
```vue
<script setup lang="ts">
import { ref } from 'vue'

const showModal = ref(false)
</script>

<template>
  <button @click="showModal = true">Open Modal</button>
  
  <!-- Teleport modal to body -->
  <Teleport to="body">
    <div v-if="showModal" class="modal-overlay" @click.self="showModal = false">
      <div class="modal">
        <h2>Modal Title</h2>
        <p>Modal content here...</p>
        <button @click="showModal = false">Close</button>
      </div>
    </div>
  </Teleport>
</template>

<style scoped>
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal {
  background: white;
  padding: 2rem;
  border-radius: 8px;
  max-width: 500px;
}
</style>
```

### Suspense (Async Components)
```vue
<!-- ==========================================
     ASYNC COMPONENT
     ========================================== -->

<script setup lang="ts">
// This component uses top-level await
const data = await fetch('/api/data').then(r => r.json())
</script>

<template>
  <div>{{ data }}</div>
</template>


<!-- ==========================================
     PARENT WITH SUSPENSE
     ========================================== -->

<script setup lang="ts">
import { defineAsyncComponent } from 'vue'

const AsyncUserProfile = defineAsyncComponent(() =>
  import('@/components/UserProfile.vue')
)
</script>

<template>
  <Suspense>
    <template #default>
      <AsyncUserProfile />
    </template>
    
    <template #fallback>
      <div class="loading">
        <span class="spinner" />
        Loading...
      </div>
    </template>
  </Suspense>
</template>
```

---

## 7) Performance Optimization

### v-memo and keep-alive
```vue
<script setup lang="ts">
import { ref } from 'vue'

const items = ref([...])
const selectedId = ref<string | null>(null)
</script>

<template>
  <!-- v-memo: Skip re-render if dependencies unchanged -->
  <div
    v-for="item in items"
    :key="item.id"
    v-memo="[item.id === selectedId]"
    :class="{ selected: item.id === selectedId }"
    @click="selectedId = item.id"
  >
    {{ item.name }}
  </div>
  
  <!-- keep-alive: Cache component state -->
  <router-view v-slot="{ Component }">
    <keep-alive :include="['HomePage', 'ProductList']" :max="10">
      <component :is="Component" />
    </keep-alive>
  </router-view>
</template>
```

### Performance Checklist
```
┌─────────────────────────────────────────┐
│       VUE 3 PERFORMANCE CHECKLIST       │
├─────────────────────────────────────────┤
│                                         │
│  REACTIVITY:                            │
│  □ Use shallowRef/shallowReactive      │
│  □ Avoid unnecessary watchers           │
│  □ Use computed for derived state       │
│                                         │
│  RENDERING:                             │
│  □ Use v-memo for expensive lists      │
│  □ Use v-once for static content       │
│  □ Use v-show vs v-if appropriately    │
│  □ Add :key to v-for                   │
│                                         │
│  COMPONENTS:                            │
│  □ Lazy load routes                    │
│  □ Use defineAsyncComponent            │
│  □ Use keep-alive for caching          │
│  □ Use Suspense for async              │
│                                         │
│  BUNDLE:                                │
│  □ Tree-shake unused features          │
│  □ Use production build               │
│  □ Analyze bundle size                 │
│                                         │
└─────────────────────────────────────────┘
```

---

## Best Practices Summary

### Script Setup
- [ ] Use `<script setup>` syntax
- [ ] TypeScript for type safety
- [ ] defineProps/defineEmits
- [ ] Extract logic to composables

### State
- [ ] ref for primitives
- [ ] reactive for objects
- [ ] computed for derived state
- [ ] Pinia for global state

### Performance
- [ ] Lazy load routes
- [ ] v-memo for lists
- [ ] keep-alive for caching
- [ ] shallowRef when possible

---

**References:**
- [Vue 3 Documentation](https://vuejs.org/)
- [Pinia Documentation](https://pinia.vuejs.org/)
- [Vue Router](https://router.vuejs.org/)
- [Vue Style Guide](https://vuejs.org/style-guide/)

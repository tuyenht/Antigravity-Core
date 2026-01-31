# Vue 3 + TypeScript Composition API Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **Vue:** 3.4+  
> **TypeScript:** 5.x  
> **Priority:** P0 - Load for Vue 3 projects

---

You are an expert in Vue 3 development with TypeScript and Composition API.

## Core Principles

- Use Composition API with `<script setup lang="ts">`
- Type all props, emits, and refs properly
- Leverage Vue 3's built-in TypeScript support
- Follow Vue 3 best practices

---

## 1) Project Setup

### Vite Configuration
```typescript
// ==========================================
// vite.config.ts
// ==========================================

import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import { fileURLToPath, URL } from 'node:url';

export default defineConfig({
  plugins: [
    vue({
      script: {
        defineModel: true,
        propsDestructure: true,
      },
    }),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
      '@components': fileURLToPath(new URL('./src/components', import.meta.url)),
      '@composables': fileURLToPath(new URL('./src/composables', import.meta.url)),
      '@stores': fileURLToPath(new URL('./src/stores', import.meta.url)),
      '@types': fileURLToPath(new URL('./src/types', import.meta.url)),
    },
  },
});
```

### TypeScript Configuration
```json
// ==========================================
// tsconfig.json
// ==========================================

{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "module": "ESNext",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "preserve",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@composables/*": ["./src/composables/*"],
      "@stores/*": ["./src/stores/*"],
      "@types/*": ["./src/types/*"]
    }
  },
  "include": ["src/**/*.ts", "src/**/*.tsx", "src/**/*.vue"],
  "references": [{ "path": "./tsconfig.node.json" }]
}


// ==========================================
// env.d.ts
// ==========================================

/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_API_URL: string;
  readonly VITE_APP_TITLE: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
```

---

## 2) Component Basics

### Script Setup with TypeScript
```vue
<!-- ==========================================
     components/UserCard.vue
     ========================================== -->

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';

// ==========================================
// PROPS
// ==========================================

interface Props {
  userId: string;
  name: string;
  email: string;
  avatar?: string;
  isActive?: boolean;
}

// With defaults
const props = withDefaults(defineProps<Props>(), {
  avatar: '/default-avatar.png',
  isActive: true,
});

// ==========================================
// EMITS
// ==========================================

interface Emits {
  (e: 'click', userId: string): void;
  (e: 'update', payload: { name: string; email: string }): void;
  (e: 'delete'): void;
}

const emit = defineEmits<Emits>();

// ==========================================
// REFS & REACTIVE STATE
// ==========================================

const isEditing = ref(false);
const editName = ref(props.name);
const editEmail = ref(props.email);

// ==========================================
// COMPUTED
// ==========================================

const initials = computed<string>(() => {
  return props.name
    .split(' ')
    .map(word => word[0])
    .join('')
    .toUpperCase()
    .slice(0, 2);
});

const displayName = computed<string>(() => {
  return props.isActive ? props.name : `${props.name} (Inactive)`;
});

// ==========================================
// METHODS
// ==========================================

function handleClick() {
  emit('click', props.userId);
}

function handleSave() {
  emit('update', {
    name: editName.value,
    email: editEmail.value,
  });
  isEditing.value = false;
}

function handleDelete() {
  emit('delete');
}

// ==========================================
// LIFECYCLE
// ==========================================

onMounted(() => {
  console.log(`UserCard mounted for ${props.name}`);
});
</script>

<template>
  <div class="user-card" @click="handleClick">
    <img :src="props.avatar" :alt="props.name" class="avatar" />
    
    <div class="info">
      <template v-if="!isEditing">
        <h3>{{ displayName }}</h3>
        <p>{{ props.email }}</p>
      </template>
      
      <template v-else>
        <input v-model="editName" placeholder="Name" />
        <input v-model="editEmail" placeholder="Email" />
      </template>
    </div>
    
    <div class="actions">
      <button v-if="!isEditing" @click.stop="isEditing = true">Edit</button>
      <button v-else @click.stop="handleSave">Save</button>
      <button @click.stop="handleDelete">Delete</button>
    </div>
  </div>
</template>

<style scoped>
.user-card {
  display: flex;
  align-items: center;
  padding: 1rem;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  cursor: pointer;
}

.avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
}

.info {
  flex: 1;
  margin-left: 1rem;
}
</style>
```

### defineModel (Vue 3.4+)
```vue
<!-- ==========================================
     components/SearchInput.vue
     ========================================== -->

<script setup lang="ts">
// Two-way binding with defineModel
const modelValue = defineModel<string>({ required: true });
const isOpen = defineModel<boolean>('open', { default: false });

// With transform
const count = defineModel<number>('count', {
  get: (value) => value ?? 0,
  set: (value) => Math.max(0, value),
});
</script>

<template>
  <div class="search-input">
    <input 
      v-model="modelValue" 
      type="text" 
      placeholder="Search..."
      @focus="isOpen = true"
      @blur="isOpen = false"
    />
    
    <div v-if="isOpen" class="dropdown">
      <!-- Search results -->
    </div>
  </div>
</template>


<!-- ==========================================
     Usage
     ========================================== -->

<script setup lang="ts">
import { ref } from 'vue';
import SearchInput from './SearchInput.vue';

const searchQuery = ref('');
const isDropdownOpen = ref(false);
</script>

<template>
  <SearchInput v-model="searchQuery" v-model:open="isDropdownOpen" />
</template>
```

### Slots with TypeScript
```vue
<!-- ==========================================
     components/DataTable.vue
     ========================================== -->

<script setup lang="ts" generic="T extends { id: string | number }">
import { computed } from 'vue';

// Generic props
interface Props {
  items: T[];
  columns: Array<{
    key: keyof T;
    label: string;
    width?: string;
  }>;
  loading?: boolean;
}

const props = defineProps<Props>();

// Typed slots
defineSlots<{
  default(props: { item: T; index: number }): any;
  header(props: { column: Props['columns'][number] }): any;
  empty(): any;
  loading(): any;
}>();

const isEmpty = computed(() => props.items.length === 0);
</script>

<template>
  <table class="data-table">
    <thead>
      <tr>
        <th v-for="column in columns" :key="String(column.key)" :style="{ width: column.width }">
          <slot name="header" :column="column">
            {{ column.label }}
          </slot>
        </th>
      </tr>
    </thead>
    
    <tbody>
      <template v-if="loading">
        <tr>
          <td :colspan="columns.length">
            <slot name="loading">Loading...</slot>
          </td>
        </tr>
      </template>
      
      <template v-else-if="isEmpty">
        <tr>
          <td :colspan="columns.length">
            <slot name="empty">No items found</slot>
          </td>
        </tr>
      </template>
      
      <template v-else>
        <tr v-for="(item, index) in items" :key="item.id">
          <slot :item="item" :index="index">
            <td v-for="column in columns" :key="String(column.key)">
              {{ item[column.key] }}
            </td>
          </slot>
        </tr>
      </template>
    </tbody>
  </table>
</template>
```

---

## 3) Composables

### Basic Composable
```typescript
// ==========================================
// composables/useFetch.ts
// ==========================================

import { ref, shallowRef, type Ref, type UnwrapRef } from 'vue';

interface UseFetchOptions<T> {
  immediate?: boolean;
  initialData?: T;
  onSuccess?: (data: T) => void;
  onError?: (error: Error) => void;
}

interface UseFetchReturn<T> {
  data: Ref<T | null>;
  error: Ref<Error | null>;
  isLoading: Ref<boolean>;
  execute: () => Promise<void>;
  refresh: () => Promise<void>;
}

export function useFetch<T>(
  url: string | (() => string),
  options: UseFetchOptions<T> = {}
): UseFetchReturn<T> {
  const { 
    immediate = true, 
    initialData = null,
    onSuccess,
    onError,
  } = options;
  
  const data = shallowRef<T | null>(initialData);
  const error = ref<Error | null>(null);
  const isLoading = ref(false);
  
  async function execute() {
    const resolvedUrl = typeof url === 'function' ? url() : url;
    
    isLoading.value = true;
    error.value = null;
    
    try {
      const response = await fetch(resolvedUrl);
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const json = await response.json() as T;
      data.value = json;
      onSuccess?.(json);
    } catch (e) {
      const err = e instanceof Error ? e : new Error(String(e));
      error.value = err;
      onError?.(err);
    } finally {
      isLoading.value = false;
    }
  }
  
  const refresh = execute;
  
  if (immediate) {
    execute();
  }
  
  return {
    data: data as Ref<T | null>,
    error,
    isLoading,
    execute,
    refresh,
  };
}


// ==========================================
// composables/useLocalStorage.ts
// ==========================================

import { ref, watch, type Ref } from 'vue';

export function useLocalStorage<T>(
  key: string,
  defaultValue: T
): Ref<T> {
  const storedValue = localStorage.getItem(key);
  const initial = storedValue ? JSON.parse(storedValue) as T : defaultValue;
  
  const state = ref<T>(initial) as Ref<T>;
  
  watch(
    state,
    (newValue) => {
      localStorage.setItem(key, JSON.stringify(newValue));
    },
    { deep: true }
  );
  
  return state;
}


// ==========================================
// composables/useDebounce.ts
// ==========================================

import { ref, watch, type Ref, type UnwrapRef } from 'vue';

export function useDebounce<T>(
  value: Ref<T>,
  delay: number = 300
): Ref<UnwrapRef<T>> {
  const debouncedValue = ref(value.value) as Ref<UnwrapRef<T>>;
  let timeout: ReturnType<typeof setTimeout>;
  
  watch(value, (newValue) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => {
      debouncedValue.value = newValue as UnwrapRef<T>;
    }, delay);
  });
  
  return debouncedValue;
}


// ==========================================
// composables/useAsync.ts
// ==========================================

import { ref, type Ref } from 'vue';

interface UseAsyncReturn<T, TParams extends unknown[]> {
  data: Ref<T | null>;
  error: Ref<Error | null>;
  isLoading: Ref<boolean>;
  execute: (...params: TParams) => Promise<T | null>;
}

export function useAsync<T, TParams extends unknown[] = []>(
  asyncFn: (...params: TParams) => Promise<T>
): UseAsyncReturn<T, TParams> {
  const data = ref<T | null>(null) as Ref<T | null>;
  const error = ref<Error | null>(null);
  const isLoading = ref(false);
  
  async function execute(...params: TParams): Promise<T | null> {
    isLoading.value = true;
    error.value = null;
    
    try {
      const result = await asyncFn(...params);
      data.value = result;
      return result;
    } catch (e) {
      error.value = e instanceof Error ? e : new Error(String(e));
      return null;
    } finally {
      isLoading.value = false;
    }
  }
  
  return { data, error, isLoading, execute };
}
```

### Generic Composable
```typescript
// ==========================================
// composables/usePagination.ts
// ==========================================

import { ref, computed, type Ref, type ComputedRef } from 'vue';

interface UsePaginationOptions {
  initialPage?: number;
  initialPageSize?: number;
  total: Ref<number>;
}

interface UsePaginationReturn {
  page: Ref<number>;
  pageSize: Ref<number>;
  totalPages: ComputedRef<number>;
  offset: ComputedRef<number>;
  isFirstPage: ComputedRef<boolean>;
  isLastPage: ComputedRef<boolean>;
  next: () => void;
  prev: () => void;
  goTo: (page: number) => void;
  setPageSize: (size: number) => void;
}

export function usePagination(
  options: UsePaginationOptions
): UsePaginationReturn {
  const { initialPage = 1, initialPageSize = 10, total } = options;
  
  const page = ref(initialPage);
  const pageSize = ref(initialPageSize);
  
  const totalPages = computed(() => 
    Math.ceil(total.value / pageSize.value)
  );
  
  const offset = computed(() => 
    (page.value - 1) * pageSize.value
  );
  
  const isFirstPage = computed(() => page.value === 1);
  const isLastPage = computed(() => page.value >= totalPages.value);
  
  function next() {
    if (!isLastPage.value) {
      page.value++;
    }
  }
  
  function prev() {
    if (!isFirstPage.value) {
      page.value--;
    }
  }
  
  function goTo(targetPage: number) {
    const validPage = Math.max(1, Math.min(targetPage, totalPages.value));
    page.value = validPage;
  }
  
  function setPageSize(size: number) {
    pageSize.value = size;
    page.value = 1;  // Reset to first page
  }
  
  return {
    page,
    pageSize,
    totalPages,
    offset,
    isFirstPage,
    isLastPage,
    next,
    prev,
    goTo,
    setPageSize,
  };
}
```

---

## 4) Vue Router

### Typed Router Setup
```typescript
// ==========================================
// router/index.ts
// ==========================================

import { 
  createRouter, 
  createWebHistory,
  type RouteRecordRaw,
  type RouteLocationNormalized,
} from 'vue-router';

// Route meta typing
declare module 'vue-router' {
  interface RouteMeta {
    requiresAuth?: boolean;
    roles?: string[];
    title?: string;
  }
}

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'home',
    component: () => import('@/views/HomeView.vue'),
    meta: { title: 'Home' },
  },
  {
    path: '/login',
    name: 'login',
    component: () => import('@/views/LoginView.vue'),
    meta: { title: 'Login' },
  },
  {
    path: '/dashboard',
    name: 'dashboard',
    component: () => import('@/views/DashboardView.vue'),
    meta: { requiresAuth: true, title: 'Dashboard' },
    children: [
      {
        path: 'users',
        name: 'users',
        component: () => import('@/views/UsersView.vue'),
        meta: { requiresAuth: true, roles: ['admin'] },
      },
      {
        path: 'users/:id',
        name: 'user-detail',
        component: () => import('@/views/UserDetailView.vue'),
        props: true,
        meta: { requiresAuth: true },
      },
    ],
  },
  {
    path: '/products/:id',
    name: 'product',
    component: () => import('@/views/ProductView.vue'),
    props: route => ({ 
      id: route.params.id,
      tab: route.query.tab as string | undefined,
    }),
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'not-found',
    component: () => import('@/views/NotFoundView.vue'),
  },
];

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
});

// Navigation guard
router.beforeEach((to, from) => {
  const isAuthenticated = !!localStorage.getItem('token');
  
  if (to.meta.requiresAuth && !isAuthenticated) {
    return { name: 'login', query: { redirect: to.fullPath } };
  }
  
  // Update document title
  if (to.meta.title) {
    document.title = `${to.meta.title} | My App`;
  }
  
  return true;
});

export default router;


// ==========================================
// composables/useTypedRouter.ts
// ==========================================

import { useRouter, useRoute, type RouteLocationRaw } from 'vue-router';
import { computed } from 'vue';

// Define route params types
interface RouteParams {
  'user-detail': { id: string };
  'product': { id: string };
}

interface RouteQuery {
  'product': { tab?: string };
}

export function useTypedRouter() {
  const router = useRouter();
  const route = useRoute();
  
  function push<T extends keyof RouteParams>(
    name: T,
    params: RouteParams[T],
    query?: T extends keyof RouteQuery ? RouteQuery[T] : never
  ) {
    return router.push({ name, params, query } as RouteLocationRaw);
  }
  
  function replace<T extends keyof RouteParams>(
    name: T,
    params: RouteParams[T]
  ) {
    return router.replace({ name, params } as RouteLocationRaw);
  }
  
  const currentParams = computed(() => route.params);
  const currentQuery = computed(() => route.query);
  
  return {
    router,
    route,
    push,
    replace,
    currentParams,
    currentQuery,
    back: router.back,
    forward: router.forward,
  };
}


// ==========================================
// views/ProductView.vue
// ==========================================

<script setup lang="ts">
import { useRoute, useRouter } from 'vue-router';
import { computed } from 'vue';

// Type route params
const route = useRoute();
const router = useRouter();

// Typed params
const productId = computed(() => route.params.id as string);
const activeTab = computed(() => route.query.tab as string | undefined);

function changeTab(tab: string) {
  router.push({
    name: 'product',
    params: { id: productId.value },
    query: { tab },
  });
}
</script>
```

---

## 5) Pinia State Management

### Typed Store
```typescript
// ==========================================
// stores/auth.ts
// ==========================================

import { defineStore } from 'pinia';
import { ref, computed } from 'vue';

interface User {
  id: string;
  email: string;
  name: string;
  avatar?: string;
  role: 'admin' | 'user';
}

interface LoginCredentials {
  email: string;
  password: string;
}

export const useAuthStore = defineStore('auth', () => {
  // State
  const user = ref<User | null>(null);
  const token = ref<string | null>(null);
  const isLoading = ref(false);
  const error = ref<string | null>(null);
  
  // Getters
  const isAuthenticated = computed(() => !!token.value);
  const isAdmin = computed(() => user.value?.role === 'admin');
  const userInitials = computed(() => {
    if (!user.value) return '';
    return user.value.name
      .split(' ')
      .map(word => word[0])
      .join('')
      .toUpperCase();
  });
  
  // Actions
  async function login(credentials: LoginCredentials): Promise<boolean> {
    isLoading.value = true;
    error.value = null;
    
    try {
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(credentials),
      });
      
      if (!response.ok) {
        throw new Error('Invalid credentials');
      }
      
      const data = await response.json() as { user: User; token: string };
      
      user.value = data.user;
      token.value = data.token;
      
      localStorage.setItem('token', data.token);
      localStorage.setItem('user', JSON.stringify(data.user));
      
      return true;
    } catch (e) {
      error.value = e instanceof Error ? e.message : 'Login failed';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  function logout() {
    user.value = null;
    token.value = null;
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  }
  
  function initialize() {
    const storedToken = localStorage.getItem('token');
    const storedUser = localStorage.getItem('user');
    
    if (storedToken && storedUser) {
      token.value = storedToken;
      user.value = JSON.parse(storedUser) as User;
    }
  }
  
  async function updateProfile(updates: Partial<Pick<User, 'name' | 'avatar'>>) {
    if (!user.value) return;
    
    isLoading.value = true;
    
    try {
      const response = await fetch('/api/auth/profile', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token.value}`,
        },
        body: JSON.stringify(updates),
      });
      
      if (!response.ok) {
        throw new Error('Update failed');
      }
      
      const updatedUser = await response.json() as User;
      user.value = updatedUser;
      localStorage.setItem('user', JSON.stringify(updatedUser));
    } finally {
      isLoading.value = false;
    }
  }
  
  return {
    // State
    user,
    token,
    isLoading,
    error,
    // Getters
    isAuthenticated,
    isAdmin,
    userInitials,
    // Actions
    login,
    logout,
    initialize,
    updateProfile,
  };
});


// ==========================================
// stores/cart.ts
// ==========================================

import { defineStore } from 'pinia';
import { ref, computed } from 'vue';

interface CartItem {
  id: string;
  productId: string;
  name: string;
  price: number;
  quantity: number;
  image: string;
}

export const useCartStore = defineStore('cart', () => {
  const items = ref<CartItem[]>([]);
  
  const itemCount = computed(() => 
    items.value.reduce((sum, item) => sum + item.quantity, 0)
  );
  
  const totalPrice = computed(() =>
    items.value.reduce((sum, item) => sum + item.price * item.quantity, 0)
  );
  
  function addItem(product: Omit<CartItem, 'id' | 'quantity'>) {
    const existing = items.value.find(item => item.productId === product.productId);
    
    if (existing) {
      existing.quantity++;
    } else {
      items.value.push({
        ...product,
        id: crypto.randomUUID(),
        quantity: 1,
      });
    }
  }
  
  function removeItem(itemId: string) {
    const index = items.value.findIndex(item => item.id === itemId);
    if (index > -1) {
      items.value.splice(index, 1);
    }
  }
  
  function updateQuantity(itemId: string, quantity: number) {
    const item = items.value.find(item => item.id === itemId);
    if (item) {
      item.quantity = Math.max(1, quantity);
    }
  }
  
  function clearCart() {
    items.value = [];
  }
  
  return {
    items,
    itemCount,
    totalPrice,
    addItem,
    removeItem,
    updateQuantity,
    clearCart,
  };
}, {
  persist: true,  // With pinia-plugin-persistedstate
});
```

---

## 6) Provide/Inject

### Type-Safe Provide/Inject
```typescript
// ==========================================
// injection-keys.ts
// ==========================================

import type { InjectionKey, Ref } from 'vue';

// Theme
export interface Theme {
  colors: {
    primary: string;
    secondary: string;
    background: string;
    text: string;
  };
  spacing: {
    sm: string;
    md: string;
    lg: string;
  };
}

export const themeKey: InjectionKey<Theme> = Symbol('theme');

// User
export interface UserContext {
  user: Ref<User | null>;
  isAuthenticated: Ref<boolean>;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
}

export const userKey: InjectionKey<UserContext> = Symbol('user');

// Modal
export interface ModalContext {
  isOpen: Ref<boolean>;
  open: (content: Component) => void;
  close: () => void;
}

export const modalKey: InjectionKey<ModalContext> = Symbol('modal');


// ==========================================
// App.vue (Provider)
// ==========================================

<script setup lang="ts">
import { provide, ref } from 'vue';
import { themeKey, userKey, type Theme } from './injection-keys';

const theme: Theme = {
  colors: {
    primary: '#007AFF',
    secondary: '#5856D6',
    background: '#FFFFFF',
    text: '#000000',
  },
  spacing: {
    sm: '0.5rem',
    md: '1rem',
    lg: '2rem',
  },
};

provide(themeKey, theme);

// User context
const user = ref(null);
const isAuthenticated = computed(() => !!user.value);

provide(userKey, {
  user,
  isAuthenticated,
  login: async (email, password) => { /* ... */ },
  logout: () => { user.value = null; },
});
</script>


// ==========================================
// composables/useTheme.ts
// ==========================================

import { inject } from 'vue';
import { themeKey, type Theme } from '@/injection-keys';

export function useTheme(): Theme {
  const theme = inject(themeKey);
  
  if (!theme) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  
  return theme;
}


// ==========================================
// Component using inject
// ==========================================

<script setup lang="ts">
import { useTheme } from '@/composables/useTheme';

const theme = useTheme();
</script>

<template>
  <button :style="{ backgroundColor: theme.colors.primary }">
    Click me
  </button>
</template>
```

---

## 7) Template Refs

### Typed Template Refs
```vue
<!-- ==========================================
     components/FormWithRefs.vue
     ========================================== -->

<script setup lang="ts">
import { ref, onMounted } from 'vue';

// DOM element refs
const inputRef = ref<HTMLInputElement | null>(null);
const formRef = ref<HTMLFormElement | null>(null);

// Component ref
interface ChildComponent {
  validate: () => boolean;
  reset: () => void;
  focus: () => void;
}

const childRef = ref<InstanceType<typeof import('./ChildComponent.vue')['default']> | null>(null);

// Focus input on mount
onMounted(() => {
  inputRef.value?.focus();
});

function handleSubmit() {
  if (childRef.value?.validate()) {
    formRef.value?.submit();
  }
}

function handleReset() {
  childRef.value?.reset();
  formRef.value?.reset();
}
</script>

<template>
  <form ref="formRef" @submit.prevent="handleSubmit">
    <input ref="inputRef" type="text" />
    <ChildComponent ref="childRef" />
    <button type="submit">Submit</button>
    <button type="button" @click="handleReset">Reset</button>
  </form>
</template>


<!-- ==========================================
     components/ChildComponent.vue
     ========================================== -->

<script setup lang="ts">
import { ref } from 'vue';

const isValid = ref(true);
const inputValue = ref('');

// Expose methods to parent
defineExpose({
  validate(): boolean {
    isValid.value = inputValue.value.length > 0;
    return isValid.value;
  },
  reset(): void {
    inputValue.value = '';
    isValid.value = true;
  },
  focus(): void {
    // Focus logic
  },
});
</script>
```

---

## 8) Testing

### Vitest + Vue Test Utils
```typescript
// ==========================================
// vitest.config.ts
// ==========================================

import { defineConfig } from 'vitest/config';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  plugins: [vue()],
  test: {
    globals: true,
    environment: 'jsdom',
    include: ['**/*.{test,spec}.{ts,tsx}'],
    setupFiles: ['./test/setup.ts'],
  },
});


// ==========================================
// test/setup.ts
// ==========================================

import { config } from '@vue/test-utils';
import { createPinia, setActivePinia } from 'pinia';

// Reset Pinia before each test
beforeEach(() => {
  setActivePinia(createPinia());
});

// Global stubs
config.global.stubs = {
  RouterLink: true,
  RouterView: true,
};


// ==========================================
// components/__tests__/UserCard.spec.ts
// ==========================================

import { describe, it, expect, vi } from 'vitest';
import { mount } from '@vue/test-utils';
import UserCard from '../UserCard.vue';

describe('UserCard', () => {
  const defaultProps = {
    userId: '1',
    name: 'John Doe',
    email: 'john@example.com',
  };
  
  it('renders user info correctly', () => {
    const wrapper = mount(UserCard, {
      props: defaultProps,
    });
    
    expect(wrapper.text()).toContain('John Doe');
    expect(wrapper.text()).toContain('john@example.com');
  });
  
  it('emits click event with userId', async () => {
    const wrapper = mount(UserCard, {
      props: defaultProps,
    });
    
    await wrapper.trigger('click');
    
    expect(wrapper.emitted('click')).toBeTruthy();
    expect(wrapper.emitted('click')![0]).toEqual(['1']);
  });
  
  it('toggles edit mode', async () => {
    const wrapper = mount(UserCard, {
      props: defaultProps,
    });
    
    expect(wrapper.find('input').exists()).toBe(false);
    
    await wrapper.find('button').trigger('click');
    
    expect(wrapper.find('input').exists()).toBe(true);
  });
  
  it('emits update event with new values', async () => {
    const wrapper = mount(UserCard, {
      props: defaultProps,
    });
    
    // Enter edit mode
    await wrapper.findAll('button')[0].trigger('click');
    
    // Change values
    const inputs = wrapper.findAll('input');
    await inputs[0].setValue('Jane Doe');
    await inputs[1].setValue('jane@example.com');
    
    // Save
    await wrapper.findAll('button')[0].trigger('click');
    
    expect(wrapper.emitted('update')).toBeTruthy();
    expect(wrapper.emitted('update')![0]).toEqual([{
      name: 'Jane Doe',
      email: 'jane@example.com',
    }]);
  });
});
```

---

## Best Practices Checklist

### Components
- [ ] Use `<script setup lang="ts">`
- [ ] Type all props with interfaces
- [ ] Type emits with payloads
- [ ] Use defineModel for v-model

### Composables
- [ ] Return typed objects
- [ ] Use generics when needed
- [ ] Export types alongside

### State
- [ ] Pinia with setup stores
- [ ] Typed getters/actions
- [ ] Persist when needed

### Router
- [ ] Type route meta
- [ ] Type params/query
- [ ] Type navigation guards

---

**References:**
- [Vue 3 TypeScript](https://vuejs.org/guide/typescript/overview.html)
- [Pinia TypeScript](https://pinia.vuejs.org/core-concepts/state.html#typescript)
- [Vue Router TypeScript](https://router.vuejs.org/guide/advanced/typed-routes.html)
- [VueUse](https://vueuse.org/)

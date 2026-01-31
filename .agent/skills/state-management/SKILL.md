---
name: State Management
description: State management patterns for React (Redux, Zustand), Vue (Pinia), and other frameworks
category: Frontend
difficulty: Intermediate
last_updated: 2026-01-16
---

# State Management Patterns

Comprehensive patterns for managing application state across frameworks.

---

## When to Use This Skill

- Complex frontend state
- Choosing state management solution
- Redux/Zustand implementation (React)
- Pinia implementation (Vue)
- State synchronization
- Performance optimization

---

## Content Map

### React State Management
- **react-state.md** - useState, useReducer, Context
- Redux Toolkit patterns
- Zustand (lightweight alternative)
- Jotai (atomic state)
- When to use each

### Vue State Management
- **vue-state.md** - Reactive state, Composition API
- Pinia patterns
- Vuex (legacy)

### State Patterns
- **patterns.md** - Common patterns
- Global vs local state
- Derived state
- Async state
- State normalization

### Performance
- **performance.md** - Optimization techniques
- Selector memoization
- Preventing re-renders
- State slicing

---

## Quick Reference

### React - useState (Local State)
```typescript
const [count, setCount] = useState(0);
const [user, setUser] = useState<User | null>(null);

// Update object state
setUser(prev => ({ ...prev, name: 'John' }));
```

### React - Context (Medium Complexity)
```typescript
const UserContext = createContext<User | null>(null);

function UserProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  
  return (
    <UserContext.Provider value={{ user, setUser }}>
      {children}
    </UserContext.Provider>
  );
}

// Usage
const { user } = useContext(UserContext);
```

### React - Redux Toolkit (Complex Apps)
```typescript
// Slice
const counterSlice = createSlice({
  name: 'counter',
  initialState: { value: 0 },
  reducers: {
    increment: (state) => {
      state.value += 1; // Immer makes this safe
    },
    decrement: (state) => {
      state.value -= 1;
    },
  },
});

// Store
const store = configureStore({
  reducer: {
    counter: counterSlice.reducer,
  },
});

// Usage
const count = useSelector((state: RootState) => state.counter.value);
const dispatch = useDispatch();
dispatch(increment());
```

### React - Zustand (Simple & Fast)
```typescript
import create from 'zustand';

const useStore = create<State>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
}));

// Usage
const { count, increment } = useStore();
```

### Vue - Pinia
```typescript
import { defineStore } from 'pinia';

export const useCounterStore = defineStore('counter', {
  state: () => ({
    count: 0,
  }),
  getters: {
    doubleCount: (state) => state.count * 2,
  },
  actions: {
    increment() {
      this.count++;
    },
  },
});

// Usage
const store = useCounterStore();
store.increment();
```

---

## Decision Tree

```
Choose State Management:

Local Component State? 
  → useState/reactive (Vue)

Shared Across Few Components?
  → Context API/Provide-Inject

Complex Global State?
  → Redux Toolkit/Pinia

Simple Global State?
  → Zustand/Pinia

Atomic Updates?
  → Jotai/Recoil
```

---

## Anti-Patterns

❌ **Everything in global state** → Keep local when possible  
❌ **Prop drilling > 3 levels** → Use context/state management  
❌ **No state normalization** → Duplicate data  
❌ **Mutating state directly** → Use immutable updates  
❌ **Over-engineering** → useState often sufficient

---

## Best Practices

✅ **Start simple** - useState/reactive first  
✅ **Normalize state** for relational data  
✅ **Memoize selectors** (useSelector, computed)  
✅ **Separate UI vs server state** (React Query for server)  
✅ **DevTools** for debugging  
✅ **TypeScript** for type safety

---

## Performance Tips

```typescript
// ✅ Good - Memoized selector
const selectUser = createSelector(
  (state: RootState) => state.users,
  (users) => users.find(u => u.active)
);

// ✅ Good - Prevent re-renders
const Component = memo(({ data }) => {
  return <div>{data}</div>;
});

// ✅ Good - State slicing (Zustand)
const count = useStore(state => state.count); // Only re-renders when count changes
```

---

## Related Skills

- `react-patterns` - React component patterns
- `performance-profiling` - Performance optimization

---

## Official Resources

- [Redux Toolkit](https://redux-toolkit.js.org/)
- [Zustand](https://github.com/pmndrs/zustand)
- [Pinia](https://pinia.vuejs.org/)
- [Jotai](https://jotai.org/)

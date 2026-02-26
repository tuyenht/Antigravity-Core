# Angular Modern Development Expert

> **Version:** 2.0.0 | **Updated:** 2026-02-01  
> **Angular:** 17+ | **Signals-first** | **Standalone Components**  
> **Priority:** P0 - Load for Angular projects

---

You are an expert in modern Angular development (v17+).

## Core Principles

- TypeScript-first development
- Component-based architecture
- Use Signals for fine-grained reactivity
- Prefer Standalone Components over NgModules

---

## 1) Standalone Components

### Modern Component Structure
```typescript
// ==========================================
// MODERN ANGULAR 17+ COMPONENT
// ==========================================

import { 
  Component, 
  input, 
  output, 
  computed, 
  signal,
  inject,
  ChangeDetectionStrategy,
  type OnInit
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { UserService } from '@/services/user.service';
import type { User } from '@/types';

@Component({
  selector: 'app-user-card',
  standalone: true,
  imports: [CommonModule, RouterLink],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <!-- New Control Flow Syntax -->
    @if (isLoading()) {
      <div class="loading">
        <span class="spinner"></span>
        Loading...
      </div>
    } @else if (error()) {
      <div class="error">
        {{ error() }}
        <button (click)="retry()">Retry</button>
      </div>
    } @else if (user()) {
      <div class="user-card" [class.selected]="isSelected()">
        @if (showAvatar()) {
          <img 
            [src]="user()!.avatarUrl" 
            [alt]="fullName()"
            class="avatar"
          />
        }
        
        <div class="info">
          <h3>{{ fullName() }}</h3>
          <p>{{ user()!.email }}</p>
        </div>
        
        <div class="actions">
          <button (click)="onEdit()">Edit</button>
          <button (click)="onDelete()" class="danger">Delete</button>
        </div>
      </div>
    }
  `,
  styles: [`
    .user-card {
      display: flex;
      align-items: center;
      gap: 1rem;
      padding: 1rem;
      border-radius: 8px;
      background: var(--surface);
    }
    
    .user-card.selected {
      border: 2px solid var(--primary);
    }
    
    .avatar {
      width: 48px;
      height: 48px;
      border-radius: 50%;
      object-fit: cover;
    }
    
    .danger {
      color: var(--error);
    }
  `]
})
export class UserCardComponent implements OnInit {
  // ==========================================
  // DEPENDENCY INJECTION
  // ==========================================
  private userService = inject(UserService);
  
  // ==========================================
  // INPUTS (Signal-based)
  // ==========================================
  userId = input.required<string>();
  showAvatar = input(true);
  size = input<'sm' | 'md' | 'lg'>('md');
  
  // ==========================================
  // OUTPUTS (Signal-based)
  // ==========================================
  userUpdated = output<User>();
  userDeleted = output<string>();
  
  // ==========================================
  // LOCAL STATE (Signals)
  // ==========================================
  user = signal<User | null>(null);
  isLoading = signal(false);
  error = signal<string | null>(null);
  
  // ==========================================
  // COMPUTED VALUES
  // ==========================================
  fullName = computed(() => {
    const u = this.user();
    return u ? `${u.firstName} ${u.lastName}` : '';
  });
  
  isSelected = computed(() => {
    return this.userService.selectedUserId() === this.userId();
  });
  
  // ==========================================
  // LIFECYCLE
  // ==========================================
  ngOnInit() {
    this.loadUser();
  }
  
  // ==========================================
  // METHODS
  // ==========================================
  async loadUser() {
    this.isLoading.set(true);
    this.error.set(null);
    
    try {
      const user = await this.userService.getUser(this.userId());
      this.user.set(user);
    } catch (e) {
      this.error.set(e instanceof Error ? e.message : 'Failed to load user');
    } finally {
      this.isLoading.set(false);
    }
  }
  
  retry() {
    this.loadUser();
  }
  
  onEdit() {
    if (this.user()) {
      this.userUpdated.emit(this.user()!);
    }
  }
  
  onDelete() {
    this.userDeleted.emit(this.userId());
  }
}
```

---

## 2) Signals System

### Signal Fundamentals
```typescript
// ==========================================
// SIGNALS - CORE API
// ==========================================

import { 
  signal, 
  computed, 
  effect,
  untracked,
  type Signal,
  type WritableSignal
} from '@angular/core';

// ==========================================
// WRITABLE SIGNALS
// ==========================================

// Create a writable signal
const count = signal(0);

// Read value
console.log(count());  // 0

// Set value
count.set(5);

// Update based on current value
count.update(current => current + 1);


// ==========================================
// OBJECTS AND ARRAYS
// ==========================================

interface User {
  id: string;
  name: string;
  email: string;
}

const user = signal<User | null>(null);

// Set entire object
user.set({ id: '1', name: 'John', email: 'john@example.com' });

// Update specific properties
user.update(u => u ? { ...u, name: 'Jane' } : null);


const items = signal<string[]>([]);

// Add item
items.update(list => [...list, 'new item']);

// Remove item
items.update(list => list.filter(item => item !== 'remove me'));


// ==========================================
// COMPUTED SIGNALS
// ==========================================

const firstName = signal('John');
const lastName = signal('Doe');

// Computed - automatically tracks dependencies
const fullName = computed(() => `${firstName()} ${lastName()}`);

console.log(fullName());  // "John Doe"

firstName.set('Jane');
console.log(fullName());  // "Jane Doe"


// Complex computed
const users = signal<User[]>([]);
const searchQuery = signal('');
const selectedRole = signal<string | null>(null);

const filteredUsers = computed(() => {
  let result = users();
  
  const query = searchQuery().toLowerCase();
  if (query) {
    result = result.filter(u => 
      u.name.toLowerCase().includes(query) ||
      u.email.toLowerCase().includes(query)
    );
  }
  
  const role = selectedRole();
  if (role) {
    result = result.filter(u => u.role === role);
  }
  
  return result;
});


// ==========================================
// EFFECTS
// ==========================================

// Effect runs when any signal it reads changes
effect(() => {
  console.log(`Count is now: ${count()}`);
});

// Effect with cleanup
effect((onCleanup) => {
  const subscription = someObservable.subscribe();
  
  onCleanup(() => {
    subscription.unsubscribe();
  });
});

// Effect with untracked (read without tracking)
effect(() => {
  const currentUser = user();  // Tracked
  const currentCount = untracked(() => count());  // Not tracked
  
  console.log(`User: ${currentUser?.name}, Count: ${currentCount}`);
});


// ==========================================
// SIGNAL EQUALITY
// ==========================================

// Custom equality function
const config = signal(
  { theme: 'dark', language: 'en' },
  { equal: (a, b) => a.theme === b.theme && a.language === b.language }
);
```

### Signals in Components
```typescript
// ==========================================
// SIGNAL-BASED COMPONENT PATTERN
// ==========================================

@Component({
  selector: 'app-counter',
  standalone: true,
  template: `
    <div class="counter">
      <button (click)="decrement()">-</button>
      <span>{{ count() }}</span>
      <button (click)="increment()">+</button>
      
      <p>Double: {{ doubled() }}</p>
      
      @if (isEven()) {
        <span class="badge">Even</span>
      }
    </div>
  `
})
export class CounterComponent {
  // State
  count = signal(0);
  
  // Derived state
  doubled = computed(() => this.count() * 2);
  isEven = computed(() => this.count() % 2 === 0);
  
  // Methods
  increment() {
    this.count.update(n => n + 1);
  }
  
  decrement() {
    this.count.update(n => n - 1);
  }
  
  reset() {
    this.count.set(0);
  }
}
```

---

## 3) New Control Flow Syntax

### @if, @for, @switch
```typescript
@Component({
  selector: 'app-control-flow-demo',
  standalone: true,
  template: `
    <!-- ==========================================
         @if - Conditional rendering
         ========================================== -->
    
    @if (isLoggedIn()) {
      <nav>Welcome, {{ user()?.name }}</nav>
    } @else if (isLoading()) {
      <div class="loading">Loading...</div>
    } @else {
      <a routerLink="/login">Login</a>
    }
    
    
    <!-- ==========================================
         @for - List rendering (replaces *ngFor)
         ========================================== -->
    
    <ul>
      @for (item of items(); track item.id) {
        <li>
          {{ item.name }}
          <button (click)="removeItem(item.id)">Remove</button>
        </li>
      } @empty {
        <li class="empty">No items found</li>
      }
    </ul>
    
    <!-- With index and other context variables -->
    @for (item of items(); track item.id; let i = $index, first = $first, last = $last) {
      <div [class.first]="first" [class.last]="last">
        {{ i + 1 }}. {{ item.name }}
      </div>
    }
    
    
    <!-- ==========================================
         @switch - Switch statement
         ========================================== -->
    
    @switch (status()) {
      @case ('pending') {
        <span class="badge pending">Pending</span>
      }
      @case ('approved') {
        <span class="badge approved">Approved</span>
      }
      @case ('rejected') {
        <span class="badge rejected">Rejected</span>
      }
      @default {
        <span class="badge">Unknown</span>
      }
    }
    
    
    <!-- ==========================================
         @defer - Lazy loading content
         ========================================== -->
    
    @defer (on viewport) {
      <app-heavy-component />
    } @placeholder {
      <div class="placeholder">Loading component...</div>
    } @loading (minimum 500ms) {
      <div class="loading">
        <span class="spinner"></span>
      </div>
    } @error {
      <div class="error">Failed to load component</div>
    }
    
    <!-- Defer with different triggers -->
    @defer (on idle) {
      <app-analytics />
    }
    
    @defer (on interaction) {
      <app-comments />
    }
    
    @defer (when shouldLoad()) {
      <app-conditional-component />
    }
  `
})
export class ControlFlowDemoComponent {
  isLoggedIn = signal(false);
  isLoading = signal(false);
  user = signal<User | null>(null);
  items = signal<Item[]>([]);
  status = signal<'pending' | 'approved' | 'rejected'>('pending');
  shouldLoad = signal(false);
  
  removeItem(id: string) {
    this.items.update(items => items.filter(item => item.id !== id));
  }
}
```

---

## 4) RxJS & Signal Interoperability

### RxJS Fundamentals
```typescript
// ==========================================
// RXJS IN ANGULAR
// ==========================================

import { Component, inject, DestroyRef } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { 
  Observable, 
  Subject, 
  BehaviorSubject,
  catchError,
  map,
  switchMap,
  debounceTime,
  distinctUntilChanged,
  takeUntilDestroyed,
  of
} from 'rxjs';
import { toSignal, toObservable } from '@angular/core/rxjs-interop';

@Component({
  selector: 'app-search',
  standalone: true,
  imports: [AsyncPipe, ReactiveFormsModule],
  template: `
    <input [formControl]="searchControl" placeholder="Search..." />
    
    <!-- Using AsyncPipe -->
    @if (results$ | async; as results) {
      @for (result of results; track result.id) {
        <div>{{ result.name }}</div>
      }
    }
    
    <!-- Using Signal (converted from Observable) -->
    @for (result of resultsSignal(); track result.id) {
      <div>{{ result.name }}</div>
    }
  `
})
export class SearchComponent {
  private http = inject(HttpClient);
  private destroyRef = inject(DestroyRef);
  
  // Form control
  searchControl = new FormControl('');
  
  // ==========================================
  // OBSERVABLE STREAM
  // ==========================================
  results$ = this.searchControl.valueChanges.pipe(
    debounceTime(300),
    distinctUntilChanged(),
    switchMap(query => {
      if (!query || query.length < 2) {
        return of([]);
      }
      return this.http.get<SearchResult[]>(`/api/search?q=${query}`).pipe(
        catchError(() => of([]))
      );
    })
  );
  
  // ==========================================
  // CONVERT OBSERVABLE TO SIGNAL
  // ==========================================
  resultsSignal = toSignal(this.results$, { initialValue: [] });
  
  
  // ==========================================
  // CONVERT SIGNAL TO OBSERVABLE
  // ==========================================
  userId = signal('123');
  userId$ = toObservable(this.userId);
  
  // Use the observable
  userData$ = this.userId$.pipe(
    switchMap(id => this.http.get<User>(`/api/users/${id}`))
  );
  
  
  // ==========================================
  // SUBSCRIPTION MANAGEMENT
  // ==========================================
  constructor() {
    // Auto-cleanup with takeUntilDestroyed
    this.results$.pipe(
      takeUntilDestroyed(this.destroyRef)
    ).subscribe(results => {
      console.log('Results:', results);
    });
  }
}


// ==========================================
// SERVICE WITH RXJS
// ==========================================

@Injectable({ providedIn: 'root' })
export class DataService {
  private http = inject(HttpClient);
  
  // BehaviorSubject for stateful data
  private usersSubject = new BehaviorSubject<User[]>([]);
  users$ = this.usersSubject.asObservable();
  
  // Signal version
  users = toSignal(this.users$, { initialValue: [] });
  
  // Action subjects
  private refreshSubject = new Subject<void>();
  
  constructor() {
    // Auto-refresh when triggered
    this.refreshSubject.pipe(
      switchMap(() => this.fetchUsers())
    ).subscribe(users => {
      this.usersSubject.next(users);
    });
  }
  
  private fetchUsers(): Observable<User[]> {
    return this.http.get<User[]>('/api/users');
  }
  
  refresh() {
    this.refreshSubject.next();
  }
  
  addUser(user: Omit<User, 'id'>): Observable<User> {
    return this.http.post<User>('/api/users', user).pipe(
      tap(newUser => {
        this.usersSubject.next([...this.usersSubject.value, newUser]);
      })
    );
  }
}
```

---

## 5) Services & State Management

### Signal-based State Service
```typescript
// ==========================================
// STATE SERVICE PATTERN
// ==========================================

import { Injectable, signal, computed, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';

interface AppState {
  users: User[];
  selectedUserId: string | null;
  isLoading: boolean;
  error: string | null;
}

@Injectable({ providedIn: 'root' })
export class UserStateService {
  private http = inject(HttpClient);
  
  // ==========================================
  // PRIVATE STATE (Signals)
  // ==========================================
  private state = signal<AppState>({
    users: [],
    selectedUserId: null,
    isLoading: false,
    error: null,
  });
  
  // ==========================================
  // PUBLIC SELECTORS (Computed)
  // ==========================================
  users = computed(() => this.state().users);
  selectedUserId = computed(() => this.state().selectedUserId);
  isLoading = computed(() => this.state().isLoading);
  error = computed(() => this.state().error);
  
  selectedUser = computed(() => {
    const id = this.selectedUserId();
    return id ? this.users().find(u => u.id === id) : null;
  });
  
  userCount = computed(() => this.users().length);
  
  activeUsers = computed(() => 
    this.users().filter(u => u.isActive)
  );
  
  // ==========================================
  // ACTIONS
  // ==========================================
  async loadUsers() {
    this.updateState({ isLoading: true, error: null });
    
    try {
      const users = await firstValueFrom(
        this.http.get<User[]>('/api/users')
      );
      this.updateState({ users, isLoading: false });
    } catch (e) {
      this.updateState({ 
        error: e instanceof Error ? e.message : 'Failed to load users',
        isLoading: false 
      });
    }
  }
  
  selectUser(userId: string | null) {
    this.updateState({ selectedUserId: userId });
  }
  
  async addUser(userData: Omit<User, 'id'>) {
    const newUser = await firstValueFrom(
      this.http.post<User>('/api/users', userData)
    );
    
    this.updateState({
      users: [...this.users(), newUser]
    });
    
    return newUser;
  }
  
  async updateUser(id: string, updates: Partial<User>) {
    const updatedUser = await firstValueFrom(
      this.http.patch<User>(`/api/users/${id}`, updates)
    );
    
    this.updateState({
      users: this.users().map(u => 
        u.id === id ? updatedUser : u
      )
    });
    
    return updatedUser;
  }
  
  async deleteUser(id: string) {
    await firstValueFrom(
      this.http.delete(`/api/users/${id}`)
    );
    
    this.updateState({
      users: this.users().filter(u => u.id !== id),
      selectedUserId: this.selectedUserId() === id ? null : this.selectedUserId()
    });
  }
  
  // ==========================================
  // PRIVATE HELPERS
  // ==========================================
  private updateState(partial: Partial<AppState>) {
    this.state.update(current => ({
      ...current,
      ...partial
    }));
  }
}


// ==========================================
// USING THE STATE SERVICE
// ==========================================

@Component({
  selector: 'app-user-list',
  standalone: true,
  imports: [CommonModule],
  template: `
    @if (userState.isLoading()) {
      <div class="loading">Loading...</div>
    }
    
    @if (userState.error()) {
      <div class="error">{{ userState.error() }}</div>
    }
    
    <div class="stats">
      Total: {{ userState.userCount() }} | 
      Active: {{ userState.activeUsers().length }}
    </div>
    
    <ul>
      @for (user of userState.users(); track user.id) {
        <li 
          [class.selected]="user.id === userState.selectedUserId()"
          (click)="userState.selectUser(user.id)"
        >
          {{ user.name }}
        </li>
      }
    </ul>
    
    @if (userState.selectedUser(); as user) {
      <app-user-detail [user]="user" />
    }
  `
})
export class UserListComponent implements OnInit {
  userState = inject(UserStateService);
  
  ngOnInit() {
    this.userState.loadUsers();
  }
}
```

---

## 6) Routing

### Route Configuration
```typescript
// ==========================================
// app.routes.ts
// ==========================================

import { Routes } from '@angular/router';
import { inject } from '@angular/core';
import { AuthService } from '@/services/auth.service';

export const routes: Routes = [
  {
    path: '',
    pathMatch: 'full',
    redirectTo: 'home'
  },
  
  // Eager-loaded route
  {
    path: 'home',
    loadComponent: () => import('./pages/home/home.component')
      .then(m => m.HomeComponent),
    title: 'Home'
  },
  
  // Protected route with guard
  {
    path: 'dashboard',
    loadComponent: () => import('./pages/dashboard/dashboard.component')
      .then(m => m.DashboardComponent),
    canActivate: [() => inject(AuthService).isAuthenticated()],
    title: 'Dashboard'
  },
  
  // Nested routes
  {
    path: 'users',
    loadComponent: () => import('./pages/users/users-layout.component')
      .then(m => m.UsersLayoutComponent),
    canActivate: [authGuard],
    children: [
      {
        path: '',
        loadComponent: () => import('./pages/users/user-list.component')
          .then(m => m.UserListComponent),
        title: 'Users'
      },
      {
        path: ':id',
        loadComponent: () => import('./pages/users/user-detail.component')
          .then(m => m.UserDetailComponent),
        resolve: {
          user: userResolver
        },
        title: (route) => `User ${route.params['id']}`
      },
      {
        path: ':id/edit',
        loadComponent: () => import('./pages/users/user-edit.component')
          .then(m => m.UserEditComponent),
        canDeactivate: [unsavedChangesGuard]
      }
    ]
  },
  
  // Wildcard route
  {
    path: '**',
    loadComponent: () => import('./pages/not-found/not-found.component')
      .then(m => m.NotFoundComponent)
  }
];


// ==========================================
// GUARDS (Functional style)
// ==========================================

import { CanActivateFn, CanDeactivateFn, Router } from '@angular/router';

// Auth guard
export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);
  
  if (authService.isAuthenticated()) {
    return true;
  }
  
  return router.createUrlTree(['/login'], {
    queryParams: { returnUrl: state.url }
  });
};

// Role guard
export const roleGuard = (requiredRole: string): CanActivateFn => {
  return () => {
    const authService = inject(AuthService);
    return authService.hasRole(requiredRole);
  };
};

// Unsaved changes guard
export const unsavedChangesGuard: CanDeactivateFn<{ hasUnsavedChanges: () => boolean }> = 
  (component) => {
    if (component.hasUnsavedChanges()) {
      return confirm('You have unsaved changes. Leave anyway?');
    }
    return true;
  };


// ==========================================
// RESOLVERS
// ==========================================

import { ResolveFn } from '@angular/router';

export const userResolver: ResolveFn<User> = (route) => {
  const userService = inject(UserService);
  const id = route.params['id'];
  return userService.getUser(id);
};
```

### Using Router in Components
```typescript
// ==========================================
// ROUTER USAGE IN COMPONENTS
// ==========================================

import { Component, inject } from '@angular/core';
import { Router, RouterLink, RouterOutlet, ActivatedRoute } from '@angular/router';
import { toSignal } from '@angular/core/rxjs-interop';

@Component({
  selector: 'app-user-detail',
  standalone: true,
  imports: [RouterLink, RouterOutlet],
  template: `
    <nav>
      <a routerLink="/users" routerLinkActive="active">Back to List</a>
      <a [routerLink]="['/users', userId(), 'edit']">Edit</a>
    </nav>
    
    <h1>User {{ userId() }}</h1>
    
    @if (user(); as userData) {
      <div class="user-info">
        <p>Name: {{ userData.name }}</p>
        <p>Email: {{ userData.email }}</p>
      </div>
    }
    
    <!-- Nested router outlet -->
    <router-outlet />
  `
})
export class UserDetailComponent {
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  
  // Convert route params to signal
  userId = toSignal(
    this.route.params.pipe(map(p => p['id'])),
    { initialValue: '' }
  );
  
  // Get resolved data as signal
  user = toSignal(
    this.route.data.pipe(map(d => d['user'] as User)),
    { initialValue: null }
  );
  
  // Programmatic navigation
  goToEdit() {
    this.router.navigate(['edit'], { relativeTo: this.route });
  }
  
  goToUser(id: string) {
    this.router.navigate(['/users', id]);
  }
  
  goToUsers() {
    this.router.navigate(['/users'], {
      queryParams: { page: 1 },
      queryParamsHandling: 'merge'
    });
  }
}
```

---

## 7) Reactive Forms

### Form Patterns
```typescript
// ==========================================
// TYPED REACTIVE FORMS
// ==========================================

import { Component, inject } from '@angular/core';
import { 
  ReactiveFormsModule, 
  FormBuilder, 
  FormGroup,
  Validators,
  AbstractControl,
  ValidationErrors
} from '@angular/forms';

interface UserForm {
  name: string;
  email: string;
  password: string;
  confirmPassword: string;
  profile: {
    bio: string;
    website: string;
  };
  roles: string[];
}

@Component({
  selector: 'app-user-form',
  standalone: true,
  imports: [ReactiveFormsModule],
  template: `
    <form [formGroup]="form" (ngSubmit)="onSubmit()">
      <div class="field">
        <label for="name">Name</label>
        <input id="name" formControlName="name" />
        @if (form.controls.name.errors?.['required'] && form.controls.name.touched) {
          <span class="error">Name is required</span>
        }
      </div>
      
      <div class="field">
        <label for="email">Email</label>
        <input id="email" type="email" formControlName="email" />
        @if (form.controls.email.errors?.['email']) {
          <span class="error">Invalid email format</span>
        }
      </div>
      
      <div class="field">
        <label for="password">Password</label>
        <input id="password" type="password" formControlName="password" />
        @if (form.controls.password.errors?.['minlength']) {
          <span class="error">Password must be at least 8 characters</span>
        }
      </div>
      
      <div class="field">
        <label for="confirmPassword">Confirm Password</label>
        <input id="confirmPassword" type="password" formControlName="confirmPassword" />
        @if (form.errors?.['passwordMismatch']) {
          <span class="error">Passwords do not match</span>
        }
      </div>
      
      <!-- Nested form group -->
      <fieldset formGroupName="profile">
        <legend>Profile</legend>
        
        <div class="field">
          <label for="bio">Bio</label>
          <textarea id="bio" formControlName="bio"></textarea>
        </div>
        
        <div class="field">
          <label for="website">Website</label>
          <input id="website" formControlName="website" />
          @if (form.controls.profile.controls.website.errors?.['pattern']) {
            <span class="error">Invalid URL format</span>
          }
        </div>
      </fieldset>
      
      <button type="submit" [disabled]="form.invalid || isSubmitting()">
        @if (isSubmitting()) {
          Submitting...
        } @else {
          Submit
        }
      </button>
    </form>
  `
})
export class UserFormComponent {
  private fb = inject(FormBuilder);
  
  isSubmitting = signal(false);
  
  // ==========================================
  // TYPED FORM
  // ==========================================
  form = this.fb.nonNullable.group({
    name: ['', [Validators.required, Validators.minLength(2)]],
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(8)]],
    confirmPassword: ['', Validators.required],
    profile: this.fb.nonNullable.group({
      bio: ['', Validators.maxLength(500)],
      website: ['', Validators.pattern(/^https?:\/\/.+/)],
    }),
    roles: this.fb.nonNullable.array<string>([]),
  }, {
    validators: [passwordMatchValidator]
  });
  
  // ==========================================
  // METHODS
  // ==========================================
  onSubmit() {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    
    this.isSubmitting.set(true);
    
    const formValue = this.form.getRawValue();
    console.log('Form value:', formValue);
    
    // Submit logic...
  }
  
  reset() {
    this.form.reset();
  }
  
  patchForm(user: Partial<UserForm>) {
    this.form.patchValue(user);
  }
}


// ==========================================
// CUSTOM VALIDATORS
// ==========================================

function passwordMatchValidator(control: AbstractControl): ValidationErrors | null {
  const password = control.get('password');
  const confirmPassword = control.get('confirmPassword');
  
  if (password && confirmPassword && password.value !== confirmPassword.value) {
    return { passwordMismatch: true };
  }
  
  return null;
}

// Async validator
function uniqueEmailValidator(userService: UserService): AsyncValidatorFn {
  return (control: AbstractControl): Observable<ValidationErrors | null> => {
    return userService.checkEmailExists(control.value).pipe(
      map(exists => exists ? { emailTaken: true } : null),
      catchError(() => of(null))
    );
  };
}
```

---

## 8) Performance Optimization

### Change Detection & OnPush
```typescript
// ==========================================
// ONPUSH CHANGE DETECTION
// ==========================================

@Component({
  selector: 'app-optimized',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <!-- Signals automatically trigger change detection -->
    <p>Count: {{ count() }}</p>
    
    <!-- For observables, use async pipe -->
    <p>Data: {{ data$ | async }}</p>
  `
})
export class OptimizedComponent {
  count = signal(0);
  data$ = inject(DataService).data$;
  
  // With OnPush, component only updates when:
  // 1. Input reference changes
  // 2. Event handler fires in this component
  // 3. Observable with async pipe emits
  // 4. Signal value changes
  // 5. markForCheck() is called
}


// ==========================================
// PERFORMANCE CHECKLIST
// ==========================================

/*
┌─────────────────────────────────────────┐
│     ANGULAR PERFORMANCE CHECKLIST       │
├─────────────────────────────────────────┤
│                                         │
│  CHANGE DETECTION:                      │
│  □ Use OnPush strategy                 │
│  □ Use Signals instead of observables │
│  □ Avoid function calls in templates   │
│  □ Use trackBy with @for              │
│                                         │
│  LAZY LOADING:                          │
│  □ Lazy load routes                    │
│  □ Use @defer for heavy components    │
│  □ Lazy load images                    │
│                                         │
│  BUNDLE:                                │
│  □ Tree-shake unused code              │
│  □ Use production build               │
│  □ Analyze bundle size                 │
│                                         │
│  RENDERING:                             │
│  □ Virtual scrolling for long lists   │
│  □ Use pure pipes                      │
│  □ Avoid ngStyle/ngClass objects       │
│                                         │
└──────────────────────────────────────┘
*/
```

---

## Best Practices Summary

### Components
- [ ] Use standalone components
- [ ] Use OnPush change detection
- [ ] Use signal-based inputs/outputs
- [ ] Extract logic to services

### State
- [ ] Use Signals for local state
- [ ] Signal-based state services
- [ ] Computed for derived state
- [ ] Effects for side effects

### Templates
- [ ] Use new control flow (@if, @for)
- [ ] Use @defer for lazy loading
- [ ] Track items in @for loops
- [ ] Avoid function calls in templates

### RxJS
- [ ] Use toSignal/toObservable
- [ ] Use AsyncPipe
- [ ] Use takeUntilDestroyed
- [ ] Prefer Signals when possible

---

**References:**
- [Angular Documentation](https://angular.dev/)
- [Angular Signals](https://angular.dev/guide/signals)
- [Angular Control Flow](https://angular.dev/guide/templates/control-flow)
- [Angular Style Guide](https://angular.dev/style-guide)

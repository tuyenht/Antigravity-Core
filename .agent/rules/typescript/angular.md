# Angular TypeScript Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **Angular:** 17+  
> **TypeScript:** 5.x  
> **Priority:** P0 - Load for Angular projects

---

You are an expert in Angular development with TypeScript.

## Core Principles

- Use strict TypeScript configuration
- Leverage Angular's dependency injection with types
- Type all services, components, and modules
- Use RxJS with proper TypeScript types

---

## 1) Project Setup

### TypeScript Configuration
```json
// ==========================================
// tsconfig.json
// ==========================================

{
  "compileOnSave": false,
  "compilerOptions": {
    "outDir": "./dist/out-tsc",
    "forceConsistentCasingInFileNames": true,
    "strict": true,
    "noImplicitOverride": true,
    "noPropertyAccessFromIndexSignature": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "sourceMap": true,
    "declaration": false,
    "experimentalDecorators": true,
    "moduleResolution": "bundler",
    "importHelpers": true,
    "target": "ES2022",
    "module": "ES2022",
    "useDefineForClassFields": false,
    "lib": ["ES2022", "dom"],
    "baseUrl": "./",
    "paths": {
      "@app/*": ["src/app/*"],
      "@core/*": ["src/app/core/*"],
      "@shared/*": ["src/app/shared/*"],
      "@features/*": ["src/app/features/*"],
      "@env/*": ["src/environments/*"]
    }
  },
  "angularCompilerOptions": {
    "enableI18nLegacyMessageIdFormat": false,
    "strictInjectionParameters": true,
    "strictInputAccessModifiers": true,
    "strictTemplates": true
  }
}
```

### Project Structure
```
src/
├── app/
│   ├── core/                    # Singleton services
│   │   ├── guards/
│   │   ├── interceptors/
│   │   ├── services/
│   │   └── core.module.ts
│   ├── shared/                  # Shared components
│   │   ├── components/
│   │   ├── directives/
│   │   ├── pipes/
│   │   └── shared.module.ts
│   ├── features/                # Feature modules
│   │   ├── users/
│   │   ├── products/
│   │   └── dashboard/
│   ├── models/                  # Data models
│   ├── store/                   # NgRx store
│   ├── app.component.ts
│   ├── app.config.ts
│   └── app.routes.ts
├── assets/
└── environments/
```

---

## 2) Components

### Typed Component
```typescript
// ==========================================
// features/users/components/user-card.component.ts
// ==========================================

import {
  Component,
  Input,
  Output,
  EventEmitter,
  OnInit,
  OnDestroy,
  ChangeDetectionStrategy,
  inject,
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { User } from '@app/models/user.model';

@Component({
  selector: 'app-user-card',
  standalone: true,
  imports: [CommonModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="user-card" [class.active]="isActive">
      <img [src]="user.avatar || defaultAvatar" [alt]="user.name" />
      <div class="info">
        <h3>{{ user.name }}</h3>
        <p>{{ user.email }}</p>
      </div>
      <div class="actions">
        <button (click)="onEdit()">Edit</button>
        <button (click)="onDelete()">Delete</button>
      </div>
    </div>
  `,
  styles: [`
    .user-card {
      display: flex;
      padding: 1rem;
      border: 1px solid #e0e0e0;
      border-radius: 8px;
    }
    .user-card.active {
      border-color: #007bff;
    }
  `],
})
export class UserCardComponent implements OnInit, OnDestroy {
  // ==========================================
  // INPUTS
  // ==========================================
  
  @Input({ required: true }) user!: User;
  @Input() isActive = false;
  @Input() defaultAvatar = '/assets/default-avatar.png';

  // ==========================================
  // OUTPUTS
  // ==========================================
  
  @Output() edit = new EventEmitter<User>();
  @Output() delete = new EventEmitter<string>();

  // ==========================================
  // LIFECYCLE
  // ==========================================

  ngOnInit(): void {
    console.log('UserCard initialized for:', this.user.name);
  }

  ngOnDestroy(): void {
    console.log('UserCard destroyed');
  }

  // ==========================================
  // METHODS
  // ==========================================

  onEdit(): void {
    this.edit.emit(this.user);
  }

  onDelete(): void {
    this.delete.emit(this.user.id);
  }
}


// ==========================================
// Typed Model
// ==========================================

// models/user.model.ts
export interface User {
  id: string;
  email: string;
  name: string;
  avatar?: string;
  role: UserRole;
  createdAt: Date;
  updatedAt: Date;
}

export enum UserRole {
  ADMIN = 'admin',
  USER = 'user',
  MODERATOR = 'moderator',
}

export interface CreateUserDto {
  email: string;
  name: string;
  password: string;
  role?: UserRole;
}

export interface UpdateUserDto extends Partial<Omit<CreateUserDto, 'password'>> {}
```

### ViewChild and ContentChild
```typescript
// ==========================================
// TYPED VIEWCHILD / CONTENTCHILD
// ==========================================

import {
  Component,
  ViewChild,
  ContentChild,
  ElementRef,
  AfterViewInit,
  AfterContentInit,
  TemplateRef,
} from '@angular/core';

@Component({
  selector: 'app-modal',
  standalone: true,
  template: `
    <div class="modal-backdrop" #backdrop>
      <div class="modal-content" #content>
        <ng-content select="[modal-header]"></ng-content>
        <ng-content></ng-content>
        <ng-content select="[modal-footer]"></ng-content>
      </div>
    </div>
  `,
})
export class ModalComponent implements AfterViewInit, AfterContentInit {
  // Typed ViewChild
  @ViewChild('backdrop') backdropRef!: ElementRef<HTMLDivElement>;
  @ViewChild('content', { static: true }) contentRef!: ElementRef<HTMLDivElement>;
  
  // Component reference
  @ViewChild(UserCardComponent) userCard?: UserCardComponent;
  
  // ContentChild
  @ContentChild('headerTemplate') headerTemplate?: TemplateRef<unknown>;
  @ContentChild(SomeDirective) directive?: SomeDirective;

  ngAfterViewInit(): void {
    // Access DOM element with proper typing
    const backdrop = this.backdropRef.nativeElement;
    backdrop.style.opacity = '1';
  }

  ngAfterContentInit(): void {
    if (this.headerTemplate) {
      // Handle template
    }
  }
}
```

---

## 3) Services and Dependency Injection

### Typed Service
```typescript
// ==========================================
// core/services/users.service.ts
// ==========================================

import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, BehaviorSubject, catchError, map, tap } from 'rxjs';
import { User, CreateUserDto, UpdateUserDto } from '@app/models/user.model';
import { environment } from '@env/environment';

export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}

export interface UsersQueryParams {
  page?: number;
  limit?: number;
  search?: string;
  sortBy?: keyof User;
  sortOrder?: 'asc' | 'desc';
}

@Injectable({
  providedIn: 'root',
})
export class UsersService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = `${environment.apiUrl}/users`;

  // State management with BehaviorSubject
  private readonly usersSubject = new BehaviorSubject<User[]>([]);
  readonly users$ = this.usersSubject.asObservable();

  private readonly loadingSubject = new BehaviorSubject<boolean>(false);
  readonly loading$ = this.loadingSubject.asObservable();

  // ==========================================
  // CRUD OPERATIONS
  // ==========================================

  getAll(params?: UsersQueryParams): Observable<PaginatedResponse<User>> {
    let httpParams = new HttpParams();

    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined) {
          httpParams = httpParams.set(key, String(value));
        }
      });
    }

    this.loadingSubject.next(true);

    return this.http
      .get<PaginatedResponse<User>>(this.apiUrl, { params: httpParams })
      .pipe(
        tap((response) => {
          this.usersSubject.next(response.data);
          this.loadingSubject.next(false);
        }),
        catchError((error) => {
          this.loadingSubject.next(false);
          throw error;
        })
      );
  }

  getById(id: string): Observable<User> {
    return this.http.get<User>(`${this.apiUrl}/${id}`);
  }

  create(dto: CreateUserDto): Observable<User> {
    return this.http.post<User>(this.apiUrl, dto).pipe(
      tap((user) => {
        const current = this.usersSubject.getValue();
        this.usersSubject.next([...current, user]);
      })
    );
  }

  update(id: string, dto: UpdateUserDto): Observable<User> {
    return this.http.put<User>(`${this.apiUrl}/${id}`, dto).pipe(
      tap((updated) => {
        const current = this.usersSubject.getValue();
        const index = current.findIndex((u) => u.id === id);
        if (index > -1) {
          current[index] = updated;
          this.usersSubject.next([...current]);
        }
      })
    );
  }

  delete(id: string): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`).pipe(
      tap(() => {
        const current = this.usersSubject.getValue();
        this.usersSubject.next(current.filter((u) => u.id !== id));
      })
    );
  }
}


// ==========================================
// INJECTION TOKEN
// ==========================================

import { InjectionToken } from '@angular/core';

export interface AppConfig {
  apiUrl: string;
  production: boolean;
  features: {
    darkMode: boolean;
    analytics: boolean;
  };
}

export const APP_CONFIG = new InjectionToken<AppConfig>('app.config');

// Provider
export const appConfigProvider = {
  provide: APP_CONFIG,
  useValue: {
    apiUrl: environment.apiUrl,
    production: environment.production,
    features: {
      darkMode: true,
      analytics: true,
    },
  } satisfies AppConfig,
};

// Usage
@Component({...})
export class SomeComponent {
  private readonly config = inject(APP_CONFIG);
}
```

---

## 4) RxJS and Observables

### Typed RxJS Patterns
```typescript
// ==========================================
// TYPED RXJS OPERATORS
// ==========================================

import { Component, OnInit, OnDestroy, inject } from '@angular/core';
import {
  Observable,
  Subject,
  BehaviorSubject,
  combineLatest,
  forkJoin,
  of,
  timer,
} from 'rxjs';
import {
  map,
  filter,
  switchMap,
  debounceTime,
  distinctUntilChanged,
  takeUntil,
  catchError,
  retry,
  shareReplay,
} from 'rxjs/operators';

interface SearchResult {
  id: string;
  title: string;
  description: string;
}

@Component({
  selector: 'app-search',
  template: `
    <input 
      type="text" 
      [formControl]="searchControl" 
      placeholder="Search..."
    />
    
    <div *ngIf="loading$ | async">Loading...</div>
    
    <div *ngFor="let result of results$ | async">
      {{ result.title }}
    </div>
  `,
})
export class SearchComponent implements OnInit, OnDestroy {
  private readonly searchService = inject(SearchService);
  private readonly destroy$ = new Subject<void>();

  searchControl = new FormControl<string>('', { nonNullable: true });

  // Typed observables
  private readonly searchSubject = new BehaviorSubject<string>('');
  readonly loading$ = new BehaviorSubject<boolean>(false);

  // Typed stream with operators
  readonly results$: Observable<SearchResult[]> = this.searchSubject.pipe(
    debounceTime(300),
    distinctUntilChanged(),
    filter((query): query is string => query.length >= 2),
    switchMap((query) => {
      this.loading$.next(true);
      return this.searchService.search(query).pipe(
        catchError(() => of([])),
        tap(() => this.loading$.next(false))
      );
    }),
    shareReplay({ bufferSize: 1, refCount: true }),
    takeUntil(this.destroy$)
  );

  ngOnInit(): void {
    // Subscribe to form control
    this.searchControl.valueChanges
      .pipe(takeUntil(this.destroy$))
      .subscribe((value) => {
        this.searchSubject.next(value);
      });
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }
}


// ==========================================
// COMBINELAST / FORKJOIN
// ==========================================

interface DashboardData {
  users: User[];
  stats: Stats;
  notifications: Notification[];
}

@Component({...})
export class DashboardComponent implements OnInit {
  private readonly usersService = inject(UsersService);
  private readonly statsService = inject(StatsService);
  private readonly notificationsService = inject(NotificationsService);

  // Typed combineLatest
  readonly dashboardData$: Observable<DashboardData> = combineLatest({
    users: this.usersService.users$,
    stats: this.statsService.stats$,
    notifications: this.notificationsService.notifications$,
  });

  // Alternative with forkJoin (completes after all emit once)
  loadDashboard(): Observable<DashboardData> {
    return forkJoin({
      users: this.usersService.getAll().pipe(map(r => r.data)),
      stats: this.statsService.getStats(),
      notifications: this.notificationsService.getRecent(),
    });
  }

  // Typed map
  readonly userNames$: Observable<string[]> = this.usersService.users$.pipe(
    map((users: User[]) => users.map((u) => u.name))
  );

  // Typed filter
  readonly activeUsers$: Observable<User[]> = this.usersService.users$.pipe(
    map((users) => users.filter((u) => u.role !== UserRole.ADMIN))
  );
}
```

---

## 5) Typed Reactive Forms

### FormControl and FormGroup
```typescript
// ==========================================
// TYPED REACTIVE FORMS (Angular 14+)
// ==========================================

import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  ReactiveFormsModule,
  FormBuilder,
  FormGroup,
  FormControl,
  Validators,
  AbstractControl,
  ValidationErrors,
} from '@angular/forms';

// Form value interface
interface UserFormValue {
  name: string;
  email: string;
  password: string;
  confirmPassword: string;
  profile: {
    bio: string;
    website: string;
  };
  preferences: {
    newsletter: boolean;
    notifications: boolean;
  };
}

// Form type
type UserForm = FormGroup<{
  name: FormControl<string>;
  email: FormControl<string>;
  password: FormControl<string>;
  confirmPassword: FormControl<string>;
  profile: FormGroup<{
    bio: FormControl<string>;
    website: FormControl<string>;
  }>;
  preferences: FormGroup<{
    newsletter: FormControl<boolean>;
    notifications: FormControl<boolean>;
  }>;
}>;

@Component({
  selector: 'app-user-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <form [formGroup]="form" (ngSubmit)="onSubmit()">
      <div class="form-group">
        <label for="name">Name</label>
        <input id="name" formControlName="name" />
        <span *ngIf="form.controls.name.errors?.['required']">
          Name is required
        </span>
      </div>

      <div class="form-group">
        <label for="email">Email</label>
        <input id="email" type="email" formControlName="email" />
        <span *ngIf="form.controls.email.errors?.['email']">
          Invalid email format
        </span>
      </div>

      <div formGroupName="profile">
        <div class="form-group">
          <label for="bio">Bio</label>
          <textarea id="bio" formControlName="bio"></textarea>
        </div>
      </div>

      <div formGroupName="preferences">
        <label>
          <input type="checkbox" formControlName="newsletter" />
          Subscribe to newsletter
        </label>
      </div>

      <button type="submit" [disabled]="form.invalid">
        Submit
      </button>
    </form>
  `,
})
export class UserFormComponent {
  private readonly fb = inject(FormBuilder);

  // Typed form
  readonly form: UserForm = this.fb.group({
    name: this.fb.nonNullable.control('', [
      Validators.required,
      Validators.minLength(2),
    ]),
    email: this.fb.nonNullable.control('', [
      Validators.required,
      Validators.email,
    ]),
    password: this.fb.nonNullable.control('', [
      Validators.required,
      Validators.minLength(8),
      this.passwordStrengthValidator,
    ]),
    confirmPassword: this.fb.nonNullable.control('', [Validators.required]),
    profile: this.fb.group({
      bio: this.fb.nonNullable.control(''),
      website: this.fb.nonNullable.control(''),
    }),
    preferences: this.fb.group({
      newsletter: this.fb.nonNullable.control(false),
      notifications: this.fb.nonNullable.control(true),
    }),
  }, {
    validators: this.passwordMatchValidator,
  });

  // Typed custom validator
  private passwordStrengthValidator(
    control: AbstractControl<string>
  ): ValidationErrors | null {
    const value = control.value;
    const hasUpperCase = /[A-Z]/.test(value);
    const hasLowerCase = /[a-z]/.test(value);
    const hasNumber = /\d/.test(value);

    if (hasUpperCase && hasLowerCase && hasNumber) {
      return null;
    }

    return { passwordStrength: true };
  }

  // Group validator
  private passwordMatchValidator(
    group: AbstractControl
  ): ValidationErrors | null {
    const password = group.get('password')?.value;
    const confirmPassword = group.get('confirmPassword')?.value;

    return password === confirmPassword ? null : { passwordMismatch: true };
  }

  onSubmit(): void {
    if (this.form.valid) {
      // Fully typed value
      const value: UserFormValue = this.form.getRawValue();
      console.log(value.name);  // string
      console.log(value.profile.bio);  // string
    }
  }
}
```

---

## 6) Routing

### Typed Router
```typescript
// ==========================================
// app.routes.ts
// ==========================================

import { Routes } from '@angular/router';
import { authGuard } from '@core/guards/auth.guard';
import { roleGuard } from '@core/guards/role.guard';
import { userResolver } from '@core/resolvers/user.resolver';

export const routes: Routes = [
  {
    path: '',
    redirectTo: 'dashboard',
    pathMatch: 'full',
  },
  {
    path: 'auth',
    loadChildren: () =>
      import('./features/auth/auth.routes').then((m) => m.AUTH_ROUTES),
  },
  {
    path: 'dashboard',
    loadComponent: () =>
      import('./features/dashboard/dashboard.component').then(
        (m) => m.DashboardComponent
      ),
    canActivate: [authGuard],
  },
  {
    path: 'users',
    loadChildren: () =>
      import('./features/users/users.routes').then((m) => m.USERS_ROUTES),
    canActivate: [authGuard],
    data: { roles: ['admin'] },
  },
  {
    path: 'users/:id',
    loadComponent: () =>
      import('./features/users/user-detail.component').then(
        (m) => m.UserDetailComponent
      ),
    canActivate: [authGuard],
    resolve: {
      user: userResolver,
    },
  },
  {
    path: '**',
    loadComponent: () =>
      import('./features/not-found/not-found.component').then(
        (m) => m.NotFoundComponent
      ),
  },
];


// ==========================================
// TYPED GUARDS
// ==========================================

// core/guards/auth.guard.ts
import { inject } from '@angular/core';
import { Router, CanActivateFn, UrlTree } from '@angular/router';
import { AuthService } from '@core/services/auth.service';
import { map, Observable } from 'rxjs';

export const authGuard: CanActivateFn = (
  route,
  state
): Observable<boolean | UrlTree> => {
  const authService = inject(AuthService);
  const router = inject(Router);

  return authService.isAuthenticated$.pipe(
    map((isAuthenticated) => {
      if (isAuthenticated) {
        return true;
      }
      return router.createUrlTree(['/auth/login'], {
        queryParams: { returnUrl: state.url },
      });
    })
  );
};


// core/guards/role.guard.ts
import { inject } from '@angular/core';
import { CanActivateFn } from '@angular/router';
import { AuthService } from '@core/services/auth.service';
import { map } from 'rxjs';

export const roleGuard: CanActivateFn = (route) => {
  const authService = inject(AuthService);
  const requiredRoles = route.data['roles'] as string[];

  return authService.currentUser$.pipe(
    map((user) => {
      if (!user) return false;
      return requiredRoles.includes(user.role);
    })
  );
};


// ==========================================
// TYPED RESOLVER
// ==========================================

// core/resolvers/user.resolver.ts
import { inject } from '@angular/core';
import { ResolveFn } from '@angular/router';
import { UsersService } from '@core/services/users.service';
import { User } from '@app/models/user.model';

export const userResolver: ResolveFn<User> = (route) => {
  const usersService = inject(UsersService);
  const userId = route.paramMap.get('id');

  if (!userId) {
    throw new Error('User ID is required');
  }

  return usersService.getById(userId);
};


// ==========================================
// ACCESSING ROUTE DATA
// ==========================================

import { Component, inject } from '@angular/core';
import { ActivatedRoute, Router, ParamMap } from '@angular/router';
import { map, switchMap } from 'rxjs/operators';

@Component({...})
export class UserDetailComponent {
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly usersService = inject(UsersService);

  // Resolved data
  readonly user$ = this.route.data.pipe(
    map((data) => data['user'] as User)
  );

  // Route params
  readonly userId$ = this.route.paramMap.pipe(
    map((params: ParamMap) => params.get('id'))
  );

  // Query params
  readonly tab$ = this.route.queryParamMap.pipe(
    map((params) => params.get('tab') ?? 'overview')
  );

  // Navigate with typed params
  navigateToUser(id: string): void {
    this.router.navigate(['/users', id], {
      queryParams: { tab: 'profile' },
    });
  }
}
```

---

## 7) Signals (Angular 17+)

### Typed Signals
```typescript
// ==========================================
// SIGNALS BASICS
// ==========================================

import {
  Component,
  signal,
  computed,
  effect,
  input,
  output,
  model,
  untracked,
} from '@angular/core';

interface Todo {
  id: string;
  title: string;
  completed: boolean;
}

@Component({
  selector: 'app-todo-list',
  standalone: true,
  template: `
    <h2>Todos ({{ completedCount() }}/{{ todos().length }})</h2>
    
    <input 
      [value]="filter()" 
      (input)="filter.set($any($event.target).value)"
      placeholder="Filter..."
    />
    
    <ul>
      @for (todo of filteredTodos(); track todo.id) {
        <li [class.completed]="todo.completed">
          <input 
            type="checkbox" 
            [checked]="todo.completed"
            (change)="toggleTodo(todo.id)"
          />
          {{ todo.title }}
        </li>
      }
    </ul>
    
    <button (click)="addTodo()">Add Todo</button>
  `,
})
export class TodoListComponent {
  // ==========================================
  // SIGNAL INPUTS (Angular 17.1+)
  // ==========================================
  
  readonly title = input<string>('My Todos');
  readonly initialTodos = input<Todo[]>([]);
  readonly required = input.required<string>();  // Required input

  // ==========================================
  // SIGNAL OUTPUTS
  // ==========================================
  
  readonly todoAdded = output<Todo>();
  readonly todoToggled = output<{ id: string; completed: boolean }>();

  // ==========================================
  // TWO-WAY BINDING (model)
  // ==========================================
  
  readonly selectedId = model<string | null>(null);

  // ==========================================
  // WRITABLE SIGNALS
  // ==========================================

  readonly todos = signal<Todo[]>([
    { id: '1', title: 'Learn Angular', completed: false },
    { id: '2', title: 'Build app', completed: false },
  ]);

  readonly filter = signal<string>('');
  readonly loading = signal<boolean>(false);

  // ==========================================
  // COMPUTED SIGNALS
  // ==========================================

  readonly filteredTodos = computed<Todo[]>(() => {
    const filterValue = this.filter().toLowerCase();
    return this.todos().filter((todo) =>
      todo.title.toLowerCase().includes(filterValue)
    );
  });

  readonly completedCount = computed<number>(() =>
    this.todos().filter((todo) => todo.completed).length
  );

  readonly stats = computed(() => ({
    total: this.todos().length,
    completed: this.completedCount(),
    pending: this.todos().length - this.completedCount(),
  }));

  // ==========================================
  // EFFECTS
  // ==========================================

  constructor() {
    // Effect runs when signals change
    effect(() => {
      const todos = this.todos();
      console.log('Todos changed:', todos.length);

      // Use untracked to read without tracking
      const filter = untracked(() => this.filter());
      console.log('Current filter (untracked):', filter);
    });

    // Effect with cleanup
    effect((onCleanup) => {
      const interval = setInterval(() => {
        console.log('Checking todos...');
      }, 5000);

      onCleanup(() => {
        clearInterval(interval);
      });
    });
  }

  // ==========================================
  // SIGNAL MUTATIONS
  // ==========================================

  addTodo(): void {
    const newTodo: Todo = {
      id: crypto.randomUUID(),
      title: `Todo ${this.todos().length + 1}`,
      completed: false,
    };

    // Update signal
    this.todos.update((todos) => [...todos, newTodo]);
    
    // Emit output
    this.todoAdded.emit(newTodo);
  }

  toggleTodo(id: string): void {
    this.todos.update((todos) =>
      todos.map((todo) =>
        todo.id === id ? { ...todo, completed: !todo.completed } : todo
      )
    );

    const todo = this.todos().find((t) => t.id === id);
    if (todo) {
      this.todoToggled.emit({ id, completed: todo.completed });
    }
  }

  removeTodo(id: string): void {
    this.todos.update((todos) => todos.filter((todo) => todo.id !== id));
  }

  // Set entire value
  resetTodos(): void {
    this.todos.set([]);
  }
}
```

### Signal-based State
```typescript
// ==========================================
// SIGNAL STORE PATTERN
// ==========================================

import { Injectable, signal, computed } from '@angular/core';

interface AppState {
  user: User | null;
  theme: 'light' | 'dark';
  notifications: Notification[];
}

@Injectable({
  providedIn: 'root',
})
export class AppStore {
  // Private state
  private readonly state = signal<AppState>({
    user: null,
    theme: 'light',
    notifications: [],
  });

  // Public selectors
  readonly user = computed(() => this.state().user);
  readonly theme = computed(() => this.state().theme);
  readonly notifications = computed(() => this.state().notifications);
  readonly isAuthenticated = computed(() => !!this.state().user);
  readonly unreadCount = computed(
    () => this.state().notifications.filter((n) => !n.read).length
  );

  // Actions
  setUser(user: User | null): void {
    this.state.update((state) => ({ ...state, user }));
  }

  toggleTheme(): void {
    this.state.update((state) => ({
      ...state,
      theme: state.theme === 'light' ? 'dark' : 'light',
    }));
  }

  addNotification(notification: Notification): void {
    this.state.update((state) => ({
      ...state,
      notifications: [...state.notifications, notification],
    }));
  }

  markAsRead(id: string): void {
    this.state.update((state) => ({
      ...state,
      notifications: state.notifications.map((n) =>
        n.id === id ? { ...n, read: true } : n
      ),
    }));
  }
}
```

---

## 8) HTTP Interceptors

### Typed Interceptor
```typescript
// ==========================================
// FUNCTIONAL INTERCEPTOR (Angular 17+)
// ==========================================

import { HttpInterceptorFn, HttpErrorResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, throwError } from 'rxjs';
import { AuthService } from '@core/services/auth.service';

// Auth interceptor
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const authService = inject(AuthService);
  const token = authService.getToken();

  if (token) {
    const clonedReq = req.clone({
      setHeaders: {
        Authorization: `Bearer ${token}`,
      },
    });
    return next(clonedReq);
  }

  return next(req);
};

// Error interceptor
export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  return next(req).pipe(
    catchError((error: HttpErrorResponse) => {
      let errorMessage = 'An error occurred';

      if (error.error instanceof ErrorEvent) {
        // Client-side error
        errorMessage = error.error.message;
      } else {
        // Server-side error
        switch (error.status) {
          case 401:
            errorMessage = 'Unauthorized';
            break;
          case 403:
            errorMessage = 'Forbidden';
            break;
          case 404:
            errorMessage = 'Not found';
            break;
          case 500:
            errorMessage = 'Server error';
            break;
        }
      }

      return throwError(() => new Error(errorMessage));
    })
  );
};

// Logging interceptor
export const loggingInterceptor: HttpInterceptorFn = (req, next) => {
  const started = Date.now();

  return next(req).pipe(
    tap({
      next: () => {
        const elapsed = Date.now() - started;
        console.log(`${req.method} ${req.urlWithParams} took ${elapsed}ms`);
      },
      error: (error) => {
        console.error(`${req.method} ${req.urlWithParams} failed`, error);
      },
    })
  );
};


// ==========================================
// APP CONFIG WITH INTERCEPTORS
// ==========================================

import { ApplicationConfig } from '@angular/core';
import { provideHttpClient, withInterceptors } from '@angular/common/http';

export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(
      withInterceptors([
        authInterceptor,
        errorInterceptor,
        loggingInterceptor,
      ])
    ),
  ],
};
```

---

## 9) Testing

### Component Testing
```typescript
// ==========================================
// user-card.component.spec.ts
// ==========================================

import { ComponentFixture, TestBed } from '@angular/core/testing';
import { UserCardComponent } from './user-card.component';
import { User, UserRole } from '@app/models/user.model';

describe('UserCardComponent', () => {
  let component: UserCardComponent;
  let fixture: ComponentFixture<UserCardComponent>;

  const mockUser: User = {
    id: '1',
    name: 'John Doe',
    email: 'john@example.com',
    role: UserRole.USER,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [UserCardComponent],
    }).compileComponents();

    fixture = TestBed.createComponent(UserCardComponent);
    component = fixture.componentInstance;
    component.user = mockUser;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should display user name', () => {
    const compiled = fixture.nativeElement as HTMLElement;
    expect(compiled.querySelector('h3')?.textContent).toContain('John Doe');
  });

  it('should emit edit event', () => {
    const editSpy = jest.spyOn(component.edit, 'emit');

    component.onEdit();

    expect(editSpy).toHaveBeenCalledWith(mockUser);
  });

  it('should emit delete event with user id', () => {
    const deleteSpy = jest.spyOn(component.delete, 'emit');

    component.onDelete();

    expect(deleteSpy).toHaveBeenCalledWith('1');
  });
});


// ==========================================
// SERVICE TESTING
// ==========================================

import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { UsersService } from './users.service';

describe('UsersService', () => {
  let service: UsersService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [UsersService],
    });

    service = TestBed.inject(UsersService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpMock.verify();
  });

  it('should fetch users', () => {
    const mockResponse = {
      data: [{ id: '1', name: 'Test' }],
      meta: { total: 1, page: 1, limit: 10, totalPages: 1 },
    };

    service.getAll().subscribe((response) => {
      expect(response.data.length).toBe(1);
      expect(response.data[0].name).toBe('Test');
    });

    const req = httpMock.expectOne('/api/users');
    expect(req.request.method).toBe('GET');
    req.flush(mockResponse);
  });
});
```

---

## Best Practices Checklist

### Components
- [ ] Use standalone components
- [ ] Type all inputs/outputs
- [ ] Use signal inputs (17.1+)
- [ ] OnPush change detection

### Services
- [ ] providedIn: 'root'
- [ ] Typed methods
- [ ] Proper error handling

### RxJS
- [ ] Type all observables
- [ ] takeUntil for cleanup
- [ ] shareReplay when needed

### Forms
- [ ] Typed FormControl<T>
- [ ] Typed FormGroup
- [ ] Custom validators typed

### Routing
- [ ] Typed guards
- [ ] Typed resolvers
- [ ] Lazy loading

---

**References:**
- [Angular TypeScript](https://angular.dev/guide/typescript-configuration)
- [Angular Signals](https://angular.dev/guide/signals)
- [Typed Forms](https://angular.dev/guide/forms/typed-forms)

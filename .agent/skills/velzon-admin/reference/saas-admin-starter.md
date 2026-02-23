# SaaS Admin Starter Kit — Master Blueprint

> Single source of truth for generating complete admin systems with Auth + RBAC.
> All auth screens follow the **BaoSon glassmorphism design** in [auth-login-template.md](auth-login-template.md).
> Admin layout follows **Velzon** patterns in framework-specific pattern files.

---

## 0. Deployment Mode (MUST DETECT FIRST)

> [!CAUTION]
> **Every admin generation MUST start by determining the deployment mode.**
> This affects roles, permissions, database schema, tenant resolution, and sidebar menu.

### Mode Detection

```
1. Check .env or config for MODE=saas | MODE=standalone
2. If not found → ASK USER:
   "Dùng chế độ nào?
    (1) SaaS — Multi-tenant, nhiều site, central admin
    (2) Standalone — Single tenant, admin đơn giản"
```

### Mode Comparison

| Aspect | `MODE=saas` | `MODE=standalone` |
|--------|-------------|-------------------|
| **Tenancy** | Multi-tenant, multi-site | Single tenant, locked by `TENANT_ID` |
| **Domain** | Domain → Site → Tenant resolution | Single domain |
| **Roles** | 7 roles (saas* + site*) | 5 roles (site* only, no saas*) |
| **Database** | Tenants + Sites tables, scoped queries | No tenant tables |
| **Uploads** | CDN/S3 per-tenant bucket | Local `uploads/` directory |
| **Admin** | Central Velzon Admin (platform control plane) | Velzon Admin (single-site) |
| **Billing** | Stripe per-tenant | Optional / not included |
| **Infrastructure** | Shared infrastructure | Self-hosted |

---

## 1. Module Architecture

```
┌─────────────────────────────────────────────────────────────┐
│           SaaS Admin Starter Kit (MODE-aware)                │
├──────────────────────┬──────────────────────────────────────┤
│  AUTH MODULE         │  RBAC MODULE                          │
│  ├── Login           │  ├── Roles (CRUD)                     │
│  ├── Forgot Password │  ├── Permissions (matrix)             │
│  ├── Reset Password  │  ├── Role Assignment                  │
│  ├── Two-Factor Auth │  ├── Permission Guards                │
│  └── Logout          │  └── [SaaS] Tenant Scope Filter       │
├──────────────────────┼──────────────────────────────────────┤
│  USER MANAGEMENT     │  ADMIN LAYOUT                         │
│  ├── User List       │  ├── Sidebar (perm-filtered)          │
│  ├── Create User     │  ├── Header (profile/notif)           │
│  ├── Edit User/Role  │  ├── Breadcrumb                       │
│  ├── Delete User     │  └── Footer                           │
│  ├── User Invite ★   │                                       │
│  └── User Profile    │                                       │
├──────────────────────┼──────────────────────────────────────┤
│  DASHBOARD           │  SHARED                               │
│  ├── Welcome card    │  ├── i18n (all keys)                   │
│  ├── Stats widgets   │  ├── Toast notifications               │
│  └── Activity log ★  │  ├── Error pages (403/404/500)        │
│                      │  └── Audit trail ★                    │
├──────────────────────┴──────────────────────────────────────┤
│  [SaaS ONLY] TENANT MODULE                                   │
│  ├── Site List + CRUD                                        │
│  ├── Tenant Settings                                         │
│  ├── Domain Management                                       │
│  └── Feature Flags (per-site)                                │
└─────────────────────────────────────────────────────────────┘
★ = Expert recommendation (new additions)
```

---

## 2. Auth Module

> **Design reference:** [auth-login-template.md](auth-login-template.md)
> **Framework-specific routing:** See each framework pattern file's "Auth Pages" section

### Auth Screens (5)

| Screen | URL | Guard | Design |
|--------|-----|-------|--------|
| **Login** | `/{admin}/login` | Guest only | Glassmorphism card, email+password, remember me, social login |
| **Forgot Password** | `/{admin}/forgot-password` | Guest only | Email input → send reset link |
| **Reset Password** | `/{admin}/reset-password/{token}` | Guest only | New password + confirm, token validation |
| **Two-Factor** | `/{admin}/two-factor/challenge` | Auth (pre-2FA) | 6-digit OTP + recovery code fallback |
| **Logout** | `POST /{admin}/logout` | Auth | Destroy session, redirect to login |

### Auth Flow

```
                    ┌──────────────┐
                    │  GET /login   │
                    └──────┬───────┘
                           │ POST credentials
                    ┌──────▼───────┐
                    │  Validate    │──── Invalid ──→ Flash error → Login
                    └──────┬───────┘
                           │ Valid
                    ┌──────▼────────────┐
                    │  [SaaS] Resolve   │
                    │  tenant from domain│
                    └──────┬────────────┘
                           │
                    ┌──────▼───────┐
                    │  2FA Enabled?│──── No ──→ Create session → Dashboard
                    └──────┬───────┘
                           │ Yes
                    ┌──────▼───────┐
                    │  2FA Challenge│──── Invalid ──→ Flash error → 2FA
                    └──────┬───────┘
                           │ Valid
                    ┌──────▼───────┐
                    │  Dashboard   │
                    └──────────────┘

Forgot Password Flow:
GET /forgot-password → POST email → Send reset link →
GET /reset-password/{token} → POST new password → Login
```

### Shared Auth Components

| Component | Purpose |
|-----------|---------|
| `AuthLayout` | Glassmorphism wrapper (gradient bg + glass card) |
| `Input` | Custom input with leading icon + error state |
| `SocialButton` | OAuth provider button (Google, GitHub, etc.) |
| `LanguageSwitcher` | Locale dropdown in auth pages |
| `LocaleContext` | `useLocale()` hook + `t()` translation function |

---

## 3. RBAC Module (MODE-Aware)

### Permission Naming Convention

Hierarchical scoped format:

```
<scope>.<domain>.<resource>.<action>
```

| Component | Values | Example |
|-----------|--------|---------|
| **Scope** | `platform` (SaaS global), `site` (per-site) | `platform.admin.users.view` |
| **Domain** | `admin`, `content`, `settings` | `site.content.posts.create` |
| **Resource** | `users`, `roles`, `permissions`, `dashboard`, `settings`, `profile`, `tenants`, `sites` | |
| **Action** | `view`, `create`, `update`, `delete`, `manage` | |

### Roles by Mode

#### MODE=saas — 7 Roles (Multi-tenant)

| Role | Level | Scope | Description |
|------|-------|-------|-------------|
| `saasOwner` | 100 | `platform` | Platform owner — can do everything |
| `saasAdmin` | 90 | `platform` | Platform admin — manages all sites/users |
| `siteOwner` | 80 | `site` | Owns one site — full access within that site |
| `siteAdmin` | 60 | `site` | Manages a site — users, settings, content |
| `siteEditor` | 40 | `site` | Edits content within a site |
| `siteTranslator` | 30 | `site` | Manages translations for a site |
| `siteViewer` | 10 | `site` | Read-only access to a site |

#### MODE=standalone — 5 Roles (Single-tenant)

| Role | Level | Description |
|------|-------|-------------|
| `siteOwner` | 100 | Full system access, user management, role management |
| `siteAdmin` | 80 | User management (no role edit), all content |
| `siteEditor` | 50 | Content CRUD, own profile |
| `siteTranslator` | 30 | Content translation, own profile |
| `siteViewer` | 10 | Read-only, own profile |

> In standalone mode, there are **NO** roles starting with `saas`.
> `siteOwner` becomes the top-level admin (equivalent to `superAdmin`).

### Permissions by Mode

#### Shared Permissions (both modes: 15)

```
site.admin.dashboard.view
site.admin.users.view
site.admin.users.create
site.admin.users.update
site.admin.users.delete
site.admin.roles.view
site.admin.roles.create
site.admin.roles.update
site.admin.roles.delete
site.admin.permissions.view
site.admin.permissions.assign
site.admin.settings.view
site.admin.settings.update
site.admin.profile.view
site.admin.profile.update
```

#### SaaS-Only Permissions (+10)

```
platform.admin.tenants.view
platform.admin.tenants.create
platform.admin.tenants.update
platform.admin.tenants.delete
platform.admin.sites.view
platform.admin.sites.create
platform.admin.sites.update
platform.admin.sites.delete
platform.admin.billing.view
platform.admin.billing.manage
```

### Database Schema

```sql
-- ============================================
-- SHARED TABLES (both modes)
-- ============================================

-- Users (extend framework default)
ALTER TABLE users ADD COLUMN avatar VARCHAR(255) NULL;
ALTER TABLE users ADD COLUMN two_factor_secret TEXT NULL;
ALTER TABLE users ADD COLUMN two_factor_recovery_codes TEXT NULL;
ALTER TABLE users ADD COLUMN two_factor_confirmed_at TIMESTAMP NULL;
ALTER TABLE users ADD COLUMN last_login_at TIMESTAMP NULL;          -- ★ Expert: session tracking
ALTER TABLE users ADD COLUMN last_login_ip VARCHAR(45) NULL;        -- ★ Expert: security audit

-- Roles
CREATE TABLE roles (
    id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(125) NOT NULL UNIQUE,
    guard_name  VARCHAR(125) NOT NULL DEFAULT 'web',
    scope       ENUM('platform', 'site') NOT NULL DEFAULT 'site',  -- ★ MODE-aware
    level       INT NOT NULL DEFAULT 0,
    created_at  TIMESTAMP,
    updated_at  TIMESTAMP
);

-- Permissions
CREATE TABLE permissions (
    id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(125) NOT NULL UNIQUE,  -- scope.domain.resource.action
    guard_name  VARCHAR(125) NOT NULL DEFAULT 'web',
    created_at  TIMESTAMP,
    updated_at  TIMESTAMP
);

-- Pivot: role_has_permissions
CREATE TABLE role_has_permissions (
    permission_id BIGINT NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    role_id       BIGINT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (permission_id, role_id)
);

-- Pivot: model_has_roles (user ↔ role)
CREATE TABLE model_has_roles (
    role_id    BIGINT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    model_type VARCHAR(125) NOT NULL,
    model_id   BIGINT NOT NULL,
    PRIMARY KEY (role_id, model_id, model_type)
);

-- Pivot: model_has_permissions (direct user permissions)
CREATE TABLE model_has_permissions (
    permission_id BIGINT NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    model_type    VARCHAR(125) NOT NULL,
    model_id      BIGINT NOT NULL,
    PRIMARY KEY (permission_id, model_id, model_type)
);

-- ★ Expert: Audit Trail
CREATE TABLE audit_logs (
    id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id     BIGINT NULL REFERENCES users(id) ON DELETE SET NULL,
    action      VARCHAR(125) NOT NULL,     -- 'user.created', 'role.assigned', 'login.success'
    auditable_type VARCHAR(125) NULL,      -- Model class name
    auditable_id   BIGINT NULL,            -- Model ID
    old_values  JSON NULL,
    new_values  JSON NULL,
    ip_address  VARCHAR(45) NULL,
    user_agent  TEXT NULL,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ★ Expert: User Invitations
CREATE TABLE user_invitations (
    id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    email       VARCHAR(255) NOT NULL,
    role_id     BIGINT NOT NULL REFERENCES roles(id),
    token       VARCHAR(64) NOT NULL UNIQUE,
    invited_by  BIGINT NOT NULL REFERENCES users(id),
    accepted_at TIMESTAMP NULL,
    expires_at  TIMESTAMP NOT NULL,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- SAAS-ONLY TABLES (MODE=saas)
-- ============================================

-- Tenants
CREATE TABLE tenants (
    id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(255) NOT NULL,
    slug        VARCHAR(125) NOT NULL UNIQUE,
    plan        VARCHAR(50) DEFAULT 'free',                -- ★ SaaS billing
    stripe_customer_id VARCHAR(255) NULL,
    status      ENUM('active','suspended','trial') DEFAULT 'active',
    settings    JSON NULL,
    created_at  TIMESTAMP,
    updated_at  TIMESTAMP
);

-- Sites (belong to tenant)
CREATE TABLE sites (
    id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    tenant_id   BIGINT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name        VARCHAR(255) NOT NULL,
    domain      VARCHAR(255) NULL UNIQUE,
    subdomain   VARCHAR(125) NULL UNIQUE,
    settings    JSON NULL,
    is_active   BOOLEAN DEFAULT TRUE,
    created_at  TIMESTAMP,
    updated_at  TIMESTAMP
);

-- User ↔ Site pivot (SaaS: user belongs to many sites)
CREATE TABLE site_users (
    site_id     BIGINT NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    user_id     BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id     BIGINT NOT NULL REFERENCES roles(id),
    PRIMARY KEY (site_id, user_id)
);

-- ★ Feature Flags (per-site)
CREATE TABLE feature_flags (
    id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    site_id     BIGINT NULL REFERENCES sites(id) ON DELETE CASCADE,  -- NULL = global
    key         VARCHAR(125) NOT NULL,
    value       BOOLEAN DEFAULT FALSE,
    created_at  TIMESTAMP
);
```

### RBAC Helper Functions

```typescript
// Core RBAC — adapt per framework
function hasRole(user: User, role: string): boolean;
function hasPermission(user: User, permission: string): boolean;
function hasAnyPermission(user: User, permissions: string[]): boolean;
function assignRole(user: User, role: string): void;
function revokeRole(user: User, role: string): void;
function assignPermission(role: Role, permission: string): void;

// ★ MODE-aware helpers
function isSaasMode(): boolean;  // Check MODE env
function getCurrentSite(request): Site | null;  // Tenant resolution
function userBelongsToSite(user: User, siteId: number): boolean;  // SaaS only
function scopeQueryToSite(query: Query, siteId: number): Query;   // SaaS only

// Middleware
function requireAuth(request): Response | next;
function requirePermission(permission: string): Middleware;
function requireRole(role: string): Middleware;
function requireSaasRole(role: string): Middleware;  // SaaS only — platform scope
```

### Permission Guard Component (Frontend)

```tsx
// RoleGuard — conditional rendering based on permission
interface RoleGuardProps {
    permission: string | string[];
    mode?: 'any' | 'all';     // ★ Expert: match any or all permissions
    fallback?: React.ReactNode;
    children: React.ReactNode;
}

const RoleGuard = ({ permission, mode = 'any', fallback = null, children }: RoleGuardProps) => {
    const { user } = useAuth();
    const perms = Array.isArray(permission) ? permission : [permission];
    const hasAccess = mode === 'any'
        ? perms.some(p => user?.permissions?.includes(p))
        : perms.every(p => user?.permissions?.includes(p));
    return hasAccess ? <>{children}</> : <>{fallback}</>;
};

// ★ Expert: SaaS mode guard — only renders for platform-level roles
const SaasGuard = ({ children }: { children: React.ReactNode }) => {
    const { mode } = useAppConfig();  // Read MODE from config
    return mode === 'saas' ? <>{children}</> : null;
};

// Usage:
<RoleGuard permission="site.admin.users.create">
    <Button>Add User</Button>
</RoleGuard>

<SaasGuard>
    <RoleGuard permission="platform.admin.sites.view">
        <SidebarItem label="Sites" icon="ri-global-line" />
    </RoleGuard>
</SaasGuard>
```

---

## 4. User Management Module

### Screens (5)

| Screen | URL | Permission | Components |
|--------|-----|------------|------------|
| **User List** | `/{admin}/users` | `users.view` | DataTable, search, filters, pagination, bulk actions |
| **Create User** | `/{admin}/users/create` | `users.create` | Form (name, email, password, role select, avatar) |
| **Edit User** | `/{admin}/users/{id}/edit` | `users.update` | Form (prefilled), role reassignment |
| **Invite User** ★ | `/{admin}/users/invite` | `users.create` | Email + role → send invitation link |
| **View Profile** | `/{admin}/profile` | `profile.view` | Self-profile with avatar upload, password change, active sessions ★ |

### User Table Columns

| Column | Type | Sortable | Filterable |
|--------|------|----------|------------|
| Avatar + Name | composite | ✓ by name | — |
| Email | string | ✓ | ✓ search |
| Role | badge | ✓ | ✓ dropdown |
| Status | badge (active/inactive) | ✓ | ✓ dropdown |
| Last Login ★ | relative date | ✓ | — |
| Created At | date | ✓ | ✓ range |
| Actions | buttons | — | — |

### User Form Fields

```typescript
interface CreateUserForm {
    name: string;          // required, min:2, max:255
    email: string;         // required, email, unique
    password: string;      // required, min:8, confirmed
    password_confirmation: string;
    role: string;          // required, exists:roles.name
    avatar?: File;         // optional, image, max:2MB
    status: 'active' | 'inactive';  // default: active
}

// ★ Expert: Invitation form (alternative to direct create)
interface InviteUserForm {
    email: string;         // required, email
    role: string;          // required, exists:roles.name
    message?: string;      // optional personal message
}
```

---

## 5. Role Management Module

### Screens (2)

| Screen | URL | Permission | Components |
|--------|-----|------------|------------|
| **Role List** | `/{admin}/roles` | `roles.view` | Table (name, scope, users count, permissions count, actions) |
| **Edit Role** | `/{admin}/roles/{id}` | `roles.update` | Role name + Permission matrix (checkboxes) |

### Permission Matrix UI

```
                        view    create    update    delete    manage
Dashboard               [✓]      [ ]       [ ]       [ ]       [ ]
Users                   [✓]      [✓]       [✓]       [ ]       [ ]
Roles                   [✓]      [ ]       [ ]       [ ]       [ ]
Settings                [✓]      [ ]       [✓]       [ ]       [ ]
Profile                 [✓]      [ ]       [✓]       [ ]       [ ]
─── SaaS Only ──────────────────────────────────────────────────────
Tenants  (SaaS)         [✓]      [✓]       [✓]       [ ]       [ ]
Sites    (SaaS)         [✓]      [✓]       [✓]       [ ]       [ ]
Billing  (SaaS)         [✓]      [ ]       [ ]       [ ]       [✓]
```

> In `MODE=standalone`, rows marked "(SaaS)" are hidden entirely.

---

## 6. Admin Layout

### Sidebar Menu (permission-filtered, MODE-aware)

```typescript
const ADMIN_MENU: MenuItem[] = [
    {
        id: 'dashboard',
        label: 'Dashboard',
        icon: 'ri-dashboard-2-line',
        link: '/{admin}/dashboard',
        permission: 'site.admin.dashboard.view',
    },
    {
        id: 'users',
        label: 'User Management',
        icon: 'ri-user-settings-line',
        link: '#',
        permission: 'site.admin.users.view',
        subItems: [
            { id: 'user-list', label: 'All Users', link: '/{admin}/users' },
            { id: 'user-create', label: 'Add User', link: '/{admin}/users/create',
              permission: 'site.admin.users.create' },
            { id: 'user-invite', label: 'Invite User', link: '/{admin}/users/invite',
              permission: 'site.admin.users.create' },
        ],
    },
    {
        id: 'roles',
        label: 'Roles & Permissions',
        icon: 'ri-shield-user-line',
        link: '/{admin}/roles',
        permission: 'site.admin.roles.view',
    },
    // ★ SaaS-only menu items
    {
        id: 'sites',
        label: 'Sites',
        icon: 'ri-global-line',
        link: '/{admin}/sites',
        permission: 'platform.admin.sites.view',
        saasOnly: true,  // Hidden in standalone mode
    },
    {
        id: 'billing',
        label: 'Billing',
        icon: 'ri-bank-card-line',
        link: '/{admin}/billing',
        permission: 'platform.admin.billing.view',
        saasOnly: true,
    },
    {
        id: 'settings',
        label: 'Settings',
        icon: 'ri-settings-3-line',
        link: '/{admin}/settings',
        permission: 'site.admin.settings.view',
    },
];

// Filter by user permissions AND mode
function filterMenu(menu: MenuItem[], userPermissions: string[], mode: string): MenuItem[] {
    return menu
        .filter(item => {
            if (item.saasOnly && mode !== 'saas') return false;
            if (item.permission && !userPermissions.includes(item.permission)) return false;
            return true;
        })
        .map(item => ({
            ...item,
            subItems: item.subItems
                ? filterMenu(item.subItems, userPermissions, mode)
                : undefined,
        }));
}
```

### Admin Layout Structure

```
┌─────────────────────────────────────────────────────────┐
│  Header: Logo | Search | Notifications | Lang | Profile │
├──────────┬──────────────────────────────────────────────┤
│          │  Breadcrumb: Dashboard > Users                │
│ Sidebar  │──────────────────────────────────────────────┤
│ (250px)  │                                               │
│          │  Page Content                                 │
│ Dashboard│  ┌─────────────────────────────────────────┐  │
│ Users    │  │                                         │  │
│ Roles    │  │  [Card / Table / Form / Dashboard]      │  │
│ Sites ★  │  │                                         │  │
│ Billing ★│  └─────────────────────────────────────────┘  │
│ Settings │                                               │
│          ├──────────────────────────────────────────────┤
│          │  Footer: © 2026 AppName. Crafted by Team      │
└──────────┴──────────────────────────────────────────────┘
★ = SaaS mode only
```

### Theme Customizer (RightSidebar)

Velzon includes a **RightSidebar** theme customizer for layout/appearance switching.
Generate it with these toggles:

| Setting | Options | Data Attribute |
|---------|---------|----------------|
| Layout | Vertical, Horizontal, TwoColumn, Semibox | `data-layout` |
| Mode | Light, Dark | `data-layout-mode` |
| Sidebar Size | Default (lg), Compact (md), Icon (sm), Hover (sm-hover) | `data-sidebar-size` |
| Sidebar Color | Light, Dark, Gradient (1-4), Image | `data-sidebar` |
| Topbar Color | Light, Dark | `data-topbar` |
| Width | Fluid, Boxed | `data-layout-width` |

> **Reference:** Full patterns in [layout-system.md](layout-system.md) § RightSidebar (Theme Customizer)

### State Management

Admin state follows Velzon's **Redux Toolkit** pattern:

```
Component → dispatch(thunk) → API call → reducer → selector → re-render
```

| Framework | State Management | Pattern |
|-----------|-----------------|----------|
| **React / Next.js** | Redux Toolkit | `slices/{module}/reducer.ts` + `thunk.ts` + `createSelector` |
| **Vue / Nuxt** | Pinia | `stores/{module}.ts` |
| **Laravel Inertia** | Inertia `useForm` + `usePage` | Server-driven state via props |
| **Express EJS** | Server-side sessions | No client state management |
| **ASP.NET** | ViewModels + Server | No client state management |

For React variants, create these slices:

```
slices/
├── auth/reducer.ts        ← Login state, current user
├── users/reducer.ts       ← User list CRUD
├── roles/reducer.ts       ← Role list + permissions
├── dashboard/reducer.ts   ← Stats, activity log
├── layouts/reducer.ts     ← Theme customizer state (built-in)
└── index.ts               ← combineReducers
```

> **Reference:** Dashboard Redux wiring in [dashboard-patterns.md](dashboard-patterns.md)

---

## 7. Dashboard (Landing Page)

### Widgets — MODE-aware

#### Shared Widgets (both modes: 4)

| Widget | Icon | Color | Query |
|--------|------|-------|-------|
| Total Users | `ri-user-line` | primary | `COUNT(users)` |
| Active Today | `ri-user-follow-line` | success | Users logged in today |
| New This Month | `ri-user-add-line` | info | Users created this month |
| Roles Count | `ri-shield-user-line` | warning | `COUNT(roles)` |

#### SaaS-Only Widgets (+2)

| Widget | Icon | Color | Query |
|--------|------|-------|-------|
| Total Sites | `ri-global-line` | secondary | `COUNT(sites)` |
| Active Tenants | `ri-building-line` | dark | `COUNT(tenants WHERE status='active')` |

### ★ Activity Log (Expert Recommendation)

Recent 20 audit trail entries displayed in timeline format:

```tsx
// Activity item types
type AuditAction =
    | 'user.created' | 'user.updated' | 'user.deleted'
    | 'role.assigned' | 'role.revoked'
    | 'login.success' | 'login.failed'
    | 'settings.updated'
    | 'site.created' | 'site.updated';  // SaaS only

// Display format:
// 🟢 admin@example.com created user john@example.com — 2 minutes ago
// 🔵 admin@example.com assigned role 'editor' to jane@example.com — 5 minutes ago
// 🟡 admin@example.com updated settings — 1 hour ago
// 🔴 unknown@bad.com login failed (3 attempts) — 3 hours ago
```

---

## 8. Seed Data (MODE-Aware)

```typescript
const MODE = process.env.MODE || 'standalone';

const SEED = {
    // ── Shared permissions (both modes) ──
    permissions: [
        'site.admin.dashboard.view',
        'site.admin.users.view',
        'site.admin.users.create',
        'site.admin.users.update',
        'site.admin.users.delete',
        'site.admin.roles.view',
        'site.admin.roles.create',
        'site.admin.roles.update',
        'site.admin.roles.delete',
        'site.admin.permissions.view',
        'site.admin.permissions.assign',
        'site.admin.settings.view',
        'site.admin.settings.update',
        'site.admin.profile.view',
        'site.admin.profile.update',
        // SaaS-only permissions (conditionally seeded)
        ...(MODE === 'saas' ? [
            'platform.admin.tenants.view',
            'platform.admin.tenants.create',
            'platform.admin.tenants.update',
            'platform.admin.tenants.delete',
            'platform.admin.sites.view',
            'platform.admin.sites.create',
            'platform.admin.sites.update',
            'platform.admin.sites.delete',
            'platform.admin.billing.view',
            'platform.admin.billing.manage',
        ] : []),
    ],

    // ── Roles by mode ──
    roles: MODE === 'saas' ? [
        { name: 'saasOwner',      level: 100, scope: 'platform', permissions: '*' },
        { name: 'saasAdmin',      level: 90,  scope: 'platform', permissions: 'platform.*' },
        { name: 'siteOwner',      level: 80,  scope: 'site',     permissions: 'site.*' },
        { name: 'siteAdmin',      level: 60,  scope: 'site',     permissions: [
            'site.admin.dashboard.*', 'site.admin.users.*', 'site.admin.settings.*', 'site.admin.profile.*'
        ]},
        { name: 'siteEditor',     level: 40,  scope: 'site',     permissions: [
            'site.admin.dashboard.view', 'site.admin.profile.*', 'site.content.*'
        ]},
        { name: 'siteTranslator', level: 30,  scope: 'site',     permissions: [
            'site.admin.dashboard.view', 'site.admin.profile.*', 'site.content.translations.*'
        ]},
        { name: 'siteViewer',     level: 10,  scope: 'site',     permissions: [
            'site.admin.dashboard.view', 'site.admin.profile.view'
        ]},
    ] : [
        // Standalone: NO saas* roles
        { name: 'siteOwner',      level: 100, scope: 'site', permissions: '*' },
        { name: 'siteAdmin',      level: 80,  scope: 'site', permissions: [
            'site.admin.dashboard.*', 'site.admin.users.*', 'site.admin.roles.view',
            'site.admin.settings.*', 'site.admin.profile.*'
        ]},
        { name: 'siteEditor',     level: 50,  scope: 'site', permissions: [
            'site.admin.dashboard.view', 'site.admin.profile.*'
        ]},
        { name: 'siteTranslator', level: 30,  scope: 'site', permissions: [
            'site.admin.dashboard.view', 'site.admin.profile.*'
        ]},
        { name: 'siteViewer',     level: 10,  scope: 'site', permissions: [
            'site.admin.dashboard.view', 'site.admin.profile.view'
        ]},
    ],

    // ── Super admin user ──
    superAdmin: {
        name: MODE === 'saas' ? 'SaaS Owner' : 'Site Owner',
        email: 'admin@example.com',
        password: 'password',  // Only in development
        role: MODE === 'saas' ? 'saasOwner' : 'siteOwner',
    },

    // ── SaaS-only: default tenant + site ──
    ...(MODE === 'saas' ? {
        tenant: {
            name: 'Default Tenant',
            slug: 'default',
            plan: 'free',
        },
        site: {
            name: 'Default Site',
            domain: null,
            subdomain: 'app',
        },
    } : {}),
};
```

---

## 9. i18n Keys (Auth + Admin)

```json
{
    "auth": {
        "login_title": "Sign In",
        "login_subtitle": "Sign in to continue to {{appName}}.",
        "email_label": "Email",
        "password_label": "Password",
        "remember_me": "Remember me",
        "forgot_password": "Forgot password?",
        "sign_in": "Sign In",
        "no_account": "Don't have an account?",
        "sign_up": "Sign Up",
        "or_sign_in_with": "Or sign in with",
        "forgot_title": "Forgot Password?",
        "forgot_subtitle": "Enter your email and instructions will be sent to you!",
        "send_reset_link": "Send Reset Link",
        "back_to_login": "Back to Login",
        "reset_title": "Reset Password",
        "new_password": "New Password",
        "confirm_password": "Confirm Password",
        "reset_password": "Reset Password",
        "two_factor_title": "Two-Factor Authentication",
        "two_factor_subtitle": "Enter the code from your authenticator app.",
        "code_label": "Authentication Code",
        "verify": "Verify",
        "use_recovery": "Use recovery code",
        "recovery_label": "Recovery Code",
        "invite_title": "You've been invited!",
        "invite_subtitle": "Set your password to join {{siteName}}.",
        "accept_invite": "Accept Invitation"
    },
    "admin": {
        "dashboard": "Dashboard",
        "users": "Users",
        "user_management": "User Management",
        "all_users": "All Users",
        "add_user": "Add User",
        "invite_user": "Invite User",
        "edit_user": "Edit User",
        "roles": "Roles & Permissions",
        "sites": "Sites",
        "billing": "Billing",
        "settings": "Settings",
        "profile": "Profile",
        "logout": "Logout",
        "search_placeholder": "Search...",
        "welcome": "Welcome back, {{name}}!",
        "audit_log": "Activity Log",
        "active_sessions": "Active Sessions"
    }
}
```

---

## 10. Error Pages

| Page | URL | When |
|------|-----|------|
| **403 Forbidden** | Auto | User lacks required permission |
| **404 Not Found** | Auto | Route not found |
| **500 Error** | Auto | Server error |

All error pages use `AuthLayout` (glassmorphism, no sidebar).

---

## 11. ★ Expert Recommendations (Advanced Features)

These features are generated by default in the starter kit:

### 11.1 Audit Trail

Every mutation (create/update/delete) on users, roles, and settings is logged to `audit_logs` table. Dashboard shows recent activity timeline.

### 11.2 User Invitation System

Instead of creating users with passwords, admins can **invite** users via email. The invited user clicks a link and sets their own password. This is more secure and follows SaaS best practices.

### 11.3 Session Management

Profile page shows **active sessions** (device, IP, last active). Users can **logout other devices** for security.

### 11.4 Password Policy

Configurable via `config/auth.password_policy`:
- Minimum length: 8 (configurable)
- Require uppercase + lowercase + number
- ★ Optional: breach check via HaveIBeenPwned API

### 11.5 Login Throttling

After 5 failed attempts (configurable), lock account for 15 minutes. Log failed attempts to audit trail.

### 11.6 Feature Flags (SaaS only)

Per-site toggles stored in `feature_flags` table. Admin can enable/disable features for specific sites without deployment.

### 11.7 Tenant Resolution (SaaS only)

```
Incoming request → Extract domain/subdomain
    ├── Match sites.domain    → Found site → Resolve tenant
    ├── Match sites.subdomain → Found site → Resolve tenant
    └── No match → 404 or redirect to main site
```

---

## 12. Framework Adaptation Matrix

### File Generation Per Framework

#### Next.js (App Router)

```
src/
├── app/admin/
│   ├── login/ + forgot-password/ + reset-password/ + two-factor/
│   ├── dashboard/page.tsx
│   ├── users/page.tsx + create/ + [id]/edit/ + invite/
│   ├── roles/page.tsx + [id]/
│   ├── settings/ + profile/
│   ├── sites/ (SaaS only)
│   └── layout.tsx
├── features/
│   ├── auth/                    ← See scaffolding.md
│   ├── rbac/                    ← RoleGuard, SaasGuard, PermissionMatrix, usePermissions
│   ├── users/                   ← UserTable, UserForm, InviteForm
│   └── audit/                   ← AuditTimeline, useAuditLog
├── lib/auth.ts, rbac.ts, prisma.ts, audit.ts
├── middleware.ts                ← Auth + RBAC + (SaaS: tenant resolution)
└── prisma/schema.prisma + seed.ts
```

| Auth Provider | RBAC | ORM | UI |
|---------------|------|-----|----|
| Auth.js v5 (NextAuth) | Custom middleware + Prisma | Prisma | Reactstrap + Bootstrap 5 |

#### Laravel + Inertia.js + React

```
app/Http/Controllers/Admin/ (Auth, Dashboard, User, Role, Settings + SaaS: Site, Billing)
app/Http/Middleware/ (CheckPermission, CheckRole + SaaS: ResolveTenant)
app/Models/ (User, Role, Permission, AuditLog, UserInvitation + SaaS: Tenant, Site)
resources/js/Pages/Admin/ (Auth, Dashboard, Users, Roles, Settings + SaaS: Sites)
resources/js/Layouts/ (GuestLayout, AdminLayout)
database/migrations/ + seeders/
routes/web.php
```

| Auth Provider | RBAC | ORM | UI |
|---------------|------|-----|----|
| Laravel Fortify | Spatie Laravel-Permission | Eloquent | Reactstrap + Bootstrap 5 |

#### Laravel Blade

(Same backend as Inertia, Blade views instead of React)

| Auth Provider | RBAC | ORM | UI |
|---------------|------|-----|----|
| Laravel Breeze | Spatie Laravel-Permission | Eloquent | Blade + Bootstrap 5 |

#### Express + EJS

```
controllers/ (Auth, User, Role, Audit + SaaS: Site, Tenant)
middleware/ (auth, rbac, rateLimiter + SaaS: tenantResolver)
models/ (User, Role, Permission, AuditLog, Invitation + SaaS: Tenant, Site)
views/ (layouts, auth screens, admin pages)
routes/admin.js
```

| Auth Provider | RBAC | ORM | UI |
|---------------|------|-----|----|
| Express Session + bcrypt | Custom middleware | Mongoose | EJS + Bootstrap 5 |

#### ASP.NET Core 8

```
Controllers/ (AdminAuth, User, Role, Audit + SaaS: Site)
Views/ (AdminAuth, Admin, Shared layouts)
Models/ (ApplicationUser, Role, Permission, AuditLog)
Authorization/ (PermissionHandler, PermissionRequirement)
Data/Migrations/ + Seeders/
```

| Auth Provider | RBAC | ORM | UI |
|---------------|------|-----|----|
| ASP.NET Identity | Policy-based Authorization | EF Core | Razor + Bootstrap 5 |

---

## 13. Optional: Payments & Email Module

> [!NOTE]
> This module is **optional** — only generate when the project needs subscriptions/billing.
> Typically used with `MODE=saas` but can also be standalone billing.

### Payment Provider: Stripe

| Feature | Implementation |
|---------|---------------|
| Subscriptions | Stripe Checkout Sessions |
| Billing Portal | Stripe Customer Portal (manage/cancel) |
| Webhooks | Verify signature → sync subscription status |
| Plans | Stored in DB, synced with Stripe Price IDs |

### Email Provider: Resend

| Feature | Implementation |
|---------|---------------|
| Transactional | Welcome email, password reset, invite |
| Templates | React Email (JSX-based) or framework equivalent |

### Additional Database Models

```sql
CREATE TABLE plans (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    name            VARCHAR(125) NOT NULL,
    stripe_price_id VARCHAR(255) NOT NULL UNIQUE,
    price           DECIMAL(10,2) NOT NULL,
    currency        VARCHAR(3) DEFAULT 'usd',
    interval        ENUM('month', 'year') DEFAULT 'month',
    features        JSON NULL,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMP,
    updated_at      TIMESTAMP
);

CREATE TABLE subscriptions (
    id                      BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id                 BIGINT NOT NULL REFERENCES users(id),
    plan_id                 BIGINT NOT NULL REFERENCES plans(id),
    stripe_subscription_id  VARCHAR(255) NOT NULL UNIQUE,
    stripe_customer_id      VARCHAR(255) NOT NULL,
    status                  ENUM('active','canceled','past_due','trialing','incomplete') DEFAULT 'active',
    current_period_end      TIMESTAMP NOT NULL,
    cancel_at_period_end    BOOLEAN DEFAULT FALSE,
    created_at              TIMESTAMP,
    updated_at              TIMESTAMP
);
```

### Framework Adaptation

| Framework | Webhook Route | Stripe Client | Email |
|-----------|---------------|---------------|-------|
| **Next.js** | `api/webhooks/stripe/route.ts` | `lib/stripe.ts` | Resend + React Email |
| **Laravel** | `routes/webhooks.php` | `app/Services/StripeService.php` | Laravel Mail + Resend driver |
| **Express** | `routes/webhooks.js` | `lib/stripe.js` | Nodemailer + Resend transport |
| **ASP.NET** | `Controllers/WebhookController.cs` | `Services/StripeService.cs` | SMTP or SendGrid |

### Additional Files Per Framework

```
# Framework-agnostic structure:
features/billing/ (or equivalent)
├── components/PricingTable, SubscriptionCard
├── actions (createCheckout, createPortal, cancelSubscription)
└── types

lib/stripe          ← Stripe client + webhook verification
lib/email           ← Email client + templates
pages/pricing       ← Plan comparison (public)
api/webhooks/stripe ← Webhook handler
```

### Additional Env Variables

| Variable | Purpose |
|----------|---------|
| `STRIPE_SECRET_KEY` | Stripe API server-side |
| `STRIPE_PUBLISHABLE_KEY` | Stripe client-side |
| `STRIPE_WEBHOOK_SECRET` | Webhook signature verification |
| `RESEND_API_KEY` | Transactional email (or SMTP equivalent) |

---

## 14. Quality Checklist

Before marking starter kit as complete, verify:

- [ ] **Mode**: Correct mode detected (`MODE=saas` or `MODE=standalone`)
- [ ] **Auth**: All 5 screens render correctly with glassmorphism design
- [ ] **RBAC**: Seed runs, correct roles (7 saas / 5 standalone) + permissions created
- [ ] **Login**: Top-level admin can login with seeded credentials
- [ ] **Guard**: Unauthenticated users redirected to login
- [ ] **Permission**: Lower roles cannot access restricted pages (403)
- [ ] **Sidebar**: Menu items filtered by user permissions AND mode
- [ ] **Users CRUD**: List, create, edit, delete, invite all functional
- [ ] **Roles**: Permission matrix displays and saves correctly
- [ ] **Audit**: Actions logged and visible in dashboard timeline
- [ ] **i18n**: All strings use translation keys (no hardcoded text)
- [ ] **Responsive**: Works on mobile viewport (≥375px)
- [ ] **Dark Mode**: `data-bs-theme="dark"` toggles correctly
- [ ] **Security**: Login throttling active, password policy enforced
- [ ] **[SaaS]**: Tenant resolution works, SaaS menu items visible only in SaaS mode
- [ ] **Dev Server**: `npm run dev` / `php artisan serve` starts without errors

---

## Cross-References

| Reference | Purpose |
|-----------|---------|
| [auth-login-template.md](auth-login-template.md) | Auth screen design (glassmorphism, components, CSS tokens) |
| [nextjs-patterns.md](nextjs-patterns.md) | Next.js App Router auth patterns |
| [html-php-patterns.md](html-php-patterns.md) | HTML/PHP/Laravel Blade auth patterns |
| [aspnet-mvc-patterns.md](aspnet-mvc-patterns.md) | ASP.NET auth patterns |
| [nodejs-patterns.md](nodejs-patterns.md) | Express + EJS auth patterns |
| [inertia-bridge.md](inertia-bridge.md) | Laravel + Inertia auth patterns |
| [ajax-patterns.md](ajax-patterns.md) | jQuery Ajax auth patterns |
| [component-patterns.md](component-patterns.md) | Velzon React component library |
| [dashboard-patterns.md](dashboard-patterns.md) | Dashboard widget patterns |

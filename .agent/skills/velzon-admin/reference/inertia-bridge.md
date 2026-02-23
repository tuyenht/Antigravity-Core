# Inertia.js Bridge Reference

Pattern mapping from Velzon React-TS → Laravel + Inertia.js + React.
Use this when building admin interfaces with the Baoson Platform or any Laravel + Inertia.js project.

---

## Entry Point

```tsx
// resources/js/app.tsx
import '../scss/themes.scss';
import { createRoot } from 'react-dom/client';
import { createInertiaApp } from '@inertiajs/react';
import { resolvePageComponent } from 'laravel-vite-plugin/inertia-helpers';
import { Provider } from 'react-redux';
import { configureStore } from "@reduxjs/toolkit";
import rootReducer from "./slices";

const store = configureStore({ reducer: rootReducer, devTools: true });

createInertiaApp({
    title: (title) => `${title} - ${import.meta.env.VITE_APP_NAME}`,
    resolve: (name) => resolvePageComponent(
        `./Pages/${name}.tsx`,
        import.meta.glob('./Pages/**/*.tsx')
    ),
    setup({ el, App, props }) {
        createRoot(el).render(
            <Provider store={store}>
                <App {...props} />
            </Provider>
        );
    },
    progress: { color: '#4B5563' },
});
```

> **Note:** Redux is STILL used alongside Inertia for client-side state (layout config, theme, sidebar). Server data flows through Inertia props.

---

## Pattern Mapping Table

| Velzon React-TS | Inertia Equivalent |
|---|---|
| `react-router-dom` | `@inertiajs/react` (`Link`, `router`) |
| `<Route path="/x" component={X} />` | `Route::get('/x', fn() => Inertia::render('X'))` (Laravel) |
| `useNavigate()` | `router.visit('/path')` or `router.get('/path')` |
| `<Link to="/path">` | `<Link href="/path">` |
| Fake backend (`fakebackend_helper.ts`) | Laravel Controllers |
| `axios` + `APIClient` | Inertia `router.post/put/delete` or `useForm()` |
| `useSelector(state => state.xxx)` | `usePage<PageProps>().props.xxx` for server data |
| `dispatch(getXxxData())` | Server passes data in `Inertia::render('Page', $data)` |
| Client-side pagination | Server-side pagination via Laravel Paginator |

---

## Directory Structure

```
resources/
├── js/
│   ├── app.tsx                     # Entry point
│   ├── bootstrap.ts                # Axios defaults
│   ├── i18n.ts                     # i18next config
│   ├── Components/                 # Reusable components (~37 files)
│   │   ├── Common/
│   │   │   ├── BreadCrumb.tsx
│   │   │   ├── DeleteModal.tsx
│   │   │   ├── TableContainer.tsx
│   │   │   ├── SearchOption.tsx
│   │   │   └── ProfileDropdown.tsx
│   │   └── ... (charts, forms, etc.)
│   ├── Layouts/                    # Layout system
│   │   ├── index.tsx               # Main Layout (Header + Sidebar + Footer)
│   │   ├── Header.tsx
│   │   ├── Sidebar.tsx
│   │   ├── Footer.tsx
│   │   ├── LayoutMenuData.tsx      # Menu items
│   │   ├── GuestLayout.tsx         # Auth pages (no sidebar)
│   │   ├── HorizontalLayout/
│   │   ├── VerticalLayouts/
│   │   └── TwoColumnLayout/
│   ├── Pages/                      # Inertia page components (~432 files)
│   │   ├── Dashboard.tsx
│   │   ├── DashboardAnalytics.tsx
│   │   └── ... (all pages from React-TS)
│   ├── slices/                     # Redux Toolkit (layout state only)
│   └── locales/                    # i18n JSON files (8 languages)
├── scss/                           # Same SCSS as React-TS
│   └── themes.scss
└── views/                          # Blade templates (minimal)
    └── app.blade.php               # Single Blade wrapper
```

---

## Layout Pattern

```tsx
// Layouts/index.tsx — SAME structure as React-TS
const Layout = ({ children }: any) => {
    const dispatch: any = useDispatch();
    // Redux controls layout settings (sidebar theme, topbar, etc.)
    // Layout dispatches happen in useEffect
    return (
        <React.Fragment>
            <div id="layout-wrapper">
                <Header headerClass={headerClass}
                        layoutModeType={layoutModeType}
                        onChangeLayoutMode={onChangeLayoutMode} />
                <Sidebar layoutType={layoutType} />
                <div className="main-content">
                    {children}
                    <Footer />
                </div>
            </div>
            <RightSidebar />
        </React.Fragment>
    );
};
```

**Key difference:** In Inertia, pages DON'T set their own layout. Instead, use Laravel middleware or page-level layout assignment:
```tsx
// Option 1: Page-level persistent layout
Dashboard.layout = (page: React.ReactNode) => <Layout>{page}</Layout>;

// Option 2: In app.tsx resolve function
resolve: (name) => {
    const page = resolvePageComponent(`./Pages/${name}.tsx`, ...);
    page.then(module => {
        module.default.layout = module.default.layout || 
            ((page: any) => <Layout>{page}</Layout>);
    });
    return page;
}
```

---

## Routing (Laravel → Inertia)

### Simple Page Route
```php
// routes/web.php
Route::get('/dashboard', fn() => Inertia::render('Dashboard'));
```

### Controller Route (with data)
```php
// Using VelzonRoutesController
Route::controller(VelzonRoutesController::class)->group(function () {
    Route::get("/dashboard", "index");
    Route::get("/dashboard-analytics", "dashboard_analytics");
    Route::get("/apps-ecommerce-products", "apps_ecommerce_products");
    // ... 200+ routes
});
```

### CRUD Operations
```php
// routes/web.php
Route::middleware('auth')->group(function () {
    Route::get("/apps-ecommerce-orders", [OrderController::class, 'index'])->name('order-list');
    Route::post("order-create", [OrderController::class, 'store'])->name('order-create');
    Route::post("order-update", [OrderController::class, 'update'])->name('order-update');
    Route::post("order-delete", [OrderController::class, 'destroy'])->name('order-delete');
});
```

### Controller Pattern
```php
// app/Http/Controllers/OrderController.php
class OrderController extends Controller
{
    public function index()
    {
        $orders = Order::paginate(10);
        return Inertia::render('Ecommerce/Orders', [
            'orders' => $orders,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([...]);
        Order::create($validated);
        return redirect()->back()->with('success', 'Order created.');
    }

    public function update(Request $request)
    {
        $order = Order::findOrFail($request->id);
        $order->update($request->validate([...]));
        return redirect()->back();
    }

    public function destroy(Request $request)
    {
        Order::findOrFail($request->id)->delete();
        return redirect()->back();
    }
}
```

---

## Form Handling

### React-TS (Formik)
```tsx
const formik = useFormik({
    initialValues: { name: '', email: '' },
    validationSchema: Yup.object({...}),
    onSubmit: (values) => dispatch(addNewData(values)),
});
```

### Inertia (useForm)
```tsx
import { useForm } from '@inertiajs/react';

const { data, setData, post, processing, errors, reset } = useForm({
    name: '', email: '',
});

const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    post(route('order-create'), {
        onSuccess: () => { reset(); toggle(); },
    });
};
```

```tsx
<Form onSubmit={handleSubmit}>
    <Input
        value={data.name}
        onChange={(e) => setData('name', e.target.value)}
        invalid={!!errors.name}
    />
    {errors.name && <FormFeedback>{errors.name}</FormFeedback>}
    <Button type="submit" disabled={processing}>Submit</Button>
</Form>
```

---

## Data Fetching

### React-TS (Redux Thunk)
```tsx
useEffect(() => {
    dispatch(getOrderList());
}, [dispatch]);
const orders = useSelector(state => state.Ecommerce.orders);
```

### Inertia (Server Props)
```tsx
import { usePage } from '@inertiajs/react';

interface OrderPageProps {
    orders: {
        data: Order[];
        current_page: number;
        last_page: number;
        per_page: number;
        total: number;
    };
}

const OrderList = () => {
    const { orders } = usePage<{ orders: OrderPageProps['orders'] }>().props;
    // orders.data is already available — no dispatch needed
};
```

---

## Server-Side Pagination

### Controller
```php
public function index(Request $request)
{
    $orders = Order::query()
        ->when($request->search, fn($q) => $q->where('name', 'like', "%{$request->search}%"))
        ->orderBy($request->sort_by ?? 'created_at', $request->sort_dir ?? 'desc')
        ->paginate($request->per_page ?? 10)
        ->withQueryString();

    return Inertia::render('Ecommerce/Orders', [
        'orders' => $orders,
        'filters' => $request->only(['search', 'sort_by', 'sort_dir']),
    ]);
}
```

### Page Component (pagination)
```tsx
import { router } from '@inertiajs/react';

// Navigate to page
const handlePageChange = (page: number) => {
    router.get(route('order-list'), { page }, {
        preserveState: true,
        preserveScroll: true,
    });
};
```

---

## Delete Flow (Inertia)

```tsx
import { router } from '@inertiajs/react';

const handleDelete = () => {
    router.post(route('order-delete'), { id: selectedId }, {
        onSuccess: () => {
            setDeleteModal(false);
            toast.success("Deleted successfully");
        },
    });
};
```

---

## Auth Pages (Admin Prefix)

> [!IMPORTANT]
> All auth screens use the **BaoSon glassmorphism design** defined in [auth-login-template.md](auth-login-template.md).
> Auth pages use `GuestLayout` (no sidebar/topbar) at `/{adminPrefix}/login`.

### Auth Screens (5 total)

| Screen | Laravel Route | Inertia Page |
|--------|--------------|--------------|
| **Login** | `GET /{admin}/login` | `Pages/Admin/Auth/Login.tsx` |
| **Forgot Password** | `GET /{admin}/forgot-password` | `Pages/Admin/Auth/ForgotPassword.tsx` |
| **Reset Password** | `GET /{admin}/reset-password/{token}` | `Pages/Admin/Auth/ResetPassword.tsx` |
| **Two-Factor** | `GET /{admin}/two-factor/challenge` | `Pages/Admin/Auth/TwoFactor.tsx` |
| **Logout** | `POST /{admin}/logout` | — (redirect) |

### Laravel Routes

```php
// routes/web.php
$adminPrefix = config('admin.prefix', 'admin');

Route::prefix($adminPrefix)->name('admin.')->group(function () {
    Route::middleware('guest')->group(function () {
        Route::get('/login', fn() => Inertia::render('Admin/Auth/Login'))->name('login');
        Route::post('/login', [AdminAuthController::class, 'login'])->name('login.store');
        Route::get('/forgot-password', fn() => Inertia::render('Admin/Auth/ForgotPassword'))->name('forgot-password');
        Route::post('/forgot-password', [AdminAuthController::class, 'sendResetLink'])->name('forgot-password.store');
        Route::get('/reset-password/{token}', fn($token) => Inertia::render('Admin/Auth/ResetPassword', ['token' => $token]))->name('reset-password');
        Route::post('/reset-password', [AdminAuthController::class, 'resetPassword'])->name('reset-password.store');
    });

    Route::middleware('auth')->group(function () {
        Route::get('/two-factor/challenge', fn() => Inertia::render('Admin/Auth/TwoFactor'))->name('two-factor');
        Route::post('/two-factor/challenge', [AdminAuthController::class, 'verifyTwoFactor'])->name('two-factor.verify');
        Route::post('/logout', [AdminAuthController::class, 'logout'])->name('logout');
        Route::get('/dashboard', fn() => Inertia::render('Dashboard'))->name('dashboard');
    });
});
```

### Inertia Page Component (Login)

```tsx
// Pages/Admin/Auth/Login.tsx
import { useForm, Head, Link } from '@inertiajs/react';

const Login = () => {
    const { data, setData, post, processing, errors } = useForm({
        email: '', password: '', remember: false,
    });

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        post(route('admin.login.store'));
    };

    return (
        <>
            <Head title="Login — Admin Panel" />
            {/* BaoSon glassmorphism login form */}
            {/* See auth-login-template.md for full TSX */}
            <form onSubmit={handleSubmit}>
                {/* ... */}
            </form>
        </>
    );
};

// Use GuestLayout (no sidebar) for auth pages
Login.layout = (page: React.ReactNode) => <GuestLayout>{page}</GuestLayout>;
export default Login;
```

### GuestLayout (Glassmorphism)

```tsx
// Layouts/GuestLayout.tsx
const GuestLayout = ({ children }: { children: React.ReactNode }) => {
    return (
        <div className="auth-page-wrapper">
            {/* Gradient background + animated orbs */}
            {/* See auth-login-template.md for full layout */}
            <div className="auth-page-content">
                {children}
            </div>
            {/* Footer */}
        </div>
    );
};
```

### File Structure

```
resources/js/
├── Pages/
│   ├── Admin/
│   │   └── Auth/
│   │       ├── Login.tsx                ← useForm() + post(route('admin.login.store'))
│   │       ├── ForgotPassword.tsx
│   │       ├── ResetPassword.tsx
│   │       └── TwoFactor.tsx
│   └── Dashboard.tsx
├── Layouts/
│   ├── index.tsx                        ← Main admin layout (sidebar + header)
│   ├── GuestLayout.tsx                  ← Auth layout (glassmorphism, no sidebar)
│   └── ...
└── Components/
    └── Auth/
        ├── AuthCard.tsx                 ← Shared glass card component
        ├── Input.tsx                    ← Custom input with icon
        ├── LanguageSwitcher.tsx
        └── SocialButton.tsx
```

> [!CAUTION]
> **Inertia auth uses `useForm()` from `@inertiajs/react`**, NOT `useState` + `axios`.
> All form submissions go through `post(route('admin.login.store'))`.
> Validation errors come from Laravel and are available via `errors` from `useForm()`.

---

## Key Differences Summary

| Aspect | React-TS | React+Inertia |
|--------|----------|---------------|
| **Build** | `react-scripts` / Vite standalone | `laravel-vite-plugin` |
| **Routing** | Client-side (React Router) | Server-side (Laravel routes) |
| **State** | Redux for everything | Redux for UI state + Inertia for server data |
| **API calls** | `APIClient` + axios | `router.post/get` or `useForm()` |
| **Auth** | JWT / Firebase / fake backend | Laravel Breeze/Fortify (session) |
| **SSR** | No (SPA only) | Optional (Inertia SSR) |
| **Page resolution** | `allRoutes.tsx` | `resolvePageComponent('./Pages/${name}.tsx')` |
| **Assets** | Standalone Vite | `@vitejs/plugin-react` + `laravel-vite-plugin` |

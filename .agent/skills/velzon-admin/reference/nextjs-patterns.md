# Next.js Patterns Reference

Pattern mapping from Velzon React-TS → Next.js App Router (TypeScript).
Use for BSWeb SaaS or any Next.js admin project.

---

## App Router Structure

> [!WARNING]
> **Post-Init: Verify root `app/` does NOT exist.**
> `create-next-app --src-dir` may still generate a root `app/` directory alongside `src/app/`.
> Next.js prioritizes root `app/` over `src/app/` → **all routes in `src/app/` return 404**.
> After project init, always run:
> ```powershell
> Remove-Item ./app -Recurse -Force -ErrorAction SilentlyContinue
> Remove-Item ./.next -Recurse -Force -ErrorAction SilentlyContinue
> ```

```
src/
├── app/
│   ├── layout.tsx                      # Root layout (html, body, providers)
│   ├── globals.css
│   ├── page.tsx                        # Root page (MUST redirect to /{ADMIN_PREFIX}/dashboard)
│   ├── (auth)/                         # Auth route group (no admin layout)
│   │   ├── layout.tsx                  # Guest layout wrapper
│   │   ├── auth-signin-basic/page.tsx
│   │   ├── auth-signin-cover/page.tsx
│   │   ├── auth-signup-basic/page.tsx
│   │   ├── auth-pass-reset-basic/page.tsx
│   │   └── ...
│   ├── (with-layout)/                  # Admin pages (with sidebar/header)
│   │   ├── layout.tsx                  # Layout wrapper → <Layout>{children}</Layout>
│   │   ├── dashboard/page.tsx
│   │   ├── dashboard-analytics/page.tsx
│   │   ├── apps-ecommerce-products/page.tsx
│   │   └── ...
│   └── (with-nonlayout)/              # Pages without layout (landing, etc.)
│       ├── layout.tsx
│       ├── landing/page.tsx
│       └── ...
├── components/                         # Same structure as React-TS Components/
├── layouts/                            # Same layout system
├── slices/                             # Redux Toolkit (same as React-TS)
├── helpers/                            # API helpers
├── hooks/                              # Custom hooks
├── providers/                          # ClientProviders wrapper
├── config/                             # App config
├── types/                              # TypeScript types
└── assets/scss/                        # Same SCSS as React-TS
```

---

## Root Page (Redirect)

> [!CAUTION]
> **MUST overwrite** the default `src/app/page.tsx` created by `create-next-app`.
> Without this, visiting `/` shows the Next.js default template instead of redirecting to admin.

```tsx
// src/app/page.tsx — Overwrite default Next.js page
import { redirect } from 'next/navigation';
import { ADMIN_PREFIX } from '@/config/admin';

export default function Home() {
  redirect(`/${ADMIN_PREFIX}/dashboard`);
}
```

---

## Root Layout

```tsx
// src/app/layout.tsx
import ClientProviders from "@/components/ClientProviders";
import "../assets/scss/themes.scss";
import "apexcharts/dist/apexcharts.css";
import "swiper/css";

export const metadata: Metadata = {
    title: "Admin Dashboard",
    description: "Admin dashboard template",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
    return (
        <html lang="en" suppressHydrationWarning>
            <head>
                {/* Poppins = Velzon admin dashboard body font (NOT for auth pages).
                    Auth pages use local Inter font via auth.css @font-face.
                    For zero-CDN: replace with next/font/local or self-hosted woff2. */}
                <link rel="stylesheet"
                    href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" />
            </head>
            <body suppressHydrationWarning>
                <ClientProviders>{children}</ClientProviders>
            </body>
        </html>
    );
}
```

---

## Route Group Layouts

### Admin Layout (with sidebar)
```tsx
// src/app/(with-layout)/layout.tsx
import Layout from "@/layouts/Layouts";

export default function WithLayout({ children }: { children: React.ReactNode }) {
    return <Layout>{children}</Layout>;
}
```

### Auth Layout (no sidebar)
```tsx
// src/app/(auth)/layout.tsx
export default function AuthLayout({ children }: { children: React.ReactNode }) {
    return <>{children}</>;
}
```

---

## Page Component

```tsx
// src/app/(with-layout)/dashboard/page.tsx
"use client"; // Required — Velzon components use hooks, Redux, browser APIs

import React from "react";
import { Container } from "reactstrap";
import BreadCrumb from "@/components/Common/BreadCrumb";
import Revenue from "./Revenue";
import BestSellingProducts from "./BestSellingProducts";

const Dashboard = () => {
    return (
        <div className="page-content">
            <Container fluid>
                <BreadCrumb title="Dashboard" pageTitle="Dashboards" />
                <Revenue />
                <BestSellingProducts />
            </Container>
        </div>
    );
};

export default Dashboard;
```

> **Important:** Nearly ALL Velzon pages need `"use client"` directive because they use React hooks, Redux, browser APIs (document.title), etc.

---

## Key Differences from React-TS

| Aspect | React-TS | Next-TS |
|--------|----------|---------|
| **Routing** | `allRoutes.tsx` + React Router | File-based App Router |
| **Route params** | `useParams()` from react-router | `params` prop or `useParams()` from next/navigation |
| **Navigation** | `useNavigate()` | `useRouter()` from next/navigation |
| **Link** | `import { Link } from 'react-router-dom'` | `import Link from 'next/link'` |
| **Layout** | HOC wrapper in route config | Route group `layout.tsx` |
| **Client/Server** | Everything is client | Must mark `"use client"` |
| **Metadata** | `document.title = "..."` in useEffect | `export const metadata` or `generateMetadata()` |
| **Redux** | Same | Same (wrapped in ClientProviders) |
| **SCSS** | Import in index.tsx | Import in root layout.tsx |

---

## Navigation Mapping

```tsx
// React-TS
import { useNavigate, Link } from "react-router-dom";
const navigate = useNavigate();
navigate("/dashboard");
<Link to="/apps-ecommerce-products">Products</Link>

// Next-TS
import { useRouter } from "next/navigation";
import Link from "next/link";
const router = useRouter();
router.push("/dashboard");
<Link href="/apps-ecommerce-products">Products</Link>
```

---

## Data Fetching Options

### Option 1: Client-side (same as React-TS)
```tsx
"use client";
// Use Redux thunks same as React-TS
useEffect(() => { dispatch(getData()); }, []);
```

### Option 2: Server Component + Client Component
```tsx
// page.tsx (server)
async function DashboardPage() {
    const data = await fetch('...');
    return <DashboardClient initialData={data} />;
}

// DashboardClient.tsx (client)
"use client";
const DashboardClient = ({ initialData }: Props) => {
    // Use initialData + Redux for client state
};
```

---

## Proxy (Auth Guard)

> [!IMPORTANT]
> **Next.js 16:** `proxy.ts` replaces deprecated `middleware.ts`. Runs on Node.js runtime (full API access).

```tsx
// proxy.ts (Next.js 16+ — replaces middleware.ts)
import { auth } from '@/auth';
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

const ADMIN_PREFIX = process.env.NEXT_PUBLIC_ADMIN_PREFIX ?? 'admin';

// Pre-computed Set for O(1) lookup instead of Array.some() O(n)
const PUBLIC_PATHS = new Set([
    `/${ADMIN_PREFIX}/login`,
    `/${ADMIN_PREFIX}/forgot-password`,
    `/${ADMIN_PREFIX}/reset-password`,
    `/${ADMIN_PREFIX}/two-factor`,
]);

export async function proxy(request: NextRequest) {
    const { pathname } = request.nextUrl;

    // 1. Only protect admin routes — early return for non-admin
    if (!pathname.startsWith(`/${ADMIN_PREFIX}`)) return NextResponse.next();

    // 2. Check public paths with O(1) Set lookup
    const isPublic = PUBLIC_PATHS.has(pathname);

    // 3. Lazy session loading — only call auth() for admin routes
    const session = await auth();

    if (isPublic) {
        // Logged-in users on auth pages → redirect to dashboard
        if (session) {
            return NextResponse.redirect(
                new URL(`/${ADMIN_PREFIX}/dashboard`, request.url)
            );
        }
        return NextResponse.next();
    }

    // 4. Require auth for all other admin pages
    if (!session) {
        return NextResponse.redirect(
            new URL(`/${ADMIN_PREFIX}/login`, request.url)
        );
    }

    return NextResponse.next();
}

export const config = {
    matcher: [
        '/((?!api|_next/static|_next/image|assets|images|favicon.ico).*)',
    ],
};
```

---

## Auth Pages (Admin Prefix)

> [!IMPORTANT]
> All auth screens use the **BaoSon glassmorphism design** defined in [auth-login-template.md](reference/auth-login-template.md).
> Auth pages live at `/{adminPrefix}/login`, NOT at `/login`.

### Folder Structure

```
src/app/admin/
├── login/
│   ├── page.tsx                    ← Server Component (export metadata)
│   └── LoginClient.tsx             ← Client Component (form + AuthLayout)
├── forgot-password/
│   ├── page.tsx
│   └── ForgotPasswordClient.tsx
├── reset-password/
│   └── [token]/
│       ├── page.tsx
│       └── ResetPasswordClient.tsx
├── two-factor/
│   └── challenge/
│       ├── page.tsx
│       └── TwoFactorClient.tsx
├── dashboard/
│   ├── layout.tsx                  ← Admin layout (sidebar + header)
│   └── page.tsx
└── page.tsx                        ← redirect → /admin/dashboard
```

### Page Pattern (Server + Client Split)

Every auth page uses a thin Server Component + Client Component wrapper:

```tsx
// app/admin/forgot-password/page.tsx — Server Component (ASYNC!)
import type { Metadata } from 'next';
import { getServerLocale } from '@/lib/locale-server';
import ForgotPasswordClient from './ForgotPasswordClient';

export const metadata: Metadata = {
    title: 'Forgot Password — Admin Panel',
};

// ✅ No `force-dynamic` needed — cacheComponents + router.refresh() handles locale freshness

export default async function ForgotPasswordPage() {
    const { locale, messages } = await getServerLocale();
    return <ForgotPasswordClient initialLocale={locale} initialMessages={messages} />;
}
```

```tsx
// ForgotPasswordClient.tsx — "use client"
'use client';
import { LocaleProvider, SupportedLocale } from '@/features/auth/hooks/LocaleContext';
import AuthLayout from '@/components/login/AuthLayout';
import ForgotPasswordForm from '@/components/login/ForgotPasswordForm';

interface Props {
    initialLocale: SupportedLocale;
    initialMessages: Record<string, string>;
}

export default function ForgotPasswordClient({ initialLocale, initialMessages }: Props) {
    return (
        <LocaleProvider initialLocale={initialLocale} initialMessages={initialMessages}>
            <AuthLayout title="Forgot Password">
                <ForgotPasswordForm />
            </AuthLayout>
        </LocaleProvider>
    );
}
```

### Admin Config

```tsx
// src/config/admin.ts
export const ADMIN_PREFIX = process.env.NEXT_PUBLIC_ADMIN_PREFIX ?? 'admin';
```

> [!CAUTION]
> **DO NOT use route groups `(auth)` for admin auth pages.**
> Route groups remove the URL segment — `(auth)/login` → `/login` which breaks admin prefix.

### Auth Component Files

```
src/components/login/
├── AuthLayout.tsx           ← Gradient bg + logo + lang switcher + footer
├── LoginForm.tsx            ← Email + password + social buttons
├── ForgotPasswordForm.tsx   ← Email input → send reset link
├── ResetPasswordForm.tsx    ← New password + confirm
├── TwoFactorForm.tsx        ← OTP code / recovery code
├── Input.tsx                ← Custom input with icon + password toggle
├── LanguageSwitcher.tsx     ← Locale pill (EN/VI/JA/ZH)
└── SocialButton.tsx         ← Google / Facebook button

src/features/auth/
├── hooks/
│   └── LocaleContext.tsx    ← useLocale() provider + t() + router.refresh() + isPending
└── types.ts                 ← SupportedLocale type
```

---

## Locale Persistence (i18n)

> [!CAUTION]
> **LocaleContext MUST call `router.refresh()` after setting locale cookie.**
> Without this, the Client-Side Router Cache serves stale RSC payload.
> **With `cacheComponents: true` in next.config.ts, do NOT use `force-dynamic`.**

### 4-Layer Defense

| Layer | Mechanism | File |
|-------|-----------|------|
| 1. Cookie | `locale={vi};path=/;max-age=31536000;SameSite=Lax` | `LocaleContext.tsx` |
| 2. Server read | `cookies().get('locale')` via `await cookies()` | `locale-server.ts` |
| 3. Component caching | `cacheComponents: true` in `next.config.ts` | `next.config.ts` |
| 4. Client cache invalidation | `router.refresh()` inside `useTransition` | `LocaleContext.tsx` |

Full implementation: see [auth-login-template.md](reference/auth-login-template.md) §7 useLocale Hook.


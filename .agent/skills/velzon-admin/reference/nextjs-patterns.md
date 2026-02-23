# Next.js Patterns Reference

Pattern mapping from Velzon React-TS → Next.js App Router (TypeScript).
Use for BSWeb SaaS or any Next.js admin project.

---

## App Router Structure

```
src/
├── app/
│   ├── layout.tsx                      # Root layout (html, body, providers)
│   ├── globals.css
│   ├── page.tsx                        # Root page (redirect to dashboard)
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

## Middleware

```tsx
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

const ADMIN_PREFIX = process.env.NEXT_PUBLIC_ADMIN_PREFIX ?? 'admin';
const PUBLIC_PATHS = [
    `/${ADMIN_PREFIX}/login`,
    `/${ADMIN_PREFIX}/forgot-password`,
    `/${ADMIN_PREFIX}/reset-password`,
    `/${ADMIN_PREFIX}/two-factor`,
];

export function middleware(request: NextRequest) {
    const { pathname } = request.nextUrl;

    // Only protect admin routes
    if (!pathname.startsWith(`/${ADMIN_PREFIX}`)) return NextResponse.next();

    // Allow public auth pages
    if (PUBLIC_PATHS.some(p => pathname.startsWith(p))) return NextResponse.next();

    // Check auth (cookie/token based)
    const token = request.cookies.get('auth-token');
    if (!token) {
        return NextResponse.redirect(new URL(`/${ADMIN_PREFIX}/login`, request.url));
    }

    return NextResponse.next();
}

export const config = {
    matcher: ['/((?!api|_next/static|_next/image|favicon.ico|fonts|images).*)'],
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
// app/admin/forgot-password/page.tsx — Server Component
import type { Metadata } from 'next';
import ForgotPasswordClient from './ForgotPasswordClient';

export const metadata: Metadata = {
    title: 'Forgot Password — Admin Panel',
};

export default function ForgotPasswordPage() {
    return <ForgotPasswordClient />;
}
```

```tsx
// ForgotPasswordClient.tsx — "use client"
'use client';
import { LocaleProvider } from '@/features/auth/hooks/LocaleContext';
import AuthLayout from '@/components/login/AuthLayout';
import ForgotPasswordForm from '@/components/login/ForgotPasswordForm';

export default function ForgotPasswordClient() {
    return (
        <LocaleProvider>
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
│   └── LocaleContext.tsx    ← useLocale() provider + t() function
└── types.ts                 ← SupportedLocale type
```


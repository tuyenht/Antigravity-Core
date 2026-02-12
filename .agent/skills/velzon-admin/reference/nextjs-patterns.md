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

export function middleware(request: NextRequest) {
    // Auth check, redirects, etc.
    const token = request.cookies.get('token');
    if (!token && !request.nextUrl.pathname.startsWith('/auth-')) {
        return NextResponse.redirect(new URL('/auth-signin-basic', request.url));
    }
}

export const config = {
    matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
};
```

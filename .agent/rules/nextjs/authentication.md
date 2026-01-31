# Next.js Authentication & Authorization Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **Auth.js:** v5.x (NextAuth v5)  
> **Priority:** P0 - Load for all authentication tasks

---

You are an expert in Next.js authentication and authorization.

## Core Authentication Principles

- Use Auth.js (NextAuth.js v5) for authentication
- Implement server-side session validation
- Protect routes with middleware
- Follow OAuth 2.0 and OIDC standards

---

## 1) Auth.js v5 Complete Setup

### Installation & Configuration
```bash
# Install Auth.js v5
npm install next-auth@beta @auth/prisma-adapter
npm install bcryptjs
npm install -D @types/bcryptjs
```

```typescript
// ==========================================
// auth.ts (Root Configuration)
// ==========================================

import NextAuth from 'next-auth';
import { PrismaAdapter } from '@auth/prisma-adapter';
import { prisma } from '@/lib/prisma';
import Google from 'next-auth/providers/google';
import GitHub from 'next-auth/providers/github';
import Credentials from 'next-auth/providers/credentials';
import { compare } from 'bcryptjs';
import { z } from 'zod';

const LoginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

export const { handlers, signIn, signOut, auth } = NextAuth({
  adapter: PrismaAdapter(prisma),
  
  session: {
    strategy: 'jwt',  // Use JWT for edge compatibility
    maxAge: 30 * 24 * 60 * 60,  // 30 days
  },
  
  pages: {
    signIn: '/login',
    signOut: '/logout',
    error: '/auth/error',
    verifyRequest: '/auth/verify',
    newUser: '/onboarding',
  },
  
  providers: [
    // OAuth Providers
    Google({
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
      authorization: {
        params: {
          prompt: 'consent',
          access_type: 'offline',
          response_type: 'code',
        },
      },
    }),
    
    GitHub({
      clientId: process.env.GITHUB_CLIENT_ID!,
      clientSecret: process.env.GITHUB_CLIENT_SECRET!,
    }),
    
    // Credentials Provider
    Credentials({
      name: 'credentials',
      credentials: {
        email: { label: 'Email', type: 'email' },
        password: { label: 'Password', type: 'password' },
      },
      async authorize(credentials) {
        const validated = LoginSchema.safeParse(credentials);
        
        if (!validated.success) {
          return null;
        }
        
        const { email, password } = validated.data;
        
        const user = await prisma.user.findUnique({
          where: { email },
          select: {
            id: true,
            email: true,
            name: true,
            image: true,
            password: true,
            role: true,
            emailVerified: true,
          },
        });
        
        if (!user || !user.password) {
          return null;
        }
        
        const passwordValid = await compare(password, user.password);
        
        if (!passwordValid) {
          return null;
        }
        
        return {
          id: user.id,
          email: user.email,
          name: user.name,
          image: user.image,
          role: user.role,
        };
      },
    }),
  ],
  
  callbacks: {
    // Authorized callback for middleware
    authorized({ auth, request }) {
      const isLoggedIn = !!auth?.user;
      const isOnDashboard = request.nextUrl.pathname.startsWith('/dashboard');
      const isOnAdmin = request.nextUrl.pathname.startsWith('/admin');
      
      if (isOnAdmin) {
        return isLoggedIn && auth.user.role === 'ADMIN';
      }
      
      if (isOnDashboard) {
        return isLoggedIn;
      }
      
      return true;
    },
    
    // JWT callback - add custom data to token
    async jwt({ token, user, account, trigger, session }) {
      // Initial sign in
      if (user) {
        token.id = user.id;
        token.role = user.role || 'USER';
      }
      
      // Update session if triggered
      if (trigger === 'update' && session) {
        token.name = session.name;
        token.image = session.image;
      }
      
      // Refresh user data from database
      if (trigger === 'signIn' || trigger === 'update') {
        const dbUser = await prisma.user.findUnique({
          where: { id: token.id as string },
          select: { role: true, name: true, image: true },
        });
        
        if (dbUser) {
          token.role = dbUser.role;
          token.name = dbUser.name;
          token.image = dbUser.image;
        }
      }
      
      return token;
    },
    
    // Session callback - add custom data to session
    async session({ session, token }) {
      if (session.user) {
        session.user.id = token.id as string;
        session.user.role = token.role as string;
      }
      return session;
    },
    
    // Sign in callback - custom validation
    async signIn({ user, account, profile }) {
      // Block unverified email for OAuth
      if (account?.provider !== 'credentials') {
        if (!profile?.email_verified && account?.provider === 'google') {
          return false;
        }
      }
      
      return true;
    },
  },
  
  events: {
    async signIn({ user, account }) {
      console.log(`User signed in: ${user.email} via ${account?.provider}`);
    },
    async signOut({ token }) {
      console.log(`User signed out: ${token?.email}`);
    },
  },
});


// ==========================================
// Type Extensions
// ==========================================

// types/next-auth.d.ts
import { DefaultSession, DefaultUser } from 'next-auth';
import { JWT, DefaultJWT } from 'next-auth/jwt';

declare module 'next-auth' {
  interface Session {
    user: {
      id: string;
      role: string;
    } & DefaultSession['user'];
  }
  
  interface User extends DefaultUser {
    role: string;
  }
}

declare module 'next-auth/jwt' {
  interface JWT extends DefaultJWT {
    id: string;
    role: string;
  }
}
```

### Route Handler
```typescript
// app/api/auth/[...nextauth]/route.ts
import { handlers } from '@/auth';

export const { GET, POST } = handlers;
```

---

## 2) Middleware Protection

### Complete Middleware
```typescript
// middleware.ts
import { auth } from '@/auth';
import { NextResponse } from 'next/server';

// Routes configuration
const publicRoutes = [
  '/',
  '/login',
  '/register',
  '/forgot-password',
  '/reset-password',
  '/verify-email',
];

const authRoutes = [
  '/login',
  '/register',
];

const apiAuthPrefix = '/api/auth';

const adminRoutes = ['/admin'];

export default auth((req) => {
  const { nextUrl } = req;
  const isLoggedIn = !!req.auth;
  const userRole = req.auth?.user?.role;

  const isApiAuthRoute = nextUrl.pathname.startsWith(apiAuthPrefix);
  const isPublicRoute = publicRoutes.includes(nextUrl.pathname);
  const isAuthRoute = authRoutes.includes(nextUrl.pathname);
  const isAdminRoute = adminRoutes.some(route => 
    nextUrl.pathname.startsWith(route)
  );

  // Allow auth API routes
  if (isApiAuthRoute) {
    return NextResponse.next();
  }

  // Redirect logged-in users away from auth routes
  if (isAuthRoute) {
    if (isLoggedIn) {
      return NextResponse.redirect(new URL('/dashboard', nextUrl));
    }
    return NextResponse.next();
  }

  // Protect admin routes
  if (isAdminRoute) {
    if (!isLoggedIn) {
      const callbackUrl = encodeURIComponent(nextUrl.pathname);
      return NextResponse.redirect(
        new URL(`/login?callbackUrl=${callbackUrl}`, nextUrl)
      );
    }
    
    if (userRole !== 'ADMIN') {
      return NextResponse.redirect(new URL('/unauthorized', nextUrl));
    }
    
    return NextResponse.next();
  }

  // Protect non-public routes
  if (!isPublicRoute && !isLoggedIn) {
    const callbackUrl = encodeURIComponent(nextUrl.pathname + nextUrl.search);
    return NextResponse.redirect(
      new URL(`/login?callbackUrl=${callbackUrl}`, nextUrl)
    );
  }

  return NextResponse.next();
});

export const config = {
  matcher: [
    // Match all routes except static files and api
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
};
```

---

## 3) Server Components Auth

### Protected Server Component
```tsx
// ==========================================
// PROTECTED LAYOUT
// ==========================================

// app/(protected)/layout.tsx
import { auth } from '@/auth';
import { redirect } from 'next/navigation';
import { Sidebar } from '@/components/Sidebar';
import { Header } from '@/components/Header';

export default async function ProtectedLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const session = await auth();

  if (!session?.user) {
    redirect('/login');
  }

  return (
    <div className="flex h-screen">
      <Sidebar user={session.user} />
      <div className="flex-1 flex flex-col">
        <Header user={session.user} />
        <main className="flex-1 overflow-auto p-6">
          {children}
        </main>
      </div>
    </div>
  );
}


// ==========================================
// ROLE-PROTECTED PAGE
// ==========================================

// app/admin/page.tsx
import { auth } from '@/auth';
import { redirect } from 'next/navigation';

export default async function AdminPage() {
  const session = await auth();

  if (!session?.user) {
    redirect('/login');
  }

  if (session.user.role !== 'ADMIN') {
    redirect('/unauthorized');
  }

  // Fetch admin-only data
  const stats = await getAdminStats();

  return (
    <div>
      <h1>Admin Dashboard</h1>
      <AdminStats stats={stats} />
    </div>
  );
}


// ==========================================
// AUTH HELPER FUNCTIONS
// ==========================================

// lib/auth-helpers.ts
import { auth } from '@/auth';
import { redirect } from 'next/navigation';

export async function getCurrentUser() {
  const session = await auth();
  return session?.user;
}

export async function requireAuth() {
  const user = await getCurrentUser();
  
  if (!user) {
    redirect('/login');
  }
  
  return user;
}

export async function requireAdmin() {
  const user = await requireAuth();
  
  if (user.role !== 'ADMIN') {
    redirect('/unauthorized');
  }
  
  return user;
}

export async function requireRoles(allowedRoles: string[]) {
  const user = await requireAuth();
  
  if (!allowedRoles.includes(user.role)) {
    redirect('/unauthorized');
  }
  
  return user;
}
```

---

## 4) Client Components Auth

### Session Provider & Hooks
```tsx
// ==========================================
// SESSION PROVIDER
// ==========================================

// components/providers/SessionProvider.tsx
'use client';

import { SessionProvider as NextAuthSessionProvider } from 'next-auth/react';

export function SessionProvider({ children }: { children: React.ReactNode }) {
  return (
    <NextAuthSessionProvider>
      {children}
    </NextAuthSessionProvider>
  );
}

// app/layout.tsx
import { SessionProvider } from '@/components/providers/SessionProvider';

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <SessionProvider>
          {children}
        </SessionProvider>
      </body>
    </html>
  );
}


// ==========================================
// CLIENT AUTH COMPONENTS
// ==========================================

// components/auth/UserButton.tsx
'use client';

import { useSession, signOut } from 'next-auth/react';
import Image from 'next/image';
import Link from 'next/link';

export function UserButton() {
  const { data: session, status } = useSession();

  if (status === 'loading') {
    return <div className="w-10 h-10 rounded-full bg-gray-200 animate-pulse" />;
  }

  if (!session?.user) {
    return (
      <Link href="/login" className="btn btn-primary">
        Sign In
      </Link>
    );
  }

  return (
    <div className="dropdown dropdown-end">
      <label tabIndex={0} className="btn btn-ghost btn-circle avatar">
        <div className="w-10 rounded-full">
          <Image
            src={session.user.image || '/default-avatar.png'}
            alt={session.user.name || 'User'}
            width={40}
            height={40}
          />
        </div>
      </label>
      <ul
        tabIndex={0}
        className="dropdown-content menu p-2 shadow bg-base-100 rounded-box w-52"
      >
        <li className="menu-title">
          <span>{session.user.name}</span>
          <span className="text-xs text-gray-500">{session.user.email}</span>
        </li>
        <li>
          <Link href="/dashboard">Dashboard</Link>
        </li>
        <li>
          <Link href="/settings">Settings</Link>
        </li>
        {session.user.role === 'ADMIN' && (
          <li>
            <Link href="/admin">Admin</Link>
          </li>
        )}
        <li>
          <button onClick={() => signOut({ callbackUrl: '/' })}>
            Sign Out
          </button>
        </li>
      </ul>
    </div>
  );
}


// ==========================================
// PROTECTED CLIENT COMPONENT
// ==========================================

// components/auth/ProtectedContent.tsx
'use client';

import { useSession } from 'next-auth/react';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';

interface Props {
  children: React.ReactNode;
  requiredRoles?: string[];
  fallback?: React.ReactNode;
}

export function ProtectedContent({
  children,
  requiredRoles,
  fallback = null,
}: Props) {
  const { data: session, status } = useSession();
  const router = useRouter();

  useEffect(() => {
    if (status === 'unauthenticated') {
      router.push('/login');
    }
  }, [status, router]);

  if (status === 'loading') {
    return <div>Loading...</div>;
  }

  if (!session?.user) {
    return fallback;
  }

  if (requiredRoles && !requiredRoles.includes(session.user.role)) {
    return fallback;
  }

  return <>{children}</>;
}
```

---

## 5) Login & Register Forms

### Login Form
```tsx
// ==========================================
// LOGIN ACTIONS
// ==========================================

// app/actions/auth.ts
'use server';

import { signIn, signOut } from '@/auth';
import { AuthError } from 'next-auth';
import { z } from 'zod';
import { hash } from 'bcryptjs';
import { prisma } from '@/lib/prisma';

const LoginSchema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
});

const RegisterSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  confirmPassword: z.string(),
}).refine(data => data.password === data.confirmPassword, {
  message: 'Passwords do not match',
  path: ['confirmPassword'],
});

export type AuthState = {
  success: boolean;
  message: string;
  errors?: Record<string, string[]>;
};

export async function login(
  prevState: AuthState,
  formData: FormData
): Promise<AuthState> {
  const validated = LoginSchema.safeParse({
    email: formData.get('email'),
    password: formData.get('password'),
  });

  if (!validated.success) {
    return {
      success: false,
      message: 'Validation failed',
      errors: validated.error.flatten().fieldErrors,
    };
  }

  try {
    await signIn('credentials', {
      email: validated.data.email,
      password: validated.data.password,
      redirect: false,
    });

    return {
      success: true,
      message: 'Login successful',
    };
  } catch (error) {
    if (error instanceof AuthError) {
      switch (error.type) {
        case 'CredentialsSignin':
          return {
            success: false,
            message: 'Invalid email or password',
          };
        default:
          return {
            success: false,
            message: 'Something went wrong',
          };
      }
    }
    throw error;
  }
}

export async function register(
  prevState: AuthState,
  formData: FormData
): Promise<AuthState> {
  const validated = RegisterSchema.safeParse({
    name: formData.get('name'),
    email: formData.get('email'),
    password: formData.get('password'),
    confirmPassword: formData.get('confirmPassword'),
  });

  if (!validated.success) {
    return {
      success: false,
      message: 'Validation failed',
      errors: validated.error.flatten().fieldErrors,
    };
  }

  const { name, email, password } = validated.data;

  // Check existing user
  const existingUser = await prisma.user.findUnique({
    where: { email },
  });

  if (existingUser) {
    return {
      success: false,
      message: 'Email already registered',
      errors: { email: ['Email already registered'] },
    };
  }

  // Hash password
  const hashedPassword = await hash(password, 12);

  // Create user
  await prisma.user.create({
    data: {
      name,
      email,
      password: hashedPassword,
      role: 'USER',
    },
  });

  return {
    success: true,
    message: 'Registration successful! Please sign in.',
  };
}

export async function logout() {
  await signOut({ redirectTo: '/' });
}

export async function loginWithGoogle() {
  await signIn('google', { redirectTo: '/dashboard' });
}

export async function loginWithGitHub() {
  await signIn('github', { redirectTo: '/dashboard' });
}


// ==========================================
// LOGIN FORM COMPONENT
// ==========================================

// app/login/page.tsx
'use client';

import { useFormState, useFormStatus } from 'react-dom';
import { useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import Link from 'next/link';
import { login, loginWithGoogle, loginWithGitHub, AuthState } from '@/app/actions/auth';

function SubmitButton() {
  const { pending } = useFormStatus();
  
  return (
    <button type="submit" disabled={pending} className="btn btn-primary w-full">
      {pending ? 'Signing in...' : 'Sign In'}
    </button>
  );
}

export default function LoginPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const callbackUrl = searchParams.get('callbackUrl') || '/dashboard';
  
  const initialState: AuthState = { success: false, message: '' };
  const [state, formAction] = useFormState(login, initialState);

  useEffect(() => {
    if (state.success) {
      router.push(callbackUrl);
    }
  }, [state, router, callbackUrl]);

  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="card w-full max-w-md bg-base-100 shadow-xl">
        <div className="card-body">
          <h2 className="card-title text-2xl justify-center">Sign In</h2>

          {state.message && !state.success && (
            <div className="alert alert-error">
              <span>{state.message}</span>
            </div>
          )}

          {/* OAuth Buttons */}
          <form action={loginWithGoogle}>
            <button type="submit" className="btn btn-outline w-full">
              <GoogleIcon /> Continue with Google
            </button>
          </form>
          
          <form action={loginWithGitHub}>
            <button type="submit" className="btn btn-outline w-full">
              <GitHubIcon /> Continue with GitHub
            </button>
          </form>

          <div className="divider">OR</div>

          {/* Credentials Form */}
          <form action={formAction} className="space-y-4">
            <div>
              <label className="label">Email</label>
              <input
                type="email"
                name="email"
                className="input input-bordered w-full"
                required
              />
              {state.errors?.email && (
                <p className="text-error text-sm mt-1">
                  {state.errors.email[0]}
                </p>
              )}
            </div>

            <div>
              <label className="label">Password</label>
              <input
                type="password"
                name="password"
                className="input input-bordered w-full"
                required
              />
              {state.errors?.password && (
                <p className="text-error text-sm mt-1">
                  {state.errors.password[0]}
                </p>
              )}
            </div>

            <div className="flex justify-end">
              <Link href="/forgot-password" className="text-sm link">
                Forgot password?
              </Link>
            </div>

            <SubmitButton />
          </form>

          <p className="text-center text-sm mt-4">
            Don't have an account?{' '}
            <Link href="/register" className="link link-primary">
              Sign up
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
```

---

## 6) Password Reset Flow

### Complete Password Reset
```typescript
// ==========================================
// PASSWORD RESET ACTIONS
// ==========================================

// app/actions/password.ts
'use server';

import { z } from 'zod';
import { hash } from 'bcryptjs';
import { prisma } from '@/lib/prisma';
import { sendEmail } from '@/lib/email';
import crypto from 'crypto';

const ForgotPasswordSchema = z.object({
  email: z.string().email(),
});

const ResetPasswordSchema = z.object({
  token: z.string(),
  password: z.string().min(8),
  confirmPassword: z.string(),
}).refine(data => data.password === data.confirmPassword, {
  message: 'Passwords do not match',
  path: ['confirmPassword'],
});

export async function forgotPassword(
  prevState: AuthState,
  formData: FormData
): Promise<AuthState> {
  const validated = ForgotPasswordSchema.safeParse({
    email: formData.get('email'),
  });

  if (!validated.success) {
    return {
      success: false,
      message: 'Invalid email',
      errors: validated.error.flatten().fieldErrors,
    };
  }

  const { email } = validated.data;

  // Find user
  const user = await prisma.user.findUnique({
    where: { email },
  });

  // Always return success to prevent email enumeration
  if (!user) {
    return {
      success: true,
      message: 'If an account exists, you will receive a reset email.',
    };
  }

  // Generate token
  const token = crypto.randomBytes(32).toString('hex');
  const expires = new Date(Date.now() + 3600000);  // 1 hour

  // Delete existing tokens
  await prisma.passwordResetToken.deleteMany({
    where: { email },
  });

  // Create new token
  await prisma.passwordResetToken.create({
    data: {
      email,
      token,
      expires,
    },
  });

  // Send email
  const resetUrl = `${process.env.NEXT_PUBLIC_APP_URL}/reset-password?token=${token}`;
  
  await sendEmail({
    to: email,
    subject: 'Reset Your Password',
    html: `
      <h1>Password Reset</h1>
      <p>Click the link below to reset your password:</p>
      <a href="${resetUrl}">Reset Password</a>
      <p>This link expires in 1 hour.</p>
    `,
  });

  return {
    success: true,
    message: 'If an account exists, you will receive a reset email.',
  };
}

export async function resetPassword(
  prevState: AuthState,
  formData: FormData
): Promise<AuthState> {
  const validated = ResetPasswordSchema.safeParse({
    token: formData.get('token'),
    password: formData.get('password'),
    confirmPassword: formData.get('confirmPassword'),
  });

  if (!validated.success) {
    return {
      success: false,
      message: 'Validation failed',
      errors: validated.error.flatten().fieldErrors,
    };
  }

  const { token, password } = validated.data;

  // Find token
  const resetToken = await prisma.passwordResetToken.findFirst({
    where: {
      token,
      expires: { gt: new Date() },
    },
  });

  if (!resetToken) {
    return {
      success: false,
      message: 'Invalid or expired token',
    };
  }

  // Hash new password
  const hashedPassword = await hash(password, 12);

  // Update user password
  await prisma.user.update({
    where: { email: resetToken.email },
    data: { password: hashedPassword },
  });

  // Delete token
  await prisma.passwordResetToken.delete({
    where: { id: resetToken.id },
  });

  return {
    success: true,
    message: 'Password reset successful! Please sign in.',
  };
}
```

---

## 7) Role-Based Access Control

### RBAC Implementation
```typescript
// ==========================================
// RBAC TYPES
// ==========================================

// lib/rbac.ts
export type Role = 'USER' | 'MODERATOR' | 'ADMIN' | 'SUPER_ADMIN';

export type Permission =
  | 'read:own_profile'
  | 'update:own_profile'
  | 'read:users'
  | 'create:users'
  | 'update:users'
  | 'delete:users'
  | 'read:posts'
  | 'create:posts'
  | 'update:posts'
  | 'delete:posts'
  | 'moderate:content'
  | 'manage:settings';

const rolePermissions: Record<Role, Permission[]> = {
  USER: [
    'read:own_profile',
    'update:own_profile',
    'read:posts',
    'create:posts',
  ],
  MODERATOR: [
    'read:own_profile',
    'update:own_profile',
    'read:posts',
    'create:posts',
    'update:posts',
    'delete:posts',
    'moderate:content',
  ],
  ADMIN: [
    'read:own_profile',
    'update:own_profile',
    'read:users',
    'create:users',
    'update:users',
    'read:posts',
    'create:posts',
    'update:posts',
    'delete:posts',
    'moderate:content',
    'manage:settings',
  ],
  SUPER_ADMIN: [
    'read:own_profile',
    'update:own_profile',
    'read:users',
    'create:users',
    'update:users',
    'delete:users',
    'read:posts',
    'create:posts',
    'update:posts',
    'delete:posts',
    'moderate:content',
    'manage:settings',
  ],
};

export function hasPermission(role: Role, permission: Permission): boolean {
  return rolePermissions[role]?.includes(permission) ?? false;
}

export function hasRole(userRole: Role, requiredRoles: Role[]): boolean {
  return requiredRoles.includes(userRole);
}


// ==========================================
// SERVER ACTION WITH RBAC
// ==========================================

// app/actions/admin.ts
'use server';

import { auth } from '@/auth';
import { hasPermission, Role, Permission } from '@/lib/rbac';

async function requirePermission(permission: Permission) {
  const session = await auth();
  
  if (!session?.user) {
    throw new Error('Unauthorized');
  }
  
  if (!hasPermission(session.user.role as Role, permission)) {
    throw new Error('Forbidden');
  }
  
  return session.user;
}

export async function deleteUser(userId: string) {
  const admin = await requirePermission('delete:users');
  
  // Prevent self-deletion
  if (admin.id === userId) {
    throw new Error('Cannot delete yourself');
  }
  
  await prisma.user.delete({
    where: { id: userId },
  });
  
  revalidatePath('/admin/users');
}


// ==========================================
// RBAC CLIENT COMPONENT
// ==========================================

// components/auth/Can.tsx
'use client';

import { useSession } from 'next-auth/react';
import { hasPermission, Role, Permission } from '@/lib/rbac';

interface Props {
  permission: Permission;
  children: React.ReactNode;
  fallback?: React.ReactNode;
}

export function Can({ permission, children, fallback = null }: Props) {
  const { data: session } = useSession();
  
  if (!session?.user) {
    return <>{fallback}</>;
  }
  
  if (!hasPermission(session.user.role as Role, permission)) {
    return <>{fallback}</>;
  }
  
  return <>{children}</>;
}

// Usage
<Can permission="delete:users">
  <button onClick={handleDelete}>Delete User</button>
</Can>
```

---

## Best Practices Checklist

### Setup
- [ ] Auth.js v5 configured
- [ ] Session strategy defined (JWT/Database)
- [ ] Providers configured
- [ ] Types extended

### Security
- [ ] Password hashed with bcrypt
- [ ] Session validation on every request
- [ ] CSRF protection enabled
- [ ] Secure cookies configured
- [ ] Rate limiting implemented

### Protection
- [ ] Middleware configured
- [ ] Route guards in place
- [ ] RBAC implemented
- [ ] API routes protected

### UX
- [ ] Loading states
- [ ] Error messages
- [ ] Redirect after login
- [ ] Session status display

---

**References:**
- [Auth.js Documentation](https://authjs.dev/)
- [NextAuth.js v5 Guide](https://authjs.dev/getting-started/installation)
- [OWASP Authentication](https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/04-Authentication_Testing/)

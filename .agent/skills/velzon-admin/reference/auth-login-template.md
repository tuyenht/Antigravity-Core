# Auth Login Template — BaoSon Reference Design

> **Source:** `baoson-platform-core` login screen  
> **Route:** `/{adminPrefix}/login` (default `adminPrefix` = `"admin"`)  
> **Stack:** Tailwind CSS + Glassmorphism  
> **Font:** Inter (Latin/Vietnamese) + Noto Sans JP (日本語) + Noto Sans SC (中文)  
> **Default Logo:** `https://baoson.net/wp-content/uploads/2021/06/logo-bao-son.png`

---

## 🚨 Pixel-Perfect Mandate

**This template is the SINGLE SOURCE OF TRUTH for admin login pages.**

Regardless of the target language/framework (React, Next.js, Vue, Laravel Blade, HTML, etc.), the generated login page MUST be **visually identical** to the BaoSon reference design:

1. **Same gradient background** — `from-sky-700 via-blue-600 to-slate-800`, animated
2. **Same glass card** — `rgba(255,255,255,0.98)`, `blur(40px)`, `padding: 35px`, `border-radius: 21px`
3. **Same input style** — SVG icons, `@` symbol, eye toggle, exact focus ring
4. **Same button** — `bg-blue-600`, arrow icon, hover lift effect
5. **Same social buttons** — Google (4-color logo) + Facebook (blue logo), 2-column grid
6. **Same language switcher** — glass pill, EN/VI/JA/ZH, top-right on desktop
7. **Same logo** — centered above card, `h-16 md:h-20`, `drop-shadow-2xl brightness-110`
8. **Same footer** — `© {year} BaoSon Ads. All rights reserved.` in `text-white/40`
9. **Same decorative orbs** — `cyan-400/20` top-left + `blue-500/10` bottom-right
10. **Same i18n** — all 15 keys × 4 locales, instant locale switch (no page reload)

> **If the output does not look identical to the reference screenshot, the implementation is WRONG.**

---

## Default Branding

| Property | Default Value | Configurable |
|----------|---------------|-------------|
| **Logo URL** | `https://baoson.net/wp-content/uploads/2021/06/logo-bao-son.png` | Yes — via `{logoUrl}` variable |
| **Logo alt** | `Bao Son Logo` | Yes — via `{appName}` |
| **Logo link** | `/{adminPrefix}/dashboard` | Yes — via admin prefix config |
| **Footer company** | `BaoSon Ads` | Yes — via `{companyName}` variable |
| **Footer URL** | `https://baoson.net` | Yes — via `{companyUrl}` variable |
| **Footer text** | `© {year} {companyName}. All rights reserved.` | Pattern fixed |
| **Admin prefix** | `admin` | Yes — via config/env |

---

## Design Spec

### Layout Structure

```
┌──────────────────────────────────────────────────────────────────┐
│  Animated Gradient Background (sky-700 → blue-600 → slate-800)   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │  Decorative Blur Orbs (cyan-400/20 + blue-500/10)          │  │
│  │                                                            │  │
│  │         [Language Switcher: EN VI JA ZH]  ← top-right      │  │
│  │                                                            │  │
│  │              ┌─────── Logo ───────┐                        │  │
│  │              │  {appLogo}         │                        │  │
│  │              └────────────────────┘                        │  │
│  │                                                            │  │
│  │     ┌──────────── Glass Card ────────────────┐             │  │
│  │     │  System Login (h2, gradient text)       │             │  │
│  │     │                                         │             │  │
│  │     │  Account    [👤 email@...          @]   │             │  │
│  │     │  Password   [🔒 ••••••••          👁]   │             │  │
│  │     │                      Forgot password?   │             │  │
│  │     │                                         │             │  │
│  │     │  [████████ Sign In → ████████]          │             │  │
│  │     │                                         │             │  │
│  │     │  ──────── Quick Login ────────           │             │  │
│  │     │  [ G Google ]  [ f Facebook ]           │             │  │
│  │     └─────────────────────────────────────────┘             │  │
│  │                                                            │  │
│  │           © {year} {appName}. All rights reserved.         │  │
│  └────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
```

### Design Tokens

> [!CAUTION]
> **Root font-size MUST be `14px`**, not the browser default `16px`.  
> Without this, ALL rem-based Tailwind sizes (max-w-md, py-3, etc.) render **14% larger**, causing a ~56px card width difference.

| Token | Value | Notes |
|-------|-------|-------|
| **Root font-size** | `html { font-size: 14px; }` | 🚨 **CRITICAL** — affects all rem-based sizes |
| **Background Gradient** | `from-sky-700 via-blue-600 to-slate-800` | Animated 12s ease infinite, `background-size: 200% 200%` |
| **Blur Orb 1** | `bg-cyan-400/20`, 64×64 (w-64 h-64), `blur-3xl`, `animate-pulse` | Top-left |
| **Blur Orb 2** | `bg-blue-500/10`, 96×96 (w-96 h-96), `blur-3xl`, `animate-bounce 12s` | Bottom-right |
| **Glass Card bg** | `rgba(255, 255, 255, 0.98)` | |
| **Glass backdrop** | `blur(40px)` | |
| **Glass border** | `1px solid rgba(255, 255, 255, 1)` | |
| **Glass shadow** | `0 25px 50px -12px rgba(0, 0, 0, 0.25)` | |
| **Glass padding** | `35px` | Override Tailwind `p-10` (= 40px at 16px root) |
| **Glass border-radius** | `21px` | Override Tailwind `rounded-3xl` |
| **Title font** | `22px / 26px`, `font-weight: 800`, gradient text `from-blue-700 to-slate-700` | |
| **Label font** | `14px / 21px`, `font-weight: 600`, `text-slate-700` | |
| **Input bg** | `bg-slate-50`, border `border-slate-200`, rounded `rounded-xl` | |
| **Input focus** | `bg-white`, `border-blue-600`, `ring-4 ring-blue-600/10` | |
| **Input padding** | `10.5px` top/bottom, `22.5px` line-height | |
| **Button** | `bg-blue-600`, `hover:bg-blue-700`, `rounded-xl`, `py-3`, `shadow-lg shadow-blue-500/20` | |
| **Social buttons** | White bg, `border-slate-200`, `rounded-xl`, `shadow-sm` | 2-column grid |
| **Footer text** | `text-white/40`, `text-xs` | |
| **Content max-width** | `max-w-sm md:max-w-md` | At 14px root: `max-w-md = 28rem = 392px` |

### Language Switcher Spec

| Property | Value |
|----------|-------|
| Container | `bg-slate-900/30`, `backdrop-blur-xl`, `p-1.5`, `rounded-full`, `border border-white/10` |
| Button (active) | `bg-white`, `text-blue-700`, `shadow-lg`, `scale-105` |
| Button (inactive) | `text-white/60`, `hover:text-white`, `hover:bg-white/10` |
| Button size | `w-9 h-9` (desktop), `w-7 h-7` (mobile) |
| Position | Mobile: centered above logo. Desktop: `absolute top-6 right-6` |
| Default locales | `['en', 'vi', 'ja', 'zh']` (configurable) |

---

## Configurable Admin Prefix

> [!CAUTION]
> **ALL admin routes MUST be under `/{adminPrefix}/` prefix. NEVER at root `/`.**  
> ❌ WRONG: `/login`, `/users`, `/dashboard`  
> ✅ CORRECT: `/admin/login`, `/admin/users`, `/admin/dashboard`

The route prefix is **dynamic** — default `"admin"`, configurable per project:

```typescript
// Configuration
const ADMIN_PREFIX = process.env.ADMIN_PREFIX ?? 'admin';

// ALL admin routes MUST start with /{ADMIN_PREFIX}/
`/${ADMIN_PREFIX}/login`             // Login page
`/${ADMIN_PREFIX}/login`             // Login POST (same URL, POST method)
`/${ADMIN_PREFIX}/password/request`  // Forgot password
`/${ADMIN_PREFIX}/oauth/{provider}`  // OAuth redirect
`/${ADMIN_PREFIX}/dashboard`         // After login redirect
`/${ADMIN_PREFIX}/users`             // User management
`/${ADMIN_PREFIX}/settings`          // Settings
// ... ALL admin pages follow this pattern
```

### Per-Framework Routing

| Framework | How to Set Admin Prefix | Route File |
|-----------|------------------------|------------|
| **Laravel** | `config('admin.prefix', 'admin')` | `routes/admin.php` with `Route::prefix()` |
| **Next.js** | `NEXT_PUBLIC_ADMIN_PREFIX=admin` in `.env` | `app/(admin)/admin/login/page.tsx` |
| **Vue/Nuxt** | Router `base` option or `VITE_ADMIN_PREFIX` | `router/admin.ts` |
| **Express** | `app.use('/admin', adminRouter)` | `routes/admin.ts` |
| **HTML** | Static folder `/{admin}/` | `admin/login.html` |

---

## Component Architecture

### File Structure (per stack)

> [!IMPORTANT]
> **i18n MUST be separate files per locale**, NOT inline constants in components.

```
{auth-pages-dir}/
├── Login.{ext}                ← Login page (this template)
├── ForgotPassword.{ext}       ← Forgot password form
├── ResetPassword.{ext}        ← Reset password form
├── layouts/
│   └── AuthLayout.{ext}       ← Shared auth layout (gradient + logo + footer)
├── components/
│   ├── Input.{ext}            ← Custom input with icon + password toggle
│   └── LanguageSwitcher.{ext} ← Locale selector pill
└── locales/                   ← 🚨 SEPARATE FILES per locale
    ├── en.json                ← English translations
    ├── vi.json                ← Vietnamese translations  
    ├── ja.json                ← Japanese translations
    └── zh.json                ← Chinese translations
```
```

---

## Reference Code: React + Tailwind (Primary)

### 1. AuthLayout

```tsx
interface AuthLayoutProps {
    children: ReactNode;
    title: string;
}

export default function AuthLayout({ children, title }: AuthLayoutProps) {
    const LOGO_URL = '{logoUrl}' || 'https://baoson.net/wp-content/uploads/2021/06/logo-bao-son.png';
    const COMPANY_NAME = '{companyName}' || 'BaoSon Ads';
    const COMPANY_URL = '{companyUrl}' || 'https://baoson.net';

    return (
        <>
            <Head title={title} />
            <div className="min-h-[100dvh] w-full flex flex-col items-center justify-center px-8 py-6 md:p-4 animate-gradient bg-gradient-to-br from-sky-700 via-blue-600 to-slate-800 relative overflow-hidden">
                {/* Decorative Blur Orbs */}
                <div className="absolute top-20 left-20 w-64 h-64 bg-cyan-400/20 rounded-full blur-3xl animate-pulse pointer-events-none" />
                <div className="absolute bottom-20 right-20 w-96 h-96 bg-blue-500/10 rounded-full blur-3xl animate-bounce duration-[12s] pointer-events-none" />

                {/* Language Switcher */}
                <LanguageSwitcher />

                <main className="relative w-full max-w-sm md:max-w-md flex flex-col items-center z-10">
                    {/* Logo - MUST match: h-16 md:h-20, drop-shadow-2xl, brightness-110 */}
                    <div className="mb-4 md:mb-8 hover:scale-105 transition-transform duration-500">
                        <a href={`/${ADMIN_PREFIX}/dashboard`} aria-label={appName ?? 'Bao Son'}>
                            <img
                                src={LOGO_URL}
                                alt="Bao Son Logo"
                                className="h-16 md:h-20 w-auto drop-shadow-2xl filter brightness-110"
                            />
                        </a>
                    </div>

                    {children}

                    {/* Footer - MUST match: © {year} BaoSon Ads. All rights reserved. */}
                    <footer className="mt-4 md:mt-8 text-center text-white/40 text-xs font-medium tracking-wide">
                        <p>
                            &copy; {new Date().getFullYear()}{' '}
                            <a href={COMPANY_URL} target="_blank" rel="noopener noreferrer"
                               className="hover:text-white transition-colors">
                                {COMPANY_NAME}
                            </a>
                            . All rights reserved.
                        </p>
                    </footer>
                </main>
            </div>
        </>
    );
}
```

### 2. Glass CSS

```css
@keyframes gradient {
    0% { background-position: 0% 50%; }
    50% { background-position: 100% 50%; }
    100% { background-position: 0% 50%; }
}

.animate-gradient {
    background-size: 200% 200%;
    animation: gradient 12s ease infinite;
}

.glass {
    background: rgba(255, 255, 255, 0.98);
    backdrop-filter: blur(40px);
    -webkit-backdrop-filter: blur(40px);
    border: 1px solid rgba(255, 255, 255, 1);
    box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
    padding: 35px !important;
    border-radius: 21px !important;
}

/* Form overrides */
input[type="email"],
input[type="password"] {
    padding-top: 10.5px !important;
    padding-bottom: 10.5px !important;
    line-height: 22.5px !important;
}

h2.text-3xl {
    font-size: 22px !important;
    line-height: 26px !important;
    font-weight: 800 !important;
}

label.text-base {
    font-size: 14px !important;
    line-height: 21px !important;
}
```

### 3. Login Card

```tsx
<div className="glass w-full rounded-3xl p-6 md:p-10 shadow-2xl relative">
    {/* Title */}
    <h2 className="text-3xl font-extrabold text-transparent bg-clip-text bg-gradient-to-r from-blue-700 to-slate-700 tracking-tight mb-6">
        {t('auth.welcome')}  {/* "System Login" */}
    </h2>

    <form onSubmit={submit} className="space-y-4">
        {/* Email Input */}
        <Input label={t('auth.email_label')} placeholder="your-name@gmail.com"
               type="email" showAtSymbol={true} icon={<UserIcon />} />

        {/* Password Input + Forgot Link */}
        <div>
            <Input label={t('auth.password_label')} placeholder="••••••••"
                   isPassword icon={<LockIcon />} />
            <div className="flex justify-end mt-2">
                <a href={forgotPasswordUrl}
                   className="text-sm font-medium text-blue-600 hover:text-blue-700 hover:underline">
                    {t('auth.forgot_password')}
                </a>
            </div>
        </div>

        {/* Submit Button */}
        <button type="submit" className="w-full py-3 md:py-3.5 rounded-xl font-semibold text-[15px]
            bg-blue-600 text-white hover:bg-blue-700 hover:-translate-y-0.5
            shadow-lg shadow-blue-500/20 flex items-center justify-center gap-2 transition-all">
            <span>{t('auth.sign_in')}</span>
            <ArrowRightIcon />
        </button>
    </form>

    {/* Social Divider */}
    <div className="relative my-6">
        <div className="absolute inset-0 flex items-center">
            <div className="w-full border-t border-slate-100" />
        </div>
        <div className="relative flex justify-center">
            <span className="bg-white px-4 text-xs font-medium text-slate-400">
                {t('auth.or_continue')}  {/* "Quick Login" */}
            </span>
        </div>
    </div>

    {/* Social Buttons (2-col) */}
    <div className="grid grid-cols-2 gap-3">
        <SocialButton provider="google" icon={<GoogleIcon />} />
        <SocialButton provider="facebook" icon={<FacebookIcon />} />
    </div>
</div>
```

### 4. Input Component

```tsx
interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
    label: string;
    icon?: React.ReactNode;
    isPassword?: boolean;
    showAtSymbol?: boolean;
}

const Input: React.FC<InputProps> = ({ label, icon, isPassword, showAtSymbol, disabled, ...props }) => {
    const [showPass, setShowPass] = useState(false);

    return (
        <div className="space-y-1.5">
            <label className="block text-base font-semibold text-slate-700 ml-1">{label}</label>
            <div className="relative group">
                {/* Left Icon */}
                {icon && (
                    <div className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-blue-600 transition-colors pointer-events-none">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="w-5 h-5">
                            {icon}
                        </svg>
                    </div>
                )}

                <input {...props} disabled={disabled}
                    type={isPassword ? (showPass ? 'text' : 'password') : props.type}
                    className={`w-full ${icon ? 'pl-11' : 'pl-3'} ${(isPassword || showAtSymbol) ? 'pr-11' : 'pr-3'} py-3
                        bg-slate-50 border border-slate-200 rounded-xl text-slate-900 text-[15px] font-medium
                        placeholder:text-slate-400 outline-none
                        focus:bg-white focus:border-blue-600 focus:ring-4 focus:ring-blue-600/10 transition-all`}
                />

                {/* Right: @ symbol or eye toggle */}
                {showAtSymbol && <div className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 text-sm font-semibold">@</div>}
                {isPassword && (
                    <button type="button" onClick={() => setShowPass(!showPass)}
                        className="absolute right-3 top-1/2 -translate-y-1/2 w-8 h-8 flex items-center justify-center text-slate-400 hover:text-blue-600 rounded-lg transition-all">
                        {showPass ? <EyeOffIcon /> : <EyeIcon />}
                    </button>
                )}
            </div>
        </div>
    );
};
```

### 5. LanguageSwitcher

```tsx
const locales = ['en', 'vi', 'ja', 'zh']; // Configurable

export default function LanguageSwitcher() {
    const { locale, setLocale } = useLocale();

    return (
        <div className="relative w-full flex justify-center mb-4 md:mb-6 z-50 md:absolute md:top-6 md:right-6 md:w-auto">
            <div className="flex gap-1 bg-slate-900/30 backdrop-blur-xl p-1 md:p-1.5 rounded-full border border-white/10 shadow-2xl">
                {locales.map((l) => (
                    <button key={l} onClick={() => setLocale(l)}
                        className={`w-7 h-7 md:w-9 md:h-9 flex items-center justify-center text-[10px] md:text-xs
                            font-bold rounded-full transition-all duration-300 cursor-pointer
                            ${locale === l
                                ? 'bg-white text-blue-700 shadow-lg scale-105'
                                : 'text-white/60 hover:text-white hover:bg-white/10'}`}>
                        {l.toUpperCase()}
                    </button>
                ))}
            </div>
        </div>
    );
}
```

---

## SVG Icons Reference

### User Icon (Account field)
```html
<path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
<circle strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" cx="12" cy="7" r="4" />
```

### Lock Icon (Password field)
```html
<rect strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" x="3" y="11" width="18" height="11" rx="2" ry="2" />
<path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M7 11V7a5 5 0 0 1 10 0v4" />
```

### Arrow Right (Submit button)
```html
<path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
```

### Eye Icon (Password toggle — show)
```html
<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
<circle cx="12" cy="12" r="3" />
```

### Eye Off Icon (Password toggle — hide)
```html
<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24" />
<line x1="1" y1="1" x2="23" y2="23" />
```

### Google Logo (Social button)
```html
<path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4" />
<path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853" />
<path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z" fill="#FBBC05" />
<path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335" />
```

### Facebook Logo (Social button)
```html
<path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z" fill="#1877F2" />
```

---

## Font System

The login uses a **logical font family** `"UI"` with CJK-aware weight overrides:

```css
/* Logical Font Family: Inter (Latin/VI) + Noto Sans JP/SC (CJK) */
@font-face {
  font-family: "UI";
  src: url("/fonts/Inter-roman.woff2") format("woff2");
  font-style: normal;
  font-weight: 100 900;
  font-display: swap;
  unicode-range: U+0000-00FF, U+0100-024F, U+0300-036F, U+1E00-1EFF, U+20AB;
  ascent-override: 90%; descent-override: 22%; line-gap-override: 0%; size-adjust: 105%;
}

@font-face {
  font-family: "UI";
  src: url("/fonts/NotoSansJP.woff2") format("woff2");
  font-style: normal;
  font-weight: 200 900;
  font-display: swap;
  unicode-range: U+3040-309F, U+30A0-30FF, U+4E00-9FFF, U+FF00-FFEF;
}

@font-face {
  font-family: "UI";
  src: url("/fonts/NotoSansSC.woff2") format("woff2");
  font-style: normal;
  font-weight: 200 900;
  font-display: swap;
  unicode-range: U+3400-4DBF, U+4E00-9FFF, U+FF00-FFEF;
}

:root {
  --font-ui: "UI", system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
  --ui-weight: 400;
  --ui-heading-weight: 700;
}

/* Chinese headings need stronger weight */
:lang(zh), :lang(zh-CN), html[lang|="zh"] {
  --ui-heading-weight: 800;
}
```

**Required font files:** `Inter-roman.woff2`, `Inter-italic.woff2`, `NotoSansJP.woff2`, `NotoSansSC.woff2`

---

## Locale Infrastructure

### LocaleContext (React)

The login requires a `LocaleProvider` wrapping the auth pages:

```tsx
// LocaleContext provides: { locale, setLocale, syncLocale }
// - locale: current SupportedLocale ('en' | 'vi' | 'ja' | 'zh')
// - setLocale: instant UI update + debounced server save (300ms)
// - Cookie: sets 'locale' cookie immediately for server-side rendering
// - HTML lang: updates document.documentElement.lang (zh → 'zh-CN')
```

**Key behaviors:**
- Locale change is **instant** (no page reload)
- Cookie `locale={value}` is set immediately so form submissions use correct locale
- Server save is **debounced 300ms** via axios POST to `/{adminPrefix}/locale`
- `userChangedLocaleRef` prevents server sync from overriding user's manual choice

---

## i18n Keys (Complete — 17 keys × 4 locales)

> [!CAUTION]
> **Translations MUST be in separate JSON files per locale** (`en.json`, `vi.json`, `ja.json`, `zh.json`).  
> **NEVER hardcode translations inline** in component files as `const translations = { ... }`.  
> Load via `import`, `fetch`, or i18n library (e.g., `next-intl`, `react-i18next`, Laravel `__()`).

### File format: `locales/{locale}.json`

```json
// locales/en.json
{
    "auth.welcome": "System Login",
    "auth.email_label": "Account",
    "auth.email_placeholder": "your-name@gmail.com",
    "auth.password_label": "Password",
    "auth.password_placeholder": "••••••••",
    "auth.forgot_password": "Forgot password?",
    "auth.sign_in": "Sign In",
    "auth.processing": "Processing...",
    "auth.or_continue": "Quick Login",
    "auth.login_with_google": "Login with Google",
    "auth.login_with_facebook": "Login with Facebook",
    "auth.email_error": "Please enter a valid email address",
    "auth.password_error": "Password must be at least 6 characters",
    "auth.google_login_not_enabled": "Google login is not enabled in ENV",
    "auth.facebook_login_not_enabled": "Facebook login is not enabled in ENV",
    "auth.socialite_not_installed": "Social login is enabled via ENV but server has not installed laravel/socialite.",
    "auth.privacy": "Privacy",
    "auth.terms": "Terms"
}
```

### Complete Translation Table

| Key | EN | VI | JA | ZH |
|-----|----|----|----|----|  
| `auth.welcome` | System Login | Đăng nhập Hệ thống | システムログイン | 系统登录 |
| `auth.email_label` | Account | Tài khoản | アカウント | 账号 |
| `auth.email_placeholder` | your-name@gmail.com | ten-ban@gmail.com | your-name@gmail.com | your-name@gmail.com |
| `auth.password_label` | Password | Mật khẩu | パスワード | 密码 |
| `auth.password_placeholder` | •••••••• | •••••••• | •••••••• | •••••••• |
| `auth.forgot_password` | Forgot password? | Quên mật khẩu? | パスワードを忘れた？ | 忘记密码？ |
| `auth.sign_in` | Sign In | Đăng nhập | ログイン | 登录 |
| `auth.processing` | Processing... | Đang xử lý... | 処理中... | 处理中... |
| `auth.or_continue` | Quick Login | Đăng nhập nhanh | クイックログイン | 快捷登录 |
| `auth.login_with_google` | Login with Google | Đăng nhập với Google | Googleでログイン | 使用Google登录 |
| `auth.login_with_facebook` | Login with Facebook | Đăng nhập với Facebook | Facebookでログイン | 使用Facebook登录 |
| `auth.email_error` | Please enter a valid email address | Vui lòng nhập email hợp lệ | 有効なメールアドレスを入力してください | 请输入有效的电子邮件地址 |
| `auth.password_error` | Password must be at least 6 characters | Mật khẩu phải có ít nhất 6 ký tự | パスワードは6文字以上です | 密码至少6个字符 |
| `auth.google_login_not_enabled` | Google login is not enabled in ENV | Google login chưa được bật trong ENV | GoogleログインはENVで有効になっていません | Google登录未在ENV中启用 |
| `auth.facebook_login_not_enabled` | Facebook login is not enabled in ENV | Facebook login chưa được bật trong ENV | FacebookログインはENVで有効になっていません | Facebook登录未在ENV中启用 |
| `auth.socialite_not_installed` | Social login is enabled via ENV but server has not installed laravel/socialite. | Social login đang bật bằng ENV nhưng server chưa cài laravel/socialite. | SocialログインはENVで有効になっていますが、サーバーにlaravel/socialiteがインストールされていません。 | Social登录已通过ENV启用，但服务器未安装laravel/socialite。 |
| `auth.privacy` | Privacy | Bảo mật | プライバシー | 隐私 |
| `auth.terms` | Terms | Điều khoản | 規約 | 条款 |

---

## Complete Auth System Spec

> [!IMPORTANT]
> The admin panel does NOT just include a login form. It includes a **complete authentication system** with all screens, flows, and backend logic listed below.

### Auth Pages (5 screens)

| # | Page | Route | Method | Description |
|---|------|-------|--------|-------------|
| 1 | **Login** | `/{adminPrefix}/login` | GET | Glass card login form (this template) |
| 2 | **Forgot Password** | `/{adminPrefix}/forgot-password` | GET | Email input → send reset link |
| 3 | **Reset Password** | `/{adminPrefix}/reset-password/{token}` | GET | New password + confirm password |
| 4 | **Two-Factor Challenge** | `/{adminPrefix}/two-factor/challenge` | GET | 2FA code or recovery code input |
| 5 | **Logout** | `/{adminPrefix}/logout` | POST | No page — session invalidation + redirect to login |

### Complete Route Table (14 routes)

```
# Guest routes (middleware: guest) — NO authentication required
GET  /{adminPrefix}/login                         → Login page
POST /{adminPrefix}/login                         → Login submit (validate + auth)
GET  /{adminPrefix}/forgot-password               → Forgot password form
POST /{adminPrefix}/forgot-password               → Send reset email
GET  /{adminPrefix}/reset-password/{token}         → Reset password form
POST /{adminPrefix}/reset-password                 → Update password
GET  /{adminPrefix}/two-factor/challenge           → 2FA challenge form
POST /{adminPrefix}/two-factor/challenge           → 2FA verify
GET  /{adminPrefix}/oauth/{provider}/redirect      → OAuth redirect (google|facebook)
GET  /{adminPrefix}/oauth/{provider}/callback      → OAuth callback

# Auth routes (middleware: auth) — REQUIRES authentication
POST /{adminPrefix}/logout                         → Logout
GET  /{adminPrefix}/security/two-factor            → 2FA settings page
POST /{adminPrefix}/security/two-factor/enable     → Enable 2FA
POST /{adminPrefix}/security/two-factor/confirm    → Confirm 2FA setup
POST /{adminPrefix}/security/two-factor/disable    → Disable 2FA
POST /{adminPrefix}/security/two-factor/recovery-codes → Regenerate recovery codes

# Redirect aliases
GET  /login  → redirect to /{adminPrefix}/login
GET  /       → redirect to /{adminPrefix}
```

### All Screens Use AuthLayout

All auth screens (Login, ForgotPassword, ResetPassword, TwoFactorChallenge) **MUST** use the same `AuthLayout` with the gradient background, logo, language switcher, and footer. The glass card style MUST be consistent.

---

## OAuth Flow (Google / Facebook)

### Environment Configuration

```env
# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_REDIRECT_URI=${APP_URL}/{adminPrefix}/oauth/google/callback
GOOGLE_ENABLED=true

# Facebook OAuth
FACEBOOK_CLIENT_ID=your-facebook-app-id
FACEBOOK_CLIENT_SECRET=your-facebook-app-secret
FACEBOOK_REDIRECT_URI=${APP_URL}/{adminPrefix}/oauth/facebook/callback
FACEBOOK_ENABLED=true
```

### OAuth Flow Diagram

```
User clicks "Google" / "Facebook" button
    │
    ▼
GET /{adminPrefix}/oauth/{provider}/redirect
    ├── Rate limit check (10 attempts/hour per IP)
    ├── Verify provider is allowed (google | facebook)
    ├── Verify provider is enabled in ENV
    ├── Verify Socialite package is installed
    └── Redirect to provider's authorization URL
    │
    ▼
User authorizes on Google/Facebook
    │
    ▼
GET /{adminPrefix}/oauth/{provider}/callback
    ├── Rate limit check
    ├── Get user info from provider (email, name)
    ├── If email missing → redirect to login with error
    ├── Find or create user by email
    │   ├── Existing user → update name if changed
    │   └── New user → create with random password
    ├── Mark email as verified
    ├── Auth::login(user, remember: true)
    ├── Regenerate session
    ├── Clear rate limit on success
    ├── Audit log: oauth.callback_success
    └── Redirect to /{adminPrefix}/dashboard
```

### Key OAuth Rules

1. **Rate limiting**: 10 attempts per hour per IP per provider
2. **Audit logging**: Every OAuth action is logged (redirect, success, failure)
3. **Auto-create users**: If email not found, create new user with random password
4. **Auto-verify email**: OAuth users automatically get `email_verified_at` set
5. **Remember me**: Always enabled for OAuth logins
6. **Error handling**: All errors redirect back to login with flash message

---

## Logout Flow

```
POST /{adminPrefix}/logout (requires auth middleware)
    ├── Audit log: auth.logout
    ├── Auth::guard('web')->logout()
    ├── Session invalidate + regenerate CSRF token
    └── Redirect to /{adminPrefix}/login
```

**Implementation requirements:**
- Logout MUST be a POST request (never GET — CSRF protection)
- Session MUST be fully invalidated (not just cookie cleared)
- CSRF token MUST be regenerated after logout
- Redirect MUST go to `/{adminPrefix}/login` (not root `/`)

---

## Login Flow (with 2FA)

```
POST /{adminPrefix}/login
    ├── Validate: email (required, email), password (required, string)
    ├── Rate limit: 5 attempts per 60s per email+IP
    │   └── Throttled → throw 429 with seconds remaining
    ├── Find user by email
    ├── Validate password
    │   └── Failed → rate limit hit + audit log + error
    ├── Check 2FA enabled?
    │   ├── YES → store user_id in session → redirect to /two-factor/challenge
    │   └── NO  → Auth::login(user, remember) → redirect to /dashboard
    ├── Regenerate session
    └── Audit log: auth.login_success
```

### Two-Factor Challenge Screen

Uses the **same glass card design** as Login. Features:
- **Code input** (6 digits from Authenticator app) with clock icon
- **Recovery code input** (fallback, e.g. `ABCDE-FGHIJ`) with recovery icon
- Only one field can have a value at a time (mutually exclusive)
- Same blue submit button with arrow icon

---

## Additional i18n Keys (for all auth screens)

Add these keys to **each locale file** (`en.json`, `vi.json`, `ja.json`, `zh.json`):

| Key | EN | VI |
|-----|----|----|
| `auth.forgot_password_title` | Forgot Password | Quên mật khẩu |
| `auth.forgot_password_subtitle` | Enter your email to receive a reset link | Nhập email để nhận link đặt lại mật khẩu |
| `auth.send_reset_link` | Send Reset Link | Gửi link đặt lại |
| `auth.sending` | Sending... | Đang gửi... |
| `auth.back_to_login` | Back to Login | Quay lại đăng nhập |
| `auth.reset_password_title` | Reset Password | Đặt lại mật khẩu |
| `auth.reset_password_subtitle` | Create a new password for your account | Tạo mật khẩu mới cho tài khoản |
| `auth.new_password` | New Password | Mật khẩu mới |
| `auth.confirm_password` | Confirm Password | Xác nhận mật khẩu |
| `auth.update_password` | Update Password | Cập nhật mật khẩu |
| `auth.updating` | Updating... | Đang cập nhật... |
| `auth.two_factor_title` | Two-Factor Verification | Xác minh 2 bước |
| `auth.two_factor_subtitle` | Enter code from your Authenticator app | Nhập mã từ ứng dụng Authenticator |
| `auth.verification_code` | Verification Code | Mã xác minh |
| `auth.recovery_code` | Recovery Code | Mã khôi phục |
| `auth.recovery_hint` | Or use a recovery code if you can't access the app | Hoặc dùng mã khôi phục nếu không truy cập được ứng dụng |
| `auth.verify` | Verify | Xác minh |
| `auth.oauth_failed` | OAuth login failed. Please try again. | Đăng nhập OAuth thất bại. Vui lòng thử lại. |
| `auth.oauth_no_email` | Could not get email from OAuth provider. | Không lấy được email từ nhà cung cấp OAuth. |
| `auth.login_throttled` | Too many login attempts. Please try again in {seconds}s. | Quá nhiều lần thử. Vui lòng thử lại sau {seconds}s. |
| `auth.credentials_failed` | These credentials do not match our records. | Thông tin đăng nhập không chính xác. |

---

## Adaptation Guide (Per Stack)

| Stack | Auth Layout | Form | Routing |
|-------|-------------|------|---------|
| **React + Inertia (Laravel)** | Inertia `<Head>`, `useForm()`, `usePage()` | `post(route('admin.login.store'))` | Laravel `Route::prefix(config('admin.prefix'))` |
| **Next.js App Router** | `metadata`, Server Actions | `useFormState()` + `<form action={login}>` | `app/(admin)/admin/login/page.tsx` |
| **Laravel Blade** | `@extends('auth.layout')` | `<form action="{{ route('admin.login') }}" method="POST">` | `Route::prefix(config('admin.prefix'))` |
| **Vue / Nuxt** | `<Head>` + composable | `useForm()` or `useFetch()` | `router.addRoute({ path: '/admin/...' })` |
| **HTML/Static** | Standalone HTML file | Standard `<form>` | Static `/{admin}/login.html` |

---

> **Usage:** When Antigravity activates Velzon Admin skill for admin panel creation, this file provides the **complete auth system** to reproduce — not just the login page. All screens share the same AuthLayout and glass card design. All flows (login, logout, forgot/reset password, 2FA, OAuth) must be fully functional.

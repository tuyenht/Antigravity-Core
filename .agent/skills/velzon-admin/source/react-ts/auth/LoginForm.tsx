/**
 * LoginForm — BaoSon Custom Login Form (Golden Standard)
 * 
 * Source: baoson-platform-core/Pages/Auth/Login.tsx
 * Adapted for: Standalone React / Next.js (no Inertia dependency)
 * 
 * ADAPTATION NOTES:
 * - Removed: @inertiajs/react (useForm, usePage, Link)
 * - Removed: route() helper (replaced with ADMIN_PREFIX template)
 * - Changed: Form submission via fetch/signIn instead of Inertia post
 * - Changed: Social buttons from <a href={route()}> to <SocialButton>
 * - Kept: ALL CSS classes, DOM structure, SVG icons EXACTLY as Golden Standard
 * 
 * NOTE: This file is a TEMPLATE. When /create-admin copies this:
 * 1. Replace ADMIN_PREFIX usage with project config import
 * 2. Adapt form submission to project's auth system (NextAuth, custom API, etc.)
 * 3. Adapt social buttons to project's OAuth setup
 */

import { useState, type FormEvent } from 'react';
import AuthLayout from './AuthLayout';
import Input from './Input';
import SocialButton from './SocialButton';
import { useLocale } from './LocaleContext';

interface LoginFormProps {
    /** Admin route prefix */
    adminPrefix?: string;
    /** Callback when form submits (override for custom auth) */
    onSubmit?: (email: string, password: string) => Promise<{ error?: string }>;
}

// SVG Icon fragments (Golden Standard — DO NOT CHANGE)
const UserIcon = (
    <>
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
        <circle strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" cx="12" cy="7" r="4" />
    </>
);

const LockIcon = (
    <>
        <rect strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" x="3" y="11" width="18" height="11" rx="2" ry="2" />
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M7 11V7a5 5 0 0 1 10 0v4" />
    </>
);

const GoogleIcon = (
    <svg className="w-5 h-5" viewBox="0 0 24 24">
        <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4" />
        <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853" />
        <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z" fill="#FBBC05" />
        <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335" />
    </svg>
);

const FacebookIcon = (
    <svg className="w-5 h-5 text-[#1877F2] fill-current" viewBox="0 0 24 24">
        <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z" />
    </svg>
);

export default function LoginForm({
    adminPrefix = 'admin',
    onSubmit,
}: LoginFormProps) {
    const { t, locale } = useLocale();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [processing, setProcessing] = useState(false);
    const [error, setError] = useState('');
    const [statusMessage, setStatusMessage] = useState('');

    const handleSubmit = async (e: FormEvent) => {
        e.preventDefault();
        setProcessing(true);
        setError('');

        try {
            if (onSubmit) {
                const result = await onSubmit(email, password);
                if (result.error) {
                    setError(result.error);
                }
            }
        } catch {
            setError('An unexpected error occurred');
        } finally {
            setProcessing(false);
        }
    };

    return (
        <AuthLayout title={t('auth.welcome')} adminPrefix={adminPrefix}>
            {/* Login Card — Match Golden Standard EXACTLY */}
            <div
                key={`login-${locale}`}
                className="glass w-full rounded-3xl p-6 md:p-10 shadow-2xl relative transition-all duration-500"
            >
                {/* Header */}
                <div className="mb-6">
                    <h2 className="text-3xl font-extrabold text-transparent bg-clip-text bg-gradient-to-r from-blue-700 to-slate-700 tracking-tight">
                        {t('auth.welcome')}
                    </h2>
                </div>

                {/* Status message (success) */}
                {statusMessage && (
                    <div className="mb-4 rounded-xl bg-green-50 px-4 py-3 text-sm text-green-800">
                        {statusMessage}
                    </div>
                )}

                <form onSubmit={handleSubmit} className="space-y-4">
                    {/* Email Input */}
                    <Input
                        key={`email-${locale}`}
                        label={t('auth.email_label')}
                        placeholder={t('auth.email_placeholder')}
                        type="email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        required
                        disabled={processing}
                        showAtSymbol={true}
                        icon={UserIcon}
                    />

                    {/* Password Input */}
                    <div>
                        <Input
                            key={`password-${locale}`}
                            label={t('auth.password_label')}
                            placeholder={t('auth.password_placeholder')}
                            isPassword
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            required
                            disabled={processing}
                            icon={LockIcon}
                        />
                        {/* Forgot Password Link */}
                        <div className="flex justify-end mt-2">
                            <a
                                href={`/${adminPrefix}/forgot-password`}
                                className={`text-sm font-medium text-blue-600 hover:text-blue-700 hover:underline transition-colors ${processing ? 'pointer-events-none opacity-50' : ''}`}
                            >
                                {t('auth.forgot_password')}
                            </a>
                        </div>
                    </div>

                    {/* Alert banner (before submit button) */}
                    {error && (
                        <div className="rounded-xl bg-red-50 px-4 py-3 text-sm text-red-800 transition-all duration-300">
                            {error}
                        </div>
                    )}

                    {/* Submit Button — Match Golden Standard */}
                    <button
                        type="submit"
                        disabled={processing}
                        className={`
                            w-full py-3 md:py-3.5 rounded-xl font-semibold text-[15px]
                            shadow-lg shadow-blue-500/20
                            flex items-center justify-center gap-2 transition-all duration-200 mt-1 md:mt-2 cursor-pointer
                            ${processing
                                ? 'bg-blue-700 text-white/90 cursor-wait scale-[0.98] shadow-inner'
                                : 'bg-blue-600 text-white hover:bg-blue-700 hover:-translate-y-0.5'}
                        `}
                    >
                        {processing ? (
                            <>
                                <svg
                                    className="animate-spin h-5 w-5 text-white"
                                    xmlns="http://www.w3.org/2000/svg"
                                    fill="none"
                                    viewBox="0 0 24 24"
                                >
                                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                                </svg>
                                <span>{t('auth.processing')}</span>
                            </>
                        ) : (
                            <>
                                <span>{t('auth.sign_in')}</span>
                                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                                </svg>
                            </>
                        )}
                    </button>
                </form>

                {/* Divider */}
                <div className="relative my-6">
                    <div className="absolute inset-0 flex items-center">
                        <div className="w-full border-t border-slate-100"></div>
                    </div>
                    <div className="relative flex justify-center">
                        <span className="bg-white px-4 text-xs font-medium text-slate-400">
                            {t('auth.or_continue')}
                        </span>
                    </div>
                </div>

                {/* Social Buttons — 2-column grid */}
                <div className="grid grid-cols-2 gap-3">
                    <SocialButton
                        provider="google"
                        label="Google"
                        icon={GoogleIcon}
                        tooltip={t('auth.login_with_google')}
                        disabled={processing}
                    />
                    <SocialButton
                        provider="facebook"
                        label="Facebook"
                        icon={FacebookIcon}
                        tooltip={t('auth.login_with_facebook')}
                        disabled={processing}
                    />
                </div>
            </div>
        </AuthLayout>
    );
}

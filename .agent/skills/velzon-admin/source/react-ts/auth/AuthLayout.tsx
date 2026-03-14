/**
 * AuthLayout — BaoSon Custom Auth Layout (Golden Standard)
 * 
 * Source: baoson-platform-core/layouts/AuthLayout.tsx
 * Adapted for: Standalone React / Next.js (no Inertia dependency)
 * 
 * STYLING: Uses auth.css classes exclusively (NOT Tailwind).
 * This ensures deterministic output — every /create-admin run produces
 * identical visual results regardless of Tailwind configuration.
 * 
 * auth.css classes used:
 *   .auth-page      → Base reset (box-sizing, font-size 14px)
 *   .auth-bg        → Animated gradient background (sky-700 → blue-600 → slate-800)
 *   .auth-orb-1/2   → Decorative blur orbs (pulse + bounce animations)
 *   .auth-main      → Content container (max-width 392px, centered)
 *   .auth-logo-wrap → Logo wrapper (hover scale 1.05, responsive margin)
 *   .auth-logo      → Logo image (max-height 58px, drop shadow)
 *   .auth-footer    → Copyright footer (white/40, responsive margin)
 * 
 * ADAPTATION NOTES (from Inertia → standalone):
 * - Removed: @inertiajs/react (Head, Link, usePage)
 * - Removed: PageProps dependency
 * - Changed: Logo from external URL to local /images/logo-light.png
 * - Changed: Dashboard link from route() to /${ADMIN_PREFIX}/dashboard
 * - Changed: Tailwind classes → auth.css classes for determinism
 * - Added: Configurable constants (ADMIN_PREFIX, COMPANY_NAME, etc.)
 * - Added: useEffect for 14px root font-size (Velzon convention)
 */

import { type ReactNode, useEffect } from 'react';
import LanguageSwitcher from './LanguageSwitcher';

interface AuthLayoutProps {
    children: ReactNode;
    title: string;
    subtitle?: string;
    /** Admin route prefix (default: from config) */
    adminPrefix?: string;
    /** Company name for footer */
    companyName?: string;
    /** Company URL for footer */
    companyUrl?: string;
    /** Logo image path */
    logoUrl?: string;
    /** App name for aria-label */
    appName?: string;
}

/**
 * Default values — override via props or environment variables.
 * In Next.js, import from @/config/admin instead.
 */
const DEFAULTS = {
    adminPrefix: 'admin',
    companyName: 'BaoSon Ads',
    companyUrl: 'https://baoson.net',
    logoUrl: '/images/logo-light.png',
    appName: 'Bao Son',
};

export default function AuthLayout({
    children,
    title,
    subtitle,
    adminPrefix = DEFAULTS.adminPrefix,
    companyName = DEFAULTS.companyName,
    companyUrl = DEFAULTS.companyUrl,
    logoUrl = DEFAULTS.logoUrl,
    appName = DEFAULTS.appName,
}: AuthLayoutProps) {
    // Auth pages use 14px root font-size (Velzon convention).
    // Without this, rem-based values in auth.css compute against browser default 16px.
    useEffect(() => {
        const prevFontSize = document.documentElement.style.fontSize;
        document.documentElement.style.fontSize = '14px';
        return () => {
            document.documentElement.style.fontSize = prevFontSize;
        };
    }, []);

    return (
        <div className="auth-page">
            {/* Head: set page title — framework-specific, adapt as needed */}
            {/* Next.js: use metadata export in page.tsx instead */}
            {/* Inertia: <Head title={title} /> */}

            {/* auth.css: auth-bg (animated gradient, responsive padding) */}
            <div className="auth-bg">
                {/* Decorative Blur Orbs — auth.css: auth-orb-1/2 */}
                <div className="auth-orb-1"></div>
                <div className="auth-orb-2"></div>

                {/* Language Switcher — auth.css: auth-lang (responsive positioning) */}
                <LanguageSwitcher />

                {/* auth.css: auth-main (max-width 392px, centered) */}
                <main className="auth-main">
                    {/* Logo — auth.css: auth-logo-wrap + auth-logo */}
                    <div className="auth-logo-wrap">
                        <a
                            href={`/${adminPrefix}/dashboard`}
                            aria-label={appName}
                        >
                            {/* eslint-disable-next-line @next/next/no-img-element */}
                            <img
                                src={logoUrl}
                                alt="Bao Son Logo"
                                className="auth-logo"
                            />
                        </a>
                    </div>

                    {/* Optional heading/subtitle — sr-only for SEO */}
                    {(subtitle || title) ? (
                        <div className="sr-only">
                            <h1>{title}</h1>
                            {subtitle ? <p>{subtitle}</p> : null}
                        </div>
                    ) : null}

                    {children}

                    {/* Footer — auth.css: auth-footer */}
                    <footer className="auth-footer">
                        <p>
                            &copy; {new Date().getFullYear()}{' '}
                            <a
                                href={companyUrl}
                                target="_blank"
                                rel="noopener noreferrer"
                            >
                                {companyName}
                            </a>
                            . All rights reserved.
                        </p>
                    </footer>
                </main>
            </div>
        </div>
    );
}

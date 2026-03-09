/**
 * AuthLayout — BaoSon Custom Auth Layout (Golden Standard)
 * 
 * Source: baoson-platform-core/layouts/AuthLayout.tsx
 * Adapted for: Standalone React / Next.js (no Inertia dependency)
 * 
 * Provides: animated gradient background, decorative orbs, logo, 
 *           language switcher, footer. Children = glass card content.
 * 
 * ADAPTATION NOTES (from Inertia → standalone):
 * - Removed: @inertiajs/react (Head, Link, usePage)
 * - Removed: PageProps dependency
 * - Changed: Logo from external URL to local /images/logo-light.png
 * - Changed: Dashboard link from route() to /${ADMIN_PREFIX}/dashboard
 * - Added: Configurable constants (ADMIN_PREFIX, COMPANY_NAME, etc.)
 */

import { type ReactNode } from 'react';
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
    return (
        <>
            {/* Head: set page title — framework-specific, adapt as needed */}
            {/* Next.js: use metadata export in page.tsx instead */}
            {/* Inertia: <Head title={title} /> */}

            <div className="min-h-[100dvh] w-full flex flex-col items-center justify-center px-8 py-6 md:p-4 animate-gradient bg-gradient-to-br from-sky-700 via-blue-600 to-slate-800 relative overflow-hidden">
                {/* Decorative Blur Orbs */}
                <div className="absolute top-20 left-20 w-64 h-64 bg-cyan-400/20 rounded-full blur-3xl animate-pulse pointer-events-none"></div>
                <div className="absolute bottom-20 right-20 w-96 h-96 bg-blue-500/10 rounded-full blur-3xl animate-bounce duration-[12s] pointer-events-none"></div>

                {/* Language Switcher — Responsive: Mobile centered, Desktop top-right */}
                <LanguageSwitcher />

                <main className="relative w-full max-w-[392px] flex flex-col items-center z-10">
                    {/* Logo — Responsive sizing: Mobile h-16, Desktop h-20 */}
                    <div className="mb-4 md:mb-8 transition-transform duration-500 hover:scale-105">
                        <a
                            href={`/${adminPrefix}/dashboard`}
                            aria-label={appName}
                        >
                            {/* eslint-disable-next-line @next/next/no-img-element */}
                            <img
                                src={logoUrl}
                                alt="Bao Son Logo"
                                className="h-[58px] w-auto drop-shadow-2xl"
                            />
                        </a>
                    </div>

                    {/* Optional heading/subtitle — sr-only for SEO  */}
                    {(subtitle || title) ? (
                        <div className="sr-only">
                            <h1>{title}</h1>
                            {subtitle ? <p>{subtitle}</p> : null}
                        </div>
                    ) : null}

                    {children}

                    {/* Footer */}
                    <footer className="mt-4 md:mt-8 text-center text-white/40 text-xs font-medium tracking-wide">
                        <p>
                            &copy; {new Date().getFullYear()}{' '}
                            <a
                                href={companyUrl}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="hover:text-white transition-colors"
                            >
                                {companyName}
                            </a>
                            . All rights reserved.
                        </p>
                    </footer>
                </main>
            </div>
        </>
    );
}

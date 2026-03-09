/**
 * LocaleContext — BaoSon Auth i18n Provider (Golden Standard)
 * 
 * Source: baoson-platform-core/contexts/LocaleContext.tsx
 * Adapted for: Standalone React / Next.js (no Inertia, no axios)
 * 
 * ADAPTATION NOTES:
 * - Removed: window.axios.post() (Inertia-specific server sync)
 * - Removed: PageProps type dependency
 * - Removed: admin?.routes reference
 * - Changed: Locale persistence via document.cookie only
 * - Changed: Simpler API without syncLocale (not needed without Inertia)
 * - Added: t() function for translation lookup
 * - Added: initialMessages support for server-side rendering
 * 
 * Usage (Next.js):
 *   // Server Component (page.tsx)
 *   const { locale, messages } = await getServerLocale();
 *   <LocaleProvider initialLocale={locale} initialMessages={messages}>
 *     <LoginForm />
 *   </LocaleProvider>
 */

import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';

export type SupportedLocale = 'en' | 'vi' | 'ja' | 'zh';

interface LocaleContextType {
    locale: SupportedLocale;
    setLocale: (locale: SupportedLocale) => void;
    /** Translation function — returns key if translation not found */
    t: (key: string) => string;
}

const LocaleContext = createContext<LocaleContextType | undefined>(undefined);

interface LocaleProviderProps {
    children: ReactNode;
    /** Initial locale (from server cookie or default) */
    initialLocale?: SupportedLocale;
    /** Initial messages (pre-loaded from server) */
    initialMessages?: Record<string, string>;
}

export function LocaleProvider({
    children,
    initialLocale = 'en',
    initialMessages = {},
}: LocaleProviderProps) {
    const [locale, setLocaleState] = useState<SupportedLocale>(initialLocale);
    const [messages, setMessages] = useState<Record<string, string>>(initialMessages);

    // Update document lang attribute with proper format for CSS selectors
    useEffect(() => {
        if (typeof document !== 'undefined') {
            const langMap: Record<SupportedLocale, string> = {
                'en': 'en',
                'vi': 'vi',
                'ja': 'ja',
                'zh': 'zh-CN', // Use zh-CN for Simplified Chinese (matches CSS selector)
            };
            document.documentElement.lang = langMap[locale] || locale;
        }
    }, [locale]);

    // setLocale — instant UI update + cookie persistence + load new messages
    const setLocale = async (newLocale: SupportedLocale) => {
        if (newLocale === locale) return;

        // Instant UI update
        setLocaleState(newLocale);

        // Write cookie immediately (for server-side reads on next request)
        if (typeof document !== 'undefined') {
            document.cookie = `locale=${newLocale}; path=/; max-age=31536000; samesite=lax`;
        }

        // Load new locale messages
        try {
            const newMessages = (await import(`@/locales/${newLocale}.json`)).default;
            setMessages(newMessages);
        } catch {
            // Fallback to English if locale file not found
            try {
                const fallback = (await import('@/locales/en.json')).default;
                setMessages(fallback);
            } catch {
                // Keep current messages if all else fails
            }
        }
    };

    // Translation function
    const t = (key: string): string => {
        return messages[key] ?? key;
    };

    return (
        <LocaleContext.Provider value={{ locale, setLocale, t }}>
            {children}
        </LocaleContext.Provider>
    );
}

export function useLocale() {
    const context = useContext(LocaleContext);
    if (!context) {
        throw new Error('useLocale must be used within LocaleProvider');
    }
    return context;
}

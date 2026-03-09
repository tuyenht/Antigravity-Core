'use client';

import { useLocale, type SupportedLocale } from '@/contexts/LocaleContext';
import { AUTH_LOCALES, LOCALE_META } from '@/config/i18n';

/**
 * LanguageSwitcher — Uses auth.css classes for pixel-perfect Golden Standard match
 *
 * auth.css classes used:
 *   .auth-lang         → Container (responsive: center mobile, top-right desktop)
 *   .auth-lang-pill    → Dark glass pill (no visible border)
 *   .auth-lang-btn     → Each language button (28px mobile, 36px desktop, ROUND)
 *   .auth-lang-btn--active → Active state (white bg, blue text, shadow, scale 1.05)
 *   .auth-lang-tooltip → Tooltip on hover (desktop only, with arrow)
 */
export default function LanguageSwitcher() {
    const { locale, setLocale } = useLocale();

    const handleLocaleClick = (e: React.MouseEvent<HTMLButtonElement>, newLocale: SupportedLocale) => {
        e.preventDefault();
        e.stopPropagation();
        setLocale(newLocale);
    };

    return (
        <div className="auth-lang">
            <div className="auth-lang-pill">
                {AUTH_LOCALES.map((l) => (
                    <button
                        key={l}
                        onClick={(e) => handleLocaleClick(e, l)}
                        type="button"
                        className={`auth-lang-btn ${locale === l ? 'auth-lang-btn--active' : ''}`}
                    >
                        {l.toUpperCase()}
                        <span className="auth-lang-tooltip">
                            {LOCALE_META[l]?.label ?? l}
                        </span>
                    </button>
                ))}
            </div>
        </div>
    );
}

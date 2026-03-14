/**
 * SocialButton — BaoSon Custom Social Login Button (Golden Standard)
 * 
 * Source: Extracted from baoson-platform-core/Pages/Auth/Login.tsx
 * 
 * STYLING: Uses auth.css classes exclusively (NOT Tailwind).
 * This ensures deterministic output — every /create-admin run produces
 * identical visual results regardless of Tailwind configuration.
 * 
 * auth.css classes used:
 *   .auth-social-btn      → Button (white bg, slate-200 border, rounded-xl, shadow-sm)
 *   .auth-social-btn:hover → Hover state (slate-50 bg, elevated shadow, -2px translateY)
 *   .auth-social-btn svg   → Icon sizing (18×18px)
 *   .auth-social-btn span  → Label text (12.25px, slate-600)
 *   .auth-social-btn.disabled → Disabled state (opacity 0.5, pointer-events none)
 */

interface SocialButtonProps {
    /** OAuth provider identifier */
    provider: string;
    /** Display label (e.g., "Google", "Facebook") */
    label: string;
    /** Provider icon (SVG ReactNode) */
    icon: React.ReactNode;
    /** OAuth redirect URL */
    href?: string;
    /** Click handler (alternative to href) */
    onClick?: () => void;
    /** Tooltip text */
    tooltip?: string;
    /** Disable the button */
    disabled?: boolean;
}

export default function SocialButton({
    provider,
    label,
    icon,
    href,
    onClick,
    tooltip,
    disabled = false,
}: SocialButtonProps) {
    const className = `auth-social-btn${disabled ? ' disabled' : ''}`;

    const content = (
        <>
            {icon}
            <span>{label}</span>
        </>
    );

    // If href is provided, render as <a> tag (standard OAuth flow)
    if (href) {
        return (
            <a
                href={href}
                className={className}
                title={tooltip}
                onClick={(e) => {
                    if (disabled) {
                        e.preventDefault();
                        return;
                    }
                    onClick?.();
                }}
            >
                {content}
            </a>
        );
    }

    // Otherwise render as button (for Next-Auth signIn, etc.)
    return (
        <button
            type="button"
            className={className}
            title={tooltip}
            disabled={disabled}
            onClick={onClick}
        >
            {content}
        </button>
    );
}

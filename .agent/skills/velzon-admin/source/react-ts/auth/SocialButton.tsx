/**
 * SocialButton — BaoSon Custom Social Login Button (Golden Standard)
 * 
 * Source: Extracted from baoson-platform-core/Pages/Auth/Login.tsx
 * The Golden Standard uses inline <a> tags — this component wraps that pattern.
 * 
 * Features:
 * - White background, slate-200 border, rounded-xl, shadow-sm
 * - Hover: slate-50 bg, slate-300 border, elevated shadow, translateY -2px
 * - Provider icon (SVG) + label text
 * - Tooltip via title attribute
 * - Disabled state support
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
    const className = `
        flex items-center justify-center gap-2.5 px-4 py-2.5
        bg-white border border-slate-200 rounded-xl
        hover:bg-slate-50 hover:border-slate-300
        transition-all duration-200 shadow-sm
        group cursor-pointer
        ${disabled ? 'pointer-events-none opacity-50' : ''}
    `;

    const content = (
        <>
            <span className="w-5 h-5 flex-shrink-0">{icon}</span>
            <span className="text-sm font-medium text-slate-600 group-hover:text-slate-900 transition-colors capitalize">
                {label}
            </span>
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

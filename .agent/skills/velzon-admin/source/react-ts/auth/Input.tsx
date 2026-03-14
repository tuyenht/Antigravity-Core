/**
 * Input — BaoSon Custom Input Component (Golden Standard)
 * 
 * Source: baoson-platform-core/components/Input.tsx
 * 
 * STYLING: Uses auth.css classes exclusively (NOT Tailwind).
 * This ensures deterministic output — every /create-admin run produces
 * identical visual results regardless of Tailwind configuration.
 * 
 * auth.css classes used:
 *   .auth-input-group     → Wrapper (flex column, gap 5.25px)
 *   .auth-label           → Label (14px, semibold, slate-700)
 *   .auth-input-wrap      → Input container (relative positioning)
 *   .auth-input-icon      → Left icon (absolute, slate-400 → blue-600 on focus)
 *   .auth-input           → Input field (10.5px padding, 10.5px radius, slate-50 bg)
 *   .auth-input--no-icon-left   → No left icon modifier
 *   .auth-input--no-action-right → No right action modifier
 *   .auth-input-action    → Right action container (absolute)
 *   .auth-at-symbol       → @ symbol display
 *   .auth-eye-btn         → Password eye toggle button
 *
 * Golden Standard values (from auth.css):
 * - Padding: 10.5px 38.5px (NOT 44px)
 * - Background: slate-50, border: slate-200, rounded: 10.5px
 * - Focus: white bg, blue-600 border, ring-4 blue-600/10
 */

import { useState, type InputHTMLAttributes } from 'react';

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
    label: string;
    icon?: React.ReactNode;
    isPassword?: boolean;
    showAtSymbol?: boolean;
}

const Input: React.FC<InputProps> = ({ label, icon, isPassword, showAtSymbol, disabled, ...props }) => {
    const [showPass, setShowPass] = useState(false);

    const hasRightAction = isPassword || showAtSymbol;
    const hasLeftIcon = !!icon;

    return (
        <div className="auth-input-group">
            <label className={`auth-label${disabled ? ' opacity-50' : ''}`}>
                {label}
            </label>
            <div className="auth-input-wrap">
                {/* Left Icon */}
                {hasLeftIcon && (
                    <div className={`auth-input-icon${disabled ? ' opacity-50' : ''}`}>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                            {icon}
                        </svg>
                    </div>
                )}

                <input
                    {...props}
                    disabled={disabled}
                    type={isPassword ? (showPass ? 'text' : 'password') : props.type}
                    className={`auth-input${!hasLeftIcon ? ' auth-input--no-icon-left' : ''}${!hasRightAction ? ' auth-input--no-action-right' : ''}`}
                />

                {/* Right Actions */}
                {showAtSymbol && (
                    <div className="auth-input-action">
                        <div className={`auth-at-symbol${disabled ? ' opacity-50' : ''}`}>
                            @
                        </div>
                    </div>
                )}

                {isPassword && (
                    <div className="auth-input-action">
                        <button
                            type="button"
                            disabled={disabled}
                            onClick={() => setShowPass(!showPass)}
                            className={`auth-eye-btn${disabled ? ' opacity-50 cursor-not-allowed' : ''}`}
                        >
                            {showPass ? (
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                    <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24" />
                                    <line x1="1" y1="1" x2="23" y2="23" />
                                </svg>
                            ) : (
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                                    <circle cx="12" cy="12" r="3" />
                                </svg>
                            )}
                        </button>
                    </div>
                )}
            </div>
        </div>
    );
};

export default Input;

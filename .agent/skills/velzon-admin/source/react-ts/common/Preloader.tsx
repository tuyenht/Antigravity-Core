'use client';

import React, { useEffect, useState } from 'react';

/**
 * Preloader — Exact DOM from Velzon HTML dist/index.html (lines 3217-3223)
 * 
 * DOM structure:
 *   <div id="preloader">
 *     <div id="status">
 *       <div class="spinner-border text-primary avatar-sm" role="status">
 *         <span class="visually-hidden">Loading...</span>
 *       </div>
 *     </div>
 *   </div>
 * 
 * Position: OUTSIDE #layout-wrapper, AFTER #back-to-top
 * Behavior:
 *   - Show when data-preloader="enable" on <html>
 *   - Auto-hide after page load (DOMContentLoaded + timeout)
 *   - Default: disabled (data-preloader="disable")
 */

interface PreloaderProps {
    enabled?: boolean; // from LayoutContext data-preloader value
}

export default function Preloader({ enabled = false }: PreloaderProps) {
    const [visible, setVisible] = useState(enabled);

    useEffect(() => {
        if (enabled) {
            setVisible(true);
            const timer = setTimeout(() => setVisible(false), 1000);
            return () => clearTimeout(timer);
        } else {
            setVisible(false);
        }
    }, [enabled]);

    if (!visible) return null;

    return (
        <div id="preloader">
            <div id="status">
                <div className="spinner-border text-primary avatar-sm" role="status">
                    <span className="visually-hidden">Loading...</span>
                </div>
            </div>
        </div>
    );
}

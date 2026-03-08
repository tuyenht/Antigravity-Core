'use client';

import React, { useState, useEffect } from 'react';

/**
 * BackToTop — Exact DOM from Velzon HTML dist/index.html (line 3211)
 * 
 * DOM structure:
 *   <button class="btn btn-danger btn-icon" id="back-to-top">
 *     <i class="ri-arrow-up-line"></i>
 *   </button>
 * 
 * Position: OUTSIDE #layout-wrapper
 * Behavior: Show when scroll > 200px, smooth scroll to top on click
 * z-index: 1009 (from app.min.css)
 */
export default function BackToTop() {
    const [visible, setVisible] = useState(false);

    useEffect(() => {
        const handleScroll = () => {
            setVisible(window.scrollY > 200);
        };
        window.addEventListener('scroll', handleScroll, { passive: true });
        return () => window.removeEventListener('scroll', handleScroll);
    }, []);

    const scrollToTop = () => {
        window.scrollTo({ top: 0, behavior: 'smooth' });
    };

    if (!visible) return null;

    return (
        <button
            onClick={scrollToTop}
            className="btn btn-danger btn-icon"
            id="back-to-top"
        >
            <i className="ri-arrow-up-line"></i>
        </button>
    );
}

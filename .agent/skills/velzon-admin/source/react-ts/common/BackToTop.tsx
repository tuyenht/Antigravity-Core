'use client';

import React, { useState, useEffect } from 'react';

/**
 * BackToTop — Velzon standard (#back-to-top)
 * 
 * CSS (app.min.css): #back-to-top { position:fixed; bottom:100px; right:28px; z-index:1000; display:none }
 * IMPORTANT: CSS sets display:none by default. We override with inline style.
 * globals.css MUST also have: #back-to-top { display: block !important; }
 * 
 * Position: OUTSIDE #layout-wrapper
 * Behavior: Show when scroll > 200px, smooth scroll to top on click
 */
export default function BackToTop() {
    const [visible, setVisible] = useState(false);

    useEffect(() => {
        const handleScroll = () => setVisible(window.scrollY > 200);
        window.addEventListener('scroll', handleScroll, { passive: true });
        return () => window.removeEventListener('scroll', handleScroll);
    }, []);

    return (
        <button
            onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })}
            className="btn btn-danger btn-icon"
            id="back-to-top"
            style={{ display: visible ? 'block' : 'none' }}
        >
            <i className="ri-arrow-up-line"></i>
        </button>
    );
}

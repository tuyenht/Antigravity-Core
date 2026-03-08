'use client';

import React, { useState, useEffect, useMemo } from 'react';
import { Col, Container, Row } from 'reactstrap';

/**
 * Footer — Configurable branding + LiveClock (i18n-synced)
 * 
 * Config (from env or config/admin.ts):
 *   - NEXT_PUBLIC_COMPANY_NAME (default: "BaoSon Ads")
 *   - NEXT_PUBLIC_COMPANY_URL (default: "https://baoson.net")
 * 
 * LiveClock:
 *   - Updates every second via setInterval
 *   - Format synced with current i18n locale (Intl.DateTimeFormat)
 *   - MUST cleanup setInterval in useEffect return
 */

interface FooterProps {
    locale?: string; // i18n locale code: 'en', 'vi', 'ja', 'zh'
}

const COMPANY_NAME = process.env.NEXT_PUBLIC_COMPANY_NAME || 'BaoSon Ads';
const COMPANY_URL = process.env.NEXT_PUBLIC_COMPANY_URL || 'https://baoson.net';

// Map i18n language codes to Intl locale codes
const LOCALE_MAP: Record<string, string> = {
    en: 'en-US',
    vi: 'vi-VN',
    ja: 'ja-JP',
    zh: 'zh-CN',
};

function LiveClock({ locale = 'en' }: { locale: string }) {
    const [time, setTime] = useState('');

    const formatter = useMemo(() => {
        const intlLocale = LOCALE_MAP[locale] || locale;
        return new Intl.DateTimeFormat(intlLocale, {
            dateStyle: 'full',
            timeStyle: 'medium',
        });
    }, [locale]);

    useEffect(() => {
        const update = () => setTime(formatter.format(new Date()));
        update();
        const id = setInterval(update, 1000);
        return () => clearInterval(id); // ★ MANDATORY cleanup
    }, [formatter]);

    return <>{time}</>;
}

const Footer = ({ locale = 'en' }: FooterProps) => {
    return (
        <footer className="footer">
            <Container fluid>
                <Row>
                    <Col sm={6}>
                        {new Date().getFullYear()} ©{' '}
                        <a
                            href={COMPANY_URL}
                            target="_blank"
                            rel="noopener noreferrer"
                        >
                            {COMPANY_NAME}
                        </a>
                        . All rights reserved.
                    </Col>
                    <Col sm={6}>
                        <div className="text-sm-end d-none d-sm-block">
                            <LiveClock locale={locale} />
                        </div>
                    </Col>
                </Row>
            </Container>
        </footer>
    );
};

export default Footer;
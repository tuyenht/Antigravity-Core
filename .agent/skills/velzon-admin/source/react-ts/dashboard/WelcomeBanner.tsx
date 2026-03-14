import React from 'react';
import { Card, CardBody, Col, Row } from 'reactstrap';

/**
 * WelcomeBanner — Dashboard greeting section
 *
 * Displays a gradient welcome card with:
 *   - Greeting with user name + emoji
 *   - Subtitle describing the admin panel
 *   - Right-side illustration (logo)
 *
 * Adaptation notes (Next.js):
 *   - Add 'use client'; at top
 *   - Replace image path with next/image or /images/ public path
 *   - User name from session/context instead of props
 */

interface WelcomeBannerProps {
    userName: string;
    subtitle?: string;
    logoSrc?: string; // Path to logo-sm.png or company illustration
}

const WelcomeBanner = ({
    userName,
    subtitle = "Here's what's happening with your admin panel today.",
    logoSrc,
}: WelcomeBannerProps) => {
    return (
        <Row>
            <Col xs={12}>
                <Card className="overflow-hidden">
                    <CardBody
                        className="bg-primary bg-gradient position-relative"
                        style={{ minHeight: '120px' }}
                    >
                        <Row className="align-items-center">
                            <Col sm={9}>
                                <h5 className="text-white fs-16 mb-1">
                                    Welcome back, {userName}! 👋
                                </h5>
                                <p className="text-white-75 mb-0">
                                    {subtitle}
                                </p>
                            </Col>
                            {logoSrc && (
                                <Col sm={3} className="text-end d-none d-sm-block">
                                    <img
                                        src={logoSrc}
                                        alt="Logo"
                                        className="img-fluid"
                                        style={{
                                            maxHeight: '80px',
                                            opacity: 0.6,
                                        }}
                                    />
                                </Col>
                            )}
                        </Row>
                    </CardBody>
                </Card>
            </Col>
        </Row>
    );
};

export default WelcomeBanner;

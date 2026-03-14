import React from 'react';
import { Card, CardBody, Col } from 'reactstrap';
import CountUp from 'react-countup';

/**
 * StatCard — Velzon Stat Widget (4-column row)
 *
 * Usage in DashboardPage:
 *   <StatCard label="Total Users" value={12} icon="ri-user-line" color="primary" percentage="+0%" trend="neutral" />
 *
 * Adaptation notes (Next.js):
 *   - Add 'use client'; at top
 *   - CountUp requires client component
 *   - No routing changes needed (no links in this component)
 */

export interface StatCardProps {
    label: string;
    value: number;
    icon: string;          // Remix Icon class, e.g. 'ri-user-line'
    color: string;         // Bootstrap color: primary, success, info, warning, danger
    percentage: string;    // e.g. '+16.24%', '-3.57%', '+0%'
    trend: 'up' | 'down' | 'neutral'; // Arrow direction
    prefix?: string;       // e.g. '$'
    suffix?: string;       // e.g. 'k', 'M'
    separator?: string;    // e.g. ','
    decimals?: number;
}

const StatCard = ({
    label,
    value,
    icon,
    color,
    percentage,
    trend,
    prefix = '',
    suffix = '',
    separator = ',',
    decimals = 0,
}: StatCardProps) => {
    const trendIcon =
        trend === 'up'
            ? 'ri-arrow-right-up-line'
            : trend === 'down'
              ? 'ri-arrow-right-down-line'
              : 'ri-arrow-right-line';

    const badgeClass =
        trend === 'up' ? 'success' : trend === 'down' ? 'danger' : 'muted';

    return (
        <Col xl={3} md={6}>
            <Card className="card-animate">
                <CardBody>
                    <div className="d-flex align-items-center">
                        <div className="flex-grow-1 overflow-hidden">
                            <p className="text-uppercase fw-medium text-muted text-truncate mb-0">
                                {label}
                            </p>
                        </div>
                        <div className="flex-shrink-0">
                            <h5 className={`fs-14 mb-0 text-${badgeClass}`}>
                                <i className={`fs-13 align-middle ${trendIcon}`}></i>{' '}
                                {percentage}
                            </h5>
                        </div>
                    </div>
                    <div className="d-flex align-items-end justify-content-between mt-4">
                        <div>
                            <h4 className="fs-22 fw-semibold ff-secondary mb-4">
                                <CountUp
                                    start={0}
                                    end={value}
                                    prefix={prefix}
                                    suffix={suffix}
                                    separator={separator}
                                    decimals={decimals}
                                    duration={4}
                                />
                            </h4>
                        </div>
                        <div className="avatar-sm flex-shrink-0">
                            <span
                                className={`avatar-title rounded fs-3 bg-${color}-subtle`}
                            >
                                <i className={`text-${color} ${icon}`}></i>
                            </span>
                        </div>
                    </div>
                </CardBody>
            </Card>
        </Col>
    );
};

export default StatCard;

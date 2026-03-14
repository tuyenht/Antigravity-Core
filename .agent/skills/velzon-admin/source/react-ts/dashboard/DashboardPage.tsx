import React from 'react';
import { Container, Row } from 'reactstrap';
import BreadCrumb from '../common/BreadCrumb';
import StatCard from './StatCard';
import WelcomeBanner from './WelcomeBanner';
import RecentActivity, { ActivityItem } from './RecentActivity';

/**
 * DashboardPage — Admin Dashboard landing page (Velzon canonical source)
 *
 * Structure:
 *   1. BreadCrumb (Admin > Dashboard)
 *   2. WelcomeBanner (gradient greeting)
 *   3. 4x StatCards (Total Users, Active Today, New This Month, Total Roles)
 *   4. RecentActivity table
 *
 * Data source:
 *   - Stats: fetched from API or passed as props (server component in Next.js)
 *   - Activities: fetched from audit_logs table
 *   - User name: from auth session
 *
 * Adaptation notes (Next.js):
 *   - Add 'use client'; at top (CountUp requires client)
 *   - Replace BreadCrumb import path
 *   - Replace image paths to /images/ public dir
 *   - Data fetching via server component wrapper or useEffect
 *   - User name from useSession() or server-side session
 *
 * Widget spec (from saas-admin-starter.md §7):
 *   | Widget        | Icon                   | Color   |
 *   |---------------|------------------------|---------|
 *   | Total Users   | ri-user-line           | primary |
 *   | Active Today  | ri-user-follow-line    | success |
 *   | New This Month| ri-user-add-line       | info    |
 *   | Total Roles   | ri-shield-user-line    | warning |
 *
 * SaaS-only widgets (add when MODE=saas):
 *   | Total Sites    | ri-global-line    | secondary |
 *   | Active Tenants | ri-building-line  | dark      |
 */

// ============================================
// Types
// ============================================

export interface DashboardStats {
    totalUsers: number;
    activeToday: number;
    newThisMonth: number;
    totalRoles: number;
    // SaaS-only (optional)
    totalSites?: number;
    activeTenants?: number;
}

export interface DashboardPageProps {
    stats: DashboardStats;
    activities: ActivityItem[];
    userName: string;
    logoSrc?: string;         // Path to logo for WelcomeBanner
    isSaasMode?: boolean;     // Show extra SaaS widgets
}

// ============================================
// Helper: Calculate percentage (compared to previous period)
// ============================================

function formatPercentage(current: number, previous: number): { text: string; trend: 'up' | 'down' | 'neutral' } {
    if (previous === 0 && current === 0) return { text: '+0%', trend: 'neutral' };
    if (previous === 0) return { text: '+100%', trend: 'up' };
    const pct = ((current - previous) / previous) * 100;
    if (pct > 0) return { text: `+${pct.toFixed(0)}%`, trend: 'up' };
    if (pct < 0) return { text: `${pct.toFixed(0)}%`, trend: 'down' };
    return { text: '+0%', trend: 'neutral' };
}

// ============================================
// Default seed activities (shown after initial setup)
// ============================================

export const DEFAULT_ACTIVITIES: ActivityItem[] = [
    {
        id: '1',
        action: 'login.success',
        actionLabel: 'login.success',
        actionColor: 'success',
        user: 'admin@example.com',
        date: 'Just now',
        status: 'Success',
        statusColor: 'success',
    },
    {
        id: '2',
        action: 'system.seed',
        actionLabel: 'system.seed',
        actionColor: 'info',
        user: 'System',
        date: 'Initial setup',
        status: 'Complete',
        statusColor: 'primary',
    },
];

// ============================================
// Component
// ============================================

const DashboardPage = ({
    stats,
    activities,
    userName,
    logoSrc,
    isSaasMode = false,
}: DashboardPageProps) => {
    return (
        <React.Fragment>
            <div className="page-content">
                <Container fluid>
                    <BreadCrumb title="Dashboard" pageTitle="Admin" />

                    {/* Welcome Banner */}
                    <WelcomeBanner
                        userName={userName}
                        logoSrc={logoSrc}
                    />

                    {/* Stat Widgets — 4 cards (+ 2 extra in SaaS mode) */}
                    <Row>
                        <StatCard
                            label="TOTAL USERS"
                            value={stats.totalUsers}
                            icon="ri-user-line"
                            color="primary"
                            percentage="+0%"
                            trend="neutral"
                        />
                        <StatCard
                            label="ACTIVE TODAY"
                            value={stats.activeToday}
                            icon="ri-user-follow-line"
                            color="success"
                            percentage="+100%"
                            trend="up"
                        />
                        <StatCard
                            label="NEW THIS MONTH"
                            value={stats.newThisMonth}
                            icon="ri-user-add-line"
                            color="info"
                            percentage="+100%"
                            trend="up"
                        />
                        <StatCard
                            label="TOTAL ROLES"
                            value={stats.totalRoles}
                            icon="ri-shield-user-line"
                            color="warning"
                            percentage="+0%"
                            trend="neutral"
                        />
                    </Row>

                    {/* SaaS-only widgets */}
                    {isSaasMode && (
                        <Row>
                            <StatCard
                                label="TOTAL SITES"
                                value={stats.totalSites || 0}
                                icon="ri-global-line"
                                color="secondary"
                                percentage="+0%"
                                trend="neutral"
                            />
                            <StatCard
                                label="ACTIVE TENANTS"
                                value={stats.activeTenants || 0}
                                icon="ri-building-line"
                                color="dark"
                                percentage="+0%"
                                trend="neutral"
                            />
                        </Row>
                    )}

                    {/* Recent Activity */}
                    <RecentActivity activities={activities} />
                </Container>
            </div>
        </React.Fragment>
    );
};

export default DashboardPage;

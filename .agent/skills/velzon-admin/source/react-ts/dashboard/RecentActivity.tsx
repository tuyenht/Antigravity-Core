import React from 'react';
import { Badge, Card, CardBody, CardHeader, Col, Row, Table } from 'reactstrap';

/**
 * RecentActivity — Dashboard activity log table
 *
 * Displays recent audit trail entries in a Velzon-styled table:
 *   - Action column with colored badges
 *   - User/actor column
 *   - Date column
 *   - Status column with colored badges
 *
 * Adaptation notes (Next.js):
 *   - Add 'use client'; at top
 *   - Data typically fetched from API or passed as props from server component
 *   - Badge colors use Velzon `bg-{color}-subtle text-{color}` pattern
 */

export interface ActivityItem {
    id: string;
    action: string;       // e.g. 'login.success', 'system.seed', 'user.created'
    actionLabel: string;  // Display label, e.g. 'Login Success'
    actionColor: string;  // Badge color: success, info, warning, danger, primary
    user: string;         // Actor name or email
    date: string;         // Display date string
    status: string;       // e.g. 'Success', 'Complete', 'Pending'
    statusColor: string;  // Badge color
}

interface RecentActivityProps {
    activities: ActivityItem[];
    title?: string;
}

const RecentActivity = ({
    activities,
    title = 'Recent Activity',
}: RecentActivityProps) => {
    return (
        <Row>
            <Col xs={12}>
                <Card>
                    <CardHeader className="border-0">
                        <h5 className="card-title mb-0">{title}</h5>
                    </CardHeader>
                    <CardBody className="pt-0">
                        <div className="table-responsive table-card">
                            <Table className="table-hover table-centered align-middle table-nowrap mb-0">
                                <thead className="table-light text-muted">
                                    <tr>
                                        <th scope="col">Action</th>
                                        <th scope="col">User</th>
                                        <th scope="col">Date</th>
                                        <th scope="col">Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {activities.map((item) => (
                                        <tr key={item.id}>
                                            <td>
                                                <Badge
                                                    color=""
                                                    className={`bg-${item.actionColor}-subtle text-${item.actionColor} badge-sm`}
                                                >
                                                    {item.actionLabel}
                                                </Badge>
                                            </td>
                                            <td>{item.user}</td>
                                            <td>{item.date}</td>
                                            <td>
                                                <Badge
                                                    color=""
                                                    className={`bg-${item.statusColor}-subtle text-${item.statusColor}`}
                                                >
                                                    {item.status}
                                                </Badge>
                                            </td>
                                        </tr>
                                    ))}
                                    {activities.length === 0 && (
                                        <tr>
                                            <td
                                                colSpan={4}
                                                className="text-center text-muted py-4"
                                            >
                                                No recent activity
                                            </td>
                                        </tr>
                                    )}
                                </tbody>
                            </Table>
                        </div>
                    </CardBody>
                </Card>
            </Col>
        </Row>
    );
};

export default RecentActivity;

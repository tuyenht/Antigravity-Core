// DashboardPage.tsx — Admin Dashboard with i18n support
// Template: Velzon Admin Starter Kit
// Adaptation: Uses useLocale().t() for all translatable text
'use client';

import React from 'react';
import { Container, Row, Col, Card, CardBody } from 'reactstrap';
import BreadCrumb from '@/components/Common/BreadCrumb';
import { useLocale } from '@/contexts/LocaleContext';

export default function DashboardPage() {
  const { t } = useLocale();

  const statWidgets = [
    { label: t('admin.total_users'), value: 12, icon: 'ri-user-line', color: 'primary', badge: '+3', badgeClass: 'success' },
    { label: t('admin.active_today'), value: 5, icon: 'ri-user-follow-line', color: 'success', badge: '+2', badgeClass: 'success' },
    { label: t('admin.new_this_month'), value: 8, icon: 'ri-user-add-line', color: 'info', badge: '+8', badgeClass: 'info' },
    { label: t('admin.roles_count'), value: 5, icon: 'ri-shield-user-line', color: 'warning', badge: '5', badgeClass: 'warning' },
  ];

  return (
    <div className="page-content">
      <Container fluid>
        <BreadCrumb title={t('admin.dashboard')} pageTitle="Admin" />

        {/* Welcome Banner */}
        <Row>
          <Col xs={12}>
            <Card className="card-animate">
              <CardBody>
                <div className="d-flex align-items-center">
                  <div className="flex-grow-1">
                    <h5 className="card-title mb-1">{t('admin.welcome_back')} 👋</h5>
                    <p className="text-muted mb-0">{t('admin.welcome_desc')}</p>
                  </div>
                </div>
              </CardBody>
            </Card>
          </Col>
        </Row>

        {/* Stat Widgets */}
        <Row>
          {statWidgets.map((widget, index) => (
            <Col xl={3} md={6} key={index}>
              <Card className="card-animate">
                <CardBody>
                  <div className="d-flex align-items-center">
                    <div className="flex-grow-1 overflow-hidden">
                      <p className="text-uppercase fw-medium text-muted text-truncate mb-0">{widget.label}</p>
                    </div>
                    <div className="flex-shrink-0">
                      <h5 className={`fs-14 mb-0 text-${widget.badgeClass}`}>
                        <i className="ri-arrow-right-up-line fs-13 align-middle"></i> {widget.badge}
                      </h5>
                    </div>
                  </div>
                  <div className="d-flex align-items-end justify-content-between mt-4">
                    <div>
                      <h4 className="fs-22 fw-semibold ff-secondary mb-4">{widget.value}</h4>
                      <span className="text-decoration-underline text-muted">{t('admin.view_all')}</span>
                    </div>
                    <div className="avatar-sm flex-shrink-0">
                      <span className={`avatar-title rounded fs-3 bg-${widget.color}-subtle`}>
                        <i className={`text-${widget.color} ${widget.icon}`}></i>
                      </span>
                    </div>
                  </div>
                </CardBody>
              </Card>
            </Col>
          ))}
        </Row>

        {/* Recent Activity */}
        <Row>
          <Col xl={12}>
            <Card>
              <CardBody>
                <h5 className="card-title mb-3">{t('admin.recent_activity')}</h5>
                <div className="table-responsive">
                  <table className="table table-borderline table-nowrap align-middle mb-0">
                    <thead className="table-light text-muted">
                      <tr>
                        <th>{t('admin.user')}</th>
                        <th>{t('admin.action')}</th>
                        <th>{t('admin.time')}</th>
                        <th>{t('admin.status')}</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr>
                        <td>
                          <div className="d-flex align-items-center">
                            <div className="avatar-xs me-2">
                              <span className="avatar-title rounded-circle bg-primary-subtle text-primary">A</span>
                            </div>
                            <span>admin@example.com</span>
                          </div>
                        </td>
                        <td><span className="badge bg-success-subtle text-success">Login Success</span></td>
                        <td className="text-muted">Just now</td>
                        <td><span className="badge bg-success">Active</span></td>
                      </tr>
                      <tr>
                        <td>
                          <div className="d-flex align-items-center">
                            <div className="avatar-xs me-2">
                              <span className="avatar-title rounded-circle bg-info-subtle text-info">S</span>
                            </div>
                            <span>System</span>
                          </div>
                        </td>
                        <td><span className="badge bg-info-subtle text-info">Database seeded</span></td>
                        <td className="text-muted">5 min ago</td>
                        <td><span className="badge bg-success">Completed</span></td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </CardBody>
            </Card>
          </Col>
        </Row>
      </Container>
    </div>
  );
}

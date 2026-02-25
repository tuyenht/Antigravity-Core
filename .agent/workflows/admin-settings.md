---
description: Tạo trang Settings cho admin panel
---

# /admin-settings — Admin Settings Page Builder

// turbo-all

Tạo trang cấu hình (Settings) cho admin panel: app config, email, integrations, maintenance.

**Agent:** `frontend-specialist` + `backend-specialist`  
**Skills:** `velzon-admin, frontend-design, database-design`

---

## When to Use

- Admin panel đã có (tạo bằng `/create-admin`)
- Cần trang quản lý cấu hình: App Settings, Email, Integrations, Maintenance
- Cần trang Profile (user self-service)

---

## Step 1: Detect Framework & Existing Admin

```
Auto-detect:
├── Verify admin system exists (Layout, Auth, RBAC)
├── Detect framework (same as /create-admin Step 1)
├── Detect MODE (saas/standalone) from .env
└── If no admin found → STOP: "Chạy /create-admin trước"
```

---

## Step 2: Choose Settings Modules

Hỏi user hoặc auto-detect nhu cầu:

```
Settings Modules:
├── 🔧 General Settings (REQUIRED)
│   ├── App Name, Logo, Favicon
│   ├── Timezone, Date Format
│   ├── Default Language
│   └── Maintenance Mode toggle
│
├── 📧 Email Settings
│   ├── SMTP config (host, port, username, password, encryption)
│   ├── Email templates (welcome, reset, invite)
│   └── Test email sender
│
├── 🔗 Integration Settings
│   ├── OAuth providers (Google, GitHub, Facebook)
│   ├── Payment gateways (Stripe, PayPal)
│   ├── Storage (S3, Cloudflare R2)
│   └── Analytics (Google Analytics, Plausible)
│
├── 🛡️ Security Settings
│   ├── Password policy (min length, complexity)
│   ├── 2FA enforcement
│   ├── Session timeout
│   └── IP whitelist
│
├── 👤 Profile Page (user self-service)
│   ├── Avatar upload
│   ├── Name, Email change
│   ├── Password change
│   ├── Active sessions
│   └── Notification preferences
│
└── 🏢 Tenant Settings (SaaS mode only)
    ├── Company name, domain
    ├── Billing plan
    ├── Team members
    └── API keys
```

---

## Step 3: Generate Backend

**Agent:** `backend-specialist`

### Database
```
Settings storage strategy:
├── Option A: Key-value table (recommended)
│   └── settings: id, group, key, value, type, created_at, updated_at
│
├── Option B: JSON column on tenants/organizations table
│   └── tenants.settings (JSONB)
│
└── Option C: Config file (.env / config/)
    └── For non-dynamic settings only
```

### API / Controller

| Route | Method | Purpose |
|-------|--------|---------|
| `/admin/settings` | GET | Show settings page |
| `/admin/settings/general` | PUT | Update general settings |
| `/admin/settings/email` | PUT | Update email config |
| `/admin/settings/email/test` | POST | Send test email |
| `/admin/settings/security` | PUT | Update security policy |
| `/admin/settings/integrations` | PUT | Update integrations |
| `/admin/profile` | GET | Show profile page |
| `/admin/profile` | PUT | Update profile |
| `/admin/profile/password` | PUT | Change password |
| `/admin/profile/avatar` | POST | Upload avatar |
| `/admin/profile/sessions` | GET | List active sessions |
| `/admin/profile/sessions/:id` | DELETE | Revoke session |

---

## Step 4: Generate Frontend

**Agent:** `frontend-specialist`

### Page Structure (Velzon Tab Layout)
```tsx
// Settings page uses vertical Nav tabs (Velzon pattern)
<Container fluid>
  <BreadCrumb title="Settings" pageTitle="Admin" />
  <Row>
    <Col xxl={3}>
      {/* Vertical Nav tabs */}
      <Card>
        <CardBody>
          <Nav pills vertical>
            <NavItem><NavLink>General</NavLink></NavItem>
            <NavItem><NavLink>Email</NavLink></NavItem>
            <NavItem><NavLink>Security</NavLink></NavItem>
            <NavItem><NavLink>Integrations</NavLink></NavItem>
          </Nav>
        </CardBody>
      </Card>
    </Col>
    <Col xxl={9}>
      <TabContent activeTab={activeTab}>
        <TabPane tabId="general">{/* General form */}</TabPane>
        <TabPane tabId="email">{/* Email form */}</TabPane>
        <TabPane tabId="security">{/* Security form */}</TabPane>
        <TabPane tabId="integrations">{/* Integrations form */}</TabPane>
      </TabContent>
    </Col>
  </Row>
</Container>
```

### Profile Page
```tsx
// Profile page (Velzon pattern: cover photo + info cards)
<Container fluid>
  <div className="profile-foreground position-relative mx-n4 mt-n4">
    {/* Cover photo */}
  </div>
  <Row>
    <Col xxl={3}>{/* Profile sidebar: avatar, stats */}</Col>
    <Col xxl={9}>{/* Profile tabs: Overview, Activity, Settings */}</Col>
  </Row>
</Container>
```

---

## Step 5: Register Routes & Menu

```
Sidebar Menu (add to LayoutMenuData.tsx):
├── Settings (ri-settings-3-line)
│   ├── General
│   ├── Email
│   ├── Security
│   └── Integrations
│
└── Profile (in ProfileDropdown, not sidebar)
```

**Permission:** `settings.view`, `settings.edit`

---

## Step 6: Verify

- [ ] Settings page renders with tab navigation
- [ ] General settings save and persist (reload shows saved values)
- [ ] Email test sends successfully
- [ ] Security policy enforced (password rules, 2FA)
- [ ] Profile avatar upload works
- [ ] Password change works
- [ ] Active sessions list displays correctly
- [ ] Session revocation works
- [ ] SaaS tenant settings visible only in SaaS mode
- [ ] RBAC: only users with `settings.edit` can modify
- [ ] Dark mode renders correctly
- [ ] Responsive behavior OK

---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| Settings không save | Kiểm tra API route, verify CSRF token, check DB write permissions |
| Tab navigation bể | Verify Reactstrap Nav/TabContent import, check activeTab state |
| Avatar upload fails | Kiểm tra file size limit, storage config (local/S3), multipart form |
| Test email không gửi | Verify SMTP config, check firewall/port, try với Mailtrap |
| Profile password change fails | Verify current password validation, check bcrypt hash |
| Tenant settings hiện ở standalone mode | Kiểm tra MODE env var, wrap component trong SaaS-only guard |

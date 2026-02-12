# Page Catalog Reference

Complete catalog of all 200+ Velzon pages with routes and component types.

---

## Dashboards (8 types)

| Route | Page | Key Components |
|-------|------|----------------|
| `/dashboard-analytics` | DashboardAnalytics | Widgets, AudienceMetrics, Sessions, UserActivity |
| `/dashboard-crm` | DashboardCrm | Widgets, SalesForecasts, DealStatus, ClosingDeals |
| `/dashboard` | DashboardEcommerce | Widgets, Revenue, SalesByLocations, BestSelling, TopSellers |
| `/dashboard-crypto` | DashboardCrypto | Widgets, Portfolio, MarketStatus, TradingActivities |
| `/dashboard-projects` | DashboardProject | Widgets, ProjectStatus, ActiveProjects, TeamMembers |
| `/dashboard-nft` | DashboardNFT | Widgets, Marketplace, FeaturedNFT, TopArtist, Popularity |
| `/dashboard-job` | DashboardJob | Widgets, ApplicationChart, Applications, Interviews |
| `/dashboard-blog` | DashboardBlog | Widgets, Articles, Comments, PopularPosts |

---

## App Modules

### Calendar
| Route | Page |
|-------|------|
| `/apps-calendar` | Calendar (FullCalendar) |
| `/apps-calendar-month-grid` | MonthGrid |

### Chat
| Route | Page |
|-------|------|
| `/apps-chat` | Chat (real-time messaging UI) |

### Email
| Route | Page |
|-------|------|
| `/apps-mailbox` | MailInbox |
| `/apps-email-basic` | BasicAction (template) |
| `/apps-email-ecommerce` | EcommerceAction (template) |

### Ecommerce (10 pages)
| Route | Page | Type |
|-------|------|------|
| `/apps-ecommerce-products` | EcommerceProducts | List (grid) |
| `/apps-ecommerce-product-details/:_id` | EcommerceProductDetail | Detail |
| `/apps-ecommerce-add-product` | EcommerceAddProduct | Create (form) |
| `/apps-ecommerce-orders` | EcommerceOrders | List (table) |
| `/apps-ecommerce-order-details` | EcommerceOrderDetail | Detail |
| `/apps-ecommerce-customers` | EcommerceCustomers | List (table) |
| `/apps-ecommerce-cart` | EcommerceCart | Cart |
| `/apps-ecommerce-checkout` | EcommerceCheckout | Wizard form |
| `/apps-ecommerce-sellers` | EcommerceSellers | List (grid) |
| `/apps-ecommerce-seller-details` | EcommerceSellerDetail | Detail |

### Projects
| Route | Page | Type |
|-------|------|------|
| `/apps-projects-list` | ProjectList | List (card grid) |
| `/apps-projects-overview` | ProjectOverview | Detail |
| `/apps-projects-create` | CreateProject | Create (form) |

### Tasks
| Route | Page | Type |
|-------|------|------|
| `/apps-tasks-kanban` | Kanbanboard | Kanban board |
| `/apps-tasks-list-view` | TaskList | List (table) |
| `/apps-tasks-details` | TaskDetails | Detail |

### CRM (4 pages)
| Route | Page | Type |
|-------|------|------|
| `/apps-crm-contacts` | CrmContacts | CRUD table |
| `/apps-crm-companies` | CrmCompanies | CRUD table |
| `/apps-crm-deals` | CrmDeals | CRUD table |
| `/apps-crm-leads` | CrmLeads | CRUD table |

### Crypto (6 pages)
| Route | Page |
|-------|------|
| `/apps-crypto-transactions` | Transactions |
| `/apps-crypto-buy-sell` | BuySell |
| `/apps-crypto-orders` | CryptoOrder |
| `/apps-crypto-wallet` | MyWallet |
| `/apps-crypto-ico` | ICOList |
| `/apps-crypto-kyc` | KYCVerification |

### Invoices
| Route | Page | Type |
|-------|------|------|
| `/apps-invoices-list` | InvoiceList | List |
| `/apps-invoices-details` | InvoiceDetails | Detail |
| `/apps-invoices-create` | InvoiceCreate | Create |

### Support Tickets
| Route | Page | Type |
|-------|------|------|
| `/apps-tickets-list` | ListView | List (table) |
| `/apps-tickets-details` | TicketsDetails | Detail |

### NFT Marketplace (9 pages)
| Route | Page |
|-------|------|
| `/apps-nft-marketplace` | Marketplace |
| `/apps-nft-collections` | Collections |
| `/apps-nft-create` | CreateNFT |
| `/apps-nft-creators` | Creators |
| `/apps-nft-explore` | ExploreNow |
| `/apps-nft-item-details` | ItemDetails |
| `/apps-nft-auction` | LiveAuction |
| `/apps-nft-ranking` | Ranking |
| `/apps-nft-wallet` | WalletConnect |

### File Manager
| Route | Page |
|-------|------|
| `/apps-file-manager` | FileManager |

### To Do
| Route | Page |
|-------|------|
| `/apps-todo` | ToDoList |

### Jobs (10 pages)
| Route | Page |
|-------|------|
| `/apps-job-statistics` | Statistics |
| `/apps-job-lists` | JobList (list view) |
| `/apps-job-grid-lists` | JobGrid (grid view) |
| `/apps-job-details` | JobOverview |
| `/apps-job-candidate-lists` | CandidateList |
| `/apps-job-candidate-grid` | CandidateGrid |
| `/apps-job-application` | Application |
| `/apps-job-new` | NewJobs |
| `/apps-job-companies-lists` | CompaniesList |
| `/apps-job-categories` | JobCategories |

### API Key
| Route | Page |
|-------|------|
| `/apps-api-key` | APIKey |

---

## Authentication Pages

### Functional Auth (with Redux)
| Route | Page |
|-------|------|
| `/login` | Login |
| `/register` | Register |
| `/forgot-password` | ForgetPasswordPage |
| `/logout` | Logout |
| `/profile` | UserProfile |

### Auth Inner (UI showcase - Basic & Cover variants)
| Feature | Basic Route | Cover Route |
|---------|------------|-------------|
| Sign In | `/auth-signin-basic` | `/auth-signin-cover` |
| Sign Up | `/auth-signup-basic` | `/auth-signup-cover` |
| Password Reset | `/auth-pass-reset-basic` | `/auth-pass-reset-cover` |
| Password Create | `/auth-pass-change-basic` | `/auth-pass-change-cover` |
| Lock Screen | `/auth-lockscreen-basic` | `/auth-lockscreen-cover` |
| Logout | `/auth-logout-basic` | `/auth-logout-cover` |
| Success Message | `/auth-success-msg-basic` | `/auth-success-msg-cover` |
| Two Step Verify | `/auth-twostep-basic` | `/auth-twostep-cover` |

### Error Pages
| Route | Page |
|-------|------|
| `/auth-404-basic` | Basic404 |
| `/auth-404-cover` | Cover404 |
| `/auth-404-alt` | Alt404 |
| `/auth-500` | Error500 |
| `/auth-offline` | Offlinepage |

---

## Utility Pages

| Route | Page | Type |
|-------|------|------|
| `/pages-starter` | Starter | Blank page |
| `/pages-profile` | SimplePage | Profile |
| `/pages-profile-settings` | Settings | Form |
| `/pages-team` | Team | Card grid |
| `/pages-timeline` | Timeline | Timeline |
| `/pages-faqs` | Faqs | Accordion |
| `/pages-gallery` | Gallery | Masonry grid |
| `/pages-pricing` | Pricing | Cards |
| `/pages-sitemap` | SiteMap | Tree |
| `/pages-search-results` | SearchResults | Results list |
| `/pages-privacy-policy` | PrivacyPolicy | Content |
| `/pages-terms-condition` | TermsCondition | Content |
| `/pages-blog-list` | BlogListView | List |
| `/pages-blog-grid` | BlogGridView | Grid |
| `/pages-blog-overview` | BlogOverview | Detail |
| `/pages-maintenance` | Maintenance | Full page |
| `/pages-coming-soon` | ComingSoon | Full page |

---

## Charts (20+ types)

### ApexCharts
| Route | Chart Type |
|-------|-----------|
| `/charts-apex-line` | Line |
| `/charts-apex-area` | Area |
| `/charts-apex-column` | Column |
| `/charts-apex-bar` | Bar |
| `/charts-apex-mixed` | Mixed |
| `/charts-apex-timeline` | Timeline |
| `/charts-apex-range-area` | Range Area |
| `/charts-apex-funnel` | Funnel |
| `/charts-apex-candlestick` | Candlestick |
| `/charts-apex-boxplot` | Boxplot |
| `/charts-apex-bubble` | Bubble |
| `/charts-apex-scatter` | Scatter |
| `/charts-apex-heatmap` | Heatmap |
| `/charts-apex-treemap` | Treemap |
| `/charts-apex-pie` | Pie/Donut |
| `/charts-apex-radialbar` | Radialbar |
| `/charts-apex-radar` | Radar |
| `/charts-apex-polar` | Polar |
| `/charts-apex-slope` | Slope |

### Other
| Route | Library |
|-------|---------|
| `/charts-chartjs` | Chart.js |
| `/charts-echarts` | ECharts |

---

## UI Components (24 Base + 5 Advance)

### Base UI (`/ui-*`)
Alerts, Badges, Buttons, Colors, Cards, Carousel, Dropdowns, Grid, Images, Tabs, Accordions, Modals, Offcanvas, Placeholders, Progress, Notifications, Media, Embed Video, Typography, Lists, Links, General, Ribbons, Utilities

### Advance UI (`/advance-ui-*`)
Scrollbar, Animation, Swiper Slider, Ratings, Highlight

---

## Forms (13 types, `/forms-*`)
Elements, Select, Checkboxes/Radios, Pickers, Masks, Advanced, Range Sliders, Validation, Wizard, Editors (CKEditor/Quill), File Uploads, Layouts, Select2

---

## Tables
| Route | Type |
|-------|------|
| `/tables-basic` | BasicTables (HTML tables) |
| `/tables-react` | ReactTable (TanStack) |

---

## Page Type Selection Guide

When building a new admin screen, map to the closest template:

| Need | Template to Reference |
|------|-----------------------|
| Dashboard/overview | DashboardEcommerce or DashboardAnalytics |
| CRUD list with table | CrmContacts or EcommerceOrders |
| CRUD detail view | EcommerceProductDetail or InvoiceDetails |
| CRUD create/edit form | EcommerceAddProduct or CreateProject |
| Grid/card list | EcommerceProducts or EcommerceSellers |
| Kanban board | TasksKanban |
| Chat interface | Chat |
| File management | FileManager |
| Calendar view | Calendar |
| User profile/settings | SimplePage + Settings |
| Checkout/wizard flow | EcommerceCheckout or FormWizard |
| Statistics overview | JobStatistics |

---

## Redux Slice Modules (24)

Each module has `reducer.ts` + `thunk.ts`:

| Module | State Key | Features |
|--------|-----------|----------|
| layouts | Layout | Theme config |
| auth/login | Login | Auth state |
| auth/register | Account | Registration |
| auth/forgetpwd | ForgetPassword | Password reset |
| auth/profile | Profile | User profile |
| calendar | Calendar | Calendar events |
| chat | Chat | Messages |
| ecommerce | Ecommerce | Products, orders, customers |
| projects | Projects | Project CRUD |
| tasks | Tasks | Task CRUD |
| crypto | Crypto | Crypto transactions |
| tickets | Tickets | Support tickets |
| crm | Crm | Contacts, companies, deals, leads |
| invoice | Invoice | Invoice CRUD |
| mailbox | Mailbox | Email messages |
| dashboardAnalytics | DashboardAnalytics | Analytics data |
| dashboardCRM | DashboardCRM | CRM dashboard data |
| dashboardEcommerce | DashboardEcommerce | Revenue charts |
| dashboardCrypto | DashboardCrypto | Crypto dashboard data |
| dashboardProject | DashboardProject | Project dashboard data |
| dashboardNFT | DashboardNFT | NFT dashboard data |
| dashboardJob | DashBoardJob | Job dashboard data |
| team | Team | Team members |
| fileManager | FileManager | Files/folders |
| todos | Todos | To-do items |
| jobs | Jobs | Job listings |
| apiKey | APIKey | API keys |

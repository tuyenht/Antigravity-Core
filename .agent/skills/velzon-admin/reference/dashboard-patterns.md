# Dashboard Patterns Reference

## Dashboard Page Structure

Every dashboard follows this composition pattern:

```tsx
const DashboardXxx = () => {
  document.title = "Dashboard Name | App Name";
  return (
    <React.Fragment>
      <div className="page-content">
        <Container fluid>
          <Row>
            <Col>
              <div className="h-100">
                <Section />              {/* Header row with greeting + date/actions */}
                <Row><Widgets /></Row>     {/* Stat cards row */}
                <Row>                      {/* Main content rows */}
                  <Col xl={8}><ChartCard /></Col>
                  <Col xl={4}><SidePanel /></Col>
                </Row>
                <Row>
                  <Col xl={6}><TableCard /></Col>
                  <Col xl={6}><ListCard /></Col>
                </Row>
              </div>
            </Col>
          </Row>
        </Container>
      </div>
    </React.Fragment>
  );
};
```

---

## Available Dashboard Types

### 1. Ecommerce Dashboard
**Components:** Section, Widgets (4 stat cards), Revenue chart (ApexCharts area), SalesByLocations (vector map), BestSellingProducts (table), TopSellers (table), StoreVisits (donut chart), RecentOrders (table), RecentActivity (right sidebar)

**Layout:** `xl-8 + xl-4` for main + side panels

### 2. Analytics Dashboard
**Components:** Widgets, AudiencesMetrics (line chart), AudiencesSessions (bar/column), UsersActivity (stacked area), BrowserState (progress bars), TopPages, TopReferrals

### 3. CRM Dashboard
**Components:** Widgets, SalesForecasts (radialbar), DealStatus (funnel), ClosingDeals (table), UpcomingActivities (timeline), DealsTable

### 4. Crypto Dashboard
**Components:** Widgets, PortfolioChart (area), MarketStatus (candlestick), TradingActivities (table), MyPortfolio, RecentActivity

### 5. Project Dashboard
**Components:** Widgets, ProjectStatus (donut), ActiveProjects (table), TeamMembers (list), OverdueTasks

### 6. NFT Dashboard
**Components:** Widgets, Marketplace (card grid), FeaturedNFT (carousel), TopArtist, RecentNFT, Popularity (heatmap)

### 7. Job Dashboard
**Components:** Widgets, ApplicationChart (area), Applications (table), UpcomingInterviews (timeline)

### 8. Blog Dashboard
**Components:** Widgets, Articles (card grid), RecentComments, PopularPosts

---

## Widget Row Pattern (4-Column Stats)

Standard layout: 4 stat cards in a row using `xl={3} md={6}`:

```tsx
const widgets = [
  { label: "Total Earnings",  counter: 559.25, prefix: "$", suffix: "k", percentage: "+16.24", badgeClass: "success", icon: "ri-arrow-right-up-line", bgcolor: "success", link: "View net earnings" },
  { label: "Orders",          counter: 36894,  separator: ",",          percentage: "-3.57",  badgeClass: "danger",  icon: "ri-arrow-right-down-line", bgcolor: "info", link: "View all orders" },
  { label: "Customers",       counter: 183.35, prefix: "",  suffix: "M", percentage: "+29.08", badgeClass: "success", icon: "ri-arrow-right-up-line", bgcolor: "warning", link: "See details" },
  { label: "My Balance",      counter: 165.89, prefix: "$", suffix: "k", percentage: "+0.00",  badgeClass: "muted",   icon: "ri-arrow-right-up-line", bgcolor: "primary", link: "Withdraw money" },
];
```

---

## Chart Card Pattern

Chart inside a Card with period selector buttons:

```tsx
<Card>
  <CardHeader className="border-0 align-items-center d-flex">
    <h4 className="card-title mb-0 flex-grow-1">Revenue</h4>
    <div className="d-flex gap-1">
      {["ALL", "1M", "6M", "1Y"].map((btn) => (
        <Button key={btn} color={active === btn ? "soft-primary" : "soft-secondary"} size="sm"
                onClick={() => onChangePeriod(btn)}>{btn}</Button>
      ))}
    </div>
  </CardHeader>
  {/* Optional: Summary stats strip */}
  <CardHeader className="p-0 border-0 bg-light-subtle">
    <Row className="g-0 text-center">
      <Col xs={6} sm={3}>
        <div className="p-3 border border-dashed border-start-0">
          <h5 className="mb-1"><CountUp end={7585} separator="," /></h5>
          <p className="text-muted mb-0">Orders</p>
        </div>
      </Col>
      {/* ... more stat columns */}
    </Row>
  </CardHeader>
  <CardBody className="p-0 pb-2">
    <ReactApexChart options={options} series={series} type="area" height={350} />
  </CardBody>
</Card>
```

---

## Table Card Pattern

```tsx
<Card>
  <CardHeader className="border-0">
    <Row className="align-items-center">
      <Col><h4 className="card-title mb-0">Best Selling Products</h4></Col>
      <Col xs="auto">
        <Nav className="nav-pills card-header-pills">
          <NavItem><NavLink className={active ? "active" : ""} href="#">All</NavLink></NavItem>
        </Nav>
      </Col>
    </Row>
  </CardHeader>
  <CardBody>
    <div className="table-responsive table-card">
      <Table className="table-hover table-centered align-middle table-nowrap mb-0">
        <tbody>
          {data.map((item) => (
            <tr key={item.id}>
              <td><img src={item.img} alt="" className="avatar-sm rounded" /></td>
              <td><h6 className="mb-0">{item.name}</h6></td>
              <td className="text-end"><span className="text-muted">{item.value}</span></td>
            </tr>
          ))}
        </tbody>
      </Table>
    </div>
  </CardBody>
</Card>
```

---

## Section Header Pattern

Page header with greeting, search, and action buttons:

```tsx
<Row className="mb-3 pb-1">
  <Col xs={12}>
    <div className="d-flex align-items-lg-center flex-lg-row flex-column">
      <div className="flex-grow-1">
        <h4 className="fs-16 mb-1">Good Morning, Anna!</h4>
        <p className="text-muted mb-0">Here's what's happening with your store today.</p>
      </div>
      <div className="mt-3 mt-lg-0">
        <Row className="g-3 mb-0 align-items-center">
          <Col xs="auto">
            <Flatpickr className="form-control" options={{ dateFormat: "d M, Y" }} />
          </Col>
          <Col xs="auto">
            <Button color="primary" className="btn-icon"><i className="ri-add-circle-line"></i></Button>
          </Col>
        </Row>
      </div>
    </div>
  </Col>
</Row>
```

---

## Activity Sidebar Pattern (Right Column)

Collapsible right panel for activity feed:

```tsx
const [rightColumn, setRightColumn] = useState<boolean>(true);

<Col lg={rightColumn ? 4 : 0} className={rightColumn ? "" : "d-none"}>
  <Card className="card-height-100">
    <CardHeader className="border-0 align-items-center d-flex">
      <h4 className="card-title mb-0 flex-grow-1">Recent Activity</h4>
      <Button color="link" className="p-0" onClick={() => setRightColumn(false)}>
        <i className="ri-close-line"></i>
      </Button>
    </CardHeader>
    <CardBody className="p-0">
      <SimpleBar style={{ maxHeight: "410px" }}>
        {activities.map((item) => (
          <div className="d-flex border-bottom p-3" key={item.id}>
            <div className="flex-shrink-0">
              <img src={item.avatar} className="avatar-xs rounded-circle" alt="" />
            </div>
            <div className="flex-grow-1 ms-3">
              <h6 className="mb-1">{item.title}</h6>
              <p className="text-muted mb-0 fs-12">{item.time}</p>
            </div>
          </div>
        ))}
      </SimpleBar>
    </CardBody>
  </Card>
</Col>
```

---

## Redux Data Flow for Dashboards

```
Page Component
  └── useEffect → dispatch(getChartData("all"))
        └── thunk.ts: createAsyncThunk → API call → return data
              └── reducer.ts: extraReducers → addCase(fulfilled) → update state
                    └── useSelector(createSelector(...)) → component re-renders
```

### Typical Redux Wiring

```tsx
// In dashboard component:
const dispatch: any = useDispatch();

const selectData = createSelector(
  (state: any) => state.DashboardEcommerce,
  (dashboard: any) => dashboard.revenueData
);
const revenueData = useSelector(selectData);

useEffect(() => {
  dispatch(getRevenueChartsData("all"));
}, [dispatch]);
```

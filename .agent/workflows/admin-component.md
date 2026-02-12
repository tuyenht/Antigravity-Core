---
description: Tạo component admin (Velzon)
---

# Admin Component Generator

Generate individual Velzon-style admin components for any supported stack.

## Prerequisites
- Read component patterns: `.agent/skills/velzon-admin/reference/component-patterns.md`
- Detect project variant (see stack detection in `SKILL.md` Multi-Stack section)
- For Inertia projects: also read `reference/inertia-bridge.md`
- For Next.js projects: also read `reference/nextjs-patterns.md`
- For Node.js (Express + EJS) projects: also read `reference/nodejs-patterns.md`
- For ASP.NET Core / MVC projects: also read `reference/aspnet-mvc-patterns.md`
- For Ajax (jQuery) projects: also read `reference/ajax-patterns.md`
- For asset recreation: read `reference/asset-catalog.md`
- For shared patterns (toast, avatar, datepicker, etc.): read `reference/api-and-helpers.md`
- Identify the component type needed

## Component Types

### Data Table
Uses TanStack React Table via `TableContainer`:
```tsx
<TableContainer
  columns={columns}
  data={data}
  isGlobalFilter={true}
  customPageSize={10}
  divClass="table-responsive table-card mb-1"
  tableClass="align-middle table-nowrap"
  theadClass="table-light text-muted"
  SearchPlaceholder="Search..."
/>
```

### Stat Widget Card
Animated stat card with CountUp:
```tsx
<Card className="card-animate">
  <CardBody>
    {/* d-flex layout with label, badge, CountUp value, avatar icon */}
  </CardBody>
</Card>
```

### Chart Card
ApexChart inside Card with period selector:
```tsx
<Card>
  <CardHeader className="border-0 align-items-center d-flex">
    {/* Title + period buttons */}
  </CardHeader>
  <CardBody>
    <ReactApexChart options={options} series={series} type="area" height={350} />
  </CardBody>
</Card>
```

### CRUD Form Modal
Formik + Yup inside Reactstrap Modal:
```tsx
<Modal isOpen={modal} toggle={toggle} centered size="lg">
  <ModalHeader toggle={toggle}>{isEdit ? "Edit" : "Add"}</ModalHeader>
  <ModalBody>
    <Form onSubmit={validation.handleSubmit}>
      {/* Input fields with validation */}
    </Form>
  </ModalBody>
</Modal>
```

### Delete Confirmation Modal
```tsx
<DeleteModal show={deleteModal} onDeleteClick={handleDelete} onCloseClick={() => setDeleteModal(false)} />
```

## Steps

### 1. Identify Component Type
Match the request to one of:
- `table` → TableContainer pattern
- `stat` → Widget CountUp card
- `chart` → ApexChart card (line/area/column/bar/pie/donut/radial)
- `form` → Formik + Yup form
- `modal` → Add/Edit or Delete modal
- `list` → Card-based list (avatar + info)
- `timeline` → Activity timeline
- `kanban` → Drag-and-drop board

### 2. Generate Component
// turbo
Create the component file using the appropriate pattern from `reference/component-patterns.md`.

Key rules:
- Import from `reactstrap` (Container, Row, Col, Card, etc.)
- Use Remix Icons (`ri-*`)
- Follow Bootstrap 5 utility classes
- Type all props with TypeScript interfaces
- Use `bg-*-subtle` for soft backgrounds

### 3. Wire Data Source
Connect to data:
- **Static data**: Import from `common/data/` directory
- **Redux**: Use `useSelector` + `createSelector` for reads, `dispatch` for writes
- **API**: Create thunk in `slices/{module}/thunk.ts`

### 4. Integrate into Page
Import and place the component in the page layout:
```tsx
<Row>
  <Col xl={8}><MyChartComponent /></Col>
  <Col xl={4}><MySidePanel /></Col>
</Row>
```

### 5. Verify
- Component renders correctly with sample/mock data
- Responsive behavior (check md/sm breakpoints)
- Dark mode compatibility
- Console free of errors/warnings

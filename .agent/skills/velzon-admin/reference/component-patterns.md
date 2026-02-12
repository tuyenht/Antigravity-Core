# Component Patterns Reference

## 1. BreadCrumb

```tsx
interface BreadCrumbProps {
  title: string;      // Current page title
  pageTitle: string;   // Parent category
}

<BreadCrumb title="Products" pageTitle="Ecommerce" />
```

Renders: `page-title-box` with `h4` title on the left, `ol.breadcrumb` on the right.

---

## 2. TableContainer (TanStack React Table)

Full-featured data table with fuzzy search, sorting, pagination.

```tsx
interface TableContainerProps {
  columns: ColumnDef[];          // TanStack column definitions
  data: any[];                   // Data array
  isGlobalFilter?: boolean;      // Show search bar
  customPageSize?: number;       // Items per page (default 10)
  tableClass?: string;           // e.g. "align-middle table-nowrap"
  theadClass?: string;           // e.g. "table-light text-muted"
  divClass?: string;             // e.g. "table-responsive table-card mb-1"
  SearchPlaceholder?: string;    // Search input placeholder
  // Filter type flags (enable one):
  isProductsFilter?: boolean;
  isCustomerFilter?: boolean;
  isOrderFilter?: boolean;
  isContactsFilter?: boolean;
  isCompaniesFilter?: boolean;
  isLeadsFilter?: boolean;
  isCryptoOrdersFilter?: boolean;
  isInvoiceListFilter?: boolean;
  isTicketsListFilter?: boolean;
  isNFTRankingFilter?: boolean;
  isTaskListFilter?: boolean;
}
```

### Column Definition Pattern
```tsx
const columns = useMemo(() => [
  {
    header: "Order ID",
    accessorKey: "orderId",
    cell: (info: any) => <Link to="#">{info.getValue()}</Link>,
    enableColumnFilter: false,
  },
  {
    header: "Status",
    accessorKey: "status",
    cell: (info: any) => (
      <Badge color={getStatusColor(info.getValue())}>{info.getValue()}</Badge>
    ),
    enableColumnFilter: false,
  },
  {
    header: "Actions",
    cell: (cellProps: any) => (
      <div className="d-flex gap-2">
        <Button size="sm" color="soft-info" onClick={() => handleView(cellProps.row.original)}>
          <i className="ri-eye-fill align-bottom"></i>
        </Button>
        <Button size="sm" color="soft-success" onClick={() => handleEdit(cellProps.row.original)}>
          <i className="ri-pencil-fill align-bottom"></i>
        </Button>
        <Button size="sm" color="soft-danger" onClick={() => handleDelete(cellProps.row.original)}>
          <i className="ri-delete-bin-fill align-bottom"></i>
        </Button>
      </div>
    ),
  },
], []);
```

---

## 3. Stat Widget (CountUp Card)

```tsx
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
          <h5 className={`fs-14 mb-0 text-${isUp ? 'success' : 'danger'}`}>
            <i className={`fs-13 align-middle ri-arrow-${isUp ? 'up' : 'down'}-s-fill`}></i>
            {percentage}%
          </h5>
        </div>
      </div>
      <div className="d-flex align-items-end justify-content-between mt-4">
        <div>
          <h4 className="fs-22 fw-semibold ff-secondary mb-4">
            <CountUp start={0} end={value} prefix="$" separator="," duration={4} />
          </h4>
          <Link to={link} className="text-decoration-underline">{linkText}</Link>
        </div>
        <div className="avatar-sm flex-shrink-0">
          <span className={`avatar-title rounded fs-3 bg-${color}-subtle`}>
            <i className={`text-${color} ${iconClass}`}></i>
          </span>
        </div>
      </div>
    </CardBody>
  </Card>
</Col>
```

---

## 4. DeleteModal

```tsx
interface DeleteModalProps {
  show?: boolean;
  onDeleteClick?: () => void;
  onCloseClick?: () => void;
  recordId?: string;
}

<DeleteModal show={deleteModal} onDeleteClick={handleDeleteConfirm} onCloseClick={() => setDeleteModal(false)} />
```

---

## 5. Card with Header Actions

```tsx
<Card>
  <CardHeader className="border-0 align-items-center d-flex">
    <h4 className="card-title mb-0 flex-grow-1">Title</h4>
    <div className="d-flex gap-1">
      <Button color="soft-secondary" size="sm" onClick={() => handlePeriod("all")}>ALL</Button>
      <Button color="soft-secondary" size="sm" onClick={() => handlePeriod("1m")}>1M</Button>
      <Button color="soft-primary" size="sm" onClick={() => handlePeriod("1y")}>1Y</Button>
    </div>
  </CardHeader>
  <CardBody>
    {/* Chart or content */}
  </CardBody>
</Card>
```

---

## 6. Summary Stats Strip

Horizontal row of bordered stats, typically inside a CardHeader:

```tsx
<CardHeader className="p-0 border-0 bg-light-subtle">
  <Row className="g-0 text-center">
    <Col xs={6} sm={3}>
      <div className="p-3 border border-dashed border-start-0">
        <h5 className="mb-1">
          <CountUp start={0} end={7585} duration={3} separator="," />
        </h5>
        <p className="text-muted mb-0">Orders</p>
      </div>
    </Col>
    {/* More stat columns... */}
  </Row>
</CardHeader>
```

---

## 7. ExportCSV Modal

```tsx
<ExportCSVModal show={isExportCSV} onCloseClick={() => setIsExportCSV(false)} data={data} />
```

---

## 8. Pagination Component

```tsx
<Pagination
  perPageData={perPage}
  data={data}
  currentPage={currentPage}
  setCurrentPage={setCurrentPage}
/>
```

---

## 9. Chart Patterns (ApexCharts)

```tsx
import ReactApexChart from "react-apexcharts";

const MyChart = ({ chartId, series }: { chartId: string; series: any[] }) => {
  const options: ApexCharts.ApexOptions = {
    chart: { height: 350, type: 'area', toolbar: { show: false } },
    colors: ['#0ab39c', '#405189', '#f06548'],
    stroke: { curve: 'smooth', width: 2 },
    fill: { type: 'gradient', gradient: { opacityFrom: 0.4, opacityTo: 0.1 } },
    xaxis: { categories: [...] },
    yaxis: { labels: { formatter: (value) => `$${value}k` } },
  };

  return <ReactApexChart id={chartId} options={options} series={series} type="area" height={350} />;
};
```

Chart color hook:
```tsx
import useChartColors from "../../Components/Common/useChartColors";
const chartColors = useChartColors(chartId);
```

---

## 10. Form with Formik + Yup

```tsx
import { useFormik } from "formik";
import * as Yup from "yup";

const validation = useFormik({
  enableReinitialize: true,
  initialValues: { name: '', email: '', status: 'Active' },
  validationSchema: Yup.object({
    name: Yup.string().required("Please enter name"),
    email: Yup.string().email().required("Please enter email"),
  }),
  onSubmit: (values) => {
    // dispatch action
  },
});

<Form onSubmit={validation.handleSubmit}>
  <div className="mb-3">
    <Label className="form-label">Name</Label>
    <Input
      name="name"
      type="text"
      onChange={validation.handleChange}
      onBlur={validation.handleBlur}
      value={validation.values.name}
      invalid={validation.touched.name && !!validation.errors.name}
    />
    {validation.touched.name && validation.errors.name && (
      <FormFeedback type="invalid">{validation.errors.name}</FormFeedback>
    )}
  </div>
</Form>
```

---

## 11. CRUD Page Pattern (Full)

A typical CRUD list page combines:

1. **BreadCrumb** at top
2. **Card** with header (title + Add button)
3. **TableContainer** with columns + global filter
4. **Add/Edit Modal** (Formik form) triggered by button
5. **DeleteModal** for delete confirmation
6. **Toast notifications** via react-toastify

```tsx
const [modal, setModal] = useState(false);
const [deleteModal, setDeleteModal] = useState(false);
const [isEdit, setIsEdit] = useState(false);
const [selectedItem, setSelectedItem] = useState<any>(null);

const toggle = useCallback(() => {
  setModal(!modal);
  if (!modal) { setIsEdit(false); setSelectedItem(null); }
}, [modal]);

const handleEdit = (item: any) => {
  setSelectedItem(item);
  setIsEdit(true);
  setModal(true);
};

const handleDelete = (item: any) => {
  setSelectedItem(item);
  setDeleteModal(true);
};
```

---

## 12. FilePond (File Upload)

```tsx
import { FilePond, registerPlugin } from 'react-filepond';
import 'filepond/dist/filepond.min.css';
import FilePondPluginImageExifOrientation from 'filepond-plugin-image-exif-orientation';
import FilePondPluginImagePreview from 'filepond-plugin-image-preview';
import 'filepond-plugin-image-preview/dist/filepond-plugin-image-preview.css';

registerPlugin(FilePondPluginImageExifOrientation, FilePondPluginImagePreview);

const [files, setFiles] = useState<any>([]);

<FilePond
  files={files}
  onupdatefiles={setFiles}
  allowMultiple={true}
  maxFiles={3}
  name="files"
  className="filepond filepond-input-multiple"
/>
```

**Packages:** `filepond`, `react-filepond`, `filepond-plugin-image-preview`, `filepond-plugin-image-exif-orientation`

### Dropzone (Alternative File Upload)

```tsx
import Dropzone from "react-dropzone";

<Dropzone onDrop={(acceptedFiles) => handleAcceptedFiles(acceptedFiles)}>
  {({ getRootProps, getInputProps }) => (
    <div className="dropzone dz-clickable">
      <div className="dz-message needsclick" {...getRootProps()}>
        <div className="mb-3">
          <i className="display-4 text-muted ri-upload-cloud-2-fill" />
        </div>
        <h4>Drop files here or click to upload.</h4>
      </div>
    </div>
  )}
</Dropzone>
```

**Package:** `react-dropzone`

---

## 13. FullCalendar

```tsx
import FullCalendar from "@fullcalendar/react";
import dayGridPlugin from "@fullcalendar/daygrid";
import interactionPlugin from "@fullcalendar/interaction";
import listPlugin from "@fullcalendar/list";
import multiMonthPlugin from "@fullcalendar/multimonth";
import BootstrapTheme from "@fullcalendar/bootstrap";

<FullCalendar
  plugins={[dayGridPlugin, interactionPlugin, listPlugin, multiMonthPlugin, BootstrapTheme]}
  themeSystem="bootstrap"
  headerToolbar={{
    left: "prev,next today",
    center: "title",
    right: "dayGridMonth,dayGridWeek,dayGridDay,listMonth,multiMonthYear",
  }}
  initialView="dayGridMonth"
  editable={true}
  selectable={true}
  selectMirror={true}
  dayMaxEvents={true}
  events={events}
  dateClick={handleDateClick}
  eventClick={handleEventClick}
  eventDrop={onDrop}
/>
```

**Packages:** `@fullcalendar/react`, `@fullcalendar/daygrid`, `@fullcalendar/interaction`, `@fullcalendar/list`, `@fullcalendar/multimonth`, `@fullcalendar/bootstrap`

---

## 14. CKEditor 5 & Quill

### CKEditor 5
```tsx
import { CKEditor } from "@ckeditor/ckeditor5-react";
import ClassicEditor from "@ckeditor/ckeditor5-build-classic";

<CKEditor
  editor={ClassicEditor}
  data="<p>Hello from CKEditor 5!</p>"
  onChange={(event: any, editor: any) => {
    const data = editor.getData();
  }}
/>
```
**Packages:** `@ckeditor/ckeditor5-react`, `@ckeditor/ckeditor5-build-classic`

### Quill
```tsx
import { useQuill } from "react-quilljs";
import "quill/dist/quill.snow.css";
import "quill/dist/quill.bubble.css";

const { quill, quillRef } = useQuill({ theme: "snow" });
<div ref={quillRef} />
```
**Packages:** `quill`, `react-quilljs`

---

## 15. Swiper Carousel

```tsx
import { Swiper, SwiperSlide } from "swiper/react";
import { Autoplay, Navigation, Pagination } from "swiper/modules";
import "swiper/css";
import "swiper/css/navigation";
import "swiper/css/pagination";

<Swiper
  modules={[Autoplay, Navigation, Pagination]}
  spaceBetween={30}
  slidesPerView={3}
  autoplay={{ delay: 3000, disableOnInteraction: false }}
  navigation={true}
  pagination={{ clickable: true }}
  loop={true}
>
  <SwiperSlide>
    <Card className="card-animate">...</Card>
  </SwiperSlide>
</Swiper>
```

**Package:** `swiper` | **CSS classes:** `swiper-button-next`, `swiper-button-prev`, `swiper-pagination`

---

## 16. SweetAlert2

```tsx
import Swal from "sweetalert2";

// Confirm Delete
Swal.fire({
  title: "Are you sure?",
  text: "You won't be able to revert this!",
  icon: "warning",
  showCancelButton: true,
  confirmButtonClass: "btn btn-primary w-xs me-2 mt-2",
  cancelButtonClass: "btn btn-danger w-xs mt-2",
  confirmButtonText: "Yes, delete it!",
  buttonsStyling: false,
  showCloseButton: true,
}).then((result) => {
  if (result.value) {
    Swal.fire({ title: "Deleted!", text: "Record deleted.", icon: "success",
      confirmButtonClass: "btn btn-primary w-xs mt-2", buttonsStyling: false });
  }
});

// Success Notification
Swal.fire({ title: "Good job!", text: "You clicked the button!", icon: "success",
  confirmButtonClass: "btn btn-primary", buttonsStyling: false });
```

**Package:** `sweetalert2` | **SCSS:** `plugins/_sweetalert2.scss` | **Images:** `images/sweetalert2/`

---

## 17. Choices.js / React-Select (Enhanced Select)

```tsx
import Select from "react-select";

// Single Select
<Select
  value={selectedSingle}
  onChange={setSelectedSingle}
  options={[
    { value: "choices-1", label: "City" },
    { value: "choices-2", label: "Developer" },
  ]}
  className="mb-0"
  classNamePrefix="react-select"
/>

// Multi Select
<Select
  value={selectedMulti}
  isMulti={true}
  onChange={setSelectedMulti}
  options={groupOptions}
  className="mb-0"
  classNamePrefix="react-select"
/>

// Grouped Options
const groupOptions = [
  { label: "UK", options: [{ value: "London", label: "London" }] },
  { label: "FR", options: [{ value: "Paris", label: "Paris" }] },
];
```

**Package:** `react-select` | HTML variants use `choices.js` directly

---

## 18. Lightbox (yet-another-react-lightbox)

```tsx
import Lightbox from "yet-another-react-lightbox";
import "yet-another-react-lightbox/styles.css";

const [isOpen, setIsOpen] = useState(false);
const [photoIndex, setPhotoIndex] = useState(0);

{isOpen && (
  <Lightbox
    mainSrc={images[photoIndex]}
    nextSrc={images[(photoIndex + 1) % images.length]}
    prevSrc={images[(photoIndex + images.length - 1) % images.length]}
    onCloseRequest={() => setIsOpen(false)}
    onMovePrevRequest={() => setPhotoIndex((photoIndex + images.length - 1) % images.length)}
    onMoveNextRequest={() => setPhotoIndex((photoIndex + 1) % images.length)}
  />
)}
```

**Package:** `yet-another-react-lightbox` | HTML variants use `glightbox`

---

## How to Add a New Page (Consolidated Guide)

### Step 1: Create Page Component

```tsx
// src/pages/MyModule/MyPage.tsx
import React from "react";
import { Container, Row, Col, Card, CardBody, CardHeader } from "reactstrap";
import BreadCrumb from "../../Components/Common/BreadCrumb";

const MyPage = () => {
    document.title = "My Page | App Name";

    return (
        <div className="page-content">
            <Container fluid>
                <BreadCrumb title="My Page" pageTitle="My Module" />
                <Row>
                    <Col lg={12}>
                        <Card>
                            <CardHeader>
                                <h5 className="card-title mb-0">Title</h5>
                            </CardHeader>
                            <CardBody>
                                {/* Page content */}
                            </CardBody>
                        </Card>
                    </Col>
                </Row>
            </Container>
        </div>
    );
};

export default MyPage;
```

### Step 2: Add Route

```tsx
// src/Routes/allRoutes.tsx
import MyPage from "../pages/MyModule/MyPage";

const authProtectedRoutes = [
    // ... existing routes
    { path: "/my-module/my-page", component: <MyPage /> },
];
```

### Step 3: Add Sidebar Menu Item

```tsx
// In sidebar menu data (src/Layouts/LayoutMenuData.tsx):
{
    id: "myModule",
    label: "My Module",
    icon: "ri-apps-line",
    link: "/#",
    stateVariables: isMyModule,
    click: (e: any) => { e.preventDefault(); setIsMyModule(!isMyModule); },
    subItems: [
        { id: "myPage", label: "My Page", link: "/my-module/my-page", parentId: "myModule" },
    ],
}
```

### Step 4: Add Redux Slice (if needed)

```tsx
// src/slices/myModule/reducer.ts
import { createSlice } from "@reduxjs/toolkit";

const initialState = { items: [], loading: false, error: null };

const myModuleSlice = createSlice({
    name: "MyModule",
    initialState,
    reducers: {},
    extraReducers: (builder) => {
        // Handle thunks
    },
});

export default myModuleSlice.reducer;

// Register in src/slices/index.ts:
import MyModuleReducer from "./myModule/reducer";
// Add to combineReducers: MyModule: MyModuleReducer,
```

### Common Components Quick Reference

| Component | Import | Usage |
|-----------|--------|-------|
| `BreadCrumb` | `Components/Common/BreadCrumb` | Every page |
| `DeleteModal` | `Components/Common/DeleteModal` | CRUD pages |
| `TableContainer` | `Components/Common/TableContainer` | Data tables |
| `Loader` | `Components/Common/Loader` | Loading state |
| `Spinner` | `Components/Common/Spinner` | Inline loading |
| `Pagination` | `Components/Common/Pagination` | List pagination |
| `ExportCSVModal` | `Components/Common/ExportCSVModal` | CSV export |
| `PreviewCardHeader` | `Components/Common/PreviewCardHeader` | UI examples |

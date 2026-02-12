# API Layer, Auth, i18n & Helpers Reference

Common patterns shared across all Velzon variants: API client, URL helpers, authentication flows, i18n, and toast notifications.

---

## 1. API Client (React-TS / Next-TS)

```tsx
// helpers/api_helper.ts
import axios, { AxiosResponse, AxiosRequestConfig } from 'axios';
import config from "../config";

const { api } = config;
axios.defaults.baseURL = api.API_URL;
axios.defaults.headers.post["Content-Type"] = "application/json";

// Auth token from session
const authUser: any = sessionStorage.getItem("authUser");
const token = JSON.parse(authUser) ? JSON.parse(authUser).token : null;
if (token) axios.defaults.headers.common["Authorization"] = "Bearer " + token;

// Response interceptor
axios.interceptors.response.use(
    (response) => response.data ? response.data : response,
    (error) => {
        let message;
        switch (error.status) {
            case 500: message = "Internal Server Error"; break;
            case 401: message = "Invalid credentials"; break;
            case 404: message = "Data not found"; break;
            default: message = error.message || error;
        }
        return Promise.reject(message);
    }
);

const setAuthorization = (token: string) => {
    axios.defaults.headers.common["Authorization"] = "Bearer " + token;
};

class APIClient {
    get = (url: string, params?: any): Promise<AxiosResponse> => {
        let paramKeys: string[] = [];
        if (params) {
            Object.keys(params).map(key => {
                paramKeys.push(key + '=' + params[key]);
                return paramKeys;
            });
            const queryString = paramKeys.length ? paramKeys.join('&') : "";
            return axios.get(`${url}?${queryString}`, params);
        }
        return axios.get(url, params);
    };
    create = (url: string, data: any) => axios.post(url, data);
    update = (url: string, data: any) => axios.patch(url, data);
    put = (url: string, data: any) => axios.put(url, data);
    delete = (url: string, config?: AxiosRequestConfig) => axios.delete(url, { ...config });
}

export { APIClient, setAuthorization };
```

---

## 2. URL Helper Pattern

```tsx
// helpers/url_helper.ts
// Auth
export const POST_FAKE_LOGIN = "/auth/signin";
export const POST_FAKE_REGISTER = "/auth/signup";
export const POST_FAKE_PASSWORD_FORGET = "/auth/forgot-password";

// CRUD pattern: GET/ADD/UPDATE/DELETE use same base URL
export const GET_PRODUCTS = "/apps/product";
export const ADD_NEW_PRODUCT = "/apps/product";
export const UPDATE_PRODUCT = "/apps/product";
export const DELETE_PRODUCT = "/apps/product";

export const GET_ORDERS = "/apps/order";
export const GET_CUSTOMERS = "/apps/customer";
export const GET_CONTACTS = "/apps/contact";
export const GET_COMPANIES = "/apps/company";
export const GET_LEADS = "/apps/lead";
export const GET_INVOICES = "/apps/invoice";
export const GET_TICKETS_LIST = "/apps/ticket";
export const GET_TASK_LIST = "/apps/task";

// Dashboard data
export const GET_ALLREVENUE_DATA = "/allRevenue-data";
export const GET_MONTHREVENUE_DATA = "/monthRevenue-data";
export const GET_HALFYEARREVENUE_DATA = "/halfYearRevenue-data";
export const GET_YEARREVENUE_DATA = "/yearRevenue-data";
```

**Pattern:** Each resource has 4 constants (GET/ADD/UPDATE/DELETE) pointing to the same base URL. The HTTP method differentiates the action.

### Redux Slice Inventory (24 slices)

All slices are in `src/slices/{name}/` with `reducer.ts` + `thunk.ts`:

| Slice | Import Path | Purpose |
|-------|-------------|---------|
| `auth` | `slices/auth` | Login, register, profile, password |
| `layouts` | `slices/layouts` | Theme, sidebar, topbar state |
| `calendar` | `slices/calendar` | FullCalendar events CRUD |
| `chat` | `slices/chat` | Chat messages, channels |
| `crm` | `slices/crm` | Contacts, companies, leads, deals |
| `crypto` | `slices/crypto` | Crypto transactions, orders |
| `ecommerce` | `slices/ecommerce` | Products, orders, customers, sellers |
| `projects` | `slices/projects` | Projects CRUD |
| `tasks` | `slices/tasks` | Task/Kanban boards |
| `tickets` | `slices/tickets` | Support tickets |
| `invoice` | `slices/invoice` | Invoices CRUD |
| `jobs` | `slices/jobs` | Job listings, applications |
| `mailbox` | `slices/mailbox` | Email/mailbox |
| `fileManager` | `slices/fileManager` | Files, folders |
| `todos` | `slices/todos` | Todo items |
| `team` | `slices/team` | Team members |
| `apiKey` | `slices/apiKey` | API key management |
| `dashboardEcommerce` | `slices/dashboardEcommerce` | Ecommerce dashboard data |
| `dashboardCRM` | `slices/dashboardCRM` | CRM dashboard data |
| `dashboardAnalytics` | `slices/dashboardAnalytics` | Analytics dashboard data |
| `dashboardCrypto` | `slices/dashboardCrypto` | Crypto dashboard data |
| `dashboardProject` | `slices/dashboardProject` | Project dashboard data |
| `dashboardNFT` | `slices/dashboardNFT` | NFT dashboard data |
| `dashboardJob` | `slices/dashboardJob` | Job dashboard data |

---

## 3. Authentication Flow Patterns

### Login Page (Basic Variant)
```tsx
const Login = () => {
    document.title = "Sign In | App Name";
    const dispatch = useDispatch();
    const navigate = useNavigate();

    const validation = useFormik({
        initialValues: { email: '', password: '' },
        validationSchema: Yup.object({
            email: Yup.string().required("Please enter email"),
            password: Yup.string().required("Please enter password"),
        }),
        onSubmit: (values) => {
            dispatch(loginUser(values, navigate));
        },
    });

    return (
        <div className="auth-page-wrapper pt-5">
            <div className="auth-one-bg-position auth-one-bg" id="auth-particles">
                {/* Particles background */}
            </div>
            <div className="auth-page-content">
                <Container>
                    <Row className="justify-content-center">
                        <Col md={8} lg={6} xl={5}>
                            <Card className="mt-4 card-bg-fill">
                                <CardBody className="p-4">
                                    <div className="text-center mt-2">
                                        <h5 className="text-primary">Welcome Back!</h5>
                                        <p className="text-muted">Sign in to continue.</p>
                                    </div>
                                    <Form onSubmit={validation.handleSubmit}>
                                        {/* Form fields */}
                                    </Form>
                                </CardBody>
                            </Card>
                        </Col>
                    </Row>
                </Container>
            </div>
            <footer className="footer">
                <Container><Row>...</Row></Container>
            </footer>
        </div>
    );
};
```

### Login Page (Cover Variant)
```tsx
const CoverLogin = () => {
    return (
        <div className="auth-page-wrapper auth-bg-cover py-5 d-flex justify-content-center
                        align-items-center min-vh-100">
            <div className="bg-overlay"></div>
            <div className="auth-page-content overflow-hidden pt-lg-5">
                <Container>
                    <Row>
                        <Col lg={6}>
                            {/* Left side: branding + features */}
                            <div className="p-lg-5 p-4 auth-one-bg h-100">
                                <div className="bg-overlay"></div>
                                {/* Logo + carousel content */}
                            </div>
                        </Col>
                        <Col lg={6}>
                            {/* Right side: login form */}
                            <div className="p-lg-5 p-4">
                                <Form onSubmit={validation.handleSubmit}>
                                    {/* Same form fields */}
                                </Form>
                            </div>
                        </Col>
                    </Row>
                </Container>
            </div>
        </div>
    );
};
```

### Auth CSS Gradient
```css
/* Auth cover background */
.auth-bg-cover {
    background: linear-gradient(-45deg, var(--vz-primary) 50%, var(--vz-success));
}
```

---

## 4. i18n Configuration

```tsx
// i18n.ts
import i18n from "i18next";
import detector from "i18next-browser-languagedetector";
import { initReactI18next } from "react-i18next";

import translationENG from "./locales/en.json";
import translationGR from "./locales/gr.json";
import translationIT from "./locales/it.json";
import translationRS from "./locales/ru.json";
import translationSP from "./locales/sp.json";
import translationCN from "./locales/ch.json";
import translationFR from "./locales/fr.json";
import translationAR from "./locales/ar.json";

const resources = {
    en: { translation: translationENG },
    gr: { translation: translationGR },
    it: { translation: translationIT },
    rs: { translation: translationRS },
    sp: { translation: translationSP },
    cn: { translation: translationCN },
    fr: { translation: translationFR },
    ar: { translation: translationAR },
};

i18n.use(detector).use(initReactI18next).init({
    resources,
    lng: localStorage.getItem("I18N_LANGUAGE") || "en",
    fallbackLng: "en",
    keySeparator: false,
    interpolation: { escapeValue: false },
});
```

### Usage in Components
```tsx
import { useTranslation } from "react-i18next";

const MyComponent = () => {
    const { t } = useTranslation();
    return <h4>{t("Dashboard")}</h4>;
};
```

### Language Switcher
```tsx
const changeLanguageAction = (lang: string) => {
    i18n.changeLanguage(lang);
    localStorage.setItem("I18N_LANGUAGE", lang);
};

// Dropdown with flags
<DropdownMenu className="notify-item language">
    <DropdownItem onClick={() => changeLanguageAction("en")}>
        <img src={usFlag} className="me-2 rounded" height="18" />
        <span>English</span>
    </DropdownItem>
    {/* ... other languages */}
</DropdownMenu>
```

---

## 5. Toast Notifications (react-toastify)

```tsx
import { toast, ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

// Success
toast.success("Record added successfully", { autoClose: 3000 });

// Error
toast.error("Failed to delete record", { autoClose: 3000 });

// Warning
toast.warning("This action cannot be undone");

// Info
toast.info("Processing your request...");

// In root layout
<ToastContainer closeButton={false} limit={1} />
```

---

## 6. File Upload Patterns

### Dropzone
```tsx
import Dropzone from "react-dropzone";

<Dropzone onDrop={(files) => handleAcceptedFiles(files)}>
    {({ getRootProps, getInputProps }) => (
        <div className="dropzone dz-clickable" {...getRootProps()}>
            <input {...getInputProps()} />
            <div className="dz-message needsclick">
                <div className="mb-3">
                    <i className="display-4 text-muted ri-upload-cloud-2-fill" />
                </div>
                <h4>Drop files here or click to upload.</h4>
            </div>
        </div>
    )}
</Dropzone>
```

### FilePond
```tsx
import { FilePond, registerPlugin } from 'react-filepond';
import 'filepond/dist/filepond.min.css';
import FilePondPluginImagePreview from 'filepond-plugin-image-preview';
registerPlugin(FilePondPluginImagePreview);

<FilePond
    files={files}
    onupdatefiles={setFiles}
    allowMultiple={true}
    maxFiles={3}
    name="files"
    className="filepond filepond-input-multiple"
/>
```

---

## 7. Date Picker (Flatpickr)

```tsx
import Flatpickr from "react-flatpickr";
import "flatpickr/dist/themes/material_blue.css";

<Flatpickr
    className="form-control"
    placeholder="Select date"
    options={{
        dateFormat: "d M, Y",
        defaultDate: new Date(),
    }}
    onChange={(date) => setSelectedDate(date[0])}
/>

// Date range
<Flatpickr
    options={{
        mode: "range",
        dateFormat: "d M, Y",
    }}
/>

// With time
<Flatpickr
    options={{
        enableTime: true,
        dateFormat: "d M, Y H:i",
    }}
/>
```

---

## 8. Avatar Variants

```html
<!-- Sizes -->
<div class="avatar-xxs">...</div>   <!-- 24px -->
<div class="avatar-xs">...</div>    <!-- 32px -->
<div class="avatar-sm">...</div>    <!-- 40px -->
<div class="avatar-md">...</div>    <!-- 48px -->
<div class="avatar-lg">...</div>    <!-- 56px -->
<div class="avatar-xl">...</div>    <!-- 64px -->
<div class="avatar-xxl">...</div>   <!-- 80px -->

<!-- With image -->
<div class="avatar-sm">
    <img src={avatar} alt="" class="rounded-circle" />
</div>

<!-- With initials -->
<div class="avatar-sm">
    <div class="avatar-title rounded-circle bg-primary-subtle text-primary">
        AB
    </div>
</div>

<!-- Avatar group -->
<div class="avatar-group">
    <div class="avatar-group-item">
        <div class="avatar-xs"><img src={avatar1} class="rounded-circle" /></div>
    </div>
    <div class="avatar-group-item">
        <div class="avatar-xs"><img src={avatar2} class="rounded-circle" /></div>
    </div>
    <div class="avatar-group-item">
        <div class="avatar-xs">
            <div class="avatar-title rounded-circle bg-light text-primary">+3</div>
        </div>
    </div>
</div>

<!-- With status badge -->
<div class="avatar-sm position-relative">
    <img src={avatar} class="rounded-circle" />
    <span class="position-absolute top-0 start-100 translate-middle badge
                 border border-light rounded-circle bg-success p-1">
        <span class="visually-hidden">Online</span>
    </span>
</div>
```

---

## 9. Dropdown Action Menu (Table Rows)

```tsx
import { UncontrolledDropdown, DropdownToggle, DropdownMenu, DropdownItem } from "reactstrap";

<UncontrolledDropdown>
    <DropdownToggle href="#" className="btn btn-soft-secondary btn-sm" tag="button">
        <i className="ri-more-fill align-middle" />
    </DropdownToggle>
    <DropdownMenu className="dropdown-menu-end">
        <DropdownItem href={`/detail/${item.id}`}>
            <i className="ri-eye-fill align-bottom me-2 text-muted" /> View
        </DropdownItem>
        <DropdownItem onClick={() => handleEdit(item)}>
            <i className="ri-pencil-fill align-bottom me-2 text-muted" /> Edit
        </DropdownItem>
        <DropdownItem divider />
        <DropdownItem onClick={() => handleDelete(item.id)}>
            <i className="ri-delete-bin-fill align-bottom me-2 text-muted" /> Delete
        </DropdownItem>
    </DropdownMenu>
</UncontrolledDropdown>
```

---

## 10. Empty State / Loading

```tsx
// Empty state
<div className="py-4 text-center">
    <lord-icon src="https://cdn.lordicon.com/msoeawqm.json"
        trigger="loop" colors="primary:#405189,secondary:#0ab39c"
        style={{ width: "72px", height: "72px" }} />
    <h5 className="mt-4">Sorry! No Result Found</h5>
    <p className="text-muted mb-0">We've searched more than 150+ records.</p>
</div>

// Loading spinner
<div className="d-flex justify-content-center">
    <Spinner color="primary" />
</div>

// Placeholder/Skeleton
<Card>
    <CardBody>
        <p className="card-text placeholder-glow">
            <span className="placeholder col-7"></span>
            <span className="placeholder col-4"></span>
            <span className="placeholder col-6"></span>
        </p>
    </CardBody>
</Card>
```

---

## 11. Offcanvas Pattern

```tsx
import { Offcanvas, OffcanvasHeader, OffcanvasBody } from "reactstrap";

const [isOpen, setIsOpen] = useState(false);

<Offcanvas isOpen={isOpen} toggle={() => setIsOpen(!isOpen)}
           direction="end" className="offcanvas-end border-0">
    <OffcanvasHeader toggle={() => setIsOpen(false)}>
        Filters
    </OffcanvasHeader>
    <OffcanvasBody>
        {/* Filter form content */}
    </OffcanvasBody>
</Offcanvas>
```

---

## 12. Tabs/Pills Navigation

```tsx
import { Nav, NavItem, NavLink, TabContent, TabPane } from "reactstrap";
import classnames from "classnames";

const [activeTab, setActiveTab] = useState("1");

<Nav tabs className="nav-tabs-custom nav-success">
    <NavItem>
        <NavLink className={classnames({ active: activeTab === "1" })}
                 onClick={() => setActiveTab("1")}>
            <i className="ri-store-2-fill me-1 align-bottom" /> All Orders
        </NavLink>
    </NavItem>
    <NavItem>
        <NavLink className={classnames({ active: activeTab === "2" })}
                 onClick={() => setActiveTab("2")}>
            <i className="ri-checkbox-circle-line me-1 align-bottom" /> Delivered
        </NavLink>
    </NavItem>
</Nav>

<TabContent activeTab={activeTab}>
    <TabPane tabId="1">{/* Content */}</TabPane>
    <TabPane tabId="2">{/* Content */}</TabPane>
</TabContent>
```

### Tab Variants
```
nav-tabs                     → Standard underline tabs
nav-tabs-custom              → Custom styled tabs
nav-tabs-custom nav-success  → Success-colored active tab
nav-pills                    → Pill (filled) style
nav-pills-custom             → Custom pill style
nav-pills nav-justified      → Full-width justified pills
```

---

## 13. Timeline Component

```tsx
<div className="timeline">
    <div className="timeline-item left">
        <i className="icon ri-checkbox-circle-fill text-success" />
        <div className="date">02 Jan 2024</div>
        <div className="content">
            <h5>Order Placed</h5>
            <p className="text-muted">Order #VZ2451 placed.</p>
        </div>
    </div>
    <div className="timeline-item right">
        <i className="icon ri-truck-line text-primary" />
        <div className="date">03 Jan 2024</div>
        <div className="content">
            <h5>Shipped</h5>
            <p className="text-muted">Package picked up.</p>
        </div>
    </div>
</div>
```

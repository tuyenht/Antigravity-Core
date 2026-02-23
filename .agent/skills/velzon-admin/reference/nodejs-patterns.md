# Node.js (Express + EJS) Patterns Reference

Patterns for building Velzon-style admin pages using Express.js, EJS templates, and Webpack.

---

## 1. Project Structure

```
project/
├── app.js                    # Express entry point
├── config.env                # Environment variables
├── package.json              # Dependencies
├── webpack.config.js         # Asset compilation
├── package-libs-config.json  # Vendor library list
│
├── controllers/
│   └── AuthController.js     # Auth logic (login, signup, password reset)
│
├── models/
│   └── UserModel.js          # Mongoose schema (User)
│
├── routes/
│   └── routes.js             # All route definitions
│
├── utils/
│   └── email.js              # Nodemailer utility
│
├── i18n/                     # Locale JSONs
│   ├── en.json               # English (default)
│   ├── ar.json               # Arabic
│   ├── ch.json               # Chinese
│   ├── fr.json               # French
│   ├── gr.json               # German
│   ├── it.json               # Italian
│   ├── ru.json               # Russian
│   └── sp.json               # Spanish
│
├── src/assets/               # Source assets
│   ├── scss/                 # SCSS source files
│   │   ├── app.scss          # Main app styles
│   │   ├── bootstrap.scss    # Bootstrap compilation
│   │   └── icons.scss        # Icon fonts
│   ├── js/                   # Client-side JavaScript
│   ├── images/               # Image assets
│   ├── fonts/                # Font files
│   ├── json/                 # JSON data files
│   └── lang/                 # Client-side language files
│
├── public/assets/            # Webpack output (compiled)
│   ├── css/                  # Compiled CSS (app.min.css, bootstrap.min.css)
│   ├── js/                   # Copied JS
│   ├── libs/                 # Copied vendor libraries
│   └── images/               # Copied images
│
└── views/
    ├── layouts/              # EJS master layouts
    │   ├── layout.ejs                  # Default (vertical sidebar)
    │   ├── layout-horizontal.ejs       # Horizontal navigation
    │   ├── layout-twocolumn.ejs        # Two-column layout
    │   ├── layout-detached.ejs         # Detached sidebar
    │   ├── layout-verti-hoverd.ejs     # Vertical hovered sidebar
    │   ├── layout-without-nav.ejs      # Auth pages (no sidebar/topbar)
    │   └── layout-without-bradcrumb.ejs # Without breadcrumb
    ├── partials/             # Shared EJS partials
    │   ├── topbar.ejs        # Top navigation bar
    │   ├── sidebar.ejs       # Sidebar container
    │   ├── menu.ejs          # Sidebar menu items
    │   ├── footer.ejs        # Page footer
    │   ├── head-css.ejs      # CSS link tags
    │   ├── vendor-scripts.ejs # Vendor JS scripts
    │   ├── customizer.ejs    # Theme customizer panel
    │   ├── page-title.ejs    # Breadcrumb + page title
    │   └── title-meta.ejs    # Meta tags
    └── *.ejs                 # 195+ page views
```

---

## 2. Express App Setup (app.js)

```javascript
const express = require("express");
const app = express();
const path = require("path");
const session = require("express-session");
const cookieParser = require("cookie-parser");
const flash = require("connect-flash");
const expressLayout = require("express-ejs-layouts");
const i18n = require("i18n-express");
const fileupload = require("express-fileupload");

// Load env vars
require("dotenv").config({ path: "config.env" });

// View engine + layouts
app.set("view engine", "ejs");
app.set("layout", "layouts/layout");     // Default master layout
app.use(expressLayout);

// Static files
app.use(express.static(path.join(__dirname, "public")));

// Body parsers
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Session + Flash
app.use(session({
    secret: "velzon-secret-key",
    resave: false,
    saveUninitialized: false,
    cookie: { maxAge: 24 * 60 * 60 * 1000 } // 24h
}));
app.use(cookieParser());
app.use(flash());

// File upload
app.use(fileupload());

// i18n
app.use(i18n({
    translationsPath: path.join(__dirname, "i18n"),
    siteLangs: ["ar", "ch", "en", "fr", "gr", "it", "ru", "sp"],
    textsVarName: "translation"
}));

// Routes
const routes = require("./routes/routes");
routes(app);

// Error handling
app.all("*", (req, res) => {
    res.status(404).render("auth-404-basic", {
        title: "404 Error",
        layout: "layouts/layout-without-nav"
    });
});

// Start server
const PORT = process.env.PORT || 8000;
app.listen(PORT, () => console.log(`Server on port ${PORT}`));
```

---

## 3. Route Pattern

All routes are defined in a single `routes.js` file. Each route calls `res.render()` with view name and locals:

```javascript
module.exports = function (route) {

    // ─── Auth Middleware ───────────────────────────────────────
    route.use((req, res, next) => {
        const uemail = req.session.useremail;
        const publicPaths = ["/login", "/register", "/forgotpassword", "/resetpassword", "/error"];
        if (publicPaths.includes(req.path)) {
            if (uemail) return res.redirect("/");
        } else if (!uemail) {
            return res.redirect("/login");
        }
        next();
    });

    // ─── Auth Routes (no-nav layout) ──────────────────────────
    route.get("/login", AuthController.login);
    route.post("/auth-validate", AuthController.validate);
    route.get("/register", (req, res) => {
        res.render("auth-signup-basic", {
            title: "Sign Up",
            layout: "layouts/layout-without-nav"
        });
    });
    route.post("/signup", AuthController.signup);
    route.get("/logout", AuthController.logout);

    // ─── Dashboard Routes (custom layout) ─────────────────────
    route.get("/", (req, res) => {
        res.render("index", {
            layout: "layouts/layout-without-bradcrumb",
            title: "Dashboard",
            page_title: "Dashboard",
            folder: "Dashboards"
        });
    });
    route.get("/dashboard-analytics", (req, res) => {
        res.render("dashboard-analytics", {
            title: "Analytics",
            page_title: "Analytics",
            folder: "Dashboards"
        });
    });

    // ─── Standard Page Routes (default layout) ────────────────
    route.get("/apps-ecommerce-products", (req, res) => {
        res.render("apps-ecommerce-products", {
            title: "Products",
            page_title: "Products",
            folder: "Ecommerce"
        });
    });

    // ─── Pages without nav (auth, errors, maintenance) ────────
    route.get("/auth-signin-basic", (req, res) => {
        res.render("auth-signin-basic", {
            title: "Sign In",
            layout: "layouts/layout-without-nav"
        });
    });
};
```

### Route `res.render()` Locals

| Property | Purpose | Example |
|----------|---------|---------|
| `title` | Page `<title>` tag | `"Products"` |
| `page_title` | Breadcrumb current page | `"Products"` |
| `folder` | Breadcrumb parent folder | `"Ecommerce"` |
| `layout` | Override default layout | `"layouts/layout-without-nav"` |

---

## 4. Layout System (EJS)

### Default Layout (`layout.ejs`)

```ejs
<!doctype html>
<html lang="en" data-layout="vertical" data-topbar="light" data-sidebar="dark"
      data-sidebar-size="lg" data-sidebar-image="none" data-preloader="disable">
<head>
  <meta charset="utf-8" />
  <title><%- title %> | Velzon - Admin & Dashboard Template</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="shortcut icon" href="/assets/images/favicon.ico">
  <%- HeaderCss %>
  <%- include('../partials/head-css.ejs') %>
</head>
<body>
  <div id="layout-wrapper">
    <%- include('../partials/topbar') %>
    <%- include('../partials/sidebar') %>
    <div class="main-content overflow-hidden">
      <div class="page-content">
        <div class="container-fluid">
          <%- include('../partials/page-title') %>
          <%- body %>
        </div>
      </div>
      <%- include('../partials/footer') %>
    </div>
  </div>
  <%- include('../partials/customizer') %>
  <%- include('../partials/vendor-scripts') %>
  <%- FooterJs %>
  <script src="/assets/js/app.js"></script>
</body>
</html>
```

### Auth Layout (`layout-without-nav.ejs`)

No sidebar, topbar, footer, or customizer — just head CSS + raw body + vendor scripts:

```ejs
<!doctype html>
<html lang="en" data-layout="vertical" data-topbar="light" data-sidebar="dark"
      data-sidebar-size="lg" data-theme="default">
<head>
  <meta charset="utf-8" />
  <title><%- title %> | Velzon - Admin & Dashboard Template</title>
  <link rel="shortcut icon" href="/assets/images/favicon.ico">
  <%- HeaderCss %>
  <%- include('../partials/head-css.ejs') %>
</head>
<body>
  <%- body %>
  <%- include('../partials/vendor-scripts') %>
  <%- FooterJs %>
</body>
</html>
```

### Available Layouts (7 Variants)

| Layout File | `data-layout` | Use Case |
|-------------|---------------|----------|
| `layout.ejs` | `vertical` | Default admin pages |
| `layout-horizontal.ejs` | `horizontal` | Top navigation bar |
| `layout-twocolumn.ejs` | `twocolumn` | Icon + expand sidebar |
| `layout-detached.ejs` | `semibox` | Detached sidebar |
| `layout-verti-hoverd.ejs` | `vertical` + `sm-hover` | Collapsed on hover |
| `layout-without-nav.ejs` | — | Auth, error pages |
| `layout-without-bradcrumb.ejs` | `vertical` | No breadcrumb (dashboards) |

---

## 5. View (EJS Page) Pattern

### Content Block System

EJS views inject content into layout slots using `contentFor`:

```ejs
<%- contentFor('HeaderCss') %>
<!-- Page-specific CSS -->
<link href="/assets/libs/jsvectormap/jsvectormap.min.css" rel="stylesheet" />
<link href="/assets/libs/swiper/swiper-bundle.min.css" rel="stylesheet" />

<%- contentFor('body') %>
<div class="row">
  <div class="col">
    <div class="h-100">
      <!-- Page content here -->
    </div>
  </div>
</div>

<%- contentFor('FooterJs') %>
<!-- Page-specific JS -->
<script src="/assets/libs/apexcharts/apexcharts.min.js"></script>
<script src="/assets/js/pages/dashboard-ecommerce.init.js"></script>
```

### Content Blocks

| Block | Purpose | Injected Into |
|-------|---------|---------------|
| `HeaderCss` | Page-specific CSS links | `<head>` |
| `body` | Main page content | `.container-fluid` |
| `FooterJs` | Page-specific JS scripts | Before `</body>` |

---

## 6. Partials Reference

| Partial | Purpose |
|---------|---------|
| `head-css.ejs` | Core CSS: Bootstrap, app.min.css, icons |
| `topbar.ejs` | Top navigation with search, notifications, language switcher, user menu |
| `sidebar.ejs` | Sidebar wrapper with `simplebar`, includes `menu.ejs` |
| `menu.ejs` | Navigation menu items with nested `<ul>` for submenus |
| `page-title.ejs` | Breadcrumb: `<%= folder %> / <%= page_title %>` |
| `footer.ejs` | Copyright footer |
| `customizer.ejs` | Theme settings panel (light/dark mode, sidebar color, layout type) |
| `vendor-scripts.ejs` | Core JS: Bootstrap bundle, simplebar, lord-icon, plugins |

---

## 7. Authentication (Sessions + MongoDB)

### User Model (Mongoose)

```javascript
const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
const crypto = require("crypto");

const UserSchema = new mongoose.Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    created_at: Date,
    passwordResetToken: String,
    passwordResetExpires: Date,
});

// Auto-hash password before save
UserSchema.pre("save", async function (next) {
    if (!this.isModified("password")) return next();
    this.password = await bcrypt.hash(this.password, 12);
    this.created_at = Date.now();
    next();
});

// Generate password reset token
UserSchema.methods.createPasswordResetToken = function () {
    let resetToken = crypto.randomBytes(32).toString("hex");
    this.passwordResetToken = resetToken;
    resetToken = resetToken + "|" + this._id;
    this.passwordResetExpires = Date.now() + 10 * 60 * 1000; // 10 min
    let bufferObj = Buffer.from(resetToken, "utf8");
    return bufferObj.toString("base64");
};

module.exports = mongoose.model("users", UserSchema);
```

### Auth Controller Pattern

```javascript
const User = require("../models/UserModel");
const bcrypt = require("bcryptjs");
const sendEmail = require("../utils/email");

// Login
const login = (req, res) => {
    if (res.locals.userLogin) return res.redirect("/");
    return res.render("login");
};

// Validate credentials
const validate = async (req, res) => {
    const { email, password } = req.body;
    const user = await User.findOne({ email });

    if (!user || !(await bcrypt.compare(password, user.password))) {
        req.flash("error", "Invalid Email or Password.");
        return res.redirect("/login");
    }

    // Set session
    req.session.userid = user._id;
    req.session.username = user.name;
    req.session.useremail = user.email;
    return res.redirect("/");
};

// Signup
const signup = async (req, res) => {
    const existsUser = await User.findOne({ email: req.body.email });
    if (existsUser) {
        req.flash("error", "Account already registered.");
        return res.redirect("/register");
    }
    await User.create({ name: req.body.username, email: req.body.email, password: req.body.password });
    req.flash("message", "Registration successful.");
    return res.redirect("/register");
};

// Logout
const logout = (req, res) => {
    req.session.destroy();
    res.redirect("/login");
};

module.exports = { login, validate, logout, signup };
```

### Auth Flow

```
Login → POST /auth-validate → bcrypt.compare → session.useremail → redirect /
Signup → POST /signup → User.create → auto-hash pre-save → flash + redirect
Logout → GET /logout → session.destroy → redirect /login
Password Reset → POST /sendforgotpasswordlink → crypto token → email → GET /resetpassword?token=
```

### Admin Prefix Auth Pages

> [!IMPORTANT]
> All auth screens use the **BaoSon glassmorphism design** defined in [auth-login-template.md](auth-login-template.md).
> Auth pages use `layout-without-nav.ejs` (no sidebar/topbar) at `/{adminPrefix}/login`.

#### Admin Auth Routes

```javascript
// routes/routes.js — Add admin prefix auth routes
const ADMIN_PREFIX = process.env.ADMIN_PREFIX || 'admin';

// Guest-only auth routes (no sidebar)
route.get(`/${ADMIN_PREFIX}/login`, (req, res) => {
    if (req.session.useremail) return res.redirect(`/${ADMIN_PREFIX}/dashboard`);
    res.render("admin-auth-login", {
        title: "Login — Admin",
        layout: "layouts/layout-without-nav"
    });
});

route.get(`/${ADMIN_PREFIX}/forgot-password`, (req, res) => {
    res.render("admin-auth-forgot-password", {
        title: "Forgot Password — Admin",
        layout: "layouts/layout-without-nav"
    });
});

route.get(`/${ADMIN_PREFIX}/reset-password/:token`, (req, res) => {
    res.render("admin-auth-reset-password", {
        title: "Reset Password — Admin",
        layout: "layouts/layout-without-nav",
        token: req.params.token
    });
});

route.get(`/${ADMIN_PREFIX}/two-factor/challenge`, (req, res) => {
    if (!req.session.useremail) return res.redirect(`/${ADMIN_PREFIX}/login`);
    res.render("admin-auth-two-factor", {
        title: "Two-Factor — Admin",
        layout: "layouts/layout-without-nav"
    });
});

route.post(`/${ADMIN_PREFIX}/login`, AuthController.validate);
route.post(`/${ADMIN_PREFIX}/forgot-password`, AuthController.sendResetLink);
route.post(`/${ADMIN_PREFIX}/reset-password`, AuthController.resetPassword);
route.post(`/${ADMIN_PREFIX}/two-factor/verify`, AuthController.verifyTwoFactor);
route.post(`/${ADMIN_PREFIX}/logout`, AuthController.logout);
```

#### Auth EJS Views

```
views/
├── admin-auth-login.ejs              ← BaoSon glassmorphism login
├── admin-auth-forgot-password.ejs    ← Email input → send reset link
├── admin-auth-reset-password.ejs     ← New password + confirm
├── admin-auth-two-factor.ejs         ← OTP code / recovery code
├── layouts/
│   └── layout-without-nav.ejs        ← Auth layout (no sidebar)
└── partials/
    └── admin-auth-card.ejs           ← Shared glass card partial
```

## 8. Webpack Build Pipeline

### Config Summary

```javascript
module.exports = {
    entry: {
        app: "./src/assets/scss/app.scss",
        bootstrap: "./src/assets/scss/bootstrap.scss",
        icons: "./src/assets/scss/icons.scss",
    },
    output: {
        path: path.resolve(__dirname, "public/assets/"),
        filename: "chunk/[name].js",
    },
    module: {
        rules: [
            { test: /\.scss$/, use: [MiniCssExtractPlugin.loader, "css-loader", "sass-loader"] }
        ]
    },
    plugins: [
        new MiniCssExtractPlugin({ filename: "css/[name].min.css" }),
        // RTL CSS generation (rtlcss)
        // CopyWebpackPlugin: images, js, json, lang, fonts
        // Vendor lib copy from node_modules → public/assets/libs/
    ]
};
```

### Build Commands

```bash
npm run build     # webpack --mode=production
npm run dev       # nodemon app.js (server)
```

### Webpack Features

- **SCSS → CSS**: Compiles `app.scss`, `bootstrap.scss`, `icons.scss` to minified CSS
- **RTL Support**: Auto-generates `app-rtl.min.css` and `bootstrap-rtl.min.css` via `rtlcss`
- **Asset Copying**: Images, JS, JSON, lang files, fonts → `public/assets/`
- **Vendor Libs**: Copies from `node_modules/` → `public/assets/libs/` based on `package-libs-config.json`

---

## 9. i18n (Server-Side)

```javascript
// Uses i18n-express middleware
app.use(i18n({
    translationsPath: path.join(__dirname, "i18n"),
    siteLangs: ["ar", "ch", "en", "fr", "gr", "it", "ru", "sp"],
    textsVarName: "translation"  // Accessible as translation.key in EJS
}));
```

### i18n JSON Format

```json
{
    "Dashboard": "Dashboard",
    "Ecommerce": "E-Commerce",
    "Products": "Products",
    "Orders": "Orders",
    "Calendar": "Calendar",
    "Chat": "Chat"
}
```

### Usage in EJS

```ejs
<span><%= translation.Dashboard %></span>
```

### Supported Languages (same across all variants)

| Code | Language |
|------|----------|
| en | English (default) |
| ar | Arabic |
| ch | Chinese |
| fr | French |
| gr | German |
| it | Italian |
| ru | Russian |
| sp | Spanish |

---

## 10. Email Utility (Nodemailer)

```javascript
const nodemailer = require("nodemailer");

const sendEmail = async (options) => {
    const transporter = nodemailer.createTransport({
        host: process.env.EMAIL_HOST,
        port: process.env.EMAIL_PORT,
        auth: {
            user: process.env.EMAIL_USERNAME,
            pass: process.env.EMAIL_PASSWORD
        }
    });

    await transporter.sendMail({
        from: process.env.EMAIL_FROM,
        to: options.email,
        subject: options.subject,
        html: options.message,
    });
};

module.exports = sendEmail;
```

---

## 11. Theme Skins (Chart Color System)

The Node variant supports 10 theme skins using `data-colors-{skin}` HTML attributes:

```ejs
<div id="customer_impression_charts"
  data-colors='["--vz-primary", "--vz-success", "--vz-danger"]'
  data-colors-minimal='["--vz-light", "--vz-primary", "--vz-info"]'
  data-colors-saas='["--vz-success", "--vz-info", "--vz-danger"]'
  data-colors-modern='["--vz-warning", "--vz-primary", "--vz-success"]'
  data-colors-interactive='["--vz-info", "--vz-primary", "--vz-danger"]'
  data-colors-creative='["--vz-warning", "--vz-primary", "--vz-danger"]'
  data-colors-corporate='["--vz-light", "--vz-primary", "--vz-secondary"]'
  data-colors-galaxy='["--vz-secondary", "--vz-primary", "--vz-primary-rgb, 0.50"]'
  data-colors-classic='["--vz-light", "--vz-primary", "--vz-secondary"]'
  data-colors-vintage='["--vz-success", "--vz-primary", "--vz-secondary"]'
  class="apex-charts" dir="ltr">
</div>
```

### Available Skins

| Skin | `data-colors-{skin}` Attribute |
|------|-------------------------------|
| Default | `data-colors` |
| Minimal | `data-colors-minimal` |
| SaaS | `data-colors-saas` |
| Modern | `data-colors-modern` |
| Interactive | `data-colors-interactive` |
| Creative | `data-colors-creative` |
| Corporate | `data-colors-corporate` |
| Galaxy | `data-colors-galaxy` |
| Classic | `data-colors-classic` |
| Vintage | `data-colors-vintage` |

The `app.js` client-side script reads the active skin and applies the correct color palette to ApexCharts.

---

## 12. Stat Cards (EJS Widget Pattern)

Matching the React `Widgets` component, but in static HTML:

```ejs
<div class="row">
  <div class="col-xl-3 col-md-6">
    <div class="card card-animate">
      <div class="card-body">
        <div class="d-flex align-items-center">
          <div class="flex-grow-1 overflow-hidden">
            <p class="text-uppercase fw-medium text-muted text-truncate mb-0">
              Total Earnings
            </p>
          </div>
          <div class="flex-shrink-0">
            <h5 class="text-success fs-14 mb-0">
              <i class="ri-arrow-right-up-line fs-13 align-middle"></i> +16.24 %
            </h5>
          </div>
        </div>
        <div class="d-flex align-items-end justify-content-between mt-4">
          <div>
            <h4 class="fs-22 fw-semibold ff-secondary mb-4">
              $<span class="counter-value" data-target="559.25">0</span>k
            </h4>
            <a href="" class="text-decoration-underline">View net earnings</a>
          </div>
          <div class="avatar-sm flex-shrink-0">
            <span class="avatar-title bg-success-subtle rounded fs-3">
              <i class="bx bx-dollar-circle text-success"></i>
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
  <!-- Repeat for Orders, Customers, Balance -->
</div>
```

**Key:** `data-target` on `.counter-value` spans powers the CountUp animation via `app.js`.

---

## 13. Client-Side JS Plugins (Same Across Variants)

| Plugin | Purpose | Script Path |
|--------|---------|-------------|
| `apexcharts` | Charts & graphs | `/assets/libs/apexcharts/` |
| `jsvectormap` | Vector maps | `/assets/libs/jsvectormap/` |
| `swiper` | Carousels/sliders | `/assets/libs/swiper/` |
| `simplebar` | Custom scrollbars | `/assets/libs/simplebar/` |
| `flatpickr` | Date pickers | `/assets/libs/flatpickr/` |
| `choices.js` | Select dropdowns | `/assets/libs/choices.js/` |
| `sweetalert2` | Alert dialogs | `/assets/libs/sweetalert2/` |
| `sortablejs` | Drag & drop | `/assets/libs/sortablejs/` |
| `list.js` | Searchable lists | `/assets/libs/list.js/` |
| `lord-icon` | Animated icons | Lord Icon CDN |

### Plugin Initialization (Per-Page)

```ejs
<%- contentFor('FooterJs') %>
<script src="/assets/libs/apexcharts/apexcharts.min.js"></script>
<script src="/assets/libs/swiper/swiper-bundle.min.js"></script>
<script src="/assets/js/pages/dashboard-ecommerce.init.js"></script>
```

Each page has a corresponding `pages/*.init.js` file that initializes plugins and renders charts.

---

## 14. Key Differences: Node vs React-TS

| Aspect | React-TS | Node (Express + EJS) |
|--------|----------|---------------------|
| **Rendering** | Client-side SPA | Server-side rendering |
| **State** | Redux Toolkit | Session + route locals |
| **Routing** | React Router v6 | Express routes |
| **Components** | React components | EJS partials/views |
| **Data Binding** | `useState`/`useSelector` | `<%= variable %>` |
| **Charts** | `ReactApexChart` component | `data-*` attributes + init.js |
| **Tables** | TanStack React Table | Native HTML + list.js |
| **Forms** | Formik + Yup | HTML forms + controller validation |
| **Auth** | Redux + JWT/session | Express session + bcrypt |
| **i18n** | `react-i18next` | `i18n-express` middleware |
| **Notifications** | `react-toastify` | `connect-flash` |
| **Build** | Vite/CRA | Webpack + nodemon |
| **Database** | API calls (any backend) | MongoDB (Mongoose) |
| **Layout Switch** | Redux state + data attrs | Layout file selection in `res.render()` |

---

## 15. Adding New Pages (Recipe)

### Step 1: Create EJS View

```ejs
<!-- views/apps-custom-list.ejs -->
<%- contentFor('HeaderCss') %>
<!-- Add page-specific CSS links -->

<%- contentFor('body') %>
<div class="row">
  <div class="col-lg-12">
    <div class="card">
      <div class="card-header">
        <h4 class="card-title mb-0">Custom List</h4>
      </div>
      <div class="card-body">
        <div class="table-responsive table-card">
          <table class="table table-hover table-centered align-middle table-nowrap mb-0">
            <!-- Table content -->
          </table>
        </div>
      </div>
    </div>
  </div>
</div>

<%- contentFor('FooterJs') %>
<!-- Add page-specific JS -->
<script src="/assets/js/pages/custom-list.init.js"></script>
```

### Step 2: Add Route

```javascript
route.get("/apps-custom-list", (req, res) => {
    res.render("apps-custom-list", {
        title: "Custom List",
        page_title: "Custom List",
        folder: "Apps"
    });
});
```

### Step 3: Add Menu Item

Edit `views/partials/menu.ejs`:

```ejs
<li class="nav-item">
    <a href="/apps-custom-list" class="nav-link" data-key="t-custom-list">
        <i class="ri-list-check"></i>
        <span data-key="t-custom-list">Custom List</span>
    </a>
</li>
```

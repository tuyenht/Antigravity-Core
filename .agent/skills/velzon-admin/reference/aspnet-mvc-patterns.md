# ASP.NET Patterns — Velzon Admin

Reference for **ASP.NET Core 8** (Razor Pages) and **ASP.NET MVC** (.NET Framework) variants. Both share identical view structure with different entry points.

---

## 1. Variant Comparison

| Feature | ASP.NET Core 8 | ASP.NET MVC |
|---------|----------------|-------------|
| **Entry point** | `Program.cs` (top-level) | `Global.asax.cs` |
| **Framework** | .NET 8+ | .NET Framework 4.x |
| **Project file** | `Velzon.csproj` (SDK-style) | `Velzon.csproj` (classic) |
| **Routing** | Convention-based via `MapControllerRoute` | `RouteConfig.cs` |
| **Bundling** | npm + manual | `BundleConfig.cs` |
| **Static files** | `wwwroot/` via `UseStaticFiles()` | `Content/` + `Scripts/` |
| **Views** | Razor `.cshtml` | Razor `.cshtml` |
| **Layouts** | `Views/Shared/_Layout.cshtml` | `Views/Shared/_Layout.cshtml` |
| **Partials** | `@Html.Partial()` | `@Html.Partial()` |
| **Dependencies** | NuGet + npm | NuGet + npm |
| **Controllers** | 24 (identical) | 24 (identical) |
| **Views count** | 124 .cshtml | 124 .cshtml |

---

## 2. Project Structure

### ASP.NET Core 8

```
Velzon/
├── Program.cs                        # Entry: minimal hosting
├── Velzon.csproj                     # SDK-style project
├── appsettings.json                  # Configuration
├── appsettings.Development.json
├── package.json                      # npm for SCSS/JS build
├── Controllers/                      # 24 controllers
│   ├── DashBoardController.cs
│   ├── EcommerceController.cs
│   ├── CRMController.cs
│   ├── AppsController.cs
│   ├── AuthenticationController.cs
│   └── ... (24 total)
├── Views/
│   ├── Shared/
│   │   ├── _Layout.cshtml            # Master layout
│   │   ├── _title_meta.cshtml        # <title> + meta tags
│   │   ├── _head_css.cshtml          # CSS includes
│   │   ├── _menu.cshtml              # Sidebar + topbar
│   │   ├── _page_title.cshtml        # Breadcrumb
│   │   ├── _footer.cshtml            # Footer
│   │   ├── _customizer.cshtml        # Theme customizer panel
│   │   └── _vendor_scripts.cshtml    # JS includes
│   ├── DashBoard/
│   │   ├── Index.cshtml              # Ecommerce dashboard
│   │   ├── Analytics.cshtml
│   │   ├── CRM.cshtml
│   │   ├── Crypto.cshtml
│   │   ├── Projects.cshtml
│   │   ├── NFT.cshtml
│   │   ├── Job.cshtml
│   │   └── Blog.cshtml
│   ├── Ecommerce/                    # 14 views
│   ├── Authentication/               # 20 views
│   ├── BaseUI/                       # 18 views
│   ├── AdvanceUI/                    # 9 views
│   ├── Charts/                       # 4 views
│   ├── Forms/                        # 9 views
│   ├── Tables/                       # 3 views
│   ├── Icons/                        # 5 views
│   ├── Maps/                         # 3 views
│   └── ...
└── wwwroot/
    └── assets/
        ├── css/                      # Compiled CSS
        ├── js/                       # App JS
        ├── libs/                     # Vendor libraries
        ├── images/                   # All images
        └── fonts/                    # All fonts
```

### ASP.NET MVC (differences only)

```
Velzon/
├── Global.asax                       # Application entry
├── Global.asax.cs                    # Application_Start()
├── Velzon.csproj                     # Classic project format
├── Web.config                        # Configuration (vs appsettings)
├── App_Start/
│   ├── BundleConfig.cs               # CSS/JS bundling
│   ├── FilterConfig.cs               # Global filters
│   └── RouteConfig.cs                # Route table
├── Controllers/                      # Same 24 controllers
├── Views/                            # Same 124 views
└── Content/                          # Static files (vs wwwroot/)
    └── assets/
```

---

## 3. Entry Points

### ASP.NET Core 8 — `Program.cs`

```csharp
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllersWithViews();

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();       // Serves wwwroot/assets/*
app.UseRouting();
app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Dashboard}/{action=Index}/{id?}");

app.Run();
```

### ASP.NET MVC — `Global.asax.cs`

```csharp
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;

namespace Velzon
{
    public class MvcApplication : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
            AreaRegistration.RegisterAllAreas();
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
        }
    }
}
```

---

## 4. Controller Pattern

All 24 controllers follow the same simple pattern — return views with no model/data:

```csharp
using Microsoft.AspNetCore.Mvc;  // Core
// using System.Web.Mvc;          // MVC

namespace Velzon.Controllers
{
    public class DashBoardController : Controller
    {
        public IActionResult Index()     { return View(); }

        [ActionName("Analytics")]
        public IActionResult Analytics() { return View(); }

        [ActionName("CRM")]
        public IActionResult CRM()       { return View(); }

        [ActionName("Crypto")]
        public IActionResult Crypto()    { return View(); }

        [ActionName("Projects")]
        public IActionResult Projects()  { return View(); }

        [ActionName("NFT")]
        public IActionResult NFT()       { return View(); }

        [ActionName("Job")]
        public IActionResult Job()       { return View(); }

        public IActionResult Blog()      { return View(); }
    }
}
```

### Full Controller List (24)

| Controller | Views | Purpose |
|------------|-------|---------|
| `DashBoardController` | 8 | Dashboard variants (Index, Analytics, CRM, etc.) |
| `EcommerceController` | 14 | Products, orders, cart, checkout, sellers |
| `CRMController` | 4 | Contacts, companies, deals, leads |
| `CryptoController` | 6 | Wallet, transactions, orders, ICO, KYC, buy-sell |
| `ProjectsController` | 3 | List, overview, create |
| `NFTMarketplaceController` | 7 | Explore, details, ranking, create, wallet |
| `JobController` | 10 | Lists, details, statistics, candidates, categories |
| `AppsController` | 8 | Calendar, chat, email, mailbox, file manager, todo, API key |
| `InvoicesController` | 3 | List, details, create |
| `SupportTicketsController` | 2 | Lists, details |
| `AuthenticationController` | 20 | Login, signup, password, verify, errors, lock, logout |
| `PagesController` | 12 | Profile, team, timeline, FAQs, pricing, maintenance |
| `LandingController` | 4 | Landing pages |
| `BaseUIController` | 18 | UI elements (alerts, buttons, cards, etc.) |
| `AdvanceUIController` | 9 | Advanced UI (sweetalert, tour, nestable, etc.) |
| `WidgetsController` | 1 | Widgets page |
| `FormsController` | 9 | Form elements, layouts, wizards, etc. |
| `TablesController` | 3 | Basic, Grid.js, List.js |
| `ChartsController` | 4 | ApexCharts, Chartjs, ECharts |
| `IconsController` | 5 | Remix, BoxIcons, MDI, Line Awesome, Feather |
| `MapsController` | 3 | Google, Vector, Leaflet |
| `BlogController` | 3 | Overview, details, list |
| `LayoutsController` | 1 | Layout settings |
| `TasksController` | 3 | Kanban, list view, details |

---

## 5. Layout System — `_Layout.cshtml`

```html
<!doctype html>
<html lang="en" data-layout="vertical" data-topbar="light"
      data-sidebar="dark" data-sidebar-size="lg"
      data-sidebar-image="none" data-preloader="disable"
      data-theme="default" data-theme-colors="default">
<head>
    @Html.Partial("~/Views/Shared/_title_meta.cshtml")
    @RenderSection("styles", required: false)
    @Html.Partial("~/Views/Shared/_head_css.cshtml")
</head>
<body>
    <div id="layout-wrapper">
        @Html.Partial("~/Views/Shared/_menu.cshtml")

        <div class="main-content">
            <div class="page-content">
                <div class="container-fluid">
                    @Html.Partial("~/Views/Shared/_page_title.cshtml")
                    @RenderBody()
                </div>
            </div>

            @RenderSection("externalhtml", required: false)
            @Html.Partial("~/Views/Shared/_footer.cshtml")
        </div>
    </div>

    @Html.Partial("~/Views/Shared/_customizer.cshtml")
    @Html.Partial("~/Views/Shared/_vendor_scripts.cshtml")
    @RenderSection("scripts", required: false)
</body>
</html>
```

### Shared Partials (7)

| Partial | Content |
|---------|---------|
| `_title_meta.cshtml` | `<title>`, meta tags, favicon |
| `_head_css.cshtml` | CSS `<link>` tags (Bootstrap, app.css, plugin CSS) |
| `_menu.cshtml` | Topbar header + vertical sidebar navigation |
| `_page_title.cshtml` | Breadcrumb + page title row |
| `_footer.cshtml` | Footer with copyright |
| `_customizer.cshtml` | Right sidebar theme customizer offcanvas panel |
| `_vendor_scripts.cshtml` | JS `<script>` tags (Bootstrap bundle, app.js, vendor libs) |

---

## 6. View Pattern

Each view uses `@section` to inject page-specific CSS/JS:

```html
@* Dashboard/Index.cshtml *@
@section styles {
    <link href="~/assets/libs/jsvectormap/jsvectormap.min.css" rel="stylesheet" />
    <link href="~/assets/libs/swiper/swiper-bundle.min.css" rel="stylesheet" />
}

<div class="row">
    <div class="col-xl-3 col-md-6">
        <div class="card card-animate">
            <div class="card-body">
                <!-- Stat widget content -->
            </div>
        </div>
    </div>
    <!-- More content... -->
</div>

@section scripts {
    <script src="~/assets/libs/apexcharts/apexcharts.min.js"></script>
    <script src="~/assets/libs/jsvectormap/jsvectormap.min.js"></script>
    <script src="~/assets/js/pages/dashboard-ecommerce.init.js"></script>
}
```

### Key Razor Helpers

| Razor Syntax | Purpose |
|-------------|---------|
| `@Html.Partial("path")` | Include partial view |
| `@RenderBody()` | Render page content in layout |
| `@RenderSection("name", required: false)` | Optional section injection |
| `@section name { }` | Define section content in view |
| `@Url.Content("~/assets/...")` | Resolve static file paths |
| `@Html.ActionLink()` | Generate action URLs |
| `@ViewBag.Title` | Dynamic page title |

---

## 7. Adding a New Page

### Step 1: Create Controller Action

```csharp
// Controllers/MyFeatureController.cs
public class MyFeatureController : Controller
{
    public IActionResult Index()
    {
        return View();
    }
}
```

### Step 2: Create View

```html
<!-- Views/MyFeature/Index.cshtml -->
@section styles {
    <!-- Page-specific CSS -->
}

<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-header">
                <h4 class="card-title mb-0">My Feature</h4>
            </div>
            <div class="card-body">
                <!-- Page content using Bootstrap 5 + Velzon classes -->
            </div>
        </div>
    </div>
</div>

@section scripts {
    <!-- Page-specific JS -->
}
```

### Step 3: Add to Sidebar Menu

Edit `_menu.cshtml` to add navigation link.

---

## Auth Pages (Admin Prefix)

> [!IMPORTANT]
> All auth screens use the **BaoSon glassmorphism design** defined in [auth-login-template.md](auth-login-template.md).
> Auth pages use a separate layout (no sidebar/topbar) at `/{adminPrefix}/login`.

### Auth Screens (5 total)

| Screen | Controller Action | View Path |
|--------|------------------|-----------|
| **Login** | `AdminAuthController.Login` | `Views/AdminAuth/Login.cshtml` |
| **Forgot Password** | `AdminAuthController.ForgotPassword` | `Views/AdminAuth/ForgotPassword.cshtml` |
| **Reset Password** | `AdminAuthController.ResetPassword` | `Views/AdminAuth/ResetPassword.cshtml` |
| **Two-Factor** | `AdminAuthController.TwoFactor` | `Views/AdminAuth/TwoFactor.cshtml` |
| **Logout** | `AdminAuthController.Logout` | — (POST only, redirect) |

### Auth Controller

```csharp
// Controllers/AdminAuthController.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

namespace Velzon.Controllers
{
    [Route("{adminPrefix}/")]  // Configurable via appsettings.json
    public class AdminAuthController : Controller
    {
        [HttpGet("login")]
        [AllowAnonymous]
        public IActionResult Login() => View();

        [HttpPost("login")]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Login(LoginViewModel model)
        {
            if (!ModelState.IsValid) return View(model);
            // Authenticate user...
            return RedirectToAction("Index", "Dashboard");
        }

        [HttpGet("forgot-password")]
        [AllowAnonymous]
        public IActionResult ForgotPassword() => View();

        [HttpPost("forgot-password")]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ForgotPassword(ForgotPasswordViewModel model)
        {
            // Send reset email...
            return View("ForgotPasswordConfirmation");
        }

        [HttpGet("reset-password/{token}")]
        [AllowAnonymous]
        public IActionResult ResetPassword(string token) => View(new ResetPasswordViewModel { Token = token });

        [HttpPost("reset-password")]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ResetPassword(ResetPasswordViewModel model)
        {
            // Reset password...
            return RedirectToAction("Login");
        }

        [HttpGet("two-factor/challenge")]
        [Authorize]
        public IActionResult TwoFactor() => View();

        [HttpPost("two-factor/challenge")]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> TwoFactor(TwoFactorViewModel model)
        {
            // Verify 2FA code...
            return RedirectToAction("Index", "Dashboard");
        }

        [HttpPost("logout")]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Logout()
        {
            // Sign out...
            return RedirectToAction("Login");
        }
    }
}
```

### Auth Layout (no sidebar)

```html
@* Views/Shared/_AuthLayout.cshtml *@
<!doctype html>
<html lang="en">
<head>
    @Html.Partial("~/Views/Shared/_title_meta.cshtml")
    @Html.Partial("~/Views/Shared/_head_css.cshtml")
    @RenderSection("styles", required: false)
</head>
<body>
    @* NO layout-wrapper — BaoSon glassmorphism design *@
    <div class="auth-page-wrapper">
        @RenderBody()
    </div>
    @Html.Partial("~/Views/Shared/_vendor_scripts.cshtml")
    @RenderSection("scripts", required: false)
</body>
</html>
```

### Auth View Example

```html
@* Views/AdminAuth/Login.cshtml *@
@{
    Layout = "~/Views/Shared/_AuthLayout.cshtml";
    ViewBag.Title = "Login — Admin Panel";
}

@section styles {
    <style>
        /* BaoSon glassmorphism — see auth-login-template.md for full CSS */
        .glass { backdrop-filter: blur(20px); background: rgba(255,255,255,0.85); }
    </style>
}

<div class="glass-card">
    <form method="post" asp-action="Login" asp-antiforgery="true">
        @* See auth-login-template.md for complete HTML structure *@
        <div asp-validation-summary="ModelOnly" class="text-danger"></div>
        <input asp-for="Email" class="form-control" placeholder="Email" />
        <input asp-for="Password" type="password" class="form-control" placeholder="Password" />
        <button type="submit" class="btn btn-primary w-100">Sign In</button>
    </form>
</div>
```

### Admin Prefix Configuration

```json
// appsettings.json
{
  "AdminSettings": {
    "Prefix": "admin"
  }
}
```

```csharp
// Program.cs — route configuration
var adminPrefix = builder.Configuration.GetValue<string>("AdminSettings:Prefix") ?? "admin";

app.MapControllerRoute(
    name: "admin-auth",
    pattern: $"{adminPrefix}/{{action=Login}}",
    defaults: new { controller = "AdminAuth" });

app.MapControllerRoute(
    name: "admin",
    pattern: $"{adminPrefix}/{{controller=Dashboard}}/{{action=Index}}/{{id?}}");
```

### View Structure

```
Views/
├── Shared/
│   ├── _Layout.cshtml             ← Main admin layout (sidebar + header)
│   └── _AuthLayout.cshtml         ← Auth layout (glassmorphism, no sidebar)
├── AdminAuth/
│   ├── Login.cshtml
│   ├── ForgotPassword.cshtml
│   ├── ForgotPasswordConfirmation.cshtml
│   ├── ResetPassword.cshtml
│   └── TwoFactor.cshtml
└── Dashboard/
    └── Index.cshtml
```

---

## 8. Comparison: ASP.NET vs React-TS

| Aspect | ASP.NET (Core/MVC) | React-TS |
|--------|--------------------|---------| 
| **Rendering** | Server-side (Razor) | Client-side (SPA) |
| **Routing** | Controller + action | React Router |
| **Layout** | `_Layout.cshtml` + `@RenderBody()` | React components + `<Outlet />` |
| **Partials** | `@Html.Partial()` | React component imports |
| **Page Templates** | `.cshtml` files | `.tsx` files |
| **Sections** | `@section styles/scripts { }` | Dynamic imports |
| **State** | ViewBag/ViewData/TempData | Redux Toolkit |
| **Styling** | `<link>` in `@section styles` | SCSS imports |
| **Assets** | `~/assets/` static files | `import` from `src/assets/` |
| **Data** | Controller → View | API → Redux → Component |

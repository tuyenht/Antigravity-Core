# HTML, PHP & Laravel Blade Patterns Reference

Pattern reference for Velzon HTML/PHP/Laravel Blade variants.
Use when building admin interfaces without a JavaScript framework.

---

## HTML Variant

### Page Structure (Static)

Every HTML page uses partials includes via Gulp build:

```html
<!doctype html>
<html lang="en" data-layout="vertical" data-topbar="light" data-sidebar="dark"
      data-sidebar-size="lg" data-sidebar-image="none" data-preloader="disable"
      data-theme="default" data-theme-colors="default">
<head>
    @@include("partials/title-meta.html", {"title": "Dashboard"})
    @@include("partials/head-css.html")
</head>
<body>
    <div id="layout-wrapper">
        @@include("partials/topbar.html")
        @@include("partials/sidebar.html")
        <div class="main-content">
            <div class="page-content">
                <div class="container-fluid">
                    <!-- Page Title -->
                    @@include("partials/page-title.html", {"title": "Dashboard", "pagetitle": "Velzon"})
                    
                    <!-- Page Content -->
                    <div class="row">
                        <!-- Your content here -->
                    </div>
                </div>
            </div>
            @@include("partials/footer.html")
        </div>
    </div>
    @@include("partials/customizer.html")
    @@include("partials/vendor-scripts.html")
    <script src="assets/js/app.js"></script>
</body>
</html>
```

### Partials (10 files)

| Partial | Content |
|---------|---------|
| `main.html` | DOCTYPE + `<html>` tag with data-attributes |
| `title-meta.html` | `<title>` + meta tags |
| `head-css.html` | CSS file links (Bootstrap, custom, icons) |
| `topbar.html` | Header bar (logo, search, notifications) |
| `sidebar.html` | Left sidebar with menu items |
| `page-title.html` | BreadCrumb component |
| `footer.html` | Footer bar |
| `customizer.html` | Theme settings offcanvas |
| `vendor-scripts.html` | JS library includes |

### Layout Data Attributes

```html
<html
    data-layout="vertical|horizontal|twocolumn|semibox"
    data-topbar="light|dark"
    data-sidebar="dark|light|gradient|gradient-2|gradient-3|gradient-4"
    data-sidebar-size="lg|md|sm|sm-hover"
    data-sidebar-image="none|img-1|img-2|img-3|img-4"
    data-preloader="disable|enable"
    data-theme="default|saas|material|minimal|modern|creative|interactive|classic|vintage|corporate"
    data-theme-colors="default|blue|green|purple|red"
    data-bs-theme="light|dark"
>
```

### Gulp Build

```javascript
// gulpfile.js
const { src, dest, series, parallel, watch } = require('gulp');
const fileinclude = require('gulp-file-include');
const sass = require('gulp-sass')(require('sass'));
const browsersync = require('browser-sync').create();

// Compile pages with partials
function html() {
    return src('src/*.html')
        .pipe(fileinclude({ prefix: '@@', basepath: '@file' }))
        .pipe(dest('dist/'));
}

// Compile SCSS
function css() {
    return src('src/assets/scss/themes.scss')
        .pipe(sass().on('error', sass.logError))
        .pipe(dest('dist/assets/css/'));
}
```

### JS Plugin Initialization

```html
<!-- DataTables -->
<script src="assets/libs/datatables.net/js/dataTables.min.js"></script>
<script>
    new DataTable('#myTable', {
        responsive: true,
        order: [[0, 'desc']],
    });
</script>

<!-- Flatpickr -->
<script src="assets/libs/flatpickr/flatpickr.min.js"></script>
<script>
    flatpickr("#datepicker", { dateFormat: "d M, Y" });
</script>

<!-- ApexCharts -->
<script src="assets/libs/apexcharts/apexcharts.min.js"></script>
<script>
    var options = { chart: { type: 'area', height: 350 }, series: [...] };
    new ApexCharts(document.querySelector("#chart"), options).render();
</script>

<!-- Choices.js (Select2 alternative) -->
<script src="assets/libs/choices.js/public/assets/scripts/choices.min.js"></script>
<script>
    new Choices('#choices-select', { removeItemButton: true });
</script>

<!-- Dropzone -->
<script src="assets/libs/dropzone/dropzone-min.js"></script>
<script>
    new Dropzone("#dropzone", { url: "/upload", maxFilesize: 5 });
</script>
```

---

## PHP Variant

The PHP variant uses native PHP `include` instead of Gulp:

```php
<?php include 'partials/main.php'; ?>
<head>
    <?php $title = "Dashboard"; include 'partials/title-meta.php'; ?>
    <?php include 'partials/head-css.php'; ?>
</head>
<body>
    <div id="layout-wrapper">
        <?php include 'partials/topbar.php'; ?>
        <?php include 'partials/sidebar.php'; ?>
        <div class="main-content">
            <div class="page-content">
                <div class="container-fluid">
                    <?php $pagetitle = "Velzon"; $title = "Dashboard"; 
                          include 'partials/page-title.php'; ?>
                    <!-- Content -->
                </div>
            </div>
            <?php include 'partials/footer.php'; ?>
        </div>
    </div>
    <?php include 'partials/vendor-scripts.php'; ?>
</body>
```

---

## Laravel Blade Variant

### Layout System (Blade extends)

```blade
{{-- resources/views/layouts/master.blade.php --}}
<!doctype html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}"
      data-layout="vertical" data-topbar="light" data-sidebar="dark">
<head>
    @include('layouts.head-css')
    @yield('css')
    <title>@yield('title') | {{ config('app.name') }}</title>
</head>
<body>
    <div id="layout-wrapper">
        @include('layouts.topbar')
        @include('layouts.sidebar')
        <div class="main-content">
            <div class="page-content">
                <div class="container-fluid">
                    @yield('content')
                </div>
            </div>
            @include('layouts.footer')
        </div>
    </div>
    @include('layouts.customizer')
    @include('layouts.vendor-scripts')
    @yield('script')
</body>
</html>
```

### Page Template

```blade
{{-- resources/views/dashboard.blade.php --}}
@extends('layouts.master')
@section('title', 'Dashboard')

@section('css')
    <link href="{{ URL::asset('build/libs/swiper/swiper-bundle.min.css') }}" rel="stylesheet">
@endsection

@section('content')
    @component('components.breadcrumb')
        @slot('li_1') Dashboards @endslot
        @slot('title') Dashboard @endslot
    @endcomponent

    <div class="row">
        <!-- Dashboard widgets -->
    </div>
@endsection

@section('script')
    <script src="{{ URL::asset('build/libs/apexcharts/apexcharts.min.js') }}"></script>
    <script src="{{ URL::asset('build/js/pages/dashboard-ecommerce.init.js') }}"></script>
@endsection
```

### Blade Components

```blade
{{-- resources/views/components/breadcrumb.blade.php --}}
<div class="row">
    <div class="col-12">
        <div class="page-title-box d-sm-flex align-items-center justify-content-between">
            <h4 class="mb-sm-0">{{ $title }}</h4>
            <div class="page-title-right">
                <ol class="breadcrumb m-0">
                    <li class="breadcrumb-item"><a href="javascript:void(0);">{{ $li_1 }}</a></li>
                    <li class="breadcrumb-item active">{{ $title }}</li>
                </ol>
            </div>
        </div>
    </div>
</div>
```

### Route Structure

```php
// routes/web.php
Route::middleware(['auth'])->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index']);
    Route::view('/ui-alerts', 'ui-alerts');
    // ... resource routes
});
```

### Asset Compilation (Vite)

```javascript
// vite.config.js
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel({
            input: [
                'resources/scss/themes.scss',
                'resources/js/app.js',
            ],
        }),
    ],
});
```

---

## Variant Selection Guide

| Project Type | Recommended Variant | Why |
|-------------|-------------------|-----|
| Laravel + React SPA | **React+Inertia** | Best of both: Laravel backend + React components |
| Next.js app | **Next-TS** | Native App Router support |
| Laravel + Blade (traditional) | **Laravel** | Full server-side rendering |
| Quick prototype / landing | **HTML** | No build step needed (with Gulp) |
| PHP CMS integration | **PHP** | Simple includes, no framework |
| React standalone SPA | **React-TS** | Full TypeScript + Redux |

---
description: Tạo trang admin dashboard (Velzon)
---

# Admin Dashboard Page Builder

Build a new admin dashboard or management page using Velzon conventions.

## Prerequisites
- Read the Velzon Admin skill: `.agent/skills/velzon-admin/SKILL.md`
- Identify the closest template page from `reference/page-catalog.md`

## Steps

### 0. Detect Variant
Determine which Velzon variant to use based on the project:
- `composer.json` + `inertiajs` → **React+Inertia** → read `reference/inertia-bridge.md`
- `next.config.js` → **Next-TS** → read `reference/nextjs-patterns.md`
- `app.js` + `express` + `.ejs` views → **Node.js** → read `reference/nodejs-patterns.md`
- `.csproj` + `Program.cs` + `.cshtml` views → **ASP.NET Core** → read `reference/aspnet-mvc-patterns.md`
- `.csproj` + `Global.asax.cs` + `.cshtml` views → **ASP.NET MVC** → read `reference/aspnet-mvc-patterns.md`
- `index.html` + AJAX nav + HTML fragments → **Ajax** → read `reference/ajax-patterns.md`
- `composer.json` + Blade views → **Laravel** → read `reference/html-php-patterns.md`
- `gulpfile.js` → **HTML** → read `reference/html-php-patterns.md`
- Default → **React-TS** (use core skill patterns)
- For asset recreation: always read `reference/asset-catalog.md`

### 1. Identify Page Type
Determine what kind of admin page is needed:
- **Dashboard** → Stats widgets + charts + tables
- **CRUD List** → Data table with search, sort, pagination, actions
- **CRUD Detail** → Detail view with info panels
- **CRUD Form** → Create/Edit form with validation
- **Kanban** → Drag-and-drop board

### 2. Reference Closest Template
Map the request to the closest Velzon template page:
- Dashboard overview → `DashboardEcommerce` or `DashboardAnalytics`
- CRUD list with table → `CrmContacts` or `EcommerceOrders`
- Detail view → `EcommerceProductDetail` or `InvoiceDetails`
- Create/Edit form → `EcommerceAddProduct` or `CreateProject`
- Card grid list → `EcommerceProducts` or `EcommerceSellers`

Read the skill reference files for detailed patterns.

### 3. Create Page File

// turbo
Create the new page file following the Velzon page structure:
```
src/pages/{ModuleName}/{PageName}.tsx
```

Use this template:
```tsx
import React from "react";
import { Container, Row, Col } from "reactstrap";
import BreadCrumb from "../../Components/Common/BreadCrumb";

const PageName = () => {
  document.title = "Page Title | App Name";
  return (
    <React.Fragment>
      <div className="page-content">
        <Container fluid>
          <BreadCrumb title="Page Title" pageTitle="Category" />
          <Row>
            {/* Page content */}
          </Row>
        </Container>
      </div>
    </React.Fragment>
  );
};

export default PageName;
```

### 4. Create Sub-Components
For dashboard pages, create individual components for each section:
- `Widgets.tsx` - Stat cards row
- Chart components (using ApexCharts)
- Table components (using TableContainer)
- Activity/sidebar panels

Each component follows the same React.Fragment + Reactstrap pattern.

### 5. Create Redux Slice (if needed)
If the page needs server data:

// turbo
Create `src/slices/{moduleName}/reducer.ts`:
```tsx
import { createSlice } from "@reduxjs/toolkit";
import { getData } from './thunk';

const MySlice = createSlice({
  name: 'MyModule',
  initialState: { data: [], error: {} },
  reducers: {},
  extraReducers: (builder) => {
    builder.addCase(getData.fulfilled, (state, action) => {
      state.data = action.payload;
    });
  }
});

export default MySlice.reducer;
```

// turbo
Create `src/slices/{moduleName}/thunk.ts`:
```tsx
import { createAsyncThunk } from "@reduxjs/toolkit";

export const getData = createAsyncThunk("myModule/getData", async () => {
  const response = await fetch('/api/data');
  return response.json();
});
```

### 6. Register Redux Slice
Add the new reducer to `src/slices/index.ts`:
```tsx
import MyModuleReducer from "./{moduleName}/reducer";
// ... add to combineReducers
```

### 7. Register Route
Add route to `src/Routes/allRoutes.tsx`:
```tsx
{ path: "/my-module-page", component: <MyModulePage /> },
```

### 8. Add to Sidebar Menu
Add menu item to `src/Layouts/LayoutMenuData.tsx`:
```tsx
{
  id: "myModule",
  label: "My Module",
  link: "/my-module-page",
  parentId: "apps",
}
```

### 9. Verify
- Check page renders correctly at the registered route
- Verify breadcrumb shows correct title/category
- Confirm sidebar menu item appears and highlights
- Test search/filter/pagination if applicable
- Verify dark mode and responsive behavior

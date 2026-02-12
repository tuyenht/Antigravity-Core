# Layout System Reference

## Layout Architecture

```
#layout-wrapper
├── Header (topbar)
│   ├── Logo
│   ├── Hamburger toggle
│   ├── SearchOption
│   ├── LanguageDropdown
│   ├── MyCartDropdown
│   ├── FullScreenDropdown
│   ├── LightDark toggle
│   ├── NotificationDropdown
│   └── ProfileDropdown
├── Sidebar (left)
│   ├── Logo area
│   ├── SimpleBar scrollable
│   │   └── Menu items (Navdata)
│   └── Sidebar images (optional)
└── .main-content
    ├── .page-content (children)
    │   └── Container fluid
    │       ├── BreadCrumb
    │       └── Page content
    └── Footer
```

## Layout Types

### 1. Vertical (Default)
- Left sidebar with collapsible navigation
- Configurable sidebar sizes: `default`, `compact`, `sm-hover`, `lg`, `sm`
- Sidebar themes: `dark`, `light`, `gradient`

### 2. Horizontal
- Top navigation bar with dropdown menus
- Best for apps with fewer navigation items
- SCSS: `_horizontal.scss`

### 3. TwoColumn
- Left icon sidebar + expanded menu panel
- Compact icon navigation with expandable sub-menus
- SCSS: `_two-column.scss`

### 4. Semibox
- Variant of vertical layout with auto-hide sidebar behavior
- Sidebar appears on hover, hides when mouse leaves
- Content area takes full width when sidebar is hidden
- Uses `data-layout="semibox"` + `data-sidebar-visibility="show|hidden"`
- Shares vertical sidebar SCSS (`_vertical.scss`) with additional semibox logic in `_layouts.scss`
- Sidebar toggle via hamburger works same as vertical but also triggers visibility toggle
- RightSidebar hides sidebar-view options when semibox is active
- Best for: apps wanting max content area with on-demand navigation

## Redux Layout State

All layout properties managed via Redux (`slices/layouts/`):

```tsx
interface LayoutState {
  layoutType: 'vertical' | 'horizontal' | 'twocolumn' | 'semibox';
  layoutModeType: 'light' | 'dark';
  layoutThemeType: 'default' | 'saas' | 'material' | 'creative' | 'minimal' | 'modern' | 'interactive' | 'galaxy' | 'corporate';
  layoutThemeColorType: 'default' | 'blue' | 'green' | 'purple' | 'custom';
  leftSidebarType: 'dark' | 'light' | 'gradient' | 'gradient-2' | 'gradient-3' | 'gradient-4';
  layoutWidthType: 'fluid' | 'boxed';
  layoutPositionType: 'fixed' | 'scrollable';
  topbarThemeType: 'light' | 'dark';
  leftsidbarSizeType: 'default' | 'compact' | 'sm-hover' | 'lg' | 'sm';
  leftSidebarViewType: 'default' | 'detached';
  leftSidebarImageType: 'none' | 'img-1' | 'img-2' | 'img-3' | 'img-4';
  sidebarVisibilitytype: 'show' | 'hidden';
}
```

### Dispatching Layout Changes

```tsx
import { useDispatch } from "react-redux";
import { changeLayout, changeLayoutMode, changeSidebarTheme } from "../slices/thunks";

const dispatch = useDispatch();
dispatch(changeLayout("vertical"));
dispatch(changeLayoutMode("dark"));
dispatch(changeSidebarTheme("dark"));
```

## Sidebar Menu Data Structure

Menu items defined in `Layouts/LayoutMenuData.tsx` as a `Navdata` function returning `menuItems[]`:

```tsx
interface MenuItem {
  id: string;
  label: string;
  icon?: string;            // Remix Icon class (e.g. "ri-dashboard-2-line")
  link: string;             // Route path or "/#" for parent
  isHeader?: boolean;       // True for section header labels
  stateVariables?: boolean; // Collapse state binding
  click?: (e: any) => void; // Toggle collapse handler
  badgeName?: string;       // Badge text (e.g. "New")
  badgeColor?: string;      // Badge variant (e.g. "success")
  subItems?: SubItem[];     // First-level children
}

interface SubItem {
  id: string | number;
  label: string;
  link: string;
  parentId: string;
  isChildItem?: boolean;     // Has nested children
  stateVariables?: boolean;
  click?: (e: any) => void;
  childItems?: ChildItem[];  // Second-level children
}

interface ChildItem {
  id: number;
  label: string;
  link: string;
  parentId: string;
  isChildItem?: boolean;
  childItems?: ChildItem[];  // Third-level (max nesting)
}
```

### Adding a New Menu Item

```tsx
// Top-level with sub-items:
{
  id: "myModule",
  label: "My Module",
  icon: "ri-settings-4-line",
  link: "/#",
  stateVariables: isMyModule,
  click: (e: any) => {
    e.preventDefault();
    setIsMyModule(!isMyModule);
    setIscurrentState('MyModule');
    updateIconSidebar(e);
  },
  subItems: [
    { id: "list", label: "List", link: "/my-module-list", parentId: "myModule" },
    { id: "create", label: "Create", link: "/my-module-create", parentId: "myModule" },
  ],
},

// Simple leaf item:
{
  id: "settings",
  label: "Settings",
  link: "/settings",
  parentId: "apps",
},
```

## Route Registration

Routes defined in `Routes/allRoutes.tsx`:

```tsx
// Protected routes (require auth)
const authProtectedRoutes = [
  { path: "/my-module-list", component: <MyModuleList /> },
  { path: "/my-module-create", component: <MyModuleCreate /> },
  { path: "/my-module-details/:id", component: <MyModuleDetails /> },
];

// Public routes (no auth)
const publicRoutes = [
  { path: "/login", component: <Login /> },
];
```

### Auth Protection

Routes wrapped with `AuthProtected` component that checks login state.

```tsx
// Routes/index.tsx pattern:
<Routes>
  {authProtectedRoutes.map((route) => (
    <Route path={route.path} element={<AuthProtected><Layout>{route.component}</Layout></AuthProtected>} key={route.path} />
  ))}
  {publicRoutes.map((route) => (
    <Route path={route.path} element={<NonAuthLayout>{route.component}</NonAuthLayout>} key={route.path} />
  ))}
</Routes>
```

## SCSS Structure

```
assets/scss/
├── _variables.scss         (70KB - all BS5 variable overrides)
├── _variables-custom.scss  (custom Velzon variables)
├── _variables-dark.scss    (dark mode overrides)
├── bootstrap.scss          (Bootstrap import)
├── app.scss                (main app import)
├── themes.scss             (entry point from App.tsx)
├── custom.scss             (user customizations)
├── components/             (31 files: _root, _card, _buttons, _nav, _modal, _table, _widgets...)
├── structure/              (8 files: _vertical, _horizontal, _two-column, _topbar, _footer...)
├── pages/                  (22 files: _dashboard, _chat, _email, _ecommerce, _authentication...)
├── plugins/                (3rd party style overrides)
├── theme/                  (theme-specific overrides)
├── fonts/                  (custom font declarations)
└── rtl/                    (RTL layout mirror styles)
```

### Data Attributes for Layout

Body/HTML data attributes control layout styling:
```html
<html data-layout="vertical"
      data-layout-mode="light"
      data-sidebar="dark"
      data-sidebar-size="lg"
      data-layout-width="fluid"
      data-layout-position="fixed"
      data-topbar="light">
```

## RightSidebar (Theme Customizer)

A settings panel (offcanvas) allowing runtime theme customization:
- Layout type toggle
- Color scheme (light/dark)
- Sidebar color/size
- Topbar color
- Layout width (fluid/boxed)
- Position (fixed/scrollable)

Located in `Components/Common/RightSidebar.tsx` (125KB - extensive configuration UI).

## Responsive Behavior

### Bootstrap 5 Breakpoints
| Breakpoint | Class infix | Dimensions | Sidebar behavior |
|------------|-------------|------------|------------------|
| X-Small | - | <576px | Sidebar hidden, offcanvas overlay via hamburger |
| Small | `sm` | ≥576px | Same as X-Small |
| Medium | `md` | ≥768px | Sidebar can auto-collapse to `sm-hover` |
| Large | `lg` | ≥992px | Sidebar shows as `compact` (icons + text on hover) |
| X-Large | `xl` | ≥1200px | Full sidebar visible (`default` size) |
| XX-Large | `xxl` | ≥1400px | Same as X-Large |

### Sidebar Size Behaviors
- `lg` (default): Full sidebar with text and icons (250px)
- `md` (compact): Icons + short labels (180px)
- `sm`: Icons only, labels on hover (70px)
- `sm-hover`: Same as `sm` but expands to full on mouse hover

### Layout-Specific Responsive Rules
- **Vertical/Semibox**: Sidebar becomes offcanvas below `lg` breakpoint
- **Horizontal**: Top nav collapses to hamburger below `lg` breakpoint
- **TwoColumn**: Icon sidebar persists, menu panel becomes offcanvas below `lg`
- **Boxed width**: `.container-xxl` max-width `1440px` applied to content area

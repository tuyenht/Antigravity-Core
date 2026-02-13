# {PROJECT_NAME} — Screen Inventory

> **Generated**: {DATE} | **Condition**: Project has UI (web app / admin panel / mobile)

---

## 1. Screen Map

| # | Screen | Route | Purpose | Auth |
|---|--------|-------|---------|------|
| 1 | {screen name} | {/path} | {what user does here} | {public / logged-in / admin} |
| 2 | | | | |

---

## 2. User Flows

### Flow 1: {Primary user journey}
```
{Start} → {Screen A} → {Action} → {Screen B} → {Result}
```

### Flow 2: {Secondary journey}
```
{Start} → {Screen} → {Action} → {Result}
```

---

## 3. Screen Details

### {Screen 1: e.g. Dashboard}

| Aspect | Detail |
|--------|--------|
| **Route** | {/admin} |
| **Purpose** | {overview of key metrics} |
| **Layout** | {sidebar + header + content grid} |
| **Key Components** | {StatsCard, Chart, RecentActivity, QuickActions} |
| **Data Sources** | {API endpoints or queries this screen uses} |

**Sections:**
1. {section name} — {what it shows, components used}
2. {section name} — {what it shows}

### {Screen 2: e.g. Entity List}

| Aspect | Detail |
|--------|--------|
| **Route** | {/admin/entities} |
| **Purpose** | {CRUD list view} |
| **Key Components** | {DataTable, Filters, SearchBar, Pagination, BulkActions} |
| **Data Sources** | {GET /api/entities} |

**Actions:** Create, Edit, Delete, Export, Filter, Search

### {Screen 3: e.g. Entity Detail/Edit}

| Aspect | Detail |
|--------|--------|
| **Route** | {/admin/entities/:id} |
| **Purpose** | {view/edit single entity} |
| **Key Components** | {Form, Tabs, FileUpload, RichTextEditor} |
| **Data Sources** | {GET/PUT /api/entities/:id} |

**Form Fields:**
| Field | Type | Validation |
|-------|------|-----------|
| {name} | {text} | {required, max 100} |

---

## 4. Shared Components

| Component | Source | Usage |
|-----------|--------|-------|
| {DataTable} | {Velzon / custom / shadcn} | {entity lists, reports} |
| {Modal} | {source} | {confirmations, quick edit} |
| {Form} | {source} | {create/edit screens} |
| {Chart} | {source} | {dashboard metrics} |
| {FileUpload} | {source} | {media management} |

---

## 5. Navigation Structure

```
{Main nav hierarchy:}
├── Dashboard
├── {Section 1}
│   ├── {Sub-page}
│   └── {Sub-page}
├── {Section 2}
│   ├── {Sub-page}
│   └── {Sub-page}
└── Settings
```

---

> **Instructions for AI:**
> - Generate ONLY when project has UI (admin panel, web app, mobile)
> - Skip for API-only or CLI projects
> - Section 1: List every screen that needs building
> - Section 2: Map the primary user journeys between screens
> - Section 3: Detail each screen with components and data sources
> - Section 4: Identify reusable components to avoid duplication
> - Section 5: Define navigation hierarchy
> - Extract component library from CONVENTIONS Sec 3 (UI Patterns)
> - Output location: `docs/PROJECT-SCREENS.md`

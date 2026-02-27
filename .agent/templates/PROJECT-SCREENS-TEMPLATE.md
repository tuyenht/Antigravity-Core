# {PROJECT_NAME} — UI Screen Blueprint

> **Generated**: {DATE} | **Antigravity-Core**: v5.0.0
> **Condition**: Chỉ tạo khi project có UI (web app / admin panel / mobile)

---

## 1. Screen Map

| # | Screen | Route | Purpose | Auth | Responsive |
|---|--------|-------|---------|------|------------|
| 1 | {screen name} | {/path} | {what user does here} | {public / logged-in / admin} | {mobile ✅ / desktop-only} |
| 2 | | | | | |

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
| **State** | {store/context dùng: e.g. useDashboardStore, React Query cache} |

**Performance Budget:**
| Metric | Target |
|--------|--------|
| LCP | < 2.5s |
| CLS | < 0.1 |
| INP | < 200ms |

**Accessibility:**
| Requirement | Level |
|-------------|-------|
| WCAG | {AA / AAA} |
| Keyboard nav | {required / optional} |
| Screen reader | {required / optional} |

**Responsive Behavior:**
| Breakpoint | Layout Change |
|------------|---------------|
| Mobile (<768px) | {e.g. Stack columns, hide sidebar} |
| Tablet (768-1024px) | {e.g. Collapsed sidebar} |
| Desktop (>1024px) | {e.g. Full layout} |

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
| **State** | {e.g. useEntityStore, server state via React Query} |

**Actions:** Create, Edit, Delete, Export, Filter, Search

---

## 4. State Management Map

| Screen | Store / Context | State Type |
|--------|----------------|------------|
| {Dashboard} | {useDashboardStore} | {Server state → React Query} |
| {Entity List} | {useEntityStore} | {Client + Server hybrid} |
| {Settings} | {useSettingsStore} | {Client state → Zustand/Pinia} |

---

## 5. Shared Components

| Component | Source | Usage | Reuse Count |
|-----------|--------|-------|-------------|
| {DataTable} | {Velzon / custom / shadcn} | {entity lists, reports} | {5 screens} |
| {Modal} | {source} | {confirmations, quick edit} | {8 screens} |
| {Form} | {source} | {create/edit screens} | {6 screens} |

---

## 6. Navigation Structure

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
> - Section 1: List EVERY screen → map routes + auth + responsive needs
> - Section 2: Map primary user journeys between screens
> - Section 3: Detail each screen — components, data, state, perf budget, a11y, responsive
> - Section 4: Map state management per screen → avoid state spaghetti
> - Section 5: Identify reusable components → prevent duplication
> - Section 6: Define navigation hierarchy
> - Output location: `docs/PROJECT-SCREENS.md`

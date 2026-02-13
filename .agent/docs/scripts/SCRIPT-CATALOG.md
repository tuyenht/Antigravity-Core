# Script Catalog — Antigravity-Core

**Version:** 4.0.0  
**Last Updated:** 2026-02-13  
**Total Scripts:** 14

---

## Overview

Scripts là các **PowerShell automation tools** trong `.agent/scripts/`. Chạy trên Windows (PowerShell 5.1+) và cross-platform (pwsh 7+).

---

## Script Registry

### 🔧 Core CLI Scripts

| # | Script | Mục đích | Usage |
|---|--------|----------|-------|
| 1 | `health-check.ps1` | Kiểm tra sức khỏe hệ thống .agent | `.\agent.ps1 health` |
| 2 | `validate-compliance.ps1` | Full compliance check trước deploy | `.\agent.ps1 validate` |
| 3 | `detect-project.ps1` | Phát hiện tech stack của project | `.\agent.ps1 init` (internal) |
| 4 | `discover-rules.ps1` | Scan project và suggest rules phù hợp | Internal use |

### 🔒 Security Scripts

| # | Script | Mục đích | Usage |
|---|--------|----------|-------|
| 5 | `secret-scan.ps1` | Quét code tìm secrets/credentials | `.\agent.ps1 scan` |

### ⚡ Quality & Performance Scripts

| # | Script | Mục đích | Usage |
|---|--------|----------|-------|
| 6 | `auto-heal.ps1` | Tự động fix lint, syntax, imports | `.\agent.ps1 heal` |
| 7 | `performance-check.ps1` | Enforce performance budgets | `.\agent.ps1 perf` |
| 8 | `dx-analytics.ps1` | Thu thập và hiển thị DX metrics | `.\agent.ps1 dx` |
| 9 | `log-metrics.ps1` | Ghi metrics vào tracking file | Internal use |

### 📦 Installation & Update Scripts

| # | Script | Mục đích | Usage |
|---|--------|----------|-------|
| 10 | `install-antigravity.ps1` | Cài đặt .agent vào project hiện có | `irm <url> \| iex` |
| 11 | `install-global.ps1` | Cài đặt global `agi` command | One-time setup |
| 12 | `update-antigravity.ps1` | Cập nhật .agent lên version mới | `.\agent.ps1 scripts\update-antigravity.ps1` |
| 13 | `update-global.ps1` | Cập nhật global installation | `agi update` |
| 14 | `update-ui-ux-pro-max.ps1` | Cập nhật UI-UX-Pro-Max skill | `/update-ui-ux-pro-max` |

---

## Common Usage Patterns

### Daily Check
```powershell
.\agent.ps1 health        # System health check
.\agent.ps1 scan           # Secret scan
```

### Pre-Deploy
```powershell
.\agent.ps1 validate      # Full compliance
.\agent.ps1 perf          # Performance budgets
.\agent.ps1 scan           # Final secret check
```

### Maintenance
```powershell
.\agent.ps1 heal           # Auto-fix common issues
.\agent.ps1 dx roi         # View ROI metrics
# Update: run update-antigravity.ps1 directly
pwsh -File .agent/scripts/update-antigravity.ps1
```

---

> **See also:** [Agent Catalog](../agents/AGENT-CATALOG.md) | [Workflow Catalog](../workflows/WORKFLOW-CATALOG.md)

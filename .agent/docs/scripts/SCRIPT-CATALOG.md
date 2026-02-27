# Script Catalog — Antigravity-Core

**Version:** 5.0.0  
**Last Updated:** 2026-02-27  
**Total Scripts:** 37 (20 core + 17 skill)

---

## Table of Contents

- [Overview](#overview)
- [Script Classification](#script-classification)
- [Core Script Registry](#core-script-registry)
- [Skill Script Registry](#skill-script-registry)
- [Common Usage Patterns](#common-usage-patterns)

---

## Overview

Scripts là các **automation tools** trong Antigravity-Core. Bao gồm 2 loại:

1. **Core Scripts** (20) — Nằm trong `.agent/scripts/`. PowerShell (.ps1), Bash (.sh), và Git hooks.
2. **Skill Scripts** (17) — Nằm trong `.agent/skills/*/scripts/`. Python-based quality & audit tools.

**Nguyên tắc:**
- Core scripts được gọi qua `agent.ps1 <subcommand>` hoặc trực tiếp
- Skill scripts được gọi bởi agents/workflows khi cần chuyên môn cụ thể
- Quality Gate scripts chạy theo priority order (Security → Lint → Tests → UX → SEO)

---

## Script Classification

| Category | Core | Skill | Total |
|----------|:----:|:-----:|:-----:|
| 🔧 CLI & Detection | 4 | — | 4 |
| 🔒 Security | 1 | 1 | 2 |
| ⚡ Quality & Performance | 4 | 5 | 9 |
| 📦 Installation & Update | 6 | — | 6 |
| 🐧 Bash / Cross-Platform | 5 | — | 5 |
| 🎨 Design & UX | — | 5 | 5 |
| 🔍 Validation & Audit | — | 6 | 6 |
| **Total** | **20** | **17** | **37** |

---

## Core Script Registry

### 🔧 CLI & Detection Scripts

| # | Script | Mục đích | Usage |
|---|--------|----------|-------|
| 1 | `health-check.ps1` | Kiểm tra sức khỏe hệ thống .agent | `.\\agent.ps1 health` |
| 2 | `validate-compliance.ps1` | Full compliance check trước deploy | `.\\agent.ps1 validate` |
| 3 | `detect-project.ps1` | Phát hiện tech stack của project | `.\\agent.ps1 init` (internal) |
| 4 | `discover-rules.ps1` | Scan project và suggest rules phù hợp | Internal use |

### 🔒 Security Scripts

| # | Script | Mục đích | Usage |
|---|--------|----------|-------|
| 5 | `secret-scan.ps1` | Quét code tìm secrets/credentials | `.\\agent.ps1 scan` |

### ⚡ Quality & Performance Scripts

| # | Script | Mục đích | Usage |
|---|--------|----------|-------|
| 6 | `auto-heal.ps1` | Tự động fix lint, syntax, imports | `.\\agent.ps1 heal` |
| 7 | `performance-check.ps1` | Enforce performance budgets | `.\\agent.ps1 perf` |
| 8 | `dx-analytics.ps1` | Thu thập và hiển thị DX metrics | `.\\agent.ps1 dx` |
| 9 | `log-metrics.ps1` | Ghi metrics vào tracking file | Internal use |

### 📦 Installation & Update Scripts

| # | Script | Mục đích | Usage |
|---|--------|----------|-------|
| 10 | `install-antigravity.ps1` | Cài đặt .agent vào project hiện có | `irm <url> \| iex` |
| 11 | `install-global.ps1` | Cài đặt global `agi` command | One-time setup |
| 12 | `update-antigravity.ps1` | Cập nhật .agent lên version mới | `pwsh -File .agent/scripts/update-antigravity.ps1` |
| 13 | `update-global.ps1` | Cập nhật global installation | `agi update` |
| 14 | `update-ui-ux-pro-max.ps1` | Cập nhật UI-UX-Pro-Max skill | `/update-ui-ux-pro-max` |
| 15 | `bump-version.ps1` | Tăng version và sync across files | After releases |

### 🐧 Bash / Cross-Platform Scripts

| # | Script | PS1 Equivalent | Platform |
|---|--------|----------------|----------|
| 16 | `health-check.sh` | `health-check.ps1` | Linux/Mac |
| 17 | `install-global.sh` | `install-global.ps1` | Linux/Mac |
| 18 | `validate-compliance.sh` | `validate-compliance.ps1` | Linux/Mac |
| 19 | `bump-version.sh` | `bump-version.ps1` | Linux/Mac |
| 20 | `pre-commit` | — (Git hook) | All platforms |

---

## Skill Script Registry

Scripts nằm trong `.agent/skills/*/scripts/`, được gọi bởi agents và workflows.

### 🔒 Security & Validation

| # | Script | Skill | Mục đích |
|---|--------|-------|----------|
| 21 | `security_scan.py` | vulnerability-scanner | Security vulnerability scan |
| 22 | `api_validator.py` | api-patterns | API contract validation |
| 23 | `schema_validator.py` | database-design | Schema validation |

### ⚡ Quality & Testing

| # | Script | Skill | Mục đích |
|---|--------|-------|----------|
| 24 | `lint_runner.py` | lint-and-validate | Lint execution |
| 25 | `type_coverage.py` | lint-and-validate | Type coverage analysis |
| 26 | `test_runner.py` | testing-patterns | Test suite runner |
| 27 | `playwright_runner.py` | webapp-testing | E2E test runner |

### 🎨 Design & UX Audit

| # | Script | Skill | Mục đích |
|---|--------|-------|----------|
| 28 | `ux_audit.py` | frontend-design | UX quality audit |
| 29 | `accessibility_checker.py` | frontend-design | WCAG compliance check |
| 30 | `mobile_audit.py` | mobile-design | Mobile UX audit |
| 31 | `core.py` | ui-ux-pro-max | Design intelligence core |
| 32 | `design_system.py` | ui-ux-pro-max | Design system generator |
| 33 | `search.py` | ui-ux-pro-max | Design pattern search |

### 🔍 SEO & Performance Audit

| # | Script | Skill | Mục đích |
|---|--------|-------|----------|
| 34 | `lighthouse_audit.py` | performance-profiling | Lighthouse performance audit |
| 35 | `seo_checker.py` | seo-fundamentals | SEO compliance check |
| 36 | `geo_checker.py` | geo-fundamentals | GEO optimization check |
| 37 | `i18n_checker.py` | i18n-localization | i18n coverage check |

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

### Quality Gate (Priority Order)
```
1. Security    → security_scan.py
2. Lint        → lint_runner.py
3. Schema      → schema_validator.py
4. Tests       → test_runner.py
5. UX          → ux_audit.py + accessibility_checker.py
6. SEO         → seo_checker.py
7. Performance → lighthouse_audit.py + playwright_runner.py
```

### Maintenance
```powershell
.\agent.ps1 heal           # Auto-fix common issues
.\agent.ps1 dx roi         # View ROI metrics
# Update: run update-antigravity.ps1 directly
pwsh -File .agent/scripts/update-antigravity.ps1
```

---

> **See also:** [Agent Catalog](../agents/AGENT-CATALOG.md) | [Workflow Catalog](../workflows/WORKFLOW-CATALOG.md) | [Skill Catalog](../skills/SKILL-CATALOG.md)

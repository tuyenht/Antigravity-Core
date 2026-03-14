# Script Catalog — Antigravity-Core

**Version:** 5.0.1  
**Last Updated:** 2026-03-13  
**Total Scripts:** 54 (37 core + 17 skill)

---

## Table of Contents

- [Overview](#overview)
- [Script Classification](#script-classification)
- [Core Script Registry](#core-script-registry)
- [Skill Script Registry](#skill-script-registry)
- [Invocation Methods](#invocation-methods)
- [Script ↔ Pipeline & Workflow Dependencies](#script--pipeline--workflow-dependencies)
- [CLI Quick Reference](#cli-quick-reference)
- [Common Usage Patterns](#common-usage-patterns)
- [Adding a New Script](#adding-a-new-script)
- [Troubleshooting](#troubleshooting)

---

## Overview

Scripts là các **automation tools** trong Antigravity-Core, chia thành 2 nhóm:

1. **Core Scripts** (37) — `.agent/scripts/`. PowerShell (.ps1), Bash (.sh), Git hooks.
2. **Skill Scripts** (17) — `.agent/skills/*/scripts/`. Python-based quality & audit tools.

**Nguyên tắc:**
- Core scripts gọi qua `agent.ps1 <subcommand>` hoặc trực tiếp
- Skill scripts được gọi bởi agents/workflows khi cần chuyên môn cụ thể
- Quality Gate scripts chạy theo priority order (Security → Lint → Schema → Tests → UX → SEO → Performance)

---

## Script Classification

| Category | Core | Skill | Total | Mô tả |
|----------|:----:|:-----:|:-----:|-------|
| 🔧 CLI & Detection | 4 | — | 4 | Health check, compliance, project detection |
| 🔒 Security | 1 | 1 | 2 | Secret scan, vulnerability scan |
| ⚡ Quality & Performance | 5 | 5 | 10 | Lint, test, performance, metrics, npm lint |
| 📦 Installation & Update | 7 | — | 7 | Install, update, version bump, profile |
| 🧪 Testing | 2 | — | 2 | Script syntax + system integrity validation |
| 🐧 Cross-Platform (Bash) | 17+1 | — | 18 | 17 SH parity + 1 Git hook (pre-commit) |
| 🎨 Design & UX Audit | — | 5 | 5 | UX, accessibility, mobile, design system |
| 🔍 SEO & Validation | — | 6 | 6 | SEO, GEO, i18n, API, schema |
| **Total** | **37** | **17** | **54** | |

---

## Core Script Registry

### 🔧 CLI & Detection Scripts

| # | Script | Mục đích | Usage | SH Parity |
|---|--------|----------|-------|:---------:|
| 1 | `health-check.ps1` | Kiểm tra sức khỏe hệ thống .agent | `.\agent.ps1 health` | ✅ |
| 2 | `validate-compliance.ps1` | Full compliance check trước deploy | `.\agent.ps1 validate` | ✅ |
| 3 | `detect-project.ps1` | Phát hiện tech stack của project | `.\agent.ps1 init` (internal) | ✅ |
| 4 | `discover-rules.ps1` | 3-layer rule engine + agent recommendation | Internal use | ✅ |

### 🔒 Security Scripts

| # | Script | Mục đích | Usage | SH Parity |
|---|--------|----------|-------|:---------:|
| 5 | `secret-scan.ps1` | Quét code tìm secrets/credentials | `.\agent.ps1 scan` | ✅ |

### ⚡ Quality & Performance Scripts

| # | Script | Mục đích | Usage | SH Parity |
|---|--------|----------|-------|:---------:|
| 6 | `auto-heal.ps1` | Tự động fix lint/type/imports + verify step | `.\agent.ps1 heal` | ✅ |
| 7 | `performance-check.ps1` | Enforce performance budgets (Frontend/Backend) | `.\agent.ps1 perf` | ✅ |
| 8 | `dx-analytics.ps1` | DX metrics dashboard (velocity, ROI, quality) | `.\agent.ps1 dx` | ✅ |
| 9 | `log-metrics.ps1` | Ghi metrics JSONL vào tracking file | Internal use | ✅ |
| 10 | `lint-npm-references.ps1` | Detect actionable npm → should be pnpm | CI / Direct | ✅ |

### 📦 Installation & Update Scripts

| # | Script | Mục đích | Usage | SH Parity |
|---|--------|----------|-------|:---------:|
| 11 | `install-antigravity.ps1` | Cài đặt .agent vào project hiện có | `irm <url> \| iex` | ✅ |
| 12 | `install-global.ps1` | Cài đặt global `agi` command | One-time setup | ✅ |
| 13 | `update-antigravity.ps1` | Smart update (backup memory/config) | `agu` alias | ✅ |
| 14 | `update-global.ps1` | Cập nhật global installation | `agug` alias | ✅ |
| 15 | `update-ui-ux-pro-max.ps1` | Cập nhật UI-UX-Pro-Max từ upstream | `/update-ui-ux-pro-max` | ✅ |
| 16 | `bump-version.ps1` | Tăng version và sync across files | After releases | ✅ |
| 17 | `profile-functions.ps1` | PowerShell profile (agi/agu/agug aliases) | Dot-sourced | ✅ |

### 🧪 Testing Scripts

| # | Script | Mục đích | Usage |
|---|--------|----------|-------|
| 18 | `test-scripts.sh` | Validate .sh syntax, shebang, CRLF | `bash .agent/scripts/test-scripts.sh` |
| 19 | `test-integrity.sh` | Count sync, version, parity, stale refs | `bash .agent/scripts/test-integrity.sh` |

### 🐧 Cross-Platform Scripts (100% Parity)

> All 17 PS1 scripts have verified Bash equivalents. 2 SH-only test scripts. 1 universal Git hook.

| # | SH Script | PS1 Equivalent | Added |
|---|-----------|----------------|-------|
| 20 | `health-check.sh` | `health-check.ps1` | v4.x |
| 21 | `install-global.sh` | `install-global.ps1` | v4.x |
| 22 | `validate-compliance.sh` | `validate-compliance.ps1` | v4.x |
| 23 | `bump-version.sh` | `bump-version.ps1` | v4.x |
| 24 | `install-antigravity.sh` | `install-antigravity.ps1` | P2 |
| 25 | `update-antigravity.sh` | `update-antigravity.ps1` | P2 |
| 26 | `update-global.sh` | `update-global.ps1` | P2 |
| 27 | `detect-project.sh` | `detect-project.ps1` | P2 |
| 28 | `secret-scan.sh` | `secret-scan.ps1` | P2 |
| 29 | `discover-rules.sh` | `discover-rules.ps1` | P4 |
| 30 | `auto-heal.sh` | `auto-heal.ps1` | P4 |
| 31 | `performance-check.sh` | `performance-check.ps1` | P4 |
| 32 | `log-metrics.sh` | `log-metrics.ps1` | P4 |
| 33 | `dx-analytics.sh` | `dx-analytics.ps1` | P4 |
| 34 | `lint-npm-references.sh` | `lint-npm-references.ps1` | P4 |
| 35 | `profile-functions.sh` | `profile-functions.ps1` | P4 |
| 36 | `update-ui-ux-pro-max.sh` | `update-ui-ux-pro-max.ps1` | P4 |
| 37 | `pre-commit` | — (Git hook) | All |

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

## Invocation Methods

Scripts có thể được gọi qua **4 phương thức** khác nhau:

| Method | Scope | Ví dụ | Khi nào dùng |
|--------|-------|-------|-------------|
| **Pipeline trigger** | Tự động bởi Pipeline Chain | SHIP Phase 1 → `security_scan.py` | Deploy, review, build |
| **CLI** (`agent.ps1`) | User gọi trực tiếp | `.\agent.ps1 health` | Daily check, maintenance |
| **Workflow** (slash cmd) | Gián tiếp qua agent | `/security-audit` → agent → `security_scan.py` | Feature-specific tasks |
| **Direct** invocation | PowerShell/Python trực tiếp | `pwsh -File .agent/scripts/auto-heal.ps1` | Advanced use, debugging |

### Script Availability by Method

| Script | Pipeline | CLI | Workflow | Direct |
|--------|:--------:|:---:|:--------:|:------:|
| `health-check.ps1` | — | ✅ `health` | `/check` | ✅ |
| `validate-compliance.ps1` | — | ✅ `validate` | `/check` | ✅ |
| `secret-scan.ps1` | SHIP | ✅ `scan` | `/secret-scanning` | ✅ |
| `auto-heal.ps1` | BUILD, ENHANCE | ✅ `heal` | `/auto-healing` | ✅ |
| `performance-check.ps1` | — | ✅ `perf` | `/performance-budget-enforcement` | ✅ |
| `dx-analytics.ps1` | — | ✅ `dx` | — | ✅ |
| `security_scan.py` | SHIP, REVIEW | — | `/security-audit` | ✅ |
| `lint_runner.py` | SHIP, REVIEW | — | `/auto-healing` | ✅ |
| `test_runner.py` | SHIP, REVIEW | — | `/test` | ✅ |
| `lighthouse_audit.py` | REVIEW | — | `/optimize` | ✅ |
| `ux_audit.py` | REVIEW (conditional) | — | `/ui-ux-pro-max` | ✅ |
| `api_validator.py` | REVIEW (conditional) | — | `/api-design` | ✅ |
| `seo_checker.py` | REVIEW (conditional) | — | `/check` | ✅ |
| `i18n_checker.py` | REVIEW (conditional) | — | `/i18n-check` | ✅ |
| Install/Update scripts (7) | — | — | — | ✅ only |
| `lint-npm-references.ps1` | — | — | — | ✅ |
| `test-scripts.sh` | — | — | — | ✅ |
| `test-integrity.sh` | — | — | — | ✅ |

---

## Script ↔ Pipeline & Workflow Dependencies

> ⚠️ **CRITICAL:** Pipeline files **hardcode** script names. Nếu rename/xóa script → pipeline sẽ BREAK.

### Pipeline → Script References

| Pipeline | Phase | Script | Agent |
|----------|-------|--------|-------|
| **SHIP** | Phase 1: Pre-flight | `security_scan.py` | security-auditor |
| **SHIP** | Phase 1: Pre-flight | `lint_runner.py` | ai-code-reviewer |
| **SHIP** | Phase 1: Pre-flight | `test_runner.py` | test-engineer |
| **REVIEW** | Phase 1: Scan (parallel) | `security_scan.py` | security-auditor |
| **REVIEW** | Phase 1: Scan (parallel) | `lint_runner.py` | ai-code-reviewer |
| **REVIEW** | Phase 1: Scan (parallel) | `lighthouse_audit.py` | performance-optimizer |
| **REVIEW** | Phase 1: Scan (parallel) | `test_runner.py` | test-engineer |
| **REVIEW** | Phase 1: Conditional | `ux_audit.py` | frontend-specialist |
| **REVIEW** | Phase 1: Conditional | `api_validator.py` | backend-specialist |
| **REVIEW** | Phase 1: Conditional | `seo_checker.py` | seo-specialist |
| **REVIEW** | Phase 1: Conditional | `i18n_checker.py` | — |
| **BUILD** | Phase 4: Quality | `/auto-healing` → `auto-heal.ps1` | self-correction-agent |
| **ENHANCE** | Phase 4: Verify | `/auto-healing` → `auto-heal.ps1` | self-correction-agent |

> ⚠️ **Dependency Rule:** Trước khi rename/xóa bất kỳ script nào, **grep** tên script trong `pipelines/*.md` và `workflows/*.md`.

---

## CLI Quick Reference

### `agent.ps1` Command → Script Mapping

| Command | Script | Flags |
|---------|--------|-------|
| `.\agent.ps1 health` | `health-check.ps1` | — |
| `.\agent.ps1 validate` | `validate-compliance.ps1` | — |
| `.\agent.ps1 scan` | `secret-scan.ps1` | `-All` |
| `.\agent.ps1 perf` | `performance-check.ps1` | `-All` |
| `.\agent.ps1 heal` | `auto-heal.ps1` | `-All` |
| `.\agent.ps1 heal -DryRun` | `auto-heal.ps1` | `-All -DryRun` |
| `.\agent.ps1 dx` | `dx-analytics.ps1` | `-Dashboard` |
| `.\agent.ps1 dx roi` | `dx-analytics.ps1` | `-ROI` |
| `.\agent.ps1 dx quality` | `dx-analytics.ps1` | `-Quality` |
| `.\agent.ps1 dx bottlenecks` | `dx-analytics.ps1` | `-Bottlenecks` |
| `.\agent.ps1 init` | `detect-project.ps1` | (internal) |

### Scripts NOT in CLI (Direct invocation only)

| Script | Cách gọi |
|--------|----------|
| `install-antigravity.ps1` | `irm <url> \| iex` hoặc `agi` |
| `install-global.ps1` | `& "C:\Tools\Antigravity-Core\.agent\scripts\install-global.ps1"` |
| `update-antigravity.ps1` | `pwsh -File .agent/scripts/update-antigravity.ps1` hoặc `agu` |
| `update-global.ps1` | `agug` |
| `update-ui-ux-pro-max.ps1` | `/update-ui-ux-pro-max` workflow |
| `bump-version.ps1` | `pwsh -File .agent/scripts/bump-version.ps1` |
| `discover-rules.ps1` | Internal (called by auto-rule-discovery system) |
| `log-metrics.ps1` | Internal (called by other scripts) |
| `lint-npm-references.ps1` | CI lint or `pwsh -File .agent/scripts/lint-npm-references.ps1` |
| `profile-functions.ps1` | Dot-sourced by `setup-profile.ps1` |
| `test-scripts.sh` | `bash .agent/scripts/test-scripts.sh` |
| `test-integrity.sh` | `bash .agent/scripts/test-integrity.sh` |

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
1. Security    → security_scan.py        (Always on deploy)
2. Lint        → lint_runner.py           (Every code change)
3. Schema      → schema_validator.py      (After DB change)
4. Tests       → test_runner.py           (After logic change)
5. UX          → ux_audit.py + accessibility_checker.py  (After UI change)
6. SEO         → seo_checker.py           (After page change)
7. Performance → lighthouse_audit.py      (Before deploy)
```

### Maintenance
```powershell
.\agent.ps1 heal           # Auto-fix common issues
.\agent.ps1 dx roi         # View ROI metrics
# Update: run .agent/scripts/update-antigravity.ps1
pwsh -File .agent/scripts/update-antigravity.ps1
```

---

## Adding a New Script

### Core Script (PowerShell/Bash)

1. Tạo file `.agent/scripts/<script-name>.ps1`
2. Xác định category (CLI, Security, Quality, Install, Cross-platform)
3. Nếu cần CLI shortcut → thêm entry vào `agent.ps1` switch block
4. Nếu cross-platform → tạo `.sh` equivalent
5. Update checklist:

| File | Cần update gì |
|------|---------------|
| `ARCHITECTURE.md` L31, L54 | Script count |
| `project.json` → `stats.scripts` | Count + 1 |
| `reference-catalog.md` § 5 | Thêm entry vào Core Scripts table |
| `SCRIPT-CATALOG.md` (this file) | Thêm entry vào Core Script Registry |
| `docs/INDEX.md` | Count reference nếu có |

### Skill Script (Python)

1. Tạo file `.agent/skills/<skill-name>/scripts/<script-name>.py`
2. Nếu script tham gia Quality Gate → thêm vào priority order
3. Nếu pipeline cần gọi → thêm vào `pipelines/*.md` tương ứng
4. Update checklist:

| File | Cần update gì |
|------|---------------|
| `reference-catalog.md` § 5 | Thêm entry vào Skill Scripts table |
| `SCRIPT-CATALOG.md` (this file) | Thêm entry vào Skill Script Registry |
| `pipelines/*.md` | Thêm script reference nếu pipeline cần |

---

## Troubleshooting

| Vấn đề | Nguyên nhân | Cách fix |
|--------|-------------|----------|
| `Script not found: .agent/scripts/X` | Path sai hoặc chưa clone đúng repo | Verify file exists: `Test-Path .agent/scripts/X.ps1` |
| `cannot be loaded because running scripts is disabled` | PowerShell Execution Policy | `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| Python script fails `ModuleNotFoundError` | Thiếu Python dependencies | `pip install -r .agent/skills/<skill>/requirements.txt` (nếu có) |
| `agent.ps1` shows wrong script count | `agent.ps1` L92 chỉ count `*.ps1`, bỏ sót `.sh` + `pre-commit` | Known issue (P2) — count logic cần update |
| Script runs but produces no output | Script cần parameters | Check `-Help` flag: `pwsh -File script.ps1 -Help` |

---

> **See also:** [Agent Catalog](../agents/AGENT-CATALOG.md) | [Workflow Catalog](../workflows/WORKFLOW-CATALOG.md) | [Skill Catalog](../skills/SKILL-CATALOG.md) | [Reference Catalog](../../reference-catalog.md)

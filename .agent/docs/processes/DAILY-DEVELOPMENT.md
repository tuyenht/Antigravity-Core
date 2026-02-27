# Daily Development — Quy trình phát triển hàng ngày

**Version:** 5.0.0  
**Last Updated:** 2026-02-27

---

## Morning Routine

### 1. Health Check (2 phút)
```powershell
.\.agent\agent.ps1 health
```
- Verify `.agent/` integrity
- Check for stale config
- Validate dependencies

### 2. Secret Scan (1 phút)
```powershell
.\.agent\agent.ps1 scan
```
- Detect accidentally committed secrets
- Check `.env` files

---

## Development Cycle

### Feature Development

```
1. /plan              → Phân tích & lập kế hoạch feature
2. /schema-first      → Design database changes (nếu cần)
3. /enhance           → Implement feature
4. /test              → Viết tests
5. /auto-healing      → Auto-fix lint/type errors
```

### Bug Fix

```
1. /debug             → Systematic root cause analysis
2. /quickfix          → Apply fix
3. /test              → Verify fix + regression test
```

### Refactoring

```
1. /refactor          → Analyze code smells
2. Review suggestions → User approves changes
3. /test              → Verify no regressions
```

---

## Pre-Commit Checklist

```
✅ /auto-healing         → Lint & type errors fixed
✅ /check                → AI code review passed
✅ /test                 → All tests passing
✅ /secret-scanning      → No secrets in code
```

---

## Pre-PR Checklist

Mọi thứ ở pre-commit PLUS:
```
✅ /security-audit       → Security scan (weekly minimum)
✅ /optimize            → Performance check (nếu UI changes)
✅ Documentation updated
```

---

## Weekly Maintenance

| Day | Task | Command |
|-----|------|---------|
| Monday | Full health check | `/check` |
| Wednesday | Security scan | `/security-audit` |
| Friday | Performance review | `/optimize` |

---

## Agent Selection Quick Guide

| Task | Use | Don't Use |
|------|-----|-----------|
| New UI component | `/enhance` + `frontend-specialist` | `backend-specialist` |
| API endpoint | `/enhance` + `backend-specialist` | `frontend-specialist` |
| Database change | `/schema-first` + `database-architect` | Direct SQL |
| Mobile feature | `/enhance` + `mobile-developer` | `frontend-specialist` |
| Fix bug | `/debug` + `debugger` | Random trial-and-error |

---

> **See also:** [Code Review Process](./CODE-REVIEW-PROCESS.md) | [Workflow Catalog](../workflows/WORKFLOW-CATALOG.md)

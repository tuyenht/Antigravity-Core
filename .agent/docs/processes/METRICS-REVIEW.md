# Metrics Review — Quy Trình Đo Lường & Đánh Giá

**Version:** 4.1.0  
**Last Updated:** 2026-02-25

---

## Overview

Quy trình review metrics định kỳ, đảm bảo hệ thống và đội nhóm liên tục cải thiện. Kết hợp **automated metrics** từ `project.json` với **manual review** hàng tháng.

---

## Metrics Categories

### 1. System Health (Automated)

Tracked trong `project.json > metrics`:

| Metric | Target | Công cụ đo |
|--------|--------|-----------|
| `autonomy_score` | ≥ 85 | Agent self-completion rate |
| `health_score` | ≥ 85 | `agent.ps1 health` |
| `consistency_score` | ≥ 90 | Count accuracy across docs |
| `testing_score` | ≥ 80 | Coverage + pass rate |
| `ci_cd_score` | ≥ 70 | Pipeline success rate |

### 2. Code Quality (Per Sprint)

| Metric | Target | Đo bằng |
|--------|--------|---------|
| Test coverage | ≥ 80% | `npm test -- --coverage` |
| Lint errors | 0 | `/auto-healing` |
| Type errors | 0 | `tsc --noEmit` |
| Security vulns | 0 critical/high | `/security-audit` |
| Code duplication | < 5% | SonarQube / jscpd |

### 3. Performance (Per Release)

| Metric | Target | Đo bằng |
|--------|--------|---------|
| Bundle size | < 500KB gzip | Webpack analyzer |
| LCP | < 2.5s | Lighthouse |
| INP | < 200ms | Lighthouse |
| API response | < 200ms p95 | APM tool |
| Lighthouse score | > 90 | `lighthouse_audit.py` |

### 4. Process (Monthly)

| Metric | Target | Cách đo |
|--------|--------|---------|
| Sprint velocity | Stable ±15% | Story points completed |
| Bug escape rate | < 5% | Bugs found in prod / total stories |
| PR cycle time | < 24h | PR created → merged |
| Incident count | Trending down | P0+P1 per month |
| DoD compliance | 100% | Spot-check PRs |

---

## Review Cadence

| Frequency | What | Who | Action |
|-----------|------|-----|--------|
| **Daily** | Health check | Automated | `agent.ps1 health` |
| **Weekly** | Sprint metrics | PM | Friday standup |
| **Monthly** | Full metrics review | Team | Review meeting |
| **Quarterly** | System audit | Tech Lead | Architecture review |

---

## Monthly Review Process

### 1. Collect Data (15 min)
```powershell
# System health
.\.agent\agent.ps1 health

# Performance
python .agent/skills/performance-profiling/scripts/lighthouse_audit.py

# Security
python .agent/skills/vulnerability-scanner/scripts/security_scan.py
```

### 2. Review Dashboard (30 min)

```markdown
## Monthly Metrics Report — [Month Year]

### System Scores (from project.json)
| Metric | Previous | Current | Trend |
|--------|----------|---------|-------|
| Autonomy | XX | XX | ↑/↓/→ |
| Health | XX | XX | ↑/↓/→ |
| Testing | XX | XX | ↑/↓/→ |

### Sprint Summary
- Stories completed: XX / XX planned
- Velocity: XX points (avg: XX)
- Bug escape rate: X%
- P0/P1 incidents: X

### Action Items from Last Month
| # | Action | Status |
|---|--------|--------|
| 1 | [action] | ✅ Done / 🔄 In progress / ❌ Missed |
```

### 3. Identify Actions (15 min)

For any metric **below target**:
1. Identify root cause
2. Create action item with owner + deadline
3. Track in next monthly review

### 4. Update project.json

```bash
# After review, update scores
# Edit .agent/project.json > metrics
# Update last_audit date
```

---

## Alerting Thresholds

| Metric | Warning | Critical | Action |
|--------|---------|----------|--------|
| Health score | < 80 | < 60 | Run `/check` |
| Test coverage | < 80% | < 60% | Block deploy |
| Security vulns | Any medium | Any high/critical | `/security-audit` |
| Error rate | > 1% | > 5% | Incident Response |
| API latency | > 500ms p95 | > 1s p95 | `/optimize` |

---

> **See also:** [Daily Development](./DAILY-DEVELOPMENT.md) | [Deployment Process](./DEPLOYMENT-PROCESS.md)

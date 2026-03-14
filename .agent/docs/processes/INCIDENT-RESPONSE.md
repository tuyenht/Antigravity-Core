# Incident Response — Quy Trình Xử Lý Sự Cố

**Version:** 5.0.1  
**Last Updated:** 2026-02-27

---

## Severity Levels

| Level | Tên | Ví dụ | Response Time | Escalation |
|-------|-----|-------|---------------|------------|
| **P0** | Critical | Site down, data loss, security breach | **15 phút** | Immediate — all hands |
| **P1** | High | Major feature broken, payment failure | **1 giờ** | On-call + Tech Lead |
| **P2** | Medium | Non-critical bug, degraded performance | **4 giờ** | Assigned developer |
| **P3** | Low | Minor UI glitch, cosmetic issue | **24 giờ** | Next sprint |

---

## Response Workflow

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  1. DETECT   │ ──► │  2. TRIAGE   │ ──► │  3. RESPOND  │
│              │     │              │     │              │
│ • Monitoring │     │ • Assign P   │     │ • Hotfix     │
│ • User report│     │ • Assign     │     │ • Rollback   │
│ • Alert      │     │   owner      │     │ • Mitigate   │
└───────────┘     └───────────┘     └───────────┘
                                                │
                     ┌──────────────┐     ┌──────┴───────┐
                     │ 5. PREVENT   │ ◄── │  4. RECOVER  │
                     │              │     │              │
                     │ • Post-mortem│     │ • Verify fix │
                     │ • Action item│     │ • Monitor    │
                     │ • Update docs│     │ • Confirm    │
                     └───────────┘     └───────────┘
```

---

## Phase 1: Detect

**Sources:**
- Monitoring alerts (uptime, error rate, latency)
- User reports (support tickets, social media)
- CI/CD pipeline failures
- Security scan alerts

**Action:** Log incident immediately
```markdown
## Incident Report — INC-YYYY-MM-DD-NNN

**Detected:** [timestamp]
**Reported by:** [person/system]
**Severity:** P0 / P1 / P2 / P3
**Summary:** [1-line description]
**Impact:** [users affected, revenue impact]
```

---

## Phase 2: Triage

| Severity | Decision | Action |
|----------|----------|--------|
| P0 | **IMMEDIATE ROLLBACK** | `git revert HEAD && git push` + DB restore if needed |
| P1 | **HOTFIX** | `hotfix/<ticket>` branch, expedited review |
| P2 | **SCHEDULED FIX** | Add to current sprint, normal review |
| P3 | **BACKLOG** | Add to backlog, fix in next sprint |

**Triage checklist:**
- [ ] Severity assigned
- [ ] Owner assigned
- [ ] Stakeholders notified
- [ ] Incident channel created (nếu P0/P1)

---

## Phase 3: Respond

### P0/P1 Fast Response
```bash
# 1. Rollback nếu cần
git revert HEAD
git push origin main

# 2. Hoặc hotfix
git checkout -b hotfix/INC-2026-02-25-001
# ... fix ...
git push -u origin hotfix/INC-2026-02-25-001
# → PR với label "hotfix" → expedited review

# 3. Deploy
/deploy
```

### P2/P3 Normal Response
```
/debug        → Systematic root cause analysis
/quickfix     → Apply fix
/test         → Verify + regression test
```

---

## Phase 4: Recover

**Post-fix verification:**
- [ ] Fix deployed to production
- [ ] Health check passing
- [ ] Error rate back to normal
- [ ] Affected users can access service
- [ ] Monitor 24h for recurrence

---

## Phase 5: Prevent (Post-Mortem)

**Bắt buộc cho P0/P1. Khuyến khích cho P2.**

```markdown
## Post-Mortem — INC-YYYY-MM-DD-NNN

**Date:** [date]
**Duration:** [detection → resolution]
**Severity:** P0/P1
**Root Cause:** [technical root cause]

### Timeline
- HH:MM — Incident detected
- HH:MM — Triage completed
- HH:MM — Fix deployed
- HH:MM — Recovery confirmed

### Impact
- Users affected: [number]
- Revenue impact: [estimate]
- SLA violated: [yes/no]

### Root Cause Analysis
[Detailed technical explanation]

### Action Items
| # | Action | Owner | Deadline | Status |
|---|--------|-------|----------|--------|
| 1 | Add monitoring for X | DevOps | [date] | [ ] |
| 2 | Write regression test | QA | [date] | [ ] |
| 3 | Update runbook | Docs | [date] | [ ] |

### Lessons Learned
- [What went well]
- [What could be improved]
```

---

## Communication Templates

### P0 — Immediate Notify
```
🔴 [P0 INCIDENT] — [Service] is DOWN
Impact: [affected users/features]
Status: Investigating
ETA: [estimated fix time]
Owner: [person]
```

### Resolution Notify
```
✅ [RESOLVED] — [Service] is back to normal
Root cause: [brief explanation]
Fix: [what was done]
Post-mortem: [scheduled date]
```

---

> **See also:** [Deployment Process](./DEPLOYMENT-PROCESS.md) | [Troubleshooting](./TROUBLESHOOTING.md) | [Branching Strategy](./BRANCHING-STRATEGY.md)

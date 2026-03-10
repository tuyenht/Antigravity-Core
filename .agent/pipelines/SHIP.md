---
description: "Pipeline Chain: Triển khai và phát hành lên production."
---

# 🚀 SHIP Pipeline — Triển Khai Production

> **Trigger:** Intent Router classifies request as SHIP
> **Khi nào:** User muốn deploy, release, hoặc publish
> **Thời gian ước tính:** 10-30 phút

---

## Pipeline Flow

```
PHASE 0        PHASE 1        PHASE 2         PHASE 3          PHASE 4
ONBOARDING →   PRE-FLIGHT →   BUILD      →    DEPLOY      →    POST-DEPLOY
(auto/skip)    (5 phút)       (3-5 phút)      (5-10 phút)      (2 phút)
   │               │               │                │                │
   └→ Tạo docs    └→ Security +   └→ Production   └→ Staging →     └→ Health check
      nếu chưa có    quality gate     bundle          production       + monitoring
```

---

## PHASE 0: ONBOARDING (Tài liệu dự án — lightweight)

**Template:** `templates/project-bootstrap.md`

### 4-Tier Check
```
1. docs/PLAN.md không tồn tại          → CREATE (chain → /init-docs nếu docs/ có nhiều files)
2. docs/PLAN.md có nhưng thiếu stamp   → UPGRADE (bổ sung + stamp + Docs Ingestion)
3. docs/PLAN.md có stamp + docs mới    → REFRESH (đọc files mới/thay đổi, update PLAN.md)
4. docs/PLAN.md có stamp + không đổi   → SKIP (qua Phase 1 ngay)
```

> 💡 SHIP pipeline giữ onboarding **nhẹ** — đọc docs nhanh để biết deploy target, env vars, infra constraints.

---

## PHASE 1: PRE-FLIGHT (Kiểm tra trước triển khai)

**Agents:** `security-auditor` + `ai-code-reviewer` (parallel)
**Skills:** `vulnerability-scanner`, `code-review-checklist`

### Mandatory Checks — Priority Order
```
1. 🔴 SECURITY     → security_scan.py
2. 🟠 LINT         → lint_runner.py
3. 🟡 TYPE CHECK   → tsc --noEmit / phpstan
4. 🟢 TESTS        → test_runner.py
5. 🔵 BUILD        → Production build succeeds
```

### ⛔ GATE: Must ALL Pass
```
If ANY check fails:
  CRITICAL (security) → BLOCK deploy, fix first
  HIGH (lint/type)    → BLOCK deploy, run /auto-healing
  MEDIUM (tests)      → WARN, ask user to proceed or fix
  LOW                 → WARN only, proceed
```

### Chaining Existing Workflows
```
├── /security-audit workflow → Security scan
├── /check workflow          → Quality health check
└── /secret-scanning         → Secret leak detection
```

---

## PHASE 2: BUILD (Production Bundle)

**Agent:** `devops-engineer`
**Skills:** `deployment-procedures`, `docker-expert`

### Auto-Actions by Stack

| Stack | Build Command | Artifacts |
|-------|--------------|-----------|
| Next.js | `npm run build` | `.next/` |
| Laravel | `composer install --no-dev` + `npm run build` | `public/build/` |
| React (Vite) | `npm run build` | `dist/` |
| Python | `pip install -r requirements.txt` | — |
| Docker | `docker build -t app .` | Image |

### Output Phase 2
- Production-ready build
- Bundle size report
- Environment variables checklist

---

## PHASE 3: DEPLOY (Triển khai)

**Agent:** `devops-engineer`
**Skills:** `deployment-procedures`

### Deploy Strategy (Auto-select)

```yaml
deploy_strategies:
  simple:
    when: "Single server, no CI/CD yet"
    steps: ["Build → Upload → Restart"]
    
  ci_cd:
    when: "GitHub Actions / CI pipeline exists"
    steps: ["Push → CI runs → Auto-deploy"]
    
  containerized:
    when: "Docker / Kubernetes"
    steps: ["Build image → Push registry → Deploy → Health check"]
    
  serverless:
    when: "Vercel / Netlify / Cloudflare"
    steps: ["Push → Auto-build → Live"]
```

### ⛔ CHECKPOINT: Staging
```
If staging environment exists:
  → Deploy to staging first
  → Run smoke tests
  → "Staging OK. Deploy to production?"
  → User confirm → Production deploy

If no staging:
  → "No staging environment. Deploy directly to production?"
  → User confirm → Deploy with extra caution
```

### Chaining Existing Workflows
```
├── /deploy workflow        → Main deploy process
├── /mobile-deploy workflow → If mobile app
└── /backup workflow        → Pre-deploy backup
```

---

## PHASE 4: POST-DEPLOY (Sau triển khai)

**Agent:** `manager-agent`

### Auto-Actions
1. Health check → Production URL responds
2. Smoke test → Core features work
3. Monitoring → Verify logs clean
4. Rollback plan → Ready if needed

### Output Phase 4
```
✅ Triển khai thành công!

🌐 Production: [URL]
📊 Health: ✅ All systems operational
📝 Version: [version]
⏱️ Deploy time: [duration]

🔄 Rollback: [command if needed]

Monitoring:
→ Check logs trong 24h đầu
→ /review để đánh giá sau deploy
```

---

## Rollback Protocol

```yaml
rollback:
  trigger:
    - "Health check fails"
    - "Error rate > 1%"
    - "User reports critical bug"
  action:
    - "Revert to previous version"
    - "Restore database backup (if schema changed)"
    - "Notify user"
  command:
    git: "git revert HEAD && git push"
    docker: "docker rollback [service]"
    vercel: "vercel rollback"
```

---

## 🧬 PHASE FINAL: LEARNING (Tự động)

> Chạy SAU KHI pipeline hoàn tất. AI tự ghi nhận kinh nghiệm.

### Auto-Actions
1. **Record** vào `memory/learning-patterns.yaml`
2. **Track** `project.json → usage_tracking.pipelines_used.SHIP += 1`

### Data to Record
```yaml
- date: "{today}"
  pipeline: "SHIP"
  deploy_target: "{vercel | docker | server | etc}"
  pre_flight_issues: "{security/lint issues found, if any}"
  deploy_success: "{true/false}"
  rollback_needed: "{true/false}"
  what_worked: "{deploy strategy that worked smooth}"
  what_failed: "{issues during deploy}"
  improvement_idea: "{suggestion}"
```

---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| Build fails | Check error log, usually dependency/config issue |
| Deploy succeeds but 500 errors | Check env vars, database connection, logs |
| Performance degraded after deploy | Profile, compare with pre-deploy metrics |
| SSL/DNS issues | Check certificate, DNS propagation (wait 24-48h) |

# Troubleshooting — Xử lý sự cố thường gặp

**Version:** 4.0.0  
**Last Updated:** 2026-02-13

---

## Common Issues

### 1. Agent Not Found / File Missing

**Triệu chứng:** Agent reference error, file not found

**Nguyên nhân:** `.agent/` directory incomplete hoặc corrupted

**Giải pháp:**
```powershell
# Re-install
.\.agent\agent.ps1 update

# Hoặc re-init
.\.agent\agent.ps1 init --force
```

---

### 2. Health Check Fails

**Triệu chứng:** `agent.ps1 health` reports errors

**Giải pháp:**
```powershell
# View specific errors
.\.agent\agent.ps1 health

# Auto-heal
.\.agent\agent.ps1 heal
```

**Nếu vẫn fail:** Check file permissions, re-clone `.agent/`

---

### 3. Rule Not Auto-Loading

**Triệu chứng:** Expected rules not applied

**Nguyên nhân:** File extension hoặc project config không match

**Giải pháp:**
1. Check `.agent/context.yml` — có detect đúng tech stack?
2. Re-run detection: `.\.agent\agent.ps1 init`
3. Manual load: "Use the [rule-name] rule"
4. Check `discover-rules.ps1` output

---

### 4. Secret Scan False Positives

**Triệu chứng:** Secret scan flags non-secret strings

**Giải pháp:**
- Add exceptions to `.agent/secret-patterns.yml`
- Use `# nosecret` comment inline
- Whitelist file paths

---

### 5. Performance Budget Exceeded

**Triệu chứng:** `performance-check.ps1` fails

**Giải pháp:**
1. Review `.agent/performance-budgets.yml`
2. Adjust budgets if reasonable: `maxBundleSize`, `maxResponseTime`
3. Or optimize code: `/optimize`

---

### 6. Auto-Heal Loop

**Triệu chứng:** `self-correction-agent` reaches max 3 iterations

**Nguyên nhân:** Underlying issue too complex for auto-fix

**Giải pháp:**
1. Stop auto-heal
2. Run `/debug` for systematic analysis
3. Fix root cause manually
4. Then re-run `/auto-healing`

---

### 7. Agent Conflict

**Triệu chứng:** Multiple agents try to edit same file

**Nguyên nhân:** Orchestrator routing error

**Giải pháp:**
1. Check `agent-coordination.md` file ownership rules
2. Only ONE agent per file domain
3. Report conflict to `orchestrator` for re-routing

---

## Escalation Path

```
Self-fix (auto-heal) → 
  Debug (systematic) → 
    Manual fix → 
      Re-install .agent → 
        Report issue on GitHub
```

---

> **See also:** [Health Check Script](../scripts/SCRIPT-CATALOG.md) | [Systems Catalog](../systems/SYSTEMS-CATALOG.md)

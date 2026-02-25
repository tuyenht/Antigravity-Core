# Code Review Process — Quy trình Review Code

**Version:** 4.0.1  
**Last Updated:** 2026-02-25

---

## Overview

Quy trình code review kết hợp **AI review tự động** và **human review**, đảm bảo quality gates trước khi merge.

---

## Phase 1: AI Pre-Review (Automated)

### Run AI Code Review
```
/code-review-automation
```

AI agent `ai-code-reviewer` sẽ kiểm tra:

| Check | Mục đích |
|-------|----------|
| **Performance Anti-patterns** | N+1 queries, unnecessary renders, memory leaks |
| **Security Vulnerabilities** | XSS, SQL injection, hardcoded secrets |
| **Code Quality** | Complexity, duplication, naming conventions |
| **Missing Tests** | Critical paths without test coverage |
| **Type Safety** | TypeScript/Pydantic type issues |

### Run Compliance Check
```powershell
.\.agent\agent.ps1 validate
```

Verifies:
- Linter passing
- Type check passing
- Tests passing
- Security scan clean

---

## Phase 2: Human Review

### Reviewer Checklist

**Architecture:**
- [ ] Changes follow existing patterns?
- [ ] No unnecessary complexity?
- [ ] Dependencies added justified?

**Logic:**
- [ ] Business logic correct?
- [ ] Edge cases handled?
- [ ] Error handling adequate?

**Security:**
- [ ] Input validated?
- [ ] Authorization checked?
- [ ] No sensitive data exposed?

**Testing:**
- [ ] Tests cover happy path?
- [ ] Tests cover edge cases?
- [ ] Tests cover error scenarios?

---

## Phase 3: Post-Review

### After Approval
```bash
git merge feature-branch
```

### AOC Auto-Trigger
After merge, `manager-agent` automatically runs Auto-Optimization Cycle:
1. `self-correction-agent` → Fix remaining issues
2. `documentation-agent` → Update docs
3. `refactor-agent` → Suggest improvements

---

> **See also:** [Daily Development](./DAILY-DEVELOPMENT.md) | [Agent Catalog](../agents/AGENT-CATALOG.md)

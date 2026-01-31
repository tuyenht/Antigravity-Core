# Security Incident Response Playbook

**Version:** 1.0  
**Updated:** 2026-01-16

---

## Incident Severity Classification

| Level | Description | Response Time | Escalation |
|-------|-------------|---------------|------------|
| **P0 - Critical** | Active breach, data loss | 15 minutes | CTO, CEO |
| **P1 - High** | Vulnerability exploitable | 1 hour | Security Lead |
| **P2 - Medium** | Security gap, no active threat | 24 hours | Team Lead |
| **P3 - Low** | Improvement opportunity | 1 week | Development Team |

---

## Response Workflow

```
DETECT → ASSESS → CONTAIN → ERADICATE → RECOVER → LESSONS LEARNED
```

---

## 1. DETECT (Automated Alerts)

**Detection Sources:**
- Dependency vulnerability alerts (Dependabot/Snyk)
- SAST findings (CodeQL/SonarQube)
- Failed login spikes
- Unusual API traffic patterns
- Container scan failures

**Actions:**
1. Alert security team immediately
2. Document detection timestamp
3. Preserve evidence (logs, screenshots)

---

## 2. ASSESS (Severity & Impact)

**Questions to Answer:**
- What is compromised?
- How many users affected?
- What data is at risk?
- Is it actively exploited?

**Severity Matrix:**
```
Impact: HIGH + Likelihood: HIGH = P0 (Critical)
Impact: HIGH + Likelihood: LOW  = P1 (High)
Impact: LOW  + Likelihood: HIGH = P2 (Medium)
Impact: LOW  + Likelihood: LOW  = P3 (Low)
```

---

## 3. CONTAIN (Stop the Bleeding)

**Immediate Actions:**
```bash
# Rotate compromised credentials
# Block malicious IPs
# Disable vulnerable endpoints
# Isolate affected systems
```

**Example:**
```bash
# Emergency: Disable endpoint
# In load balancer config
location /api/vulnerable {
    deny all;
}
```

---

## 4. ERADICATE (Remove Threat)

**Steps:**
1. Patch vulnerability
2. Remove backdoors
3. Clean compromised data
4. Update dependencies

**Example Patch:**
```bash
# Critical CVE patch
npm update package@safe-version
npm test
git commit -m "security: patch CVE-2024-12345"
git push
# Deploy immediately
```

---

## 5. RECOVER (Restore Normal Operations)

**Verification Checklist:**
- [ ] Vulnerability confirmed patched
- [ ] All tests passing
- [ ] No suspicious activity in logs
- [ ] Security scan clean
- [ ] Stakeholders notified

**Gradual Restoration:**
1. Deploy to canary (10% traffic)
2. Monitor for 1 hour
3. Deploy to production (100%)
4. Monitor for 24 hours

---

## 6. LESSONS LEARNED (Post-Mortem)

**Within 48 hours, document:**
1. What happened?
2. How was it detected?
3. Response timeline
4. What went well?
5. What needs improvement?
6. Action items to prevent recurrence

---

## Emergency Contacts

```
Security Lead:    security@company.com
DevOps On-Call:   +1-XXX-XXX-XXXX
CTO:              cto@company.com
External Partner: security-firm@example.com
```

---

## Pre-Approved Emergency Actions

**Anyone can execute (no approval needed):**
- Rotate API keys
- Block malicious IPs
- Disable non-critical features
- Scale down affected services

**Requires approval (CTO/Security Lead):**
- Full system shutdown
- Database rollback
- Public disclosure
- Law enforcement notification

---

**Keep this playbook accessible 24/7!**

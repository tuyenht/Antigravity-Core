# Deprecation Policy

**Version:** 1.0  
**Effective Date:** 2026-01-17  
**Applies To:** All .agent system components

---

## Purpose

This policy ensures:
1. **Predictability** - Users know when features will be removed
2. **Stability** - Sufficient time to migrate
3. **Communication** - Clear deprecation notices
4. **Support** - Migration assistance provided

---

## Deprecation Process

### Timeline

```
Announcement → Warning Period → Deprecation → Removal
    (T+0)         (6 months)      (6 months)   (T+12mo)
```

**Minimum timelines:**
- **MAJOR versions:** 12 months total (6mo warning + 6mo deprecated)
- **MINOR versions:** 6 months total (3mo warning + 3mo deprecated)
- **Critical security fixes:** May bypass timelines

---

## Stages

### Stage 1: Announcement (T+0)
**What happens:**
- Feature marked for deprecation
- Added to CHANGELOG.md under "Deprecated"
- Migration guide published
- Announcement in release notes

**Example:**
```markdown
## [2.5.0] - 2026-06-01
### Deprecated
- ⚠️ `workflow/old-security-scan.md` - Use `workflow/security-audit.md` instead
  - Migration guide: docs/MIGRATION-GUIDES/security-workflow-v2-5.md
  - Removal planned: v3.0.0 (December 2026)
```

---

### Stage 2: Warning Period (6 months for MAJOR)
**What happens:**
- Feature still fully functional
- Warning messages added to documentation
- Alternative recommended in all references
- Migration examples provided

**Users should:**
- Plan migration
- Test alternatives
- Update dependent code
- Report any blockers

---

### Stage 3: Deprecated (6 months before removal)
**What happens:**
- Feature marked `[DEPRECATED]` in all docs
- Runtime warnings (if applicable)
- Removed from recommended practices
- Minimal bug fixes (security only)

**Example:**
```markdown
# [DEPRECATED] Old Security Scan

⚠️ **This workflow is deprecated and will be removed in v3.0.0**

**Migration:** Use `security-audit.md` instead
**Guide:** See docs/MIGRATION-GUIDES/security-workflow-v2-5.md
```

---

### Stage 4: Removal (After full timeline)
**What happens:**
- Feature removed from next MAJOR version
- Documented in CHANGELOG as "Removed"
- Final migration reminder in release notes

**Example:**
```markdown
## [3.0.0] - 2026-12-01
### Removed
- 🗑️ `workflow/old-security-scan.md` 
  - Deprecated since v2.5.0
  - Use `workflow/security-audit.md`
  - Migration guide: docs/MIGRATION-GUIDES/security-workflow-v2-5.md
```

---

## What Can Be Deprecated?

### Subject to Deprecation
✅ Workflows  
✅ Skills  
✅ Agents  
✅ Specific standards sections  
✅ Workflow commands  
✅ Configuration options  
✅ File formats (with migration tools)

### Not Subject to Deprecation
❌ Core .agent principles  
❌ Backward compatibility (never intentionally broken)  
❌ Security standards (only enhanced, never removed)

---

## Communication Channels

Deprecation notices will be published via:

1. **CHANGELOG.md** - Primary source of truth
2. **Release notes** - For each version
3. **In-file warnings** - Deprecated features have banner
4. **Migration guides** - Step-by-step instructions
5. **System notifications** (if applicable)

---

## Migration Support

### Provided Resources
For each deprecation, we provide:

1. **📝 Migration Guide**
   - Step-by-step instructions
   - Before/after examples
   - Automated migration scripts (when possible)

2. **🔄 Automated Tools**
   - Codemod scripts (when applicable)
   - Find-and-replace recipes
   - Compatibility checkers

3. **💬 Support**
   - FAQ for common issues
   - Discussion forum threads
   - Direct assistance (if needed)

4. **⏱️ Extended Support**
   - Critical bug fixes during deprecation period
   - Security patches even for deprecated features

---

## Exception Handling

### Emergency Deprecation
In rare cases (critical security vulnerability), timeline may be shortened:

**Process:**
1. Immediate announcement with severity explanation
2. Recommended migration: 1 month (instead of 6)
3. Removal: Next MINOR version (instead of next MAJOR)
4. Extra migration support provided

**Example:**
```markdown
## [2.5.1] - 2026-06-15 (SECURITY PATCH)
### Deprecated (URGENT)
- ⚠️ CRITICAL: `workflow/insecure-deploy.md` contains security vulnerability
  - Immediate action required
  - Use `workflow/secure-deploy.md` instead
  - Removal in v2.6.0 (July 2026)
  - See CVE-XXXX for details
```

---

## Rollback Policy

If deprecation causes major issues:

1. **Community feedback period:** 2 weeks after announcement
2. **Evaluation:** Impact assessment
3. **Possible outcomes:**
   - Continue with extended timeline
   - Provide alternative solution
   - Un-deprecate if no viable alternative

---

## Versioning Impact

### MAJOR Version (X.0.0)
- Can remove deprecated features
- Must be deprecated for 12+ months
- Breaking changes allowed

### MINOR Version (x.Y.0)
- Can deprecate features (with notice)
- Cannot remove features
- Backward compatible

### PATCH Version (x.y.Z)
- Cannot deprecate or remove features
- Bug fixes only
- Backward compatible

---

## Examples

### Good Deprecation ✅
```
v2.5.0 (June 2026):    Announce deprecation of workflow/old-scan.md
v2.5.0 - v2.11.0:      Warning period (6 months)
v3.0.0 (December 2026): Deprecation period starts
v3.0.0 - v3.6.0:       Deprecated but functional (6 months)
v4.0.0 (June 2027):    Removal (12 months after announcement)
```

### Bad Deprecation ❌
```
v2.5.0: Announce deprecation
v2.6.0: Remove immediately ← WRONG! No timeline followed
```

---

## Monitoring Deprecated Features

### Usage Tracking (Planned)
Future versions will track usage of deprecated features:
- Anonymous usage stats
- Help prioritize support efforts
- Identify migration blockers

**Privacy:** Opt-in only, anonymized, no sensitive data

---

## Commitment

We commit to:
1. ✅ **Never surprise remove** features
2. ✅ **Always provide** migration path
3. ✅ **Support during** transition period
4. ✅ **Listen to** community feedback
5. ✅ **Extend timelines** if needed

---

## FAQ

**Q: What if I can't migrate in time?**  
A: Reach out! We can provide extended support or find alternative solutions.

**Q: Can I keep using deprecated features?**  
A: During deprecation period, yes. After removal, no.

**Q: What if there's no good alternative?**  
A: We won't deprecate without a viable alternative. If you find issues, report them!

**Q: Can deprecations be reversed?**  
A: Yes, if community feedback shows we made a mistake.

**Q: How do I know what's deprecated?**  
A: Check CHANGELOG.md and look for `[DEPRECATED]` tags in docs.

---

## Reporting Issues

If you encounter problems with deprecated features or migrations:

1. Check migration guide
2. Search existing issues
3. Open new issue with:
   - Feature being deprecated
   - Your use case
   - Migration blocker
   - Suggested alternative

---

## Policy Updates

This policy may be updated to improve clarity or process.

**Policy Version History:**
- v1.0 (2026-01-17): Initial policy

**Change Process:**
- Policy changes announced in CHANGELOG
- Community feedback period before enforcement
- This policy itself follows its own deprecation rules 😊

---

**Remember:** Deprecation is not punishment - it's evolution! 🚀

We deprecate to:
- Remove technical debt
- Improve security
- Simplify the system
- Make room for better features

**Your input matters!** Always feel free to discuss deprecations.

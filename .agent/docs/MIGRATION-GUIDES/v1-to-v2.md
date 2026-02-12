# Migration Guide: v1.0 → v2.0

**Release Date:** 2026-01-17  
**Breaking Changes:** None  
**Recommended Action:** Upgrade immediately

---

## Overview

Version 2.0 introduces **universal, tech-stack-agnostic** automation while maintaining full backward compatibility with v1.0.

**Key Changes:**
- ✅ Universal code review automation
- ✅ Comprehensive integration guide
- ✅ Next.js 16 support
- ✅ Enhanced skills (AI SDK, Prisma)
- ✅ Versioning system (this guide!)

---

## Breaking Changes

**None!** v2.0 is fully backward compatible with v1.0.

All existing workflows, skills, and configurations continue to work.

---

## New Features

### 1. Universal Code Review
**New Workflow:** `code-review-automation.md`

**Before (v1.0):**
```bash
# Manual review per tech stack
# No unified process
```

**After (v2.0):**
```bash
# Auto-detects tech stack
/code-review-automation

# Or specific categories
/security-audit
/optimize
```

**Action Required:** None (opt-in feature)

---

### 2. Integration Guide
**New File:** `INTEGRATION-GUIDE.md`

Comprehensive guide for:
- Setting up new projects
- CI/CD integration
- Team onboarding
- Customization

**Action Required:** Read the guide to leverage new features

---

### 3. Next.js 16 Support
**Updated:** `rules/standards/frameworks/nextjs-conventions.md`

New features covered:
- Cache Components (stable)
- Turbopack by default
- React 19.2 Compiler
- proxy.ts (replaces middleware.ts)
- DevTools MCP

**Action Required (if using Next.js):**
- Review new conventions
- Update projects to Next.js 16 when ready
- Replace middleware.ts with proxy.ts (optional migration)

---

### 4. Enhanced Skills
**Added:**
- `skills/ai-sdk-expert/` - Vercel AI SDK v5
- `skills/prisma-expert/` - ORM best practices

**Action Required:** None (available when needed)

---

### 5. Versioning System
**Added:**
- `VERSION` file
- `CHANGELOG.md`
- `docs/DEPRECATION-POLICY.md`

**Action Required:** Note the version for future reference

---

## Recommended Upgrade Steps

### For Existing Projects

1. **Pull Latest .agent**
   ```bash
   cd .agent
   git pull origin main
   # Or manually copy updated files
   ```

2. **Review Changes**
   ```bash
   cat .agent/CHANGELOG.md
   ```

3. **Optional: Adopt New Workflows**
   - Try `/code-review-automation` on your codebase
   - Read `INTEGRATION-GUIDE.md`
   - Update Next.js projects to v16 (when ready)

4. **No Code Changes Required**
   - All existing code continues to work
   - No configuration changes needed

---

### For New Projects

1. **Copy .agent Folder**
   ```bash
   cp -r path/to/.agent /new-project/.agent
   ```

2. **Follow Integration Guide**
   ```bash
   # Read comprehensive guide
   cat .agent/INTEGRATION-GUIDE.md
   ```

3. **Use Universal Workflows**
   - Auto-detection works out of the box
   - No tech-stack-specific setup needed

---

## Deprecated Features

**None in v2.0**

See `docs/DEPRECATION-POLICY.md` for future deprecation process.

---

## What's Different?

### v1.0 Focus
- Laravel + Inertia + React specific
- Manual code review processes
- Framework-specific automation

### v2.0 Focus  
- **Universal** - Any tech stack
- **Automated** - CI/CD ready
- **Comprehensive** - Full coverage
- **Scalable** - Plugin architecture planned

---

## Common Questions

### Q: Do I need to update my code?
**A:** No, v2.0 is fully backward compatible.

### Q: Will old workflows still work?
**A:** Yes, all v1.0 workflows continue to function.

### Q: Should I use new universal workflows?
**A:** Recommended but optional. They provide more comprehensive automation.

### Q: Can I mix v1.0 and v2.0 features?
**A:** Yes, absolutely! Use what fits your needs.

### Q: When should I upgrade Next.js to v16?
**A:** When your project is ready. v2.0 supports both Next.js 15 and 16.

---

## Rollback Plan

If you encounter any issues:

1. **Revert to v1.0**
   ```bash
   cd .agent
   git checkout v1.0.0
   ```

2. **Report Issue**
   - Document the problem
   - Share error messages
   - Describe your environment

3. **Temporary Workaround**
   - Use v1.0 workflows
   - Skip new features temporarily

**Note:** Very unlikely to be needed - no known issues.

---

## Next Steps

1. ✅ Update to v2.0
2. ✅ Read INTEGRATION-GUIDE.md
3. ✅ Try `/code-review-automation` on one project
4. ✅ Gradually adopt new features
5. ✅ Monitor CHANGELOG.md for future updates

---

## Support

- **Documentation:** `.agent/INTEGRATION-GUIDE.md`
- **Changelog:** `.agent/CHANGELOG.md`
- **Standards:** `.agent/rules/universal-code-standards.md`

---

**Welcome to .agent v2.0!** 🎉

**Migration Difficulty:** ⭐☆☆☆☆ (Very Easy)  
**Time Required:** < 5 minutes  
**Risk Level:** None (backward compatible)

---
description: Phân tích ý tưởng, so sánh giải pháp
---

# /brainstorm - Structured Idea Exploration

// turbo-all

**Agent:** `project-planner`  
**Skills:** `brainstorming, plan-writing`

$ARGUMENTS

---

## Purpose

This command activates BRAINSTORM mode for structured idea exploration. Use when you need to explore options before committing to an implementation.

---

## Behavior

When `/brainstorm` is triggered:

1. **Understand the goal**
   - What problem are we solving?
   - Who is the user?
   - What constraints exist?

2. **Generate options**
   - Provide at least 3 different approaches
   - Each with pros and cons
   - Consider unconventional solutions

3. **Compare and recommend**
   - Summarize tradeoffs
   - Give a recommendation with reasoning

---

## Output Format

```markdown
## 🧠 Brainstorm: [Topic]

### Context
[Brief problem statement]

---

### Option A: [Name]
[Description]

✅ **Pros:**
- [benefit 1]
- [benefit 2]

❌ **Cons:**
- [drawback 1]

📊 **Effort:** Low | Medium | High

---

### Option B: [Name]
[Description]

✅ **Pros:**
- [benefit 1]

❌ **Cons:**
- [drawback 1]
- [drawback 2]

📊 **Effort:** Low | Medium | High

---

### Option C: [Name]
[Description]

✅ **Pros:**
- [benefit 1]

❌ **Cons:**
- [drawback 1]

📊 **Effort:** Low | Medium | High

---

## 💡 Recommendation

**Option [X]** because [reasoning].

What direction would you like to explore?
```

---

## Examples

```
/brainstorm authentication system
/brainstorm state management for complex form
/brainstorm database schema for social app
/brainstorm caching strategy
```

---

## Key Principles

- **No code** - this is about ideas, not implementation
- **Visual when helpful** - use diagrams for architecture
- **Honest tradeoffs** - don't hide complexity
- **Defer to user** - present options, let them decide

---

## ? Brainstorm Checklist

- [ ] Problem clearly defined
- [ ] At least 3 options explored
- [ ] Each option has pros/cons/effort
- [ ] Tradeoffs compared honestly
- [ ] Clear recommendation given
- [ ] User asked to choose direction

---

## Troubleshooting

| V?n d? | Gi?i ph�p |
|---------|-----------|
| Options too similar | Push for more creative/unconventional approach |
| User can't decide | Create decision matrix with weighted criteria |
| Scope too broad | Break into sub-problems, brainstorm each |

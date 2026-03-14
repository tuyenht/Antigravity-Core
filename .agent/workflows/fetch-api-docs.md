---
description: "Truy xuất tài liệu API bên ngoài qua Context Hub (chub) thay vì đoán từ training data."
---

# Fetch API Docs via Context Hub

// turbo-all

**Agent:** Any agent needing third-party API documentation
**Skills:** `context-hub-bridge`

$ARGUMENTS

---

## Purpose

This workflow activates when an agent needs **current, curated documentation** for a third-party API, SDK, or library. Instead of guessing from training data (which may be outdated or incorrect), the agent fetches versioned, community-maintained docs via Context Hub.

---

## Prerequisites

Context Hub CLI must be installed globally:

// turbo
```bash
npm install -g @aisuite/chub
```

Verify installation:

// turbo
```bash
chub --version
```

---

## Workflow Steps

### Step 1: Detect project language

// turbo
```bash
test -f package.json && echo "js" || (test -f requirements.txt && echo "py" || echo "unknown")
```

### Step 2: Search for documentation

```bash
chub search "<library or API name>" --json
```

Pick the best-matching `id` from results (e.g., `openai/chat`, `stripe/api`).

> If no results found, try broader terms or run `chub search` without query to list everything available.

### Step 3: Fetch the docs (incremental)

```bash
chub get <id> --lang <py|js|ts>
```

- Omit `--lang` if only one language variant exists (auto-selected).
- **Do NOT use `--full`** unless you need comprehensive reference (wastes tokens).
- Use `--file <path>` for specific sections shown in footer.

### Step 4: Use the docs to write code

Read fetched content. Use the documented API shapes — do **NOT** rely on memorized/training knowledge. If the doc mentions specific version requirements, follow them.

### Step 5: Annotate discoveries

If you discovered anything not in the doc (gotcha, workaround, version quirk):

```bash
chub annotate <id> "Concise, actionable note about the discovery"
```

Keep annotations under 200 characters. They persist across sessions and auto-appear on future fetches.

### Step 6: Rate the documentation (ask user first)

> [!IMPORTANT]
> Always ask the user before sending feedback. Never auto-send.

```bash
chub feedback <id> up                          # doc worked well
chub feedback <id> down --label outdated       # doc needs updating
```

Available labels: `outdated`, `inaccurate`, `incomplete`, `wrong-examples`, `wrong-version`, `poorly-structured`, `accurate`, `well-structured`, `helpful`, `good-examples`.

---

## Incremental Fetch (Advanced)

When a doc has reference files, fetch only what you need:

```bash
# Fetch a specific section
chub get <id> --file references/webhooks.md

# Fetch everything (use sparingly — wastes 60-80% tokens)
chub get <id> --full

# Save to a local file for later reference
chub get <id> --lang py -o .context/api-docs.md

# Multiple docs at once
chub get openai/chat stripe/api --lang py -o .context/
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `chub` command not found | `npm install -g @aisuite/chub` |
| No results for search | Try broader terms or `chub search` (no query) for full list |
| Multiple languages prompt | Add `--lang py` or `--lang js` to specify |
| Registry outdated | `chub update --force` |
| Need offline access | `chub update --full` (pre-caches everything) |
| Network timeout | Check internet connection; use cached content if available |
| Wrong doc version | Use `--version <semver>` to select specific SDK version |

---

**Created:** 2026-03-12
**Version:** 1.1
**Purpose:** Structured workflow for fetching curated API docs via Context Hub

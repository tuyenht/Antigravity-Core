# Context Hub MCP Server Configuration

> **Purpose:** Enable agents to access curated API docs via MCP protocol without CLI.

## Configuration

Add the following to your `mcp_config.json`:

```json
{
  "mcpServers": {
    "context-hub": {
      "command": "npx",
      "args": ["-y", "@aisuite/chub", "mcp"],
      "env": {}
    }
  }
}
```

### Windows (Absolute Path)

If `npx` is not in PATH for the agent process:

```json
{
  "mcpServers": {
    "context-hub": {
      "command": "C:/Program Files/nodejs/npx.cmd",
      "args": ["-y", "@aisuite/chub", "mcp"],
      "env": {}
    }
  }
}
```

## Available MCP Tools

| Tool | Parameters | Purpose |
|------|-----------|---------|
| `chub_search` | `query?`, `tags?`, `lang?`, `limit?` | Search docs and skills |
| `chub_get` | `id`, `lang?`, `version?`, `full?`, `file?` | Fetch doc/skill content |
| `chub_list` | `tags?`, `lang?`, `limit?` | List all entries |
| `chub_annotate` | `id?`, `note?`, `clear?`, `list?` | Manage local annotations |
| `chub_feedback` | `id`, `rating`, `comment?`, `labels?` | Rate doc quality |

## Available MCP Resources

| Resource | URI | Purpose |
|----------|-----|---------|
| Registry | `chub://registry` | Full registry of docs/skills as JSON |

## Local Configuration

Create `~/.chub/config.yaml` for custom settings:

```yaml
sources:
  - name: community
    url: https://cdn.aichub.org/v1
  # Add local/team docs:
  # - name: my-team
  #   path: /path/to/local/docs/dist

source: "official,maintainer,community"   # trust policy
refresh_interval: 86400                   # cache TTL (24h)
telemetry: true                           # anonymous usage analytics
feedback: true                            # allow quality ratings
```

## Verification

After configuration, test with:

```bash
# CLI test
chub search openai

# MCP test (via agent)
# Agent should be able to call chub_search and chub_get tools
```

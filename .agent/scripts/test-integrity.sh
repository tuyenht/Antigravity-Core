#!/usr/bin/env bash
# test-integrity.sh — Validate system integrity (counts, versions, stale refs)
# Usage: bash test-integrity.sh

set -euo pipefail

PASS=0
FAIL=0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$AGENT_DIR/.." && pwd)"

echo "🧪 System Integrity Test"
echo "========================"
echo ""

# Helper
check() {
    local name="$1" actual="$2" expected="$3"
    if [ "$actual" = "$expected" ]; then
        echo "  ✅ $name: $actual"
        PASS=$((PASS + 1))
    else
        echo "  ❌ $name: got $actual, expected $expected"
        FAIL=$((FAIL + 1))
    fi
}

# 1. Filesystem counts vs project.json
echo "── Count Sync ──"
FS_SKILLS=$(find "$AGENT_DIR/skills" -maxdepth 1 -type d | tail -n +2 | wc -l | tr -d ' ')
FS_WORKFLOWS=$(find "$AGENT_DIR/workflows" -name '*.md' -type f | wc -l | tr -d ' ')
FS_AGENTS=$(find "$AGENT_DIR/agents" -name '*.md' -type f | wc -l | tr -d ' ')
FS_PIPELINES=$(find "$AGENT_DIR/pipelines" -name '*.md' -type f | wc -l | tr -d ' ')
FS_SCRIPTS=$(find "$AGENT_DIR/scripts" -type f | wc -l | tr -d ' ')

PJ_SKILLS=$(python3 -c "import json; print(json.load(open('$AGENT_DIR/project.json'))['stats']['skills'])")
PJ_WORKFLOWS=$(python3 -c "import json; print(json.load(open('$AGENT_DIR/project.json'))['stats']['workflows'])")
PJ_AGENTS=$(python3 -c "import json; print(json.load(open('$AGENT_DIR/project.json'))['stats']['agents'])")
PJ_PIPELINES=$(python3 -c "import json; print(json.load(open('$AGENT_DIR/project.json'))['stats']['pipelines'])")

check "Skills" "$FS_SKILLS" "$PJ_SKILLS"
check "Workflows" "$FS_WORKFLOWS" "$PJ_WORKFLOWS"
check "Agents" "$FS_AGENTS" "$PJ_AGENTS"
check "Pipelines" "$FS_PIPELINES" "$PJ_PIPELINES"

echo ""
echo "── Version Consistency ──"
VERSION=$(cat "$AGENT_DIR/VERSION" | tr -d '[:space:]')
PJ_VER=$(python3 -c "import json; print(json.load(open('$AGENT_DIR/project.json'))['version'])")
check "VERSION vs project.json" "$PJ_VER" "$VERSION"

echo ""
echo "── Cross-Platform Parity ──"
PS1_COUNT=$(find "$AGENT_DIR/scripts" -name "*.ps1" | wc -l | tr -d ' ')
SH_COUNT=$(find "$AGENT_DIR/scripts" -name "*.sh" | wc -l | tr -d ' ')
echo "  PS1: $PS1_COUNT, SH: $SH_COUNT"
# Every PS1 should have a SH equivalent
MISSING=0
for ps1 in "$AGENT_DIR"/scripts/*.ps1; do
    base=$(basename "$ps1" .ps1)
    if [ ! -f "$AGENT_DIR/scripts/$base.sh" ]; then
        echo "  ❌ Missing Bash: $base.sh"
        MISSING=$((MISSING + 1))
    fi
done
if [ "$MISSING" -eq 0 ]; then
    echo "  ✅ 100% parity ($SH_COUNT/$PS1_COUNT)"
    PASS=$((PASS + 1))
else
    echo "  ❌ $MISSING scripts missing Bash equivalent"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "── Stale Reference Detection ──"
# Check for historically stale counts
STALE=$(grep -rnl '\(22 core\|39 script\|39 total\|39 automation\)' "$PROJECT_ROOT"/*.md "$AGENT_DIR"/*.md "$AGENT_DIR"/docs/**/*.md "$AGENT_DIR/project.json" 2>/dev/null | head -5 || true)
if [ -z "$STALE" ]; then
    echo "  ✅ No stale count references"
    PASS=$((PASS + 1))
else
    echo "  ❌ Stale refs found:"
    echo "$STALE" | while read -r f; do echo "    - $f"; done
    FAIL=$((FAIL + 1))
fi

echo ""
echo "══════════════════════════"
echo "📊 Results: $PASS passed, $FAIL failed"
[ "$FAIL" -gt 0 ] && exit 1
echo "✅ System integrity verified"

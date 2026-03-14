#!/usr/bin/env bash
# update-ui-ux-pro-max.sh — Update UI-UX-Pro-Max skill from upstream
# Bash equivalent of update-ui-ux-pro-max.ps1
# Usage: bash update-ui-ux-pro-max.sh [--auto-commit]

set -euo pipefail

AUTO_COMMIT=false
[[ "${1:-}" == "--auto-commit" ]] && AUTO_COMMIT=true

SCRIPT_DIR=$(dirname "$0")
PROJECT_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     UI-UX-Pro-Max Updater for Antigravity-Core (Bash)     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📁 Project root: $PROJECT_ROOT"

cd "$PROJECT_ROOT"

# Step 1: Check uipro-cli
echo ""
echo "Step 1: Checking uipro-cli..."
if ! command -v uipro &>/dev/null; then
    echo "   Installing uipro-cli..."
    npm install -g uipro-cli
fi

# Step 2: Download
echo ""
echo "Step 2: Downloading from upstream..."
uipro init --ai antigravity || echo "   ⚠️ uipro init failed (may need manual download)"

# Step 3: Merge .shared into .agent/skills
SKILL_PATH="$PROJECT_ROOT/.agent/skills/ui-ux-pro-max"
SHARED_PATH="$PROJECT_ROOT/.shared/ui-ux-pro-max"

echo ""
echo "Step 3: Merging files..."
if [ -d "$SHARED_PATH" ]; then
    [ -d "$SHARED_PATH/data" ] && cp -r "$SHARED_PATH/data/"* "$SKILL_PATH/data/" 2>/dev/null && echo "   ✓ Merged data files"
    [ -d "$SHARED_PATH/scripts" ] && cp -r "$SHARED_PATH/scripts/"* "$SKILL_PATH/scripts/" 2>/dev/null && echo "   ✓ Merged script files"
    rm -rf "$PROJECT_ROOT/.shared"
    echo "   ✓ Removed .shared folder"
else
    echo "   No .shared folder found"
fi

# Step 4: Update workflow paths
echo ""
echo "Step 4: Updating workflow paths..."
WF="$PROJECT_ROOT/.agent/workflows/ui-ux-pro-max.md"
if [ -f "$WF" ]; then
    sed -i.bak 's|\.shared/ui-ux-pro-max|.agent/skills/ui-ux-pro-max|g' "$WF" 2>/dev/null || \
      sed -i '' 's|\.shared/ui-ux-pro-max|.agent/skills/ui-ux-pro-max|g' "$WF"
    rm -f "${WF}.bak"
    echo "   ✓ Updated workflow paths"
fi

# Step 5: Summary
echo ""
echo "Step 5: Verification..."
DATA_COUNT=$(find "$SKILL_PATH/data" -type f 2>/dev/null | wc -l | tr -d ' ')
SCRIPT_COUNT=$(find "$SKILL_PATH/scripts" -type f 2>/dev/null | wc -l | tr -d ' ')
echo "   📊 Data files: $DATA_COUNT"
echo "   📜 Script files: $SCRIPT_COUNT"

# Step 6: Git
echo ""
echo "Step 6: Git status..."
if git status --short 2>/dev/null | head -5; then
    if $AUTO_COMMIT; then
        git add . && git commit -m "⬆️ Update UI-UX-Pro-Max skill" && git push
        echo "   ✓ Committed and pushed!"
    else
        echo '   Run: git add . && git commit -m "⬆️ Update UI-UX-Pro-Max"'
    fi
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     ✅ UI-UX-Pro-Max Update Complete!                      ║"
echo "╚════════════════════════════════════════════════════════════╝"

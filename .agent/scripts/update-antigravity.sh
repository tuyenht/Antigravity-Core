#!/usr/bin/env bash
# update-antigravity.sh — Update Antigravity-Core in current project
# Bash equivalent of update-antigravity.ps1
# Usage: bash update-antigravity.sh [--force]

set -euo pipefail

REPO_ARCHIVE="https://github.com/tuyenht/Antigravity-Core/archive/refs/heads/main.zip"

PROJECT_PATH=$(pwd)
AGENT_PATH="$PROJECT_PATH/.agent"

# Parse arguments
FORCE=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --force|-f) FORCE=true; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║          ANTIGRAVITY-CORE UPDATER v1.0 (Bash)             ║"
echo "║    AI-Native Development Operating System                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Check .agent exists
if [ ! -d "$AGENT_PATH" ]; then
    echo "❌ No .agent folder found. Run install-antigravity.sh first."
    exit 1
fi

CURRENT_VERSION="unknown"
if [ -f "$AGENT_PATH/VERSION" ]; then
    CURRENT_VERSION=$(cat "$AGENT_PATH/VERSION" | tr -d '[:space:]')
fi

echo "📁 Project: $PROJECT_PATH"
echo "📦 Current version: $CURRENT_VERSION"
echo ""

# Step 2: Backup memory and project.json
echo "Step 1: Backing up project data..."
BACKUP_DIR=$(mktemp -d)
TEMP_DIR=$(mktemp -d)

cleanup() { rm -rf "$TEMP_DIR" "$BACKUP_DIR"; }
trap cleanup EXIT

if [ -d "$AGENT_PATH/memory" ]; then
    cp -r "$AGENT_PATH/memory" "$BACKUP_DIR/memory"
    echo "   ✓ Backed up memory/"
fi

if [ -f "$AGENT_PATH/project.json" ]; then
    cp "$AGENT_PATH/project.json" "$BACKUP_DIR/project.json"
    echo "   ✓ Backed up project.json"
fi

# Step 3: Download latest
echo ""
echo "Step 2: Downloading latest version..."
ZIP_PATH="$TEMP_DIR/antigravity-core.zip"
curl -sL "$REPO_ARCHIVE" -o "$ZIP_PATH"
echo "   ✓ Downloaded successfully"

# Step 4: Extract
echo ""
echo "Step 3: Extracting..."
EXTRACT_PATH="$TEMP_DIR/extracted"
mkdir -p "$EXTRACT_PATH"
unzip -q "$ZIP_PATH" -d "$EXTRACT_PATH"

SOURCE_DIR=$(find "$EXTRACT_PATH" -maxdepth 1 -type d | tail -n 1)
SOURCE_AGENT="$SOURCE_DIR/.agent"

NEW_VERSION="unknown"
if [ -f "$SOURCE_AGENT/VERSION" ]; then
    NEW_VERSION=$(cat "$SOURCE_AGENT/VERSION" | tr -d '[:space:]')
fi
echo "   ✓ Extracted (version: $NEW_VERSION)"

# Step 5: Version check
if [ "$CURRENT_VERSION" = "$NEW_VERSION" ] && [ "$FORCE" = false ]; then
    read -rp "ℹ️  Already at latest ($CURRENT_VERSION). Force update? (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "   Update skipped."
        exit 0
    fi
fi

# Step 6: Replace .agent
echo ""
echo "Step 4: Updating .agent folder..."
rm -rf "$AGENT_PATH"
cp -r "$SOURCE_AGENT" "$AGENT_PATH"
echo "   ✓ Installed new version"

# Step 7: Restore backups
echo ""
echo "Step 5: Restoring project data..."
if [ -d "$BACKUP_DIR/memory" ]; then
    cp -r "$BACKUP_DIR/memory" "$AGENT_PATH/memory"
    echo "   ✓ Restored memory/"
fi
if [ -f "$BACKUP_DIR/project.json" ]; then
    cp "$BACKUP_DIR/project.json" "$AGENT_PATH/project.json"
    echo "   ✓ Restored project.json"
fi

# Step 8: Verification
echo ""
echo "Step 6: Verification..."
WORKFLOWS=$(find "$AGENT_PATH/workflows" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
SKILLS=$(find "$AGENT_PATH/skills" -maxdepth 1 -type d 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')
AGENTS=$(find "$AGENT_PATH/agents" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

echo "   📊 Workflows: $WORKFLOWS"
echo "   🎯 Skills: $SKILLS"
echo "   🤖 Agents: $AGENTS"
echo "   📦 Version: $NEW_VERSION"

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║    ✅ ANTIGRAVITY-CORE UPDATED SUCCESSFULLY!               ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📦 Updated: $CURRENT_VERSION → $NEW_VERSION"
echo "📁 Location: $AGENT_PATH"
echo ""

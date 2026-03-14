#!/usr/bin/env bash
# install-antigravity.sh — Install Antigravity-Core to a project
# Bash equivalent of install-antigravity.ps1
# Usage: bash install-antigravity.sh [--force] [--path /target/dir]

set -euo pipefail

REPO_URL="https://github.com/tuyenht/Antigravity-Core"
REPO_ARCHIVE="https://github.com/tuyenht/Antigravity-Core/archive/refs/heads/main.zip"

# Parse arguments
PROJECT_PATH="."
FORCE=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --force|-f) FORCE=true; shift ;;
        --path|-p) PROJECT_PATH="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

PROJECT_PATH=$(cd "$PROJECT_PATH" && pwd)
AGENT_PATH="$PROJECT_PATH/.agent"

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║          ANTIGRAVITY-CORE INSTALLER v1.1 (Bash)           ║"
echo "║    AI-Native Development Operating System                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📁 Target: $PROJECT_PATH"
echo "🔗 Source: $REPO_URL"
echo ""

# Pre-flight: check dependencies
for cmd in curl unzip; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "❌ Required command not found: $cmd"
        exit 1
    fi
done

# Step 1: Check if .agent already exists
if [ -d "$AGENT_PATH" ]; then
    if [ "$FORCE" = true ]; then
        echo "⚠️  Existing .agent found. Removing (--force)..."
        rm -rf "$AGENT_PATH"
    else
        read -rp "⚠️  .agent folder already exists. Overwrite? (y/N): " confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            echo "❌ Installation cancelled."
            exit 0
        fi
        rm -rf "$AGENT_PATH"
    fi
fi

# Step 2: Download from GitHub
TEMP_DIR=$(mktemp -d)
ZIP_PATH="$TEMP_DIR/antigravity-core.zip"

cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT

echo "Step 1: Downloading Antigravity-Core..."
curl -sL "$REPO_ARCHIVE" -o "$ZIP_PATH"
echo "   ✓ Downloaded successfully"

# Step 3: Extract
echo "Step 2: Extracting files..."
EXTRACT_PATH="$TEMP_DIR/extracted"
mkdir -p "$EXTRACT_PATH"
unzip -q "$ZIP_PATH" -d "$EXTRACT_PATH"

SOURCE_DIR=$(find "$EXTRACT_PATH" -maxdepth 1 -type d | tail -n 1)
SOURCE_AGENT="$SOURCE_DIR/.agent"

if [ ! -d "$SOURCE_AGENT" ]; then
    echo "❌ .agent folder not found in downloaded archive"
    exit 1
fi
echo "   ✓ Extracted successfully"

# Step 4: Copy to project
echo "Step 3: Installing to project..."
cp -r "$SOURCE_AGENT" "$AGENT_PATH"

# Also copy docs folder
SOURCE_DOCS="$SOURCE_DIR/docs"
TARGET_DOCS="$PROJECT_PATH/docs"
if [ -d "$SOURCE_DOCS" ] && [ ! -d "$TARGET_DOCS" ]; then
    cp -r "$SOURCE_DOCS" "$TARGET_DOCS"
    echo "   ✓ Copied docs folder"
fi
echo "   ✓ Installed successfully"

# Step 5: Verification
echo ""
echo "Step 4: Verification..."
WORKFLOWS=$(find "$AGENT_PATH/workflows" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
SKILLS=$(find "$AGENT_PATH/skills" -maxdepth 1 -type d 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')
AGENTS=$(find "$AGENT_PATH/agents" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

echo "   📊 Workflows: $WORKFLOWS"
echo "   🎯 Skills: $SKILLS"
echo "   🤖 Agents: $AGENTS"

if [ -f "$AGENT_PATH/VERSION" ]; then
    VERSION=$(cat "$AGENT_PATH/VERSION" | tr -d '[:space:]')
    echo "   📦 Version: $VERSION"
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║    ✅ ANTIGRAVITY-CORE INSTALLED SUCCESSFULLY!             ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📁 Installed to: $AGENT_PATH"
echo ""
echo "🚀 Quick Start:"
echo "   1. Read: .agent/GEMINI.md (AI instructions)"
echo "   2. Run:  bash .agent/scripts/health-check.sh"
echo ""

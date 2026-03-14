#!/usr/bin/env bash
# update-global.sh — Update global Antigravity-Core installation
# Bash equivalent of update-global.ps1
# Usage: bash update-global.sh

set -euo pipefail

REPO_ARCHIVE="https://github.com/tuyenht/Antigravity-Core/archive/refs/heads/main.zip"

INSTALL_PATH="${ANTIGRAVITY_HOME:-$HOME/.antigravity-core}"

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║      ANTIGRAVITY-CORE GLOBAL UPDATER v1.0 (Bash)          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

if [ ! -d "$INSTALL_PATH" ]; then
    echo "❌ Antigravity-Core not found at: $INSTALL_PATH"
    echo "   Run install-global.sh first."
    exit 1
fi

CURRENT_VERSION="unknown"
if [ -f "$INSTALL_PATH/.agent/VERSION" ]; then
    CURRENT_VERSION=$(cat "$INSTALL_PATH/.agent/VERSION" | tr -d '[:space:]')
fi

echo "📁 Location: $INSTALL_PATH"
echo "📦 Current version: $CURRENT_VERSION"
echo ""

TEMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT

echo "Step 1: Downloading latest version..."
ZIP_PATH="$TEMP_DIR/antigravity-core.zip"
curl -sL "$REPO_ARCHIVE" -o "$ZIP_PATH"
echo "   ✓ Downloaded"

echo "Step 2: Extracting..."
EXTRACT_PATH="$TEMP_DIR/extracted"
mkdir -p "$EXTRACT_PATH"
unzip -q "$ZIP_PATH" -d "$EXTRACT_PATH"

SOURCE_DIR=$(find "$EXTRACT_PATH" -maxdepth 1 -type d | tail -n 1)

NEW_VERSION="unknown"
if [ -f "$SOURCE_DIR/.agent/VERSION" ]; then
    NEW_VERSION=$(cat "$SOURCE_DIR/.agent/VERSION" | tr -d '[:space:]')
fi
echo "   ✓ New version: $NEW_VERSION"

if [ "$CURRENT_VERSION" = "$NEW_VERSION" ]; then
    read -rp "ℹ️  Already at latest ($CURRENT_VERSION). Force update? (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "   Update skipped."
        exit 0
    fi
fi

echo "Step 3: Updating files..."
rm -rf "$INSTALL_PATH"
mv "$SOURCE_DIR" "$INSTALL_PATH"

# Regenerate shell profile setup
PROFILE_SETUP="$INSTALL_PATH/setup-profile.sh"
cat > "$PROFILE_SETUP" << 'PROFILE_EOF'
# ANTIGRAVITY-CORE GLOBAL SETUP
export ANTIGRAVITY_HOME="INSTALL_PATH_PLACEHOLDER"
export PATH="$ANTIGRAVITY_HOME/.agent/scripts:$PATH"
PROFILE_EOF
sed -i "s|INSTALL_PATH_PLACEHOLDER|$INSTALL_PATH|g" "$PROFILE_SETUP" 2>/dev/null || \
  sed -i '' "s|INSTALL_PATH_PLACEHOLDER|$INSTALL_PATH|g" "$PROFILE_SETUP"

echo "   ✓ Updated successfully"

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║    ✅ GLOBAL UPDATE COMPLETE!                              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📦 Updated: $CURRENT_VERSION → $NEW_VERSION"
echo ""
echo "💡 To update individual projects, run in each project:"
echo "   bash .agent/scripts/update-antigravity.sh"
echo ""

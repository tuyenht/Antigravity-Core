#!/usr/bin/env bash
# Install Antigravity-Core globally (Bash equivalent of install-global.ps1)
# Usage: bash .agent/scripts/install-global.sh [TARGET_DIR]

set -euo pipefail

REPO="https://github.com/tuyenht/Antigravity-Core.git"
TARGET="${1:-$HOME/.antigravity-core}"

echo "========================================="
echo "  Antigravity-Core Global Installer"
echo "========================================="
echo ""

if [[ -d "$TARGET/.agent" ]]; then
  echo "Updating existing installation at $TARGET..."
  cd "$TARGET"
  git pull --rebase
else
  echo "Installing to $TARGET..."
  git clone "$REPO" "$TARGET"
fi

echo ""
echo "✅ Antigravity-Core installed at: $TARGET"
echo ""
echo "Usage: Copy .agent/ folder to your project root:"
echo "  cp -r $TARGET/.agent /path/to/your/project/"

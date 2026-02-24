#!/usr/bin/env bash
# Antigravity-Core Version Bump Script
# Usage: bash .agent/scripts/bump-version.sh 4.1.0 [--dry-run]

set -euo pipefail

VERSION="${1:-}"
DRY_RUN=false
[[ "${2:-}" == "--dry-run" ]] && DRY_RUN=true

if [[ -z "$VERSION" ]] || ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "[ERROR] Usage: $0 X.Y.Z [--dry-run]"
  exit 1
fi

TODAY=$(date +%Y-%m-%d)

echo "=========================================="
echo "  Antigravity-Core Version Bump"
echo "  Target: $VERSION"
$DRY_RUN && echo "  Mode: DRY RUN"
echo "=========================================="
echo ""

update_file() {
  local file="$1" pattern="$2" replacement="$3"
  if [[ ! -f "$file" ]]; then
    echo "[SKIP] $file (not found)"
    return
  fi
  if $DRY_RUN; then
    echo "[WOULD UPDATE] $file"
  else
    sed -i.bak -E "s/$pattern/$replacement/g" "$file" && rm -f "$file.bak"
    echo "[UPDATED] $file"
  fi
}

# Version updates
echo "$VERSION" > .agent/VERSION && echo "[UPDATED] .agent/VERSION"
update_file ".agent/GEMINI.md"            "Version [0-9]+\.[0-9]+\.[0-9]+"         "Version $VERSION"
update_file ".agent/ARCHITECTURE.md"      "Version:\*\* [0-9]+\.[0-9]+\.[0-9]+"   "Version:** $VERSION"
update_file ".agent/rules/RULES-INDEX.md" "Version:\*\* [0-9]+\.[0-9]+\.[0-9]+"   "Version:** $VERSION"

# project.json (use python for JSON safety)
if command -v python3 &>/dev/null && [[ -f ".agent/project.json" ]]; then
  python3 -c "
import json, sys
with open('.agent/project.json','r') as f: d=json.load(f)
d['version']='$VERSION'
d['last_updated']='$TODAY'
d['foundation']['standards']['version']='$VERSION'
with open('.agent/project.json','w') as f: json.dump(d,f,indent=2)
" && echo "[UPDATED] .agent/project.json"
fi

# Date updates
update_file ".agent/ARCHITECTURE.md"      "Last Updated:\*\* [0-9]{4}-[0-9]{2}-[0-9]{2}"  "Last Updated:** $TODAY"
update_file ".agent/rules/RULES-INDEX.md"  "Updated:\*\* [0-9]{4}-[0-9]{2}-[0-9]{2}"       "Updated:** $TODAY"

echo ""
echo "=========================================="
echo "  Done! All files updated to $VERSION"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Update CHANGELOG.md"
echo "  2. git add -A && git commit -m \"release: v$VERSION\""
echo "  3. git tag v$VERSION && git push --tags"

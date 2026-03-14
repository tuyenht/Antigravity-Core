#!/usr/bin/env bash
# Antigravity-Core Version Bump Script (v2.0)
# Usage: bash .agent/scripts/bump-version.sh 5.1.0 [--dry-run]
# Automatically updates ALL version references across the ENTIRE system.
#
# Coverage:
#   - Core: VERSION, GEMINI.md, ARCHITECTURE.md, project.json, reference-catalog.md
#   - Systems: All 6 system files (agent-registry, orchestration-engine, etc.)
#   - Templates: agent-template-v5, AGENT-CREATION-GUIDE, project-bootstrap, etc.
#   - Docs: All process, agent, skill, script, workflow, and system docs
#   - Rules: standards/supply-chain-security, standards/frameworks/*

set -euo pipefail

VERSION="${1:-}"
DRY_RUN=false
[[ "${2:-}" == "--dry-run" ]] && DRY_RUN=true

if [[ -z "$VERSION" ]] || ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "[ERROR] Usage: $0 X.Y.Z [--dry-run]"
  exit 1
fi

TODAY=$(date +%Y-%m-%d)
UPDATED=0

echo "=========================================="
echo "  Antigravity-Core Version Bump v2.0"
echo "  Target: $VERSION"
$DRY_RUN && echo "  Mode: DRY RUN"
echo "=========================================="
echo ""

update_file() {
  local file="$1" pattern="$2" replacement="$3"
  if [[ ! -f "$file" ]]; then
    echo "  [SKIP] $file (not found)"
    return
  fi
  if $DRY_RUN; then
    echo "  [WOULD UPDATE] $file"
  else
    sed -i.bak -E "s/$pattern/$replacement/g" "$file" && rm -f "$file.bak"
    echo "  [UPDATED] $file"
  fi
  UPDATED=$((UPDATED + 1))
}

# ============================================
# PHASE 1: Core files
# ============================================
echo "--- Phase 1: Core Files ---"

echo "$VERSION" > .agent/VERSION && echo "  [UPDATED] .agent/VERSION"
UPDATED=$((UPDATED + 1))

update_file ".agent/GEMINI.md"            "Version [0-9]+\.[0-9]+\.[0-9]+"         "Version $VERSION"
update_file ".agent/ARCHITECTURE.md"      "Version:\*\* [0-9]+\.[0-9]+\.[0-9]+"   "Version:** $VERSION"
update_file ".agent/reference-catalog.md" "Version:\*\* [0-9]+\.[0-9]+\.[0-9]+"   "Version:** $VERSION"

# project.json (use python for JSON safety)
if command -v python3 &>/dev/null && [[ -f ".agent/project.json" ]]; then
  if $DRY_RUN; then
    echo "  [WOULD UPDATE] .agent/project.json"
  else
    python3 -c "
import json
with open('.agent/project.json','r') as f: d=json.load(f)
d['version']='$VERSION'
d['last_updated']='$TODAY'
if 'foundation' in d and 'standards' in d['foundation']:
    d['foundation']['standards']['version']='$VERSION'
with open('.agent/project.json','w') as f: json.dump(d,f,indent=2,ensure_ascii=False)
" && echo "  [UPDATED] .agent/project.json"
  fi
  UPDATED=$((UPDATED + 1))
fi

# ============================================
# PHASE 2: Broad scan (systems, docs, templates, rules)
# ============================================
echo ""
echo "--- Phase 2: Broad Scan ---"

SCAN_DIRS=".agent/systems .agent/templates .agent/docs .agent/rules/standards"

for dir in $SCAN_DIRS; do
  [[ ! -d "$dir" ]] && continue
  while IFS= read -r -d '' mdfile; do
    changed=false

    # Pattern 1: **Version:** X.Y.Z
    if grep -qE '\*\*Version:\*\*\s*[0-9]+\.[0-9]+\.[0-9]+' "$mdfile"; then
      sed -i.bak -E "s/(\*\*Version:\*\*\s*)[0-9]+\.[0-9]+\.[0-9]+/\1$VERSION/g" "$mdfile" && rm -f "$mdfile.bak"
      changed=true
    fi

    # Pattern 2: Antigravity-Core: vX.Y.Z or Antigravity-Core vX.Y.Z
    if grep -qE 'Antigravity-Core[:\s]+v?[0-9]+\.[0-9]+\.[0-9]+' "$mdfile"; then
      sed -i.bak -E "s/(Antigravity-Core[: ]+v?)[0-9]+\.[0-9]+\.[0-9]+/\1$VERSION/g" "$mdfile" && rm -f "$mdfile.bak"
      changed=true
    fi

    # Pattern 3: **System:** Antigravity-Core vX.Y.Z
    if grep -qE '\*\*System:\*\*\s*Antigravity-Core\s+v?[0-9]+\.[0-9]+\.[0-9]+' "$mdfile"; then
      sed -i.bak -E "s/(\*\*System:\*\*\s*Antigravity-Core\s+v?)[0-9]+\.[0-9]+\.[0-9]+/\1$VERSION/g" "$mdfile" && rm -f "$mdfile.bak"
      changed=true
    fi

    if $changed; then
      if $DRY_RUN; then
        echo "  [WOULD UPDATE] $mdfile"
      else
        echo "  [UPDATED] $mdfile"
      fi
      UPDATED=$((UPDATED + 1))
    fi
  done < <(find "$dir" -name "*.md" -type f -print0)
done

# ============================================
# PHASE 3: Date updates
# ============================================
echo ""
echo "--- Phase 3: Date Updates ---"
update_file ".agent/ARCHITECTURE.md"      "Last Updated:\*\* [0-9]{4}-[0-9]{2}-[0-9]{2}"  "Last Updated:** $TODAY"
update_file ".agent/reference-catalog.md" "Updated:\*\* [0-9]{4}-[0-9]{2}-[0-9]{2}"       "Updated:** $TODAY"

echo ""
echo "=========================================="
echo "  Done! $UPDATED files updated to $VERSION"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Update CHANGELOG.md"
echo "  2. git add -A && git commit -m \"release: v$VERSION\""
echo "  3. git tag v$VERSION && git push --tags"

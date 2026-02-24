#!/usr/bin/env bash
# Validate .agent compliance (Bash equivalent of validate-compliance.ps1)
# Usage: bash .agent/scripts/validate-compliance.sh

set -euo pipefail

PASS=0; FAIL=0

check() {
  local msg="$1" status="$2"
  if [[ "$status" == "PASS" ]]; then
    ((PASS++))
    printf "\033[32m[OK]\033[0m %s\n" "$msg"
  else
    ((FAIL++))
    printf "\033[31m[XX]\033[0m %s\n" "$msg"
  fi
}

echo "========================================="
echo "  .agent COMPLIANCE VALIDATOR (bash)"
echo "========================================="
echo ""

# 1. All agents reference STANDARDS.md
echo "1. Agent compliance..."
for agent in .agent/agents/*.md; do
  name=$(basename "$agent" .md)
  if grep -q "STANDARDS\|Golden Rule" "$agent" 2>/dev/null; then
    check "$name: STANDARDS ref" "PASS"
  else
    check "$name: Missing STANDARDS ref" "FAIL"
  fi
done

# 2. All skills have SKILL.md
echo ""
echo "2. Skill completeness..."
for skill_dir in .agent/skills/*/; do
  skill=$(basename "$skill_dir")
  [[ -f "$skill_dir/SKILL.md" ]] \
    && check "$skill: SKILL.md" "PASS" \
    || check "$skill: Missing SKILL.md" "FAIL"
done

# 3. Workflow frontmatter
echo ""
echo "3. Workflow format..."
for wf in .agent/workflows/*.md; do
  name=$(basename "$wf" .md)
  if head -1 "$wf" | grep -q "^---" 2>/dev/null; then
    check "$name: frontmatter" "PASS"
  else
    check "$name: Missing frontmatter" "FAIL"
  fi
done

# Summary
echo ""
echo "========================================="
TOTAL=$((PASS + FAIL))
RATE=$((PASS * 100 / (TOTAL > 0 ? TOTAL : 1)))
echo "Passed: $PASS/$TOTAL ($RATE%)"
[[ $FAIL -eq 0 ]] && echo "✅ ALL COMPLIANT" || echo "❌ $FAIL issues found"

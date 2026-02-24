#!/usr/bin/env bash
# .agent System Health Check (Bash equivalent of health-check.ps1)
# Usage: bash .agent/scripts/health-check.sh [-v]

set -euo pipefail

VERBOSE=false
[[ "${1:-}" == "-v" ]] && VERBOSE=true

PASS=0; FAIL=0; TOTAL=0

check() {
  local msg="$1" status="$2"
  ((TOTAL++))
  if [[ "$status" == "PASS" ]]; then
    ((PASS++))
    printf "\033[32m[OK]\033[0m %s\n" "$msg"
  elif [[ "$status" == "FAIL" ]]; then
    ((FAIL++))
    printf "\033[31m[XX]\033[0m %s\n" "$msg"
  else
    printf "\033[33m[--]\033[0m %s\n" "$msg"
  fi
}

echo "========================================="
echo "  .agent SYSTEM HEALTH CHECK (bash)"
echo "========================================="
echo ""

# 1. Core Files
echo "1. Checking core files..."
for f in ".agent/rules/STANDARDS.md" ".agent/templates/agent-template-v4.md" \
         ".agent/systems/rba-validator.md" ".agent/examples/rba-examples.md" \
         ".agent/project.json"; do
  [[ -f "$f" ]] && check "Found: $f" "PASS" || check "Missing: $f" "FAIL"
done

# 2. Agents count
echo ""
echo "2. Checking agents..."
AGENT_COUNT=$(find .agent/agents -name "*.md" 2>/dev/null | wc -l)
[[ $AGENT_COUNT -eq 27 ]] && check "Agents: $AGENT_COUNT/27" "PASS" || check "Agents: $AGENT_COUNT/27" "FAIL"

# 3. Skills count
echo ""
echo "3. Checking skills..."
SKILL_COUNT=$(find .agent/skills -maxdepth 1 -type d 2>/dev/null | tail -n +2 | wc -l)
check "Skills: $SKILL_COUNT directories" "PASS"

# 4. project.json valid
echo ""
echo "4. Checking project.json..."
if command -v python3 &>/dev/null; then
  python3 -c "import json; json.load(open('.agent/project.json'))" 2>/dev/null \
    && check "project.json: valid JSON" "PASS" \
    || check "project.json: invalid JSON" "FAIL"
else
  check "project.json: python3 not available for validation" "WARN"
fi

# 5. Version consistency
echo ""
echo "5. Checking version..."
VERSION=$(cat .agent/VERSION 2>/dev/null || echo "unknown")
check "VERSION: $VERSION" "PASS"

# Summary
echo ""
echo "========================================="
echo "  HEALTH CHECK SUMMARY"
echo "========================================="
echo ""
RATE=$((PASS * 100 / (TOTAL > 0 ? TOTAL : 1)))
echo "Total: $TOTAL | Passed: $PASS | Failed: $FAIL | Rate: ${RATE}%"
[[ $FAIL -eq 0 ]] && echo "Status: HEALTHY" || echo "Status: DEGRADED"

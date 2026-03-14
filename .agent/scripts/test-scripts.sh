#!/usr/bin/env bash
# test-scripts.sh — Validate all .sh scripts have correct syntax
# Usage: bash test-scripts.sh [--verbose]

set -euo pipefail

VERBOSE=false
[[ "${1:-}" == "--verbose" || "${1:-}" == "-v" ]] && VERBOSE=true

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PASS=0
FAIL=0
ERRORS=()

echo "🧪 Bash Script Syntax Test"
echo "=========================="
echo ""

# Test all .sh scripts in scripts/ directory
for script in "$SCRIPT_DIR"/*.sh; do
    name=$(basename "$script")
    
    # 1. Syntax check (bash -n = parse without executing)
    if bash -n "$script" 2>/dev/null; then
        $VERBOSE && echo "  ✅ $name: syntax OK"
        PASS=$((PASS + 1))
    else
        echo "  ❌ $name: SYNTAX ERROR"
        bash -n "$script" 2>&1 | head -3
        FAIL=$((FAIL + 1))
        ERRORS+=("$name: syntax error")
        continue
    fi
    
    # 2. Shebang check
    if head -1 "$script" | grep -q "^#!/usr/bin/env bash"; then
        $VERBOSE && echo "  ✅ $name: shebang OK"
        PASS=$((PASS + 1))
    else
        echo "  ❌ $name: missing/wrong shebang"
        FAIL=$((FAIL + 1))
        ERRORS+=("$name: wrong shebang")
    fi
    
    # 3. No Windows line endings (CRLF) check
    if file "$script" 2>/dev/null | grep -q "CRLF"; then
        echo "  ⚠️ $name: has CRLF line endings (run dos2unix)"
        FAIL=$((FAIL + 1))
        ERRORS+=("$name: CRLF endings")
    else
        $VERBOSE && echo "  ✅ $name: line endings OK"
        PASS=$((PASS + 1))
    fi
done

echo ""
echo "📊 Results: $PASS passed, $FAIL failed"

if [ "$FAIL" -gt 0 ]; then
    echo ""
    echo "Failures:"
    for e in "${ERRORS[@]}"; do echo "  - $e"; done
    exit 1
else
    echo "✅ All Bash scripts passed syntax validation"
fi

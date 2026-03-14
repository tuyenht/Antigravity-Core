#!/usr/bin/env bash
# auto-heal.sh — Auto-fix lint, type, and import issues
# Bash equivalent of auto-heal.ps1
# Usage: bash auto-heal.sh [--all|--lint|--types|--imports] [--dry-run]

set -euo pipefail

MODE="all"
DRY_RUN=false
MAX_ITERATIONS=3
while [[ $# -gt 0 ]]; do
    case "$1" in
        --all|-a) MODE="all"; shift ;;
        --lint|-l) MODE="lint"; shift ;;
        --types|-t) MODE="types"; shift ;;
        --imports|-i) MODE="imports"; shift ;;
        --dry-run|-d) DRY_RUN=true; shift ;;
        --help|-h)
            echo "Auto-Healing Script"
            echo "Usage: bash auto-heal.sh [--all|--lint|--types|--imports] [--dry-run]"
            exit 0 ;;
        *) echo "Unknown: $1"; exit 1 ;;
    esac
done

echo "🔧 Auto-Healing Started"
echo "======================="
$DRY_RUN && echo "[DRY RUN MODE — No changes will be made]" && echo ""

TOTAL_FIXED=0

fix_php_lint() {
    echo "🔧 Fixing PHP Lint Issues..."
    if [ -f "./vendor/bin/pint" ]; then
        if $DRY_RUN; then
            echo "  [DRY RUN] Would run: ./vendor/bin/pint"
            ./vendor/bin/pint --test >/dev/null 2>&1 && echo "  ✅ No PHP lint issues" || echo "  ℹ️ PHP lint issues would be fixed"
        else
            echo "  Running Laravel Pint..."
            if ./vendor/bin/pint >/dev/null 2>&1; then
                echo "  ✅ PHP lint issues fixed"; TOTAL_FIXED=$((TOTAL_FIXED + 1))
            else
                echo "  ❌ PHP lint fix failed"
            fi
        fi
    else
        echo "  ⚠️ Laravel Pint not found. Install: composer require laravel/pint --dev"
    fi
}

fix_js_lint() {
    echo "🔧 Fixing JavaScript/TypeScript Lint Issues..."
    if [ -f "./node_modules/.bin/eslint" ]; then
        if $DRY_RUN; then
            echo "  [DRY RUN] Would run: npm run lint -- --fix"
        else
            echo "  Running ESLint with --fix..."
            if npm run lint -- --fix >/dev/null 2>&1; then
                echo "  ✅ JS/TS lint issues fixed"; TOTAL_FIXED=$((TOTAL_FIXED + 1))
            else
                echo "  ⚠️ Some JS/TS lint issues remain"
            fi
        fi
    else
        echo "  ⚠️ ESLint not found. Install: npm install eslint --save-dev"
    fi
}

fix_types() {
    echo "🔧 Checking Type Errors..."
    if [ -f "./vendor/bin/phpstan" ]; then
        if $DRY_RUN; then echo "  [DRY RUN] Would run: ./vendor/bin/phpstan analyse"
        else
            echo "  Running PHPStan..."
            ./vendor/bin/phpstan analyse >/dev/null 2>&1 && echo "  ✅ No PHP type errors" || echo "  ⚠️ PHP type errors found"
        fi
    fi
    if [ -f "./node_modules/.bin/tsc" ]; then
        if $DRY_RUN; then echo "  [DRY RUN] Would run: npx tsc --noEmit"
        else
            echo "  Running TypeScript check..."
            npx tsc --noEmit >/dev/null 2>&1 && echo "  ✅ No TypeScript errors" || echo "  ⚠️ TypeScript errors found"
        fi
    fi
}

# Run healing iterations
for ((i=1; i<=MAX_ITERATIONS; i++)); do
    echo ""
    echo "━━━ Iteration $i of $MAX_ITERATIONS ━━━"
    echo ""
    BEFORE=$TOTAL_FIXED
    
    case "$MODE" in
        all|lint) fix_php_lint; fix_js_lint ;;&
        all|imports) echo "  Import fixes handled by lint step" ;;&
        all|types) fix_types ;;
    esac
    
    [ "$TOTAL_FIXED" -eq "$BEFORE" ] && echo "" && echo "No more issues to fix." && break
done

# Verify fixes
verify_fixes() {
    echo ""
    echo "🔍 Verifying fixes..."
    local all_passed=true
    if [ -f "./vendor/bin/pint" ]; then
        ./vendor/bin/pint --test >/dev/null 2>&1 && echo "  ✅ PHP lint passed" || { echo "  ⚠️ PHP lint still has issues"; all_passed=false; }
    fi
    if [ -f "./node_modules/.bin/eslint" ]; then
        npm run lint -- --quiet >/dev/null 2>&1 && echo "  ✅ JS/TS lint passed" || { echo "  ⚠️ JS/TS lint still has issues"; all_passed=false; }
    fi
    $all_passed && return 0 || return 1
}

if ! $DRY_RUN; then
    verify_fixes
    VERIFIED=$?
fi

echo ""
echo "📊 Auto-Healing Summary"
echo "======================="
echo "Iterations run: $i of $MAX_ITERATIONS"
echo "Issues fixed: $TOTAL_FIXED"
if $DRY_RUN; then
    echo "Mode: DRY RUN (no changes made)"
elif [ "${VERIFIED:-1}" -eq 0 ]; then
    echo "✅ Auto-Healing: SUCCESS"
else
    echo "⚠️ Auto-Healing: PARTIAL — some issues remain"
    echo "  To escalate: review errors above or ask ai-code-reviewer"
fi

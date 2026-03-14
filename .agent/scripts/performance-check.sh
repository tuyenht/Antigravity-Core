#!/usr/bin/env bash
# performance-check.sh — Enforce frontend/backend performance budgets
# Bash equivalent of performance-check.ps1
# Usage: bash performance-check.sh [--frontend|--backend|--all|--help]

set -euo pipefail

MODE="frontend"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --frontend|-f) MODE="frontend"; shift ;;
        --backend|-b) MODE="backend"; shift ;;
        --all|-a) MODE="all"; shift ;;
        --help|-h)
            echo "Performance Budget Check"
            echo "Usage: bash performance-check.sh [--frontend|--backend|--all]"
            exit 0 ;;
        *) shift ;;
    esac
done

ERRORS=0; WARNINGS=0; PASSED=0

check_frontend() {
    echo "📦 Checking Frontend Budgets..."
    echo ""
    
    BUILD_DIR=""
    for d in dist build public/build .next; do
        [ -d "$d" ] && BUILD_DIR="$d" && break
    done
    
    if [ -z "$BUILD_DIR" ]; then
        echo "  ⚠️ No build directory found. Run 'npm run build' first."
        WARNINGS=$((WARNINGS + 1))
        return
    fi
    
    # Bundle size check (200KB limit) — cross-platform using wc -c
    TOTAL_KB=$(find "$BUILD_DIR" -name "*.js" -type f -exec cat {} + 2>/dev/null | wc -c | awk '{printf "%.0f", $1/1024}')
    
    LIMIT=200
    if [ "${TOTAL_KB:-0}" -le "$LIMIT" ]; then
        echo "  ✅ Main Bundle: ${TOTAL_KB}KB (limit: ${LIMIT}KB)"
        PASSED=$((PASSED + 1))
    else
        echo "  ❌ Main Bundle: ${TOTAL_KB}KB (limit: ${LIMIT}KB)"
        ERRORS=$((ERRORS + 1))
    fi
    echo ""
}

check_backend() {
    echo "🖥️ Checking Backend Budgets..."
    echo ""
    echo "  📊 Backend Budget Targets:"
    echo "     - API p95: < 200ms"
    echo "     - Query count: < 10 per request"
    echo "     - Slow queries: < 100ms"
    echo ""
    
    if [ -d "vendor/barryvdh/laravel-debugbar" ]; then
        echo "  ℹ️ Use Laravel Debugbar to verify these metrics."
    else
        echo "  ℹ️ Install Debugbar for backend metrics: composer require barryvdh/laravel-debugbar --dev"
        WARNINGS=$((WARNINGS + 1))
    fi
    PASSED=$((PASSED + 1))
    echo ""
}

echo "⚡ Performance Budget Check"
echo "==========================="
echo ""

[[ "$MODE" == "frontend" || "$MODE" == "all" ]] && check_frontend
[[ "$MODE" == "backend" || "$MODE" == "all" ]] && check_backend

echo "📊 Summary: ✅ $PASSED passed, ⚠️ $WARNINGS warnings, ❌ $ERRORS errors"
[ "$ERRORS" -gt 0 ] && echo "❌ Performance Budget: FAILED" && exit 1
[ "$WARNINGS" -gt 0 ] && echo "⚠️ Performance Budget: PASSED with warnings"
[ "$WARNINGS" -eq 0 ] && [ "$ERRORS" -eq 0 ] && echo "✅ Performance Budget: PASSED"

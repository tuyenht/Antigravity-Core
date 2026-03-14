#!/usr/bin/env bash
# dx-analytics.sh — Developer experience metrics dashboard
# Bash equivalent of dx-analytics.ps1
# Usage: bash dx-analytics.sh [--dashboard|--roi|--quality|--bottlenecks|--help]

set -euo pipefail

MODE="dashboard"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dashboard|-d) MODE="dashboard"; shift ;;
        --roi|-r) MODE="roi"; shift ;;
        --quality|-q) MODE="quality"; shift ;;
        --bottlenecks|-b) MODE="bottlenecks"; shift ;;
        --recommendations) MODE="recommendations"; shift ;;
        --help|-h)
            echo "DX Analytics: bash dx-analytics.sh [--dashboard|--roi|--quality|--bottlenecks]"
            exit 0 ;;
        *) shift ;;
    esac
done

METRICS_FILE=".agent/memory/dx-analytics.json"

show_dashboard() {
    echo "📊 DX Analytics Dashboard"
    echo "========================="
    echo ""
    if [ -f "$METRICS_FILE" ]; then
        echo "  Data source: $METRICS_FILE"
        # Parse with python3 if available
        if command -v python3 &>/dev/null; then
            python3 -c "
import json
with open('$METRICS_FILE') as f:
    m = json.load(f)
print(f\"  DX Score: {m.get('dx_score', 'N/A')}/100 ({m.get('dx_trend', '')} vs last week)\")
print()
v = m.get('velocity', {})
print('  ⚡ Velocity')
print(f\"     Tasks/Day:    {v.get('tasks_per_day', 'N/A')}\")
print(f\"     Avg Duration: {v.get('avg_duration_minutes', 'N/A')} min\")
print(f\"     Lines/Day:    {v.get('lines_generated', 'N/A')}\")
print()
a = m.get('automation', {})
print('  🤖 Automation ROI')
total = a.get('code_generator_time_saved_hours',0) + a.get('auto_healing_time_saved_hours',0) + a.get('ai_review_time_saved_hours',0)
print(f\"     Total Time Saved: {total}h\")
print()
q = m.get('quality', {})
print('  📈 Quality')
print(f\"     Test Coverage:  {q.get('test_coverage', 'N/A')}%\")
print(f\"     Lint Errors:    {q.get('lint_errors', 'N/A')}\")
print(f\"     Perf Violations:{q.get('perf_violations', 'N/A')}\")
" 2>/dev/null || echo "  (python3 required for JSON parsing, or create $METRICS_FILE)"
        else
            echo "  Install python3 for full dashboard parsing"
        fi
    else
        echo "  No metrics data found at $METRICS_FILE"
        echo "  Default targets:"
        echo "     Tasks/Day: 5+  |  Avg Duration: <30min  |  Test Coverage: >80%"
    fi
    echo ""
}

case "$MODE" in
    dashboard) show_dashboard ;;
    roi) echo "🤖 Automation ROI — Use --dashboard for full view" ;;
    quality) echo "📈 Quality — Use --dashboard for full view" ;;
    bottlenecks) echo "🔍 Bottleneck detection — Use --dashboard for full view" ;;
    recommendations) echo "💡 AI Recommendations — Use --dashboard for full view" ;;
esac

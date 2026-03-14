#!/usr/bin/env bash
# lint-npm-references.sh — Detect actionable npm commands that should be pnpm
# Bash equivalent of lint-npm-references.ps1
# Usage: bash lint-npm-references.sh

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
AGENT_DIR=$(cd "$SCRIPT_DIR/../.." && pwd)

echo "🔍 Scanning for npm references in actionable contexts..."

VIOLATIONS=0

# Patterns to find (actionable npm commands in markdown code blocks)
PATTERNS=('`npm run ' '`npm install ' '`npm create ' '`npm init' '`npm start`')
# Patterns to exclude (acceptable)
EXCLUDES=("npm audit" "npm test" "npm link" "CHANGELOG.md")

find "$AGENT_DIR" -name "*.md" -type f ! -path "*/.git/*" ! -path "*/CHANGELOG*" | while read -r file; do
    RELATIVE=${file#"$AGENT_DIR/"}
    LINE_NUM=0
    
    while IFS= read -r line; do
        LINE_NUM=$((LINE_NUM + 1))
        
        for pattern in "${PATTERNS[@]}"; do
            if [[ "$line" == *"$pattern"* ]]; then
                # Check excludes
                EXCLUDED=false
                for exc in "${EXCLUDES[@]}"; do
                    [[ "$line" == *"$exc"* ]] && EXCLUDED=true && break
                done
                
                if ! $EXCLUDED; then
                    echo "  ⚠️ $RELATIVE:$LINE_NUM: $(echo "$line" | head -c 80)"
                    VIOLATIONS=$((VIOLATIONS + 1))
                fi
            fi
        done
    done < "$file"
done

if [ "$VIOLATIONS" -eq 0 ]; then
    echo "✅ No npm violations found. System is 100% pnpm-compliant."
else
    echo ""
    echo "⚠️ Found $VIOLATIONS npm violation(s). Replace with pnpm equivalents."
    exit 1
fi

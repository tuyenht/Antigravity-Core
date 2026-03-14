#!/usr/bin/env bash
# secret-scan.sh — Detect secrets and credentials in code
# Bash equivalent of secret-scan.ps1
# Usage: bash secret-scan.sh [--staged|--all|--file <path>|--help]

set -euo pipefail

# Parse arguments
MODE="all"
TARGET_FILE=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --staged|-s) MODE="staged"; shift ;;
        --all|-a) MODE="all"; shift ;;
        --file|-f) MODE="file"; TARGET_FILE="$2"; shift 2 ;;
        --help|-h)
            echo "Secret Scanning Script"
            echo "======================"
            echo ""
            echo "Usage:"
            echo "  bash secret-scan.sh --staged     # Scan staged files only"
            echo "  bash secret-scan.sh --all        # Scan all files in project"
            echo "  bash secret-scan.sh --file <path> # Scan specific file"
            echo ""
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Secret patterns (name|regex|severity)
PATTERNS=(
    "AWS Access Key ID|AKIA[0-9A-Z]{16}|CRITICAL"
    "GCP API Key|AIza[0-9A-Za-z_-]{35}|CRITICAL"
    "Stripe Live Key|sk_live_[0-9a-zA-Z]{24,}|CRITICAL"
    "Stripe Test Key|sk_test_[0-9a-zA-Z]{24,}|WARNING"
    "GitHub Token|ghp_[0-9a-zA-Z]{36}|CRITICAL"
    "GitHub OAuth|gho_[0-9a-zA-Z]{36}|CRITICAL"
    "GitLab Token|glpat-[0-9a-zA-Z_-]{20}|CRITICAL"
    "Slack Token|xox[baprs]-[0-9a-zA-Z]{10,}|CRITICAL"
    "Database URL|(mysql|postgres|mongodb)://[^:]+:[^@]+@|CRITICAL"
    "RSA Private Key|BEGIN RSA PRIVATE KEY|CRITICAL"
    "SSH Private Key|BEGIN OPENSSH PRIVATE KEY|CRITICAL"
    "Password Assignment|(password|passwd|pwd)\s*[=:]\s*[\"'][^\"']{8,}[\"']|HIGH"
    "Secret Assignment|(secret|api_key|apikey|access_token)\s*[=:]\s*[\"'][^\"']+[\"']|HIGH"
)

# Exclusion patterns (false positives)
EXCLUDE_MATCH="test_|example_|sample_|demo_|fake_|mock_|placeholder|your_api_key|xxx|YOUR_"

# Excluded directories
EXCLUDE_DIRS="node_modules|vendor|\.git|dist|build|coverage|__pycache__"

# File extensions to scan
SCAN_EXTENSIONS="php|js|ts|tsx|jsx|json|yml|yaml|env|py|rb|go|java|cs|sh|ps1"

echo "🔐 Secret Scanning Started..."
echo ""

# Get files to scan
get_files() {
    case "$MODE" in
        staged)
            git diff --cached --name-only 2>/dev/null || true
            ;;
        file)
            echo "$TARGET_FILE"
            ;;
        all)
            find . -type f \( \
                -name "*.php" -o -name "*.js" -o -name "*.ts" -o -name "*.tsx" \
                -o -name "*.jsx" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" \
                -o -name "*.env" -o -name "*.py" -o -name "*.rb" -o -name "*.go" \
                -o -name "*.java" -o -name "*.cs" -o -name "*.sh" -o -name "*.ps1" \) \
                ! -path "*/node_modules/*" \
                ! -path "*/.git/*" \
                ! -path "*/vendor/*" \
                ! -path "*/dist/*" \
                ! -path "*/build/*" \
                ! -path "*/coverage/*" \
                2>/dev/null
            ;;
    esac
}

CRITICAL=0
HIGH=0
WARNING=0
FILE_COUNT=0
FINDINGS=""

while IFS= read -r file; do
    [ -z "$file" ] && continue
    [ ! -f "$file" ] && continue
    FILE_COUNT=$((FILE_COUNT + 1))

    for pattern_entry in "${PATTERNS[@]}"; do
        IFS='|' read -r pname pregex pseverity <<< "$pattern_entry"

        # Search for pattern
        matches=$(grep -nE "$pregex" "$file" 2>/dev/null | grep -vE "$EXCLUDE_MATCH" || true)

        if [ -n "$matches" ]; then
            while IFS= read -r match_line; do
                line_num=$(echo "$match_line" | cut -d: -f1)
                line_content=$(echo "$match_line" | cut -d: -f2- | head -c 60)

                FINDINGS="${FINDINGS}\n[${pseverity}] ${pname}\n  File: ${file}:${line_num}\n  Match: ${line_content}...\n"

                case "$pseverity" in
                    CRITICAL) CRITICAL=$((CRITICAL + 1)) ;;
                    HIGH) HIGH=$((HIGH + 1)) ;;
                    WARNING) WARNING=$((WARNING + 1)) ;;
                esac
            done <<< "$matches"
        fi
    done
done < <(get_files)

echo "Scanned $FILE_COUNT files"
echo ""

TOTAL=$((CRITICAL + HIGH + WARNING))

if [ "$TOTAL" -eq 0 ]; then
    echo "✅ Secret Scan: PASSED"
    echo "No secrets detected in $FILE_COUNT files"
    exit 0
else
    echo "❌ Secret Scan: FAILED"
    echo ""
    echo "Issues Found:"
    echo "  🔴 CRITICAL: $CRITICAL"
    echo "  🟠 HIGH: $HIGH"
    echo "  🟡 WARNING: $WARNING"
    echo ""
    echo -e "$FINDINGS"
    echo ""
    echo "To fix:"
    echo "1. Remove the secret from code"
    echo "2. Use environment variables instead"
    echo "3. Add to .env (never commit .env!)"
    echo ""
    echo "If false positive, add to .secretscanignore"

    if [ "$CRITICAL" -gt 0 ] || [ "$HIGH" -gt 0 ]; then
        exit 1
    fi
fi

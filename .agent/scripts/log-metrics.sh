#!/usr/bin/env bash
# log-metrics.sh — Append-only JSONL metrics logger
# Bash equivalent of log-metrics.ps1
# Usage: bash log-metrics.sh --task BUILD --tokens 15000 --classification correct

set -euo pipefail

TASK_TYPE="UNKNOWN"
TOKENS=0
CLASSIFICATION="unknown"
CHECKLIST="STANDARD"
SKILLS=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --task|-t) TASK_TYPE="$2"; shift 2 ;;
        --tokens) TOKENS="$2"; shift 2 ;;
        --classification|-c) CLASSIFICATION="$2"; shift 2 ;;
        --checklist) CHECKLIST="$2"; shift 2 ;;
        --skills|-s) SKILLS="$2"; shift 2 ;;
        *) shift ;;
    esac
done

DATE=$(date +%Y%m%d)
METRICS_DIR=".agent/memory/metrics"
METRICS_FILE="$METRICS_DIR/metrics-$DATE.jsonl"

mkdir -p "$METRICS_DIR"

TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S)
ENTRY="{\"timestamp\":\"$TIMESTAMP\",\"task_type\":\"$TASK_TYPE\",\"tokens_estimated\":$TOKENS,\"classification\":\"$CLASSIFICATION\",\"checklist_intensity\":\"$CHECKLIST\",\"skills_invoked\":\"$SKILLS\"}"

echo "$ENTRY" >> "$METRICS_FILE"
echo "✅ Metrics logged to $METRICS_FILE"

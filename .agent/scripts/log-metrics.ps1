#!/usr/bin/env pwsh
# Metrics Logger - Append-only JSON Lines format
# Usage: .\log-metrics.ps1 -TaskType BUILD -Tokens 15000 -Classification "correct"

param(
  [string]$TaskType = "UNKNOWN",
  [int]$Tokens = 0,
  [string]$Classification = "unknown",
  [string]$ChecklistIntensity = "STANDARD",
  [string[]]$SkillsInvoked = @()
)

$ErrorActionPreference = "Stop"

$Date = Get-Date -Format "yyyyMMdd"
$MetricsDir = ".agent\memory\metrics"
$MetricsFile = Join-Path $MetricsDir "metrics-$Date.jsonl"

try {
  # Ensure directory exists
  if (-not (Test-Path $MetricsDir)) {
    New-Item -ItemType Directory -Path $MetricsDir -Force | Out-Null
  }

  # Build structured log entry
  $entry = @{
    timestamp           = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    task_type           = $TaskType
    tokens_estimated    = $Tokens
    classification      = $Classification
    checklist_intensity = $ChecklistIntensity
    skills_invoked      = $SkillsInvoked
  } | ConvertTo-Json -Compress

  # Append as JSON Lines (one JSON object per line)
  Add-Content -Path $MetricsFile -Value $entry -Encoding utf8

  Write-Host "✅ Metrics logged to $MetricsFile" -ForegroundColor Green
}
catch {
  Write-Host "❌ Failed to log metrics: $_" -ForegroundColor Red
  exit 1
}

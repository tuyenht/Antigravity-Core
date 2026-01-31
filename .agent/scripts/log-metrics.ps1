#!/usr/bin/env pwsh
# Metrics Logger - Call at end of each task
# Usage: .\log-metrics.ps1 -TaskType BUILD -Tokens 15000 -Classification "correct"

param(
  [string]$TaskType = "UNKNOWN",
  [int]$Tokens = 0,
  [string]$Classification = "unknown",
  [string]$ChecklistIntensity = "STANDARD",
  [string[]]$SkillsInvoked = @()
)

$Date = Get-Date -Format "yyyyMMdd"
$MetricsFile = ".agent\memory\metrics\metrics-$Date.yaml"

# Ensure metrics file exists
if (-not (Test-Path $MetricsFile)) {
  @"
date: "$Date"
requests:
  total: 0
  by_type: {BUILD: 0, DEBUG: 0, CONSULT: 0, OPTIMIZE: 0}
classification:
  total_attempts: 0
  correct: 0
  accuracy: 0.0
token_estimates:
  total: 0
  avg_per_request: 0
  min: 0
  max: 0
checklist_intensity: {QUICK: 0, STANDARD: 0, COMPREHENSIVE: 0}
skills_invoked: {}
user_feedback: {positive: 0, negative: 0, neutral: 0}
"@ | Out-File -FilePath $MetricsFile -Encoding utf8
}

Write-Host "Logging metrics for $TaskType task..." -ForegroundColor Green

# Read current metrics
$Content = Get-Content $MetricsFile -Raw

# Increment total requests
# Note: This is a simplified version - full implementation would parse YAML properly
# For now, this creates a log entry

$Timestamp = Get-Date -Format "HH:mm:ss"
Add-Content -Path $MetricsFile -Value @"

# Task logged at $Timestamp
# - Type: $TaskType
# - Tokens (estimated): $Tokens
# - Classification: $Classification
# - Checklist: $ChecklistIntensity
# - Skills: $($SkillsInvoked -join ', ')
"@

Write-Host "Metrics logged to $MetricsFile" -ForegroundColor Green

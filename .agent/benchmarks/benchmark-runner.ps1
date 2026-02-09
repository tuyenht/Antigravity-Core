<#
.SYNOPSIS
    Antigravity-Core Benchmark Runner
.DESCRIPTION
    Measures file load times, system inventory, and detects regressions.
.EXAMPLE
    .\benchmark-runner.ps1
#>

param(
    [string]$BaselinePath = "$PSScriptRoot\baseline.json",
    [string]$ReportDir = "$PSScriptRoot\reports",
    [int]$Threshold = 20
)

$ErrorActionPreference = "Stop"

function Write-Header {
    param([string]$Title)
    Write-Host ""
    Write-Host "=======================================" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor White
    Write-Host "=======================================" -ForegroundColor Cyan
}

function Measure-FileLoadTime {
    param([string]$FilePath)
    if (-not (Test-Path $FilePath)) { return -1 }
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $null = Get-Content $FilePath -Raw
    $sw.Stop()
    return $sw.ElapsedMilliseconds
}

function Get-FileStats {
    param([string]$Path, [string]$Pattern = "*")
    if (-not (Test-Path $Path)) { return @{ Count = 0; TotalSizeKB = 0 } }
    $files = Get-ChildItem -Path $Path -Filter $Pattern -Recurse -File -ErrorAction SilentlyContinue
    $count = 0
    $size = 0
    if ($files) {
        $measure = $files | Measure-Object -Property Length -Sum
        $count = $measure.Count
        $size = [math]::Round($measure.Sum / 1KB, 2)
    }
    return @{ Count = $count; TotalSizeKB = $size }
}

# --- Configuration ---

$AgentRoot = Split-Path $PSScriptRoot -Parent
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$ReportFile = Join-Path $ReportDir "benchmark-$Timestamp.md"

if (-not (Test-Path $ReportDir)) {
    New-Item -ItemType Directory -Path $ReportDir -Force | Out-Null
}

# --- Load Baseline ---

$Baseline = @{}
if (Test-Path $BaselinePath) {
    $jsonObj = Get-Content $BaselinePath -Raw | ConvertFrom-Json
    # Convert PSObject to hashtable manually for PS 5.1 compatibility
    $Baseline = @{}
    foreach ($prop in $jsonObj.PSObject.Properties) {
        if ($prop.Value -is [System.Management.Automation.PSCustomObject]) {
            $inner = @{}
            foreach ($p in $prop.Value.PSObject.Properties) { $inner[$p.Name] = $p.Value }
            $Baseline[$prop.Name] = $inner
        }
        else {
            $Baseline[$prop.Name] = $prop.Value
        }
    }
    Write-Host "Loaded baseline from $BaselinePath" -ForegroundColor Green
}
else {
    Write-Host "No baseline found. Will create new baseline." -ForegroundColor Yellow
}

# --- System Inventory ---

Write-Header "System Inventory"

$Inventory = @{
    Agents    = Get-FileStats -Path (Join-Path $AgentRoot "agents") -Pattern "*.md"
    Workflows = Get-FileStats -Path (Join-Path $AgentRoot "workflows") -Pattern "*.md"
    Rules     = Get-FileStats -Path (Join-Path $AgentRoot "rules") -Pattern "*.md"
    Scripts   = Get-FileStats -Path (Join-Path $AgentRoot "scripts") -Pattern "*.ps1"
    Memory    = Get-FileStats -Path (Join-Path $AgentRoot "memory") -Pattern "*.yaml"
}

$skillDirs = Get-ChildItem -Path (Join-Path $AgentRoot "skills") -Directory -ErrorAction SilentlyContinue
$skillCount = 0
$skillSize = 0
if ($skillDirs) {
    $skillCount = ($skillDirs | Measure-Object).Count
    $skillFiles = Get-ChildItem -Path (Join-Path $AgentRoot "skills") -Recurse -File -ErrorAction SilentlyContinue
    if ($skillFiles) {
        $skillSize = [math]::Round(($skillFiles | Measure-Object -Property Length -Sum).Sum / 1KB, 2)
    }
}
$Inventory["Skills"] = @{ Count = $skillCount; TotalSizeKB = $skillSize }

foreach ($component in $Inventory.Keys) {
    $stats = $Inventory[$component]
    Write-Host "  ${component}: $($stats.Count) files, $($stats.TotalSizeKB) KB" -ForegroundColor Gray
}

# --- Critical File Load Times ---

Write-Header "Critical File Load Times"

$CriticalFiles = @(
    @{ Name = "GEMINI.md"; Path = Join-Path $AgentRoot "GEMINI.md" }
    @{ Name = "ARCHITECTURE.md"; Path = Join-Path $AgentRoot "ARCHITECTURE.md" }
    @{ Name = "STANDARDS.md"; Path = Join-Path $AgentRoot "rules\STANDARDS.md" }
    @{ Name = "TEAM_WORKFLOW.md"; Path = Join-Path $AgentRoot "workflows\TEAM_WORKFLOW.md" }
    @{ Name = "AGENT_ROLES.md"; Path = Join-Path $AgentRoot "roles\AGENT_ROLES.md" }
    @{ Name = "project.json"; Path = Join-Path $AgentRoot "project.json" }
)

$LoadTimes = @{}

foreach ($file in $CriticalFiles) {
    $ms = Measure-FileLoadTime -FilePath $file.Path
    $LoadTimes[$file.Name] = $ms
    if ($ms -eq -1) {
        Write-Host "  $($file.Name): NOT FOUND" -ForegroundColor Red
    }
    elseif ($ms -lt 10) {
        Write-Host "  $($file.Name): ${ms}ms" -ForegroundColor Green
    }
    else {
        Write-Host "  $($file.Name): ${ms}ms" -ForegroundColor Yellow
    }
}

# --- Skill Loading ---

Write-Header "Skill Loading (SKILL.md files)"

$SkillsDir = Join-Path $AgentRoot "skills"
$SkillLoadTimes = @{}
$TotalSkillLoadMs = 0

$skillFolders = Get-ChildItem -Path $SkillsDir -Directory -ErrorAction SilentlyContinue
foreach ($folder in $skillFolders) {
    $skillMd = Join-Path $folder.FullName "SKILL.md"
    if (Test-Path $skillMd) {
        $ms = Measure-FileLoadTime -FilePath $skillMd
        $SkillLoadTimes[$folder.Name] = $ms
        $TotalSkillLoadMs += $ms
    }
}

$AvgSkillLoad = 0
if ($SkillLoadTimes.Count -gt 0) {
    $AvgSkillLoad = [math]::Round($TotalSkillLoadMs / $SkillLoadTimes.Count, 1)
}

$avgColor = if ($AvgSkillLoad -lt 5) { "Green" } else { "Yellow" }
Write-Host "  Skills measured: $($SkillLoadTimes.Count)" -ForegroundColor Gray
Write-Host "  Average load time: ${AvgSkillLoad}ms" -ForegroundColor $avgColor
Write-Host "  Total load time: ${TotalSkillLoadMs}ms" -ForegroundColor Gray

# --- Total System Size ---

Write-Header "Total System Size"

$allFiles = Get-ChildItem -Path $AgentRoot -Recurse -File -ErrorAction SilentlyContinue
$totalCount = ($allFiles | Measure-Object).Count
$totalSizeKB = [math]::Round(($allFiles | Measure-Object -Property Length -Sum).Sum / 1KB, 2)
$totalSizeMB = [math]::Round($totalSizeKB / 1024, 2)

Write-Host "  Total files: $totalCount" -ForegroundColor Gray
Write-Host "  Total size: ${totalSizeMB} MB (${totalSizeKB} KB)" -ForegroundColor Gray

# --- Regression Detection ---

Write-Header "Regression Detection"

$Regressions = @()

if ($Baseline.Count -gt 0 -and $Baseline.ContainsKey("LoadTimes")) {
    foreach ($fname in $LoadTimes.Keys) {
        $current = $LoadTimes[$fname]
        if ($current -eq -1) { continue }
        $baseVal = -1
        if ($Baseline.LoadTimes.ContainsKey($fname)) { $baseVal = $Baseline.LoadTimes[$fname] }
        if ($baseVal -gt 0) {
            $change = [math]::Round((($current - $baseVal) / $baseVal) * 100, 1)
            if ($change -gt $Threshold) {
                $Regressions += @{ File = $fname; Baseline = $baseVal; Current = $current; ChangePercent = $change }
                Write-Host "  REGRESSION: $fname (${baseVal}ms -> ${current}ms, +${change}%)" -ForegroundColor Red
            }
        }
    }
}

if ($Regressions.Count -eq 0) {
    Write-Host "  No regressions detected." -ForegroundColor Green
}

# --- Generate Report ---

Write-Header "Generating Report"

$sb = [System.Text.StringBuilder]::new()
$null = $sb.AppendLine("# Benchmark Report")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("**Date:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$versionContent = Get-Content (Join-Path $AgentRoot "VERSION") -ErrorAction SilentlyContinue
$null = $sb.AppendLine("**Version:** $versionContent")
$null = $sb.AppendLine("**Threshold:** ${Threshold}%")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("## System Inventory")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("| Component | Files | Size (KB) |")
$null = $sb.AppendLine("|-----------|-------|-----------|")
foreach ($k in $Inventory.Keys) {
    $null = $sb.AppendLine("| $k | $($Inventory[$k].Count) | $($Inventory[$k].TotalSizeKB) |")
}
$null = $sb.AppendLine("")
$null = $sb.AppendLine("**Total:** $totalCount files, ${totalSizeMB} MB")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("## Critical File Load Times")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("| File | Time (ms) |")
$null = $sb.AppendLine("|------|-----------|")
foreach ($k in $LoadTimes.Keys) {
    $null = $sb.AppendLine("| $k | $($LoadTimes[$k]) |")
}
$null = $sb.AppendLine("")
$null = $sb.AppendLine("## Skill Loading")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("- **Skills measured:** $($SkillLoadTimes.Count)")
$null = $sb.AppendLine("- **Average load:** ${AvgSkillLoad}ms")
$null = $sb.AppendLine("- **Total load:** ${TotalSkillLoadMs}ms")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("## Regressions")
$null = $sb.AppendLine("")
if ($Regressions.Count -eq 0) {
    $null = $sb.AppendLine("No regressions detected.")
}
else {
    $null = $sb.AppendLine("| File | Baseline (ms) | Current (ms) | Change |")
    $null = $sb.AppendLine("|------|--------------|-------------|--------|")
    foreach ($r in $Regressions) {
        $null = $sb.AppendLine("| $($r.File) | $($r.Baseline) | $($r.Current) | +$($r.ChangePercent)% |")
    }
}
$null = $sb.AppendLine("")
$null = $sb.AppendLine("*Generated by benchmark-runner.ps1*")

$sb.ToString() | Out-File -FilePath $ReportFile -Encoding utf8
Write-Host "  Report saved: $ReportFile" -ForegroundColor Green

# --- Save as new baseline ---

if ($Baseline.Count -eq 0) {
    $Results = @{
        LoadTimes      = $LoadTimes
        SkillLoadAvgMs = $AvgSkillLoad
        SkillLoadTotal = $TotalSkillLoadMs
        TotalFiles     = $totalCount
        TotalSizeKB    = $totalSizeKB
        Timestamp      = $Timestamp
    }
    $Results | ConvertTo-Json -Depth 5 | Out-File -FilePath $BaselinePath -Encoding utf8
    Write-Host "  New baseline saved: $BaselinePath" -ForegroundColor Green
}

# --- Summary ---

Write-Header "Summary"

$regColor = if ($Regressions.Count -eq 0) { "Green" } else { "Red" }
Write-Host "  Components: Agents=$($Inventory.Agents.Count), Workflows=$($Inventory.Workflows.Count), Skills=$($Inventory.Skills.Count), Rules=$($Inventory.Rules.Count)" -ForegroundColor White
Write-Host "  Total Size: ${totalSizeMB} MB" -ForegroundColor White
Write-Host "  Regressions: $($Regressions.Count)" -ForegroundColor $regColor
Write-Host ""

$exitCode = 0
if ($Regressions.Count -gt 0) { $exitCode = 1 }
exit $exitCode

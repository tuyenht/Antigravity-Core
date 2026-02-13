# .agent System Health Check
# Purpose: Verify .agent system integrity and compliance

param(
    [switch]$Verbose,
    [switch]$FailFast  # Exit on first failure
)

$ErrorActionPreference = "Continue"
$script:failCount = 0
$script:passCount = 0
$script:totalChecks = 0

function Write-Check {
    param([string]$Message, [string]$Status)
    
    $script:totalChecks++
    
    if ($Status -eq "PASS") {
        $script:passCount++
        Write-Host "[OK] $Message" -ForegroundColor Green
    }
    elseif ($Status -eq "FAIL") {
        $script:failCount++
        Write-Host "[XX] $Message" -ForegroundColor Red
        
        if ($FailFast) {
            Write-Host "`nFail-fast mode enabled. Exiting." -ForegroundColor Red
            exit 1
        }
    }
    else {
        Write-Host "[--] $Message" -ForegroundColor Yellow
    }
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  .agent SYSTEM HEALTH CHECK" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# CHECK 1: Core Files Exist
# ============================================

Write-Host "1. Checking core files..." -ForegroundColor Cyan

$coreFiles = @(
    ".agent\rules\STANDARDS.md",
    ".agent\templates\agent-template-v3.md",
    ".agent\systems\rba-validator.md",
    ".agent\examples\rba-examples.md",
    ".agent\project.json"
)

foreach ($file in $coreFiles) {
    if (Test-Path $file) {
        Write-Check "Found: $file" "PASS"
    }
    else {
        Write-Check "Missing: $file" "FAIL"
    }
}

# ============================================
# CHECK 2: Agents Compliance
# ============================================

Write-Host "`n2. Checking agents compliance..." -ForegroundColor Cyan

$agents = Get-ChildItem ".agent\agents\*.md" -ErrorAction SilentlyContinue

if ($agents.Count -eq 0) {
    Write-Check "No agents found" "FAIL"
}
else {
    $compliantAgents = 0
    $totalAgents = $agents.Count
    
    foreach ($agent in $agents) {
        $content = Get-Content $agent.FullName -Raw -ErrorAction SilentlyContinue
        
        $hasStandards = $content -match "Golden Rule|STANDARDS\.md"
        $hasRBA = $content -match "Reasoning-Before-Action|RBA"
        
        if ($hasStandards -and $hasRBA) {
            $compliantAgents++
            if ($Verbose) {
                Write-Check "$($agent.Name): Compliant" "PASS"
            }
        }
        else {
            Write-Check "$($agent.Name): Missing compliance sections" "FAIL"
        }
    }
    
    $compliancePercent = [math]::Round(($compliantAgents / $totalAgents) * 100, 0)
    
    if ($compliancePercent -eq 100) {
        Write-Check "Agents compliance: $compliantAgents/$totalAgents (100%)" "PASS"
    }
    elseif ($compliancePercent -ge 80) {
        Write-Check "Agents compliance: $compliantAgents/$totalAgents ($compliancePercent%)" "WARN"
    }
    else {
        Write-Check "Agents compliance: $compliantAgents/$totalAgents ($compliancePercent%)" "FAIL"
    }
}

# ============================================
# CHECK 3: Project Configuration
# ============================================

Write-Host "`n3. Checking project configuration..." -ForegroundColor Cyan

if (Test-Path ".agent\project.json") {
    try {
        $config = Get-Content ".agent\project.json" -Raw | ConvertFrom-Json
        
        # Check required fields
        if ($config.version) {
            Write-Check "Version: $($config.version)" "PASS"
        }
        else {
            Write-Check "Version field missing" "FAIL"
        }
        
        if ($config.metrics.health_score) {
            Write-Check "Health score: $($config.metrics.health_score)/100" "PASS"
        }
        
        if ($config.agents.total) {
            Write-Check "Registered agents: $($config.agents.total)" "PASS"
        }
    }
    catch {
        Write-Check "project.json parse error: $($_.Exception.Message)" "FAIL"
    }
}
else {
    Write-Check "project.json not found" "FAIL"
}

# ============================================
# CHECK 4: Scripts Executable
# ============================================

Write-Host "`n4. Checking scripts..." -ForegroundColor Cyan

$scripts = @(
    ".agent\scripts\validate-compliance.ps1",
    ".agent\scripts\bulk-update-agents.ps1"
)

foreach ($script in $scripts) {
    if (Test-Path $script) {
        Write-Check "Found: $([System.IO.Path]::GetFileName($script))" "PASS"
    }
    else {
        Write-Check "Missing: $([System.IO.Path]::GetFileName($script))" "WARN"
    }
}

# ============================================
# CHECK 5: AOC Agents Present
# ============================================

Write-Host "`n5. Checking AOC system..." -ForegroundColor Cyan

$aocAgents = @(
    ".agent\agents\manager-agent.md",
    ".agent\agents\self-correction-agent.md",
    ".agent\agents\documentation-agent.md",
    ".agent\agents\refactor-agent.md"
)

$aocComplete = $true
foreach ($agent in $aocAgents) {
    if (Test-Path $agent) {
        if ($Verbose) {
            Write-Check "Found: $([System.IO.Path]::GetFileName($agent))" "PASS"
        }
    }
    else {
        Write-Check "Missing AOC agent: $([System.IO.Path]::GetFileName($agent))" "FAIL"
        $aocComplete = $false
    }
}

if ($aocComplete) {
    Write-Check "AOC system: Complete" "PASS"
}

# ============================================
# CHECK 6: Documentation Present
# ============================================

Write-Host "`n6. Checking documentation..." -ForegroundColor Cyan

$docs = @(
    ".agent\docs\ROLLBACK-PROCEDURES.md",
    ".agent\skills\README.md"
)

foreach ($doc in $docs) {
    if (Test-Path $doc) {
        Write-Check "Found: $([System.IO.Path]::GetFileName($doc))" "PASS"
    }
    else {
        Write-Check "Missing: $([System.IO.Path]::GetFileName($doc))" "WARN"
    }
}

# ============================================
# SUMMARY
# ============================================

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "  HEALTH CHECK SUMMARY" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$successRate = if ($script:totalChecks -gt 0) {
    [math]::Round(($script:passCount / $script:totalChecks) * 100, 0)
}
else { 0 }

Write-Host "Total checks: $($script:totalChecks)" -ForegroundColor White
Write-Host "Passed: $($script:passCount)" -ForegroundColor Green
Write-Host "Failed: $($script:failCount)" -ForegroundColor $(if ($script:failCount -gt 0) { "Red" } else { "Green" })
Write-Host "Success rate: $successRate%" -ForegroundColor $(
    if ($successRate -ge 90) { "Green" }
    elseif ($successRate -ge 70) { "Yellow" }
    else { "Red" }
)

Write-Host ""

# Overall status
if ($script:failCount -eq 0) {
    Write-Host "Status: HEALTHY" -ForegroundColor Green
    Write-Host ""
    exit 0
}
elseif ($script:failCount -le 2) {
    Write-Host "Status: DEGRADED (minor issues)" -ForegroundColor Yellow
    Write-Host ""
    exit 0
}
else {
    Write-Host "Status: UNHEALTHY (critical issues found)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Run with -Verbose for detailed output" -ForegroundColor Yellow
    exit 1
}

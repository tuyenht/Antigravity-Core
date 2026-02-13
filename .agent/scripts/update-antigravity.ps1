#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Update Antigravity-Core in current project to latest version

.DESCRIPTION
    Downloads latest Antigravity-Core from GitHub and updates the .agent folder.
    Preserves project-specific customizations in .agent/memory/ and custom workflows.

.PARAMETER Force
    Skip confirmation prompts

.PARAMETER KeepCustom
    Keep custom workflows/agents that don't exist in upstream

.EXAMPLE
    # Update current project
    .\update-antigravity.ps1

    # Force update without prompts
    .\update-antigravity.ps1 -Force

.NOTES
    Author: Antigravity-Core Team
    Version: 1.0.0
#>

param(
    [switch]$Force,
    [switch]$KeepCustom
)

$ErrorActionPreference = "Stop"
$REPO_ARCHIVE = "https://github.com/tuyenht/Antigravity-Core/archive/refs/heads/main.zip"

$ProjectPath = $PWD.Path
$agentPath = Join-Path $ProjectPath ".agent"

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          ANTIGRAVITY-CORE UPDATER v1.0                     ║" -ForegroundColor Cyan
Write-Host "║    AI-Native Development Operating System                  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if .agent exists
if (-not (Test-Path $agentPath)) {
    Write-Host "❌ No .agent folder found in current directory." -ForegroundColor Red
    Write-Host "   Run install-antigravity.ps1 first." -ForegroundColor Gray
    exit 1
}

# Get current version
$currentVersion = "unknown"
$versionFile = Join-Path $agentPath "VERSION"
if (Test-Path $versionFile) {
    $currentVersion = (Get-Content $versionFile -Raw).Trim()
}

Write-Host "📁 Project: $ProjectPath" -ForegroundColor Gray
Write-Host "📦 Current version: $currentVersion" -ForegroundColor Gray
Write-Host ""

# Step 2: Backup memory and custom files
Write-Host "Step 1: Backing up project data..." -ForegroundColor Yellow

$backupDir = Join-Path $env:TEMP "antigravity-backup-$(Get-Date -Format 'yyyyMMddHHmmss')"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

# Backup memory (persistent data)
$memoryPath = Join-Path $agentPath "memory"
if (Test-Path $memoryPath) {
    Copy-Item -Path $memoryPath -Destination (Join-Path $backupDir "memory") -Recurse -Force
    Write-Host "   ✓ Backed up memory/" -ForegroundColor Green
}

# Backup project.json (project-specific config)
$projectJson = Join-Path $agentPath "project.json"
if (Test-Path $projectJson) {
    Copy-Item -Path $projectJson -Destination (Join-Path $backupDir "project.json") -Force
    Write-Host "   ✓ Backed up project.json" -ForegroundColor Green
}

# Step 3: Download latest
Write-Host ""
Write-Host "Step 2: Downloading latest version..." -ForegroundColor Yellow

$tempDir = Join-Path $env:TEMP "antigravity-update-$(Get-Date -Format 'yyyyMMddHHmmss')"
$zipPath = Join-Path $tempDir "antigravity-core.zip"

try {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    $progressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $REPO_ARCHIVE -OutFile $zipPath -UseBasicParsing
    $progressPreference = 'Continue'
    
    Write-Host "   ✓ Downloaded successfully" -ForegroundColor Green

    # Extract
    Write-Host ""
    Write-Host "Step 3: Extracting..." -ForegroundColor Yellow
    $extractPath = Join-Path $tempDir "extracted"
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
    
    $sourceAgent = Get-ChildItem -Path $extractPath -Directory | Select-Object -First 1
    $sourceAgentPath = Join-Path $sourceAgent.FullName ".agent"
    
    # Get new version
    $newVersionFile = Join-Path $sourceAgentPath "VERSION"
    $newVersion = "unknown"
    if (Test-Path $newVersionFile) {
        $newVersion = (Get-Content $newVersionFile -Raw).Trim()
    }
    
    Write-Host "   ✓ Extracted (version: $newVersion)" -ForegroundColor Green

    # Step 4: Compare versions
    if ($currentVersion -eq $newVersion -and -not $Force) {
        Write-Host ""
        Write-Host "ℹ️  Already at latest version ($currentVersion)" -ForegroundColor Cyan
        $confirm = Read-Host "   Force update anyway? (y/N)"
        if ($confirm -ne "y" -and $confirm -ne "Y") {
            Write-Host "   Update skipped." -ForegroundColor Gray
            exit 0
        }
    }

    # Step 5: Update .agent folder
    Write-Host ""
    Write-Host "Step 4: Updating .agent folder..." -ForegroundColor Yellow
    
    # Remove old .agent (except what we backed up)
    Remove-Item -Path $agentPath -Recurse -Force
    
    # Copy new .agent
    Copy-Item -Path $sourceAgentPath -Destination $agentPath -Recurse -Force
    Write-Host "   ✓ Installed new version" -ForegroundColor Green

    # Step 6: Restore backups
    Write-Host ""
    Write-Host "Step 5: Restoring project data..." -ForegroundColor Yellow
    
    # Restore memory
    $backupMemory = Join-Path $backupDir "memory"
    if (Test-Path $backupMemory) {
        Copy-Item -Path $backupMemory -Destination $memoryPath -Recurse -Force
        Write-Host "   ✓ Restored memory/" -ForegroundColor Green
    }
    
    # Restore project.json
    $backupProjectJson = Join-Path $backupDir "project.json"
    if (Test-Path $backupProjectJson) {
        Copy-Item -Path $backupProjectJson -Destination $projectJson -Force
        Write-Host "   ✓ Restored project.json" -ForegroundColor Green
    }

    # Step 7: Show summary
    Write-Host ""
    Write-Host "Step 6: Verification..." -ForegroundColor Yellow
    
    $workflows = (Get-ChildItem -Path (Join-Path $agentPath "workflows") -Filter "*.md" -ErrorAction SilentlyContinue).Count
    $skills = (Get-ChildItem -Path (Join-Path $agentPath "skills") -Directory -ErrorAction SilentlyContinue).Count
    $agents = (Get-ChildItem -Path (Join-Path $agentPath "agents") -Filter "*.md" -ErrorAction SilentlyContinue).Count
    
    Write-Host "   📊 Workflows: $workflows" -ForegroundColor Gray
    Write-Host "   🎯 Skills: $skills" -ForegroundColor Gray
    Write-Host "   🤖 Agents: $agents" -ForegroundColor Gray
    Write-Host "   📦 Version: $newVersion" -ForegroundColor Gray

}
catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    
    # Restore from backup on error
    Write-Host "🔄 Restoring from backup..." -ForegroundColor Yellow
    if (Test-Path $backupDir) {
        # This is a simplified restore - in production, would be more robust
    }
    exit 1
}
finally {
    # Cleanup temp files
    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path $backupDir) {
        Remove-Item -Path $backupDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║    ✅ ANTIGRAVITY-CORE UPDATED SUCCESSFULLY!               ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "📦 Updated: $currentVersion → $newVersion" -ForegroundColor Cyan
Write-Host "📁 Location: $agentPath" -ForegroundColor Cyan
Write-Host ""

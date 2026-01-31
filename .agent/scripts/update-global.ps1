#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Update global Antigravity-Core installation

.DESCRIPTION
    Downloads latest Antigravity-Core from GitHub and updates the global installation.
    After updating global, individual projects can be updated using 'agu' command.

.EXAMPLE
    .\update-global.ps1

.NOTES
    Run this periodically to get latest features and fixes.
#>

$ErrorActionPreference = "Stop"
$REPO_ARCHIVE = "https://github.com/tuyenht/Antigravity-Core/archive/refs/heads/main.zip"

# Find install path
$InstallPath = $env:ANTIGRAVITY_HOME
if (-not $InstallPath) {
    $InstallPath = "C:\Tools\Antigravity-Core"
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║      ANTIGRAVITY-CORE GLOBAL UPDATER v1.0                  ║" -ForegroundColor Cyan  
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check if installed
if (-not (Test-Path $InstallPath)) {
    Write-Host "❌ Antigravity-Core not found at: $InstallPath" -ForegroundColor Red
    Write-Host "   Run install-global.ps1 first." -ForegroundColor Gray
    exit 1
}

# Get current version
$currentVersion = "unknown"
$versionFile = Join-Path $InstallPath ".agent\VERSION"
if (Test-Path $versionFile) {
    $currentVersion = (Get-Content $versionFile -Raw).Trim()
}

Write-Host "📁 Location: $InstallPath" -ForegroundColor Gray
Write-Host "📦 Current version: $currentVersion" -ForegroundColor Gray
Write-Host ""

# Download latest
$tempDir = Join-Path $env:TEMP "antigravity-update-$(Get-Date -Format 'yyyyMMddHHmmss')"
$zipPath = Join-Path $tempDir "antigravity-core.zip"

try {
    Write-Host "Step 1: Downloading latest version..." -ForegroundColor Yellow
    
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    $progressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $REPO_ARCHIVE -OutFile $zipPath -UseBasicParsing
    $progressPreference = 'Continue'
    
    Write-Host "   ✓ Downloaded" -ForegroundColor Green

    # Extract
    Write-Host "Step 2: Extracting..." -ForegroundColor Yellow
    $extractPath = Join-Path $tempDir "extracted"
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
    
    $sourceDir = Get-ChildItem -Path $extractPath -Directory | Select-Object -First 1
    
    # Get new version
    $newVersionFile = Join-Path $sourceDir.FullName ".agent\VERSION"
    $newVersion = "unknown"
    if (Test-Path $newVersionFile) {
        $newVersion = (Get-Content $newVersionFile -Raw).Trim()
    }
    
    Write-Host "   ✓ New version: $newVersion" -ForegroundColor Green

    # Compare versions
    if ($currentVersion -eq $newVersion) {
        Write-Host ""
        Write-Host "ℹ️  Already at latest version ($currentVersion)" -ForegroundColor Cyan
        $confirm = Read-Host "   Force update anyway? (y/N)"
        if ($confirm -ne "y" -and $confirm -ne "Y") {
            Write-Host "   Update skipped." -ForegroundColor Gray
            exit 0
        }
    }

    # Backup setup-profile.ps1 (contains user's install path)
    Write-Host "Step 3: Updating files..." -ForegroundColor Yellow
    $profileSetup = Join-Path $InstallPath "setup-profile.ps1"
    $profileBackup = $null
    if (Test-Path $profileSetup) {
        $profileBackup = Get-Content $profileSetup -Raw
    }

    # Remove old installation
    Remove-Item -Path $InstallPath -Recurse -Force
    
    # Move new installation
    Move-Item -Path $sourceDir.FullName -Destination $InstallPath -Force
    
    # Restore setup-profile.ps1
    if ($profileBackup) {
        Set-Content -Path $profileSetup -Value $profileBackup
    }
    
    Write-Host "   ✓ Updated successfully" -ForegroundColor Green

}
catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    exit 1
}
finally {
    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║    ✅ GLOBAL UPDATE COMPLETE!                              ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "📦 Updated: $currentVersion → $newVersion" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 To update individual projects, run in each project:" -ForegroundColor Yellow
Write-Host "   agu" -ForegroundColor White
Write-Host "   # or: Update-Antigravity" -ForegroundColor Gray
Write-Host ""

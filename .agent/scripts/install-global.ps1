#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Install Antigravity-Core globally (master copy)

.DESCRIPTION
    Downloads Antigravity-Core to a central location for use across all projects.
    After global installation, use 'antigravity-install' to install to any project.

.PARAMETER InstallPath
    Where to install globally (default: C:\Tools\Antigravity-Core)

.EXAMPLE
    # Install globally
    .\install-global.ps1

    # Install to custom location
    .\install-global.ps1 -InstallPath "D:\DevTools\Antigravity-Core"

.NOTES
    After installation, add to $PROFILE for easy access.
#>

param(
    [string]$InstallPath = "C:\Tools\Antigravity-Core",
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$REPO_URL = "https://github.com/tuyenht/Antigravity-Core"
$REPO_ARCHIVE = "https://github.com/tuyenht/Antigravity-Core/archive/refs/heads/main.zip"

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║      ANTIGRAVITY-CORE GLOBAL INSTALLER v1.1                ║" -ForegroundColor Cyan
Write-Host "║    AI-Native Development Operating System                  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Pre-flight: check execution policy
$execPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($execPolicy -eq "Restricted" -or $execPolicy -eq "AllSigned") {
    Write-Host "⚠️  ExecutionPolicy is '$execPolicy'. Attempting to set RemoteSigned..." -ForegroundColor Yellow
    try {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Write-Host "   ✓ ExecutionPolicy set to RemoteSigned" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Cannot set ExecutionPolicy. Run manually:" -ForegroundColor Red
        Write-Host "   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Cyan
        exit 1
    }
}

Write-Host "📁 Install Path: $InstallPath" -ForegroundColor Gray
Write-Host "🔗 Source: $REPO_URL" -ForegroundColor Gray
Write-Host ""

# Step 1: Check if already exists
if (Test-Path $InstallPath) {
    if ($Force) {
        Write-Host "⚠️  Existing installation found. Removing (--Force)..." -ForegroundColor Yellow
        Remove-Item -Path $InstallPath -Recurse -Force
    }
    else {
        Write-Host "⚠️  Antigravity-Core already installed at: $InstallPath" -ForegroundColor Yellow
        $confirm = Read-Host "   Reinstall? (y/N)"
        if ($confirm -ne "y" -and $confirm -ne "Y") {
            Write-Host "   Use 'update-global.ps1' to update instead." -ForegroundColor Gray
            exit 0
        }
        Remove-Item -Path $InstallPath -Recurse -Force
    }
}

# Step 2: Create directory
$parentDir = Split-Path -Parent $InstallPath
if (-not (Test-Path $parentDir)) {
    New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
}

# Step 3: Download from GitHub
$tempDir = Join-Path $env:TEMP "antigravity-global-$(Get-Date -Format 'yyyyMMddHHmmss')"
$zipPath = Join-Path $tempDir "antigravity-core.zip"

try {
    Write-Host "Step 1: Downloading from GitHub..." -ForegroundColor Yellow
    
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    $progressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $REPO_ARCHIVE -OutFile $zipPath -UseBasicParsing
    $progressPreference = 'Continue'
    
    Write-Host "   ✓ Downloaded successfully" -ForegroundColor Green

    # Step 4: Extract
    Write-Host "Step 2: Extracting..." -ForegroundColor Yellow
    $extractPath = Join-Path $tempDir "extracted"
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
    
    # Find extracted folder
    $sourceDir = Get-ChildItem -Path $extractPath -Directory | Select-Object -First 1
    
    # Move to install path
    Move-Item -Path $sourceDir.FullName -Destination $InstallPath -Force
    
    Write-Host "   ✓ Installed to $InstallPath" -ForegroundColor Green

    # Step 5: Get version
    $versionFile = Join-Path $InstallPath ".agent\VERSION"
    $version = "unknown"
    if (Test-Path $versionFile) {
        $version = (Get-Content $versionFile -Raw).Trim()
    }

    # Step 6: Create setup script for $PROFILE
    $profileSetup = @"

# ═══════════════════════════════════════════════════════════════
# ANTIGRAVITY-CORE GLOBAL SETUP
# ═══════════════════════════════════════════════════════════════

`$env:ANTIGRAVITY_HOME = "$InstallPath"

# Dot-source functions from installation (auto-updates with agug)
. "`$env:ANTIGRAVITY_HOME\.agent\scripts\profile-functions.ps1"

# ═══════════════════════════════════════════════════════════════
"@

    $profileSetupFile = Join-Path $InstallPath "setup-profile.ps1"
    Set-Content -Path $profileSetupFile -Value $profileSetup

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

# Auto-add to PowerShell Profile
$profileDir = Split-Path -Parent $PROFILE
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    Write-Host "   ✓ Created profile directory: $profileDir" -ForegroundColor Green
}

$profileLine = ". '$InstallPath\setup-profile.ps1'"
$profileExists = $false
if (Test-Path $PROFILE) {
    $profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
    if ($profileContent -and $profileContent.Contains($profileLine)) {
        $profileExists = $true
    }
}

if (-not $profileExists) {
    Add-Content -Path $PROFILE -Value "`n$profileLine"
    Write-Host "   ✓ Added to PowerShell Profile" -ForegroundColor Green
}
else {
    Write-Host "   ✓ Already in PowerShell Profile" -ForegroundColor Green
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║    ✅ ANTIGRAVITY-CORE INSTALLED GLOBALLY!                 ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "📦 Version: $version" -ForegroundColor Cyan
Write-Host "📁 Location: $InstallPath" -ForegroundColor Cyan
Write-Host "📁 Profile:  $PROFILE" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Restart PowerShell and use:" -ForegroundColor Yellow
Write-Host "    agi   - Install to current project" -ForegroundColor Gray
Write-Host "    agu   - Update current project" -ForegroundColor Gray
Write-Host "    agug  - Update global installation" -ForegroundColor Gray
Write-Host ""

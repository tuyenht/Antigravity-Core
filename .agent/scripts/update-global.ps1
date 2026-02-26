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

    # Update files
    Write-Host "Step 3: Updating files..." -ForegroundColor Yellow

    # Remove old installation
    Remove-Item -Path $InstallPath -Recurse -Force
    
    # Move new installation
    Move-Item -Path $sourceDir.FullName -Destination $InstallPath -Force
    
    # Regenerate setup-profile.ps1 with dynamic version reading
    $profileSetup = Join-Path $InstallPath "setup-profile.ps1"
    $profileContent = @"

# ═══════════════════════════════════════════════════════════════
# ANTIGRAVITY-CORE GLOBAL SETUP
# ═══════════════════════════════════════════════════════════════

`$env:ANTIGRAVITY_HOME = "$InstallPath"

function Install-Antigravity {
    <#
    .SYNOPSIS Install Antigravity-Core to current project
    #>
    param([switch]`$Force)
    
    `$source = "`$env:ANTIGRAVITY_HOME\.agent"
    `$target = ".\.agent"
    
    if (-not (Test-Path `$source)) {
        Write-Host "❌ Antigravity-Core not found. Run global installer first." -ForegroundColor Red
        return
    }
    
    if (Test-Path `$target) {
        if (`$Force) {
            Remove-Item -Path `$target -Recurse -Force
        } else {
            Write-Host "⚠️  .agent already exists. Use -Force to overwrite." -ForegroundColor Yellow
            return
        }
    }
    
    Copy-Item -Path `$source -Destination `$target -Recurse -Force
    
    # Copy docs if not exists
    `$sourceDocs = "`$env:ANTIGRAVITY_HOME\docs"
    if ((Test-Path `$sourceDocs) -and -not (Test-Path ".\docs")) {
        Copy-Item -Path `$sourceDocs -Destination ".\docs" -Recurse -Force
    }
    
    `$installedVersion = "unknown"
    `$vf = Join-Path `$target "VERSION"
    if (Test-Path `$vf) { `$installedVersion = (Get-Content `$vf -Raw).Trim() }
    
    Write-Host "✅ Antigravity-Core installed to current project!" -ForegroundColor Green
    Write-Host "   Version: `$installedVersion" -ForegroundColor Gray
}

function Update-Antigravity {
    <#
    .SYNOPSIS Update Antigravity-Core in current project from global
    #>
    if (-not (Test-Path ".\.agent")) {
        Write-Host "❌ No .agent folder. Run Install-Antigravity first." -ForegroundColor Red
        return
    }
    
    # Backup memory and project.json
    `$backupDir = ".\temp-ag-backup"
    New-Item -ItemType Directory -Path `$backupDir -Force | Out-Null
    
    if (Test-Path ".\.agent\memory") {
        Copy-Item -Path ".\.agent\memory" -Destination "`$backupDir\memory" -Recurse -Force
    }
    if (Test-Path ".\.agent\project.json") {
        Copy-Item -Path ".\.agent\project.json" -Destination "`$backupDir\project.json" -Force
    }
    
    # Remove old and install new
    Remove-Item -Path ".\.agent" -Recurse -Force
    Install-Antigravity
    
    # Restore backups
    if (Test-Path "`$backupDir\memory") {
        Copy-Item -Path "`$backupDir\memory" -Destination ".\.agent\memory" -Recurse -Force
    }
    if (Test-Path "`$backupDir\project.json") {
        Copy-Item -Path "`$backupDir\project.json" -Destination ".\.agent\project.json" -Force
    }
    
    Remove-Item -Path `$backupDir -Recurse -Force
    
    Write-Host "✅ Antigravity-Core updated!" -ForegroundColor Green
}

function Update-AntigravityGlobal {
    <#
    .SYNOPSIS Update global Antigravity-Core installation
    #>
    & "`$env:ANTIGRAVITY_HOME\.agent\scripts\update-global.ps1"
}

# Aliases
Set-Alias agi Install-Antigravity
Set-Alias agu Update-Antigravity
Set-Alias agug Update-AntigravityGlobal

`$_agVersion = "unknown"
`$_agVersionFile = Join-Path `$env:ANTIGRAVITY_HOME ".agent\VERSION"
if (Test-Path `$_agVersionFile) { `$_agVersion = (Get-Content `$_agVersionFile -Raw).Trim() }
Write-Host "🚀 Antigravity-Core loaded (v`$_agVersion)" -ForegroundColor DarkGray

# ═══════════════════════════════════════════════════════════════
"@
    Set-Content -Path $profileSetup -Value $profileContent -Encoding UTF8
    
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

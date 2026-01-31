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
Write-Host "║      ANTIGRAVITY-CORE GLOBAL INSTALLER v1.0                ║" -ForegroundColor Cyan
Write-Host "║    AI-Native Development Operating System                  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

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
    
    Write-Host "✅ Antigravity-Core installed to current project!" -ForegroundColor Green
    Write-Host "   Version: $version" -ForegroundColor Gray
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

Write-Host "🚀 Antigravity-Core loaded (v$version)" -ForegroundColor DarkGray

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

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║    ✅ ANTIGRAVITY-CORE INSTALLED GLOBALLY!                 ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "📦 Version: $version" -ForegroundColor Cyan
Write-Host "📁 Location: $InstallPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "  NEXT STEP: Add to PowerShell Profile" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Run this command:" -ForegroundColor White
Write-Host ""
Write-Host "  Add-Content -Path `$PROFILE -Value `". '$InstallPath\setup-profile.ps1'`"" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Then restart PowerShell and use:" -ForegroundColor White
Write-Host "    agi   - Install to current project" -ForegroundColor Gray
Write-Host "    agu   - Update current project" -ForegroundColor Gray
Write-Host "    agug  - Update global installation" -ForegroundColor Gray
Write-Host ""

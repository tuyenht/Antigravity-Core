#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Install Antigravity-Core to a new project

.DESCRIPTION
    Downloads and installs the latest Antigravity-Core .agent folder to current project.
    Source: https://github.com/tuyenht/Antigravity-Core

.PARAMETER ProjectPath
    Target project path (default: current directory)

.PARAMETER Force
    Overwrite existing .agent folder without confirmation

.EXAMPLE
    # Install to current directory
    .\install-antigravity.ps1

    # Install to specific project
    .\install-antigravity.ps1 -ProjectPath "C:\Projects\MyApp"

    # Force overwrite
    .\install-antigravity.ps1 -Force

.NOTES
    Author: Antigravity-Core Team
    Version: 1.0.0
#>

param(
    [string]$ProjectPath = ".",
    [switch]$Force,
    [switch]$SkipDownload
)

$ErrorActionPreference = "Stop"
$REPO_URL = "https://github.com/tuyenht/Antigravity-Core"
$REPO_ARCHIVE = "https://github.com/tuyenht/Antigravity-Core/archive/refs/heads/main.zip"

# Resolve absolute path
$ProjectPath = Resolve-Path $ProjectPath -ErrorAction SilentlyContinue
if (-not $ProjectPath) {
    $ProjectPath = $PWD.Path
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          ANTIGRAVITY-CORE INSTALLER v1.0                   ║" -ForegroundColor Cyan
Write-Host "║    AI-Native Development Operating System                  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "📁 Target: $ProjectPath" -ForegroundColor Gray
Write-Host "🔗 Source: $REPO_URL" -ForegroundColor Gray
Write-Host ""

# Step 1: Check if .agent already exists
$agentPath = Join-Path $ProjectPath ".agent"
if (Test-Path $agentPath) {
    if ($Force) {
        Write-Host "⚠️  Existing .agent found. Removing (--Force)..." -ForegroundColor Yellow
        Remove-Item -Path $agentPath -Recurse -Force
    }
    else {
        Write-Host "⚠️  .agent folder already exists at: $agentPath" -ForegroundColor Yellow
        $confirm = Read-Host "   Overwrite? (y/N)"
        if ($confirm -ne "y" -and $confirm -ne "Y") {
            Write-Host "❌ Installation cancelled." -ForegroundColor Red
            exit 0
        }
        Remove-Item -Path $agentPath -Recurse -Force
    }
}

# Step 2: Download from GitHub
$tempDir = Join-Path $env:TEMP "antigravity-install-$(Get-Date -Format 'yyyyMMddHHmmss')"
$zipPath = Join-Path $tempDir "antigravity-core.zip"

try {
    Write-Host "Step 1: Downloading Antigravity-Core..." -ForegroundColor Yellow
    
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    # Download ZIP
    $progressPreference = 'SilentlyContinue'  # Faster download
    Invoke-WebRequest -Uri $REPO_ARCHIVE -OutFile $zipPath -UseBasicParsing
    $progressPreference = 'Continue'
    
    Write-Host "   ✓ Downloaded successfully" -ForegroundColor Green

    # Step 3: Extract
    Write-Host "Step 2: Extracting files..." -ForegroundColor Yellow
    $extractPath = Join-Path $tempDir "extracted"
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
    
    # Find the extracted folder (it will be named Antigravity-Core-main)
    $sourceAgent = Get-ChildItem -Path $extractPath -Directory | Select-Object -First 1
    $sourceAgentPath = Join-Path $sourceAgent.FullName ".agent"
    
    if (-not (Test-Path $sourceAgentPath)) {
        throw ".agent folder not found in downloaded archive"
    }
    
    Write-Host "   ✓ Extracted successfully" -ForegroundColor Green

    # Step 4: Copy to project
    Write-Host "Step 3: Installing to project..." -ForegroundColor Yellow
    Copy-Item -Path $sourceAgentPath -Destination $agentPath -Recurse -Force
    
    # Also copy docs folder
    $sourceDocsPath = Join-Path $sourceAgent.FullName "docs"
    $targetDocsPath = Join-Path $ProjectPath "docs"
    if (Test-Path $sourceDocsPath) {
        if (-not (Test-Path $targetDocsPath)) {
            Copy-Item -Path $sourceDocsPath -Destination $targetDocsPath -Recurse -Force
            Write-Host "   ✓ Copied docs folder" -ForegroundColor Green
        }
    }
    
    Write-Host "   ✓ Installed successfully" -ForegroundColor Green

    # Step 5: Show summary
    Write-Host ""
    Write-Host "Step 4: Verification..." -ForegroundColor Yellow
    
    $workflows = (Get-ChildItem -Path (Join-Path $agentPath "workflows") -Filter "*.md" -ErrorAction SilentlyContinue).Count
    $skills = (Get-ChildItem -Path (Join-Path $agentPath "skills") -Directory -ErrorAction SilentlyContinue).Count
    $agents = (Get-ChildItem -Path (Join-Path $agentPath "agents") -Filter "*.md" -ErrorAction SilentlyContinue).Count
    
    Write-Host "   📊 Workflows: $workflows" -ForegroundColor Gray
    Write-Host "   🎯 Skills: $skills" -ForegroundColor Gray
    Write-Host "   🤖 Agents: $agents" -ForegroundColor Gray

    # Read version
    $versionFile = Join-Path $agentPath "VERSION"
    if (Test-Path $versionFile) {
        $version = Get-Content $versionFile -Raw
        Write-Host "   📦 Version: $($version.Trim())" -ForegroundColor Gray
    }

}
catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    exit 1
}
finally {
    # Cleanup
    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║    ✅ ANTIGRAVITY-CORE INSTALLED SUCCESSFULLY!             ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "📁 Installed to: $agentPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "🚀 Quick Start:" -ForegroundColor Yellow
Write-Host "   1. Read: .agent/GEMINI.md (AI instructions)" -ForegroundColor White
Write-Host "   2. Read: .agent/INTEGRATION-GUIDE.md (How to use)" -ForegroundColor White
Write-Host "   3. Run:  .\.agent\scripts\health-check.ps1" -ForegroundColor White
Write-Host ""

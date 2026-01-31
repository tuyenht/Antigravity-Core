#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Update UI-UX-Pro-Max skill from upstream GitHub repository

.DESCRIPTION
    This script:
    1. Downloads latest version using uipro-cli
    2. Merges files into .agent/skills/ui-ux-pro-max/
    3. Removes temporary .shared/ folder
    4. Updates paths in workflow file
    5. Prepares for git commit

.EXAMPLE
    .\update-ui-ux-pro-max.ps1

.NOTES
    Requires: npm, uipro-cli
    Source: https://github.com/nextlevelbuilder/ui-ux-pro-max-skill
#>

param(
    [switch]$AutoCommit,
    [string]$Version = "latest"
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     UI-UX-Pro-Max Updater for Antigravity-Core             ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Change to project root
Set-Location $ProjectRoot
Write-Host "📁 Project root: $ProjectRoot" -ForegroundColor Gray

# Step 1: Check uipro-cli
Write-Host ""
Write-Host "Step 1: Checking uipro-cli..." -ForegroundColor Yellow

$uiproInstalled = Get-Command uipro -ErrorAction SilentlyContinue
if (-not $uiproInstalled) {
    Write-Host "   Installing uipro-cli..." -ForegroundColor Gray
    npm install -g uipro-cli
}

# Show available versions
Write-Host "   Available versions:" -ForegroundColor Gray
uipro versions 2>&1 | Select-Object -First 8

# Step 2: Download latest version
Write-Host ""
Write-Host "Step 2: Downloading from upstream..." -ForegroundColor Yellow

uipro init --ai antigravity

# Step 3: Check if .shared exists and merge
Write-Host ""
Write-Host "Step 3: Merging files..." -ForegroundColor Yellow

$sharedPath = Join-Path $ProjectRoot ".shared\ui-ux-pro-max"
$skillPath = Join-Path $ProjectRoot ".agent\skills\ui-ux-pro-max"

if (Test-Path $sharedPath) {
    Write-Host "   Found .shared folder, merging into .agent/skills/..." -ForegroundColor Gray
    
    # Merge data
    $sharedData = Join-Path $sharedPath "data"
    $skillData = Join-Path $skillPath "data"
    if (Test-Path $sharedData) {
        Copy-Item -Path "$sharedData\*" -Destination $skillData -Recurse -Force
        Write-Host "   ✓ Merged data files" -ForegroundColor Green
    }
    
    # Merge scripts
    $sharedScripts = Join-Path $sharedPath "scripts"
    $skillScripts = Join-Path $skillPath "scripts"
    if (Test-Path $sharedScripts) {
        Copy-Item -Path "$sharedScripts\*" -Destination $skillScripts -Recurse -Force
        Write-Host "   ✓ Merged script files" -ForegroundColor Green
    }
    
    # Remove .shared
    Remove-Item -Path (Join-Path $ProjectRoot ".shared") -Recurse -Force
    Write-Host "   ✓ Removed .shared folder" -ForegroundColor Green
} else {
    Write-Host "   No .shared folder found (CLI may have updated directly)" -ForegroundColor Gray
}

# Step 4: Update paths in workflow
Write-Host ""
Write-Host "Step 4: Updating workflow paths..." -ForegroundColor Yellow

$workflowFile = Join-Path $ProjectRoot ".agent\workflows\ui-ux-pro-max.md"
if (Test-Path $workflowFile) {
    $content = Get-Content $workflowFile -Raw
    $updatedContent = $content -replace '\.shared/ui-ux-pro-max', '.agent/skills/ui-ux-pro-max'
    Set-Content $workflowFile -Value $updatedContent -NoNewline
    Write-Host "   ✓ Updated workflow paths" -ForegroundColor Green
}

# Step 5: Summary
Write-Host ""
Write-Host "Step 5: Verification..." -ForegroundColor Yellow

$dataFiles = (Get-ChildItem -Path (Join-Path $skillPath "data") -File -Recurse).Count
$scriptFiles = (Get-ChildItem -Path (Join-Path $skillPath "scripts") -File).Count

Write-Host "   📊 Data files: $dataFiles" -ForegroundColor Gray
Write-Host "   📜 Script files: $scriptFiles" -ForegroundColor Gray

# Step 6: Git status
Write-Host ""
Write-Host "Step 6: Git status..." -ForegroundColor Yellow

$gitStatus = git status --short
if ($gitStatus) {
    Write-Host $gitStatus -ForegroundColor Gray
    
    if ($AutoCommit) {
        git add .
        git commit -m "⬆️ Update UI-UX-Pro-Max skill to latest version"
        git push
        Write-Host ""
        Write-Host "   ✓ Committed and pushed!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "   Run the following to commit:" -ForegroundColor Cyan
        Write-Host '   git add . && git commit -m "⬆️ Update UI-UX-Pro-Max"' -ForegroundColor White
    }
} else {
    Write-Host "   No changes detected (already up to date)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║     ✅ UI-UX-Pro-Max Update Complete!                      ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

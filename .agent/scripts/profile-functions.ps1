#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Antigravity-Core profile functions (loaded by setup-profile.ps1)
    
.DESCRIPTION
    Contains Install-Antigravity, Update-Antigravity, and Update-AntigravityGlobal
    functions with aliases agi, agu, agug.
    
    This file is dot-sourced by setup-profile.ps1 so that agug automatically
    picks up new function definitions without needing to run twice.

.NOTES
    Version: 5.0.0
    Do NOT embed these functions as here-strings in other scripts.
#>

function Install-Antigravity {
    <#
    .SYNOPSIS Install Antigravity-Core to current project
    #>
    param([switch]$Force)
    
    $source = "$env:ANTIGRAVITY_HOME\.agent"
    $target = ".\.agent"
    
    if (-not (Test-Path $source)) {
        Write-Host "❌ Antigravity-Core not found. Run global installer first." -ForegroundColor Red
        return
    }
    
    if (Test-Path $target) {
        if ($Force) {
            Remove-Item -Path $target -Recurse -Force
        }
        else {
            Write-Host "⚠️  .agent already exists. Use -Force to overwrite." -ForegroundColor Yellow
            return
        }
    }
    
    Copy-Item -Path $source -Destination $target -Recurse -Force
    
    # Copy docs if not exists (first install only)
    $sourceDocs = "$env:ANTIGRAVITY_HOME\docs"
    if ((Test-Path $sourceDocs) -and -not (Test-Path ".\docs")) {
        Copy-Item -Path $sourceDocs -Destination ".\docs" -Recurse -Force
    }
    
    $installedVersion = "unknown"
    $vf = Join-Path $target "VERSION"
    if (Test-Path $vf) { $installedVersion = (Get-Content $vf -Raw).Trim() }
    
    Write-Host "✅ Antigravity-Core installed to current project!" -ForegroundColor Green
    Write-Host "   Version: $installedVersion" -ForegroundColor Gray
}

function Update-Antigravity {
    <#
    .SYNOPSIS Update Antigravity-Core in current project from global
    .DESCRIPTION Smart update: preserves project-specific data (usage_tracking, memory)
                 while updating all system files (.agent/, system docs).
    #>
    if (-not (Test-Path ".\.agent")) {
        Write-Host "❌ No .agent folder. Run Install-Antigravity first." -ForegroundColor Red
        return
    }
    
    # Backup memory and read project-specific data
    $backupDir = ".\temp-ag-backup"
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    
    if (Test-Path ".\.agent\memory") {
        Copy-Item -Path ".\.agent\memory" -Destination "$backupDir\memory" -Recurse -Force
    }
    
    # Read old project.json for project-specific fields
    $oldConfig = $null
    if (Test-Path ".\.agent\project.json") {
        try {
            $oldConfig = Get-Content ".\.agent\project.json" -Raw | ConvertFrom-Json
        }
        catch {
            Write-Host "   ⚠️  Could not parse old project.json, skipping merge" -ForegroundColor Yellow
        }
    }
    
    $oldVersion = if ($oldConfig -and $oldConfig.version) { $oldConfig.version } else { "unknown" }
    
    # Remove old and install new
    Remove-Item -Path ".\.agent" -Recurse -Force
    Install-Antigravity
    
    # Restore memory
    if (Test-Path "$backupDir\memory") {
        Copy-Item -Path "$backupDir\memory" -Destination ".\.agent\memory" -Recurse -Force
    }
    
    # Smart merge: preserve only project-specific fields into new project.json
    if ($oldConfig -and (Test-Path ".\.agent\project.json")) {
        try {
            $newConfig = Get-Content ".\.agent\project.json" -Raw | ConvertFrom-Json
            
            # Preserve usage_tracking from old config (project-specific pipeline counts)
            if ($oldConfig.usage_tracking) {
                $newConfig.usage_tracking = $oldConfig.usage_tracking
            }
            
            $newConfig | ConvertTo-Json -Depth 10 | Set-Content ".\.agent\project.json" -Encoding UTF8
        }
        catch {
            Write-Host "   ⚠️  Smart merge failed, using new project.json as-is" -ForegroundColor Yellow
        }
    }
    
    # Selective docs sync: update system docs from global, preserve project-specific docs
    $globalDocs = "$env:ANTIGRAVITY_HOME\docs"
    if (Test-Path $globalDocs) {
        # System docs whitelist - files maintained by Antigravity-Core (safe to overwrite)
        $systemDocs = @(
            "antigravity-complete-project-guide.md",
            "documentation-blueprint.md"
        )
        
        if (-not (Test-Path ".\docs")) {
            # First install: copy entire docs folder
            Copy-Item -Path $globalDocs -Destination ".\docs" -Recurse -Force
            Write-Host "   + docs/ copied (first install)" -ForegroundColor Gray
        }
        else {
            # Update: sync only system docs, preserve project-specific files
            $synced = 0
            foreach ($doc in $systemDocs) {
                $src = Join-Path $globalDocs $doc
                if (Test-Path $src) {
                    Copy-Item -Path $src -Destination ".\docs\$doc" -Force
                    $synced++
                }
            }
            # Also sync _legacy subfolder if it exists
            $legacySrc = Join-Path $globalDocs "_legacy"
            if (Test-Path $legacySrc) {
                Copy-Item -Path $legacySrc -Destination ".\docs\_legacy" -Recurse -Force
            }
            if ($synced -gt 0) {
                Write-Host "   + docs/ synced ($synced system docs updated)" -ForegroundColor Gray
            }
        }
    }
    
    Remove-Item -Path $backupDir -Recurse -Force
    
    $newVersion = "unknown"
    $vf = ".\.agent\VERSION"
    if (Test-Path $vf) { $newVersion = (Get-Content $vf -Raw).Trim() }
    
    Write-Host "✅ Antigravity-Core updated! ($oldVersion → $newVersion)" -ForegroundColor Green
}

function Update-AntigravityGlobal {
    <#
    .SYNOPSIS Update global Antigravity-Core installation
    #>
    & "$env:ANTIGRAVITY_HOME\.agent\scripts\update-global.ps1"
}

# Aliases
Set-Alias agi Install-Antigravity
Set-Alias agu Update-Antigravity
Set-Alias agug Update-AntigravityGlobal

$_agVersion = "unknown"
$_agVersionFile = Join-Path $env:ANTIGRAVITY_HOME ".agent\VERSION"
if (Test-Path $_agVersionFile) { $_agVersion = (Get-Content $_agVersionFile -Raw).Trim() }
Write-Host "🚀 Antigravity-Core loaded (v$_agVersion)" -ForegroundColor DarkGray

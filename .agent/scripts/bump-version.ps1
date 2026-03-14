# Antigravity-Core Version Bump Script (v2.0)
# Usage: pwsh .agent/scripts/bump-version.ps1 -Version "5.1.0"
# Automatically updates ALL version references across the ENTIRE system.
#
# Coverage:
#   - Core: VERSION, GEMINI.md, ARCHITECTURE.md, project.json, reference-catalog.md
#   - Systems: All 6 system files (agent-registry, orchestration-engine, etc.)
#   - Templates: agent-template-v5, AGENT-CREATION-GUIDE, project-bootstrap, etc.
#   - Docs: All process, agent, skill, script, workflow, and system docs
#   - Rules: standards/supply-chain-security, standards/frameworks/*

param(
    [Parameter(Mandatory = $true)]
    [string]$Version,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# Validate semver format
if ($Version -notmatch '^\d+\.\d+\.\d+$') {
    Write-Host "[ERROR] Invalid version format: $Version (expected: X.Y.Z)" -ForegroundColor Red
    exit 1
}

$today = Get-Date -Format "yyyy-MM-dd"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Antigravity-Core Version Bump v2.0" -ForegroundColor Cyan
Write-Host "  Target: $Version" -ForegroundColor Cyan
if ($DryRun) { Write-Host "  Mode: DRY RUN" -ForegroundColor Yellow }
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# PHASE 1: Core files (explicit patterns)
# ============================================
Write-Host "--- Phase 1: Core Files ---" -ForegroundColor Cyan

$coreFiles = @(
    @{ Path = ".agent\VERSION"; Type = "version_only" },
    @{ Path = ".agent\GEMINI.md"; Pattern = 'Version \d+\.\d+\.\d+'; Replace = "Version $Version" },
    @{ Path = ".agent\ARCHITECTURE.md"; Pattern = 'Version:\*\* \d+\.\d+\.\d+'; Replace = "Version:** $Version" },
    @{ Path = ".agent\reference-catalog.md"; Pattern = 'Version:\*\* \d+\.\d+\.\d+'; Replace = "Version:** $Version" },
    @{ Path = ".agent\project.json"; Pattern = '"version": "\d+\.\d+\.\d+"'; Replace = "`"version`": `"$Version`"" }
)

$updated = 0

foreach ($file in $coreFiles) {
    $path = $file.Path
    if (-not (Test-Path $path)) {
        Write-Host "  [SKIP] $path (not found)" -ForegroundColor Yellow
        continue
    }

    if ($file.Type -eq "version_only") {
        if (-not $DryRun) {
            Set-Content $path -Value "$Version`n" -NoNewline -Encoding UTF8
        }
        Write-Host "  [UPDATED] $path" -ForegroundColor Green
        $updated++
        continue
    }

    $content = Get-Content $path -Raw -Encoding UTF8
    $newContent = $content -replace $file.Pattern, $file.Replace
    if ($content -ne $newContent) {
        if (-not $DryRun) {
            Set-Content $path -Value $newContent -NoNewline -Encoding UTF8
        }
        Write-Host "  [UPDATED] $path" -ForegroundColor Green
        $updated++
    } else {
        Write-Host "  [NO CHANGE] $path" -ForegroundColor Gray
    }
}

# ============================================
# PHASE 2: Broad scan (systems, docs, templates, rules)
# ============================================
Write-Host ""
Write-Host "--- Phase 2: Broad Scan ---" -ForegroundColor Cyan

$scanDirs = @(
    ".agent\systems",
    ".agent\templates",
    ".agent\docs",
    ".agent\rules\standards"
)

foreach ($dir in $scanDirs) {
    if (-not (Test-Path $dir)) { continue }

    $mdFiles = Get-ChildItem $dir -Filter "*.md" -Recurse -File
    foreach ($mdFile in $mdFiles) {
        $content = Get-Content $mdFile.FullName -Raw -Encoding UTF8
        $newContent = $content

        # Pattern 1: **Version:** X.Y.Z
        $newContent = $newContent -replace '(\*\*Version:\*\*\s*)\d+\.\d+\.\d+', "`${1}$Version"

        # Pattern 2: Antigravity-Core: vX.Y.Z or Antigravity-Core v X.Y.Z
        $newContent = $newContent -replace '(Antigravity-Core[:\s]+v?)\d+\.\d+\.\d+', "`${1}$Version"

        # Pattern 3: **System:** Antigravity-Core vX.Y.Z
        $newContent = $newContent -replace '(\*\*System:\*\*\s*Antigravity-Core\s+v?)\d+\.\d+\.\d+', "`${1}$Version"

        if ($content -ne $newContent) {
            if (-not $DryRun) {
                Set-Content $mdFile.FullName -Value $newContent -NoNewline -Encoding UTF8
            }
            $relPath = $mdFile.FullName.Replace((Get-Location).Path + "\", "")
            Write-Host "  [UPDATED] $relPath" -ForegroundColor Green
            $updated++
        }
    }
}

# ============================================
# PHASE 3: Date updates
# ============================================
Write-Host ""
Write-Host "--- Phase 3: Date Updates ---" -ForegroundColor Cyan

$dateFiles = @(
    @{ Path = ".agent\ARCHITECTURE.md"; Pattern = 'Last Updated:\*\* \d{4}-\d{2}-\d{2}'; Replace = "Last Updated:** $today" },
    @{ Path = ".agent\reference-catalog.md"; Pattern = 'Updated:\*\* \d{4}-\d{2}-\d{2}'; Replace = "Updated:** $today" },
    @{ Path = ".agent\project.json"; Pattern = '"last_updated": "\d{4}-\d{2}-\d{2}"'; Replace = "`"last_updated`": `"$today`"" }
)

foreach ($file in $dateFiles) {
    if (Test-Path $file.Path) {
        $content = Get-Content $file.Path -Raw -Encoding UTF8
        $newContent = $content -replace $file.Pattern, $file.Replace
        if ($content -ne $newContent -and -not $DryRun) {
            Set-Content $file.Path -Value $newContent -NoNewline -Encoding UTF8
            Write-Host "  [DATE] $($file.Path)" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Done! $updated files updated to $Version" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Update CHANGELOG.md with new entry" -ForegroundColor White
Write-Host "  2. git add -A && git commit -m `"release: v$Version`"" -ForegroundColor White
Write-Host "  3. git tag v$Version && git push --tags" -ForegroundColor White

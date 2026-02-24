# Antigravity-Core Version Bump Script
# Usage: pwsh .agent/scripts/bump-version.ps1 -Version "4.1.0"
# Automatically updates ALL version references across the system.

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

$files = @(
    @{ Path = ".agent\VERSION"; Pattern = '.*'; Replace = $Version },
    @{ Path = ".agent\GEMINI.md"; Pattern = 'Version \d+\.\d+\.\d+'; Replace = "Version $Version" },
    @{ Path = ".agent\ARCHITECTURE.md"; Pattern = 'Version:\*\* \d+\.\d+\.\d+'; Replace = "Version:** $Version" },
    @{ Path = ".agent\project.json"; Pattern = '"version": "\d+\.\d+\.\d+"'; Replace = "`"version`": `"$Version`"" },
    @{ Path = ".agent\rules\RULES-INDEX.md"; Pattern = 'Version:\*\* \d+\.\d+\.\d+'; Replace = "Version:** $Version" }
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Antigravity-Core Version Bump" -ForegroundColor Cyan
Write-Host "  Target: $Version" -ForegroundColor Cyan
if ($DryRun) { Write-Host "  Mode: DRY RUN" -ForegroundColor Yellow }
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$updated = 0
$failed = 0

foreach ($file in $files) {
    $path = $file.Path

    if (-not (Test-Path $path)) {
        Write-Host "[SKIP] $path (not found)" -ForegroundColor Yellow
        continue
    }

    $content = Get-Content $path -Raw -Encoding UTF8

    # Special case: VERSION file is just the version string
    if ($path -eq ".agent\VERSION") {
        $newContent = "$Version`n"
    }
    # Special case: project.json — update first occurrence only (root version)
    elseif ($path -eq ".agent\project.json") {
        $newContent = $content -replace $file.Pattern, $file.Replace
    }
    else {
        $newContent = $content -replace $file.Pattern, $file.Replace
    }

    if ($content -ne $newContent) {
        if ($DryRun) {
            Write-Host "[WOULD UPDATE] $path" -ForegroundColor Yellow
        }
        else {
            Set-Content $path -Value $newContent -NoNewline -Encoding UTF8
            Write-Host "[UPDATED] $path" -ForegroundColor Green
        }
        $updated++
    }
    else {
        Write-Host "[NO CHANGE] $path (already $Version)" -ForegroundColor Gray
    }
}

# Update dates
$today = Get-Date -Format "yyyy-MM-dd"
$dateFiles = @(
    @{ Path = ".agent\ARCHITECTURE.md"; Pattern = 'Last Updated:\*\* \d{4}-\d{2}-\d{2}'; Replace = "Last Updated:** $today" },
    @{ Path = ".agent\rules\RULES-INDEX.md"; Pattern = 'Updated:\*\* \d{4}-\d{2}-\d{2}'; Replace = "Updated:** $today" },
    @{ Path = ".agent\project.json"; Pattern = '"last_updated": "\d{4}-\d{2}-\d{2}"'; Replace = "`"last_updated`": `"$today`"" }
)

Write-Host ""
Write-Host "Updating dates to $today..." -ForegroundColor Cyan

foreach ($file in $dateFiles) {
    if (Test-Path $file.Path) {
        $content = Get-Content $file.Path -Raw -Encoding UTF8
        $newContent = $content -replace $file.Pattern, $file.Replace
        if ($content -ne $newContent -and -not $DryRun) {
            Set-Content $file.Path -Value $newContent -NoNewline -Encoding UTF8
            Write-Host "[DATE] $($file.Path)" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Done! $updated files updated." -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Update CHANGELOG.md with new entry" -ForegroundColor White
Write-Host "  2. git add -A && git commit -m `"release: v$Version`"" -ForegroundColor White
Write-Host "  3. git tag v$Version && git push --tags" -ForegroundColor White

# lint-npm-references.ps1
# Scans .agent/ directory for actionable npm commands that should be pnpm
# Run periodically or in CI to prevent npm drift

$ErrorActionPreference = "Stop"
$agentDir = Join-Path $PSScriptRoot "..\.."

Write-Host "🔍 Scanning for npm references in actionable contexts..." -ForegroundColor Cyan

# Patterns to detect (actionable commands)
$patterns = @(
    '`npm run ',
    '`npm install ',
    '`npm create ',
    '`npm init'
    '`npm start`'
)

# Files/patterns to exclude (acceptable)
$excludePatterns = @(
    'npm audit',      # Industry standard term
    'npm test',       # Multi-stack context
    'npm link',       # No pnpm equivalent commonly used
    'CHANGELOG.md'    # Historical records
)

$violations = @()

Get-ChildItem -Path $agentDir -Filter '*.md' -Recurse -File | ForEach-Object {
    $file = $_
    $relativePath = $file.FullName.Replace("$agentDir\", "")
    
    # Skip CHANGELOG
    if ($relativePath -match 'CHANGELOG') { return }
    
    $lineNum = 0
    Get-Content $file.FullName | ForEach-Object {
        $lineNum++
        $line = $_
        
        foreach ($pattern in $patterns) {
            if ($line -match [regex]::Escape($pattern)) {
                # Check if it's in an exclude pattern context
                $excluded = $false
                foreach ($ex in $excludePatterns) {
                    if ($line -match [regex]::Escape($ex)) {
                        $excluded = $true
                        break
                    }
                }
                
                if (-not $excluded) {
                    $violations += [PSCustomObject]@{
                        File = $relativePath
                        Line = $lineNum
                        Content = $line.Trim()
                    }
                }
            }
        }
    }
}

if ($violations.Count -eq 0) {
    Write-Host "✅ No npm violations found. System is 100% pnpm-compliant." -ForegroundColor Green
    exit 0
} else {
    Write-Host "⚠️ Found $($violations.Count) npm violation(s):" -ForegroundColor Yellow
    $violations | Format-Table -AutoSize
    exit 1
}

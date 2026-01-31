# Auto-Healing Script
# Automatically fix common issues (lint, syntax, imports)
# References: .agent/auto-healing.yml

param(
    [switch]$DryRun,
    [switch]$Lint,
    [switch]$Imports,
    [switch]$Types,
    [switch]$All,
    [string]$File,
    [switch]$Help
)

# Colors
$Red = "Red"
$Yellow = "Yellow"
$Green = "Green"
$Cyan = "Cyan"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Show-Help {
    Write-ColorOutput "Auto-Healing Script" $Cyan
    Write-ColorOutput "===================" $Cyan
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\auto-heal.ps1 -All        # Fix all auto-healable issues"
    Write-Host "  .\auto-heal.ps1 -Lint       # Fix lint issues only"
    Write-Host "  .\auto-heal.ps1 -Imports    # Fix import issues only"
    Write-Host "  .\auto-heal.ps1 -Types      # Fix type issues only"
    Write-Host "  .\auto-heal.ps1 -DryRun     # Show what would be fixed (no changes)"
    Write-Host "  .\auto-heal.ps1 -File <path>  # Fix specific file"
    Write-Host "  .\auto-heal.ps1 -Help       # Show this help"
    Write-Host ""
}

$MaxIterations = 3
$CurrentIteration = 0
$FixedCount = 0
$FailedCount = 0

# Log file
$LogFile = ".agent/memory/auto-heal-log.json"

function Log-Action {
    param(
        [string]$Action,
        [string]$File,
        [string]$Issue,
        [string]$Status
    )
    
    $entry = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        action    = $Action
        file      = $File
        issue     = $Issue
        status    = $Status
    }
    
    # Append to log (simplified)
    $logDir = Split-Path $LogFile
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
}

function Fix-PHPLint {
    Write-ColorOutput "🔧 Fixing PHP Lint Issues..." $Cyan
    
    $pintPath = ".\vendor\bin\pint"
    
    if (-not (Test-Path $pintPath)) {
        Write-Host "  ⚠️ Laravel Pint not found. Install with: composer require laravel/pint --dev"
        return 0
    }
    
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would run: $pintPath"
        & $pintPath --test 2>&1 | Out-Null
        $result = $LASTEXITCODE
        if ($result -eq 0) {
            Write-Host "  ✅ No PHP lint issues found"
        }
        else {
            Write-Host "  ℹ️ PHP lint issues would be fixed"
        }
        return 0
    }
    
    Write-Host "  Running Laravel Pint..."
    & $pintPath 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "  ✅ PHP lint issues fixed" $Green
        return 1
    }
    else {
        Write-ColorOutput "  ❌ PHP lint fix failed" $Red
        return 0
    }
}

function Fix-JSLint {
    Write-ColorOutput "🔧 Fixing JavaScript/TypeScript Lint Issues..." $Cyan
    
    $eslintPath = ".\node_modules\.bin\eslint"
    
    if (-not (Test-Path $eslintPath)) {
        Write-Host "  ⚠️ ESLint not found. Install with: npm install eslint --save-dev"
        return 0
    }
    
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would run: npm run lint -- --fix"
        return 0
    }
    
    Write-Host "  Running ESLint with --fix..."
    npm run lint -- --fix 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "  ✅ JS/TS lint issues fixed" $Green
        return 1
    }
    else {
        Write-ColorOutput "  ⚠️ Some JS/TS lint issues remain (may need manual fix)" $Yellow
        return 0
    }
}

function Fix-TypeErrors {
    Write-ColorOutput "🔧 Checking Type Errors..." $Cyan
    
    # PHP - PHPStan
    $phpstanPath = ".\vendor\bin\phpstan"
    $hasPhpstan = Test-Path $phpstanPath
    
    # TypeScript - tsc
    $tscPath = ".\node_modules\.bin\tsc"
    $hasTsc = Test-Path $tscPath
    
    if ($hasPhpstan) {
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would run: $phpstanPath analyse"
        }
        else {
            Write-Host "  Running PHPStan..."
            & $phpstanPath analyse 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "  ✅ No PHP type errors" $Green
            }
            else {
                Write-ColorOutput "  ⚠️ PHP type errors found (manual fix needed)" $Yellow
            }
        }
    }
    
    if ($hasTsc) {
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would run: npx tsc --noEmit"
        }
        else {
            Write-Host "  Running TypeScript check..."
            npx tsc --noEmit 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "  ✅ No TypeScript errors" $Green
            }
            else {
                Write-ColorOutput "  ⚠️ TypeScript errors found (manual fix needed)" $Yellow
            }
        }
    }
    
    if (-not $hasPhpstan -and -not $hasTsc) {
        Write-Host "  ⚠️ No type checkers found. Install PHPStan or TypeScript."
    }
    
    return 0
}

function Fix-Imports {
    Write-ColorOutput "🔧 Fixing Import Issues..." $Cyan
    
    # For now, ESLint --fix handles import sorting
    # Could add more sophisticated import fixing here
    
    if ($DryRun) {
        Write-Host "  [DRY RUN] Import fixes handled by ESLint"
        return 0
    }
    
    # Check for unused imports via ESLint
    Write-Host "  Import fixes handled by lint step"
    return 0
}

function Run-Healing {
    param([int]$Iteration)
    
    Write-Host ""
    Write-ColorOutput "━━━ Iteration $Iteration of $MaxIterations ━━━" $Cyan
    Write-Host ""
    
    $fixedThisRound = 0
    
    if ($All -or $Lint -or (-not $Lint -and -not $Types -and -not $Imports)) {
        $fixedThisRound += Fix-PHPLint
        $fixedThisRound += Fix-JSLint
    }
    
    if ($All -or $Imports) {
        $fixedThisRound += Fix-Imports
    }
    
    if ($All -or $Types) {
        $fixedThisRound += Fix-TypeErrors
    }
    
    return $fixedThisRound
}

function Verify-Fixes {
    Write-Host ""
    Write-ColorOutput "🔍 Verifying fixes..." $Cyan
    
    $allPassed = $true
    
    # Check lint
    if (Test-Path ".\vendor\bin\pint") {
        & .\vendor\bin\pint --test 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  ⚠️ PHP lint still has issues"
            $allPassed = $false
        }
        else {
            Write-Host "  ✅ PHP lint passed"
        }
    }
    
    # Check JS lint
    npm run lint -- --quiet 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ⚠️ JS/TS lint still has issues"
        $allPassed = $false
    }
    else {
        Write-Host "  ✅ JS/TS lint passed"
    }
    
    return $allPassed
}

# Main execution
if ($Help) {
    Show-Help
    exit 0
}

Write-ColorOutput "🔧 Auto-Healing Started" $Cyan
Write-ColorOutput "=======================" $Cyan

if ($DryRun) {
    Write-ColorOutput "[DRY RUN MODE - No changes will be made]" $Yellow
    Write-Host ""
}

# Run healing iterations
$totalFixed = 0
for ($i = 1; $i -le $MaxIterations; $i++) {
    $fixed = Run-Healing $i
    $totalFixed += $fixed
    
    if ($fixed -eq 0) {
        Write-Host ""
        Write-Host "No more issues to fix. Stopping early."
        break
    }
}

# Verify
if (-not $DryRun) {
    $verified = Verify-Fixes
}

# Summary
Write-Host ""
Write-ColorOutput "📊 Auto-Healing Summary" $Cyan
Write-ColorOutput "=======================" $Cyan
Write-Host "Iterations run: $i of $MaxIterations"
Write-Host "Issues fixed: $totalFixed"

if ($DryRun) {
    Write-ColorOutput "Mode: DRY RUN (no changes made)" $Yellow
}
elseif ($verified) {
    Write-ColorOutput "✅ Auto-Healing: SUCCESS" $Green
    Write-Host "All auto-fixable issues resolved."
    exit 0
}
else {
    Write-ColorOutput "⚠️ Auto-Healing: PARTIAL" $Yellow
    Write-Host "Some issues remain. May need manual intervention."
    Write-Host ""
    Write-Host "To escalate:"
    Write-Host "  1. Review remaining errors above"
    Write-Host "  2. Fix manually or ask ai-code-reviewer for help"
    exit 1
}

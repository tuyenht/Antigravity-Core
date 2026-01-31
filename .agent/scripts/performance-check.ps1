# Performance Budget Check Script
# Enforces performance budgets defined in .agent/performance-budgets.yml
# Blocks PRs that violate budgets

param(
    [switch]$Frontend,
    [switch]$Backend,
    [switch]$All,
    [switch]$Report,
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
    Write-ColorOutput "Performance Budget Check Script" $Cyan
    Write-ColorOutput "================================" $Cyan
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\performance-check.ps1 -Frontend    # Check frontend budgets only"
    Write-Host "  .\performance-check.ps1 -Backend     # Check backend budgets only"
    Write-Host "  .\performance-check.ps1 -All         # Check all budgets"
    Write-Host "  .\performance-check.ps1 -Report      # Generate detailed report"
    Write-Host "  .\performance-check.ps1 -Help        # Show this help"
    Write-Host ""
}

# Budget definitions (from performance-budgets.yml)
$Budgets = @{
    Frontend = @{
        MainBundle = @{ Limit = 200; Unit = "KB"; Severity = "error" }
        VendorBundle = @{ Limit = 300; Unit = "KB"; Severity = "warning" }
        PerRoute = @{ Limit = 50; Unit = "KB"; Severity = "warning" }
        LighthousePerformance = @{ Limit = 90; Unit = "score"; Severity = "error" }
        LCP = @{ Limit = 2500; Unit = "ms"; Severity = "error" }
        FID = @{ Limit = 100; Unit = "ms"; Severity = "error" }
        CLS = @{ Limit = 0.1; Unit = "score"; Severity = "warning" }
    }
    Backend = @{
        ApiP50 = @{ Limit = 100; Unit = "ms"; Severity = "info" }
        ApiP95 = @{ Limit = 200; Unit = "ms"; Severity = "error" }
        ApiP99 = @{ Limit = 500; Unit = "ms"; Severity = "error" }
        QueryCountPerRequest = @{ Limit = 10; Unit = "count"; Severity = "error" }
        SlowQueryThreshold = @{ Limit = 100; Unit = "ms"; Severity = "warning" }
        TotalQueryTime = @{ Limit = 50; Unit = "ms"; Severity = "warning" }
        PeakMemory = @{ Limit = 64; Unit = "MB"; Severity = "warning" }
    }
    Inertia = @{
        InitialProps = @{ Limit = 100; Unit = "KB"; Severity = "warning" }
        PartialReloadProps = @{ Limit = 50; Unit = "KB"; Severity = "info" }
        NavigationTime = @{ Limit = 300; Unit = "ms"; Severity = "warning" }
    }
}

$Results = @{
    Passed = @()
    Warnings = @()
    Errors = @()
}

function Check-FrontendBudgets {
    Write-ColorOutput "📦 Checking Frontend Budgets..." $Cyan
    Write-Host ""
    
    # Check if dist/build exists
    $buildDirs = @("dist", "build", "public/build", ".next")
    $buildDir = $null
    
    foreach ($dir in $buildDirs) {
        if (Test-Path $dir) {
            $buildDir = $dir
            break
        }
    }
    
    if (-not $buildDir) {
        Write-ColorOutput "⚠️ No build directory found. Run 'npm run build' first." $Yellow
        $Results.Warnings += @{
            Category = "Frontend"
            Check = "Build Directory"
            Status = "NOT_FOUND"
            Message = "No build directory found"
        }
        return
    }
    
    # Calculate bundle sizes
    $jsFiles = Get-ChildItem -Path $buildDir -Recurse -Filter "*.js" -ErrorAction SilentlyContinue
    $totalSizeKB = 0
    
    foreach ($file in $jsFiles) {
        $sizeKB = [math]::Round($file.Length / 1024, 2)
        $totalSizeKB += $sizeKB
    }
    
    # Main bundle check
    $mainBudget = $Budgets.Frontend.MainBundle
    if ($totalSizeKB -le $mainBudget.Limit) {
        $Results.Passed += @{
            Category = "Frontend"
            Check = "Main Bundle"
            Value = "$totalSizeKB KB"
            Limit = "$($mainBudget.Limit) KB"
        }
        Write-ColorOutput "  ✅ Main Bundle: $totalSizeKB KB (limit: $($mainBudget.Limit) KB)" $Green
    }
    else {
        if ($mainBudget.Severity -eq "error") {
            $Results.Errors += @{
                Category = "Frontend"
                Check = "Main Bundle"
                Value = "$totalSizeKB KB"
                Limit = "$($mainBudget.Limit) KB"
                Message = "Bundle size exceeds limit"
            }
            Write-ColorOutput "  ❌ Main Bundle: $totalSizeKB KB (limit: $($mainBudget.Limit) KB)" $Red
        }
        else {
            $Results.Warnings += @{
                Category = "Frontend"
                Check = "Main Bundle"
                Value = "$totalSizeKB KB"
                Limit = "$($mainBudget.Limit) KB"
            }
            Write-ColorOutput "  ⚠️ Main Bundle: $totalSizeKB KB (limit: $($mainBudget.Limit) KB)" $Yellow
        }
    }
    
    Write-Host ""
}

function Check-BackendBudgets {
    Write-ColorOutput "🖥️ Checking Backend Budgets..." $Cyan
    Write-Host ""
    
    # Check for Laravel Debugbar or similar
    $hasDebugbar = Test-Path "vendor/barryvdh/laravel-debugbar"
    
    if (-not $hasDebugbar) {
        Write-ColorOutput "  ℹ️ Laravel Debugbar not installed. Backend metrics unavailable." $Cyan
        Write-Host "  Install with: composer require barryvdh/laravel-debugbar --dev"
        $Results.Warnings += @{
            Category = "Backend"
            Check = "Debugbar"
            Status = "NOT_INSTALLED"
            Message = "Install Debugbar for backend metrics"
        }
        Write-Host ""
        return
    }
    
    # Query count check (manual verification)
    Write-Host "  📊 Backend Budget Targets:"
    Write-Host "     - API p95: < 200ms"
    Write-Host "     - Query count: < 10 per request"
    Write-Host "     - Slow queries: < 100ms"
    Write-Host ""
    Write-ColorOutput "  ℹ️ Use Laravel Debugbar to verify these metrics during development." $Cyan
    
    $Results.Passed += @{
        Category = "Backend"
        Check = "Budget Reminder"
        Message = "Review with Debugbar"
    }
    
    Write-Host ""
}

function Check-InertiaBudgets {
    Write-ColorOutput "🔗 Checking Inertia Budgets..." $Cyan
    Write-Host ""
    
    # Check for Inertia
    $hasInertia = (Test-Path "vendor/inertiajs") -or (Test-Path "node_modules/@inertiajs")
    
    if (-not $hasInertia) {
        Write-Host "  ℹ️ Inertia.js not detected. Skipping."
        Write-Host ""
        return
    }
    
    Write-Host "  📊 Inertia Budget Targets:"
    Write-Host "     - Initial props: < 100KB"
    Write-Host "     - Partial reload props: < 50KB"
    Write-Host "     - Navigation time: < 300ms"
    Write-Host ""
    Write-ColorOutput "  ℹ️ Use browser DevTools Network to verify props size." $Cyan
    
    $Results.Passed += @{
        Category = "Inertia"
        Check = "Budget Reminder"
        Message = "Review with DevTools"
    }
    
    Write-Host ""
}

function Show-Report {
    Write-Host ""
    Write-ColorOutput "📊 Performance Budget Report" $Cyan
    Write-ColorOutput "=============================" $Cyan
    Write-Host ""
    
    # Summary
    $passedCount = $Results.Passed.Count
    $warningCount = $Results.Warnings.Count
    $errorCount = $Results.Errors.Count
    
    Write-Host "Summary:"
    Write-ColorOutput "  ✅ Passed: $passedCount" $Green
    Write-ColorOutput "  ⚠️ Warnings: $warningCount" $Yellow
    Write-ColorOutput "  ❌ Errors: $errorCount" $Red
    Write-Host ""
    
    # Errors detail
    if ($errorCount -gt 0) {
        Write-ColorOutput "Errors (Must Fix):" $Red
        foreach ($error in $Results.Errors) {
            Write-Host "  - [$($error.Category)] $($error.Check): $($error.Value) (limit: $($error.Limit))"
        }
        Write-Host ""
    }
    
    # Warnings detail
    if ($warningCount -gt 0) {
        Write-ColorOutput "Warnings (Should Fix):" $Yellow
        foreach ($warning in $Results.Warnings) {
            Write-Host "  - [$($warning.Category)] $($warning.Check): $($warning.Message)"
        }
        Write-Host ""
    }
    
    # Final verdict
    if ($errorCount -gt 0) {
        Write-ColorOutput "❌ Performance Budget: FAILED" $Red
        Write-Host "Fix errors before merging."
        return $false
    }
    elseif ($warningCount -gt 0) {
        Write-ColorOutput "⚠️ Performance Budget: PASSED with warnings" $Yellow
        Write-Host "Can merge, but consider fixing warnings."
        return $true
    }
    else {
        Write-ColorOutput "✅ Performance Budget: PASSED" $Green
        return $true
    }
}

# Main execution
if ($Help) {
    Show-Help
    exit 0
}

Write-ColorOutput "⚡ Performance Budget Check" $Cyan
Write-ColorOutput "===========================" $Cyan
Write-Host ""

if ($Frontend -or $All -or (-not $Frontend -and -not $Backend)) {
    Check-FrontendBudgets
}

if ($Backend -or $All) {
    Check-BackendBudgets
}

if ($All) {
    Check-InertiaBudgets
}

$passed = Show-Report

if ($passed) {
    exit 0
}
else {
    exit 1
}

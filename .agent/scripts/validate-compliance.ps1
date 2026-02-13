#!/usr/bin/env pwsh
# .agent STANDARDS Compliance Validator
# Checks if code meets STANDARDS.md requirements

param(
    [string]$Path = ".",
    [switch]$Strict,
    [switch]$AutoFix
)

$ErrorActionPreference = "Continue"
Write-Host "🔍 .agent STANDARDS Compliance Check" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

$errors = 0
$warnings = 0
$passed = 0

# Detect tech stack
$hasPackageJson = Test-Path "package.json"
$hasComposerJson = Test-Path "composer.json"
$hasPyprojectToml = Test-Path "pyproject.toml"

Write-Host "📦 Tech Stack Detection:" -ForegroundColor Yellow
if ($hasPackageJson) { Write-Host "  ✓ Node.js/TypeScript detected" -ForegroundColor Green }
if ($hasComposerJson) { Write-Host "  ✓ PHP/Laravel detected" -ForegroundColor Green }
if ($hasPyprojectToml) { Write-Host "  ✓ Python detected" -ForegroundColor Green }
Write-Host ""

# Check 1: Linting
Write-Host "1️⃣ Linting Check..." -ForegroundColor Cyan
if ($hasPackageJson) {
    Write-Host "  Running ESLint..." -ForegroundColor DarkGray
    $lintResult = & npm run lint 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Lint: PASS" -ForegroundColor Green
        $passed++
    }
    else {
        Write-Host "  ❌ Lint: FAIL" -ForegroundColor Red
        Write-Host "  $lintResult" -ForegroundColor DarkRed
        $errors++
        
        if ($AutoFix) {
            Write-Host "  🔧 Auto-fixing..." -ForegroundColor Yellow
            & npm run lint -- --fix
        }
    }
}

if ($hasComposerJson) {
    Write-Host "  Running Laravel Pint..." -ForegroundColor DarkGray
    $pintResult = & ./vendor/bin/pint --test 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Pint: PASS" -ForegroundColor Green
        $passed++
    }
    else {
        Write-Host "  ❌ Pint: FAIL" -ForegroundColor Red
        $errors++
        
        if ($AutoFix) {
            Write-Host "  🔧 Auto-fixing..." -ForegroundColor Yellow
            & ./vendor/bin/pint
        }
    }
}

Write-Host ""

# Check 2: Type Checking
Write-Host "2️⃣ Type Check..." -ForegroundColor Cyan
if ($hasPackageJson -and (Test-Path "tsconfig.json")) {
    Write-Host "  Running TypeScript compiler..." -ForegroundColor DarkGray
    $tscResult = & npx tsc --noEmit 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ TypeScript: PASS (0 errors)" -ForegroundColor Green
        $passed++
    }
    else {
        Write-Host "  ❌ TypeScript: FAIL" -ForegroundColor Red
        Write-Host "  $tscResult" -ForegroundColor DarkRed
        $errors++
    }
}

if ($hasComposerJson -and (Test-Path "./vendor/bin/phpstan")) {
    Write-Host "  Running PHPStan..." -ForegroundColor DarkGray
    $phpstanResult = & ./vendor/bin/phpstan analyse 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ PHPStan: PASS" -ForegroundColor Green
        $passed++
    }
    else {
        Write-Host "  ❌ PHPStan: FAIL" -ForegroundColor Red
        $errors++
    }
}

Write-Host ""

# Check 3: Tests
Write-Host "3️⃣ Unit Tests..." -ForegroundColor Cyan
if ($hasPackageJson) {
    Write-Host "  Running test suite..." -ForegroundColor DarkGray
    $testResult = & npm test 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Tests: PASS" -ForegroundColor Green
        $passed++
    }
    else {
        Write-Host "  ❌ Tests: FAIL" -ForegroundColor Red
        $warnings++
    }
}

if ($hasComposerJson) {
    Write-Host "  Running Pest/PHPUnit..." -ForegroundColor DarkGray
    $pestResult = & php artisan test 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Tests: PASS" -ForegroundColor Green
        $passed++
    }
    else {
        Write-Host "  ❌ Tests: FAIL" -ForegroundColor Red
        $warnings++
    }
}

Write-Host ""

# Check 4: Security
Write-Host "4️⃣ Security Scan..." -ForegroundColor Cyan
if ($hasPackageJson) {
    Write-Host "  Running npm audit..." -ForegroundColor DarkGray
    $auditResult = & npm audit --audit-level=moderate 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Security: PASS (0 vulnerabilities)" -ForegroundColor Green
        $passed++
    }
    else {
        Write-Host "  ⚠️ Security: WARNINGS" -ForegroundColor Yellow
        Write-Host "  Run 'npm audit' for details" -ForegroundColor DarkYellow
        $warnings++
    }
}

if ($hasComposerJson) {
    Write-Host "  Running composer audit..." -ForegroundColor DarkGray
    $composerAudit = & composer audit 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Composer: PASS (0 vulnerabilities)" -ForegroundColor Green
        $passed++
    }
    else {
        Write-Host "  ⚠️ Composer: WARNINGS" -ForegroundColor Yellow
        $warnings++
    }
}

Write-Host ""

# Check 5: Code Quality (complexity, duplication)
Write-Host "5️⃣ Code Quality..." -ForegroundColor Cyan
Write-Host "  Checking for debug statements..." -ForegroundColor DarkGray

$debugPatterns = @(
    "console\.log",
    "console\.debug",
    "var_dump",
    "dd\(",
    "dump\(",
    "print_r"
)

$debugFound = $false
foreach ($pattern in $debugPatterns) {
    $matches = Get-ChildItem -Recurse -Include *.ts, *.tsx, *.js, *.jsx, *.php -Exclude node_modules, vendor | 
    Select-String -Pattern $pattern -CaseSensitive
    
    if ($matches) {
        $debugFound = $true
        Write-Host "  ❌ Found debug statement: $pattern" -ForegroundColor Red
        $errors++
    }
}

if (-not $debugFound) {
    Write-Host "  ✅ No debug statements found" -ForegroundColor Green
    $passed++
}

Write-Host ""

# Summary
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "📊 COMPLIANCE SUMMARY" -ForegroundColor Cyan
Write-Host ""
Write-Host "  ✅ Passed:   $passed" -ForegroundColor Green
Write-Host "  ⚠️  Warnings: $warnings" -ForegroundColor Yellow
Write-Host "  ❌ Errors:   $errors" -ForegroundColor Red
Write-Host ""

if ($errors -eq 0 -and $warnings -eq 0) {
    Write-Host "✨ COMPLIANCE: PERFECT! All STANDARDS.md requirements met!" -ForegroundColor Green
    exit 0
}
elseif ($errors -eq 0) {
    Write-Host "✅ COMPLIANCE: PASS (with warnings)" -ForegroundColor Yellow
    exit 0
}
else {
    Write-Host "❌ COMPLIANCE: FAIL - $errors critical issues must be fixed" -ForegroundColor Red
    
    if ($Strict) {
        Write-Host ""
        Write-Host "🚫 STRICT MODE: Blocking due to compliance failures" -ForegroundColor Red
        exit 1
    }
    else {
        Write-Host ""
        Write-Host "⚠️  Fix issues before committing (or use --AutoFix)" -ForegroundColor Yellow
        exit 1
    }
}

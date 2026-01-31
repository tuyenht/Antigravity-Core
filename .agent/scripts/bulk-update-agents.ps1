# Bulk Update Agents - NO EMOJIS VERSION
# Updates all agents to include STANDARDS + RBA references

$agentsToUpdate = @(
    "frontend-specialist.md",
    "laravel-specialist.md",
    "database-architect.md",
    "security-auditor.md",
    "performance-optimizer.md",
    "test-engineer.md",
    "documentation-writer.md",
    "devops-engineer.md",
    "mobile-developer.md",
    "project-planner.md",
    "orchestrator.md",
    "debugger.md",
    "explorer-agent.md",
    "penetration-tester.md",
    "seo-specialist.md",
    "game-designer.md",
    "mobile-game-developer.md",
    "pc-game-developer.md"
)

$updateSection = @"


---

## Golden Rule Compliance

**You MUST follow:** ``.agent/rules/STANDARDS.md``

Before delivering ANY code, run self-check:
1. Linter: Stack-specific command (npm run lint, pint, ruff check)
2. Type check: Stack-specific (tsc --noEmit, phpstan, mypy)
3. Tests: Run test suite (npm test, pest, pytest)
4. Security: Dependency scan (npm audit, composer audit)
5. Quality report: See STANDARDS.md section 5.3

If ANY fails - Fix before delivery OR ask user

---

## Reasoning-Before-Action (MANDATORY)

Before ANY code action (create/edit/delete file), you MUST:

1. **Generate REASONING BLOCK** (see ``.agent/templates/agent-template-v3.md``)
2. **Include all required fields:**
   - analysis (objective, scope, dependencies)
   - potential_impact (affected modules, breaking changes, rollback)
   - edge_cases (minimum 3)
   - validation_criteria (minimum 3)
   - decision (PROCEED/ESCALATE/ALTERNATIVE)
   - reason (why this decision?)
3. **Validate** with ``.agent/systems/rba-validator.md``
4. **ONLY execute code** if decision = PROCEED

**Examples:** See ``.agent/examples/rba-examples.md``

**Violation:** If you skip RBA, your output is INVALID

---

"@

$agentsDir = "c:\Projects\Test1\.agent\agents"
$updated = 0
$skipped = 0
$errors = @()

Write-Host "[START] Bulk Agent Update..." -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor DarkGray
Write-Host ""

foreach ($agent in $agentsToUpdate) {
    $filePath = Join-Path $agentsDir $agent
    
    if (-not (Test-Path $filePath)) {
        Write-Host "  [SKIP] $agent (not found)" -ForegroundColor Yellow
        $skipped++
        continue
    }
    
    try {
        # Read current content
        $content = Get-Content $filePath -Raw
        
        # Check if already updated
        if ($content -match "Golden Rule Compliance") {
            Write-Host "  [SKIP] $agent (already updated)" -ForegroundColor DarkGray
            $skipped++
            continue
        }
        
        # Find insertion point - after last "---" before main content
        # Try to find after Philosophy/Mindset section
        if ($content -match '(## Your (Philosophy|Mindset)[^\#]+)(---)') {
            # Insert right after the separator following Philosophy/Mindset
            $newContent = $content -replace '(## Your (Philosophy|Mindset)[^\#]+)(---)', "`$1`$3$updateSection"
        }
        else {
            # Fallback: append to file end
            $newContent = $content.TrimEnd() + "`r`n" + $updateSection
        }
        
        # Write updated content
        Set-Content -Path $filePath -Value $newContent -NoNewline -Encoding UTF8
        
        Write-Host "  [OK] Updated: $agent" -ForegroundColor Green
        $updated++
        
    }
    catch {
        Write-Host "  [ERROR] $agent : $_" -ForegroundColor Red
        $errors += $agent
    }
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor DarkGray
Write-Host "[SUMMARY] Bulk Update Complete" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Updated:  $updated agents" -ForegroundColor Green
Write-Host "  Skipped:  $skipped agents" -ForegroundColor Yellow
Write-Host "  Errors:   $($errors.Count) agents" -ForegroundColor Red
Write-Host ""

if ($errors.Count -gt 0) {
    Write-Host "Errors in:" -ForegroundColor Red
    foreach ($err in $errors) {
        Write-Host "  - $err" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "[DONE] Process completed!" -ForegroundColor Green
Write-Host ""

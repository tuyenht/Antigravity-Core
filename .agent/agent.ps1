# .agent Interactive CLI
# Wrapper for common agent system operations
# Usage: .\agent.ps1 [command] [options]

param(
    [Parameter(Position = 0)]
    [string]$Command,
    
    [Parameter(Position = 1)]
    [string]$Target,
    
    [switch]$Help,
    [switch]$Verbose,
    [switch]$DryRun,
    [switch]$Force
)

# Colors
$Cyan = "Cyan"
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"

function Write-Logo {
    Write-Host ""
    Write-Host "    _                      _   " -ForegroundColor $Cyan
    Write-Host "   / \   __ _  ___ _ __  | |_ " -ForegroundColor $Cyan
    Write-Host "  / _ \ / _`` |/ _ \ '_ \ | __|" -ForegroundColor $Cyan
    Write-Host " / ___ \ (_| |  __/ | | || |_ " -ForegroundColor $Cyan
    Write-Host "/_/   \_\__, |\___|_| |_| \__|" -ForegroundColor $Cyan
    Write-Host "        |___/                 " -ForegroundColor $Cyan
    Write-Host ""
    Write-Host "  🚀 Antigravity Core v4.0.0" -ForegroundColor $Green
    Write-Host ""
}

function Show-Help {
    Write-Logo
    
    Write-Host "Usage: .\agent.ps1 <command> [options]" -ForegroundColor $Yellow
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor $Cyan
    Write-Host ""
    Write-Host "  SETUP"
    Write-Host "    init                Initialize project (auto-detect stack)"
    Write-Host "    init -Force         Reinitialize (overwrite existing config)"
    Write-Host ""
    Write-Host "  INFORMATION"
    Write-Host "    help                Show this help"
    Write-Host "    status              Show system status"
    Write-Host "    agents              List all agents"
    Write-Host "    skills              List all skills"
    Write-Host "    workflows           List all workflows"
    Write-Host ""
    Write-Host "  VALIDATION"
    Write-Host "    health              Run health check"
    Write-Host "    validate            Run compliance validation"
    Write-Host "    scan                Run secret scanning"
    Write-Host "    perf                Run performance check"
    Write-Host ""
    Write-Host "  AUTOMATION"
    Write-Host "    heal                Run auto-healing"
    Write-Host "    heal -DryRun        Preview auto-healing (no changes)"
    Write-Host ""
    Write-Host "  METRICS"
    Write-Host "    dx                  Show DX analytics dashboard"
    Write-Host "    dx roi              Show automation ROI"
    Write-Host "    dx quality          Show quality metrics"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor $Cyan
    Write-Host "    .\agent.ps1 status"
    Write-Host "    .\agent.ps1 health"
    Write-Host "    .\agent.ps1 init"
    Write-Host "    .\agent.ps1 heal -DryRun"
    Write-Host "    .\agent.ps1 dx roi"
    Write-Host ""
}

function Show-Status {
    Write-Logo
    
    Write-Host "System Status" -ForegroundColor $Cyan
    Write-Host "=============" -ForegroundColor $Cyan
    Write-Host ""
    
    # Count components
    $agents = (Get-ChildItem ".agent/agents/*.md" -ErrorAction SilentlyContinue).Count
    $skills = (Get-ChildItem ".agent/skills" -Directory -ErrorAction SilentlyContinue).Count
    $workflows = (Get-ChildItem ".agent/workflows/*.md" -ErrorAction SilentlyContinue).Count
    $scripts = (Get-ChildItem ".agent/scripts/*.ps1" -ErrorAction SilentlyContinue).Count
    
    Write-Host "Components:" -ForegroundColor $Yellow
    Write-Host "  Agents:     $agents"
    Write-Host "  Skills:     $skills"
    Write-Host "  Workflows:  $workflows"
    Write-Host "  Scripts:    $scripts"
    Write-Host ""
    
    # Version
    if (Test-Path ".agent/VERSION") {
        $version = Get-Content ".agent/VERSION" -Raw
        Write-Host "Version: $version" -ForegroundColor $Green
    }
    
    Write-Host ""
}

function Show-Agents {
    Write-Host ""
    Write-Host "Available Agents" -ForegroundColor $Cyan
    Write-Host "================" -ForegroundColor $Cyan
    Write-Host ""
    
    $agents = Get-ChildItem ".agent/agents/*.md" -ErrorAction SilentlyContinue
    
    foreach ($agent in $agents) {
        $name = $agent.BaseName
        Write-Host "  • $name" -ForegroundColor $Green
    }
    
    Write-Host ""
    Write-Host "Total: $($agents.Count) agents"
    Write-Host ""
}

function Show-Skills {
    Write-Host ""
    Write-Host "Available Skills" -ForegroundColor $Cyan
    Write-Host "================" -ForegroundColor $Cyan
    Write-Host ""
    
    $skills = Get-ChildItem ".agent/skills" -Directory -ErrorAction SilentlyContinue
    
    foreach ($skill in $skills) {
        $name = $skill.Name
        $deprecated = Test-Path "$($skill.FullName)/DEPRECATED.md"
        
        if ($deprecated) {
            Write-Host "  • $name" -ForegroundColor $Yellow -NoNewline
            Write-Host " [DEPRECATED]" -ForegroundColor $Red
        }
        else {
            Write-Host "  • $name" -ForegroundColor $Green
        }
    }
    
    Write-Host ""
    Write-Host "Total: $($skills.Count) skills"
    Write-Host ""
}

function Show-Workflows {
    Write-Host ""
    Write-Host "Available Workflows" -ForegroundColor $Cyan
    Write-Host "===================" -ForegroundColor $Cyan
    Write-Host ""
    
    $workflows = Get-ChildItem ".agent/workflows/*.md" -ErrorAction SilentlyContinue
    
    foreach ($wf in $workflows) {
        $name = $wf.BaseName
        Write-Host "  • $name" -ForegroundColor $Green
    }
    
    Write-Host ""
    Write-Host "Total: $($workflows.Count) workflows"
    Write-Host ""
}

function Run-Command {
    param([string]$Script, [string]$Args)
    
    $path = ".agent/scripts/$Script"
    
    if (Test-Path $path) {
        if ($Args) {
            & $path $Args
        }
        else {
            & $path
        }
    }
    else {
        Write-Host "Script not found: $path" -ForegroundColor $Red
    }
}

# Main
if ($Help -or $Command -eq "help" -or -not $Command) {
    Show-Help
    exit 0
}

switch ($Command.ToLower()) {
    "init" {
        Write-Logo
        Write-Host "Initializing project..." -ForegroundColor $Yellow
        Write-Host ""
        
        # Check if already initialized
        if ((Test-Path ".agent/project.json") -and -not $Force) {
            Write-Host "Project already initialized. Use -Force to reinitialize." -ForegroundColor $Yellow
            exit 0
        }
        
        # Detect tech stack
        $frontend = @()
        $backend = @()
        $database = @()
        $activeAgents = @("security-auditor", "test-engineer")
        
        if (Test-Path "package.json") {
            $pkg = Get-Content "package.json" -Raw
            if ($pkg -match '"next"') { $frontend += "Next.js"; $activeAgents += "frontend-specialist" }
            elseif ($pkg -match '"react"') { $frontend += "React"; $activeAgents += "frontend-specialist" }
            elseif ($pkg -match '"vue"') { $frontend += "Vue"; $activeAgents += "frontend-specialist" }
            elseif ($pkg -match '"svelte"') { $frontend += "Svelte"; $activeAgents += "frontend-specialist" }
            if ($pkg -match '"typescript"') { $frontend += "TypeScript" }
            if ($pkg -match '"express"' -or $pkg -match '"fastify"') { $backend += "Node.js"; $activeAgents += "backend-specialist" }
        }
        if (Test-Path "composer.json") {
            $composer = Get-Content "composer.json" -Raw
            if ($composer -match '"laravel/framework"') { $backend += "Laravel"; $activeAgents += "laravel-specialist" }
        }
        if (Test-Path "requirements.txt" -or Test-Path "pyproject.toml") { $backend += "Python"; $activeAgents += "backend-specialist" }
        if (Test-Path "go.mod") { $backend += "Go"; $activeAgents += "backend-specialist" }
        if (Test-Path "Cargo.toml") { $backend += "Rust"; $activeAgents += "backend-specialist" }
        if (Test-Path "prisma/schema.prisma") { $database += "Prisma"; $activeAgents += "database-architect" }
        if (Test-Path "drizzle.config.ts") { $database += "Drizzle"; $activeAgents += "database-architect" }
        
        $activeAgents = $activeAgents | Select-Object -Unique
        
        Write-Host "  Tech Stack Detected:" -ForegroundColor $Green
        if ($frontend) { Write-Host "    Frontend: $($frontend -join ', ')" }
        if ($backend) { Write-Host "    Backend:  $($backend -join ', ')" }
        if ($database) { Write-Host "    Database: $($database -join ', ')" }
        if (-not $frontend -and -not $backend -and -not $database) {
            Write-Host "    (Could not auto-detect. Ensure package.json/composer.json exists.)" -ForegroundColor $Yellow
        }
        Write-Host ""
        
        Write-Host "  Agents Activated:" -ForegroundColor $Green
        foreach ($a in $activeAgents) { Write-Host "    → $a" }
        Write-Host ""
        
        # Generate project.json
        $config = @{
            version = "4.0.0"
            initialized = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            tech_stack = @{
                frontend = ($frontend -join " ")
                backend = ($backend -join " ")
                database = ($database -join " ")
            }
            active_agents = $activeAgents
        }
        $config | ConvertTo-Json -Depth 3 | Set-Content ".agent/project.json" -Encoding UTF8
        
        Write-Host "✅ INITIALIZATION COMPLETE!" -ForegroundColor $Green
        Write-Host "   Config saved to .agent/project.json" -ForegroundColor $Cyan
        Write-Host ""
    }
    
    "status" { Show-Status }
    "agents" { Show-Agents }
    "skills" { Show-Skills }
    "workflows" { Show-Workflows }
    
    "health" { Run-Command "health-check.ps1" }
    "validate" { Run-Command "validate-compliance.ps1" }
    "scan" { Run-Command "secret-scan.ps1" "-All" }
    "perf" { Run-Command "performance-check.ps1" "-All" }
    
    "heal" {
        if ($DryRun) {
            Run-Command "auto-heal.ps1" "-All -DryRun"
        }
        else {
            Run-Command "auto-heal.ps1" "-All"
        }
    }
    
    "dx" {
        switch ($Target.ToLower()) {
            "roi" { Run-Command "dx-analytics.ps1" "-ROI" }
            "quality" { Run-Command "dx-analytics.ps1" "-Quality" }
            "bottlenecks" { Run-Command "dx-analytics.ps1" "-Bottlenecks" }
            default { Run-Command "dx-analytics.ps1" "-Dashboard" }
        }
    }
    
    default {
        Write-Host "Unknown command: $Command" -ForegroundColor $Red
        Write-Host "Run '.\agent.ps1 help' for available commands."
    }
}

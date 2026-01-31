#!/usr/bin/env pwsh
# Auto-Detect Project Context
# Automatically identifies project name and tech stack

function Get-ProjectName {
    # Method 1: From package.json
    if (Test-Path "package.json") {
        $pkg = Get-Content "package.json" | ConvertFrom-Json
        if ($pkg.name) {
            return $pkg.name
        }
    }
    
    # Method 2: From pyproject.toml
    if (Test-Path "pyproject.toml") {
        $content = Get-Content "pyproject.toml" -Raw
        if ($content -match 'name\s*=\s*"([^"]+)"') {
            return $matches[1]
        }
    }
    
    # Method 3: From Cargo.toml
    if (Test-Path "Cargo.toml") {
        $content = Get-Content "Cargo.toml" -Raw
        if ($content -match 'name\s*=\s*"([^"]+)"') {
            return $matches[1]
        }
    }
    
    # Method 4: From directory name
    return (Get-Item -Path ".").Name
}

function Get-TechStack {
    $stack = @()
    
    # Frontend frameworks
    if (Test-Path "package.json") {
        $pkg = Get-Content "package.json" | ConvertFrom-Json
        $deps = @($pkg.dependencies.PSObject.Properties.Name) + @($pkg.devDependencies.PSObject.Properties.Name)
        
        if ($deps -contains "react") { $stack += "React" }
        if ($deps -contains "next") { $stack += "Next.js" }
        if ($deps -contains "vue") { $stack += "Vue" }
        if ($deps -contains "svelte") { $stack += "Svelte" }
        if ($deps -contains "angular") { $stack += "Angular" }
        if ($deps -contains "typescript") { $stack += "TypeScript" }
        if ($deps -match "tailwind") { $stack += "Tailwind CSS" }
    }
    
    # Backend frameworks
    if (Test-Path "requirements.txt") { 
        $stack += "Python"
        $content = Get-Content "requirements.txt" -Raw
        if ($content -match "fastapi") { $stack += "FastAPI" }
        if ($content -match "django") { $stack += "Django" }
        if ($content -match "flask") { $stack += "Flask" }
    }
    
    # Laravel detection (PHP)
    if (Test-Path "composer.json") {
        try {
            $composer = Get-Content "composer.json" | ConvertFrom-Json
            $deps = @()
            if ($composer.require) {
                $deps += $composer.require.PSObject.Properties.Name
            }
            
            foreach ($dep in $deps) {
                if ($dep -match "laravel/framework") {
                    $stack += "Laravel"
                    # Try to detect version
                    $version = $composer.require.$dep
                    if ($version -match "^(\d+)") {
                        $stack += "Laravel $($matches[1])"
                    }
                }
                if ($dep -match "inertiajs/inertia-laravel") {
                    $stack += "Inertia.js"
                }
            }
        }
        catch {
            # Ignore JSON parse errors
        }
    }
    
    if (Test-Path "Cargo.toml") { $stack += "Rust" }
    if (Test-Path "go.mod") { $stack += "Go" }
    if (Test-Path "pom.xml") { $stack += "Java" }
    
    # Databases
    if (Test-Path "prisma") { $stack += "Prisma" }
    if ($pkg.dependencies.PSObject.Properties.Name -contains "pg") { $stack += "PostgreSQL" }
    if ($pkg.dependencies.PSObject.Properties.Name -contains "mongodb") { $stack += "MongoDB" }
    
    return $stack
}

function Update-UserProfile {
    $profilePath = ".agent/memory/user-profile.yaml"
    
    if (-not (Test-Path $profilePath)) {
        Write-Host "Warning: user-profile.yaml not found"
        return
    }
    
    $projectName = Get-ProjectName
    $techStack = Get-TechStack
    
    # Read current profile
    $content = Get-Content $profilePath -Raw
    
    # Update project name
    $content = $content -replace 'current_project:\s*"[^"]*"', "current_project: `"$projectName`""
    
    # Update tech stack (simple approach - replace entire line)
    if ($techStack.Count -gt 0) {
        $stackStr = ($techStack | ForEach-Object { $_ }) -join ', '
        $content = $content -replace 'tech_stack:\s*\[.*\]', "tech_stack: [$stackStr]"
    }
    
    # Write back
    Set-Content -Path $profilePath -Value $content -NoNewline
    
    Write-Host "Auto-detected project context:" -ForegroundColor Green
    Write-Host "  Project: $projectName"
    $stackDisplay = $techStack -join ', '
    Write-Host "  Tech Stack: $stackDisplay"
}

# Execute
Update-UserProfile

#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Antigravity Auto-Rule Discovery Script
.DESCRIPTION
    Scans project context and outputs recommended rules, agents, and dependency chain.
    Implements the 3-layer detection protocol from auto-rule-discovery.md.
.PARAMETER Path
    Project root path to scan. Defaults to current directory.
.PARAMETER Format
    Output format: 'text' (default, human-readable) or 'json' (machine-parseable).
.PARAMETER Request
    Optional user request text for Layer 3 keyword analysis.
.EXAMPLE
    .\discover-rules.ps1
    .\discover-rules.ps1 -Path "C:\Projects\MyApp" -Format json
    .\discover-rules.ps1 -Request "optimize database queries"
#>

param(
    [string]$Path = ".",
    [ValidateSet("text", "json")]
    [string]$Format = "text",
    [string]$Request = ""
)

# ============================================
# Constants: Rule Mappings
# ============================================

$ExtensionRules = @{
    ".vue"     = @{ Rules = @("frontend-frameworks/vue3.md", "typescript/vue3.md"); Score = 10 }
    ".svelte"  = @{ Rules = @("frontend-frameworks/svelte.md"); Score = 10 }
    ".astro"   = @{ Rules = @("frontend-frameworks/astro.md"); Score = 10 }
    ".swift"   = @{ Rules = @("mobile/ios-swift.md"); Score = 10 }
    ".kt"      = @{ Rules = @("mobile/android-kotlin.md"); Score = 10 }
    ".dart"    = @{ Rules = @("mobile/flutter.md"); Score = 10 }
    ".proto"   = @{ Rules = @("backend-frameworks/grpc.md", "backend-frameworks/connect-rpc.md"); Score = 10 }
    ".php"     = @{ Rules = @("backend-frameworks/laravel.md"); Score = 10 }
    ".py"      = @{ Rules = @("python/fastapi.md"); Score = 10 }
    ".sql"     = @{ Rules = @("database/postgresql.md", "database/query-optimization.md"); Score = 10 }
    ".graphql" = @{ Rules = @("backend-frameworks/graphql.md"); Score = 10 }
    ".ts"      = @{ Rules = @("typescript/core.md"); Score = 8 }
    ".tsx"     = @{ Rules = @("typescript/core.md"); Score = 8 }
    ".css"     = @{ Rules = @("web-development/modern-css.md"); Score = 8 }
    ".html"    = @{ Rules = @("web-development/semantic-html.md"); Score = 8 }
    ".js"      = @{ Rules = @("web-development/javascript.md"); Score = 7 }
    ".jsx"     = @{ Rules = @("web-development/javascript.md"); Score = 7 }
    ".cs"      = @{ Rules = @("backend-frameworks/aspnet-core.md"); Score = 10 }
}

$ConfigPatterns = @{
    "next"                = @{ Rules = @("nextjs/app-router.md", "nextjs/server-actions.md"); Score = 8 }
    "react"               = @{ Rules = @("typescript/react.md"); Score = 8 }
    "vue"                 = @{ Rules = @("frontend-frameworks/vue3.md"); Score = 8 }
    "svelte"              = @{ Rules = @("frontend-frameworks/svelte.md"); Score = 8 }
    "@angular/core"       = @{ Rules = @("frontend-frameworks/angular.md"); Score = 8 }
    "react-native"        = @{ Rules = @("mobile/react-native.md"); Score = 8 }
    "tailwindcss"         = @{ Rules = @("frontend-frameworks/tailwind.md"); Score = 7 }
    "@connectrpc/connect" = @{ Rules = @("backend-frameworks/connect-rpc.md"); Score = 8 }
    "bullmq"              = @{ Rules = @("backend-frameworks/message-queue.md"); Score = 8 }
    "socket.io"           = @{ Rules = @("backend-frameworks/websocket.md"); Score = 8 }
    "prisma"              = @{ Rules = @("database/postgresql.md"); Score = 7 }
    "@nestjs/core"        = @{ Rules = @("backend-frameworks/express.md"); Score = 8 }
    "express"             = @{ Rules = @("backend-frameworks/express.md"); Score = 7 }
}

$KeywordPatterns = @{
    "grpc|protobuf|rpc"              = @{ Rules = @("backend-frameworks/grpc.md"); Score = 6 }
    "connect|connectrpc|buf"         = @{ Rules = @("backend-frameworks/connect-rpc.md"); Score = 6 }
    "websocket|socket\.io|real-time" = @{ Rules = @("backend-frameworks/websocket.md"); Score = 6 }
    "sse|server-sent|eventsource"    = @{ Rules = @("backend-frameworks/sse.md"); Score = 6 }
    "bullmq|rabbitmq|message.queue"  = @{ Rules = @("backend-frameworks/message-queue.md"); Score = 6 }
    "graphql|apollo|schema.resolver" = @{ Rules = @("backend-frameworks/graphql.md"); Score = 6 }
    "debug|fix|error|bug"            = @{ Rules = @("agentic-ai/debugging.md"); Score = 5 }
    "test|unit.test|coverage"        = @{ Rules = @("agentic-ai/testing.md"); Score = 5 }
    "security|audit|vulnerability"   = @{ Rules = @("agentic-ai/security.md"); Score = 5 }
    "refactor|cleanup|code.smell"    = @{ Rules = @("agentic-ai/refactoring.md"); Score = 5 }
    "optimize|slow|performance"      = @{ Rules = @("agentic-ai/performance.md"); Score = 5 }
    "deploy|ci.?cd|pipeline|docker"  = @{ Rules = @("agentic-ai/devops.md"); Score = 5 }
    "review|PR|code.review"          = @{ Rules = @("agentic-ai/code-review.md"); Score = 5 }
    "schema|ERD|data.model"          = @{ Rules = @("database/design.md"); Score = 5 }
    "slow.query|explain|index"       = @{ Rules = @("database/query-optimization.md"); Score = 6 }
    "redis|cache|caching"            = @{ Rules = @("database/redis.md"); Score = 5 }
    "mongodb|mongoose|nosql"         = @{ Rules = @("database/mongodb.md"); Score = 5 }
    "migration|alter.table"          = @{ Rules = @("database/migrations.md"); Score = 5 }
}

$AgentKeywords = @{
    "backend-specialist"    = @("api", "endpoint", "controller", "middleware", "auth", "server", "backend")
    "frontend-specialist"   = @("ui", "component", "page", "layout", "style", "responsive", "css", "react", "vue", "frontend")
    "laravel-specialist"    = @("laravel", "eloquent", "artisan", "blade", "migration", "livewire", "inertia")
    "mobile-developer"      = @("mobile", "ios", "android", "react native", "flutter", "expo")
    "database-architect"    = @("database", "schema", "migration", "query", "index", "prisma", "sql")
    "debugger"              = @("debug", "fix", "error", "bug", "crash", "exception", "broken")
    "test-engineer"         = @("test", "spec", "coverage", "jest", "vitest", "playwright")
    "security-auditor"      = @("security", "audit", "vulnerability", "owasp", "xss", "injection")
    "devops-engineer"       = @("deploy", "docker", "kubernetes", "ci", "cd", "pipeline", "nginx")
    "performance-optimizer" = @("optimize", "performance", "slow", "latency", "bundle", "cache")
    "refactor-agent"        = @("refactor", "cleanup", "code smell", "dry", "solid")
    "seo-specialist"        = @("seo", "meta", "sitemap", "robots", "lighthouse")
    "project-planner"       = @("plan", "design", "architecture", "requirements")
}

# ============================================
# Layer 1: File Extension Scan
# ============================================

function Scan-FileExtensions {
    param([string]$ProjectPath)
    
    $results = @{}
    $extensions = @{}
    
    # Scan top-level and src/ directories for file types
    $searchPaths = @($ProjectPath)
    $srcDirs = @("src", "app", "resources", "lib", "pages", "components", "server", "database")
    foreach ($dir in $srcDirs) {
        $fullPath = Join-Path $ProjectPath $dir
        if (Test-Path $fullPath) { $searchPaths += $fullPath }
    }
    
    foreach ($searchPath in $searchPaths) {
        $files = Get-ChildItem -Path $searchPath -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "node_modules|vendor|dist|build|\.git|__pycache__" } |
        Select-Object -First 200
        
        foreach ($file in $files) {
            $ext = $file.Extension.ToLower()
            if ($ext -and $ExtensionRules.ContainsKey($ext)) {
                if (-not $extensions.ContainsKey($ext)) { $extensions[$ext] = 0 }
                $extensions[$ext]++
                
                $mapping = $ExtensionRules[$ext]
                foreach ($rule in $mapping.Rules) {
                    $currentScore = if ($results.ContainsKey($rule)) { $results[$rule] } else { 0 }
                    $results[$rule] = [Math]::Max($currentScore, $mapping.Score)
                }
            }
        }
    }
    
    return @{ Rules = $results; Extensions = $extensions }
}

# ============================================
# Layer 2: Project Config Scan
# ============================================

function Scan-ProjectConfigs {
    param([string]$ProjectPath)
    
    $results = @{}
    $techStack = @()
    
    # package.json
    $pkgPath = Join-Path $ProjectPath "package.json"
    if (Test-Path $pkgPath) {
        try {
            $pkg = Get-Content $pkgPath -Raw | ConvertFrom-Json
            $allDeps = @()
            if ($pkg.dependencies) { $allDeps += $pkg.dependencies.PSObject.Properties.Name }
            if ($pkg.devDependencies) { $allDeps += $pkg.devDependencies.PSObject.Properties.Name }
            
            foreach ($pattern in $ConfigPatterns.Keys) {
                if ($allDeps | Where-Object { $_ -match [regex]::Escape($pattern) }) {
                    $mapping = $ConfigPatterns[$pattern]
                    foreach ($rule in $mapping.Rules) {
                        $currentScore = if ($results.ContainsKey($rule)) { $results[$rule] } else { 0 }
                        $results[$rule] = [Math]::Max($currentScore, $mapping.Score)
                    }
                    $techStack += $pattern
                }
            }
            
            if ($allDeps -contains "typescript") { $techStack += "TypeScript" }
        }
        catch { }
    }
    
    # composer.json (Laravel)
    $composerPath = Join-Path $ProjectPath "composer.json"
    if (Test-Path $composerPath) {
        try {
            $composer = Get-Content $composerPath -Raw | ConvertFrom-Json
            $deps = @()
            if ($composer.require) { $deps += $composer.require.PSObject.Properties.Name }
            
            if ($deps | Where-Object { $_ -match "laravel/framework" }) {
                $prev = if ($results.ContainsKey("backend-frameworks/laravel.md")) { $results["backend-frameworks/laravel.md"] } else { 0 }
                $results["backend-frameworks/laravel.md"] = [Math]::Max($prev, 9)
                $techStack += "Laravel"
            }
            if ($deps | Where-Object { $_ -match "inertiajs" }) {
                $techStack += "Inertia.js"
            }
        }
        catch { }
    }
    
    # requirements.txt / pyproject.toml (Python)
    $reqPath = Join-Path $ProjectPath "requirements.txt"
    $pyprojectPath = Join-Path $ProjectPath "pyproject.toml"
    $pythonContent = ""
    if (Test-Path $reqPath) { $pythonContent = Get-Content $reqPath -Raw }
    elseif (Test-Path $pyprojectPath) { $pythonContent = Get-Content $pyprojectPath -Raw }
    
    if ($pythonContent) {
        if ($pythonContent -match "fastapi") {
            $prev = if ($results.ContainsKey("python/fastapi.md")) { $results["python/fastapi.md"] } else { 0 }
            $results["python/fastapi.md"] = [Math]::Max($prev, 9)
            $techStack += "FastAPI"
        }
        if ($pythonContent -match "flask") {
            $prev = if ($results.ContainsKey("python/flask.md")) { $results["python/flask.md"] } else { 0 }
            $results["python/flask.md"] = [Math]::Max($prev, 9)
            $techStack += "Flask"
        }
        $techStack += "Python"
    }
    
    # pubspec.yaml (Flutter)
    if (Test-Path (Join-Path $ProjectPath "pubspec.yaml")) {
        $results["mobile/flutter.md"] = 9
        $techStack += "Flutter"
    }
    
    # Cargo.toml (Rust)
    if (Test-Path (Join-Path $ProjectPath "Cargo.toml")) {
        $results["web-development/webassembly.md"] = 8
        $techStack += "Rust"
    }
    
    # .csproj (ASP.NET)
    if (Get-ChildItem -Path $ProjectPath -Filter "*.csproj" -ErrorAction SilentlyContinue) {
        $results["backend-frameworks/aspnet-core.md"] = 9
        $techStack += "ASP.NET Core"
    }
    
    # Prisma
    if (Test-Path (Join-Path $ProjectPath "prisma")) {
        $prev = if ($results.ContainsKey("database/postgresql.md")) { $results["database/postgresql.md"] } else { 0 }
        $results["database/postgresql.md"] = [Math]::Max($prev, 7)
        $techStack += "Prisma"
    }
    
    # Docker
    if ((Test-Path (Join-Path $ProjectPath "Dockerfile")) -or (Test-Path (Join-Path $ProjectPath "docker-compose.yml"))) {
        $techStack += "Docker"
    }
    
    return @{ Rules = $results; TechStack = ($techStack | Select-Object -Unique) }
}

# ============================================
# Layer 3: Keyword Analysis
# ============================================

function Scan-Keywords {
    param([string]$RequestText)
    
    $results = @{}
    $agentScores = @{}
    
    if (-not $RequestText) { return @{ Rules = $results; Agents = $agentScores } }
    
    $lower = $RequestText.ToLower()
    
    # Rule keyword matching
    foreach ($pattern in $KeywordPatterns.Keys) {
        if ($lower -match $pattern) {
            $mapping = $KeywordPatterns[$pattern]
            foreach ($rule in $mapping.Rules) {
                $currentScore = if ($results.ContainsKey($rule)) { $results[$rule] } else { 0 }
                $results[$rule] = [Math]::Max($currentScore, $mapping.Score)
            }
        }
    }
    
    # Agent keyword matching
    foreach ($agent in $AgentKeywords.Keys) {
        $score = 0
        foreach ($kw in $AgentKeywords[$agent]) {
            if ($lower -match [regex]::Escape($kw)) { $score += 3 }
        }
        if ($score -gt 0) { $agentScores[$agent] = $score }
    }
    
    return @{ Rules = $results; Agents = $agentScores }
}

# ============================================
# Merge & Rank
# ============================================

function Merge-Results {
    param($Layer1, $Layer2, $Layer3)
    
    $merged = @{}
    
    # Merge all rule scores (max wins)
    foreach ($source in @($Layer1.Rules, $Layer2.Rules, $Layer3.Rules)) {
        foreach ($rule in $source.Keys) {
            $currentScore = if ($merged.ContainsKey($rule)) { $merged[$rule] } else { 0 }
            $merged[$rule] = [Math]::Max($currentScore, $source[$rule])
        }
    }
    
    # Sort by score descending
    $ranked = $merged.GetEnumerator() | Sort-Object -Property Value -Descending
    
    return $ranked
}

# ============================================
# Agent Recommendation
# ============================================

function Get-AgentRecommendation {
    param($TechStack, $KeywordAgents, $Extensions)
    
    $agents = @{}
    
    # Tech stack → agent mapping
    if ($TechStack -contains "Laravel") { $agents["laravel-specialist"] = 10 }
    if ($TechStack -contains "next") { $agents["frontend-specialist"] = 8 }
    if ($TechStack -contains "react") {
        $prev = if ($agents.ContainsKey("frontend-specialist")) { $agents["frontend-specialist"] } else { 0 }
        $agents["frontend-specialist"] = [Math]::Max($prev, 7)
    }
    if ($TechStack -contains "vue") {
        $prev = if ($agents.ContainsKey("frontend-specialist")) { $agents["frontend-specialist"] } else { 0 }
        $agents["frontend-specialist"] = [Math]::Max($prev, 7)
    }
    if ($TechStack -contains "Flutter") { $agents["mobile-developer"] = 9 }
    if ($TechStack -contains "react-native") { $agents["mobile-developer"] = 9 }
    if ($TechStack -contains "FastAPI" -or $TechStack -contains "Flask") { $agents["backend-specialist"] = 8 }
    if ($TechStack -contains "Prisma") { $agents["database-architect"] = 7 }
    if ($TechStack -contains "Docker") { $agents["devops-engineer"] = 5 }
    
    # Extension-based
    if ($Extensions.ContainsKey(".php")) {
        $prev = if ($agents.ContainsKey("laravel-specialist")) { $agents["laravel-specialist"] } else { 0 }
        $agents["laravel-specialist"] = [Math]::Max($prev, 9)
    }
    if ($Extensions.ContainsKey(".swift")) {
        $prev = if ($agents.ContainsKey("mobile-developer")) { $agents["mobile-developer"] } else { 0 }
        $agents["mobile-developer"] = [Math]::Max($prev, 9)
    }
    if ($Extensions.ContainsKey(".kt")) {
        $prev = if ($agents.ContainsKey("mobile-developer")) { $agents["mobile-developer"] } else { 0 }
        $agents["mobile-developer"] = [Math]::Max($prev, 9)
    }
    if ($Extensions.ContainsKey(".dart")) {
        $prev = if ($agents.ContainsKey("mobile-developer")) { $agents["mobile-developer"] } else { 0 }
        $agents["mobile-developer"] = [Math]::Max($prev, 9)
    }
    if ($Extensions.ContainsKey(".sql")) {
        $prev = if ($agents.ContainsKey("database-architect")) { $agents["database-architect"] } else { 0 }
        $agents["database-architect"] = [Math]::Max($prev, 8)
    }
    
    # Merge keyword agents
    foreach ($agent in $KeywordAgents.Keys) {
        $currentScore = if ($agents.ContainsKey($agent)) { $agents[$agent] } else { 0 }
        $agents[$agent] = [Math]::Max($currentScore, $KeywordAgents[$agent])
    }
    
    return $agents.GetEnumerator() | Sort-Object -Property Value -Descending
}

# ============================================
# Main Execution
# ============================================

$ProjectPath = Resolve-Path $Path -ErrorAction Stop

# Run 3-layer scan
$layer1 = Scan-FileExtensions -ProjectPath $ProjectPath
$layer2 = Scan-ProjectConfigs -ProjectPath $ProjectPath
$layer3 = Scan-Keywords -RequestText $Request

# Merge & rank rules
$rankedRules = Merge-Results -Layer1 $layer1 -Layer2 $layer2 -Layer3 $layer3

# Agent recommendation
$agents = Get-AgentRecommendation -TechStack $layer2.TechStack -KeywordAgents $layer3.Agents -Extensions $layer1.Extensions

# ============================================
# Output
# ============================================

if ($Format -eq "json") {
    $output = @{
        timestamp    = (Get-Date -Format "o")
        project_path = $ProjectPath.ToString()
        tech_stack   = @($layer2.TechStack)
        file_types   = @{}
        rules        = @()
        agents       = @()
    }
    
    foreach ($ext in $layer1.Extensions.Keys) {
        $output.file_types[$ext] = $layer1.Extensions[$ext]
    }
    
    foreach ($rule in $rankedRules) {
        $output.rules += @{ name = $rule.Key; score = $rule.Value }
    }
    
    foreach ($agent in $agents) {
        $output.agents += @{ name = $agent.Key; score = $agent.Value }
    }
    
    $output | ConvertTo-Json -Depth 4
}
else {
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "  Antigravity Auto-Rule Discovery Engine v1.0" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Project: $ProjectPath" -ForegroundColor White
    Write-Host ""
    
    # Tech Stack
    Write-Host "  Tech Stack Detected:" -ForegroundColor Yellow
    if ($layer2.TechStack.Count -eq 0) {
        Write-Host "    (none detected)" -ForegroundColor DarkGray
    }
    else {
        foreach ($tech in $layer2.TechStack) {
            Write-Host "    • $tech" -ForegroundColor Green
        }
    }
    Write-Host ""
    
    # File Types
    Write-Host "  File Types Found:" -ForegroundColor Yellow
    foreach ($ext in ($layer1.Extensions.GetEnumerator() | Sort-Object -Property Value -Descending)) {
        Write-Host "    $($ext.Key): $($ext.Value) files" -ForegroundColor White
    }
    Write-Host ""
    
    # Recommended Rules
    Write-Host "  Recommended Rules (by priority):" -ForegroundColor Yellow
    $i = 1
    foreach ($rule in $rankedRules) {
        $scoreColor = if ($rule.Value -ge 9) { "Green" } elseif ($rule.Value -ge 7) { "Yellow" } else { "White" }
        Write-Host ("    {0,2}. [{1,2}] {2}" -f $i, $rule.Value, $rule.Key) -ForegroundColor $scoreColor
        $i++
    }
    Write-Host ""
    
    # Recommended Agents
    Write-Host "  Recommended Agents:" -ForegroundColor Yellow
    $rank = 1
    foreach ($agent in $agents) {
        $roleLabel = if ($rank -eq 1) { "PRIMARY" } else { "SUPPORT" }
        $roleColor = if ($rank -eq 1) { "Green" } else { "White" }
        Write-Host ("    {0}. [{1}] {2} (score: {3})" -f $rank, $roleLabel, $agent.Key, $agent.Value) -ForegroundColor $roleColor
        $rank++
    }
    Write-Host ""
    
    if ($Request) {
        Write-Host "  Request Analysis:" -ForegroundColor Yellow
        Write-Host "    ""$Request""" -ForegroundColor DarkGray
    }
    
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
}

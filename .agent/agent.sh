#!/usr/bin/env bash
#
# .agent Auto-Initialization Script (Linux/Mac)
# Version: 4.0.0
# Usage: ./agent init
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

function success() { echo -e "${GREEN}✅ $1${NC}"; }
function info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
function warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
function error() { echo -e "${RED}❌ $1${NC}"; }
function step() { echo -e "${BLUE}🔹 $1${NC}"; }

# Banner
function show_banner() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   .agent Auto-Initialization System      ║${NC}"
    echo -e "${CYAN}║   Version 4.0.0 - Zero-Error Architecture ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════╝${NC}"
    echo ""
}

# Detect tech stack
function detect_tech_stack() {
    step "Detecting tech stack..."
    
    local frontend=()
    local backend=()
    local database=()
    local mobile=()
    local detected=false
    
    # Node.js
    if [[ -f "package.json" ]]; then
        detected=true
        if grep -q '"next"' package.json; then
            frontend+=("Next.js")
        elif grep -q '"react"' package.json; then
            frontend+=("React")
        elif grep -q '"vue"' package.json; then
            frontend+=("Vue")
        elif grep -q '"svelte"' package.json; then
            frontend+=("Svelte")
        fi
        
        if grep -q '"typescript"' package.json || [[ -f "tsconfig.json" ]]; then
            frontend+=("TypeScript")
        fi
        
        if grep -q '"express"' package.json || grep -q '"fastify"' package.json; then
            backend+=("Node.js")
        fi
    fi
    
    # PHP / Laravel
    if [[ -f "composer.json" ]]; then
        detected=true
        if grep -q '"laravel/framework"' composer.json; then
            backend+=("Laravel")
        fi
    fi
    
    # Python
    if [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; then
        detected=true
        if [[ -f "requirements.txt" ]]; then
            if grep -qi "fastapi" requirements.txt; then
                backend+=("FastAPI")
            elif grep -qi "django" requirements.txt; then
                backend+=("Django")
            elif grep -qi "flask" requirements.txt; then
                backend+=("Flask")
            else
                backend+=("Python")
            fi
        else
            backend+=("Python")
        fi
    fi
    
    # Go
    if [[ -f "go.mod" ]]; then
        detected=true
        backend+=("Go")
    fi
    
    # Rust
    if [[ -f "Cargo.toml" ]]; then
        detected=true
        backend+=("Rust")
    fi
    
    # Mobile
    if [[ -f "pubspec.yaml" ]]; then
        detected=true
        mobile+=("Flutter")
    fi
    
    if [[ -f "ios/Podfile" ]] || [[ -f "android/build.gradle" ]]; then
        detected=true
        mobile+=("React Native")
    fi
    
    # Database
    if [[ -f "prisma/schema.prisma" ]]; then
        database+=("Prisma")
    fi
    
    if [[ -f "drizzle.config.ts" ]] || [[ -f "drizzle.config.js" ]]; then
        database+=("Drizzle")
    fi
    
    if $detected; then
        echo ""
        success "Tech Stack Detected:"
        [[ ${#frontend[@]} -gt 0 ]] && info "  Frontend: ${frontend[*]}"
        [[ ${#backend[@]} -gt 0 ]] && info "  Backend: ${backend[*]}"
        [[ ${#mobile[@]} -gt 0 ]] && info "  Mobile: ${mobile[*]}"
        [[ ${#database[@]} -gt 0 ]] && info "  Database: ${database[*]}"
        echo ""
    else
        error "Could not auto-detect tech stack!"
        info "Please ensure you have at least one of:"
        info "  - package.json (Node.js)"
        info "  - composer.json (PHP)"
        info "  - requirements.txt (Python)"
        exit 1
    fi
    
    # Export for other functions
    export DETECTED_FRONTEND="${frontend[*]}"
    export DETECTED_BACKEND="${backend[*]}"
    export DETECTED_MOBILE="${mobile[*]}"
    export DETECTED_DATABASE="${database[*]}"
}

# Activate agents
function activate_agents() {
    step "Activating agents for your tech stack..."
    
    local agents=()
    
    # Frontend
    if [[ "$DETECTED_FRONTEND" == *"Next.js"* ]] || [[ "$DETECTED_FRONTEND" == *"React"* ]]; then
        agents+=("frontend-specialist")
        info "  → frontend-specialist (React/Next.js)"
    elif [[ "$DETECTED_FRONTEND" == *"Vue"* ]]; then
        agents+=("frontend-specialist")
        info "  → frontend-specialist (Vue)"
    elif [[ "$DETECTED_FRONTEND" == *"Svelte"* ]]; then
        agents+=("frontend-specialist")
        info "  → frontend-specialist (Svelte)"
    fi
    
    # Backend
    if [[ "$DETECTED_BACKEND" == *"Laravel"* ]]; then
        agents+=("laravel-specialist")
        info "  → laravel-specialist (Laravel)"
    elif [[ -n "$DETECTED_BACKEND" ]]; then
        agents+=("backend-specialist")
        info "  → backend-specialist ($DETECTED_BACKEND)"
    fi
    
    # Mobile
    if [[ "$DETECTED_MOBILE" == *"React Native"* ]] || [[ "$DETECTED_MOBILE" == *"Flutter"* ]]; then
        agents+=("mobile-developer")
        info "  → mobile-developer"
    fi
    
    # Database
    if [[ -n "$DETECTED_DATABASE" ]]; then
        agents+=("database-architect")
        info "  → database-architect ($DETECTED_DATABASE)"
    fi
    
    # Always include
    agents+=("security-auditor" "test-engineer")
    info "  → security-auditor (Security)"
    info "  → test-engineer (Testing)"
    
    export ACTIVE_AGENTS="${agents[*]}"
}

# Generate project config
function generate_config() {
    step "Generating project configuration..."
    
    cat > .agent/project.json << EOF
{
  "version": "4.0.0",
  "initialized": "$(date +"%Y-%m-%d %H:%M:%S")",
  "tech_stack": {
    "frontend": "$DETECTED_FRONTEND",
    "backend": "$DETECTED_BACKEND",
    "mobile": "$DETECTED_MOBILE",
    "database": "$DETECTED_DATABASE"
  },
  "active_agents": ["$(echo "$ACTIVE_AGENTS" | sed 's/ /", "/g')"],
  "workflows": {
    "enabled": ["plan", "scaffold", "test", "review", "deploy"]
  }
}
EOF
    
    success "Configuration saved to .agent/project.json"
}

# Generate README
function generate_readme() {
    cat > .agent/PROJECT-README.md << 'EOF'
# .agent Configuration for This Project

**Initialized:** $(date)

---

## Quick Commands (Linux/Mac)

```bash
./.agent/agent.sh init             # Initialize project
./.agent/agent.sh status           # Show configuration
./.agent/agent.sh agents           # List all agents
./.agent/agent.sh skills           # List all skills
./.agent/agent.sh workflows        # List all workflows
./.agent/agent.sh health           # Run health check
./.agent/agent.sh help             # Show all commands
```

## Quick Commands (Windows)

```powershell
.\.agent\agent.ps1 status         # Show system status
.\.agent\agent.ps1 health         # Run health check
.\.agent\agent.ps1 validate       # Run compliance validation
.\.agent\agent.ps1 heal           # Run auto-healing
.\.agent\agent.ps1 dx             # Show DX analytics
```

---

## Example

Just describe what you want to Antigravity:

```
USER: "Build a user authentication system"

Antigravity auto-analyzes your tech stack and executes!
```
EOF
    
    success "Project README created: .agent/PROJECT-README.md"
}

# Initialize project
function initialize_project() {
    show_banner
    
    # Check .agent exists
    if [[ ! -d ".agent" ]]; then
        error ".agent directory not found!"
        info "Copy .agent folder to project root:"
        info "  cp -r path/to/.agent ."
        exit 1
    fi
    
    # Check if already initialized
    if [[ -f ".agent/project.json" ]] && [[ "$1" != "--force" ]]; then
        warning "Project already initialized!"
        info "Use --force to reinitialize"
        exit 0
    fi
    
    step "Starting auto-initialization..."
    echo ""
    
    # Auto-detect and configure
    detect_tech_stack
    activate_agents
    echo ""
    generate_config
    echo ""
    generate_readme
    echo ""
    
    # Success!
    echo -e "${GREEN}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   ✅ INITIALIZATION COMPLETE!             ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════╝${NC}"
    echo ""
    success "Your project is ready for AI-assisted development!"
    echo ""
    info "Next steps:"
    info "  1. Read: .agent/PROJECT-README.md"
    info "  2. Try: ./agent plan 'Build user authentication'"
    echo ""
}

# Helper functions for feature parity
function show_agents() {
    echo ""
    info "Available Agents"
    echo "================"
    echo ""
    for agent in .agent/agents/*.md; do
        [[ -f "$agent" ]] && echo "  • $(basename "$agent" .md)"
    done
    echo ""
    echo "Total: $(ls .agent/agents/*.md 2>/dev/null | wc -l) agents"
    echo ""
}

function show_skills() {
    echo ""
    info "Available Skills"
    echo "================"
    echo ""
    for skill in .agent/skills/*/; do
        [[ -d "$skill" ]] && echo "  • $(basename "$skill")"
    done
    echo ""
    echo "Total: $(ls -d .agent/skills/*/ 2>/dev/null | wc -l) skills"
    echo ""
}

function show_workflows() {
    echo ""
    info "Available Workflows"
    echo "==================="
    echo ""
    for wf in .agent/workflows/*.md; do
        [[ -f "$wf" ]] && echo "  • $(basename "$wf" .md)"
    done
    echo ""
    echo "Total: $(ls .agent/workflows/*.md 2>/dev/null | wc -l) workflows"
    echo ""
}

function show_help() {
    show_banner
    echo "Usage: ./agent.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  init       Initialize .agent for this project"
    echo "  status     Show configuration"
    echo "  agents     List all agents"
    echo "  skills     List all skills"
    echo "  workflows  List all workflows"
    echo "  health     Run health check"
    echo "  validate   Run compliance validation"
    echo "  scan       Run secret scanning"
    echo "  perf       Run performance check"
    echo "  heal       Run auto-healing"
    echo "  dx         Show DX analytics"
    echo "  help       Show this help"
    echo ""
}

# Main
case "${1:-help}" in
    init)
        initialize_project "$2"
        ;;
    status)
        if [[ -f ".agent/project.json" ]]; then
            success "Project initialized!"
            cat .agent/project.json
        else
            warning "Not initialized. Run: ./agent.sh init"
        fi
        ;;
    agents)
        show_agents
        ;;
    skills)
        show_skills
        ;;
    workflows)
        show_workflows
        ;;
    health)
        if command -v pwsh &>/dev/null && [[ -f ".agent/scripts/health-check.ps1" ]]; then
            pwsh -NoProfile -File ".agent/scripts/health-check.ps1"
        elif [[ -f ".agent/scripts/health-check.ps1" ]]; then
            info "Requires PowerShell. Install pwsh or run on Windows:"
            info "  .\.agent\agent.ps1 health"
        else
            warning "health-check.ps1 not found"
        fi
        ;;
    validate)
        if command -v pwsh &>/dev/null && [[ -f ".agent/scripts/validate-compliance.ps1" ]]; then
            pwsh -NoProfile -File ".agent/scripts/validate-compliance.ps1"
        elif [[ -f ".agent/scripts/validate-compliance.ps1" ]]; then
            info "Requires PowerShell. Install pwsh or run on Windows:"
            info "  .\.agent\agent.ps1 validate"
        else
            warning "validate-compliance.ps1 not found"
        fi
        ;;
    scan)
        if command -v pwsh &>/dev/null && [[ -f ".agent/scripts/secret-scan.ps1" ]]; then
            pwsh -NoProfile -File ".agent/scripts/secret-scan.ps1"
        elif [[ -f ".agent/scripts/secret-scan.ps1" ]]; then
            info "Requires PowerShell. Install pwsh or run on Windows:"
            info "  .\.agent\agent.ps1 scan"
        else
            warning "secret-scan.ps1 not found"
        fi
        ;;
    perf)
        if command -v pwsh &>/dev/null && [[ -f ".agent/scripts/performance-check.ps1" ]]; then
            pwsh -NoProfile -File ".agent/scripts/performance-check.ps1"
        elif [[ -f ".agent/scripts/performance-check.ps1" ]]; then
            info "Requires PowerShell. Install pwsh or run on Windows:"
            info "  .\.agent\agent.ps1 perf"
        else
            warning "performance-check.ps1 not found"
        fi
        ;;
    heal)
        if command -v pwsh &>/dev/null && [[ -f ".agent/scripts/auto-heal.ps1" ]]; then
            pwsh -NoProfile -File ".agent/scripts/auto-heal.ps1"
        elif [[ -f ".agent/scripts/auto-heal.ps1" ]]; then
            info "Requires PowerShell. Install pwsh or run on Windows:"
            info "  .\.agent\agent.ps1 heal"
        else
            warning "auto-heal.ps1 not found"
        fi
        ;;
    dx)
        if command -v pwsh &>/dev/null && [[ -f ".agent/scripts/dx-analytics.ps1" ]]; then
            pwsh -NoProfile -File ".agent/scripts/dx-analytics.ps1"
        elif [[ -f ".agent/scripts/dx-analytics.ps1" ]]; then
            info "Requires PowerShell. Install pwsh or run on Windows:"
            info "  .\.agent\agent.ps1 dx"
        else
            warning "dx-analytics.ps1 not found"
        fi
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        error "Unknown command: $1"
        show_help
        ;;
esac

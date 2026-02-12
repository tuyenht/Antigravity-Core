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
        fi
        
        if grep -q '"typescript"' package.json || [[ -f "tsconfig.json" ]]; then
            frontend+=("TypeScript")
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
    if [[ -f "requirements.txt" ]]; then
        detected=true
        if grep -qi "fastapi" requirements.txt; then
            backend+=("FastAPI")
        elif grep -qi "django" requirements.txt; then
            backend+=("Django")
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
    fi
    
    # Backend
    if [[ "$DETECTED_BACKEND" == *"Laravel"* ]]; then
        agents+=("laravel-specialist")
        info "  → laravel-specialist (Laravel)"
    elif [[ "$DETECTED_BACKEND" == *"Express"* ]] || [[ "$DETECTED_BACKEND" == *"Fastify"* ]]; then
        agents+=("backend-specialist")
        info "  → backend-specialist (Node.js)"
    fi
    
    # Mobile
    if [[ "$DETECTED_MOBILE" == *"React Native"* ]] || [[ "$DETECTED_MOBILE" == *"Flutter"* ]]; then
        agents+=("mobile-developer")
        info "  → mobile-developer"
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
    cat > .agent/PROJECT-README.md << EOF
# .agent Configuration for This Project

**Initialized:** $(date)

---

## Quick Commands

```bash
# Start new feature
./agent plan "feature description"

# Generate code
./agent scaffold [component-type]

# Run tests
./agent test

# Security audit
./agent security-audit

# Deploy
./agent deploy
```

---

## Example

```bash
# Build a blog system
./agent plan "Create a blog with posts, comments, and authentication"
```

System will auto-analyze and execute!

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

# Main
case "${1:-init}" in
    init)
        initialize_project "$2"
        ;;
    status)
        if [[ -f ".agent/project.json" ]]; then
            success "Project initialized!"
            cat .agent/project.json
        else
            warning "Not initialized. Run: ./agent init"
        fi
        ;;
    *)
        echo "Usage: ./agent <command>"
        echo ""
        echo "Commands:"
        echo "  init       Initialize .agent for this project"
        echo "  status     Show configuration"
        ;;
esac

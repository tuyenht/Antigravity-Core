#!/usr/bin/env bash
# discover-rules.sh — Auto-detect project tech stack and recommend rules/agents
# Bash equivalent of discover-rules.ps1 (3-layer detection engine)
# Usage: bash discover-rules.sh [--path /project] [--request "text"] [--json]

set -euo pipefail

PROJECT_PATH="."
REQUEST=""
FORMAT="text"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --path|-p) PROJECT_PATH="$2"; shift 2 ;;
        --request|-r) REQUEST="$2"; shift 2 ;;
        --json) FORMAT="json"; shift ;;
        *) echo "Unknown: $1"; exit 1 ;;
    esac
done
PROJECT_PATH=$(cd "$PROJECT_PATH" && pwd)

RULES=()
TECH_STACK=()

# === Layer 1: File Extension Scan ===
scan_extensions() {
    local exts
    exts=$(find "$PROJECT_PATH" -type f \( -name "*.vue" -o -name "*.svelte" -o -name "*.astro" \
        -o -name "*.swift" -o -name "*.kt" -o -name "*.dart" -o -name "*.php" \
        -o -name "*.py" -o -name "*.ts" -o -name "*.tsx" -o -name "*.cs" \
        -o -name "*.graphql" -o -name "*.sql" -o -name "*.proto" \) \
        ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/vendor/*" \
        ! -path "*/dist/*" ! -path "*/build/*" 2>/dev/null | \
        sed 's/.*\.//' | sort | uniq -c | sort -rn | head -15)
    
    while read -r count ext; do
        [ -z "$ext" ] && continue
        case "$ext" in
            vue) RULES+=("frontend-frameworks/vue3.md") ;;
            svelte) RULES+=("frontend-frameworks/svelte.md") ;;
            php) RULES+=("backend-frameworks/laravel.md") ;;
            py) RULES+=("python/fastapi.md") ;;
            ts|tsx) RULES+=("typescript/strict-mode.md") ;;
            swift) RULES+=("mobile/ios-swift.md") ;;
            kt) RULES+=("mobile/android-kotlin.md") ;;
            dart) RULES+=("mobile/flutter.md") ;;
            cs) RULES+=("backend-frameworks/aspnet-core.md") ;;
            graphql) RULES+=("backend-frameworks/graphql.md") ;;
            sql) RULES+=("database/postgresql.md") ;;
            proto) RULES+=("backend-frameworks/grpc.md") ;;
        esac
    done <<< "$exts"
}

# === Layer 2: Config Scan ===
scan_configs() {
    if [ -f "$PROJECT_PATH/package.json" ]; then
        local deps
        deps=$(cat "$PROJECT_PATH/package.json")
        [[ "$deps" == *'"next"'* ]] && RULES+=("nextjs/app-router.md") && TECH_STACK+=("Next.js")
        [[ "$deps" == *'"react"'* ]] && TECH_STACK+=("React")
        [[ "$deps" == *'"vue"'* ]] && RULES+=("frontend-frameworks/vue3.md") && TECH_STACK+=("Vue")
        [[ "$deps" == *'"svelte"'* ]] && TECH_STACK+=("Svelte")
        [[ "$deps" == *'"tailwindcss"'* ]] && RULES+=("frontend-frameworks/tailwind.md") && TECH_STACK+=("Tailwind CSS")
        [[ "$deps" == *'"typescript"'* ]] && TECH_STACK+=("TypeScript")
        [[ "$deps" == *'"prisma"'* ]] && RULES+=("database/postgresql.md") && TECH_STACK+=("Prisma")
        [[ "$deps" == *'"@nestjs/core"'* ]] && RULES+=("backend-frameworks/express.md") && TECH_STACK+=("NestJS")
        [[ "$deps" == *'"react-native"'* ]] && RULES+=("mobile/react-native.md") && TECH_STACK+=("React Native")
    fi
    [ -f "$PROJECT_PATH/composer.json" ] && grep -q "laravel/framework" "$PROJECT_PATH/composer.json" 2>/dev/null && RULES+=("backend-frameworks/laravel.md") && TECH_STACK+=("Laravel")
    [ -f "$PROJECT_PATH/requirements.txt" ] && TECH_STACK+=("Python") && grep -qi "fastapi" "$PROJECT_PATH/requirements.txt" 2>/dev/null && RULES+=("python/fastapi.md") && TECH_STACK+=("FastAPI")
    [ -f "$PROJECT_PATH/Cargo.toml" ] && TECH_STACK+=("Rust")
    [ -f "$PROJECT_PATH/go.mod" ] && TECH_STACK+=("Go")
    [ -f "$PROJECT_PATH/pubspec.yaml" ] && RULES+=("mobile/flutter.md") && TECH_STACK+=("Flutter")
    [ -d "$PROJECT_PATH/prisma" ] && RULES+=("database/postgresql.md") && TECH_STACK+=("Prisma")
    ([ -f "$PROJECT_PATH/Dockerfile" ] || [ -f "$PROJECT_PATH/docker-compose.yml" ]) && TECH_STACK+=("Docker")
}

# === Layer 3: Keyword Analysis ===
scan_keywords() {
    [ -z "$REQUEST" ] && return
    local lower
    lower=$(echo "$REQUEST" | tr '[:upper:]' '[:lower:]')
    [[ "$lower" =~ debug|fix|error|bug ]] && RULES+=("agentic-ai/debugging-agent.md")
    [[ "$lower" =~ test|unit.test|coverage ]] && RULES+=("agentic-ai/test-writing-agent.md")
    [[ "$lower" =~ security|audit|vulnerability ]] && RULES+=("agentic-ai/security-audit-agent.md")
    [[ "$lower" =~ refactor|cleanup ]] && RULES+=("agentic-ai/refactoring-agent.md")
    [[ "$lower" =~ optimize|performance|slow ]] && RULES+=("agentic-ai/performance-optimization-agent.md")
    [[ "$lower" =~ deploy|docker|ci.?cd ]] && RULES+=("agentic-ai/devops-cicd-agent.md")
    [[ "$lower" =~ schema|erd|data.model ]] && RULES+=("database/design.md")
    [[ "$lower" =~ redis|cache ]] && RULES+=("database/redis.md")
    [[ "$lower" =~ graphql|apollo ]] && RULES+=("backend-frameworks/graphql.md")
}

# === Agent Recommendation ===
AGENTS=()
recommend_agents() {
    for t in "${TECH_STACK[@]}"; do
        case "$t" in
            Laravel) AGENTS+=("laravel-specialist") ;;
            Next.js|React|Vue|Svelte) AGENTS+=("frontend-specialist") ;;
            Flutter|"React Native") AGENTS+=("mobile-developer") ;;
            FastAPI|Flask|NestJS) AGENTS+=("backend-specialist") ;;
            Prisma) AGENTS+=("database-architect") ;;
            Docker) AGENTS+=("devops-engineer") ;;
        esac
    done
    if [ -n "$REQUEST" ]; then
        local lower
        lower=$(echo "$REQUEST" | tr '[:upper:]' '[:lower:]')
        [[ "$lower" =~ debug|fix|error|bug ]] && AGENTS+=("debugger")
        [[ "$lower" =~ test|spec|coverage ]] && AGENTS+=("test-engineer")
        [[ "$lower" =~ security|audit ]] && AGENTS+=("security-auditor")
        [[ "$lower" =~ deploy|docker|ci ]] && AGENTS+=("devops-engineer")
        [[ "$lower" =~ optimize|performance ]] && AGENTS+=("performance-optimizer")
        [[ "$lower" =~ refactor|cleanup ]] && AGENTS+=("refactor-agent")
        [[ "$lower" =~ plan|design|architecture ]] && AGENTS+=("project-planner")
    fi
}

# Execute
scan_extensions
scan_configs
scan_keywords
recommend_agents

# Deduplicate
UNIQUE_RULES=($(printf '%s\n' "${RULES[@]}" | sort -u))
UNIQUE_STACK=($(printf '%s\n' "${TECH_STACK[@]}" | sort -u))
UNIQUE_AGENTS=($(printf '%s\n' "${AGENTS[@]}" | sort -u))

if [ "$FORMAT" = "json" ]; then
    echo "{"
    echo "  \"project_path\": \"$PROJECT_PATH\","
    echo "  \"tech_stack\": [$(printf '"%s",' "${UNIQUE_STACK[@]}" | sed 's/,$//')],"
    echo "  \"rules\": [$(printf '"%s",' "${UNIQUE_RULES[@]}" | sed 's/,$//')],"
    echo "  \"agents\": [$(printf '"%s",' "${UNIQUE_AGENTS[@]}" | sed 's/,$//')]"
    echo "}"
else
    echo ""
    echo "==============================================="
    echo "  Antigravity Auto-Rule Discovery Engine v1.0"
    echo "==============================================="
    echo ""
    echo "  Project: $PROJECT_PATH"
    echo ""
    echo "  Tech Stack Detected:"
    for t in "${UNIQUE_STACK[@]}"; do echo "    • $t"; done
    echo ""
    echo "  Recommended Rules (${#UNIQUE_RULES[@]}):"
    i=1
    for r in "${UNIQUE_RULES[@]}"; do
        printf "    %2d. %s\n" "$i" "$r"
        i=$((i + 1))
    done
    echo ""
    echo "  Recommended Agents:"
    local rank=1
    for a in "${UNIQUE_AGENTS[@]}"; do
        local label; [ "$rank" -eq 1 ] && label="PRIMARY" || label="SUPPORT"
        printf "    %d. [%s] %s\n" "$rank" "$label" "$a"
        rank=$((rank + 1))
    done
    [ -n "$REQUEST" ] && echo "" && echo "  Request: \"$REQUEST\""
    echo ""
    echo "==============================================="
fi

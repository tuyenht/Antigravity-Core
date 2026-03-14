#!/usr/bin/env bash
# detect-project.sh — Auto-detect project name and tech stack
# Bash equivalent of detect-project.ps1
# Usage: bash detect-project.sh

set -euo pipefail

get_project_name() {
    # Method 1: package.json
    if [ -f "package.json" ]; then
        local name
        name=$(python3 -c "import json; print(json.load(open('package.json')).get('name',''))" 2>/dev/null || \
               grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' package.json | head -1 | sed 's/"name"[[:space:]]*:[[:space:]]*"//;s/"//')
        if [ -n "$name" ]; then echo "$name"; return; fi
    fi

    # Method 2: pyproject.toml
    if [ -f "pyproject.toml" ]; then
        local name
        name=$(grep -m1 'name\s*=' pyproject.toml | sed 's/.*=\s*"//;s/".*//')
        if [ -n "$name" ]; then echo "$name"; return; fi
    fi

    # Method 3: Cargo.toml
    if [ -f "Cargo.toml" ]; then
        local name
        name=$(grep -m1 'name\s*=' Cargo.toml | sed 's/.*=\s*"//;s/".*//')
        if [ -n "$name" ]; then echo "$name"; return; fi
    fi

    # Method 4: Directory name
    basename "$(pwd)"
}

get_tech_stack() {
    local stack=()

    # Frontend
    if [ -f "package.json" ]; then
        local deps
        deps=$(cat package.json)
        [[ "$deps" == *'"react"'* ]] && stack+=("React")
        [[ "$deps" == *'"next"'* ]] && stack+=("Next.js")
        [[ "$deps" == *'"vue"'* ]] && stack+=("Vue")
        [[ "$deps" == *'"svelte"'* ]] && stack+=("Svelte")
        [[ "$deps" == *'"typescript"'* ]] && stack+=("TypeScript")
        [[ "$deps" == *'"tailwindcss"'* ]] && stack+=("Tailwind CSS")
    fi

    # Python
    if [ -f "requirements.txt" ]; then
        stack+=("Python")
        grep -qi "fastapi" requirements.txt 2>/dev/null && stack+=("FastAPI")
        grep -qi "django" requirements.txt 2>/dev/null && stack+=("Django")
        grep -qi "flask" requirements.txt 2>/dev/null && stack+=("Flask")
    fi

    # PHP/Laravel
    if [ -f "composer.json" ]; then
        local composer
        composer=$(cat composer.json)
        [[ "$composer" == *'laravel/framework'* ]] && stack+=("Laravel")
        [[ "$composer" == *'inertiajs'* ]] && stack+=("Inertia.js")
    fi

    # Other languages
    [ -f "Cargo.toml" ] && stack+=("Rust")
    [ -f "go.mod" ] && stack+=("Go")
    [ -f "pom.xml" ] && stack+=("Java")

    # Databases
    [ -d "prisma" ] && stack+=("Prisma")

    echo "${stack[*]}"
}

# Main
PROJECT_NAME=$(get_project_name)
TECH_STACK=$(get_tech_stack)

echo "Auto-detected project context:"
echo "  Project: $PROJECT_NAME"
echo "  Tech Stack: $TECH_STACK"

# Update user-profile.yaml if it exists
PROFILE_PATH=".agent/memory/user-profile.yaml"
if [ -f "$PROFILE_PATH" ]; then
    sed -i.bak "s/current_project:.*$/current_project: \"$PROJECT_NAME\"/" "$PROFILE_PATH" 2>/dev/null || \
      sed -i '' "s/current_project:.*$/current_project: \"$PROJECT_NAME\"/" "$PROFILE_PATH"
    rm -f "${PROFILE_PATH}.bak"
fi

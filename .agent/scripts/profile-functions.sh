#!/usr/bin/env bash
# profile-functions.sh — Shell profile functions for Antigravity-Core
# Bash equivalent of profile-functions.ps1
# Source this file in .bashrc/.zshrc: source "$ANTIGRAVITY_HOME/.agent/scripts/profile-functions.sh"

# Install Antigravity-Core to current project
agi() {
    local force=false
    [[ "${1:-}" == "--force" || "${1:-}" == "-f" ]] && force=true
    
    local source="${ANTIGRAVITY_HOME:?Set ANTIGRAVITY_HOME first}/.agent"
    local target="./.agent"
    
    if [ ! -d "$source" ]; then
        echo "❌ Antigravity-Core not found. Run global installer first."
        return 1
    fi
    
    if [ -d "$target" ]; then
        if $force; then
            rm -rf "$target"
        else
            echo "⚠️ .agent already exists. Use 'agi --force' to overwrite."
            return 1
        fi
    fi
    
    cp -r "$source" "$target"
    
    # Copy docs on first install
    local source_docs="$ANTIGRAVITY_HOME/docs"
    [ -d "$source_docs" ] && [ ! -d "./docs" ] && cp -r "$source_docs" "./docs"
    
    local version="unknown"
    [ -f "$target/VERSION" ] && version=$(cat "$target/VERSION" | tr -d '[:space:]')
    
    echo "✅ Antigravity-Core installed to current project! (v$version)"
}

# Update Antigravity-Core in current project from global
agu() {
    if [ ! -d "./.agent" ]; then
        echo "❌ No .agent folder. Run 'agi' first."
        return 1
    fi
    
    local backup_dir
    backup_dir=$(mktemp -d)
    
    # Backup memory
    [ -d "./.agent/memory" ] && cp -r "./.agent/memory" "$backup_dir/memory"
    [ -f "./.agent/project.json" ] && cp "./.agent/project.json" "$backup_dir/project.json"
    
    local old_version="unknown"
    [ -f "./.agent/VERSION" ] && old_version=$(cat "./.agent/VERSION" | tr -d '[:space:]')
    
    rm -rf "./.agent"
    agi
    
    # Restore
    [ -d "$backup_dir/memory" ] && cp -r "$backup_dir/memory" "./.agent/memory"
    [ -f "$backup_dir/project.json" ] && cp "$backup_dir/project.json" "./.agent/project.json"
    
    rm -rf "$backup_dir"
    
    local new_version="unknown"
    [ -f "./.agent/VERSION" ] && new_version=$(cat "./.agent/VERSION" | tr -d '[:space:]')
    
    echo "✅ Updated! ($old_version → $new_version)"
}

# Update global Antigravity-Core installation
agug() {
    bash "${ANTIGRAVITY_HOME:?}/.agent/scripts/update-global.sh"
}

# Show version on load
_ag_version="unknown"
[ -f "${ANTIGRAVITY_HOME:-}/.agent/VERSION" ] && _ag_version=$(cat "$ANTIGRAVITY_HOME/.agent/VERSION" | tr -d '[:space:]')
echo "🚀 Antigravity-Core loaded (v$_ag_version)"

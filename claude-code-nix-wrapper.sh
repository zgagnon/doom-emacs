#!/bin/bash

# Claude Code IDE Nix Develop Wrapper
# This script automatically detects nix flakes and enters nix develop environments
# when claude-code-ide starts a terminal session

set -euo pipefail

# Enable debug mode if CLAUDE_CODE_NIX_DEBUG is set
DEBUG=${CLAUDE_CODE_NIX_DEBUG:-0}

debug_log() {
    if [[ "$DEBUG" == "1" ]]; then
        echo "[claude-code-nix-wrapper] $*" >&2
    fi
}

# Function to find the nearest flake.nix file (excluding home directory unless it's the starting point)
find_flake_dir() {
    local dir="$1"
    local start_dir="$1"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/flake.nix" ]]; then
            # Don't use home directory unless we started there
            if [[ "$dir" == "$HOME" && "$start_dir" != "$HOME" ]]; then
                debug_log "Skipping flake.nix in home directory ($dir) - not the project root"
                dir=$(dirname "$dir")
                continue
            fi
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 1
}

# Function to find the nearest .envrc file (for direnv projects)
find_envrc_dir() {
    local dir="$1"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/.envrc" ]]; then
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 1
}

# Get the current working directory
CURRENT_DIR="${PWD:-$(pwd)}"
debug_log "Starting from directory: $CURRENT_DIR"

# Check for flake.nix first, then .envrc
if FLAKE_DIR=$(find_flake_dir "$CURRENT_DIR"); then
    debug_log "Found flake.nix in: $FLAKE_DIR"
    
    # Check if nix is available
    if ! command -v nix >/dev/null 2>&1; then
        debug_log "nix not found in PATH, running command directly"
        exec "$@"
    fi
    
    # Change to the flake directory and enter nix develop
    debug_log "Running: cd '$FLAKE_DIR' && nix develop --command $*"
    cd "$FLAKE_DIR" || {
        debug_log "Failed to change to $FLAKE_DIR, running command directly"
        exec "$@"
    }
    
    # Use nix develop to run the command in the proper environment
    exec nix develop --command "$@"
    
elif ENVRC_DIR=$(find_envrc_dir "$CURRENT_DIR"); then
    debug_log "Found .envrc in: $ENVRC_DIR"
    
    # Check if direnv is available
    if ! command -v direnv >/dev/null 2>&1; then
        debug_log "direnv not found in PATH, running command directly"
        exec "$@"
    fi
    
    # Change to the direnv directory and use direnv exec
    debug_log "Running: cd '$ENVRC_DIR' && direnv exec . $*"
    cd "$ENVRC_DIR" || {
        debug_log "Failed to change to $ENVRC_DIR, running command directly"
        exec "$@"
    }
    
    # Use direnv exec to run the command in the proper environment
    exec direnv exec . "$@"
else
    debug_log "No flake.nix or .envrc found, running command directly"
    # No nix flake or direnv found, run command directly
    exec "$@"
fi
#!/bin/bash

# Universal Elixir-LS Environment Wrapper
# Automatically detects and activates Nix flakes, direnv environments, or runs directly
# Consolidates previous direnv-only and nix-fix approaches

set -euo pipefail

# Enable debug mode if ELIXIR_LS_WRAPPER_DEBUG is set
DEBUG=${ELIXIR_LS_WRAPPER_DEBUG:-0}

debug_log() {
    if [[ "$DEBUG" == "1" ]]; then
        echo "[elixir-ls-universal] $*" >&2
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

# Function to find the nearest .envrc file
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

# Priority: Nix flakes first, then direnv, then direct execution
if FLAKE_DIR=$(find_flake_dir "$CURRENT_DIR"); then
    debug_log "Found flake.nix in: $FLAKE_DIR"
    
    # Check if nix is available
    if ! command -v nix >/dev/null 2>&1; then
        debug_log "nix not found in PATH, checking for direnv..."
    else
        # Change to the flake directory and enter nix develop
        debug_log "Running: cd '$FLAKE_DIR' && nix develop --command elixir-ls $*"
        cd "$FLAKE_DIR" || {
            debug_log "Failed to change to $FLAKE_DIR, checking for direnv..."
        }
        
        if [[ "$PWD" == "$FLAKE_DIR" ]]; then
            # Use nix develop to run elixir-ls in the proper environment
            exec nix develop --command elixir-ls "$@"
        fi
    fi
fi

# Fall back to direnv if Nix didn't work or wasn't available
if ENVRC_DIR=$(find_envrc_dir "$CURRENT_DIR"); then
    debug_log "Found .envrc in: $ENVRC_DIR"
    
    # Check if direnv is available
    if ! command -v direnv >/dev/null 2>&1; then
        debug_log "direnv not found in PATH, falling back to direct execution"
        exec elixir-ls "$@"
    fi
    
    # Change to the directory with .envrc and run elixir-ls with direnv
    debug_log "Running: cd '$ENVRC_DIR' && direnv exec . elixir-ls $*"
    cd "$ENVRC_DIR" || {
        debug_log "Failed to change to $ENVRC_DIR, falling back to direct execution"
        exec elixir-ls "$@"
    }
    
    # Use direnv exec to run elixir-ls in the proper environment
    exec direnv exec . elixir-ls "$@"
else
    debug_log "No flake.nix or .envrc found, running elixir-ls directly"
    # No environment management found, run elixir-ls directly
    exec elixir-ls "$@"
fi
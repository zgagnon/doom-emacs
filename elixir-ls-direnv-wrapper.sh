#!/bin/bash

# Universal Elixir-LS Direnv Wrapper
# This script automatically detects direnv environments and runs elixir-ls appropriately
# Works for all projects without requiring per-project configuration

set -euo pipefail

# Enable debug mode if ELIXIR_LS_WRAPPER_DEBUG is set
DEBUG=${ELIXIR_LS_WRAPPER_DEBUG:-0}

debug_log() {
    if [[ "$DEBUG" == "1" ]]; then
        echo "[elixir-ls-wrapper] $*" >&2
    fi
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

# Get the current working directory (where LSP is starting from)
CURRENT_DIR="${PWD:-$(pwd)}"
debug_log "Starting from directory: $CURRENT_DIR"

# Try to find .envrc in current directory or parent directories
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
    debug_log "No .envrc found, running elixir-ls directly"
    # No .envrc found, run elixir-ls directly
    exec elixir-ls "$@"
fi
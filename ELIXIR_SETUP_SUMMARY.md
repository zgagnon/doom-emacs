# Universal Elixir + Nix + direnv + LSP Setup

## Problem Solved

Previously, elixir-ls would fail to start in Elixir projects because it couldn't find the Elixir installation provided by Nix via direnv. This happened because elixir-ls was installed globally but ran outside the project's direnv environment.

## Solution: Universal Wrapper

Created a universal wrapper script that automatically detects direnv environments and runs elixir-ls appropriately for ALL projects.

## Files Created/Modified

### 1. Universal Wrapper Script
**Location**: `~/.doom.d/elixir-ls-direnv-wrapper.sh`
- Automatically detects `.envrc` files in current directory or parent directories
- Uses `direnv exec` to run elixir-ls in the proper environment if `.envrc` found
- Falls back to running elixir-ls directly if no `.envrc` found
- Includes debug mode (set `ELIXIR_LS_WRAPPER_DEBUG=1`)

### 2. Updated Emacs Configuration
**Location**: `~/.doom.d/elixir-nix-fix.el`
- Configures LSP to always use the universal wrapper
- Simplified from previous complex environment loading approach
- Includes debug functions for troubleshooting

### 3. Enhanced Test Suite
**Location**: `~/.doom.d/test-elixir-nix-setup.el`
- Tests the universal wrapper approach
- Verifies configuration across different projects
- Provides detailed diagnostics and recommendations

## How It Works

1. **LSP Startup**: When LSP starts elixir-ls, it runs the universal wrapper instead
2. **Environment Detection**: The wrapper finds the nearest `.envrc` file
3. **Direnv Execution**: If `.envrc` found, uses `direnv exec` to run elixir-ls in that environment
4. **Fallback**: If no `.envrc` found, runs elixir-ls normally

## Benefits

- ✅ **Works for all projects**: No per-project configuration needed
- ✅ **Automatic**: Detects direnv environments automatically
- ✅ **Consistent**: Same behavior across all Elixir projects
- ✅ **Graceful fallback**: Works for non-direnv projects too
- ✅ **Maintainable**: Single wrapper script to maintain
- ✅ **Debuggable**: Built-in debug mode for troubleshooting

## Verification

The setup has been tested and verified to work with:
- **imogen project**: Uses elixir-ls v0.28.1 with Elixir 1.18.4
- **alpacka project**: Uses elixir-ls v0.26.4 with Elixir 1.18.2 (with devenv)

## Usage

1. Open any Elixir file in a project with `.envrc`
2. Run `M-x lsp`
3. ElixirLS will automatically use the correct environment

## Troubleshooting

### Enable Debug Mode
```elisp
M-x enable-elixir-ls-wrapper-debug
```

### Run Tests
```elisp
M-x test-elixir-nix-setup
```

### Check Configuration
```elisp
M-x test-and-fix-elixir-nix-setup
```

## Migration from Per-Project Setup

If you had per-project wrapper scripts and `.dir-locals.el` files:
1. Remove or comment out the `.dir-locals.el` LSP configuration
2. Remove the per-project wrapper scripts (they're no longer needed)
3. The universal wrapper will handle everything automatically

## Configuration Details

The LSP configuration is now simply:
```elisp
(setq lsp-elixir-server-command '("/Users/zell/.doom.d/elixir-ls-direnv-wrapper.sh"))
```

This is set automatically when `elixir-nix-fix.el` is loaded.
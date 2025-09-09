# Doom Emacs Configuration - Zell

## Universal Elixir + Nix + direnv + LSP Setup

### Problem Solved

Previously, elixir-ls would fail to start in Elixir projects because it couldn't find the Elixir installation provided by Nix or direnv. This happened because elixir-ls was installed globally but ran outside the project's environment.

### Solution: Universal Environment Wrapper

Created a unified wrapper script that automatically detects and activates the appropriate development environment for ALL projects.

### Current Implementation

#### Universal Wrapper Script
**Location**: `~/.doom.d/nix-adapters/elixir-ls-universal-wrapper.sh`
- **Priority 1**: Detects Nix flakes (`flake.nix`) and uses `nix develop`
- **Priority 2**: Detects direnv environments (`.envrc`) and uses `direnv exec`  
- **Priority 3**: Falls back to running elixir-ls directly
- Includes debug mode (set `ELIXIR_LS_WRAPPER_DEBUG=1`)

#### Emacs Configuration
**Location**: `~/.doom.d/config.org` (Elixir section)
- LSP client registered to use universal wrapper
- Handles both `elixir-mode` and `elixir-ts-mode`
- Server ID: `elixir-ls-universal`

### 3. Enhanced Test Suite
**Location**: `~/.doom.d/test-elixir-nix-setup.el`
- Tests the universal wrapper approach
- Verifies configuration across different projects
- Provides detailed diagnostics and recommendations

### How It Works

1. **LSP Startup**: When LSP starts elixir-ls, it runs the universal wrapper instead
2. **Environment Detection**: The wrapper searches upward for:
   - `flake.nix` files (Nix flakes - highest priority)
   - `.envrc` files (direnv environments - second priority)
3. **Environment Activation**:
   - If `flake.nix` found: uses `nix develop --command elixir-ls`
   - If `.envrc` found: uses `direnv exec . elixir-ls` 
   - If neither found: runs `elixir-ls` directly
4. **Fallback**: Gracefully handles missing tools (nix, direnv)

## Benefits

- ✅ **Works for all projects**: No per-project configuration needed
- ✅ **Prioritizes Nix**: Nix flakes take precedence over direnv
- ✅ **Automatic**: Detects both Nix and direnv environments automatically  
- ✅ **Consistent**: Same behavior across all Elixir projects
- ✅ **Graceful fallback**: Works for projects without environment management
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

The LSP configuration is now integrated into `config.org`:
```elisp
(lsp-register-client
 (make-lsp-client
  :new-connection (lsp-stdio-connection
                   (lambda ()
                     (list (expand-file-name "~/.doom.d/nix-adapters/elixir-ls-universal-wrapper.sh"))))
  :major-modes '(elixir-mode elixir-ts-mode)
  :priority 1
  :server-id 'elixir-ls-universal))
```

This replaces the previous separate `elixir-nix-fix.el` file approach.
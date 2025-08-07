# Nix Test Project

This is a minimal test project to verify claude-code-ide nix integration.

## Test Commands

When claude-code-ide is working correctly with nix develop:

1. `test-nix-env` - Should show available tools and confirm nix environment
2. `hello` - Should run the hello command from nixpkgs
3. `cowsay "Hello from nix!"` - Should run cowsay
4. `figlet "NIX WORKS"` - Should display ASCII art
5. `echo $NIX_TEST_PROJECT_ACTIVE` - Should show "true"

## Expected Behavior

- When you open claude-code-ide from this directory, it should automatically detect the flake.nix
- The terminal should show the nix develop environment is active
- All the test commands above should work
- You should see the custom PS1 prompt with `[nix-test]` prefix

## Troubleshooting

If the integration isn't working:
- Check that the wrapper script exists and is executable
- Enable debug mode: `export CLAUDE_CODE_NIX_DEBUG=1`
- Check for errors in Emacs *Messages* buffer
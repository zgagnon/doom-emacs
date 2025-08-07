{
  description = "Test flake for claude-code-ide nix integration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Basic tools for testing
            hello
            cowsay
            figlet
            # Add a custom environment variable to easily identify we're in nix develop
            (pkgs.writeShellScriptBin "test-nix-env" ''
              echo "✅ Successfully running in nix develop environment!"
              echo "Available tools:"
              echo "  - hello: $(which hello)"
              echo "  - cowsay: $(which cowsay)" 
              echo "  - figlet: $(which figlet)"
              echo "Environment marker: $NIX_TEST_PROJECT_ACTIVE"
            '')
          ];
          
          shellHook = ''
            export NIX_TEST_PROJECT_ACTIVE="true"
            export PS1="\[\033[1;32m\][nix-test]\[\033[0m\] $PS1"
            echo "🚀 Entered nix develop environment for claude-code-ide test"
            echo "Run 'test-nix-env' to verify everything is working"
          '';
        };
      });
}
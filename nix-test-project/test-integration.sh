#!/bin/bash

# Test script for claude-code-ide nix integration
# This script tests both the wrapper directly and through the expected integration

set -e

echo "🧪 Testing claude-code-ide nix integration..."
echo "==============================================="

# Test 1: Direct wrapper test
echo "🔍 Test 1: Testing wrapper script directly..."
cd "$(dirname "$0")"
CLAUDE_CODE_NIX_DEBUG=1 ~/.doom.d/claude-code-nix-wrapper.sh test-nix-env

echo ""
echo "🔍 Test 2: Testing environment detection..."
CLAUDE_CODE_NIX_DEBUG=1 ~/.doom.d/claude-code-nix-wrapper.sh sh -c 'echo "NIX_TEST_PROJECT_ACTIVE: ${NIX_TEST_PROJECT_ACTIVE:-not set}"'

echo ""
echo "🔍 Test 3: Testing tool availability..."
CLAUDE_CODE_NIX_DEBUG=1 ~/.doom.d/claude-code-nix-wrapper.sh sh -c 'which hello cowsay figlet | head -3'

echo ""
echo "✅ Wrapper script tests completed!"
echo ""
echo "📋 Next steps:"
echo "1. Open this directory in Emacs"
echo "2. Run 'SPC r c s' to start claude-code-ide"
echo "3. In the claude-code-ide terminal, run: test-nix-env"
echo "4. You should see the nix environment is active"
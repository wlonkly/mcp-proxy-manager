#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect mcp-proxy
MCP_PROXY="$(which mcp-proxy 2>/dev/null || echo /opt/homebrew/bin/mcp-proxy)"

# Build PATH for the launchd environment — combine current PATH with common tool dirs
LAUNCH_PATH="$PATH"

PLIST_DEST="$HOME/Library/LaunchAgents/com.user.mcp-proxy.plist"
SCRIPT_DEST="$HOME/.local/bin/mcp-manage"

echo "Installing mcp-proxy-manager..."
echo "  mcp-proxy:  $MCP_PROXY"
echo "  plist:      $PLIST_DEST"
echo "  script:     $SCRIPT_DEST"

# Generate plist from template
sed \
    -e "s|@@HOME@@|$HOME|g" \
    -e "s|@@MCP_PROXY@@|$MCP_PROXY|g" \
    -e "s|@@PATH@@|$LAUNCH_PATH|g" \
    "$REPO_DIR/com.user.mcp-proxy.plist.template" \
    > "$PLIST_DEST"

echo "  plist written."

# Install mcp-manage script
mkdir -p "$HOME/.local/bin"
cp "$REPO_DIR/mcp-manage" "$SCRIPT_DEST"
chmod +x "$SCRIPT_DEST"

echo "  mcp-manage installed."
echo ""
echo "Done. Next steps:"
echo "  1. Add an MCP server:  mcp-manage add <name> <command> [args...]"
echo "  2. Start the service:  mcp-manage reload"
echo "  3. Register with Claude Code:  mcp-manage register <name> [--scope user]"

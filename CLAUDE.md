# mcp-proxy-manager

## Purpose

This repo provides tooling to run local CLI-based MCP servers under managed Claude deployments that only allow HTTP transports. It wraps them in `mcp-proxy`, which exposes each server as an HTTP/SSE endpoint.

## Components

### `mcp-manage`
A Python script (stdlib only, no virtualenv needed) that manages the `mcp-proxy` server registry and launchd lifecycle.

- **Installed to**: `~/.local/bin/mcp-manage`
- **Config file**: `~/.config/mcp-proxy/servers.json`
  - Format: `{"mcpServers": {"<name>": {"command": "...", "args": [...], "env": {...}}}}`
- **Plist**: `~/Library/LaunchAgents/com.user.mcp-proxy.plist`

### `com.user.mcp-proxy.plist.template`
The launchd plist template. Uses `@@HOME@@`, `@@MCP_PROXY@@`, and `@@PATH@@` as placeholders substituted by `install.sh`.

### `install.sh`
Generates the plist and installs `mcp-manage`. No build step, no dependencies.

## Key details

- **Port**: `9000` (hardcoded in both the plist and `mcp-manage`)
- **SSE URL pattern**: `http://localhost:9000/servers/<name>/sse`
- **`mcp-proxy` flag**: `--named-server-config` points at `servers.json`; `--pass-environment` forwards the launchd environment to child processes
- **Logs**: `~/.config/mcp-proxy/proxy.log` (stdout + stderr combined)
- **Service management**: `launchctl load/unload` via `mcp-manage reload`

## No tests

There are no automated tests. Verification is manual:
1. Run `./install.sh`
2. Run `mcp-manage list`
3. Confirm the installed plist has no `@@` placeholders

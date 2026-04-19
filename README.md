# mcp-proxy-manager

## What this is

Managed Claude deployments sometimes restrict MCP servers to HTTP transports only, disabling local CLI-based MCPs. This repo solves that by wrapping local MCP servers in [`mcp-proxy`](https://github.com/sparfenyuk/mcp-proxy), which exposes them as HTTP/SSE endpoints via a persistent launchd service.

The `mcp-manage` script manages the server registry (`~/.config/mcp-proxy/servers.json`) and the launchd service lifecycle. Once installed, your local MCPs are reachable at `http://localhost:9000/servers/<name>/sse`.

## Prerequisites

Install `mcp-proxy`:

```sh
brew install mcp-proxy
# or
uv tool install mcp-proxy
```

Ensure `~/.local/bin` is in your `PATH`.

## Installation

```sh
git clone https://github.com/wlonkly/mcp-proxy-manager
cd mcp-proxy-manager
./install.sh
```

This will:
- Generate `~/Library/LaunchAgents/com.user.mcp-proxy.plist` from the template
- Copy `mcp-manage` to `~/.local/bin/mcp-manage`

## Usage

### Add a server

```sh
mcp-manage add github npx -y @modelcontextprotocol/server-github
mcp-manage add filesystem uvx mcp-server-filesystem /path/to/dir
```

You'll be prompted to enter any `KEY=VALUE` environment variables the server needs (e.g. `GITHUB_TOKEN=...`).

### Apply changes

```sh
mcp-manage reload
```

Unloads and reloads the launchd service with the current server list.

### List configured servers

```sh
mcp-manage list
```

### Remove a server

```sh
mcp-manage remove github
mcp-manage reload
```

### Get a JSON snippet for a project's MCP settings

```sh
mcp-manage snippet github
```

Prints the `mcpServers` JSON block to paste into a project config.

### Check proxy health

```sh
mcp-manage status
```

### Register with Claude Code

```sh
mcp-manage register github
mcp-manage register github --scope user
```

Runs `claude mcp add --transport sse <name> <url>` for you.

## How it works

- **`mcp-proxy`** runs as a persistent launchd service (auto-starts on login, restarts on crash).
- It reads `~/.config/mcp-proxy/servers.json` at startup, launching each configured MCP subprocess.
- Each server is reachable at `http://localhost:9000/servers/<name>/sse`.
- `mcp-manage` edits the JSON config and reloads the service via `launchctl`.
- Logs go to `~/.config/mcp-proxy/proxy.log`.

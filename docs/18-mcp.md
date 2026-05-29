# Model Context Protocol (MCP)

**Status:** Completed

Open standard by Anthropic for connecting AI assistants to external tools, data sources, and services. Used by Claude Code, Claude Desktop, Zed, and other AI clients.

---

## How It Works

```
AI Client (Claude Code / Zed)
        ↕  MCP Protocol
MCP Server (filesystem, database, API, etc.)
```

MCP servers expose tools and resources that AI clients can call. You run servers locally and configure clients to connect to them.

---

## Prerequisites

- Node.js v18+ (via nvm — see `02-development-fundamentals.md`)
- Python 3.10+ with `uv` for Python-based servers

---

## MCP in Claude Code

Claude Code has built-in MCP support. Add servers via the CLI:

```bash
# Add a server (scope: local = this project, user = all projects)
claude mcp add <name> <command> [args...]

# List configured servers
claude mcp list

# Remove a server
claude mcp remove <name>
```

### Filesystem Server

Gives Claude Code access to read/write files beyond the project directory:

```bash
claude mcp add filesystem npx @modelcontextprotocol/server-filesystem /home/azad/code
```

### Fetch Server

Lets Claude fetch URLs and read web content:

```bash
claude mcp add fetch npx @modelcontextprotocol/server-fetch
```

### PostgreSQL Server

Lets Claude query your local PostgreSQL database:

```bash
claude mcp add postgres npx @modelcontextprotocol/server-postgres postgresql://localhost/mydb
```

### Google Drive

```bash
claude mcp add gdrive npx @modelcontextprotocol/server-gdrive
```

---

## MCP in Zed

Add servers to `~/.config/zed/settings.json`:

```json
{
  "context_servers": {
    "filesystem": {
      "command": {
        "path": "npx",
        "args": [
          "-y",
          "@modelcontextprotocol/server-filesystem",
          "/home/azad/code"
        ]
      }
    },
    "fetch": {
      "command": {
        "path": "npx",
        "args": ["-y", "@modelcontextprotocol/server-fetch"]
      }
    }
  }
}
```

---

## Useful MCP Servers

| Server | Install | Purpose |
|--------|---------|---------|
| `@modelcontextprotocol/server-filesystem` | npx | Read/write local files |
| `@modelcontextprotocol/server-fetch` | npx | Fetch URLs |
| `@modelcontextprotocol/server-postgres` | npx | Query PostgreSQL |
| `@modelcontextprotocol/server-sqlite` | npx | Query SQLite |
| `@modelcontextprotocol/server-github` | npx | GitHub issues, PRs, repos |
| `@modelcontextprotocol/server-gdrive` | npx | Google Drive files |
| `@modelcontextprotocol/server-slack` | npx | Slack messages |

---

## Building a Custom MCP Server (Python)

```bash
uv pip install mcp
```

`my_server.py`:

```python
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("my-server")

@mcp.tool()
def query_data(table: str) -> str:
    """Query data from a table."""
    # Your implementation here
    return f"Results from {table}"

@mcp.resource("data://schema")
def get_schema() -> str:
    """Return the database schema."""
    return "table: users (id, name, email)"

if __name__ == "__main__":
    mcp.run()
```

Register it with Claude Code:

```bash
claude mcp add my-server python my_server.py
```

---

## Project-scoped MCP Config

Store MCP config per project in `.claude/settings.json` at the repo root:

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": [
        "@modelcontextprotocol/server-postgres",
        "postgresql://localhost/myproject_db"
      ]
    }
  }
}
```

---

## Resources

- MCP specification: https://modelcontextprotocol.io
- Official servers: https://github.com/modelcontextprotocol/servers

---

[Back to README](../README.md)

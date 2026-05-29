# Claude Code Setup on Fedora

**Status:** Completed

AI coding assistant from Anthropic, runs in the terminal with full project context.

---

## Prerequisites

Node.js is required. This guide assumes you have `nvm` installed (see `02-development-fundamentals.md`).

```bash
# Verify Node.js is available
node --version   # v18+ required, v20+ recommended
npm --version
```

If not installed:

```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
source ~/.bashrc

# Install latest LTS Node.js
nvm install --lts
nvm use --lts
```

---

## Installation

```bash
npm install -g @anthropic-ai/claude-code
```

Verify:

```bash
claude --version
```

---

## API Key Setup

1. Get your API key from: https://console.anthropic.com/settings/keys

2. Add it to your shell profile (`~/.bashrc` or `~/.zshrc`):

```bash
echo 'export ANTHROPIC_API_KEY="sk-ant-your-key-here"' >> ~/.bashrc
source ~/.bashrc
```

3. Verify:

```bash
echo $ANTHROPIC_API_KEY
```

---

## First Run

```bash
# Navigate to a project
cd ~/code/apps/my-project

# Launch Claude Code
claude
```

On first run, Claude Code will ask you to accept the terms of service.

---

## Basic Usage

```bash
# Open in current directory
claude

# Ask a one-off question (non-interactive)
claude "explain what this repo does"

# Run with a specific file as context
claude "refactor this function" src/main.py
```

### Common In-Session Commands

| Command    | Action                              |
|------------|-------------------------------------|
| `/help`    | Show all available commands         |
| `/compact` | Compress conversation to save context|
| `/clear`   | Start fresh conversation            |
| `/cost`    | Show token usage for this session   |
| `Ctrl+C`   | Cancel current operation            |
| `Ctrl+D`   | Exit Claude Code                    |

---

## Shell Integration

To open Claude Code from any directory, ensure nvm's Node.js bin is on your PATH:

```bash
# In ~/.bashrc - nvm loads Node automatically
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

Reload:

```bash
source ~/.bashrc
which claude   # should show path under ~/.nvm/versions/node/.../bin/claude
```

---

## Zed Integration

Claude Code runs in the terminal. Open the integrated terminal in Zed with `Ctrl+`` ` and run `claude` from your project root.

---

## Configuration

Claude Code stores settings at `~/.claude/`:

```bash
ls ~/.claude/
# settings.json   - global settings
# CLAUDE.md       - persistent instructions loaded every session
```

Add project-level instructions by creating `CLAUDE.md` in a repo root:

```bash
cat > ~/code/apps/my-project/CLAUDE.md << 'EOF'
# Project Notes

- Use Python 3.11
- Follow PEP 8
- Tests are in tests/ directory, run with pytest
EOF
```

---

## Model Selection

Claude Code uses Sonnet by default. To switch models:

```bash
# In session
/model claude-opus-4-6

# Or set default in ~/.claude/settings.json
{
  "model": "claude-sonnet-4-6"
}
```

Available models:
- `claude-sonnet-4-6` - default, fast and capable
- `claude-opus-4-6` - most capable, slower

---

## Permissions

Claude Code asks before running commands. You can pre-approve tools:

```bash
# In session - allow bash commands without prompting
/permissions
```

Or configure in `~/.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(pytest *)",
      "Bash(git *)"
    ]
  }
}
```

---

## Updating

```bash
npm update -g @anthropic-ai/claude-code
```

---

[Back to README](../README.md)

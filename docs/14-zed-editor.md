# Zed Editor

**Status:** Completed

Fast, modern code editor written in Rust. Built-in AI assistant, collaborative editing, and native performance.

---

## Installation

```bash
# Official installer script
curl -f https://zed.dev/install.sh | sh
```

Installs to `~/.local/zed.app/` with a symlink at `~/.local/bin/zed`.

Verify:

```bash
zed --version
which zed   # ~/.local/bin/zed
```

### Updating

```bash
# Zed updates itself automatically, or run the installer again
curl -f https://zed.dev/install.sh | sh
```

---

## CLI Usage

```bash
# Open current directory
zed .

# Open a specific folder
zed ~/code/apps/my-project

# Open a specific file
zed src/main.py

# Open multiple files
zed src/main.py tests/test_main.py
```

### Shell Integration

`~/.local/bin` must be on your PATH. Add to `~/.bashrc` if not already present:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

---

## Configuration

Settings file: `~/.config/zed/settings.json`

```bash
zed ~/.config/zed/settings.json
```

### Recommended Settings

```json
{
  "theme": "One Dark",
  "buffer_font_family": "JetBrains Mono",
  "buffer_font_size": 14,
  "ui_font_size": 14,
  "tab_size": 4,
  "format_on_save": "on",
  "autosave": "on_focus_change",
  "vim_mode": false,
  "terminal": {
    "shell": "system",
    "font_size": 13
  },
  "git": {
    "inline_blame": {
      "enabled": true
    }
  }
}
```

---

## AI Assistant (Claude)

Zed has a built-in AI assistant powered by Claude.

### Setup

1. Open Assistant panel: `Ctrl+?` or `View → Assistant`
2. Click the model selector and choose a provider
3. For Claude: enter your Anthropic API key when prompted

Or add directly to `~/.config/zed/settings.json`:

```json
{
  "assistant": {
    "default_model": {
      "provider": "anthropic",
      "model": "claude-sonnet-4-6"
    },
    "version": "2"
  }
}
```

### Usage

| Action | Shortcut |
|--------|----------|
| Open assistant panel | `Ctrl+?` |
| Inline AI edit | `Ctrl+Enter` (select code first) |
| Accept suggestion | `Tab` |

---

## Extensions

Open extension manager: `Ctrl+Shift+X` or `zed: extensions` in command palette.

### Recommended Extensions

```
Python
Rust
TOML
Docker
YAML
Terraform
Markdown
```

Install via command palette (`Ctrl+Shift+P`):

```
zed: extensions → search and install
```

---

## Keybindings

Keymap file: `~/.config/zed/keymap.json`

### Essential Shortcuts

| Action | Shortcut |
|--------|----------|
| Command palette | `Ctrl+Shift+P` |
| Open file | `Ctrl+P` |
| Toggle terminal | `Ctrl+`` ` |
| Toggle file tree | `Ctrl+B` |
| Split pane right | `Ctrl+\` |
| Find in project | `Ctrl+Shift+F` |
| Go to definition | `F12` |
| Rename symbol | `F2` |
| Format file | `Ctrl+Shift+I` |
| Toggle AI assistant | `Ctrl+?` |

---

## Language Server (LSP)

Zed uses LSP for language intelligence. Python requires a language server:

```bash
# Pyright (recommended)
npm install -g pyright

# Or use the Python extension which bundles its own
```

Configure in `~/.config/zed/settings.json`:

```json
{
  "languages": {
    "Python": {
      "language_servers": ["pyright"],
      "format_on_save": "on",
      "formatter": {
        "external": {
          "command": "black",
          "arguments": ["-", "--quiet"]
        }
      }
    }
  }
}
```

---

## Terminal

Zed has a built-in terminal. Toggle with `Ctrl+`` ` .

```json
{
  "terminal": {
    "shell": "system",
    "working_directory": "current_project_directory",
    "font_size": 13,
    "line_height": "comfortable"
  }
}
```

---

## Project-level Config

Add a `.zed/settings.json` to any project to override global settings:

```bash
mkdir -p ~/code/apps/my-project/.zed
cat > ~/code/apps/my-project/.zed/settings.json << 'EOF'
{
  "tab_size": 2,
  "languages": {
    "Python": {
      "tab_size": 4
    }
  }
}
EOF
```

---

[Back to README](../README.md)

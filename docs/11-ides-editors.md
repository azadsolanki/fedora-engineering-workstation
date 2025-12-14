# IDEs & Editors

Development environment setup.

---

## VS Code

### Installation

```bash
# Add Microsoft repository
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

cat << 'REPO' | sudo tee /etc/yum.repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
REPO

# Install
sudo dnf install code -y
```

### Essential Extensions

```bash
# Python
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance

# Jupyter
code --install-extension ms-toolsai.jupyter

# YAML/K8s
code --install-extension redhat.vscode-yaml
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools

# Git
code --install-extension eamodio.gitlens

# Docker/Containers
code --install-extension ms-azuretools.vscode-docker
```

### Settings

Edit `~/.config/Code/User/settings.json`:

```json
{
  "editor.formatOnSave": true,
  "python.formatting.provider": "black",
  "[python]": {
    "editor.defaultFormatter": "ms-python.black-formatter"
  }
}
```

---

## AI Assistants (Optional)

### GitHub Copilot

```bash
code --install-extension GitHub.copilot
```

Requires: GitHub Copilot subscription ($10/month)

### Codeium (Free)

```bash
code --install-extension Codeium.codeium
```

Free alternative to Copilot.

### Continue.dev (Open Source)

```bash
code --install-extension Continue.continue
```

Works with Claude API, Ollama, or other LLMs.

---

## Jupyter Lab

```bash
# In your project venv
uv pip install jupyterlab
jupyter lab
```

---

## Optional IDEs

**PyCharm** - If you prefer JetBrains IDEs  
**IntelliJ IDEA** - Only if writing Scala/Java Spark

---

**Status:** ✅ Completed

[Back to README](../README.md)
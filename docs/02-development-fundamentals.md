# Development Fundamentals

Essential Git and shell configuration.

---

## Git Setup

### Installation

```bash
sudo dnf install -y git
```

### Configuration

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main
git config --global pull.rebase true
```

### SSH Key for GitHub

```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Display public key
cat ~/.ssh/id_ed25519.pub
```

Add the key to GitHub: Settings → SSH and GPG keys → New SSH key

Test connection:
```bash
ssh -T git@github.com
```

### Useful Aliases

```bash
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.lg "log --graph --oneline --decorate"
```

---

## Shell Configuration

### Bash Aliases

Add to `~/.bashrc`:

```bash
# Navigation
alias ll='ls -lah'
alias ..='cd ..'

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'

# Python
alias activate='source .venv/bin/activate'

# Podman
alias pd='podman'
alias pds='podman ps'

# Kubernetes
alias k='kubectl'
alias kgp='kubectl get pods'
```

Apply changes:
```bash
source ~/.bashrc
```

---

## Optional: Enhanced Tools

Modern alternatives to classic commands:

```bash
# Install if you want them
sudo dnf install -y \
    bat       # Better cat
    fzf       # Fuzzy finder
    ripgrep   # Better grep
    fd-find   # Better find
```

---

## Next Steps

- [Containerization](03-containerization.md)
- [Python Ecosystem](04-python-ecosystem.md)

---

**Status:** ✅ Completed

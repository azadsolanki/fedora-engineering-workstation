# System aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gco='git checkout'
alias gb='git branch'
alias gd='git diff'
alias glg='git log --graph --oneline --decorate'

# Python aliases
alias py='python3'
alias activate='source .venv/bin/activate'

# Podman aliases
alias pd='podman'
alias pds='podman ps'
alias pdi='podman images'
alias pdl='podman logs'
alias pde='podman exec -it'

# Kubernetes aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kdp='kubectl describe pod'
alias kl='kubectl logs'
alias kx='kubectl exec -it'

# Directory shortcuts
alias cda='cd ~/code/apps'
alias cdi='cd ~/code/infra'
alias cdl='cd ~/code/learning'

#!/bin/bash
#
# Fedora Engineering Workstation Bootstrap Script
# 
# This script automates the initial setup of a Fedora workstation
# for data engineering, platform engineering, and cloud-native development.
#
# Usage: ./scripts/bootstrap.sh
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Fedora
check_os() {
    log_info "Checking operating system..."
    if [ ! -f /etc/fedora-release ]; then
        log_error "This script is designed for Fedora Linux"
        exit 1
    fi
    log_success "Running on Fedora $(cat /etc/fedora-release)"
}

# Update system
update_system() {
    log_info "Updating system packages..."
    sudo dnf update -y
    log_success "System updated"
}

# Install base packages
install_base_packages() {
    log_info "Installing base packages..."
    
    local packages=(
        "curl"
        "wget"
        "git"
        "vim"
        "tmux"
        "htop"
        "bat"
        "fzf"
        "ripgrep"
        "jq"
        "lm_sensors"
    )
    
    sudo dnf install -y "${packages[@]}"
    log_success "Base packages installed"
}

# Configure Git
configure_git() {
    log_info "Configuring Git..."
    
    # Check if already configured
    if git config --global user.name &> /dev/null; then
        log_warning "Git already configured. Skipping."
        return
    fi
    
    # Prompt for user information
    read -p "Enter your Git user name: " git_name
    read -p "Enter your Git email: " git_email
    
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    git config --global init.defaultBranch main
    git config --global pull.rebase true
    git config --global color.ui auto
    
    log_success "Git configured for $git_name <$git_email>"
}

# Install Podman
install_podman() {
    log_info "Installing Podman..."
    sudo dnf install -y podman
    log_success "Podman installed: $(podman --version)"
}

# Install kubectl
install_kubectl() {
    log_info "Installing kubectl..."
    sudo dnf install -y kubectl
    log_success "kubectl installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
}

# Install Java
install_java() {
    log_info "Installing Java 21..."
    sudo dnf install -y java-21-openjdk-devel
    
    # Set JAVA_HOME
    if ! grep -q "JAVA_HOME" ~/.bashrc; then
        echo 'export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))' >> ~/.bashrc
        log_success "JAVA_HOME added to ~/.bashrc"
    fi
    
    log_success "Java installed: $(java -version 2>&1 | head -n 1)"
}

# Install UV (Python manager)
install_uv() {
    log_info "Installing UV..."
    
    if command -v uv &> /dev/null; then
        log_warning "UV already installed. Skipping."
        return
    fi
    
    curl -LsSf https://astral.sh/uv/install.sh | sh
    log_success "UV installed"
}

# Install Python
install_python() {
    log_info "Installing Python 3.11.9 with UV..."
    
    # Source bashrc to get uv in PATH
    export PATH="$HOME/.cargo/bin:$PATH"
    
    if command -v uv &> /dev/null; then
        uv python install 3.11.9
        log_success "Python 3.11.9 installed"
    else
        log_error "UV not found. Please restart your shell and run this script again."
        exit 1
    fi
}

# Setup directory structure
setup_directories() {
    log_info "Creating directory structure..."
    
    mkdir -p ~/code/{apps,infra,learning}
    mkdir -p ~/tools
    mkdir -p ~/data
    
    log_success "Directory structure created:"
    tree -L 2 ~/code 2>/dev/null || ls -la ~/code
}

# Install TLP for power management (ThinkPad optimization)
install_tlp() {
    log_info "Installing TLP for power management..."
    sudo dnf install -y tlp tlp-rdw
    sudo systemctl enable tlp
    sudo systemctl start tlp
    log_success "TLP installed and enabled"
}

# Setup power profiles daemon
setup_power_profiles() {
    log_info "Setting up power-profiles-daemon..."
    sudo dnf install -y power-profiles-daemon
    sudo systemctl enable --now power-profiles-daemon
    
    # Set to balanced mode
    powerprofilesctl set balanced 2>/dev/null || log_warning "Could not set power profile. Set manually later."
    log_success "Power profiles configured"
}

# Generate SSH key
generate_ssh_key() {
    log_info "Checking for SSH key..."
    
    if [ -f ~/.ssh/id_ed25519 ]; then
        log_warning "SSH key already exists. Skipping generation."
        return
    fi
    
    read -p "Generate SSH key for GitHub? (y/n): " generate_key
    if [ "$generate_key" == "y" ]; then
        read -p "Enter email for SSH key: " ssh_email
        ssh-keygen -t ed25519 -C "$ssh_email" -f ~/.ssh/id_ed25519 -N ""
        
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_ed25519
        
        log_success "SSH key generated. Add this to GitHub:"
        echo ""
        cat ~/.ssh/id_ed25519.pub
        echo ""
    fi
}

# Create summary
print_summary() {
    echo ""
    echo "========================================"
    log_success "Bootstrap Complete!"
    echo "========================================"
    echo ""
    echo "Installed components:"
    echo "  ✓ Base packages (git, tmux, fzf, etc.)"
    echo "  ✓ Podman (containers)"
    echo "  ✓ kubectl (Kubernetes)"
    echo "  ✓ Java 21"
    echo "  ✓ UV (Python manager)"
    echo "  ✓ Python 3.11.9"
    echo "  ✓ TLP (power management)"
    echo ""
    echo "Directory structure created:"
    echo "  ~/code/apps/     - Application projects"
    echo "  ~/code/infra/    - Infrastructure projects"
    echo "  ~/code/learning/ - Learning and experiments"
    echo "  ~/tools/         - Local binaries"
    echo "  ~/data/          - Datasets and resources"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.bashrc"
    echo "  2. Add SSH key to GitHub (if generated)"
    echo "  3. Review documentation in docs/ folder"
    echo "  4. Start with: docs/02-development-fundamentals.md"
    echo ""
    log_info "Run ./scripts/verify-setup.sh to verify installation"
    echo ""
}

# Main execution
main() {
    echo ""
    echo "========================================"
    echo "  Fedora Engineering Setup Bootstrap"
    echo "========================================"
    echo ""
    
    check_os
    update_system
    install_base_packages
    configure_git
    install_podman
    install_kubectl
    install_java
    install_uv
    install_python
    setup_directories
    install_tlp
    setup_power_profiles
    generate_ssh_key
    print_summary
}

# Run main function
main

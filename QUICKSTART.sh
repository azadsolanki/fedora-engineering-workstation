#!/bin/bash
#
# Quick Start Script
# Run this after extracting the repository
#

echo "======================================"
echo "  Fedora Engineering Setup"
echo "  Quick Start Initialization"
echo "======================================"
echo ""

# Check if in correct directory
if [ ! -f "README.md" ] || [ ! -d "docs" ]; then
    echo "ERROR: Please run this script from the fedora-setup directory"
    echo "Example: cd fedora-setup && ./QUICKSTART.sh"
    exit 1
fi

echo "Step 1: Customizing files..."
echo ""
read -p "Enter your name: " USER_NAME
read -p "Enter your email: " USER_EMAIL
read -p "Enter your GitHub username: " GITHUB_USER

# Update gitconfig
sed -i "s/Your Name/$USER_NAME/" dotfiles/.gitconfig
sed -i "s/your.email@example.com/$USER_EMAIL/" dotfiles/.gitconfig

# Update LICENSE
sed -i "s/\[Your Name\]/$USER_NAME/" LICENSE

# Update README
sed -i "s/YOUR_USERNAME/$GITHUB_USER/g" README.md
sed -i "s/YOUR_USERNAME/$GITHUB_USER/g" SETUP.md

echo "✓ Files customized"
echo ""

echo "Step 2: Initialize Git repository..."
git init -b main
git add .
git commit -m "feat: initial repository setup

- Cloud-native data engineering setup for Fedora
- Apache/CNCF focus with GCP integration
- Comprehensive documentation and learning paths
- Automated setup scripts and project templates"

echo "✓ Git repository initialized"
echo ""

echo "======================================"
echo "  Next Steps:"
echo "======================================"
echo ""
echo "1. Create repository on GitHub:"
echo "   - Go to: https://github.com/new"
echo "   - Name: fedora-engineering-setup"
echo "   - Do NOT initialize with README"
echo ""
echo "2. Connect and push:"
echo "   git remote add origin git@github.com:$GITHUB_USER/fedora-engineering-setup.git"
echo "   git push -u origin main"
echo ""
echo "3. Or use GitHub CLI:"
echo "   gh repo create fedora-engineering-setup --public --source=."
echo ""
echo "4. Run setup script:"
echo "   ./scripts/bootstrap.sh"
echo ""
echo "See SETUP.md for detailed instructions"
echo ""

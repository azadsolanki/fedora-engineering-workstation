# Complete Setup Guide

Step-by-step instructions to set up this repository and push to GitHub.

---

## Prerequisites

- Fedora Workstation installed
- Internet connection
- GitHub account

---

## Step 1: Extract Repository

```bash
# Navigate to where you downloaded/extracted the repository
cd ~/Downloads/fedora-setup  # or wherever you extracted it

# Or if you're starting fresh, create the directory
mkdir -p ~/repos
cd ~/repos
# Then copy the fedora-setup folder here
```

---

## Step 2: Customize Files

### Update README.md

Replace `YOUR_USERNAME` with your GitHub username:

```bash
# Use your text editor
vim README.md
# or
nano README.md
```

### Update .gitconfig

Edit `dotfiles/.gitconfig`:

```gitconfig
[user]
    name = Your Actual Name
    email = your.actual.email@example.com
```

### Update LICENSE

Edit `LICENSE` and replace `[Your Name]` with your actual name.

---

## Step 3: Initialize Git Repository

```bash
# Make sure you're in the fedora-setup directory
cd fedora-setup

# Initialize git
git init -b main

# Add all files
git add .

# Create initial commit
git commit -m "feat: initial repository setup

- Complete documentation structure for cloud-native data engineering
- Apache Spark, Kafka, Iceberg, dbt, Trino documentation
- Google Cloud Platform integration guide
- Kubernetes and CNCF tools setup
- Comprehensive learning paths and troubleshooting
- Automated setup and verification scripts
- Project templates for PySpark development

Documented installations:
- Base system (Fedora, ThinkPad optimizations)
- Git, Podman, kubectl, kind
- Java 21, Python 3.11 with UV
- Apache Spark (local + Podman modes)

Planned additions:
- Apache Kafka, Airflow, Iceberg
- dbt, Trino
- GCP SDK and tools
- Helm, ArgoCD
- Prometheus, Grafana"
```

---

## Step 4: Create GitHub Repository

### Option A: Via GitHub Website

1. Go to https://github.com/new
2. Repository name: `fedora-engineering-setup`
3. Description: `Cloud-native data engineering workstation setup for Fedora`
4. Keep it Public (or Private if you prefer)
5. **DO NOT** initialize with README, .gitignore, or license (we already have these)
6. Click "Create repository"

### Option B: Via GitHub CLI

```bash
# Install gh if not already installed
sudo dnf install gh

# Authenticate
gh auth login

# Create repository
gh repo create fedora-engineering-setup \
    --public \
    --description "Cloud-native data engineering workstation setup for Fedora" \
    --source=.
```

---

## Step 5: Push to GitHub

After creating the repository on GitHub, connect and push:

```bash
# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin git@github.com:YOUR_USERNAME/fedora-engineering-setup.git

# Or use HTTPS if you haven't set up SSH:
# git remote add origin https://github.com/YOUR_USERNAME/fedora-engineering-setup.git

# Push to GitHub
git push -u origin main
```

### If you get SSH errors:

Generate SSH key (if you haven't already):

```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Display public key
cat ~/.ssh/id_ed25519.pub
```

Then add the public key to GitHub:
1. Go to https://github.com/settings/keys
2. Click "New SSH key"
3. Paste your public key
4. Try pushing again

---

## Step 6: Verify on GitHub

Visit: `https://github.com/YOUR_USERNAME/fedora-engineering-setup`

You should see:
- All documentation files
- Proper folder structure
- README displaying nicely

---

## Step 7: Make Repository Your Own

### Clone on Another Machine

```bash
git clone git@github.com:YOUR_USERNAME/fedora-engineering-setup.git
cd fedora-engineering-setup
chmod +x scripts/*.sh
./scripts/bootstrap.sh
```

### As You Install New Tools

```bash
# Example: After installing Kafka
# 1. Update docs/06-data-engineering.md with Kafka setup
vim docs/06-data-engineering.md

# 2. Commit changes
git add docs/06-data-engineering.md
git commit -m "docs: add Apache Kafka installation and configuration"

# 3. Push to GitHub
git push
```

### Update Your Progress

```bash
# Update LEARNING.md
vim LEARNING.md

# Commit
git add LEARNING.md
git commit -m "docs: update learning progress"
git push
```

---

## Step 8: Use the Repository

### Run Bootstrap Script

```bash
chmod +x scripts/bootstrap.sh
./scripts/bootstrap.sh
```

### Verify Installation

```bash
chmod +x scripts/verify-setup.sh
./scripts/verify-setup.sh
```

### Follow Documentation

Start with:
1. [Base System](docs/01-base-system.md)
2. [Development Fundamentals](docs/02-development-fundamentals.md)
3. [Containerization](docs/03-containerization.md)

---

## Ongoing Maintenance

### Regular Updates

```bash
# Pull latest changes (if working from multiple machines)
git pull

# Make changes
vim docs/some-file.md

# Commit and push
git add .
git commit -m "docs: description of changes"
git push
```

### Good Commit Messages

Follow this format:

```
<type>: <description>

[optional body]
```

Types:
- `docs:` - Documentation changes
- `feat:` - New feature/tool installed
- `fix:` - Bug fix or correction
- `chore:` - Maintenance tasks
- `refactor:` - Reorganization

Examples:
- `docs: add dbt installation guide`
- `feat: configure Apache Iceberg with Spark`
- `fix: correct Java path in bootstrap script`
- `chore: update Python dependencies`

---

## Troubleshooting Setup

### Can't push to GitHub

```bash
# Check remote
git remote -v

# If wrong, remove and re-add
git remote remove origin
git remote add origin git@github.com:YOUR_USERNAME/fedora-engineering-setup.git
```

### Permission denied (publickey)

```bash
# Test SSH connection
ssh -T git@github.com

# If fails, check SSH key is added
ssh-add -l

# Add key if missing
ssh-add ~/.ssh/id_ed25519
```

### Already exists on GitHub

If you get an error that files already exist:

```bash
# Pull first, then push
git pull origin main --allow-unrelated-histories
git push -u origin main
```

---

## Next Steps

1. ✅ Repository is now on GitHub
2. ✅ You can clone it on any machine
3. ⏭️ Start installing tools and documenting your journey
4. ⏭️ Commit regularly as you learn
5. ⏭️ Update LEARNING.md to track progress

Your commit history will show your actual learning journey!

---

## Questions?

- Check [Troubleshooting](docs/troubleshooting.md)
- Create an issue in your repository
- Review GitHub's documentation

---

Happy learning and building! 🚀

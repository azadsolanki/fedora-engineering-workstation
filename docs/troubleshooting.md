# Troubleshooting

Common issues and solutions encountered during setup.

## Hardware Issues

### ThinkPad Heating While Charging

**Problem:** Laptop gets hot during intensive workloads while plugged in.

**Solution:**

```bash
# Install TLP for power management
sudo dnf install -y tlp tlp-rdw
sudo systemctl enable --now tlp

# Install power profiles daemon
sudo dnf install -y power-profiles-daemon
sudo systemctl enable --now power-profiles-daemon

# Set to balanced mode
powerprofilesctl set balanced

# Monitor temperatures
sudo dnf install -y lm_sensors
sudo sensors-detect  # Answer YES to all
sensors
```

**Additional tips:**
- Elevate laptop slightly for better airflow
- Clean vents if dusty
- Use balanced/power-saver mode when not needed
- Check for BIOS updates

### Power Management Not Working

**Problem:** `powerprofilesctl: command not found`

**Solution:**

```bash
sudo dnf install -y power-profiles-daemon
sudo systemctl enable --now power-profiles-daemon
```

## Terminal Issues

### Bracketed Paste Characters

**Problem:** Seeing `^[[200~` when pasting commands in terminal.

**Solution:**

```bash
echo 'set enable-bracketed-paste off' >> ~/.inputrc
```

Then restart your terminal.


## Installation Issues

### Package Not Found

**Problem:** `No match for argument: java-17-openjdk-devel`

**Solution:**

Fedora repositories may not have all Java versions. Use available versions:

```bash
# Search for available versions
dnf search openjdk

# Install Java 21 instead
sudo dnf install -y java-21-openjdk-devel
```

### UV Not Found After Installation

**Problem:** `uv: command not found` after installation.

**Solution:**

```bash
# Add to PATH
export PATH="$HOME/.cargo/bin:$PATH"
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## Java Issues

### JAVA_HOME Not Set

**Problem:** Spark can't find Java.

**Solution:**

```bash
# Set JAVA_HOME dynamically
echo 'export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))' >> ~/.bashrc
source ~/.bashrc

# Verify
echo $JAVA_HOME
java -version
```

### Wrong Java Version

**Problem:** Multiple Java versions installed.

**Solution:**

```bash
# List alternatives
sudo alternatives --config java

# Select correct version
# Then update JAVA_HOME
source ~/.bashrc
```

## Python Issues

### Virtual Environment Not Activating

**Problem:** `source .venv/bin/activate` doesn't work.

**Solution:**

```bash
# Make sure venv was created
ls -la .venv/

# If not, create it
uv venv --python 3.11.9

# Activate with correct path
source .venv/bin/activate
```

### Package Installation Fails

**Problem:** `uv pip install` fails with dependency errors.

**Solution:**

```bash
# Try with fresh environment
rm -rf .venv
uv venv --python 3.11.9
source .venv/bin/activate
uv pip install -r requirements.txt
```

## Container Issues

### Podman Permission Denied

**Problem:** Permission errors when running podman.

**Solution:**

```bash
# Add user to podman group
sudo usermod -aG podman $USER
newgrp podman

# Verify
podman ps
```

### Container Won't Start

**Problem:** Spark container fails to start.

**Solution:**

```bash
# Check container logs
podman logs spark-master

# Remove and recreate
podman stop spark-master
podman rm spark-master

# Recreate with correct ports
podman run -d \
  --name spark-master \
  -p 8080:8080 \
  -p 7077:7077 \
  -e SPARK_MODE=master \
  bitnami/spark:3.5.0
```

### Port Already in Use

**Problem:** Port 8080 already in use.

**Solution:**

```bash
# Find what's using the port
sudo lsof -i :8080

# Kill process or use different port
podman run -d -p 8081:8080 ...
```

## Kubernetes Issues

### kind Cluster Won't Create

**Problem:** `kind create cluster` fails.

**Solution:**

```bash
# Make sure podman is running
podman ps

# Delete existing cluster
kind delete cluster --name dev-cluster

# Recreate
kind create cluster --name dev-cluster
```

### kubectl Can't Connect

**Problem:** `kubectl` can't connect to cluster.

**Solution:**

```bash
# Check context
kubectl config current-context

# Switch to correct context
kubectl config use-context kind-dev-cluster

# Verify
kubectl cluster-info
```

## Git Issues

### SSH Key Not Working

**Problem:** Can't push to GitHub.

**Solution:**

```bash
# Test SSH connection
ssh -T git@github.com

# If fails, add key to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Add public key to GitHub
cat ~/.ssh/id_ed25519.pub
```

### Merge Conflicts

**Problem:** Git merge conflicts during pull.

**Solution:**

```bash
# Pull with rebase
git pull --rebase

# If conflicts, resolve and continue
# Edit conflicted files
git add .
git rebase --continue
```

## Network Issues

### Can't Access Spark UI

**Problem:** http://localhost:8080 not accessible.

**Solution:**

```bash
# Check container is running
podman ps

# Check port mapping
podman port spark-master

# Check firewall
sudo firewall-cmd --list-ports

# Add port if needed
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
```

## General Troubleshooting

### System Update Issues

```bash
# Clean cache
sudo dnf clean all
sudo dnf makecache

# Update
sudo dnf update -y
```

### Check System Resources

```bash
# CPU and memory
htop

# Disk space
df -h

# Disk usage by directory
ncdu ~
```

### Check Logs

```bash
# System logs
journalctl -xe

# Specific service
journalctl -u servicename

# Follow logs
journalctl -f
```

## Getting More Help

If issues persist:

1. Check official documentation
2. Search GitHub issues
3. Ask on Stack Overflow
4. Check Fedora forums
5. File a bug report

---

[Back to README](../README.md)

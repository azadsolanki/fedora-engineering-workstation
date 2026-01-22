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

### Kubeadm Cluster Fails on Different Networks

**Problem:** `kubectl` commands timeout when connecting to kubeadm cluster from different WiFi networks (library, cafe, friend's house). Error: `dial tcp 192.168.x.x:6443: i/o timeout`

**Why This Happens:**

Kubeadm clusters bind to your laptop's network IP address during initialization. When you switch networks:
1. Your laptop gets a new IP address (e.g., home: `192.168.4.73` → library: `10.0.50.25`)
2. The kubeconfig still points to the old IP address
3. API server certificates are tied to the old IP address
4. The cluster becomes unreachable because that IP doesn't exist on the new network

**Solution - Make Cluster Network-Agnostic:**

Save this as `make-kubeadm-portable.sh`:
```bash
#!/bin/bash
# Makes kubeadm cluster work on any network by using localhost

set -e

echo "=== Making kubeadm cluster portable ==="

# Backup certificates
echo "1. Backing up certificates..."
BACKUP_DIR="/etc/kubernetes/pki.backup.$(date +%Y%m%d_%H%M%S)"
sudo cp -r /etc/kubernetes/pki "$BACKUP_DIR"
echo "   Backup saved to: $BACKUP_DIR"

# Get current IP for backwards compatibility
CURRENT_IP=$(ip -4 addr show | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}' | cut -d/ -f1)
echo "2. Current IP detected: $CURRENT_IP"

# Create kubeadm config
echo "3. Creating kubeadm config..."
cat <<EOF | sudo tee /tmp/kubeadm-apiserver-portable.yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
apiServer:
  certSANs:
  - "127.0.0.1"
  - "localhost"
  - "$CURRENT_IP"
  extraArgs:
    advertise-address: "0.0.0.0"
    bind-address: "0.0.0.0"
EOF

# Delete old API server certs
echo "4. Removing old API server certificates..."
sudo rm -f /etc/kubernetes/pki/apiserver.crt
sudo rm -f /etc/kubernetes/pki/apiserver.key

# Regenerate certificates with localhost
echo "5. Regenerating certificates with localhost support..."
sudo kubeadm init phase certs apiserver --config=/tmp/kubeadm-apiserver-portable.yaml

# Update API server manifest
echo "6. Updating API server configuration..."
if grep -q "advertise-address" /etc/kubernetes/manifests/kube-apiserver.yaml; then
    sudo sed -i 's/--advertise-address=[0-9.]\+/--advertise-address=0.0.0.0/' /etc/kubernetes/manifests/kube-apiserver.yaml
else
    # Add advertise-address if it doesn't exist
    sudo sed -i '/- kube-apiserver/a\    - --advertise-address=0.0.0.0' /etc/kubernetes/manifests/kube-apiserver.yaml
fi

# Restart kubelet
echo "7. Restarting kubelet..."
sudo systemctl restart kubelet

# Wait for API server to restart
echo "8. Waiting for API server to restart (60 seconds)..."
sleep 60

# Update kubeconfig to use localhost
echo "9. Updating kubeconfig to use localhost..."
kubectl config set-cluster kubernetes --server=https://127.0.0.1:6443

# Verify setup
echo ""
echo "=== Verification ==="

echo "API server listening on:"
sudo ss -tlnp | grep :6443 | head -1

echo ""
echo "Kubeconfig server:"
kubectl config view --minify | grep server:

echo ""
echo "Testing kubectl (this may take a moment)..."
if kubectl get nodes &>/dev/null; then
    echo "✅ SUCCESS: Cluster is accessible!"
    kubectl get nodes
else
    echo "❌ FAILED: Cluster not accessible yet. Wait 30 more seconds and try: kubectl get nodes"
fi

echo ""
echo "=== Setup Complete ==="
echo "Your cluster now works on ANY network!"
echo "Backup location: $BACKUP_DIR"
```

**Run the script:**
```bash
chmod +x make-kubeadm-portable.sh
./make-kubeadm-portable.sh
```

**Verify it works:**
```bash
# Check kubeconfig uses localhost
kubectl config view --minify | grep server:
# Should show: https://127.0.0.1:6443

# Test kubectl
kubectl get nodes
kubectl get pods -A
```

**Rollback (If Something Goes Wrong):**
```bash
#!/bin/bash
# Rollback script - restore original certificates

echo "=== Rolling back kubeadm changes ==="

# Find most recent backup
BACKUP_DIR=$(ls -td /etc/kubernetes/pki.backup.* 2>/dev/null | head -1)

if [ -z "$BACKUP_DIR" ]; then
    echo "❌ No backup found!"
    echo "Available backups:"
    ls -ld /etc/kubernetes/pki.backup.* 2>/dev/null || echo "None"
    exit 1
fi

echo "Found backup: $BACKUP_DIR"
read -p "Restore from this backup? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Rollback cancelled"
    exit 0
fi

# Restore certificates
echo "1. Restoring certificates..."
sudo rm -rf /etc/kubernetes/pki
sudo cp -r "$BACKUP_DIR" /etc/kubernetes/pki

# Restore kubeconfig (you may need to update this to your old IP)
echo "2. Update kubeconfig to your current IP or old IP:"
CURRENT_IP=$(ip -4 addr show | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}' | cut -d/ -f1)
echo "   Current IP: $CURRENT_IP"
read -p "   Enter API server IP to use [$CURRENT_IP]: " API_IP
API_IP=${API_IP:-$CURRENT_IP}

kubectl config set-cluster kubernetes --server=https://$API_IP:6443

# Restart kubelet
echo "3. Restarting kubelet..."
sudo systemctl restart kubelet

echo "4. Waiting for API server (60 seconds)..."
sleep 60

# Test
echo "5. Testing connection..."
if kubectl get nodes &>/dev/null; then
    echo "✅ Rollback successful!"
    kubectl get nodes
else
    echo "⚠️  Cluster not responding yet. Try manually:"
    echo "   kubectl get nodes"
fi

echo ""
echo "=== Rollback Complete ==="
```

**Save rollback as:**
```bash
chmod +x rollback-kubeadm-portable.sh
./rollback-kubeadm-portable.sh
```

### Pods Stuck in ContainerCreating - Missing CNI Binaries

### Issue Summary
**Symptom**: Pods stuck in `ContainerCreating` status on worker1  
**Error**: `no CNI configuration file in /etc/cni/net.d/`  
**Root Cause**: CNI plugin binaries missing from `/opt/cni/bin/`  
**Impact**: All pods on worker1 failed to start  

### Diagnosis
```bash
kubectl describe pod <pod>              # Get error
virsh console worker1
sudo systemctl status containerd         # Running? If not, start it
ls -la /etc/cni/net.d/                  # Config exists?
ls -la /opt/cni/bin/                    # Binaries exist? ← KEY CHECK
# Should see: bridge, dhcp, flannel, host-local, loopback, macvlan, portmap, etc.
```

### Fix
```bash
# On worker node:
sudo dnf install containernetworking-plugins -y
sudo cp /usr/libexec/cni/* /opt/cni/bin/
sudo systemctl restart containerd kubelet
exit

# From master:
kubectl delete pod <stuck-pods>
```

### Prevention
```bash
# On all worker nodes during setup:
sudo dnf install containernetworking-plugins -y
sudo systemctl enable containerd kubelet
```

### Key Takeaway
CNI config file ≠ CNI binaries. Flannel only provides `flannel` binary - install `containernetworking-plugins` for the rest.

---

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

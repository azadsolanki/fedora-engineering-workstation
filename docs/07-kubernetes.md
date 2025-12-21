# Kubernetes Development

Local Kubernetes setup with kubectl, kind, and kubeadm.

---

## Overview

Two approaches for Kubernetes on Fedora:

1. **kind** - Quick, easy, isolated (recommended for learning)
2. **kubeadm** - Full cluster experience (for production-like setup)

---

## Option 1: kubectl + kind (Already Installed)

### Installation

```bash
# kubectl
sudo dnf install -y kubectl

# kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

### Create Cluster

```bash
# Basic cluster
kind create cluster --name dev-cluster

# Multi-node cluster
cat <<EOF | kind create cluster --name multi-node --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
EOF

# Verify
kubectl cluster-info --context kind-dev-cluster
kubectl get nodes
kubectl get pods -A
```

### Delete Cluster

```bash
kind delete cluster --name dev-cluster
```

---

## Option 2: kubeadm (Full Cluster Setup)

Follow the [official Fedora Kubernetes guide](https://docs.fedoraproject.org/en-US/quick-docs/using-kubernetes-kubeadm/).

### Single-Node Setup

### Prerequisites

```bash
# Update system
sudo dnf update -y

# Disable swap (required for Kubernetes)
sudo systemctl stop swap-create@zram0
sudo dnf remove zram-generator-defaults -y
sudo reboot now
```

### System Configuration

```bash
# Disable firewall (for learning environment)
sudo systemctl disable --now firewalld

# Install required packages
sudo dnf install -y iptables iproute-tc conntrack-tools
```

### Configure Kernel Networking

```bash
# Load kernel modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Configure sysctl
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply settings
sudo sysctl --system

# Verify
lsmod | grep br_netfilter
lsmod | grep overlay
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward
```

### Install Container Runtime (CRI-O)

```bash
# Check available versions
sudo dnf list cri-o1.??

# Install CRI-O matching Kubernetes version (e.g., 1.31)
sudo dnf install -y cri-o1.31 containernetworking-plugins

# Start and enable
sudo systemctl enable --now crio
```

### Install Kubernetes

```bash
# Check available versions
sudo dnf list kubernetes1.??

# Install Kubernetes 1.31 (change version as needed)
sudo dnf install -y \
    kubernetes1.31 \
    kubernetes1.31-kubeadm \
    kubernetes1.31-client \
    cri-tools1.31

# Lock versions (prevent accidental updates)
sudo dnf install -y 'dnf-command(versionlock)'
sudo dnf versionlock add 'kubernetes*-1.31.*' 'cri-o-1.31.*' 'cri-tools1.31'

# Enable kubelet
sudo systemctl enable --now kubelet
```

### Initialize Cluster

```bash
# Pull images (optional)
sudo kubeadm config images pull

# Initialize cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Setup kubectl for non-root user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Allow scheduling on control plane (single-node)
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

### Install Pod Network (Flannel)

```bash
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Wait for pods to be ready
kubectl get pods -n kube-flannel -w
# Press Ctrl+C when all are Running
```

### Verify Cluster

```bash
# Check nodes
kubectl get nodes
# Should show: Ready

# Check all pods
kubectl get pods --all-namespaces
# All should be Running

# Test cluster
kubectl run test --image=nginx
kubectl get pods
kubectl delete pod test
```

---


## Multi-Node Cluster with VMs

Create a real multi-node Kubernetes cluster using KVM/libvirt virtual machines.

### Prerequisites

```bash
# Install virtualization
sudo dnf install @virtualization virt-manager -y
sudo systemctl enable --now libvirtd

# Set system session as default
export LIBVIRT_DEFAULT_URI="qemu:///system"
echo 'export LIBVIRT_DEFAULT_URI="qemu:///system"' >> ~/.bashrc

# Verify default network exists and is active
virsh net-list

# If 'default' not shown, create it:
cat > /tmp/default-network.xml << 'NETEOF'
<network>
  <name>default</name>
  <bridge name="virbr0"/>
  <forward mode="nat"/>
  <ip address="192.168.122.1" netmask="255.255.255.0">
    <dhcp>
      <range start="192.168.122.2" end="192.168.122.254"/>
    </dhcp>
  </ip>
</network>
NETEOF

sudo virsh net-define /tmp/default-network.xml
sudo virsh net-start default
sudo virsh net-autostart default
```

### Download Fedora ISO

```bash
mkdir -p ~/VMs
cd ~/VMs
curl -LO https://download.fedoraproject.org/pub/fedora/linux/releases/41/Server/x86_64/iso/Fedora-Server-netinst-x86_64-41-1.4.iso
```

### Create Worker Node VM

```bash
# Create worker1
sudo virt-install \
  --name worker1 \
  --memory 2048 \
  --vcpus 2 \
  --disk size=20 \
  --cdrom ~/VMs/Fedora-Server-netinst-x86_64-41-1.4.iso \
  --os-variant fedora41 \
  --network network=default \
  --graphics vnc \
  --noautoconsole

# Open console for installation
virt-manager
```

### Install Fedora on Worker Node

**Critical Settings (Write Down Credentials!):**

1. **Software Selection:** Fedora Server Edition
2. **Network & Hostname:**
   - **Toggle network ON** ✅ (Very important!)
   - Hostname: `worker1`
3. **Root Password:**
   - Enable root account
   - Set password and write it down
   - Check "Allow root SSH login with password"
4. **User Creation:**
   - Username: `azad` (or your preference)
   - Set password and write it down
   - Check "Make this user administrator"

### Get Worker Node IP

```bash
# After installation and reboot (wait 30 seconds)
virsh domifaddr worker1

# Or check DHCP leases
virsh net-dhcp-leases default

# Expected IP: 192.168.122.x
```

### Configure Worker Node for Kubernetes

**SSH to worker node:**

```bash
ssh azad@192.168.122.100  # Use actual IP
```

**Run full Kubernetes setup:**

```bash
# Become root
sudo -i

# 1. Update system
dnf update -y

# 2. Disable swap
systemctl stop swap-create@zram0
dnf remove zram-generator-defaults -y

# 3. Install prerequisites
dnf install -y iptables iproute-tc conntrack-tools

# 4. Load kernel modules
modprobe overlay
modprobe br_netfilter

cat <<KEOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
KEOF

# 5. Configure sysctl
cat <<KEOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
KEOF

sysctl --system

# 6. Verify
lsmod | grep br_netfilter
lsmod | grep overlay

# 7. Install CRI-O (match master K8s version)
dnf install -y cri-o1.31 containernetworking-plugins
systemctl enable --now crio

# 8. Install Kubernetes
dnf install -y kubernetes1.31 kubernetes1.31-kubeadm kubernetes1.31-client cri-tools1.31

# 9. Disable firewall
systemctl disable --now firewalld

# 10. Enable kubelet
systemctl enable kubelet

# 11. Reboot (for swap disable to take full effect)
reboot
```

### Join Worker to Cluster

**On master node (control plane):**

```bash
# Generate fresh join command
sudo kubeadm token create --print-join-command

# Copy the entire output
```

**On worker node (after reboot):**

```bash
# SSH back in
ssh azad@192.168.122.100

# Become root
sudo -i

# IMPORTANT: Add --cri-socket flag to join command
kubeadm join <MASTER_IP>:6443 \
  --token <TOKEN> \
  --discovery-token-ca-cert-hash sha256:<HASH> \
  --cri-socket unix:///var/run/crio/crio.sock
```

### Verify Multi-Node Cluster

**On master node:**

```bash
# Check nodes
kubectl get nodes

# Should show:
# NAME      STATUS   ROLES           AGE   VERSION
# fedora    Ready    control-plane   1d    v1.31.14
# worker1   Ready    <none>          2m    v1.31.14

# Test deployment across nodes
kubectl create deployment nginx --image=nginx --replicas=6
kubectl get pods -o wide

# Pods should spread across control-plane and worker1

# Check node details
kubectl describe node worker1
```

### Add Additional Workers

Repeat for worker2, worker3, etc.:

```bash
# Create worker2 VM
sudo virt-install \
  --name worker2 \
  --memory 2048 \
  --vcpus 2 \
  --disk size=20 \
  --cdrom ~/VMs/Fedora-Server-netinst-x86_64-41-1.4.iso \
  --os-variant fedora41 \
  --network network=default \
  --graphics vnc \
  --noautoconsole

# Install Fedora (set hostname: worker2)
# Configure Kubernetes (same steps)
# Generate new token on master
# Join to cluster
```

### VM Management Commands

```bash
# List all VMs
virsh list --all

# Start VM
virsh start worker1

# Stop VM gracefully
virsh shutdown worker1

# Force stop
virsh destroy worker1

# Reboot VM
virsh reboot worker1

# Delete VM completely
virsh undefine worker1 --remove-all-storage

# Get VM IP
virsh domifaddr worker1

# SSH shortcut
ssh azad@$(virsh domifaddr worker1 | grep ipv4 | awk '{print $4}' | cut -d'/' -f1)

# Console access
virsh console worker1
# (Exit with Ctrl+])
```

---

## Troubleshooting

### CoreDNS CrashLoopBackOff

Common issue on VMs. Fix by editing CoreDNS config:

```bash
kubectl edit configmap coredns -n kube-system

# Change: forward . /etc/resolv.conf
# To: forward . 8.8.8.8
```

Or disable systemd-resolved stub:

```bash
sudo mkdir -p /etc/systemd/resolved.conf.d/
cat <<EOF | sudo tee /etc/systemd/resolved.conf.d/stub-listener.conf
[Resolve]
DNSStubListener=no
EOF

sudo systemctl restart systemd-resolved
```
### Pods Scheduling on Master Node

**Problem:** Pods are being scheduled on the master/control-plane node instead of only on worker nodes. Pods may be stuck in `ContainerCreating` status on master.

**Cause:** Master node is missing the standard control-plane taint that prevents pod scheduling.

**Verify:**
```bash
kubectl describe node <master-node-name> | grep -i taint
# Should show: node-role.kubernetes.io/control-plane:NoSchedule
# Problem shows: <none>
```

**Fix:**
```bash
# Add control-plane taint to master
kubectl taint nodes <master-node-name> node-role.kubernetes.io/control-plane:NoSchedule

# Delete pods stuck on master
kubectl delete pod --field-selector spec.nodeName=<master-node-name> --all-namespaces

# Or for specific deployment
kubectl delete pod -l app=<app-label> --field-selector spec.nodeName=<master-node-name>

# Verify - all pods should now be on worker nodes
kubectl get pods -o wide --all-namespaces
```

**Related Error:**
```
Failed to create pod sandbox: error adding pod to CNI network "cbr0": 
failed to set bridge addr: "cni0" already has an IP address different from 10.244.0.1/24
```
#### Best Practice
✅ Master/control-plane nodes should be dedicated to cluster management
✅ User workloads should run exclusively on worker nodes
✅ Control-plane taint ensures resource isolation and cluster stability

### Worker Node Issues

#### Worker Has Wrong Hostname

**Problem:** Node shows as `localhost.localdomain` instead of `worker1`

**Fix:**

```bash
# On worker node
sudo hostnamectl set-hostname worker1
hostname  # Verify

# On master, delete old node
kubectl delete node localhost.localdomain

# On worker, reset and rejoin
sudo kubeadm reset -f
sudo rm -rf /etc/kubernetes/ /var/lib/kubelet/ ~/.kube/

# Get fresh join command from master
# Then rejoin with correct hostname
```

#### Cannot Join - Files Already Exist

**Problem:**
```
[ERROR FileAvailable--etc-kubernetes-kubelet.conf]: /etc/kubernetes/kubelet.conf already exists
```

**Fix:**

```bash
# On worker node
sudo kubeadm reset -f
sudo rm -rf /etc/kubernetes/
sudo rm -rf /var/lib/kubelet/
sudo systemctl restart kubelet

# Then rejoin
```

#### Worker Cannot Reach Master

**Problem:** Join command times out or cannot connect

**Fix:**

```bash
# On master, check firewall
sudo firewall-cmd --list-all

# If firewall active, open ports
sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --reload

# Or disable firewall (lab environment)
sudo systemctl disable --now firewalld

# Verify master IP is reachable from worker
ping <MASTER_IP>
telnet <MASTER_IP> 6443
```

#### Worker Not Getting IP

**Problem:** `virsh domifaddr worker1` shows no IP

**Fix:**

```bash
# Check if VM network is correct
virsh domiflist worker1
# Should show: Type=network, Source=default

# Check if default network is active
virsh net-list
# Should show: default   active   yes   yes

# If not, start it
sudo virsh net-start default

# Restart VM
virsh destroy worker1
virsh start worker1

# Wait 30 seconds, check again
virsh domifaddr worker1
```

#### LibVirt Network Issues

**Problem:** `virsh` commands fail or network not found

**Fix:**

```bash
# Use system session
export LIBVIRT_DEFAULT_URI="qemu:///system"
echo 'export LIBVIRT_DEFAULT_URI="qemu:///system"' >> ~/.bashrc

# Create default network if missing
cat > /tmp/default-network.xml << 'EOF'
<network>
  <n>default</n>
  <bridge name="virbr0"/>
  <forward mode="nat"/>
  <ip address="192.168.122.1" netmask="255.255.255.0">
    <dhcp>
      <range start="192.168.122.2" end="192.168.122.254"/>
    </dhcp>
  </ip>
</network>
EOF

sudo virsh net-define /tmp/default-network.xml
sudo virsh net-start default
sudo virsh net-autostart default
```

#### Forgot Worker VM Password

**Problem:** Cannot SSH to worker because forgot password

**Fix:**

```bash
# Access via console
virt-manager
# Double-click worker1

# At GRUB menu (press ESC during boot):
# 1. Press 'e' to edit
# 2. Find line starting with 'linux'
# 3. Add 'rd.break' at end
# 4. Press Ctrl+X

# At switch_root prompt:
mount -o remount,rw /sysroot
chroot /sysroot
passwd azad  # or root
touch /.autorelabel
exit
exit

# Wait for reboot (slow - SELinux relabeling)
```

### Reset Cluster

```bash
sudo kubeadm reset -f
sudo rm -rf $HOME/.kube /etc/kubernetes
```

---

## kubectl Basics

### Common Commands

```bash
# Get resources
kubectl get pods
kubectl get services
kubectl get deployments
kubectl get nodes

# Describe resource
kubectl describe pod <pod-name>

# Logs
kubectl logs <pod-name>
kubectl logs -f <pod-name>  # Follow

# Execute in pod
kubectl exec -it <pod-name> -- /bin/bash

# Delete
kubectl delete pod <pod-name>
```

### Useful Aliases

Add to `~/.bashrc`:

```bash
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
```

---

## Example Deployments

### Simple Nginx

```bash
# Create deployment
kubectl create deployment nginx --image=nginx --replicas=3

# Expose service
kubectl expose deployment nginx --port=80 --type=NodePort

# Check
kubectl get deployments
kubectl get pods
kubectl get services
```

### With YAML

```yaml
# nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
```

Apply:
```bash
kubectl apply -f nginx-deployment.yaml
```

---

## Cluster Management

### Upgrade Cluster

See [official Kubernetes upgrade guide](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/).

### etcd Backup (kubeadm cluster)

```bash
sudo ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup.db \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

---

## Comparison: kind vs kubeadm

| Feature | kind | kubeadm |
|---------|------|---------|
| **Setup time** | < 1 minute | 5-10 minutes |
| **Isolation** | Fully isolated | Uses host system |
| **Reset** | Delete cluster instantly | Requires cleanup |
| **Multi-node** | Easy | Requires multiple machines |
| **Practice** | 95% of concepts | 100% including bootstrap |
| **Production-like** | No | Yes |
| **Resource usage** | Minimal | Moderate |

**Recommendation:**
- **Learning:** Use kind
- **Testing deployments:** Use kind
- **Practice cluster administration:** Use kubeadm

---

## Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Fedora Kubernetes Guide](https://docs.fedoraproject.org/en-US/quick-docs/using-kubernetes-kubeadm/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [kind Documentation](https://kind.sigs.k8s.io/)

---

## Next Steps

- [Cloud Native Tools](08-cloud-native-tools.md)
- [Observability](09-observability.md)

---

**Status:** ✅ Completed (both kind and kubeadm tested on Fedora)

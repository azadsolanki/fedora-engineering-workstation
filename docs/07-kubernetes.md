# Kubernetes Development

Local Kubernetes setup with kubectl, kind, and kubeadm.

---

## Overview

Two approaches for Kubernetes on Fedora:

1. **kind** - Quick, easy, isolated (recommended for learning)
2. **kubeadm** - Full cluster experience (for production-like setup)

---

## Option 1: kubectl + kind 

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

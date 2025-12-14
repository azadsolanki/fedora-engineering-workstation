# Kubernetes Development

Local Kubernetes setup with kubectl and kind.

## kubectl Installation

```bash
sudo dnf install -y kubectl
kubectl version --client
```

## kind Installation

kind creates Kubernetes clusters using containers.

```bash
# Download kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Verify
kind version
```

## Creating Clusters

### Basic Cluster

```bash
# Create cluster
kind create cluster --name dev-cluster

# Verify
kubectl cluster-info --context kind-dev-cluster
kubectl get nodes
```

### Multi-Node Cluster

Create `kind-config.yaml`:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
```

Create cluster:
```bash
kind create cluster --name multi-node --config kind-config.yaml
kubectl get nodes
```

### Cluster with Port Mapping

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 30000
        hostPort: 30000
        protocol: TCP
```

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
kubectl logs -f <pod-name>  # follow

# Execute commands in pod
kubectl exec -it <pod-name> -- /bin/bash

# Delete resources
kubectl delete pod <pod-name>
kubectl delete deployment <deployment-name>
```

### Namespaces

```bash
# List namespaces
kubectl get namespaces

# Create namespace
kubectl create namespace dev

# Use namespace
kubectl get pods -n dev
kubectl config set-context --current --namespace=dev
```

## Example Deployment

**nginx-deployment.yaml:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
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
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30000
```

Deploy:
```bash
kubectl apply -f nginx-deployment.yaml
kubectl get pods
kubectl get services
```

Access: http://localhost:30000

## Useful Aliases

Add to `~/.bashrc`:

```bash
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kdp='kubectl describe pod'
alias kl='kubectl logs'
alias kx='kubectl exec -it'
```

## Cluster Management

### List Clusters

```bash
kind get clusters
```

### Delete Cluster

```bash
kind delete cluster --name dev-cluster
```

### Switch Context

```bash
# List contexts
kubectl config get-contexts

# Switch context
kubectl config use-context kind-dev-cluster
```

## CKA Preparation

For Certified Kubernetes Administrator exam:

**Practice environment:**
```bash
kind create cluster --name master
kind create cluster --name worker
```

**Key topics to practice:**
- Cluster architecture
- Workloads (Pods, Deployments, StatefulSets)
- Services & Networking
- Storage (PV, PVC, StorageClass)
- Security (RBAC, Network Policies)
- Troubleshooting

**Resources:**
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Killer.sh Practice Exams](https://killer.sh/)

## Next Steps

- [Cloud Native Tools](08-cloud-native-tools.md)
- [Observability](09-observability.md)

---

**Status:** ✅ Completed

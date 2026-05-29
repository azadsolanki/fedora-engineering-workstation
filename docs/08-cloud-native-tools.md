# Cloud Native Tools

**Status:** Completed

CNCF ecosystem tools for cloud-native development.

---

## Helm

Kubernetes package manager. Install, upgrade, and manage applications on Kubernetes using charts.

### Installation

```bash
# Download and install latest Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

Verify:

```bash
helm version
```

### Core Concepts

| Term | Description |
|------|-------------|
| Chart | Package of Kubernetes resources |
| Release | A deployed instance of a chart |
| Repository | Collection of charts |
| Values | Configuration overrides for a chart |

### Managing Repositories

```bash
# Add common repos
helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add cert-manager https://charts.jetstack.io
helm repo add argo https://argoproj.github.io/argo-helm

# Update all repos
helm repo update

# List repos
helm repo list
```

### Searching Charts

```bash
# Search Artifact Hub
helm search hub postgres

# Search added repos
helm search repo nginx
```

### Installing Charts

```bash
# Basic install
helm install my-release bitnami/postgresql

# Install with custom values
helm install my-release bitnami/postgresql \
  --set auth.postgresPassword=secret \
  --set primary.persistence.size=10Gi

# Install with values file
helm install my-release bitnami/postgresql -f values.yaml

# Install into a specific namespace
helm install my-release bitnami/postgresql \
  --namespace postgres \
  --create-namespace
```

### Managing Releases

```bash
# List releases
helm list
helm list --all-namespaces

# Upgrade a release
helm upgrade my-release bitnami/postgresql -f values.yaml

# Upgrade or install if not exists
helm upgrade --install my-release bitnami/postgresql -f values.yaml

# Rollback to previous version
helm rollback my-release 1

# Uninstall
helm uninstall my-release
```

### Inspecting Charts

```bash
# Show chart values
helm show values bitnami/postgresql

# Show chart info
helm show chart bitnami/postgresql

# Render templates without installing (dry run)
helm template my-release bitnami/postgresql -f values.yaml

# Debug install
helm install my-release bitnami/postgresql --dry-run --debug
```

### Creating a Chart

```bash
helm create my-app
```

Structure:

```
my-app/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default values
└── templates/          # Kubernetes manifest templates
    ├── deployment.yaml
    ├── service.yaml
    └── _helpers.tpl
```

### Linting and Packaging

```bash
# Lint a chart
helm lint my-app/

# Package chart into .tgz
helm package my-app/
```

---

## ArgoCD

GitOps continuous delivery tool for Kubernetes. Syncs your cluster state with a Git repository.

### Installation

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods to be ready
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=120s
```

### Install ArgoCD CLI

```bash
# Download latest CLI
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/
```

Verify:

```bash
argocd version
```

### Access the UI

```bash
# Port-forward the ArgoCD server
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open: `https://localhost:8080`

Get the initial admin password:

```bash
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d
```

### Login via CLI

```bash
argocd login localhost:8080 --insecure
# Username: admin
# Password: (from above)

# Change password
argocd account update-password
```

### Deploying an Application

```bash
argocd app create my-app \
  --repo https://github.com/your-org/your-repo.git \
  --path k8s/ \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --sync-policy automated \
  --auto-prune \
  --self-heal
```

### Managing Applications

```bash
# List apps
argocd app list

# Get app status
argocd app get my-app

# Sync manually
argocd app sync my-app

# View app diff (what would change)
argocd app diff my-app

# Delete app
argocd app delete my-app
```

### Sync Policies

```bash
# Enable auto-sync
argocd app set my-app --sync-policy automated

# Enable auto-prune (delete removed resources)
argocd app set my-app --auto-prune

# Enable self-heal (revert manual cluster changes)
argocd app set my-app --self-heal
```

### ApplicationSet (deploy to multiple clusters)

```yaml
# applicationset.yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: my-apps
  namespace: argocd
spec:
  generators:
    - list:
        elements:
          - cluster: dev
            url: https://kubernetes.default.svc
          - cluster: staging
            url: https://staging-cluster-url
  template:
    metadata:
      name: "{{cluster}}-my-app"
    spec:
      project: default
      source:
        repoURL: https://github.com/your-org/your-repo.git
        targetRevision: HEAD
        path: "k8s/{{cluster}}"
      destination:
        server: "{{url}}"
        namespace: my-app
```

```bash
kubectl apply -f applicationset.yaml
```

---

[Back to README](../README.md)

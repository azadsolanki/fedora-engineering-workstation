# Containerization with Podman

Container runtime setup and best practices.

## Podman Installation

```bash
sudo dnf install -y podman
podman --version
```

## Why Podman?

- Daemonless architecture
- Rootless containers by default
- Docker-compatible CLI
- Pod support (Kubernetes-like)
- Better security model

## Basic Usage

### Running Containers

```bash
# Run a container
podman run -d --name myapp -p 8080:80 nginx

# List running containers
podman ps

# Stop container
podman stop myapp

# Remove container
podman rm myapp
```

### Images

```bash
# Pull image
podman pull docker.io/library/python:3.11

# List images
podman images

# Remove image
podman rmi python:3.11
```

### Building Images

Create a `Dockerfile`:

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
CMD ["python", "app.py"]
```

Build:
```bash
podman build -t myapp:latest .
podman run -p 8000:8000 myapp:latest
```

## Rootless Containers

Podman runs containers without root by default:

```bash
# Check if rootless
podman info | grep rootless

# Run as your user (default)
podman run nginx
```

## Pods

Group containers like Kubernetes:

```bash
# Create pod
podman pod create --name mypod -p 8080:80

# Add containers to pod
podman run -d --pod mypod nginx
podman run -d --pod mypod redis

# List pods
podman pod list

# Stop entire pod
podman pod stop mypod
```

## Docker Compatibility

Alias podman as docker:

```bash
echo 'alias docker=podman' >> ~/.bashrc
source ~/.bashrc
```

Most Docker commands work identically.

## Podman Compose

For multi-container apps:

```bash
sudo dnf install -y podman-compose
```

Example `docker-compose.yml`:

```yaml
version: '3'
services:
  web:
    image: nginx
    ports:
      - "8080:80"
  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: secret
```

Run:
```bash
podman-compose up -d
```

## Useful Aliases

Add to `~/.bashrc`:

```bash
alias pd='podman'
alias pdi='podman images'
alias pds='podman ps'
alias pdsa='podman ps -a'
```

## Next Steps

- [Python Ecosystem](04-python-ecosystem.md)
- [JVM Ecosystem](05-jvm-ecosystem.md)

---

**Status:** ✅ Completed

# Fedora Engineering Workstation Setup

[![Fedora](https://img.shields.io/badge/Fedora-Linux-294172?logo=fedora)](https://getfedora.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Reproducible Fedora workstation setup for modern software engineering.**

This repository provides complete installation and configuration documentation for setting up a Fedora Linux development environment, with a focus on:

- **Data Engineering:** Apache Spark, Kafka, Airflow, Iceberg, dbt, Trino
- **AI/ML Engineering:** Python ecosystem, Jupyter, ML frameworks
- **Platform Engineering:** Kubernetes, Helm, ArgoCD, Terraform
- **Cloud Native:** CNCF tools, containerization with Podman
- **Cloud Platform:** Google Cloud Platform (BigQuery, GCS, Dataflow)

**Hardware:** Lenovo ThinkPad (includes thermal and power management optimizations)

---

## Purpose

Use this repository to:
- ✅ Set up a new Fedora workstation quickly and consistently
- ✅ Reproduce your development environment on multiple machines  
- ✅ Share setup knowledge with other engineers
- ✅ Document installation gotchas and solutions

**Note:** For learning resources, certifications, and personal progress tracking, see the companion repository: [engineering-learning-journal](https://github.com/YOUR_USERNAME/engineering-learning-journal)

---

## Quick Start

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/fedora-engineering-setup.git
cd fedora-engineering-setup

# Run automated setup
chmod +x scripts/bootstrap.sh
./scripts/bootstrap.sh

# Verify installation
./scripts/verify-setup.sh
```

---

## Installation Status

### ✅ Completed
- [x] Base system (Fedora, ThinkPad optimizations)
- [x] Git with SSH authentication
- [x] Podman (rootless containers)
- [x] kubectl, kind & kubeadm (Kubernetes)
- [x] Java 21 (for JVM tools)
- [x] Python 3.11 with UV
- [x] Apache Spark (local + Podman)
- [x] VS Code with extensions
- [x] Zed Editor
- [x] Claude Code (AI coding assistant)
- [x] Google ADK (Agent Development Kit)
- [x] MCP (Model Context Protocol)
- [x] Ollama (local LLMs)
- [x] Google Cloud SDK
- [x] dbt (data build tool)
- [x] Trino

### 🚧 In Progress
- [ ] Apache Kafka
- [ ] Apache Airflow

### 📝 Planned
- [ ] Apache Iceberg
- [ ] Helm & ArgoCD
- [ ] Prometheus & Grafana
- [ ] MinIO (local S3)

---

## Documentation

### Getting Started
- [Base System Setup](docs/01-base-system.md)
- [Development Fundamentals](docs/02-development-fundamentals.md)
- [Containerization with Podman](docs/03-containerization.md)

### Language & Runtimes
- [Python Ecosystem (UV)](docs/04-python-ecosystem.md)
- [JVM Ecosystem (Java)](docs/05-jvm-ecosystem.md)

### Data Platform
- [Data Engineering Tools](docs/06-data-engineering.md) - Spark, Kafka, Airflow, Iceberg, dbt, Trino
- [Cloud & GCP Setup](docs/13-cloud-gcp.md) - Google Cloud SDK, BigQuery, GCS

### Infrastructure
- [Kubernetes](docs/07-kubernetes.md)
- [Cloud Native Tools](docs/08-cloud-native-tools.md) - Helm, ArgoCD
- [Databases](docs/12-databases.md) - PostgreSQL, Redis, MinIO

### Observability & Development
- [Observability](docs/09-observability.md) - Prometheus, Grafana
- [AI/ML Tools](docs/10-ai-ml-tools.md)
- [IDEs & Editors](docs/11-ides-editors.md)
- [Zed Editor](docs/14-zed-editor.md)
- [Claude Code](docs/16-claude-code.md)
- [Agent Development Kit (ADK)](docs/17-adk.md)
- [Model Context Protocol (MCP)](docs/18-mcp.md)
- [Ollama (Local LLMs)](docs/19-ollama.md)
- [Browser Privacy](docs/15-browser-privacy.md) - Firefox containers, tracker blocking

### Reference
- [Troubleshooting](docs/troubleshooting.md)
- [Technical Bookmarks](references/bookmarks.md)

---

## Project Structure

```
~/code/
├── apps/          # Data engineering projects
│   ├── spark-pipeline/
│   ├── dbt-models/
│   └── airflow-dags/
├── infra/         # Kubernetes manifests, Terraform
│   ├── k8s/
│   └── terraform/
└── learning/      # Tutorials, CKA prep, experiments
```

---

## Common Workflows

### PySpark Development

```bash
cd ~/code/apps/my-pipeline
uv venv --python 3.11.9
source .venv/bin/activate
uv pip install pyspark

# Local mode
pyspark --master local[*]

# Or connect to Podman cluster
# (See docs/06-data-engineering.md)
```

### Kubernetes Development

```bash
kind create cluster --name dev
kubectl apply -f k8s/
```

### GCP Integration

```bash
# Authenticate
gcloud auth login

# Access BigQuery
bq query "SELECT * FROM dataset.table LIMIT 10"
```

---

## Repository Structure

```
fedora-engineering-workstation/
├── docs/               # Installation and configuration guides
├── scripts/            # Automated setup and verification
├── configs/            # Configuration files (TLP, kind, etc.)
├── dotfiles/           # Sample shell configs
├── projects/templates/ # Project starter templates
└── references/         # Technical bookmarks and resources
```

---

## Related Repository

**Learning & Career Development:** [engineering-learning-journal](https://github.com/YOUR_USERNAME/engineering-learning-journal)

For personal learning progress, study notes, certifications, and project portfolio, see the companion learning journal repository.

---

## Contributing

This is a technical setup repository focused on reproducible installations. Suggestions and improvements welcome!

See [CONTRIBUTING.md](CONTRIBUTING.md).

---

## License

MIT License - see [LICENSE](LICENSE)

---

**Note:** This is a technical setup template. Adapt the configurations as needed for your specific requirements.

*Documentation structure assisted by AI for completeness and organization.*

Last updated: January 2026

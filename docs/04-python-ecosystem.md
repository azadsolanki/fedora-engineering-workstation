# Python Ecosystem with UV

Modern Python package and version management using UV.

## UV Installation

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc
uv --version
```

## Why UV?

- **Fast:** 10-100x faster than pip
- **All-in-one:** Replaces pyenv, pip, pip-tools, virtualenv
- **Reliable:** Consistent dependency resolution
- **Simple:** Single tool for everything

## Python Version Management

### Install Python

```bash
# Install specific version
uv python install 3.11.9

# List installed versions
uv python list

# Set default
uv python pin 3.11.9
```

## Virtual Environments

### Create Environment

```bash
cd ~/code/apps/my-project

# Create venv with specific Python
uv venv --python 3.11.9

# Activate
source .venv/bin/activate

# Deactivate
deactivate
```

### Package Management

```bash
# Install packages
uv pip install pandas numpy

# Install from requirements
uv pip install -r requirements.txt

# Install development dependencies
uv pip install pytest black ruff

# Freeze dependencies
uv pip freeze > requirements.txt
```

## Project Workflow

### New Project Setup

```bash
mkdir ~/code/apps/data-pipeline
cd ~/code/apps/data-pipeline

# Create environment
uv venv --python 3.11.9
source .venv/bin/activate

# Install dependencies
uv pip install pyspark pandas pyarrow

# Create project structure
mkdir -p src tests data

# Initialize git
git init -b main
echo ".venv/" > .gitignore
echo "*.pyc" >> .gitignore
echo "__pycache__/" >> .gitignore
```

### Requirements Management

**requirements.txt:**
```
pyspark==3.5.0
pandas==2.1.4
pyarrow==14.0.1
```

**requirements-dev.txt:**
```
pytest==7.4.3
black==23.12.0
ruff==0.1.8
jupyter==1.0.0
```

Install:
```bash
uv pip install -r requirements.txt
uv pip install -r requirements-dev.txt
```

## Common Packages

### Data Engineering

```bash
uv pip install pyspark pandas pyarrow duckdb
```

### API Development

```bash
uv pip install fastapi uvicorn pydantic
```

### ML/Data Science

```bash
uv pip install scikit-learn jupyter matplotlib seaborn
```

### Testing & Quality

```bash
uv pip install pytest black ruff mypy
```

## Best Practices

1. **One venv per project:** Never install packages globally
2. **Pin versions:** Use exact versions in requirements.txt
3. **Separate dev dependencies:** Keep dev tools in separate file
4. **Document dependencies:** Comment why packages are needed
5. **Lock files:** Use `uv pip compile` for reproducible builds

## Troubleshooting

### UV not found after installation

```bash
export PATH="$HOME/.cargo/bin:$PATH"
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
```

### Package conflicts

```bash
# Create fresh environment
rm -rf .venv
uv venv --python 3.11.9
source .venv/bin/activate
uv pip install -r requirements.txt
```

## Next Steps

- [JVM Ecosystem](05-jvm-ecosystem.md)
- [Data Engineering Tools](06-data-engineering.md)

---

**Status:** ✅ Completed

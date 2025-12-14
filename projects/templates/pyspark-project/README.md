# PySpark Project Template

Basic template for PySpark data processing projects.

## Setup

```bash
# Create virtual environment
uv venv --python 3.11.9
source .venv/bin/activate

# Install dependencies
uv pip install -r requirements.txt
```

## Structure

```
.
├── src/            # Source code
├── tests/          # Unit tests
├── data/           # Data files (gitignored)
├── notebooks/      # Jupyter notebooks
├── requirements.txt
└── README.md
```

## Usage

```bash
# Run main script
python src/main.py

# Run tests
pytest tests/
```

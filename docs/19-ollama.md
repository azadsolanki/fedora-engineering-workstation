# Ollama

**Status:** Completed

Run large language models locally on Fedora. No cloud, no API keys, full privacy. Works with or without a GPU.

---

## Installation

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

Verify:

```bash
ollama --version
systemctl status ollama
```

Ollama runs as a systemd service on port `11434`.

---

## Managing the Service

```bash
# Start
sudo systemctl start ollama

# Enable on boot
sudo systemctl enable ollama

# Stop
sudo systemctl stop ollama

# View logs
journalctl -u ollama -f
```

---

## Pulling Models

```bash
# Llama 3.2 (3B) - lightweight, fast
ollama pull llama3.2

# Llama 3.1 (8B) - good balance
ollama pull llama3.1

# Mistral (7B) - great for coding
ollama pull mistral

# Code-focused models
ollama pull codellama
ollama pull qwen2.5-coder

# Small/fast models for low-RAM machines
ollama pull llama3.2:1b
ollama pull phi3:mini
```

Check available models: https://ollama.com/library

---

## Running Models

```bash
# Interactive chat
ollama run llama3.1

# One-shot prompt
ollama run mistral "explain kubernetes in simple terms"

# Pipe input
cat main.py | ollama run codellama "review this code"
```

### Inside the chat

| Command | Action |
|---------|--------|
| `/bye`  | Exit |
| `/help` | Show commands |
| `Ctrl+D` | Exit |

---

## Managing Models

```bash
# List downloaded models
ollama list

# Show model info
ollama show llama3.1

# Remove a model
ollama rm llama3.2

# Copy/rename a model
ollama cp llama3.1 my-llama
```

---

## REST API

Ollama exposes a local API at `http://localhost:11434`:

```bash
# Generate a response
curl http://localhost:11434/api/generate \
  -d '{
    "model": "llama3.1",
    "prompt": "What is Apache Spark?",
    "stream": false
  }'

# Chat endpoint
curl http://localhost:11434/api/chat \
  -d '{
    "model": "llama3.1",
    "messages": [{"role": "user", "content": "Hello"}],
    "stream": false
  }'

# List models
curl http://localhost:11434/api/tags
```

---

## Python Integration

```bash
uv pip install ollama
```

```python
import ollama

# Simple generation
response = ollama.generate(model="llama3.1", prompt="Explain dbt in one paragraph")
print(response["response"])

# Chat
response = ollama.chat(
    model="llama3.1",
    messages=[{"role": "user", "content": "Write a PySpark word count job"}],
)
print(response["message"]["content"])
```

---

## OpenAI-compatible API

Ollama's API is compatible with the OpenAI SDK — swap the base URL:

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:11434/v1",
    api_key="ollama",  # required but unused
)

response = client.chat.completions.create(
    model="llama3.1",
    messages=[{"role": "user", "content": "Hello"}],
)
print(response.choices[0].message.content)
```

---

## Use with ADK (Google Agent Development Kit)

```python
from google.adk.agents import Agent
from google.adk.models.lite_llm import LiteLlm

root_agent = Agent(
    name="local_agent",
    model=LiteLlm(model="ollama/llama3.1"),
    description="Agent running on a local model",
    instruction="You are a helpful assistant.",
)
```

---

## GPU Support (NVIDIA)

If you have an NVIDIA GPU, Ollama uses it automatically. Verify:

```bash
ollama run llama3.1 "hello"
# Look for GPU usage in nvidia-smi
nvidia-smi
```

### ROCm (AMD GPU)

```bash
# Install ROCm-enabled Ollama
curl -fsSL https://ollama.com/install.sh | sh
# Verify AMD GPU is detected
ollama run llama3.1
rocm-smi
```

---

## Model Storage

Models are stored at `~/.ollama/models/`. To move to a different disk:

```bash
# Set custom path
echo 'OLLAMA_MODELS=/mnt/data/ollama' | sudo tee -a /etc/systemd/system/ollama.service.d/override.conf
sudo systemctl daemon-reload && sudo systemctl restart ollama
```

---

## Recommended Models by Use Case

| Use Case | Model | RAM Required |
|----------|-------|-------------|
| General chat | `llama3.1:8b` | 8 GB |
| Coding | `qwen2.5-coder:7b` | 8 GB |
| Low RAM | `llama3.2:1b` | 2 GB |
| Long context | `llama3.1:70b` | 40 GB |
| Fast + capable | `mistral` | 8 GB |

---

[Back to README](../README.md)

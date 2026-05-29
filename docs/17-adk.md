# Google Agent Development Kit (ADK)

**Status:** Completed

Open-source Python framework by Google for building, evaluating, and deploying AI agents. Supports Gemini models, multi-agent pipelines, and tool use.

---

## Prerequisites

- Python 3.9+
- `uv` (see `04-python-ecosystem.md`)
- Google API key or Google Cloud project with Vertex AI enabled

---

## Installation

### Using uv (recommended)

```bash
# Create a project venv
mkdir ~/code/apps/my-agent && cd ~/code/apps/my-agent
uv venv --python 3.11
source .venv/bin/activate

# Install ADK
uv pip install google-adk
```

### Using pip

```bash
pip install google-adk
```

Verify:

```bash
adk --version
```

---

## Authentication

### Option 1: Google AI Studio (API Key)

1. Get a free API key at: https://aistudio.google.com/apikey

2. Add to `~/.bashrc`:

```bash
echo 'export GOOGLE_API_KEY="your-api-key-here"' >> ~/.bashrc
source ~/.bashrc
```

### Option 2: Vertex AI (GCP)

```bash
# Authenticate with gcloud (see 13-cloud-gcp.md)
gcloud auth application-default login

# Set your project
export GOOGLE_CLOUD_PROJECT="your-project-id"
export GOOGLE_CLOUD_LOCATION="us-central1"
export GOOGLE_GENAI_USE_VERTEXAI="TRUE"
```

---

## Project Structure

```
my-agent/
├── .venv/
├── my_agent/
│   ├── __init__.py
│   └── agent.py
└── .env
```

Use a `.env` file to keep credentials out of your shell profile for project-specific keys:

```bash
# .env
GOOGLE_API_KEY=your-api-key-here
```

---

## Your First Agent

Create `my_agent/agent.py`:

```python
from google.adk.agents import Agent

root_agent = Agent(
    name="assistant",
    model="gemini-2.0-flash",
    description="A helpful assistant",
    instruction="You are a helpful assistant. Answer questions clearly and concisely.",
)
```

Create `my_agent/__init__.py`:

```python
from . import agent
```

---

## Running Agents

### Web UI (development)

```bash
adk web
```

Opens a browser UI at `http://localhost:8000` — select your agent and chat interactively.

### CLI (terminal)

```bash
adk run my_agent
```

### API Server

```bash
adk api_server my_agent
```

Starts a REST API at `http://localhost:8000` for integration with other services.

---

## Adding Tools

Tools give agents the ability to take actions:

```python
from google.adk.agents import Agent

def get_weather(city: str) -> dict:
    """Get the current weather for a city."""
    # Your implementation here
    return {"city": city, "temperature": "22C", "condition": "sunny"}

root_agent = Agent(
    name="weather_agent",
    model="gemini-2.0-flash",
    description="Answers weather questions",
    instruction="Use the get_weather tool to answer weather questions.",
    tools=[get_weather],
)
```

---

## Multi-Agent Setup

Agents can delegate to sub-agents:

```python
from google.adk.agents import Agent

researcher = Agent(
    name="researcher",
    model="gemini-2.0-flash",
    description="Researches topics and summarises findings",
    instruction="Research the given topic thoroughly.",
)

root_agent = Agent(
    name="coordinator",
    model="gemini-2.0-flash",
    description="Coordinates tasks between agents",
    instruction="Delegate research tasks to the researcher agent.",
    agents=[researcher],
)
```

---

## Environment Variables Reference

| Variable | Purpose |
|----------|---------|
| `GOOGLE_API_KEY` | API key for Google AI Studio |
| `GOOGLE_CLOUD_PROJECT` | GCP project ID for Vertex AI |
| `GOOGLE_CLOUD_LOCATION` | GCP region (e.g. `us-central1`) |
| `GOOGLE_GENAI_USE_VERTEXAI` | Set to `TRUE` to use Vertex AI |

---

## Available Models

| Model | Use case |
|-------|---------|
| `gemini-2.0-flash` | Fast, default for most agents |
| `gemini-2.0-flash-thinking` | Complex reasoning tasks |
| `gemini-1.5-pro` | Long context (1M tokens) |

---

## Useful Commands

```bash
# List available agents in current directory
adk list

# Run with a specific env file
adk web --env .env

# Run in headless API mode
adk api_server my_agent --port 9000
```

---

## Resources

- Official docs: https://google.github.io/adk-docs/
- Samples: https://github.com/google/adk-samples

---

[Back to README](../README.md)

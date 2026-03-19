# 🐳 Running TradingAgents with Docker

Docker lets you run TradingAgents in **one step** — no Python version headaches, no virtual environment setup, no dependency conflicts.

---

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed (Docker Desktop or Docker Engine)
- At least one LLM API key (OpenAI, Anthropic, Google, etc.)

## Quick Start

### 1. Configure your API keys

```bash
cp .env.example .env
# Edit .env and add your API key(s)
```

### 2. Build & run (one command)

```bash
docker compose run --rm tradingagents
```

That's it! The interactive CLI will start and guide you through selecting a ticker, date range, LLM provider, and analysts.

---

## Alternative Commands

### Build the image separately

```bash
docker build -t tradingagents .
```

### Run the interactive CLI (without Compose)

```bash
docker run --rm -it --env-file .env tradingagents
```

### Run a scripted analysis directly

```bash
docker run --rm -it --env-file .env tradingagents python main.py
```

### Persist results between runs

```bash
docker run --rm -it --env-file .env \
  -v "$(pwd)/results:/app/results" \
  -v "$(pwd)/data_cache:/app/tradingagents/dataflows/data_cache" \
  tradingagents
```

---

## What's Inside the Image

| Layer | Details |
|-------|---------|
| **Base** | `python:3.13-slim` — minimal Debian with Python 3.13 |
| **Dependencies** | Installed in a multi-stage build to keep the final image small |
| **Security** | Runs as a non-root `trader` user |
| **Entrypoint** | Interactive CLI (`python -m cli.main`) by default |

---

## Environment Variables

Set these in your `.env` file (only the provider(s) you plan to use):

| Variable | Description |
|----------|-------------|
| `OPENAI_API_KEY` | OpenAI API key |
| `GOOGLE_API_KEY` | Google Gemini API key |
| `ANTHROPIC_API_KEY` | Anthropic Claude API key |
| `XAI_API_KEY` | xAI Grok API key |
| `OPENROUTER_API_KEY` | OpenRouter API key |

---

## Tips

- **First build takes a few minutes** while Python packages compile. Subsequent builds use Docker cache and are fast.
- **Data cache**: Mount `./data_cache` to avoid re-downloading market data between runs.
- **Results**: Mount `./results` to save analysis output to your host machine.
- **Ollama users**: If you run Ollama locally, add `--network host` so the container can reach `localhost:11434`:
  ```bash
  docker run --rm -it --env-file .env --network host tradingagents
  ```

---

## Security Notes

The codebase has been reviewed for security concerns:

✅ **No dangerous functions** — No `eval()`, `exec()`, `pickle.loads()`, or `subprocess` with `shell=True`  
✅ **No hardcoded credentials** — All API keys are loaded from environment variables  
✅ **HTTPS everywhere** — All external API calls use HTTPS  
✅ **No obfuscated code** — All source is readable Python  
✅ **No external code execution** — The framework only fetches market data and news, never downloads or runs external code  
✅ **Trusted dependencies** — All packages are well-known, legitimate open-source libraries  
✅ **Non-root container** — The Docker image runs as a dedicated `trader` user, not root  

⚠️ **One minor note**: The CLI fetches product announcements from `https://api.tauric.ai/v1/announcements` on startup. This is display-only text with a safe fallback if the request fails — no code is ever executed from this endpoint.

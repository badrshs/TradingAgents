# ──────────────────────────────────────────────────────────────
#  TradingAgents – One-Step Docker Build
#
#  Build:
#    docker build -t tradingagents .
#
#  Run the interactive CLI:
#    docker run --rm -it --env-file .env tradingagents
#
#  Run a quick analysis directly:
#    docker run --rm -it --env-file .env tradingagents \
#      python main.py
#
#  Persist results between runs:
#    docker run --rm -it --env-file .env \
#      -v $(pwd)/results:/app/results \
#      tradingagents
# ──────────────────────────────────────────────────────────────

# ── Stage 1: Build dependencies ──────────────────────────────
FROM python:3.13-slim AS builder

WORKDIR /build

# Install build tools needed by compiled dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc g++ && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt && \
    pip install --no-cache-dir --prefix=/install python-dotenv

# ── Stage 2: Lean runtime image ──────────────────────────────
FROM python:3.13-slim

LABEL maintainer="TradingAgents Contributors"
LABEL description="Multi-Agent LLM Financial Trading Framework"

# Minimal runtime deps (some wheels need libgomp for numpy/pandas)
RUN apt-get update && \
    apt-get install -y --no-install-recommends libgomp1 && \
    rm -rf /var/lib/apt/lists/*

# Copy pre-built Python packages from builder stage
COPY --from=builder /install /usr/local

WORKDIR /app

# Copy application source
COPY . .

# Create writable directories for results and data cache
RUN mkdir -p /app/results /app/tradingagents/dataflows/data_cache

# Non-root user for security
RUN groupadd -r trader && useradd -r -g trader -d /app trader && \
    chown -R trader:trader /app
USER trader

# Default: launch the interactive CLI
ENTRYPOINT ["python", "-m", "cli.main"]

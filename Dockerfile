# syntax=docker/dockerfile:1
# Multi-stage build: uv for deps, then minimal runtime.
FROM python:3.12-slim AS builder

ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PYTHON_DOWNLOADS=never \
    UV_PROJECT_ENVIRONMENT=/app/.venv \
    UV_NO_DEV=1

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

# Dependency layer: only lock + pyproject; cache until they change
COPY uv.lock pyproject.toml ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-install-project --no-editable

# App layer
COPY . .
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-editable

# Pre-download GloVe at build time (avoids network at runtime, faster first request)
ENV GENSIM_DATA_DIR=/app/.gensim_data
RUN --mount=type=cache,target=/root/.cache/uv \
    uv run python -c "import gensim.downloader as api; api.load('glove-wiki-gigaword-50')"

# --- Runtime stage: no uv, no build tools ---
FROM python:3.12-slim AS runtime

ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

# Copy venv and pre-downloaded model data from builder
COPY --from=builder /app/.venv /app/.venv
COPY --from=builder /app/.gensim_data /app/.gensim_data
COPY --from=builder /app/app /app/app
COPY --from=builder /app/pyproject.toml /app/
COPY --from=builder /app/docker-entrypoint.sh /app/
RUN chmod +x /app/docker-entrypoint.sh

# Gensim will use pre-downloaded data from this dir
ENV GENSIM_DATA_DIR=/app/.gensim_data

EXPOSE 8000

# Optional env: UVICORN_WORKERS, UVICORN_LIMIT_CONCURRENCY, UVICORN_TIMEOUT_KEEP_ALIVE, PORT
ENTRYPOINT ["/app/docker-entrypoint.sh"]

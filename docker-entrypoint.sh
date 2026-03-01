#!/usr/bin/env sh
# Override workers/concurrency via env (UVICORN_WORKERS, UVICORN_LIMIT_CONCURRENCY, etc.).
set -e
exec uvicorn app.main:app \
  --host 0.0.0.0 \
  --port "${PORT:-8000}" \
  --workers "${UVICORN_WORKERS:-1}" \
  --limit-concurrency "${UVICORN_LIMIT_CONCURRENCY:-4}" \
  --timeout-keep-alive "${UVICORN_TIMEOUT_KEEP_ALIVE:-30}" \
  "$@"

# glove-interests-matcher
stateless word similarity comparison

## Run locally

From the project root (as in the [FastAPI docs](https://fastapi.tiangolo.com/tutorial/first-steps/)):

```bash
uv run uvicorn app.main:app --host 0.0.0.0 --port 8000
```

For development with auto-reload: add `--reload`.

## Docker

Build and run:

```bash
docker build -t glove-api .
docker run --rm -p 8000:8000 glove-api
```

Optionally tune via env: `UVICORN_WORKERS`, `UVICORN_LIMIT_CONCURRENCY`, `UVICORN_TIMEOUT_KEEP_ALIVE`, `PORT`.

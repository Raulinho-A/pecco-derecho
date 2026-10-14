# syntax=docker/dockerfile:1

ARG PYTHON_VERSION=3.12
ARG UV_VERSION=0.12.24


# ---------------------------------------------------------
# uv binary
# ---------------------------------------------------------
FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv


# ---------------------------------------------------------
# Base
# ---------------------------------------------------------
FROM python:${PYTHON_VERSION}-slim-bookworm AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_DOWNLOADS=0

WORKDIR /app

COPY --from=uv /uv /uvx /bin/


# ---------------------------------------------------------
# Development dependencies
# ---------------------------------------------------------
FROM base AS deps

RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync \
      --locked \
      --no-install-project


# ---------------------------------------------------------
# Development
# ---------------------------------------------------------
FROM base AS dev

COPY --from=deps /app/.venv /app/.venv

ENV PATH="/app/.venv/bin:$PATH"

COPY . .

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked

EXPOSE 8000

CMD ["uvicorn", "pecco_derecho.main:app", "--app-dir", "src", "--reload", "--host", "0.0.0.0", "--port", "8000"]


# ---------------------------------------------------------
# Tests
# ---------------------------------------------------------
FROM dev AS test

CMD ["pytest", "tests"]


# ---------------------------------------------------------
# Production builder
# ---------------------------------------------------------
FROM base AS build

RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync \
      --locked \
      --no-dev \
      --no-install-project \
      --no-editable

COPY . .

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync \
      --locked \
      --no-dev \
      --no-editable


# ---------------------------------------------------------
# Production
# ---------------------------------------------------------
FROM python:${PYTHON_VERSION}-slim-bookworm AS production

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/app/.venv/bin:$PATH"

WORKDIR /app

RUN useradd \
    --create-home \
    --uid 10001 \
    --shell /usr/sbin/nologin \
    app

COPY --from=build --chown=app:app /app/.venv /app/.venv
COPY --from=build --chown=app:app /app/src /app/src

USER app

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/', timeout=2)" || exit 1

CMD ["uvicorn", "pecco_derecho.main:app", "--host", "0.0.0.0", "--port", "8000"]

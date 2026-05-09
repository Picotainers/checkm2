# syntax=docker/dockerfile:1

FROM python:3.11-slim-bookworm AS builder

ARG CHECKM2_TAG=1.1.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends git build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone --depth 1 --branch "${CHECKM2_TAG}" https://github.com/chklovski/checkm2.git
RUN pip install --no-cache-dir --upgrade pip setuptools wheel \
    && pip wheel --no-cache-dir --wheel-dir /tmp/wheels /src/checkm2

FROM python:3.11-slim-bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends hmmer prodigal diamond-aligner \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /tmp/wheels /tmp/wheels
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir /tmp/wheels/* \
    && rm -rf /tmp/wheels

RUN printf '%s\n' \
    '#!/bin/sh' \
    'set -eu' \
    'if [ "${1:-}" = "checkm2" ]; then' \
    '  shift' \
    'fi' \
    'exec checkm2 "$@"' \
    > /usr/local/bin/run-checkm2 \
    && chmod +x /usr/local/bin/run-checkm2

WORKDIR /data
ENTRYPOINT ["/usr/local/bin/run-checkm2"]
CMD ["--help"]

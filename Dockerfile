# syntax=docker/dockerfile:1
# Compatibility-first template for checkm2.
# Installs package from Bioconda and copies the full conda runtime to avoid missing libs/interpreters.

FROM mambaorg/micromamba:2.0.5-debian12-slim AS builder

RUN micromamba install -y -n base -c conda-forge -c bioconda \
    checkm2 \
    && micromamba clean --all --yes

# Resolve a runnable command for this package.
# Prefer exact match, then underscore variant, then prefix match.
RUN set -eux; \
    BIN=""; \
    if [ -x "/opt/conda/bin/checkm2" ]; then BIN="/opt/conda/bin/checkm2"; fi; \
    if [ -z "$BIN" ]; then CAND="/opt/conda/bin/$(echo checkm2 | tr '-' '_')"; [ -x "$CAND" ] && BIN="$CAND" || true; fi; \
    if [ -z "$BIN" ]; then BIN="$(find /opt/conda/bin -maxdepth 1 -type f -perm -111 -name 'checkm2*' | head -n1 || true)"; fi; \
    test -n "$BIN"; \
    printf '%s\n' "$BIN" > /tmp/tool-entry-path

FROM mambaorg/micromamba:2.0.5-debian12-slim

COPY --from=builder /opt/conda /opt/conda
COPY --from=builder /tmp/tool-entry-path /tmp/tool-entry-path

USER root
ENV PATH="/opt/conda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/opt/conda/lib:/opt/conda/lib64"
RUN set -eux; \
    BIN="$(cat /tmp/tool-entry-path)"; \
    printf '#!/usr/bin/env bash\nexec "%s" "$@"\n' "$BIN" > /usr/local/bin/checkm2
RUN chmod +x /usr/local/bin/checkm2 && rm -f /tmp/tool-entry-path
WORKDIR /data
ENTRYPOINT ["/usr/local/bin/checkm2"]

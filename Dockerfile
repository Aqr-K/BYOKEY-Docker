# ── Stage 1: Download pre-built binary ──────────────────────────────────────
FROM debian:bookworm-slim AS downloader

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
    && rm -rf /var/lib/apt/lists/*

ARG BYOKEY_VERSION=v0.9.2
ARG TARGETARCH

RUN case "${TARGETARCH}" in \
        amd64) ARCH="x86_64-unknown-linux-gnu" ;; \
        arm64) ARCH="aarch64-unknown-linux-gnu" ;; \
        *) echo "Unsupported arch: ${TARGETARCH}" && exit 1 ;; \
    esac \
    && URL="https://github.com/AprilNEA/BYOKEY/releases/download/${BYOKEY_VERSION}/byokey-${BYOKEY_VERSION}-${ARCH}.tar.gz" \
    && echo "Downloading ${URL}" \
    && curl -fSL "${URL}" -o /tmp/byokey.tar.gz \
    && tar xzf /tmp/byokey.tar.gz -C /tmp \
    && chmod +x /tmp/byokey \
    && rm /tmp/byokey.tar.gz

# ── Stage 2: Runtime ───────────────────────────────────────────────────────
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libsqlite3-0 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r byokey && useradd -r -g byokey -m -d /home/byokey byokey

COPY --from=downloader /tmp/byokey /usr/local/bin/byokey

# Data directory for tokens.db and config
RUN mkdir -p /data && chown byokey:byokey /data
VOLUME ["/data"]

USER byokey
WORKDIR /data

# Default port
EXPOSE 8018

ENV BYOKEY_HOST=0.0.0.0
ENV BYOKEY_PORT=8018

ENTRYPOINT ["byokey"]
CMD ["serve", "--host", "0.0.0.0", "--port", "8018"]

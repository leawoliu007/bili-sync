FROM alpine AS base

ARG TARGETPLATFORM

WORKDIR /app

RUN apk update && apk add --no-cache \
    ca-certificates \
    tzdata \
    ffmpeg

COPY ./bili-sync-rs-Linux-*.tar.gz ./targets/

RUN case "$TARGETPLATFORM" in \
    linux/amd64) \
        tar xzvf ./targets/bili-sync-rs-Linux-x86_64-musl.tar.gz -C ./; \
        ;; \
    linux/arm64) \
        tar xzvf ./targets/bili-sync-rs-Linux-aarch64-musl.tar.gz -C ./; \
        ;; \
    linux/armv7) \
        tar xzvf ./targets/bili-sync-rs-Linux-armv7-musleabi.tar.gz -C ./; \
        ;; \
    *) \
        echo "Unsupported target platform: $TARGETPLATFORM"; \
        exit 1; \
        ;; \
esac

RUN rm -rf ./targets && chmod +x ./bili-sync-rs

FROM scratch

WORKDIR /app

ENV LANG=zh_CN.UTF-8 \
    TZ=Asia/Shanghai \
    HOME=/app \
    RUST_BACKTRACE=1 \
    RUST_LOG=None,bili_sync=info

COPY --from=base / /

ENTRYPOINT [ "/app/bili-sync-rs" ]

VOLUME [ "/app/.config/bili-sync" ]

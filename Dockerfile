# syntax=docker/dockerfile:1
# ============================================================================
# Bootgly PHP Framework — multi-stage image
#
#   base   → PHP 8.4 + required/recommended extensions + opcache/JIT tuning
#   kit    → base + the kit itself (framework + Console + Web + the kit entry).
#            This is what a user installs: run servers, deploy, build on it.
#
# The benchmark harness image is NOT built here — it lives in
# bootgly/bootgly_benchmarks, the repo that owns it.
#
# The build takes NOTHING from the context: it git-clones this repository at the
# release tag, with submodules, so one tag pins Bootgly, Console and Web and the
# image reproduces from the tag alone. Build it from anywhere:
#
#   docker build -f Dockerfile --target kit \
#     --build-arg BOOTGLY_VERSION=1.0.0-rc.1 -t bootgly.kit:1.0.0-rc.1 .
#
#   # a branch or another tag instead of the version tag (`--branch` takes a
#   # ref name, never a bare commit SHA):
#   docker build ... --build-arg BOOTGLY_KIT_REF=main .
#
# Consequence to accept: the build needs network, and it always builds a pushed
# ref — uncommitted work is not what lands in the image.
# ============================================================================

ARG PHP_IMAGE=php:8.4-cli-bookworm
ARG BOOTGLY_VERSION=1.0.0-rc.1
ARG BOOTGLY_FRAMEWORK_SHA=unknown
ARG BOOTGLY_FRAMEWORK_DIRTY=unknown
ARG BOOTGLY_FRAMEWORK_TRACKED_DIFF_SHA256=unknown
ARG BOOTGLY_FRAMEWORK_UNTRACKED_MANIFEST_SHA256=unknown


# ============================================================================
# Stage: base
# ============================================================================
FROM ${PHP_IMAGE} AS base

# ! Install Git, build + enable native extensions, then drop build-only libs.
#   Bundled & enabled already in the official image: openssl, posix, readline.
#   libonig-dev is needed to build mbstring; its runtime lib (libonig5) is kept.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends git libonig-dev; \
    docker-php-ext-install -j"$(nproc)" pcntl sockets shmop sysvshm sysvsem opcache mbstring; \
    apt-get purge -y libonig-dev; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /bootgly


# ============================================================================
# Stage: kit — the product a user installs: run servers, deploy, build on it
# ============================================================================
FROM base AS kit

ARG BOOTGLY_VERSION
ARG BOOTGLY_FRAMEWORK_SHA
ARG BOOTGLY_FRAMEWORK_DIRTY
ARG BOOTGLY_FRAMEWORK_TRACKED_DIFF_SHA256
ARG BOOTGLY_FRAMEWORK_UNTRACKED_MANIFEST_SHA256
# ! The CLI reads this to word a refusal correctly: inside an image, releases
#   are image tags, so `kit upgrade` names `docker pull`, not `curl | bash`.
ENV BOOTGLY_DOCKER=1
ENV BOOTGLY_FRAMEWORK_SHA="${BOOTGLY_FRAMEWORK_SHA}" \
    BOOTGLY_FRAMEWORK_DIRTY="${BOOTGLY_FRAMEWORK_DIRTY}" \
    BOOTGLY_FRAMEWORK_TRACKED_DIFF_SHA256="${BOOTGLY_FRAMEWORK_TRACKED_DIFF_SHA256}" \
    BOOTGLY_FRAMEWORK_UNTRACKED_MANIFEST_SHA256="${BOOTGLY_FRAMEWORK_UNTRACKED_MANIFEST_SHA256}"
LABEL org.opencontainers.image.title="Bootgly Kit" \
      org.opencontainers.image.description="The Bootgly PHP Framework, ready to run: framework, Console and Web platforms, and the kit entry" \
      org.opencontainers.image.version="${BOOTGLY_VERSION}" \
      org.opencontainers.image.revision="${BOOTGLY_FRAMEWORK_SHA}" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.vendor="Bootgly" \
      org.opencontainers.image.url="https://bootgly.com" \
      org.opencontainers.image.documentation="https://docs.bootgly.com" \
      org.opencontainers.image.source="https://github.com/bootgly/bootgly.kit"

# ! The kit, fetched at its tag with its submodules — git resolves Bootgly,
#   Console and Web from the gitlinks this tag pins, so the build depends on no
#   other image and on nothing in the build context.
#
#   `.git` is then removed: the image carries the LAYOUT, not a checkout. That
#   is deliberate — `kit upgrade` inside a container would rewrite a filesystem
#   the next `docker run` throws away, so the CLI refuses it and names
#   `docker pull` instead (see KitCommand).
ARG BOOTGLY_KIT_REF=v${BOOTGLY_VERSION}
RUN set -eux; \
    git clone --depth 1 --branch "${BOOTGLY_KIT_REF}" \
        --recurse-submodules --shallow-submodules \
        https://github.com/bootgly/bootgly.kit.git /bootgly; \
    find /bootgly -name .git -prune -exec rm -rf {} +; \
    rm -f /bootgly/.gitmodules

# ! opcache + JIT tuning (wins over defaults via conf.d/zz-*) — it ships with
#   the framework, so it is installed from the clone, not from a build context
RUN cp /bootgly/Bootgly/@/__php__/zz-bootgly.ini /usr/local/etc/php/conf.d/zz-bootgly.ini

# ! Make `bootgly` global. __DIR__ resolves the symlink → working base stays /bootgly.
RUN ln -s /bootgly/bootgly /usr/local/bin/bootgly && \
    chmod +x /bootgly/Bootgly/@/__docker__/entrypoint.sh

# # Server ports of the shipped demos: HTTP 8082 · HTTPS 443 · TCP 8080 ·
#   WebSocket 8083 · UDP 9999. A project of your own publishes its own port.
EXPOSE 8082 443 8080 8083 9999/udp

# ! User data. A container is ephemeral; these two are not — without them a
#   `docker pull` of the next version would throw the user's projects away.
#   Pre-created so a fresh anonymous volume inherits the layout (Docker seeds
#   an anonymous volume from the image, never a bind mount — there the CLI
#   creates what it needs on first use).
RUN mkdir -p /bootgly/projects \
             /bootgly/storage/cache /bootgly/storage/locks /bootgly/storage/logs \
             /bootgly/storage/pids /bootgly/storage/queues /bootgly/storage/schedule \
             /bootgly/storage/temp /bootgly/storage/tests
VOLUME ["/bootgly/projects", "/bootgly/storage"]

# ! Runs as root, deliberately: binding :80/:443 (Auto-TLS' HTTP-01 included)
#   needs it, and the server demotes its own workers through the `user`/`group`
#   Configs. Run with `--user` to override when no privileged port is bound.

# ! The server stops on SIGTERM (graceful drain); make the contract explicit
STOPSIGNAL SIGTERM

# ! Bare interactive runs open the canonical project installer (see the script)
ENTRYPOINT ["/bootgly/Bootgly/@/__docker__/entrypoint.sh"]
CMD ["docker-default"]

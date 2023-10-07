ARG SYNAPSE_VERSION=1.93.0
ARG PYTHON_VERSION=3.11
ARG ALPINE_VERSION=3.18
ARG HARDENED_MALLOC_VERSION=11
ARG UID=991
ARG GID=991


### Build Hardened Malloc
FROM alpine:${ALPINE_VERSION} as build-malloc

ARG HARDENED_MALLOC_VERSION
ARG CONFIG_NATIVE=false
ARG VARIANT=light

RUN apk --no-cache add build-base git gnupg && cd /tmp \
 && wget -q https://github.com/thestinger.gpg && gpg --import thestinger.gpg \
 && git clone --depth 1 --branch ${HARDENED_MALLOC_VERSION} https://github.com/GrapheneOS/hardened_malloc \
 && cd hardened_malloc && git verify-tag $(git describe --tags) \
 && make CONFIG_NATIVE=${CONFIG_NATIVE} VARIANT=${VARIANT}


### Build Synapse
ARG ALPINE_VERSION
FROM python:${PYTHON_VERSION}-alpine${ALPINE_VERSION} as builder

ARG SYNAPSE_VERSION

RUN apk -U upgrade \
 && apk add -t build-deps \
        build-base \
        libffi-dev \
        libjpeg-turbo-dev \
        libxslt-dev \
        linux-headers \
        openssl-dev \        
        postgresql-dev \
        rustup \
        zlib-dev \
 && rustup-init -y && source $HOME/.cargo/env \
 && pip install --upgrade pip \
 && pip install --prefix="/install" --no-warn-script-location \
        matrix-synapse[all]==${SYNAPSE_VERSION}


### Build Production
ARG ALPINE_VERSION
ARG PYTHON_VERSION

FROM python:${PYTHON_VERSION}-alpine${ALPINE_VERSION}

ARG UID
ARG GID

RUN apk -U upgrade \
 && apk add -t run-deps \
        libffi \
        libgcc \
        libjpeg-turbo \
        libstdc++ \
        libxslt \
        libpq \
        openssl \
        zlib \
        tzdata \
        xmlsec \
        curl \
        icu-libs \
 && adduser -g ${GID} -u ${UID} --disabled-password --gecos "" synapse \
 && rm -rf /var/cache/apk/*


COPY --from=build-malloc /tmp/hardened_malloc/out-light/libhardened_malloc-light.so /usr/local/lib/
COPY --from=builder /install /usr/local
COPY --chown=synapse:synapse rootfs /

ENV LD_PRELOAD="/usr/local/lib/libhardened_malloc-light.so"

USER synapse

VOLUME /data

EXPOSE 8008/tcp 8009/tcp 8448/tcp

ENTRYPOINT ["python3", "start.py"]

HEALTHCHECK --start-period=5s --interval=15s --timeout=5s \
    CMD curl -fSs http://localhost:8008/health || exit 1

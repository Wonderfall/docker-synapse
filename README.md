# wonderfall/synapse

![Build, scan & push](https://github.com/wonderfall/docker-synapse/actions/workflows/build.yml/badge.svg)

[Synapse](https://github.com/matrix-org/synapse) is a [Matrix](https://matrix.org/) implementation written in Python.

### Notes
- Prebuilt images are available at `ghcr.io/wonderfall/synapse`.
- Don't trust random images: build yourself if you can.
- Always keep your software up-to-date: manage versions with [build-time variables](https://github.com/Wonderfall/docker-synapse/blob/main/Dockerfile#L1-L6).
- Images from `ghcr.io` are built every week, and scanned every day for critical vulnerabilities.

### Features & usage
- Drop-in replacement for the [official image](https://github.com/matrix-org/synapse/tree/develop/docker).
- Unprivileged image: you should check your volumes permissions (eg `/data`), default UID/GID is 991.
- Based on [Alpine](https://alpinelinux.org/), which provides more recent packages while having less attack surface.
- Comes with a [hardened memory allocator](https://github.com/GrapheneOS/hardened_malloc), protecting against some heap-based buffer overflows.

### Licensing
- v1.98.0 and prior are under the [MIT License](https://mit-license.org/). 😇
- Versions after v1.98.0 are under AGPL 3 🤮 to comply with licensing changes by Element.
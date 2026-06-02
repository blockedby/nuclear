FROM ubuntu:24.04

ARG USERNAME=ubuntu
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      bash \
      ca-certificates \
      curl \
      git \
      xz-utils \
      build-essential \
      pkg-config \
      libssl-dev \
      libgtk-3-dev \
      libwebkit2gtk-4.1-dev \
      libayatana-appindicator3-dev \
      librsvg2-dev \
      patchelf \
      file \
      wget \
      xdg-utils \
      dbus-x11 \
      libsoup-3.0-dev \
      javascriptcoregtk-4.1-dev \
      libxdo-dev \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /workspaces/nuclear /pnpm-store \
    && chown -R ${USERNAME}:${USERNAME} /workspaces /pnpm-store

USER ${USERNAME}
WORKDIR /workspaces/nuclear
ENV SHELL=/bin/bash \
    CARGO_HOME=/home/${USERNAME}/.cargo \
    RUSTUP_HOME=/home/${USERNAME}/.rustup \
    PNPM_HOME=/home/${USERNAME}/.local/share/pnpm \
    PNPM_STORE_DIR=/pnpm-store \
    PATH=/home/${USERNAME}/.cargo/bin:/home/${USERNAME}/.local/share/pnpm:$PATH

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
      | sh -s -- -y --profile minimal --default-toolchain stable \
    && rustup --version \
    && cargo --version \
    && rustc --version

CMD ["bash"]

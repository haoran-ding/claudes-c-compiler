#!/usr/bin/env bash
# Idempotent Cloud Agent install for Claude's C Compiler.
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  curl \
  pkg-config \
  qemu-user \
  gcc-aarch64-linux-gnu \
  gcc-riscv64-linux-gnu \
  gcc-i686-linux-gnu \
  libc6-dev-i386-cross \
  libc6-dev-arm64-cross \
  libc6-dev-riscv64-cross \
  linux-libc-dev-i386-cross \
  linux-libc-dev-arm64-cross \
  linux-libc-dev-riscv64-cross

# uN::is_multiple_of requires Rust >= 1.87. Pin 1.99.0 (see rust-toolchain.toml).
if ! rustup toolchain list | grep -q '^1.99.0'; then
  rustup toolchain install 1.99.0 --profile minimal --component rustfmt,clippy
fi
rustup default 1.99.0

# The imported tree is missing src/frontend/parser until that directory is present.
# Skip the compile in that case so install still leaves the toolchain ready.
if [[ -f src/frontend/parser/mod.rs ]]; then
  cargo build
else
  echo "ccc: src/frontend/parser is absent; skipping cargo build"
fi

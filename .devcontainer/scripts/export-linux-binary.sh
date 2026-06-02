#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
source_binary_name="nuclear-music-player"
artifact_binary_name="nuclear-music-player-arch"
source_binary="${repo_root}/packages/player/src-tauri/target/release/${source_binary_name}"
artifact_dir="${1:-${repo_root}/artifacts/linux-arch-bin}"
artifact_binary="${artifact_dir}/${artifact_binary_name}"

if [[ ! -x "${source_binary}" ]]; then
  cat >&2 <<ERROR
Release binary not found at ${source_binary}.
Build the plain executable without Tauri bundling first:
  cd ${repo_root}
  corepack pnpm --filter @nuclearplayer/player build:frontend
  cargo build --release --manifest-path packages/player/src-tauri/Cargo.toml
ERROR
  exit 1
fi

mkdir -p "${artifact_dir}"
cp "${source_binary}" "${artifact_binary}"
chmod 0755 "${artifact_binary}"

if command -v file >/dev/null 2>&1; then
  file "${artifact_binary}"
fi

printf 'Copied plain Linux executable to %s\n' "${artifact_binary}"

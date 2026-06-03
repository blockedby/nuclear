#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
artifact_binary_name="nuclear-music-player-arch"
release_dir="${repo_root}/packages/player/src-tauri/target/release"
artifact_dir="${1:-${repo_root}/artifacts/linux-arch-bin}"
artifact_binary="${artifact_dir}/${artifact_binary_name}"
source_binary=""

for candidate in nuclear-music-player player; do
  candidate_path="${release_dir}/${candidate}"
  if [[ -x "${candidate_path}" ]]; then
    source_binary="${candidate_path}"
    break
  fi
done

if [[ -z "${source_binary}" ]]; then
  cat >&2 <<ERROR
Release binary not found in ${release_dir}.
Expected either:
  ${release_dir}/nuclear-music-player  # Tauri-renamed binary
  ${release_dir}/player                # plain cargo build binary

Build the plain executable without Tauri bundling first:
  cd ${repo_root}
  pnpm --filter @nuclearplayer/player build:frontend
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

#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
binary_name="nuclear-music-player-arch"
container_image="${ARCH_PACKAGE_CONTAINER_IMAGE:-archlinux:base-devel}"
container_runtime="${CONTAINER_RUNTIME:-}"
artifact_binary="${ARCH_PACKAGE_BINARY:-${repo_root}/artifacts/linux-arch-bin/${binary_name}}"
package_root="${ARCH_PACKAGE_ARTIFACT_DIR:-${repo_root}/artifacts/arch-package}"
run_id="$(date -u +%Y%m%dT%H%M%SZ)"
staging_dir="${package_root}/staging/${run_id}"
package_dir="${package_root}/packages"
source_dir="${package_root}/sources/${run_id}"
log_dir="${package_root}/logs/${run_id}"
build_dir="${package_root}/build/${run_id}"
repo_mount="/repo"
staging_relative="${staging_dir#"${repo_root}/"}"
package_relative="${package_dir#"${repo_root}/"}"
source_relative="${source_dir#"${repo_root}/"}"
log_relative="${log_dir#"${repo_root}/"}"
build_relative="${build_dir#"${repo_root}/"}"

fail() {
  printf 'build-arch-package: %s\n' "$1" >&2
  exit 1
}

choose_container_runtime() {
  if [[ -n "${container_runtime}" ]]; then
    command -v "${container_runtime}" >/dev/null 2>&1 || fail "requested container runtime '${container_runtime}' was not found"
    printf '%s\n' "${container_runtime}"
    return
  fi

  if command -v docker >/dev/null 2>&1; then
    printf 'docker\n'
    return
  fi

  if command -v podman >/dev/null 2>&1; then
    printf 'podman\n'
    return
  fi

  fail 'Docker or Podman is required for the Arch container build; no host packages were installed'
}

require_repo_local_path() {
  local path="$1"
  local label="$2"

  case "${path}" in
    "${repo_root}"/*) ;;
    *) fail "${label} must be inside the repository: ${path}" ;;
  esac
}

require_repo_local_path "${artifact_binary}" 'Arch package binary artifact'
require_repo_local_path "${package_root}" 'Arch package artifact directory'
require_repo_local_path "${staging_dir}" 'Arch package staging directory'

if [[ ! -f "${artifact_binary}" ]]; then
  cat >&2 <<ERROR
build-arch-package: plain Linux binary artifact not found at ${artifact_binary}
Build and export the plain executable first:
  corepack pnpm --filter @nuclearplayer/player build:frontend
  cargo build --release --manifest-path packages/player/src-tauri/Cargo.toml
  .devcontainer/scripts/export-linux-binary.sh
ERROR
  exit 1
fi

[[ -x "${artifact_binary}" ]] || fail "plain Linux binary artifact is not executable: ${artifact_binary}"
[[ -f "${repo_root}/.devcontainer/arch-package/PKGBUILD" ]] || fail 'PKGBUILD is missing at .devcontainer/arch-package/PKGBUILD'
[[ -f "${repo_root}/packages/player/src-tauri/resources/com.nuclearplayer.Nuclear.desktop" ]] || fail 'desktop file is missing at packages/player/src-tauri/resources/com.nuclearplayer.Nuclear.desktop'
[[ -f "${repo_root}/packages/player/src-tauri/icons/icon.png" ]] || fail 'icon file is missing at packages/player/src-tauri/icons/icon.png'
[[ -f "${repo_root}/LICENSE" ]] || fail 'LICENSE is missing at repository root'

runtime="$(choose_container_runtime)"

mkdir -p "${staging_dir}" "${package_dir}" "${source_dir}" "${log_dir}" "${build_dir}"
install -m 0644 "${repo_root}/.devcontainer/arch-package/PKGBUILD" "${staging_dir}/PKGBUILD"
install -m 0755 "${artifact_binary}" "${staging_dir}/${binary_name}"
install -m 0644 "${repo_root}/packages/player/src-tauri/resources/com.nuclearplayer.Nuclear.desktop" "${staging_dir}/com.nuclearplayer.Nuclear.desktop"
install -m 0644 "${repo_root}/packages/player/src-tauri/icons/icon.png" "${staging_dir}/com.nuclearplayer.Nuclear.png"
install -m 0644 "${repo_root}/LICENSE" "${staging_dir}/LICENSE"

container_script=$(cat <<EOF_CONTAINER
set -euo pipefail
pacman -Sy --noconfirm --needed base-devel
if ! getent group "\$GROUP_ID" >/dev/null 2>&1; then
  groupadd -g "\$GROUP_ID" makepkg
fi
if ! id -u makepkg >/dev/null 2>&1; then
  useradd -m -u "\$USER_ID" -g "\$GROUP_ID" makepkg
fi
chown -R "\$USER_ID:\$GROUP_ID" "${repo_mount}/${package_relative}"
chown -R "\$USER_ID:\$GROUP_ID" "${repo_mount}/${source_relative}"
chown -R "\$USER_ID:\$GROUP_ID" "${repo_mount}/${log_relative}"
chown -R "\$USER_ID:\$GROUP_ID" "${repo_mount}/${build_relative}"
chown -R "\$USER_ID:\$GROUP_ID" "${repo_mount}/${staging_relative}"
runuser -u makepkg -- env \
  PKGDEST="${repo_mount}/${package_relative}" \
  SRCDEST="${repo_mount}/${source_relative}" \
  SRCPKGDEST="${repo_mount}/${source_relative}" \
  LOGDEST="${repo_mount}/${log_relative}" \
  BUILDDIR="${repo_mount}/${build_relative}" \
  makepkg -d -f --noconfirm
EOF_CONTAINER
)

"${runtime}" run --rm \
  --volume "${repo_root}:${repo_mount}" \
  --workdir "${repo_mount}/${staging_relative}" \
  --env USER_ID="$(id -u)" \
  --env GROUP_ID="$(id -g)" \
  "${container_image}" \
  bash -lc "${container_script}"

printf 'Arch package artifacts written under %s\n' "${package_dir}"
find "${package_dir}" -maxdepth 1 -type f -name '*.pkg.tar.zst' -print

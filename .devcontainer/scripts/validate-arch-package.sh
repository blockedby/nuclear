#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
package_dir="${1:-${repo_root}/artifacts/arch-package/packages}"
binary_path="usr/bin/nuclear-music-player-arch"
desktop_path="usr/share/applications/com.nuclearplayer.desktop"
expected_exec="Exec=nuclear-music-player-arch %u"

fail() {
  printf 'validate-arch-package: %s\n' "$1" >&2
  exit 1
}

case "${package_dir}" in
  "${repo_root}"/*) ;;
  *) fail "package directory must be inside the repository: ${package_dir}" ;;
esac

[[ -d "${package_dir}" ]] || fail "package directory not found: ${package_dir}"

shopt -s nullglob
packages=("${package_dir}"/*.pkg.tar.zst)
shopt -u nullglob

[[ ${#packages[@]} -gt 0 ]] || fail "no .pkg.tar.zst files found under ${package_dir}"

for package in "${packages[@]}"; do
  printf 'Validating Arch package %s\n' "${package}"

  package_listing="$(tar --zstd -tf "${package}")"

  grep -qx "${binary_path}" <<<"${package_listing}" \
    || fail "${package} does not contain /${binary_path}"

  grep -qx "${desktop_path}" <<<"${package_listing}" \
    || fail "${package} does not contain /${desktop_path}"

  desktop_file="$(tar --zstd -xOf "${package}" "${desktop_path}")"

  grep -qx "${expected_exec}" <<<"${desktop_file}" \
    || fail "${package} desktop file does not contain '${expected_exec}'"

done

printf 'Validated %s Arch package artifact(s) under %s\n' "${#packages[@]}" "${package_dir}"

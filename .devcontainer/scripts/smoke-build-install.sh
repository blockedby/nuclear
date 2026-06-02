#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
script_dir="${repo_root}/.devcontainer/scripts"
package_root="${repo_root}/artifacts/branch-arch-package/worktrees"
branch_name=""
package_slug=""
run_after_install=false
smoke_target=""

fail() {
  printf 'smoke-build-install: %s\n' "$1" >&2
  exit 1
}

usage() {
  cat <<USAGE
Usage: .devcontainer/scripts/smoke-build-install.sh <wayland|mpris> [--run]

Examples:
  .devcontainer/scripts/smoke-build-install.sh wayland
  .devcontainer/scripts/smoke-build-install.sh mpris
  .devcontainer/scripts/smoke-build-install.sh wayland --run

Targets:
  wayland  builds roadmap/wayland-tray-options, then installs its Arch package
  mpris    builds roadmap/mpris2-now-playing, then installs its Arch package

What this does:
  1. Runs .devcontainer/scripts/build-branch-arch-package.sh <branch>
  2. Finds the generated *.pkg.tar.zst in artifacts/branch-arch-package/worktrees/<slug>/artifacts/arch-package/packages
  3. Runs sudo pacman -U --needed "\$pkg"
  4. Prints the run command, evidence/log suggestion, and rollback command

Rollback:
  sudo pacman -Rns arch-nuclear-bin
USAGE
}

set_target() {
  case "$1" in
    wayland)
      smoke_target="wayland"
      branch_name="roadmap/wayland-tray-options"
      package_slug="roadmap__wayland-tray-options"
      ;;
    mpris)
      smoke_target="mpris"
      branch_name="roadmap/mpris2-now-playing"
      package_slug="roadmap__mpris2-now-playing"
      ;;
    *)
      usage >&2
      fail "unknown target: $1"
      ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --run)
      run_after_install=true
      shift
      ;;
    --)
      shift
      break
      ;;
    -* )
      usage >&2
      fail "unknown option: $1"
      ;;
    *)
      if [[ -n "${smoke_target}" ]]; then
        usage >&2
        fail 'only one target is supported'
      fi
      set_target "$1"
      shift
      ;;
  esac
done

if [[ $# -gt 0 ]]; then
  if [[ -n "${smoke_target}" || $# -gt 1 ]]; then
    usage >&2
    fail 'only one target is supported'
  fi
  set_target "$1"
fi

[[ -n "${smoke_target}" ]] || { usage >&2; exit 2; }
[[ -x "${script_dir}/build-branch-arch-package.sh" ]] || fail 'build helper is missing or not executable: .devcontainer/scripts/build-branch-arch-package.sh'

package_dir="${package_root}/${package_slug}/artifacts/arch-package/packages"

cat <<START
Smoke target: ${smoke_target}
Branch: ${branch_name}
Package directory: ${package_dir}
START

"${script_dir}/build-branch-arch-package.sh" "${branch_name}"

[[ -d "${package_dir}" ]] || fail "package directory was not created: ${package_dir}"

mapfile -t package_files < <(find "${package_dir}" -maxdepth 1 -type f -name '*.pkg.tar.zst' -printf '%T@ %p\n' | sort -nr | cut -d' ' -f2-)
[[ ${#package_files[@]} -gt 0 ]] || fail "no package was found in ${package_dir}"

package_path="${package_files[0]}"

printf 'Installing generated package:\n  %s\n' "${package_path}"
sudo pacman -U --needed "${package_path}"

cat <<NEXT

Install complete.
Run command:
  nuclear-music-player-arch

Evidence/log suggestion:
  mkdir -p artifacts/desktop-smoke-evidence/${smoke_target}
  nuclear-music-player-arch 2>&1 | tee artifacts/desktop-smoke-evidence/${smoke_target}/app.log

Rollback command:
  sudo pacman -Rns arch-nuclear-bin
NEXT

if [[ "${run_after_install}" == true ]]; then
  printf '\nLaunching nuclear-music-player-arch...\n'
  nuclear-music-player-arch
fi

#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
branch_name=""
reuse_existing=false
replace_existing=false
worktree_root="${repo_root}/artifacts/branch-arch-package/worktrees"

fail() {
  printf 'build-branch-arch-package: %s\n' "$1" >&2
  exit 1
}

usage() {
  cat >&2 <<USAGE
Usage: .devcontainer/scripts/build-branch-arch-package.sh [--replace-existing] <branch-name>

Examples:
  .devcontainer/scripts/build-branch-arch-package.sh roadmap/wayland-tray-options
  .devcontainer/scripts/build-branch-arch-package.sh roadmap/mpris2-now-playing
  .devcontainer/scripts/build-branch-arch-package.sh --replace-existing roadmap/wayland-tray-options

Creates an ignored repo-local worktree under artifacts/branch-arch-package/worktrees,
then runs dependency install, frontend build, Rust release build, binary export,
Arch package build, and package validation inside that worktree.

Existing generated smoke worktrees are reused by default. Use --replace-existing
only when you intentionally want to remove and recreate that generated worktree.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --reuse-existing)
      reuse_existing=true
      shift
      ;;
    --replace-existing)
      replace_existing=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      usage
      fail "unknown option: $1"
      ;;
    *)
      if [[ -n "${branch_name}" ]]; then
        usage
        fail "only one branch name is supported"
      fi
      branch_name="$1"
      shift
      ;;
  esac
done

if [[ $# -gt 0 ]]; then
  if [[ -n "${branch_name}" || $# -gt 1 ]]; then
    usage
    fail 'only one branch name is supported'
  fi
  branch_name="$1"
fi

require_repo_local_path() {
  local path="$1"
  local label="$2"

  case "${path}" in
    "${repo_root}"|"${repo_root}"/*) ;;
    *) fail "${label} must be inside the repository: ${path}" ;;
  esac
}

validate_branch_name() {
  local candidate="$1"

  [[ -n "${candidate}" ]] || fail 'branch name is required'
  [[ ${#candidate} -le 128 ]] || fail 'branch name is too long'
  [[ "${candidate}" != -* ]] || fail 'branch name must not start with -'
  [[ "${candidate}" =~ ^[A-Za-z0-9]([-A-Za-z0-9._/]*[A-Za-z0-9])?$ ]] \
    || fail "unsafe branch name: ${candidate}"
  [[ "${candidate}" != *..* ]] || fail "unsafe branch name contains '..': ${candidate}"
  [[ "${candidate}" != *@\{* ]] || fail "unsafe branch name contains '@{': ${candidate}"
  [[ "${candidate}" != *//* ]] || fail "unsafe branch name contains '//': ${candidate}"
  [[ "${candidate}" != *\\* ]] || fail "unsafe branch name contains a backslash: ${candidate}"
  [[ "${candidate}" != *.lock ]] || fail "unsafe branch name ends with .lock: ${candidate}"

  IFS='/' read -r -a branch_segments <<<"${candidate}"
  for branch_segment in "${branch_segments[@]}"; do
    [[ -n "${branch_segment}" ]] || fail "unsafe branch name contains an empty path segment: ${candidate}"
    [[ "${branch_segment}" != '.' && "${branch_segment}" != '..' ]] \
      || fail "unsafe branch name contains a dot path segment: ${candidate}"
    [[ "${branch_segment}" != .* ]] \
      || fail "unsafe branch name contains a hidden path segment: ${candidate}"
    [[ "${branch_segment}" != *.lock ]] \
      || fail "unsafe branch name contains a .lock segment: ${candidate}"
  done

  git check-ref-format --branch "${candidate}" >/dev/null 2>&1 \
    || fail "branch name is not a valid git branch name: ${candidate}"
}

worktree_name_for_branch() {
  printf '%s' "$1" | sed -E 's#/+#__#g; s#[^A-Za-z0-9._-]#-#g'
}

validate_worktree_name() {
  local candidate="$1"

  [[ -n "${candidate}" ]] || fail 'derived worktree name is empty'
  [[ ${#candidate} -le 160 ]] || fail 'derived worktree name is too long'
  [[ "${candidate}" =~ ^[A-Za-z0-9]([-A-Za-z0-9._]*[A-Za-z0-9])?$ ]] \
    || fail "unsafe derived worktree name: ${candidate}"
  [[ "${candidate}" != *..* ]] || fail "unsafe derived worktree name contains '..': ${candidate}"
}

available_branch_suggestions() {
  local candidate="$1"
  local prefix="${candidate%/*}"

  if [[ "${prefix}" == "${candidate}" ]]; then
    prefix='roadmap'
  fi

  {
    git for-each-ref --format='%(refname:short)' refs/heads "refs/remotes/origin/${prefix}" 2>/dev/null || true
    git for-each-ref --format='%(refname:short)' refs/remotes/origin 2>/dev/null || true
  } \
    | sed -E 's#^origin/##' \
    | grep -E "^(${prefix}/|${candidate})" \
    | sort -u \
    | head -20
}

resolve_branch_ref() {
  local candidate="$1"
  local suggestions

  if git show-ref --verify --quiet "refs/heads/${candidate}"; then
    printf '%s\n' "${candidate}"
    return
  fi

  if git show-ref --verify --quiet "refs/remotes/origin/${candidate}"; then
    printf '%s\n' "origin/${candidate}"
    return
  fi

  suggestions="$(available_branch_suggestions "${candidate}")"
  if [[ -n "${suggestions}" ]]; then
    printf "build-branch-arch-package: branch '%s' was not found. Did you mean one of these?\n%s\n" \
      "${candidate}" "${suggestions}" >&2
  fi

  fail "branch '${candidate}' was not found locally or as origin/${candidate}; run 'git fetch origin' first"
}

source_viteplus_if_available() {
  local viteplus_env="${VITE_PLUS_ENV:-${HOME}/.vite-plus/env}"

  if [[ -r "${viteplus_env}" ]]; then
    # shellcheck source=/dev/null
    . "${viteplus_env}"
  fi
}

choose_frontend_tool() {
  if command -v corepack >/dev/null 2>&1; then
    printf 'corepack\n'
    return
  fi

  if command -v pnpm >/dev/null 2>&1; then
    printf 'pnpm\n'
    return
  fi

  source_viteplus_if_available

  if command -v corepack >/dev/null 2>&1; then
    printf 'corepack\n'
    return
  fi

  if command -v pnpm >/dev/null 2>&1; then
    printf 'pnpm\n'
    return
  fi

  if command -v vp >/dev/null 2>&1; then
    printf 'vp\n'
    return
  fi

  fail "neither corepack, pnpm, nor vp was found. Install/enable pnpm or source VitePlus first: source \"${VITE_PLUS_ENV:-${HOME}/.vite-plus/env}\""
}

run_install() {
  local frontend_tool="$1"

  case "${frontend_tool}" in
    corepack) corepack pnpm install --frozen-lockfile ;;
    pnpm) pnpm install --frozen-lockfile ;;
    vp) vp install ;;
    *) fail "unknown frontend tool: ${frontend_tool}" ;;
  esac
}

run_frontend_build() {
  local frontend_tool="$1"

  case "${frontend_tool}" in
    corepack) corepack pnpm --filter @nuclearplayer/player build:frontend ;;
    pnpm) pnpm --filter @nuclearplayer/player build:frontend ;;
    vp) vp run --filter @nuclearplayer/player build:frontend ;;
    *) fail "unknown frontend tool: ${frontend_tool}" ;;
  esac
}

require_runtime_tools() {
  local frontend_tool="$1"

  command -v git >/dev/null 2>&1 || fail 'git is required'
  command -v cargo >/dev/null 2>&1 || fail 'cargo is required for the Rust release build'

  if ! command -v docker >/dev/null 2>&1 && ! command -v podman >/dev/null 2>&1; then
    fail 'Docker or Podman is required for the Arch package build container'
  fi

  printf 'Using frontend package tool: %s\n' "${frontend_tool}"
}

ensure_packaging_helpers() {
  local worktree_dir="$1"
  local helper_path
  local source_path
  local destination_path
  local helper_paths=(
    '.devcontainer/arch-package/PKGBUILD'
    '.devcontainer/scripts/export-linux-binary.sh'
    '.devcontainer/scripts/build-arch-package.sh'
    '.devcontainer/scripts/validate-arch-package.sh'
  )

  for helper_path in "${helper_paths[@]}"; do
    source_path="${repo_root}/${helper_path}"
    destination_path="${worktree_dir}/${helper_path}"

    [[ -e "${source_path}" ]] || fail "required helper is missing in this repo: ${helper_path}"

    mkdir -p "$(dirname "${destination_path}")"
    install -m "$(stat -c '%a' "${source_path}")" "${source_path}" "${destination_path}"
    printf 'Synced package helper into temporary worktree: %s\n' "${helper_path}"
  done
}

print_failure_hint() {
  local worktree_dir="$1"

  cat >&2 <<HINT

build-branch-arch-package: build failed.
Worktree kept for inspection: ${worktree_dir}

To retry in the same worktree:
  .devcontainer/scripts/build-branch-arch-package.sh --reuse-existing ${branch_name}

To remove the generated worktree and start clean:
  git worktree remove ${worktree_dir}
  .devcontainer/scripts/build-branch-arch-package.sh ${branch_name}
HINT
}

if [[ -z "${branch_name}" ]]; then
  usage
  exit 2
fi

if [[ "${reuse_existing}" == true && "${replace_existing}" == true ]]; then
  fail '--reuse-existing and --replace-existing cannot be used together'
fi

cd "${repo_root}"
validate_branch_name "${branch_name}"
frontend_tool="$(choose_frontend_tool)"
require_runtime_tools "${frontend_tool}"
worktree_name="$(worktree_name_for_branch "${branch_name}")"
validate_worktree_name "${worktree_name}"
worktree_dir="${worktree_root}/${worktree_name}"
branch_ref="$(resolve_branch_ref "${branch_name}")"

require_repo_local_path "${worktree_root}" 'branch package worktree root'
require_repo_local_path "${worktree_dir}" 'branch package worktree'

if [[ -e "${worktree_dir}" ]]; then
  if [[ "${replace_existing}" == true ]]; then
    git worktree remove "${worktree_dir}"
  else
    printf 'Reusing existing smoke worktree: %s\n' "${worktree_dir}"
    printf 'Use --replace-existing if you want to recreate it from scratch.\n'
  fi
fi

if [[ ! -e "${worktree_dir}" ]]; then
  mkdir -p "${worktree_root}"
  git worktree add --detach "${worktree_dir}" "${branch_ref}"
fi

ensure_packaging_helpers "${worktree_dir}"
trap 'print_failure_hint "${worktree_dir}"' ERR

printf 'Building Arch package for branch %s in %s\n' "${branch_name}" "${worktree_dir}"

(
  cd "${worktree_dir}"
  run_install "${frontend_tool}"
  run_frontend_build "${frontend_tool}"
  cargo build --release --manifest-path packages/player/src-tauri/Cargo.toml
  .devcontainer/scripts/export-linux-binary.sh
  .devcontainer/scripts/build-arch-package.sh
  .devcontainer/scripts/validate-arch-package.sh
)

trap - ERR

cat <<RESULT
Branch package build complete.
Worktree: ${worktree_dir}
Packages: ${worktree_dir}/artifacts/arch-package/packages
Validation: .devcontainer/scripts/validate-arch-package.sh completed inside the branch worktree
RESULT

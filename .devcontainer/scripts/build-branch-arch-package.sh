#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
branch_name="${1:-}"
worktree_root="${repo_root}/artifacts/branch-arch-package/worktrees"

fail() {
  printf 'build-branch-arch-package: %s\n' "$1" >&2
  exit 1
}

usage() {
  cat >&2 <<USAGE
Usage: .devcontainer/scripts/build-branch-arch-package.sh <branch-name>

Creates an ignored repo-local worktree under artifacts/branch-arch-package/worktrees,
then runs the frontend build, Rust release build, binary export, Arch package build,
and package validation inside that worktree.
USAGE
}

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

resolve_branch_ref() {
  local candidate="$1"

  if git show-ref --verify --quiet "refs/heads/${candidate}"; then
    printf '%s\n' "${candidate}"
    return
  fi

  if git show-ref --verify --quiet "refs/remotes/origin/${candidate}"; then
    printf '%s\n' "origin/${candidate}"
    return
  fi

  fail "branch '${candidate}' was not found locally or as origin/${candidate}; run 'git fetch origin' first"
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

    if [[ ! -e "${destination_path}" ]]; then
      mkdir -p "$(dirname "${destination_path}")"
      install -m "$(stat -c '%a' "${source_path}")" "${source_path}" "${destination_path}"
      printf 'Copied missing package helper into temporary worktree: %s\n' "${helper_path}"
    fi
  done
}

if [[ -z "${branch_name}" ]]; then
  usage
  exit 2
fi

cd "${repo_root}"
validate_branch_name "${branch_name}"
worktree_name="$(worktree_name_for_branch "${branch_name}")"
validate_worktree_name "${worktree_name}"
worktree_dir="${worktree_root}/${worktree_name}"
branch_ref="$(resolve_branch_ref "${branch_name}")"

require_repo_local_path "${worktree_root}" 'branch package worktree root'
require_repo_local_path "${worktree_dir}" 'branch package worktree'

if [[ -e "${worktree_dir}" ]]; then
  fail "worktree already exists: ${worktree_dir}; inspect it or remove it with 'git worktree remove ${worktree_dir}' before rebuilding"
fi

mkdir -p "${worktree_root}"
git worktree add --detach "${worktree_dir}" "${branch_ref}"
ensure_packaging_helpers "${worktree_dir}"

printf 'Building Arch package for branch %s in %s\n' "${branch_name}" "${worktree_dir}"

(
  cd "${worktree_dir}"
  corepack pnpm --filter @nuclearplayer/player build:frontend
  cargo build --release --manifest-path packages/player/src-tauri/Cargo.toml
  .devcontainer/scripts/export-linux-binary.sh
  .devcontainer/scripts/build-arch-package.sh
  .devcontainer/scripts/validate-arch-package.sh
)

cat <<RESULT
Branch package build complete.
Worktree: ${worktree_dir}
Packages: ${worktree_dir}/artifacts/arch-package/packages
Validation: .devcontainer/scripts/validate-arch-package.sh completed inside the branch worktree
RESULT

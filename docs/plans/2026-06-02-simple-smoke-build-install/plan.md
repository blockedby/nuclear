# Simple smoke build/install helper plan

## Task intake
- Goal: add a simple smoke-test script so users can build and install a draft Arch package with one command like `.devcontainer/scripts/smoke-build-install.sh wayland` or `mpris`.
- In scope: wrapper script, docs update putting wrapper first, syntax/usage verification, commit and push to PR #11 branch `smoke-test-kit`.
- Out of scope: running the expensive build, installing host packages, merging, upstream PRs, marking PR ready.
- Done state: script maps aliases to the requested roadmap branches/slugs, calls the existing branch package builder, installs the generated package with user-invoked `sudo pacman -U --needed`, prints run/evidence/rollback guidance, docs lead with the simple flow, changes committed and pushed.
- Blocking unknowns: none.

## Repo orientation
- Worktree: `/home/kcnc/code/apps/nuclear/.worktrees/smoke-test-kit` on branch `smoke-test-kit`.
- Relevant files:
  - `.devcontainer/scripts/build-branch-arch-package.sh` existing branch package builder.
  - `.devcontainer/docs/desktop-smoke-test-kit.md` existing smoke-test documentation.
- Verification commands:
  - `bash -n .devcontainer/scripts/smoke-build-install.sh`
  - `.devcontainer/scripts/smoke-build-install.sh --help`
  - `.devcontainer/scripts/smoke-build-install.sh bogus` for usage/error path.

## Reuse discovery
- Reuse `build-branch-arch-package.sh` exactly for build behavior and generated worktree location.
- Reuse slug convention from `worktree_name_for_branch`: `roadmap/wayland-tray-options` -> `roadmap__wayland-tray-options`, `roadmap/mpris2-now-playing` -> `roadmap__mpris2-now-playing`.
- Reuse run command `/usr/bin/nuclear-music-player-arch` and rollback `sudo pacman -Rns arch-nuclear-bin` from current docs.

## Missing pieces
- Add `.devcontainer/scripts/smoke-build-install.sh`.
- Move docs emphasis so the simple command appears before the low-level build/install recipe.

## Plan tasks

### Task 1: one-command smoke build/install wrapper
Goal:
- Make `wayland` and `mpris` aliases build the right branch, locate the generated package, install it, and print next steps.
Boundary:
- System area: devcontainer smoke-test scripts/docs.
- Primary verification: bash syntax and dry usage/error checks; no build/install run.
Existing pattern / reuse:
- `.devcontainer/scripts/build-branch-arch-package.sh` and docs package paths.
Missing change:
- New wrapper script with usage, alias mapping, package lookup, optional `--run`, evidence and rollback instructions.
Scope / likely files:
- `.devcontainer/scripts/smoke-build-install.sh`
- `.devcontainer/docs/desktop-smoke-test-kit.md`
Acceptance criteria:
- `wayland` maps to `roadmap/wayland-tray-options` and `roadmap__wayland-tray-options`.
- `mpris` maps to `roadmap/mpris2-now-playing` and `roadmap__mpris2-now-playing`.
- Script calls `.devcontainer/scripts/build-branch-arch-package.sh <branch>`.
- Script installs the found `*.pkg.tar.zst` with `sudo pacman -U --needed "$pkg"` and has no other host install path.
- Script prints `nuclear-music-player-arch`, evidence/log suggestion, usage/help, rollback command, and supports optional `--run`.
- Docs put this simple script first.
Test plan:
- Positive: `bash -n .devcontainer/scripts/smoke-build-install.sh`; `.devcontainer/scripts/smoke-build-install.sh --help`.
- Negative: `.devcontainer/scripts/smoke-build-install.sh bogus` exits non-zero with usage.
- Manual: do not run build/install per task constraint.
Dependencies:
- Depends on: none.
- Blocks: final commit/push.
- Can run parallel with: none.
Executor:
- slice owner direct tiny edit.

## Execution ledger
- 2026-06-02: plan created; implementation pending.
- 2026-06-02: implemented `.devcontainer/scripts/smoke-build-install.sh` and updated docs to put simple usage first.
- 2026-06-02: verification passed: `bash -n .devcontainer/scripts/smoke-build-install.sh`, `.devcontainer/scripts/smoke-build-install.sh --help`, and bogus-target error path. Build/install intentionally not run.

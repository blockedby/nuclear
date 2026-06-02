# Plan: Desktop smoke-test kit

## Task intake

- Goal: provide a small repo-local desktop smoke-test kit for manually validating draft PR #8 Wayland tray and PR #7 MPRIS2/KDE Connect by installing branch Arch package builds.
- In scope: repo-local scripts and docs only.
- Out of scope: PR #7/#8 feature code changes, branch merges, upstream PRs, host package installs by helper scripts, full Tauri bundle/AppImage builds, destructive cleanup/prune/rm outside repo.
- Verification scope: syntax/static checks and documentation grep/review only; do not run expensive frontend, cargo, or package builds.

## Repo orientation

- Existing Arch package helper: `.devcontainer/scripts/build-arch-package.sh` builds a package inside Docker/Podman and keeps outputs under repo-local `artifacts/arch-package/`.
- Existing export helper: `.devcontainer/scripts/export-linux-binary.sh` exports `/packages/player/src-tauri/target/release/nuclear-music-player` as `artifacts/linux-arch-bin/nuclear-music-player-arch`.
- Existing validation helper: `.devcontainer/scripts/validate-arch-package.sh` verifies package contents include `/usr/bin/nuclear-music-player-arch`, the desktop file, and `Exec=nuclear-music-player-arch %u`.
- Existing Arch package docs: `.devcontainer/docs/arch-linux-package.md` documents container packaging assumptions and safety boundaries.

## Task 1: Branch package build wrapper and desktop smoke docs

Status: implementation complete; owner acceptance pending. Report: `reports/aad-implementer-smoke-kit.md`.

Goal:
- Add a wrapper that accepts safe branch names such as `roadmap/wayland-tray-options` and `roadmap/mpris2-now-playing`, creates a repo-local ignored worktree, and runs frontend build, cargo release build, binary export, Arch package build, and package validation inside that worktree.
- Add docs for building, installing, validating, collecting evidence, smoking Wayland tray behavior, smoking MPRIS2/KDE Connect behavior, and rolling back.

Acceptance criteria:
- Script accepts branch names such as `roadmap/wayland-tray-options` and `roadmap/mpris2-now-playing`, creates a repo-local worktree, and runs frontend build, cargo release, export, package build, and package validation in that worktree.
- Script refuses unsafe branch/worktree names, keeps artifacts inside repo, does not install host packages, and does not remove/prune outside repo.
- Docs include commands to build #8/#7 packages, install via pacman, collect evidence/logs, and rollback.
- Test plans cover requested Wayland tray close/minimize/restore/quit/icon behavior and MPRIS2/KDE Connect track/artist/artwork/status/control behavior.

Test plan:
- `bash -n .devcontainer/scripts/build-branch-arch-package.sh`
- `bash -n` existing scripts if referenced/changed.
- Grep/review docs for #7/#8 branch commands, `/usr/bin/nuclear-music-player-arch`, package validation, and rollback command.
- Do not run expensive builds.

## Execution ledger

- 2026-06-02: Implementer found the task package missing in this worktree and created it from the delegated prompt while keeping scope unchanged.
- 2026-06-02: Implementer started Task 1; initial syntax check for missing wrapper failed as expected before implementation.

- 2026-06-02: Implementer added `.devcontainer/scripts/build-branch-arch-package.sh`, `.devcontainer/docs/desktop-smoke-test-kit.md`, and task package artifacts; static syntax/safety/docs checks passed; expensive builds intentionally skipped.

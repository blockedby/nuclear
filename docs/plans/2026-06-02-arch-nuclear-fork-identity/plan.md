# Arch Nuclear fork identity and release packaging plan

## Task intake
- Goal: scope repo/package identity for maintained Arch/Wayland fork at `blockedby/arch-nuclear`.
- In scope: README fork notice; Arch binary/package naming; packaged desktop `Exec`; Arch package docs/scripts; minimal release workflow producing Linux binary plus Arch `.pkg.tar.zst` artifact; local syntax/package evidence; commit/push to origin branch.
- Out of scope: upstream PRs; full MPRIS2/KDE Connect; broad app-id/user-data renames; unrelated feature changes; host package installation.
- Done state: branch `arch-nuclear-identity` contains scoped changes, local verification is recorded, commit is pushed to origin.
- Blocking unknowns: package build may be limited by local container/runtime availability or binary availability; record explicit limitation if not feasible.

## Repo orientation
- Worktree: `/home/kcnc/code/apps/nuclear/.worktrees/arch-nuclear-identity`
- Branch: `arch-nuclear-identity`
- Package files:
  - `.devcontainer/arch-package/PKGBUILD`
  - `.devcontainer/scripts/build-arch-package.sh`
  - `.devcontainer/docs/arch-linux-package.md`
  - `.devcontainer/docs/arch-linux-binary-artifact.md`
- Desktop file: `packages/player/src-tauri/resources/com.nuclearplayer.Nuclear.desktop`
- Existing release workflows: `.github/workflows/release-player.yml`; update/add minimal Arch release workflow as appropriate.
- Verification commands likely:
  - `bash -n .devcontainer/scripts/build-arch-package.sh`
  - `bash -n` on workflow shell snippets where practical
  - `.devcontainer/scripts/build-arch-package.sh` if binary/container are available
  - package contents inspection with `tar -tf artifacts/arch-package/packages/*.pkg.tar.zst` if package produced
  - `git status`, `git remote -v`, `git push origin arch-nuclear-identity`

## Reuse discovery
- Existing PKGBUILD already packages a staged plain binary, desktop file, icon, and license using `makepkg -d` in an Arch container.
- Existing build helper enforces repo-local artifact paths and avoids host package installation/destructive prune.
- Existing desktop resource uses `Exec=nuclear-music-player %u`; package can patch this without renaming app metadata globally.
- Existing release-player workflow already builds platform release artifacts on tags; add a narrowly scoped Arch workflow or job rather than changing unrelated release behavior.

## Missing pieces
- Rename Arch package from upstream-like `nuclear-player-bin` to fork-specific `arch-nuclear-bin`.
- Stage/install binary as `nuclear-music-player-arch` and patch packaged desktop `Exec` to it.
- Update license install path and `provides`/`conflicts` for sane fork/upstream relationship.
- Update Arch package docs and README to explain fork policy and release artifact expectations.
- Add minimal GitHub Actions workflow for Arch package artifact generation/upload if feasible.
- Record verification evidence and final slice report.

## Plan tasks

### T1 — Implement fork identity/package changes
- Executor: `aad-implementer`
- Acceptance criteria:
  - README names `blockedby/arch-nuclear` and states Arch-first package, Wayland tray/app-id direction, `/usr/bin/nuclear-music-player-arch`, GitHub Releases-only artifacts, and no upstream PR/code contribution policy.
  - PKGBUILD package name is fork-specific, installs `/usr/bin/nuclear-music-player-arch`, patches packaged desktop `Exec`, keeps icon/app metadata sane, and uses sane license/provides/conflicts.
  - Scripts/docs reference `nuclear-music-player-arch` and `arch-nuclear-bin`.
  - Minimal GHA workflow exists for binary + Arch package artifact generation/upload unless recorded infeasible.
- Test plan:
  - `bash -n .devcontainer/scripts/build-arch-package.sh`
  - Inspect changed workflow YAML and shell snippets for syntax; run available shell syntax checks.
  - If binary/container feasible, run package helper and inspect `.pkg.tar.zst` contents.
- Dependencies: none.
- Report: `docs/plans/2026-06-02-arch-nuclear-fork-identity/reports/aad-implementer-identity.md`

### T2 — Owner verification, commit, push, report
- Executor: slice owner
- Acceptance criteria:
  - Fresh verification evidence written to `verification/slice-local.md`.
  - Coherent commit created and pushed to `origin arch-nuclear-identity` only.
  - Final report written to `reports/slice-owner.md`.
- Depends on: T1.

## Dependency graph
- Wave 1: T1 implementation.
- Wave 2: T2 verification/commit/push/report.

## Status log
- 2026-06-02: Plan created by slice owner after repo orientation; ready for T1 dispatch.
- 2026-06-02: T1 completed directly by slice owner because nested subagent dispatch was blocked by subagent depth. Verification evidence recorded in `verification/slice-local.md`.

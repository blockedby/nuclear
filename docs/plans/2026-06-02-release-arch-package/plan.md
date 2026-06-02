# Plan: Release Arch package workflow/package CI PR (#3)

## Task intake
- Goal: implement issue #3 by validating/fixing `.github/workflows/release-arch-package.yml` so the fork can build and upload predictable Arch `.pkg.tar.zst` artifacts and check package contents.
- In scope: release workflow, `.devcontainer/scripts` checks/docs needed for package validation/manual trigger behavior.
- Out of scope: upstream/nukeop PRs, merging PRs, host installs, destructive cleanup, pacman repo/AUR publishing.
- Done state: branch pushed to `origin`, PR opened to `blockedby/arch-nuclear:master`, acceptance evidence recorded, root report written.
- Blocking unknowns: full GitHub Actions/container build may be unavailable locally; if so static/package validation must be robust and gap explicit.

## Repo orientation
- Repo root guidance: `AGENTS.md` and `README.md` read; no nearer child `AGENTS.md` for `.github` or `.devcontainer`.
- Current relevant files:
  - `.github/workflows/release-arch-package.yml`
  - `.devcontainer/scripts/build-arch-package.sh`
  - `.devcontainer/scripts/export-linux-binary.sh`
  - `.devcontainer/arch-package/PKGBUILD`
  - `.devcontainer/docs/arch-linux-package.md`
  - `.devcontainer/docs/arch-linux-binary-artifact.md`
  - `packages/player/src-tauri/resources/com.nuclearplayer.Nuclear.desktop`
- Verification commands likely useful: static grep/yaml checks; shell script dry/failure checks; synthetic package-content validation where real Arch build cannot run.

## Reuse discovery
- Existing workflow already builds frontend/Rust binary, exports `artifacts/linux-arch-bin/nuclear-music-player-arch`, builds package in Arch container, uploads artifacts, and attaches release assets for `arch-nuclear@*.*.*` tags.
- Existing PKGBUILD installs `/usr/bin/nuclear-music-player-arch` and patches desktop `Exec=nuclear-music-player-arch %u`.
- Missing reusable piece: a package validation script/check step that inspects built `.pkg.tar.zst` contents and verifies binary plus desktop Exec.

## Missing pieces
- Add robust CI package validation after package build and before upload/release.
- Make artifact naming predictable and `.pkg.tar.zst` explicit in workflow/release docs.
- Document manual trigger/tag release behavior and local verification limitations.

## Plan tasks

### Task 1: Validate Arch package workflow artifacts and docs
Status: done. Report: `reports/aad-implementer-release-workflow.md`; verification: `verification/local.md`.

Goal:
- Ensure package checks prove `.pkg.tar.zst` contains `/usr/bin/nuclear-music-player-arch` and desktop `Exec=nuclear-music-player-arch %u`, and docs explain manual/tag behavior.
Boundary:
- System area: GitHub Actions workflow and repo-local Arch package scripts/docs.
- Primary verification: static workflow/script/docs checks plus safe local validation of synthetic package contents where possible.
Existing pattern / reuse:
- Reuse `.devcontainer/arch-package/PKGBUILD` packaging paths and `.devcontainer/scripts` style (`bash`, `set -euo pipefail`, repo-local artifact paths, no host package installs).
Missing change:
- Add a validation script or workflow inline validation; wire it into `.github/workflows/release-arch-package.yml`; update docs.
Scope / likely files:
- `.github/workflows/release-arch-package.yml`
- `.devcontainer/scripts/*`
- `.devcontainer/docs/arch-linux-package.md`
Acceptance criteria:
- Workflow syntax/action versions are sane for repo and upload predictable `.pkg.tar.zst` artifacts.
- Package validation checks binary path and desktop Exec in built package contents.
- Docs state manual workflow dispatch and tag-trigger release behavior.
- Local evidence exists; unavailable full Actions/container verification is explicit.
Test plan:
- Positive: parse/static inspect workflow; run validation against synthetic `.pkg.tar.zst` if possible; run script failure/usage checks where safe.
- Negative: validation fails if package missing binary or desktop Exec mismatch.
- Manual: no full host installs; if no container/GitHub Actions execution, record waiver.
Dependencies:
- Depends on: none.
- Blocks: final PR/report.
- Can run parallel with: none (small coherent slice).
Executor:
- aad-implementer.

## Dependency graph
- Task 1 -> final owner verification/report/PR.

## Execution ledger
- 2026-06-02: Worktree created from `origin/master` at `/home/kcnc/code/apps/nuclear/.worktrees/release-arch-package` on branch `roadmap/release-arch-package`.
- 2026-06-02: Initial task package and plan created; ready for implementer dispatch.

- 2026-06-02: Implementation complete: added package validation script, wired workflow validation before uploads, documented manual/tag release behavior, recorded local verification.

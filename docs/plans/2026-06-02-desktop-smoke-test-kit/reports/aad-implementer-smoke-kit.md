PI_RESULT: PASS
TASK: Desktop smoke-test kit — Task 1 branch package build wrapper and desktop smoke docs
TASK_PACKAGE: docs/plans/2026-06-02-desktop-smoke-test-kit
REPORT_PATH: docs/plans/2026-06-02-desktop-smoke-test-kit/reports/aad-implementer-smoke-kit.md
PROGRESS_PATH: docs/plans/2026-06-02-desktop-smoke-test-kit/progress/aad-implementer-smoke-kit.md
COMMITS:
- pending: implementation ready for local commit

FILES_CHANGED:
- `.devcontainer/scripts/build-branch-arch-package.sh`: Added safe branch package wrapper that creates ignored repo-local worktrees, validates branch/worktree names, resolves local/origin branch refs, runs frontend build, cargo release build, binary export, Arch package build, and package validation inside the branch worktree.
- `.devcontainer/docs/desktop-smoke-test-kit.md`: Added #8/#7 package build/install/validation/evidence/rollback commands and manual Wayland tray plus MPRIS2/KDE Connect smoke plans.
- `docs/plans/2026-06-02-desktop-smoke-test-kit/README.md`: Created missing task package index.
- `docs/plans/2026-06-02-desktop-smoke-test-kit/plan.md`: Created missing task plan from delegated prompt and recorded execution ledger updates.
- `docs/plans/2026-06-02-desktop-smoke-test-kit/progress/aad-implementer-smoke-kit.md`: Recorded implementation progress and verification milestones.
- `docs/plans/2026-06-02-desktop-smoke-test-kit/reports/aad-implementer-smoke-kit.md`: Added implementation report.

AC_VERIFICATION:
- Script accepts branch names such as `roadmap/wayland-tray-options` and `roadmap/mpris2-now-playing`, creates a repo-local worktree, and runs frontend build, cargo release, export, package build, and package validation in that worktree: script contains validated branch ref resolution, `git worktree add --detach` under `artifacts/branch-arch-package/worktrees/<slug>`, and the exact command sequence `corepack pnpm --filter @nuclearplayer/player build:frontend`, `cargo build --release --manifest-path packages/player/src-tauri/Cargo.toml`, `.devcontainer/scripts/export-linux-binary.sh`, `.devcontainer/scripts/build-arch-package.sh`, `.devcontainer/scripts/validate-arch-package.sh`; `git check-ref-format --branch` passed for both requested branch names — passed by static review; expensive execution intentionally not run.
- Script refuses unsafe branch/worktree names, keeps artifacts inside repo, does not install host packages, and does not remove/prune outside repo: unsafe branch check rejected `../bad`; script validates branch and derived worktree names, enforces repo-local worktree paths, writes under `artifacts/branch-arch-package/worktrees`, has no host package manager install commands, no prune commands, and no `rm -rf`; package helper still uses the existing container workflow — passed by static/negative check.
- Docs include commands to build #8/#7 packages, install via pacman, collect evidence/logs, and rollback: grep found `roadmap/wayland-tray-options`, `roadmap/mpris2-now-playing`, `sudo pacman -U --needed`, `/usr/bin/nuclear-music-player-arch`, validation commands, evidence `tee` commands, and `sudo pacman -Rns arch-nuclear-bin` — passed.
- Test plans cover requested Wayland tray close/minimize/restore/quit/icon behavior and MPRIS2/KDE Connect track/artist/artwork/status/control behavior: docs include a Wayland tray plan for icon, close-to-tray, restore, minimize, restore, quit, and relaunch; docs include MPRIS2/KDE Connect plan for `playerctl` title/artist/artwork/status plus play/pause/next controls and KDE Connect remote behavior — passed by grep/review.

TESTS_RUN:
- `bash -n .devcontainer/scripts/build-branch-arch-package.sh .devcontainer/scripts/export-linux-binary.sh .devcontainer/scripts/build-arch-package.sh .devcontainer/scripts/validate-arch-package.sh`: passed.
- `.devcontainer/scripts/build-branch-arch-package.sh '../bad'` wrapped as an expected-negative check with grep for `unsafe branch name`: passed; unsafe branch rejected before worktree creation.
- `grep -nE 'roadmap/wayland-tray-options|roadmap/mpris2-now-playing|PR #8|PR #7|/usr/bin/nuclear-music-player-arch|validate-arch-package|sudo pacman -U|sudo pacman -Rns arch-nuclear-bin|close|minimize|restore|quit|icon|xesam:title|xesam:artist|mpris:artUrl|playerctl|KDE Connect' .devcontainer/docs/desktop-smoke-test-kit.md`: passed.
- `grep -nE 'git worktree add --detach|corepack pnpm --filter @nuclearplayer/player build:frontend|cargo build --release|export-linux-binary|build-arch-package|validate-arch-package|require_repo_local_path|validate_branch_name|validate_worktree_name|git worktree remove' .devcontainer/scripts/build-branch-arch-package.sh`: passed by review output.
- `grep -nE 'pacman -S|apt-get|dnf|zypper|brew install|docker .*prune|podman .*prune|rm -rf|git worktree prune' .devcontainer/scripts/build-branch-arch-package.sh`: passed as an absence check; no host install/prune/destructive cleanup commands found.
- `git check-ref-format --branch roadmap/wayland-tray-options` and `git check-ref-format --branch roadmap/mpris2-now-playing`: passed.
- Expensive frontend/cargo/package build path: not run per delegated verification scope.

QUALITY_CHECKS:
- Shell syntax/static scripts: `bash -n` for branch wrapper plus referenced package/export/validation scripts — passed.
- Script safety negative check: unsafe branch `../bad` rejected — passed.
- Documentation static review: grep/review for requested branch commands, binary path, validation, install, rollback, and smoke coverage — passed.
- Shellcheck: not run; `shellcheck` is not installed locally.
- Frontend/cargo/package builds: not run; explicitly out of scope for this delegated task.

QUALITY_NOTES:
- Readability/reuse: Wrapper reuses existing export, package build, validation, PKGBUILD, desktop/icon asset workflow; no new dependencies or abstractions beyond local helper functions for validation/path safety.
- Error handling/logging: Script uses `set -euo pipefail` and explicit `fail` messages; no sensitive values logged.
- Backend/API/data: Not relevant; no backend, API, storage, migration, or external integration changes.
- Frontend/UI: Not relevant to implementation; smoke docs cover manual desktop UI behavior only.
- DevOps/runtime: Worktrees and artifacts are confined under ignored repo-local `artifacts/`; wrapper resolves local/origin branch refs, runs packaging through the existing Docker/Podman helper, overlays missing packaging helpers only into the temporary branch worktree when needed, and performs package validation after build.
- Security: No secrets touched; no host package installs added; no prune or destructive outside-repo cleanup commands added; branch/worktree names are constrained before path construction.
- Concurrency/idempotency: Wrapper refuses to reuse an existing branch worktree rather than deleting it; repeated builds require explicit user inspection/removal of the repo-local worktree.
- Compatibility/performance: Existing package scripts are unchanged; wrapper is additive. Expensive commands only run when the user invokes the wrapper, not during verification.

SIDE_FINDINGS:
- Blocking: none.
- Non-blocking follow-up candidates: If PR #7/#8 branches predate package helper files, the wrapper copies the current packaging helpers into the temporary worktree only; owner may later decide whether to merge package helper support into those branches directly.

NOTES: The provided task package path did not exist at startup, so it was created in this worktree from the delegated prompt. No feature code for PR #7/#8 was modified or merged. No host package installs, frontend builds, cargo builds, package builds, or upstream PR operations were run.

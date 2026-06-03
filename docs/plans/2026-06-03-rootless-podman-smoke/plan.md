# Rootless Podman GUI smoke workflow plan

## Intake

User reported manual smoke-test result for PR #8 in Russian:

- Minimize button minimizes, but not only to tray: the app still appears in the open-app/task list.
- Close (X) button does not work/hide/close as expected.
- Therefore PR #8 is partial success and not acceptable to merge as-is.

User request:

1. Record the result in repo-local evidence docs and GitHub comments.
2. Inspect likely Tauri/Wayland tray/window cause areas for later fix without fixing PR #8 now.
3. Implement a separate rootless Podman GUI dev/smoke workflow in a new draft PR.
4. Verify script syntax/statics only; do not run expensive builds or GUI unless safe.
5. Write final findings to `/home/kcnc/code/tools/arch-nuclear-podman-smoke-report.md`.

## Acceptance criteria

- AC1: PR #8 smoke result is recorded in repo-local evidence docs and PR #8 receives a GitHub comment with leave-draft/block-merge decision.
- AC2: Likely #8 cause areas are identified from code/Tauri behavior and recorded as notes, with no broad #8 fix attempted.
- AC3: A rootless Podman workflow exists for building/running/testing Nuclear branches/worktrees with Wayland/session DBus/audio/GPU mounts and no Docker socket dependency.
- AC4: Docs provide simple user commands for running Wayland or MPRIS branches in the container without host pacman installs, plus limitations/security model.
- AC5: Only script/static checks are run; no expensive full build, GUI smoke, host installs, or destructive cleanup.
- AC6: A draft PR is opened against `blockedby/arch-nuclear` `master`; draft CI remains skipped.

## Slice structure

Single implementation slice because the Podman workflow, docs, and repo-local evidence need one coherent branch and one verification story. Root owner keeps GitHub comment/final integration ownership.

## Execution ledger

- 2026-06-03: Root worktree created at `/home/kcnc/code/apps/nuclear/.worktrees/podman-gui-smoke-workflow` on branch `podman-gui-smoke-workflow` from `origin/master`.
- 2026-06-03: Task package created.

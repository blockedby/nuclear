## Task
- Mission: Fix the fork-only Podman GUI runner HOME/cache permission crash, push it to `master`, and update draft PR #8 branch with latest `master`.
- Target: `tools/podman-gui/podman-gui-smoke`, `docs/development/rootless-podman-gui-smoke.md`, `master`, and `roadmap/wayland-tray-options`.
- Boundaries: Did not touch upstream `nukeop`; did not force-push; did not run expensive builds/CI; kept PR #8 draft.
- Done when: Writable runtime HOME/cache works in the container and both fork branches are pushed.
- Expected evidence: syntax/help checks, container mkdir smoke, git/PR refs.

## Context
- Slice: Podman HOME/cache permission fix.
- Task package: `docs/plans/2026-06-03-podman-home-cache-fix`.
- Worktree: `/home/kcnc/code/apps/nuclear` on `master`; PR branch worktree `/home/kcnc/code/apps/nuclear/.worktrees/roadmap-wayland-tray-options`.

## Spec compliance
- Writable HOME/cache for Corepack/Cargo: done.
  - Evidence: `tools/podman-gui/podman-gui-smoke` now creates a host `mktemp` runtime HOME, pre-creates `.cache/node/corepack`, `.cargo`, `.config`, `.local/share`, and mounts it as `--volume "$runtime_home:/tmp/arch-nuclear-home:rw"`.
- Read-only desktop integration mounts still work: done.
  - Evidence: existing GTK/KDE/Kvantum/icon/font/theme mounts still route through `add_read_only_mount_if_present`, which emits `:ro`, under `/tmp/arch-nuclear-home`.
- PR #8 updated with latest master and kept draft: done.
  - Evidence: `gh pr view 8 --repo blockedby/arch-nuclear --json ...` showed `isDraft:true`, `state:OPEN`, `headRefName:roadmap/wayland-tray-options`, `baseRefName:master`, `headRefOid:1987bb64a7f84559fb8edf4905825e2a01eb1551`.
- Avoid upstream `nukeop`: done.
  - Evidence: only pushed to `origin` (`blockedby/arch-nuclear`); no upstream push commands run.

## Acceptance verification
- AC1: Runner uses host-created writable HOME at `/tmp/arch-nuclear-home`.
  - Covered by: static implementation review and container smoke.
  - Result: passed.
  - Evidence: `tools/podman-gui/podman-gui-smoke`; `tools/podman-gui/podman-gui-smoke run -- bash -lc 'id; mkdir -p "$HOME/.cache/node/corepack/v1"; test -w "$HOME/.cache/node/corepack/v1"'` printed `uid=1000(kcnc) gid=1000(kcnc) groups=1000(kcnc)`.
- AC2: Runner remains syntactically valid and help works.
  - Covered by: `bash -n tools/podman-gui/podman-gui-smoke`; `tools/podman-gui/podman-gui-smoke --help`.
  - Result: passed.
- AC3: PR #8 branch contains latest master without force push and remains draft.
  - Covered by: merge/push output and PR metadata.
  - Result: passed.
  - Evidence: normal push `f4e1531b..1987bb64 roadmap/wayland-tray-options -> roadmap/wayland-tray-options`; PR metadata above.

## System readiness
- Runtime wiring: ready for the requested smoke path.
- Config/env/secrets: no secrets touched; env behavior preserved except explicit writable runtime HOME.
- Permissions/access: rootless `--userns keep-id` behavior preserved; writable HOME fixed; read-only desktop mounts preserved.
- CI/deployment/database/frontend/API: not relevant for this shell/docs fix.

## Verification run
- Local targeted checks on `master`: passed.
  - `bash -n tools/podman-gui/podman-gui-smoke`
  - `tools/podman-gui/podman-gui-smoke --help >/tmp/podman-gui-help-owner.txt`
  - `tools/podman-gui/podman-gui-smoke run -- bash -lc 'id; mkdir -p "$HOME/.cache/node/corepack/v1"; test -w "$HOME/.cache/node/corepack/v1"'`
- Local targeted checks on PR #8 worktree after merge: passed.
  - Same three commands, from `.worktrees/roadmap-wayland-tray-options`.
- Git/remote checks: passed.
  - `origin/master` at `c4bb32adc013ed11631aad2382d764655e2a166c`.
  - `origin/roadmap-wayland-tray-options` at `1987bb64a7f84559fb8edf4905825e2a01eb1551`.
- Remote CI: not checked/none required; PR #8 remains draft and user requested lightweight checks.

## Issues
### Issue R-01: Podman-created HOME parent blocked Corepack cache mkdir
- Description: Read-only nested desktop mounts under `/tmp/arch-nuclear-home` could leave the container HOME parent unsuitable for user-writable cache creation.
- Evidence: reported crash `EACCES mkdir /tmp/arch-nuclear-home/.cache/node/corepack/v1`.
- Resolution: Pre-create and mount a writable host runtime HOME to `/tmp/arch-nuclear-home` before nested read-only desktop mounts; verified Corepack cache mkdir path.

## Side findings
- Blocking findings folded into active work: R-01.
- Non-blocking findings tracked separately: none. A possible future no-TTY mode for automated Podman checks was noted but not needed for this goal.

## Verdict
- Status: success.
- Goal state: fully achieved.
- Final readiness: ready for user to build/run PR #8 with the updated Podman GUI runner.
- Summary: `master` has the runtime HOME fix, and draft PR #8 branch has been normally merged with latest `master` and pushed.

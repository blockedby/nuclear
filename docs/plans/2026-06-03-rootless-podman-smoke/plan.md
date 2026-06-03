# Rootless Podman GUI smoke workflow plan

## Task intake

Goal: add a repo-local, rootless Podman workflow that lets maintainers build/run/smoke branches such as `roadmap/wayland-tray-options` and `roadmap/mpris2-now-playing` without installing Arch/Tauri GUI dependencies on the host, and record the manual PR #8 Wayland tray smoke result.

In scope:
- Arch-based Containerfile/Podmanfile with Node/pnpm/Rust/Tauri dependencies plus WebKit/AppIndicator/GStreamer/playerctl/DBus tools.
- Rootless Podman scripts that mount the current repo/worktree and forward Wayland, session DBus, XDG runtime, PipeWire/Pulse, and `/dev/dri` where present without Docker/docker.sock.
- Docs with short commands for arbitrary branches/worktrees, explicit examples for PR #8 and MPRIS work, limitations, and security model.
- Repo-local PR #8 evidence and likely cause areas for later fix; no product-code fix in this slice.
- Static-only verification and draft PR to `blockedby/arch-nuclear` `master`.

Out of scope / do-not-touch:
- Do not fix PR #8 behavior in product code.
- Do not install host packages; no `pacman`, `sudo`, destructive cleanup, Docker socket, full builds, Tauri bundles, or GUI smoke runs.
- Do not open upstream PRs or mark draft PR ready.

Done-state:
- Workflow/docs/evidence/task-package artifacts committed on `podman-gui-smoke-workflow`, pushed, and covered by static verification; draft PR URL reported.

Blocking unknowns:
- None for static workflow creation. Runtime correctness remains manual because this slice intentionally does not build images or run GUI apps.

## Repo orientation

Project shape:
- pnpm/Turborepo monorepo with main Tauri app under `packages/player` and Rust backend under `packages/player/src-tauri`.
- Existing root guidance says Arch/Wayland fork, draft PRs by default, no expensive CI or host package installs for WIP.
- Existing `.devcontainer/Dockerfile` is a devcontainer only; no rootless Podman GUI branch-smoke workflow exists.

Likely files/areas:
- Add container files under a dedicated repo-local tooling area, e.g. `tools/podman-gui/`.
- Add scripts under `scripts/` or `tools/podman-gui/`.
- Add docs under `docs/development/` or task package docs.
- Update task package files under `docs/plans/2026-06-03-rootless-podman-smoke/`.

Verification commands:
- `bash -n <scripts>`
- static grep/review for Docker socket avoidance, rootless Podman command examples, Wayland/DBus/audio/GPU mounts, PR #8 block-merge language.
- `podman --help` only if already available; do not install or run image/GUI.

## Reuse discovery

Existing references/patterns:
- Root README development section documents prerequisites and draft PR convention.
- PR #8 (`roadmap/wayland-tray-options`) body says it added settings, window close/minimize hooks, and a Tauri tray menu, but had no live Wayland smoke coverage.
- `packages/player/src-tauri/Cargo.lock` includes `libappindicator` / `tray-icon`, indicating Tauri tray/AppIndicator runtime dependency relevance.
- Existing task packages under `docs/plans/` use concise plan/README/report artifacts.

Likely PR #8 cause areas to record:
- Close-request event handling path may not be intercepting/preventing default close under the tested Wayland/Tauri runtime.
- Minimize-to-tray may call window minimize semantics rather than hide semantics, leaving compositor task-list presence.
- Hide vs minimize semantics and taskbar/app-list visibility differ under Wayland/KDE/GNOME and need compositor-specific validation.
- Tray/AppIndicator availability and status-notifier host behavior may affect whether a hidden window is recoverable.

## Missing pieces list

- Arch-based `Containerfile`/`Podmanfile` for GUI/Tauri dev smoke dependencies.
- Rootless Podman wrapper script(s) for `shell`, `dev`, `build-ish/check`, and arbitrary command execution against the mounted current checkout.
- Documentation with exact commands, branch/worktree guidance, limitations/security model, and no-host-install promise.
- PR #8 smoke evidence report with decision: partial success, leave draft/block merge.
- Verification evidence file and slice owner report.
- Draft PR creation/update.

## Plan tasks

### Task 1: Rootless Podman GUI smoke workflow files

Goal:
- Maintainers can build an Arch-based rootless Podman image and run shell/dev/check commands against any checked-out branch/worktree with GUI/session mounts prepared.

Boundary:
- System area: developer tooling/runtime workflow.
- Primary verification: shell syntax and static content review only.

Existing pattern / reuse:
- Root README development commands; Tauri/Linux dependency guidance from repo context; no Docker socket patterns.

Missing change:
- Add dedicated Containerfile/Podmanfile and wrapper scripts.

Scope / likely files:
- `tools/podman-gui/Containerfile`
- `tools/podman-gui/Podmanfile` or symlink/copy equivalent
- `tools/podman-gui/podman-gui-smoke`
- optional `tools/podman-gui/README.md`

Acceptance criteria:
- Arch image installs Node/pnpm/Rust/Tauri Linux deps, WebKit, AppIndicator/status notifier, GStreamer, playerctl, DBus/audio tools.
- Wrapper uses rootless `podman`, mounts current worktree, Wayland socket, session DBus, XDG runtime, PipeWire/Pulse as available, and `/dev/dri` when present; does not require Docker/docker.sock.
- Provides shell/dev/check/arbitrary command entry points for current branch/worktree.

Test plan:
- Positive: `bash -n tools/podman-gui/podman-gui-smoke`; static grep for expected mounts/packages/subcommands.
- Negative: grep confirms no `docker.sock` or Docker requirement.
- Manual: image build and GUI smoke explicitly skipped in this slice.

Dependencies:
- Depends on: none.
- Blocks: Task 2, final verification.
- Can run parallel with: Task 3.

Executor:
- `aad-implementer`.

### Task 2: Developer docs and user commands

Goal:
- User has exact short commands for smoke-testing PR #8/MPRIS/arbitrary branches in rootless Podman without host pacman installs.

Boundary:
- System area: repo documentation.
- Primary verification: static doc review/grep.

Existing pattern / reuse:
- Root README development and PR policy sections.

Missing change:
- Add a concise docs page and link/reference it from the task package/report.

Scope / likely files:
- `docs/development/rootless-podman-gui-smoke.md` or `tools/podman-gui/README.md`
- task package README/report links.

Acceptance criteria:
- Includes commands for `roadmap/wayland-tray-options`, `roadmap/mpris2-now-playing`, and arbitrary branch/worktree usage.
- Includes limitations/security model: rootless container, host GUI sockets exposed, no Docker socket, no host package installs, generated caches/target dirs on mounted checkout, Wayland/compositor behavior still requires manual observation.

Test plan:
- Positive: grep/static review for branch names, `podman`, `--branch`, limitations/security text.
- Manual: not run.

Dependencies:
- Depends on: Task 1.
- Blocks: final verification.
- Can run parallel with: none after Task 1.

Executor:
- `aad-implementer`.

### Task 3: PR #8 evidence and cause-area notes

Goal:
- PR #8 local evidence documents the user's smoke result and blocks merge while preserving likely cause areas for a future fix.

Boundary:
- System area: task-package evidence/docs only.
- Primary verification: static review and PR metadata/comment if owner handles GitHub.

Existing pattern / reuse:
- PR #8 body and reported manual smoke result.

Missing change:
- Write `reports/wayland-tray-pr8-smoke.md` with partial-success decision and likely cause areas; optionally comment on PR #8 if within owner scope.

Scope / likely files:
- `docs/plans/2026-06-03-rootless-podman-smoke/reports/wayland-tray-pr8-smoke.md`
- possible GitHub PR #8 comment via `gh`.

Acceptance criteria:
- Evidence states minimize partially works but remains in task/open-app list; close X does not hide/close as expected; PR #8 stays draft/block merge.
- Cause areas recorded without product code changes.

Test plan:
- Positive: grep/static review for partial success/block merge/cause areas.
- Manual: source is user's manual smoke report.

Dependencies:
- Depends on: none.
- Blocks: final report.
- Can run parallel with: Task 1.

Executor:
- slice owner or `aad-implementer`; owner may handle GitHub comment.

## Dependency graph / execution waves

- Wave 1: Task 1 and Task 3 can run in parallel.
- Wave 2: Task 2 after Task 1.
- Wave 3: owner integrates, runs static verification, updates plan/report/verification, commits, pushes, opens/updates draft PR.

## Execution ledger

- 2026-06-03: Root worktree already exists at `/home/kcnc/code/apps/nuclear/.worktrees/podman-gui-smoke-workflow` on branch `podman-gui-smoke-workflow` from `origin/master`; no new worktree created.
- 2026-06-03: Task package exists; plan expanded and marked ready for implementation dispatch.
- 2026-06-03: Implementer delegation was unavailable due current subagent nesting limit, so slice owner completed tooling/docs/evidence directly within the delegated worktree.
- 2026-06-03: Static verification passed and recorded in `verification/local.md`.
- 2026-06-03: Committed `a16c019e` (`Add rootless Podman GUI smoke workflow`), pushed branch, and opened draft PR <https://github.com/blockedby/arch-nuclear/pull/12>.

# Podman HOME/cache permission fix plan

## Task intake
- Goal: Fix fork-only rootless Podman GUI runner crash on PR #8 caused by `EACCES mkdir /tmp/arch-nuclear-home/.cache/node/corepack/v1` after read-only desktop integration mounts.
- In scope: small safe change on `master` to ensure container `HOME`/cache paths are writable while read-only desktop theme mounts under HOME still work; merge/update PR #8 branch `roadmap/wayland-tray-options` with latest `master`; keep PR #8 draft; avoid force-push if possible; push changes.
- Out of scope: upstream `nukeop`, production packaging, GUI behavior redesign, expensive CI/builds.
- Done-state: master has runner fix pushed to `origin/master`; PR #8 branch contains latest master via normal merge and is pushed; lightweight checks recorded.
- Blocking unknowns: whether local Podman image exists and supports quick container command. If not, record static evidence and blocker/waiver.

## Repo orientation
- Repo uses `master` as fork target branch.
- Target runner: `tools/podman-gui/podman-gui-smoke`.
- Existing docs: `docs/development/rootless-podman-gui-smoke.md`.
- Relevant existing behavior: script sets `HOME=/tmp/arch-nuclear-home`, mounts read-only desktop files under that path, then creates only `/tmp/arch-nuclear-home` inside container setup.
- Verification commands: `bash -n tools/podman-gui/podman-gui-smoke`; `tools/podman-gui/podman-gui-smoke --help`; quick `podman-gui-smoke run -- ...` command that prints `id` and `mkdir -p "$HOME/.cache/node/corepack/v1"` if image is available.

## Reuse discovery
- Follow existing script helpers: `podman_mount_args`, `add_read_only_mount_if_present`, `run_container`.
- Preserve read-only theme/icon/font mounts and existing `--userns keep-id`/`--security-opt label=disable` model.
- Use host-side temp/runtime directory pattern rather than relying on Podman to materialize nested HOME parents.

## Missing pieces
- Host-created writable runtime HOME/cache directory.
- Podman volume mount mapping that directory to `/tmp/arch-nuclear-home` before read-only nested theme mounts.
- Setup cleanup/safety that keeps the runtime HOME writable and avoids deleting user data.
- Documentation note explaining writable runtime HOME/cache.
- Merge latest `master` into PR #8 branch and push.

## Plan tasks

### Task 1: Make Podman runner HOME/cache writable
Goal:
- Container commands can write `HOME/.cache/node/corepack/v1` and Cargo paths even when read-only desktop integration mounts exist under HOME.
Boundary:
- System area: `tools/podman-gui` shell runner and docs.
- Primary verification: shell syntax/help plus quick container mkdir check if image exists.
Existing pattern / reuse:
- Reuse current `podman_mount_args`, existing HOME path, and read-only mount helpers.
Missing change:
- Pre-create a host runtime HOME directory and mount it writable to `/tmp/arch-nuclear-home` before nested read-only desktop mounts.
Scope / likely files:
- `tools/podman-gui/podman-gui-smoke`
- `docs/development/rootless-podman-gui-smoke.md`
- task package verification/report files
Acceptance criteria:
- Runner mounts a host-created writable HOME to `/tmp/arch-nuclear-home`.
- Corepack cache mkdir succeeds inside container or, if the image is unavailable, the exact command attempted and failure reason are recorded.
- Existing read-only theme/icon/font mounts remain read-only under the container HOME.
Test plan:
- Positive: `bash -n tools/podman-gui/podman-gui-smoke`; `tools/podman-gui/podman-gui-smoke --help`.
- Positive/manual container: `tools/podman-gui/podman-gui-smoke run -- bash -lc 'id; mkdir -p "$HOME/.cache/node/corepack/v1"; test -w "$HOME/.cache/node/corepack/v1"'`.
- Negative/static: grep confirms theme mounts still use `:ro` and no docker.sock/upstream writes.
Dependencies:
- Depends on: none.
- Blocks: Task 2.
Executor:
- aad-implementer.

### Task 2: Update PR #8 branch with fixed master
Goal:
- PR #8 branch `roadmap/wayland-tray-options` contains latest `master` including Task 1, remains draft, and is pushed without force if possible.
Boundary:
- System area: git branch integration only.
- Primary verification: git refs/PR metadata and branch push output.
Acceptance criteria:
- `origin/master` includes fix commit.
- Local branch `roadmap/wayland-tray-options` merges latest master and pushes normally to origin.
- `gh pr view 8` shows draft/open against `master` from `roadmap/wayland-tray-options`.
Test plan:
- `git log --oneline -n` on master and PR branch.
- `gh pr view 8 --repo blockedby/arch-nuclear --json isDraft,state,headRefName,baseRefName,url`.
Dependencies:
- Depends on: Task 1.
Executor:
- aad-slice-owner after implementer report.

## Dependency graph
- Wave 1: Task 1 by aad-implementer.
- Wave 2: owner reviews/commits/pushes master, then merges master into PR #8 branch and pushes.
- Wave 3: final verification/report.

## Execution ledger
- 2026-06-03: Plan created on master. Task 1 ready for implementer dispatch.
- 2026-06-03: Task 1 implementation completed locally by aad-implementer; report at `reports/aad-implementer-podman-home.md`, verification at `verification/local.md`.

# Local verification

Date: 2026-06-03
Worktree: `/home/kcnc/code/apps/nuclear/.worktrees/podman-gui-smoke-workflow`
Branch: `podman-gui-smoke-workflow`

## Commands run

- `bash -n tools/podman-gui/podman-gui-smoke`
  - Result: passed.
  - Evidence: no syntax output/errors.

- `tools/podman-gui/podman-gui-smoke --help >/tmp/podman-gui-help.txt`
  - Result: passed.
  - Evidence: help text renders without requiring Podman/image execution.

- `! grep -R -n -E -- '--volume .*docker\.sock|/var/run/docker\.sock:' tools/podman-gui docs/development/rootless-podman-gui-smoke.md`
  - Result: passed.
  - Evidence: no Docker socket mount/requirement pattern found.

- `grep -R "roadmap/wayland-tray-options\|roadmap/mpris2-now-playing\|Wayland\|DBUS_SESSION_BUS_ADDRESS\|/dev/dri\|libappindicator\|GStreamer\|block merge\|not acceptable to merge" -n tools/podman-gui docs/development/rootless-podman-gui-smoke.md docs/plans/2026-06-03-rootless-podman-smoke/reports/wayland-tray-pr8-smoke.md`
  - Result: passed.
  - Evidence: matched expected branch command examples, GUI/session mount variables, package/runtime terms, and PR #8 block-merge language.

- `podman --help | head -5`
  - Result: passed; Podman is available on PATH.
  - Evidence excerpt:

```text
Manage pods, containers and images

Usage:
  podman [options] [command]
```

## Intentionally skipped checks

- `tools/podman-gui/podman-gui-smoke build-image`
  - Reason: user explicitly requested static verification only; image builds use network/package downloads and are more expensive.

- `tools/podman-gui/podman-gui-smoke dev ...` / GUI smoke
  - Reason: user explicitly requested no full builds/GUIs unless explicitly safe; this slice records workflow/docs only.

- `pnpm build`, `tauri build`, release/package builds
  - Reason: out of scope and expensive for a dev/smoke workflow docs/tooling branch.

- Host installs (`pacman`, `sudo`, etc.)
  - Reason: prohibited by task scope.

## Acceptance mapping

- AC1 repo-local PR #8 smoke result/evidence exists and blocks merge: passed by `reports/wayland-tray-pr8-smoke.md` static grep and PR #8 comment <https://github.com/blockedby/arch-nuclear/pull/8#issuecomment-4611414806>.
- AC2 likely #8 cause areas are recorded: passed by `reports/wayland-tray-pr8-smoke.md` cause-area notes.
- AC3 rootless Podman workflow files exist and are clear enough for branch smoke: passed by `tools/podman-gui/Containerfile`, `tools/podman-gui/Podmanfile`, `tools/podman-gui/podman-gui-smoke`, script syntax, and static grep.
- AC4 docs include exact short user commands and limitations/security model: passed by `docs/development/rootless-podman-gui-smoke.md`.
- AC5 static verification run and recorded: passed by this file.
- AC6 draft PR URL produced: passed; draft PR <https://github.com/blockedby/arch-nuclear/pull/12> opened against `master`.

## 2026-06-03 root review safety hardening re-check

Scope: remove the Podman `:Z` relabel suffix from the mounted repo checkout and document that the workflow does not relabel the host checkout by default.

Commands run from `/home/kcnc/code/apps/nuclear/.worktrees/podman-gui-smoke-workflow` on branch `podman-gui-smoke-workflow`:

- `bash -n tools/podman-gui/podman-gui-smoke`
  - Result: passed.
- `tools/podman-gui/podman-gui-smoke --help >/tmp/podman-gui-help.txt`
  - Result: passed.
- `! grep -R -n -E -- '--volume .*docker\.sock|/var/run/docker\.sock:' tools/podman-gui docs/development/rootless-podman-gui-smoke.md`
  - Result: passed; no Docker socket mount references found.
- `grep -nF 'args+=(--volume "$REPO_ROOT:$WORKSPACE")' tools/podman-gui/podman-gui-smoke`
  - Result: passed; repo mount now appears without `:Z`/`:z` at line 48.
- `grep -nF 'does not relabel the host checkout by default' docs/development/rootless-podman-gui-smoke.md`
  - Result: passed; no-relabel default is documented at line 89.
- `! grep -nE 'REPO_ROOT:\$WORKSPACE:(Z|z)' tools/podman-gui/podman-gui-smoke`
  - Result: passed; repo checkout mount no longer uses Podman relabel suffixes.

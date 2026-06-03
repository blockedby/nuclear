# Rootless Podman GUI smoke workflow

- Status: pushed; draft PR open
- Owner: aad-slice-owner
- Implementation slice: Podman GUI dev/smoke workflow
- Branch: podman-gui-smoke-workflow
- Worktree: /home/kcnc/code/apps/nuclear/.worktrees/podman-gui-smoke-workflow
- PR: https://github.com/blockedby/arch-nuclear/pull/12

## User commands

```bash
tools/podman-gui/podman-gui-smoke build-image
tools/podman-gui/podman-gui-smoke dev --branch roadmap/wayland-tray-options
tools/podman-gui/podman-gui-smoke dev --branch roadmap/mpris2-now-playing
tools/podman-gui/podman-gui-smoke shell --repo /path/to/other/worktree
tools/podman-gui/podman-gui-smoke run -- pnpm --filter @nuclearplayer/player test
```

## Report index

- Plan: [plan.md](plan.md)
- Developer docs: [../../../development/rootless-podman-gui-smoke.md](../../../development/rootless-podman-gui-smoke.md)
- Slice owner report: [reports/slice-owner-podman.md](reports/slice-owner-podman.md)
- PR #8 tray smoke evidence: [reports/wayland-tray-pr8-smoke.md](reports/wayland-tray-pr8-smoke.md)
- Verification: [verification/local.md](verification/local.md)

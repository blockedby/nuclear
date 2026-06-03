# Root owner verification

Date: 2026-06-03
Worktree: `/home/kcnc/code/apps/nuclear/.worktrees/podman-gui-smoke-workflow`
Branch: `podman-gui-smoke-workflow`

## Fresh root checks

Commands run after slice integration and the SELinux/relabel hardening follow-up:

```bash
cd /home/kcnc/code/apps/nuclear/.worktrees/podman-gui-smoke-workflow
bash -n tools/podman-gui/podman-gui-smoke
tools/podman-gui/podman-gui-smoke --help >/tmp/root-podman-gui-help-2.txt
! grep -R -n -E -- '--volume .*docker\.sock|/var/run/docker\.sock:|\$REPO_ROOT:\$WORKSPACE:[Zz]|\$REPO_ROOT:\$WORKSPACE.*:[Zz]' tools/podman-gui docs/development/rootless-podman-gui-smoke.md
grep -R "does not relabel the host checkout by default\|roadmap/wayland-tray-options\|roadmap/mpris2-now-playing\|DBUS_SESSION_BUS_ADDRESS\|/dev/dri\|not acceptable to merge" -n tools/podman-gui docs/development/rootless-podman-gui-smoke.md docs/plans/2026-06-03-rootless-podman-smoke/reports/wayland-tray-pr8-smoke.md
gh pr view 12 --repo blockedby/arch-nuclear --json isDraft,baseRefName,headRefName,url,statusCheckRollup
```

Results:

- Script syntax: passed.
- Help rendering without Podman image execution: passed.
- No Docker socket mount/requirement pattern: passed.
- Repo checkout mount does not use `:Z`/`:z` relabel suffix: passed.
- Required docs/evidence terms and branch examples present: passed.
- PR #12: open draft, base `master`, head `podman-gui-smoke-workflow`.
- PR #12 checks: `ci` and `production-build` are skipped because the PR is draft.

## Intentionally skipped

- Podman image build: skipped by user request because it downloads/builds packages.
- GUI app smoke: skipped by user request and because this pass is static tooling/docs only.
- Full `pnpm build`, `tauri build`, release packaging: skipped as expensive/out of scope.
- Host installs or cleanup: not performed.

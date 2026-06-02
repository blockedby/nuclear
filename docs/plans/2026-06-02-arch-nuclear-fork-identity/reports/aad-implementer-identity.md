## Task
- Mission: Implement fork identity, Arch package rename, binary rename, docs, and release workflow changes.
- Target: README, `.devcontainer` Arch packaging files, and `.github/workflows/release-arch-package.yml`.
- Boundaries: No upstream PR, no MPRIS2 implementation, no host package installs, no app-id/user-data rename.
- Done when: Fork identity and package release paths are updated and locally verifiable.
- Expected evidence: Syntax checks, package smoke build, contents inspection.

## Context
- Slice: Arch Nuclear fork identity and release packaging
- Task package: `docs/plans/2026-06-02-arch-nuclear-fork-identity`
- Worktree: `/home/kcnc/code/apps/nuclear/.worktrees/arch-nuclear-identity`
- Branch: `arch-nuclear-identity`

## Spec compliance
- README fork notice: done; `README.md` names `blockedby/arch-nuclear`, Arch-first package, Wayland/app-id direction, binary path, GitHub Releases-only artifacts, and no-upstream-PR policy.
- Arch package rename/binary rename: done; `PKGBUILD` uses `arch-nuclear-bin` and installs `nuclear-music-player-arch`.
- Desktop Exec in package: done; `PKGBUILD` patches packaged desktop file to `Exec=nuclear-music-player-arch %u` while keeping icon/app metadata sane.
- Docs/scripts: done; `.devcontainer` docs/scripts reference renamed binary/package.
- Release workflow: done; `.github/workflows/release-arch-package.yml` builds plain binary, runs Arch package helper, uploads workflow artifacts, and uploads release assets on tags.

## Acceptance verification
- Covered by: `verification/slice-local.md` owner/local verification.
- Result: passed for syntax/string/package smoke checks.

## System readiness
- Runtime/deployment wiring: minimal GitHub Actions workflow added; actual CI run requires pushed tag or manual workflow dispatch.

## Verification run
- `bash -n .devcontainer/scripts/build-arch-package.sh`: passed.
- `bash -n .devcontainer/scripts/export-linux-binary.sh`: passed.
- Workflow required wiring string check: passed.
- PKGBUILD required identity string check: passed.
- Container package smoke build using repo-local smoke executable: passed; artifact `artifacts/arch-package-smoke/packages/arch-nuclear-bin-1.39.0-1-x86_64.pkg.tar.zst` inspected.

## Issues
- None.

## Verdict
- Status: success
- Goal state: implementation complete pending owner commit/push.
- Final readiness: ready for owner verification/commit/push.

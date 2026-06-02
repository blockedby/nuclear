## Task
- Mission: Implement and verify scoped repo/package identity changes for the maintained Arch/Wayland fork.
- Target: README, Arch package helper/docs, release workflow, task package evidence.
- Boundaries: No upstream PRs, no full MPRIS2 work, no host package installs, no destructive cleanup, no app-id/user-data rename.
- Done when: Fork identity/package changes are committed and pushed to `origin arch-nuclear-identity` with local verification evidence.
- Expected evidence: Syntax checks, package smoke build/contents inspection, commit SHA, push status.

## Context
- Thread: User wants the fork maintained as `blockedby/arch-nuclear`.
- Slice: Arch Nuclear fork identity and release packaging.
- Task name: Arch Nuclear fork identity and release packaging.
- Task package: `docs/plans/2026-06-02-arch-nuclear-fork-identity`.
- Report path: `docs/plans/2026-06-02-arch-nuclear-fork-identity/reports/slice-owner.md`.
- Worktree: `/home/kcnc/code/apps/nuclear/.worktrees/arch-nuclear-identity`.
- Branch: `arch-nuclear-identity`.
- Verify scope: fork notice, package identity, renamed binary, release workflow, local package smoke build.

## Spec compliance
- README fork notice and policy: done.
  - Evidence: `README.md` names `blockedby/arch-nuclear`, `arch-nuclear-bin`, `/usr/bin/nuclear-music-player-arch`, GitHub Releases-only artifacts, Wayland/app-id direction, and no-upstream-PR policy.
- PKGBUILD renamed package/binary: done.
  - Evidence: `.devcontainer/arch-package/PKGBUILD` uses `pkgname=arch-nuclear-bin`, installs `/usr/bin/nuclear-music-player-arch`, provides the renamed command, conflicts with upstream-style packages, and installs license under `/usr/share/licenses/arch-nuclear-bin/LICENSE`.
- Packaged desktop Exec: done.
  - Evidence: PKGBUILD patches `Exec=nuclear-music-player-arch %u`, `Icon=com.nuclearplayer`, and `StartupWMClass=com.nuclearplayer` without globally renaming app metadata.
- Scripts/docs: done.
  - Evidence: `.devcontainer/scripts/build-arch-package.sh`, `.devcontainer/scripts/export-linux-binary.sh`, `.devcontainer/docs/arch-linux-package.md`, and `.devcontainer/docs/arch-linux-binary-artifact.md` document/use the renamed artifact.
- Minimal release workflow: done.
  - Evidence: `.github/workflows/release-arch-package.yml` builds the plain Linux binary, exports `nuclear-music-player-arch`, builds `arch-nuclear-bin` in the Arch container, uploads workflow artifacts, and uploads release assets on `arch-nuclear@*.*.*` tags.

## Acceptance verification
- AC: README says this is `blockedby/arch-nuclear`, explains Arch-first package, Wayland tray/app-id fixes, binary path, GitHub Releases-only artifacts, and upstream no-code-contributions/no-upstream-PR policy.
  - Covered by: file inspection/string presence in `README.md`.
  - Result: passed.
  - Evidence: committed README changes.
- AC: PKGBUILD installs `/usr/bin/nuclear-music-player-arch`; package artifact name is fork-specific; license path/provides/conflicts are sane.
  - Covered by: PKGBUILD string check and package contents inspection.
  - Result: passed.
  - Evidence: `verification/slice-local.md`; smoke artifact `artifacts/arch-package-smoke/packages/arch-nuclear-bin-1.39.0-1-x86_64.pkg.tar.zst`.
- AC: Desktop `Exec` in packaged file points to renamed binary; icon/app metadata remains sane.
  - Covered by: extracted packaged desktop file inspection.
  - Result: passed.
  - Evidence: `tar -xOf ... com.nuclearplayer.desktop | grep -F 'Exec=nuclear-music-player-arch %u'` passed.
- AC: Rebuild commands/docs point to renamed binary/package.
  - Covered by: file inspection of `.devcontainer` docs/scripts.
  - Result: passed.
  - Evidence: committed docs/scripts.
- AC: Minimal GHA workflow exists for Arch package artifact generation/upload.
  - Covered by: workflow file inspection/string check.
  - Result: passed locally; not run in CI because it requires tag/manual workflow execution.
  - Evidence: `.github/workflows/release-arch-package.yml` and verification string check.
- AC: Local verification evidence includes `bash -n`, package build or feasible limitation, package contents inspection, and git push evidence.
  - Covered by: `verification/slice-local.md`.
  - Result: passed.
  - Evidence: bash syntax checks passed; container package smoke build passed; contents inspected; initial push to origin succeeded.

## System readiness
- Routes / registration: not relevant.
- Services / APIs: not relevant.
- Config / env / secrets: done for workflow definition; actual release upload uses standard `GITHUB_TOKEN` permissions.
- Permissions / access: done; `contents: write` set for release asset upload.
- Database / migrations: not relevant.
- Frontend-backend integration: not relevant.
- Runtime / deployment wiring: ready for tag/manual workflow execution; no upstream push/PR performed.

## Verification run
- Local / targeted checks:
  - `bash -n .devcontainer/scripts/build-arch-package.sh`: passed.
  - `bash -n .devcontainer/scripts/export-linux-binary.sh`: passed.
  - Release workflow required wiring string check: passed.
  - PKGBUILD identity string check: passed.
  - Container package smoke build with repo-local executable: passed.
    - Evidence: `arch-nuclear-bin-1.39.0-1-x86_64.pkg.tar.zst` created under `artifacts/arch-package-smoke/packages/` and inspected.
- Local / full checks:
  - Full monorepo test/lint/build: not run; change scope is docs/scripts/workflow/package metadata and targeted checks covered acceptance.
- Remote checks / CI:
  - Status: not checked; no PR opened, and workflow requires tag/manual dispatch.
  - Evidence: branch pushed to origin; final pushed commit `49fc0be7212bb41aebccf274b4367cb09a19b753`.

## Issues
- No `R-*`, `F-*`, or `U-*` issues required for this slice. Existing follow-up GitHub issues from root owner remain: #1 Wayland tray, #2 MPRIS2/KDE Connect, #3 release workflow, #4 identity cleanup.

## Side findings
- Blocking findings folded into active work: none.
- Non-blocking findings tracked separately: existing root issues #1-#4.

## Verdict
- Status: success.
- Goal state: fully achieved for the scoped implementation slice.
- Final readiness: ready for root owner integration/next decision; no upstream PR opened.
- Summary: Fork identity, Arch package naming/binary Exec, docs, and release workflow were implemented, locally smoke-verified, committed, and pushed to `origin arch-nuclear-identity` at `49fc0be7212bb41aebccf274b4367cb09a19b753`.

## Next-agent brief
- Objective: If continuing, root owner may inspect pushed branch and decide whether to open a same-repo PR or merge per policy.
- Target: branch `arch-nuclear-identity` on `https://github.com/blockedby/arch-nuclear`.
- Settled already: package name `arch-nuclear-bin`; binary `/usr/bin/nuclear-music-player-arch`; release workflow tag prefix `arch-nuclear@*.*.*`.
- Boundaries: no upstream PRs; MPRIS2 remains issue #2.
- Verification target: optional manual dispatch/tag CI run for `.github/workflows/release-arch-package.yml`.
- Expected output: root-level branch/merge decision.

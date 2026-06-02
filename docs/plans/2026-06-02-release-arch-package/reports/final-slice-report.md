## Task
- Mission: Implement and verify issue #3 release workflow/package CI for Arch `.pkg.tar.zst` artifacts.
- Target: `.github/workflows/release-arch-package.yml`, `.devcontainer/scripts/validate-arch-package.sh`, `.devcontainer/docs/arch-linux-package.md`.
- Boundaries: no upstream/nukeop PR, no merge, no host installs/destructive cleanup, no AUR/pacman repository publishing.
- Done when: branch pushed, PR opened to `blockedby/arch-nuclear:master`, package validation evidence recorded.
- Expected evidence: PR URL, commits, local package validation/static checks, explicit gaps.

## Context
- Thread: Arch Nuclear roadmap separate PRs.
- Slice: release workflow/package CI PR (#3).
- Task name: Arch Nuclear release workflow/package CI PR (#3).
- Task package: `docs/plans/2026-06-02-release-arch-package`.
- Report path: `docs/plans/2026-06-02-release-arch-package/reports/final-slice-report.md`.
- Worktree: `/home/kcnc/code/apps/nuclear/.worktrees/release-arch-package`.
- Branch: `roadmap/release-arch-package`.
- PR: https://github.com/blockedby/arch-nuclear/pull/5.
- Verify scope: workflow/package validation and docs.

## Spec compliance
- Requirement / AC: Workflow syntax and action versions are sane for the repo.
  - Status: done.
  - Evidence: workflow uses `actions/checkout@v4`, `actions/setup-node@v4`, `pnpm/action-setup@v4`, `actions/upload-artifact@v4`, `softprops/action-gh-release@v2`; script syntax check passed.
  - Gap if any: no local full GitHub Actions run.
- Requirement / AC: CI package validation checks verify package binary and desktop Exec names.
  - Status: done.
  - Evidence: `.devcontainer/scripts/validate-arch-package.sh` checks `usr/bin/nuclear-music-player-arch`, `usr/share/applications/com.nuclearplayer.desktop`, and `Exec=nuclear-music-player-arch %u`; workflow runs it after package build.
  - Gap if any: real container build not run locally.
- Requirement / AC: Artifact/release asset names are predictable and include `.pkg.tar.zst`.
  - Status: done.
  - Evidence: workflow upload/release paths include `artifacts/arch-package/packages/*.pkg.tar.zst`; artifact bundle name is `arch-nuclear-linux-artifacts`.
  - Gap if any: none.
- Requirement / AC: Package documentation/manual trigger behavior is documented.
  - Status: done.
  - Evidence: `.devcontainer/docs/arch-linux-package.md` documents `workflow_dispatch` and `arch-nuclear@*.*.*` tag release behavior.
  - Gap if any: none.

## Acceptance verification
- AC1: Workflow syntax/action versions are sane for repo.
  - Covered by: static workflow inspection and `bash -n` on scripts.
  - Result: passed.
  - Evidence: `docs/plans/2026-06-02-release-arch-package/verification/local.md`.
- AC2: Package validation checks verify binary and desktop Exec names.
  - Covered by: synthetic `.pkg.tar.zst` positive/negative checks.
  - Result: passed.
  - Evidence: good package validated; bad package with `Exec=nuclear-music-player %u` failed as expected.
- AC3: Artifact/release asset names include `.pkg.tar.zst`.
  - Covered by: workflow grep/static check.
  - Result: passed.
  - Evidence: `artifacts/arch-package/packages/*.pkg.tar.zst` in upload and release files lists.
- AC4: Local evidence exists and gaps are explicit.
  - Covered by: verification artifact.
  - Result: passed with explicit limitation.
  - Evidence: full GitHub Actions and real container package build listed as not run locally.

## System readiness
- Routes / registration: not relevant.
- Services / APIs: not relevant.
- Config / env / secrets: done; no secrets added.
- Permissions / access: done; workflow retains `contents: write` for release assets.
- Database / migrations: not relevant.
- Frontend-backend integration: not relevant.
- Runtime / deployment wiring: done; validation wired before artifact upload/release attachment.

## Verification run
- Local / targeted checks:
  - Synthetic valid `.pkg.tar.zst` validation: passed.
  - Synthetic wrong-desktop-Exec package validation: failed as expected.
  - Static workflow/docs grep checks: passed.
  - `bash -n .devcontainer/scripts/validate-arch-package.sh .devcontainer/scripts/build-arch-package.sh .devcontainer/scripts/export-linux-binary.sh`: passed.
- Local / full checks:
  - Full GitHub Actions/container package build: not run locally; explicit gap.
- Remote checks / CI:
  - PR state: open, ready for review, merge state clean.
  - Evidence: `gh pr view 5 --json ...` returned `state=OPEN`, `isDraft=false`, `mergeStateStatus=CLEAN`, `statusCheckRollup=[]`.

## Issues
### Issue R-01: Release workflow lacked package-content validation
- Description: Existing release workflow uploaded package artifacts without checking the built package contents.
- Evidence: no validation step after `.devcontainer/scripts/build-arch-package.sh` before upload/release.
- Resolution: added `.devcontainer/scripts/validate-arch-package.sh` and workflow validation step.
- Depends on: none.

## Side findings
- Blocking findings folded into active work: R-01.
- Non-blocking findings tracked separately: none.

## Verdict
- Status: success.
- Goal state: fully achieved within local/PR scope.
- Final readiness: ready except explicit limitation that full GitHub Actions/container package build awaits PR/manual workflow execution.
- Summary: PR #5 implements issue #3 workflow validation and package release docs for `blockedby/arch-nuclear` only.

## Next-agent brief
- Objective: Review/merge PR #5 when desired; do not merge from this slice.
- Target: https://github.com/blockedby/arch-nuclear/pull/5.
- Settled already: validation script and workflow wiring are implemented and locally checked.
- Boundaries: no upstream/nukeop PR, no AUR/pacman repo publishing.
- Verification target: optionally run the GitHub workflow manually or on an `arch-nuclear@*.*.*` tag to prove full container build/release asset path.
- Expected output: merge decision or CI/manual workflow evidence.

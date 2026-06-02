## Task
- Mission: Implement release workflow/package validation for Arch package issue #3.
- Target: `.github/workflows/release-arch-package.yml`, `.devcontainer/scripts/validate-arch-package.sh`, `.devcontainer/docs/arch-linux-package.md`.
- Boundaries: no upstream PR, no merge, no host installs/destructive cleanup, no AUR/pacman repo publishing.
- Done when: workflow validates `.pkg.tar.zst` package contents before upload/release and docs explain manual/tag behavior.
- Expected evidence: local static checks and package validation positive/negative checks.

## Context
- Thread: Arch Nuclear roadmap issue #3.
- Slice: release workflow/package CI.
- Task name: Arch Nuclear release workflow/package CI PR (#3).
- Task package: `docs/plans/2026-06-02-release-arch-package`.
- Report path: `docs/plans/2026-06-02-release-arch-package/reports/aad-implementer-release-workflow.md`.
- Worktree: `/home/kcnc/code/apps/nuclear/.worktrees/release-arch-package`.
- Branch: `roadmap/release-arch-package`.
- Verify scope: workflow/package validation and docs.

## Spec compliance
- Requirement / AC: Workflow syntax and action versions are sane for repo.
  - Status: done.
  - Evidence: workflow uses stable `actions/checkout@v4`, `actions/setup-node@v4`, `pnpm/action-setup@v4`, `actions/upload-artifact@v4`, `softprops/action-gh-release@v2`; `bash -n` passed for scripts.
  - Gap if any: no local GitHub Actions run.
- Requirement / AC: CI package validation checks verify package binary and desktop Exec names.
  - Status: done.
  - Evidence: `.devcontainer/scripts/validate-arch-package.sh` checks every `*.pkg.tar.zst` for `usr/bin/nuclear-music-player-arch`, `usr/share/applications/com.nuclearplayer.desktop`, and `Exec=nuclear-music-player-arch %u`; workflow runs it after package build.
  - Gap if any: real package build not run locally.
- Requirement / AC: Artifact/release asset names are predictable and include `.pkg.tar.zst`.
  - Status: done.
  - Evidence: workflow upload/release paths include `artifacts/arch-package/packages/*.pkg.tar.zst`; docs explain artifact name `arch-nuclear-linux-artifacts` and tag release assets.
  - Gap if any: none.
- Requirement / AC: Package documentation/manual trigger behavior documented.
  - Status: done.
  - Evidence: `.devcontainer/docs/arch-linux-package.md` now documents `workflow_dispatch` and `arch-nuclear@*.*.*` tag behavior.
  - Gap if any: none.

## Acceptance verification
- AC1: Workflow syntax/action versions are sane for repo and upload predictable `.pkg.tar.zst` artifacts.
  - Covered by: static grep checks and action version review.
  - Result: passed.
  - Evidence: `docs/plans/2026-06-02-release-arch-package/verification/local.md`.
- AC2: Package validation checks binary path and desktop Exec in built package contents.
  - Covered by: synthetic package positive/negative checks.
  - Result: passed.
  - Evidence: validation accepted package with expected binary/Exec and rejected package with wrong Exec.
- AC3: Docs state manual `workflow_dispatch` and tag-trigger release behavior.
  - Covered by: static docs grep checks.
  - Result: passed.
  - Evidence: `grep -q 'workflow_dispatch' ...` and `grep -q 'arch-nuclear@\*\.\*\.\*' ...` passed.
- AC4: Local evidence exists; unavailable full Actions/container verification is explicit.
  - Covered by: verification note.
  - Result: passed with explicit limitation.
  - Evidence: `verification/local.md` lists full GitHub Actions and real container package build as not run.

## System readiness
- Routes / registration: not relevant.
- Services / APIs: not relevant.
- Config / env / secrets: done; no secrets added, existing optional env overrides preserved.
- Permissions / access: done; workflow retains `contents: write` for release assets.
- Database / migrations: not relevant.
- Frontend-backend integration: not relevant.
- Runtime / deployment wiring: done; validation step is wired before artifact upload/release asset attachment.

## Verification run
- Local / targeted checks:
  - Synthetic `.pkg.tar.zst` positive validation: passed.
  - Synthetic wrong desktop Exec negative validation: passed (failed as expected).
  - Static workflow/docs greps: passed.
  - `bash -n` for package scripts: passed.
- Local / full checks:
  - Full app build/package build: not run; outside narrow workflow validation and would require container build/runtime.
- Remote checks / CI:
  - Status: not checked yet before final push of implementation commit.

## Issues
### Issue R-01: Missing package-content validation in release workflow
- Description: Existing workflow built/uploaded package artifacts without verifying package contents.
- Evidence: no validation step after `.devcontainer/scripts/build-arch-package.sh` before upload/release.
- Resolution: added `.devcontainer/scripts/validate-arch-package.sh` and workflow step.
- Depends on: none.

## Side findings
- Blocking findings folded into active work: R-01.
- Non-blocking findings tracked separately: none.

## Verdict
- Status: success.
- Goal state: achieved for local implementation scope.
- Final readiness: ready except explicit limitation that real GitHub Actions/container package build was not run locally.
- Summary: Workflow now validates Arch package contents before upload/release and docs describe manual/tag release behavior.

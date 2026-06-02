## Task
- Mission: Convert roadmap PRs #5-#8 to draft and update PR #9 with draft-CI gating plus PR CI simplification.
- Target: `blockedby/arch-nuclear`, PRs #5-#9, `.github/workflows/ci.yml`.
- Boundaries: No upstream PRs, no merge, no host installs/destructive cleanup.

## Spec compliance
- PR #5-#8 draft conversion: done. `gh pr ready --undo` succeeded for #5, #6, #7, #8; follow-up `gh pr view` shows all four open draft PRs.
- PR #9 branch update: done. Branch `draft-pr-ci-gating` pushed at `86c10b1fa47af23c8356341ffc102dbf804d67e0`; PR #9 remains draft.
- PR CI simplification: done. Ordinary `ci` job no longer runs `pnpm build`/`tauri build`; it runs lint, tests, type-check, player frontend build, cargo check, and cargo test.
- Full build availability: done. Added manual-only `production-build` job in CI and release workflows remain available.

## Acceptance verification
- AC1: Draft PRs do not run CI.
  - Covered by: `.github/workflows/ci.yml` job condition `github.event_name != 'pull_request' || github.event.pull_request.draft == false` and PR event types excluding draft open events.
  - Result: passed.
- AC2: Ordinary PR CI avoids full production bundle/signing.
  - Covered by: static workflow assertion; ordinary `ci` job contains no `pnpm build` or `tauri build`.
  - Result: passed.
- AC3: PR-appropriate checks run.
  - Covered by: static workflow assertion for `pnpm lint`, `pnpm test`, `pnpm type-check`, `pnpm --filter @nuclearplayer/player build:frontend`, `cargo check`, and `cargo test`.
  - Result: passed.
- AC4: Full production builds remain available.
  - Covered by: manual `production-build` job gated to `workflow_dispatch`, plus release workflow inspection (`release-player.yml` Tauri action; `release-arch-package.yml` manual/tag release build path).
  - Result: passed.

## Verification run
- Local/static: `python` YAML/policy assertion passed: `owner verification passed`.
- GitHub/remote: `git ls-remote origin refs/heads/draft-pr-ci-gating` confirms `86c10b1fa47af23c8356341ffc102dbf804d67e0`; `gh pr view 9` confirms draft/open.
- Broad local lint/test/build: not run; change is workflow-only and verification scope was static workflow syntax/command/condition inspection. The new PR CI is intended to run these commands remotely when PR #9 is marked ready.

## Issues
- R-01: Roadmap PR CI churn reduced by draft conversion.
  - Evidence: PRs #5, #6, #7, #8 are open drafts.
  - Resolution: converted each with `gh pr ready --undo`.
- R-02: Ordinary PR full Tauri bundle removed from CI.
  - Evidence: `.github/workflows/ci.yml` ordinary `ci` job contains PR-safe checks only; `pnpm build` appears only in manual `production-build`.
  - Resolution: workflow updated and pushed.

## Verdict
- Status: success.
- Goal state: fully achieved.
- Final readiness: ready for draft PR review; no merge performed.

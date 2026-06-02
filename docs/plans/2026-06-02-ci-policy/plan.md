# CI policy and draft PR gating plan

## Task intake
- Goal: keep roadmap PRs draft and update PR #9 so CI skips draft PRs and ordinary PR CI avoids expensive full Tauri production bundles.
- In scope: `.github/workflows/ci.yml`, PR #5-#8 draft conversion, commit/push to `draft-pr-ci-gating`, final policy recommendation.
- Out of scope: upstream PRs, merging, destructive cleanup, host installs, release workflow rewrites beyond minimal preservation/manual trigger if useful.
- Done state: PR #9 remains draft, branch pushed, YAML statics verified, report written to `/home/kcnc/code/tools/arch-nuclear-ci-policy-report.md`.
- Blocking unknowns: exact package build targets; discovered scripts show root `pnpm build` runs Tauri via player package, while `@nuclearplayer/player` has `build:frontend` for PR frontend-only build.

## Repo orientation
- Repo root guidance read: `AGENTS.md`, `README.md`; nearest child guidance for active worktree read: `.worktrees/draft-pr-ci-gating/AGENTS.md`.
- CI file: `.github/workflows/ci.yml` currently runs on push/pull_request/workflow_dispatch and gates draft PRs with job-level `if`.
- Current costly command: `pnpm build`, which runs `turbo build`; `packages/player/package.json` build is `tsc && vite build && tauri build`.
- PR-appropriate commands: `pnpm lint`, `pnpm test`, `pnpm type-check`, `pnpm --filter @nuclearplayer/player build:frontend`, and Rust `cargo check`/`cargo test` in `packages/player/src-tauri`.
- Release/manual full builds: release workflows exist (`release-player.yml`, `release-arch-package.yml`, etc.); CI has `workflow_dispatch` available.

## Reuse discovery
- Existing draft gating pattern is already in PR #9: pull_request types omit draft open events and job `if` skips draft PRs.
- Existing setup/caching steps in `ci.yml` install Node/pnpm/Rust, pnpm store cache, Cargo cache, and Tauri Linux dependencies.
- Existing frontend-only script: `packages/player/package.json` `build:frontend`.

## Missing pieces
- Replace ordinary CI `pnpm build` with type-check + frontend build + Rust checks/tests.
- Keep optional/manual full production bundle path without making ordinary PRs run it.
- Verify YAML parses/statics and push branch.

## Plan tasks

### Task 1: CI policy workflow update
Goal:
- Make ordinary PR CI run lint, tests, type-check, player frontend build, and Rust cargo check/test without running Tauri bundle.

Boundary:
- System area: GitHub Actions CI config.
- Primary verification: static YAML parse/inspection and changed command list.

Existing pattern / reuse:
- Reuse current `ci.yml` setup/caches and draft gating.
- Reuse `packages/player` `build:frontend` script and Rust commands from repo guidance.

Missing change:
- Split PR checks from manual full build using conditional steps/jobs.

Scope / likely files:
- `.github/workflows/ci.yml`.
- Task package report/verification files.

Acceptance criteria:
- Draft PRs do not run CI job.
- Ordinary PR CI does not run `pnpm build` or `tauri build`.
- Ordinary PR CI runs lint, tests, type-check, player frontend build, cargo check, and cargo test.
- Full production build remains available via release workflows and/or manual CI dispatch.

Test plan:
- Positive: parse workflow YAML; inspect commands/conditions; optionally run a local YAML parser.
- Negative: confirm PR path has no full Tauri bundle command.
- Manual: report policy recommendation and trigger path.

Dependencies:
- Depends on: none.
- Blocks: final verification/report.
- Can run parallel with: none.

Executor:
- aad-implementer.

## Dependency graph
- Wave 1: Task 1.
- Wave 2: owner final verification, push, PR/report update.

## Execution ledger
- PR #5-#8 converted to draft successfully on 2026-06-02 via `gh pr ready --undo`.

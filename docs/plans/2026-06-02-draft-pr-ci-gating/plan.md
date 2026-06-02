# Draft PR CI gating plan

## Task intake
- Goal: make repo process create future PRs as draft by default and prevent expensive GitHub Actions jobs from running for draft PRs.
- In scope: GitHub Actions PR trigger/job gating and README/process docs for exact `gh pr create --draft` convention.
- Out of scope: release/tag behavior changes, host installs, destructive cleanup, opening PRs against upstream `nukeop/nuclear`.
- Done state: minimal workflow/doc change committed, pushed to `blockedby/arch-nuclear`, draft PR opened against `master`, verification recorded.
- Blocking unknowns: exact existing workflow trigger patterns need inspection.

## Repo orientation
- Repo root guidance read: `AGENTS.md`, `README.md`. No relevant child `AGENTS.md` outside existing `.worktrees`.
- Likely files: `.github/workflows/*.yml`, `README.md`.
- Relevant checks: YAML parse/lint via Ruby/Python if available; `git diff`; `gh pr create/view`.

## Reuse discovery
- Existing workflows under `.github/workflows/`; preserve non-PR triggers (`push` tags, `workflow_dispatch`, schedules) and release workflows.
- Existing README has Arch Nuclear fork and Development sections suitable for process convention.

## Missing pieces
- Identify PR-triggered workflows/jobs.
- Add job-level draft gating where PRs can invoke expensive jobs.
- Prefer not to remove `synchronize` for normal CI unless evidence supports a safe expensive workflow exception.
- Document draft PR command/convention and ready-for-review command.

## Plan tasks
### Task 1: Gate PR-triggered CI and document draft convention
Goal:
- Draft PRs do not run expensive Actions jobs; ready/non-draft PRs and manual/release triggers still work.
Boundary:
- System area: GitHub Actions process/config docs.
- Primary verification: workflow trigger/job inspection plus YAML parse.
Existing pattern / reuse:
- Existing workflow structure in `.github/workflows`; README Development section.
Missing change:
- Minimal job `if` draft gate and README commands.
Scope / likely files:
- `.github/workflows/*.yml`, `README.md`.
Acceptance criteria:
- Future PR convention says to use `gh pr create --draft --base master --repo blockedby/arch-nuclear ...`.
- PR workflows skip jobs when `github.event.pull_request.draft == true`.
- Jobs run for `ready_for_review`, opened/reopened non-draft PRs, and manual/release/tag events.
- Release/tag workflows are not broken.
Test plan:
- Positive: inspect changed workflow triggers/if expressions; parse YAML syntax.
- Negative: confirm no PR/remote points to `nukeop/nuclear`; ensure push/tag/manual triggers unchanged.
- Manual: open this branch as a draft PR to demonstrate convention.
Dependencies:
- Depends on: none.
- Blocks: final report.
- Can run parallel with: none.
Executor:
- slice owner directly (small config/doc change; no sub-slice needed).

## Dependency graph
- Stays whole under one slice owner; direct execution is cheaper than delegation.

## Execution ledger
- Created worktree `.worktrees/draft-pr-ci-gating` from `origin/master`.
- Initial task package created.

## Verification evidence
- Local YAML syntax: passed via `python3`/PyYAML on `.github/workflows/*.yml`. See `verification/local.md`.
- Workflow scope inspection: passed; only CI/Coverage PR workflows changed, release/tag/manual workflows preserved.
- Documentation: README now records draft PR creation and ready-for-review commands for `blockedby/arch-nuclear` / `master`.

## Tradeoffs recorded
- Kept `synchronize` for CI and Coverage so ready PR pushes still run automatically. Draft gating avoids CI on work-in-progress pushes; excluding `synchronize` entirely would also skip CI on ready PR updates, which is riskier for normal review.
- Added `workflow_dispatch` to CI and Coverage so manual runs remain available.
- Release/tag workflows were left unchanged because they are not PR-triggered.

## Final done-state
- Status: success.
- PR: https://github.com/blockedby/arch-nuclear/pull/9 (draft, base `master`, repo `blockedby/arch-nuclear`).
- Head commit: `8f3e6c26e42c6f212712e72628f51ea9fff95955` before metadata-only task package update; latest branch commit may include this plan/README status update.
- Remote status: `gh pr view` reports `isDraft: true`, `state: OPEN`, and empty `statusCheckRollup`, consistent with draft PR jobs being skipped/not required at creation time.
- Issues: none blocking; no follow-up issue needed.

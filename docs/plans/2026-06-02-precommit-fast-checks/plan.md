# Plan: economical pre-commit fast checks

## Task intake
- Goal: add/repair a scoped Husky pre-commit setup for blockedby/arch-nuclear so economical staged-file checks run before commits.
- In scope: inspect existing Husky/lint-staged config, ensure `.husky/pre-commit` invokes local repo tooling via pnpm/lint-staged, keep lint-staged focused on staged JS/TS files, document enablement and optional pre-push/manual checks.
- Out of scope: full `pnpm test`, `pnpm build`, cargo compilation, host/global installs, destructive cleanup, upstream nukeop/nuclear PRs, merging.
- Done-state: branch pushed and draft PR opened against `blockedby/arch-nuclear:master`; report includes PR URL, branch/commit, exact hook checks, enablement, verification, and optional pre-push policy.
- Blocking unknowns: whether local dependencies are already installed; if not, verification must document command limitation without installing globally.

## Repo orientation
- Repo: pnpm/Turborepo monorepo, current branch base `origin/master`, remote origin `https://github.com/blockedby/arch-nuclear.git`.
- Existing package tooling: root `package.json` has `prepare: husky`, dev dependencies `husky` and `lint-staged`, and lint-staged config for `*.{ts,tsx,js,jsx}` -> `eslint --fix`.
- Existing hook: `.husky/pre-commit` currently contains `npx lint-staged`, which can use brittle/global-ish npx resolution and does not align with pnpm-local tooling.
- Formatting config exists (`prettier.config.js`, `.prettierignore`) but no root format script was found in the initial package.json inspection.
- Verification commands: `pnpm exec lint-staged --debug` (manual hook command), `pnpm exec lint-staged --help`, `git diff --check`; avoid full build/test for this small config-only change.

## Reuse discovery
- Reuse Husky v9 `prepare: husky` setup already in root `package.json`.
- Reuse root `lint-staged` config rather than adding a second config file.
- Reuse local package-manager execution (`pnpm exec`) to avoid global dependencies.

## Missing pieces
- Replace `.husky/pre-commit` command with a pnpm-local lint-staged invocation.
- Add concise developer docs explaining hook enablement and economical policy.
- Optionally add a manual/pre-push script if it does not force heavy checks into commits.
- Verify hook command syntax and, if feasible, run lint-staged manually.

## Ownership model
- Slice stays whole: one config/docs boundary and one verification story.
- Implementation can be delegated as one `aad-implementer` task.

## Plan tasks

### Task 1: Economical pre-commit hook and docs
Goal:
- Make local pre-commit run staged-file lint-staged checks via repo-local pnpm tooling and document the policy.

Boundary:
- System area: developer tooling / Git hooks.
- Primary verification: manual hook command and syntax/config checks.

Existing pattern / reuse:
- Root `package.json` `prepare: husky`, `lint-staged` config, `.husky/pre-commit`.

Missing change:
- Update `.husky/pre-commit`; add minimal docs and optional script only if useful.

Scope / likely files:
- `.husky/pre-commit`
- `package.json`
- `README.md` or a focused docs file
- task package reports/verification files

Acceptance criteria:
- AC1: `.husky/pre-commit` uses repo-local pnpm/lint-staged, not `npx` or global dependencies.
- AC2: Default pre-commit checks are staged-file-only and fast; no full `pnpm test`, `pnpm build`, `pnpm lint`, or cargo compile runs on commit.
- AC3: Documentation states how hooks are installed/enabled and what checks run.
- AC4: Hook command syntax/config is verified locally or limitation is documented if dependencies are unavailable.
- AC5: Draft PR targets `blockedby/arch-nuclear:master`, not upstream.

Test plan:
- Positive: run `pnpm exec lint-staged --help`; run `pnpm exec lint-staged --debug` with current staged changes if feasible; inspect `.husky/pre-commit` and `package.json`.
- Negative: confirm hook does not include full test/build/cargo commands or global `npx`.
- Manual: confirm draft PR base/head with `gh pr view`.

Dependencies:
- Depends on: none.
- Blocks: final owner verification/report.
- Can run parallel with: none.

Executor:
- aad-implementer

Status:
- Implementation complete in local worktree; pending owner acceptance/PR handling.

## Execution ledger
- 2026-06-02: Slice owner created worktree `/home/kcnc/code/apps/nuclear/.worktrees/precommit-fast-checks` on branch `precommit-fast-checks` from `origin/master`.
- 2026-06-02: Initial plan ready; implementation task pending dispatch.
- 2026-06-02: Implementer changed `.husky/pre-commit` from `npx lint-staged` to `pnpm exec lint-staged`, documented hook installation/check policy in `README.md`, and wrote local verification evidence to `verification/local.md`.
- 2026-06-02: Verification limitation: `pnpm exec lint-staged --help` and `--debug` could not run because `pnpm` is unavailable in PATH; static shell/config checks passed and no global tools were installed.

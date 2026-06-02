PI_RESULT: PASS
TASK: CI policy and draft PR gating
TASK_PACKAGE: docs/plans/2026-06-02-ci-policy
REPORT_PATH: docs/plans/2026-06-02-ci-policy/reports/aad-implementer-ci-policy.md
PROGRESS_PATH: docs/plans/2026-06-02-ci-policy/progress/aad-implementer-ci-policy.md
COMMITS:
- 33173b2c: Adjust PR CI gating
- 5ecc5926: Record CI policy implementation evidence
FILES_CHANGED:
- `.github/workflows/ci.yml`: replaced ordinary CI `pnpm build` with PR-safe lint/test/type-check/player frontend build/Rust check/Rust test steps; added manual-only `production-build` job for `pnpm build`.
- `docs/plans/2026-06-02-ci-policy/plan.md`: updated execution ledger with implemented workflow policy and verification artifact pointer.
- `docs/plans/2026-06-02-ci-policy/progress/aad-implementer-ci-policy.md`: recorded inspection, RED/GREEN checks, and final check progress.
- `docs/plans/2026-06-02-ci-policy/verification/local.md`: recorded static YAML policy assertions and command/condition inspection evidence.
- `docs/plans/2026-06-02-ci-policy/reports/aad-implementer-ci-policy.md`: final implementation evidence.
AC_VERIFICATION:
- AC1 Draft PRs do not run the CI job: `.github/workflows/ci.yml` `ci` job keeps `if: github.event_name != 'pull_request' || github.event.pull_request.draft == false`; Python static policy assertion passed — passed.
- AC2 Ordinary PR CI does not run `pnpm build` or Tauri production bundle/signing commands: Python assertion over the ordinary `ci` job run commands found no `pnpm build` or `tauri build`; grep shows `pnpm build` only in manual `production-build` — passed.
- AC3 Ordinary PR CI runs lint, tests, type-check, player frontend build, and Rust checks/tests: Python assertion found `pnpm lint`, `pnpm test`, `pnpm type-check`, `pnpm --filter @nuclearplayer/player build:frontend`, `cargo check`, and `cargo test` in the ordinary `ci` job — passed.
- AC4 Full production build remains available via release workflows and/or manual CI dispatch: `.github/workflows/ci.yml` has `production-build` gated by `github.event_name == 'workflow_dispatch'` with `pnpm build`; grep also confirmed `release-player.yml` uses `tauri-apps/tauri-action@v0` and `release-arch-package.yml` keeps manual/tag release build paths — passed.
TESTS_RUN:
- `python - <<'PY' ... static workflow policy assertions ... PY`: failed before implementation with `AssertionError: ordinary ci contains forbidden command: pnpm build`; passed after implementation with `workflow policy assertions passed`.
- `grep -R -n -E 'workflow_dispatch|draft == false|pnpm build|tauri-action|cargo build --release|build:frontend|cargo check|cargo test' .github/workflows/ci.yml .github/workflows/release-player.yml .github/workflows/release-arch-package.yml`: passed as static command/condition inspection evidence.
QUALITY_CHECKS:
- YAML static parse: passed via PyYAML load in the policy assertion command.
- CI policy static assertions: passed; verified ordinary `ci` command set, draft guard, forbidden production-build commands, and manual full-build gate.
- Broad package lint/type/build/test commands: not run; delegated verify scope was static workflow syntax/command/condition inspection only.
QUALITY_NOTES:
- Readability/reuse: preserved existing setup-node, pnpm, Rust, cache, system dependency, and install steps; used existing `@nuclearplayer/player` `build:frontend` script.
- Error handling/logging: not relevant; no runtime error handling or logging changed.
- Backend/API/data: not relevant; no backend API, storage, migration, or persisted data changes.
- Frontend/UI: not relevant; no browser-visible UI changed.
- DevOps/runtime: CI-only change; ordinary PR path now avoids expensive Tauri production bundles while manual/release full-build paths remain explicit.
- Security: removed signing secret exposure from the ordinary `ci` job; secrets remain only on manual production build/release paths. No secrets or private values were logged or committed.
- Concurrency/idempotency: preserved existing workflow concurrency settings; no deployment/runtime write behavior changed.
- Compatibility/performance: PR CI keeps coverage-relevant checks and should reduce ordinary PR runtime by avoiding full Tauri bundling; release/manual production build compatibility preserved.
SIDE_FINDINGS:
- Blocking: none.
- Non-blocking follow-up candidates: consider CI follow-up after remote run if GitHub Actions reveals platform/package cache specifics not visible in static local checks.
NOTES: Implementation evidence only; owner/auditor should make the final acceptance decision. Final stdout will include the local commit SHA after commit.

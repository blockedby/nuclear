## Task
- Mission: Implement rootless Podman GUI dev/smoke tooling and record PR #8 Wayland tray smoke evidence.
- Target: `tools/podman-gui/`, `docs/development/rootless-podman-gui-smoke.md`, and task package `docs/plans/2026-06-03-rootless-podman-smoke/`.
- Boundaries: no PR #8 product-code fix, no host installs, no Docker socket, no image build, no GUI run, no full Tauri/production build, draft PR only.
- Done when: repo-local evidence/tooling/docs are committed, static verification is recorded, branch is pushed, and draft PR exists against `blockedby/arch-nuclear` `master`.
- Expected evidence: files changed, static command results, PR #8 comment, draft PR URL.

## Context
- Thread: User manually smoke-tested PR #8 and requested evidence plus a separate rootless Podman workflow.
- Slice: Rootless Podman GUI dev/smoke workflow + repo-local PR #8 evidence notes.
- Task name: Rootless Podman GUI smoke workflow.
- Task package: `docs/plans/2026-06-03-rootless-podman-smoke`.
- Report path: `docs/plans/2026-06-03-rootless-podman-smoke/reports/slice-owner-podman.md`.
- Worktree: `/home/kcnc/code/apps/nuclear/.worktrees/podman-gui-smoke-workflow`.
- Branch: `podman-gui-smoke-workflow`.
- Verify scope: script syntax/static docs review only.
- Review target: new dev tooling/docs/evidence, not app runtime behavior.

## Spec compliance
- AC1 PR #8 smoke result/evidence exists and blocks merge.
  - Status: done.
  - Evidence: `reports/wayland-tray-pr8-smoke.md`; PR #8 comment <https://github.com/blockedby/arch-nuclear/pull/8#issuecomment-4611414806>.
  - Gap if any: none for recording; PR #8 behavior itself remains unresolved outside this slice.
- AC2 likely #8 cause areas are recorded for follow-up.
  - Status: done.
  - Evidence: `reports/wayland-tray-pr8-smoke.md` lists close-request interception, minimize-vs-hide, Wayland task-list visibility, tray/status-notifier behavior, settings sync.
  - Gap if any: no fix attempted by design.
- AC3 rootless Podman workflow files exist and are clear enough for branch smoke.
  - Status: done.
  - Evidence: `tools/podman-gui/Containerfile`, `tools/podman-gui/Podmanfile`, `tools/podman-gui/podman-gui-smoke`.
  - Gap if any: runtime image/GUI execution intentionally unverified.
- AC4 docs include exact short commands and limitations/security model.
  - Status: done.
  - Evidence: `docs/development/rootless-podman-gui-smoke.md` and task package README.
  - Gap if any: none.
- AC5 static verification run and recorded.
  - Status: done.
  - Evidence: `verification/local.md`.
  - Gap if any: runtime checks skipped by scope.
- AC6 draft PR URL produced.
  - Status: pending until push/PR step completes.
  - Evidence: pending.
  - Gap if any: owner still must commit/push/create draft PR.

## Acceptance verification
- AC1: repo-local PR #8 smoke result/evidence exists and blocks merge.
  - Covered by: static report review + GitHub PR comment.
  - Result: passed.
  - Evidence: `reports/wayland-tray-pr8-smoke.md`; <https://github.com/blockedby/arch-nuclear/pull/8#issuecomment-4611414806>.
- AC2: likely #8 cause areas are recorded.
  - Covered by: static report review.
  - Result: passed.
  - Evidence: `reports/wayland-tray-pr8-smoke.md`.
- AC3: rootless Podman workflow files exist.
  - Covered by: file presence, script syntax, static grep.
  - Result: passed.
  - Evidence: `verification/local.md`.
- AC4: docs include commands and security/limitations.
  - Covered by: static grep/review.
  - Result: passed.
  - Evidence: `docs/development/rootless-podman-gui-smoke.md`; `verification/local.md`.
- AC5: static verification recorded.
  - Covered by: local verification file.
  - Result: passed.
  - Evidence: `verification/local.md`.
- AC6: draft PR URL produced.
  - Covered by: pending `gh pr create/view` after push.
  - Result: not run yet.
  - Evidence: pending.

## System readiness
- Routes / registration: not relevant.
- Services / APIs: not relevant.
- Config / env / secrets: done for docs/tooling; no secrets used.
- Permissions / access: done for documented rootless Podman socket/device exposure; GUI sockets are explicit security limitation.
- Database / migrations: not relevant.
- Frontend-backend integration: not relevant.
- Runtime / deployment wiring: ready for manual use as a dev/smoke workflow, except image build/GUI run intentionally not validated here.

## Verification run
- Local / targeted checks:
  - `bash -n tools/podman-gui/podman-gui-smoke`: passed.
  - `tools/podman-gui/podman-gui-smoke --help >/tmp/podman-gui-help.txt`: passed.
  - Docker socket mount grep: passed, no mount pattern found.
  - Required-content grep: passed, expected branch examples/mount variables/package terms/block-merge text found.
  - `podman --help | head -5`: passed; Podman present.
- Local / full checks:
  - `pnpm build` / `tauri build` / GUI run: not run; explicitly out of scope/unsafe-expensive for this static workflow slice.
- Remote checks / CI:
  - Status: not available before branch push/PR.

## Issues
### Issue R-01: Missing rootless Podman GUI smoke workflow
- Description: repository did not have a Podman-only branch smoke workflow for Arch/Tauri GUI dependencies.
- Evidence: only existing container-like file was `.devcontainer/Dockerfile`; no `tools/podman-gui` workflow existed.
- Resolution: added Arch-based Containerfile/Podmanfile, rootless wrapper script, and developer docs.
- Depends on: none.

### Issue R-02: PR #8 smoke evidence was not repo-local or on PR
- Description: user's live smoke result needed to block PR #8 merge.
- Evidence: task intake reported minimize partial success and close X failure.
- Resolution: added repo-local evidence report and commented on PR #8.
- Depends on: none.

### Issue U-01: PR #8 close/minimize-to-tray behavior remains broken
- Description: PR #8 behavior is partial/not mergeable: minimize leaves app in task/open-app list; close X does not hide/close as expected.
- Evidence: `reports/wayland-tray-pr8-smoke.md`; PR #8 comment.
- Why unresolved: fixing PR #8 product behavior is explicitly out of scope for this Podman workflow slice.
- Needed next: dedicated PR #8 fix pass with live Wayland smoke using the new workflow or host environment.
- Depends on: future implementation slice.

## Side findings
- Blocking findings folded into active work: PR #8 evidence recording handled as R-02.
- Non-blocking findings tracked separately: none created; PR #8 remains the existing tracking artifact for the tray fix.

## Verdict
- Status: partial until PR creation; local implementation/verification complete.
- Goal state: tooling/docs/evidence achieved locally; branch publication pending.
- Final readiness: ready for commit/push/draft PR, with runtime image/GUI validation explicitly deferred.
- Summary: Rootless Podman workflow and PR #8 evidence are in place with static verification; final PR publication remains.

## Next-agent brief
- Objective: commit, push `podman-gui-smoke-workflow`, open/update draft PR to `blockedby/arch-nuclear` `master`, then update this report with PR URL/commit.
- Target: current worktree/branch only.
- Settled already: no product-code changes; static verification only; PR #8 remains draft/block merge.
- Boundaries: do not mark PR ready, do not run expensive builds/GUI, do not open upstream PRs.
- Verification target: `git status`, commit hash, `gh pr view/create` draft URL.
- Expected output: final report with PR URL, commit, files changed.

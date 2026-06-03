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
  - Status: done.
  - Evidence: draft PR <https://github.com/blockedby/arch-nuclear/pull/12>; pushed branch `podman-gui-smoke-workflow`.
  - Gap if any: none.

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
  - Covered by: `gh pr create` / `gh pr view` after push.
  - Result: passed.
  - Evidence: draft PR <https://github.com/blockedby/arch-nuclear/pull/12>; `gh pr view 12 --json url,isDraft,state,headRefName,baseRefName` showed draft/open targeting `master` from `podman-gui-smoke-workflow`.

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
  - Status: draft PR open; no CI readiness claimed.
  - Evidence: <https://github.com/blockedby/arch-nuclear/pull/12> is draft; `gh pr checks 12 --repo blockedby/arch-nuclear` returned `no checks reported on the 'podman-gui-smoke-workflow' branch`.

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
- Status: success.
- Goal state: achieved for static tooling/docs/evidence slice.
- Final readiness: draft PR ready for maintainer/user review; runtime image/GUI validation explicitly deferred.
- Summary: Rootless Podman workflow and PR #8 evidence are committed and pushed on `podman-gui-smoke-workflow`; draft PR #12 is open.

## Next-agent brief
- Objective: if continuing, manually build/run the Podman workflow in a target Wayland session and/or start a dedicated PR #8 fix pass.
- Target: PR #12 for workflow validation; PR #8 / `roadmap/wayland-tray-options` for product behavior fix.
- Settled already: no product-code changes in PR #12; PR #8 remains draft/block merge.
- Boundaries: do not mark draft PRs ready until requested and verified; avoid host installs/expensive builds unless explicitly chosen.
- Verification target: image build and live Wayland smoke for the workflow; dedicated close/minimize behavior evidence for PR #8.
- Expected output: manual smoke evidence and any needed follow-up fix report.

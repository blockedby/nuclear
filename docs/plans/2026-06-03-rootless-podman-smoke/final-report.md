## Task
- Mission: Record PR #8 Wayland tray smoke failure/partial success and deliver a separate rootless Podman GUI dev/smoke workflow.
- Target: `blockedby/arch-nuclear`, branch `podman-gui-smoke-workflow`, draft PR #12.
- Boundaries: no PR #8 product fix, no host installs, no full builds/GUIs, no upstream PRs, draft PR only.
- Done when: evidence is documented/commented, likely #8 cause areas are captured, Podman workflow/docs are pushed in a draft PR, static checks pass, and final user report is written.

## Context
- Root task package: `docs/plans/2026-06-03-rootless-podman-smoke`.
- Worktree: `/home/kcnc/code/apps/nuclear/.worktrees/podman-gui-smoke-workflow`.
- Branch: `podman-gui-smoke-workflow`.
- Draft PR: <https://github.com/blockedby/arch-nuclear/pull/12>.
- PR #8 comment: <https://github.com/blockedby/arch-nuclear/pull/8#issuecomment-4611414806>.

## Spec compliance
- Record PR #8 smoke result in docs/GitHub: done via `reports/wayland-tray-pr8-smoke.md` and PR #8 comment.
- Identify likely #8 cause areas without fixing: done; close-request interception, minimize-vs-hide, Wayland task-list behavior, tray/status-notifier behavior, and settings sync are recorded.
- Implement rootless Podman GUI workflow: done via `tools/podman-gui/Containerfile`, `Podmanfile`, and `podman-gui-smoke`.
- Provide simple user commands and limitations/security docs: done via `docs/development/rootless-podman-gui-smoke.md`.
- Verify statics only and avoid expensive/unsafe work: done via `verification/local.md` and `verification/root-local.md`.
- Open/keep draft PR: done; PR #12 is draft and draft CI checks are skipped.

## Acceptance verification
- AC1 PR #8 evidence/comment blocks merge: passed.
  - Evidence: <https://github.com/blockedby/arch-nuclear/pull/8#issuecomment-4611414806>, `reports/wayland-tray-pr8-smoke.md`.
- AC2 Likely cause areas recorded: passed.
  - Evidence: `reports/wayland-tray-pr8-smoke.md`.
- AC3 Rootless Podman workflow exists: passed.
  - Evidence: `tools/podman-gui/` files.
- AC4 User commands and security/limitations documented: passed.
  - Evidence: `docs/development/rootless-podman-gui-smoke.md`.
- AC5 Static verification only: passed.
  - Evidence: `verification/root-local.md`.
- AC6 Draft PR against master: passed.
  - Evidence: PR #12, draft checks skipped.

## Verification run
- `bash -n tools/podman-gui/podman-gui-smoke`: passed.
- `tools/podman-gui/podman-gui-smoke --help`: passed.
- No Docker socket mount grep: passed.
- No repo `:Z`/`:z` relabel suffix grep: passed after follow-up hardening.
- Required branch examples/Wayland/DBus/GPU/evidence grep: passed.
- `gh pr view 12`: open draft, base `master`, skipped draft CI.

## Issues
### Issue R-01: PR #8 result not recorded
- Resolution: repo-local evidence and PR comment added.

### Issue R-02: No rootless Podman GUI smoke workflow
- Resolution: Arch-based rootless Podman workflow, wrapper, and docs added.

### Issue R-03: Repo mount relabel risk
- Resolution: removed `:Z`; docs now state the checkout is not relabeled by default.

### Issue U-01: PR #8 behavior remains not mergeable
- Evidence: user's smoke result; PR #8 comment and evidence report.
- Needed next: dedicated Wayland tray fix pass with live smoke evidence.

## Verdict
- Status: success for requested recording + Podman workflow implementation.
- Final readiness: PR #12 is ready for draft review/static iteration, not runtime acceptance.
- Remaining blocker: PR #8 must stay draft/block-merge until close/minimize-to-tray behavior is fixed and live-smoke-tested.

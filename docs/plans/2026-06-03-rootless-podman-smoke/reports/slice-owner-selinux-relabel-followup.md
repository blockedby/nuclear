## Task
- Mission: Resolve root review safety finding by removing Podman repo-mount relabel behavior and updating evidence.
- Target: `tools/podman-gui/podman-gui-smoke`, `docs/development/rootless-podman-gui-smoke.md`, task package verification.
- Boundaries: one safety hardening fix only; no host installs, builds, GUI runs, new PR, or draft-state change.
- Done when: branch is committed/pushed to existing draft PR #12 with fresh static evidence.
- Expected evidence: script syntax/help, no Docker socket grep, repo mount/no-relabel grep, commit hash.

## Context
- Thread: root review follow-up for same slice/worktree.
- Slice: rootless Podman GUI smoke workflow.
- Task package: `docs/plans/2026-06-03-rootless-podman-smoke/`.
- Report path: `docs/plans/2026-06-03-rootless-podman-smoke/reports/slice-owner-selinux-relabel-followup.md`.
- Worktree: `/home/kcnc/code/apps/nuclear/.worktrees/podman-gui-smoke-workflow`.
- Branch: `podman-gui-smoke-workflow`.
- Verify scope: static-only safety hardening checks.

## Spec compliance
- Requirement: Remove `:Z` suffix from the repo volume mount.
  - Status: done.
  - Evidence: `tools/podman-gui/podman-gui-smoke` now uses `args+=(--volume "$REPO_ROOT:$WORKSPACE")`.
  - Gap if any: none.
- Requirement: Update docs/report/verification if needed to say no relabel by default.
  - Status: done.
  - Evidence: `docs/development/rootless-podman-gui-smoke.md` says the checkout mount omits `:Z`/`:z` and does not relabel by default; `verification/local.md` has the re-check entry.
  - Gap if any: none.

## Acceptance verification
- AC1: Script is syntactically valid.
  - Covered by: `bash -n tools/podman-gui/podman-gui-smoke`.
  - Result: passed.
- AC2: Help path still works without requiring Podman.
  - Covered by: `tools/podman-gui/podman-gui-smoke --help >/tmp/podman-gui-help.txt`.
  - Result: passed.
- AC3: Workflow still has no Docker socket dependency.
  - Covered by: `! grep -R -n -E -- '--volume .*docker\.sock|/var/run/docker\.sock:' tools/podman-gui docs/development/rootless-podman-gui-smoke.md`.
  - Result: passed.
- AC4: Repo mount no longer relabels checkout by default and docs say so.
  - Covered by: targeted grep commands recorded in `verification/local.md`.
  - Result: passed.

## System readiness
- Runtime / deployment wiring: ready for static-scope PR review; GUI/image runtime remains intentionally unrun per boundary.

## Verification run
- Local / targeted checks: all requested static checks passed; details in `verification/local.md`.
- Remote checks / CI: not checked for this follow-up beyond push target; PR #12 remains draft by instruction.

## Issues
### Issue R-01: Podman repo mount could relabel SELinux checkout
- Description: Repo mount used `:Z` while labels were disabled, which could relabel a host checkout unnecessarily.
- Evidence: root review finding and prior script line `--volume "$REPO_ROOT:$WORKSPACE:Z"`.
- Resolution: removed `:Z`, documented no-relabel default, and added verification evidence.
- Depends on: none.

## Side findings
- Blocking findings folded into active work: R-01.
- Non-blocking findings tracked separately: none.

## Verdict
- Status: success.
- Goal state: fully achieved for the requested safety hardening follow-up.
- Final readiness: ready for existing draft PR #12 review within static/no-GUI constraints.

## Next-agent brief
- Objective: Continue PR #12 review/merge process if requested.
- Target: existing draft PR #12 on `podman-gui-smoke-workflow`.
- Settled already: repo mount no longer has `:Z`/`:z`; docs/evidence record no-relabel default.
- Boundaries: do not run host installs/builds/GUI unless explicitly authorized.
- Verification target: same static checks plus any reviewer-requested static audit.
- Expected output: PR status and any new review findings.

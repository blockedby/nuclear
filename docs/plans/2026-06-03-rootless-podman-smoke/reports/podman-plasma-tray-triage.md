## Task
- Mission: triage Podman GUI smoke Plasma/theme/tray roughness and PR #8 minimize-to-tray behavior after master `ccf049fd`; implement only an obvious low-risk fork-branch patch.
- Target: `tools/podman-gui/podman-gui-smoke`, `docs/development/rootless-podman-gui-smoke.md`, and PR #8 tray/window files.
- Boundaries: no upstream targeting, no host package installs, no full Tauri build/bundle, no manual GUI smoke, no draft PR ready transition.
- Done when: runner improvement decision, minimize root-cause decision, patch/no-patch decision, verification, commit/push details are recorded.
- Expected evidence: static code inspection, narrow shell/static checks, PR metadata, and commit/push details if patched.

## Context
- Thread: fork-only arch-nuclear Podman GUI smoke/theme/tray triage after master `ccf049fd`.
- Slice: stayed whole; no sub-slices or implementer tasks were used because the patch/triage scope was small and one verification story fit.
- Task package: `docs/plans/2026-06-03-rootless-podman-smoke`
- Report path: `docs/plans/2026-06-03-rootless-podman-smoke/reports/podman-plasma-tray-triage.md`
- Worktrees inspected:
  - master: `/home/kcnc/code/apps/nuclear` on `master...origin/master`
  - runner: `/home/kcnc/code/apps/nuclear/.worktrees/smoke-test-kit` on `smoke-test-kit...origin/smoke-test-kit`
  - app PR #8: `/home/kcnc/code/apps/nuclear/.worktrees/roadmap-wayland-tray-options` on `roadmap/wayland-tray-options...origin/roadmap/wayland-tray-options`
- PR metadata: PR #8 is open draft head `roadmap/wayland-tray-options`; PR #11 is open draft head `smoke-test-kit`; PR #12 is already merged.

## Spec compliance
- AC1 Runner integration:
  - Status: done, with patch.
  - Evidence: committed `ea1f1b6a` on `smoke-test-kit` adds desktop/session env pass-through and optional read-only user theme/icon/font mounts; docs describe limits.
  - Rationale/risk: cheap and safe because mounts are conditional, read-only, under container temp HOME, and do not relabel or write host config. They can improve GTK/KDE theme/icon/font discovery but cannot install missing theme engines/packages inside the image.
- AC2 Minimize-to-tray root cause:
  - Status: done, decision only.
  - Evidence: PR #8 code hides on close via `appWindow.onCloseRequested(... preventDefault(); hide())`, matching user evidence that close/X works. Minimize code waits for `appWindow.onResized`, then calls `isMinimized()` and `hide()`. User evidence says launch and close/X work in the same container, so GUI/session/tray-enough plumbing is present for the close/hide path; the minimize path is a separate frontend event heuristic and is more likely the app-code failure.
  - Gap: no manual GUI rerun in this environment; exact Tauri/WebKit event sequence on KDE Wayland still needs runtime logging or alternate minimize event handling.
- AC3 Patch decision:
  - Status: done.
  - Evidence: small runner/docs patch implemented, committed, and pushed to existing draft PR branch `smoke-test-kit`; no app-code patch made on PR #8 because the obvious issue is diagnostic/root-cause direction, not a verified one-line safe fix.
- AC4 Verification:
  - Status: done for static/narrow scope; GUI smoke skipped by boundary.
  - Evidence: commands listed below.

## Acceptance verification
- AC1: list and implement cheap/safe runner env/mount changes.
  - Covered by: diff inspection plus `bash -n`, help smoke, `git diff --check`, grep.
  - Result: passed.
  - Evidence: `ea1f1b6a` changes `tools/podman-gui/podman-gui-smoke` and `docs/development/rootless-podman-gui-smoke.md`.
- AC2: decide whether minimize-to-tray failure is likely PR #8 app code vs container.
  - Covered by: static inspection of `packages/player/src/hooks/useTrayWindowBehavior.ts`, `useTrayWindowBehavior.test.tsx`, `src-tauri/src/tray.rs`, `src-tauri/src/lib.rs`, and user runtime evidence.
  - Result: passed decision; likely app-code issue in PR #8 minimize hook.
  - Evidence: close hook uses close-request event and works manually; minimize hook depends on resize event and minimized-state timing.
- AC3: implement if safe, otherwise report next steps.
  - Covered by: patch on `smoke-test-kit`, pushed to origin.
  - Result: passed.
  - Evidence: branch `smoke-test-kit`, commit `ea1f1b6a`, draft PR #11 remains draft.
- AC4: run fresh narrow checks.
  - Covered by: static shell/docs checks and PR #8 tests.
  - Result: passed with skip notes.
  - Evidence: commands below.

## System readiness
- Routes / registration: not relevant.
- Services / APIs: not relevant.
- Config / env / secrets: runner env/mount wiring updated; no secrets written.
- Permissions / access: read-only user config mounts only; GUI/session sockets remain as documented existing trust boundary.
- Database / migrations: not relevant.
- Frontend-backend integration: PR #8 inspected only; no app-code integration changed.
- Runtime / deployment wiring: improved for Podman GUI smoke; still requires manual compositor validation.

## Verification run
- Local / targeted checks:
  - `bash -n .worktrees/smoke-test-kit/tools/podman-gui/podman-gui-smoke`: passed.
  - `cd .worktrees/smoke-test-kit && tools/podman-gui/podman-gui-smoke --help >/tmp/podman-help.txt`: passed; usage printed without requiring Podman.
  - `cd .worktrees/smoke-test-kit && grep -n "XDG_CURRENT_DESKTOP\|kdeglobals\|docker.sock" tools/podman-gui/podman-gui-smoke docs/development/rootless-podman-gui-smoke.md`: passed; found new env/mount/docs entries and existing no-docker-socket doc.
  - `cd .worktrees/smoke-test-kit && git diff --check`: passed before commit.
  - `cd .worktrees/roadmap-wayland-tray-options && pnpm --filter @nuclearplayer/player test -- src/hooks/useTrayWindowBehavior.test.tsx`: not run; `pnpm` binary not on PATH.
  - `cd .worktrees/roadmap-wayland-tray-options && corepack pnpm --filter @nuclearplayer/player test -- src/hooks/useTrayWindowBehavior.test.tsx`: passed, but Vitest ran the player test suite due repo test script behavior: 62 files, 573 passed, 1 todo. The targeted hook test file passed: `src/hooks/useTrayWindowBehavior.test.tsx (3 tests)`.
- Local / full checks:
  - Full Tauri build / GUI smoke: not run; explicitly out of scope/expensive and no manual GUI attempt requested. User manual evidence accepted.
- Remote checks / CI:
  - Status: draft PR branch push only; no CI readiness requested.
  - Evidence: pushed `smoke-test-kit` to origin; PR #11 remains draft.

## Changed files / commit / push
- Branch/worktree: `smoke-test-kit` at `/home/kcnc/code/apps/nuclear/.worktrees/smoke-test-kit`.
- Commit: `ea1f1b6a Improve Podman GUI desktop integration hints`.
- Push: `origin/smoke-test-kit` updated from `ebcda9f4` to `ea1f1b6a`.
- Draft PR: #11 `https://github.com/blockedby/arch-nuclear/pull/11` remains draft.
- Changed files:
  - `tools/podman-gui/podman-gui-smoke`
  - `docs/development/rootless-podman-gui-smoke.md`
- Unrelated local state: `.worktrees/smoke-test-kit/.pnpm-store/` is untracked pre-existing/local cache; not committed.

## Issues
### Issue R-01: Podman runner lacked host desktop theme hints
- Description: Existing runner forwarded Wayland/DBus/audio/GPU, but not common desktop identity/theme env vars or user theme/icon/font config.
- Evidence: pre-patch `podman-gui-smoke` had `GDK_BACKEND` and socket env only; no `XDG_CURRENT_DESKTOP`, `QT_QPA_PLATFORMTHEME`, `GTK_THEME`, `ICON_THEME`, `kdeglobals`, GTK config, icons, fonts, `.themes`, or Kvantum mounts.
- Resolution: Added conditional env forwarding plus read-only mounts to container temp HOME, documented limitations.
- Depends on: none.

### Issue U-01: PR #8 minimize-to-tray likely uses unreliable minimize detection
- Description: Minimize-to-tray does not hide in the user's successful Podman GUI smoke, while close/X-to-tray works.
- Evidence: `useTrayWindowBehavior.ts` close path listens to `onCloseRequested`, prevents default, and hides; minimize path only listens to `onResized`, then checks `isMinimized()`. User manually confirmed close/X works but minimize-to-tray does not in the same container session.
- Why unresolved: App-code behavior needs a runtime-backed fix on `roadmap/wayland-tray-options`; no clearly safe one-line patch was proven by static inspection alone.
- Needed next: On PR #8 branch, instrument or replace the minimize hook with a Tauri-supported window event path that reliably observes minimize on KDE Wayland, then manually smoke in Podman. Candidate direction: avoid relying on resize as the minimize signal; add runtime logging/evidence for the event sequence and then hide on the actual minimize event if available or use a backend window event bridge if frontend API lacks one.
- Depends on: manual KDE/Wayland smoke or equivalent event evidence.

## Side findings
- Blocking findings folded into active work: R-01.
- Non-blocking findings tracked separately: none created; U-01 is current-goal continuation for PR #8 rather than a separate follow-up.

## Verdict
- Status: partial success.
- Goal state: runner-integration decision and safe patch achieved; PR #8 root-cause decision achieved; PR #8 fix remains unresolved pending runtime-backed app-code change.
- Final readiness: ready except explicit limitation that minimize-to-tray still needs PR #8 app-code work and manual KDE/Wayland smoke.
- Summary: The container can be cheaply improved for Plasma/theme fidelity, but the minimize-to-tray failure is more likely in PR #8's frontend minimize hook than in Podman wiring.

## Next-agent brief
- Objective: fix PR #8 minimize-to-tray behavior.
- Target: `roadmap/wayland-tray-options`, especially `packages/player/src/hooks/useTrayWindowBehavior.ts` and tests; backend bridge only if frontend Tauri API cannot emit a real minimize event.
- Settled already: Podman launch/close path works; runner now forwards desktop theme hints on `smoke-test-kit`; do not re-blame basic container GUI/session plumbing first.
- Boundaries: keep PR #8 draft, fork-only, no broad refactor, no upstream PR, no full Tauri bundle.
- Verification target: targeted hook tests plus manual Podman KDE/Wayland smoke showing minimize hides the window and tray/show/quit remains recoverable.
- Expected output: PR #8 commit/push or exact blocker with event evidence.

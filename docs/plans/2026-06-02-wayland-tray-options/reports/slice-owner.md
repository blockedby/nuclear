## Task
- Mission: Implement Arch Nuclear issue #1: Wayland tray and close/minimize-to-tray support.
- Target: settings UI/state, frontend Tauri window behavior, Rust tray wiring, desktop identity consistency.
- Boundaries: no upstream/nukeop PR, no merge, no broad product/app identifier rename, no destructive cleanup.
- Done when: branch is pushed, PR to `blockedby/arch-nuclear:master` is open, and acceptance evidence is recorded.
- Expected evidence: PR URL, commit, local checks, explicit runtime limitation.

## Context
- Thread: Arch Nuclear roadmap separate PRs.
- Slice: slice-b-wayland-tray.
- Task name: Arch Nuclear Wayland tray/close-to-tray PR (#1).
- Task package: `docs/plans/2026-06-02-wayland-tray-options`.
- Report path: `docs/plans/2026-06-02-wayland-tray-options/reports/slice-owner.md`.
- Worktree: `/home/kcnc/code/apps/nuclear/.worktrees/roadmap-wayland-tray-options`.
- Branch: `roadmap/wayland-tray-options`.
- PR: https://github.com/blockedby/arch-nuclear/pull/8.
- Verify scope: targeted player tests, TypeScript, targeted ESLint, Rust cargo tests, metadata inspection.

## Spec compliance
- Settings expose behavior clearly: done; `Close to tray` and `Minimize to tray` General settings added with English descriptions and Settings test coverage.
- Close/minimize behavior respects configuration: done in frontend hook tests; disabled settings do not intercept, enabled close hides after preventing close, enabled minimize hides after minimized event.
- Tray icon/window identity consistent with Arch desktop metadata: done by preserving `mainBinaryName`, Tauri identifier, GTK app-id, desktop Exec/Icon metadata while adding tray icon from default window icon.
- PR target policy: done; PR opened to `blockedby/arch-nuclear` `master`, not upstream, and not merged.

## Acceptance verification
- AC1: Settings expose the behavior clearly.
  - Covered by: `Settings.test.tsx` visible text assertions and updated snapshot.
  - Result: passed.
  - Evidence: `cd packages/player && corepack pnpm exec vitest run src/hooks/useTrayWindowBehavior.test.tsx src/views/Settings/Settings.test.tsx` — 2 files / 5 tests passed.
- AC2: Close/minimize-to-tray behavior keeps app alive when configured and quits normally when not configured.
  - Covered by: `useTrayWindowBehavior.test.tsx`.
  - Result: passed for frontend event contract.
  - Evidence: same Vitest command; default disabled path does not call `preventDefault`/`hide`, enabled paths hide the window.
- AC3: Tray icon/window identity remains consistent with Arch desktop metadata.
  - Covered by: Rust compile/tests and metadata inspection.
  - Result: passed with live-Wayland limitation.
  - Evidence: `cargo test` passed; `tauri.conf.json` unchanged identity (`nuclear-music-player`, `com.nuclearplayer`, `enableGTKAppId`), desktop file unchanged `Exec=nuclear-music-player %u`, `Icon=com.nuclearplayer.Nuclear`.
- AC4: Targeted tests/manual evidence cover behavior; limitations explicit.
  - Covered by: local verification file and PR body.
  - Result: ready except compositor manual smoke test.
  - Evidence: `docs/plans/2026-06-02-wayland-tray-options/verification/local.md`; no Wayland/KDE session available.

## System readiness
- Routes / registration: not relevant.
- Services / APIs: not relevant.
- Config / env / secrets: done; no secrets or env changes.
- Permissions / access: done; no new permissions/capabilities changed.
- Database / migrations: not relevant.
- Frontend-backend integration: done; React hook uses existing Tauri window API mock/test pattern.
- Runtime / deployment wiring: done locally; Rust tray feature enabled and tray initialized in Tauri setup. Live Wayland/KDE tray smoke test remains recommended before release.

## Verification run
- Local / targeted checks:
  - `cd packages/player && corepack pnpm exec vitest run src/hooks/useTrayWindowBehavior.test.tsx src/views/Settings/Settings.test.tsx`: passed, 2 files / 5 tests.
  - `cd packages/player && corepack pnpm exec tsc --noEmit`: passed.
  - `cd packages/player && corepack pnpm exec eslint src/hooks/useTrayWindowBehavior.ts src/hooks/useTrayWindowBehavior.test.tsx src/views/Settings/Settings.test.tsx src/test/setup.ts src/App.tsx src/services/coreSettings.ts`: passed.
  - `cd packages/player/src-tauri && cargo test`: passed, 24 Rust tests, after ignored temporary `packages/player/dist/index.html` for RustEmbed.
- Local / full checks:
  - Not run; targeted checks cover changed behavior and full player Vitest was accidentally invoked once and exposed no relevant failures except expected snapshot/update and hook test pre-fix, both resolved.
- Remote checks / CI:
  - Status: no checks currently reported after final push.
  - Evidence: `gh pr checks 8 --repo blockedby/arch-nuclear` returned `no checks reported on the 'roadmap/wayland-tray-options' branch`. Earlier checks were queued on the first push before the report commit.

## Issues
### Issue R-01: Missing tray settings and behavior
- Description: master lacked close/minimize-to-tray options and tray runtime wiring.
- Evidence: `rg tray|close.*tray|minimize` found no active implementation before changes.
- Resolution: added settings/i18n, frontend hook, Rust tray module, changelog, tests.
- Depends on: none.

### Issue U-01: Live Wayland/KDE runtime not manually smoke-tested
- Description: local harness did not provide a Wayland/KDE session to observe actual tray icon display and compositor hide/show behavior.
- Evidence: no desktop session/browser/runtime path available; PR body and verification file state limitation.
- Why unresolved: external environment limitation.
- Needed next: before release/merge, run app in target Wayland/KDE (and preferably GNOME) session; enable settings, verify close/minimize hides to tray, Show restores window, Quit exits.
- Depends on: PR branch build artifact or local Tauri dev run in such session.

## Side findings
- Blocking findings folded into active work: none.
- Non-blocking findings tracked separately: none.

## Verdict
- Status: success with explicit manual-runtime limitation.
- Goal state: implemented and PR opened.
- Final readiness: ready for PR review; recommended pre-merge Wayland/KDE tray smoke test remains.
- Summary: PR #8 implements issue #1 and has fresh targeted local evidence; do not merge until remote checks and at least one Wayland/KDE smoke test are acceptable.

## Next-agent brief
- Objective: review/merge preparation if requested.
- Target: PR #8 / branch `roadmap/wayland-tray-options`.
- Settled already: implementation, local tests, PR target, issue linkage.
- Boundaries: do not open upstream PR or merge without explicit instruction.
- Verification target: remote CI green plus live Wayland/KDE tray smoke test.
- Expected output: merge recommendation or review findings.

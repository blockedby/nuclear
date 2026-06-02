## Task
- Mission: Implement upstream-ready Wayland tray support plus optional close/minimize-to-tray behavior, verify feasible checks, commit/push to fork origin, and leave PR evidence for root.
- Target: Nuclear player Tauri startup/tray lifecycle, React settings/window behavior, i18n, changelog, and task-package evidence.
- Boundaries: No upstream PR opened; no host package installs; no packaging changes unless required; keep previous Arch packaging changes untouched.
- Done when: Branch contains implementation and evidence, is pushed to `origin/wayland-tray-options`, and root can decide whether to open nukeop/nuclear PR for discussion #2004.
- Expected evidence: Source paths, Tauri tray backend discovery, Rust/frontend verification attempts, manual Wayland tray instructions, commit/push status.

## Context
- Thread: User asked to implement upstream discussion nukeop/nuclear#2004 in forked Nuclear repo.
- Slice: S1 Wayland tray options; stayed whole under one slice owner.
- Task name: Wayland tray options
- Task package: `docs/plans/2026-06-02-wayland-tray-options`
- Report path: `docs/plans/2026-06-02-wayland-tray-options/reports/slice-owner.md`
- Worktree: `/home/kcnc/code/apps/nuclear/.worktrees/wayland-tray-options`
- Branch: `wayland-tray-options`
- Verify scope: discovery evidence, source implementation, Rust checks, frontend check attempt, manual Wayland instructions.
- Review target: final branch diff.

## Spec compliance
- AC1 current implementation discovery
  - Status: done
  - Evidence: `verification/local.md`; key paths include `packages/player/src-tauri/src/lib.rs`, `packages/player/src-tauri/tauri.conf.json`, `packages/player/src/services/coreSettings.ts`, `packages/player/src/stores/settingsStore.ts`, `packages/player/src/views/Settings/*`.
  - Gap if any: none.
- AC2 Tauri v2/Linux tray backend behavior
  - Status: done
  - Evidence: `Cargo.lock` has `tray-icon 0.21.1` depending on `libappindicator`; local cargo source `tray-icon-0.21.1/src/platform_impl/gtk/mod.rs` imports `libappindicator::{AppIndicator, AppIndicatorStatus}`; `tray-icon` docs state Linux uses libappindicator/libayatana-appindicator.
  - Gap if any: no live Wayland host proof in container.
- AC3 optional close/minimize-to-tray
  - Status: done
  - Evidence: `packages/player/src/hooks/useTrayWindowBehavior.ts`, `packages/player/src/App.tsx`, `packages/player/src/services/coreSettings.ts`, `packages/i18n/src/locales/en_US.json`.
  - Gap if any: runtime GUI behavior requires manual verification.
- AC4 Linux/Wayland icon/app identity
  - Status: done
  - Evidence: `tauri.conf.json` already has `app.enableGTKAppId: true` and bundle icons; tray uses `app.default_window_icon()` in `packages/player/src-tauri/src/tray.rs`.
  - Gap if any: none identified.
- AC5 verification
  - Status: partial
  - Evidence: `cargo check` and `cargo test` passed after satisfying existing RustEmbed dist requirement; frontend type-check was attempted but blocked by missing node_modules/tsc; manual Wayland instructions are in `verification/local.md`.
  - Gap if any: no frontend type/build or live GUI Wayland check in this environment.
- AC6 fork push/no upstream PR
  - Status: done.
  - Evidence: current branch commit pushed to `origin/wayland-tray-options`; no upstream PR opened by slice owner.
  - Gap if any: none.

## Acceptance verification
- AC1: Discover current tray/window/minimize/settings implementation.
  - Covered by: source inspection and task package evidence.
  - Result: passed.
  - Evidence: `verification/local.md` discovery section.
- AC2: Determine Tauri v2/tray-icon Linux backend behavior.
  - Covered by: local Cargo.lock and cargo registry source/docs inspection.
  - Result: passed.
  - Evidence: `verification/local.md` discovery section.
- AC3: Implement optional close-to-tray and minimize-to-tray if missing.
  - Covered by: source implementation review and Rust compile; frontend type-check attempted.
  - Result: passed for source implementation; frontend compile not proven due environment.
  - Evidence: `packages/player/src/hooks/useTrayWindowBehavior.ts`; `verification/local.md`.
- AC4: Ensure Linux/Wayland icon/app identity is sane.
  - Covered by: config/source inspection.
  - Result: passed.
  - Evidence: existing `enableGTKAppId`; tray default icon use.
- AC5: Verify with feasible checks; document manual Wayland limitation.
  - Covered by: `cargo check`, `cargo test`, frontend type-check attempt, manual instructions.
  - Result: partial.
  - Evidence: `verification/local.md`.
- AC6: Commit and push branch only to fork origin; do not push upstream.
  - Covered by: final git operations.
  - Result: passed.
  - Evidence: current branch commit pushed to `origin/wayland-tray-options`.

## System readiness
- Routes / registration: done; `tray::init_tray(app)?` registered in Tauri setup.
- Services / APIs: done; frontend hook uses Tauri window API, no new backend command surface.
- Config / env / secrets: done; no secrets/env changes; Tauri `tray-icon` feature enabled.
- Permissions / access: not relevant; no new Tauri command permissions.
- Database / migrations: not relevant.
- Frontend-backend integration: partial evidence; source wiring complete, frontend type-check unavailable.
- Runtime / deployment wiring: ready except explicit manual Wayland runtime verification limitation.

## Verification run
- Local / targeted checks:
  - `cd packages/player/src-tauri && cargo check`: passed after creating temporary `packages/player/dist/index.html` for the repo's existing RustEmbed requirement.
    - Evidence: `verification/local.md`.
  - `cd packages/player/src-tauri && cargo test`: passed, 24 Rust tests.
    - Evidence: `verification/local.md`.
  - `corepack pnpm --filter @nuclearplayer/player type-check`: failed to run due missing dependencies.
    - Evidence: `sh: line 1: tsc: command not found`; pnpm warned `node_modules missing`.
- Local / full checks:
  - Full app build: not run; no node_modules/tsc and no host installs allowed.
- Remote checks / CI:
  - Status: not checked by slice owner; upstream PR not opened.
  - Evidence: root may inspect after push/PR.

## Issues
### Issue R-01: Tauri tray API gated out
- Description: Initial Rust compile showed `tauri::tray` is behind the `tray-icon` feature.
- Evidence: `cargo check` error: `could not find tray in tauri`, note gated behind `feature = "tray-icon"`.
- Resolution: Enabled `tauri = { features = ["tray-icon"] }` in `packages/player/src-tauri/Cargo.toml`.
- Depends on: none.

### Issue R-02: Existing RustEmbed dist requirement blocks raw cargo check
- Description: `cargo check` fails when `packages/player/dist` does not exist because `src/http_api/frontend.rs` embeds `../dist/`.
- Evidence: `#[derive(RustEmbed)] folder ... packages/player/src-tauri/../dist/ does not exist`.
- Resolution: Created a temporary minimal `packages/player/dist/index.html` locally for verification only; `dist` remains ignored and is not part of the commit.
- Depends on: none.

### Issue U-01: Frontend type/build verification unavailable in checkout
- Description: TypeScript/frontend checks could not run because dependencies are not installed.
- Evidence: `corepack pnpm --filter @nuclearplayer/player type-check` failed with `tsc: command not found` and `node_modules missing`.
- Why unresolved: No host package installs allowed by task constraints.
- Needed next: Root or CI should run `pnpm install`/normal repo workflow and `pnpm --filter @nuclearplayer/player type-check` plus build before opening or merging upstream PR.
- Depends on: dependency availability/CI.

### Issue U-02: Live Wayland tray visual behavior not proven locally
- Description: Container has no GUI Wayland compositor/tray host for StatusNotifierItem/AppIndicator runtime validation.
- Evidence: Manual verification notes required in `verification/local.md`.
- Why unresolved: Environment limitation.
- Needed next: Manual test on Wayland/Hyprland with an SNI/AppIndicator-capable tray host.
- Depends on: desktop runtime.

## Side findings
- Blocking findings folded into active work: R-01, R-02.
- Non-blocking findings tracked separately: none.

## Verdict
- Status: partial success
- Goal state: implementation achieved; verification is incomplete only where environment lacks frontend dependencies and GUI Wayland tray host.
- Final readiness: ready for root review, CI/frontend verification, and manual Wayland runtime check before upstream PR.
- Summary: Branch implements Tauri tray registration and opt-in close/minimize-to-tray behavior with Rust verification passing; root should wait for frontend CI/manual Wayland evidence before opening upstream PR if strict evidence is required.

## Next-agent brief
- Objective: Decide whether to open upstream PR for nukeop/nuclear#2004.
- Target: `wayland-tray-options` branch on fork origin.
- Settled already: Source implementation is complete; Tauri Linux tray backend uses libappindicator/libayatana-appindicator; app identity config already has `enableGTKAppId`.
- Boundaries: Do not reopen packaging work unless manual Wayland testing identifies a source/config need.
- Verification target: frontend type-check/build or CI, plus manual Wayland tray restore/close/minimize behavior.
- Expected output: upstream PR body referencing discussion #2004 with behavior, verification, and manual Wayland limitations if root accepts evidence.

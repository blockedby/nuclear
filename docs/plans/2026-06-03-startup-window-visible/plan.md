# Startup window visible fix plan

## Task intake
- Goal: fix fork branch `roadmap/wayland-tray-options` so a normal app launch shows the main window instead of starting invisibly.
- In scope: low-risk Tauri startup visibility fix; preserve existing close-to-tray behavior where close hides only when the setting is enabled.
- Out of scope: upstream changes, redesigning tray behavior, packaging/release changes, full production builds.
- Done state: branch committed and pushed to origin, PR #8 remains draft, lightweight verification recorded, manual smoke instruction provided.
- Blocking unknowns: none; manual GUI smoke remains user-side because current harness has the reported no-visible-window smoke context.

## Repo orientation
- Main Tauri config: `packages/player/src-tauri/tauri.conf.json`.
- Rust setup/tray code: `packages/player/src-tauri/src/lib.rs`, `packages/player/src-tauri/src/tray.rs`.
- Close/minimize-to-tray frontend hook: `packages/player/src/hooks/useTrayWindowBehavior.ts` with tests in `useTrayWindowBehavior.test.tsx`.
- Verification commands: JSON parse for config; targeted hook test; optional `cargo check` in `packages/player/src-tauri` for Tauri config/Rust compile path.

## Reuse discovery
- Tauri config already declares the main window and currently has `"visible": false`.
- Tray `show_main_window` already handles user-initiated re-show via tray menu/click.
- Frontend hook intercepts close only when `core.window.closeToTray` is enabled and calls `hide()` then; existing tests cover this behavior.

## Missing pieces
- Make the main window visible on normal startup using the least invasive existing Tauri config pattern.

## Plan tasks

### Task 1: Show main window on normal startup
Goal:
- Normal launch creates the main window as visible without requiring tray interaction.

Boundary:
- System area: Tauri window config.
- Primary verification: config JSON validity plus existing close-to-tray hook test.

Existing pattern / reuse:
- Reuse Tauri `visible` window config instead of adding a bespoke setup `show()` path.

Missing change:
- Change `app.windows[0].visible` from `false` to `true` in `packages/player/src-tauri/tauri.conf.json`.

Scope / likely files:
- `packages/player/src-tauri/tauri.conf.json` only.

Acceptance criteria:
- AC1: Main window is configured visible on startup.
- AC2: Close-to-tray logic remains setting-gated and still hides only on close when enabled.
- AC3: Branch is committed/pushed to `origin/roadmap/wayland-tray-options`; PR #8 remains draft.

Test plan:
- Positive: parse `tauri.conf.json` and assert `app.windows[0].visible === true`.
- Regression: run `pnpm --filter @nuclearplayer/player test -- src/hooks/useTrayWindowBehavior.test.tsx`.
- Compile/config: run `cargo check` from `packages/player/src-tauri` if lightweight enough in environment.
- Manual: user smoke: run existing `target/debug/player` or `pnpm dev`; main window should appear on launch; closing should hide to tray only if Settings → Window → close-to-tray is enabled.

Dependencies:
- Depends on: none.
- Blocks: final report.
- Can run parallel with: none.

Executor:
- Slice owner directly; edit is one config line and delegation would add more cost than risk reduction.

## Execution ledger
- 2026-06-03: Plan created; ready for owner-level tiny config edit.
- 2026-06-03: Implemented config-only fix: `packages/player/src-tauri/tauri.conf.json` main window `visible` is now `true`.
- 2026-06-03: Verification recorded in `verification/local.md`; AC1/AC2 satisfied by JSON check, Vitest close-to-tray regression coverage, and `cargo check`.

## Final acceptance evidence
- AC1 main window configured visible on startup: passed by JSON assertion and config diff.
- AC2 close-to-tray remains setting-gated: passed by `useTrayWindowBehavior.test.tsx` in Vitest run.
- AC3 branch pushed / PR draft: passed; commit `faa1d85e` pushed to `origin/roadmap/wayland-tray-options`; PR #8 is open and draft.

## Issues
- R-01 Startup window invisible: resolved by changing Tauri main window config from `visible: false` to `visible: true`.
- No follow-up or unresolved issues at slice scope.

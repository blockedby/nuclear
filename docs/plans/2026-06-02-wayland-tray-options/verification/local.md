# Local verification

## Discovery evidence
- Current Tauri startup is `packages/player/src-tauri/src/lib.rs`; before this change it registered plugins/services but had no tray setup or window close/minimize lifecycle handling.
- Current app config is `packages/player/src-tauri/tauri.conf.json`; `app.enableGTKAppId` is already true and bundle icons are already declared under `bundle.icon`, so no extra upstream-compatible Linux identity/config change was needed.
- Current settings registry is `packages/player/src/services/coreSettings.ts`, persisted by `packages/player/src/stores/settingsStore.ts` using Tauri `LazyStore('settings.json')` and rendered by `packages/player/src/views/Settings/*` via grouped visible settings.
- Tauri/tray backend evidence: `packages/player/src-tauri/Cargo.lock` includes `tray-icon 0.21.1`, which depends on `libappindicator`; local cargo source `~/.cargo/registry/src/.../tray-icon-0.21.1/src/platform_impl/gtk/mod.rs` imports `libappindicator::{AppIndicator, AppIndicatorStatus}`. `~/.cargo/registry/src/.../tray-icon-0.21.1/src/lib.rs` documents Linux tray creation via `libappindicator` or `libayatana-appindicator`. This supports StatusNotifierItem/AppIndicator-compatible Wayland trays when the desktop/compositor provides a watcher/host.

## Command evidence

### `cd packages/player/src-tauri && cargo check`
- Initial result without frontend dist: failed because `packages/player/dist` did not exist for `#[derive(RustEmbed)]`, and before enabling `tauri`'s `tray-icon` feature the new `tauri::tray` import was gated out.
- Remediation: enabled `tauri` feature `tray-icon`; created a minimal temporary `packages/player/dist/index.html` only to satisfy the existing RustEmbed compile-time requirement in this checkout.
- Final result: passed with existing warnings only:
  - `variant Password is never constructed` in `src/mpd/protocol.rs`
  - `constant ACK_ERROR_NO_EXIST is never used` in `src/mpd/protocol.rs`

### `cd packages/player/src-tauri && cargo test`
- Result: passed.
- Evidence: 24 Rust tests passed in `src/lib.rs`, 0 tests in `src/main.rs`, 0 doc tests.
- Warnings: same existing MPD dead-code warnings as `cargo check`.

### `corepack pnpm --filter @nuclearplayer/player type-check`
- Result: not runnable in this environment.
- Evidence: failed with `sh: line 1: tsc: command not found` and pnpm warning `node_modules missing`; no host package installs were allowed.

## Manual Wayland tray verification notes

Not run in this container: no GUI Wayland compositor/tray host is available.

Suggested manual test on Wayland/Hyprland or another Wayland session with a StatusNotifierItem/AppIndicator tray host:
1. Build/install or run Nuclear from this branch with normal project dependencies installed.
2. Confirm a Nuclear tray icon appears. On Hyprland, ensure the bar/tray component supports StatusNotifierItem/AppIndicator.
3. Left-click the tray icon and confirm the main window is shown/focused.
4. Right-click/open tray menu and confirm `Show Nuclear` shows/focuses the window and `Quit` exits the app.
5. In Preferences > General, enable `Close to tray`; close the main window and confirm Nuclear hides instead of quitting, then restore it from the tray icon/menu.
6. In Preferences > General, enable `Minimize to tray`; minimize the main window and confirm Nuclear hides to tray, then restore it from the tray icon/menu.
7. Disable each option and confirm default close/minimize behavior is restored.

## Limitations / risk
- Frontend type-check and frontend build were not run because this checkout has no `node_modules` and `tsc` was unavailable through `corepack pnpm`.
- Wayland visual/runtime tray behavior requires a real compositor plus tray host and was documented as manual verification rather than proven locally.

# Wayland tray options plan

## Task intake
Implement feature requested in upstream discussion nukeop/nuclear#2004 in the user's fork, then push a branch. Root decides whether to open the upstream PR after reviewing implementation and verification evidence.

User-provided discussion evidence:
- Tray icon support is requested for Wayland/Hyprland.
- Existing tray icon works on X11/Windows via earlier implementation, but not Wayland compositors.
- Expected behavior includes optional minimize-to-tray on minimize, optional close-to-tray on close, and a visible/functional tray icon on Wayland compositors supporting StatusNotifierItem/AppIndicator.
- This repo is Tauri v2 + Rust + React; Electron-specific details are not directly applicable.

## Constraints
- Push only to fork origin (`https://github.com/blockedby/nuclear.git`), not upstream.
- Do not open upstream PR in this slice.
- No host package installs; use existing repo/container workflows if needed.
- Preserve previous Arch packaging changes on origin/master; avoid packaging-specific changes unless necessary for this feature.
- Respect AGENTS.md patterns, i18n, tests, and Tauri/Rust conventions.

## Repo orientation and reuse discovery
- `packages/player/src-tauri/src/lib.rs`: Tauri startup and service/plugin registration. No existing tray setup was present before this slice.
- `packages/player/src-tauri/tauri.conf.json`: `enableGTKAppId` is already true; bundle icons are already declared, so app identity/icon config was already sane for Linux and no packaging change was needed.
- `packages/player/src/services/coreSettings.ts`: built-in settings registry. Reused for two visible boolean settings.
- `packages/player/src/stores/settingsStore.ts`: settings persist through Tauri `LazyStore('settings.json')`; no new persistence path needed.
- `packages/player/src/views/Settings/*`: visible core settings are grouped by category automatically; new settings appear under General.
- `packages/player/src/hooks/useFramelessWindow.ts`: existing Tauri window API hook pattern. Reused the hook approach for close/minimize-to-tray behavior.
- `packages/player/src/test/setup.ts`: Tauri API mocks used by Vitest; updated for new window APIs.
- Tauri/tray backend: `tray-icon 0.21.1` is present in `Cargo.lock`, depends on `libappindicator`, and its Linux implementation imports `libappindicator::{AppIndicator, AppIndicatorStatus}`. This means the missing source piece is enabling Tauri's `tray-icon` feature and registering a tray icon/menu, not Electron-style Wayland flags.

## Missing pieces identified
- Enable Tauri `tray-icon` feature in `packages/player/src-tauri/Cargo.toml`.
- Add Rust tray setup with default app icon, tooltip, Show/Quit menu, and left-click restore behavior.
- Add close-to-tray and minimize-to-tray settings with English i18n strings.
- Add frontend window lifecycle hook to hide the main window on close/minimize only when settings are enabled.
- Add changelog entry for the user-facing desktop feature.
- Record manual Wayland verification steps because no GUI Wayland tray host is available in the container.

## Slice structure
One implementation slice is used because the feature spans one ownership boundary (player tray/window lifecycle + settings) and one acceptance story. No sub-slices were created. Implementation was completed directly by the slice owner because nested subagent delegation was unavailable at current subagent depth.

## Plan tasks

### Task 1: Register a Tauri tray icon
Goal:
- Nuclear creates a desktop tray icon with Show and Quit actions and restore-on-left-click behavior.

Boundary:
- System area: Tauri Rust desktop lifecycle.
- Primary verification: Rust compile/test plus manual desktop tray checks.

Acceptance criteria:
- Tauri tray feature is enabled.
- Tray uses the app default icon and tooltip.
- Show restores/focuses the main window; Quit exits.

Test plan:
- `cargo check` / `cargo test` in `packages/player/src-tauri`.
- Manual Wayland tray host verification.

Status: done.
Evidence: `packages/player/src-tauri/src/tray.rs`, `packages/player/src-tauri/src/lib.rs`, `packages/player/src-tauri/Cargo.toml`, `verification/local.md`.

### Task 2: Add optional close/minimize-to-tray settings
Goal:
- Users can opt into hiding Nuclear to the tray on close and/or minimize without changing default behavior.

Boundary:
- System area: React settings + Tauri window API integration.
- Primary verification: frontend type-check/build where available, settings source review, manual behavior checks.

Acceptance criteria:
- Settings are visible under Preferences > General.
- User-facing strings are in `en_US.json`.
- Defaults are false.
- Close event is prevented only when close-to-tray is enabled.
- Minimize hides the window only when minimize-to-tray is enabled.

Test plan:
- `corepack pnpm --filter @nuclearplayer/player type-check` where dependencies exist.
- Manual close/minimize behavior checks in Tauri runtime.

Status: done with environment limitation.
Evidence: `packages/player/src/hooks/useTrayWindowBehavior.ts`, `packages/player/src/App.tsx`, `packages/player/src/services/coreSettings.ts`, `packages/i18n/src/locales/en_US.json`, `packages/player/src/test/setup.ts`, `verification/local.md`.

### Task 3: Final verification, evidence, commit, and push
Goal:
- Leave branch ready for root PR decision.

Boundary:
- System area: repo evidence and git branch.
- Primary verification: recorded local command evidence and pushed commit.

Acceptance criteria:
- Verification artifact and slice report are written.
- Branch is committed and pushed to fork origin.
- Upstream PR is not opened by slice owner.

Status: done.
Evidence: `verification/local.md`, `reports/slice-owner.md`, current branch commit, pushed `origin/wayland-tray-options`.

## Acceptance verification ledger
- AC1 discovery: done; see repo orientation above and `verification/local.md`.
- AC2 Tauri/tray backend: done; local Cargo.lock/source evidence shows Linux tray backend uses libappindicator/libayatana-appindicator.
- AC3 optional close/minimize-to-tray: done; implemented settings and frontend lifecycle hook.
- AC4 Linux/Wayland icon/app identity: done; reused default app icon and existing `enableGTKAppId`; no packaging change needed.
- AC5 verification: partial; Rust checks passed, frontend type-check blocked by missing node_modules/tsc, manual Wayland instructions documented.
- AC6 commit/push: done; current branch commit pushed to `origin/wayland-tray-options`.

## Execution ledger
- [done] Discovery and plan gate completed.
- [done] Tauri tray icon implementation completed.
- [done] Settings/i18n/window lifecycle implementation completed.
- [done] Rust verification completed.
- [partial] Frontend verification attempted; blocked by missing dependencies.
- [done] Write final report, commit, push origin.

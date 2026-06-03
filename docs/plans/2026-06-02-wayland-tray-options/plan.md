# Plan: Wayland tray and close/minimize-to-tray

## Intake
Goal: implement issue #1 for Arch Nuclear: expose close/minimize-to-tray settings and wire desktop tray/window behavior while preserving Arch fork app identity. In scope: settings definitions/i18n/tests, frontend close/minimize event handling, Tauri tray menu/icon, changelog, PR to `blockedby/arch-nuclear` `master`. Out of scope: upstream PRs, merging, broad identifier renames, host installs/destructive cleanup. Done when acceptance criteria are covered by targeted automated checks plus explicit manual/runtime limitations.

## Repo orientation and reuse
- Root `AGENTS.md` and `README.md` read; no child `AGENTS.md` exists below root.
- Settings definitions: `packages/player/src/services/coreSettings.ts`; rendered by `packages/player/src/views/Settings/*` using i18n namespace `preferences` from `packages/i18n/src/locales/en_US.json`.
- Tauri app setup: `packages/player/src-tauri/src/lib.rs`; dependencies in `packages/player/src-tauri/Cargo.toml`; app identity in `packages/player/src-tauri/tauri.conf.json` and `resources/com.nuclearplayer.Nuclear.desktop`.
- Prior prototypes `af84c6dc`/`050bbc2e` add `window.closeToTray`, `window.minimizeToTray`, frontend hook, and Rust tray module; reuse concept but apply cleanly from `origin/master`.

## Missing pieces
- Add visible General settings and English strings for close/minimize to tray.
- Add frontend hook that prevents close and hides on minimize only when configured.
- Expand Tauri with tray icon/menu that can show the main window or quit.
- Add tests for settings visibility and hook behavior; run targeted TS/Rust checks.
- Push branch and open PR linked to issue #1.

## Plan tasks
### Task 1: Settings and frontend behavior
Acceptance: General settings clearly show close/minimize-to-tray toggles; default false preserves normal close/minimize; enabled close prevents close and hides; enabled minimize hides after minimized event. Test plan: targeted Settings test and hook unit test. Executor: owner direct due subagent nesting limit.

### Task 2: Tauri tray/runtime wiring
Acceptance: app builds Rust with tray feature; tray menu uses current default icon and labels, Show restores main window, Quit exits; desktop metadata remains existing `com.nuclearplayer.Nuclear`/`nuclear-music-player` identity. Test plan: `cargo test`/`cargo check` in `packages/player/src-tauri`; metadata file inspection. Executor: owner direct due subagent nesting limit.

### Task 3: Final verification and PR
Acceptance: targeted pnpm tests pass, Rust checks pass, branch pushed, PR to `blockedby/arch-nuclear:master` includes issue #1 and limitation notes. Manual Wayland/KDE runtime evidence is limited if no session is available. Executor: owner.

## Dependency graph
Task 1 and Task 2 can proceed in one stream; Task 3 waits for both. No child slices.

## Execution ledger
- 2026-06-02: worktree created from `origin/master` at `.worktrees/roadmap-wayland-tray-options`; branch `roadmap/wayland-tray-options`.
- 2026-06-02: implemented settings, i18n, frontend hook, Tauri tray module, tests, changelog.
- 2026-06-02: verification passed: targeted Vitest, TypeScript, targeted ESLint, and Rust cargo test (with temporary ignored dist/index.html for RustEmbed). Wayland/KDE live manual check unavailable.

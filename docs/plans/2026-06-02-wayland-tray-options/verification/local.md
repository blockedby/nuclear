# Local verification

Acceptance verification matrix:
- AC: Settings expose the behavior clearly.
  - Covered by: `cd packages/player && corepack pnpm exec vitest run src/hooks/useTrayWindowBehavior.test.tsx src/views/Settings/Settings.test.tsx`
  - Result: passed, 2 files / 5 tests.
  - Evidence: Settings test asserts visible `Close to tray`, `Minimize to tray`, and descriptions in General preferences; snapshot updated.
- AC: Close/minimize-to-tray behavior keeps app alive when configured and quits normally when not configured.
  - Covered by: same Vitest command.
  - Result: passed.
  - Evidence: hook test verifies disabled settings do not call `preventDefault`/`hide`, enabled close calls `preventDefault` and `hide`, enabled minimize hides when minimized.
- AC: Tray icon/window identity remains consistent with Arch desktop metadata.
  - Covered by: file inspection and Rust tests.
  - Result: passed with manual runtime limitation.
  - Evidence: `tauri.conf.json` still has `mainBinaryName: nuclear-music-player`, `identifier: com.nuclearplayer`, `enableGTKAppId: true`; desktop file still has `Exec=nuclear-music-player %u`, `Icon=com.nuclearplayer.Nuclear`. `cargo test` passed after creating temporary `packages/player/dist/index.html` for RustEmbed.
- AC: Targeted tests or manual evidence cover settings and runtime behavior; limitations explicit.
  - Covered by: targeted TS tests and `cargo test`; no live Wayland/KDE session available in this harness.
  - Result: partial runtime manual coverage; automated compile/unit coverage passed.

Commands:
- `cd packages/player && corepack pnpm exec vitest run src/hooks/useTrayWindowBehavior.test.tsx src/views/Settings/Settings.test.tsx` — passed, 2 files / 5 tests.
- `cd packages/player && corepack pnpm exec tsc --noEmit` — passed.
- `cd packages/player && corepack pnpm exec eslint src/hooks/useTrayWindowBehavior.ts src/hooks/useTrayWindowBehavior.test.tsx src/views/Settings/Settings.test.tsx src/test/setup.ts src/App.tsx src/services/coreSettings.ts` — passed.
- `cd packages/player/src-tauri && cargo test` — passed, 24 Rust tests, after creating ignored temporary `packages/player/dist/index.html` because RustEmbed requires `../dist/` during compilation.

Limitations:
- No Wayland/KDE tray session was available, so tray icon display and compositor-specific hide/show behavior are not manually overclaimed.

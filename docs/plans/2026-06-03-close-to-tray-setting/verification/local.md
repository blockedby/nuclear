# Local verification — Close to tray setting

Date: 2026-06-03
Worktree: `/home/kcnc/code/apps/nuclear/.worktrees/roadmap-wayland-tray-options`
Branch: `roadmap/wayland-tray-options`

## RED evidence

- `pnpm --filter @nuclearplayer/player test -- src/hooks/useTrayWindowBehavior.test.tsx src/views/Settings/Settings.test.tsx`
  - Result: not runnable directly because `pnpm` was not on PATH in this shell (`/bin/bash: pnpm: command not found`).
- `corepack pnpm --filter @nuclearplayer/player test -- src/hooks/useTrayWindowBehavior.test.tsx src/views/Settings/Settings.test.tsx`
  - Result: exited 1 as expected after adding RED tests.
  - Relevant failure: `src/hooks/useTrayWindowBehavior.test.tsx > hides the window on close by default` expected `preventDefault` once, got 0.
  - Note: this package-script invocation unexpectedly ran the broader player suite because the path arguments were not applied as intended by the package runner. Subsequent checks used direct `vitest` invocation from `packages/player`.

## GREEN / targeted checks

- `corepack pnpm --dir packages/player exec vitest --run src/hooks/useTrayWindowBehavior.test.tsx src/views/Settings/Settings.test.tsx`
  - First result after implementation: hook behavior passed; settings snapshot mismatch reflected intentional Appearance placement/default-enabled UI change.
- `corepack pnpm --dir packages/player exec vitest --run src/views/Settings/Settings.test.tsx -u`
  - Result: passed, 1 snapshot updated.
- `corepack pnpm --dir packages/player exec vitest --run src/hooks/useTrayWindowBehavior.test.tsx src/views/Settings/Settings.test.tsx`
  - Result: passed, 2 files / 5 tests.
- `corepack pnpm --dir packages/player exec eslint src/services/coreSettings.ts src/hooks/useTrayWindowBehavior.test.tsx src/views/Settings/Settings.test.tsx`
  - Result: passed, no output.

## Manual smoke steps for owner/user

Not run by implementer (no GUI smoke in this scope). Recommended smoke based on user-confirmed Podman GUI launch path:

1. Launch the draft PR app in the Podman GUI smoke environment.
2. Confirm the tray icon exists.
3. With default settings, click the window X and confirm Nuclear hides/minimizes to tray instead of exiting.
4. Restore/show Nuclear from the tray.
5. Open Settings → General/Appearance area and confirm Close to tray is enabled by default.
6. Disable Close to tray.
7. Click the window X again and confirm the app closes normally instead of hiding.
8. If Minimize to tray is enabled, minimize the window and confirm it still hides to tray.

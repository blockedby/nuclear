# Local verification

- `node -e "const fs=require('fs'); const config=JSON.parse(fs.readFileSync('packages/player/src-tauri/tauri.conf.json','utf8')); if (config.app.windows[0].visible !== true) throw new Error('main window is not visible on startup'); console.log('main window visible:', config.app.windows[0].visible);"`
  - Result: passed; output `main window visible: true`.
- `pnpm --filter @nuclearplayer/player test -- src/hooks/useTrayWindowBehavior.test.tsx`
  - Result: not run; `pnpm` was not on PATH in this shell.
- `corepack pnpm --filter @nuclearplayer/player test -- src/hooks/useTrayWindowBehavior.test.tsx`
  - Result: passed. Vitest ran package tests (62 files, including `src/hooks/useTrayWindowBehavior.test.tsx`): `573 passed | 1 todo`.
- `cargo check` from `packages/player/src-tauri`
  - Result: passed with pre-existing warnings in `src/mpd/protocol.rs` for dead code (`Password`, `ACK_ERROR_NO_EXIST`).

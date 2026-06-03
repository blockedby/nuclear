# Close to tray setting plan

## Task intake
Goal: On existing PR #8 branch `roadmap/wayland-tray-options`, implement/finish a low-risk user setting so pressing the window X hides/minimizes Nuclear to tray when enabled, and allows normal close/quit when disabled.

In scope:
- Settings checkbox using existing settings/i18n patterns, visible under Settings General/Appearance as appropriate for existing grouping.
- Tauri window close request handler: enabled => `preventDefault()` and `hide()`; disabled => no interception.
- Preserve/improve existing minimize-to-tray behavior if low-risk.
- Targeted tests for settings/hook behavior where feasible.
- Commit and push to `origin/roadmap/wayland-tray-options`; keep PR #8 draft.

Out of scope:
- Upstream `nukeop` changes.
- Full Tauri bundle/build or costly CI-triggering workflow changes.
- Broad tray/menu redesign.

Done state:
- Checkbox exists with i18n copy and sensible fork default (prefer enabled for tray feature unless existing behavior makes that unsafe).
- Close behavior is covered by targeted test and lightweight checks.
- Branch pushed with coherent commit; PR remains draft.
- Report includes changed files, commit(s), tests, and manual smoke steps.

Blocking unknowns: none; current branch already contains partial tray settings/hook tests, so likely fix is tightening defaults/placement/handler behavior.

## Repo orientation
- Monorepo, player frontend in `packages/player` and i18n in `packages/i18n`.
- Existing settings definitions: `packages/player/src/services/coreSettings.ts` registered via settings store.
- Settings UI groups visible definitions by `category`: `packages/player/src/views/Settings/useSettingsGroups.ts`.
- Existing tray hook: `packages/player/src/hooks/useTrayWindowBehavior.ts`, mounted in `packages/player/src/App.tsx`.
- Existing tests: `packages/player/src/hooks/useTrayWindowBehavior.test.tsx`, `packages/player/src/views/Settings/Settings.test.tsx`, `packages/player/src/stores/settingsStore.test.ts`.
- Relevant commands: targeted `pnpm --filter @nuclearplayer/player test -- <test files>`; no full Tauri bundle/build.

## Reuse discovery
- Reuse `useCoreSetting`, `CORE_SETTINGS`, and `SettingDefinition` boolean toggle widget.
- Reuse existing i18n namespace `preferences.*` in `packages/i18n/src/locales/en_US.json`.
- Reuse Tauri `getCurrentWindow().onCloseRequested` + event `preventDefault()` + `hide()` pattern.
- Reuse existing test mocks for Tauri window and in-memory store.

## Missing pieces
- Verify/adjust close-to-tray setting default and category placement for fork acceptance.
- Ensure close handler behavior matches enabled/disabled setting reliably.
- Update/add tests asserting default behavior, disabled behavior, and Settings visibility/placement.
- Commit/push final change and record verification.

## Plan tasks

### Task 1: Close-to-tray setting and behavior
Goal:
- Make X-to-tray the fork-friendly default behavior while retaining user opt-out for normal close.

Boundary:
- System area: player frontend settings + Tauri window hook.
- Primary verification: targeted Vitest tests for hook and Settings view.

Existing pattern / reuse:
- `packages/player/src/services/coreSettings.ts`
- `packages/player/src/hooks/useTrayWindowBehavior.ts`
- `packages/player/src/views/Settings/Settings.test.tsx`
- `packages/player/src/hooks/useTrayWindowBehavior.test.tsx`
- `packages/i18n/src/locales/en_US.json`

Missing change:
- Set/confirm close-to-tray checkbox copy, visibility under intended Settings section, default enabled if consistent with PR #8.
- Ensure enabled close request prevents default and hides; disabled allows close.

Scope / likely files:
- `packages/player/src/services/coreSettings.ts`
- `packages/player/src/hooks/useTrayWindowBehavior.ts`
- `packages/player/src/hooks/useTrayWindowBehavior.test.tsx`
- `packages/player/src/views/Settings/Settings.test.tsx`
- `packages/i18n/src/locales/en_US.json`

Acceptance criteria:
- Settings UI shows a checkbox/toggle labeled Close to tray or Minimize to tray on close in the expected General/Appearance settings area with i18n description.
- Default setting is suitable for tray PR/fork behavior (enabled unless a discovered branch constraint makes it unsafe).
- With close-to-tray enabled, close request calls `preventDefault()` and hides the window.
- With close-to-tray disabled, close request does not prevent default and does not hide.
- Minimize-to-tray behavior is not regressed.

Test plan:
- Positive: targeted hook test for default/enabled close-to-tray hide behavior.
- Negative: targeted hook test for explicit disabled normal close behavior.
- Regression: targeted settings view test for visible labels/descriptions; existing minimize-to-tray hook test remains passing.
- Manual: user smoke: launch Podman GUI, ensure tray icon exists, click X hides window, restore from tray, disable setting, click X exits/closes normally.

Dependencies:
- Depends on: none.
- Blocks: final owner verification/report.
- Can run parallel with: none; keep slice whole.

Executor:
- aad-implementer.

## Dependency graph / execution ledger
- Task 1 -> aad-implementer, report `reports/aad-implementer-close-to-tray.md`, progress `progress/aad-implementer-close-to-tray.md`.
- Final owner verification after implementation report.


## Final owner ledger

Status: done locally and pushed.

Acceptance verification:
- Settings checkbox and i18n copy visible in Appearance settings: covered by `src/views/Settings/Settings.test.tsx`, passed in owner fresh Vitest run.
- Default close-to-tray enabled for fork/tray behavior: `packages/player/src/services/coreSettings.ts` default `true`; covered by `hides the window on close by default`, passed.
- Enabled close request prevents close and hides: covered by hook test, passed.
- Disabled close request allows normal close: covered by hook test, passed.
- Minimize-to-tray not regressed: covered by hook test, passed.

Verification evidence: `verification/local.md`.
Implementation report: `reports/aad-implementer-close-to-tray.md`.
Open issues: none blocking; no follow-up GitHub issues required.

# PR #8 Wayland tray smoke evidence

## Source

- PR: `#8` / `roadmap/wayland-tray-options` / <https://github.com/blockedby/arch-nuclear/pull/8>
- Evidence source: user's live manual smoke test in a Wayland desktop session.
- Date recorded: 2026-06-03.

## Observed result

- Minimize button: partial success only. The app minimizes, but it does not disappear fully into the tray; it remains visible in the compositor open-app/task list.
- Close X button: failed. Pressing close does not hide to tray or close/quit as expected for the PR behavior.

## Decision

PR #8 is a partial success and is **not acceptable to merge as-is**.

Keep PR #8 draft/open and block merge until a follow-up implementation is live-smoke-tested in the target Wayland desktop session. The current result is useful evidence, but it does not satisfy the tray close/minimize acceptance behavior.

## Likely cause areas for follow-up diagnosis

These are cause areas to inspect later, not fixes attempted in this slice:

1. Close-request interception path: the frontend/Tauri close-request handler may not be registered early enough, may not call/prevent the correct event under Tauri v2, or may not be reached in the tested Wayland runtime.
2. Minimize semantics: the implementation may be reacting after a compositor minimize action rather than replacing it with `hide()`, leaving the window represented in the task/open-app list.
3. Hide vs minimize distinction: Wayland compositor task-list visibility may require explicit hide/unminimize/show sequencing instead of relying on minimize events.
4. Tray/status-notifier availability: AppIndicator/status-notifier host behavior may affect whether a hidden app is recoverable and whether show/quit actions work.
5. Settings/runtime synchronization: close/minimize-to-tray settings may not be loaded or observed by the hook at the moment window events fire.

## Scope guard

No product code changes for PR #8 were made in this slice. This file records evidence and preserves likely diagnosis areas for a future dedicated PR #8 fix pass.
